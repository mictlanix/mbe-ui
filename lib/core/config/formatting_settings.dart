import 'package:flutter/foundation.dart';

/// The deployment's build-time formatting configuration (spec 028 FR-010),
/// resolved once at startup via [FormattingSettings.fromEnvironment] and held
/// on `AppSettings.formatting` for the life of the process — never mutable
/// from the UI, and never a per-user preference (constitution §V's two
/// configuration levels).
///
/// Every field falls back to its documented default on a malformed or absent
/// value rather than failing startup, the same rule `BrandConfig` already
/// applies to a bad hex color.
///
/// **The date default is deliberately ISO**, not the locale-derived rendering
/// the app used before this feature (spec 028 Clarifications; research.md
/// R4). A deployment preferring a local rendering sets `DATE_FORMAT`
/// explicitly — see `.env.template` for worked examples of both.
@immutable
class FormattingSettings {
  const FormattingSettings({
    this.datePattern = 'yyyy-MM-dd',
    this.dateTimePattern = 'yyyy-MM-dd HH:mm',
    this.currencySymbol = r'$',
    this.currencyCode = 'MXN',
    this.currencyDecimalDigits = 2,
    this.percentDecimalDigits = 2,
    this.quantityDecimalDigits = 0,
  });

  /// `DateFormat` pattern for a date-only value, e.g. `yyyy-MM-dd` → `2026-08-17`.
  /// Accepts any `intl` pattern or skeleton string as given — see
  /// `.env.template` for the supported set with worked examples.
  final String datePattern;

  /// `DateFormat` pattern for a date-plus-time value, e.g.
  /// `yyyy-MM-dd HH:mm` → `2026-08-17 14:30`.
  final String dateTimePattern;

  /// Currency symbol prefix, e.g. `$`.
  final String currencySymbol;

  /// ISO 4217 currency code, carried for display/reporting. Not read by the
  /// symbol-prefixed `display.currency` rendering.
  final String currencyCode;

  /// Decimal digits for a currency amount, e.g. `2` → `$1,234.50`.
  final int currencyDecimalDigits;

  /// Decimal digits for a percentage, e.g. `2` → `16.00 %`.
  final int percentDecimalDigits;

  /// Decimal digits for a quantity. `0` drops trailing zeros:
  /// `"3.0000"` → `3`, matching today's `formatQuantity` behavior.
  final int quantityDecimalDigits;

  static const _datePatternEnv = String.fromEnvironment(
    'DATE_FORMAT',
    defaultValue: 'yyyy-MM-dd',
  );
  static const _dateTimePatternEnv = String.fromEnvironment(
    'DATE_TIME_FORMAT',
    defaultValue: 'yyyy-MM-dd HH:mm',
  );
  static const _currencySymbolEnv = String.fromEnvironment(
    'CURRENCY_SYMBOL',
    defaultValue: r'$',
  );
  static const _currencyCodeEnv = String.fromEnvironment(
    'CURRENCY_CODE',
    defaultValue: 'MXN',
  );
  static const _currencyDecimalDigitsEnv = String.fromEnvironment(
    'CURRENCY_DECIMAL_DIGITS',
    defaultValue: '2',
  );
  static const _percentDecimalDigitsEnv = String.fromEnvironment(
    'PERCENT_DECIMAL_DIGITS',
    defaultValue: '2',
  );
  static const _quantityDecimalDigitsEnv = String.fromEnvironment(
    'QUANTITY_DECIMAL_DIGITS',
    defaultValue: '0',
  );

  /// Build-time source. A pattern string is accepted as given — `intl`
  /// cannot validate a pattern ahead of use without formatting a probe date,
  /// so an unrecognized pattern surfaces as an odd rendering rather than a
  /// startup failure, which is consistent with every other fallback here.
  factory FormattingSettings.fromEnvironment() {
    if (kDebugMode) {
      debugPrint(
        '[FormattingSettings] DATE_FORMAT=$_datePatternEnv '
        'DATE_TIME_FORMAT=$_dateTimePatternEnv '
        'CURRENCY_SYMBOL=$_currencySymbolEnv '
        'CURRENCY_CODE=$_currencyCodeEnv '
        'CURRENCY_DECIMAL_DIGITS=$_currencyDecimalDigitsEnv '
        'PERCENT_DECIMAL_DIGITS=$_percentDecimalDigitsEnv '
        'QUANTITY_DECIMAL_DIGITS=$_quantityDecimalDigitsEnv',
      );
    }
    return FormattingSettings(
      datePattern: _nonEmptyOrDefault(_datePatternEnv, 'yyyy-MM-dd'),
      dateTimePattern: _nonEmptyOrDefault(
        _dateTimePatternEnv,
        'yyyy-MM-dd HH:mm',
      ),
      currencySymbol: _nonEmptyOrDefault(_currencySymbolEnv, r'$'),
      currencyCode: _nonEmptyOrDefault(_currencyCodeEnv, 'MXN'),
      currencyDecimalDigits: _parseDigits(_currencyDecimalDigitsEnv, 2),
      percentDecimalDigits: _parseDigits(_percentDecimalDigitsEnv, 2),
      quantityDecimalDigits: _parseDigits(_quantityDecimalDigitsEnv, 0),
    );
  }

  static String _nonEmptyOrDefault(String value, String fallback) =>
      value.isEmpty ? fallback : value;

  /// Parses a non-negative decimal-digit count. Falls back on anything that
  /// isn't a non-negative integer — a malformed build flag must not brick
  /// app startup.
  static int _parseDigits(String value, int fallback) {
    final parsed = int.tryParse(value);
    if (parsed == null || parsed < 0) return fallback;
    return parsed;
  }

  @override
  bool operator ==(Object other) =>
      other is FormattingSettings &&
      other.datePattern == datePattern &&
      other.dateTimePattern == dateTimePattern &&
      other.currencySymbol == currencySymbol &&
      other.currencyCode == currencyCode &&
      other.currencyDecimalDigits == currencyDecimalDigits &&
      other.percentDecimalDigits == percentDecimalDigits &&
      other.quantityDecimalDigits == quantityDecimalDigits;

  @override
  int get hashCode => Object.hash(
    datePattern,
    dateTimePattern,
    currencySymbol,
    currencyCode,
    currencyDecimalDigits,
    percentDecimalDigits,
    quantityDecimalDigits,
  );
}
