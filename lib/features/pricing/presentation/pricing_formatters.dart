import 'package:intl/intl.dart';

/// Display formatting for the pricing feature's monetary/percentage/date
/// values (FR-006, FR-013, FR-018) — never manual string formatting
/// (constitution §V). [locale] defaults to the app's fixed `es-MX` locale
/// (`app.dart`); callers with a `BuildContext` MAY pass
/// `Localizations.localeOf(context).toString()` instead.
///
/// Inputs are the raw `String` decimals carried end-to-end by the domain
/// entities (research.md §3) — formatting never round-trips through
/// `double` for storage, only for display.
abstract final class PricingFormatters {
  static const _defaultLocale = 'es_MX';

  /// FR-013 — a price/profit amount as MXN currency, e.g. `"120.5"` →
  /// `"$120.50"`.
  static String currency(String value, {String locale = _defaultLocale}) {
    final amount = num.tryParse(value) ?? 0;
    return NumberFormat.currency(
      locale: locale,
      symbol: r'$',
      decimalDigits: 2,
    ).format(amount);
  }

  /// FR-006 — a decimal margin as a percentage, e.g. `"0.40"` → `"40%"`.
  static String percent(String decimalValue, {String locale = _defaultLocale}) {
    final value = num.tryParse(decimalValue) ?? 0;
    return NumberFormat.percentPattern(locale).format(value);
  }

  /// FR-018 — a locale-aware short date for an exchange rate's `date`.
  static String date(DateTime value, {String locale = _defaultLocale}) {
    return DateFormat.yMd(locale).format(value);
  }
}
