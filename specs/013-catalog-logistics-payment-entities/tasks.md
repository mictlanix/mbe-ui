---
description: "Task list for Catalog Logistics Entities (Expenses, Vehicles, Vehicle Operators)"
---

# Tasks: Catalog Logistics Entities (Expenses, Vehicles, Vehicle Operators)

**Input**: Design documents from `/specs/013-catalog-logistics-payment-entities/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/mbe-api-catalogs.md, contracts/routes.md, quickstart.md

**Tests**: Included — the constitution's "Development Workflow & Quality Gates" mandates unit tests for repositories, widget tests for critical screens, and an integration test for the golden path; specs/011 and specs/012 set this precedent for the same kind of catalog work.

**Organization**: Tasks are grouped by user story. Story order follows the spec's priorities: US1 Expenses (P1), US2 Vehicles (P1), US3 Vehicle Operators (P2). US3 is the only story with a cross-feature dependency — it consumes the spec-012 `employeeRepositoryProvider` / `EmployeeListItem` for its driver picker and filter (already shipped; nothing in this feature re-creates it).

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: US1–US3, mapping to the spec's user stories
- Every task includes an exact file path

## Path Conventions

Single Flutter project, feature-first. All work lands inside the existing `lib/features/catalog/` module (plan.md Structure Decision), plus `lib/core/navigation/`, `lib/app/router/`, and `lib/l10n/`. No `lib/core/domain/` additions (research.md §9). Tests live under `test/unit/features/catalog/`, `test/widget/features/catalog/`, and `test/integration/`.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Confirm preconditions; no new module is created (the `catalog` module already exists).

- [ ] T001 Confirm the generated clients are present, include the regenerated `search` param, and are untouched: `lib/generated/openapi/lib/src/api/{expenses_api,vehicles_api,vehicle_operators_api}.dart` expose `list…Get` with `search` (Expenses/Vehicles: `{search, skip, limit}`; Vehicle Operators: `{search, employee, skip, limit}`), plus the `{Expense,Vehicle,VehicleOperator}{Response,Create,Update}` and `ListResponse*` models (contracts/mbe-api-catalogs.md, research.md §8). Do NOT regenerate; if `search` is missing on any endpoint, stop and re-open research.md §8
- [ ] T002 [P] Confirm the test directories `test/unit/features/catalog/`, `test/widget/features/catalog/`, and `test/integration/` exist (they already hold product/pricing/spec-012 tests — no new module dirs needed)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Shared pieces used by more than one story. Must complete before the stories that consume them.

**⚠️ CRITICAL**: T005 seeds the shared `.arb` keys every story appends to.

- [ ] T003 [P] Extend the existing `lib/features/catalog/domain/catalog_field_validators.dart` (created by spec 012) with any validator these three entities need that is not already present: required-non-empty (already exists — reused for name/licensePlate/nickname/licenseType/driverLicenseNumber/issuingLocation), required-non-negative-integer for `tonsCapacity` (reuse the existing optional-non-negative-integer, made required at the call site), and a new `dateNotBefore(start, end)` helper for the Vehicle Operator `expirationDate ≥ issueDate` soft rule (data-model.md §3). Do NOT duplicate validators that already exist
- [ ] T004 [P] **Reuse, don't duplicate**: for Vehicle Operator `issueDate`/`expirationDate` display, import and use `PricingFormatters.date` from `lib/features/pricing/presentation/pricing_formatters.dart` directly in the catalog screens (the same cross-feature import spec 012 established for employee dates). Do NOT create a new formatter. No money formatter is needed (no money field in this feature)
- [ ] T005 Seed shared l10n keys in `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb`: the three nav titles (`expensesMenuTitle`, `vehiclesMenuTitle`, `vehicleOperatorsMenuTitle`), and the shared column/field labels reused across entities (name, comment, active/status, license plate, nickname). Reuse the existing `editRecordTooltip`/delete-confirm/cancel strings from spec 012. Per-entity keys are added inside each story. Run `flutter gen-l10n` after editing
- [ ] T005a [P] Unit test `test/unit/features/catalog/catalog_field_validators_logistics_test.dart` for the T003 additions — required non-negative-integer `tonsCapacity` (reject empty/negative/decimal, accept 0 and positive), and `dateNotBefore` (reject expiration < issue, accept equal/after)

**Checkpoint**: Shared validators, formatter reuse, and nav/shared l10n keys ready.

---

## Phase 3: User Story 1 - Manage the Expenses catalog (Priority: P1) 🎯 MVP

**Goal**: Full CRUD Expenses catalog (list + detail) — a near-verbatim Labels clone, with the response's `expense` field normalized to `name` (research.md §3).

**Independent Test**: Open `/expenses`, search by name, create an expense, edit its comment, view it read-only, and delete one — independent of any other catalog.

### Tests for User Story 1 ⚠️

- [ ] T006 [P] [US1] Unit test `test/unit/features/catalog/expense_repository_impl_test.dart` — `ExpenseResponse`→`Expense` mapping asserting `name` is sourced from `r.expense`; `list`(with `search`)/`get`/`create`/`update`/`delete`; error mapping to the shared types (mocktail-faked `ExpensesApi`)
- [ ] T007 [P] [US1] Unit test `test/unit/features/catalog/expenses_list_controller_test.dart` — search + pagination state, `AsyncValue` transitions
- [ ] T008 [P] [US1] Unit test `test/unit/features/catalog/expense_form_controller_test.dart` — required name, optional comment, update sends changed fields, create/update permission re-check before submit
- [ ] T009 [P] [US1] Widget test `test/widget/features/catalog/expenses_list_screen_test.dart` — columns (name, comment), search + pagination present, toolbar Create shown only with `create`, Edit row icon hidden (not disabled) without `update`, row-click opens read-only view (constitution §VI)
- [ ] T010 [P] [US1] Widget test `test/widget/features/catalog/expense_detail_screen_test.dart` — create vs view vs edit modes, AppBar carries only the read-only→edit toggle (constitution v1.8.0), body Save + error-styled body Delete, delete hidden without `delete`, server rejection on delete surfaced with the expense left in place

### Implementation for User Story 1

- [ ] T011 [P] [US1] Create the `Expense` freezed entity + `ExpenseListItem` in `lib/features/catalog/domain/entities/{expense,expense_list_item}.dart` per data-model.md §1 (`expenseId`, `name` ← `r.expense`, `comment?`) with `fromResponse`
- [ ] T012 [US1] Define `ExpenseRepository` in `lib/features/catalog/domain/repositories/expense_repository.dart` — `list`(search/skip/limit) / `get` / `create` / `update` / `delete` + `ExpenseListResult`
- [ ] T013 [US1] Implement `lib/features/catalog/data/expense_repository_impl.dart` wrapping `ExpensesApi` — build `ExpenseCreate`/`ExpenseUpdate` (create/update use `name`), forward `search`, map errors, expose `expenseRepositoryProvider`
- [ ] T014 [US1] Create `ExpensesListController` (`Notifier`) in `lib/features/catalog/presentation/expenses_list_controller.dart` — search + pagination driving `AsyncValue`, mirroring `LabelsListController`
- [ ] T015 [US1] Create `ExpenseFormController` (`Notifier`) in `lib/features/catalog/presentation/expense_form_controller.dart` — form state, required-name validation via T003, create/update/delete with permission re-checks and list invalidation, error codes localized in the screen (mirror `LabelFormController`)
- [ ] T016 [US1] Create `ExpensesListScreen` + `ExpenseDetailScreen` in `lib/features/catalog/presentation/{expenses_list_screen,expense_detail_screen}.dart` — shared `DataTableView`, `CatalogFilterBar`/`CatalogSearchBar`, `CatalogPagination`, toolbar `FilledButton.icon` Create, single Edit row action via the shared row-actions helper, row-click → read-only; detail uses `ResponsiveFormGrid`, create/view/edit modes, AppBar read-only→edit toggle only, body Save + error-styled body Delete with confirm dialog, errors via `ErrorBanner`. No filter drawer (search-only endpoint). Add expense-specific l10n keys to both `.arb` files
- [ ] T017 [US1] Wire routes + nav: add branch `/expenses`, plus `/expenses/new` and `/expenses/:expenseId` siblings, and the `expenses` `_routeGate` (read) in `lib/app/router/app_router.dart`; add the `expenses` `NavDestination` + `NavBranch.expenses` (index 11 — the **first** of the three new branches) to `lib/core/navigation/nav_destinations.dart` per contracts/routes.md. **Branch order MUST match between the two files; append at the next available position, do not reserve a later index.** Sequential with T029/T039 (same two files)

**Checkpoint**: Expenses catalog fully functional and independently testable (MVP).

---

## Phase 4: User Story 2 - Manage the Vehicles catalog (Priority: P1)

**Goal**: Full CRUD Vehicles catalog with a clearly displayed active/inactive status.

**Independent Test**: Open `/vehicles`, search, create a vehicle with a license plate and tonnage capacity, edit its nickname, toggle Active, delete one.

### Tests for User Story 2 ⚠️

- [ ] T018 [P] [US2] Unit test `test/unit/features/catalog/vehicle_repository_impl_test.dart` — `VehicleResponse`→`Vehicle` mapping; `list`(with `search`)/`get`/`create`/`update`/`delete`; `tonsCapacity` sent as `int`; error mapping (mocktail-faked `VehiclesApi`)
- [ ] T019 [P] [US2] Unit test `test/unit/features/catalog/vehicles_list_controller_test.dart` — search + pagination
- [ ] T020 [P] [US2] Unit test `test/unit/features/catalog/vehicle_form_controller_test.dart` — required license plate/name/nickname/tonsCapacity (integer ≥ 0), `active` defaults true on create, update sends changed fields, permission re-check
- [ ] T021 [P] [US2] Widget test `test/widget/features/catalog/vehicles_list_screen_test.dart` — columns (plate, name, nickname, active badge), search + pagination, Create/Edit gated by privilege, row-click read-only
- [ ] T022 [P] [US2] Widget test `test/widget/features/catalog/vehicle_detail_screen_test.dart` — create/view/edit, tonsCapacity numeric field, active switch, AppBar toggle only, body Delete gated, deletion rejection surfaced

### Implementation for User Story 2

- [ ] T023 [P] [US2] Create the `Vehicle` freezed entity + `VehicleListItem` in `lib/features/catalog/domain/entities/{vehicle,vehicle_list_item}.dart` per data-model.md §2 (`vehicleId`, `licensePlate`, `name`, `nickname`, `tonsCapacity` int, `active` bool) with `fromResponse`
- [ ] T024 [US2] Define `VehicleRepository` in `lib/features/catalog/domain/repositories/vehicle_repository.dart` — `list`(search/skip/limit) / `get` / `create` / `update` / `delete` + `VehicleListResult`
- [ ] T025 [US2] Implement `lib/features/catalog/data/vehicle_repository_impl.dart` wrapping `VehiclesApi` — build `VehicleCreate`/`VehicleUpdate`, forward `search`, map errors, expose `vehicleRepositoryProvider`
- [ ] T026 [US2] Create `VehiclesListController` + `VehicleFormController` in `lib/features/catalog/presentation/{vehicles_list_controller,vehicle_form_controller}.dart` — search + pagination; form validation via T003 (tonsCapacity integer), `active` switch defaulting true, create/update/delete with permission re-checks and list invalidation
- [ ] T027 [US2] Create `VehiclesListScreen` + `VehicleDetailScreen` in `lib/features/catalog/presentation/{vehicles_list_screen,vehicle_detail_screen}.dart` — same shared-widget pattern as Expenses (no filter drawer), active status badge in the list and an active switch in the form; add vehicle l10n keys
- [ ] T028 [US2] Wire routes + nav: `/vehicles`, `/vehicles/new`, `/vehicles/:vehicleId`, `_routeGate` (read, `SystemObject.vehicle`) in `app_router.dart`; `NavDestination` + `NavBranch.vehicles` (index 12 — next available after T017, using a fleet icon distinct from Suppliers' `local_shipping`) in `nav_destinations.dart` per contracts/routes.md. Sequential with T017/T039 (shared router/nav files)

**Checkpoint**: Vehicles catalog works independently.

---

## Phase 5: User Story 3 - Manage the Vehicle Operators catalog (Priority: P2)

**Goal**: Full CRUD Vehicle Operators catalog with a driver picker (reusing spec-012's employee lookup), issue/expiration date pickers, a server-computed "days until expiry" indicator, and a driver filter drawer.

**Independent Test**: Open `/vehicle-operators`, filter to a specific driver, create an operator by searching/selecting an employee and entering license details + dates, confirm driver-by-name and days-until-expiry render, edit the issuing location, delete one — assuming the spec-012 Employees catalog has shipped.

### Tests for User Story 3 ⚠️

- [ ] T029 [P] [US3] Unit test `test/unit/features/catalog/vehicle_operator_repository_impl_test.dart` — `VehicleOperatorResponse`→`VehicleOperator` mapping incl. `driver`(`EmployeeResponse`)→`driverId`/`driverName`, `Date`→`DateTime` for issue/expiration, and `daysUntilExpiry` passthrough; `list` with `search` + `employee`(driver) params; `get`/`create`/`update`/`delete`; `DateTime`→`Date` on write; **an unresolvable driver does not crash (fallback label)** and a **null `daysUntilExpiry` falls back to a client-derived value** (research.md §4, §7); error mapping
- [ ] T030 [P] [US3] Unit test `test/unit/features/catalog/vehicle_operators_list_controller_test.dart` — search + `driverId` filter state + pagination, and the driver-filter badge/active-count logic
- [ ] T031 [P] [US3] Unit test `test/unit/features/catalog/vehicle_operator_form_controller_test.dart` — required driver/licenseType/driverLicenseNumber/issueDate/expirationDate/issuingLocation, `expirationDate ≥ issueDate` soft rule (T003 `dateNotBefore`), `active` defaults true, create/update permission re-check
- [ ] T032 [P] [US3] Widget test `test/widget/features/catalog/vehicle_operators_list_screen_test.dart` — columns (driver name, license type/number, expiration + days-until-expiry, active), driver filter drawer behind a `Badge.count` `IconButton`, Create/Edit gated, row-click read-only, driver rendered by name (not raw id)
- [ ] T033 [P] [US3] Widget test `test/widget/features/catalog/vehicle_operator_detail_screen_test.dart` — driver `CatalogEntityPicker` (reusing `employeeRepositoryProvider`) searchable and showing the selected employee name, issue/expiration fields open `showDatePicker` and display the locale-formatted date, days-until-expiry shown, AppBar toggle only, body Delete gated

### Implementation for User Story 3

- [ ] T034 [P] [US3] Create the `VehicleOperator` detail entity + `VehicleOperatorListItem` in `lib/features/catalog/domain/entities/{vehicle_operator,vehicle_operator_list_item}.dart` per data-model.md §3 (`driverId`/`driverName`, dates as `DateTime`, `daysUntilExpiry` int?, `active`) with `fromResponse`; audit fields omitted
- [ ] T035 [US3] Define `VehicleOperatorRepository` in `lib/features/catalog/domain/repositories/vehicle_operator_repository.dart` — `list`(search/driverId/skip/limit) / `get` / `create` / `update` / `delete` + `VehicleOperatorListResult`
- [ ] T036 [US3] Implement `lib/features/catalog/data/vehicle_operator_repository_impl.dart` wrapping `VehicleOperatorsApi` — `Date`↔`DateTime` via `DateTimeToDate.toDate()`/`Date.toDateTime()`, map `driver` FK to id+name with a fallback label, pass `driverId` as the endpoint's `employee` param, forward `search`, build `VehicleOperatorCreate`/`VehicleOperatorUpdate`, map errors, expose `vehicleOperatorRepositoryProvider`
- [ ] T037 [US3] Implement `VehicleOperatorsListController` + `VehicleOperatorFilterController` (freezed filter with `driverId` + active-count) in `lib/features/catalog/presentation/vehicle_operators_list_controller.dart`, and `VehicleOperatorFormController` in `lib/features/catalog/presentation/vehicle_operator_form_controller.dart` — validation via T003 incl. date order, dates, driver selection, permission re-checks, list invalidation
- [ ] T038 [US3] Create `VehicleOperatorsListScreen` + `VehicleOperatorDetailScreen` in `lib/features/catalog/presentation/{vehicle_operators_list_screen,vehicle_operator_detail_screen}.dart` — list with a `CatalogFilterSheet` driver drawer (a single driver `CatalogEntityPicker<EmployeeListItem>` reusing `employeeRepositoryProvider`), a days-until-expiry indicator column (server value, client fallback), driver-by-name column with fallback; detail with `ResponsiveFormGrid`, the driver `CatalogEntityPicker` (mirroring the Customer form's salesperson field), `showDatePicker` issue/expiration fields, days-until-expiry display, AppBar toggle only, body Save/Delete. Add vehicle-operator l10n keys (incl. the "expires in N days"/"expired N days ago" strings)
- [ ] T039 [US3] Wire routes + nav: `/vehicle-operators`, `/vehicle-operators/new`, `/vehicle-operators/:vehicleOperatorId`, `_routeGate` (read, `SystemObject.vehicleOperators`) in `app_router.dart`; `NavDestination` + `NavBranch.vehicleOperators` (index 13 — next available after T028) in `nav_destinations.dart` per contracts/routes.md. Sequential with T017/T028 (shared router/nav files)

**Checkpoint**: All three catalogs independently functional; driver picker reuses spec 012 unchanged.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Cross-story validation and final gates.

- [ ] T040 [P] Integration test `test/integration/catalog_logistics_flow_test.dart` — the golden path: create an expense → create a vehicle → create a vehicle operator picking an existing employee as driver, then confirm the operator lists by driver name with a days-until-expiry indicator (quickstart.md golden path)
- [ ] T041 Run the full gate: `dart run build_runner build --delete-conflicting-outputs`, `flutter gen-l10n`, `flutter analyze` (clean), and the quickstart.md manual smoke + RBAC spot-check across the three catalogs
- [ ] T042 [P] Confirm no regression in the spec-012 employee picker / `employeeRepositoryProvider` after adding the driver picker consumer (SC-005) — re-run the spec-012 customer/employee widget tests

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately.
- **Foundational (Phase 2)**: Depends on Setup — BLOCKS all user stories (validators + shared l10n).
- **User Stories (Phase 3–5)**: All depend on Foundational.
  - US1 (Expenses) and US2 (Vehicles) are fully independent of each other and of US3.
  - US3 (Vehicle Operators) depends only on the **already-shipped** spec-012 `employeeRepositoryProvider` — no dependency on US1/US2 in this feature.
  - The **only** in-feature serialization is the shared router/nav files (`app_router.dart`, `nav_destinations.dart`): T017 → T028 → T039 must run in that order (branch index 11 → 12 → 13). Everything else across stories is parallelizable.
- **Polish (Phase 6)**: Depends on all three stories being complete.

### Within Each User Story

- Tests (marked [P]) are written first and MUST fail before implementation.
- Entity → repository interface → repository impl → controllers → screens → routes/nav.
- The routes/nav task is sequential across stories (shared files); everything else within a story after the entity is largely sequential on its own files.

### Parallel Opportunities

- All Phase 1/2 [P] tasks can run in parallel.
- Once Foundational completes, **US1, US2, and US3 can be built in parallel by different developers** — they touch disjoint files except the two shared router/nav files, which are edited in branch-index order (T017 → T028 → T039).
- All test tasks within a story marked [P] can run in parallel.

---

## Parallel Example: User Story 1

```bash
# Launch all US1 tests together (they fail first):
Task: "Unit test expense_repository_impl_test.dart"
Task: "Unit test expenses_list_controller_test.dart"
Task: "Unit test expense_form_controller_test.dart"
Task: "Widget test expenses_list_screen_test.dart"
Task: "Widget test expense_detail_screen_test.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 only)

1. Complete Phase 1: Setup.
2. Complete Phase 2: Foundational (validators + shared l10n).
3. Complete Phase 3: Expenses (US1).
4. **STOP and VALIDATE**: exercise `/expenses` end-to-end (create/view/edit/delete + search + RBAC).
5. Deploy/demo if ready — Expenses is a complete, shippable catalog.

### Incremental Delivery

1. Setup + Foundational → foundation ready.
2. Add US1 Expenses → test independently → demo (MVP).
3. Add US2 Vehicles → test independently → demo.
4. Add US3 Vehicle Operators → test independently → demo.
5. Polish (integration + gates).

### Parallel Team Strategy

With Foundational done: Developer A takes US1, B takes US2, C takes US3. They integrate independently; the only coordination point is the shared router/nav edit order (branch indices 11 → 12 → 13).

---

## Notes

- Search is server-side on all three endpoints (mbe-api #82/#83/#84 shipped and regenerated) — repositories forward `search` directly; no client-side filter seam is needed (research.md §8).
- No `lib/core/domain/` additions and no money/`AnyOf` path in this feature (research.md §9) — unlike spec 012.
- [P] tasks = different files, no dependencies. [Story] label maps each task to its user story.
- Verify tests fail before implementing; commit after each task or logical group.
- Stop at any checkpoint to validate a story independently.
