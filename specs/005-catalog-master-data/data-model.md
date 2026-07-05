# Data Model: Product Catalog Master-Data Integration

**Feature**: `005-catalog-master-data` | **Spec**: [spec.md](./spec.md) | **Research**: [research.md](./research.md)

---

## Modified Domain Entities

### `Product` (`lib/features/catalog/domain/entities/product.dart`)

Scalar FK fields replaced by expanded fields. New `labels` list added.

| Field | Old type | New type | Notes |
|---|---|---|---|
| `unitOfMeasurement` | `String` | *(removed)* | Split into the two fields below |
| `unitOfMeasurementCode` | — | `String` | The SAT code (e.g. `"KGM"`); sent on update |
| `unitOfMeasurementName` | — | `String` | Human-readable name from `SatUnitOfMeasurementResponse.name` |
| `unitOfMeasurementDescription` | — | `String?` | Optional description from `SatUnitOfMeasurementResponse.description` |
| `unitOfMeasurementSymbol` | — | `String?` | Optional symbol from `SatUnitOfMeasurementResponse.symbol` |
| `key` | `String?` | *(removed)* | Split into the two fields below |
| `satKeyCode` | — | `String?` | The SAT product/service code (e.g. `"43211507"`) |
| `satKeyDescription` | — | `String?` | Human-readable description from `SatCatalogResponse.description` |
| `supplier` | `int?` | *(removed)* | Split into the two fields below |
| `supplierId` | — | `int?` | Foreign key used in create/update requests |
| `supplierName` | — | `String?` | Display name from `SupplierResponse.name`; `null` when no supplier |
| `labels` | — | `List<ProductLabel>` | Currently assigned labels; empty list when none |

`fromResponse(ProductResponse)` updated to extract all of the above from the now-nested response fields.

---

### `ProductListItem` (`lib/features/catalog/domain/entities/product_list_item.dart`)

| Field | Old type | New type | Notes |
|---|---|---|---|
| `unitOfMeasurement` | `String` | *(removed)* | Split below |
| `unitOfMeasurementCode` | — | `String` | Maps from `SatUnitOfMeasurementResponse.id` |
| `unitOfMeasurementName` | — | `String` | Maps from `SatUnitOfMeasurementResponse.name`; shown in list column |

The list screen shows `unitOfMeasurementName` where available; filters/comparisons that need the code use `unitOfMeasurementCode`.

---

### `ProductPrice` (`lib/features/catalog/domain/entities/product_price.dart`)

| Field | Old type | New type | Notes |
|---|---|---|---|
| `priceList` | `int` | *(removed)* | Split below |
| `priceListId` | — | `int` | The price list's id |
| `priceListName` | — | `String` | From `PriceListResponse.name`; shown as the row label |

`fromResponse(ProductPriceResponse)` updated: `response.priceList` is now a `PriceListResponse` object.

---

## New Domain Entities

### `ProductLabel` (`lib/features/catalog/domain/entities/product_label.dart`)

A label attached to a product (read from `ProductResponse.labels`).

| Field | Type | Notes |
|---|---|---|
| `labelId` | `int` | Primary key; used in `ProductCreate`/`ProductUpdate.labels` list |
| `name` | `String` | Displayed on the product detail screen and in pickers |

`fromResponse(LabelResponse)` factory.

---

### `SatUnit` (`lib/features/catalog/domain/entities/sat_unit.dart`)

A SAT unit-of-measurement catalog entry, used as the picker's item type.

| Field | Type | Notes |
|---|---|---|
| `code` | `String` | The 3-char SAT code (e.g. `"KGM"`); sent as `unit_of_measurement` on create/update |
| `name` | `String` | Human-readable name |
| `description` | `String?` | Optional longer description |
| `symbol` | `String?` | Optional symbol (e.g. `"kg"`) |

`fromResponse(SatUnitOfMeasurementResponse)` factory.

---

### `SatCatalogItem` (`lib/features/catalog/domain/entities/sat_catalog_item.dart`)

A generic SAT catalog entry used for product/service key picker items.

| Field | Type | Notes |
|---|---|---|
| `code` | `String` | The SAT code (e.g. `"43211507"`); sent as `key` on create/update |
| `description` | `String?` | Human-readable description |

`fromResponse(SatCatalogResponse)` factory.

---

### `SupplierListItem` (`lib/features/catalog/domain/entities/supplier_list_item.dart`)

A supplier search result, used as the picker's item type.

| Field | Type | Notes |
|---|---|---|
| `supplierId` | `int` | Sent as `supplier` on product create/update |
| `code` | `String` | Shown alongside name in picker results (e.g. `"SUP001 — Aceros del Norte"`) |
| `name` | `String` | Primary display name |

`fromResponse(SupplierResponse)` factory.

---

### `LabelItem` (`lib/features/catalog/domain/entities/label_item.dart`)

A label, used for both the multi-picker on the form and the filter dropdown on the list.

| Field | Type | Notes |
|---|---|---|
| `labelId` | `int` | Used in filter param and in `ProductCreate`/`ProductUpdate.labels` |
| `name` | `String` | Displayed in the chip/dropdown |

`fromResponse(LabelResponse)` factory.

---

## Modified Form State

### `ProductFormState` (`lib/features/catalog/presentation/product_form_controller.dart`)

| Field | Old | New | Notes |
|---|---|---|---|
| `unitOfMeasurement` | `String` | *(renamed)* | — |
| `unitOfMeasurementCode` | — | `String` | Replaces `unitOfMeasurement`; validated non-empty |
| `unitOfMeasurementDisplayText` | — | `String` | Pre-fills picker field (`SatUnit.name`); not validated |
| `key` | not present | *(new split)* | Was absent from form state entirely |
| `satKeyCode` | — | `String?` | Sent as `key` on submit |
| `satKeyDisplayText` | — | `String?` | Pre-fills SAT key picker field |
| `supplier` | not present | *(new split)* | Was absent from form state entirely |
| `supplierId` | — | `int?` | Sent as `supplier` on submit |
| `supplierName` | — | `String?` | Pre-fills supplier picker field |
| `labelIds` | not present | `List<int>` | Sent as `labels` on submit; `[]` by default |

**Unchanged fields**: `code`, `name`, `brand`, `model`, `barCode`, `location`, `taxRate`, `comment`, `stockable`, `perishable`, `seriable`, `purchasable`, `salable`, `invoiceable`, `deactivated`, `photo`/`pendingPhotoBytes`/`pendingPhotoFilename`/`photoMarkedForRemoval`, `loading`, `submitting`, `saved`, `error`, `errorDetail`, `fieldErrors`.

---

## Modified Filter State

### `ProductFilter` (`lib/features/catalog/presentation/products_list_controller.dart`)

| Field | Old | New | Notes |
|---|---|---|---|
| `label` | not present | `int?` | Passed as `?label=` to `GET /api/v1/products` |

`ProductFilterController` gains `labelChanged(int? value)`.

---

## Repository Interfaces

### Modified: `ProductRepository`

Additional parameters on existing methods:

```
create(
  ...existing params...,
  int? supplier,       // NEW
  String? key,         // NEW
  List<int> labels,    // NEW, default []
)

update(
  ...existing params...,
  int? supplier,       // NEW
  String? key,         // NEW
  List<int>? labels,   // NEW, null = no change
)

list(
  ...existing params...,
  int? label,          // NEW
)
```

### New: `SupplierRepository` (`lib/features/catalog/domain/repositories/supplier_repository.dart`)

```
list({String? search, int skip = 0, int limit = 20}) → SupplierListResult
```

`SupplierListResult`: `items: List<SupplierListItem>`, `total: int`

### New: `SatCatalogRepository` (`lib/features/catalog/domain/repositories/sat_catalog_repository.dart`)

```
listUnitsOfMeasurement({String? search, int skip = 0, int limit = 20}) → SatUnitListResult
listProductServices({String? search, int skip = 0, int limit = 20}) → SatCatalogItemListResult
```

### New: `LabelRepository` (`lib/features/catalog/domain/repositories/label_repository.dart`)

```
list({String? search, int skip = 0, int limit = 100}) → LabelListResult
```

`LabelListResult`: `items: List<LabelItem>`, `total: int`

---

## New Shared Widgets

### `CatalogEntityPicker<T>` (`lib/core/widgets/catalog_entity_picker.dart`)

A generic, single-select search-as-you-type picker for form fields backed by paginated server-side search.

**Key parameters**:
- `displayStringForOption: String Function(T)` — text shown in the dropdown row and filled into the field after selection
- `optionsBuilder: Future<Iterable<T>> Function(String query)` — called with a 300 ms debounce on each text change
- `onSelected: ValueChanged<T>` — fires when the user picks an item
- `initialDisplayText: String?` — pre-fills the field in edit mode
- `errorText: String?` — surfaces `fieldErrors` from `ProductFormState`
- `label: String` — field label

Used for: supplier picker, SAT unit-of-measurement picker, SAT product/service key picker.

### `LabelMultiPicker` (`lib/core/widgets/label_multi_picker.dart`)

A multi-select label picker for the product form.

**Key parameters**:
- `labels: List<LabelItem>` — all available labels (pre-loaded)
- `selectedIds: List<int>` — currently selected label ids (from `ProductFormState.labelIds`)
- `onChanged: ValueChanged<List<int>>` — fires with the new full selected set on each chip tap
- `enabled: bool` — `false` renders chips read-only (for users without edit privilege)
