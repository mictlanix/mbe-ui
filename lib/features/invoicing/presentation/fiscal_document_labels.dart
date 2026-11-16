import 'package:decimal/decimal.dart';

import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_document.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// PUE / PPD in words (spec 066).
String invoicePaymentTermsLabel(
  AppLocalizations l10n,
  InvoicePaymentTerms terms,
) => switch (terms) {
  InvoicePaymentTerms.pue => l10n.fiscalDocumentTermsPue,
  InvoicePaymentTerms.ppd => l10n.fiscalDocumentTermsPpd,
};

/// A line's VAT rate: "16 %", "0 %" or "Exento". A rate the app doesn't know
/// shows as the raw value, never hidden.
String invoiceTaxRateLabel(AppLocalizations l10n, Decimal rate) {
  final known = InvoiceTaxRate.fromRate(rate);
  return switch (known) {
    InvoiceTaxRate.iva16 => l10n.fiscalDocumentTaxIva16,
    InvoiceTaxRate.zero => l10n.fiscalDocumentTaxZero,
    InvoiceTaxRate.exempt => l10n.fiscalDocumentTaxExempt,
    null => l10n.fiscalDocumentTaxOther(rate.toString()),
  };
}

/// A relation type's name, with its SAT code.
String invoiceRelationTypeLabel(
  AppLocalizations l10n,
  InvoiceRelationType type,
) => switch (type) {
  InvoiceRelationType.substitution => l10n.fiscalDocumentRelationSubstitution,
  InvoiceRelationType.advanceApplication => l10n.fiscalDocumentRelationAdvance,
  InvoiceRelationType.creditNoteOf => l10n.fiscalDocumentRelationCreditNote,
};
