import 'package:mbe_ui/features/sales/domain/entities/credit_note.dart';

/// Reading credit notes (spec 056 data-model.md §3). Read-only: spending a
/// note is an ordinary application of its backing payment, which
/// `CustomerPaymentRepository.applyPayment` already does.
///
/// Every list keeps to the caller's facility: mbe-api scopes `GET
/// /credit-notes` to it by default (mbe-api spec 034 FR-013), which is also the
/// only facility whose notes the caller may spend (FR-010).
abstract class CreditNoteRepository {
  /// `GET /credit-notes` — one page, newest first as the server orders it.
  /// [openOnly] keeps the notes mbe-api counts as spendable: something left,
  /// not paid back in cash, and not the walk-in customer's (spec 034 FR-004).
  Future<CreditNoteListResult> list({
    int? customerId,
    bool openOnly = false,
    int skip = 0,
    int limit = 20,
  });

  /// Every note [customerId] can spend from their balance, read page by page
  /// until the server's `total` is reached, oldest first.
  Future<List<CreditNote>> listSpendable(int customerId);

  /// The note backed by [customerPaymentId] — the number a ticket prints
  /// under its barcode — or `null` when that payment backs none in the
  /// caller's facility.
  Future<CreditNote?> findByPayment(int customerPaymentId);
}

/// One page of [CreditNote]s and the total across all pages — the same shape
/// as `CustomerPaymentListResult`.
class CreditNoteListResult {
  const CreditNoteListResult({required this.items, required this.total});
  final List<CreditNote> items;
  final int total;
}
