import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/credit_note_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/customer_payment_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/credit_note.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';

/// Spec 056's repository calls against a live `GET /credit-notes`, and SC-005:
/// for a note that has an amount issued, the list's figures agree with its
/// backing payment.
///
/// Discovers its fixtures at runtime, so it needs no seeded data, and it is
/// read-only — it creates and applies nothing. In particular it does **not**
/// redeem a note: a redemption writes an application to a real order, and no
/// note on the dev tenant is a safe fixture for it (legacy notes report 0
/// remaining until mbe-api#277 ships, and note 158 was paid out in cash).
/// Redemption is covered by the controller and widget tests and by the
/// manual walkthrough in quickstart.md. Skipped without credentials.
const _username = String.fromEnvironment('MBE_POS_USERNAME');
const _password = String.fromEnvironment('MBE_POS_PASSWORD');

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

  test(
    'list pages through every note, and total matches what paging reaches',
    () async {
      final first = await notes.list(limit: 100);
      if (first.total == 0) {
        markTestSkipped('this tenant has no credit notes');
        return;
      }

      final reached = <CreditNote>[...first.items];
      var skipped = first.items.length;
      while (skipped < first.total) {
        final page = await notes.list(skip: skipped, limit: 100);
        if (page.items.isEmpty) break;
        reached.addAll(page.items);
        skipped += page.items.length;
      }

      expect(reached, hasLength(first.total));
      // Newest first, as the list shows them.
      expect(first.items.first.id, greaterThanOrEqualTo(first.items.last.id));
    },
    skip: skip,
  );

  test('listForCustomer returns the customer\'s notes, oldest first', () async {
    final first = await notes.list(limit: 1);
    if (first.items.isEmpty) {
      markTestSkipped('this tenant has no credit notes');
      return;
    }
    final anchor = first.items.single;

    final all = await notes.listForCustomer(anchor.customerId);

    expect(all.map((n) => n.id), contains(anchor.id));
    expect(all.every((n) => n.customerId == anchor.customerId), isTrue);
    for (var i = 1; i < all.length; i++) {
      final a = all[i - 1].date;
      final b = all[i].date;
      if (a != null && b != null) {
        expect(
          a.isAfter(b),
          isFalse,
          reason: 'note ${all[i - 1].id} should not follow ${all[i].id}',
        );
      }
    }
  }, skip: skip);

  test('findByPayment finds a note from its ticket number', () async {
    final first = await notes.list(limit: 1);
    if (first.items.isEmpty) {
      markTestSkipped('this tenant has no credit notes');
      return;
    }
    final anchor = first.items.single;

    final found = await notes.findByPayment(
      customerPaymentId: anchor.customerPaymentId,
      customerId: anchor.customerId,
    );

    expect(found?.id, anchor.id);
  }, skip: skip);

  test('findByPayment is null for a number that backs no note', () async {
    final first = await notes.list(limit: 1);
    if (first.items.isEmpty) {
      markTestSkipped('this tenant has no credit notes');
      return;
    }
    final anchor = first.items.single;

    expect(
      await notes.findByPayment(
        customerPaymentId: 1,
        customerId: anchor.customerId,
      ),
      isNull,
    );
  }, skip: skip);

  test('SC-005: remaining agrees with the backing payment for notes whose '
      'issued amount is the payment\'s own', () async {
    // The fixture is found at runtime: a note with an amount issued whose
    // backing payment is for exactly that amount. Anything else is a legacy
    // note — nothing issued (mbe-api#277), or a payment that is not the note's
    // alone — and is reported, not failed on: that is the upstream data's
    // shape, not this feature's.
    final candidates = <CreditNote>[];
    var skipped = 0;
    while (true) {
      final page = await notes.list(skip: skipped, limit: 100);
      candidates.addAll(
        page.items.where((n) => compareAmounts(n.issued, '0') > 0),
      );
      skipped += page.items.length;
      if (page.items.isEmpty || skipped >= page.total) break;
    }

    final mismatches = <String>[];
    var checked = 0;
    for (final note in candidates.take(20)) {
      final payment = await payments.get(
        customerPaymentId: note.customerPaymentId,
      );
      if (compareAmounts(note.issued, payment.amount) != 0) {
        // ignore: avoid_print
        print(
          'legacy note ${note.id}: issued ${note.issued} but its payment is '
          '${payment.amount} — not checked',
        );
        continue;
      }
      checked++;
      if (compareAmounts(note.remaining, payment.unapplied) != 0) {
        mismatches.add(
          'note ${note.id}: remaining ${note.remaining} vs unapplied '
          '${payment.unapplied}',
        );
      }
    }
    if (checked == 0) {
      markTestSkipped('no note on this tenant has issued == its payment');
      return;
    }
    expect(mismatches, isEmpty);
  }, skip: skip);
}
