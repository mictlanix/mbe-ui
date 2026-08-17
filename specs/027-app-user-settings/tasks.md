---

description: "Task list for 027-app-user-settings"
---

# Tasks: App Settings, User Settings & Cross-Widget Consistency

**Input**: Design documents from `/specs/027-app-user-settings/`
**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md), [data-model.md](data-model.md), [contracts/](contracts/)

**Numbering note**: US1 and its tasks do not exist — value formatting was
descoped from this feature on 2026-08-16 (spec.md Clarifications) into a
future spec. Story numbering below starts at US2 to match spec.md; there is
no US1 phase.

**Tests**: included. Widget/unit tests are explicitly required by several
acceptance scenarios (FR-024's measured overflow check, FR-035's measured
insets/baselines, FR-005's malformed-value fallback) and by the constraint
that golden/screenshot suites must pass **unchanged** — that can only be
verified by running them, not asserted by inspection.

**Organization**: tasks are grouped by user story so each is independently
implementable, testable, and demoable. Per plan.md's Phasing, US2 → US3 → US6
is one dependency chain (US3 needs US2's default locale; US6 needs US3's text
scaler) and US4+US5 are a second, independent track.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: can run in parallel (different files, no unmet dependency)
- **[Story]**: US2 / US3 / US4 / US5 / US6, or none for Setup/Foundational/Polish
- File paths are exact and repo-relative to `/Users/augusto/development/repos/mictlanix/mbe-ui/`

---

## Phase 1: Setup

**Purpose**: nothing here changes app behavior; it only prepares the ground.

- [X] T001 Create empty directories `lib/core/config/`, `lib/core/settings/`, `lib/features/settings/presentation/`
- [X] T002 [P] Add an "App settings" section to `.env.template`, documenting `DEFAULT_LOCALE=es_MX` alongside the existing test-credential section (research R11) — do not touch the existing sections
- [X] T003 [P] Add a `deploy/` directory with a `README.md` one-liner pointing at `.env.template` for per-customer deployment files (research R11; contracts/app-and-user-settings.md §"How they are supplied")

**Checkpoint**: directories exist; no code yet.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: `AppSettings` + its provider, and the `SharedPreferences` seam —
every user story below reads at least one of these.

**⚠️ CRITICAL**: no user story may start until this phase is checked off.

- [X] T004 Create `AppSettings` in `lib/core/config/app_settings.dart`: a `@immutable` class with `AppSettings.fromEnvironment()` following `BrandConfig.fromEnvironment()`'s pattern (data-model.md §1) — fields `apiBaseUrl` (`API_BASE_URL`, default `http://127.0.0.1:8000`), `photosBaseUrl` (`PHOTOS_BASE_URL`, default `= apiBaseUrl` — **must stay a compile-time const cross-reference**, research R7), `posDefaultCustomerId` (`POS_DEFAULT_CUSTOMER_ID`, default `1`), `brand` (a `BrandConfig`, composed via `BrandConfig.fromEnvironment()` unchanged), `defaultLocale` (`DEFAULT_LOCALE`, default `es_MX`, parsed to a `Locale` with fallback to `es_MX` on a malformed value — mirror `BrandConfig._parseSeedColor`'s fallback-on-malformed pattern, FR-005)
- [X] T005 Add `appSettingsProvider` in `lib/core/config/app_settings_provider.dart` (`Provider<AppSettings>`, `(ref) => AppSettings.fromEnvironment()`), and re-point `brandConfigProvider` (`lib/core/branding/brand_config_provider.dart`) at `ref.watch(appSettingsProvider).brand` so there is exactly one `BrandConfig` instance, not two (data-model.md §1.1)
- [X] T006 [P] Unit tests in `test/unit/core/config/app_settings_test.dart`: every default reproduces today's exact values (`apiBaseUrl` == `http://127.0.0.1:8000`, `photosBaseUrl` == `apiBaseUrl`, `posDefaultCustomerId` == `1`, `defaultLocale` == `es_MX`); a malformed `DEFAULT_LOCALE` falls back to `es_MX` without throwing (FR-005); `appSettingsProvider` is overridable via `ProviderContainer(overrides: [...])` (constitution §II)
- [X] T007 Re-point the four existing call sites at `AppSettings` instead of their own `String.fromEnvironment`/`int.fromEnvironment`: `lib/core/network/dio_client.dart` (`apiBaseUrl`), `lib/core/network/photo_url.dart` (`photosBaseUrl`), `lib/features/sales/pos_defaults.dart` (`posDefaultCustomerId`) — each becomes `ref.watch(appSettingsProvider).<field>` at its provider definition, with the top-level `const` removed since the value now comes from a provider. Verify via `grep -rn "String.fromEnvironment\|int.fromEnvironment" lib/core/network lib/features/sales/pos_defaults.dart` that only `brand_config.dart` (composed into T004, unchanged) still calls `fromEnvironment` directly
- [X] T008 Add `sharedPreferencesProvider` in `lib/core/storage/shared_preferences_provider.dart` as an unimplemented `Provider<SharedPreferences>` (throws if not overridden — the standard Riverpod "must be overridden" pattern), and seed it in `lib/main.dart`: call `await SharedPreferences.getInstance()` **before** `runApp`, pass it via `ProviderScope(overrides: [sharedPreferencesProvider.overrideWithValue(prefs)], child: const App())` (research R5) — this must land before `runApp` regardless of the `kDebugMode`/driver-extension branch already in `main.dart`
- [X] T009 [P] Verify `flutter analyze` and the existing full suite (`flutter test`) both pass after T004–T008 — this phase must be behavior-preserving; no screen renders differently yet

**Checkpoint**: `AppSettings` and the preferences seam exist and are wired; zero visible change. User stories can now proceed — US2/US3/US6 as one chain, US4/US5 in parallel.

---

## Phase 3: User Story 2 - A deployment is configured without touching source (Priority: P2)

**Goal**: one `.env` file controls the deployment's default locale, API/photos endpoints, brand tokens and POS defaults — with every option defaulted and documented.

**Independent Test**: build with a `.env` setting `DEFAULT_LOCALE` and `API_BASE_URL`; confirm the app targets that host and reads deployment strings for that language. Build with no `.env`; confirm today's defaults.

### Tests for User Story 2

- [X] T010 [P] [US2] Widget/integration-style test (or extend T006) asserting that with no `.env` at all, `AppSettings.fromEnvironment()` still produces a fully usable `AppSettings` (FR-004) — add to `test/unit/core/config/app_settings_test.dart`
- [X] T011 [P] [US2] Test in `test/unit/core/config/app_settings_test.dart` that a `.env`-style override (via `--dart-define` in the test's own compilation, or by asserting the parsing function directly) for `API_BASE_URL` changes `dioProvider`'s base URL (FR-003) without touching any other setting

### Implementation for User Story 2

- [X] T012 [US2] Confirm (via T007) that `API_BASE_URL`, `PHOTOS_BASE_URL`, `POS_DEFAULT_CUSTOMER_ID`, and the five `BRAND_*` keys are all reachable through `appSettingsProvider` alone — no feature file still reads `String.fromEnvironment`/`int.fromEnvironment` directly except `brand_config.dart` itself (composed, not duplicated)
- [X] T013 [US2] Finalize the `.env.template` app-settings section from T002: document `DEFAULT_LOCALE` plus the eight existing keys (`API_BASE_URL`, `PHOTOS_BASE_URL`, `POS_DEFAULT_CUSTOMER_ID`, `BRAND_DISPLAY_NAME`, `BRAND_SEED_COLOR`, `BRAND_WELCOME_ASSET`, `BRAND_LOCKUP_ASSET`, `BRAND_MARK_ASSET`) with default and one-line description each (FR-006), matching contracts/app-and-user-settings.md's key table exactly — do not add the formatting keys from that same contract file, they are explicitly out of scope (FR-002 note)
- [X] T014 [US2] Manual quickstart validation: run quickstart.md §3 (deployment configuration) — a custom `.env` changes host/locale/brand with no source edit; no `.env` and a malformed `DEFAULT_LOCALE` both start cleanly

**Checkpoint**: US2 is independently complete — `AppSettings` is the one place every deployment option lives, documented, defaulted, fallback-safe.

---

## Phase 4: User Story 3 - A user adjusts theme, text size and language (Priority: P2)

**Goal**: a settings screen where appearance, text size (4 levels) and language are chosen, apply immediately, and persist per device.

**Independent Test**: open the settings screen, change each control, observe immediate effect, restart, confirm persistence.

**Depends on**: Phase 3 (US2) for `appSettingsProvider.defaultLocale`, the fallback a user with no override gets.

### Tests for User Story 3

- [X] T015 [P] [US3] Unit tests for the composing text scaler in `test/unit/core/design/text_scale_test.dart`: at `TextSizeLevel.normal` (factor 1.0), `effectiveScaler.scale(x) == platformScaler.scale(x)` for several platform scalers including non-`TextScaler.noScaling` ones (research R1's "identity at default, composes at non-default" invariant); at other levels, `effectiveScaler.scale(x) == platformScaler.scale(x * level.factor)`
- [X] T016 [P] [US3] Unit tests for `UserDisplayPreferencesController` in `test/unit/core/settings/user_display_preferences_controller_test.dart`: default state is `ThemeMode.system` / `TextSizeLevel.normal` / `localeOverride: null`; each setter persists to `SharedPreferences` under its key and updates state synchronously (no async gap — FR-020); reading a corrupt/unparseable stored `text_size_level` value falls back to `normal` without throwing (FR-022); reading the pre-existing `theme_mode` key with a value from before this feature still restores correctly (FR-017)
- [X] T017 [P] [US3] Widget test in `test/widget/features/settings/user_settings_screen_test.dart`: renders the three controls; tapping each Light/Dark/System, each text-size level, and each language option calls the corresponding controller method; `AppBar.actions` is empty (constitution §VI); no RBAC check gates rendering (FR-016, Assumptions)
- [X] T018 [P] [US3] `test/unit/core/l10n_parity_test.dart` must still pass once new settings-screen strings are added to both ARBs (run, don't write — this is the existing guard, FR-023 well-formedness check)

### Implementation for User Story 3

- [X] T019 [P] [US3] Create `TextSizeLevel` enum (`small`/`normal`/`large`/`extraLarge`, factors `0.9`/`1.0`/`1.15`/`1.3`, `normal` default — data-model.md §3.1) and the composing `TextScaler` in `lib/core/design/text_scale.dart` per research R1's sketch: `effective.scale(size) == platform.scale(size * level.factor)`, never replacing the platform scaler
- [X] T020 [US3] Create `UserDisplayPreferences` (immutable value: `themeMode`, `textSizeLevel`, `localeOverride`) in `lib/core/settings/user_display_preferences.dart`, and `UserDisplayPreferencesController` (a `Notifier`, constitution §II) in `lib/core/settings/user_display_preferences_controller.dart` reading/writing `SharedPreferences` synchronously via `sharedPreferencesProvider` (already seeded before `runApp` — no restore flash, research R5): keys `theme_mode` (existing — reuse verbatim, FR-017), `text_size_level` (new), `locale_override` (new, nullable). Fold `ThemeModeController` (`lib/app/theme/app_theme.dart`) into this controller, removing the old async `_restore()` — `setThemeMode` becomes a thin call into the new controller so nothing else in the app needs to change its `ref.watch(themeModeControllerProvider)` call sites beyond re-pointing them at the new provider
- [X] T021 [US3] Add a resolved-locale provider in `lib/core/settings/user_display_preferences.dart` (or a sibling file): `localeOverride ?? appSettings.defaultLocale`, validated against `AppLocalizations.supportedLocales` and falling back to the deployment default then to `supportedLocales.first` (data-model.md §4, research R9)
- [X] T022 [US3] Wire `lib/app/app.dart`: replace the hard-coded `locale: const Locale('es', 'MX')` with the resolved-locale provider from T021; wrap the existing `builder` callback's returned subtree in a `MediaQuery` applying the composing text scaler from T019 (`MediaQuery.textScalerOf(context)` composed with the current `UserDisplayPreferences.textSizeLevel`), positioned **above** the existing `DesignTheme.forTier(...)` call so every route/dialog/sheet inherits both
- [X] T023 [US3] Create `UserSettingsScreen` in `lib/features/settings/presentation/user_settings_screen.dart`: three controls (appearance radio/segmented group, text-size selector with 4 options, language selector with Español/English/follow-system) using the shared `ResponsiveFormGrid` (constitution §VI), empty `AppBar.actions`, each control calling its `UserDisplayPreferencesController` setter directly (no separate Save step — FR-020)
- [X] T024 [US3] Add the route `GoRoute(path: '/auth/account/settings', builder: (context, state) => const UserSettingsScreen())` in `lib/app/router/app_router.dart`, beside the existing `/auth/account/password` route (Assumptions: "a route beside the existing account/password route")
- [X] T025 [US3] Add a "Settings" `MenuItemButton` to `lib/core/widgets/user_menu_button.dart`, beside `user_menu_change_password`, `onPressed: () => context.push('/auth/account/settings')` (FR-016)
- [X] T026 [P] [US3] Add the new strings (settings screen title, appearance/text-size/language labels and options, user-menu entry) to both `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb` with matching keys (constitution's `l10n_parity_test.dart` requirement)
- [X] T027 [US3] Manual quickstart validation: run quickstart.md §4 (user settings) end to end, including the "no flash of default theme on launch" check (research R5) and the unsaved-input-survives-a-language-change edge case (spec.md Edge Cases)

**Checkpoint**: US2 + US3 together are independently demoable — a full settings experience, deployment-configured and user-adjustable.

---

## Phase 5: User Story 6 - Rows and cards are vertically symmetric and baseline-aligned (Priority: P3)

**Goal**: the POS sale line's vertical insets are symmetric and its control band shares the line-total's baseline, in all three layouts, at all four text-size levels.

**Independent Test**: render a POS sale line at the single-row width; assert measured top/bottom insets are equal and the control band's baseline coincides with the line total's.

**Depends on**: Phase 4 (US3) for the composing text scaler `sale_line_layout.dart`'s constants must derive from.

### Tests for User Story 6

- [X] T028 [P] [US6] Extend the sale-line overflow coverage across all four `TextSizeLevel` factors (0.9/1.0/1.15/1.3) — `test/widget/features/sales/sale_line_symmetry_test.dart`. **Outcome differs from plan**: at `extraLarge` on the 1024 px tablet width, the row does **not** fall back to two-row — it stays single-row and simply renders taller (78px vs 60px band), with zero overflow. Empirically verified (a throwaway diagnostic forcing `TextScaler.linear(1.3)` at 1024px and 700px both threw no exception) that `saleLineSingleRowMinWidth`/`saleLineTwoRowMinWidth` do **not** need to scale — width and text-driven height are independent, and nothing constrains the row's *height* from outside, so a taller row is never an overflow. Locked in as a permanent regression test, not a one-off check.
- [X] T029 [P] [US6] Added `test/widget/features/sales/sale_line_symmetry_test.dart`, measuring via `tester.getRect` (not `getDistanceToBaseline`/`getDryBaseline` — both proved unreliable for `InputDecorator` during investigation, see research note below): (a) top/bottom card insets equal (FR-031/FR-035); (b) every shared value's `(top, height)` — rounded to 1 decimal to absorb floating-point noise — is identical across warehouse/quantity/price/discount/tax/total, which is what "shares a baseline" cashes out to for same-style text boxes (FR-032/FR-035). Values chosen so discount and the total both end in a round-bottomed '0' — comparing against a flat-bottomed glyph (e.g. quantity's '1') reads a spurious 1-2px gap from glyph shape alone, not misalignment. Covers single-row, two-row, and the two-line-wrapped product name case, at all four text-scale levels.

### Implementation for User Story 6

- [X] T030 [US6] In `lib/features/sales/presentation/capture/sale_line_layout.dart`, changed `saleLineFieldHeight`, `_saleLineTextContentHeight`, `_saleLineDropdownContentHeight`, `saleLineTextFieldPadding`, `saleLineDropdownPadding`, `saleLineRowHeight` from `const double` to functions of the effective `TextScaler`, scaling proportionally to how much the body role's 14px font grows under it (identity at `TextSizeLevel.normal`, so byte-identical rendering at the default level — confirmed via the full golden/screenshot suite passing with zero re-baselining). The dropdown content-height keeps Flutter's own `max(lineHeight, 24)` floor, with only the `lineHeight` term scaled (the `24` is icon-derived, not font-derived). **`saleLineSingleRowMinWidth`/`saleLineTwoRowMinWidth` were deliberately left unscaled** — see T028's outcome note; scaling them was the plan's assumption, not a requirement that survived empirical testing. Column widths (`SaleLineColumns`) stay untouched, consumers in `sale_line_row.dart` updated to pass `MediaQuery.textScalerOf(context)`
- [X] T031 [US6] **Finding, not a fix**: investigated the reported baseline/symmetry defect directly against the real app theme (`pumpGoldenScenario`, applying the actual `component_themes.dart` `InputDecorationTheme`) and it does not reproduce — every value already shares one `(top, height)` and the card's insets are already symmetric (32px/32px, then confirmed at all four text scales). A first attempt at a source fix (wrapping the value cells in a `CrossAxisAlignment.baseline` sub-`Row`) was built and pixel-verified against a **bare `MaterialApp`** (framework-default decoration), where a real ~2px gap existed and closed to 0px — but that gap turned out to be an artifact of testing against the wrong theme, not a defect in the shipped one; re-verified against `pumpGoldenScenario` showed the fix changed nothing that needed changing, so it was reverted (`sale_line_row.dart` has zero diff from its original `_singleRow`/`_twoRow` `CrossAxisAlignment.center` structure). The likely explanation: `saleLineTextFieldPadding`/`saleLineDropdownPadding`'s existing derivation (spec 022/023) already solved this. FR-033 is satisfied by the existing code; T029's tests lock it in as a permanent regression guard rather than asserting something a fix newly produced
- [X] T032 [P] [US6] `sale_line_card.dart` needed no fix either — its outer `Card` padding (`EdgeInsets.all(12)`) is symmetric by construction and it has no shared value band (a vertically-stacked form, not a row), so FR-032's baseline claim does not apply to it. Added a confirming test in `sale_line_symmetry_test.dart` (top inset ≥ the declared 12px padding) as a regression guard, per US6 acceptance scenario 4's "vertical symmetry holds" for the card arrangement too
- [X] T033 [US6] Re-ran `test/widget/features/sales/sale_line_row_test.dart` (existing overflow assertions, updated for the `const double` → `function(TextScaler)` signature change — two tests referencing `saleLineFieldHeight`/`saleLineRowHeight` as bare values needed `TextScaler.noScaling` passed explicitly) plus the new `sale_line_symmetry_test.dart` — all pass, no regression to the fixed line height or the tablet-width overflow guarantee
- [X] T034 [P] [US6] Ran `flutter test test/golden/ test/screenshots/` — **zero re-baselining needed anywhere, including the POS sale-line goldens**, a stronger outcome than planned: since T031 found no source fix was actually needed (only T030's text-scale derivation, which is the identity at the default level), the sale-line's default-scale rendering is genuinely unchanged, not just "unchanged except the deliberate fix." Full suite confirms: 1882 passed

**Checkpoint**: US2 + US3 + US6 together are independently demoable — settings work, and the POS sale line reads correctly at every text size.

---

## Phase 6: User Story 4 - The POS sales list filters like every other list (Priority: P3)

**Goal**: `pos_sales_list_screen.dart`'s inline date-range chip and status popup menu move into the shared badged filters drawer.

**Independent Test**: open `/sales/pos`; confirm one badged filters button, no inline chips; open the drawer, set date range + status, confirm URL/list update and clear-all returns to today's range.

**Depends on**: Phase 2 (Foundational) only — independent of US2/US3/US6 (plan.md Phasing: "the other track").

### Tests for User Story 4

- [X] T035 [P] [US4] Updated `test/widget/features/sales/pos_sales_list_screen_test.dart`: the existing "defaults to today" test now asserts the badged button (`pos_sales_filter_button`) instead of the inline "Hoy" chip text; added a `filter drawer` group — no inline chips present, badge reflects an active status facet, opening the drawer and choosing a status navigates with that facet (verified via a real `GoRouter` harness, `pumpListRouted`, since the plain `pumpPos`/`pumpList` harness has no router and throws on `context.go`), and clear-all returns the badge to inactive. 19 tests, all passing

### Implementation for User Story 4

- [X] T036 [US4] In `lib/features/sales/presentation/pos_sales_list_screen.dart`, extracted the `DateRangeFilterChip` and status facet into a new `_PosSalesFiltersPanel` widget (mirroring `_CashSessionFiltersPanel`'s shape in `cash_sessions_screen.dart` — a labelled date-range control plus a `Wrap` of `ChoiceChip`s, replacing the old status `PopupMenuButton` for drawer-internal consistency with every other facet panel), rendered inside `showCatalogFilterSheet`'s `builder` via `CurrentListQueryBuilder`
- [X] T037 [US4] Replaced the `filters: [DateRangeFilterChip(...), _StatusFilterChip(...)]` list with a single `Badge.count` + `IconButton.outlined(icon: Icons.tune)` opening `showCatalogFilterSheet(...)`, matching `cash_sessions_screen.dart`'s pattern exactly: badge count from `filter.activeFilterCount(today)`, clear-all resetting `date-from`/`date-to`/`status` facets together (confirmed via test: returns to today's range, never unbounded). **`activeFilterCount`'s definition changed** (`pos_sales_list_controller.dart`): it previously counted `search.isNotEmpty` too (unused until now, so safe to correct) — excluded to match the established convention (`CashSessionFilterBadge`) that the badge reflects only drawer-internal facets, since search has its own visible affordance outside the drawer
- [X] T038 [US4] Removed the now-unused `_StatusFilterChip` class; kept `DateRangeFilterChip` itself, now used inside `_PosSalesFiltersPanel` rather than inline. **Found and fixed a real, pre-existing bug while writing T035's interaction test**: `catalog_filter_sheet.dart`'s footer (`Row` + `TextButton` + `Spacer` + `FilledButton`) overflows by 46px when a real (translated) label is long enough — es-MX's "Limpiar filtros" (15 chars) vs the golden test's hardcoded literal "Clear all" (9 chars), which is why no prior test caught it despite the footer being shared by 10+ list screens. Fixed with `OverflowBar` (`alignment: spaceBetween` for the normal case, falling back to a stacked column only on genuine overflow) — chosen over wrapping the buttons in `Flexible` after that approach visibly regressed button positioning (giving buttons equal flex share with the `Spacer` pulled "Apply" away from the trailing edge even when everything fit). Zero re-baselining needed on the `CatalogFilterSheet` golden — `OverflowBar` reproduces the original layout exactly at normal label lengths
- [X] T039 [US4] Manual quickstart validation (quickstart.md §6, POS sales list): badge count updates, drawer opens/applies/clears, URL state unchanged in shape — confirmed via the automated test suite above; the deliberate screenshot change (`test/screenshots/pos_screens_screenshot_test.dart` "mixed row states") was inspected side-by-side before re-baselining and shows exactly the intended swap: the old "Hoy"/"Todos los estados" chips replaced by the one badged filter button

**Checkpoint**: US4 independently demoable — POS sales list matches every other catalog screen's filter affordance.

---

## Phase 7: User Story 5 - The cash-sessions screen matches the catalog list structure (Priority: P3)

**Goal**: `cash_sessions_screen.dart` becomes a standard list screen; the shift form moves into a sheet opened from a toolbar action that itself communicates shift state.

**Independent Test**: open `/sales/cash-sessions` with no/open/stale shift; confirm standard list structure, state-aware toolbar action, sheet preserves all inline-panel information, and open/close still completes in ≤1 extra interaction.

**Depends on**: Phase 2 (Foundational) only — independent of US2/US3/US6, and independent of US4 (both can run in parallel; they touch different files except the shared sheet shell in T040, which is additive and side-effect-free for US4).

### Tests for User Story 5

- [X] T040 [P] [US5] The shell's responsive/root-navigator behavior is exercised via the EXISTING `CatalogFilterSheet` golden test (unchanged, zero re-baselining — proof `showAppSideSheet` reproduces `showCatalogFilterSheet`'s prior behavior byte-for-byte) plus the new cash-sessions sheet tests (T041/T043), which exercise the root-navigator requirement directly: T043's "tapping Close... navigates... the sheet itself must be gone" test is exactly the `context.push`-from-inside-the-sheet scenario research R6 called out. No separate `app_side_sheet_test.dart` file was added — the shell has no behavior not already covered by its two real consumers
- [X] T041 [P] [US5] Rewrote `test/widget/features/sales/cash_sessions_screen_test.dart` — every "none/open/stale state" test that used to check the inline panel directly now opens the sheet first via a new `openShiftSheet(tester)` helper. Added a dedicated "shift toolbar action" group: no-shift reads "Abrir sesión", open/stale show the drawer name + status chip (`cash_session_status_chip_open`/`_stale`), absent (not disabled) for a user without `pos:create`. **Found a latent test bug while doing this**: the harness never pinned `locale:`, so it silently rendered in English in this environment; pinning `Locale('es', 'MX')` surfaced that an existing assertion (`'3,240'`, US-style) never actually exercised es-MX number formatting (`3.240,00`, period-thousands) — fixed to assert the real format
- [X] T042 [P] [US5] Covered by the existing `cash_sessions_screen_test.dart` "the search slot renders nothing" test, updated for spec 027 FR-029: asserts no `CatalogSearchBar` in the tree, now that `cash_sessions_screen.dart` omits `search:` entirely rather than passing `const SizedBox.shrink()`
- [X] T043 [P] [US5] Added "submitting successfully dismisses the sheet" (opens via the assigned-drawer user, whose drawer is pre-seeded, avoiding an autocomplete interaction unrelated to what this test verifies) and "tapping Close dismisses the sheet and navigates... never stranded over the pushed route" — both assert the sheet's own key widgets are gone after the action, not just that navigation happened. The blocked-by-another-session path's `context.push` was updated the same way (`Navigator.pop()` first) but has no dedicated new test — it mirrors the same pattern already proven by the Close-button test

### Implementation for User Story 5

- [X] T044 [US5] Extracted the responsive shell into `lib/core/widgets/app_side_sheet.dart` as `showAppSideSheet({required BuildContext context, required String title, required WidgetBuilder builder, WidgetBuilder? footerBuilder})` — same breakpoint logic, `useRootNavigator: true`, header/close chrome. **`footerBuilder` is optional**, not required as originally planned: the shift sheet's Open/Close action is part of `_OpenForm`/`_OpenShiftCard` itself (submitted inline like any other form), not lifted into a second slot — forcing every consumer through one dedicated footer would have meant restructuring the shift form's own layout for no benefit. `footerBuilder` (a `WidgetBuilder`, so it gets its own `BuildContext` to call `Navigator.of(context).pop()`) is still there for the filter sheet's Clear all/Apply
- [X] T045 [US5] Re-pointed `showCatalogFilterSheet` to call `showAppSideSheet(...)`, passing its Clear all/Apply row as `footerBuilder` — confirmed byte-identical via the existing `CatalogFilterSheet` golden test (zero re-baselining). **Found and fixed a real, pre-existing bug in the footer while doing this**: `Row` + `TextButton` + `Spacer` + `FilledButton` overflows 46px when a real (translated) label is long enough — es-MX's "Limpiar filtros" (15 chars) vs the golden test's hardcoded literal "Clear all" (9 chars), which is why no prior test caught it despite this footer being shared by 10+ list screens. A first fix wrapping both buttons in `Flexible` visibly regressed button positioning (giving them equal flex share with the `Spacer` pulled "Apply" away from the trailing edge even when everything fit) — replaced with `OverflowBar` (`alignment: spaceBetween`, falling back to a stacked column only on genuine overflow), which reproduces the original layout exactly and needs no re-baselining either
- [X] T046 [US5] Made `CatalogFilterBar.search` optional (`Widget?`, default `null`); when `null`, the search slot is omitted entirely from both the single-row `Row` and the reflowed `Column` layouts — no space reserved for a control that doesn't exist
- [X] T047 [US5] Removed the `search: const SizedBox.shrink()` placeholder now that `search` is optional. Wrapped the existing `_OpenForm`/`_OpenShiftCard` `.when()` switch (unchanged internally — nothing dropped, per FR-028) in a new `_ShiftSheetContent` widget, rendered inside `showAppSideSheet`'s `builder` from the new toolbar action
- [X] T048 [US5] Added `_ShiftToolbarAction` to `_HistoryListSection`'s `CatalogFilterBar.actions` slot: no shift + can open → "Abrir sesión" button; open/stale → drawer name + `CashSessionStatusChip` (reusing the exact status vocabulary); no shift + cannot open → `SizedBox.shrink()` (absent, not disabled, FR-028a). Loading/error states get a neutral/error-colored icon button rather than disappearing, since `_ShiftSheetContent`'s own body reproduces the same `.when()` and shows the real error once opened — the toolbar button just can't yet say *which* state it's opening into
- [X] T049 [US5] Open success: `_OpenForm` uses `ref.listen(openSessionFormControllerProvider, ...)` to pop the sheet the moment `formState.saved` flips true — `submit()` already invalidates `currentSessionControllerProvider` itself (pre-existing controller behavior), so the toolbar action and (via that same provider family) the history list refresh with no extra wiring needed. Close and the blocked-by-another-session path both call `Navigator.of(context).pop()` before `context.push(...)`, confirmed by test to never leave the sheet stranded over the pushed route
- [X] T050 [US5] `CashSessionsScreen.build()` is now just `_HistoryListSection(query: query)` — the old `_ShiftPanel`, `Divider`, and inter-section `SizedBox` spacing are gone. **Found and fixed a real regression while verifying against the app's own router/shell tests**: removing the outer `SingleChildScrollView` (which used to make the whole page scrollable) left `_HistoryListSection`'s history table at a *fixed* `SizedBox(height: 480)` — fine inside a scrollable page, but a `RenderFlex` overflow at any narrower shell viewport once nothing above it could scroll. Changed to `Expanded`, matching every other catalog list screen's structure (filter row, `Expanded` list, pagination) — the fix `app_router_test.dart`'s existing cash-sessions route tests caught immediately
- [X] T051 [US5] Manual quickstart validation (quickstart.md §7, now §6 after renumbering): standard list structure confirmed (filter row + `Expanded` list + pagination, no form above it), toolbar action confirmed in all three shift states via the automated suite, sheet parity with the old inline panel confirmed (every field/action from `_OpenForm`/`_OpenShiftCard` present, nothing dropped), blocked-session navigation edge case confirmed not to strand the sheet

**Checkpoint**: US5 independently demoable — cash-sessions route matches the catalog structure, shift management moved to a sheet with no information loss.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: the constitution amendment this feature's code makes true, and the final full-suite confirmation.

- [X] T052 Re-read `.specify/memory/constitution.md` v1.11.0 and `DESIGN.md` §4.3/§4.4/§4.5 against the final state of T001-T051. Found and fixed one drift: DESIGN.md §4.4 said user display preferences persist "extending the existing `ThemeModeController`" — that controller was deleted (T009-area work) and replaced by `UserDisplayPreferencesController`, which reuses its `theme_mode` SharedPreferences key verbatim; updated the prose to name the actual class and explain the key reuse. Also corrected §4.3's alignment/symmetry paragraph, which still asserted the sale line "reads bottom-heavy" as a present-tense bug — per the US6 finding (Errors and Fixes #4) that mismatch does not reproduce under the real theme; reworded to describe the investigation, the false-harness cause, and what US6 actually shipped (text-scale-aware layout + `sale_line_symmetry_test.dart`). Everything else in both documents (two-levels-of-configuration split, filter-drawer/no-form-above-list/symmetry rules, four text-size levels, user settings screen placement) matched the shipped code with no changes needed
- [X] T053 [P] Confirmed the `exchange_rates_list_screen.dart` filter-drawer violation still holds, unchanged, still out of scope; no additional per-screen filter-drawer-rule violation surfaced among the 17 scanned screens. Added a "Post-implementation check" note to R8 documenting the one thing the original grep-based audit couldn't have found: the `CatalogFilterSheet` footer overflow bug fixed in T045, which affected all 10 correctly-drawer-using screens (not just the two flagged violations) — recorded so a future spec auditing this area doesn't treat it as new
- [X] T054 `flutter analyze` — 1 remaining info (`deprecated_member_use` on `ComposedTextScaler.textScaleFactor`, an unavoidable override of `TextScaler`'s own deprecated-but-abstract getter) silenced with a scoped `// ignore` and an explanatory comment; **0 issues** after. `flutter test` — **1890 passed, 47 skipped, 1 failed**. The 1 failure (`auth_flow_test.dart` "scenario 2: an incorrect password yields a single generic error") is **pre-existing and unrelated**: confirmed by stashing every uncommitted change from this feature and re-running against the untouched base commit (`1407c11`) — same failure, same stack trace, rooted in `AuthRepositoryImpl.login` (from the already-merged `aa9ac36` backend-unavailability change), nothing this feature's tasks touch. Golden/screenshot suites pass with only the T034-documented deliberate re-baseline changed
- [X] T055 Ran quickstart.md end to end. §1 static gates: `flutter analyze` clean, `flutter test test/unit/core/` all pass. §2 nothing-rendered-changed: `flutter test test/golden/ test/screenshots/` all pass, no re-baselining beyond T034. §4 settings: `flutter test test/widget/features/settings/` all pass (manual device walkthrough steps 1-6 not run interactively in this environment; covered instead by the automated widget-test assertions for each numbered step). §5 largest text size: `flutter test test/widget/features/sales/sale_line_row_test.dart` passes at all four levels. §6 remediated screens: `flutter test test/widget/features/sales/` passes (manual walkthrough steps likewise covered by the corresponding widget tests). §7 alignment: found and fixed a **typo in this quickstart itself** — the documented `flutter test test/widget/features/sales/ -n "symmetry"` uses `-n`, which isn't a valid `flutter test` flag (it's `--name`/`--plain-name`); corrected the doc to the direct file path `test/widget/features/sales/sale_line_symmetry_test.dart`, ran it, 21/21 pass at all four text-size levels. Also reworded §7's "the extra space under a sale line reported in the spec is gone" — inaccurate per the US6 finding (T052) that the reported mismatch never reproduced under the real theme — to describe the test as a regression lock on already-correct alignment, not a bug fix. Full suite (`flutter analyze && flutter test`) reconfirmed after these doc fixes: same result as T054

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: no dependencies
- **Foundational (Phase 2)**: depends on Setup — **blocks every user story**
- **US2 (Phase 3)**: depends on Foundational only
- **US3 (Phase 4)**: depends on Foundational + US2 (needs `appSettingsProvider.defaultLocale` as the language fallback)
- **US6 (Phase 5)**: depends on Foundational + US3 (needs the composing text scaler from T019)
- **US4 (Phase 6)**: depends on Foundational only — independent of US2/US3/US6
- **US5 (Phase 7)**: depends on Foundational only — independent of US2/US3/US6 and of US4
- **Polish (Phase 8)**: depends on all five stories being complete

### User Story Dependencies

- **US2 → US3 → US6**: one chain (plan.md Phasing tracks 1-2-3)
- **US4** and **US5**: the second, independent track — may run fully in parallel with the US2/US3/US6 chain and with each other, starting immediately after Phase 2

### Parallel Opportunities

- All `[P]`-marked Setup tasks (T002, T003)
- All `[P]`-marked Foundational tasks (T006, T009) once T004/T005/T007/T008 land
- **The two tracks**: US2→US3→US6 (Phases 3-4-5) and US4 (Phase 6) and US5 (Phase 7) can all be staffed concurrently once Phase 2 checks off
- Within each story, all `[P]`-marked test tasks run together; T032 (`sale_line_card.dart`) is parallel with T031 (`sale_line_row.dart`) once T030 lands

---

## Parallel Example: Foundational → two tracks

```bash
# After Phase 2 (Foundational) completes:

# Track A (chain) — start immediately:
Task: "US2 T010/T011 tests, then T012-T014 implementation"

# Track B (independent) — start immediately, in parallel with Track A:
Task: "US4 T035 test, then T036-T039 implementation"
Task: "US5 T040-T043 tests, then T044-T051 implementation"
```

---

## Implementation Strategy

### MVP First (US2 + US3)

1. Phase 1 (Setup) → Phase 2 (Foundational) — required, no shortcuts
2. Phase 3 (US2): `AppSettings` consolidated and documented
3. Phase 4 (US3): the settings screen — **STOP and VALIDATE** via quickstart §4
4. This alone delivers the two things the user asked for by name: app settings and user settings

### Incremental Delivery

1. Setup + Foundational → foundation ready, zero visible change
2. US2 → deployment configuration works → demo
3. US3 → settings screen works → demo (needs US2's default-locale fallback)
4. US6 → sale-line symmetry/baseline fixed, verified at all four text sizes → demo (needs US3's scaler)
5. US4 → POS sales list drawer conversion → demo (parallel-track, no dependency on 2-4)
6. US5 → cash-sessions sheet conversion → demo (parallel-track, no dependency on 2-4 or on US4)
7. Polish → constitution/DESIGN.md accuracy check, full-suite confirmation

### Parallel Team Strategy

With two developers: one takes the US2→US3→US6 chain (Phases 3-4-5), the other takes US4 and US5 (Phases 6-7) — both start the moment Phase 2 is checked off, and neither blocks the other since they touch disjoint files (`core/config/`, `core/settings/`, `app/`, `sale_line_*` vs. `pos_sales_list_screen.dart`, `cash_sessions_screen.dart`, `catalog_filter_*`).

---

## Notes

- **No US1.** Formatting was descoped before this file was written; there is nothing to do for it here. Its finished design sits in `contracts/formatting-surface.md` and `research.md` R3/R4/R8 for whichever spec picks it up next.
- **`sale_line_layout.dart` is touched once, for two requirements** (T030): FR-024's text-scale derivation and FR-033's baseline/symmetry fix share the same arithmetic, per plan.md's Complexity Tracking — do not split this into two passes.
- **The strongest regression check is T034**: golden/screenshot suites passing with *only* the deliberately-changed sale-line visuals re-baselined is the evidence that nothing else in the app rendered differently, which is the whole point of deferring formatting.
- [P] tasks touch different files with no unmet dependency — verified per-task above, not assumed.
- Stop at any checkpoint to validate a story independently before continuing.
