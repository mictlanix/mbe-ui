# Quickstart: Delivery Orders

**Spec**: [spec.md](./spec.md) | **Contracts**: [contracts/ui-contracts.md](./contracts/ui-contracts.md)

## Prerequisites

- mbe-api running locally with the dev tenant. `.env` holds `MBE_POS_*`, the admin account (see `test/integration/TEST_ACCOUNTS.md`).
- After a DB reset, run `python3 tool/seed_test_accounts.py`. The access check uses `qanoaccess`, which has no rights. Step 10 needs an account with right 71 read but not update. No seeded account has that today, so give one in User Profiles before running it.
- A completed sale with at least two lines, set up for delivery in the POS "Entrega" step, so that one draft delivery order exists. A second completed sale set up for "Recoge en tienda" gives a pickup draft.

## Automated

```bash
flutter test test/unit test/widget
# Live, against a running mbe-api (read-only by default)
flutter test integration_test/delivery_orders_quickstart_test.dart -d macos \
  --dart-define-from-file=.env.settings \
  --dart-define=MBE_POS_USERNAME=... --dart-define=MBE_POS_PASSWORD=...
# ...add this to also create, edit, confirm, cancel and hand over a pickup
  --dart-define=MBE_WRITE=true
```

Each write run leaves on the tenant:
- one cancelled delivery order;
- one picked-up order, with a generated 1×1 PNG as its proof;
- the two 1-unit completed sales they were raised from.

## Manual walkthrough

1. **Access (US1-1, SC-006).**
   - As admin, the Logística group (after Ventas) shows "Órdenes de entrega", then Vehículos and Operadores.
   - As `qanoaccess`, the entry is missing, and typing `/sales/delivery-orders` is refused.
2. **List (US1-2..4, FR-002..005).**
   - It opens on every status at your facility, newest first, with the filter badge at 0.
   - Drafts read "Borrador" in Folio.
   - Typing a folio finds that order. Typing letters isn't accepted.
   - Filter by Estado = Fallida, Tipo = Recoge en tienda, a date range, a customer, a sale, and another facility. Each narrows the list, and "Limpiar todo" returns to the opening state.
3. **Detail (US1-5, US1-6, US5).**
   - Open the POS draft. The facts strip, ship-to, contact, sale link and lines show all five quantities.
   - The history has one line, "— → Borrador", with the cashier's name.
4. **Edit the draft (US3).**
   - "Editar encabezado": change date, priority and contact, then save. The values stick after a reload.
   - ✎ on a line: lower its quantity. Enter more than the sale has, and the server's message gives what's left.
   - 🗑 on a line: confirm, and the line is gone.
   - "Agregar línea": choose another completed sale of the same customer, enter a quantity on one line, then add. The line appears.
5. **Confirm (US2).**
   - Confirm the draft. The dialog names customer, date and line count.
   - Afterwards the title has the folio, the status is En preparación (or Pendiente de aprobación if approval is on), and the history gains a line.
   - Header, line actions and "Agregar línea" are gone.
6. **Too little notice (FR-017).** Only when the tenant has `min_span_hours_for_deliveries > 0`. Confirm a draft dated within that span as a non-administrator. The dialog stays open and shows the earliest date allowed.
7. **Cancel (US4).**
   - On the confirmed order, "Cancelar orden" stays disabled until a reason is typed.
   - Confirm. The order is Cancelada, and the history shows the reason and your name.
   - In the POS, resume that sale's Entrega step. The cancelled destination doesn't count against the sale's lines (R9).
8. **Pickup (US7).**
   - Confirm the pickup draft, and it reads Aprobada. "Lista para recoger" moves it to Lista para recoger.
   - "Entregar al cliente" stays disabled until name, identification and a photo are given. Confirm, and it reads Recogida.
   - The "Comprobante de entrega" section shows name, identification, photo and time.
9. **Requeue (US6).** Needs a FAILED order, produced through mbe-api's `/delivery-itineraries` endpoints: create an itinerary, add the order as a stop, commit its lines, depart, then close the stop as FAILED with a proof.
   - Open it, and "Reprogramar" is offered.
   - Confirm. It reads En preparación, and Devuelta is back to 0.00.
10. **Read-only user (FR-015).** As a user with 71 read but not update, open a draft. No edit control or action button shows.
11. **Compact tier.** Narrow the window to phone width.
    - The list rows stack, without Pedidos.
    - On the detail, the lines become cards, and the action buttons wrap full width.
12. **Largest text size (§V).** At desktop width, set the largest text size. The status chip, folio and quantities in both tables don't clip.
