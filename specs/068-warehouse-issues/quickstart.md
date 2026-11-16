# Quickstart: Warehouse Issues (068)

This guide validates the feature end to end against the dev mbe-api.
- Contracts: [ui-contract.md](contracts/ui-contract.md), [repository.md](contracts/repository.md), [error-messages.md](contracts/error-messages.md).
- Entities and rules: [data-model.md](data-model.md).

## Prerequisites

- The dev mbe-api is running, and `.env` / `.env.settings` point to it.
- Accounts (`test/integration/TEST_ACCOUNTS.md`):
  - an administrator;
  - `qareadonly` and `qanoaccess`;
  - for steps 3 and 8, a non-administrator with read, create, update and delete on InventoryIssues (16), and read on Warehouses (4) and Products, assigned to a facility with a point-of-sale warehouse. None is seeded, so these steps are manual (research R9).
- In the dev tenant:
  - an active stockable product, P1, with available stock in warehouse W1, and a second stockable product, P2;
  - W2, a warehouse in another facility.
  - Confirming a receipt of P1 (spec 067) is an easy way to add stock.

## Automated checks

```bash
flutter test test/unit/features/inventory test/widget/features/inventory      # receipts suite still green after the move (research R1) + issues
flutter test test/unit/core/errors/catalog_coverage_test.dart test/unit/core/formatting_guard_test.dart test/unit/app/router/app_router_test.dart
flutter test test/integration/inventory_issues_live_test.dart --dart-define-from-file=.env.settings                    # read-only
MBE_WRITE=true flutter test test/integration/inventory_issues_live_test.dart --dart-define-from-file=.env.settings     # writes
MBE_WRITE=true flutter test test/integration/inventory_receipts_live_test.dart --dart-define-from-file=.env.settings   # receipts unchanged
flutter test integration_test/inventory_issues_quickstart_test.dart -d macos --dart-define-from-file=.env
```

Expected: everything passes, and the receipts tests pass with only renamed imports and symbols.

## Walkthrough

1. **Nav and gate.**
   - As the administrator: "Inventario" shows Entradas de almacén, then Salidas de almacén.
   - As `qanoaccess`: the group is absent, and `/inventory/issues` redirects to home.
2. **List.**
   - As the administrator: issues are newest first.
   - Filter Estado = Confirmada and Almacén = W1. The badge shows 2, and the rows match.
   - There is no Orden de compra column.
3. **Create** (manual, non-administrator).
   - Nueva salida starts with the user's point-of-sale warehouse.
   - The picker doesn't offer W2.
   - The notes field is labelled "Motivo / notas" and shows the hint.
   - Create opens "Salida · Borrador #{id}", and the list shows "Borrador #{id}".
4. **Header.**
   - As the administrator: change the warehouse to W2, and the Sucursal follows. Change it back to W1.
   - Clear the notes and reopen: no note is shown.
   - More than 500 characters can't be submitted.
5. **Lines.**
   - Add P1 × 2, then P1 × 1: one line with 3.
   - Add P2, edit it, then remove it.
   - A non-stockable product isn't offered.
   - A quantity of 0 can't be submitted.
6. **Insufficient stock.**
   - Note P1's available stock in W1 (`GET /stock/products/{P1}`).
   - On a draft, set P1's line to that stock + 1 and confirm.
   - The Spanish message shows the requested and available quantities, plus "Producto: P1 · Almacén: W1".
   - The issue stays "Salida · Borrador #{id}" (SC-003).
7. **Confirm and stock.**
   - Lower the line to 3 and confirm after the prompt, which says the stock is taken out.
   - The issue shows "Salida {folio}" and Confirmada, with no edit actions.
   - P1 in W1 dropped by 3 (SC-002).
   - An empty draft's confirm shows "La salida de almacén no tiene partidas."
8. **Cancel.**
   - Cancel a draft: it shows Cancelada.
   - Cancel the issue from step 7, after the prompt that says the stock goes back: P1 in W1 is back to its noted value.
   - A cancelled issue offers no actions.
   - As `qareadonly`: no Nueva salida, edit, Confirmar or Cancelar anywhere (SC-005).
   - Manual, as the non-administrator, on an administrator's draft in W2: Confirmar shows `facility.other_facility` in Spanish.
9. **Supplier-return fact.** If a legacy issue with a supplier return exists (the live test looks for one), its detail shows "Devolución a proveedor #{id}" as plain text.
10. **Largest text level.** At the largest text size, the list and lines tables don't clip or scroll sideways at 1280 px.

## Done when

- Every step behaves as described.
- No English server text appears on screen (SC-004).
- Recording and confirming a 10-product write-off takes under 3 minutes (SC-001).
