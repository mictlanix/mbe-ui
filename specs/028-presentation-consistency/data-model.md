# Phase 1 Data Model: Presentation Consistency

**Feature**: 028-presentation-consistency | **Date**: 2026-08-17

Carried forward from `specs/027-app-user-settings/data-model.md` §1.2 and §2,
where both were marked *descoped — future spec*. **Amended here** for the ISO
default (research R4) and the guard-allowlist correction (research R2).

---

## 1. `FormattingSettings` — the deployment's formatting knobs

A field on the existing `AppSettings` (spec 027), resolved once at startup from
build-time values. Never mutable from the UI (constitution §V).

| Field | Type | Env key | Default | vs. today |
|---|---|---|---|---|
| `datePattern` | `String` | `DATE_FORMAT` | `yyyy-MM-dd` | ⚠ **changed** (was `DateFormat.yMd` → `17/8/2026`) |
| `dateTimePattern` | `String` | `DATE_TIME_FORMAT` | `yyyy-MM-dd HH:mm` | ⚠ **changed** (was `17/8/2026 14:30`) |
| `currencySymbol` | `String` | `CURRENCY_SYMBOL` | `$` | ✅ matches the hard-coded `r'$'` |
| `currencyCode` | `String` | `CURRENCY_CODE` | `MXN` | new; carried for display/reporting, unused by the symbol path |
| `currencyDecimalDigits` | `int` | `CURRENCY_DECIMAL_DIGITS` | `2` | ✅ |
| `percentDecimalDigits` | `int` | `PERCENT_DECIMAL_DIGITS` | `2` | ⚠ matches `money.dart`'s `16.00 %`; **changes** `MoneyFormatters.percent`'s `16%` |
| `quantityDecimalDigits` | `int` | `QUANTITY_DECIMAL_DIGITS` | `0` | ✅ trailing zeros dropped, as today |

> **The 027 table claimed every default reproduced current output
> byte-for-byte. Two rows above break that**, one by choice (dates) and one by
> necessity (percent — the two existing paths disagree, so unifying them had to
> change one). See research R4.

**Validation**: every key falls back to the default above on a malformed or
absent value rather than failing startup — the rule
`BrandConfig._parseSeedColor` already applies to a bad hex colour
(constitution §V). A non-numeric digit count falls back; a date pattern is
accepted as given, since `intl` treats any unrecognised string as a literal
pattern and cannot be validated ahead of use without formatting a probe date.

### 1.1 Accepted pattern forms

`DateFormat(pattern, locale)` accepts **two different kinds of string**, and
the difference is the whole ISO-vs-local question. Verified against
Flutter 3.44.2 / `intl` on 2026-08-17 with `2026-08-17 14:30`:

**Explicit patterns — fixed layout, identical in every locale:**

| Pattern | `es_MX` | `en` |
|---|---|---|
| `yyyy-MM-dd` *(default)* | `2026-08-17` | `2026-08-17` |
| `d/M/yyyy` | `17/8/2026` | `17/8/2026` |
| `dd/MM/yyyy` | `17/08/2026` | `17/08/2026` |
| `yyyy-MM-dd HH:mm` *(default)* | `2026-08-17 14:30` | `2026-08-17 14:30` |
| `d/M/yyyy HH:mm` | `17/8/2026 14:30` | `17/8/2026 14:30` |

**Skeletons — the same constructor resolves these per locale:**

| Skeleton | `es_MX` | `en` |
|---|---|---|
| `yMd` | `17/8/2026` | `8/17/2026` ⚠ order flips |
| `yMMMd` | `17 ago 2026` | `Aug 17, 2026` |

A deployment serving one locale can use either. A deployment serving both
should understand that a skeleton follows the reader's locale while an
explicit pattern does not — which is precisely why the ISO default is an
explicit pattern: one unambiguous rendering everywhere, independent of who is
reading.

**Number knobs**, same probe:

| Setting | Value | Renders |
|---|---|---|
| `CURRENCY_SYMBOL=$`, `CURRENCY_DECIMAL_DIGITS=2` | `1234.5` | `$1,234.50` |
| `PERCENT_DECIMAL_DIGITS=2` | `0.16` | `16.00 %` |
| `QUANTITY_DECIMAL_DIGITS=0` | `3.0000` | `3` |

---

## 2. `AppFormatters` — the single formatting surface

Derived, not configured: an immutable value object built from
`FormattingSettings` + the resolved locale. Lives in `lib/core/formatting/`.
Exposed as `formattersProvider`; resolved **once per build** by call sites
(research R1).

Two explicitly separate groups — the separation *is* the read-only/editable
requirement, not a naming convention.

### 2.1 `display.*` — read-only rendering

| Method | In | Out (defaults, `es_MX`) |
|---|---|---|
| `currency(String?)` | `"120.5"` | `$120.50` |
| `percent(String?)` | `"0.16"` | `16.00 %` |
| `date(DateTime?)` | | `2026-08-17` |
| `dateTime(DateTime?)` | | `2026-08-17 14:30` |
| `quantity(String?)` | `"3.0000"` | `3` |

### 2.2 `field.*` — editable-field rendering, with inverses

No currency symbol; nothing that would have to be typed around or would break
re-parsing.

| Method | In | Out | Inverse |
|---|---|---|---|
| `price(String)` | `"50.0000000"` | `50.00` | `parsePrice` |
| `rate(String)` | `"0.1600"` | `16` | `parseRate` |
| `quantity(String)` | `"3.0000"` | `3` | `parseQuantity` |

**Invariant**: `parseX(field.x(v)) == v` for every value the domain can hold —
asserted as a property test, not per-example (research R8). Each `parseX`
returns `null` for input it cannot read, so the caller rejects the edit rather
than persisting nonsense — the behaviour `parsePercentAsRate` already has.

### 2.3 Absent / unparseable input

One rule, applied by every method, replacing three behaviours that disagree
today:

- `null` → `—`
- non-null but unparseable → `—`

| Replaced behaviour | Where |
|---|---|
| renders a formatted `0` | `MoneyFormatters.*` (`num.tryParse(value) ?? 0`) |
| returns the raw input unchanged | `money.dart` (`if (parsed == null) return value`) |
| hand-writes `'—'` | `cash_sessions_screen.dart`, for a missing session end |

A caller needing a different empty rendering supplies it at the call site; it
does not re-implement the formatter.

### 2.4 Migration map

| Replaced | Sites | By |
|---|---|---|
| `MoneyFormatters.currency/percent/date/dateTime` | 50 (22 files) | `display.*` |
| `money.dart`: `formatQuantity`, `formatPrice`, `formatRateAsPercent`, `formatRateAsPercentWithSymbol`, `parsePercentAsRate` | 25 | `field.*` / `display.percent` |
| inline `DateFormat.yMd()` — `taxpayer_certificates_section.dart:51` | 1 | `display.date` |
| `_dateFacetFormat` — `pos_sales_list_controller.dart:19` | 1 | **not migrated** — URL query encoder, exempt |

**≈76 migrated call sites.** `money.dart`'s decimal *arithmetic* is not in this
table and does not move — see research R6 for the full stay/go split and the
`formatAmount` trap.

---

## 3. Guard allowlist

Data, not code — the guard reads this set. Corrected from 027 (research R2):
generated localizations live in `lib/l10n/`, not `lib/generated/`.

| Entry | Reason |
|---|---|
| `lib/core/formatting/**` | the surface itself |
| `lib/generated/**` | generated OpenAPI client |
| `lib/l10n/app_localizations*.dart` | generated by `flutter gen-l10n` per `l10n.yaml` |
| `lib/main.dart` | `initializeDateFormatting` |
| `lib/features/sales/presentation/pos_sales_list_controller.dart` | `_dateFacetFormat`, a URL query encoder |

Banned outside it: `import 'package:intl/...'` anywhere in `lib/`, and
`toStringAsFixed(` anywhere under `presentation/`.

---

## 4. Spacing conversion inventory

Not runtime data — the record US2 produces, satisfying "skipped sites must be
recorded" (FR-028). One row per `Row`/`Column` that contains at least one
spacer.

| Field | Values |
|---|---|
| Site | `path:line` |
| Flex kind | `Row` \| `Column` |
| Outcome | `converted` \| `skipped` |
| Reason (when skipped) | `non-uniform` \| `partial gaps` \| `edge pad` \| `single child` |
| Gap | the literal preserved, when converted |

Heuristic baseline to work from (research R7): **85** Flexes contain spacers;
**40** scan as clean candidates across 23 files, removing 41 spacers; 31 are
non-uniform and 14 have partial gaps. The 40 is a **floor** — the scan cannot
see through collection-`if` children and so misses cases like
`sale_line_card.dart`'s outer `Column`.
