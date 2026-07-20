# Contract: Routes, Navigation & RBAC Gating

**Feature**: `013-catalog-logistics-payment-entities` | **Date**: 2026-07-19

Mirrors the specs/011 + specs/012 router/nav wiring exactly. **The branch order
in `app_router.dart` MUST match the `NavBranch` index order in
`nav_destinations.dart`** (invariant documented in `nav_destinations.dart`). The
three new branches append after spec-012's last branch
(`taxpayerRecipients = 10`).

## 1. Shell branches (in `app_router.dart`)

Three new `StatefulShellBranch`es are appended to the existing indexed-stack
shell. Existing branches run home(0) … taxpayerRecipients(10). **Branch index is
positional** — append each at the next free position, in tasks.md build order
(Expenses→Vehicles→VehicleOperators, per story priorities US1→US2→US3):

| New branch index | Route | List screen | Story |
|---|---|---|---|
| 11 | `/expenses` | `ExpensesListScreen` | US1 |
| 12 | `/vehicles` | `VehiclesListScreen` | US2 |
| 13 | `/vehicle-operators` | `VehicleOperatorsListScreen` | US3 |

> This order MUST be replicated identically in `NavBranch` and
> `kNavigationTree` (`nav_destinations.dart`'s invariant), and each story's
> router-wiring task MUST append its branch at the position shown here, in build
> order — not skip ahead to a "reserved" future index.

## 2. Top-level detail/form sub-routes (siblings, full-screen, no rail)

All three entities use server-assigned `int` ids (standard `/new` + `/:id`
shape, identical to spec-012's int-id entities):

```
/expenses/new                          → ExpenseDetailScreen (create)
/expenses/:expenseId                   → ExpenseDetailScreen (view/edit)
/vehicles/new                          → VehicleDetailScreen (create)
/vehicles/:vehicleId                   → VehicleDetailScreen (view/edit)
/vehicle-operators/new                 → VehicleOperatorDetailScreen (create)
/vehicle-operators/:vehicleOperatorId  → VehicleOperatorDetailScreen (view/edit)
```

The detail screen opens read-only on row-click (`/:id`) and editable via the
AppBar read-only→edit toggle when the user holds update; `/new` opens editable.
Consistent with every spec-012 detail screen.

## 3. Route gating (`_routeGate` in `app_router.dart`)

Each location prefix maps to a `(SystemObject, AccessRight.read)` gate; deeper
create/update/delete gating happens in-screen via `accessControlProvider.can`.

| Location prefix | SystemObject | Right |
|---|---|---|
| `/expenses` | `SystemObject.expenses` (81) | `read` |
| `/vehicles` | `SystemObject.vehicle` (88) | `read` |
| `/vehicle-operators` | `SystemObject.vehicleOperators` (89) | `read` |

All three `SystemObject`s already exist in `system_object.dart` — no enum edit.

## 4. Navigation (`nav_destinations.dart`)

Three `NavDestination`s appended to the catalog group, each gated
`(object, read)` so the item is hidden without read privilege (FR-008). Add
`NavBranch` constants matching the router branch indices above:

```
static const int expenses = 11;
static const int vehicles = 12;
static const int vehicleOperators = 13;
```

| id | label (l10n) | icon (suggested) | route | branchIndex | gate |
|---|---|---|---|---|---|
| `expenses` | `_expensesLabel` | `Icons.receipt_long_outlined` | `/expenses` | `NavBranch.expenses` | `expenses`, read |
| `vehicles` | `_vehiclesLabel` | `Icons.local_shipping_outlined`¹ | `/vehicles` | `NavBranch.vehicles` | `vehicle`, read |
| `vehicleOperators` | `_vehicleOperatorsLabel` | `Icons.badge_outlined` | `/vehicle-operators` | `NavBranch.vehicleOperators` | `vehicleOperators`, read |

¹ Suppliers already uses `local_shipping_outlined`; pick a distinct fleet icon
for Vehicles to avoid ambiguity (e.g. `Icons.directions_bus_outlined` or
`Icons.airport_shuttle_outlined`). Final icon choices are a tasks.md detail;
the gate/route/branch wiring is the binding part.

## 5. RBAC action gating (in-screen)

| Action | Gate (per entity object) |
|---|---|
| Create button (list toolbar) | `can(object, AccessRight.create)` |
| Edit row icon / read-only→edit toggle | `can(object, AccessRight.update)` |
| Delete button (detail form body) | `can(object, AccessRight.delete)` |

Controls are **hidden**, not disabled, when the privilege is absent (§IV, FR-007,
SC-005). Objects: `expenses(81)`, `vehicle(88)`, `vehicleOperators(89)`.
