import 'package:intl/intl.dart';

/// Display formatting for monetary/percentage/date values across features
/// (FR-006, FR-013, FR-018 of 011-product-pricing) — never manual string
/// formatting (constitution §V). [locale] defaults to the app's fixed
/// `es-MX` locale (`app.dart`); callers with a `BuildContext` MAY pass
/// `Localizations.localeOf(context).toString()` instead.
///
/// Inputs are the raw `String` decimals carried end-to-end by domain
/// entities (research.md §3 of 011-product-pricing) — formatting never
/// round-trips through `double` for storage, only for display.
///
/// Promoted from `features/pricing/presentation/pricing_formatters.dart`
/// (021-cash-sessions research.md §3): a second feature outside pricing
/// needed currency/date formatting, which constitution §I forbids reaching
/// via a cross-feature `presentation` import, and constitution §VI requires
/// shared formatters to live in `core/widgets/`. The class name changed
/// (`PricingFormatters` → `MoneyFormatters`); behavior of the three original
/// methods is unchanged byte-for-byte, including the hard-coded `$` symbol
/// and the `'es_MX'` default — fixing those would alter what every existing
/// pricing screen renders, which no requirement asks for.
abstract final class MoneyFormatters {
  static const _defaultLocale = 'es_MX';

  /// A price/profit amount as MXN currency, e.g. `"120.5"` → `"$120.50"`.
  static String currency(String value, {String locale = _defaultLocale}) {
    final amount = num.tryParse(value) ?? 0;
    return NumberFormat.currency(
      locale: locale,
      symbol: r'$',
      decimalDigits: 2,
    ).format(amount);
  }

  /// A decimal margin as a percentage, e.g. `"0.40"` → `"40%"`.
  static String percent(String decimalValue, {String locale = _defaultLocale}) {
    final value = num.tryParse(decimalValue) ?? 0;
    return NumberFormat.percentPattern(locale).format(value);
  }

  /// A locale-aware short date, e.g. for an exchange rate's `date`.
  static String date(DateTime value, {String locale = _defaultLocale}) {
    return DateFormat.yMd(locale).format(value);
  }

  /// A locale-aware short date plus time-of-day — added for 021-cash-sessions,
  /// whose session `start`/`end` timestamps carry a time component that
  /// [date] alone would drop.
  static String dateTime(DateTime value, {String locale = _defaultLocale}) {
    return DateFormat.yMd(locale).add_Hm().format(value);
  }
}
