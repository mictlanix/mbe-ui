import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/customer_payment_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/customer_payment.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';

/// Spec 054's repository calls against a live `GET /customer-payments`,
/// `/search`, `/{id}` and `/{id}/applications` — and SC-003: the server's
/// `unapplied` is the amount less the applications that still stand, which is
/// exactly what the payment screen's Aplicado line is built from.
///
/// Discovers its fixtures at runtime, so it needs no seeded data: it finds
/// payments through the cross-facility search (the `MBE_POS_*` account is the
/// administrator), then reads them back through every other call. Read-only —
/// it creates nothing, so it leaves nothing behind. Skipped without
/// credentials.
const _username = String.fromEnvironment('MBE_POS_USERNAME');
const _password = String.fromEnvironment('MBE_POS_PASSWORD');

const _canRun = _username != '' && _password != '';

void main() {
  test(
    'lists, searches and reads payments, and unapplied = amount − applied',
    () async {
      final dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
      final token = await AuthRepositoryImpl(
        dio,
      ).login(username: _username, password: _password);
      dio.options.headers['Authorization'] = 'Bearer $token';
      final repository = CustomerPaymentRepositoryImpl(dio);

      final watch = Stopwatch()..start();
      void lap(String what) {
        // ignore: avoid_print
        print('${watch.elapsed.inMilliseconds} ms — $what');
      }

      final found = await repository.searchAcrossFacilities(limit: 10);
      lap('searchAcrossFacilities');
      if (found.items.isEmpty) {
        markTestSkipped('this tenant has no customer payments');
        return;
      }
      // ignore: avoid_print
      print(
        'discovered ${found.total} payments; examining ${found.items.length}',
      );

      // SC-003: the figure the screen shows as Sin aplicar is the amount less
      // the non-reversed applications, and `get` agrees with the list.
      final mismatches = <String>[];
      for (final payment in found.items) {
        final read = await repository.get(
          customerPaymentId: payment.customerPaymentId,
        );
        expect(read.customerPaymentId, payment.customerPaymentId);
        expect(read.facilityId, payment.facilityId);

        final applications = await repository.listApplications(
          customerPaymentId: payment.customerPaymentId,
        );
        var applied = '0';
        for (final application in applications.where((a) => !a.reversed)) {
          applied = addAmounts(applied, application.amount);
        }
        final expected = subtractAmounts(read.amount, applied);
        if (compareAmounts(expected, read.unapplied) != 0) {
          mismatches.add(
            '#${read.customerPaymentId}: amount ${read.amount} − applied '
            '$applied = $expected, server unapplied ${read.unapplied}',
          );
        }
      }
      expect(
        mismatches,
        isEmpty,
        reason: 'unapplied must equal amount − Σ non-reversed applications',
      );

      // The facility-scoped list finds a payment of that facility, and
      // narrows by customer.
      final sample = found.items.first;
      lap('applications and reads');
      final scoped = await repository.list(
        facilityId: sample.facilityId,
        customerId: sample.customerId,
        limit: 100,
      );
      expect(
        scoped.items.map((p) => p.customerPaymentId),
        contains(sample.customerPaymentId),
      );
      expect(
        scoped.items.every((p) => p.facilityId == sample.facilityId),
        isTrue,
      );
      expect(
        scoped.items.every((p) => p.customerId == sample.customerId),
        isTrue,
      );

      lap('list by facility + customer');
      // `verified` is tri-state on the wire.
      final unverified = await repository.list(
        facilityId: sample.facilityId,
        verified: false,
        limit: 50,
      );
      expect(unverified.items.every((p) => p.verifierId == null), isTrue);
      final verified = await repository.list(
        facilityId: sample.facilityId,
        verified: true,
        limit: 50,
      );
      expect(verified.items.every((p) => p.verifierId != null), isTrue);

      lap('verified true/false');
      // Reference search finds a payment by a fragment of its reference. The
      // newest payments are counter cash and carry none, so look among the
      // methods that do: transfer (3), cheque (2), credit card (4).
      CustomerPayment? withReference;
      for (final method in [3, 2, 4]) {
        final page = await repository.list(
          facilityId: sample.facilityId,
          methodCode: method,
          limit: 50,
        );
        withReference = page.items
            .where((p) => (p.reference ?? '').trim().length >= 4)
            .firstOrNull;
        if (withReference != null) break;
      }
      lap('reference lookup');
      if (withReference == null) {
        // Not `markTestSkipped`: that would mark the whole test skipped and
        // hide that everything above it ran and passed.
        // ignore: avoid_print
        print(
          'no payment with a reference found; reference search not checked',
        );
        return;
      }
      final reference = withReference.reference!.trim();
      final fragment = reference.substring(1, 4).toLowerCase();
      final byReference = await repository.searchAcrossFacilities(
        reference: fragment,
        limit: 100,
      );
      expect(
        byReference.items.map((p) => p.customerPaymentId),
        contains(withReference.customerPaymentId),
        reason: 'a case-insensitive fragment ("$fragment") of "$reference"',
      );
    },
    // A dev tenant can hold hundreds of thousands of payments, and every list
    // call counts them; the default 30 s is not enough.
    timeout: const Timeout(Duration(minutes: 4)),
    skip: _canRun ? null : 'needs --dart-define=MBE_POS_USERNAME/PASSWORD',
  );
}
