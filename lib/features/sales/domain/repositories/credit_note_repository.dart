import 'package:mbe_ui/features/sales/domain/entities/credit_note.dart';

/// Reading credit notes (spec 056 data-model.md §3). Read-only: spending a
/// note is an ordinary application of its backing payment, which
/// `CustomerPaymentRepository.applyPayment` already does.
///
/// No method here turns `open_only` on — mbe-api#278 makes it page before it
/// filters, so a first page can come back empty while open notes exist.
/// Callers that want open notes filter on [CreditNote.isOpen] themselves.
abstract class CreditNoteRepository {
  /// `GET /credit-notes` — one page, newest first as the server orders it.
  Future<CreditNoteListResult> list({
    int? customerId,
    int skip = 0,
    int limit = 20,
  });

  /// Every note a customer holds, read page by page until the server's
  /// `total` is reached, oldest first.
  Future<List<CreditNote>> listForCustomer(int customerId);

  /// The note backed by [customerPaymentId], or `null` when [customerId]
  /// holds none. Pages newest first and stops at the first match.
  Future<CreditNote?> findByPayment({
    required int customerPaymentId,
    required int customerId,
  });
}

/// One page of [CreditNote]s and the total across all pages — the same shape
/// as `CustomerPaymentListResult`.
class CreditNoteListResult {
  const CreditNoteListResult({required this.items, required this.total});
  final List<CreditNote> items;
  final int total;
}
