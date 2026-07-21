---
description: "Task list for Facilities and their Facility-Scoped Operational Catalogs"
---

# Tasks: Facilities and their Facility-Scoped Operational Catalogs

**Input**: Design documents from `/specs/014-facility-scoped-catalogs/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: INCLUDED — the constitution's Development Workflow mandates unit/widget/integration tests, and plan.md enumerates the `test/` files. Test tasks are marked ⚠️ and precede their implementation.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: US1 Warehouses · US2 Cash Drawers · US3 Points of Sale · US4 Facilities
- Every task lists an exact path under the repo root.

## Path Conventions

Single Flutter project, feature-first. Feature code under
`lib/features/catalog/{data,domain,presentation}/`; shared enums under
`lib/core/domain/`; integration wiring in `lib/app/router/app_router.dart`,
`lib/core/navigation/nav_destinations.dart`, `lib/core/access/system_object.dart`,
`lib/l10n/app_*.arb`. Tests under `test/{unit,widget,integration}/`.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Confirm the ground the feature builds on; no codegen (client already regenerated 2026-07-21).

- [ ] T001 Verify the regenerated client exposes `WarehousesApi`, `CashDrawersApi`, `PointsOfSaleApi`, `FacilitiesApi`, `AddressesApi`, `TaxpayerIssuersApi` with `search` on every list method, under `lib/generated/openapi/lib/src/api/` (research.md §1); do not edit generated files.
- [ ] T002 Confirm `warehouses(4)`, `pointsOfSale(9)`, `cashDrawers(10)`, `addresses(11)`, `taxpayers(24)` already exist in `lib/core/access/system_object.dart` (only `facilities` needs correction, done in T010).

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Shared pieces every downstream story needs — the facility read path used by all pickers/filters, the facility-type enum, the RBAC-mirror correction, and shared l10n. **No story can start until this phase is done.**

- [ ] T010 [P] FR-027: in `lib/core/access/system_object.dart`, first grep the repo for `SystemObject.stores` and `SystemObject.productionSites` and report any real consumer; then rename `stores(29)` → `facilities(29)` and remove `productionSites(107)` (research.md §2, contracts/routes.md).
- [ ] T011 [P] Create `lib/core/domain/facility_type.dart`: `FacilityType` enum `store(0)`/`productionSite(1)` with `fromApi`/`toApi`, mirroring `entity_status.dart` (data-model.md, research.md §5).
- [ ] T012 [P] Create `lib/features/catalog/domain/entities/facility_list_item.dart`: `FacilityListItem{facilityId, code, name, type: FacilityType, status: EntityStatus}` with `fromResponse` from `FacilityResponse`/`FacilitySummary` (data-model.md).
- [ ] T013 Create `lib/features/catalog/domain/repositories/facility_repository.dart`: interface with `list({search, status, skip, limit})` returning a `FacilityListResult` (get/create/update/delete are added in US4).
- [ ] T014 Create `lib/features/catalog/data/facility_repository_impl.dart`: wraps `FacilitiesApi`, implements `list`, exposes `facilityRepositoryProvider`; `DioException`→`AppError` via the operator-repo pattern (contracts/mbe-api-catalogs.md).
- [ ] T015 Run `dart run build_runner build --delete-conflicting-outputs` to generate `.freezed.dart`/`.g.dart` for T011–T012, then `dart analyze` those files.
- [ ] T016 [P] Add shared l10n keys used by all four catalogs (status labels already exist; add facility-type labels `facilityTypeStore`/`facilityTypeProductionSite` and any shared column/empty-state keys) to `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb`, keeping both files in key parity.

**Checkpoint**: Facility read repository + picker view model + `FacilityType` enum ready; `facilities(29)` corrected. Pickers/filters in every story can now read facilities.

---

## Phase 3: User Story 1 - Manage the Warehouses catalog (Priority: P1) 🎯 MVP

**Goal**: Full CRUD for Warehouses with a facility picker (form), a facility+status filter drawer, and server-side search.

**Independent test**: Open `/warehouses`, filter to one facility, create a warehouse by picking a facility + entering code/name, edit its comment, change status, view read-only, delete — per spec US1 acceptance scenarios.

### Tests for User Story 1 ⚠️

- [ ] T020 [P] [US1] Unit test `test/unit/features/catalog/warehouse_test.dart`: `Warehouse.fromResponse` maps the pre-expanded `facility` summary to `facilityName`; unresolvable facility → fallback label.
- [ ] T021 [P] [US1] Widget test `test/widget/features/catalog/warehouses_list_screen_test.dart`: list renders facility/code/name/status; filter drawer combines facility + status; empty state; Create/Edit hidden without RBAC.
- [ ] T022 [P] [US1] Widget test `test/widget/features/catalog/warehouse_detail_screen_test.dart`: read-only vs editable toggle by update privilege; delete in form body gated by delete privilege; duplicate-code server rejection surfaced on the form (FR-012).

### Implementation for User Story 1

- [ ] T023 [P] [US1] Create `lib/features/catalog/domain/entities/warehouse.dart`: `Warehouse{warehouseId, facilityId, facilityName, code, name, comment?, status}` + `fromResponse` (data-model.md).
- [ ] T024 [P] [US1] Create `lib/features/catalog/domain/repositories/warehouse_repository.dart`: `list({search, facilityId, status, skip, limit})`, `get`, `create`, `update`, `delete`.
- [ ] T025 [US1] Create `lib/features/catalog/data/warehouse_repository_impl.dart`: wraps `WarehousesApi`, maps create/update from `{facility, code, name, comment?, status?}`, exposes `warehouseRepositoryProvider` (contracts/mbe-api-catalogs.md).
- [ ] T026 [US1] Create `lib/features/catalog/presentation/warehouses_list_controller.dart`: `WarehouseFilter{search, facilityId?, facilityDisplayText, status?}` + `FilterBadge` extension + filter `Notifier` + list `Notifier` with `goToPage`, mirroring `products_list_controller.dart` + the operator FK-facet (research.md §6).
- [ ] T027 [US1] Create `lib/features/catalog/presentation/warehouses_list_screen.dart`: `DataTableView` + `CatalogPagination` + `CatalogFilterBar` (search) + `CatalogFilterSheet` with a `CatalogEntityPicker<FacilityListItem>` facet and `EntityStatusControls`; Create as a toolbar `FilledButton`; row-click → read-only detail; Edit row icon.
- [ ] T028 [US1] Create `lib/features/catalog/presentation/warehouse_form_controller.dart`: `WarehouseFormState` + validate (facility/code/name required) + submitCreate/submitUpdate/delete with pre-submit RBAC re-check and `_fieldErrorsFromServer`, mirroring `vehicle_operator_form_controller.dart`.
- [ ] T029 [US1] Create `lib/features/catalog/presentation/warehouse_detail_screen.dart`: `ResponsiveFormGrid`; facility `CatalogEntityPicker<FacilityListItem>` (backed by `facilityRepositoryProvider`); code/name/comment fields; `EntityStatusControls`; read-only "View" mode + edit toggle; delete button in body.
- [ ] T030 [US1] Add the `/warehouses` + `/warehouses/new` + `/warehouses/:id` branch to `lib/app/router/app_router.dart` (wrapped in `_routeGate(SystemObject.warehouses, read)`), appended after the vehicle-operators branch (contracts/routes.md).
- [ ] T031 [US1] Add the Warehouses `NavDestination` + `NavBranch.warehouses = 14` to `lib/core/navigation/nav_destinations.dart`, in the same position as the router branch (NavBranch invariant).
- [ ] T032 [P] [US1] Add Warehouses l10n keys (nav title, column headers, field labels, validation, empty state) to `lib/l10n/app_en.arb` and `app_es.arb` in parity.
- [ ] T033 [US1] Run `dart run build_runner build --delete-conflicting-outputs` then `dart analyze lib/features/catalog` for the new US1 files.

**Checkpoint**: Warehouses catalog fully functional and independently testable (MVP).

---

## Phase 4: User Story 2 - Manage the Cash Drawers catalog (Priority: P1)

**Goal**: Full CRUD for Cash Drawers — structurally identical to Warehouses (research.md §3).

**Independent test**: Open `/cash-drawers`, filter by facility+status, create/edit/delete a cash drawer — per spec US2 acceptance scenarios.

### Tests for User Story 2 ⚠️

- [ ] T040 [P] [US2] Unit test `test/unit/features/catalog/cash_drawer_test.dart`: `CashDrawer.fromResponse` facility expansion + fallback.
- [ ] T041 [P] [US2] Widget test `test/widget/features/catalog/cash_drawers_list_screen_test.dart`: list + facility/status filter drawer + empty state + RBAC hiding.
- [ ] T042 [P] [US2] Widget test `test/widget/features/catalog/cash_drawer_detail_screen_test.dart`: read-only/edit toggle, delete gating, server-rejection surfacing.

### Implementation for User Story 2

- [ ] T043 [P] [US2] Create `lib/features/catalog/domain/entities/cash_drawer.dart` (Warehouse shape with `cashDrawerId`) + `fromResponse`.
- [ ] T044 [P] [US2] Create `lib/features/catalog/domain/repositories/cash_drawer_repository.dart` (same ops as warehouse repo).
- [ ] T045 [US2] Create `lib/features/catalog/data/cash_drawer_repository_impl.dart`: wraps `CashDrawersApi`, exposes `cashDrawerRepositoryProvider`.
- [ ] T046 [US2] Create `lib/features/catalog/presentation/cash_drawers_list_controller.dart`: `CashDrawerFilter{search, facilityId?, facilityDisplayText, status?}` + badge + filter/list notifiers.
- [ ] T047 [US2] Create `lib/features/catalog/presentation/cash_drawers_list_screen.dart` (Warehouses list screen copy, retargeted; facility + status drawer).
- [ ] T048 [US2] Create `lib/features/catalog/presentation/cash_drawer_form_controller.dart` (Warehouse form controller copy; RBAC object `cashDrawers`).
- [ ] T049 [US2] Create `lib/features/catalog/presentation/cash_drawer_detail_screen.dart` (Warehouse detail copy; facility picker + code/name/comment/status).
- [ ] T050 [US2] Add the `/cash-drawers` branch to `lib/app/router/app_router.dart` (`_routeGate(SystemObject.cashDrawers, read)`), appended after Warehouses.
- [ ] T051 [US2] Add the Cash Drawers `NavDestination` + `NavBranch.cashDrawers = 15` to `lib/core/navigation/nav_destinations.dart` (matching router position).
- [ ] T052 [P] [US2] Add Cash Drawers l10n keys to both `.arb` files in parity.
- [ ] T053 [US2] Run `build_runner` + `dart analyze` for the new US2 files.

**Checkpoint**: Cash Drawers catalog works independently.

---

## Phase 5: User Story 3 - Manage the Points of Sale catalog (Priority: P2)

**Goal**: Full CRUD for Points of Sale with facility **and** warehouse pickers (warehouse scoped to the selected facility) and a facility+warehouse+status filter drawer.

**Depends on**: US1 for the warehouse read repository the warehouse picker/filter uses.

**Independent test**: Open `/points-of-sale`, filter by facility/warehouse/status, create a point of sale picking a facility then a warehouse (only that facility's warehouses offered), change facility → warehouse clears, edit/delete — per spec US3 acceptance scenarios.

### Tests for User Story 3 ⚠️

- [ ] T060 [P] [US3] Unit test `test/unit/features/catalog/point_sale_test.dart`: `PointSale.fromResponse` expands both facility and warehouse; either unresolvable → fallback.
- [ ] T061 [P] [US3] Widget test `test/widget/features/catalog/points_of_sale_list_screen_test.dart`: three-facet drawer (facility+warehouse+status); empty state; RBAC.
- [ ] T062 [P] [US3] Widget test `test/widget/features/catalog/point_sale_detail_screen_test.dart`: warehouse picker scoped to selected facility; changing facility to one the current warehouse doesn't belong to clears/forces reselect (FR-022); cross-facility server rejection surfaced (mbe-api#102).

### Implementation for User Story 3

- [ ] T063 [P] [US3] Create `lib/features/catalog/domain/entities/point_sale.dart`: `PointSale{pointSaleId, facilityId, facilityName, code, name, warehouseId, warehouseName, comment?, status}` + `fromResponse`.
- [ ] T064 [P] [US3] Create `lib/features/catalog/domain/repositories/point_sale_repository.dart` (list with facility+warehouse+status, get/create/update/delete).
- [ ] T065 [US3] Create `lib/features/catalog/data/point_sale_repository_impl.dart`: wraps `PointsOfSaleApi`, exposes `pointSaleRepositoryProvider`.
- [ ] T066 [US3] Create `lib/features/catalog/presentation/points_of_sale_list_controller.dart`: `PointSaleFilter{search, facilityId?, facilityDisplayText, warehouseId?, warehouseDisplayText, status?}` + badge + filter/list notifiers.
- [ ] T067 [US3] Create `lib/features/catalog/presentation/points_of_sale_list_screen.dart`: list + `CatalogFilterSheet` with facility picker, warehouse picker (`warehouseRepositoryProvider` from US1), and `EntityStatusControls`.
- [ ] T068 [US3] Create `lib/features/catalog/presentation/point_sale_form_controller.dart`: `PointSaleFormState` with facility+warehouse id/displayText pairs; on facility change, clear the warehouse when it no longer belongs (FR-022); validate facility/code/name/warehouse required.
- [ ] T069 [US3] Create `lib/features/catalog/presentation/point_sale_detail_screen.dart`: facility picker + warehouse picker whose `optionsBuilder` passes `facilityId` to `warehouseRepo.list`; code/name/comment/status; read-only/edit/delete.
- [ ] T070 [US3] Add the `/points-of-sale` branch to `app_router.dart` (`_routeGate(SystemObject.pointsOfSale, read)`), appended after Cash Drawers.
- [ ] T071 [US3] Add the Points of Sale `NavDestination` + `NavBranch.pointsOfSale = 16` to `nav_destinations.dart` (matching router position).
- [ ] T072 [P] [US3] Add Points of Sale l10n keys to both `.arb` files in parity.
- [ ] T073 [US3] Run `build_runner` + `dart analyze` for the new US3 files.

**Checkpoint**: Points of Sale works; warehouse picker is facility-scoped over a real backend invariant.

---

## Phase 6: User Story 4 - Manage the Facilities catalog (Priority: P2)

**Goal**: Full CRUD for Facilities, with a SAT location picker, an address picker + inline-create, and a taxpayer autocomplete. Extends the foundational facility read repo with write ops.

**Independent test**: Open `/facilities`, create a facility with a new inline address + a picked taxpayer + a location, edit its receipt message, change status, delete; a created facility is immediately selectable in the other catalogs' pickers — per spec US4 acceptance scenarios.

### Tests for User Story 4 ⚠️

- [ ] T080 [P] [US4] Unit test `test/unit/features/catalog/facility_test.dart`: `Facility.fromResponse` expands `location` and `address`, keeps `taxpayer` as bare RFC (FR-034b); `FacilityType`/`AddressType` round-trip.
- [ ] T081 [P] [US4] Unit test `test/unit/features/catalog/facility_validators_test.dart`: required fields (code/name/location/address/taxpayer) and RFC ≤13 shape-only (never an existence claim).
- [ ] T082 [P] [US4] Widget test `test/widget/features/catalog/facilities_list_screen_test.dart`: list (code/name/type/status) + status-only filter drawer + empty state + RBAC.
- [ ] T083 [P] [US4] Widget test `test/widget/features/catalog/facility_detail_screen_test.dart`: location/address/taxpayer pickers; address inline-create shown only with `addresses(11)` create (FR-032); taxpayer degrades to typed RFC without `taxpayers(24)` read (FR-034); delete gating.
- [ ] T084 [P] [US4] Widget test `test/widget/features/catalog/address_inline_create_test.dart`: required address fields; on success returns the address to the facility form; a later facility-save failure keeps the created address selected (spec Edge Cases).

### Implementation for User Story 4

- [ ] T085 [P] [US4] Create `lib/core/domain/address_type.dart`: `AddressType` `other(0)`/`home(1)`/`work(2)`/`business(3)`/`fiscal(4)` with `fromApi`/`toApi` (data-model.md, FR-033).
- [ ] T086 [P] [US4] Extend `lib/features/catalog/domain/entities/facility.dart`: `Facility{facilityId, code, name, type, locationId, locationLabel, addressId, addressLabel, taxpayerRfc, logo?, receiptMessage?, defaultBatch?, status}` + `fromResponse` (address/location from expanded objects; taxpayer bare RFC).
- [ ] T087 [P] [US4] Create `lib/features/catalog/domain/entities/address_list_item.dart` (`{addressId, label, type}` + `AddressCreatePayload`) and `taxpayer_issuer_list_item.dart` (`{rfc, name?}`).
- [ ] T088 [US4] Extend `facility_repository.dart` + `facility_repository_impl.dart` with `get`/`create`/`update`/`delete` over `FacilitiesApi` (contracts/mbe-api-catalogs.md).
- [ ] T089 [P] [US4] Create `lib/features/catalog/domain/repositories/address_repository.dart` + `data/address_repository_impl.dart`: `list({search})` and `create(AddressCreatePayload)`, `addressRepositoryProvider` (list+create only; contracts §Addresses).
- [ ] T090 [P] [US4] Create `lib/features/catalog/domain/repositories/taxpayer_issuer_repository.dart` + `data/taxpayer_issuer_repository_impl.dart`: `list({search})` and optional `get(rfc)`, `taxpayerIssuerRepositoryProvider` (contracts §Taxpayer Issuers).
- [ ] T091 [US4] Add an RFC shape validator (≤13 chars, shape only) to `lib/features/catalog/domain/catalog_field_validators.dart` (FR-034).
- [ ] T092 [US4] Create `lib/features/catalog/presentation/facilities_list_controller.dart`: `FacilityFilter{search, status?}` + badge + filter/list notifiers.
- [ ] T093 [US4] Create `lib/features/catalog/presentation/facilities_list_screen.dart`: list (code/name/type/status) + `CatalogFilterSheet` with `EntityStatusControls` only; Create toolbar button; row-click read-only.
- [ ] T094 [US4] Create `lib/features/catalog/presentation/address_inline_create_controller.dart` + `address_inline_create.dart`: Material 3 `Dialog` with a `ResponsiveFormGrid` body over the `AddressCreate` fields, posting via `addressRepositoryProvider`, returning the created `AddressListItem`; shown only with `can(addresses, create)` (FR-031/032).
- [ ] T095 [US4] Create `lib/features/catalog/presentation/facility_form_controller.dart`: `FacilityFormState` (all facility fields); validate; submitCreate/submitUpdate/delete with pre-submit RBAC re-check on `facilities`; `_fieldErrorsFromServer` maps duplicate-code / unregistered-taxpayer to the right field (FR-012).
- [ ] T096 [US4] Create `lib/features/catalog/presentation/facility_detail_screen.dart`: `ResponsiveFormGrid` with — code/name; `FacilityType` control; location `CatalogEntityPicker<SatCatalogItem>` (reuse `SatCatalogRepository.listPostalCodes`, research.md §7); address `CatalogEntityPicker<AddressListItem>` + inline-create affordance; taxpayer `CatalogEntityPicker<TaxpayerIssuerListItem>` gated on `taxpayers(24)` with typed-RFC degrade (FR-034); logo/receiptMessage/defaultBatch; status; read-only/edit/delete.
- [ ] T097 [US4] Add the `/facilities` branch to `app_router.dart` (`_routeGate(SystemObject.facilities, read)`), appended after Points of Sale.
- [ ] T098 [US4] Add the Facilities `NavDestination` + `NavBranch.facilities = 17` to `nav_destinations.dart` (router-matching position; the destination MAY be listed first in the Catalogs group for display).
- [ ] T099 [P] [US4] Add Facilities + address + taxpayer + address-type l10n keys to both `.arb` files in parity.
- [ ] T100 [US4] Run `build_runner` + `dart analyze` for the new US4 files.

**Checkpoint**: All four catalogs independently functional; a facility created here is immediately selectable in the other three pickers (FR-023, SC-010).

---

## Phase 7: Polish & Cross-Cutting Concerns

- [ ] T110 [P] Integration test `test/integration/facility_catalogs_flow_test.dart`: the quickstart golden path — create facility (inline address + taxpayer pick) → warehouse under it → point of sale picking that warehouse → cash drawer — against a local mbe-api.
- [ ] T111 [P] Verify `lib/l10n/app_en.arb` and `app_es.arb` are at full key parity for all keys added across US1–US4 (no missing/orphan keys).
- [ ] T112 Run `dart run build_runner build --delete-conflicting-outputs` clean, then `dart analyze` with zero new warnings across `lib/` and `test/`.
- [ ] T113 [P] Confirm the NavBranch↔router-branch order invariant across all four new branches (`nav_destinations.dart` indices 14–17 match `app_router.dart` branch order); run the app and confirm the correct nav item highlights per route (contracts/routes.md).
- [ ] T114 [P] Run the quickstart.md targeted checks (RBAC hiding, address-create gating, taxpayer degrade, cross-facility rejection, duplicate code, no-N+1) and record results.

---

## Dependencies & Execution Order

### Phase dependencies

- **Setup (P1)** → **Foundational (P2)** → the user stories.
- **US1 (Warehouses)** and **US2 (Cash Drawers)** depend only on Foundational and are mutually independent — parallelizable.
- **US3 (Points of Sale)** depends on **US1** (reuses `warehouseRepositoryProvider` for the warehouse picker/filter).
- **US4 (Facilities)** depends only on Foundational (it extends the foundational facility repo). Independent of US1–US3; its output (facilities) is what their pickers read, but those read the repo, not the US4 screens.
- **Polish (P7)** depends on all stories.

### Within each user story

Entity → repository interface → repository impl → list/filter controller → list screen → form controller → detail screen → router → nav → l10n → build_runner/analyze. Tests (⚠️) are written first and fail until the story's impl lands.

### Parallel opportunities

- All of Phase 2's `[P]` tasks (T010, T011, T012, T016) except where T013/T014 depend on T012, and T015 depends on T011–T012.
- US1 and US2 can be built by two people in parallel after Foundational.
- Within a story, the `[P]` entity/repo-interface/l10n tasks run together; the impl-wiring tasks (screens/router/nav) are sequential on shared files.
- Cross-story, the `.arb` tasks (T032/T052/T072/T099) touch the same two files — treat as sequential to avoid merge churn despite the `[P]` marker on distinct key blocks.

---

## Implementation Strategy

### MVP first (User Story 1 only)

Setup + Foundational + US1 delivers a complete, shippable Warehouses catalog and proves the whole pattern (facility picker, facet drawer, server search, RBAC, CRUD). Stop-and-ship point.

### Incremental delivery

1. Foundational → US1 (Warehouses, MVP).
2. US2 (Cash Drawers) — near-verbatim, low risk.
3. US4 (Facilities) — the parent catalog; unblocks creating facilities in-app.
4. US3 (Points of Sale) — the two-picker screen; after US1's warehouse repo exists.
5. Polish.

### Parallel team strategy

After Foundational: one developer on US1→US3 (they share the warehouse repo), another on US2 and US4 in parallel. Reconcile `app_router.dart`, `nav_destinations.dart`, and the `.arb` files at each merge (shared-file tasks).

## Notes

- No codegen for the API client (already regenerated 2026-07-21); `build_runner` here is only for `freezed`/`riverpod` in this feature's own new files.
- Zero open upstream dependencies (spec Upstream Dependencies; research.md §1).
- The only shared-kernel edits are the two new `core/domain/` enums and the FR-027 `system_object.dart` correction (guarded by a grep in T010).
