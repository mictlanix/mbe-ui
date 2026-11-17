# Quickstart: Physical Inventory Counts (070)

This guide validates the feature end to end against the dev mbe-api.
- Contracts: [ui-contract.md](contracts/ui-contract.md), [repository.md](contracts/repository.md), [error-messages.md](contracts/error-messages.md).
- Entities and rules: [data-model.md](data-model.md).

## Prerequisites

- The dev mbe-api is running, and `.env` / `.env.settings` point to it.
- Accounts (`test/integration/TEST_ACCOUNTS.md`):
  - an administrator (`MBE_POS_*`, whose point-of-sale warehouse is W1);
  - `qareadonly` and `qanoaccess`;
  - for the non-administrator checks, an account with read, create, update and delete on PhysicalCountAdjustment (74), and read on warehouses and products. None is seeded, so these checks are manual.
- In the dev tenant, discovered at run time by the live tests:
  - stockable products P1 and P2 with stock in W1;
  - P3, a non-stockable product;
  - P4, a product with stock reserved by an open sales order in W1 (for the reservation warning).

## Automated checks

```bash
flutter test test/unit/features/inventory test/widget/features/inventory
flutter test test/unit/core/errors/catalog_coverage_test.dart test/unit/core/formatting_guard_test.dart test/unit/app/router/app_router_test.dart
flutter test test/integration/inventory_counts_live_test.dart --dart-define-from-file=.env.settings                  # read-only
MBE_WRITE=true flutter test test/integration/inventory_counts_live_test.dart --dart-define-from-file=.env.settings   # writes
caffeinate -dimsu flutter test integration_test/inventory_counts_quickstart_test.dart -d macos --dart-define-from-file=.env
```

Expected: everything passes. The receipts, issues and transfers suites are unchanged.

## Walkthrough

1. **Nav and gate.** As the administrator, Inventario lists Entradas, Salidas, Traspasos, then Conteos físicos. As `qanoaccess`, `/inventory/counts` redirects to home.
2. **List.** Counts are newest first. Filter Estado = Confirmado and Almacén = W1: the badge shows 2 and the rows match. The chips read "Confirmado" and "Cancelado" (masculine).
3. **Create.** Nuevo conteo starts with W1 selected. Create it with the comment "QA070". The title is "Conteo · Borrador #{id}", with no lines.
4. **Blind entry.** With quick entry, type P1's code and its stock + 3, then press Enter. The line shows only Contado. Enter P2 with 0. Enter P1 again with its stock + 1: the feedback reads "… → … (reemplazada)", and there is still one P1 line. Nowhere on the screen is an expected quantity shown.
5. **Refusals.** Quick entry with "NOEXISTE-070" shows "El producto no existe." and keeps the values. P3 via Agregar producto shows "no es inventariable".
6. **Paste.** Pegar lista with a header row: it is reported as row 1 and Enviar stays disabled. Remove the header and paste P1 `\t` 5 and P2 `\t` 2,5: it sends, and the lines are replaced (P2 = 2.5).
7. **Paste refusal.** Paste 2,001 rows where row 2,001 is an unknown code. Batch 1 is applied, batch 2 is refused, the dialog lists that code at row 2,001 and says 2,000 rows were applied. (The live test builds the rows from discovered codes.)
8. **Confirm.** Confirm with the checkbox off. The count shows its folio, the Confirmado chip and Esperado/Diferencia per line. W1's stock of P1 and P2 equals the counted quantities. There is no Cancelar.
9. **Large count timing.** On a draft, paste 15,000 rows (or as many stockable products as the tenant has), then time one quick entry. If it takes more than about 2 s, record it and file the mbe-api follow-up (research R4). Cancel the draft.
10. **Warnings.** Count P4 below its reservation and confirm: the band lists P4 with counted, reserved and available. Start drafts A and B on W1, both with P1. Confirm B, then A: A's band lists P1 with "conteo {B's folio}". Leave and reopen A: the band is gone.
11. **Uncounted.** On a draft with only P1, confirm with the checkbox on. The completed count has extra lines at Contado 0 for every other product that had stock in W1.
12. **Cancel and read-only.** Cancel a draft: it shows Cancelado with title "Conteo · Borrador #{id}". As `qareadonly`, a draft opens with no quick entry, no row icons and no actions.
13. **Largest text level.** At the largest text setting, the detail with the warnings band and the paste dialog do not overflow.
14. **Non-administrator (manual).** The warehouse picker offers only the user's facility's warehouses. Confirming another facility's draft shows the other-facility refusal.

Writes leave confirmed counts on W1. The live test restores P1's and P2's stock with a final count at their original quantities.
