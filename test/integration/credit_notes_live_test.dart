import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/credit_note_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/customer_payment_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/credit_note.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';

/// Spec 056's repository calls against a live `GET /credit-notes`, as mbe-api
/// spec 034 left it: issued is the backing payment's amount, remaining its
/// unapplied amount, `open_only` filters before paging, a note can be found by
/// its backing payment, and every list keeps to the caller's facility.
///
/// Discovers its fixtures at runtime, so it needs no seeded data, and it is
/// read-only — it creates and applies nothing. In particular it does **not**
/// redeem a note: a redemption writes an application to a real order.
/// Redemption is covered by the controller and widget tests and by the
/// manual walkthrough in quickstart.md. Skipped without credentials.
const _username = String.fromEnvironment('MBE_POS_USERNAME');
const _password = String.fromEnvironment('MBE_POS_PASSWORD');

/// The walk-in customer, whose notes `open_only` leaves out (spec 034 FR-004).
const _walkIn = int.fromEnvironment('POS_DEFAULT_CUSTOMER_ID', defaultValue: 1);

const _canRun = _username != '' && _password != '';

void main() {
  late CreditNoteRepositoryImpl notes;
  late CustomerPaymentRepositoryImpl payments;

  setUpAll(() async {
    if (!_canRun) return;
    final dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
    final token = await AuthRepositoryImpl(
      dio,
    ).login(username: _username, password: _password);
    dio.options.headers['Authorization'] = 'Bearer $token';
    notes = CreditNoteRepositoryImpl(dio);
    payments = CustomerPaymentRepositoryImpl(dio);
  });

  const skip = _canRun ? null : 'needs --dart-define=MBE_POS_USERNAME/PASSWORD';

  Future<List<CreditNote>> readAll({bool openOnly = false}) async {
    final all = <CreditNote>[];
    while (true) {
      final page = await notes.list(
        openOnly: openOnly,
        skip: all.length,
        limit: 100,
      );
      all.addAll(page.items);
      if (page.items.isEmpty || all.length >= page.total) return all;
    }
  }

  test('list pages through every note, and total matches what paging '
      'reaches', () async {
    final first = await notes.list(limit: 100);
    if (first.total == 0) {
      markTestSkipped('this facility has no credit notes');
      return;
    }

    final reached = await readAll();

    expect(reached, hasLength(first.total));
    expect(first.items.first.id, greaterThanOrEqualTo(first.items.last.id));
  }, skip: skip);

  test('open_only keeps exactly the spendable notes, and counts only them '
      '(spec 034 FR-004, FR-007)', () async {
    final open = await readAll(openOnly: true);
    final first = await notes.list(openOnly: true, limit: 1);

    expect(open, hasLength(first.total));
    for (final n in open) {
      expect(n.isOpen, isTrue, reason: 'note ${n.id}');
      expect(n.customerId, isNot(_walkIn), reason: 'note ${n.id}');
    }
  }, skip: skip);

  test(
    'listSpendable returns a customer\'s open notes, oldest first',
    () async {
      final first = await notes.list(openOnly: true, limit: 1);
      if (first.items.isEmpty) {
        markTestSkipped('this facility has no spendable credit note');
        return;
      }
      final anchor = first.items.single;

      final all = await notes.listSpendable(anchor.customerId);

      expect(all.map((n) => n.id), contains(anchor.id));
      expect(all.every((n) => n.customerId == anchor.customerId), isTrue);
      expect(all.every((n) => n.isOpen), isTrue);
      for (var i = 1; i < all.length; i++) {
        final a = all[i - 1].date;
        final b = all[i].date;
        if (a != null && b != null) {
          expect(a.isAfter(b), isFalse, reason: 'note ${all[i - 1].id}');
        }
      }
    },
    skip: skip,
  );

  test('findByPayment finds a note from its ticket number, and nothing for '
      'a number that backs none', () async {
    final first = await notes.list(limit: 1);
    if (first.items.isEmpty) {
      markTestSkipped('this facility has no credit notes');
      return;
    }
    final anchor = first.items.single;

    expect(
      (await notes.findByPayment(anchor.customerPaymentId))?.id,
      anchor.id,
    );
    expect(await notes.findByPayment(1), isNull);
  }, skip: skip);

  test('SC-005: issued is the backing payment\'s amount, and an open note\'s '
      'remaining is its unapplied amount (spec 034 FR-001, FR-002)', () async {
    final sample = (await readAll()).take(20).toList();
    if (sample.isEmpty) {
      markTestSkipped('this facility has no credit notes');
      return;
    }

    final mismatches = <String>[];
    for (final note in sample) {
      final payment = await payments.get(
        customerPaymentId: note.customerPaymentId,
      );
      if (compareAmounts(note.issued, payment.amount) != 0) {
        mismatches.add(
          'note ${note.id}: issued ${note.issued} vs payment ${payment.amount}',
        );
      }
      // A note paid back in cash reports 0 whatever its payment says (FR-002),
      // so only a note with something left is compared.
      if (note.isOpen &&
          compareAmounts(note.remaining, payment.unapplied) != 0) {
        mismatches.add(
          'note ${note.id}: remaining ${note.remaining} vs unapplied '
          '${payment.unapplied}',
        );
      }
    }
    expect(mismatches, isEmpty);
  }, skip: skip);
}
