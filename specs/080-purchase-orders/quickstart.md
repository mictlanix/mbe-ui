# Quickstart: Purchase Orders with Receipts, PDF and Email (080)

How to prove the feature works end to end. Behaviour is specified in [spec.md](spec.md) and [contracts/ui-contract.md](contracts/ui-contract.md); this is only the run guide.

## Prerequisites

- mbe-api with the purchase-order routes (spec 031, migration 028) on the dev tenant. Mail configured for step 10 (without it, expect the 503 message).
- `.env` with `MBE_POS_*` (the admin account, which holds 20, 86, 96 and 15) and `.env.settings`.
- In the tenant: a purchasable product with a supplier and a cost; a purchasable product without cost; a non-stockable purchasable product (a service); a supplier with a contact email (point it at a mailbox you can read); two non-transit warehouses in different facilities. The live test makes its own approved request with marked lines through the 079 repository.

## Automated checks

```bash
# unit + widget (never with the .env defines)
flutter test test/unit/features/purchases test/widget/features/purchases \
  test/unit/core/navigation test/unit/app/router test/unit/core/documents \
  test/unit/core/errors/catalog_coverage_test.dart

# live repository test (writes only with MBE_WRITE=true)
flutter test test/integration/purchase_orders_live_test.dart \
  --dart-define-from-file=.env.settings --dart-define-from-file=.env --dart-define=MBE_WRITE=true

# device walkthrough on macOS (keep the machine awake: caffeinate -dims)
flutter test integration_test/purchase_orders_quickstart_test.dart -d macos \
  --dart-define-from-file=.env.settings --dart-define-from-file=.env
```

## Walkthrough (also automated by the device test)

1. **Navigation.** As admin, Compras shows Solicitudes de compra, Aprobación de solicitudes, Por comprar and Órdenes de compra. As `qanoaccess`, neither new entry shows and `/purchases/orders` redirects home.
2. **Por comprar.** Approve a request with two marked lines (one with a supplier, one without cost). Por comprar shows its supplier group with the line count and estimate, the costless line as "sin costo". A "Sin proveedor" group, if any, has no Crear orden. Filter by Sucursal: only that facility's groups.
3. **Create from a group.** Crear orden: the new draft opens with the group's lines priced at cost, the costless one at 0 with the price-0 warning. Back: the group is gone. **Timed (SC-001, manual):** group to confirmed order in under 1 minute.
4. **Create by hand.** Nueva orden with a supplier, a date and notes. Past dates are not selectable.
5. **Header.** Change the date, then clear the notes and the date: reopen and check both are empty (research R7).
6. **Lines.** Add a product with quantity 2: it lands in the admin's POS warehouse at its cost and tax rate. Edit it: warehouse in the other facility, quantity 1.2345, price 10.1234567, IVA 0 %. Try quantity 0 and 1.23456: refused by the dialog. Delete it.
7. **Request lines.** Add the lines of an approved request already ordered in step 3: the SnackBar says they were already on another order (or `nothing_to_add`). Add another approved request's lines: added, with "Sol. {serial}" under each product.
8. **Confirm.** Confirm the hand order with lines for two warehouses and one service line: the prompt names both warehouses and any price-0 line. After: Confirmada, Entradas lists two receipts (the service line gets none), each opens the receipt screen. Reload the order: the Entradas section is gone (until mbe-api#355). Recibido 0 / Pendiente = ordered; the service line shows "—".
9. **Receive.** Confirm one of the receipts in Inventario, reopen the order: that warehouse's lines show Recibido = ordered, Pendiente 0. Open the receipt: its "Orden de compra" is a link back to the order (FR-030); the request detail's order column links too.
10. **Print and email.** Imprimir shows the PDF. Enviar por correo suggests the supplier's contact; add a second address and a message, send: success SnackBar and the mail arrives with the PDF. A draft offers neither. **Timed (SC-002, manual):** a 5-line order written, confirmed, printed and emailed in under 4 minutes.
11. **Cancel.** Cancel a draft created from Por comprar: Cancelada, lines kept, and its lines are back in Por comprar. A confirmed order offers no cancel.
12. **List.** Default shows the admin's orders without cancelled. Mostrar → Todas widens it and counts in the badge. Filter Cancelada, a supplier, a date range; search an order number.
13. **Rights.** With a read-only user on 20 (`qareadonly` if it holds 20 read; else grant temporarily): the list and detail open, Imprimir shows, nothing else. Without read on 20, the request and receipt details show the order number as plain text.
14. **Concurrency.** Open the same draft in two sessions; confirm in one, edit in the other: the Spanish refusal shows and the screen reloads as Confirmada.
15. **Largest text.** At the largest text level the list, Por comprar and detail stay readable (§V).
