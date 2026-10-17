# Feature Specification: POS Sales Fixes

**Feature Branch**: `047-pos-sales-fixes`

**Created**: 2026-10-17

**Status**: Draft

**Input**: User description: "POS Sales fixes: User shouldn't be able to start a sale if there is no valid cash session. And, if a session is expired, redirect to close it. Label filtering not working. Warehouse selector not rendering correctly. Change to pop up. Capture step shouldn't let continue if stock is insufficient. Payment step's `Apply payment` isn't necessary, it should apply payment on type selection. Payment of type cash should accept greater amounts than the charged, and show how much to give back."

## Context & Findings

These findings come from an audit of the POS sale flow in mbe-ui and mbe-api, done on 2026-10-17. They explain each reported problem and set the scope.

- **Cash session validity.** A cashier's session is either *none*, *open* (opened today, not closed) or *expired* (opened on an earlier day and never closed). Today only *none* blocks the POS. An expired session shows a warning banner, but the cashier can still start sales and take payments, which are then booked against that old session. The backend does not require a session to create a sale, so the POS screen is the only place this can be enforced. A screen to close a session already exists in Cash Sessions.
- **Label filtering.** The label filter lives in the capture step's *Advanced search* screen. The filter panel reads its current selection from the wrong place when the screen is opened from a sale, so it always looks empty. Because of this, a selected label never shows as selected, and every tap replaces the previous selection and clears the search text. The *stockable*, *purchasable* and *supplier* filters on the same panel have the same problem. The search itself sends labels to the backend correctly.
- **Warehouse selector.** Each sale line has an inline drop-down whose width is limited by its narrow column. Each option has to fit the warehouse name and its stock status (quantity, "short", "none" or "unknown"), so the options are cramped and get cut off.
- **Stock on capture.** Stock is checked per warehouse only to show a warning. Quantities are not limited, and *Continue* checks only that the sale has at least one line. Stock is known only for products looked up during the current visit, so a resumed sale has no stock information at all.
- **Applying a payment.** The cashier enters an amount, taps a payment method and then taps *Apply payment*. Methods that need a reference (e.g. a card authorization) also have a reference field.
- **Cash change.** Paying more than the balance is already accepted, and the excess is booked as change. It is shown only as a line in the summary panel, and it is accepted for **every** method, including card and transfer, where change makes no sense.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Selling requires a valid cash session (Priority: P1)

A cashier can only start a new sale, or take a payment, when their cash session was opened today and is still open. If their session has expired, the POS takes them to that session's close screen so they can close it before opening a new one.

**Why this priority**: Without this, sales and cash payments land in a session from a previous day. That corrupts the cash cut, which is a financial control.

**Independent Test**: Use a cashier with an expired session. Open the POS sales list and try to start a sale. Confirm you are taken to that session's close screen. Close it, open a new session, and confirm you can now start a sale.

**Acceptance Scenarios**:

1. **Given** a cashier with no session, **When** they view the POS sales list, **Then** *New sale* is disabled and explains that a cash session must be opened, with a way to go to Cash Sessions (current behavior, kept).
2. **Given** a cashier whose session has expired, **When** they tap *New sale*, **Then** no sale is created and they are taken to the close screen of that session, with a message explaining why.
3. **Given** a cashier whose session has expired, **When** they open an existing, unfinished sale (directly or through a link), **Then** they can view it but cannot add payments. They are shown a message with an action that takes them to the close screen of the expired session.
4. **Given** a cashier with a session opened today, **When** they tap *New sale*, **Then** the sale opens normally.
5. **Given** a cashier whose session expires while the POS is open (e.g. after midnight), **When** they next try to start a sale or apply a payment, **Then** the expired-session rule above applies.
6. **Given** a cashier who has just closed their expired session, **When** they return to the POS, **Then** they see the *no session* state and can open a new session from there.

---

### User Story 2 - Label filter in Advanced search works (Priority: P1)

In the capture step's *Advanced search*, a cashier can select one or more labels, together with the other filters and a search term, and the results respect all of them.

**Why this priority**: This is a functional bug. Cashiers cannot narrow products by label, which is the main reason that screen exists.

**Independent Test**: From a sale, open Advanced search and type a term. Select two labels one after the other. Confirm both labels show as selected, the term is kept, and only products that match are listed.

**Acceptance Scenarios**:

1. **Given** Advanced search was opened from a sale, **When** the cashier selects a label, **Then** the label shows as selected and the results are filtered by it.
2. **Given** one label is selected, **When** the cashier selects a second label, **Then** both stay selected and the search term is kept.
3. **Given** labels are selected, **When** the cashier changes the *stockable*, *purchasable* or *supplier* filter, **Then** the label selection and the term are kept.
4. **Given** labels are selected, **When** the cashier deselects one, **Then** only that label is removed.

---

### User Story 3 - Sale lines cannot exceed available stock (Priority: P2)

When a sale line asks for more than its chosen warehouse has, the cashier sees this on the line, and *Continue* to payment stays blocked until every line can be fulfilled. To fix it, the cashier can lower the quantity, pick another warehouse or remove the line.

**Why this priority**: Selling stock that is not there causes unfulfillable orders and negative inventory. It ranks below P1 because the current warning already makes the problem visible.

**Independent Test**: Add a product with 3 units in the selected warehouse and set the quantity to 5. Confirm the line is marked and *Continue* is blocked with a reason. Change the quantity to 3, or switch to a warehouse with enough stock, and confirm *Continue* is enabled.

**Acceptance Scenarios**:

1. **Given** a line whose quantity is greater than the stock available in its warehouse, **When** the cashier looks at the capture step, **Then** the line is marked as short and *Continue* is disabled with a message saying which lines are short.
2. **Given** a short line, **When** the cashier lowers the quantity to what is available, switches to a warehouse with enough stock, or removes the line, **Then** *Continue* is enabled once no line is short.
3. **Given** the same product appears on two lines from the same warehouse, **When** their combined quantity is greater than the stock, **Then** both lines count as short.
4. **Given** a product that is not stock-tracked (e.g. a service), **When** it is on the sale, **Then** it never blocks *Continue*.
5. **Given** a resumed sale, **When** the capture step opens, **Then** stock is loaded for every line, so the check works the same as for a new sale.
6. **Given** the stock for a line cannot be loaded, **When** the cashier tries to continue, **Then** the line shows that its stock is unknown and does not block *Continue*.
7. **Given** a short line, **When** the cashier looks for a way to continue anyway, **Then** none is offered to any user or privilege (hard block).

---

### User Story 4 - Warehouse selector as a pop-up (Priority: P2)

On a sale line, tapping the warehouse opens a pop-up that lists the warehouses available to the point of sale. Each row shows the full warehouse name and its stock for that product, and the current choice is marked. Picking a row sets the line's warehouse and closes the pop-up.

**Why this priority**: The drop-down is hard to read today, and this pop-up is how cashiers fix short lines from User Story 3.

**Independent Test**: On a line, open the warehouse selector. Confirm every warehouse shows its full name and stock, and that the current one is marked. Pick another one and confirm the line updates.

**Acceptance Scenarios**:

1. **Given** a sale line, **When** the cashier taps its warehouse, **Then** a pop-up lists the point of sale's warehouses with the full name, available quantity (or "unknown") and a clear short/no-stock indicator for the line's quantity.
2. **Given** the pop-up is open, **When** the cashier picks a warehouse, **Then** the line uses it and the pop-up closes.
3. **Given** the pop-up is open, **When** the cashier dismisses it, **Then** the line keeps its warehouse.
4. **Given** a compact (narrow) screen, **When** the selector is used, **Then** the pop-up is fully readable without horizontal scrolling.
5. **Given** a sale that can no longer be edited, **When** the line is shown, **Then** the warehouse is displayed but the pop-up cannot be opened.

---

### User Story 5 - Payment is applied when the method is chosen (Priority: P2)

On the payment step, the cashier enters (or keeps) an amount and taps a payment method. The payment is applied right away, with no *Apply payment* button.

**Why this priority**: This removes one tap from every payment, on the busiest screen of the POS.

**Independent Test**: On a sale with a balance of 100, enter 60 and tap *Cash*. Confirm a payment of 60 is applied at once and the balance becomes 40. Tap *Card* and confirm the remaining 40 is applied.

**Acceptance Scenarios**:

1. **Given** a balance and an amount greater than zero, **When** the cashier taps a method that needs no reference, **Then** the payment is applied immediately, appears in the applied-payments list, and the amount resets for the next payment.
2. **Given** the payment step opens or a payment was just applied, **When** the amount field is shown, **Then** it is pre-filled with the remaining balance.
3. **Given** a method that needs a reference, **When** the cashier taps it, **Then** they are asked for the reference, and the payment is applied when they confirm it (or nothing happens if they cancel).
4. **Given** an amount of zero or empty, **When** the cashier taps a method, **Then** nothing is applied and the amount field shows why.
5. **Given** a payment is being applied, **When** the cashier taps another method, **Then** the second tap is ignored until the first finishes (no double charges).
6. **Given** a payment was applied by mistake, **When** the cashier reverses it from the applied-payments list, **Then** it is undone (current behavior, kept).
7. **Given** the *Apply payment* button, **When** the payment step is shown, **Then** the button is no longer there.

---

### User Story 6 - Cash overpayment and change (Priority: P2)

When a customer pays cash with more than they owe, the cashier enters the amount handed over. The sale's balance is settled, and the change to give back is shown prominently right after the payment is applied. Other methods cannot be used to pay more than the balance.

**Why this priority**: Giving the right change is part of every cash sale. Today the change is easy to miss, and overpayment is allowed for card and transfer by mistake.

**Independent Test**: On a sale with a balance of 87.50, enter 100 and tap *Cash*. Confirm the sale is fully paid and a prominent "Change: 12.50" is shown. Then, on another sale, enter more than the balance and tap *Card*. Confirm it is refused.

**Acceptance Scenarios**:

1. **Given** a balance of 87.50, **When** the cashier enters 100 and taps *Cash*, **Then** the balance becomes 0 and a clearly visible notice shows 12.50 change, which stays visible until the cashier dismisses it or moves on.
2. **Given** an entered amount above the balance, **When** the cashier taps any method other than cash, **Then** no payment is applied and a message says that only cash can exceed the balance.
3. **Given** the cashier is typing an amount above the balance, **When** cash would be used, **Then** the change it would give is previewed before the method is tapped.
4. **Given** a cash payment with change, **When** the session's cash cut is calculated, **Then** the change is subtracted, so the drawer total matches the cash kept (current backend behavior, kept).
5. **Given** a cash payment equal to or less than the balance, **When** it is applied, **Then** no change notice is shown.

---

### Edge Cases

- The session is closed in another window or device while a sale is open: the next payment attempt follows User Story 1 (the session state is checked again, not cached from when the screen opened).
- A sale was started before this release under a session that has now expired: it can be viewed, but payments are blocked until a new session is opened (User Story 1, scenario 3).
- Stock changes after the cashier passes the capture step (e.g. another cashier sells the last unit): this spec checks stock only at capture; no recheck at payment time.
- A point of sale with a single warehouse: the pop-up still opens and shows that warehouse's stock, so the cashier can see availability.
- A cash amount far above the balance (e.g. a typo of 10,000 on a 50 sale): accepted as written, and the large change is shown, so the cashier notices before handing it out.
- Credit-term customers who leave the payment step with a balance: unchanged by this spec.

## Requirements *(mandatory)*

### Functional Requirements

**Cash session gate**

- **FR-001**: The POS MUST treat a cash session as valid only when it is open and was opened on the current day; a session from an earlier day that is still open is *expired*.
- **FR-002**: Starting a new sale MUST be prevented without a valid session.
- **FR-003**: When the cashier's session is expired, attempting to start a sale MUST take them to that session's close screen, with a message explaining why.
- **FR-004**: When the session is expired or missing, applying payments to an existing sale MUST be prevented. The sale MUST stay viewable, with an action that leads to the close screen (expired) or to Cash Sessions (missing).
- **FR-005**: The session state MUST be checked again when starting a sale and before applying each payment, so a session that expires or is closed while the POS is open is caught.

**Advanced search filters**

- **FR-006**: The Advanced search filter panel MUST show and keep the active label, stockable, purchasable and supplier selections, and the search term, no matter how the screen was opened.
- **FR-007**: Changing one filter MUST keep all other active filters and the search term.

**Stock on capture**

- **FR-008**: The capture step MUST know the available stock of each line's warehouse for every stock-tracked product on the sale, including on resumed sales.
- **FR-009**: A line MUST be marked short when the total quantity of that product from that warehouse across the sale is greater than what is available there.
- **FR-010**: *Continue* to payment MUST be disabled while any line is short, with a message identifying the short lines.
- **FR-011**: Products that are not stock-tracked MUST NOT be checked against stock. Lines whose stock could not be loaded MUST show an "unknown stock" warning and MUST NOT block *Continue*.
- **FR-011a**: The stock block MUST have no override: no privilege, role or sale type (including delivery sales) bypasses it.

**Warehouse pop-up**

- **FR-012**: The per-line warehouse selector MUST open as a pop-up listing the point of sale's warehouses with full name, available quantity (or unknown) and a short/no-stock indicator for the line's quantity, with the current warehouse marked.
- **FR-013**: The pop-up MUST be readable on compact screens without horizontal scrolling, and MUST NOT be openable on sales that cannot be edited.

**Payment application**

- **FR-014**: Tapping a payment method MUST apply a payment for the entered amount immediately. The separate *Apply payment* button MUST be removed.
- **FR-015**: Methods that need a reference MUST ask for it when tapped, and apply the payment only after the cashier confirms it.
- **FR-016**: The amount MUST default to the remaining balance when the step opens and after each payment.
- **FR-017**: While a payment is being applied, further method taps MUST be ignored.

**Cash change**

- **FR-018**: Only cash payments MAY exceed the remaining balance; the excess MUST be recorded as change and the balance MUST NOT go below zero.
- **FR-019**: Non-cash payments above the remaining balance MUST be refused with an explanation.
- **FR-020**: After a cash payment with change, the change amount MUST be displayed prominently until the cashier dismisses it or leaves the step. The change MUST also be previewed while an amount above the balance is entered.

**General**

- **FR-021**: All new or changed text MUST be available in Spanish and English.

### Key Entities

- **Cash session**: A cashier's shift on a cash drawer, with a start and an optional end. Valid = open and started today; expired = open and started on an earlier day.
- **Sale line**: A product, quantity and source warehouse on a POS sale. It is short when the quantity is more than the stock available in its warehouse.
- **Warehouse stock**: How many units of a product are available in a warehouse.
- **Payment application**: A tender applied to a sale: method, amount applied, optional reference and, for cash only, change given back.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: No sale can be started, and no payment applied, under a missing or expired cash session (0 occurrences in testing across all entry points: list, direct link, resumed sale).
- **SC-002**: A cashier with an expired session reaches its close screen in one tap from the POS.
- **SC-003**: In Advanced search, selecting any combination of up to 5 labels together with other filters and a term shows exactly the products that match all of them, every time.
- **SC-004**: No sale can move from capture to payment with a short stock-tracked line.
- **SC-005**: Each payment takes one fewer tap than today (amount + method instead of amount + method + apply). A full-balance payment needs one tap.
- **SC-006**: For every cash overpayment, the correct change is shown before the cashier leaves the payment step; no non-cash payment can exceed the balance.
- **SC-007**: Every warehouse name and stock value in the selector is fully readable at the smallest supported screen width.

## Clarifications

### Session 2026-10-17

- Q: When a line's stock cannot be loaded, is it blocking? → A: No. It shows an "unknown stock" warning and the cashier can continue.
- Q: Are there exceptions to the stock block (privileged override, delivery sales)? → A: No. It is a hard block for everyone and every sale type.

## Assumptions

- "Expired" uses the same day-boundary rule the backend already uses to mark a session as expired. This spec does not introduce a configurable session length.
- Viewing sales, and reversing payments already applied, stay allowed without a valid session. Only starting sales and adding payments are blocked.
- The session gate is enforced in the POS screens only. Adding the rule to the backend is a possible follow-up for mbe-api and is not required here.
- "Available stock" is the warehouse stock the backend reports for the product. Units held by other unfinished sales are not subtracted.
- Stock is checked when leaving the capture step, not again at payment time.
- The cash method is identified by its existing payment-method code. All other methods count as non-cash.
- Removing *Apply payment* keeps the current support for split payments: each method tap is one payment, and the cashier can tap several methods in turn.
- No backend changes are expected: change is already supported for payment applications and already counted in the cash cut.
