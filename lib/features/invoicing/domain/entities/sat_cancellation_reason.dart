/// SAT's cancellation reasons, catalogue `sat_reason_cancellation` (spec 072
/// research R6). The set is closed, so it is fixed here rather than fetched.
enum SatCancellationReason {
  withRelation('01'),
  withoutRelation('02'),
  notCarriedOut('03'),
  globalInvoiceNominative('04');

  const SatCancellationReason(this.code);

  /// The code on the wire.
  final String code;

  /// Reason 01 must name the document that replaces the cancelled one.
  bool get needsSubstitute => this == withRelation;

  /// `null` for a code outside 01–04.
  static SatCancellationReason? fromCode(String code) =>
      values.where((r) => r.code == code).firstOrNull;
}
