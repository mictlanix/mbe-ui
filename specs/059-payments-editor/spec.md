# Feature Specification: Payments Editor (applications, reversal and recording payments)

**Feature Branch**: `059-payments-editor`

**Created**: 2026-11-13

**Status**: Draft

**Input**: User description: mictlanix/mbe-roadmap#26. Scope 02 §2.8 (legacy Payments Editor, mbe-api `docs/specs/02-sales.md` §8). Server side done in mbe-api spec 011 (User Stories 2 and 8), refined by specs 033, 034 and 035. Weight: 5 legacy actions. Before specify, the user chose to also cover recording a new payment from the back office, and to offer the actions from both the payment view and the Pedidos order screen.

Payments get applied to the wrong order. A customer pays ahead for goods they haven't ordered yet. A customer on credit comes in to pay off two orders. Today the new app can show all of this in Pagos (specs 054 and 055) but can't change any of it. Outside the POS register, nobody can record a payment, undo an application or move money to another order.

This feature adds those actions. On a payment, staff can reverse an application, giving a reason, and apply the payment's unapplied money to another of the customer's outstanding orders. In Pagos, staff can record a credit payment or an advance, apply it, and print its ticket. On a Pedidos order, staff can see the payments applied to it and reverse them.

## Clarifications

### Session 2026-11-13

- Q: Must recording a payment require an open cash session? → A: Only for cash. A cash payment needs one so the drawer count includes it. A transfer, card or check can be recorded without one.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Move a misapplied payment to the right order (Priority: P1)

A cashier applied a customer's $1,500 transfer to order 1041. It belonged to order 1047. A supervisor finds the payment in Pagos and opens it. The applications list shows the $1,500 on order 1041. The supervisor reverses it and types the reason "Aplicado al pedido equivocado". The application stays in the list, marked reversed. The payment now shows $1,500 unapplied. The supervisor taps "Aplicar a pedido". The app lists the customer's outstanding orders with their balances. The supervisor picks 1047, keeps the suggested amount and confirms. The payment's unapplied amount drops to zero, and order 1047's balance falls by $1,500.

**Why this priority**: This is the core of the legacy Payments Editor and the most common correction. It needs both halves, reverse and apply, so it is the smallest slice that delivers value.

**Independent Test**: Apply a seeded payment to the wrong order. In the payment view, reverse that application with a reason, then apply the freed amount to another order of the same customer. Check that both orders' balances and paid status, and the payment's unapplied amount, are correct.

**Acceptance Scenarios**:

1. **Given** a payment with a live application, **When** a user allowed to reverse opens the payment view, **Then** that application row offers "Revertir".
2. **Given** the reverse dialog, **When** the reason is empty or only spaces, **Then** the confirm action is disabled.
3. **Given** a reason, **When** the user confirms, **Then** the application stays listed and is marked reversed, the payment's unapplied amount goes up by what the application took (amount plus change given), and the order's balance is restored.
4. **Given** the reversal brought the order's balance back above zero, **When** the user looks at the order, **Then** it no longer shows as paid.
5. **Given** a payment with unapplied money, **When** a user allowed to apply opens the payment view, **Then** "Aplicar a pedido" is offered. With nothing left unapplied, it is not.
6. **Given** the apply dialog, **When** it opens, **Then** it lists only the payment customer's outstanding orders, in the payment's currency, each with its folio, date, total and balance.
7. **Given** an order is picked, **When** the amount is proposed, **Then** it defaults to the smaller of the order's balance and the payment's unapplied amount, and can be lowered but not raised above either.
8. **Given** a confirmed application, **When** the view refreshes, **Then** the new application shows in the list and the payment's unapplied amount fell by the amount applied.

---

### User Story 2 - Record a credit payment or an advance in the back office (Priority: P2)

A customer on credit comes to the office with $3,000 to pay off two orders. The clerk opens Pagos and taps "Registrar pago". The clerk picks the customer, chooses "Abono a crédito", the method (cash, transfer…), its option and reference, and enters $3,000. On saving, the payment gets its folio and opens in the payment view with $3,000 unapplied. The clerk applies it to the two orders as in User Story 1 and prints the ticket for the customer.

Another customer pays $5,000 ahead for an order that isn't placed yet. The clerk records it as "Anticipo" and prints the ticket. It stays unapplied until the order exists.

**Why this priority**: Today a credit customer can't pay outside the register, and an advance can't be taken at all. It reuses User Story 1's apply action, so it comes second.

**Independent Test**: Record a credit payment for a customer with outstanding orders. Check it appears in Pagos with its folio and full amount unapplied, apply it to one order, and print its ticket.

**Acceptance Scenarios**:

1. **Given** a user allowed to record payments, **When** they open Pagos, **Then** "Registrar pago" is offered. Others don't see it.
2. **Given** the record form, **When** it opens, **Then** it asks for customer, payment type (credit payment or advance), method, payment option when the method has options, reference and amount. Currency defaults to the tenant's default.
3. **Given** missing customer, method or amount, or an amount of zero or less, **When** the user tries to save, **Then** saving is refused and the missing field is named.
4. **Given** a valid form, **When** the user saves, **Then** the payment is created with its folio and the payment view opens on it with the full amount unapplied.
5. **Given** the newly recorded payment, **When** the user taps print, **Then** its ticket prints, as for any credit payment or advance (spec 055).
6. **Given** a save is in flight, **When** the user taps save again or leaves, **Then** no second payment is created.
7. **Given** the method is cash and the user has no open cash session, **When** they try to save, **Then** saving is refused with a message that a cash payment needs an open session. A transfer is saved without one.

---

### User Story 3 - See and reverse an order's payments from Pedidos (Priority: P3)

A supervisor is looking at order 1041 in Pedidos and sees it marked paid, but knows the payment belongs elsewhere. The order screen lists the payments applied to it: each with method, reference, amount, change, date and whether it was reversed. The supervisor reverses the wrong one from there with a reason, and opens the payment to apply it to the right order.

**Why this priority**: Corrections often start from the order, not the payment. It adds no new rules; it is a second door to User Story 1.

**Independent Test**: Open a back-office order with an applied payment. Check that its payments are listed, reverse one with a reason, and check the order's balance and paid status update and the payment link opens the payment view.

**Acceptance Scenarios**:

1. **Given** a completed order in Pedidos, **When** it has applications, **Then** the order screen lists them, live and reversed, with method, reference, amount, change, date and reversed status.
2. **Given** a live application on that list and a user allowed to reverse, **When** they reverse it with a reason, **Then** the list, the order's balance and its paid status refresh.
3. **Given** an application row, **When** the user opens its payment, **Then** the Pagos payment view opens on that payment.
4. **Given** an order with no applications, **When** it is opened, **Then** the list says no payments have been applied.

---

### Edge Cases

- **Reversing on an order that was already refunded.** The order stops being paid but the refund stays. The reverse dialog warns that the order has refunds before the user confirms.
- **Another facility's payment.** A user without Payments Editor read can't open it (spec 055), so can't act on it. A Payments Editor can act on it. The order applied to may be of any facility.
- **The order changed in between.** It was settled or cancelled, or its balance dropped below the amount, after the list loaded. The server refuses; the app shows the reason and reloads the outstanding orders.
- **The payment changed in between.** Another user applied or reversed it meanwhile. The server refuses an amount above what is left; the app shows the reason and reloads the payment.
- **Application already reversed.** A second reversal is refused with a message and the view reloads.
- **No outstanding orders.** The apply dialog says the customer has none in this currency.
- **Payment of type credit note.** It is applied like any payment (spec 056 already spends notes at the POS). Recording a credit note here is not offered: notes come only from refunds.
- **Cash session closed while recording.** If the clerk's session is closed in between, the server refuses with "The cash session is closed"; the app shows it and nothing is created.
- **Walk-in customer.** Recording an advance or credit payment for the general-public customer is refused by the form: it can't be tracked to anyone.
- **Network failure after save.** The user isn't told it failed when it may have succeeded; the app says the result is unknown and points to Pagos to check before retrying.

## Requirements *(mandatory)*

### Functional Requirements

**Reverse**

- **FR-001**: The payment view MUST offer "Revertir" on each live application, only to users with Customer Payments update.
- **FR-002**: Reversing MUST require a reason that isn't empty or only whitespace. The reason is recorded by the server as evidence.
- **FR-003**: After a reversal, the payment view MUST show the application as reversed, the new unapplied amount, and the order's updated status. Reversed applications MUST stay visible.
- **FR-004**: Before confirming a reversal on an order that has refunds, the dialog MUST warn that the refund will not be undone.

**Apply**

- **FR-005**: The payment view MUST offer "Aplicar a pedido" when the payment has more than 0.01 unapplied, only to users with Customer Payments create.
- **FR-006**: The apply dialog MUST list only outstanding orders of the payment's customer in the payment's currency, with folio, date, total and balance, searchable by folio.
- **FR-007**: The applied amount MUST default to the smaller of the order's balance and the payment's unapplied amount, and MUST NOT be accepted above either or at zero or less.
- **FR-008**: The back-office apply MUST record no change given back.
- **FR-009**: When the server refuses an application (order settled, cancelled or not completed, amount above balance or above what the payment has left, currency or customer mismatch), the app MUST show the reason in the user's language and reload the data the refusal concerns.

**Record**

- **FR-010**: Pagos MUST offer "Registrar pago" only to users with Customer Payments create.
- **FR-011**: The record form MUST capture customer, payment type (credit payment or advance only), method, payment option when the method has options, reference and amount, with currency defaulting to the tenant default.
- **FR-012**: The form MUST refuse to save without a customer, method and an amount above zero, and MUST refuse the general-public customer.
- **FR-013**: Saving MUST create the payment once, even if the user taps save repeatedly, and then open the payment view on it.
- **FR-014**: The payment view of a freshly recorded payment MUST offer its ticket, as spec 055 does for any credit payment or advance.
- **FR-015**: Recording a cash payment MUST require the user to have an open cash session; without one the form MUST say so and refuse to save. Other methods MUST be recordable without a session.

**Order screen**

- **FR-016**: A completed order in Pedidos MUST list its applications, live and reversed, with method, reference, amount, change, date and reversed status.
- **FR-017**: Each live application on that list MUST offer reversal under FR-001 and FR-002, and the order's balance and paid status MUST refresh after it.
- **FR-018**: Each application row MUST link to its payment's view in Pagos.

**General**

- **FR-019**: Every action in this feature MUST follow the server's facility rule: a payment of another facility is acted on only by Payments Editor readers or administrators.
- **FR-020**: Every new label, message and error MUST be available in Spanish and English.

### Key Entities

- **Customer payment**: money received from a customer. Has a folio, customer, type (sale payment, credit payment, advance, credit note), method and option, reference, currency, amount and an unapplied amount (amount less live applications and the change they gave back).
- **Application**: a part of a payment applied to one order. Has the order, amount, change given back, who applied it and when, and whether it was reversed. Reversed applications are kept.
- **Outstanding order**: a completed, uncancelled, unpaid order of a customer, with its total and balance.
- **Reversal reason**: free text the server records with who reversed and when.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A supervisor can move a misapplied payment to the right order in under 1 minute, without leaving the payment view.
- **SC-002**: A clerk can record a credit payment, apply it to one order and print its ticket in under 2 minutes.
- **SC-003**: After any reverse or apply, the payment's unapplied amount equals its amount less its live applications and their change, and each order's balance moved by the same amount, in 100% of the walkthrough cases.
- **SC-004**: No reversal can be confirmed without a reason, and no application above the order's balance or the payment's remainder can be confirmed from the app.
- **SC-005**: Users without the matching Customer Payments right see none of the record, apply or reverse actions.
- **SC-006**: Repeated taps on save never create more than one payment.

## Assumptions

- The rights follow the server: recording and applying need Customer Payments create, reversing needs Customer Payments update. Payments Editor (100) read only widens which facilities' payments a user can act on. The legacy Payments Editor screen becomes these actions on the existing Pagos screens, not a separate screen.
- "Reapply to a different order" is reverse plus apply. There is no single "move" action.
- The recorded payment's date is the moment it is saved; back-dating is not offered.
- The payment's facility is the user's facility, as the server sets it.
- The reverse dialog is the same one the POS uses on a sale's payments.
- The Pedidos order screen shows no payments today; this feature adds that list. Applying a payment from the order side is not offered: the user opens the payment to apply it.
- Applying with change given back is a register action and stays in the POS.
- Mismatched currencies are not offered; the server refuses them anyway.
- Out of scope: payment verification and rejection (mictlanix/mbe-roadmap#27), editing a recorded payment's amount, method or customer, deleting a payment, splitting one application into several in one step, recording credit notes, the received-payments report (#99), and accounts receivable statements (#78).

## Verbatim Constraints

- Server rules relied on: `POST /customer-payments`, `POST /customer-payments/{id}/applications`, `POST /customer-payments/{id}/applications/{application_id}/reverse` (body carries `reason`), `GET /customer-payments/outstanding-orders`, `GET /sales-orders/{id}/applications`, `GET /customer-payments/{id}/ticket`.
- Error text: "The cash session is closed".
