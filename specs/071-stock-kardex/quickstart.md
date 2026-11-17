# Quickstart: Stock and Kardex (071)

This guide validates the feature end to end against the dev mbe-api.
- Contracts: [ui-contract.md](contracts/ui-contract.md), [repository.md](contracts/repository.md), [error-messages.md](contracts/error-messages.md).
- Entities and the source mapping: [data-model.md](data-model.md).

## Prerequisites

- The dev mbe-api is running, and `.env` and `.env.settings` point to it.
- Accounts:
  - the administrator (`MBE_POS_*`, whose point-of-sale warehouse is warehouse 12);
  - `qanoaccess`;
  - for the right checks, a non-administrator with read on 67 but not 32, and one with read on 32 but not 67. Neither is seeded, so those checks are manual.
- Known data in the dev tenant, from specs 067–070:
  - warehouse 15 holds products 2926, 6483, 21998 and 14342, with QA070 counts and their restoring counts;
  - warehouse 12 holds product 1999, which has a reservation, and products 2368 and 7352, which have QA070 counts.
  - The live test discovers its fixtures at run time and doesn't rely on these ids.

## Automated checks

```bash
flutter test test/unit/features/inventory test/widget/features/inventory test/widget/features/catalog test/widget/core
flutter test test/unit/core/errors/catalog_coverage_test.dart test/unit/core/formatting_guard_test.dart test/unit/app/router/app_router_test.dart test/unit/core/navigation
flutter test test/integration/stock_kardex_live_test.dart --dart-define-from-file=.env.settings --dart-define-from-file=.env
caffeinate -dimsu flutter test integration_test/stock_kardex_quickstart_test.dart -d macos --dart-define-from-file=.env
```

Expected: everything passes. The live test is read-only: these screens write nothing, so it needs no `MBE_WRITE`.

## Walkthrough

1. **Nav and gate.** As the administrator, Inventario lists Entradas, Salidas, Traspasos, Conteos físicos, Existencias, then Kardex. As `qanoaccess`, `/inventory/stock` and `/inventory/kardex` redirect to home.
2. **Existencias start.** Opening Existencias starts on warehouse 12. The selection strip names it, and the URL carries `warehouse=12`.
3. **Figures.** Product 1999's available quantity equals its on hand minus its reserved quantity. Negative figures, if any, show with a minus sign.
4. **Search and switch.** Searching part of a code narrows the list. Turning on "Mostrar sin existencia" adds products with every figure at zero. Reloading the page keeps the warehouse, search and switch.
5. **In-transit warehouse.** Choosing a facility's in-transit warehouse shows the Spanish in-transit refusal and an empty list.
6. **Product view.** Tapping product 2926 in warehouse 15 opens "Existencias · {code} {name}". The view lists every warehouse with stock, and the totals strip sums them. A product on a dispatched transfer also shows its En tránsito section.
7. **To the kardex.** "Ver kardex" on the warehouse 15 row opens Kardex with product 2926, warehouse 15 and the last 30 days.
8. **Kardex balance.** The opening balance plus Entradas minus Salidas equals the final balance, and the final balance equals Existencias' on-hand figure for that product and warehouse (SC-002). The QA070 count rows show "Conteo físico" with their folios.
9. **Document links.** Tapping a count row opens that count, and back returns to the same kardex. A row of a type with no screen (itinerary, purchase order) shows "#id" and does nothing.
10. **Invalid range.** Setting a range longer than 366 days shows "El rango no puede pasar de 366 días." with no request. An end date before the start shows the reversed-range text.
11. **Catalog link.** In Productos, open product 2926 in View mode: "Ver existencias" is there and opens the same product view as step 6. In edit mode the button is absent.
12. **Largest text level.** The three screens, with long product names, don't clip or scroll sideways.
13. **Rights (manual).** With 67 read only, Existencias and the product view work, but the kardex nav entry and "Ver kardex" are absent. With 32 read only, Kardex works, but Existencias and "Ver existencias" are absent.
