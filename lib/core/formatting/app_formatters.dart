import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:mbe_ui/core/config/formatting_settings.dart';

/// The single point every screen reaches through to format a value for
/// display (spec 028 FR-001/FR-002; contracts/formatting-surface.md).
/// Supersedes `MoneyFormatters` and the display helpers in
/// `features/sales/domain/money.dart` — no other file constructs a
/// `DateFormat`/`NumberFormat` or calls `toStringAsFixed` for display
/// (enforced by `test/unit/core/formatting_guard_test.dart`).
///
/// Built once from the resolved locale and the deployment's
/// [FormattingSettings], then resolved **once per build** via
/// `formattersProvider` and closed over — never reconstructed per cell
/// (research.md R1).
class AppFormatters {
  AppFormatters({required Locale locale, required FormattingSettings settings})
    : display = DisplayFormatters(locale: locale, settings: settings),
      field = FieldFormatters(settings: settings);

  /// Read-only rendering: currency, percent, date, date-time, quantity.
  /// Carries symbols, fixed decimals, locale separators — never round-trips.
  final DisplayFormatters display;

  /// Editable-field rendering: price, rate, quantity. No currency symbol;
  /// each has a `parse*` inverse (contracts/formatting-surface.md).
  final FieldFormatters field;
}

/// The placeholder every formatter renders for `null` or unparseable input,
/// replacing the three behaviors that disagreed before this feature: a
/// formatted zero (`MoneyFormatters`), the raw input unchanged (`money.dart`),
/// and a hand-written `'—'` (`cash_sessions_screen.dart`).
const emptyValuePlaceholder = '—';

/// `display.*` — read-only rendering (contracts/formatting-surface.md).
class DisplayFormatters {
  DisplayFormatters({required Locale locale, required FormattingSettings settings})
    : _settings = settings,
      _currency = NumberFormat.currency(
        locale: locale.toString(),
        symbol: settings.currencySymbol,
        decimalDigits: settings.currencyDecimalDigits,
      ),
      _percent = NumberFormat.decimalPatternDigits(
        locale: locale.toString(),
        decimalDigits: settings.percentDecimalDigits,
      ),
      _date = DateFormat(settings.datePattern, locale.toString()),
      _dateTime = DateFormat(settings.dateTimePattern, locale.toString());

  final FormattingSettings _settings;
  final NumberFormat _currency;
  final NumberFormat _percent;
  final DateFormat _date;
  final DateFormat _dateTime;

  /// A monetary amount, e.g. `"120.5"` → `"$120.50"` (defaults). `null` or
  /// unparseable → [emptyValuePlaceholder].
  String currency(String? value) {
    if (value == null) return emptyValuePlaceholder;
    final parsed = Decimal.tryParse(value);
    if (parsed == null) return emptyValuePlaceholder;
    return _currency.format(parsed.toDouble());
  }

  /// A stored rate as a percentage with symbol, e.g. `"0.16"` → `"16.00 %"`
  /// (defaults) — two decimals always, so a column of rates reads aligned
  /// rather than a ragged mix of `16` and `7.5`. `null` or unparseable →
  /// [emptyValuePlaceholder].
  ///
  /// ⚠ Deliberately **not** `NumberFormat.percentPattern`, which renders a
  /// bare `16%` with no configurable decimal count. That was one of the two
  /// disagreeing percent behaviors this surface exists to unify — this
  /// method keeps `money.dart`'s `"16.00 %"` shape, the one `.env.template`
  /// documents (research.md R4).
  String percent(String? value) {
    if (value == null) return emptyValuePlaceholder;
    final parsed = Decimal.tryParse(value);
    if (parsed == null) return emptyValuePlaceholder;
    final asPercent = (parsed * Decimal.fromInt(100)).toDouble();
    return '${_percent.format(asPercent)} %';
  }

  /// A date, e.g. `2026-08-17` (ISO default). `null` → [emptyValuePlaceholder].
  String date(DateTime? value) {
    if (value == null) return emptyValuePlaceholder;
    return _date.format(value);
  }

  /// A date plus time-of-day, e.g. `2026-08-17 14:30` (ISO default). `null`
  /// → [emptyValuePlaceholder].
  String dateTime(DateTime? value) {
    if (value == null) return emptyValuePlaceholder;
    return _dateTime.format(value);
  }

  /// A quantity with trailing zeros dropped, e.g. `"3.0000"` → `"3"`,
  /// `"2.5000"` → `"2.5"`. `null` or unparseable → [emptyValuePlaceholder].
  ///
  /// [FormattingSettings.quantityDecimalDigits] `0` (the default) means
  /// "natural precision, trailing zeros dropped, never rounded" — today's
  /// exact behavior. A value greater than `0` caps the shown precision at
  /// that many decimals (still with trailing zeros dropped within the cap),
  /// for a deployment whose quantities carry unreasonably long precision.
  String quantity(String? value) => _formatQuantity(value, _settings.quantityDecimalDigits);

  /// Shared by [quantity] and [FieldFormatters.quantity] — identical
  /// rendering rule in both groups (data-model.md §2.1/§2.2).
  static String _formatQuantity(String? value, int decimalDigits) {
    if (value == null) return emptyValuePlaceholder;
    final parsed = Decimal.tryParse(value);
    if (parsed == null) return emptyValuePlaceholder;
    if (decimalDigits <= 0) return parsed.toString();
    return Decimal.parse(
      parsed.toStringAsFixed(decimalDigits),
    ).toString();
  }
}

/// `field.*` — editable-field rendering, with inverses
/// (contracts/formatting-surface.md). No currency symbol; nothing a caller
/// would have to type around or that would break re-parsing.
@immutable
class FieldFormatters {
  const FieldFormatters({required FormattingSettings settings}) : _settings = settings;

  final FormattingSettings _settings;

  /// A unit price at [FormattingSettings.currencyDecimalDigits] decimals
  /// (`2` by default): `"50.0000000"` → `"50.00"`. Not currency — this feeds
  /// an editable field, where a symbol prefix would have to be typed around;
  /// [DisplayFormatters.currency] stays the choice for read-only amounts.
  ///
  /// ⚠ Rounds to the configured precision. The round-trip guarantee
  /// (`parsePrice(price(v)) == v`) holds for the domain's real values,
  /// which never carry genuine precision beyond [FormattingSettings.currencyDecimalDigits]
  /// — a wire string like `"50.0000000"` pads with trailing zeros, it does
  /// not carry seven significant decimal digits. If a value ever did exceed
  /// that precision, this method would round it for *display*, but the
  /// caller must still send back the original unrounded value when the user
  /// has not edited the field (spec.md Edge Cases) — that is a UI-level
  /// rule this formatter cannot enforce on its own.
  String price(String value) => _formatFixed(value, _settings.currencyDecimalDigits);

  /// Inverse of [price]. Returns `null` for input it cannot read, so the
  /// caller rejects the edit rather than sending nonsense.
  String? parsePrice(String value) => _parseFixed(value);

  /// A stored rate rendered as the percentage the cashier thinks in, full
  /// precision, no rounding, no `%` suffix: `"0.1600"` → `"16"`,
  /// `"0.075"` → `"7.5"`. Rates are stored `0 ≤ r ≤ 1`; every label in the
  /// capture grid reads `%`, so the two must not disagree.
  String rate(String value) {
    final parsed = Decimal.tryParse(value.trim());
    if (parsed == null) return value;
    return (parsed * Decimal.fromInt(100)).toString();
  }

  /// Inverse of [rate]: `"16"` → `"0.16"`. Returns `null` for input it
  /// cannot read, so the caller rejects the edit rather than sending
  /// nonsense — the behavior `parsePercentAsRate` already had.
  String? parseRate(String value) {
    final parsed = Decimal.tryParse(value.trim());
    if (parsed == null) return null;
    return (parsed / Decimal.fromInt(100))
        .toDecimal(scaleOnInfinitePrecision: 6)
        .toString();
  }

  /// A quantity with trailing zeros dropped — identical rule to
  /// [DisplayFormatters.quantity], just without the `—` placeholder since a
  /// field being edited is never null.
  String quantity(String value) =>
      DisplayFormatters._formatQuantity(value, _settings.quantityDecimalDigits);

  /// Inverse of [quantity]. Returns `null` for input it cannot read.
  String? parseQuantity(String value) {
    final parsed = Decimal.tryParse(value.trim());
    if (parsed == null) return null;
    return parsed.toString();
  }

  String _formatFixed(String value, int decimalDigits) {
    final parsed = Decimal.tryParse(value);
    if (parsed == null) return value;
    return parsed.toStringAsFixed(decimalDigits);
  }

  String? _parseFixed(String value) {
    final parsed = Decimal.tryParse(value.trim());
    if (parsed == null) return null;
    return parsed.toString();
  }
}
