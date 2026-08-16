# Phase 0 Research: App Settings, User Settings & Cross-Widget Consistency

**Feature**: 027-app-user-settings | **Date**: 2026-08-16

Every unknown in the plan's Technical Context is resolved here. Findings that
change the shape of the work are marked **⚠**.

> **Descope note (2026-08-16).** Value formatting was moved out of 027 into a
> future spec *because of* R8's audit. **R3, R4 and R8's formatting half stay
> here, complete and unchanged** — they are that spec's finished Phase 0, and
> re-deriving them costs a full re-audit. They describe work 027 does not do.

---

## R1 — How four app-wide text-size levels are applied

**Decision**: a custom `TextScaler` that *composes* the platform's own scaler
with the chosen level's factor, injected via `MediaQuery` in `App.build`'s
existing `builder` callback — above `DesignTheme.forTier`, so every route,
dialog and sheet below inherits it.

```dart
// core/design/text_scale.dart (sketch, not final)
class _LevelTextScaler extends TextScaler {
  const _LevelTextScaler(this.parent, this.factor);
  final TextScaler parent;
  final double factor;
  @override double scale(double fontSize) => parent.scale(fontSize * factor);
  @override double get textScaleFactor => parent.textScaleFactor * factor;
}
```

**Rationale**:

- **At the default level the factor is 1.0 and the composition is the
  identity** — the widget tree is byte-identical to today. That matters
  concretely: `test/golden/core_widgets_golden_test.dart` and
  `test/screenshots/pos_screens_screenshot_test.dart` hold pixel baselines,
  and a mechanism that perturbed the default would force a mass re-baseline
  that hides real regressions in the noise.
- **Composing, rather than replacing, preserves OS-level accessibility.** A
  user who already scaled text at the OS level keeps that scaling and applies
  the app level on top. Replacing it would mean a user on a 1.5× system who
  picks "Grande" (1.15×) gets *smaller* text than before — an accessibility
  regression disguised as an accessibility feature.
- **Delegating to `parent.scale` rather than multiplying a factor** keeps
  non-linear platform scalers (Android 14+) correct; `TextScaler` is not
  guaranteed linear, and `textScaleFactor` is deprecated precisely because it
  assumes it is.
- The `DesignTheme.forTier` memo cache is keyed on `(base, tier)`. Because
  this approach never rebuilds `TextTheme`, that cache stays at its documented
  ceiling of 8 live entries instead of growing 4× with levels.

**Alternatives considered**:

- *Scale the `TextTheme` inside `AppTheme`*: produces a new `base` per level,
  multiplying the theme cache to 32 entries, losing `TextScaler` semantics
  (widgets that set explicit font sizes wouldn't scale), and defeating
  Flutter's own text-scaling machinery. Rejected.
- *`MediaQuery(textScaler: TextScaler.linear(f))`, replacing the platform
  scaler*: simplest, but discards OS accessibility settings. Rejected on the
  regression above.

**Level factors** (four, per FR-019): `0.9 / 1.0 / 1.15 / 1.3`, default 1.0.
Chosen so the default is exactly today's rendering, the largest is a
meaningful accessibility gain, and the range stays inside what the POS
capture surface can absorb (R2).

---

## R2 — ⚠ The POS capture surface at the largest text size (FR-024)

**Finding**: this is the real risk the spec flagged, and it is concentrated in
one file. `features/sales/presentation/capture/sale_line_layout.dart` hard-codes
a set of constants derived from a **14 px body role at a 1.43 line height**:

| Constant | Value | Derivation |
|---|---|---|
| `saleLineSingleRowMinWidth` | 950 | measured column budget + 6 gaps + 202 px product cell |
| `saleLineFieldHeight` | 52 | the height every control in the band shares |
| `_saleLineTextContentHeight` | 20 | one line of the body role (14 × 1.43) |
| `_saleLineDropdownContentHeight` | 24 | Flutter's `_kDenseButtonHeight` floor |
| `saleLineTextFieldPadding` | (52−20)/2 = 16 | derived |
| `saleLineDropdownPadding` | (52−24)/2 = 14 | derived |

At 1.3× the body line becomes ~26 px, so a 52 px band would clip its own text,
and the width a single row needs exceeds 950.

**Decision**: derive the *vertical* constants from the effective text scaler
rather than hard-coding them, and scale the single-row width threshold by the
same factor. Column widths themselves stay fixed.

- The vertical constants are **arithmetic on a line height**, not measurements
  — `_saleLineTextContentHeight` is literally `14 × 1.43`. Scaling them is
  therefore mechanical and preserves the file's own invariant: text fields and
  dropdowns pay the difference *in padding* so both boxes end the same height
  and both centre their text on the same baseline (which is what US6 is
  about — the two requirements resolve to the same code).
- Scaling `saleLineSingleRowMinWidth` means the **existing, designed fallback
  engages** instead of the row overflowing: `SaleLineRow` already drops to a
  two-row layout below the threshold, and `capture_step.dart` already drops to
  `SaleLineCard` below 600 px. A 1024 px tablet at 1.3× falling to two rows is
  the responsive design working, not a defect.
- Column widths stay fixed and their secondary text ellipsizes, which
  constitution §VI already permits for non-critical columns. Money, totals and
  status are never truncated.

**Verification**: `test/widget/features/sales/sale_line_row_test.dart` already
pumps a real line at the tablet's real width and fails on overflow. Extend it
to a loop over all four levels. That test is what kept the original budget
honest (it caught the quantity column's first, too-tight 104 px); it is the
right instrument here too.

**Alternative considered**: capping the text scaler for the POS capture
subtree only. Rejected — it makes the app's most-used screen the one place
accessibility silently doesn't apply, and the fallback layouts already exist
precisely for this.

---

## R3 — The shape of the shared formatting surface *(deferred — future spec)*

**Decision**: a Riverpod `Provider<AppFormatters>` (`formattersProvider`),
derived from `appSettingsProvider` and the resolved locale. `AppFormatters` is
an immutable value object holding pre-built `intl` formatters. Call sites
resolve it **once per build** and close over it.

```dart
// in a ConsumerWidget's build:
final fmt = ref.watch(formattersProvider);
...
DataTableColumn(cellBuilder: (context, s) => Text(fmt.dateTime(s.start)))
```

**Rationale**:

- **It satisfies FR-013 structurally, not by convention.** There is no
  `locale:` parameter to pass, because the provider owns the locale.
- The provider is the *only* place locale is resolved, and it is the same
  value that drives `MaterialApp.locale` (R5) — so the interface language and
  the formatted values can never disagree, which is exactly the class of bug
  this feature exists to remove.
- Constitution §II already requires state and DI to go through Riverpod, and
  requires providers so tests can override them. A test can now pin formatting
  by overriding one provider instead of passing a locale string into 53 call
  sites.
- **Resolving once per build is strictly cheaper than today.** The current
  code calls `Localizations.localeOf(context).toString()` per screen and then
  re-enters `NumberFormat.currency(...)`/`DateFormat(...)` **per cell** — a
  table of 50 rows × 3 formatted columns constructs 150 formatters per frame.
  Pre-built formatters in a cached value object eliminate that.

**Numeric type**: the API stays `String` in, `String` out. Domain entities
carry raw decimal strings end-to-end (spec 011 research §3) and must not
round-trip through `double` for storage. Internally the surface parses with
`Decimal.tryParse` for validity, and converts to `double` only at the final
`NumberFormat.format` call, which requires a `num`. This preserves both
existing behaviors rather than picking one.

**Read-only vs. editable (FR-011/FR-012)**: two explicitly named groups on the
same object, not two ad-hoc conventions:

- `display.*` — `currency`, `percent`, `date`, `dateTime`, `quantity`. Carries
  symbols, fixed decimals, locale separators.
- `field.*` — `price`, `rate`, `quantity`. No currency symbol, trailing zeros
  dropped, rates shown as the percentage the cashier thinks in, and a matching
  `parse*` for each so FR-012's round-trip is testable as an identity property.

**Alternatives considered**: a `BuildContext` extension over an
`InheritedWidget` (rejected — a second DI mechanism beside Riverpod, which §II
forbids); a static class reading a global (rejected — untestable, and it is
what `MoneyFormatters` already is).

---

## R4 — The out-of-band formatting guard (FR-015) *(deferred — future spec)*

**Decision**: a source-scanning unit test, following the precedent already in
this repo. `test/unit/core/layering_test.dart` scans `lib/` for a banned
import and `test/unit/core/l10n_parity_test.dart` parses the `.arb` files —
both are plain `dart:io` tests, no new tooling.

The guard bans, outside an explicit allowlist:

1. `import 'package:intl/...'` — the strongest and simplest signal, since
   `DateFormat`/`NumberFormat` are unreachable without it.
2. `toStringAsFixed(` anywhere under `presentation/`.

**Allowlist** (FR-015's required exemptions, each justified in the test's own
doc comment):

- the formatting surface itself,
- `lib/generated/**` (generated, never hand-edited — constitution §III),
- `lib/main.dart` (`initializeDateFormatting`),
- `features/sales/presentation/pos_sales_list_controller.dart`'s
  `_dateFacetFormat` — a **query-parameter encoder**, not a display path; it
  produces `yyyy-MM-dd` for a URL facet and must stay locale-*in*dependent.

**Rationale**: a custom lint rule would need `custom_lint`/`analyzer` plugin
wiring and a new dependency for one rule; a test costs one file and runs in
the existing suite. Rejected the lint on cost, not on principle — if the repo
adopts `custom_lint` for other reasons, this rule should move there.

---

## R5 — Preference loading, and an existing defect it fixes

**Finding**: `ThemeModeController.build()` returns `ThemeMode.system` and then
`_restore()`s asynchronously from `SharedPreferences`. There is therefore a
frame (or several) where a user who chose Dark sees the light theme — a
visible flash that exists today. Adding locale and text scale to the same
pattern would triple it, and a locale flash is worse: it re-runs
`MaterialApp`'s localization delegates.

**Decision**: load `SharedPreferences` **once in `main()` before `runApp`**,
and inject it through a `ProviderScope` override:

```dart
final prefs = await SharedPreferences.getInstance();
runApp(ProviderScope(
  overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  child: const App(),
));
```

Every preference controller then reads synchronously in `build()`, so the
first frame is already correct. This removes the existing flash rather than
propagating it, and it gives tests a first-class seam (override the provider
with `SharedPreferences.setMockInitialValues`).

**Corrupt/unreadable storage (FR-022)**: each controller's read is
`try`-guarded and falls back to the default; an unparseable stored value is
treated as absent, never as a startup error.

---

## R6 — The cash-session shift sheet (FR-027)

**Decision**: extract the responsive sheet *shell* out of
`core/widgets/catalog_filter_sheet.dart` into a shared
`showAppSideSheet(...)`, have `showCatalogFilterSheet` delegate to it, and
build the shift sheet on the same shell with its own footer.

**Rationale**: that file already solves the two hard problems and documents
why:

- **Presentation**: modal bottom sheet below `LayoutBreakpoints.expanded`,
  right-anchored 360 px side sheet above it, with the slide transition.
- **`useRootNavigator: true`**: each list lives in its own
  `StatefulShellBranch` with a nested Navigator, and a sheet attached to that
  nested Navigator is torn down by `context.go`'s declarative page-stack
  rebuild. The shift sheet needs exactly this: the spec's edge case has the
  blocked-by-another-session error calling `context.push` to that session's
  detail screen from inside the sheet.

Re-solving either from scratch for a second sheet is how the two diverge.

**Sheet chrome differs** and is *not* shared: the filter sheet's footer is
Clear all / Apply; the shift sheet's is the open/close action. Only the shell
(presentation, sizing, navigator, transition, header) is common.

---

## R7 — Consolidating build-time settings without breaking `const`

**Finding**: `String.fromEnvironment` only reads the compile-time value in a
`const` context. The existing keys, which MUST be preserved (FR-003) so
current deployment scripts keep working:

| Key | Default | Site today |
|---|---|---|
| `API_BASE_URL` | `http://127.0.0.1:8000` | `core/network/dio_client.dart` |
| `PHOTOS_BASE_URL` | *(defaults to `apiBaseUrl`)* | `core/network/photo_url.dart` |
| `POS_DEFAULT_CUSTOMER_ID` | `1` | `features/sales/pos_defaults.dart` |
| `BRAND_DISPLAY_NAME` | `Mictlanix Business Essentials` | `core/branding/brand_config.dart` |
| `BRAND_SEED_COLOR` | *(unset ⇒ XBE palette)* | idem |
| `BRAND_WELCOME_ASSET` | *(unset)* | idem |
| `BRAND_LOCKUP_ASSET` | `assets/brand/login_lockup.png` | idem |
| `BRAND_MARK_ASSET` | `assets/brand/nav_lockup.png` | idem |
| `ENABLE_FLUTTER_DRIVER_EXTENSION` | `true` | `lib/main.dart` |

**Decision**: follow the `BrandConfig.fromEnvironment()` pattern already
proven here — an `AppSettings.fromEnvironment()` factory whose body is a
sequence of `const String.fromEnvironment(...)` reads, exposed as
`appSettingsProvider` so tests can override it. **`BrandConfig` is composed,
not absorbed**: it already has this exact shape, its own provider, its own
tests, and spec 019 semantics (`usesDefaultPalette` distinguishes "unset" from
"set to the default value"). `AppSettings` holds a `BrandConfig` field.

**⚠ Constraint discovered**: `PHOTOS_BASE_URL`'s default is `apiBaseUrl` — a
const cross-reference between two settings. Consolidation must keep both as
top-level `const`s (or `static const`s) so that defaulting still resolves at
compile time; a runtime-constructed object cannot express it. This is why the
new keys are added as `const` fields rather than a map.

**New keys** (formatting + locale), all with defaults matching today's
rendering exactly, so no existing deployment changes appearance:

`CURRENCY_SYMBOL` (`$`), `CURRENCY_CODE` (`MXN`), `CURRENCY_DECIMAL_DIGITS`
(`2`), `DATE_FORMAT` (`yMd`), `DATE_TIME_FORMAT` (`yMd Hm`), `PERCENT_DECIMAL_DIGITS`
(`2`), `QUANTITY_DECIMAL_DIGITS` (`0`, trailing zeros dropped),
`DEFAULT_LOCALE` (`es_MX`).

**Malformed values (FR-005)**: parse-with-fallback, exactly as
`BrandConfig._parseSeedColor` already does for a bad hex — "a malformed build
flag must not brick app startup" is an established rule here, not a new one.

---

## R11 — ⚠ `.env` already has an owner

**Finding**: `.env` is **gitignored** (`.gitignore:21` — "Local integration-test
credentials") and `.env.template` documents *only* integration-test
credentials: `MBE_ADMIN_USERNAME`, `MBE_POS_PASSWORD`, and ~15 more, consumed
by `test/integration/*_test.dart` via `flutter test --dart-define-from-file=.env`.

Putting deployment configuration in the same file needs a deliberate answer,
because the two have opposite lifecycles: test credentials are per-developer
and secret; deployment configuration is per-customer and belongs with the
deployment.

**Decision**: keep one *format* and one *mechanism*, but two *files*.

- **`.env`** stays what it is — the developer's local, gitignored file. It may
  now also carry local overrides of app settings, which is convenient and
  harmless since every key has a default.
- **Deployment configuration lives in its own file per customer**, e.g.
  `deploy/casa-maestra.env`, passed the same way:
  `flutter build web --dart-define-from-file=deploy/casa-maestra.env`. Whether
  those files are committed is the deployment's call; they contain no secrets
  (endpoints, brand tokens, formats).
- **`.env.template` gains a second section** for app settings, keeping its
  existing test-credential section intact. It remains the single documentation
  source FR-006 requires, now covering both.

**Rationale**: the mechanism is already proven here and needs no change; only
the file's audience widens. Forcing deployment config into a gitignored
developer file would make it undiscoverable, and inventing a second mechanism
for deployments would contradict FR-002's "one place".

**Consequence for testing**: integration tests run with
`--dart-define-from-file=.env`, so they pick up whatever app settings that
file sets. Tests asserting configured behaviour must override
`appSettingsProvider` rather than depend on the developer's `.env` — otherwise
a developer with a local override sees spurious failures. This is why
`appSettingsProvider` is overridable (constitution §II).

---

## R8 — ⚠ Compliance inventory (FR-030)

Scanned all 17 list screens that use `CatalogFilterBar`.

**Filter-drawer rule — 2 violations, not 1:**

| Screen | State |
|---|---|
| `features/sales/presentation/pos_sales_list_screen.dart` | **In scope (US4)**. `filters:` holds a `DateRangeFilterChip` and a status `PopupMenuButton`; no drawer, no badge. |
| `features/pricing/presentation/exchange_rates_list_screen.dart` | **⚠ Newly found, out of scope.** `filters:` holds an inline `OutlinedButton.icon` opening `showDateRangePicker` directly — no drawer, no active-filter badge. Also calls `MoneyFormatters.date` with no locale. Correct when next touched. |

The other 15 comply: 10 pass a `Badge.count` + `IconButton.outlined(Icons.tune)`
into `filters:` and open `showCatalogFilterSheet`; 5 (labels, expenses,
price_lists, suppliers, taxpayer_recipients/issuers) pass no `filters:` at all
because they have no facets — compliant by construction, not by omission.

**Formatting rule — migration size** *(this audit is why formatting was
descoped; the numbers size the future spec)*:

- **53** `MoneyFormatters.*` call sites across **22** files.
- **24** call sites of the `money.dart` display helpers.
- 1 inline `DateFormat.yMd()` (`taxpayer_certificates_section.dart:51`).
- 1 `DateFormat` that is *correctly* exempt (`pos_sales_list_controller.dart`,
  query encoder — R4).

≈78 call sites. Mechanical, but larger than the rest of 027 combined, and
**indivisible**: the guard test only becomes satisfiable once the last call
site moves, so a partial migration leaves both paths alive *and* no guard.
That is what took it out of this feature and into its own spec.

**Symmetry rule**: not mechanically detectable by grep. Scope stays the POS
sale line (US6); the constitution rule governs new work.

---

## R9 — Runtime locale switching

**Decision**: `MaterialApp.locale` is driven by the same resolved-locale
provider that feeds `formattersProvider` (R3), replacing the hard-coded
`Locale('es', 'MX')` in `app.dart:30`. Resolution order: user preference →
app-settings default → `supportedLocales.first`.

`main.dart` already calls `initializeDateFormatting()` with no argument, which
loads **all** locales' date symbols — so switching locale at runtime needs no
additional initialization. A user preference naming an unsupported locale
falls back to the deployment default (spec edge case), which
`supportedLocales` makes checkable.

**Unsaved-input edge case**: changing locale rebuilds under a new
`Localizations`, but does **not** remount route widgets, so form controller
state survives. The settings screen holds no other screen's state. Confirmed
as a behavior to assert in a widget test rather than a risk to design around.

---

## R10 — Test strategy summary

| Requirement | Instrument | Notes |
|---|---|---|
| ~~FR-008…015~~ | *(deferred with the formatting spec)* | R3/R4 hold the design |
| FR-001…007 | unit tests on `AppSettings.fromEnvironment` | malformed-value fallbacks |
| FR-016…023 | widget tests on the settings screen | prefs via `setMockInitialValues` |
| FR-024 | `sale_line_row_test.dart` × 4 levels | R2 |
| FR-025…029 | widget tests on both screens | badge count, drawer, sheet dismissal |
| FR-031…035 | measuring widget tests | assert insets equal, baselines coincide |
| Regression | existing goldens + screenshots | unchanged at the default level (R1) |
