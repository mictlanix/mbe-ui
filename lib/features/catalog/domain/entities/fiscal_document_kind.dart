/// The kind of fiscal document a taxpayer series (batch) numbers — legacy's
/// `FiscalDocumentType` (spec 065 data-model.md). Declared in the order a
/// series list is sorted in: the first kind is listed first (research R5).
///
/// The API's batch response carries the kind as a plain `int`, while a
/// create/update takes the generated `FiscalDocumentType`; this domain enum
/// keeps presentation off the generated type and lets an unknown code render
/// instead of failing (spec edge case).
enum FiscalDocumentKind {
  invoice(0),
  feeReceipt(1),
  rentReceipt(2),
  debitNote(3),
  creditNote(100),
  advancePaymentsApplied(101),
  paymentReceipt(200);

  const FiscalDocumentKind(this.code);

  /// The code the API exchanges.
  final int code;

  /// The kind for an API [code], or `null` for a code this app doesn't know.
  static FiscalDocumentKind? fromCode(int code) {
    for (final kind in values) {
      if (kind.code == code) return kind;
    }
    return null;
  }
}
