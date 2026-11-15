# Quickstart: Delivery Order Print

**Feature**: [spec.md](./spec.md) | **Contracts**: [contracts/ui-actions.md](./contracts/ui-actions.md), [contracts/consumed-endpoints.md](./contracts/consumed-endpoints.md)

This guide proves the feature end to end against the dev tenant.

## Prerequisites

- **Backend.** mbe-api with spec 026: `GET /delivery-orders/{id}/ticket` and `/document`.
- **Accounts.**
  - The admin account from `.env` (`MBE_POS_*`) has Delivery Orders (71) read.
  - For the rights check, use a role without 71 read (`qanoaccess`, seeded by `tool/seed_test_accounts.py`), or rely on the widget tests.
- **Data.**
  - One order in Borrador. A POS Entrega step leaves drafts.
  - One approved-or-later delivery order and one counter pickup. Spec 062's runs left delivery 30242 (En preparación) and pickup 30243 (Aprobada).
  - One cancelled order.
  - For step 6, an approved order whose lines come from two warehouses. Add two lines from different warehouses to a draft in Órdenes de entrega, then confirm it.
- **DB tunnel.** A stable tunnel, as for spec 061's live test.

## Automated

```sh
flutter analyze
flutter test test/unit/core/documents test/unit/core/errors test/widget/core/documents
flutter test test/unit/features/sales test/widget/features/sales

# Live, read-only. Skips the multi-warehouse step when the tenant has no such order.
flutter test integration_test/delivery_order_print_quickstart_test.dart -d macos \
  --dart-define-from-file=.env.settings
```

## Manual walkthrough

1. **Draft has no print.** Open Logística → Órdenes de entrega with the "Todas" status. A Borrador or Pendiente de aprobación row has no ticket icon. Its detail screen has no "Ver ticket" or "Ver formato carta".
2. **Delivery ticket from the list.** On an En preparación delivery row, tap the receipt icon. The preview opens over the list, titled "Ticket de entrega · {folio}", with the 72 mm delivery ticket: ship-to QR and signature line. Close it. The list keeps its filters, page and scroll.
3. **Pickup ticket.** Do the same on an approved pickup row. The server's pickup ticket appears, with "Entrega en mostrador" and a barcode.
4. **Print and download.** In the preview, "Imprimir" opens the print dialog. "Descargar" saves `entrega-000XXXXX.pdf`, named by the order's id.
5. **Detail screen.** Open an approved order. "Ver ticket" (outlined) and "Ver formato carta" (text) lead the action area. "Ver formato carta" opens a Letter page titled "Orden de entrega · {folio} (carta)", and its download is `orden-entrega-….pdf`.
6. **Two warehouses.** On the multi-warehouse order:
   - "Ver ticket" first asks "¿Qué líneas imprimir?", with "Todos los almacenes" selected and the two warehouses by name.
   - Pick one: the title ends in that warehouse's name, and only its lines print.
   - Repeat from the list row: the same chooser appears after a brief lookup.
   - Dismiss the chooser: nothing opens.
7. **Cancelled.** On a cancelled order, the detail screen shows only the two print buttons, with no status actions. The ticket is stamped "CANCELADA".
8. **Refusal messages.** An order never moves from a printable status back to an unprintable one, so the UI can't trigger the 409 live. The widget tests cover the three new messages with fake refusals, and the unit tests cover them in es and en. Live, `curl` the ticket of a draft (`/api/v1/delivery-orders/{id}/ticket`) and check that the body's `code` is `delivery_order.not_approved`.
9. **Rights.** As a user without Delivery Orders read, the screens aren't reachable, so nothing is offered.
10. **Repeated taps.** Double-click the row icon quickly: one chooser or preview, never two.
11. **Compact.** Narrow the window to phone width. The chooser and the preview go fullscreen, and the row icon still shows on the cards.
