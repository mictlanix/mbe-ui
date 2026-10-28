## Summary

Cashiers can now spend store credit at the register, and staff can see which credit notes exist and what is left on each. Spec: `specs/056-credit-notes/`.

- **Spend a named customer's credit (P1).** In the POS Cobro step, a "Nota de crédito · Saldo $X" tile shows the customer's spendable credit. One tap spends their notes oldest first, capped at the sale's balance and at any amount typed in the field. It never gives change. A redemption applies the note's existing backing payment (`POST /customer-payments/{id}/applications`); no payment is created. If a later note fails, the earlier ones stay applied and the step says how much went through, above the server's error. Applied rows read "Nota de crédito · Nº {ticket}".
- **Redeem a walk-in ticket (P2).** On a walk-in sale the tile becomes "Canjear nota de crédito". It opens a dialog where the cashier scans or types the number under the ticket's barcode, which is the backing payment's id. The dialog shows what is left and what will be applied, then applies exactly that. It refuses, with the reason, an unknown number, a used-up note, a note already on this sale, or a note that belongs to a named customer (and names them).
- **"Notas de crédito" list (P3).** A new Ventas entry at `/sales/credit-notes`. Columns: date, customer, origin (refund and order, with the order linked when the user can open it), issued and remaining. Filters: customer, and "Solo utilizables" (mbe-api's `open_only`: notes a customer can still spend from their balance). There is no search box, because the endpoint has none. A row opens the backing payment on the existing payment screen.

**Scope note.** Redemption is in the POS Cobro step only. The back-office Pedidos workspace takes no payment (spec 029), so there is no second payment dialog to add it to.

**Gates.** The list and its nav entry need Credit Payments (83) read. The tiles need Credit Payments read and Customer Payments (8) create; the walk-in ticket also needs Customer Payments read, because it looks the payment up. Opening a row needs Customer Payments read. Anything a user can't use is absent, not disabled.

**Server figures as sent.** The app never computes a remaining balance (FR-015). It builds on mbe-api spec 034, which shipped the three issues this feature filed:
- issued is the backing payment's amount and remaining its unapplied amount, 0 once paid back in cash (mbe-api#277);
- `open_only` filters before paging (mbe-api#278), so the list and the customer's credit page on the server;
- `GET /credit-notes?customer_payment=` finds a ticket's note in one request (mbe-api#280).

Lists keep to the caller's facility, the server's default, which is also the only facility whose notes a cashier may spend. "Solo utilizables" leaves out walk-in notes, which are redeemed by ticket instead.

Also: `SalePayment` now carries its `PaymentType`, mapped from the existing `OrderApplicationResponse.paymentType`. The generated client is regenerated against mbe-api spec 034 (`8757d41`); it also brought the accounts payable and receivable APIs, which nothing here uses yet.

## Roadmap

Closes mictlanix/mbe-roadmap#28

Upstream: mbe-api#277, #278 and #280 were filed during this spec and shipped in mbe-api spec 034; the generated client is regenerated against it.

## Test plan

- [x] `flutter analyze`: no issues.
- [x] `flutter test test/unit test/widget`: 3820 passed.
- [x] Goldens and screenshots: the same 7 pre-existing failures as on `main` (6 in `test/golden/core_widgets_golden_test.dart`, 1 in `test/screenshots/pos_screens_screenshot_test.dart`), CI-only goldens (mbe-ui#209).
- [x] Live repository test `test/integration/credit_notes_live_test.dart` against the dev tenant: 5 of 5 pass (paging, `open_only` keeps exactly the spendable notes and counts only them, a customer's spendable notes, lookup by ticket number, and SC-005: issued equals the payment's amount and an open note's remaining its unapplied amount).
- [x] Walkthrough `integration_test/credit_notes_quickstart_test.dart` on macOS against the dev tenant: quickstart steps 1–4 and 10 pass (list, customer filter, "Solo utilizables", opening a row, and a no-access user gets no entry and is redirected).
- [ ] Spending a note live (quickstart steps 5–9). Not run: it writes an application to a real order, and the walkthrough creates no data. Facility 51 now has spendable notes to try it with. Covered by the controller and widget tests (`payment_controller_test`, `payment_method_grid_test`, `credit_note_ticket_dialog_test`, `payment_step_gate_test`).

🤖 Generated with [Claude Code](https://claude.com/claude-code)
