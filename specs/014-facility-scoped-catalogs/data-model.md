# Phase 1 Data Model: Facilities and their Facility-Scoped Operational Catalogs

Domain entities are immutable `freezed` classes in
`lib/features/catalog/domain/entities/`, each with a `fromResponse` factory
mapping the generated DTO (constitution §III). Shared enums live in
`lib/core/domain/`. Wire enums are mapped through the domain enums, never read as
raw `number0`/`number1`.

## Shared-kernel enums (new)

### `FacilityType` — `lib/core/domain/facility_type.dart`
| Domain | Wire | Label key |
|---|---|---|
| `store` | 0 | `facilityTypeStore` |
| `productionSite` | 1 | `facilityTypeProductionSite` |

`fromApi(api.FacilityType) → FacilityType` (unknown → `store`, graceful);
`toApi() → api.FacilityType`. Mirrors `EntityStatus`/`Gender`.

### `AddressType` — `lib/core/domain/address_type.dart`
| Domain | Wire | Label key |
|---|---|---|
| `other` | 0 | `addressTypeOther` |
| `home` | 1 | `addressTypeHome` |
| `work` | 2 | `addressTypeWork` |
| `business` | 3 | `addressTypeBusiness` |
| `fiscal` | 4 | `addressTypeFiscal` |

`fromApi`/`toApi` as above (unknown → `other`).

### `EntityStatus` — reused unchanged (`lib/core/domain/entity_status.dart`)

## Detail entities (list/detail screens)

### Warehouse — `warehouse.dart`
| Field | Type | Notes |
|---|---|---|
| `warehouseId` | `int` | id |
| `facilityId` | `int` | from `facility.facilityId` |
| `facilityName` | `String` | from `facility.name` (pre-expanded `FacilitySummary`) |
| `code` | `String` | |
| `name` | `String` | |
| `comment` | `String?` | |
| `status` | `EntityStatus` | via `fromApi` |

`fromResponse(WarehouseResponse)`. An unresolvable facility (defensive) →
`facilityName` fallback label.

### CashDrawer — `cash_drawer.dart`
Identical shape to Warehouse with `cashDrawerId` in place of `warehouseId`.
`fromResponse(CashDrawerResponse)`.

### PointSale — `point_sale.dart`
| Field | Type | Notes |
|---|---|---|
| `pointSaleId` | `int` | |
| `facilityId` / `facilityName` | `int` / `String` | pre-expanded `FacilitySummary` |
| `code` / `name` | `String` | |
| `warehouseId` / `warehouseName` | `int` / `String` | pre-expanded `WarehouseSummary` |
| `comment` | `String?` | |
| `status` | `EntityStatus` | |

`fromResponse(PointSaleResponse)`. Either FK unresolvable → fallback label
(FR-021).

### Facility — `facility.dart`
| Field | Type | Notes |
|---|---|---|
| `facilityId` | `int` | |
| `code` / `name` | `String` | |
| `type` | `FacilityType` | via `fromApi` |
| `locationId` | `String` | from `location.id` (SAT postal-code) |
| `locationLabel` | `String` | from expanded `SatCatalogResponse` (FR-030 display) |
| `addressId` | `int` | from `address.addressId` (pre-expanded) |
| `addressLabel` | `String` | composed from expanded `AddressResponse` (FR-035) |
| `taxpayerRfc` | `String` | bare RFC (unexpanded on the response; FR-034b) |
| `taxpayerName` | `String?` | resolved issuer name — `null` from `fromResponse` (the response carries only the RFC); populated on the detail/edit load by a single `TaxpayerIssuersApi.get(rfc)` call (FR-034b, research.md §9). The detail screen shows `taxpayerName ?? taxpayerRfc`; the list shows `taxpayerRfc` (no per-row resolve). |
| `logo` | `String?` | optional (mbe-api#91) |
| `receiptMessage` | `String?` | optional |
| `defaultBatch` | `String?` | optional |
| `status` | `EntityStatus` | |

`fromResponse(FacilityResponse)`. `addressLabel` is a one-line render of the
expanded address (street + number + neighborhood…); unresolvable address →
fallback label.

## Picker / filter view models

### FacilityListItem — `facility_list_item.dart`
`{ facilityId: int, code: String, name: String, type: FacilityType, status: EntityStatus }`
from `FacilityResponse`/`FacilitySummary`. Picker displays `name`; facet filter
stores `facilityId`.

### AddressListItem — `address_list_item.dart`
`{ addressId: int, label: String, type: AddressType }` from `AddressResponse`.
Picker displays `label` (composed one-line address). Also carries the
`AddressCreatePayload` value object used by the inline-create sub-form.

### TaxpayerIssuerListItem — `taxpayer_issuer_list_item.dart`
`{ rfc: String, name: String? }` from `TaxpayerIssuerResponse`. Picker matches on
both, displays `name ?? rfc`; the facility stores `rfc`. The repository also
exposes `get(rfc) → TaxpayerIssuerListItem?` so the facility detail/edit load can
resolve the stored RFC to a display name (FR-034b) with a single request, no
per-row resolve.

### List-item view models for the four catalogs
Warehouses/CashDrawers/PointsOfSale/Facilities list rows reuse their detail
entity directly (all displayed columns are already on it) — no separate
list-item type is needed, matching how vehicles/expenses did it. (If a leaner row
projection is wanted at task time it is additive, not required.)

## Filter state objects (per list screen)

| Screen | Filter fields | Facet count source |
|---|---|---|
| Warehouses | `search`, `facilityId?`, `facilityDisplayText`, `status?` | facility + status |
| Cash Drawers | `search`, `facilityId?`, `facilityDisplayText`, `status?` | facility + status |
| Points of Sale | `search`, `facilityId?`, `facilityDisplayText`, `warehouseId?`, `warehouseDisplayText`, `status?` | facility + warehouse + status |
| Facilities | `search`, `status?` | status only |

Each has a `FilterBadge` extension (`activeFilterCount`, excluding `search`) and a
`reset()` preserving `search`, mirroring `ProductFilter`/`VehicleOperatorFilter`.

## Form state objects (per detail screen)

Standard `*FormState` freezed classes mirroring `VehicleOperatorFormState`:
loading/submitting/saved/deleted flags, `error`/`errorDetail`, `fieldErrors`
map, plus the entity's editable fields. FK fields are held as `id?` +
`displayText` pairs (as the operator form holds `driverId`/`driverDisplayText`).

- **Warehouse / Cash Drawer form**: `facilityId?`, `facilityDisplayText`, `code`,
  `name`, `comment`, `status`.
- **Point of Sale form**: adds `warehouseId?`, `warehouseDisplayText`; the
  warehouse `optionsBuilder` is scoped to `facilityId`, and changing the facility
  clears the warehouse when it no longer belongs (FR-022).
- **Facility form**: `code`, `name`, `type`, `locationId?`/`locationDisplayText`,
  `addressId?`/`addressDisplayText`, `taxpayerRfc`/`taxpayerDisplayText`, `logo`,
  `receiptMessage`, `defaultBatch`, `status`.
- **Address inline-create sub-state**: the `AddressCreate` fields
  (street/exteriorNumber/postalCode/neighborhood/borough/state/country required;
  interiorNumber/locality/city/nickname/type/comment optional), its own
  validation + submit, returning the created `AddressListItem` to the facility
  form.

## Validation (in `catalog_field_validators.dart`, reused/extended)

- **Required non-empty**: warehouse/cash-drawer/facility `code` and `name`;
  point-of-sale `code`/`name`; facility `location`, `address`, `taxpayer`;
  address required fields (§8).
- **FK required**: facility on warehouse/cash-drawer/point-of-sale; warehouse on
  point-of-sale; location/address on facility.
- **Taxpayer RFC shape**: ≤ 13 chars; shape only, never an existence claim
  (FR-034). Existence is the server's to reject (FR-012).
- Server `ValidationError`s map field-by-field via `_fieldErrorsFromServer`
  (the operator-form pattern), so a duplicate `code` or an unregistered taxpayer
  lands on the right field without discarding input (FR-012).

## Relationships

```
Facility 1──* Warehouse
Facility 1──* CashDrawer
Facility 1──* PointSale *──1 Warehouse   (PointSale.warehouse MUST belong to PointSale.facility — FR-022, backend-enforced mbe-api#102)
Facility *──1 Address      (pre-expanded on response)
Facility *──1 SatPostalCode(location, pre-expanded)
Facility *──1 TaxpayerIssuer (by RFC, NOT expanded)
```
