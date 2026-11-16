import 'package:mbe_ui/features/catalog/domain/entities/fiscal_document_kind.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_batch.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The localized name of a fiscal document [kind] (spec 065, FR-003).
String fiscalDocumentKindLabel(
  AppLocalizations l10n,
  FiscalDocumentKind kind,
) => switch (kind) {
  FiscalDocumentKind.invoice => l10n.fiscalDocumentKindInvoice,
  FiscalDocumentKind.expense => l10n.fiscalDocumentKindExpense,
  FiscalDocumentKind.payment => l10n.fiscalDocumentKindPayment,
  FiscalDocumentKind.transfer => l10n.fiscalDocumentKindTransfer,
  FiscalDocumentKind.creditNote => l10n.fiscalDocumentKindCreditNote,
  FiscalDocumentKind.paymentReceipt => l10n.fiscalDocumentKindPaymentReceipt,
  FiscalDocumentKind.advancePaymentsApplied =>
    l10n.fiscalDocumentKindAdvancePaymentsApplied,
};

/// The label of a series' document type: the kind's name, or a generic
/// "Unknown type (code)" for a code this app doesn't know, so the row still
/// shows (spec edge case).
String taxpayerBatchTypeLabel(AppLocalizations l10n, TaxpayerBatch batch) {
  final kind = batch.kind;
  return kind == null
      ? l10n.fiscalDocumentKindUnknown(batch.typeCode)
      : fiscalDocumentKindLabel(l10n, kind);
}
