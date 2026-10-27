## Summary

Cashiers can now spend store credit at the register, and staff can see which credit notes exist and what is left on each. Spec: `specs/056-credit-notes/`.

- **Spend a named customer's credit (P1).** In the POS Cobro step, a "Nota de crédito · Saldo $X" tile shows the customer's spendable credit. One tap spends their notes oldest first, capped at the sale's balance and at any amount typed in the field. It never gives change. A redemption applies the note's existing backing payment (`POST /customer-payments/{id}/applications`); no payment is created. If a later note fails, the earlier ones stay applied and the step says how much went through, above the server's error. Applied rows read "Nota de crédito · Nº {ticket}".
- **Redeem a walk-in ticket (P2).** On a walk-in sale the tile becomes "Canjear nota de crédito". It opens a dialog where the cashier scans or types the number under the ticket's barcode, which is the backing payment's id. The dialog shows what is left and what will be applied, then applies exactly that. It refuses, with the reason, an unknown number, a used-up note, a note already on this sale, or a note that belongs to a named customer (and names them).
- **"Notas de crédito" list (P3).** A new Ventas entry at `/sales/credit-notes`. Columns: date, customer, origin (refund and order, with the order linked when the user can open it), issued and remaining. Filters: customer, and "Solo con saldo". There is no search box, because the endpoint has none. A row opens the backing payment on the existing payment screen.

**Scope note.** Redemption is in the POS Cobro step only. The back-office Pedidos workspace takes no payment (spec 029), so there is no second payment dialog to add it to.

**Gates.** The list and its nav entry need Credit Payments (83) read. The tiles need Credit Payments read and Customer Payments (8) create; the walk-in ticket also needs Customer Payments read, because it looks the payment up. Opening a row needs Customer Payments read. Anything a user can't use is absent, not disabled.

**Server figures as sent.** The app never computes a remaining balance (FR-015) and never turns on `open_only`. Two places read more than they should until mbe-api catches up. Each carries a `// simplified:` marker:
- "Solo con saldo" without a customer reads every page and filters locally, because `open_only` pages before it filters (mbe-api#278).
- A walk-in ticket lookup scans that customer's notes newest first, because there is no filter by backing payment yet (mbe-api#280).

Also: `SalePayment` now carries its `PaymentType`, mapped from the existing `OrderApplicationResponse.paymentType`. No client regeneration was needed.

## Roadmap

Closes mictlanix/mbe-roadmap#28

Upstream, all filed during this spec and still open:
- mbe-api#277: legacy notes report 0 issued and 0 remaining, because legacy writes 0 in the field the server reads. On the dev tenant 982 of 984 notes show $0.00, and none can be spent until this ships. The comment there also covers the "cashed out" marker that mbe-api's refund path writes on every note.
- mbe-api#278: `open_only` filters after paging.
- mbe-api#280: filter `GET /credit-notes` by backing payment, for ticket lookup.

## Test plan

- [x] `flutter analyze`: no issues.
- [x] `flutter test test/unit test/widget`: 3822 passed.
- [x] Goldens and screenshots: the same 7 pre-existing failures as on `main` (6 in `test/golden/core_widgets_golden_test.dart`, 1 in `test/screenshots/pos_screens_screenshot_test.dart`), CI-only goldens (mbe-ui#209).
- [x] Live repository test `test/integration/credit_notes_live_test.dart` against the dev tenant: 5 of 5 pass (paging, per-customer read, lookup by ticket number, and SC-005 on notes whose issued amount is their payment's own; legacy note 462 is reported, not checked).
- [x] Walkthrough `integration_test/credit_notes_quickstart_test.dart` on macOS against the dev tenant: quickstart steps 1–4 and 10 pass (list, customer filter, "Solo con saldo", opening a row, and a no-access user gets no entry and is redirected).
- [ ] Spending a note live (quickstart steps 5–9). Not run: the dev tenant has no spendable note until mbe-api#277 ships, and the walkthrough creates no data. Covered by the controller and widget tests (`payment_controller_test`, `payment_method_grid_test`, `credit_note_ticket_dialog_test`, `payment_step_gate_test`).

🤖 Generated with [Claude Code](https://claude.com/claude-code)
