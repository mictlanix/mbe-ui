# Phase 0 Research: Presentation Consistency

**Feature**: 028-presentation-consistency | **Date**: 2026-08-17

> **Provenance.** R1–R3 are carried forward from `specs/027-app-user-settings/research.md`
> (there numbered R3, R4, R8), where they were written as finished design and
> then descoped. They are **authoritative here**; 027's copies are historical.
> R2 and R3 carry corrections found while re-verifying on 2026-08-17 — read the
> ⚠ blocks, they change the implementation.
>
> R4–R8 are new to this feature.

| Here | In 027 | Status |
|---|---|---|
| R1 Formatting surface shape | R3 | Carried forward unchanged |
| R2 The out-of-band guard | R4 | Carried forward **+ allowlist correction** |
| R3 Migration inventory | R8 | Carried forward **+ re-verified, numbers drifted** |
| R4 The ISO default and its true blast radius | — | New |
| R5 Re-baselining goldens and screenshots | — | New |
| R6 What stays behind in `money.dart` | — | New |
| R7 The spacing conversion rubric and its size | — | New |
| R8 Sequencing and test strategy | — | New |

---

## R1 — The shape of the shared formatting surface

**Decision**: a Riverpod `Provider<AppFormatters>` (`formattersProvider`),
derived from `appSettingsProvider` and the resolved locale. `AppFormatters` is
an immutable value object holding pre-built `intl` formatters. Call sites
resolve it **once per build** and close over it.

```dart
// in a ConsumerWidget's build:
final fmt = ref.watch(formattersProvider);
...
DataTableColumn(cellBuilder: (context, s) => Text(fmt.display.dateTime(s.start)))
```

**Rationale**:

- **It satisfies the no-locale-parameter rule structurally, not by
  convention.** There is no `locale:` parameter to pass, because the provider
  owns the locale.
- The provider is the *only* place locale is resolved, and it is the same value
  that drives `MaterialApp.locale` — so the interface language and the
  formatted values can never disagree, which is the class of bug this feature
  exists to remove.
- Constitution §II already requires state and DI to go through Riverpod, and
  requires providers so tests can override them. A test pins formatting by
  overriding one provider instead of threading a locale string into 53 call
  sites.
- **Resolving once per build is strictly cheaper than today.** Current code
  calls `Localizations.localeOf(context).toString()` per screen and re-enters
  `NumberFormat.currency(...)`/`DateFormat(...)` **per cell** — a table of 50
  rows × 3 formatted columns constructs 150 formatters per frame. Pre-built
  formatters in a cached value object eliminate that.

**Numeric type**: the API stays `String` in, `String` out. Domain entities
carry raw decimal strings end-to-end (spec 011 research §3) and must not
round-trip through `double` for storage. Internally the surface parses with
`Decimal.tryParse` for validity and converts to `double` only at the final
`NumberFormat.format` call, which requires a `num`.

**Read-only vs. editable**: two explicitly named groups on the same object.

- `display.*` — `currency`, `percent`, `date`, `dateTime`, `quantity`. Carries
  symbols, fixed decimals, locale separators.
- `field.*` — `price`, `rate`, `quantity`. No currency symbol, trailing zeros
  dropped, rates shown as the percentage the cashier thinks in, and a matching
  `parse*` for each so the round-trip is testable as an identity property.

**Alternatives considered**: a `BuildContext` extension over an
`InheritedWidget` (rejected — a second DI mechanism beside Riverpod, which §II
forbids); a static class reading a global (rejected — untestable, and it is
exactly what `MoneyFormatters` already is).

**Existing seam confirmed present (2026-08-17)**: 027 shipped
`resolvedLocaleProvider` (`lib/core/settings/user_display_preferences_controller.dart:117`),
already consumed by `lib/app/app.dart:25` for `MaterialApp.locale`.
`formattersProvider` composes that provider with `appSettingsProvider`; neither
has to be built for this feature.

---

## R2 — The out-of-band formatting guard

**Decision**: a source-scanning unit test, following precedent already in this
repo. `test/unit/core/layering_test.dart` scans `lib/` for a banned import and
`test/unit/core/l10n_parity_test.dart` parses the `.arb` files — both plain
`dart:io` tests, no new tooling.

The guard bans, outside an explicit allowlist:

1. `import 'package:intl/...'` — the strongest, simplest signal, since
   `DateFormat`/`NumberFormat` are unreachable without it.
2. `toStringAsFixed(` anywhere under `presentation/`.

### ⚠ Allowlist correction — the 027 design would fail on day one

027's allowlist named `lib/generated/**` for generated sources. Verified
2026-08-17: **`lib/generated/` contains only `openapi/`.** The generated
localization files live in `lib/l10n/`, per `l10n.yaml`
(`arb-dir: lib/l10n`, `output-localization-file: app_localizations.dart`), and
three of them import `package:intl`:

```
lib/l10n/app_localizations.dart
lib/l10n/app_localizations_en.dart
lib/l10n/app_localizations_es.dart
```

They are tracked in git (not gitignored), so the guard sees them. The
allowlist must therefore be:

| Entry | Why |
|---|---|
| `lib/core/formatting/**` | the surface itself |
| `lib/generated/**` | generated OpenAPI client (§III: never hand-edited) |
| `lib/l10n/app_localizations*.dart` | **generated by `flutter gen-l10n`** — the correction above |
| `lib/main.dart` | `initializeDateFormatting` |
| `lib/features/sales/presentation/pos_sales_list_controller.dart` | `_dateFacetFormat` — a URL query encoder, must stay locale-independent |

Matching generated l10n by path prefix rather than by the `lib/generated/`
convention is deliberate: the generator's output location is set by
`l10n.yaml`, and a future change to that file must update the allowlist with
it. The guard's doc comment says so.

**Rationale for a test over a lint**: a custom lint rule needs
`custom_lint`/`analyzer` plugin wiring and a new dependency for one rule; a
test costs one file and runs in the existing suite. Rejected on cost, not on
principle — if the repo adopts `custom_lint` for other reasons, this rule
should move there.

---

## R3 — Migration inventory *(re-verified 2026-08-17)*

The 027 audit's numbers were re-measured on this branch rather than assumed.
**They have drifted upward slightly** — the spec's Assumptions anticipated
this.

| Path | 027 audit (2026-08-16) | Re-verified (2026-08-17) | Δ |
|---|---|---|---|
| `MoneyFormatters.*` call sites | 53 across **22** files | **53** across **24** files | files +2 |
| `money.dart` display helpers | 24 | **25** | +1 |
| inline `DateFormat.yMd()` | 1 | **1** (`taxpayer_certificates_section.dart:51`) | — |
| **Total** | ≈78 | **≈79** | +1 |
| Correctly exempt | 1 (`_dateFacetFormat`) | **1**, unchanged | — |

`money.dart` display-helper breakdown as measured (call sites in `lib/`,
excluding the definitions themselves):

| Helper | Sites |
|---|---|
| `formatQuantity` | 19 |
| `formatPrice` | 2 |
| `formatRateAsPercent` | 2 |
| `formatRateAsPercentWithSymbol` | 1 |
| `parsePercentAsRate` | 1 |

Files importing `package:intl` under `lib/`: 7 — of which 3 are generated l10n
(R2), 1 is `main.dart`, 1 is the exempt query encoder, and 2 are genuine
migration targets (`money_formatters.dart`, `taxpayer_certificates_section.dart`).

**Indivisibility confirmed**: the guard becomes satisfiable only when the last
call site moves, so a partial migration leaves both paths alive *and* no
guard. This is what took the work out of 027.

**Known-and-still-open, out of scope**: `exchange_rates_list_screen.dart`
calls `MoneyFormatters.date` with no locale *and* violates the filter-drawer
rule. Its formatting call migrates here with all the others; its filter-drawer
violation stays out of scope, as 027 recorded.

---

## R4 — ⚠ The ISO default changes more than dates

**Decision**: default `DATE_FORMAT=yyyy-MM-dd`, `DATE_TIME_FORMAT=yyyy-MM-dd HH:mm`
(spec Clarifications, FR-011). This supersedes the carried-forward contract's
"defaults reproduce today's rendering byte-for-byte" guarantee.

**The important finding**: that guarantee was **already unachievable**, and
not only because of the date default. The two percent paths disagree today,
so unifying them changes output no matter which default is chosen:

| Path | Call | Renders `0.16` as |
|---|---|---|
| `MoneyFormatters.percent` | `NumberFormat.percentPattern(locale)` | `16%` |
| `money.dart` `formatRateAsPercentWithSymbol` | hand-built | `16.00 %` |

`FormattingSettings.percentDecimalDigits: 2` in 027's data-model was
documented as "✅ matches `"16.00 %"`" — true for the `money.dart` path and
**false for the `MoneyFormatters` path**, whose call sites lose the bare `16%`
form. Since the whole premise of the feature is that these three paths
disagree, at least one rendering had to change; the contract's byte-for-byte
line quietly assumed otherwise.

**Consequences to carry into tasks**:

1. Date and date-time renderings change everywhere (the deliberate choice).
2. Percent renderings change at the `MoneyFormatters.percent` call sites
   (a consequence, not a choice — flagged so it is not mistaken for a
   regression during review).
3. Currency and quantity are unaffected: `CURRENCY_SYMBOL=$`,
   `CURRENCY_DECIMAL_DIGITS=2` and trailing-zero-dropped quantities all
   reproduce current output exactly.

**Alternatives considered**: keeping `percentPattern` for `display.percent`
and giving the picker its own formatter (rejected — reintroduces the
two-paths-for-one-concept problem the feature exists to remove); making
percent spacing configurable (rejected — configuration invented to avoid a
decision, and no deployment has asked for it).

---

## R5 — Re-baselining goldens and screenshots

**Decision**: re-record in one pass at the end of US1, never incrementally,
and land the re-recorded baselines through CI.

**Constraint that dictates this** — `test/golden/README.md`:

> This repo designates **CI** as the source of truth for goldens; a local
> `--update-goldens` run is advisory, not authoritative, until it lands there.

Baselines present: **92** in `test/golden/goldens/`, **8** in
`test/screenshots/shots/`.

**Method**:

1. Migrate every call site (US1) with baselines untouched. The golden suite
   fails; that failure set *is* the inventory of date/percent-bearing
   baselines, which is cheaper and more reliable than predicting it by
   reading fixtures.
2. Re-record once: `flutter test test/golden --update-goldens` and the
   screenshot equivalent.
3. Verify the font check the README demands before trusting any output —
   headings must render as real Archivo glyphs, not placeholder boxes, or
   `loadGoldenFonts()` never ran and the suite is verifying nothing.
4. Land through CI, per the README's authority rule.

**Why not pin the tests to a fixed format instead**: overriding
`appSettingsProvider` in the golden harness to force the old `yMd` rendering
would keep baselines green — and would mean the golden suite no longer shows
what the product actually looks like. Rejected.

**Ordering with US2**: US2 must run against the re-recorded baselines and
change none of them (FR-027). A baseline that moves during US2 is a bug in
the conversion, not a baseline needing an update.

---

## R6 — What stays behind in `money.dart`

**Decision**: only the **display helpers** leave; the exact-decimal arithmetic
stays exactly where it is.

`lib/features/sales/domain/money.dart` holds two unrelated bodies of code
under one file docstring. The spec's "the three superseded paths MUST be
removed" (FR-017, SC-008) means the display half — not the file.

| Stays (domain arithmetic, `package:decimal`) | Migrates (display, → `field.*` / `display.percent`) |
|---|---|
| `parseAmount`, `formatAmount`, `extendedAmount` | `formatQuantity` |
| `countedTotal`, `expectedCash`, `difference` | `formatPrice` |
| `addAmounts`, `subtractAmounts`, `compareAmounts` | `formatRateAsPercent` |
| `isZeroAmount`, `halveAmount` | `formatRateAsPercentWithSymbol` |
| | `parsePercentAsRate` |

**Watch item**: `formatAmount(Decimal)` reads like a display formatter and is
not one — it produces the canonical **wire** string that feeds
`display.currency`. It stays, keeps its name, and its docstring gets one line
saying so, because the next person migrating call sites by grepping `format*`
will otherwise take it with them.

`money.dart` must remain "the one file in the feature that imports
`package:decimal`" per its own docstring. The formatting surface parses with
`Decimal.tryParse` too (R1), so `lib/core/formatting/` becomes a second
importer — the docstring's claim is scoped to the *sales feature*, and stays
true. Noted so the discrepancy is not re-litigated during review.

---

## R7 — The spacing conversion rubric, and how big it is

**Decision**: convert only a `Row`/`Column` where a spacer sits between
**every** adjacent pair of children and **all** spacers are the same size.
Anything else is left alone and recorded.

The rule follows from what `spacing` actually does: it inserts the gap between
every adjacent pair, and never at the leading or trailing edge. So:

| Shape | Convert? | Why |
|---|---|---|
| `[A, g8, B, g8, C]` | ✅ | uniform, between every pair — identical output |
| `[A, g8, B, g16, C]` | ❌ | `spacing` cannot vary; converting changes layout |
| `[A, g8, B, C]` | ❌ | would **add** a gap between B and C |
| `[g8, A, B]` / `[A, B, g8]` | ❌ | edge pad, not a gap; `spacing` cannot express it |
| single child | ❌ | no adjacent pair exists |

**Sizing** (heuristic scan, 2026-08-17 — a balanced-delimiter scan over
`Row(`/`Column(` spans, not a Dart parser; treat as an estimate):

| Measure | Count |
|---|---|
| `Row`/`Column` containing at least one spacer | 85 |
| **Clean candidates** | **40** |
| Spacers removed by those | 41 |
| Files touched | 23 |
| Skipped — non-uniform sizes | 31 |
| Skipped — uniform but not between every pair | 14 |

**⚠ 40 is a floor, not the total.** The scan cannot see through
collection-`if` children, so it misclassifies exactly the case the spec uses
as its worked example: `sale_line_card.dart`'s outer `Column` is reported as
"partial gaps" and skipped, when it is in fact convertible — its four
`SizedBox(height: 8)` are uniform, and the conditional last child carries its
own `Padding(top: 8)` precisely because a collection-`if` child cannot take a
preceding spacer. Converting collapses that `Padding` too. Implementers must
read these by hand; the scan narrows where to look, it does not decide.

**Token adoption stays out** (spec Clarifications): converted sites keep their
literal value. `Spacing.fieldGapVertical`/`fieldGapHorizontal` are
**tier-dependent**, so swapping them in would change layout at some tiers —
the one thing US2 promises not to do. `Spacing.xs`/`xxs` are fixed at 8/4 and
would be safe, but adopting tokens for some sites and not others is worse than
adopting none.

**Alternatives considered**: a lint to enforce the style going forward
(rejected for this feature — `analysis_options.yaml` is stock `flutter_lints`,
no custom-lint infrastructure exists, and US2 is explicitly scoped small);
converting non-uniform Flexes by picking the dominant gap and padding the odd
one out (rejected — that is a redesign wearing a refactor's clothes).

---

## R8 — Sequencing and test strategy

**The one hard ordering constraint**: the guard test lands **after** the final
call site migrates. Landing it earlier fails the suite for the entire
migration. Everything else is free.

Proposed order within US1:

1. Build `lib/core/formatting/` + `formattersProvider`, with unit tests. No
   call site touched; both old paths still alive and green.
2. Add `FormattingSettings` to `AppSettings`, and document the keys in
   `.env.template`.
3. Migrate call sites feature-module by feature-module.
4. Delete `MoneyFormatters` and `money.dart`'s display helpers (R6).
5. Re-record baselines (R5).
6. Land the guard (R2).
7. Amend the constitution (FR-029) in the same change as step 6 — the rule and
   the code that satisfies it land together, per §Governance practice.

**Test strategy**, mapped to constitution §Development Workflow:

| Level | What |
|---|---|
| Unit | Every `display.*` and `field.*` method, including `null`/unparseable → `—`. Round-trip asserted as a **property** (`parseX(field.x(v)) == v`) over generated values, not per-example — 027's design called for this and it is the only way to cover values whose stored precision exceeds displayed precision. |
| Unit | `FormattingSettings.fromEnvironment` falls back per-key on malformed input without throwing. |
| Unit | The guard itself (R2) — plus a deliberately-planted violation proving it fails, then removed. SC-006 requires this. |
| Widget | One screen per formatted data type renders through the provider; overriding `appSettingsProvider` with `DATE_FORMAT=d/M/yyyy` changes the rendering (SC-003). |
| Golden | Re-recorded once (R5), then unchanged by US2 (FR-027). |

**No backend dependency.** Nothing in this feature touches mbe-api, so
constitution §Development Workflow's codegen/RBAC clauses do not apply. No
mbe-api issue to file.

**US2 needs no new tests.** Its correctness criterion is that the existing
golden and screenshot suites pass unchanged; adding tests for it would be
testing Flutter's `Flex`, not this repo's code.
