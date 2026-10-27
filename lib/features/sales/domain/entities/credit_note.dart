import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/features/sales/domain/money.dart';

part 'credit_note.freezed.dart';

/// Store credit a refund leaves with a customer, mapped from
/// `CreditNoteResponse` (spec 056 data-model.md §1).
///
/// A credit note is a view over its backing customer payment, so spending one
/// is an ordinary application of [customerPaymentId] to an order — there is no
/// redemption record of its own. [customerPaymentId] is also the number
/// printed under the ticket's barcode.
///
/// `cash_session` is deliberately not mapped: whether a note was paid out in
/// cash is the server's call, reported through [remaining] (mbe-api#277).
@freezed
abstract class CreditNote with _$CreditNote {
  const CreditNote._();

  const factory CreditNote({
    required int id,
    required int customerId,

    /// The order the refund came from.
    required int salesOrderId,
    required int customerRefundId,

    /// The backing payment; its id is the ticket number.
    required int customerPaymentId,

    /// The server's `refunded` figure, shown as sent. It reads 0 on legacy
    /// notes until mbe-api#277 ships.
    required String issued,

    /// What is left to spend, as the server reports it. Never recomputed
    /// client-side (spec 056 FR-015).
    required String remaining,
    DateTime? date,
  }) = _CreditNote;

  factory CreditNote.fromResponse(api.CreditNoteResponse r) => CreditNote(
    id: r.creditNoteId,
    customerId: r.customer,
    salesOrderId: r.salesOrder,
    customerRefundId: r.customerRefund,
    customerPaymentId: r.customerPayment,
    issued: r.refunded,
    remaining: r.remaining,
    date: r.date,
  );

  /// Whether there is anything left to spend.
  bool get isOpen => compareAmounts(remaining, '0') > 0;
}
