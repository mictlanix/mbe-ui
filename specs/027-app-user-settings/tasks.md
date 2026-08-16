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

- [ ] T001 Create empty directories `lib/core/config/`, `lib/core/settings/`, `lib/features/settings/presentation/`
- [ ] T002 [P] Add an "App settings" section to `.env.template`, documenting `DEFAULT_LOCALE=es_MX` alongside the existing test-credential section (research R11) — do not touch the existing sections
- [ ] T003 [P] Add a `deploy/` directory with a `README.md` one-liner pointing at `.env.template` for per-customer deployment files (research R11; contracts/app-and-user-settings.md §"How they are supplied")

**Checkpoint**: directories exist; no code yet.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: `AppSettings` + its provider, and the `SharedPreferences` seam —
every user story below reads at least one of these.

**⚠️ CRITICAL**: no user story may start until this phase is checked off.

- [ ] T004 Create `AppSettings` in `lib/core/config/app_settings.dart`: a `@immutable` class with `AppSettings.fromEnvironment()` following `BrandConfig.fromEnvironment()`'s pattern (data-model.md §1) — fields `apiBaseUrl` (`API_BASE_URL`, default `http://127.0.0.1:8000`), `photosBaseUrl` (`PHOTOS_BASE_URL`, default `= apiBaseUrl` — **must stay a compile-time const cross-reference**, research R7), `posDefaultCustomerId` (`POS_DEFAULT_CUSTOMER_ID`, default `1`), `brand` (a `BrandConfig`, composed via `BrandConfig.fromEnvironment()` unchanged), `defaultLocale` (`DEFAULT_LOCALE`, default `es_MX`, parsed to a `Locale` with fallback to `es_MX` on a malformed value — mirror `BrandConfig._parseSeedColor`'s fallback-on-malformed pattern, FR-005)
- [ ] T005 Add `appSettingsProvider` in `lib/core/config/app_settings_provider.dart` (`Provider<AppSettings>`, `(ref) => AppSettings.fromEnvironment()`), and re-point `brandConfigProvider` (`lib/core/branding/brand_config_provider.dart`) at `ref.watch(appSettingsProvider).brand` so there is exactly one `BrandConfig` instance, not two (data-model.md §1.1)
- [ ] T006 [P] Unit tests in `test/unit/core/config/app_settings_test.dart`: every default reproduces today's exact values (`apiBaseUrl` == `http://127.0.0.1:8000`, `photosBaseUrl` == `apiBaseUrl`, `posDefaultCustomerId` == `1`, `defaultLocale` == `es_MX`); a malformed `DEFAULT_LOCALE` falls back to `es_MX` without throwing (FR-005); `appSettingsProvider` is overridable via `ProviderContainer(overrides: [...])` (constitution §II)
- [ ] T007 Re-point the four existing call sites at `AppSettings` instead of their own `String.fromEnvironment`/`int.fromEnvironment`: `lib/core/network/dio_client.dart` (`apiBaseUrl`), `lib/core/network/photo_url.dart` (`photosBaseUrl`), `lib/features/sales/pos_defaults.dart` (`posDefaultCustomerId`) — each becomes `ref.watch(appSettingsProvider).<field>` at its provider definition, with the top-level `const` removed since the value now comes from a provider. Verify via `grep -rn "String.fromEnvironment\|int.fromEnvironment" lib/core/network lib/features/sales/pos_defaults.dart` that only `brand_config.dart` (composed into T004, unchanged) still calls `fromEnvironment` directly
- [ ] T008 Add `sharedPreferencesProvider` in `lib/core/storage/shared_preferences_provider.dart` as an unimplemented `Provider<SharedPreferences>` (throws if not overridden — the standard Riverpod "must be overridden" pattern), and seed it in `lib/main.dart`: call `await SharedPreferences.getInstance()` **before** `runApp`, pass it via `ProviderScope(overrides: [sharedPreferencesProvider.overrideWithValue(prefs)], child: const App())` (research R5) — this must land before `runApp` regardless of the `kDebugMode`/driver-extension branch already in `main.dart`
- [ ] T009 [P] Verify `flutter analyze` and the existing full suite (`flutter test`) both pass after T004–T008 — this phase must be behavior-preserving; no screen renders differently yet

**Checkpoint**: `AppSettings` and the preferences seam exist and are wired; zero visible change. User stories can now proceed — US2/US3/US6 as one chain, US4/US5 in parallel.

---

## Phase 3: User Story 2 - A deployment is configured without touching source (Priority: P2)

**Goal**: one `.env` file controls the deployment's default locale, API/photos endpoints, brand tokens and POS defaults — with every option defaulted and documented.

**Independent Test**: build with a `.env` setting `DEFAULT_LOCALE` and `API_BASE_URL`; confirm the app targets that host and reads deployment strings for that language. Build with no `.env`; confirm today's defaults.

### Tests for User Story 2

- [ ] T010 [P] [US2] Widget/integration-style test (or extend T006) asserting that with no `.env` at all, `AppSettings.fromEnvironment()` still produces a fully usable `AppSettings` (FR-004) — add to `test/unit/core/config/app_settings_test.dart`
- [ ] T011 [P] [US2] Test in `test/unit/core/config/app_settings_test.dart` that a `.env`-style override (via `--dart-define` in the test's own compilation, or by asserting the parsing function directly) for `API_BASE_URL` changes `dioProvider`'s base URL (FR-003) without touching any other setting

### Implementation for User Story 2

- [ ] T012 [US2] Confirm (via T007) that `API_BASE_URL`, `PHOTOS_BASE_URL`, `POS_DEFAULT_CUSTOMER_ID`, and the five `BRAND_*` keys are all reachable through `appSettingsProvider` alone — no feature file still reads `String.fromEnvironment`/`int.fromEnvironment` directly except `brand_config.dart` itself (composed, not duplicated)
- [ ] T013 [US2] Finalize the `.env.template` app-settings section from T002: document `DEFAULT_LOCALE` plus the eight existing keys (`API_BASE_URL`, `PHOTOS_BASE_URL`, `POS_DEFAULT_CUSTOMER_ID`, `BRAND_DISPLAY_NAME`, `BRAND_SEED_COLOR`, `BRAND_WELCOME_ASSET`, `BRAND_LOCKUP_ASSET`, `BRAND_MARK_ASSET`) with default and one-line description each (FR-006), matching contracts/app-and-user-settings.md's key table exactly — do not add the formatting keys from that same contract file, they are explicitly out of scope (FR-002 note)
- [ ] T014 [US2] Manual quickstart validation: run quickstart.md §3 (deployment configuration) — a custom `.env` changes host/locale/brand with no source edit; no `.env` and a malformed `DEFAULT_LOCALE` both start cleanly

**Checkpoint**: US2 is independently complete — `AppSettings` is the one place every deployment option lives, documented, defaulted, fallback-safe.

---

## Phase 4: User Story 3 - A user adjusts theme, text size and language (Priority: P2)

**Goal**: a settings screen where appearance, text size (4 levels) and language are chosen, apply immediately, and persist per device.

**Independent Test**: open the settings screen, change each control, observe immediate effect, restart, confirm persistence.

**Depends on**: Phase 3 (US2) for `appSettingsProvider.defaultLocale`, the fallback a user with no override gets.

### Tests for User Story 3

- [ ] T015 [P] [US3] Unit tests for the composing text scaler in `test/unit/core/design/text_scale_test.dart`: at `TextSizeLevel.normal` (factor 1.0), `effectiveScaler.scale(x) == platformScaler.scale(x)` for several platform scalers including non-`TextScaler.noScaling` ones (research R1's "identity at default, composes at non-default" invariant); at other levels, `effectiveScaler.scale(x) == platformScaler.scale(x * level.factor)`
- [ ] T016 [P] [US3] Unit tests for `UserDisplayPreferencesController` in `test/unit/core/settings/user_display_preferences_controller_test.dart`: default state is `ThemeMode.system` / `TextSizeLevel.normal` / `localeOverride: null`; each setter persists to `SharedPreferences` under its key and updates state synchronously (no async gap — FR-020); reading a corrupt/unparseable stored `text_size_level` value falls back to `normal` without throwing (FR-022); reading the pre-existing `theme_mode` key with a value from before this feature still restores correctly (FR-017)
- [ ] T017 [P] [US3] Widget test in `test/widget/features/settings/user_settings_screen_test.dart`: renders the three controls; tapping each Light/Dark/System, each text-size level, and each language option calls the corresponding controller method; `AppBar.actions` is empty (constitution §VI); no RBAC check gates rendering (FR-016, Assumptions)
- [ ] T018 [P] [US3] `test/unit/core/l10n_parity_test.dart` must still pass once new settings-screen strings are added to both ARBs (run, don't write — this is the existing guard, FR-023 well-formedness check)

### Implementation for User Story 3

- [ ] T019 [P] [US3] Create `TextSizeLevel` enum (`small`/`normal`/`large`/`extraLarge`, factors `0.9`/`1.0`/`1.15`/`1.3`, `normal` default — data-model.md §3.1) and the composing `TextScaler` in `lib/core/design/text_scale.dart` per research R1's sketch: `effective.scale(size) == platform.scale(size * level.factor)`, never replacing the platform scaler
- [ ] T020 [US3] Create `UserDisplayPreferences` (immutable value: `themeMode`, `textSizeLevel`, `localeOverride`) in `lib/core/settings/user_display_preferences.dart`, and `UserDisplayPreferencesController` (a `Notifier`, constitution §II) in `lib/core/settings/user_display_preferences_controller.dart` reading/writing `SharedPreferences` synchronously via `sharedPreferencesProvider` (already seeded before `runApp` — no restore flash, research R5): keys `theme_mode` (existing — reuse verbatim, FR-017), `text_size_level` (new), `locale_override` (new, nullable). Fold `ThemeModeController` (`lib/app/theme/app_theme.dart`) into this controller, removing the old async `_restore()` — `setThemeMode` becomes a thin call into the new controller so nothing else in the app needs to change its `ref.watch(themeModeControllerProvider)` call sites beyond re-pointing them at the new provider
- [ ] T021 [US3] Add a resolved-locale provider in `lib/core/settings/user_display_preferences.dart` (or a sibling file): `localeOverride ?? appSettings.defaultLocale`, validated against `AppLocalizations.supportedLocales` and falling back to the deployment default then to `supportedLocales.first` (data-model.md §4, research R9)
- [ ] T022 [US3] Wire `lib/app/app.dart`: replace the hard-coded `locale: const Locale('es', 'MX')` with the resolved-locale provider from T021; wrap the existing `builder` callback's returned subtree in a `MediaQuery` applying the composing text scaler from T019 (`MediaQuery.textScalerOf(context)` composed with the current `UserDisplayPreferences.textSizeLevel`), positioned **above** the existing `DesignTheme.forTier(...)` call so every route/dialog/sheet inherits both
- [ ] T023 [US3] Create `UserSettingsScreen` in `lib/features/settings/presentation/user_settings_screen.dart`: three controls (appearance radio/segmented group, text-size selector with 4 options, language selector with Español/English/follow-system) using the shared `ResponsiveFormGrid` (constitution §VI), empty `AppBar.actions`, each control calling its `UserDisplayPreferencesController` setter directly (no separate Save step — FR-020)
- [ ] T024 [US3] Add the route `GoRoute(path: '/auth/account/settings', builder: (context, state) => const UserSettingsScreen())` in `lib/app/router/app_router.dart`, beside the existing `/auth/account/password` route (Assumptions: "a route beside the existing account/password route")
- [ ] T025 [US3] Add a "Settings" `MenuItemButton` to `lib/core/widgets/user_menu_button.dart`, beside `user_menu_change_password`, `onPressed: () => context.push('/auth/account/settings')` (FR-016)
- [ ] T026 [P] [US3] Add the new strings (settings screen title, appearance/text-size/language labels and options, user-menu entry) to both `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb` with matching keys (constitution's `l10n_parity_test.dart` requirement)
- [ ] T027 [US3] Manual quickstart validation: run quickstart.md §4 (user settings) end to end, including the "no flash of default theme on launch" check (research R5) and the unsaved-input-survives-a-language-change edge case (spec.md Edge Cases)

**Checkpoint**: US2 + US3 together are independently demoable — a full settings experience, deployment-configured and user-adjustable.

---

## Phase 5: User Story 6 - Rows and cards are vertically symmetric and baseline-aligned (Priority: P3)

**Goal**: the POS sale line's vertical insets are symmetric and its control band shares the line-total's baseline, in all three layouts, at all four text-size levels.

**Independent Test**: render a POS sale line at the single-row width; assert measured top/bottom insets are equal and the control band's baseline coincides with the line total's.

**Depends on**: Phase 4 (US3) for the composing text scaler `sale_line_layout.dart`'s constants must derive from.

### Tests for User Story 6

- [ ] T028 [P] [US6] Extend `test/widget/features/sales/sale_line_row_test.dart`: parameterize the existing tablet-width overflow test across all four `TextSizeLevel`s (FR-024) — at `extraLarge` on a 1024 px surface, assert the layout **falls back to two-row** (not overflow) per `saleLineLayoutFor`'s existing threshold logic, now scaled
- [ ] T029 [P] [US6] Add a measuring test to `test/widget/features/sales/sale_line_row_test.dart` (or a new `sale_line_symmetry_test.dart`) that pumps `SaleLineRow` in the single-row layout and asserts, via `tester.getRect`/`RenderBox.getDistanceToBaseline` on the rendered elements: (a) the vertical gap between the Card's top edge and the content top equals the gap between content bottom and the Card's bottom edge (FR-031, FR-035); (b) the text baseline of a control-band field (e.g. the quantity `TextField`) coincides with the text baseline of `_totalCell` (FR-032, FR-035). Repeat for the two-row layout (US6 acceptance scenario 4) and for a two-line-wrapped product name (acceptance scenario 3)

### Implementation for User Story 6

- [ ] T030 [US6] In `lib/features/sales/presentation/capture/sale_line_layout.dart`, change `saleLineFieldHeight`, `_saleLineTextContentHeight`, `_saleLineDropdownContentHeight`, `saleLineTextFieldPadding`, `saleLineDropdownPadding`, `saleLineRowHeight` from `const double` to functions of the effective `TextScaler` (research R2) — keep the file's existing derivation (`_saleLineTextContentHeight` = one body-role line at the scaled font size × its line height; padding = half the remaining height) so text fields and dropdowns still land on the same height *and* baseline at every scale. Change `saleLineSingleRowMinWidth` similarly, scaled by the same factor, so `saleLineLayoutFor` engages the existing two-row/card fallback at large text sizes instead of overflowing (data-model.md §5). Column widths (`SaleLineColumns`) stay untouched
- [ ] T031 [US6] In `lib/features/sales/presentation/capture/sale_line_row.dart`, fix the baseline/symmetry defect itself: wrap `_totalCell`'s `Text` so it aligns to the same baseline the control band's fields land on (e.g. via a `Baseline` widget or by giving the total cell the same `_band()`-style height + vertical centering the fields use), and adjust the outer `Card`'s `Padding` (currently `EdgeInsets.all(8)` at `sale_line_row.dart:81`) and the row/band heights so the resulting top and bottom insets are equal — use T029's measuring test to converge, not visual inspection (FR-033, FR-034: every value from `theme.spacing.*`, never a new literal)
- [ ] T032 [P] [US6] Apply the equivalent fix to `lib/features/sales/presentation/capture/sale_line_card.dart` (the compact-tier layout) so US6 acceptance scenario 4's "vertical symmetry holds" also covers the card arrangement, not just the row
- [ ] T033 [US6] Re-run `test/widget/features/sales/sale_line_row_test.dart` (existing overflow assertions) plus T028/T029 to confirm no regression to the fixed line height or the tablet-width overflow guarantee already pinned there
- [ ] T034 [P] [US6] Run `flutter test test/golden/ test/screenshots/` — confirm no re-baselining is needed anywhere **except** the POS sale-line goldens/screenshots specifically covering this row, which are expected to change (research R1: default level is the identity, so only the deliberately-fixed visuals move)

**Checkpoint**: US2 + US3 + US6 together are independently demoable — settings work, and the POS sale line reads correctly at every text size.

---

## Phase 6: User Story 4 - The POS sales list filters like every other list (Priority: P3)

**Goal**: `pos_sales_list_screen.dart`'s inline date-range chip and status popup menu move into the shared badged filters drawer.

**Independent Test**: open `/sales/pos`; confirm one badged filters button, no inline chips; open the drawer, set date range + status, confirm URL/list update and clear-all returns to today's range.

**Depends on**: Phase 2 (Foundational) only — independent of US2/US3/US6 (plan.md Phasing: "the other track").

### Tests for User Story 4

- [ ] T035 [P] [US4] Update `test/widget/features/sales/pos_sales_list_screen_test.dart` (or create it if absent): assert the filter row shows the search box and **one** `Badge.count` + `IconButton.outlined(Icons.tune)` — no `DateRangeFilterChip`/`PopupMenuButton` rendered inline (FR-025, FR-026); tapping the button opens `showCatalogFilterSheet`; setting a date range and a status inside the sheet updates `ListQuery`/URL exactly as the current inline chips do; "clear all" returns `filter.isToday(today) == true` and `filter.status == null` (spec.md US4 acceptance scenario 3)

### Implementation for User Story 4

- [ ] T036 [US4] In `lib/features/sales/presentation/pos_sales_list_screen.dart`, extract the current `DateRangeFilterChip` and `_StatusFilterChip` (lines ~123–148, 275–306) into a new `_PosSalesFiltersPanel` widget (mirroring `_CashSessionFiltersPanel`'s shape in `cash_sessions_screen.dart`) rendered inside `showCatalogFilterSheet`'s `builder`
- [ ] T037 [US4] Replace the `filters: [DateRangeFilterChip(...), _StatusFilterChip(...)]` list in `CatalogFilterBar` (currently at `pos_sales_list_screen.dart:122-148`) with a single `Badge.count` + `IconButton.outlined(icon: Icons.tune)` opening `showCatalogFilterSheet(context, title: ..., builder: (_) => _PosSalesFiltersPanel(...), onClearAll: () => goTo(...))`, following the exact pattern already in `cash_sessions_screen.dart`'s `_HistoryListSection` (lines 291-318): badge count from `filter.activeFilterCount`, clear-all reset to `query.copyWith(pageIndex: 0)` with both `date-from`/`date-to`/`status` facets cleared — verify this reproduces "today's range" as the post-clear state (FR-026), not an unbounded range
- [ ] T038 [US4] Remove the now-unused `_StatusFilterChip` class (`pos_sales_list_screen.dart:275-306`) once its `PopupMenuButton` content has moved into `_PosSalesFiltersPanel`; keep `DateRangeFilterChip` itself (`core/widgets/date_range_filter_chip.dart`) since the panel still uses its underlying control, only its placement changes
- [ ] T039 [US4] Manual quickstart validation: run quickstart.md §6 (POS sales list) — badge count updates, drawer opens/applies/clears, URL state unchanged in shape from before this feature

**Checkpoint**: US4 independently demoable — POS sales list matches every other catalog screen's filter affordance.

---

## Phase 7: User Story 5 - The cash-sessions screen matches the catalog list structure (Priority: P3)

**Goal**: `cash_sessions_screen.dart` becomes a standard list screen; the shift form moves into a sheet opened from a toolbar action that itself communicates shift state.

**Independent Test**: open `/sales/cash-sessions` with no/open/stale shift; confirm standard list structure, state-aware toolbar action, sheet preserves all inline-panel information, and open/close still completes in ≤1 extra interaction.

**Depends on**: Phase 2 (Foundational) only — independent of US2/US3/US6, and independent of US4 (both can run in parallel; they touch different files except the shared sheet shell in T040, which is additive and side-effect-free for US4).

### Tests for User Story 5

- [ ] T040 [P] [US5] Widget test `test/widget/core/app_side_sheet_test.dart` for the extracted shell (T041): asserts modal-bottom-sheet below `LayoutBreakpoints.expanded` and right-anchored 360 px side sheet above it, `useRootNavigator: true` is honored (a `context.push` from inside the sheet body does not tear the sheet down — research R6), and `showCatalogFilterSheet` still renders identically through the new shell (regression: existing filter-sheet tests must still pass unchanged)
- [ ] T041 [P] [US5] Widget test `test/widget/features/sales/cash_sessions_screen_test.dart` (extend or create): with no open shift, the toolbar action reads/looks like "open a shift" (FR-027, FR-028a) and is visible without scrolling; with an open shift, activating it shows drawer name, start time, opening amount, payments-by-method, and the close action (FR-028); with a stale shift, the stale warning and other-open-sessions note additionally appear, and the toolbar action itself signals staleness (not just the sheet contents); for a user without the open-shift privilege, the toolbar action is **absent** (not disabled) — mirroring today's `!canOpen` branch in `_OpenForm`
- [ ] T042 [P] [US5] Widget test asserting the empty `search:` placeholder is gone: `CatalogFilterBar` renders with no search control when `search` is omitted (FR-029), not a `SizedBox.shrink()` passed explicitly — verify against `catalog_filter_bar.dart`'s updated signature
- [ ] T043 [P] [US5] Widget test for the success path: completing an open or close from the sheet dismisses it, invalidates `cashSessionsListControllerProvider`/`currentSessionControllerProvider` so the history list and toolbar action both reflect the new state without a manual reload (FR-028b), and — for the blocked-by-another-session error's `context.push` to that session's detail screen — the sheet is no longer present after that navigation (spec.md Edge Cases: "Navigating out of the shift sheet")

### Implementation for User Story 5

- [ ] T044 [US5] Extract the responsive shell from `lib/core/widgets/catalog_filter_sheet.dart` into `lib/core/widgets/app_side_sheet.dart` as `showAppSideSheet({required BuildContext context, required String title, required WidgetBuilder builder, required Widget footer})` — same bottom-sheet/side-sheet breakpoint logic, same `useRootNavigator: true`, same header/close-button chrome, but the footer becomes a caller-supplied `Widget` instead of the hard-coded Clear all/Apply row (research R6, contracts/screen-structure.md §3)
- [ ] T045 [US5] Re-point `showCatalogFilterSheet` in `catalog_filter_sheet.dart` to call `showAppSideSheet(...)`, passing its existing Clear all/Apply row as the `footer` — confirm byte-identical behavior via T040 and the existing filter-sheet tests
- [ ] T046 [US5] Make `CatalogFilterBar.search` optional (`Widget?` instead of `Widget`, default `null`) in `lib/core/widgets/catalog_filter_bar.dart`; when `null`, omit the search slot entirely from both the single-row `Row` and the reflowed `Column` layouts rather than reserving its space (FR-029)
- [ ] T047 [US5] In `lib/features/sales/presentation/cash_sessions_screen.dart`, remove `search: const SizedBox.shrink()` (line ~295) now that `search` is optional; extract `_OpenForm`, `_OpenShiftCard` and the "no privilege" text (lines 84-209, 211-274) out of `CashSessionsScreen.build`'s direct `Column` into a new `_ShiftSheetContent` widget rendered inside `showAppSideSheet`'s `builder`
- [ ] T048 [US5] Add a toolbar action to `_HistoryListSection`'s `CatalogFilterBar` (via the `actions:` slot, following `_NewSaleAction`'s pattern in `pos_sales_list_screen.dart`): a state-aware button/chip reading "no shift" / "shift open" / "shift stale" (reusing `CashSessionStatusChip`'s status vocabulary — `cash_session_status_chip.dart`) that calls `showAppSideSheet(context, title: ..., builder: (_) => const _ShiftSheetContent(), footer: ...)`; absent entirely when `!access.can(SystemObject.pos, AccessRight.create)` **and** the user has no way to open one (mirror the current `_OpenForm`'s `!canOpen` early return, FR-028a)
- [ ] T049 [US5] Wire the sheet's success paths (open/close submit handlers) to dismiss via `Navigator.of(context).pop()` and `ref.invalidate` both `cashSessionsListControllerProvider(filter)` and `currentSessionControllerProvider`, so the toolbar action and history list both refresh without a manual reload (FR-028b); confirm the blocked-by-another-session `context.push` (currently `cash_sessions_screen.dart:180-184`) still pops the sheet first so it doesn't strand over the pushed route (Edge Cases)
- [ ] T050 [US5] Delete `CashSessionsScreen`'s now-unused top-level `_ShiftPanel` composition from `build()` (lines 48-63) — the screen's `build()` becomes just `_HistoryListSection` plus its new toolbar action; remove the `const Divider()`/`SizedBox` spacing that separated the old inline panel from the list
- [ ] T051 [US5] Manual quickstart validation: run quickstart.md §7 (cash sessions) — standard list structure, state-aware toolbar action in all three shift states, sheet parity with the old inline panel, and the blocked-session navigation edge case

**Checkpoint**: US5 independently demoable — cash-sessions route matches the catalog structure, shift management moved to a sheet with no information loss.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: the constitution amendment this feature's code makes true, and the final full-suite confirmation.

- [ ] T052 Confirm `.specify/memory/constitution.md` v1.11.0 and `DESIGN.md` §4.3/§4.4/§4.5 (already amended ahead of this implementation, per Governance) accurately describe the code as built — re-read both against the final state of T001–T051 and correct any drift between what was planned and what was actually shipped (FR-036)
- [ ] T053 [P] Update research.md R8's compliance inventory if implementation revealed anything beyond the two already-known violations — it currently lists `exchange_rates_list_screen.dart` as a third, out-of-scope violation; confirm that finding still holds and no new one surfaced
- [ ] T054 Run the full suite: `flutter analyze && flutter test` — every existing suite plus everything added in T006/T010/T011/T015-T018/T028-T029/T035/T040-T043 must pass; golden/screenshot suites pass with **only** the deliberate POS sale-line changes re-baselined (T034), nothing else
- [ ] T055 Run quickstart.md end to end (all sections) as the final acceptance pass before marking the feature complete

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
