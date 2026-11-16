import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:mbe_ui/features/catalog/domain/entities/fiscal_document_kind.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/invoice_amounts.dart';

part 'fiscal_document.freezed.dart';

/// The state of a fiscal document, derived on the server (spec 066
/// data-model §1). Only a draft is editable.
enum FiscalDocumentStatus { draft, sealed, issued, cancelled }

/// PUE (one payment) or PPD (deferred). Named apart from the sales
/// `PaymentTerms`, which is a different concept.
enum InvoicePaymentTerms { pue, ppd }

/// The VAT rates a line can take. The wire value is a decimal string.
enum InvoiceTaxRate {
  iva16,
  zero,
  exempt;

  /// The rate as the API exchanges it (exempt is -1).
  Decimal get rate => switch (this) {
    InvoiceTaxRate.iva16 => Decimal.parse('0.16'),
    InvoiceTaxRate.zero => Decimal.zero,
    InvoiceTaxRate.exempt => Decimal.fromInt(-1),
  };

  /// The tax rate for a wire value, or null for one this app doesn't know.
  static InvoiceTaxRate? fromRate(Decimal rate) {
    for (final r in values) {
      if (r.rate == rate) return r;
    }
    return null;
  }
}

/// The CFDI relation type: 04 and 07 can be added, 01 is read only.
enum InvoiceRelationType {
  substitution('04'),
  advanceApplication('07'),
  creditNoteOf('01');

  const InvoiceRelationType(this.code);
  final String code;

  static InvoiceRelationType? fromCode(String? code) {
    for (final t in values) {
      if (t.code == code) return t;
    }
    return null;
  }
}

/// One row of the fiscal documents list.
@freezed
abstract class FiscalDocumentSummary with _$FiscalDocumentSummary {
  const FiscalDocumentSummary._();

  const factory FiscalDocumentSummary({
    required int id,
    required int typeCode,
    required String version,
    String? series,

    /// Null until the first confirm.
    int? serial,
    required String issuerRfc,
    String? issuerName,
    String? recipientRfc,
    String? recipientName,

    /// Mexico City wall-clock time (spec 043); null on a draft.
    DateTime? issued,
    String? stampUuid,
    required FiscalDocumentStatus status,

    /// Null on a draft: the server reads it from the XML.
    Decimal? total,
  }) = _FiscalDocumentSummary;

  FiscalDocumentKind? get kind => FiscalDocumentKind.fromCode(typeCode);

  /// `"{series}{serial}"`, or null while there is no serial.
  String? get folioLabel => serial == null ? null : '${series ?? ''}$serial';
}

/// A line of an invoice.
@freezed
abstract class InvoiceLine with _$InvoiceLine {
  const InvoiceLine._();

  const factory InvoiceLine({
    required int id,
    int? productId,

    /// Non-null when the line came from a sales order.
    int? orderLineId,
    String? productCode,
    required String productName,
    String? satProductKey,
    String? unitKey,
    String? unitName,
    required Decimal quantity,
    required Decimal price,

    /// A fraction, 0–1.
    required Decimal discountRate,

    /// 0.16, 0 or -1 (exempt).
    required Decimal taxRate,
    required bool taxIncluded,
    String? comment,
  }) = _InvoiceLine;

  LineAmounts get amounts => lineAmounts(this);
  InvoiceTaxRate? get tax => InvoiceTaxRate.fromRate(taxRate);
}

/// A document related to an invoice.
@freezed
abstract class InvoiceRelation with _$InvoiceRelation {
  const factory InvoiceRelation({
    required int id,
    required int documentId,
    InvoiceRelationType? type,
    String? stampUuid,
    String? series,
    int? serial,
  }) = _InvoiceRelation;
}

/// A fiscal document in full.
@freezed
abstract class FiscalDocument with _$FiscalDocument {
  const FiscalDocument._();

  const factory FiscalDocument({
    required FiscalDocumentSummary summary,
    String? issuerRegime,
    String? issuerRegimeName,
    int? customerId,
    int? facilityId,
    required String issuedLocation,
    String? taxpayerRegime,
    String? taxpayerPostalCode,
    String? usage,
    required InvoicePaymentTerms paymentTerms,
    required int paymentForm,
    required int currencyCode,
    required Decimal exchangeRate,
    String? reference,
    String? comment,
    DateTime? stamped,
    DateTime? cancellationDate,
    String? cancellationReason,
    @Default(<InvoiceLine>[]) List<InvoiceLine> lines,
    @Default(<InvoiceRelation>[]) List<InvoiceRelation> relations,
  }) = _FiscalDocument;

  int get id => summary.id;
  FiscalDocumentStatus get status => summary.status;
  bool get isInvoice => summary.typeCode == 0;
  bool get isEditableDraft => isInvoice && status == FiscalDocumentStatus.draft;
  bool get canReopen => isInvoice && status == FiscalDocumentStatus.sealed;

  /// PDF and XML are offered; the server still refuses unstamped or pre-4.0.
  bool get hasDocuments =>
      status == FiscalDocumentStatus.issued ||
      status == FiscalDocumentStatus.cancelled;

  bool get hasRelations => relations.isNotEmpty;

  /// The type shared by the relations, or null when there are none.
  InvoiceRelationType? get relationType =>
      relations.isEmpty ? null : relations.first.type;

  InvoiceAmounts get amounts => invoiceAmounts(lines);
}

/// Start an invoice for a customer's RFC.
@freezed
abstract class NewInvoice with _$NewInvoice {
  const factory NewInvoice({
    required int customerId,
    required String recipientRfc,
  }) = _NewInvoice;
}

/// A partial header update: only non-null fields are sent. An empty
/// [reference] or [comment] clears it.
@freezed
abstract class InvoiceHeaderPatch with _$InvoiceHeaderPatch {
  const factory InvoiceHeaderPatch({
    String? recipientRfc,
    String? series,
    String? usage,
    InvoicePaymentTerms? paymentTerms,
    int? paymentForm,
    DateTime? issued,
    int? facilityId,
    String? reference,
    String? comment,
  }) = _InvoiceHeaderPatch;
}

/// A partial line update. [discountPercent] is 0–100 here and a 0–1 fraction
/// on the wire. A blank [productName] resets to the product's name.
@freezed
abstract class InvoiceLinePatch with _$InvoiceLinePatch {
  const factory InvoiceLinePatch({
    Decimal? quantity,
    Decimal? price,
    Decimal? discountPercent,
    InvoiceTaxRate? taxRate,
    String? productCode,
    String? productName,
    String? comment,
  }) = _InvoiceLinePatch;
}
