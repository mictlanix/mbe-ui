---
description: "Task list for Catalog Master Entities (Customers, Employees, Suppliers, Labels, Taxpayer Recipients)"
---

# Tasks: Catalog Master Entities (Customers, Employees, Suppliers, Labels, Taxpayer Recipients)

**Input**: Design documents from `/specs/012-catalog-master-entities/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/mbe-api-catalogs.md, contracts/routes.md, quickstart.md

**Tests**: Included — the constitution's "Development Workflow & Quality Gates" mandates unit tests for repositories, widget tests for critical screens, and an integration test for the golden path; specs/011-product-pricing set this precedent for the same kind of catalog work.

**Organization**: Tasks are grouped by user story. Story order follows the spec's priorities: US1 Suppliers (P1), US2 Labels (P1), US3 Employees (P1), US4 Customers (P2), US5 Taxpayer Recipients (P3). US4 is the only story with a cross-story dependency (it needs US3's employee repository for the salesperson picker).

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: US1–US5, mapping to the spec's user stories
- Every task includes an exact file path

## Path Conventions

Single Flutter project, feature-first. All work lands inside the existing `lib/features/catalog/` module (plan.md Structure Decision), plus `lib/core/domain/`, `lib/core/navigation/`, `lib/app/router/`, and `lib/l10n/`. Tests live under `test/unit/features/catalog/`, `test/widget/features/catalog/`, and `test/integration/`.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Confirm preconditions; no new module is created (the `catalog` module already exists).

- [ ] T001 Confirm the generated clients are present and untouched: `lib/generated/openapi/lib/src/api/{customers_api,employees_api,taxpayer_recipients_api,suppliers_api,labels_api}.dart` and the `{Customer,Employee,TaxpayerRecipient,Supplier,Label}{Response,Create,Update}`, `CustomerListItem`, `CreditLimit`/`CreditLimit1`, and `ListResponse*` models (contracts/mbe-api-catalogs.md). Do NOT regenerate; if anything is missing, stop and re-open the no-codegen decision in research.md §2
- [ ] T002 [P] Confirm/create the test directories `test/unit/features/catalog/`, `test/widget/features/catalog/`, and `test/integration/` (they already hold product/pricing tests — no new module dirs needed)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Shared pieces used by more than one story. Must complete before the stories that consume them.

**⚠️ CRITICAL**: T003 is consumed by US1 (Suppliers) and US4 (Customers); T005 seeds the shared `.arb` files every story appends to.

- [ ] T003 [P] Create shared field validators for these catalogs in `lib/features/catalog/domain/catalog_field_validators.dart`: required-non-empty (code/name/nickname/email), optional-non-negative-decimal (`creditLimit`), optional-non-negative-integer (`creditDays`/`enrollNumber`). Operate on `String`; money is NOT parsed to `double` (plan.md Constraints). Reused by Suppliers (US1), Customers (US4), and Employees (US3)
- [ ] T004 [P] Add a credit-limit/money display helper to `lib/features/catalog/presentation/catalog_formatters.dart` using `intl` MXN/`es-MX` (constitution §V) plus a `es-MX` `DateFormat` helper for employee dates — no manual string formatting. (If a suitable formatter already exists in `core/`, reuse it and skip creating a new file, noting so in the task)
- [ ] T005 Seed shared l10n keys in `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb`: the five nav titles (`customersMenuTitle`, `employeesMenuTitle`, `suppliersMenuTitle`, `labelsMenuTitle`, `taxpayerRecipientsMenuTitle`), the shared column/field labels reused across entities (code, name, zone, comment, credit limit, credit days, status/active), and the shared `editRecordTooltip`/delete-confirm/cancel strings if not already present. Per-entity keys are added inside each story. Run `flutter gen-l10n` after editing
- [ ] T005a [P] Unit test `test/unit/features/catalog/catalog_field_validators_test.dart` for T003 — empty vs non-empty, negative/zero/decimal credit limit, non-integer credit days, and that a high-precision credit-limit string is neither rejected nor truncated

**Checkpoint**: Shared validators, formatters, and nav/shared l10n keys ready.

---

## Phase 3: User Story 1 - Manage the Suppliers catalog (Priority: P1) 🎯 MVP

**Goal**: Full CRUD Suppliers catalog (list + detail), promoting the existing read-only supplier lookup to a managed catalog without changing the product form's supplier picker.

**Independent Test**: Open `/suppliers`, search, create a supplier with a credit limit, edit it, delete it — with the product form's supplier picker still working unchanged.

### Tests for User Story 1 ⚠️

- [ ] T006 [P] [US1] Unit test `test/unit/features/catalog/supplier_repository_impl_test.dart` — `SupplierResponse`→`Supplier` mapping; `list`/`get`/`create`/`update`/`delete`; **a round-trip asserting the `creditLimit` `AnyOf` write path serializes as a JSON decimal *string* (e.g. `"1000.50"`), not `num`/`null`/`{}`, for BOTH the create (`CreditLimit`) and update (`CreditLimit1`) wrappers** (contracts/mbe-api-catalogs.md §7, plan.md Risks); error mapping to the shared types (mocktail-faked `SuppliersApi`)
- [ ] T007 [P] [US1] Unit test `test/unit/features/catalog/suppliers_list_controller_test.dart` — search + pagination state, `AsyncValue` transitions
- [ ] T008 [P] [US1] Unit test `test/unit/features/catalog/supplier_form_controller_test.dart` — required code/name, optional non-negative credit limit, update sends changed fields, create/update permission re-check before submit
- [ ] T009 [P] [US1] Widget test `test/widget/features/catalog/suppliers_list_screen_test.dart` — columns, search + pagination present, toolbar Create shown only with `create`, Edit row icon hidden (not disabled) without `update`, row-click opens read-only view (constitution §VI)
- [ ] T010 [P] [US1] Widget test `test/widget/features/catalog/supplier_detail_screen_test.dart` — create vs view vs edit modes, AppBar carries only the read-only→edit toggle (constitution v1.8.0), body Save + error-styled body Delete, delete hidden without `delete`, server rejection on delete surfaced with the supplier left in place

### Implementation for User Story 1

- [ ] T011 [P] [US1] Create the `Supplier` freezed entity in `lib/features/catalog/domain/entities/supplier.dart` per data-model.md §1 (`supplierId`, `code`, `name`, `zone?`, `creditLimit` String, `creditDays`, `comment?`) with `fromResponse`. Leave the existing `SupplierListItem` untouched
- [ ] T012 [US1] Extend `lib/features/catalog/domain/repositories/supplier_repository.dart` — add `get`/`create`/`update`/`delete` to the interface, keeping `list` as-is
- [ ] T013 [US1] Extend `lib/features/catalog/data/supplier_repository_impl.dart` — implement `get`/`create`/`update`/`delete` wrapping `SuppliersApi`, building `SupplierCreate.creditLimit` via `AnyOf2<String, num>(values: {0: value})` on the `CreditLimit` builder and `SupplierUpdate.creditLimit` via the distinct `CreditLimit1` builder (contracts/mbe-api-catalogs.md §7, research.md §4); keep `list` and the existing provider untouched
- [ ] T014 [US1] Create `SuppliersListController` (`Notifier`) in `lib/features/catalog/presentation/suppliers_list_controller.dart` — search + pagination driving `AsyncValue<CatalogPage<Supplier>>`, mirroring `PriceListsListController`
- [ ] T015 [US1] Create `SupplierFormController` (`Notifier`) in `lib/features/catalog/presentation/supplier_form_controller.dart` — form state, validation via T003, create/update/delete with permission re-checks and `SuppliersListController` invalidation, error codes localized in the screen (mirror `PriceListFormController`)
- [ ] T016 [US1] Create `SuppliersListScreen` in `lib/features/catalog/presentation/suppliers_list_screen.dart` — shared `DataTableView`, `CatalogFilterBar`/`CatalogSearchBar`, `CatalogPagination`, toolbar `FilledButton.icon` Create, single Edit row action via `buildCatalogRowActions`, row-click → `?view=true`. No filter drawer (search-only endpoint, plan.md §VI note). Add supplier-specific l10n keys to both `.arb` files
- [ ] T017 [US1] Create `SupplierDetailScreen` in `lib/features/catalog/presentation/supplier_detail_screen.dart` — `ResponsiveFormGrid`, create/view/edit modes with `?view=true`, AppBar read-only→edit toggle only, body Save + error-styled body Delete with confirm dialog, errors via `ErrorBanner`. Add supplier form l10n keys
- [ ] T018 [US1] Wire routes + nav: add branch `/suppliers`, plus `/suppliers/new` and `/suppliers/:supplierId` siblings, and the `suppliers` `_routeGate` (read) in `lib/app/router/app_router.dart`; add the `suppliers` `NavDestination` + `NavBranch.suppliers` (index 6 — the **first** of the five new branches, since Suppliers is built first) to `lib/core/navigation/nav_destinations.dart` per contracts/routes.md. **Branch order MUST match between the two files; append at the next available position, do not reserve a later index.** Sequential with T029/T041/T053/T064 (same two files)

**Checkpoint**: Suppliers catalog fully functional and independently testable.

---

## Phase 4: User Story 2 - Manage the Labels catalog (Priority: P1)

**Goal**: Full CRUD Labels catalog, keeping the product form's label picker and the products-list label filter working, and refreshing them after any mutation.

**Independent Test**: Open `/labels`, create a label, confirm it appears in the product form's label picker; rename it; delete an unused one.

### Tests for User Story 2 ⚠️

- [ ] T019 [P] [US2] Unit test `test/unit/features/catalog/label_repository_impl_test.dart` — `LabelResponse`→`Label` mapping; `get`/`create`/`update`/`delete`; **asserts `allLabelsProvider` is invalidated after each mutation** (FR-014); error mapping (mocktail-faked `LabelsApi`)
- [ ] T020 [P] [US2] Unit test `test/unit/features/catalog/labels_list_controller_test.dart` — search + pagination
- [ ] T021 [P] [US2] Unit test `test/unit/features/catalog/label_form_controller_test.dart` — required name, create/update/delete with permission re-check
- [ ] T022 [P] [US2] Widget test `test/widget/features/catalog/labels_list_screen_test.dart` — columns, search, pagination, Create/Edit gated by privilege, row-click read-only
- [ ] T023 [P] [US2] Widget test `test/widget/features/catalog/label_detail_screen_test.dart` — create/view/edit, AppBar toggle only, body Delete hidden without `delete`, deletion-while-assigned rejection surfaced

### Implementation for User Story 2

- [ ] T024 [P] [US2] Create the `Label` freezed detail entity in `lib/features/catalog/domain/entities/label.dart` per data-model.md §2 (`labelId`, `name`, `comment?`) with `fromResponse`. Leave the existing `LabelItem` (picker/filter type) untouched
- [ ] T025 [US2] Extend `lib/features/catalog/domain/repositories/label_repository.dart` — add `get`/`create`/`update`/`delete`, keeping `list`
- [ ] T026 [US2] Extend `lib/features/catalog/data/label_repository_impl.dart` — implement `get`/`create`/`update`/`delete` wrapping `LabelsApi`; **invalidate `allLabelsProvider` after each mutation** so the product form/filter refresh (FR-014). Keep `list` and `allLabelsProvider` definitions intact
- [ ] T027 [US2] Create `LabelsListController` (`Notifier`) in `lib/features/catalog/presentation/labels_list_controller.dart` — search + pagination
- [ ] T028 [US2] Create `LabelFormController` (`Notifier`) in `lib/features/catalog/presentation/label_form_controller.dart` — form state, required-name validation, create/update/delete with permission re-checks and list invalidation
- [ ] T029 [US2] Create `LabelsListScreen` + `LabelDetailScreen` in `lib/features/catalog/presentation/{labels_list_screen,label_detail_screen}.dart` — same shared-widget pattern as Suppliers (no filter drawer), add label l10n keys, and wire routes/nav (`/labels`, `/labels/new`, `/labels/:labelId`, `_routeGate` read, `NavDestination` + `NavBranch.labels` index 7 — the next available position after T018) in `app_router.dart`/`nav_destinations.dart`. Sequential with T018/T041/T053/T064 (shared router/nav files)

**Checkpoint**: Labels catalog works; product form/filter still reflect label changes.

---

## Phase 5: User Story 3 - Manage the Employees catalog (Priority: P1)

**Goal**: Full CRUD Employees catalog with an active/sales-person filter drawer, date pickers, and a gender dropdown — and an `EmployeeListItem` picker type US4 will consume.

**Independent Test**: Open `/employees`, filter to active sales-people, create an employee (dates via picker, gender via dropdown), edit, delete.

### Tests for User Story 3 ⚠️

- [ ] T030 [P] [US3] Unit test `test/unit/core/domain/gender_test.dart` — `Gender.fromValue(0/1)` → female/male, and `null` for an unknown code
- [ ] T031 [P] [US3] Unit test `test/unit/features/catalog/employee_repository_impl_test.dart` — `EmployeeResponse`→`Employee` mapping incl. `Date`→`DateTime` and `int`→`Gender`; `list` with `active`/`salesPerson` params; `get`/`create`/`update`/`delete`; `DateTime`→`Date` (y/m/d) on write; an **unknown gender code does not crash** (fallback per research.md §6); error mapping
- [ ] T032 [P] [US3] Unit test `test/unit/features/catalog/employees_list_controller_test.dart` — search + `active`/`salesPerson` filter state + pagination, and `activeFilterCount` badge logic
- [ ] T033 [P] [US3] Unit test `test/unit/features/catalog/employee_form_controller_test.dart` — required first/last/nickname/gender/birthday/startJobDate, optional non-negative enroll number, create/update permission re-check
- [ ] T034 [P] [US3] Widget test `test/widget/features/catalog/employees_list_screen_test.dart` — columns, filter drawer opens with active + salesPerson tri-state chips behind a `Badge.count` `IconButton.outlined`, Create/Edit gated, row-click read-only
- [ ] T035 [P] [US3] Widget test `test/widget/features/catalog/employee_detail_screen_test.dart` — gender `DropdownButtonFormField`, birthday/startJobDate fields open `showDatePicker` and display the locale-formatted date (research.md §8), AppBar toggle only, body Delete gated

### Implementation for User Story 3

- [ ] T036 [P] [US3] Create the `Gender` enum in `lib/core/domain/gender.dart` — `female(0)`, `male(1)` with `final int value` and `static Gender? fromValue(int)`, mirroring `lib/core/domain/currency.dart` / `system_object.dart` and legacy `mbe/docs/constants.md §GenderEnum` (data-model.md §7, research.md §6). Add `genderFemaleLabel`/`genderMaleLabel` l10n keys
- [ ] T037 [P] [US3] Create the `Employee` detail entity and `EmployeeListItem` picker/list entity in `lib/features/catalog/domain/entities/{employee,employee_list_item}.dart` per data-model.md §3 (dates as `DateTime`, gender as `Gender`; `EmployeeListItem` = id + fullName + nickname + active + salesPerson) with `fromResponse`. Do NOT map `EmployeeResponse.disabled` — it's deliberately excluded (data-model.md §3 note, U1)
- [ ] T038 [US3] Define `EmployeeRepository` in `lib/features/catalog/domain/repositories/employee_repository.dart` — `list`(search/active/salesPerson/skip/limit) / `get` / `create` / `update` / `delete`
- [ ] T039 [US3] Implement `lib/features/catalog/data/employee_repository_impl.dart` wrapping `EmployeesApi` — `Date`↔`DateTime` conversion, `Gender`↔`int`, build `EmployeeCreate`/`EmployeeUpdate` (never setting `EmployeeUpdate.disabled` — U1), map errors, expose provider
- [ ] T040 [US3] Implement `EmployeesListController` + `EmployeeFilterController` (freezed filter with `active`/`salesPerson` + `activeFilterCount` extension) in `lib/features/catalog/presentation/employees_list_controller.dart`, and `EmployeeFormController` in `lib/features/catalog/presentation/employee_form_controller.dart` (validation via T003, dates, gender, permission re-checks, list invalidation)
- [ ] T041 [US3] Create `EmployeesListScreen` + `EmployeeDetailScreen` in `lib/features/catalog/presentation/{employees_list_screen,employee_detail_screen}.dart` — list with a `CatalogFilterSheet` drawer (active + salesPerson tri-state `FilterChip`s, modeled on `_ProductFiltersPanel`); detail with `ResponsiveFormGrid`, gender dropdown, `showDatePicker` date fields, AppBar toggle only, body Save/Delete. Add employee l10n keys and wire routes/nav (`/employees`, `/employees/new`, `/employees/:employeeId`, `_routeGate` read, `NavDestination` + `NavBranch.employees` index 8 — the next available position after T029). Sequential with T018/T029/T053/T064 (shared router/nav files)

**Checkpoint**: Employees catalog works; `EmployeeListItem` + `EmployeeRepository.list()` are ready for US4's salesperson picker.

---

## Phase 6: User Story 4 - Manage the Customers catalog (Priority: P2)

**Goal**: Full CRUD Customers catalog with a disabled/price-list/salesperson filter drawer, FK fields shown by name, a required price-list picker, and an optional salesperson picker.

**⚠️ Depends on US3** (Employees) for the salesperson picker and on the existing `PriceListRepository` for the price-list picker.

**Independent Test** (with US3 shipped): Open `/customers`, filter by active + a price list + a salesperson, create a customer picking a price list and an employee salesperson, confirm both render by name, create one with no salesperson (fallback), delete.

### Tests for User Story 4 ⚠️

- [ ] T042 [P] [US4] Unit test `test/unit/features/catalog/customer_repository_impl_test.dart` — `CustomerResponse`/`CustomerListItem`→domain mapping with **expanded `priceList`/`salesperson` FKs → display names** (research.md §7); `creditLimit` `AnyOf` round-trip (create `CreditLimit` + update `CreditLimit1`, JSON decimal string); `list` with `disabled`/`priceList`/`salesperson` params; write path sends FKs as **plain ids**; error mapping
- [ ] T043 [P] [US4] Unit test `test/unit/features/catalog/customers_list_controller_test.dart` — search + disabled/priceList/salesperson filter state + pagination + `activeFilterCount`
- [ ] T044 [P] [US4] Unit test `test/unit/features/catalog/customer_form_controller_test.dart` — required code/name/priceList (priceList required — FR-019), optional salesperson, credit-limit validation, permission re-check
- [ ] T045 [P] [US4] Widget test `test/widget/features/catalog/customers_list_screen_test.dart` — columns show salesperson **by name** and a "none assigned" fallback; filter drawer with disabled tri-state + price-list + salesperson `CatalogEntityPicker` filters; Create/Edit gated; row-click read-only
- [ ] T046 [P] [US4] Widget test `test/widget/features/catalog/customer_detail_screen_test.dart` — price-list picker (required) + salesperson picker (optional) render selected names; unresolved/absent FK shows fallback, not a crash; AppBar toggle only; body Delete gated; server rejection on delete surfaced

### Implementation for User Story 4

- [ ] T047 [P] [US4] Create `Customer` + `CustomerListItem` entities (and the small `PriceListRef`/`EmployeeRef` value objects) in `lib/features/catalog/domain/entities/{customer,customer_list_item}.dart` per data-model.md §4 — map expanded FK objects to `{id, name}`, `creditLimit` as String
- [ ] T048 [US4] Define `CustomerRepository` in `lib/features/catalog/domain/repositories/customer_repository.dart` — `list`(search/disabled/priceList/salesperson/skip/limit) / `get` / `create` / `update` / `delete`
- [ ] T049 [US4] Implement `lib/features/catalog/data/customer_repository_impl.dart` wrapping `CustomersApi` — `creditLimit` via `CreditLimit`/`CreditLimit1` AnyOf, FKs sent as plain ids (`priceList`/`salesperson`), FKs read from the expanded response, errors mapped, provider exposed
- [ ] T050 [US4] Implement `CustomersListController` + `CustomerFilterController` in `lib/features/catalog/presentation/customers_list_controller.dart`, and `CustomerFormController` in `lib/features/catalog/presentation/customer_form_controller.dart` (required price-list, optional salesperson, credit-limit validation, permission re-checks, list invalidation)
- [ ] T051 [US4] Create `CustomersListScreen` in `lib/features/catalog/presentation/customers_list_screen.dart` — shared table (salesperson/price-list by name, "none assigned" fallback), `CatalogFilterSheet` drawer with a disabled tri-state chip + a price-list `CatalogEntityPicker` (backed by the existing `PriceListRepository.list()`) + a salesperson `CatalogEntityPicker` (backed by US3's `EmployeeRepository.list()`), toolbar Create, single Edit row action. Add customer l10n keys
- [ ] T052 [US4] Create `CustomerDetailScreen` in `lib/features/catalog/presentation/customer_detail_screen.dart` — `ResponsiveFormGrid`; a required price-list `CatalogEntityPicker` and an optional salesperson `CatalogEntityPicker` (same repos as T051), credit-limit/credit-days/zone/shipping fields, AppBar toggle only, body Save + error-styled Delete. Add customer form l10n keys
- [ ] T053 [US4] Wire routes + nav: `/customers` branch, `/customers/new`, `/customers/:customerId`, `_routeGate` (customers, read), `NavDestination` + `NavBranch.customers` index 9 — the next available position after T041, per contracts/routes.md. Sequential with T018/T029/T041/T064 (shared router/nav files)

**Checkpoint**: Customers catalog works end-to-end, resolving FK names via US3 + existing pricing.

---

## Phase 7: User Story 5 - Manage the Taxpayer Recipients catalog (Priority: P3)

**Goal**: Full CRUD Taxpayer Recipients catalog with a client-supplied immutable String id, and postal-code/tax-regime pickers backed by two new SAT lookup methods.

**Independent Test**: Open `/taxpayer-recipients`, create one by typing a tax id and picking a postal code + tax regime, confirm they show by description, confirm the id is not editable on edit, confirm a duplicate-id create is rejected clearly.

### Tests for User Story 5 ⚠️

- [ ] T054 [P] [US5] Unit test `test/unit/features/catalog/sat_catalog_repository_impl_test.dart` — the two new methods `listPostalCodes`/`listTaxRegimes` map `SatCatalogResponse`→`SatCatalogItem` and pass `search`/`skip`/`limit` (mocktail-faked `SatCatalogsApi`); existing methods unaffected
- [ ] T055 [P] [US5] Unit test `test/unit/features/catalog/taxpayer_recipient_repository_impl_test.dart` — `TaxpayerRecipientResponse`→domain mapping with **expanded `postalCode`/`regime` FKs → descriptions** and a **fallback for an unresolved code** (data-model.md §5); create sends the client-supplied String `taxpayerRecipientId`; update omits it (immutable); a **duplicate-id create rejection surfaces via the shared error type** (FR-027); error mapping
- [ ] T056 [P] [US5] Unit test `test/unit/features/catalog/taxpayer_recipients_list_controller_test.dart` + `.../taxpayer_recipient_form_controller_test.dart` — search + pagination; required id/name/email on create, id NOT editable on update, permission re-checks
- [ ] T057 [P] [US5] Widget test `test/widget/features/catalog/taxpayer_recipients_list_screen_test.dart` + `.../taxpayer_recipient_detail_screen_test.dart` — list columns + search; detail shows an editable id field in **create** mode and a read-only id in **edit** mode (mirroring the Users admin `user_id_field` pattern), postal-code/regime `CatalogEntityPicker`s, FK-by-description with fallback, AppBar toggle only, body Delete gated, duplicate-id rejection surfaced

### Implementation for User Story 5

- [ ] T058 [US5] Extend `lib/features/catalog/domain/repositories/sat_catalog_repository.dart` and `lib/features/catalog/data/sat_catalog_repository_impl.dart` — add `listPostalCodes` and `listTaxRegimes` mirroring `listUnitsOfMeasurement`/`listProductServices` exactly (research.md §5, contracts §6)
- [ ] T059 [P] [US5] Create `TaxpayerRecipient` + `TaxpayerRecipientListItem` entities (and the `SatRef` value object) in `lib/features/catalog/domain/entities/{taxpayer_recipient,taxpayer_recipient_list_item}.dart` per data-model.md §5 — String PK, FK descriptions with fallback
- [ ] T060 [US5] Define `TaxpayerRecipientRepository` in `lib/features/catalog/domain/repositories/taxpayer_recipient_repository.dart` — `list`(search/skip/limit) / `get`(String id) / `create` / `update` / `delete`(String id)
- [ ] T061 [US5] Implement `lib/features/catalog/data/taxpayer_recipient_repository_impl.dart` wrapping `TaxpayerRecipientsApi` — send client-supplied `taxpayerRecipientId` on create, omit on update, send postalCode/regime as plain code Strings, read expanded FKs, map errors, expose provider
- [ ] T062 [US5] Implement `TaxpayerRecipientsListController` + `TaxpayerRecipientFormController` in `lib/features/catalog/presentation/{taxpayer_recipients_list_controller,taxpayer_recipient_form_controller}.dart` — search + pagination; form state where the id is required-and-editable on create and immutable on edit (research.md §9)
- [ ] T063 [US5] Create `TaxpayerRecipientsListScreen` + `TaxpayerRecipientDetailScreen` in `lib/features/catalog/presentation/{taxpayer_recipients_list_screen,taxpayer_recipient_detail_screen}.dart` — list (no filter drawer, search-only); detail with a create-only editable id field (`if (!_isEdit)`, mirroring `user_detail_screen.dart`), postal-code/regime `CatalogEntityPicker`s (T058 methods), FK-by-description, AppBar toggle only, body Save/Delete. Add taxpayer l10n keys
- [ ] T064 [US5] Wire routes + nav: `/taxpayer-recipients` branch, `/taxpayer-recipients/new`, and `/taxpayer-recipients/:taxpayerRecipientId` passing the id through as a **String** (no `int.parse`), `_routeGate` (taxpayerRecipients, read), `NavDestination` + `NavBranch.taxpayerRecipients` index 10, per contracts/routes.md. Sequential with T018/T029/T041/T053 (shared router/nav files)

**Checkpoint**: All five catalogs independently functional.

---

## Phase 8: Polish & Cross-Cutting Concerns

- [ ] T065 Write the integration test `test/integration/catalog_master_flow_test.dart` — golden path against a live mbe-api: create an employee → create a customer selecting that employee as salesperson and a price list → create a taxpayer recipient with a postal code + tax regime (quickstart.md golden path; constitution Quality Gates)
- [ ] T066 **Regression guard (SC-005)**: add/extend widget tests asserting the product form's supplier picker, unit-of-measurement/SAT-key pickers, label multi-picker, and the products-list label filter all still work after Suppliers/Labels were promoted to full CRUD (quickstart.md "Regression guard")
- [ ] T067 Verify the RBAC matrix (quickstart.md "RBAC checks", FR-007, constitution §VI): a user lacking read on a catalog sees no nav entry and is redirected from its direct URL; a user with read but not update/delete sees no Edit row icon and no Save/Delete on detail, while the read-only view still renders every field (including FK names)
- [ ] T068 Run `dart run build_runner build --delete-conflicting-outputs`, `flutter gen-l10n`, `flutter analyze`, and `dart format` — zero new analyzer findings; confirm **no file under `lib/generated/openapi/` was modified** (constitution §III)
- [ ] T069 Run the full quickstart.md validation against a live mbe-api, including the credit-limit wire-format check (`"creditLimit": "1000.50"` arrives as a JSON string) and the duplicate taxpayer-id rejection (FR-027)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: no dependencies.
- **Foundational (Phase 2)**: after Setup. T003 blocks US1/US3/US4 form controllers; T005 seeds the `.arb` files.
- **User Stories (Phases 3–7)**: after Foundational. US1, US2, US3 are mutually independent. **US4 depends on US3** (employee repository/list-item for the salesperson picker) and on the existing `PriceListRepository`. US5 is independent (its SAT extension is self-contained in T058).
- **Polish (Phase 8)**: after all stories being shipped are complete.

### Cross-story shared files (NOT parallelizable across stories)

- `lib/app/router/app_router.dart` and `lib/core/navigation/nav_destinations.dart` — edited by T018, T029, T041, T053, T064, **in that order**. Branch index is positional (`StatefulShellRoute.indexedStack`'s `branches:` list — a branch's index is its position when added, not an arbitrary label), so each task appends its branch at the *next available* position rather than a pre-reserved index: suppliers 6 (T018), labels 7 (T029), employees 8 (T041), customers 9 (T053), taxpayer-recipients 10 (T064) — matching the build order, corrected 2026-07-19 per `/speckit-analyze` finding I1 (the original index assignment used an unrelated order that didn't match this build sequence, which would have been unbuildable as a positional list).
- `lib/l10n/app_en.arb` / `app_es.arb` — seeded in T005, then appended per story. Serialize the edits (append-only) and re-run `flutter gen-l10n`.
- `lib/features/catalog/data/{supplier,label}_repository_impl.dart` and their interfaces are **extended**, not created — coordinate with any concurrent product-form work (none in this feature).

### Within Each User Story

- Tests (write first, confirm they fail) → entities → repository interface → repository impl → controllers → screens → routing/nav.
- Entities and tests marked [P] are independent; the repo impl depends on the entity + interface; controllers on the repo; screens on the controllers.

### Parallel Opportunities

- All Setup [P] and Foundational [P] tasks can run together.
- US1, US2, US3, US5 can be developed in parallel by different people once Foundational is done; US4 waits on US3.
- Within a story, all `[P]` test tasks and all `[P]` entity tasks can run together.

---

## Parallel Example: User Story 1 (Suppliers)

```bash
# Tests first (write, confirm they fail):
Task: "Unit test supplier_repository_impl_test.dart (incl. creditLimit AnyOf round-trip)"
Task: "Unit test suppliers_list_controller_test.dart"
Task: "Unit test supplier_form_controller_test.dart"
Task: "Widget test suppliers_list_screen_test.dart"
Task: "Widget test supplier_detail_screen_test.dart"

# Then the entity (parallel with any other story's entity):
Task: "Create Supplier freezed entity in lib/features/catalog/domain/entities/supplier.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 — Suppliers)

1. Setup (Phase 1) → Foundational (Phase 2).
2. US1 Suppliers (Phase 3) — the smallest full-CRUD slice that also exercises the `creditLimit` `AnyOf` write path (the feature's main construction risk).
3. **STOP and VALIDATE**: `/suppliers` CRUD works, product-form supplier picker unregressed.

### Incremental Delivery

1. Foundation → US1 Suppliers (MVP, proves AnyOf + shared list/detail scaffolding).
2. US2 Labels (proves the picker/filter invalidation path) → US3 Employees (adds filter drawer + dates + Gender).
3. US4 Customers (builds on US3's employee picker + existing price-list picker).
4. US5 Taxpayer Recipients (String PK + SAT picker extension).
5. Polish: integration test, regression guard, RBAC matrix, analyze/format, quickstart.

### Risk-first note

US1 front-loads the `creditLimit` `AnyOf` write path — the same wrapper family that cost specs/011 a `RangeError`. Its mandatory round-trip test (T006) must pass before any customer/supplier UI is trusted; US4 reuses the identical construction, so once US1's test is green the risk is retired for both.

---

## Notes

- [P] = different files, no dependency on an incomplete task.
- Every entity mapping (`fromResponse`) keeps money as `String` and never edits generated files (constitution §III).
- Each story is independently completable and testable; only US4 depends on another story (US3).
- Commit after each task or logical group; validate at each checkpoint.
- The `AppBar.actions` on all ten detail screens carry **only** the read-only→edit toggle (constitution v1.8.0) — this feature is the reference implementation of that amendment.
