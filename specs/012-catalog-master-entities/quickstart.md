# Quickstart: Catalog Master Entities — Validation Guide

**Feature**: `012-catalog-master-entities` | **Date**: 2026-07-19

Runnable validation for the five catalogs. Prerequisites, commands, and the
end-to-end golden path that proves the feature works against a live mbe-api.
Implementation detail belongs in `tasks.md`, not here.

## Prerequisites

- A local mbe-api dev server running (default `http://127.0.0.1:8000`), reachable
  by mbe-ui's configured base URL (`.env`).
- A signed-in user whose privileges include read+create+update+delete on
  `customers(2)`, `suppliers(3)`, `employees(6)`, `labels(1)`, and
  `taxpayerRecipients(54)`. (Admin short-circuits all of these.)
- At least one price list already present (for the Customer price-list picker) —
  create one at `/price-lists` if none exists.

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

## Golden path (cross-entity, proves the dependency chain)

This is the integration flow in `test/integration/catalog_master_flow_test.dart`
and the manual smoke test:

1. **Employees first** (User Story 3 — no dependency).
   - Go to **Employees** (`/employees`). Confirm the list paginates and searches.
   - Open the filter drawer; toggle **Active** and **Sales person** tri-states;
     confirm the list narrows and the filter badge counts.
   - Create an employee: first/last/nickname, pick **Gender**, pick **Birthday**
     and **Start date** via the date pickers, tick **Sales person**. Save.
   - Confirm it appears in the list; row-click opens it read-only; the AppBar
     edit toggle switches to the editable form.

2. **Suppliers & Labels** (User Story 1 & 2 — no dependency).
   - **Suppliers** (`/suppliers`): create a supplier (code+name, a credit limit
     like `1000.50`), confirm it saves, edit the credit limit, delete it.
     The credit-limit round-trip proves the `AnyOf` write path.
   - **Labels** (`/labels`): create a label, then open the **product form** and
     confirm the new label is selectable in the label picker (proves
     `allLabelsProvider` invalidation, FR-014). Rename it, confirm the change
     shows on a product already tagged with it.

3. **Customers** (User Story 4 — depends on Employees + price list).
   - Go to **Customers** (`/customers`). Create a customer: code+name, pick a
     **Price list** from the picker, search the **Salesperson** picker for the
     employee created in step 1 and select them. Save.
   - Confirm the list shows the salesperson **by name** (not an id) and the
     price list **by name**.
   - Open the filter drawer; filter by **disabled** tri-state, by that **price
     list**, and by that **salesperson**; confirm each narrows the list.
   - Create a second customer with **no** salesperson; confirm it renders the
     "none assigned" fallback.

4. **Taxpayer Recipients** (User Story 5 — depends on the new SAT pickers).
   - Go to **Taxpayer Recipients** (`/taxpayer-recipients`). Create one: type a
     **tax id** (e.g. `XAXX010101000`), name, email, then search+select a
     **Postal code** and a **Tax regime** from their pickers. Save.
   - Confirm the list/detail show postal code and regime **by description**.
   - Open the record for edit; confirm the **tax id is not editable**.
   - Attempt to create another with the **same tax id**; confirm a clear
     rejection message (FR-027), not a silent overwrite or opaque failure.

## RBAC checks (constitution §IV / FR-007)

- Sign in as a user lacking read on one catalog (e.g. `employees`); confirm the
  nav item is hidden and navigating directly to `/employees` redirects to `/`.
- Sign in as a user with read but not update on `customers`; confirm no Edit
  row icon, no Save/Delete on the detail screen, and the read-only view still
  renders every field (including salesperson/price-list names).

## Endpoint coverage (drift check)

The golden path exercises `list`/`get`/`create`/`update`/`delete` on all five
entity APIs plus `listPostalCodes`/`listTaxRegimes` on `SatCatalogsApi`. If the
committed generated client has drifted from the running mbe-api, one of these
calls fails loudly (4xx/5xx surfaced via `ErrorBanner`) rather than silently —
that is the intended signal to re-run codegen (research.md §2).

## Regression guard (SC-005)

After the above, reopen the **product form**: confirm the supplier picker, the
unit-of-measurement / SAT-key pickers, the label multi-picker, and the products
list's label filter all still work unchanged — the Suppliers/Labels promotion to
full CRUD must not regress their existing read-only consumers.
