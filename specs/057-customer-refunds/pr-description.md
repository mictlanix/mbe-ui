## Summary

Clerks can now refund goods a customer brings back from a paid order, and staff can find and cancel refunds. Spec: `specs/057-customer-refunds/`. Printing the refund receipt is not in this PR: it waits for mbe-api#287.

- **Refund from a paid order (P1).** A "Devolver" button on a paid order's header in Pedidos, and on a paid sale's detail in the POS, opens the order's refund. If the order already has an open refund, that one opens instead of a second. The refund lists the order's returnable lines at 0. The clerk sets each return quantity (capped at what the line can still take) and its return-to warehouse. Every change is saved at once and the totals come back from the server. "Confirmar devolución" checks the clerk's cash session first. With no valid session it shows a banner with a way to open one, and no payout is asked for. Otherwise a dialog asks for cash from the drawer or a credit note, with nothing pre-selected. A confirmed refund is read-only. It shows its folio, how the money went back (cash, or "Nota de crédito Nº {ticket}" linked to the payment), and a notice when the server lowered a quantity because another refund got there first.
- **Find, resume and cancel (P2).** A new Ventas entry, "Devoluciones", at `/sales/refunds`. Columns: folio, date, customer, order, status, total. Filters: status, customer, order number. "Nueva devolución" starts a refund from a typed order number, with the same rules as "Devolver". Opening a row goes to `/sales/refunds/:refundId`, where a refund that isn't confirmed can be cancelled after a prompt. In "Notas de crédito", the refund part of a note's origin is now a link.
- **Why an order is refused.** The app tells "not confirmed", "not paid" (cancel the order instead), "nothing left to return" and "order not found" apart. It reads the order's own status for the first three. It never parses the server's message, which it only shows, for example the one that names an invoice to cancel first.

**Gates.** The list, its nav entry and the detail need Customer Refunds (22) read. "Devolver" and "Nueva devolución" need create and read. Quantity, warehouse and cancel need update. Confirm needs Customer Refund Confirm (110) update. Anything a user can't use is absent, not disabled. A user who can edit but not confirm sees a hint that someone with confirm access finishes the refund.

**Server figures as sent.** The app never computes a total or a refundable quantity. Every write replaces the refund with the server's response.

**Where this changes existing behaviour.** A "Devolver" button on `OrderHeaderPanel` and `PosSaleDetailView`, and a refund link in the credit-notes origin cell. A paid POS sale whose delivery is still pending shows the POS workspace, not the sale detail, so it has no button there. Pedidos offers it for that sale.

**Interim code, to remove when mbe-api ships.** Each carries a `// simplified:` marker:
- Customer names in the list are looked up per row (mbe-api#284).
- A confirmed refund's payout is inferred by scanning the customer's credit notes. A refund with no matching note is shown as cash (mbe-api#286).
- The list has no search box and no "my refunds" filter, and shows newest first instead of open first (mbe-api#285).

**Known gap.** The server doesn't stop two clerks opening a draft for the same order at the same instant. The app resumes an existing draft, so only a true race leaves a duplicate, and a stray draft can be cancelled. No issue is filed.

## Roadmap

Part of mictlanix/mbe-roadmap#29. Printing the receipt (User Story 3, T038–T042) is blocked on mbe-api#287. Merging this does not complete the roadmap item; the follow-up PR that adds printing closes it.

Upstream, filed during this spec and still open: mbe-api#284, #285, #286, #287.

## Test plan

- [x] `flutter analyze`: no issues.
- [x] `flutter test test/unit test/widget`: 3945 passed, 11 failed. All 11 are in `customer_payment_repository_impl_test.dart` and `customer_payment_entity_test.dart`, which this PR does not touch. Their fixtures lack the `serial` field that `CustomerPaymentResponse` now requires after main's commit 9917cc1.
- [ ] Goldens and screenshots (`test/golden`, `test/screenshots`): not run for this PR.
- [x] Live walkthrough `integration_test/customer_refunds_quickstart_test.dart` on macOS against the dev API: steps 1 to 5 and 8 to 10 pass (a draft opens with its lines at 0; "Devolver" again resumes the same draft; the quantity cap holds and a write updates the server's totals; the unpaid and unconfirmed order refusals; the session banner with no dialog and nothing sent; the list filters; cancelling through the UI; a no-access account gets no entry and is redirected). The test cancels every draft it opens.
- [ ] Quickstart steps 6 and 7 (confirm as cash, confirm as credit note) are not run. They write stock and cash, so they sit behind `--dart-define=MBE_REFUND_CONFIRM=1`. Run them once before merging.
- [ ] Not checked: the new screens at the largest text size, and printing.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
