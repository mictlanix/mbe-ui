# Research: Product Catalog Master-Data Integration

**Feature**: `005-catalog-master-data` | **Spec**: [spec.md](./spec.md)

---

## §1 — Server-Side FK Expansion: No Lookup Calls Needed on Read

**Decision**: No new `FutureProvider` or separate fetch calls are needed to display supplier name, SAT unit description, SAT key description, price-list name, or labels on the detail/list screens. All FK fields are now pre-expanded server-side in `ProductResponse` and `ProductListItem`.

**Findings**:

- `ProductResponse.supplier` → `SupplierResponse?` (`supplierId`, `code`, `name`, …)
- `ProductResponse.unit_of_measurement` → `SatUnitOfMeasurementResponse` (`id`, `name`, `description`, `symbol`)
- `ProductResponse.key` → `SatCatalogResponse?` (`id`, `description`)
- `ProductPriceResponse.price_list` → `PriceListResponse` (`priceListId`, `name`, `highProfitMargin`, `lowProfitMargin`)
- `ProductResponse.labels` → `BuiltList<LabelResponse>` (`labelId`, `name`, `comment`)
- `ProductListItem.unit_of_measurement` → `SatUnitOfMeasurementResponse` (same as detail)

**Impact on existing `fromResponse` factories**: the three domain entities that map these fields all currently hold raw scalar values (`String`/`int`). Each factory must be updated to extract from the now-nested response object. This is purely mechanical — no new async work at read time.

**Alternatives considered**: per-ID lookup providers (e.g. a `FutureProvider` fetching the supplier by id) — rejected because the server already delivers the data; an extra round-trip would be wasteful and introduce race conditions with page navigation.

---

## §2 — Picker Widget Design for Form Fields

**Decision**: Implement a shared `CatalogEntityPicker<T>` in `core/widgets/` wrapping Flutter's `Autocomplete<T>` widget with debounced server-side search. A separate `LabelMultiPicker` wraps `FilterChip` rows for multi-select label assignment.

**Findings**:

`CatalogEntityPicker<T>` covers Supplier, SAT unit-of-measurement, and SAT product/service key:

- Flutter `Autocomplete<T>` provides the field + dropdown overlay and calls `optionsBuilder` whenever text changes. `optionsBuilder` returns a `Future<Iterable<T>>`, so it naturally integrates with async API calls.
- A 300 ms debounce inside `optionsBuilder` prevents per-keystroke API calls.
- The widget accepts `onSelected: ValueChanged<T>` so the parent form controller receives the fully-typed selection (e.g. `SupplierResponse`) and can extract both the id (for the submission payload) and the display name (for the picker field pre-fill).
- `initialValue` (the currently saved code/id + display text) populates the field in edit mode; the widget reconstructs `TextEditingValue` from the display string.
- `displayStringForOption: T Function(T)` provides the text shown in the dropdown and in the filled field after selection.
- `fieldViewBuilder` renders a `TextFormField` so `ProductFormState.fieldErrors` can annotate the unit-of-measurement field normally.

`LabelMultiPicker` covers label assignment:

- Labels are loaded once per form open (not per-keystroke) since label datasets are small (typically < 100 entries). A `FutureProvider` keyed by `(search: null, limit: 100)` covers this.
- Renders a `Wrap` of `FilterChip`s, one per label; `selected` = true for labels already in `ProductFormState.labelIds`.
- An optional search `TextField` above the chips lets users filter the chip list client-side without an extra API call, sufficient for typical label-set sizes.
- `onSelected` calls `ProductFormController.labelToggled(labelId)`.

**Alternatives considered**:

- `SearchAnchor` (Flutter 3.10+ Material 3 search) — more opinionated UI; `Autocomplete<T>` is lower-level and lets the surrounding form control focus/error state more easily.
- `DropdownButton<T>` — not searchable; impractical for SAT product/service catalog (thousands of codes).
- Inline `ListView.builder` inside an `ExpansionTile` — reasonable for labels but `FilterChip`-in-`Wrap` is cleaner for multi-select since selected state is visible without expansion.

---

## §3 — Form State Design for Picker Selections

**Decision**: `ProductFormState` carries parallel id+display fields for each picker. The code/id is the submission value; the display string pre-fills the picker's `TextEditingValue` on load.

**Rationale**: `ProductFormState` is a `@freezed` plain-data class (no generics, no widget refs). Storing the full API response object in it would couple the domain layer to generated DTOs. Storing just the id means the form would need a separate async lookup on load to reconstruct the display text, adding complexity. Parallel scalar fields (e.g. `supplierId: int?` + `supplierName: String?`) are the smallest, cleanest extension.

**Added fields to `ProductFormState`**:

| Field | Type | Purpose |
|---|---|---|
| `supplierId` | `int?` | Sent as the `supplier` field in `ProductCreate`/`ProductUpdate` |
| `supplierName` | `String?` | Pre-fills the supplier picker's text field on edit load |
| `unitOfMeasurementCode` | `String` | Replaces `unitOfMeasurement`; the SAT code sent on submit |
| `unitOfMeasurementDisplayText` | `String` | Pre-fills the unit-of-measurement picker; derived from `SatUnitOfMeasurementResponse.name` |
| `satKeyCode` | `String?` | Replaces `key` field; the SAT product/service code sent on submit |
| `satKeyDisplayText` | `String?` | Pre-fills the SAT key picker; derived from `SatCatalogResponse.description` |
| `labelIds` | `List<int>` | Sent as the `labels` field in `ProductCreate`/`ProductUpdate` |

`ProductFormController.loadForEdit` maps from the new `Product` entity fields (post-expansion). `ProductFormController.submitCreate`/`submitUpdate` pass `supplierId` as `supplier`, `unitOfMeasurementCode` as `unitOfMeasurement`, `satKeyCode` as `key`, and `labelIds` as `labels` to the repository.

The existing `unitOfMeasurement` field on `ProductFormState` is renamed to `unitOfMeasurementCode`; `_validate()` is updated accordingly.

---

## §4 — New Repository Placement

**Decision**: New read-only repositories for Supplier, Label, and SAT catalogs are placed in `lib/features/catalog/`, matching the constitution's description of catalog as the shared master-data module.

**Rationale**: The constitution explicitly names `catalog` as the shared kernel for entities used across features. Suppliers, Labels, and SAT catalogs are master-data that will eventually be used in sales, invoicing, and inventory too. Placing them in `lib/features/catalog/` now — rather than a hypothetical `lib/features/master_data/` folder — avoids introducing a new feature folder for entities the catalog feature already needs, while still keeping them accessible to other features via import. A future refactor to a dedicated `master_data` module can move them there without changing callers.

**New repository interfaces** (each paired with an `_impl.dart`):

- `SupplierRepository.list({String? search, int skip, int limit})` → `SupplierListResult`
- `SatCatalogRepository.listUnitsOfMeasurement({String? search, int skip, int limit})` → `SatUnitListResult`
- `SatCatalogRepository.listProductServices({String? search, int skip, int limit})` → `SatCatalogItemListResult`
- `LabelRepository.list({String? search, int skip, int limit})` → `LabelListResult`

All impls use the generated client (`SuppliersApi`, `LabelsApi`, `SatCatalogsApi`) and follow the same `_toAppError(e)` pattern as `ProductRepositoryImpl`.

---

## §5 — Label Filter on Products List

**Decision**: Add `label: int?` to `ProductFilter` and `ProductFilterController`; render as a `DropdownButton<LabelResponse?>` in the `CatalogFilterBar`'s `filters` list, following the existing filter pattern.

**Rationale**: The product list endpoint already accepts `?label=<id>`. The filter state is a Riverpod `@freezed` class already extended for each new facet in 002/003; adding `label: int?` follows the exact same pattern as `deactivated`/`stockable`/`salable`/`purchasable`.

The label dropdown pre-loads available labels from `LabelRepository.list()` via a `futureProvider`; if the list is empty the dropdown is hidden (FR-008 edge case). A "no filter" sentinel (`null`) renders as "All labels" and clears the filter.

**Alternatives considered**: `FilterChip` row — better visual when label set is large but adds layout complexity to `CatalogFilterBar`; `DropdownButton` is consistent with what the filter bar already renders for the tri-state boolean filters.

---

## §6 — ProductListItem: `unitOfMeasurement` Type Change

**Decision**: `ProductListItem.unitOfMeasurement` changes from `String` to storing the SAT unit code string (from `SatUnitOfMeasurementResponse.id`) in the existing field, plus a new optional `unitOfMeasurementName: String?` field for display enrichment.

**Rationale**: The generated `api.ProductListItem.unit_of_measurement` is now a `SatUnitOfMeasurementResponse` object, but the domain `ProductListItem.fromResponse` factory still reads it as `.unitOfMeasurement` (a `String`). The factory will be updated to read `.unitOfMeasurement.id` for the code, and `.unitOfMeasurement.name` for the display name. Keeping the code as the primary field preserves any existing filter/search behavior that compares codes.

The list screen currently shows `unitOfMeasurement` as a column — it will show the human-readable name where available, falling back to the code.

---

## §7 — `ProductRepository.create`/`update` Missing `supplier` and `key` Parameters

**Finding**: The existing `ProductRepository` interface and `ProductRepositoryImpl.create`/`update` methods do NOT currently pass `supplier` or `key` — these were omitted when the form was first built in 002. Now that both fields have SAT/supplier pickers and the backend accepts them, these parameters must be added to the repository interface and implementation.

`ProductCreate` already accepts `supplier: int?` and `key: String?` in the generated model; adding them to the repository's parameter lists and the `ProductCreate`/`ProductUpdate` builder calls is mechanical.
