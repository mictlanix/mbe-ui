/// Client-side validators shared by the Suppliers, Employees, Customers, and
/// Taxpayer Recipients forms (spec 012 FR-011/FR-016/FR-019/FR-024).
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
}
