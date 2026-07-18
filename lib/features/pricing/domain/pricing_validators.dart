/// Client-side validators shared by the pricing feature's forms
/// (FR-006/FR-011/FR-016, research.md §3). Operate on the raw `String`
/// representation of a decimal — money and margins are never parsed to
/// `double` for storage, only checked for validity here.
abstract final class PricingValidators {
  /// FR-002/FR-003 — a price list's name.
  static bool isRequiredNonEmpty(String value) => value.trim().isNotEmpty;

  /// FR-011 — product prices/profit figures: zero is a valid amount (an
  /// unpriced/free item), negative is not.
  static bool isNonNegativeDecimal(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return false;
    final parsed = num.tryParse(trimmed);
    return parsed != null && parsed >= 0;
  }

  /// FR-006 — a price list's margins are optional on create; when present,
  /// the same non-negative rule as [isNonNegativeDecimal] applies. Empty is
  /// valid here (field simply not set).
  static bool isOptionalNonNegativeDecimal(String value) {
    if (value.trim().isEmpty) return true;
    return isNonNegativeDecimal(value);
  }

  /// FR-016 — an exchange rate: zero is invalid (a conversion can't be
  /// zero), unlike [isNonNegativeDecimal]'s prices.
  static bool isPositiveDecimal(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return false;
    final parsed = num.tryParse(trimmed);
    return parsed != null && parsed > 0;
  }
}
