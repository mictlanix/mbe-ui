import 'package:decimal/decimal.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/invoicing/data/fiscal_document_repository_impl.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_document.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/sat_cancellation_reason.dart';
import 'package:mbe_ui/features/invoicing/domain/repositories/fiscal_document_repository.dart';
import 'package:mbe_ui/features/invoicing/presentation/fiscal_document_detail_controller.dart';
import 'package:mbe_ui/features/invoicing/presentation/fiscal_documents_list_controller.dart';

part 'fiscal_document_actions.g.dart';

/// Every write on a fiscal document (spec 066 R6).
///
/// Each method answers the [AppError] the server refused with, or `null` when
/// it went through, rather than throwing: the dialog that asked shows the
/// refusal where the user is looking. A [NetworkError] means the request may
/// or may not have landed, so the screen words it as an unknown result.
///
/// The detail is always invalidated, so the screen refetches what the server
/// now holds and never takes the document from the write's response. The list
/// is invalidated too unless the server refused, since only then is it known
/// that nothing changed.
///
/// Keep-alive because a write outlives the dialog that started it.
@Riverpod(keepAlive: true)
class FiscalDocumentActions extends _$FiscalDocumentActions {
  @override
  void build() {}

  /// `POST /fiscal-documents`. Answers the new document's id, or the refusal.
  Future<({AppError? error, int? id})> create(NewInvoice invoice) async {
    try {
      final doc = await ref
          .read(fiscalDocumentRepositoryProvider)
          .create(invoice);
      ref.invalidate(fiscalDocumentsListControllerProvider);
      return (error: null, id: doc.id);
    } on AppError catch (e) {
      if (e is NetworkError) {
        ref.invalidate(fiscalDocumentsListControllerProvider);
      }
      return (error: e, id: null);
    }
  }

  /// `POST /fiscal-documents/credit-notes` (spec 073). Answers the new credit
  /// note's id, or the refusal.
  Future<({AppError? error, int? id})> createCreditNote(int invoiceId) async {
    try {
      final doc = await ref
          .read(fiscalDocumentRepositoryProvider)
          .createCreditNote(invoiceId);
      ref.invalidate(fiscalDocumentsListControllerProvider);
      return (error: null, id: doc.id);
    } on AppError catch (e) {
      if (e is NetworkError) {
        ref.invalidate(fiscalDocumentsListControllerProvider);
      }
      return (error: e, id: null);
    }
  }

  /// `PUT /fiscal-documents/{id}`.
  Future<AppError?> updateHeader(int id, InvoiceHeaderPatch patch) =>
      _run(id, (r) => r.updateHeader(id, patch));

  /// `POST /fiscal-documents/{id}/sales-orders`.
  Future<AppError?> addSalesOrder(int id, int salesOrderId) =>
      _run(id, (r) => r.addSalesOrder(id, salesOrderId));

  /// `POST /fiscal-documents/{id}/lines`.
  Future<AppError?> addProduct(int id, int productId) =>
      _run(id, (r) => r.addProduct(id, productId));

  /// `POST /fiscal-documents/{id}/invoice-lines`, once per entry of [lines], in
  /// the order given (spec 073 R1). It stops at the first refusal and answers
  /// how many were added and which line was refused. The detail is refetched
  /// once, at the end.
  // simplified: one request per line, no batch route on the server; ask for
  // one if returns commonly span more than a few dozen lines.
  Future<({int added, AppError? error, int? failedLineId})> copyInvoiceLines(
    int id,
    List<({int lineId, Decimal quantity})> lines,
  ) async {
    final repository = ref.read(fiscalDocumentRepositoryProvider);
    var added = 0;
    AppError? error;
    int? failedLineId;
    for (final line in lines) {
      try {
        await repository.copyInvoiceLine(
          id,
          line.lineId,
          quantity: line.quantity,
        );
        added++;
      } on AppError catch (e) {
        error = e;
        failedLineId = line.lineId;
        break;
      }
    }
    ref.invalidate(fiscalDocumentDetailProvider(id));
    if (added > 0 || error is NetworkError) {
      ref.invalidate(fiscalDocumentsListControllerProvider);
    }
    return (added: added, error: error, failedLineId: failedLineId);
  }

  /// `PUT /fiscal-documents/{id}/lines/{lineId}`.
  Future<AppError?> updateLine(int id, int lineId, InvoiceLinePatch patch) =>
      _run(id, (r) => r.updateLine(id, lineId, patch));

  /// `DELETE /fiscal-documents/{id}/lines/{lineId}`.
  Future<AppError?> removeLine(int id, int lineId) =>
      _run(id, (r) => r.removeLine(id, lineId));

  /// `POST /fiscal-documents/{id}/relations`.
  Future<AppError?> addRelation(
    int id,
    int documentId,
    InvoiceRelationType type,
  ) => _run(id, (r) => r.addRelation(id, documentId, type));

  /// `DELETE /fiscal-documents/{id}/relations/{relationId}`.
  Future<AppError?> removeRelation(int id, int relationId) =>
      _run(id, (r) => r.removeRelation(id, relationId));

  /// `POST /fiscal-documents/{id}/confirm`.
  Future<AppError?> confirm(int id) => _run(id, (r) => r.confirm(id));

  /// `POST /fiscal-documents/{id}/reopen`.
  Future<AppError?> reopen(int id) => _run(id, (r) => r.reopen(id));

  /// `POST /fiscal-documents/{id}/stamp` (spec 072): sends the sealed
  /// document to the PAC. A PAC timeout is a refusal (`pac.timeout`), and the
  /// reloaded detail then shows the document as stamping.
  Future<AppError?> stamp(int id) => _run(id, (r) => r.stamp(id));

  /// `POST /fiscal-documents/{id}/cancel` (spec 072). [substitution] is the
  /// replacement's UUID, for reason 01 only.
  Future<AppError?> cancel(
    int id,
    SatCancellationReason reason, {
    String? substitution,
  }) => _run(id, (r) => r.cancel(id, reason, substitution: substitution));

  /// `POST /fiscal-documents/{id}/refresh` (spec 072). Answers the status the
  /// server returned, so the screen can tell "still in process" (the same
  /// status as before) from a resolved document. `status` is `null` when the
  /// server refused.
  Future<({AppError? error, FiscalDocumentStatus? status})> refresh(
    int id,
  ) async {
    final result = await _attempt(id, (r) => r.refresh(id));
    return (error: result.error, status: result.value?.status);
  }

  Future<AppError?> _run(
    int id,
    Future<Object?> Function(FiscalDocumentRepository repository) write,
  ) async => (await _attempt(id, write)).error;

  Future<({AppError? error, T? value})> _attempt<T>(
    int id,
    Future<T> Function(FiscalDocumentRepository repository) write,
  ) async {
    AppError? error;
    T? value;
    try {
      value = await write(ref.read(fiscalDocumentRepositoryProvider));
    } on AppError catch (e) {
      error = e;
    }
    ref.invalidate(fiscalDocumentDetailProvider(id));
    if (error == null || error is NetworkError) {
      ref.invalidate(fiscalDocumentsListControllerProvider);
    }
    return (error: error, value: value);
  }
}
