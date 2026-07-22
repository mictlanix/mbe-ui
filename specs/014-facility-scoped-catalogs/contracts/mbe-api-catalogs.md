# Contract: mbe-api endpoints & DTOs consumed

All endpoints below are present in the client regenerated 2026-07-21. No codegen
is part of this feature; generated files are not hand-edited (constitution §III).
Method names are the generated dio names.

## Warehouses — `WarehousesApi` — RBAC `warehouses(4)`

| Op | Method | Notes |
|---|---|---|
| List | `listWarehousesApiV1WarehousesGet(search, facility, status, skip, limit)` | `ListResponseWarehouseResponse` |
| Get | `getWarehouseApiV1WarehousesWarehouseIdGet(warehouseId)` | `WarehouseResponse` |
| Create | `createWarehouseApiV1WarehousesPost(warehouseCreate)` | `WarehouseCreate{facility:int, code, name, comment?, status?}` |
| Update | `updateWarehouseApiV1WarehousesWarehouseIdPut(warehouseId, warehouseUpdate)` | all fields optional |
| Delete | `deleteWarehouseApiV1WarehousesWarehouseIdDelete(warehouseId)` | may 4xx if referenced → `ErrorBanner` |

`WarehouseResponse{warehouseId, facility: FacilitySummary, code, name, comment?, status}`.

## Cash Drawers — `CashDrawersApi` — RBAC `cashDrawers(10)`

Same operation shape as Warehouses with `cashDrawer`/`cashDrawerId` naming.
`CashDrawerResponse{cashDrawerId, facility: FacilitySummary, code, name, comment?, status}`.
List: `listCashDrawersApiV1CashDrawersGet(search, facility, status, skip, limit)`.

## Points of Sale — `PointsOfSaleApi` — RBAC `pointsOfSale(9)`

| Op | Method | Notes |
|---|---|---|
| List | `listPointsOfSaleApiV1PointsOfSaleGet(search, facility, warehouse, status, skip, limit)` | |
| Get / Create / Update / Delete | `…PointOfSale…` | `PointSaleCreate{facility:int, code, name, warehouse:int, comment?, status?}` |

`PointSaleResponse{pointSaleId, facility: FacilitySummary, code, name, warehouse: WarehouseSummary, comment?, status}`.
**Backend validates** `warehouse ∈ facility` on create+update (mbe-api#102) — a
mismatch 4xxs; surface it, don't pre-block (FR-022).

## Facilities — `FacilitiesApi` — RBAC `facilities(29)` *(FR-027 mirror fix)*

| Op | Method | Notes |
|---|---|---|
| List | `listFacilitiesApiV1FacilitiesGet(search, status, skip, limit)` | no `facility` facet |
| Get / Create / Update / Delete | `…Facility…` | |

`FacilityCreate{code, name, type?, location:String, address:int, taxpayer:String, logo?, receiptMessage?, defaultBatch?, status?}`
(`type` defaults Store; `logo` optional per mbe-api#91).
`FacilityResponse{facilityId, code, name, type: FacilityType, location: SatCatalogResponse (expanded), address: AddressResponse (expanded, mbe-api#101), taxpayer: String (RFC, NOT expanded), logo?, receiptMessage?, defaultBatch?, status}`.

## Addresses — `AddressesApi` — RBAC `addresses(11)` — *inline-create only*

| Op | Method | Used for |
|---|---|---|
| List | `listAddressesApiV1AddressesGet(search, type, status, skip, limit)` | facility address picker |
| Create | `createAddressApiV1AddressesPost(addressCreate)` | inline-create dialog (FR-031/032) |

`AddressCreate{nickname?, type?, street, exteriorNumber, interiorNumber?, postalCode, neighborhood, locality?, borough, state, city?, country, urlAddress?, comment?, status?}`.
`AddressResponse` expands all of the above + `addressId`. This feature uses list +
create only (no address get/update/delete, no address screens).

## Taxpayer Issuers — `TaxpayerIssuersApi` — RBAC `taxpayers(24)` — *autocomplete only*

| Op | Method | Used for |
|---|---|---|
| List | `listTaxpayerIssuersApiV1TaxpayerIssuersGet(search, skip, limit)` | facility taxpayer autocomplete |
| Get | `getTaxpayerIssuerApiV1TaxpayerIssuersRfcGet(rfc)` | optional single-issuer name resolve on facility detail (FR-034b) |

`TaxpayerIssuerResponse{taxpayerIssuerId (RFC), name?, regime?, provider, postalCode?, comment?}`.
Create/update/delete exist but are **out of scope** (FR-034a). The
`TaxpayerCertificatesApi` and `FiscalCertificationProvider` enum that shipped
alongside are **not consumed**.

## SAT Postal Codes — `SatCatalogsApi` (existing) — facility location picker

`listPostalCodesApiV1SatPostalCodesGet(search, …)` → `ListResponseSatCatalogResponse`,
already consumed by the product form's SAT pickers; reused unchanged for
`Facility.location` (FR-030).

## Upstream dependency status

**All resolved (verified 2026-07-21).** #86–#93 and #100–#102 are closed and
regenerated. No open cross-repo dependency. Full table in spec.md → Upstream
Dependencies.

## Error mapping (all endpoints)

`DioException` → shared `AppError` via `mapDioException`; `ValidationError`
field-mapped via `_fieldErrorsFromServer`; everything else → `error`/`errorDetail`
surfaced through `ErrorBanner`. No endpoint is pre-blocked on a guessed
constraint (duplicate `code`, referential delete, cross-facility warehouse,
unregistered taxpayer are all server-decided).
