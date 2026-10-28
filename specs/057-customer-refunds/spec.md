# Feature Specification: Customer Refunds (Devoluciones)

**Feature Branch**: `057-customer-refunds`

**Created**: 2026-10-28

**Status**: Draft

**Input**: User description: mictlanix/mbe-roadmap#29. Scope 02 §2.6 (legacy Customer Refunds, mbe-api `docs/specs/02-sales.md` §6). The server side shipped in mbe-api spec 011 (User Story 5, FR-060 to FR-066). Out of scope in ui spec 020. Weight: 7 legacy actions.

A customer brings goods back from a sale they already paid for. The clerk takes the goods back into stock and returns the money, as cash from the drawer or as a credit note the customer spends later. Today the new app has no way to do this, and the credit notes spec 056 can spend are only the ones legacy issued.

A refund is a document of its own. It is opened against one paid order and starts with every line that can still be returned, each at a return quantity of zero. The clerk enters what is coming back and where it goes, then confirms. Confirming restocks the goods, gives the refund its folio, and pays the full total back in the form the clerk picks. A confirmed refund is read-only. A refund that is not confirmed can be cancelled.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Refund returned goods from a paid order (Priority: P1)

A customer returns two of the five units they bought. The clerk opens the paid order in Pedidos or in the POS sales list and taps "Devolver". A refund opens with the order's returnable lines, each at zero. The clerk enters 2 on the right line, keeps or changes the warehouse the goods go back to, and confirms. The app asks how the money goes back: cash from the drawer, or a credit note. The clerk picks one. The refund gets its folio, becomes read-only, and shows how the money was returned.

**Why this priority**: This is the whole point of the feature. Without it no return can be processed in the new app.

**Independent Test**: With an open cash session, take a paid order, refund part of one line as cash, and check that the refund is completed with a folio and its total shows up as cash out in the session. Refund another order as a credit note and check that the note appears in "Notas de crédito".

**Acceptance Scenarios**:

1. **Given** a paid order with returnable lines, **When** the clerk taps "Devolver", **Then** a refund opens listing each returnable line with its product, price, the quantity still returnable, and a return quantity of zero. Lines with nothing left to return are not shown.
2. **Given** an open refund, **When** the clerk enters a quantity above what the line can still return, **Then** the app refuses it and says the most that line can take.
3. **Given** an open refund with quantities entered and an open cash session of the clerk's own, **When** the clerk confirms and picks cash, **Then** the refund is completed with its folio, lines left at zero are gone, and the total is paid out of the clerk's session.
4. **Given** the same, **When** the clerk picks credit note, **Then** the refund is completed and a credit note for its full total is issued to the order's customer.
5. **Given** the clerk has no open cash session, **When** they try to confirm, **Then** the app says a session must be open first and offers the way to open one. Nothing is confirmed.
6. **Given** an order that already has an open refund, **When** the clerk taps "Devolver", **Then** that refund opens instead of a second one.
7. **Given** an order whose goods were all returned already, **When** the clerk taps "Devolver", **Then** the app says there is nothing left to return.

---

### User Story 2 - Find, resume and cancel refunds (Priority: P2)

A supervisor opens "Devoluciones" to see the refunds at their facility. They filter by status, customer or order number, and open one to see its lines, total and how the money went back. A clerk finds a refund they left open, finishes it or cancels it. A clerk who knows only the order number starts a new refund from this screen by typing it.

**Why this priority**: Refunds have to be traceable and an abandoned one has to be closable. The P1 flow works without this screen, so it comes second.

**Independent Test**: Open a refund and leave it, confirm another, then find both in "Devoluciones" by order number and status. Cancel the open one and check it shows as cancelled.

**Acceptance Scenarios**:

1. **Given** refunds in several states, **When** the user opens "Devoluciones", **Then** each row shows folio, date, customer, source order, status and total, open refunds first, then newest first.
2. **Given** the list, **When** the user filters by status, customer or order number, **Then** only matching refunds are shown.
3. **Given** the list, **When** the user enters an order number to start a refund, **Then** the same rules as "Devolver" apply: a new refund opens, an existing open one is resumed, or the reason it can't be refunded is shown.
4. **Given** an order that is not paid yet, **When** a refund is started for it, **Then** the app says the order is not paid and that it should be cancelled instead. An order that is not confirmed gets its own message.
5. **Given** an open refund, **When** the user cancels it and confirms the prompt, **Then** it shows as cancelled and can no longer be edited. A confirmed refund offers no cancel.
6. **Given** a credit note in "Notas de crédito" that came from a refund, **When** the user follows its origin, **Then** the refund opens.

---

### User Story 3 - Print a refund receipt (Priority: P3)

After confirming, the clerk prints a receipt for the customer. It lists what came back and the total, and says whether the money was paid in cash or as a credit note. A credit note receipt carries the note's ticket number, which is how a walk-in customer redeems the note later (spec 056).

**Why this priority**: A walk-in credit note can only be spent by its ticket number, so the receipt matters. It depends on an mbe-api print template that doesn't exist yet, so it comes last.

**Independent Test**: Confirm a refund as a credit note for the walk-in customer, print it, and redeem the note at the POS payment step by the ticket number on the receipt.

**Acceptance Scenarios**:

1. **Given** a confirmed refund, **When** the clerk taps print, **Then** the receipt opens the same way other documents print (spec 044).
2. **Given** a refund paid as a credit note, **When** it is printed, **Then** the receipt shows the credit note's ticket number.
3. **Given** a refund that is open or cancelled, **When** the user views it, **Then** no print action is offered.

### Edge Cases

- **Another clerk refunds the same line first.** The server re-checks quantities when the refund is confirmed and lowers or drops lines. The confirmed refund shows what was actually returned, and the app tells the clerk the quantities changed.
- **Every quantity is still zero.** Confirm is not available until at least one line has a quantity above zero.
- **The clerk can edit refunds but can't confirm them.** They can prepare the refund. Confirm is hidden, and someone with confirm access finishes it.
- **The return-to warehouse.** Each line starts with the warehouse the server proposes. The clerk can pick another warehouse that sells, and the server refuses one that doesn't.
- **A refund of an order paid with a credit note.** Allowed. The money goes back as cash or a new credit note like any other refund.
- **The refund total is more cash than the drawer holds.** The app does not check this. The server allows it and the session close shows it.
- **Network failure while confirming.** The app reloads the refund before letting the clerk retry, so a refund that went through is not confirmed twice.

## Requirements *(mandatory)*

### Functional Requirements

**Opening a refund**

- **FR-001**: A completed, paid order's detail in Pedidos and in the POS sales list MUST offer "Devolver" to users who can create refunds. Orders in any other status MUST NOT offer it.
- **FR-002**: "Devoluciones" MUST let users who can create refunds start one by entering a sales order number.
- **FR-003**: Starting a refund for an order that already has an open refund MUST open that refund instead of creating another.
- **FR-004**: When the server refuses to open a refund, the app MUST show its reason in words the clerk can act on, and tell "not paid" (cancel the order instead) apart from "not confirmed" and from "nothing left to return".

**Editing a refund**

- **FR-005**: An open refund MUST show each line's product, price, discount, tax, quantity still returnable, return quantity and return-to warehouse, plus the refund's subtotal, tax and total.
- **FR-006**: Users who can edit refunds MUST be able to change a line's return quantity and return-to warehouse while the refund is open. Totals MUST come from the server after each change, never computed in the app.
- **FR-007**: The app MUST refuse a return quantity below zero or above the line's returnable quantity, and say the maximum.

**Confirming and cancelling**

- **FR-008**: Users with refund confirm access MUST be able to confirm an open refund that has at least one line above zero. Confirm MUST ask the clerk to choose cash or credit note, showing the total that will be returned. There is no default choice.
- **FR-009**: When the clerk has no open cash session, the app MUST say so before sending the confirm and offer to open one.
- **FR-010**: A confirmed refund MUST show its folio, date, final lines and total, and be read-only.
- **FR-011**: When the confirmed lines differ from what the clerk entered, the app MUST say that quantities were adjusted because of another refund.
- **FR-012**: Users who can edit refunds MUST be able to cancel an open refund after a confirmation prompt. Completed and cancelled refunds MUST NOT offer cancel.

**Listing and tracing**

- **FR-013**: Users who can read refunds MUST be able to open "Devoluciones", listing folio, date, customer, source order, status and total, open first and then newest first, paginated.
- **FR-014**: The list MUST filter by status, customer and order number.
- **FR-015**: Each refund MUST have its own link, so other screens can open it directly. A refund's source order MUST link to that order. A refund that ended as a credit note MUST link to it in "Notas de crédito".
- **FR-016**: The refund segment of a credit note's origin in "Notas de crédito" MUST link to the refund.
- **FR-017**: A confirmed refund MUST show whether it was paid as cash or as a credit note, and for a credit note its ticket number.

**Printing**

- **FR-018**: A confirmed refund MUST offer print, following the document printing behaviour of spec 044. Open and cancelled refunds MUST NOT.
- **FR-019**: A printed credit-note refund MUST show the credit note's ticket number.

**Access and copy**

- **FR-020**: Every action MUST follow the user's access: Customer Refunds read, create and update, and Customer Refund Confirm for confirming. "Devoluciones" MUST NOT appear in navigation for users without read access.
- **FR-021**: All new copy MUST exist in Spanish and English.

### Key Entities

- **Refund**: goods a customer brought back from one paid order. It has a source order, customer, salesperson, facility, currency, a status (open, completed or cancelled), a folio and date once confirmed, and subtotal, tax and total.
- **Refund line**: one line of the source order being returned. It has the product, price, discount and tax of the original line, the quantity still returnable, the return quantity, and the warehouse the goods go back to.
- **Payout**: how a confirmed refund's total went back to the customer. Either cash out of the confirming clerk's session, or a credit note (spec 056) whose ticket number is its backing payment.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A clerk processes a one-line return from a paid order, from "Devolver" to a confirmed refund, in under one minute.
- **SC-002**: No confirmed refund returns more of a line than was sold, minus earlier refunds.
- **SC-003**: Every cash refund appears as cash out in the confirming clerk's session close, and every credit-note refund appears in "Notas de crédito" with its refund as origin.
- **SC-004**: An order never has more than one open refund started from the app.
- **SC-005**: A walk-in customer's credit note issued by a refund can be redeemed at the POS using the ticket number printed on the refund receipt.
- **SC-006**: Each of the 7 legacy refund actions (list, open from order, view, edit line, confirm, cancel, print) has an equivalent in the app.

## Assumptions

- "Paid" means the order's status is paid. The server decides what can be refunded, and the app shows its answer rather than repeating the rules.
- Refunds are back-office work with a POS entry point. Confirming still needs the clerk's own open cash session, as on the server.
- The list shows what the server returns for the caller. There is no "my refunds" default and no text or folio search until mbe-api adds them.
- **Interim, until mbe-api adds them** (issues to be filed as part of this feature):
  - The refund list doesn't carry customer names, so the app looks each customer up per row.
  - The refund doesn't record its payout or link its credit note. Until it does, the app finds the credit note by matching notes for the refund's customer against the refund. A completed refund with no matching note is shown as cash.
  - mbe-api has no refund print template. Printing (User Story 3) waits for it, and the rest of the feature ships without it if needed.
- Sales orders' detail in Pedidos and the POS sale detail are where "Devolver" lives. A paid order is already read-only there, so the action adds to it without changing editing.

## Out of Scope

- Applying a refund to an order's remaining balance. A refundable order is fully paid, so this can't happen (mbe-api FR-064).
- Refunding unpaid or partly paid orders. Those are cancelled instead.
- Reversing a confirmed refund.
- Refunds that change prices or add goods that weren't on the order.
- Fiscal documents (credit-note CFDI) for refunds.
