import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/sales/domain/entities/credit_note.dart';
import 'package:mbe_ui/features/sales/domain/entities/customer_refund.dart';
import 'package:mbe_ui/features/sales/pos_defaults.dart';
import 'package:mbe_ui/features/sales/presentation/refunds/refund_outcome_provider.dart';

import '../../../widget/features/sales/pos_test_harness.dart';

const _note = CreditNote(
  id: 1,
  customerId: 7,
  salesOrderId: 42,
  customerRefundId: 9,
  customerPaymentId: 300001,
  issued: '20.00',
  remaining: '20.00',
);

void main() {
  late MockCreditNoteRepository notes;

  setUp(() => notes = MockCreditNoteRepository());

  Future<RefundOutcome?> outcomeOf(CustomerRefund refund) {
    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [creditNoteOverride(notes)],
    );
    addTearDown(container.dispose);
    return container.read(refundOutcomeProvider(refund).future);
  }

  void stubFind(Future<CreditNote?> Function() answer) => when(
    () => notes.findByRefund(
      customerId: any(named: 'customerId'),
      refundId: any(named: 'refundId'),
      refundDate: any(named: 'refundDate'),
    ),
  ).thenAnswer((_) => answer());

  CustomerRefund completed({int? customerId = 7}) => testRefund(
    status: RefundStatus.completed,
    serial: 5,
    customerId: customerId,
  );

  test('a matching note maps to creditNote', () async {
    stubFind(() async => _note);

    final outcome = await outcomeOf(completed());

    expect(outcome, const RefundOutcome.creditNote(_note));
    verify(
      () => notes.findByRefund(
        customerId: 7,
        refundId: 9,
        refundDate: DateTime(2026, 10, 28),
      ),
    ).called(1);
  });

  test('no match maps to cash', () async {
    stubFind(() async => null);

    expect(await outcomeOf(completed()), const RefundOutcome.cash());
  });

  test('the generic customer is scanned like any other', () async {
    stubFind(() async => null);

    final outcome = await outcomeOf(
      completed(customerId: posDefaultCustomerId),
    );

    expect(outcome, const RefundOutcome.cash());
    verify(
      () => notes.findByRefund(
        customerId: posDefaultCustomerId,
        refundId: 9,
        refundDate: any(named: 'refundDate'),
      ),
    ).called(1);
  });

  test('no customer maps to unknown without a lookup', () async {
    final outcome = await outcomeOf(completed(customerId: null));

    expect(outcome, const RefundOutcome.unknown());
    verifyNever(
      () => notes.findByRefund(
        customerId: any(named: 'customerId'),
        refundId: any(named: 'refundId'),
        refundDate: any(named: 'refundDate'),
      ),
    );
  });

  test('a thrown error maps to unknown', () async {
    stubFind(() async => throw const AppError.network());

    expect(await outcomeOf(completed()), const RefundOutcome.unknown());
  });

  test('a draft has no outcome and no lookup', () async {
    expect(await outcomeOf(testRefund()), isNull);
    verifyNever(
      () => notes.findByRefund(
        customerId: any(named: 'customerId'),
        refundId: any(named: 'refundId'),
        refundDate: any(named: 'refundDate'),
      ),
    );
  });
}
