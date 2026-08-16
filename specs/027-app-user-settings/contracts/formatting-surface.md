# Contract: The Formatting Surface

**Feature**: 027-app-user-settings

The contract between value formatting and every screen in the product.
Consumers: every feature module author. Supersedes `MoneyFormatters` and the
display helpers in `features/sales/domain/money.dart`.

---

## The one access rule

Every formatted value is reached through one provider, resolved **once per
build**. No widget imports `package:intl`, constructs a `DateFormat`/
`NumberFormat`, or calls `toStringAsFixed` for display.

```dart
class SomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fmt = ref.watch(formattersProvider);
    ...
    Text(fmt.display.currency(sale.total))
    Text(fmt.display.dateTime(session.start))
  }
}
```

**No `locale:` parameter exists.** The provider owns the locale, and it is the
same locale that drives `MaterialApp.locale` — the interface language and the
formatted values cannot disagree. Any call site currently writing
`Localizations.localeOf(context).toString()` for this purpose deletes it.

**Resolve once, not per cell.** Inside a table, close over `fmt`:

```dart
DataTableColumn(
  label: l10n.cashSessionColumnStart,
  cellBuilder: (context, s) => Text(fmt.display.dateTime(s.start)),
)
```

---

## Read-only display

| Call | Input | Output (es-MX defaults) |
|---|---|---|
| `fmt.display.currency(v)` | `"120.5"` | `$120.50` |
| `fmt.display.percent(v)` | `"0.16"` | `16.00 %` |
| `fmt.display.date(d)` | `DateTime` | `16/8/2026` |
| `fmt.display.dateTime(d)` | `DateTime` | `16/8/2026 14:30` |
| `fmt.display.quantity(v)` | `"3.0000"` | `3` |

Inputs are the raw decimal `String`s domain entities carry end-to-end.
Formatting never round-trips a stored value through `double`.

## Editable fields

A field the user types into carries **no** currency symbol and **must**
round-trip. Every formatter here has an inverse:

| Call | Input | Output | Inverse |
|---|---|---|---|
| `fmt.field.price(v)` | `"50.0000000"` | `50.00` | `fmt.field.parsePrice` |
| `fmt.field.rate(v)` | `"0.1600"` | `16` | `fmt.field.parseRate` |
| `fmt.field.quantity(v)` | `"3.0000"` | `3` | `fmt.field.parseQuantity` |

**Guaranteed**: `parseX(fmt.field.x(v)) == v`. A `parseX` returns `null` for
input it cannot read, so the caller rejects the edit rather than sending
nonsense — the behaviour `parsePercentAsRate` already has.

## Absent and unparseable input

One rule everywhere: `null` or unparseable renders `—`.

This replaces three behaviours that disagree today — `MoneyFormatters` renders
a formatted zero, `money.dart` returns the raw input unchanged, and
`cash_sessions_screen.dart` hand-writes `'—'` for a missing session end. A
caller needing a different empty rendering supplies it at the call site; it
does not re-implement the formatter.

---

## What is configurable

Output shape comes from `AppSettings.formatting` (see
[app-and-user-settings.md](app-and-user-settings.md)) — symbol, decimal
digits, date and date-time patterns. **Defaults reproduce today's rendering
byte-for-byte**, so upgrading changes nothing a deployment has not asked to
change.

---

## The guard

A source-scanning test fails the suite when a file outside the allowlist
imports `package:intl`, or calls `toStringAsFixed` under `presentation/`.
It names the offending file and line.

**Allowlist**: the formatting surface itself; `lib/generated/**`;
`lib/main.dart` (`initializeDateFormatting`); and
`pos_sales_list_controller.dart`'s `_dateFacetFormat`, which encodes a
`yyyy-MM-dd` **URL query facet** and must stay locale-independent — it is not
a display path.

If you are adding a new exemption, you are almost certainly adding a display
path that belongs in the surface instead.
