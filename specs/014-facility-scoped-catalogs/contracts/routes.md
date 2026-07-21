# Contract: Routes, Navigation & RBAC gating

## Routes (`app_router.dart`)

Four new `StatefulShellBranch`es, each a list route + a detail route, appended
**after** the existing vehicle-operators branch (index 13). Detail route carries
the id; create uses the same detail screen with a null id.

| Branch | List route | Detail route | RBAC gate (read) |
|---|---|---|---|
| Facilities | `/facilities` | `/facilities/new`, `/facilities/:id` | `facilities(29)` |
| Warehouses | `/warehouses` | `/warehouses/new`, `/warehouses/:id` | `warehouses(4)` |
| Points of Sale | `/points-of-sale` | `/points-of-sale/new`, `/points-of-sale/:id` | `pointsOfSale(9)` |
| Cash Drawers | `/cash-drawers` | `/cash-drawers/new`, `/cash-drawers/:id` | `cashDrawers(10)` |

Each list route is wrapped by `_routeGate(object, AccessRight.read)` exactly as
the spec-012/013 catalog routes are. Route order MUST match the NavBranch order
below.

## Navigation (`nav_destinations.dart`)

Four new `NavDestination`s under the Catalogs group, and four new `NavBranch`
index constants **appended in the same order** as the router branches:

```
static const int facilities = 14;
static const int warehouses = 15;
static const int pointsOfSale = 16;
static const int cashDrawers = 17;
```

Each destination sets `gate: (object: SystemObject.<obj>, right: AccessRight.read)`
so `navDestinationsProvider` hides it without read privilege (constitution §IV).
Suggested placement: Facilities first (it is the parent), then Warehouses, Points
of Sale, Cash Drawers.

**Invariant** (documented at `nav_destinations.dart`, honored by specs 012/013):
the Nth `NavBranch` index MUST correspond to the Nth `StatefulShellBranch` in
`app_router.dart`. Add to both in the same order in the same change.

## RBAC gating summary (constitution §IV)

| Surface | Gate |
|---|---|
| Route + nav (per catalog) | `can(object, Read)` |
| Create button (per catalog) | `can(object, Create)` |
| Row Edit icon + detail edit toggle | `can(object, Update)` |
| Detail delete button | `can(object, Delete)` |
| Facility address **inline-create** affordance | `can(addresses(11), Create)` — hidden if absent; picker still shown (FR-032) |
| Facility taxpayer **autocomplete** read | `can(taxpayers(24), Read)` — degrades to typed RFC field if absent (FR-034) |
| Facility location picker read | `can(facilities(29), Read)` is the screen gate; SAT catalogs are reference data |

Mutating controllers re-check the privilege immediately before submit (the
operator-form pattern), since it may have been revoked since the form opened.

## FR-027 mirror correction

`system_object.dart`: `stores(29)` → `facilities(29)`; remove
`productionSites(107)`. Grep `SystemObject.stores` / `SystemObject.productionSites`
first; report any real consumer rather than silently rebinding (research.md §2).
