## Summary

Clerks can now refund goods a customer brings back from a paid order, find and cancel refunds, and print the receipt. Spec: `specs/057-customer-refunds/`.

- **Refund from a paid order (P1).** A "Devolver" button on a paid order's header in Pedidos, and on a paid sale's detail in the POS, opens the order's refund. If the order already has an open refund, that one opens instead of a second. The refund lists the order's returnable lines at 0. The clerk sets each return quantity (capped at what the line can still take) and its return-to warehouse. Every change is saved at once and the totals come back from the server. "Confirmar devolución" checks the clerk's cash session first. With no valid session it shows a banner with a way to open one, and no payout is asked for. Otherwise a dialog asks for cash from the drawer or a credit note, with nothing pre-selected. A confirmed refund is read-only. It shows its folio, how the money went back (cash, or "Nota de crédito Nº {ticket}" linked to the payment), and a notice when the server lowered a quantity because another refund got there first.
- **Find, resume and cancel (P2).** A new Ventas entry, "Devoluciones", at `/sales/refunds`. Columns: folio, date, customer, order, status, total. A search box (a number matches the folio, the refund id or the order; text matches the customer's name), filters for status, customer and order number, and a "Solo mis devoluciones" switch that starts off. "Nueva devolución" starts a refund from a typed order number, with the same rules as "Devolver". Opening a row goes to `/sales/refunds/:refundId`, where a refund that isn't confirmed can be cancelled after a prompt. In "Notas de crédito", the refund part of a note's origin is now a link, and the customer's name comes from the server.
- **Print the receipt (P3).** A confirmed refund has an "Imprimir" button that opens mbe-api's receipt. A credit-note refund prints the note's ticket number with its barcode, which is how a walk-in customer redeems the note. Open and cancelled refunds have no button.
- **Why an order is refused.** The app tells "not confirmed", "not paid" (cancel the order instead), "nothing left to return" and "order not found" apart. It reads the order's own status for the first three. It never parses the server's message, which it only shows, for example the one that names an invoice to cancel first.

**Gates.** The list, its nav entry, the detail and the receipt need Customer Refunds (22) read. "Devolver" and "Nueva devolución" need create and read. Quantity, warehouse and cancel need update. Confirm needs Customer Refund Confirm (110) update. Anything a user can't use is absent, not disabled. A user who can edit but not confirm sees a hint that someone with confirm access finishes the refund.

**Server figures as sent.** The app never computes a total or a refundable quantity. Every write replaces the refund with the server's response. It builds on the mbe-api changes this feature asked for, all shipped on 2026-11-04:
- customer names on refunds and credit notes (mbe-api#283, #284);
- the list's search and own-refunds filter, with open refunds first (mbe-api#285);
- the refund's payout, backing payment and credit note (mbe-api#286);
- the receipt, `GET /customer-refunds/{id}/ticket` (mbe-api#287).

The workarounds written before they shipped (a per-row customer lookup and a scan of the customer's credit notes) are gone.

**Behaviour to know about.**
- A refund now belongs to the store that processes it. Another store's refund opens only for a user with SearchCreditsFromAllStores read, and otherwise shows as not found.
- A cash payout also leaves a credit note, already paid back and never spendable. Only a credit-note payout links to its payment. A refund with no payout, such as a legacy one that only reduced an unpaid order, reads "Forma de pago no disponible".
- A paid POS sale whose delivery is still pending opens the POS workspace, not the sale detail, so it has no "Devolver" there. Pedidos offers it for that sale.
- The server doesn't stop two clerks opening a draft for the same order at the same instant. The app resumes an existing draft, so only a true race leaves a duplicate, and a stray draft can be cancelled. No issue is filed.

**Where this changes existing behaviour.** A "Devolver" button on `OrderHeaderPanel` and `PosSaleDetailView`, a refund link and the server's customer name in the credit-notes list, and a new `DocumentKind` for the receipt, and the `ValidationError` hide removed from three taxpayer files (see the test plan).

## Roadmap

Closes mictlanix/mbe-roadmap#29

Upstream, filed during this spec and shipped: mbe-api#283 to #287.

## Test plan

- [x] `flutter analyze`: no issues. The regenerated client (`675ca26`) no longer exports `ValidationError`, so the three `hide ValidationError` lists in `taxpayer_issuer_form_controller.dart` and two taxpayer tests lost that name.
- [x] `flutter test test/unit test/widget`: 3968 passed, 11 failed. All 11 are in `customer_payment_repository_impl_test.dart` and `customer_payment_entity_test.dart`, which this PR does not touch. Their fixtures lack the `serial` field that `CustomerPaymentResponse` now requires after main's commit 9917cc1.
- [ ] Goldens and screenshots (`test/golden`, `test/screenshots`): not run for this PR.
- [x] Live walkthrough `integration_test/customer_refunds_quickstart_test.dart` on macOS against the dev API, with `--dart-define=MBE_REFUND_CONFIRM=1`: every step passes (steps 1 to 12 and 12b). A draft opens with its lines at 0; "Devolver" again resumes the same draft; the quantity cap holds and a write updates the server's totals; the unpaid and unconfirmed order refusals; the list filters and the search; cancelling through the UI; **confirming as cash** (payout line "Pagada en efectivo", no link) and **confirming as a credit note** (payout line with its ticket number, linked to the payment); payout lines for existing refunds match the server's `payout`; the receipt preview opening a PDF for a credit-note refund and for the refund just confirmed; a no-access account gets no entry and is redirected. Step 5 (no open session: banner, no dialog, nothing sent) passed in earlier runs with no session, and prints SKIP when the run itself opens one.
- [ ] The run writes to the dev tenant. It cancels every draft it opens, but confirmed refunds cannot be undone: it left refunds 9665, 9669 and 9674 (cash) and 9675 (credit note, ticket 300911), and cash session 10445 open for the admin.
- [ ] Not checked: the new screens at the largest text size, and the walk-in redemption by the printed ticket number (quickstart step 13, by hand).

🤖 Generated with [Claude Code](https://claude.com/claude-code)
