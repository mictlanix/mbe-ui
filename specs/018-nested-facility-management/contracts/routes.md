# Contract: Routes, Navigation Branches and Access Guards

**Feature**: `018-nested-facility-management`

This contract governs `lib/core/navigation/nav_destinations.dart` and
`lib/app/router/app_router.dart`. The invariant it protects — **`NavBranch`
constants must equal the positional index of their `StatefulShellBranch` in the
router's build order** — has been carried by every spec since 010 and is the
easiest thing in this feature to break.

---

## 1. Navigation destinations

### Removed from `kNavigationTree`

| id | route | branch | gate |
|---|---|---|---|
| `warehouses` | `/warehouses` | 14 | `warehouses:read` |
| `cash-drawers` | `/cash-drawers` | 15 | `cashDrawers:read` |
| `points-of-sale` | `/points-of-sale` | 16 | `pointsOfSale:read` |

Their label tear-offs (`_warehousesLabel`, `_cashDrawersLabel`,
`_pointsOfSaleLabel`) are removed with them. The **l10n keys they resolved are
kept** and reused as child-section headers (research §8).

### Retained

`facilities` keeps id, route `/facilities` and gate `facilities:read`. Its
position in the Catálogos group is unchanged. The stale comment above it
("Facilities is the parent of the three catalogs above") must be updated — the
three catalogs are no longer above it, or anywhere.

---

## 2. Branch renumbering

`NavBranch` after this feature. Branches 0–13 are byte-identical; only the last
three constants move.

```
home 0 · users 1 · products 2 · priceLists 3 · pricing 4 · exchangeRates 5
suppliers 6 · labels 7 · employees 8 · customers 9 · taxpayerRecipients 10
expenses 11 · vehicles 12 · vehicleOperators 13
facilities 14      (was 17)
paymentMethodOptions 15  (was 18)
taxpayerIssuers 16       (was 19)
```

Correspondingly, the three `StatefulShellBranch` entries at
`app_router.dart:216-243` are deleted so that `/facilities` becomes the 15th
branch (index 14) in build order.

**Verification**: `test/unit/app/router/app_router_test.dart` MUST assert that for
every `NavDestination` in `kNavigationTree`, navigating to its `route` activates
the shell branch at its `branchIndex`. A hand-checked table is not sufficient —
this invariant has no compile-time enforcement.

---

## 3. Routes removed

| Path | Screen |
|---|---|
| `/warehouses` | `WarehousesListScreen` |
| `/cash-drawers` | `CashDrawersListScreen` |
| `/points-of-sale` | `PointsOfSaleListScreen` |

No redirect is added. These paths cease to resolve.

---

## 4. Routes retained, with one addition

All six child record routes survive unchanged in path and privilege:

```
/warehouses/new              /warehouses/:warehouseId
/cash-drawers/new            /cash-drawers/:cashDrawerId
/points-of-sale/new          /points-of-sale/:pointSaleId
```

The three `/new` routes gain an **optional** `?facility=<id>` query parameter,
parsed by the route builder and passed to the screen as `facilityId`:

```
/warehouses/new?facility=7
```

Absent or unparseable → `null` → the form opens with an empty facility picker,
exactly as today. This mirrors the existing `?view=true` handling on the
`:id` routes.

`/facilities/new` and `/facilities/:facilityId` are unchanged.

---

## 5. Access guards — DO NOT DELETE

`_gateFor(location)` at `app_router.dart:617-625` contains:

```dart
if (location.startsWith('/warehouses'))     return (warehouses,    read);
if (location.startsWith('/cash-drawers'))   return (cashDrawers,   read);
if (location.startsWith('/points-of-sale')) return (pointsOfSale,  read);
```

These are **prefix** matches. They gate `/warehouses/new` and
`/warehouses/:warehouseId` as much as `/warehouses`. All three clauses MUST be
kept verbatim.

Deleting them alongside the list screens is the intuitive move and it is wrong:
it would leave every surviving warehouse, cash-drawer and point-of-sale record
screen with no route-level RBAC, violating constitution §IV and FR-003. Because
the screens themselves also check privileges, the resulting hole would not show
up as a crash or a failing existing test — only as records reachable by URL that
should not be.

**Verification**: an explicit test asserting that a user lacking
`warehouses:read` is redirected away from `/warehouses/5`, and likewise for the
other two objects.

---

## 6. Navigation-tree filtering is unchanged

`navDestinationsProvider` and `_filterTree` are untouched. A user lacking
`facilities:read` sees no Facilities destination and, with the other three gone,
reaches none of the four catalogs — the accepted consequence recorded in
spec.md Assumptions.
