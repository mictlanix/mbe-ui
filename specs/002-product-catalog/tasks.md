---

description: "Task list for Product Catalog (Products CRUD)"

---

# Tasks: Product Catalog (Products CRUD)

**Input**: Design documents from `/specs/002-product-catalog/`

**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/](./contracts/), [quickstart.md](./quickstart.md)

**Tests**: Included per constitution §"Development Workflow & Quality Gates"
(unit/widget/integration tests are a quality gate, not optional, for this
project). Write each story's tests first; confirm they fail before
implementing.

**Organization**: Tasks are grouped by user story (spec.md priorities P1/P2)
to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no unmet dependencies)
- **[Story]**: Maps the task to US1 (Browse and find products), US2 (Create a
  new product), US3 (Edit an existing product), or US4 (Deactivate a product)
- File paths are relative to the repository root

## Path Conventions

Single Flutter project per plan.md "Project Structure": `lib/`, `test/` at
repository root. This feature adds `lib/features/catalog/` and edits the
existing `lib/app/router/app_router.dart` from the auth feature — no new
top-level directories.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Confirm the generated API client is current before building
against it. No new dependency or tooling decision is needed (plan.md
"Technical Context" — all required packages already exist from the auth
feature).

- [X] T001 Run `./tool/generate_api_client.sh http://127.0.0.1:8000/openapi.json`
  against a local mbe-api instance and confirm `lib/generated/openapi/`
  already contains `ProductsApi`, `ProductCreate`, `ProductUpdate`,
  `ProductResponse`, `ProductListItem`, `ProductPriceResponse` (research.md
  §3); commit any diff if the spec has drifted since the last codegen run.

**Checkpoint**: `lib/generated/openapi/` is confirmed current for the
`products` paths.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Domain entities and the read side of the repository that ALL
four user stories depend on (every story either lists or loads a product).
No user-story screen can be meaningfully implemented before this phase.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [X] T002 [P] Create `Product` freezed entity (all fields per data-model.md
  "Product", incl. `prices: List<ProductPrice>`) mapping
  `ProductResponse`/`ProductCreate`/`ProductUpdate` in
  `lib/features/catalog/domain/entities/product.dart`.
- [X] T003 [P] Create `ProductPrice` freezed entity mapping
  `ProductPriceResponse` (read-only) in
  `lib/features/catalog/domain/entities/product_price.dart` (data-model.md
  "ProductPrice").
- [X] T004 [P] Create `ProductListItem` freezed entity mapping the API's
  `ProductListItem` projection in
  `lib/features/catalog/domain/entities/product_list_item.dart`
  (data-model.md "ProductListItem").
- [X] T005 Define the `ProductRepository` interface (`list`, `get`) in
  `lib/features/catalog/domain/repositories/product_repository.dart` per
  contracts/mbe-api-products.md `GET /products`, `GET /products/{id}`
  (depends on T002, T004).
- [X] T006 Implement `ProductRepositoryImpl.list`/`.get` in
  `lib/features/catalog/data/product_repository_impl.dart` using the
  generated `ProductsApi` client, mapping DTOs to `Product`/`ProductListItem`
  and errors to the existing shared `AppError` types
  (`lib/core/errors/app_error.dart`) (depends on T001, T002, T003, T004,
  T005).

**Checkpoint**: `ProductRepository.list`/`.get` work end-to-end against a
real mbe-api instance; no screens yet — user-story implementation can now
begin.

---

## Phase 3: User Story 1 - Browse and find products (Priority: P1) 🎯 MVP

**Goal**: Any user with `products` Read privilege can search/filter the
catalog by code/name/brand/model and by active/disabled/stockable/salable/
purchasable; a user without that privilege cannot reach the catalog at all
(FR-001, FR-002, FR-012, FR-013).

**Independent Test**: quickstart.md "Story 1" — exact code search, partial
name search, active-only filter, deny-by-default for a no-privilege account.

### Tests for User Story 1

- [X] T007 [P] [US1] `ProductRepositoryImpl.list`/`.get` tests covering
  `200`, `404`, `422`, network-error → `AppError` mapping in
  `test/unit/features/catalog/product_repository_impl_test.dart` (mocktail
  `ProductsApi` fake).
- [X] T008 [P] [US1] `ProductsListController` tests: search/filter state →
  `skip`/`limit`/`search`/`deactivated`/`stockable`/`salable`/`purchasable`
  query param mapping (research.md §6) in
  `test/unit/features/catalog/products_list_controller_test.dart`.
- [X] T009 [P] [US1] Widget test for `ProductsListScreen` (search box,
  filter chips, "no products found" empty state, inactive badge) in
  `test/widget/features/catalog/products_list_screen_test.dart`.
- [X] T010 [P] [US1] Integration test: sign in with a Read-privilege account
  and find a known product by exact code and by partial name; sign in with a
  no-`products`-privilege account and confirm `/products` is unreachable, in
  `test/integration/product_catalog_flow_test.dart` (quickstart Story 1
  scenarios 1, 2, 4 — run against local mbe-api).

### Implementation for User Story 1

- [X] T011 [P] [US1] Create `ProductsListController` (plain `Notifier`:
  `search`, `deactivated`/`stockable`/`salable`/`purchasable` filters,
  `skip`/`limit` pagination cursor, `AsyncValue<List<ProductListItem>>`
  results) in `lib/features/catalog/presentation/products_list_controller.dart`
  (data-model.md "ProductFilter"; depends on T004, T006).
- [X] T012 [US1] Create `ProductsListScreen` (search field, filter chips,
  the shared `DataTableView` from `lib/core/widgets/data_table_view.dart`,
  "load more"/infinite-scroll pagination per research.md §5) in
  `lib/features/catalog/presentation/products_list_screen.dart` (depends on
  T011).
- [X] T013 [US1] Register the `/products` route in
  `lib/app/router/app_router.dart`, gated by
  `can(SystemObject.products, AccessRight.read)` per contracts/routes.md
  (depends on T012).

**Checkpoint**: User Story 1 is fully functional and independently
testable — browsing, search, and filter all work, and deny-by-default is
enforced for the route.

---

## Phase 4: User Story 2 - Create a new product (Priority: P1)

**Goal**: A user with `products` Create privilege adds a new product with a
unique code, valid name, and required defaults; invalid submissions
(duplicate code, short name, malformed barcode) are rejected with clear
field-level feedback; a user without Create privilege never sees the create
action (FR-003..FR-007, FR-012, FR-014, FR-015).

**Independent Test**: quickstart.md "Story 2" — valid create, duplicate
code, invalid name, invalid barcode, no-create-privilege visibility check.

### Tests for User Story 2

- [X] T014 [P] [US2] `ProductRepositoryImpl.create` tests covering `201`,
  `422` (duplicate code, name too short, invalid barcode) → `AppError`
  mapping in `test/unit/features/catalog/product_repository_impl_test.dart`
  (extends T007's file).
- [X] T015 [P] [US2] `ProductFormController` tests: client-side validation
  (code 1–25 chars no whitespace, name 4–250 chars, barcode empty-or-13-
  digits per contracts/mbe-api-products.md) and create-submission mapping to
  `ProductCreate` (defaults: `deactivated: false` per FR-015) in
  `test/unit/features/catalog/product_form_controller_test.dart`.
- [X] T016 [P] [US2] Widget test for `ProductDetailScreen` create mode
  (field-level validation errors block submission, duplicate-code server
  error surfaced via `ErrorBanner`, no "create product" action rendered for
  an account without Create privilege) in
  `test/widget/features/catalog/product_detail_screen_test.dart`.
- [X] T017 [P] [US2] Integration test: create a valid product and see it
  appear in `/products`; attempt a duplicate code (incl. a disabled
  product's code) and an invalid name/barcode and confirm rejection; confirm
  a Read-only account has no create action, in
  `test/integration/product_catalog_flow_test.dart` (extends T010's file;
  quickstart Story 2 scenarios 1-5).

### Implementation for User Story 2

- [X] T018 [US2] Add `create(ProductCreate) -> Product` to `ProductRepository`
  (`lib/features/catalog/domain/repositories/product_repository.dart`) and
  `ProductRepositoryImpl`
  (`lib/features/catalog/data/product_repository_impl.dart`) per
  contracts/mbe-api-products.md `POST /products` (depends on T006).
- [X] T019 [P] [US2] Create `ProductFormController` (plain `Notifier`: all
  editable `Product` fields per data-model.md, `submitting`, `fieldErrors`,
  client-side validation mirroring contracts/mbe-api-products.md, a
  `submitCreate()` action building `ProductCreate`) in
  `lib/features/catalog/presentation/product_form_controller.dart` (depends
  on T002, T018).
- [X] T020 [US2] Create `ProductDetailScreen` create mode (multi-column
  form per constitution §VI, field-level error display, calls
  `ProductFormController.submitCreate`) in
  `lib/features/catalog/presentation/product_detail_screen.dart` (depends on
  T019).
- [X] T021 [US2] Register the `/products/new` route in
  `lib/app/router/app_router.dart` gated by
  `can(SystemObject.products, AccessRight.create)`, and add a gated "New
  product" action to `ProductsListScreen` per contracts/routes.md (depends
  on T012, T020).

**Checkpoint**: User Stories 1 AND 2 both work independently — browsing and
creating products are both fully usable.

---

## Phase 5: User Story 3 - Edit an existing product (Priority: P2)

**Goal**: A user with `products` Update privilege edits an existing
product's fields, with the same validation as creation; a Read-only user
sees all fields but cannot edit (FR-008, FR-009, FR-013).

**Independent Test**: quickstart.md "Story 3" — edit name/tax rate, attempt
a duplicate-code rename, confirm read-only rendering for a Read-only
account.

### Tests for User Story 3

- [X] T022 [P] [US3] `ProductRepositoryImpl.update` tests covering `200`,
  `404`, `422` (duplicate code on rename) → `AppError` mapping in
  `test/unit/features/catalog/product_repository_impl_test.dart` (extends
  T007/T014's file).
- [X] T023 [P] [US3] `ProductFormController` tests: loading an existing
  `Product` into form state, building a partial `ProductUpdate` (only
  changed fields), and a `readOnly` flag that blocks `submitUpdate()` in
  `test/unit/features/catalog/product_form_controller_test.dart` (extends
  T015's file).
- [X] T024 [P] [US3] Widget test for `ProductDetailScreen` edit mode (fields
  editable + Save visible when `can(products, update)`; all fields rendered
  read-only with no Save action when only `can(products, read)`) in
  `test/widget/features/catalog/product_detail_screen_test.dart` (extends
  T016's file).
- [X] T025 [P] [US3] Integration test: edit a product's name/tax rate and
  confirm the change reflects in list and detail views; rename to an
  existing code and confirm rejection; confirm a Read-only account sees no
  Save action, in `test/integration/product_catalog_flow_test.dart` (extends
  T017's file; quickstart Story 3 scenarios 1-3).

### Implementation for User Story 3

- [X] T026 [US3] Add `update(int productId, ProductUpdate) -> Product` to
  `ProductRepository`/`ProductRepositoryImpl` per
  contracts/mbe-api-products.md `PUT /products/{product_id}` (depends on
  T018).
- [X] T027 [US3] Extend `ProductFormController` with edit-mode support:
  `loadForEdit(Product)`, a `readOnly` flag derived from
  `accessControlProvider.can(SystemObject.products, AccessRight.update)`,
  and `submitUpdate()` sending only changed fields as `ProductUpdate`
  (depends on T019, T026).
- [X] T028 [US3] Extend `ProductDetailScreen` to support view/edit mode:
  fetch the `Product` via `ProductRepository.get` for `/products/:productId`,
  render read-only when `readOnly` is true (FR-013), editable form + Save
  otherwise (depends on T027).
- [X] T029 [US3] Register the `/products/:productId` route in
  `lib/app/router/app_router.dart` gated by
  `can(SystemObject.products, AccessRight.read)` to view (Save itself is
  gated inside the screen per contracts/routes.md) (depends on T013, T028).

**Checkpoint**: User Stories 1-3 all work independently — browsing,
creating, and editing products are fully usable.

---

## Phase 6: User Story 4 - Deactivate (soft-delete) a product (Priority: P2)

**Goal**: A user with `products` Delete privilege deactivates a product,
removing it from default views/new-transaction selection while preserving
history; a user without Delete privilege never sees the action; deactivating
an already-inactive product is a no-op (FR-010, FR-011, edge case on
re-deactivation).

**Independent Test**: quickstart.md "Story 4" — deactivate, confirm excluded
from the active-only list, confirm visible with "include disabled", confirm
no action for a non-privileged account.

### Tests for User Story 4

- [X] T030 [P] [US4] `ProductFormController` tests: `deactivate()` calls
  `ProductRepository.update` with `{deactivated: true}` only, and is a no-op
  when the product is already `deactivated == true`, in
  `test/unit/features/catalog/product_form_controller_test.dart` (extends
  T023's file).
- [X] T031 [P] [US4] Widget test for `ProductDetailScreen` Deactivate action
  (visible only when `can(products, delete)` AND the product is currently
  active; absent/disabled otherwise) in
  `test/widget/features/catalog/product_detail_screen_test.dart` (extends
  T024's file).
- [X] T032 [P] [US4] Integration test: deactivate a product and confirm it
  disappears from the default `/products` list on next refresh; confirm it
  still appears, marked inactive, with the "include disabled" filter on;
  confirm a no-Delete-privilege account has no Deactivate action, in
  `test/integration/product_catalog_flow_test.dart` (extends T025's file;
  quickstart Story 4 scenarios 1, 2, 4).

### Implementation for User Story 4

- [X] T033 [US4] Add a `deactivate()` action to `ProductFormController`
  (calls `submitUpdate`-equivalent with only `{deactivated: true}`; no-ops
  if already deactivated) in
  `lib/features/catalog/presentation/product_form_controller.dart` (depends
  on T026, T027).
- [X] T034 [US4] Add a "Deactivate" action to `ProductDetailScreen`, gated
  by `can(SystemObject.products, AccessRight.delete)` and the product's
  current `deactivated` state, in
  `lib/features/catalog/presentation/product_detail_screen.dart` (depends on
  T033, T028).
- [X] T035 [US4] Add an "include disabled" filter toggle to
  `ProductsListScreen`/`ProductsListController` and render an inactive badge
  per row (FR-011) in
  `lib/features/catalog/presentation/products_list_screen.dart` and
  `lib/features/catalog/presentation/products_list_controller.dart` (depends
  on T011, T012).

**Checkpoint**: All four user stories are independently functional —
browse, create, edit, and deactivate all work end-to-end with deny-by-
default RBAC enforced throughout.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Final consistency pass across all four stories.

- [X] T036 [P] Run `dart run build_runner build --delete-conflicting-outputs`
  and resolve any `freezed`/`riverpod_generator` codegen errors introduced
  in `lib/features/catalog/`.
- [X] T037 [P] Add `es-MX` localized strings (`.arb` files under
  `lib/l10n/`) for all catalog screens introduced in Phases 3-6
  (constitution §V).
- [X] T038 Run `flutter analyze` across `lib/features/catalog/` and resolve
  all warnings/errors.
- [X] T039 Execute [quickstart.md](./quickstart.md) end-to-end against a
  local mbe-api instance (Stories 1-4 validation scenarios) and fix any
  discrepancies found.

---

## Phase 8: Remediation (from `/speckit-analyze`)

**Purpose**: Close coverage gaps H2, M1, and M3 identified by `/speckit-analyze`
against spec.md. (C1, the server-side RBAC gap, is tracked separately as
[mictlanix/mbe-api#70](https://github.com/mictlanix/mbe-api/issues/70) — not
a task in this repo.) These tasks extend files already created in earlier
phases, so they are sequenced after those phases rather than numbered inline.

- [ ] T040 [US3] Render `Product.prices` (`List<ProductPrice>`) as a
  read-only sub-panel on `ProductDetailScreen` (FR-008, data-model.md
  "ProductPrice") in
  `lib/features/catalog/presentation/product_detail_screen.dart` (depends on
  T003, T028).
- [ ] T041 [US2] Add a submit-time privilege re-check to
  `ProductFormController.submitCreate` — re-evaluate
  `accessControlProvider.can(SystemObject.products, AccessRight.create)`
  immediately before calling the repository, surfacing a clear error and
  aborting if it now fails (spec.md Edge Cases — privilege revoked while a
  form is open) in
  `lib/features/catalog/presentation/product_form_controller.dart` (depends
  on T019).
- [ ] T042 [US3] Add the same submit-time privilege re-check to
  `ProductFormController.submitUpdate` (re-evaluate
  `can(SystemObject.products, AccessRight.update)` before calling the
  repository) in
  `lib/features/catalog/presentation/product_form_controller.dart` (depends
  on T027, T041).
- [ ] T043 [US2] Map a server-returned `ValidationError` (422) from
  `submitCreate`/`submitUpdate` into the same `fieldErrors` state used for
  client-side validation, so duplicate-code-on-race and other server-only
  rejections render the same way as client-side ones (FR-014) in
  `lib/features/catalog/presentation/product_form_controller.dart` (depends
  on T019, T027).

**Checkpoint**: Pricing is visible on the detail screen, privilege changes
mid-session are re-checked at submit time, and server-side validation
errors render through the same field-error UI as client-side ones.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately.
- **Foundational (Phase 2)**: Depends on Phase 1. BLOCKS all user stories.
- **User Story 1 (Phase 3)**: Depends on Phase 2 completion. No dependency
  on US2/US3/US4.
- **User Story 2 (Phase 4)**: Depends on Phase 2 completion. Independent of
  US1 at the code level, but T021 edits `app_router.dart`/
  `products_list_screen.dart` alongside T013/T012 — sequence or coordinate.
- **User Story 3 (Phase 5)**: Depends on Phase 2 and on User Story 2's
  `ProductFormController`/`ProductDetailScreen` (T019, T020) — it extends
  the same files rather than creating new ones, so US3 cannot start in
  parallel with US2 even though it is a logically distinct story.
- **User Story 4 (Phase 6)**: Depends on User Story 3's
  `ProductFormController`/`ProductDetailScreen` extensions (T027, T028) for
  the same reason — it adds `deactivate()` and the Deactivate button to
  files US3 already modified.
- **Remediation (Phase 8)**: T040 depends on Phase 5 (US3); T041 depends on
  Phase 4 (US2); T042 depends on T041 and Phase 5 (US3); T043 depends on
  Phase 4 (US2) and Phase 5 (US3). All four extend files created in Phases
  4-5 — none can start before their respective phase completes.
- **Polish (Phase 7)**: Depends on whichever of Phases 3-6 are complete. May
  run before or after Phase 8 — they touch different concerns.

### Within Each User Story

- Tests (T007-T010, T014-T017, T022-T025, T030-T032) MUST be written and
  FAIL before their corresponding implementation tasks.
- Entities/repository before controllers; controllers before screens;
  screens before router registration.

### Parallel Opportunities

- Phase 2: T002-T004 (entities) can run in parallel; T005-T006 follow.
- User Story 1 can run fully in parallel with Setup/Foundational consumers
  once Phase 2 completes.
- User Stories 2, 3, and 4 share `product_form_controller.dart` and
  `product_detail_screen.dart` and must be sequenced (US2 → US3 → US4) even
  though each is independently testable once its predecessor's file changes
  land.
- All `[P]` test tasks within a story can run in parallel.

---

## Parallel Example: User Story 1

```bash
# Tests (after Phase 2 checkpoint):
Task: "ProductRepositoryImpl list/get tests in test/unit/features/catalog/product_repository_impl_test.dart"
Task: "ProductsListController tests in test/unit/features/catalog/products_list_controller_test.dart"
Task: "ProductsListScreen widget test in test/widget/features/catalog/products_list_screen_test.dart"
Task: "product_catalog_flow_test.dart integration test"

# Implementation:
Task: "ProductsListController in lib/features/catalog/presentation/products_list_controller.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup.
2. Complete Phase 2: Foundational (CRITICAL — blocks all stories).
3. Complete Phase 3: User Story 1.
4. **STOP and VALIDATE**: run quickstart.md Story 1 against local mbe-api.
5. Demo: search/filter the catalog with a Read-privilege account; confirm a
   no-privilege account is denied.

### Incremental Delivery

1. Setup + Foundational → `ProductRepository.list`/`.get` working, no
   screens.
2. Add User Story 1 → validate independently → MVP demo (browse/search).
3. Add User Story 2 → validate independently → demo (create).
4. Add User Story 3 → validate independently → demo (edit).
5. Add User Story 4 → validate independently → demo (deactivate).
6. Phase 7 polish across all four.

---

## Notes

- `[P]` tasks touch different files with no unmet dependencies.
- `[Story]` labels (US1-US4) map to spec.md priorities P1 (US1, US2) / P2
  (US3, US4).
- `product_form_controller.dart` and `product_detail_screen.dart` are
  created in US2 (T019, T020) and then extended in US3 (T027, T028) and US4
  (T033, T034) — these three stories are NOT parallel with each other at
  the file level even though each delivers independent user-facing value;
  sequence them US2 → US3 → US4.
- `product_repository.dart`/`product_repository_impl.dart` are extended by
  T018 (US2, `create`) and T026 (US3, `update`) — sequence these two.
- `app_router.dart` is edited by T013 (US1), T021 (US2), and T029 (US3) —
  coordinate to avoid merge conflicts, same as noted in
  specs/001-user-authentication/tasks.md.
- Commit after each task or logical group; stop at any checkpoint to
  validate a story independently.
- `product_form_controller.dart` and `product_detail_screen.dart` are
  extended a third time in Phase 8 (T040-T043) — these come after US4
  (Phase 6) is implemented or at least after the specific predecessor task
  each depends on, to avoid clobbering US4's edits to the same files.
