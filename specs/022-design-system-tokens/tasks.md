---
description: "Task list for feature implementation"
---

# Tasks: Design System Tokens & Component Theming

**Input**: Design documents from `/specs/022-design-system-tokens/`

**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md),
[data-model.md](./data-model.md), [contracts/design-tokens.md](./contracts/design-tokens.md),
[quickstart.md](./quickstart.md)

**Tests**: Included as first-class deliverables, not optional TDD scaffolding — the spec's
User Story 3 *is* the test safety net (`FR-020`/`021`/`023`), and `FR-027`'s deployment gate
and `SC-008`'s brand-independence proof are only real if something asserts them.

**Organization**: Tasks are grouped by user story, in the priority order from `spec.md`.
Two cross-story orderings are load-bearing, not stylistic — see Dependencies below.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependency on an incomplete task)
- **[Story]**: Maps to `spec.md`'s US1–US6. Setup and Polish carry no story label.
- Every task names an exact file path.

## Path Conventions

Single Flutter application, `lib/` and `test/` at repository root — no other project type
applies. New code lands in `lib/core/design/` (product tokens) and `test/golden/` +
`test/contract/` (new test categories); everything else is an edit to an existing file.

---

## Phase 1: Setup

**Purpose**: Scaffolding only — no token logic, no widget changes.

- [ ] T001 Create the `lib/core/design/` directory and stub `lib/core/design/design.dart`
  (empty barrel export for now); create `test/golden/`, `test/contract/`,
  `test/unit/core/design/`, `test/widget/core/design/`.
- [ ] T002 Create `test/unit/core/layering_test.dart`: assert, by scanning `lib/features/`
  and `lib/core/` source for `import 'package:mbe_ui/app/`, that nothing imports
  `lib/app/` (constitution §I; Verbatim Constraint in spec.md). Guards the invariant every
  later phase relies on.

**Checkpoint**: directories exist; the layering invariant is now regression-tested.

---

## Phase 2: User Story 1 - Text and surfaces show the brand's real colors (Priority: P1)

**Goal**: Text uses the brand's own ink; the light-mode raised surface resolves from an
approved value instead of falling back to a seed-derived one.

**Independent Test**: sample body text and card-background color in light and dark mode;
both match the approved brand values. No other phase needs to exist first.

- [ ] T003 [US1] In `lib/app/theme/app_theme.dart`'s `_buildTheme`, stop seeding
  `_brandTextTheme`'s base from a bare `ThemeData(brightness: brightness)` (which carries
  no `colorScheme` and so resolves Flutter's M3 baseline ink, `#1D1B20`/`#E6E0E9`). Seed it
  from a `ThemeData` built **with** `colorScheme`, so every text role's color traces to the
  pinned `onSurface` (`#1C1A16` light / `#EFE9DF` dark) instead (`FR-001`).
- [ ] T004 [US1] In `lib/core/branding/xbe_palette.dart`, add `lightSurfaceContainerLow`.
  Value: `#F9F6F1` — the midpoint between the existing `lightSurfaceContainerLowest`
  (`#FFFFFF`) and `lightSurfaceContainer` (`#F3EDE3`), since the brand guide's own §06
  "Modo claro" section never specified this role. **Flag this interpolated value for
  brand-owner confirmation** in the same way `FR-026` flags off-grid spacing — it is an
  engineering estimate standing in for a design decision, not an approved token.
- [ ] T005 [US1] In `lib/app/theme/app_theme.dart`'s `_lightScheme`, pin
  `surfaceContainerLow: XbePalette.lightSurfaceContainerLow`, mirroring the existing dark
  pin (`FR-002`).
- [ ] T006 [P] [US1] Extend `test/widget/app/app_theme_test.dart`: for both brightnesses,
  assert every `TextTheme` role's `.color` equals `colorScheme.onSurface` (not
  `#1D1B20`/`#E6E0E9`); assert `light.colorScheme.surfaceContainerLow` equals the new pinned
  constant, not a seed-derived value.
- [ ] T007 [US1] Run `quickstart.md` Scenario 1 (`flutter test test/widget/app/app_theme_test.dart`
  plus the WCAG contrast check already present in that file) and confirm `SC-003` (≥4.5:1
  every text role, both modes) still holds after T003–T005.

**Checkpoint**: US1 ships independently. Deployable on its own.

---

## Phase 3: User Story 2 - One vocabulary for spacing, shape, elevation and density (Priority: P1)

**Goal**: `Spacing`, `Shapes`, `Elevations`, `Density`, `TypeRoles` exist as `ThemeExtension`s
under `lib/core/design/`, tier-resolved via `MaterialApp.builder` (research R1). Zero
screens change yet.

**Independent Test**: request each token at all four tiers, both brightnesses; confirm
documented values (`data-model.md`) and identical results under two different brand configs.

**Depends on**: T005 (`Elevations.raised` maps to `surfaceContainerLow`, unusable in light
mode until it is pinned).

- [ ] T008 [P] [US2] Create `lib/core/design/spacing.dart`: `Spacing` `ThemeExtension` with
  the 8 fixed steps and 7 tier-dependent layout metrics from `data-model.md` §1, `const`
  constructors, no `BrandConfig` parameter (`FR-004`, `FR-010`).
- [ ] T009 [P] [US2] Create `lib/core/design/shapes.dart`: `Shapes` `ThemeExtension` with
  the 7 radii from `data-model.md` §2, including `lg = 16` (Verbatim Constraint) (`FR-005`).
- [ ] T010 [P] [US2] Create `lib/core/design/elevations.dart`: `Elevations` `ThemeExtension`
  with the 6 levels from `data-model.md` §3, each carrying a surface-role reference and a
  shadow dp (`0` for persistent surfaces) (`FR-006`).
- [ ] T011 [P] [US2] Create `lib/core/design/density.dart`: `Density` `ThemeExtension`
  resolved from `VisualDensity.adaptivePlatformDensity` (research R2 — **not**
  `MediaQuery.navigationModeOf`, which the spec's own Assumptions wrongly named), with the
  touch/pointer table from `data-model.md` §4 (`FR-007`).
- [ ] T012 [US2] Create `lib/core/design/type_roles.dart`: `TypeRoles` `ThemeExtension`
  with the 20 slots from `data-model.md` §5, each returning a ready `TextStyle` for the
  current tier. Bake per-slot weight emphasis into the role itself where the current
  hardcode adds one on top of the brand default (`metricValue`, `pageHeading` both need
  `w700`, one step above their base role's brand `w600`) — so a call site never needs its
  own `.copyWith` (`FR-008`).
- [ ] T013 [US2] Create `lib/core/design/design_theme.dart`: `DesignTheme.forTier(ThemeData
  base, LayoutTier tier)` assembling T008–T012 into a derived `ThemeData`, memoized per
  `(Brightness, LayoutTier)` (at most 8 live instances) so only a tier-boundary crossing
  triggers a rebuild (research R1).
- [ ] T014 [US2] In `lib/app/app.dart`, add a `MaterialApp.builder` that resolves
  `LayoutBreakpoints.tierOfContext(context)` and wraps `child` in
  `Theme(data: DesignTheme.forTier(Theme.of(context), tier), child: child!)`. Because
  `builder` wraps the `Navigator`, every route/dialog/sheet inherits the tier-resolved
  theme (research R1).
- [ ] T015 [P] [US2] Populate `lib/core/design/design.dart` (stubbed in T001) as the barrel
  export for T008–T013.
- [ ] T016 [P] [US2] Add `ThemeData` extension getters (`theme.spacing`, `.shapes`,
  `.elevations`, `.density`, `.typeRoles`) mirroring the shipped `BrandInkTheme` pattern —
  each falls back to its `const` default when the extension is absent, satisfying `FR-024`
  and `FR-009` together.
- [ ] T017 [P] [US2] Create `test/unit/core/design/spacing_test.dart`,
  `shapes_test.dart`, `elevations_test.dart`, `density_test.dart`: assert the grid/ordering
  invariants from `data-model.md`'s per-entity Validation notes, and that every
  tier-dependent field resolves for all four tiers with no gap (`SC-005`).
- [ ] T018 [US2] Create `test/unit/core/design/brand_independence_test.dart`: build
  `DesignTheme.forTier` under the default `BrandConfig` and under an overridden-seed one;
  assert every design-token value is identical between the two (`SC-008`) — the structural
  proof that `FR-010` holds, not just a documentation claim.
- [ ] T019 [US2] Create `test/widget/core/design/tier_resolution_test.dart`: pump the app at
  480 / 720 / 1024 / 1440 logical px and assert `MaterialApp.builder` resolves
  compact/medium/expanded/large respectively, with the tier-resolved theme visible above
  the `Navigator`.
- [ ] T020 [US2] Create `test/widget/core/design/fallback_test.dart`: pump a bare
  `ThemeData()` with no design extensions and confirm `theme.spacing` etc. return their
  `const` defaults rather than throwing (`FR-024`).

**Checkpoint**: the vocabulary exists, tier-resolved, brand-independent, and tested. No
screen has changed. US2 ships independently on top of US1.

---

## Phase 4: User Story 3 - A safety net before anything is restyled (Priority: P2)

**Goal**: golden images for every shared component, light/dark × narrow/wide, that fail
loudly on any visual change.

**Independent Test**: deliberately alter one component's appearance; the comparison fails
and names the component and combination.

- [ ] T021 [US3] Create `test/golden/golden_harness.dart`: a shared
  `pumpGoldenScenario(tester, widget, brightness, tier)` helper, plus a `setUpAll` that
  loads `assets/fonts/Archivo-Variable.ttf` and `assets/fonts/RobotoMono-Variable.ttf` via
  `FontLoader`. **Required, not optional** — without it, goldens render text as placeholder
  boxes and the suite verifies nothing (research R4).
- [ ] T022 [US3] Create `test/golden/README.md` recording the generating Flutter version
  (3.44.2) and the `--update-goldens` workflow, per research R4's host-dependence note.
- [ ] T023 [US3] Create `test/golden/core_widgets_golden_test.dart`: for each of the 20
  widgets in `lib/core/widgets/` (`app_navigation`, `app_shell`, `brand_logo`,
  `brand_nav_header`, `catalog_action_icons`, `catalog_entity_picker`, `catalog_filter_bar`,
  `catalog_filter_sheet`, `catalog_pagination`, `catalog_search_bar`, `data_table_view`,
  `entity_status_controls`, `error_banner`, `label_multi_picker`, `list_state_views`,
  `product_photo`, `record_form_actions`, `responsive_form_grid`, `user_menu_button`),
  capture 4 goldens (light/dark × 400dp/1024dp) via T021's harness. A widget with no
  golden must fail the run, not pass silently (`FR-023`).
- [ ] T024 [US3] Run `flutter test test/golden --update-goldens` to generate the baseline
  images; commit the resulting PNGs.
- [ ] T025 [US3] Verify the net catches change (`FR-021` proof, quickstart Scenario 3):
  temporarily change one widget's padding, run `flutter test test/golden`, confirm the
  failure names the widget and combination, then revert the change before continuing.

**Checkpoint**: `FR-020`/`021`/`023` and `SC-006` satisfied. **Phase 5 must not start until
this checkpoint is green** (plan.md's hard sequencing rule).

---

## Phase 5: User Story 4 - Components look the same everywhere without per-screen styling (Priority: P2)

**Goal**: 17 component sub-themes centralize appearance; the duplicated status chip becomes
one shared control.

**Independent Test**: the same control in three feature areas is pixel-identical; a change
to one sub-theme propagates to every screen with zero screen files edited.

**Depends on**: Phase 4 checkpoint (golden net green) and Phase 3 (tokens to consume).

- [ ] T026 [US4] Create `lib/core/widgets/status_chip.dart`: a generic `StatusChip<T>`
  reading its label/background/foreground from a caller-supplied mapping and from
  `ChipThemeData`, replacing the two near-duplicate chip implementations (`FR-018`).
- [ ] T027 [US4] Refactor `lib/core/widgets/entity_status_controls.dart` to delegate its
  chip rendering to `StatusChip`.
- [ ] T028 [US4] Refactor `lib/features/sales/presentation/widgets/cash_session_status_chip.dart`
  to delegate to `StatusChip`; remove its now-redundant `labelStyle`/`visualDensity`.
- [ ] T029 [US4] Add golden coverage for the new `StatusChip` to
  `test/golden/core_widgets_golden_test.dart` (extends T023 — the widget did not exist when
  the baseline was captured).
- [ ] T030 [US4] In `lib/app/theme/app_theme.dart`'s `_buildTheme`, add `AppBarTheme`,
  `CardThemeData` (`shapes.lg`, `surfaceContainerLow`, elevation 0, tier margin from
  `spacing`), `InputDecorationTheme` (filled, `shapes.xs`, tier `isDense` from `density`),
  and `ChipThemeData` (`typeRoles.chipLabel`, `shapes.sm`) (contracts table rows 1–4).
- [ ] T031 [US4] Add `DataTableThemeData` (`typeRoles.tableHeader`/`.tableCell`,
  `headingRowColor`), `DividerThemeData` (`outlineVariant`, thickness 1), and
  `DialogThemeData` (`shapes.xl`, `typeRoles.sectionHeading`) (contracts rows 5–7).
- [ ] T032 [US4] Add `NavigationRailThemeData` and `NavigationDrawerThemeData`
  (`indicatorShape: shapes.full`, `secondaryContainer`, `typeRoles.navLabel`); update
  `lib/core/widgets/app_navigation.dart` to remove its ad-hoc `Colors.transparent` fill and
  `BorderRadius.circular(28)`, and its raw `TextStyle` for the destination label, reading
  all three from the new sub-themes instead (contracts rows 8–9).
- [ ] T033 [US4] Add `FilledButtonTheme`/`OutlinedButtonTheme`/`TextButtonTheme`
  (`shapes.full`, tier padding, `typeRoles.buttonLabel`), `ListTileThemeData`, and
  `SegmentedButtonThemeData` (contracts rows 10–11).
- [ ] T034 [US4] Add `BottomSheetThemeData` (`shapes.xl`, top corners only),
  `SnackBarThemeData`, `TooltipThemeData`, `PopupMenuThemeData`, `SwitchThemeData`, and
  `ProgressIndicatorThemeData` (contracts rows 12–14).
- [ ] T035 [US4] In `lib/core/widgets/data_table_view.dart`, pass `dataRowHeight`,
  `headingRowHeight`, and `dividerThickness` explicitly from `theme.density`, since
  `data_table_2` reads those three from its own constructor parameters rather than
  `DataTableThemeData` (research R5) — this is the one place any screen touches table
  sizing; no other screen may pass these itself.
- [ ] T036 [P] [US4] Create `test/widget/core/widgets/status_chip_test.dart`: assert
  `EntityStatus` and `CashSessionStatus` both render through the single shared `StatusChip`
  (`SC-010`).
- [ ] T037 [US4] Re-run `flutter test test/golden`. Review every diff: `CardThemeData.shape`
  (12→16), the navigation indicator shape, and chip styling are **expected** — accept and
  regenerate those baselines with `--update-goldens`. Any other diff is a regression; fix
  before proceeding.
- [ ] T038 [US4] Manual verification, quickstart Scenario 4: compare the status indicator
  across Catalog → Products, Facilities → child rows, and Sales → Cash Sessions — confirm
  identical. Change `CardThemeData.shape` once more and confirm every card-bearing screen
  reflects it with zero screen files edited (`SC-009`).

**Checkpoint**: appearance is centralized; one status chip implementation remains.

---

## Phase 6: User Story 5 - Type is chosen by role, not typed in by hand (Priority: P3)

**Goal**: retire the 5 hardcoded typefaces and 3 hardcoded sizes; narrow the monospace
contract to match actual usage.

**Independent Test**: zero hardcoded typefaces/sizes remain outside the token definitions;
a product code in a table stays on the body role.

**Depends on**: Phase 3 (`TypeRoles` must exist).

- [ ] T039 [US5] In `lib/core/widgets/brand_nav_header.dart`, replace the hardcoded
  `TextStyle(fontFamily: 'Archivo', fontWeight: w600, fontSize: 14)` with
  `theme.typeRoles.navHeader`.
- [ ] T040 [US5] In `lib/features/auth/presentation/login/login_branding_pane.dart`, replace
  the two hardcoded `TextStyle`s (`fontSize: 32`/`15`, `fontFamily: 'Archivo'`) with
  `theme.typeRoles.heroHeading`/`.heroSubhead`, keeping each style's `.copyWith(color:
  XbePalette.darkOnSurface / .darkOnSurfaceVariant)` — this pane is deliberately always-dark
  regardless of the user's theme choice, which `FR-019`'s ban on hardcoded typefaces/sizes
  does not override.
- [ ] T041 [US5] In `lib/features/home/presentation/home_dashboard_tiles.dart` and
  `home_welcome.dart`, remove the `.copyWith(fontFamily: 'Archivo', fontWeight: w700)`
  overrides (now redundant — T012 already bakes the emphasis into the role) and use
  `theme.typeRoles.metricValue` / `.pageHeading` directly.
- [ ] T042 [US5] In `lib/features/home/presentation/home_activity_feed.dart`, replace the
  hardcoded `fontFamily: 'RobotoMono'` with `theme.typeRoles.timestamp`.
- [ ] T043 [US5] In `specs/019-xbe-default-branding/contracts/brand-tokens.md`'s Typography
  contract table, narrow "Codes / SKUs / monospaced data" to "Record identifiers /
  timestamps", per `FR-028` (clarified 2026-08-08) — a documentation correction to match
  behaviour that was never actually built.
- [ ] T044 [P] [US5] Extend `test/unit/core/design/type_roles_test.dart` (from T017):
  assert `theme.typeRoles.productCode` uses the standard body role (not RobotoMono), and
  `.recordId`/`.timestamp` do use RobotoMono (`FR-028`).
- [ ] T045 [US5] Run the `SC-001` check from `quickstart.md` Scenario 5
  (`grep -rn "fontFamily:\s*'" lib | grep -v generated | grep -v core/design`, and the
  equivalent for `fontSize:`) and confirm zero results.

**Checkpoint**: US5 ships. `SC-001` holds repo-wide.

---

## Phase 7: User Story 6 - Ready for tablets and phones without a token redesign (Priority: P3)

**Goal**: every width-dependent value has a decided value at all four tiers; tablet/desktop
controls visibly adapt at the tier boundary.

**Independent Test**: inspect every tier table for gaps; resize across 840px and observe
metric changes.

**Depends on**: Phase 3 (the tier tables to audit) and, for the visible-adaptation check,
Phase 5 (a themed control to observe).

- [ ] T046 [US6] Audit `lib/core/design/spacing.dart` and `density.dart` against
  `data-model.md` §1/§4: confirm every tier-dependent field has a defined value for
  compact, medium, expanded, **and** large — no accidental gap (`FR-012`, `SC-005`). Fix
  any gap found.
- [ ] T047 [US6] Extend `test/widget/core/design/tier_resolution_test.dart` (T019) with
  assertions that `screenMargin`, `cardPadding`, `sectionGap`, and `paneGutter` change
  value crossing the 840px expanded boundary (`FR-013`), and that compact-tier values
  resolve even though no compact-tier layout consumes them yet (`FR-014`).
- [ ] T048 [US6] Manual verification, quickstart Scenario 6: resize the desktop app window
  across 840px and confirm the Phase 5 shared widgets visibly step their spacing and
  density at the boundary.

**Checkpoint**: all six user stories are independently functional.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: the deployment-facing gate and closing verification, spanning every story.

- [ ] T049 [P] Run `flutter analyze lib test` and fix any lints introduced by this feature.
- [ ] T050 Create `test/contract/brand_contrast_test.dart`: build the real `AppTheme` from
  `BrandConfig.fromEnvironment()` (so it honors whatever `--dart-define` values the caller
  passed) and assert every foreground role clears 4.5:1 in both brightnesses (`FR-027`).
  Document, in the file's header comment, that a deployment pipeline MUST run this with the
  **same** `--dart-define` values as the following `flutter build`, and MUST treat a
  non-zero exit as a failed deployment (`SC-011`) — see quickstart.md Scenario 7 and
  research R6 for why this cannot be a build-time hook instead.
- [ ] T051 [P] Update `DESIGN-SYSTEM.md`, marking §3 (type roles), §4 (spacing), §5 (shape),
  §6 (elevation), §7 (density), and §8 (sub-themes) as shipped, linking to this spec.
- [ ] T052 Run every scenario in `quickstart.md` end-to-end and record the result of each
  against its listed success criteria.

**Checkpoint**: feature complete. All 28 functional requirements and 11 success criteria
verified.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: no dependencies.
- **US1 (Phase 2)**: depends on Setup. Independent of every other story — the smallest
  deployable slice.
- **US2 (Phase 3)**: depends on Setup and on **US1's T005** specifically (`Elevations.raised`
  needs the light `surfaceContainerLow` pin to be meaningful). Otherwise independent of US1.
- **US3 (Phase 4)**: depends on Setup only. Can run concurrently with US1/US2 — it captures
  the *current* appearance of shared widgets, which does not require the new tokens to exist.
- **US4 (Phase 5)**: depends on **US3's checkpoint being green** (hard gate — a sub-theme
  change is otherwise unverifiable) and on **US2** (sub-themes consume the tokens).
- **US5 (Phase 6)**: depends on **US2** (`TypeRoles` must exist). Independent of US3/US4.
- **US6 (Phase 7)**: depends on **US2** for its audit, and on **US4** for the
  visible-adaptation manual check (T048) only — its token-completeness tasks (T046–T047)
  need only US2.
- **Polish (Phase 8)**: depends on all stories being complete.

### Parallel Opportunities

- T003/T004 (US1) are sequential (T004 defines the constant T005 consumes); T006 can start
  once T003 lands.
- T008–T011 (US2's four independent token files) run in parallel; T012 (`TypeRoles`) and
  T013 (`DesignTheme`) are sequential after them.
- T017 (US2's four unit test files) run in parallel.
- **US3 (Phase 4) can run in parallel with US2 (Phase 3)** — it tests today's widgets, not
  the new tokens. Staffing both at once shortens the path to Phase 5's start.
- Within Phase 5, T030–T034 (sub-theme additions) are five edits to the same
  `_buildTheme` method and are **not** parallelizable; T036 (a new test file) can run
  alongside them.
- T049/T051 (Phase 8) are independent of each other and of T050/T052.

---

## Parallel Example: User Story 2

```bash
# Four independent token files, no shared state:
Task: "Create Spacing ThemeExtension in lib/core/design/spacing.dart"
Task: "Create Shapes ThemeExtension in lib/core/design/shapes.dart"
Task: "Create Elevations ThemeExtension in lib/core/design/elevations.dart"
Task: "Create Density ThemeExtension in lib/core/design/density.dart"

# Their four unit-test files, equally independent:
Task: "Spacing invariants in test/unit/core/design/spacing_test.dart"
Task: "Shapes invariants in test/unit/core/design/shapes_test.dart"
Task: "Elevations invariants in test/unit/core/design/elevations_test.dart"
Task: "Density invariants in test/unit/core/design/density_test.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup.
2. Complete Phase 2: User Story 1 — the text-ink and light-surface fix.
3. **STOP and VALIDATE**: run `quickstart.md` Scenario 1 independently.
4. This alone is deployable: a real defect fix, zero new abstractions, zero visual risk
   beyond the correction itself.

### Incremental Delivery

1. Setup → US1 (deploy the fix) → US2 (vocabulary exists, nothing visible changes) → US3
   (safety net proven) → US4 (the visible product-wide restyle, gated on US3) → US5 (type
   hardcodes retired) → US6 (tablet/phone readiness confirmed) → Polish (deployment gate).
2. US3 can be staffed in parallel with US2 rather than strictly after it — the golden net
   tests today's widgets, not the new tokens.
3. Each checkpoint is a valid place to pause, demo, or ship.

### Parallel Team Strategy

With multiple developers: one takes US1 (small, self-contained) while a second starts US2's
four independent token files (T008–T011) and a third starts US3's harness (T021–T023) —
none of the three blocks the others. US4 is the one phase that genuinely needs US2 and US3
both finished, and its own sub-theme edits (T030–T034) land in one file sequentially even
with a large team.

---

## Notes

- `[P]` tasks touch different files with no dependency on an incomplete task in this list.
- Every task traces to a functional requirement or success criterion named inline —
  cross-check against [spec.md](./spec.md) if a task's purpose is unclear.
- The pre-existing test-suite compile failure (stale `built_value` output in
  `lib/generated/openapi/`, unrelated to this feature — see `quickstart.md`) means a raw
  "N tests passed" count is not a valid regression signal until that package is
  regenerated. Scope test runs to the directories this feature touches.
- Two brand-content decisions are flagged rather than silently resolved: the interpolated
  `lightSurfaceContainerLow` value (T004) and the off-grid 14px brand-guide gap (`FR-026`,
  already in spec.md). Both need the brand owner's sign-off before they are treated as
  final, not just correct-by-construction.
