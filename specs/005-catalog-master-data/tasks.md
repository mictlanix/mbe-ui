# Tasks: Product Catalog Master-Data Integration

**Feature**: `005-catalog-master-data`  
**Input**: Design documents from `specs/005-catalog-master-data/`  
**Plan**: [plan.md](./plan.md) | **Spec**: [spec.md](./spec.md) | **Data model**: [data-model.md](./data-model.md)

## Format: `[ID] [P?] [Story?] Description`

- **[P]**: Can run in parallel (different files, no blocking dependencies between them)
- **[Story]**: Which user story this task belongs to (US1–US5)
- Exact file paths are shown in each task description

---

## Phase 1: Setup

**Purpose**: Verify the baseline before any changes.

- [X] T001 Run `dart run build_runner build --delete-conflicting-outputs` from the repo root and confirm it passes cleanly; note any pre-existing analyzer warnings to distinguish them from regressions introduced by this feature

**Checkpoint**: Clean build confirmed — safe to begin entity modifications.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Shared entity modifications and new domain entities that all user stories depend on. **Must be complete before any user story phase begins.**

> ⚠️ T002–T009 all touch different files and can be done in parallel. T010 (build_runner) must run after T002–T009 are all done. T011–T013 can follow in any order.

### 2a — Modify existing domain entities

- [X] T002 [P] Modify `lib/features/catalog/domain/entities/product.dart`: remove `unitOfMeasurement: String`, `key: String?`, `supplier: int?`; add `unitOfMeasurementCode: String`, `unitOfMeasurementName: String`, `unitOfMeasurementDescription: String?`, `unitOfMeasurementSymbol: String?`, `satKeyCode: String?`, `satKeyDescription: String?`, `supplierId: int?`, `supplierName: String?`, `labels: List<ProductLabel>`; update `fromResponse(ProductResponse)` to extract all nested objects (`response.unitOfMeasurement.id/name/description/symbol`, `response.key?.id/description`, `response.supplier?.supplierId/name`, `response.labels`)
- [X] T003 [P] Modify `lib/features/catalog/domain/entities/product_list_item.dart`: remove `unitOfMeasurement: String`; add `unitOfMeasurementCode: String` and `unitOfMeasurementName: String`; update `fromResponse` to read from the `SatUnitOfMeasurementResponse` object (`response.unitOfMeasurement.id` and `response.unitOfMeasurement.name`)
- [X] T004 [P] Modify `lib/features/catalog/domain/entities/product_price.dart`: remove `priceList: int`; add `priceListId: int` and `priceListName: String`; update `fromResponse` to read from the `PriceListResponse` object (`response.priceList.priceListId` and `response.priceList.name`)

### 2b — Add new domain entities

- [X] T005 [P] Create `lib/features/catalog/domain/entities/product_label.dart`: `@freezed` class with `labelId: int`, `name: String`; `fromResponse(LabelResponse r)` factory
- [X] T006 [P] Create `lib/features/catalog/domain/entities/sat_unit.dart`: `@freezed` class with `code: String`, `name: String`, `description: String?`, `symbol: String?`; `fromResponse(SatUnitOfMeasurementResponse r)` factory mapping `r.id → code`, `r.name → name`, `r.description → description`, `r.symbol → symbol`
- [X] T007 [P] Create `lib/features/catalog/domain/entities/sat_catalog_item.dart`: `@freezed` class with `code: String`, `description: String?`; `fromResponse(SatCatalogResponse r)` factory mapping `r.id → code`, `r.description → description`
- [X] T008 [P] Create `lib/features/catalog/domain/entities/supplier_list_item.dart`: `@freezed` class with `supplierId: int`, `code: String`, `name: String`; `fromResponse(SupplierResponse r)` factory mapping `r.supplierId → supplierId`, `r.code → code`, `r.name → name`
- [X] T009 [P] Create `lib/features/catalog/domain/entities/label_item.dart`: `@freezed` class with `labelId: int`, `name: String`; `fromResponse(LabelResponse r)` factory

### 2c — Regenerate freezed code

- [X] T010 Run `dart run build_runner build --delete-conflicting-outputs`; fix all compilation errors from field renames (e.g. old `unitOfMeasurement`, `priceList`, `supplier` references throughout the codebase that now need `unitOfMeasurementCode`, `priceListId`, `supplierId`, etc.)

### 2d — Extend ProductRepository interface and impl (all four user stories that write or list products touch the same interface)

- [X] T011 Extend `lib/features/catalog/domain/repositories/product_repository.dart`: add `int? supplier`, `String? key`, `List<int> labels` (default `[]`) to `create`; add `int? supplier`, `String? key`, `List<int>? labels` to `update`; add `int? label` to `list`
- [X] T012 Extend `lib/features/catalog/data/product_repository_impl.dart`: wire `supplier`, `key`, `labels` to `ProductCreate`/`ProductUpdate` generated model builder calls; wire `label` to the products list API call query params

### 2e — Shared picker widget (used by US1 and US2)

- [X] T013 Create `lib/core/widgets/catalog_entity_picker.dart`: generic `StatefulWidget CatalogEntityPicker<T>` that wraps Flutter's built-in `Autocomplete<T>`; debounce `optionsBuilder` calls by 300 ms using a widget-local `Timer`; expose parameters: `String label`, `String? initialDisplayText`, `String Function(T) displayStringForOption`, `Future<Iterable<T>> Function(String) optionsBuilder`, `ValueChanged<T> onSelected`, `String? errorText`, `bool enabled`; when `enabled` is false render a read-only `TextFormField` showing `initialDisplayText`

**Checkpoint**: All entities compile, build_runner passes, `ProductRepository` interface has new params, `CatalogEntityPicker` widget exists. User story phases can now begin.

---

## Phase 3: User Story 1 — Supplier picker (Priority: P1) 🎯 MVP

**Goal**: Replace the raw numeric supplier input with a searchable picker; display supplier's name on the form, detail screen, and wherever the product is shown.

**Independent Test**: Open product edit form → type two letters of a known supplier name → confirm dropdown appears within 1 s → select a supplier → save → open detail screen → confirm supplier name (not numeric id) is shown; open a product with no supplier → confirm "no supplier" fallback.

- [X] T014 [P] [US1] Create `lib/features/catalog/domain/repositories/supplier_repository.dart`: abstract class with `Future<({List<SupplierListItem> items, int total})> list({String? search, int skip = 0, int limit = 20})`
- [X] T015 [P] [US1] Create `lib/features/catalog/data/supplier_repository_impl.dart`: implement `SupplierRepository` by calling `SuppliersApi`'s list method with the `search`/`skip`/`limit` params; map each `SupplierResponse` via `SupplierListItem.fromResponse`; expose `supplierRepositoryProvider` as a `Provider<SupplierRepository>`
- [X] T016 [US1] Extend `ProductFormState` and `ProductFormController` in `lib/features/catalog/presentation/product_form_controller.dart`: add `supplierId: int?` and `supplierName: String?` fields to the state; add `supplierSelected(SupplierListItem? item)` method that sets both fields (or clears them when `item` is null); update `loadForEdit` to populate `supplierId`/`supplierName` from `product.supplierId`/`product.supplierName`; update `submit` to pass `supplierId` as `supplier` to `ProductRepository.create`/`update`
- [X] T017 [US1] Run `dart run build_runner build --delete-conflicting-outputs` after T016 to regenerate `product_form_controller.freezed.dart` and `product_form_controller.g.dart`
- [X] T018 [US1] Update `lib/features/catalog/presentation/product_detail_screen.dart` — form section: replace the numeric supplier `TextFormField` with `CatalogEntityPicker<SupplierListItem>`; wire `optionsBuilder` to call `supplierRepositoryProvider.list(search: query)`; wire `onSelected` to `controller.supplierSelected(item)`; wire `initialDisplayText` to `state.supplierName`; set `enabled` from the edit-privilege RBAC check
- [X] T019 [US1] Update `lib/features/catalog/presentation/product_detail_screen.dart` — detail/view section: display `product.supplierName` next to the supplier label; when `product.supplierId == null` show a "No supplier" fallback text; replace any reference to the old raw `supplier` int field

**Checkpoint**: Supplier picker fully functional — search, select, save, name on detail. US1 acceptance scenarios 1–5 pass. (quickstart.md Scenario 1)

---

## Phase 4: User Story 2 — SAT unit-of-measurement and product/service key pickers (Priority: P1)

**Goal**: Replace free-text unit-of-measurement and SAT key inputs with SAT-catalog-backed search pickers. Unit is required and blocks save when missing; SAT key is optional.

**Independent Test**: Open product form → search unit field for "kilo" → confirm matches include code + name + description → select KGM → clear field and attempt to save → confirm required-field validation error → re-select → search SAT key field → select an optional key → save → open detail screen → confirm unit shows code+name and key shows code+description.

> ⚠️ T022 modifies `product_form_controller.dart` — it must run after T016 (US1) is complete because both modify the same file and the freezed state is regenerated in sequence.

- [X] T020 [P] [US2] Create `lib/features/catalog/domain/repositories/sat_catalog_repository.dart`: abstract class with `Future<({List<SatUnit> items, int total})> listUnitsOfMeasurement({String? search, int skip = 0, int limit = 20})` and `Future<({List<SatCatalogItem> items, int total})> listProductServices({String? search, int skip = 0, int limit = 20})`
- [X] T021 [P] [US2] Create `lib/features/catalog/data/sat_catalog_repository_impl.dart`: implement `SatCatalogRepository` calling the `SatCatalogsApi` list methods for units and product-services; map responses via `SatUnit.fromResponse` / `SatCatalogItem.fromResponse`; expose `satCatalogRepositoryProvider` as a `Provider<SatCatalogRepository>`
- [X] T022 [US2] Extend `ProductFormState` and `ProductFormController` in `lib/features/catalog/presentation/product_form_controller.dart`: rename `unitOfMeasurement → unitOfMeasurementCode`; add `unitOfMeasurementDisplayText: String` (for pre-filling the picker); add `satKeyCode: String?` and `satKeyDisplayText: String?`; add `unitSelected(SatUnit unit)` and `satKeySelected(SatCatalogItem? item)` methods; update `loadForEdit` to populate unit and SAT key display fields from `product.unitOfMeasurementCode`/`unitOfMeasurementName` and `product.satKeyCode`/`satKeyDescription`; update `validate` to check `unitOfMeasurementCode` is non-empty (required); update `submit` to pass `key: satKeyCode` to the repository
- [X] T023 [US2] Run `dart run build_runner build --delete-conflicting-outputs` after T022 to regenerate `product_form_controller.freezed.dart` and `product_form_controller.g.dart`
- [X] T024 [US2] Update `lib/features/catalog/presentation/product_detail_screen.dart` — form section: replace the unit-of-measurement `TextFormField` with `CatalogEntityPicker<SatUnit>`; `displayStringForOption` = `"${unit.code} — ${unit.name}"`; `optionsBuilder` → `satCatalogRepository.listUnitsOfMeasurement(search: query)`; `onSelected` → `controller.unitSelected(unit)`; `initialDisplayText` = `state.unitOfMeasurementDisplayText`; `errorText` from `state.fieldErrors['unitOfMeasurementCode']`; required field
- [X] T025 [US2] Update `lib/features/catalog/presentation/product_detail_screen.dart` — form section: replace the SAT key `TextFormField` with `CatalogEntityPicker<SatCatalogItem>`; `displayStringForOption` = `"${item.code} — ${item.description ?? ''}"`; `optionsBuilder` → `satCatalogRepository.listProductServices(search: query)`; `onSelected` → `controller.satKeySelected(item)`; `initialDisplayText` = `state.satKeyDisplayText`; optional field (clearable, no error text)
- [X] T026 [US2] Update `lib/features/catalog/presentation/product_detail_screen.dart` — detail/view section: display unit of measurement as `"${product.unitOfMeasurementCode} — ${product.unitOfMeasurementName}"`; display SAT key as `"${product.satKeyCode} — ${product.satKeyDescription ?? ''}"` (omit this row entirely when `product.satKeyCode == null`)

**Checkpoint**: Both SAT pickers functional, required validation blocks submit without unit, detail shows code + description. US2 acceptance scenarios 1–5 pass. (quickstart.md Scenarios 2 & 3)

---

## Phase 5: User Story 3 — Price-list names on the detail screen (Priority: P2)

**Goal**: Replace raw price-list numeric ids with human-readable names in the product detail screen's price sub-panel.

**Independent Test**: Open any product with multiple price entries → confirm each row label shows the price list's name (e.g. "Retail", "Wholesale"), not a number; verify a price pointing to a non-resolvable price list shows "Unknown price list" fallback.

> No new repository, controller, or widget changes needed — the `ProductPrice` entity already has `priceListId`/`priceListName` from Phase 2 (T004). This phase is one task: update the view.

- [X] T027 [US3] Update `lib/features/catalog/presentation/product_detail_screen.dart` — prices sub-panel: replace any display of the old `priceList` int with `price.priceListName`; when `price.priceListName` is empty or blank show `"Unknown price list"` as a fallback; do not crash or hide the row

**Checkpoint**: Price list names visible on detail screen, no raw ids remain. US3 acceptance scenarios 1–2 pass. (quickstart.md Scenario 4)

---

## Phase 6: User Story 4 — Label filter on the products list (Priority: P3)

**Goal**: Add a label filter control to the products list that narrows results to products carrying a selected label; clearing the filter restores the full list.

**Independent Test**: With at least one labeled product in the system: open products list → select the label from the filter control → confirm only labeled products appear → clear filter → confirm all products reappear.

- [X] T028 [P] [US4] Create `lib/features/catalog/domain/repositories/label_repository.dart`: abstract class with `Future<({List<LabelItem> items, int total})> list({String? search, int skip = 0, int limit = 100})`
- [X] T029 [P] [US4] Create `lib/features/catalog/data/label_repository_impl.dart`: implement `LabelRepository` calling `LabelsApi`'s list method with the given params; map `LabelResponse` via `LabelItem.fromResponse`; expose `labelRepositoryProvider` as a `Provider<LabelRepository>`; expose `allLabelsProvider` as an `AsyncNotifierProvider<List<LabelItem>>` (or `FutureProvider`) that calls `list(limit: 100)` once — this provider is shared with Phase 7 (US5)
- [X] T030 [US4] Extend `ProductFilter` and `ProductFilterController` in `lib/features/catalog/presentation/products_list_controller.dart`: add `label: int?` field to `ProductFilter`; add `labelChanged(int? value)` method to the controller that updates the filter and triggers a fresh `list` call; wire `filter.label` to the `ProductRepository.list(label: ...)` call
- [X] T031 [US4] Update `lib/features/catalog/presentation/products_list_screen.dart`: consume `allLabelsProvider`; when the labels list is non-empty add a label `DropdownButton<int?>` (or `FilterChip` row) to the existing `CatalogFilterBar`; wire selection to `controller.labelChanged()`; hide the control entirely when the labels list is empty or still loading (no loading spinner needed — just absent)

**Checkpoint**: Label filter operational. Selecting a label narrows the list; clearing it restores all products; control is absent when no labels exist. US4 acceptance scenarios 1–4 pass. (quickstart.md Scenario 5)

---

## Phase 7: User Story 5 — Label assignment on the product form (Priority: P3)

**Goal**: Let users assign and remove labels on a product via a multi-select chip picker on the product form. Labels display read-only on the detail screen for all users.

**Independent Test**: Open product edit form → confirm all available labels show as chips → select two → save → open detail screen → confirm both labels displayed → reopen form → confirm pre-selection → deselect one → save → confirm only remaining label on detail screen.

> ⚠️ T033 modifies `product_form_controller.dart` — must run after T022 (US2) is complete since both modify the same file.

- [X] T032 [US5] Create `lib/core/widgets/label_multi_picker.dart`: `StatelessWidget LabelMultiPicker` that accepts `List<LabelItem> labels`, `List<int> selectedIds`, `ValueChanged<List<int>> onChanged`, `bool enabled`; renders each `LabelItem` as a `FilterChip` inside a `Wrap`; on chip tap compute the new selected set (toggle the tapped id) and call `onChanged`; when `enabled` is false render `FilterChip` with `onSelected: null` (read-only appearance); when `labels` is empty render nothing (no placeholder text needed)
- [X] T033 [US5] Extend `ProductFormState` and `ProductFormController` in `lib/features/catalog/presentation/product_form_controller.dart`: add `labelIds: List<int>` field (default `const []`); add `labelToggled(int labelId)` method that toggles the id in the list and notifies; update `loadForEdit` to populate `labelIds` from `product.labels.map((l) => l.labelId).toList()`; update `submit` to pass `labelIds` as `labels` to `ProductRepository.create`/`update`
- [X] T034 [US5] Run `dart run build_runner build --delete-conflicting-outputs` after T033 to regenerate `product_form_controller.freezed.dart` and `product_form_controller.g.dart`
- [X] T035 [US5] Update `lib/features/catalog/presentation/product_detail_screen.dart` — form section: add `LabelMultiPicker` below the other fields; consume `allLabelsProvider` (from T029) to get available labels — show a loading indicator while it is loading and an error message on failure; wire `labels` to the resolved list, `selectedIds` to `state.labelIds`, `onChanged` to a closure that calls `controller.labelToggled` for each changed id (or accept the full list if `LabelMultiPicker.onChanged` provides it), `enabled` to the edit-privilege RBAC check
- [X] T036 [US5] Update `lib/features/catalog/presentation/product_detail_screen.dart` — detail/view section: display `product.labels` as read-only `Chip` widgets in a `Wrap`; when `product.labels` is empty omit the labels row entirely (no placeholder needed)

**Checkpoint**: Label assignment and display complete. Pre-selection works on edit. Labels persisted on save. Read-only on detail. US5 acceptance scenarios 1–4 pass. (quickstart.md Scenario 6)

---

## Phase 8: Polish & Cross-Cutting Concerns

- [X] T037 Run `flutter analyze` from the repo root and resolve all errors and warnings introduced by this feature (field renames, unused imports, type mismatches)
- [X] T038 [P] Run `flutter test` and fix any existing unit or widget tests that fail due to the `Product`, `ProductListItem`, or `ProductPrice` field renames (e.g. `unitOfMeasurement → unitOfMeasurementCode`, `priceList → priceListId`, `supplier → supplierId`)
- [X] T039 [P] Run the full build once more (`dart run build_runner build --delete-conflicting-outputs`) and confirm zero errors before marking the feature complete
- [X] T040 Execute quickstart.md Scenarios 1–7 against a local mbe-api instance; record any deviations from expected outcomes and open follow-up issues if needed

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies — start immediately.
- **Phase 2 (Foundational)**: Depends on Phase 1. **Blocks all user story phases.**
  - T002–T009: all parallel (different new/modified files)
  - T010 (build_runner): after T002–T009
  - T011–T013: after T010, can run in parallel with each other
- **Phase 3 (US1)**: After Phase 2.
  - T014–T015: parallel (different files)
  - T016: after T015 (needs `SupplierListItem` type) and T013 (`CatalogEntityPicker`)
  - T017 (build_runner): after T016
  - T018–T019: after T017
- **Phase 4 (US2)**: After Phase 2 AND after T017 (T022 modifies same file as T016)
  - T020–T021: parallel (different files), can start as soon as Phase 2 is done
  - T022: after T021 and T017 (sequential on `product_form_controller.dart`)
  - T023 (build_runner): after T022
  - T024–T026: after T023
- **Phase 5 (US3)**: After Phase 2. No dependency on US1 or US2 (only entity changes from T004 needed). T027 modifies the same file as T019/T026 — sequence after US1 and US2 detail-screen tasks.
- **Phase 6 (US4)**: After Phase 2.
  - T028–T029: parallel
  - T030: after T011 (extended `ProductRepository` interface) — already done in Phase 2
  - T031: after T029 (`allLabelsProvider`) and T030
- **Phase 7 (US5)**: After Phase 2 AND after T023 (T033 modifies same file as T022). Also needs T029 (`allLabelsProvider`) from Phase 6.
  - T032: parallel with T033 (different files)
  - T033: after T023
  - T034 (build_runner): after T033
  - T035: after T032, T034, T029
  - T036: after T034
- **Phase 8 (Polish)**: After all desired stories complete.

### Cross-Story File Contention

| File | Touched by phases |
|---|---|
| `product_form_controller.dart` | Phase 2 (T011 → same module), Phase 3 T016, Phase 4 T022, Phase 7 T033 — **must be sequential in this order** |
| `product_detail_screen.dart` | Phase 3 T018/T019, Phase 4 T024/T025/T026, Phase 5 T027, Phase 7 T035/T036 — **must be sequential across phases** |
| `products_list_screen.dart` | Phase 6 T031 only |

### Parallel Opportunities Within Each Phase

```
# Phase 2 — all entity tasks in parallel:
T002 (product.dart) ┐
T003 (product_list_item.dart) ┤
T004 (product_price.dart)     ┤ → T010 (build_runner) → T011, T012, T013 (parallel)
T005 (product_label.dart)     ┤
T006 (sat_unit.dart)          ┤
T007 (sat_catalog_item.dart)  ┤
T008 (supplier_list_item.dart)┤
T009 (label_item.dart)        ┘

# Phase 3 — repository pair in parallel:
T014 (supplier_repository.dart) ┐
T015 (supplier_repository_impl) ┘ → T016 → T017 → T018, T019 (parallel)

# Phase 4 — repository pair in parallel:
T020 (sat_catalog_repository.dart) ┐
T021 (sat_catalog_repository_impl) ┘ → T022 → T023 → T024, T025, T026 (parallel)

# Phase 6 — repository pair in parallel:
T028 (label_repository.dart) ┐
T029 (label_repository_impl) ┘ → T030 → T031

# Phase 7:
T032 (label_multi_picker.dart) ─┐
T033 (product_form_controller)  ┘ → T034 → T035, T036 (parallel)
```

---

## Implementation Strategy

### MVP First (User Story 1 only)

1. Complete Phase 1 (Setup) + Phase 2 (Foundational — **critical blocker**)
2. Complete Phase 3 (US1 — supplier picker)
3. **STOP and validate**: quickstart.md Scenario 1 + Scenario 7 (regression)
4. Demo / ship if ready

### Incremental Delivery

1. Phase 1 + Phase 2 → foundation ready
2. Phase 3 (US1) → supplier picker → validate Scenario 1 → deploy/demo
3. Phase 4 (US2) → SAT pickers → validate Scenarios 2 & 3 → deploy/demo
4. Phase 5 (US3) → price list names → validate Scenario 4
5. Phase 6 (US4) → label filter → validate Scenario 5
6. Phase 7 (US5) → label assignment → validate Scenario 6
7. Phase 8 (Polish) → regression check Scenario 7

---

## Notes

- `[P]` marks tasks with different target files and no in-flight dependencies — safe to start in parallel.
- `product_form_controller.dart` is the single most contended file — T016 (US1) → T022 (US2) → T033 (US5) must run in that order; never two of these in parallel.
- `product_detail_screen.dart` is the single most contended screen file — all detail/form section edits across US1–US5 must be sequential.
- Run `build_runner` after each batch of `@freezed` changes (T010, T017, T023, T034) rather than once at the end — catches type errors early.
- The `allLabelsProvider` created in T029 (Phase 6) is shared with Phase 7 (US5) — implement Phase 6 before Phase 7 to avoid duplication.
- Commit after each checkpoint (end of each phase) to keep the branch clean and rollback-friendly.
