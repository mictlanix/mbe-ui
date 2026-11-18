import 'dart:typed_data';

import 'package:decimal/decimal.dart';

import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_document.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/sat_cancellation_reason.dart';

/// One page of the fiscal documents list.
class FiscalDocumentPage {
  const FiscalDocumentPage({required this.items, required this.total});

  final List<FiscalDocumentSummary> items;
  final int total;
}

/// The stored XML of a document and the name the server gave it, if any.
class XmlDownload {
  const XmlDownload({required this.bytes, this.filename});

  final Uint8List bytes;
  final String? filename;
}

/// Fiscal documents over `/fiscal-documents` (spec 066 research R3). Every
/// write returns the whole updated document.
abstract class FiscalDocumentRepository {
  /// `GET /fiscal-documents`, newest first.
  Future<FiscalDocumentPage> list({
    String? search,
    String? issuer,
    int? type,
    FiscalDocumentStatus? status,
    DateTime? dateFrom,
    DateTime? dateTo,
    int skip = 0,
    int limit = 20,
  });

  /// `GET /fiscal-documents/{id}`.
  Future<FiscalDocument> getById(int id);

  /// `GET /fiscal-documents/{id}/xml`: the stored XML of a stamped document.
  Future<XmlDownload> downloadXml(int id);

  /// `POST /fiscal-documents`: a new invoice draft.
  Future<FiscalDocument> create(NewInvoice invoice);

  /// `POST /fiscal-documents/credit-notes`: a credit-note draft for issued
  /// invoice [invoiceId] (spec 073).
  Future<FiscalDocument> createCreditNote(int invoiceId);

  /// `PUT /fiscal-documents/{id}`: only the patch's non-null fields change.
  Future<FiscalDocument> updateHeader(int id, InvoiceHeaderPatch patch);

  /// `POST /fiscal-documents/{id}/sales-orders`: adds an order's invoiceable
  /// lines (re-adding duplicates nothing).
  Future<FiscalDocument> addSalesOrder(int id, int salesOrderId);

  /// `POST /fiscal-documents/{id}/lines`: a manual product line.
  Future<FiscalDocument> addProduct(int id, int productId);

  /// `POST /fiscal-documents/{id}/invoice-lines`: copies one line of the
  /// credit note's invoice at [quantity] (spec 073).
  Future<FiscalDocument> copyInvoiceLine(
    int id,
    int invoiceLineId, {
    required Decimal quantity,
  });

  /// `PUT /fiscal-documents/{id}/lines/{lineId}`.
  Future<FiscalDocument> updateLine(int id, int lineId, InvoiceLinePatch patch);

  /// `DELETE /fiscal-documents/{id}/lines/{lineId}`.
  Future<FiscalDocument> removeLine(int id, int lineId);

  /// `POST /fiscal-documents/{id}/relations`.
  Future<FiscalDocument> addRelation(
    int id,
    int documentId,
    InvoiceRelationType type,
  );

  /// `DELETE /fiscal-documents/{id}/relations/{relationId}`.
  Future<FiscalDocument> removeRelation(int id, int relationId);

  /// `POST /fiscal-documents/{id}/confirm`: validates and seals.
  Future<FiscalDocument> confirm(int id);

  /// `POST /fiscal-documents/{id}/reopen`: a sealed invoice back to draft.
  Future<FiscalDocument> reopen(int id);

  /// `POST /fiscal-documents/{id}/stamp`: sends the sealed document to the PAC.
  /// A timeout leaves it stamping; [refresh] resolves it.
  Future<FiscalDocument> stamp(int id);

  /// `POST /fiscal-documents/{id}/cancel`: asks SAT, through the PAC, to cancel
  /// an issued document. [substitution] is the replacement's UUID, for reason
  /// 01 only.
  Future<FiscalDocument> cancel(
    int id,
    SatCancellationReason reason, {
    String? substitution,
  });

  /// `POST /fiscal-documents/{id}/refresh`: asks the PAC what became of a stamp
  /// or a cancellation in process. Answers the document as it now is, which is
  /// unchanged while it is still in process.
  Future<FiscalDocument> refresh(int id);
}
