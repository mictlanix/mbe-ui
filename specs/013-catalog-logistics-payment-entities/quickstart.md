# Quickstart: Catalog Logistics Entities — Validation Guide

**Feature**: `013-catalog-logistics-payment-entities` | **Date**: 2026-07-19

Runnable validation for the three catalogs (Expenses, Vehicles, Vehicle
Operators). Prerequisites, commands, and the end-to-end golden path that proves
the feature works against a live mbe-api. Implementation detail belongs in
`tasks.md`, not here.

## Prerequisites

- A local mbe-api dev server running (default `http://127.0.0.1:8000`), reachable
  by mbe-ui's configured base URL (`.env`).
- A signed-in user whose privileges include read+create+update+delete on
  `expenses(81)`, `vehicle(88)`, and `vehicleOperators(89)`. (Admin
  short-circuits all of these.)
- At least one **employee** already present (for the Vehicle Operator's driver
  picker) — create one at `/employees` (spec 012) if none exists.

## Build / codegen / analyze

```bash
# regenerate freezed/riverpod parts for the new entities & controllers
dart run build_runner build --delete-conflicting-outputs

# regenerate localizations after editing app_en.arb / app_es.arb
flutter gen-l10n

# static analysis must be clean
flutter analyze
```

## Run the app

```bash
flutter run -d chrome   # or macos / windows / linux
```

## Golden path (cross-entity, proves the driver dependency)

This is the integration flow in
`test/integration/catalog_logistics_flow_test.dart` and the manual smoke test:

1. **Expenses** (User Story 1 — no dependency).
   - Go to **Expenses** (`/expenses`). Confirm the list paginates and the search
     box is present. (Search *results* depend on mbe-api#82 — see note below.)
   - Create an expense: enter a **name**, optional **comment**. Save.
   - Confirm it appears; row-click opens it read-only; the AppBar edit toggle
     switches to the editable form; edit the comment and save.
   - Open it again, **Delete** from the form body, confirm the dialog, verify it
     is gone.

2. **Vehicles** (User Story 2 — no dependency).
   - Go to **Vehicles** (`/vehicles`). Confirm list + search box.
   - Create a vehicle: **license plate**, **name**, **nickname**, **tons
     capacity** (integer), leave **Active** on. Save.
   - Confirm the active badge renders; edit the nickname; toggle Active off and
     confirm the badge updates; delete one.

3. **Vehicle Operators** (User Story 3 — depends on an existing employee).
   - Go to **Vehicle Operators** (`/vehicle-operators`). Confirm list + search
     box + the **driver filter** drawer.
   - Create an operator: open the **driver** picker, search an employee by name,
     select one; enter **license type**, **license number**, **issuing
     location**; pick **issue date** and **expiration date** via the date
     pickers (set expiration in the near future). Leave **Active** on. Save.
   - Confirm the row shows the **driver name** (not a raw id), the expiration
     date, and a **"days until expiry"** indicator (SC-002/SC-003/FR-019).
   - Open the filter drawer, pick that same driver, confirm the list narrows to
     that driver's operators; clear the filter.
   - Row-click opens read-only; edit toggle → change the issuing location →
     save; delete one.

## RBAC spot-check (SC-005)

- Sign in as a user **lacking** `vehicleOperators(89)` read → `/vehicle-operators`
  is not reachable and the nav item is hidden.
- Sign in as a user with read but **not** update on `vehicle(88)` → the Vehicles
  list shows no Edit row icon and the detail screen shows no edit toggle / delete.

## Note on search (external dependency)

The search box renders on all three screens (constitution §VI). Its *results*
become live once mbe-api ships the `search` param and the client is regenerated:

- Expenses → [mictlanix/mbe-api#82](https://github.com/mictlanix/mbe-api/issues/82)
- Vehicles → [mictlanix/mbe-api#83](https://github.com/mictlanix/mbe-api/issues/83)
- Vehicle Operators → [mictlanix/mbe-api#84](https://github.com/mictlanix/mbe-api/issues/84)

Until then, validate findability via pagination and (for operators) the driver
filter. No UI change is needed when the param lands — re-run codegen and the box
filters server-side.

## Expected outcomes

- 6 screens reachable and gated per `contracts/routes.md`.
- 100% of vehicle-operator rows show driver-by-name + a days-until-expiry
  indicator (SC-002/SC-003).
- No regression in the spec-012 employee picker (SC-005) — the same
  `CatalogEntityPicker`/`employeeRepositoryProvider` powers the driver field.
