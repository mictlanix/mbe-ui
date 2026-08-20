# Contract: The Formatting Surface

**Feature**: 028-presentation-consistency

> Carried forward from `specs/027-app-user-settings/contracts/formatting-surface.md`,
> which was written as finished design and then descoped. **This copy is
> authoritative**; 027's is historical. Two changes from that version are marked
> ⚠ below — the ISO default, and the percent rendering.

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

| Call | Input | Output (defaults) |
|---|---|---|
| `fmt.display.currency(v)` | `"120.5"` | `$120.50` |
| `fmt.display.percent(v)` | `"0.16"` | `16.00 %` ⚠ |
| `fmt.display.date(d)` | `DateTime` | `2026-08-17` ⚠ |
| `fmt.display.dateTime(d)` | `DateTime` | `2026-08-17 14:30` ⚠ |
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

Output shape comes from `AppSettings.formatting` — symbol, decimal digits,
date and date-time patterns. Deployment-level only: set per customer through
`deploy/<customer>.env`, resolved once at startup, **never reachable from the
UI** and never a per-user preference.

### ⚠ Change from the 027 version of this contract

That version guaranteed "defaults reproduce today's rendering byte-for-byte."
**That guarantee is withdrawn**, for two reasons:

1. **By choice** — the default date format is now ISO `yyyy-MM-dd`
   (date-time `yyyy-MM-dd HH:mm`), not the locale-derived `17/8/2026`. A
   deployment preferring the local rendering sets `DATE_FORMAT=d/M/yyyy`.
2. **By necessity** — the two percent paths being merged never agreed:
   `MoneyFormatters.percent` rendered `16%` and `money.dart` rendered
   `16.00 %`. One had to change. The contract keeps `16.00 %`.

Currency and quantity defaults do reproduce current output exactly.

### Pattern reference

The same `DateFormat(pattern, locale)` accepts **explicit patterns** and
**skeletons**, and they behave differently. Verified on Flutter 3.44.2 with
`2026-08-17 14:30`:

```bash
# ── Explicit patterns: identical layout in every locale ──────────────
DATE_FORMAT=yyyy-MM-dd          # 2026-08-17   ← default, ISO 8601
DATE_FORMAT=d/M/yyyy            # 17/8/2026
DATE_FORMAT=dd/MM/yyyy          # 17/08/2026

DATE_TIME_FORMAT="yyyy-MM-dd HH:mm"   # 2026-08-17 14:30   ← default
DATE_TIME_FORMAT="d/M/yyyy HH:mm"     # 17/8/2026 14:30

# ── Skeletons: resolved per locale by the same setting ───────────────
DATE_FORMAT=yMd                 # es_MX 17/8/2026    en 8/17/2026  ← order flips
DATE_FORMAT=yMMMd               # es_MX 17 ago 2026  en Aug 17, 2026

# ── Number knobs ─────────────────────────────────────────────────────
CURRENCY_SYMBOL=$               # with digits=2:  1234.5 → $1,234.50
CURRENCY_CODE=MXN               # carried for reporting; not shown by the symbol path
CURRENCY_DECIMAL_DIGITS=2
PERCENT_DECIMAL_DIGITS=2        # 0.16 → 16.00 %
QUANTITY_DECIMAL_DIGITS=0       # 3.0000 → 3   (trailing zeros dropped)
```

Pick an explicit pattern for one unambiguous rendering regardless of who is
reading; pick a skeleton to follow the reader's locale. The ISO default is
explicit deliberately — a deployment serving both `es_MX` and `en` gets one
date format, not two.

**This block is the source for `.env.template`.** Every key appears there with
its default, a one-line description, and these worked examples as comments;
the two must not drift.

---

## The guard

A source-scanning test fails the suite when a file outside the allowlist
imports `package:intl`, or calls `toStringAsFixed` under `presentation/`. It
names the offending file and line.

**Allowlist**: the formatting surface itself; `lib/generated/**`;
`lib/l10n/app_localizations*.dart` (generated by `flutter gen-l10n` — the
output path comes from `l10n.yaml`, so a change there updates this list);
`lib/main.dart` (`initializeDateFormatting`); and
`pos_sales_list_controller.dart`'s `_dateFacetFormat`, which encodes a
`yyyy-MM-dd` **URL query facet** and must stay locale-independent — it is not
a display path.

If you are adding a new exemption, you are almost certainly adding a display
path that belongs in the surface instead.
