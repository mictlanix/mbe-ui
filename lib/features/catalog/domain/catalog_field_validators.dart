/// Client-side validators shared by the Suppliers, Employees, Customers,
/// Taxpayer Recipients, Vehicles, and Vehicle Operators forms (spec 012
/// FR-011/FR-016/FR-019/FR-024; spec 013 FR-013/FR-016).
/// Money/integer fields operate on their raw `String` representation and are
/// never parsed to `double` for storage, only checked for validity here.
abstract final class CatalogFieldValidators {
  /// A required text field (code, name, nickname, email, tax id, ...).
  static bool isRequiredNonEmpty(String value) => value.trim().isNotEmpty;

  /// `creditLimit` on Suppliers/Customers: optional on create; when present,
  /// must be a non-negative decimal. Empty is valid (field simply not set).
  static bool isOptionalNonNegativeDecimal(String value) {
    if (value.trim().isEmpty) return true;
    final parsed = num.tryParse(value.trim());
    return parsed != null && parsed >= 0;
  }

  /// `creditDays`/`enrollNumber`: optional on create; when present, must be
  /// a non-negative integer. Empty is valid (field simply not set).
  static bool isOptionalNonNegativeInteger(String value) {
    if (value.trim().isEmpty) return true;
    final parsed = int.tryParse(value.trim());
    return parsed != null && parsed >= 0;
  }

  /// `tonsCapacity` on Vehicles: required, must be a non-negative integer.
  /// Combine with [isRequiredNonEmpty] at the call site — empty is NOT valid
  /// here, unlike [isOptionalNonNegativeInteger] (data-model.md §2).
  static bool isRequiredNonNegativeInteger(String value) {
    final parsed = int.tryParse(value.trim());
    return parsed != null && parsed >= 0;
  }

  /// Vehicle Operator's `expirationDate >= issueDate` soft rule
  /// (data-model.md §3). `null` for either date is treated as valid here —
  /// the required-field check runs separately.
  static bool dateNotBefore(DateTime? start, DateTime? end) {
    if (start == null || end == null) return true;
    return !end.isBefore(start);
  }
}
