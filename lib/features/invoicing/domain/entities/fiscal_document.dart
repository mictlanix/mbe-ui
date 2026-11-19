import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:mbe_ui/core/domain/payment_method.dart';
import 'package:mbe_ui/features/catalog/domain/entities/fiscal_document_kind.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_cancellation.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_stamp.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/invoice_amounts.dart';

part 'fiscal_document.freezed.dart';

/// The state of a fiscal document, derived on the server (spec 066
/// data-model §1, spec 072 data-model). Only a draft is editable. The order is
/// the lifecycle's, which is the order the list's state filter shows.
enum FiscalDocumentStatus {
  draft('draft'),
  sealed('sealed'),
  stamping('stamping'),
  issued('issued'),
  cancellationPending('cancellation_pending'),
  cancelled('cancelled');

  const FiscalDocumentStatus(this.wireName);

  /// The value on the wire and in the list's URL. It is not [name]:
  /// `cancellationPending` goes as `cancellation_pending`.
  final String wireName;

  /// `null` for a value that is none of the six.
  static FiscalDocumentStatus? fromWire(String? wire) =>
      values.where((s) => s.wireName == wire).firstOrNull;
}

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

/// One PPD invoice a payment receipt pays (spec 074 data-model). The values
/// are the server's: live on a draft, stored once the receipt is sealed.
@freezed
abstract class PaidInvoice with _$PaidInvoice {
  const PaidInvoice._();

  const factory PaidInvoice({
    /// The id the update and remove routes take.
    required int relationId,
    required int invoiceId,
    String? series,
    int? serial,
    String? stampUuid,
    required int installment,
    required Decimal previousBalance,
    required Decimal amount,
    required Decimal remaining,
  }) = _PaidInvoice;

  /// Series and serial, or `#invoiceId` for an invoice with no serial.
  String get folioLabel =>
      serial == null ? '#$invoiceId' : '${series ?? ''}$serial';
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

    /// The PAC's stamp; `null` before stamping. Legacy-stamped documents have
    /// one too.
    FiscalStamp? stamp,

    /// When the pending stamp was sent, while the document is stamping.
    DateTime? stampingSince,

    /// UUID of the document that replaced this one (cancellation reason 01).
    String? cancellationSubstitution,

    /// Every cancellation request, newest first as the server sends them.
    @Default(<FiscalCancellation>[]) List<FiscalCancellation> cancellations,
    @Default(<InvoiceLine>[]) List<InvoiceLine> lines,
    @Default(<InvoiceRelation>[]) List<InvoiceRelation> relations,

    /// A payment receipt's payment (spec 074): `null` on other types, and on a
    /// fresh by-hand receipt until the header is filled.
    DateTime? paymentDate,
    Decimal? paymentAmount,
    String? paymentReference,

    /// The customer payment the receipt came from, when it did.
    int? customerPaymentId,

    /// The invoices a receipt pays; empty for any other type.
    @Default(<PaidInvoice>[]) List<PaidInvoice> paidInvoices,
  }) = _FiscalDocument;

  int get id => summary.id;
  FiscalDocumentStatus get status => summary.status;
  bool get isInvoice => summary.typeCode == 0;
  bool get isCreditNote => summary.typeCode == 100;
  bool get isPaymentReceipt => summary.typeCode == 200;

  /// An invoice, or a credit note that relates its invoice (spec 073 R8). A
  /// credit note with no relation (legacy) can't be edited: the lines are
  /// copied from that invoice and the server's confirm needs the relation.
  /// Any other type is read-only here.
  bool get isEditableKind =>
      isInvoice ||
      isPaymentReceipt ||
      (isCreditNote && creditedInvoice != null);

  bool get isEditableDraft =>
      isEditableKind && status == FiscalDocumentStatus.draft;
  bool get canReopen => isEditableKind && status == FiscalDocumentStatus.sealed;

  /// A live, stamped invoice can start a credit note (spec 073).
  bool get canIssueCreditNote =>
      isInvoice && status == FiscalDocumentStatus.issued;

  /// The invoice a credit note credits: its first type-01 relation.
  InvoiceRelation? get creditedInvoice => isCreditNote
      ? relations
            .where((r) => r.type == InvoiceRelationType.creditNoteOf)
            .firstOrNull
      : null;

  /// A credit-note draft still on payment form 99: the server refuses to
  /// confirm it until a real form is chosen (spec 073 R5).
  bool get needsPaymentForm =>
      (isCreditNote || isPaymentReceipt) &&
      status == FiscalDocumentStatus.draft &&
      paymentForm == PaymentMethod.toBeDefined.code;

  /// Stamping applies to a sealed document of any type (spec 072 R2).
  bool get canStamp => status == FiscalDocumentStatus.sealed;

  /// Only a stamped, live document can be cancelled, of any type.
  bool get canCancel => status == FiscalDocumentStatus.issued;

  /// A stamp or a cancellation is in process and the PAC can be asked.
  bool get canRefresh =>
      status == FiscalDocumentStatus.stamping ||
      status == FiscalDocumentStatus.cancellationPending;

  /// The cancellation request still waiting for an answer, if any.
  FiscalCancellation? get openCancellation =>
      cancellations.where((c) => c.outcome.isOpen).firstOrNull;

  /// PDF and XML are offered; the server still refuses unstamped or pre-4.0.
  bool get hasDocuments =>
      status == FiscalDocumentStatus.issued ||
      status == FiscalDocumentStatus.cancellationPending ||
      status == FiscalDocumentStatus.cancelled;

  bool get hasRelations => relations.isNotEmpty;

  /// The ordering bank of a receipt: the server stores it in `reference`
  /// (spec 074 R7).
  String? get orderingBank => isPaymentReceipt ? reference : null;

  /// What the paid invoices add up to (spec 074 FR-010).
  Decimal get assignedAmount =>
      paidInvoices.fold(Decimal.zero, (sum, p) => sum + p.amount);

  /// The payment amount not yet assigned to an invoice; `null` while the
  /// payment amount is unknown.
  Decimal? get unassignedAmount {
    final amount = paymentAmount;
    return amount == null ? null : amount - assignedAmount;
  }

  /// A draft receipt made from a payment whose orders yielded no PPD invoice
  /// (spec 074 C38).
  bool get showsNoProposalBanner =>
      isPaymentReceipt &&
      status == FiscalDocumentStatus.draft &&
      customerPaymentId != null &&
      paidInvoices.isEmpty;

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

/// Start a payment receipt for a customer's RFC, optionally from one of their
/// payments (spec 074).
@freezed
abstract class NewPaymentReceipt with _$NewPaymentReceipt {
  const factory NewPaymentReceipt({
    required int customerId,
    required String recipientRfc,
    int? customerPaymentId,
  }) = _NewPaymentReceipt;
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

    /// A payment receipt's fields (spec 074). The server accepts them only on
    /// a receipt, and the invoice fields above only on an invoice or credit
    /// note.
    DateTime? paymentDate,
    Decimal? paymentAmount,
    String? paymentReference,
    String? orderingBank,
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
