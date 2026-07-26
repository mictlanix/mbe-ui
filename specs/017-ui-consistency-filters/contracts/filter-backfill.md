# Contract: filter backfill — facets the client already accepts

**Feature**: `017-ui-consistency-filters` | Satisfies FR-009 – FR-016

Every facet below is **already accepted by the generated client**. No backend
change, no codegen re-run, no upstream dependency (research §5).

## 1. Full audit — client parameters vs repository parameters

Extracted from `lib/generated/openapi/lib/src/api/*_api.dart` and compared with each
`lib/features/*/domain/repositories/*.dart` `list()` signature, on `main` at `44b8e95`.

| Screen | Client accepts | Repository declares | Gap |
|---|---|---|---|
| **Vehicles** | `search`, `status` | `search` | **`status`** |
| **Vehicle Operators** | `search`, `employee`, `status` | `search`, `driverId` | **`status`** |
| **Users** | `search`, `status` | `search` | **`status`** |
| **Products** | `search`, `label`, `status`, `stockable`, `salable`, `purchasable`, `supplier` | all but `supplier` | **`supplier`** |
| Customers | `search`, `status`, `priceList`, `salesperson` | all four | — |
| Employees | `search`, `status`, `salesPerson` | all three | — |
| Warehouses | `search`, `facility`, `status` | all three | — |
| Cash Drawers | `search`, `facility`, `status` | all three | — |
| Points of Sale | `search`, `facility`, `warehouse`, `status` | all four | — |
| Facilities | `search`, `status` | both | — |
| Payment Method Options | `facility`, `status` | + `search` (wired, pending upstream) | tracked, unchanged |
| Exchange Rates | `dateFrom`, `dateTo`, `base_`, `target` | all four | — |
| Labels | `search` | `search` | — |
| Suppliers | `search` | `search` | — |
| Expenses | `search` | `search` | — |
| Price Lists | `search` | `search` | — |
| Taxpayer Recipients | `search` | `search` | — |
| Taxpayer Issuers | `search` | `search` | — |

Search-only screens stay search-only. A missing server-side facet is **never**
compensated for with client-side page filtering (FR-016).

## 2. The four changes

### 2.1 Vehicles — `status`

- `VehicleRepository.list` gains `EntityStatus? status`; impl forwards it.
- The screen has **no filter sheet today** and gains its first one:
  `CatalogFilterBar.filters` gets a filter button with an active-count badge, opening
  `showCatalogFilterSheet` containing `EntityStatusFilterChips`.
- **Correct the stale comment** at `vehicles_list_screen.dart:19-22`, which claims
  "the list endpoint exposes no facets beyond `search`". That was true when spec 013
  shipped; leaving it would re-teach the wrong thing.
- New keys: filter-sheet title. Status labels and "Filters"/"Clear all"/"Apply"
  already exist.

### 2.2 Vehicle Operators — `status`

- `VehicleOperatorRepository.list` gains `EntityStatus? status`; impl forwards it.
- The screen already has a filter sheet (employee picker); `EntityStatusFilterChips`
  is added below it, combinable with the existing facet (FR-010).
- Badge count goes from 1 possible facet to 2.

### 2.3 Users — `status`

- `UserRepository.list` gains `EntityStatus? status`; impl forwards it to
  `listUsersApiV1UsersGet`.
- The screen gains its first filter sheet, as Vehicles does.
- Note: `UsersController.refresh()` (`users_controller.dart:133`) already re-fetches
  the **current** page rather than invalidating — the one screen without the
  page-reset bug. Preserve that behavior through the conversion.

### 2.4 Products — `supplier`

- `ProductRepository.list` gains `int? supplier`; impl forwards it.
- The existing filter sheet gains a `CatalogEntityPicker<Supplier>` fed by
  `SupplierRepository`, alongside the current label / status / tri-state flag
  controls (FR-012).
- This is the one backfilled facet that is an FK, so it needs the cold-load
  id → label resolution from [list-query.md](./list-query.md) §8 and
  [../data-model.md](../data-model.md) §4.

## 3. Shared-control requirement (FR-013)

Every backfilled facet uses the controls the rest of the app already uses — no
module invents its own presentation:

| Facet type | Control | Reference implementation |
|---|---|---|
| status | `EntityStatusFilterChips` | `warehouses_list_screen.dart:169-186` |
| FK reference | `CatalogEntityPicker<T>` | `warehouses_list_screen.dart:146-166` |
| panel | `showCatalogFilterSheet` | `catalog_filter_sheet.dart` |
| badge | `activeFilterCount` extension on the filter value | `WarehouseFilterBadge` |

The Warehouses screen is the canonical template for a facility+status catalog and
should be followed structurally, not just visually.

## 4. Server-side only (FR-014)

Each facet is passed to the repository and reaches the client's query string.
Filtered totals and page counts come from the server's `total`, never from
`items.length`. A test asserts the repository received the facet, not merely that
the visible rows changed.

## 5. The standing audit (FR-015)

The table in §1 is a snapshot; it will go stale exactly the way
`vehicles_list_screen.dart:19` did. **Encode it as a test**:
`test/unit/features/repository_list_params_audit_test.dart` asserts, per entity,
that the repository's declared list parameters match a checked-in expected set.

- A **new** upstream facet appearing in the generated client fails the test, forcing
  a decision instead of silent drift.
- A deliberate omission is recorded by updating the expectation **with a comment
  giving the reason** — which is what makes FR-015's "recorded, with a reason"
  auditable rather than aspirational.

## 6. Test obligations

- Per backfilled facet: selecting it calls the repository with that value.
- Per backfilled facet: it round-trips through the URL ([list-query.md](./list-query.md) §9).
- Combining a new facet with an existing one passes both (FR-010, FR-012).
- Clearing returns the unfiltered list without a reload (FR-006 of the spec's US2).
- Filtered `total` and page count come from the server response.
- The audit test fails when a repository ignores a client parameter.
