import 'package:decimal/decimal.dart';

import 'package:mbe_ui/core/domain/payment_method.dart';
import 'package:mbe_ui/features/sales/domain/entities/cash_session.dart';
import 'package:mbe_ui/features/sales/domain/entities/denomination_count.dart';

/// Exact decimal arithmetic for the counted total, the expected-cash figure,
/// and the difference between them (data-model.md §7, research.md §2).
///
/// This is the one file in the feature that imports `package:decimal` — every
/// entity still carries amounts as `String`, matching the repo-wide
/// convention; `Decimal` never escapes this file. Added specifically because
/// this feature is the first to *compute* on money rather than only display
/// it, and the difference is compared against zero to decide over/short,
/// which `double` cannot be trusted for.

/// Parses a wire decimal string exactly. Throws on malformed input — callers
/// control what they parse (server-supplied amounts, or denomination values
/// from [kMxnDenominations]), so a malformed string is a programming error,
/// not a user input to degrade gracefully from.
Decimal parseAmount(String value) => Decimal.parse(value);

/// The canonical string form of [value], suitable for
/// `MoneyFormatters.currency`.
String formatAmount(Decimal value) => value.toString();

/// `denomination * quantity`, as a formatted string — the single
/// denomination-row equivalent of [countedTotal], for a widget to show a row's
/// extended amount without importing `package:decimal` itself.
String extendedAmount(String denomination, int quantity) =>
    formatAmount(parseAmount(denomination) * Decimal.fromInt(quantity));

/// The sum of `denomination * quantity` over [counts].
Decimal countedTotal(List<DenominationCount> counts) {
  var total = Decimal.zero;
  for (final count in counts) {
    total += parseAmount(count.denomination) * Decimal.fromInt(count.quantity);
  }
  return total;
}

/// The session's expected cash: its opening amount plus only the
/// cash-method entries of [payments] — every other payment method is
/// excluded, since a card payment never entered the drawer.
///
/// Known incomplete by design: [payments] excludes expense vouchers,
/// cash-on-delivery movements, and any other drawer outflow the backend
/// does not track per method. Callers MUST present this as advisory
/// (spec FR-018), never as an exact figure.
Decimal expectedCash({
  required String openingAmount,
  required List<PaymentMethodTotal> payments,
}) {
  var total = parseAmount(openingAmount);
  for (final payment in payments) {
    if (payment.method == PaymentMethod.cash.code) {
      total += parseAmount(payment.total);
    }
  }
  return total;
}

/// `counted - expected`. Positive means over, negative means short, zero
/// means exact — callers decide how to label the sign; this function only
/// computes it.
Decimal difference({required Decimal counted, required Decimal expected}) =>
    counted - expected;

// ── 020-point-of-sale additions ─────────────────────────────────────────────
//
// Generic decimal arithmetic the sale-capture flow needs — outstanding
// balance, change, quantity distribution, the paid-equals-total gate — none
// of which is specific to a cash-drawer count the way everything above this
// line is. Kept in this file rather than a second one so this stays "the one
// file in the feature that imports `package:decimal`" (see the file
// docstring above), not two.

/// `a + b`, both wire-format decimal strings, returned as a wire-format
/// string. The generic counterpart to [countedTotal]'s summation.
String addAmounts(String a, String b) =>
    formatAmount(parseAmount(a) + parseAmount(b));

/// `a - b`, both wire-format decimal strings, returned as a wire-format
/// string.
String subtractAmounts(String a, String b) =>
    formatAmount(parseAmount(a) - parseAmount(b));

/// Compares two wire-format decimal strings exactly — negative if [a] < [b],
/// zero if equal, positive if [a] > [b]. The one correct way to compare two
/// money amounts in this codebase; never compare the raw strings or convert
/// through `double`.
int compareAmounts(String a, String b) => parseAmount(a).compareTo(parseAmount(b));

/// `true` iff [value] is exactly zero — the payment-step close gate
/// (`Sale.balance`) and the delivery-distribution-complete check both read
/// this rather than a string/`==` comparison, which would miss `"0"` vs
/// `"0.00"`.
bool isZeroAmount(String value) => parseAmount(value).compareTo(Decimal.zero) == 0;

/// Half of [value], rounded to two decimal places — the payment step's
/// "Mitad" quick-amount chip. Rounded because a tender is money handed over,
/// not an exact half of an odd cent: an unrounded `0.005` would be refused.
String halveAmount(String value) => formatAmount(
  (parseAmount(value) / Decimal.fromInt(2)).toDecimal(scaleOnInfinitePrecision: 2),
);

// ── Display formatting for editable line fields (FR-022) ────────────────────
//
// mbe-api sends every decimal at full stored scale — `"3.0000"`, `"50.0000000"`,
// `"0.1600"`. Putting those raw into an editable field is unreadable and, for a
// rate under a "%" label, actively wrong. These convert at the display edge
// only; the value sent back is always a plain decimal string in the server's
// own units.

/// A quantity with trailing zeros dropped: `"3.0000"` → `"3"`,
/// `"2.5000"` → `"2.5"`.
String formatQuantity(String value) {
  final parsed = Decimal.tryParse(value);
  if (parsed == null) return value;
  return parsed.toString();
}

/// A unit price at two decimals: `"50.0000000"` → `"50.00"`. Not currency —
/// this feeds an editable field, where a `$` prefix would have to be typed
/// around. [MoneyFormatters.currency] stays the choice for read-only amounts.
String formatPrice(String value) {
  final parsed = Decimal.tryParse(value);
  if (parsed == null) return value;
  return parsed.toStringAsFixed(2);
}

/// A stored rate rendered as the percentage the cashier thinks in:
/// `"0.1600"` → `"16"`, `"0.075"` → `"7.5"`. Rates are stored `0 ≤ r ≤ 1`
/// (data-model.md §9) but every label in the capture grid reads `%`, so the
/// two must not disagree.
String formatRateAsPercent(String value) {
  final parsed = Decimal.tryParse(value);
  if (parsed == null) return value;
  return (parsed * Decimal.fromInt(100)).toString();
}

/// The inverse of [formatRateAsPercent], for sending an edited field back:
/// `"16"` → `"0.16"`. Returns `null` when [value] is not a number, so the
/// caller can reject the edit rather than send nonsense.
String? parsePercentAsRate(String value) {
  final parsed = Decimal.tryParse(value.trim());
  if (parsed == null) return null;
  return (parsed / Decimal.fromInt(100)).toDecimal(scaleOnInfinitePrecision: 6).toString();
}
