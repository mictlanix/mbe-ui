import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/features/sales/data/credit_note_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/customer_refund.dart';

part 'refund_outcome_provider.g.dart';

/// How a completed refund was paid out (spec 057 R6), or `null` for a draft
/// or cancelled one, which has no payout.
// simplified: scans the customer's notes; replace with the refund's own payout fields when mbe-api#286 ships
@riverpod
Future<RefundOutcome?> refundOutcome(Ref ref, CustomerRefund refund) async {
  if (refund.status != RefundStatus.completed) return null;
  final customerId = refund.customerId;
  final date = refund.date;
  if (customerId == null || date == null) return const RefundOutcome.unknown();
  try {
    final note = await ref
        .read(creditNoteRepositoryProvider)
        .findByRefund(
          customerId: customerId,
          refundId: refund.id,
          refundDate: date,
        );
    return note == null
        ? const RefundOutcome.cash()
        : RefundOutcome.creditNote(note);
  } on Object {
    return const RefundOutcome.unknown();
  }
}
