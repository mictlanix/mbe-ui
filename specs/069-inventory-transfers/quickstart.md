# Quickstart: Inventory Transfers (069)

This guide validates the feature end to end against the dev mbe-api.
- Contracts: [ui-contract.md](contracts/ui-contract.md), [repository.md](contracts/repository.md), [error-messages.md](contracts/error-messages.md).
- Entities, states and action availability: [data-model.md](data-model.md).

## Prerequisites

- The dev mbe-api is running, and `.env` / `.env.settings` point to it.
- Accounts (`test/integration/TEST_ACCOUNTS.md`):
  - the `MBE_POS_*` administrator;
  - `qareadonly` and `qanoaccess`;
  - for step 9, a non-administrator with read, create, update and delete on InventoryTransfers (17), and read on Warehouses (4), Products and Sales orders, assigned to a facility with a point-of-sale warehouse. None is seeded, so step 9 is manual (research R12).
- In the dev tenant:
  - W1 and W2, two warehouses in facility F1, and W3 in facility F2;
  - F1 and F2 each have an in-transit warehouse. If one doesn't, dispatch shows "no tiene almacén en tránsito", which is worth recording;
  - P1 and P2, active stockable products with at least 10 available at W1. Confirming a receipt (spec 067) adds stock;
  - SO1, a completed sales order with stockable lines.

## Automated checks

```bash
flutter test test/unit/features/inventory test/widget/features/inventory
flutter test test/unit/core/errors/catalog_coverage_test.dart test/unit/core/formatting_guard_test.dart \
  test/unit/core/navigation/nav_destinations_test.dart test/unit/app/router/app_router_test.dart
flutter test test/integration/inventory_transfers_live_test.dart --dart-define-from-file=.env.settings --dart-define-from-file=.env                          # read-only
flutter test test/integration/inventory_transfers_live_test.dart --dart-define-from-file=.env.settings --dart-define-from-file=.env --dart-define=MBE_WRITE=true  # writes
caffeinate -dimsu flutter test integration_test/inventory_transfers_quickstart_test.dart -d macos --dart-define-from-file=.env
```

Expected: everything passes, and the receipts and issues suites are unchanged.

## Walkthrough

1. **Nav and gate.**
   - As the administrator, "Inventario" shows Entradas, Salidas, then Traspasos.
   - As `qanoaccess`, `/inventory/transfers` redirects to home.
2. **List.**
   - Transfers are listed newest first.
   - Filter Estado = En tránsito and Almacén = W2. Transfers where W2 is the origin or the destination appear, and the badge shows 2.
3. **Create and dispatch** (US2).
   - Nuevo traspaso: the origin starts at the POS warehouse. Pick W1 → W2.
   - The title reads "Traspaso · Borrador #{id}".
   - Choosing W1 → W1 in Editar encabezado shows "deben ser distintos".
   - Add P1 × 4, then P1 × 2: one line of 6. Add P2 × 3.
   - Despachar: the folio appears, the state is En tránsito, and the lines show Enviado / Recibido 0 / Pendiente.
   - In stock: W1 has P1 −6 and P2 −3, and W2 is unchanged.
   - SC-001: time a draft of 10 products from Nuevo traspaso to Despachar. Expect under 3 minutes, and note the time in the PR.
4. **Insufficient stock.**
   - A new draft W1 → W2 with P1 at available + 1. Despachar shows the stock message plus "Producto: P1 · Almacén: W1".
   - The transfer stays a draft, with no folio.
5. **Receive** (US3).
   - On the step 3 transfer, Recibir: the rows show 6 and 3, prefilled.
   - Change P1 to 4. Entering 7 shows a field error and disables Recibir. Receive 4 and 3.
   - The transfer stays En tránsito, P1 Pendiente 2. W2 has +4 P1 and +3 P2.
   - Recibir again with the dialog unchanged: the transfer becomes Recibido.
   - SC-002: time a full receipt (open the transfer, Recibir, accept), expecting under 30 seconds, and a receipt with two lowered lines, expecting under 1 minute. Note both in the PR.
6. **Close the remainder** (US4).
   - Dispatch a new W1 → W3 transfer of P1 × 5 (cross-facility). Receive 3.
   - Cerrar pendiente: the transfer is Recibido, the line shows 5 / 3 / 0, and W1 has P1 +2 back.
7. **Cancel** (US6).
   - Cancel a draft: Cancelado, and the title keeps "Borrador #".
   - Cancel the step 5 transfer: W1 and W2 are back to their pre-dispatch stock.
   - On a received transfer whose destination has since issued the goods (Salida de almacén at W2), cancel shows the stock message naming W2.
8. **Fill from a sales order** (US8).
   - On a draft that already has one of SO1's products, Agregar desde pedido → SO1. The missing products are added, the existing line is unchanged, and the snackbar reports the count.
   - Repeat: "ya estaban en el traspaso".
9. **Non-administrator (manual).**
   - The origin picker shows F1 warehouses only, and the destination picker shows every warehouse.
   - In-transit: no facility picker, and the title names F1.
   - Recibir a transfer whose destination is in F2: the "otra sucursal" refusal is shown.
10. **In transit** (US7).
    - From the list, En tránsito: F1's outstanding lines (both directions) and per-product totals.
    - As the administrator, switch to F2. A row opens its transfer.
11. **Read-only.**
    - As `qareadonly` (with read on 17): no Nuevo traspaso, and no detail actions on any state.
12. **Largest text level.**
    - The list, detail, receive dialog and in-transit screen have no overflow (widget large-text test, plus a manual look on macOS).
