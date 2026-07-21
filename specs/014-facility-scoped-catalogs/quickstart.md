# Quickstart: Validating Facilities & Facility-Scoped Catalogs

A runnable validation guide for the four catalogs. Assumes a local mbe-api with
a user holding read/create/update/delete on `facilities(29)`, `warehouses(4)`,
`pointsOfSale(9)`, `cashDrawers(10)`, plus read on `addresses(11)` and
`taxpayers(24)` (and create on `addresses(11)` to exercise inline-create).

## Prerequisites

- mbe-api running locally (default `http://127.0.0.1:8000`) with at least one
  registered taxpayer issuer and one SAT postal code available.
- `flutter pub get` done; app pointed at the local API.
- No codegen needed — the client is already regenerated (research.md §1). If the
  API spec changes, regenerate per the repo's codegen script; never hand-edit
  generated files.

## Run

```bash
flutter run -d chrome   # or macos/windows/linux
```

## Golden-path scenario (proves the whole feature end to end)

1. **Facilities → Create** (`/facilities/new`). Enter code + name; pick a type
   (Store/Production Site); pick a **location** via the SAT postal-code
   autocomplete; open the **address** picker and use **New address** to create
   one inline (street, exterior number, postal code, neighborhood, borough,
   state, country); pick a **taxpayer** from the autocomplete. Save.
   → new facility appears in the list showing code, name, type, status
   (SC-008, FR-028/031/034).
2. **Warehouses → Create** (`/warehouses/new`). Pick the facility just created,
   enter code + name. Save. → appears in the list with the facility shown **by
   name** (SC-002, FR-013/015).
3. **Points of Sale → Create**. Pick the same facility; open the **warehouse**
   picker → only that facility's warehouses are offered; pick the warehouse from
   step 2; enter code + name. Save. → appears with facility and warehouse both by
   name (FR-019/021/022).
4. **Cash Drawers → Create**. Pick the facility, enter code + name. Save
   (FR-016).
5. **Filter**: on each list, open the filter drawer and narrow by facility (and
   by warehouse on Points of Sale) and by status; confirm the badge count and
   that combining with the search box works (FR-003, SC-003).
6. **View / Edit / Delete**: row-click opens read-only; the edit toggle appears
   only with update privilege; delete lives in the detail body and confirms
   first (FR-005/006/007).

## Targeted checks

- **RBAC hiding** (SC-005): with a user lacking update on warehouses, the Edit
  icon and edit toggle are absent; lacking read on a catalog, its nav entry and
  route are gone.
- **Address inline-create gating** (FR-032): with a user lacking create on
  `addresses(11)`, the address picker shows **without** the New-address path.
- **Taxpayer degrade** (FR-034): with a user lacking read on `taxpayers(24)`,
  the taxpayer field is a shape-validated typed RFC entry, not an autocomplete.
- **Cross-facility warehouse rejection** (FR-022, mbe-api#102): if a mismatched
  pairing is somehow submitted, the server rejection surfaces via `ErrorBanner`
  without losing input.
- **Duplicate code** (FR-012): saving a warehouse with an existing code surfaces
  the rejection on the form, input preserved.
- **No N+1** (SC-002/009): a facilities list page renders addresses and
  locations with no extra per-row requests (all pre-expanded, research.md §11).
- **FR-027**: facility routes/nav gate on `facilities(29)`; a repo grep confirms
  no lingering `SystemObject.stores` / `productionSites` consumer.

## Automated coverage

- **Unit** (`test/unit/features/catalog/`): `fromResponse` mapping incl.
  FK-summary expansion and the unexpanded taxpayer RFC; `FacilityType`/
  `AddressType` round-trip; validators (required fields, RFC ≤13 shape).
- **Widget** (`test/widget/features/catalog/`): each of the 8 screens
  (read-only vs editable, filter drawers, empty states, RBAC hiding) + the
  inline-address dialog + the addresses-gated create path.
- **Integration** (`test/integration/facility_catalogs_flow_test.dart`): the
  golden-path chain above against a local mbe-api.
