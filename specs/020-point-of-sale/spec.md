# Feature Specification: Point of Sale — Sale Capture

**Feature Branch**: `020-point-of-sale`

**Created**: 2026-08-03

**Status**: Draft

**Input**: User description: "Add a new screen for point of sales. This design consists on a two or three steps workflow: (1) A screen where the user should first select the customer (or create a new customer record) and how the sales order will be delivered: On store (Tienda), a programmed delivery (Domicilio) that requires including one or many addresses, or both ways (Mixta). The user should also search and add the products of the sales order, quantities, discounts, taxes and the warehouse that will provide the products. (2) An optional step, if user selects Delivery (Domicilio) or both (Mixta), in which the user should add the delivery addresses and split the quantities between destinations. On store sales should omit this step. (3) A screen where the user should record the payments."

## Overview

Every screen this application has shipped so far maintains master data. This is
the first that **sells** — the counter screen a cashier lives in all day, and the
only screen where a mistake costs money rather than a re-edit.

The workflow adapts to how the goods leave the store. A counter sale is two
steps: capture the sale, take the money. A sale that has to be delivered is
three: capture the sale, take the money, then say where each unit goes. The
third step appears only when it has something to do.

Three decisions shape everything below, and all three came from the user rather
than from the mock:

1. **The sale is recorded live, from the first keystroke.** The order record is
   opened when the cashier enters the screen, and every line lands on the server
   as it is captured — not held in a basket and posted at the end. A crash, a
   reload or a walk-away leaves a real order that can be picked up again, and the
   open-orders selector in the app bar is what picks it up.
2. **The screen lives inside the ordinary application shell.** It is not a
   kiosk. The mock draws its own hamburger, back arrow and window chrome; those
   are duplicates of what the shell already provides and are dropped. What is
   kept from the mock's header is the open-orders selector and the step
   indicator.
3. **Delivery is the last step, not the middle one.** The order of the steps is
   Venta → Cobro → Entrega, which departs deliberately from the mock's
   Venta → Entrega → Cobro.

The layout in `artifacts/point_of_sale/POS Adaptativo.dc.html` is the visual
reference for this feature — the expanded (desktop) frames `2a`, `2b`, `2c`,
`2d` and the compact frames in `2e`. Its dark canvas palette is a presentation
of the mock, not a requirement: the screen uses the application's existing
theme. The mock's step *order* is superseded by decision 3 above; its step
*content* stands.

That third decision is worth its own paragraph, because it removes the one
constraint that would otherwise have bent the feature out of shape. A delivery
record cannot exist against an unconfirmed sale, and confirming the sale is
what freezes it — so with delivery in the middle, destinations would have had
to be held in the screen and written in a batch when the cashier left for
payment: the one place where "recorded live" could not hold, and a batch whose
partial failure needed its own recovery story. With delivery last, the sale is
already confirmed and paid by the time the step opens, so **every destination
is recorded the moment it is entered**, exactly like every line before it. The
promise of live recording now holds across the whole workflow with no
exception.

Nothing in the money depends on the destinations — shipping is not charged (see
A-003) — so taking payment before knowing where the goods go costs the customer
nothing.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Sell across the counter and take the money (Priority: P1)

A cashier opens the point of sale and starts a sale. The customer defaults to
the walk-in customer, the fulfilment mode defaults to counter pickup, and a
fresh order is already open. They scan or search products; each product lands as
a line showing the warehouse it will come from, its available stock, quantity,
unit, price, discount, tax and line total, with a running summary of item count,
subtotal, discounts, tax and grand total fixed at the bottom. They adjust a
quantity, apply a discount to one line, and press the button that takes them to
payment. The sale is confirmed and given its folio. On the payment step they
enter an amount, pick a payment method, add the payment, repeat until the
balance reaches zero, and confirm. The sale is done.

**Why this priority**: This is the entire product for a counter sale, the most
common transaction in the store, and it stands alone: a store that only ever
sells across the counter is fully served by this story. Every other story adds a
branch to a flow that already works end to end.

**Independent Test**: Open the screen, add two products, take a single cash
payment for the full amount, and confirm — the resulting order exists, is
confirmed, carries both lines and shows a zero balance.

**Acceptance Scenarios**:

1. **Given** a cashier with permission to create sales orders, **When** they
   open the point of sale, **Then** an order is opened for their point of sale
   and facility, the walk-in customer and counter pickup are preselected, and
   the line area is empty.
2. **Given** an open sale, **When** the cashier scans a barcode that matches one
   product, **Then** that product is added as a line at the customer's price
   list price with the default warehouse, and the search field clears ready for
   the next scan.
3. **Given** a search term matching several products, **When** the cashier
   searches, **Then** matches are listed with code, name, brand, price and
   per-warehouse availability, and choosing one adds it as a line.
4. **Given** a line already on the sale, **When** the cashier changes its
   quantity, price, discount or warehouse, **Then** the change is recorded and
   the line total, the running totals and the stock indicator all update.
5. **Given** a line for a product with insufficient stock in the chosen
   warehouse, **When** the line is displayed, **Then** it carries a visible
   warning naming the shortfall, and the cashier can still continue capturing.
6. **Given** a sale with at least one line, **When** the cashier continues to
   payment, **Then** the sale is confirmed, a folio is assigned, the lines
   become read-only, and the payment step opens showing the full total as
   outstanding.
7. **Given** the payment step with an outstanding balance, **When** the cashier
   enters an amount, selects a method and adds the payment, **Then** the payment
   is recorded against the sale, the applied-payments list gains an entry, and
   the outstanding balance drops by that amount.
8. **Given** a counter-pickup sale whose payments cover the total, **When** the
   cashier confirms, **Then** the sale shows as paid, any change due is
   displayed, the workflow ends without a delivery step, and the screen offers
   to start a new sale.
9. **Given** payments that do not yet cover the total, **When** the cashier
   looks at the confirm action, **Then** it is unavailable and explains that it
   unlocks when the amount paid equals the total.

---

### User Story 2 - Send the goods to one or more addresses (Priority: P2)

The customer wants most of the order delivered to a building site and will take
the rest with them now. The cashier picks the mixed mode during capture and
names the main delivery address there, then captures the lines and takes the
money as usual. Because the sale is not a counter sale, a third step opens after
payment. There they confirm the first destination, give it a contact and a
delivery date, and set how many units of each line go there. A second
destination takes another share. What is left stays as counter pickup. A panel
shows, per line, how the ordered quantity is distributed and whether every unit
has been accounted for. The sale closes when the whole order is distributed.

**Why this priority**: Delivery is a large share of the business this product
serves, but it is a branch off a flow that must already work. Built second, it
inherits a proven capture and payment path — and because it now runs against a
confirmed, paid sale, each destination is recorded as it is entered rather than
staged.

**Independent Test**: Capture and pay a two-line sale in delivery mode, split one
line between two addresses, close the sale — two delivery records exist, one per
address, holding exactly the quantities entered.

**Acceptance Scenarios**:

1. **Given** counter pickup is selected, **When** the sale is paid, **Then** the
   delivery step never appears and the workflow ends.
2. **Given** delivery or mixed mode is selected during capture, **When** the
   cashier chooses that mode, **Then** they must name the sale's main delivery
   address, picking an existing address of the customer's or creating one
   inline.
3. **Given** a paid sale in delivery or mixed mode, **When** the payment step
   closes, **Then** the delivery step opens with the first destination
   pre-filled from the sale's main delivery address and every line showing its
   ordered quantity.
4. **Given** the delivery step, **When** the cashier adds a destination, **Then**
   they can pick one of the customer's existing addresses or create a new one
   without leaving the step, give it a contact name, phone and delivery date,
   and the destination is recorded as soon as it is complete.
5. **Given** a recorded destination, **When** the cashier assigns quantities line
   by line, **Then** each change is recorded, each line's remaining
   undistributed quantity updates, and no destination can be given more of a
   line than remains.
6. **Given** mixed mode, **When** some quantity is left undistributed, **Then**
   it is shown as staying at the counter for pickup, and closing the sale
   records it as a counter-pickup delivery.
7. **Given** pure delivery mode with quantity left undistributed, **When** the
   cashier tries to close the sale, **Then** they are blocked and told how many
   units of which lines are still unassigned.
8. **Given** a destination that could not be recorded, **When** the failure
   occurs, **Then** the reason is shown, the entered values are kept, and the
   cashier can retry that destination alone — every other destination already
   recorded is unaffected.

---

### User Story 3 - Pick up a sale that was left open (Priority: P2)

A cashier is halfway through a large order when the customer goes back to the
aisle for one more item. Another customer is served in the meantime, and the
first sale is left as it stands. The app bar shows how many sales are open
today; choosing the earlier one restores it exactly as it was left — customer,
mode, lines and totals — and capture continues.

**Why this priority**: Live recording makes half-finished sales an everyday
occurrence rather than an accident, so the means to return to one is part of the
same promise. It is separable from P1 only because a single-sale-at-a-time store
can operate without it.

**Independent Test**: Start a sale with two lines, leave the screen, reopen the
point of sale and select the earlier sale from the selector — both lines and the
selected customer are still there.

**Acceptance Scenarios**:

1. **Given** unconfirmed sales opened at this point of sale, **When** the
   cashier opens the selector in the app bar, **Then** those sales are listed
   with their reference, customer and total, newest first.
2. **Given** the selector, **When** the cashier picks a sale, **Then** its
   customer, fulfilment mode, lines and totals are restored and capture
   continues where it stopped.
3. **Given** a restored sale, **When** the cashier starts a new sale instead,
   **Then** a fresh order is opened and the earlier one remains open and
   selectable.
4. **Given** a confirmed but unpaid sale, **When** it is selected, **Then** the
   screen opens directly on the payment step with its lines read-only and its
   outstanding balance shown.
5. **Given** a paid sale in delivery or mixed mode whose lines are not yet fully
   distributed, **When** it is selected, **Then** the screen opens directly on
   the delivery step with the destinations already recorded and the quantities
   still undistributed.
6. **Given** an open sale with no lines, **When** the cashier abandons it,
   **Then** it is cancelled rather than left as an empty open sale.

---

### User Story 4 - Register a customer without losing the sale (Priority: P3)

A new customer wants to buy on the spot. The cashier opens the new-customer form
from the customer field, fills in the customer's code, name, price list, zone,
credit terms and delivery flags, saves, and the new customer is attached to the
sale in progress. Capture resumes with the customer's price list in effect.

**Why this priority**: A workaround exists — register the customer in the
Customers screen and come back — so this is convenience, not capability. It is
also the story most likely to be trimmed if the release must be cut short.

**Independent Test**: From an open sale, create a customer through the inline
form and confirm the sale is now attached to that customer with their price list
applied to subsequently added lines.

**Acceptance Scenarios**:

1. **Given** an open sale, **When** the cashier chooses to create a customer,
   **Then** the form opens over the sale on wide displays and full-screen on
   compact ones, without discarding what has been captured.
2. **Given** the form, **When** it is saved, **Then** the customer is created and
   immediately attached to the sale, and the header shows the new customer's
   name, credit standing and price list.
3. **Given** the form has a validation error or the code is already taken,
   **When** saving fails, **Then** the message is shown on the form with the
   entered values kept.
4. **Given** the form is cancelled, **When** it closes, **Then** the sale is
   untouched and still attached to whichever customer it had.
5. **Given** lines were captured before the customer changed, **When** the
   customer changes, **Then** the cashier is told that existing lines keep the
   prices they were captured at and which lines those are.

---

### User Story 5 - Work the counter from a phone (Priority: P3)

A salesperson on the shop floor takes the same sale on a phone: a single-column
capture list, a full-screen customer form, the delivery destinations as stacked
expandable cards, and a payment step with an on-screen amount pad. Every step
of the desktop flow is reachable; nothing is hidden behind a horizontal scroll.

**Why this priority**: The desktop counter station is the primary target and the
compact layout serves a secondary usage, but the project's layout rules require
every screen to remain usable below 600 px, so it cannot be dropped — only
sequenced last.

**Independent Test**: Drive the complete counter-sale story at 390 px wide
without horizontal scrolling and with every control reachable.

**Acceptance Scenarios**:

1. **Given** a viewport under 600 px, **When** the screen renders, **Then** lines
   are a single-column list showing product, warehouse, quantity, price and
   total, and the running total and primary action stay fixed at the bottom.
2. **Given** a viewport under 600 px, **When** the step indicator renders,
   **Then** it collapses to a step-of-total label rather than the full step
   list.
3. **Given** a viewport under 600 px, **When** the payment step opens, **Then**
   amount entry, quick amounts, methods and applied payments are all reachable
   by vertical scrolling alone.
4. **Given** any viewport width, **When** any step renders, **Then** the page
   never scrolls horizontally and no critical value is truncated without a way
   to read it in full.

---

### Edge Cases

- **Stock ran out between capture and confirmation.** Confirmation is rejected
  because another sale took the stock first. The cashier must be told which
  lines and which warehouses, and left on the capture step able to fix them —
  not dropped into an inconsistent payment step.
- **A line is priced at zero.** Confirmation is rejected. The offending lines
  must be identified.
- **A manually entered price falls outside the allowed margin.** The line is
  rejected on entry; the cashier is told, and the previous price stands.
- **A quantity below the product's minimum order quantity.** Rejected on entry
  with the minimum named.
- **The customer is changed after lines exist.** Existing lines keep their
  captured prices; only lines added afterwards use the new price list.
- **Credit terms chosen for a customer with no credit line.** Refused, with the
  reason shown, and the sale stays on immediate terms.
- **A payment in a currency other than the sale's.** Refused before the payment
  is recorded.
- **A payment larger than the outstanding balance.** Accepted as a tender, with
  the excess presented as change rather than as an overpayment.
- **A payment method that requires a reference or authorization.** The payment
  cannot be added until the reference is entered.
- **The cashier leaves after confirmation but before paying.** The sale stays as
  a confirmed, unpaid order, reachable from the selector, and its stock stays
  committed.
- **The cashier leaves after paying but before capturing the destinations.** The
  sale stays paid with its delivery incomplete, and reopening it lands on the
  delivery step. The sale must not be presented as finished while units are
  still undistributed.
- **The customer decides at the till that they will take the goods after all.**
  A sale captured as delivery or mixed cannot change mode once confirmed; the
  remedy is to leave the quantities undistributed as counter pickup in mixed
  mode, or to handle it from the sales-order screens.
- **The last line is removed from a sale.** Continuing to payment is blocked
  until at least one line exists.
- **The connection drops mid-capture.** The failed action is reported and
  retryable, and the screen's contents are reconciled against the server rather
  than assumed.
- **The same open sale is opened at two stations.** The second station works from
  what the server holds; a stale change is reported rather than silently
  overwriting.
- **A destination's address is deleted while the delivery step is open.** The
  destination is flagged and must be repointed before continuing.
- **Zero destinations in delivery mode.** Continuing is blocked until at least
  one destination exists.

## Requirements *(mandatory)*

### Functional Requirements

#### Entering the screen and the sale record

- **FR-001**: The application MUST offer a point-of-sale destination in the
  existing navigation, gated on permission to read sales orders, and MUST render
  it inside the existing application shell rather than as a separate full-screen
  surface.
- **FR-002**: Entering the screen without a sale in progress MUST open a new
  sale record immediately, associated with the cashier's point of sale and
  facility, before any product is captured.
- **FR-003**: The screen MUST NOT duplicate chrome the shell already provides —
  no second hamburger, no second back affordance, no simulated window frame —
  and MUST use the shell's own navigation controls.
- **FR-004**: The app bar MUST carry the open-sales selector and the step
  indicator, and the step indicator MUST show which of the two or three steps is
  current, which are complete, and which are still ahead.
- **FR-005**: The step indicator MUST present the steps in the order capture,
  payment, delivery — two steps when the fulfilment mode is counter pickup and
  three when it is delivery or mixed — and MUST update the moment the mode
  changes.
- **FR-006**: A cashier without permission to create sales orders MUST NOT be
  able to open a sale, and MUST be told why rather than shown a broken screen.

#### Recording the sale as it is captured

- **FR-007**: Every capture action — adding a line, changing a line's quantity,
  price, discount or warehouse, removing a line, changing the customer, the
  fulfilment mode, the payment terms or the currency — MUST be recorded on the
  server as it happens, not deferred to a later submit.
- **FR-008**: After each recorded action, the screen MUST show the totals the
  server returns rather than totals it computed locally, so that displayed
  subtotal, discount, tax and grand total always match what the sale is worth.
- **FR-009**: A capture action that the server rejects MUST leave the screen
  showing the last accepted state, name the reason, and be retryable without
  re-entering the rest of the sale.
- **FR-010**: While a capture action is in flight, the screen MUST remain usable
  for reading, and MUST NOT lose keystrokes typed into the product search.

#### Customer

- **FR-011**: The sale MUST open with the configured default walk-in customer
  preselected, and the customer area MUST show the customer's name, credit line,
  outstanding balance and price list.
- **FR-012**: The cashier MUST be able to search for and select a different
  customer by code or name, and the selection MUST be recorded on the sale.
- **FR-013**: The cashier MUST be able to create a customer from the sale
  without leaving it, capturing at minimum code, name, price list, zone, credit
  limit, credit days, tax registration, whether the customer may receive
  deliveries and whether deliveries need a signed document.
- **FR-014**: A customer created from the sale MUST be attached to the sale on
  save, and the customer's price list MUST apply to lines added afterwards.
- **FR-015**: When the customer changes on a sale that already has lines, the
  screen MUST tell the cashier that existing lines keep the prices they were
  captured at.
- **FR-016**: The cashier MUST be able to choose immediate or credit payment
  terms; choosing credit for a customer without an available credit line MUST be
  refused with the reason shown.

#### Fulfilment mode

- **FR-017**: The screen MUST offer exactly three fulfilment modes — counter
  pickup, delivery, and mixed — as a single always-visible selector, defaulting
  to counter pickup.
- **FR-018**: Selecting delivery or mixed MUST add a delivery step after the
  payment step; selecting counter pickup MUST remove it. The mode MUST be
  changeable freely while the sale is unconfirmed and MUST be fixed once the
  sale is confirmed.
- **FR-019**: Delivery and mixed modes MUST be unavailable for a customer not
  permitted to receive deliveries, with the reason shown.
- **FR-056**: Selecting delivery or mixed MUST require the cashier to name the
  sale's main delivery address before capture continues, choosing one of the
  customer's addresses or creating one inline, and that address MUST be recorded
  on the sale.
- **FR-057**: The fulfilment mode MUST survive leaving and reopening the screen:
  a resumed sale MUST reopen in the mode it was captured in, determined from
  what the sale itself records rather than from anything held in the screen.

#### Capturing lines

- **FR-020**: The screen MUST provide one input that both accepts a scanned
  barcode and searches by code, name, brand or SKU, and MUST keep focus in it
  after each successful add so consecutive scans need no clicks.
- **FR-021**: A scan that matches exactly one product MUST add that product
  directly; a search that matches several MUST present the matches with code,
  name, brand, price and per-warehouse availability for the cashier to choose.
- **FR-022**: Each line MUST show the product name and code, the source
  warehouse, that warehouse's availability for the product, quantity, unit,
  unit price, discount, tax rate, and the line total.
- **FR-023**: Each line's quantity, unit price, discount rate, source warehouse
  and tax treatment MUST be editable in place, and quantity MUST additionally be
  adjustable by increment and decrement controls.
- **FR-024**: Adding a product MUST default its source warehouse to the
  warehouse configured for the cashier's point of sale, and the cashier MUST be
  able to change it per line and see availability for the chosen warehouse.
- **FR-025**: A line whose ordered quantity exceeds availability in its chosen
  warehouse MUST carry a visible, non-blocking warning stating the shortfall,
  and MUST offer to reduce the quantity to what is available.
- **FR-026**: A line for a product with no availability in its chosen warehouse
  MUST be distinguished from a partial shortfall and MUST offer a way to look at
  other warehouses.
- **FR-027**: The cashier MUST be able to remove a line, and removal MUST take
  effect immediately with no confirmation prompt for a line that has just been
  added.
- **FR-028**: A summary MUST stay visible at all times showing line count, total
  units, subtotal, total discount, tax and grand total in the sale's currency.

#### Delivery destinations

- **FR-029**: The delivery step MUST open after the sale is paid, and only for
  sales in delivery or mixed mode. It MUST list every destination as a card
  carrying its address, contact name and phone, delivery date, its line count
  and its unit count, and MUST allow adding, editing and removing destinations.
- **FR-030**: A destination MUST be recorded as a delivery against the sale as
  soon as its address is chosen, and each subsequent change to it — contact,
  date, or any line quantity — MUST be recorded as it is made, consistent with
  FR-007. Nothing on this step may be held unrecorded until the sale closes.
- **FR-031**: Adding a destination MUST let the cashier pick one of the
  customer's existing addresses or create a new address inline, without leaving
  the step or losing the distribution already entered.
- **FR-032**: Each destination MUST allow a per-line quantity to be set, and MUST
  refuse a quantity that would take a line beyond what remains undistributed
  across all destinations.
- **FR-033**: The step MUST show, for every line, the ordered quantity and how it
  is distributed across destinations and the counter, and MUST show a running
  count of distributed units against total units.
- **FR-034**: The first destination MUST be pre-filled from the sale's main
  delivery address (FR-056), and the cashier MUST be able to change it.
- **FR-035**: In mixed mode, quantity left undistributed MUST be presented as
  staying at the counter for pickup and MUST NOT block closing the sale; in
  delivery mode, any undistributed quantity MUST block closing and the block
  MUST name how many units of which lines are unassigned.
- **FR-036**: Closing a mixed-mode sale MUST record the undistributed remainder
  as a counter-pickup delivery, so that every ordered unit is accounted for by
  exactly one delivery record.
- **FR-037**: A destination the system refuses to record MUST leave the rest of
  the step untouched: the reason is shown, the entered values are kept, and the
  cashier can retry that destination alone.
- **FR-058**: A sale in delivery or mixed mode MUST NOT be presented as finished
  while units remain undistributed, and such a sale MUST remain reachable from
  the open-sales selector until its delivery is complete.

#### Confirming the sale

- **FR-038**: Continuing from the capture step to the payment step MUST confirm
  the sale, and confirmation MUST be blocked while the sale has no lines.
- **FR-039**: A confirmation rejected for insufficient stock or zero-priced lines
  MUST leave the cashier on the capture step with the offending lines
  identified, and the sale still editable.
- **FR-040**: After confirmation the sale's reference MUST switch from its
  provisional identifier to the assigned folio wherever it is displayed.
- **FR-041**: After confirmation, the lines, the customer, the payment terms and
  the fulfilment mode MUST become read-only, and the screen MUST say so rather
  than offering controls that will fail.

#### Taking payment

- **FR-042**: The payment step MUST show the sale's total, the amount already
  paid, and the outstanding balance at all times.
- **FR-043**: The cashier MUST be able to enter a payment amount by keyboard and
  by an on-screen number pad, and MUST be offered quick amounts including the
  full outstanding balance.
- **FR-044**: The cashier MUST select a payment method for each payment from the
  methods the system supports, and each method MUST state whether it needs a
  reference or authorization.
- **FR-045**: A payment whose method requires a reference MUST NOT be recordable
  until the reference is entered.
- **FR-046**: Adding a payment MUST record it against the sale immediately and
  reduce the outstanding balance by the applied amount.
- **FR-047**: A tender larger than the outstanding balance MUST apply only the
  outstanding amount and present the difference as change due.
- **FR-048**: Applied payments MUST be listed with method, amount, reference and
  any pending-validation state, and each MUST be reversible while the sale is
  unconfirmed as paid, with the reversal reason recorded.
- **FR-049**: The action that leaves the payment step MUST be unavailable while
  the outstanding balance is above zero, and MUST state the condition that
  unlocks it.
- **FR-050**: Leaving the payment step MUST show the change due, then end the
  workflow and offer to start a new sale for a counter-pickup sale, or open the
  delivery step for a delivery or mixed sale.
- **FR-051**: A sale on credit terms MUST be able to leave the payment step with
  an outstanding balance, and the screen MUST make clear that the remainder is
  owed rather than unpaid in error.

#### Presentation

- **FR-052**: The screen MUST use the application's existing theme, typography
  and iconography — the mock's palette is reference only — and MUST honour the
  established conventions for filters, pickers, forms and error banners.
- **FR-053**: The screen MUST be usable from 1440 px down to 360 px without
  horizontal scrolling at any width, collapsing the line grid to a single-column
  list and the step indicator to a step-of-total label below 600 px.
- **FR-054**: All screen text MUST come from the application's localization
  resources in both supported languages, with no literal strings in the screen
  itself.
- **FR-055**: Money and quantities MUST be formatted for the active locale, and
  the sale's currency MUST be shown wherever a total is presented.

### Key Entities

- **Sale** — what the customer is buying: the customer, the salesperson, the
  point of sale, payment terms, currency, priority, its lines, its derived
  subtotal, tax, total and outstanding balance, and its state (open, confirmed,
  paid, cancelled). Opened when the screen is entered; confirmed when capture
  ends; paid when payments cover it.
- **Sale line** — one product on the sale: the product with its code and name,
  quantity, unit price, discount rate, tax rate and whether tax is included, the
  source warehouse, and the derived line subtotal, tax and total.
- **Product lookup result** — what a search or scan returns: code, name, brand,
  model, barcode, price for this customer, tax treatment, minimum order
  quantity, and availability per warehouse expressed both as physically on hand
  and as still promisable.
- **Fulfilment mode** — how this sale's goods reach the customer: counter
  pickup, delivery, or mixed. Chosen during capture, fixed at confirmation,
  recoverable from the sale itself, and the thing that decides whether a
  delivery step follows payment.
- **Destination** — one place goods are going: an address, a contact name and
  phone, a delivery date, and the quantity of each sale line assigned to it.
  Recorded against the sale as soon as it is named. The counter-pickup
  remainder in a mixed sale becomes a destination of its own when the sale
  closes.
- **Payment** — money taken: an amount, a method, a currency, an optional
  reference, its validation state, and how much of it is applied to this sale
  versus returned as change.
- **Customer** — who is buying: code, name, price list, zone, credit limit and
  days, outstanding balance, whether they may receive deliveries and whether
  deliveries require a signed document, and their addresses.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A cashier completes a two-line counter sale — open, capture, pay,
  close — in under 45 seconds using only a barcode scanner and the number pad.
- **SC-002**: A scanned product appears as a line within 1 second of the scan
  under normal store network conditions.
- **SC-003**: A cashier can capture 30 lines on one sale without the running
  totals ever disagreeing with the recorded sale.
- **SC-004**: 100% of sales interrupted at any step (reload, navigation away,
  browser crash) are recoverable from the open-sales selector, reopening on the
  step they were left at with every captured line, payment and destination
  intact.
- **SC-005**: A three-destination delivery sale results in exactly three
  delivery records whose quantities sum, per line, to the ordered quantity.
- **SC-006**: No sale can be closed with an outstanding balance unless it is on
  credit terms — 0 occurrences across the acceptance suite.
- **SC-007**: Every one of the five user journeys is completable at 390 px wide
  with zero horizontal scrolling.
- **SC-008**: Every error the server can raise during capture, confirmation,
  delivery creation and payment is surfaced with a message naming the cause —
  0 silent failures and 0 raw technical errors shown to the cashier.
- **SC-009**: Both supported languages render every screen with no missing
  translations and no clipped labels at any supported width.

## Assumptions

- **A-001**: "Tienda", "Domicilio" and "Mixta" are the Spanish labels for
  counter pickup, delivery and mixed fulfilment; the English resources get
  equivalent terms. The three modes are exactly the two fulfilment types the
  system records, plus the mixed case that produces both.
- **A-002**: The customer's code is entered by the cashier when creating a
  customer from the sale. The mock's auto-generated code is not implemented —
  the backend requires an explicit code and no generation rule exists.
- **A-003**: The mock's shipping cost line in the delivery summary is **not**
  implemented: no shipping charge exists in the data model, and inventing one is
  out of scope.
- **A-004**: The mock's credit-note and voucher payment methods are shown as
  standard payment methods; applying an existing credit note document to a sale
  is out of scope for this feature.
- **A-005**: Payments attach to the cashier's open cash session when one exists
  and record without one when it does not. Opening and closing cash sessions is
  a separate feature and is not part of this screen.
- **A-006**: The mock's "pending validation in terminal" payment state reflects
  the existing verification lifecycle for card payments; this screen displays
  that state but does not perform the verification.
- **A-007**: The default walk-in customer, the default point of sale and the
  default warehouse come from the cashier's configured settings; this screen
  reads them and does not manage them.
- **A-008**: Each destination carries its own delivery date on its own record.
  The sale keeps the promise date it was opened with — the destinations are
  captured after the sale is confirmed, and a confirmed sale's promise date can
  no longer be changed.
- **A-009**: Confirming a sale commits stock. A sale left confirmed and unpaid
  therefore holds its stock until it is paid or cancelled; cancelling such a
  sale is done from the sales-order screens, not from this one.

## Dependencies

- **D-001**: Sales order capture, confirmation, product lookup with per-warehouse
  availability, delivery records, customer payments and their application, and
  customer and address creation all already exist in the backend. No new backend
  capability is required for the counter-sale and payment stories.
- **D-002**: Creating a delivery record requires a confirmed sale, and — in
  deployments that enable the corresponding setting — a paid or credit sale.
  Putting the delivery step after payment satisfies both conditions by
  construction, in every deployment and whichever way that setting is
  configured. This was the deciding argument for the step order, and it is why
  no deployment check is needed before implementation.
- **D-003**: Splitting one sale across several destinations is expressed as a
  sequence of create-then-trim operations against the delivery API: a new
  destination claims whatever quantity is not yet spoken for, and the cashier's
  per-line entries trim it back. There is no single call that creates a delivery
  for a named subset of quantities. A backend enhancement request for a
  per-destination create is worth filing but is not a blocker.
- **D-004**: The screen reuses the existing customer picker, address inline
  creation, warehouse and price-list pickers rather than introducing new ones.

## Out of Scope

- Printing or emailing a sale ticket or receipt.
- Invoicing, tax stamping, or any fiscal document.
- Cash session opening, closing, counting or reconciliation.
- Returns, refunds, credit notes and cancellation of a confirmed sale.
- Sales quotes and converting a quote into a sale.
- Delivery routing, itineraries, driver assignment and proof of delivery.
- Card terminal integration and payment verification.
- Offline capture: the screen requires a connection, consistent with the rest of
  the application.
- Discount authorization workflows beyond the margin rules the backend already
  enforces.

## Verbatim Constraints

These values were pinned by the request and MUST be used exactly as written.

- Fulfilment mode labels (Spanish locale): `Tienda`, `Domicilio`, `Mixta`
- Step labels (Spanish locale), in flow order: `Venta`, `Cobro`, `Entrega`
- The action that ends capture and confirms the sale (Spanish locale):
  `Continuar al cobro`
- Design reference: `artifacts/point_of_sale/POS Adaptativo.dc.html`
