---

description: "Task list for 018-nested-facility-management"
---

# Tasks: Nested Facility Management

**Input**: Design documents from `/specs/018-nested-facility-management/`

**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/](./contracts/)

**Tests**: Included. Constitution "Development Workflow & Quality Gates" requires
unit, widget and integration coverage, and plan.md records two paths
(production-site rendering, page preservation) that have **no live data** in the
reference tenant and can only be verified by widget test.

**Organization**: Grouped by user story. Phases 3–6 map to the spec's P1–P4.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Parallelizable — different file, no dependency on an incomplete task
- **[Story]**: US1–US4, on user-story phases only

## Path Conventions

Single Flutter app. Source under `lib/`, tests under `test/`. Generated
`*.freezed.dart` / `*.g.dart` files are never hand-edited — they are produced by
the `build_runner` tasks below.

---

## Phase 1: Setup

**Purpose**: Establish a clean baseline so later failures are attributable to this
feature's changes.

- [ ] T001 Confirm a clean baseline on branch `018-nested-facility-management`: run `flutter pub get`, `dart run build_runner build --delete-conflicting-outputs`, `flutter gen-l10n`, `flutter analyze` and `flutter test`, and record any pre-existing failure before changing code
- [ ] T002 Re-read [contracts/routes.md](./contracts/routes.md) §5 and note the three `startsWith` guards in `lib/app/router/app_router.dart` that MUST survive Phase 5 — this is the feature's highest-risk edit and has no compile-time protection

**Checkpoint**: Baseline green, guard risk understood.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: The child-loading data layer. Every user story depends on it.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [ ] T003 Create the `FacilityChildren` freezed entity in `lib/features/catalog/domain/entities/facility_children.dart` with fields `facilityId`, `warehouses`, `pointsOfSale`, `cashDrawers`, `warehousesReadable`, `pointsOfSaleReadable`, `cashDrawersReadable`, per [data-model.md](./data-model.md) §2
- [ ] T004 Add the derived-value extension to `lib/features/catalog/domain/entities/facility_children.dart`: `warehouseCount`, `pointSaleCount`, `cashDrawerCount` (list lengths) and `isCrossFacility(PointSale)` (warehouse not among this facility's warehouses, FR-009) — depends on T003 (same file, appends after the entity it extends); not parallelizable with it
- [ ] T005 Create `facilityChildrenControllerProvider` as a `@riverpod` family keyed by `facilityId` in `lib/features/catalog/presentation/facility_children_controller.dart`, resolving which types to fetch by `FacilityType` first and `accessControlProvider` second, per [data-model.md](./data-model.md) §3 and [research.md](./research.md) §2
- [ ] T006 In `lib/features/catalog/presentation/facility_children_controller.dart`, implement the complete-the-collection loop required by FR-019: request each child type with `limit: 100` and, while `total > loaded.length`, append subsequent pages by `skip`, with no user-facing control
- [ ] T007 Run `dart run build_runner build --delete-conflicting-outputs` to generate the freezed and riverpod companions for T003–T006
- [ ] T008 [P] Unit-test the controller in `test/unit/features/catalog/facility_children_controller_test.dart` against fake repositories, covering: a store issues three fetches; a production site issues **only** the warehouse fetch; a type the user cannot read is not requested and its `*Readable` flag is `false`; a section whose `total` exceeds 100 is loaded completely; a repository failure surfaces as `AsyncError` without throwing

**Checkpoint**: Children load correctly and are unit-tested. The app is unchanged
and still builds.

---

## Phase 3: User Story 1 — See a facility's full shape at a glance (Priority: P1) 🎯 MVP

**Goal**: Replace the Facilities table with the read-only expandable hierarchy —
cards, counts, sections, statuses, empty states, the production-site note and the
cross-facility badge — while keeping search, status filter and pagination.

**Independent test**: Load `/facilities` and verify counts on collapsed cards match
what expansion reveals, that a production site shows only Warehouses, and that
empty sections say so. No record is created or edited.

- [ ] T009 [P] [US1] Add the 11 new keys from [contracts/ui-contracts.md](./contracts/ui-contracts.md) §7 to `lib/l10n/app_es.arb`, authoring the es-MX wording first
- [ ] T010 [P] [US1] Add the same 11 keys with English wording and `@` metadata entries to `lib/l10n/app_en.arb`
- [ ] T011 [US1] Run `flutter gen-l10n` to regenerate `lib/l10n/app_localizations*.dart`
- [ ] T012 [P] [US1] Create `lib/features/catalog/presentation/widgets/facility_child_row.dart` rendering one warehouse, point-of-sale or cash-drawer row: type icon, name, code chip, status, edit affordance, plus the warehouse name and cross-facility badge for points of sale — all colors from `Theme.of(context)` (FR-030), keys per contracts §2
- [ ] T013 [P] [US1] Create `lib/features/catalog/presentation/widgets/facility_child_section.dart` rendering a section header (label, count, divider, create slot), its rows, and the dashed empty-state placeholder when the section is empty but readable (FR-010)
- [ ] T014 [US1] Create `lib/features/catalog/presentation/widgets/facility_card.dart` composing the header (chevron, type icon, name, code chip, type label, counts, status, edit affordance) and the expanded body, watching `facilityChildrenControllerProvider(facilityId)` and rendering per-card loading, error-with-retry (FR-020) and the production-site note (FR-011)
- [ ] T015 [US1] Rewrite `lib/features/catalog/presentation/facilities_list_screen.dart` as the hierarchy: keep `CatalogFilterBar`, `CatalogSearchBar`, the status facet panel and pagination unchanged, and replace `DataTableView` with a **non-lazy** card list — `ListView(children: [...])`, never `ListView.builder`, per [research.md](./research.md) §1
- [ ] T016 [US1] Add the expand-all/collapse-all toolbar control and the view-local `Set<int> expandedFacilityIds` state to `lib/features/catalog/presentation/facilities_list_screen.dart` (FR-012, FR-013), keeping expansion out of the URL
- [ ] T017 [US1] Ensure collapsed-card counts render a placeholder rather than `0` while children are loading (contracts §5) in `lib/features/catalog/presentation/widgets/facility_card.dart`
- [ ] T018 [US1] Rewrite `test/widget/features/catalog/facilities_list_screen_test.dart` for the hierarchy: counts on collapsed cards, expansion revealing sections, empty-state placeholders, **a production-site facility showing only Warehouses plus the note** (fabricated data — no live rows exist, plan.md "Reference-tenant reality"), the cross-facility badge, and per-card error-with-retry isolation. The rewrite MUST also **retain** equivalent coverage for behavior this feature does not change (FR-014/015/016): search-field presence, filter-button presence, and a status facet passed from the URL to the repository — replacing the existing `find.byType(PaginatedDataTable2)` assertion, which will fail outright once the table is gone, with an equivalent assertion against the new card list

**Checkpoint**: US1 is independently shippable — the hierarchy renders read-only
while the three old list screens still exist as a fallback.

---

## Phase 4: User Story 2 — Manage a site's records without leaving the tree (Priority: P2)

**Goal**: Create, view, edit and delete from the tree, with the parent facility
pre-selected and the affected card refreshing in place.

**Independent test**: Create one warehouse, one point of sale and one cash drawer
from the tree, edit each, move one between facilities, delete one — verifying the
parent was pre-selected and that page and expansion survive every round trip.

- [ ] T019 [US2] Parse an optional `?facility=<id>` query parameter on `/warehouses/new`, `/cash-drawers/new` and `/points-of-sale/new` in `lib/app/router/app_router.dart` and pass it to the screen as `facilityId`, treating absent or unparseable as `null` (contracts/routes.md §4)
- [ ] T020 [P] [US2] Add the optional `facilityId` parameter to `lib/features/catalog/presentation/warehouse_detail_screen.dart` and, in create mode, resolve it through the existing `facilityDisplayNameProvider` and apply it via `facilitySelected`, tolerating a `null` name (research §5)
- [ ] T021 [P] [US2] Apply the same prefill to `lib/features/catalog/presentation/cash_drawer_detail_screen.dart`
- [ ] T022 [P] [US2] Apply the same prefill to `lib/features/catalog/presentation/point_sale_detail_screen.dart`
- [ ] T023 [P] [US2] Add `int? originalFacilityId` to `WarehouseFormState` in `lib/features/catalog/presentation/warehouse_form_controller.dart`, set it in `loadForEdit`, leave it untouched in `facilitySelected`, and repoint `_invalidateCaches` to invalidate `facilityChildrenControllerProvider` for the current facility and — when the facility changed — the original one too (research §6)
- [ ] T024 [P] [US2] Apply the same `originalFacilityId` and invalidation change to `lib/features/catalog/presentation/cash_drawer_form_controller.dart`
- [ ] T025 [P] [US2] Apply the same `originalFacilityId` and invalidation change to `lib/features/catalog/presentation/point_sale_form_controller.dart`
- [ ] T026 [US2] In `lib/features/catalog/presentation/facility_form_controller.dart`, additionally invalidate that facility's `facilityChildrenControllerProvider` instance alongside the existing facilities-list invalidation, so a deleted-then-recreated id cannot serve stale children
- [ ] T027 [US2] Run `dart run build_runner build --delete-conflicting-outputs` to regenerate the three form states changed in T023–T025
- [ ] T028 [US2] Wire navigation into the tree per [contracts/ui-contracts.md](./contracts/ui-contracts.md) §3 — header and row taps push `?view=true`, edit affordances push the editable route, section create actions push `/<child>/new?facility=<facilityId>` — across `facility_card.dart`, `facility_child_section.dart` and `facility_child_row.dart`, all via `context.push`
- [ ] T029 [US2] Apply the RBAC matrix from [contracts/ui-contracts.md](./contracts/ui-contracts.md) §4 across the three widgets: hide (never disable) each create and edit affordance, omit a section the user cannot read, and exclude that section's count from the collapsed header (FR-028, FR-029)
- [ ] T030 [P] [US2] Extend `test/widget/features/catalog/warehouse_detail_screen_test.dart`, `cash_drawer_detail_screen_test.dart` and `point_sale_detail_screen_test.dart` with a cold-load case asserting `?facility=<id>` pre-selects the parent (FR-023)
- [ ] T031 [US2] Add tests to `test/widget/features/catalog/facilities_list_screen_test.dart` for: create/edit/view navigation targets per contracts §3; RBAC hiding of create and edit affordances; a section omitted entirely without read privilege; and **page and expansion preserved across a mutation** (fabricated multi-page data — the reference tenant is single-page)
- [ ] T032 [US2] Add a unit test in `test/unit/features/catalog/facility_children_controller_test.dart` asserting that moving a record between facilities invalidates **both** the original and the new facility's children (the `originalFacilityId` path)

**Checkpoint**: The tree is a complete workspace. Removing the old screens is now
safe.

---

## Phase 5: User Story 3 — One navigation entry instead of four (Priority: P3)

**Goal**: Remove the three sibling destinations, their list screens and their
router branches — without touching the guards that protect the surviving record
routes.

**Independent test**: Catálogos shows Facilities only; `/warehouses` no longer
resolves; `/warehouses/<id>` still does and still enforces `warehouses:read`.

- [ ] T033 [US3] Remove the `warehouses`, `cash-drawers` and `points-of-sale` `NavDestination` entries and their `_warehousesLabel`/`_cashDrawersLabel`/`_pointsOfSaleLabel` tear-offs from `lib/core/navigation/nav_destinations.dart`, keeping the three l10n keys themselves (they are reused as section headers)
- [ ] T034 [US3] Renumber `NavBranch` in `lib/core/navigation/nav_destinations.dart` to `facilities = 14`, `paymentMethodOptions = 15`, `taxpayerIssuers = 16` per [contracts/routes.md](./contracts/routes.md) §2, and update the stale comment above the Facilities destination that still describes it as the parent of "the three catalogs above"
- [ ] T035 [US3] Delete the three `StatefulShellBranch` entries for `/warehouses`, `/cash-drawers` and `/points-of-sale` from `lib/app/router/app_router.dart`, along with their now-unused screen imports, and update the branch-order comments
- [ ] T036 [US3] Verify in `lib/app/router/app_router.dart` that the three `location.startsWith(...)` clauses for `/warehouses`, `/cash-drawers` and `/points-of-sale` in `_gateFor` remain **unchanged** — they gate the surviving detail routes (contracts/routes.md §5)
- [ ] T037 [P] [US3] Delete `lib/features/catalog/presentation/warehouses_list_screen.dart` and `warehouses_list_controller.dart` with its `.freezed.dart` and `.g.dart` companions
- [ ] T038 [P] [US3] Delete `lib/features/catalog/presentation/cash_drawers_list_screen.dart` and `cash_drawers_list_controller.dart` with its generated companions
- [ ] T039 [P] [US3] Delete `lib/features/catalog/presentation/points_of_sale_list_screen.dart` and `points_of_sale_list_controller.dart` with its generated companions
- [ ] T040 [P] [US3] Delete `test/widget/features/catalog/warehouses_list_screen_test.dart`, `cash_drawers_list_screen_test.dart` and `points_of_sale_list_screen_test.dart`
- [ ] T041 [US3] Add a test to `test/unit/app/router/app_router_test.dart` asserting that for every `NavDestination` in `kNavigationTree`, navigating to its `route` activates the shell branch at its `branchIndex` — the renumbering invariant has no compile-time enforcement
- [ ] T042 [US3] Add a test to `test/unit/app/router/app_router_test.dart` asserting that a user lacking `warehouses:read` is redirected away from **`/warehouses/5`** (not just `/warehouses`), and the equivalent for `cashDrawers` and `pointsOfSale` — this is the only thing standing between T035 and a silent RBAC hole
- [ ] T043 [P] [US3] Update `test/widget/core/widgets/app_navigation_test.dart` for the three removed destinations
- [ ] T044 [US3] Rework `test/integration/facility_catalogs_flow_test.dart` to drive the facility tree instead of the deleted list screens, and update branch expectations in `test/integration/navigation_shell_flow_test.dart`

**Checkpoint**: One navigation entry; every record still reachable and still
gated.

---

## Phase 6: User Story 4 — Usable on a phone (Priority: P4)

**Goal**: Compact-tier density for the same hierarchy, with every wide-tier action
reachable.

**Independent test**: Below 600 px, no horizontal scrolling, all targets touch-
sized, every action available.

- [ ] T045 [P] [US4] Branch on `LayoutBreakpoints.isCompact(context)` in `lib/features/catalog/presentation/widgets/facility_card.dart` for the compact header: trailing chevron, 40 px icon tile, wrapped meta chips, dot status indicator (contracts §6)
- [ ] T046 [P] [US4] Apply compact density to `lib/features/catalog/presentation/widgets/facility_child_row.dart`: wrapped metadata, dot status, ≥44 px touch targets
- [ ] T047 [US4] In `lib/features/catalog/presentation/widgets/facility_child_section.dart` and `facility_card.dart`, move the per-section create actions into a single chip row at the end of the expanded body on the compact tier
- [ ] T048 [US4] Add the compact-tier create-facility FAB (`new_facility_fab`) to `lib/features/catalog/presentation/facilities_list_screen.dart`, gated on `facilities:create`
- [ ] T049 [US4] Add compact-tier cases to `test/widget/features/catalog/facilities_list_screen_test.dart`: no horizontal overflow at 390 px width, FAB present and RBAC-gated, create chips present in the expanded body

**Checkpoint**: Feature complete across both tiers.

---

## Phase 7: Polish & Cross-Cutting

- [ ] T050 Verify no hex color literal from the design mock reached Dart — grep the three new widget files and `facilities_list_screen.dart` for `0xFF` and `Color(` and replace any with `Theme.of(context)` tokens (FR-030)
- [ ] T051 Verify truncation behavior across the tree per FR-033: long names wrap or ellipsize **with a tooltip**, and code, name and status are never truncated
- [ ] T052 Run `flutter analyze` and `dart fix --apply`, then remove any import or symbol left orphaned by the Phase 5 deletions
- [ ] T053 Run the full `flutter test` suite and confirm `test/unit/features/repository_list_params_audit_test.dart` still passes untouched — the repositories were not changed
- [ ] T054 Walk [quickstart.md](./quickstart.md) Gates 1–4 against a live mbe-api, performing by hand the two checks that fail silently: scroll the facilities page to confirm counts do **not** pop in (eager loading, research §1), and open `/warehouses/5` as a user without `warehouses:read` to confirm the redirect (contracts/routes.md §5)

---

## Dependencies

**Phase order**: Setup → Foundational → US1 → US2 → US3 → US4 → Polish.

**Story dependencies** — unusually, these are *not* independent:

- **US1 requires Phase 2.** The cards cannot render without the children provider.
- **US2 requires US1.** There is no tree to wire actions into otherwise.
- **US3 requires US2.** Deleting the old screens before the tree does everything
  they did would strand functionality. This ordering is deliberate: until Phase 5
  lands, the old screens remain a working fallback.
- **US4 requires US1** (density on existing widgets) and touches US2's actions, so
  it is sequenced after both.

**Critical path**: T003 → T005 → T007 → T014 → T015 → T028 → T035 → T042.

**Notable intra-phase dependencies**:

- T004 depends on T003 — same file, not parallelizable.
- T011 (`gen-l10n`) blocks T012–T016 — the widgets reference the new keys.
- T014 depends on T012 and T013; T015 depends on T014.
- T027 (`build_runner`) must follow T023–T025 and precede T031.
- T036 is a verification gate on T035, not an edit — do them together.

## Parallel Opportunities

| Phase | Parallel set | Why safe |
|---|---|---|
| 3 | T009, T010 | Different `.arb` files |
| 3 | T012, T013 | Different widget files, neither imports the other |
| 4 | T020, T021, T022 | Three independent detail screens |
| 4 | T023, T024, T025 | Three independent form controllers |
| 5 | T037, T038, T039, T040, T043 | Independent deletions and one unrelated test file |
| 6 | T045, T046 | Different widget files |

## Implementation Strategy

**MVP = Phases 1–3 (T001–T018).** That delivers the spec's P1 story: the
structural view that no current screen provides, satisfying SC-002 and SC-006. It
ships safely because the three old list screens are still present and still
reachable — nothing is removed until Phase 5.

**Incremental delivery**: each phase checkpoint is a shippable state. Phase 4 turns
the view into a workspace (SC-001, SC-005). Phase 5 is the only destructive phase
and is deliberately last (SC-003). Phase 6 adds the compact tier (SC-008).

**The two things most likely to go wrong**, both silent:

1. Rendering the card list with `ListView.builder` in T015. Everything looks
   correct until you scroll and counts pop in. T054 checks it by hand.
2. Deleting the three `_gateFor` clauses in T035. Nothing crashes, no existing test
   fails, and every child record becomes reachable by URL without privilege. T036
   and T042 exist solely to prevent this.
