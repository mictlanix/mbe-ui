# Phase 0 Research: Facilities and their Facility-Scoped Operational Catalogs

All decisions below were verified against the regenerated client under
`lib/generated/openapi/` and the mbe-api source at
`/Users/augusto/development/repos/mictlanix/mbe-api` during planning (2026-07-21).

## §1. Generated client is complete; zero open upstream dependency

**Decision**: Consume the already-generated `WarehousesApi`, `CashDrawersApi`,
`PointsOfSaleApi`, `FacilitiesApi`, `AddressesApi`, and `TaxpayerIssuersApi`
as-is. No codegen step is part of this feature.

**Rationale**: Every list method now takes `String? search` as its first
positional-optional param, ahead of the facet params:
- warehouses: `search, facility, status, skip, limit`
- cash-drawers: `search, facility, status, skip, limit`
- points-of-sale: `search, facility, warehouse, status, skip, limit`
- facilities: `search, status, skip, limit`
- addresses: `search, type, status, skip, limit` (create/get/update/delete present)
- taxpayer-issuers: `search, skip, limit` (get by RFC + create/update/delete present)

Nine mbe-api issues filed across this spec's life — #86–#89 (search), #90/#91
(address resource, optional logo), #92/#93 (facility-type names, facilities
`SystemObject`), #100/#101/#102 (taxpayer issuers, address expansion, PoS
validation) — are **all closed and regenerated into the client**. The spec's
Upstream Dependencies table records the resolutions.

**Alternatives considered**: Building against a not-yet-shipped param (the
spec-013 "ship the box wired ahead" posture) — unnecessary now that everything
landed.

## §2. RBAC-mirror correction (FR-027)

**Decision**: In `lib/core/access/system_object.dart`, rename `stores(29)` to
`facilities(29)` and remove `productionSites(107)`.

**Rationale**: mbe-api's `app/enums.py` defines `FACILITIES = 29` (reusing the
old stores slot) and no longer defines `STORES` or `PRODUCTION_SITES`. The
facilities endpoints gate on `require_privilege(SystemObject.FACILITIES, ...)`.
The app's mirror is therefore stale on both counts, and facility routes/nav must
gate on `facilities(29)` (FR-025).

**Guard**: before editing, grep the repo for `SystemObject.stores` and
`SystemObject.productionSites`. Legacy report objects (`storeMovementsSummary(99)`,
`searchCreditsFromAllStores(101)`) are separate constants and unaffected. Any
real consumer of `stores`/`productionSites` found is reported in the task, not
silently rebound.

**Alternatives considered**: Adding a new `facilities(29)` alongside the stale
entries — rejected: two enum members cannot share wire value 29, and leaving
`productionSites(107)` would imply an object the backend no longer has.

## §3. Warehouses and Cash Drawers are a near-verbatim pair

**Decision**: Implement Cash Drawers as a structural copy of Warehouses,
differing only in identifiers, route, l10n keys, and RBAC object.

**Rationale**: `WarehouseResponse` and `CashDrawerResponse` are both
`{id, facility: FacilitySummary, code, name, comment?, status}`; both
create/update take `{facility: int, code, name, comment?, status?}`; both list
endpoints expose `facility`/`status`. The only difference is the id field name
and the RBAC object (`warehouses(4)` vs `cashDrawers(10)`).

## §4. FK pickers reuse `CatalogEntityPicker`

**Decision**: Facility, warehouse, address, location, and taxpayer form fields
are all `CatalogEntityPicker<T>` constructions, one per referenced entity's
list-item view model.

**Rationale**: `lib/core/widgets/catalog_entity_picker.dart` is the exact widget
the customer form's salesperson picker (`CatalogEntityPicker<EmployeeListItem>`)
and the operator form's driver picker use — search-as-you-type, 300 ms debounce,
read-only `TextFormField` when `enabled: false`, `initialDisplayText` for the
loaded value. Each picker's `optionsBuilder` calls the corresponding
repository's `list(search: query)`.

## §5. `FacilityType` and `AddressType` domain enums

**Decision**: Add `lib/core/domain/facility_type.dart`
(`store(0)`, `productionSite(1)`) and `lib/core/domain/address_type.dart`
(`other(0)`, `home(1)`, `work(2)`, `business(3)`, `fiscal(4)`), each with
`fromApi`/`toApi` mappers, following the `EntityStatus`/`Gender` precedent.

**Rationale**: openapi-generator renders both wire enums as opaque
`number0`/`number1`/… constants (verified). The mapping is confirmed from the
mbe-api source (`app/enums.py`: `class FacilityType(IntEnum): STORE=0,
PRODUCTION_SITE=1`; `class AddressType(IntEnum): OTHER=0, HOME=1, WORK=2,
BUSINESS=3, FISCAL=4`). Naming them in exactly one place each (FR-026, FR-033)
keeps every screen off raw numbers, exactly as `entity_status.dart` documents
for its own case.

**Note**: `FiscalCertificationProvider` (`number0`–`number4`) has the same shape
but is **not consumed** by this feature (it rides on `TaxpayerIssuerResponse`,
which we read only for the autocomplete's RFC + name) — so no enum is added for
it.

## §6. Filter drawers: FK facet + status facet, both with precedent

**Decision**: Each list screen's `CatalogFilterSheet` combines an FK facet (a
`CatalogEntityPicker` for facility, plus warehouse on Points of Sale) with a
status facet (`EntityStatusControls`). Search stays outside the sheet in the
always-visible box.

**Rationale**: Two precedents exist and are combined unchanged —
- the **FK facet** is the vehicle-operators driver filter: an FK picker inside
  the filter sheet writing an id into the filter `Notifier`
  (`VehicleOperatorFilterController.driverSelected`);
- the **status facet** is the product/customer filter: an `EntityStatus?` where
  `null` == "All" (`ProductFilterController.statusChanged`), badged via the
  `activeFilterCount` extension.

Facilities has only the status facet (its endpoint exposes no `facility`);
Warehouses and Cash Drawers have facility + status; Points of Sale has facility +
warehouse + status.

## §7. Facility location = SAT postal-code picker

**Decision**: The facility form's `location` field is a
`CatalogEntityPicker<SatCatalogItem>` over `SatCatalogsApi.listPostalCodes`,
reusing the existing `SatCatalogRepository` path the product form's SAT pickers
already use.

**Rationale**: `FacilityCreate.location` is a SAT postal-code id (`String`);
`FacilityResponse.location` arrives pre-expanded as a `SatCatalogResponse`, so
display needs no extra fetch. `listPostalCodes` supports `search`, satisfying the
searchable-picker requirement (FR-030).

## §8. Address picker + inline create

**Decision**: The facility form's `address` field is a
`CatalogEntityPicker<AddressListItem>` over `AddressesApi.list`, with an inline
"create new address" affordance opening a Material 3 dialog whose body is a
`ResponsiveFormGrid` posting to `AddressesApi.create`. The inline-create
affordance is shown only when the user holds `addresses(11)` create privilege
(FR-032); without it the picker is present without the create path.

**Rationale**: Addresses have full CRUD but no screens of their own (a dedicated
Addresses catalog is out of scope), so a facility can otherwise only reference a
pre-existing address (FR-031). `AddressCreate` requires
`street, exteriorNumber, postalCode, neighborhood, borough, state, country` and
optionally `interiorNumber, locality, city, nickname, type, comment`. On success
the returned `AddressResponse` is selected on the facility form; a subsequent
facility-save failure does **not** roll it back (spec Edge Cases).

**Display**: `FacilityResponse.address` arrives pre-expanded (mbe-api#101), so
the selected/loaded address renders directly with no per-row fetch (FR-035).

## §9. Taxpayer autocomplete

**Decision**: The facility form's `taxpayer` field is a
`CatalogEntityPicker<TaxpayerIssuerListItem>` over `TaxpayerIssuersApi.list`,
matching by RFC and name, storing the selected issuer's `taxpayerIssuerId` (the
RFC) on the facility. Gated on `taxpayers(24)` read; if denied, it degrades to a
shape-validated typed RFC field (FR-034). No inline issuer create (FR-034a).

**Rationale**: `TaxpayerIssuersApi.list` supports `search`; `TaxpayerIssuerResponse`
carries `taxpayerIssuerId` (RFC) + nullable `name`. `FacilityCreate.taxpayer` is
the RFC string, so the stored value is identical whether picked or typed.

**Display**: `FacilityResponse.taxpayer` is **not** expanded — it is the bare
RFC. Per FR-034b the list shows the RFC (human-meaningful); the detail screen MAY
resolve the single issuer name via `TaxpayerIssuersApi.get(rfc)`. Never a
per-row resolve (§11).

## §10. Point-of-sale facility↔warehouse coupling

**Decision**: Scope the warehouse picker to the selected facility (its
`optionsBuilder` passes `facility: state.facilityId` to `warehouseRepo.list`),
and clear/require-reselect the warehouse when the facility changes to one the
current warehouse does not belong to (FR-022). Surface any server rejection via
`ErrorBanner`.

**Rationale**: mbe-api#102 shipped `_validate_warehouse_facility` on both
`create_point_sale` and `update_point_sale` (verified in
`app/services/point_sale_service.py`), validating the effective pairing when only
one side changes. The UI guard is therefore a convenience over a real backend
invariant, not the sole defense — so it MUST NOT be tested as if the backend
were permissive, and a slipped-through mismatch (e.g. a legacy record) still
loads and is surfaced on save if re-submitted.

## §11. No N+1 — every displayed FK is pre-expanded

**Decision**: No list or detail screen issues a per-row FK lookup.

**Rationale**: `WarehouseResponse.facility` → `FacilitySummary`;
`CashDrawerResponse.facility` → `FacilitySummary`; `PointSaleResponse.facility`
→ `FacilitySummary` and `.warehouse` → `WarehouseSummary`;
`FacilityResponse.location` → `SatCatalogResponse` and `.address` →
`AddressResponse` (mbe-api#101). Only `FacilityResponse.taxpayer` is unexpanded
(the bare RFC), and FR-034b forbids resolving it per row — the list shows the
RFC, the detail may resolve one issuer (§9).
