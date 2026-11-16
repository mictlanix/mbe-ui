# Quickstart: Warehouse Receipts (067)

This guide validates the feature end to end against the dev mbe-api. Contracts: [ui-contract.md](contracts/ui-contract.md), [repository.md](contracts/repository.md), [error-messages.md](contracts/error-messages.md). Entities and rules: [data-model.md](data-model.md).

## Prerequisites

- The dev mbe-api is running, and `.env` / `.env.settings` point to it.
- Accounts (see `test/integration/TEST_ACCOUNTS.md`, re-seeded by `tool/seed_test_accounts.py` after a DB reset):
  - an administrator;
  - a non-administrator with read, create, update and delete on InventoryReceipts (15) and read on Warehouses (4) and Products, assigned to a facility with a point-of-sale warehouse;
  - `qareadonly` (read only) and `qanoaccess` (no rights).
- In the dev tenant:
  - an active stockable product, P1 (and a second, P2);
  - an active non-stockable product, N1;
  - a warehouse, W1, in the non-administrator's facility, and a warehouse, W2, in another facility;
  - for step 8, a legacy receipt linked to a completed, under-received purchase order. The live test discovers one at runtime and skips the step when none exists.

## Automated checks

```bash
flutter test test/unit/features/inventory test/widget/features/inventory
flutter test test/unit/core/errors/catalog_coverage_test.dart test/unit/core/formatting_guard_test.dart test/unit/app/router/app_router_test.dart
flutter test test/integration/inventory_receipts_live_test.dart --dart-define-from-file=.env.settings                    # read-only
MBE_WRITE=true flutter test test/integration/inventory_receipts_live_test.dart --dart-define-from-file=.env.settings     # writes
flutter test integration_test/inventory_receipts_quickstart_test.dart -d macos --dart-define-from-file=.env
```

Expected: all pass. The coverage test lists the 9 new codes in both locales.

## Walkthrough

1. **Nav and gate.**
   - As the administrator: "Inventario → Entradas de almacén" appears between Logística and Facturación.
   - As `qanoaccess`: the group is absent, and `/inventory/receipts` shows the no-access screen.
2. **List scope and filters.**
   - As the non-administrator: only receipts for their POS warehouse or created by them appear, newest first.
   - Filter Estado = Confirmada, then Almacén = W1. The badge shows 2, and the rows match.
   - As the administrator: every receipt appears.
3. **Create.**
   - As the non-administrator: Nueva entrada → W1, with notes. The detail opens as "Entrada (borrador)" with no folio.
   - A note longer than 500 characters can't be submitted.
4. **In-transit warehouse.** In the warehouse picker, look for the facility's in-transit warehouse.
   - If it is listed, choose it. The server's `warehouse.in_transit_location` message appears in Spanish, and the warehouse is unchanged.
   - Record whether the list includes in-transit rows (research R5).
5. **Header.**
   - Editar encabezado → change the warehouse to W2. The Sucursal changes to W2's facility.
   - Clear the notes, save, and reopen: no note is shown (research R8).
   - Switch the warehouse back to W1.
6. **Lines.**
   - Add P1 × 3, then add P1 × 2. There is one P1 line with 5.
   - Add P2 × 1. Edit P2 to 4. Remove P2 after the prompt.
   - Try N1: it isn't offered by the picker. Typing its exact code also finds nothing.
   - A quantity of 0 can't be submitted.
7. **Confirm and stock.**
   - Note `GET /stock/products/{P1}` for W1.
   - Confirm after the prompt. The receipt shows "Entrada {folio}" and Confirmada, and has no edit actions.
   - The stock of P1 in W1 grew by 5 (SC-002).
   - Confirming an empty draft shows `inventory_document.no_lines` in Spanish.
8. **Purchase order, warnings and complementary** (skip if no fixture).
   - Open the linked receipt. Linked lines show Ordenado and Recibido en otras entradas.
   - Entrada complementaria opens a draft with the remaining quantities. Choosing it again from the source receipt opens the same draft.
   - On that draft, raise a line above its remainder: the over-receipt banner names the code and the excess, and Confirmar still works. The confirm prompt lists the warning.
   - The warehouse field is read-only on this draft.
   - On a receipt whose order is fully received, the action shows the "ya se recibió completa" reason.
9. **Cancel.**
   - Cancel a draft: it shows Cancelada.
   - Cancel the receipt from step 7: P1 in W1 is back to the noted value.
   - Confirm a new receipt of P1 × 5, issue or sell 3 from W1, then cancel: the insufficient-stock message shows the quantities and "Producto: P1", and the receipt stays Confirmada.
   - As `qareadonly`: no New, edit, Confirm, Cancel or Complementary actions anywhere (SC-004).
   - As the non-administrator, on a draft in W2 (another facility): Confirm shows `facility.other_facility` in Spanish.
10. **Largest text level.** Set the text size to the largest level. The list and the lines table don't clip or scroll sideways at 1280 px.

## Done when

- Every step behaves as described, with no English server text on screen (SC-003).
- Recording and confirming 10 products takes under 3 minutes (SC-001).
