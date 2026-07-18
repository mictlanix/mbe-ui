/// Currency codes mirroring mbe-api/legacy `CurrencyCode`
/// (`mbe/docs/constants.md` §CurrencyCode). Hand-written — mbe-api exposes
/// exchange-rate `base`/`target` as bare `int` with no published currency
/// schema to generate from (research.md §6, data-model.md §5). Shape
/// mirrors `lib/core/access/system_object.dart`.
enum Currency {
  mxn(0),
  usd(1),
  eur(2);

  const Currency(this.value);

  final int value;

  /// Looks up the [Currency] whose [value] matches mbe-api's `base`/`target`
  /// integer. Returns `null` for an unrecognized code — the API's currency
  /// set is not schema-constrained, so callers MUST fall back gracefully
  /// (data-model.md §4) rather than crash.
  static Currency? fromValue(int value) {
    for (final currency in Currency.values) {
      if (currency.value == value) return currency;
    }
    return null;
  }
}
