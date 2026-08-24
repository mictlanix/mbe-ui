# Feature Specification: Back-Office Sales Orders ("Pedidos")

**Feature Branch**: `029-back-office-sales-orders`

**Created**: 2026-08-19

**Status**: Draft

**Input**: User description: "Let's create a spec to build a new sales screen, which is meant to be used to capture sales orders without following the steps of a point of sale's sale, it's just to create a sales order for a customer. I think it can reuse most of the UI built for step 1 of point of sale. So there should be a sales order crud with all the facilities' sales orders (let's see if we can exclude point of sale's orders). There is an analogous screen at legacy mbe named 'Pedidos', screenshots attached."

## Clarifications

### Session 2026-08-19

- Q: Can point-of-sale sales be excluded from the list? → A: **Dropped — the list is not concerned with where an order originated.** Excluding register-originated orders is not expressible against the current backend (every order carries a mandatory register, the listing filter matches a register only by equality, and the list payload omits the register entirely), and the idea was discarded rather than pursued through a backend change. Orders appear in the list on the strength of *who* they belong to, not *where* they were taken — exactly as legacy "Pedidos" behaves (Assumption A1).
- Q: Whose orders does a user see? → A: **Their own, and only their own.** An ordinary user sees the orders they created, last edited, or are the salesperson of, and has no control to widen that. An administrator sees every user's orders and gets two facets an ordinary user does not: salesperson and facility. Filtering by the *creating user* was asked for and dropped — the backend exposes no such filter and does not return the creating user on a list row, so it would require a backend change (Assumption A4).
- Q: What does "all the facilities' sales orders" mean, given the backend always scopes a listing to exactly one facility? → A: **One facility at a time, and only for administrators.** An ordinary user's view is their own orders in their own facility, with no facility control at all. An administrator gets a facility facet in the filter drawer and may switch to any single facility. There is never a merged multi-facility page, because the backend applies a single-facility predicate unconditionally. The restriction is a user-interface affordance, not a security boundary — the backend accepts a facility from any caller holding sales-order read access (Assumption A2).
- Q: How far does the order screen go? → A: **Capture and confirm only.** Customer, terms, currency, dates, priority, salesperson, comment and lines, plus confirm and cancel. Collecting payment stays a separate screen — legacy keeps "Caja de Cobro" as its own menu entry — and delivery/fulfilment planning is not part of this feature (Out-of-Scope OS-2, OS-3).
- Q: Which header fields does the order screen expose beyond the ones the point-of-sale capture step already edits (customer, payment terms, currency, ship-to address, contact, fulfilment intent)? → A: **Promise date, due date, priority, order comment and salesperson.** Promise date ("Límite Para Envío"), priority, comment and salesperson are editable while the order is a draft; priority remains editable after the order is confirmed. **Due date is display-only** — the backend derives it from the payment terms and the customer's credit days and accepts no value for it (Assumption A6).

## User Scenarios & Testing *(mandatory)*

> **Relationship to the point-of-sale feature (specs 020, 023, 025, 026).** This
> feature is the back-office twin of the point-of-sale capture step: the same
> document (a sales order), captured by a salesperson who is not standing at a
> register, without a cash session, without payment collection and without the
> guided step sequence. The customer, product-search, line-editing and totals
> user interface is deliberately the *same* user interface, reused rather than
> re-drawn, so that a change to how a line is edited lands in both places at
> once (FR-029). It does **not** replace the point-of-sale screen and does not
> change its behaviour.

### User Story 1 - Capture and confirm an order for a customer (Priority: P1)

A salesperson takes an order over the phone or at a desk. They open Sales
Orders, start a new order, pick the customer, search products by name or code
and add them as lines, adjust quantity, price, discount, tax and the source
warehouse per line, set the promise date, priority and any notes, watch the
subtotal/tax/total update as they go, and confirm. The order gets its folio and
becomes a real, stock-committing document.

**Why this priority**: This is the feature's reason to exist. Without it, a
salesperson serving a credit customer or a phoned-in order has to pretend to be
a cashier at a register to record the sale.

**Independent Test**: Sign in as a salesperson with sales-order create rights,
start a new order from the Sales Orders screen, add at least one product, and
confirm it — the order comes back with a folio and a "Completed" status, and the
totals shown match the confirmed document.

**Acceptance Scenarios**:

1. **Given** a salesperson on the Sales Orders screen, **When** they choose "New
   order", **Then** an empty order capture screen opens with the deployment's
   default walk-in customer, the default currency and the terms implied by that
   customer already filled in, and **no** order has been written to the server
   yet.
2. **Given** an empty capture screen, **When** the salesperson adds the first
   line, **Then** the draft order is created at that moment and the line appears
   with its price taken from the customer's price list, its quantity defaulted to
   the product's minimum order quantity (or 1 when that minimum is zero) and its
   own tax rate.
3. **Given** a draft with lines, **When** the salesperson changes the customer,
   **Then** every existing line is repriced against the new customer's price list
   and the totals update accordingly.
4. **Given** a draft with at least one line, **When** the salesperson confirms,
   **Then** the order is assigned a folio, its status becomes Completed, the
   screen switches to read-only, and a confirmation is shown.
5. **Given** a draft containing a zero-priced line or a line whose quantity
   exceeds available stock, **When** the salesperson confirms, **Then** the
   confirmation is refused, the offending products are named in the message, and
   the order stays an editable draft.
6. **Given** a user whose account has no point of sale configured, **When** they
   open the Sales Orders screen, **Then** the list and every order still open
   normally but the "New order" action is unavailable and an explanatory message
   tells them what to ask their administrator for.

---

### User Story 2 - Resume, amend or abandon a draft (Priority: P2)

An order captured yesterday is still a draft: the customer has not confirmed the
quantities. The salesperson finds it in the list, opens it, adds a line, corrects
a price and confirms — or, if the customer walked away, cancels it.

**Why this priority**: Orders are rarely finished in one sitting; without this,
every interruption strands a draft that can only be reached from the register.

**Independent Test**: Create a draft, navigate away, find it in the list, reopen
it, change something, and confirm the change survived a reload.

**Acceptance Scenarios**:

1. **Given** a draft order in the list, **When** the salesperson opens it,
   **Then** its header and lines load into the same capture screen used to create
   it, fully editable.
2. **Given** an open draft, **When** the salesperson edits a line's quantity,
   price, discount, tax rate, warehouse or comment, **Then** the totals recompute
   from the server's response, not locally.
3. **Given** an open draft, **When** the salesperson removes its last line,
   **Then** the order stays a draft with a zero total and confirmation is
   unavailable until a line is added.
4. **Given** an open draft, **When** the salesperson cancels it and confirms the
   destructive-action prompt, **Then** the order's status becomes Cancelled, the
   screen becomes read-only, and it is no longer offered for editing.
5. **Given** two people opened the same draft, **When** one confirms it and the
   other then tries to edit a line, **Then** the second is told the order is no
   longer editable and the screen refreshes to the confirmed state rather than
   showing a stale draft.

---

### User Story 3 - Find an order (Priority: P2)

A salesperson or supervisor needs a specific order: by folio, by customer name,
by the day it was taken, or "everything still unconfirmed this month".

**Why this priority**: The list is how every other story is reached, but its
*filtering* is separable — the screen is usable with its default view before the
facets exist.

**Independent Test**: With more than one page of orders present, apply each facet
and the search box in turn and confirm the result set, the total count and the
page controls agree, and that the filter state survives a page reload.

**Acceptance Scenarios**:

1. **Given** an ordinary user on the Sales Orders screen, **When** it first opens,
   **Then** it shows exactly the orders in their facility that they created, last
   edited, or are the salesperson of — newest first — and offers no control that
   would widen the view to anyone else's orders.
2. **Given** the list, **When** the user types a number in the search box,
   **Then** orders whose internal id **or** folio matches are returned; **when**
   they type text, **Then** orders whose customer name matches are returned.
3. **Given** the list, **When** the user opens the filter drawer and sets a date
   range and/or a status (Draft, Completed, Paid, Cancelled), **Then** the list
   narrows accordingly and the filters icon shows how many facets are active.
4. **Given** an active set of filters, **When** the user copies the address and
   reopens it, **Then** the same filters, page and search term are restored.
5. **Given** more results than fit one page, **When** the user pages forward and
   back, **Then** the page indicator and total count stay consistent with the
   filters in force.

---

### User Story 4 - Read a finished order (Priority: P3)

Anyone with sales-order read access opens a confirmed, paid or cancelled order to
check what was sold, at what price, to whom, and whether it has been paid.

**Why this priority**: Valuable but non-blocking — a finished order can be
inspected today from the point-of-sale sales list, and this story mostly moves
that reach into the back-office screen.

**Independent Test**: Open a confirmed order and a cancelled order; confirm every
control is read-only except priority, and that the totals, folio, dates, terms
and balance are all shown.

**Acceptance Scenarios**:

1. **Given** a confirmed, paid or cancelled order, **When** it is opened, **Then**
   the header, lines and totals are shown read-only, with no add-line, remove-line
   or confirm affordance.
2. **Given** a confirmed order, **When** a user with update rights changes its
   priority, **Then** the change is accepted and no other field becomes editable.
3. **Given** an order with money applied against it, **When** it is viewed,
   **Then** its outstanding balance and paid state are visible without leaving the
   screen.
4. **Given** a user holding only read access to sales orders, **When** they open
   the screen, **Then** they can browse and read orders and see no create, edit,
   confirm or cancel affordance anywhere.

---

### User Story 5 - Supervise everyone's orders (Priority: P3)

An administrator oversees the whole operation rather than their own desk: they
see every user's orders, narrow to one salesperson to review that person's week,
and switch to another branch to check what it has taken today.

**Why this priority**: Real supervisory need, but it serves a small group and the
feature is complete for the salespeople it is built for without it.

**Independent Test**: As an administrator, confirm the list shows orders belonging
to other users; apply the salesperson facet and the facility facet in turn and
confirm the rows and the address both follow. As an ordinary user, confirm neither
facet exists and no other user's order is ever visible.

**Acceptance Scenarios**:

1. **Given** an administrator on the Sales Orders screen, **When** it first opens,
   **Then** it shows every user's orders in their own facility, newest first —
   not only their own.
2. **Given** an administrator, **When** they open the filter drawer, **Then** a
   salesperson facet and a facility facet are offered, the facility one defaulting
   to their own facility and the salesperson one to "everyone".
3. **Given** an administrator with the salesperson facet set, **When** the list
   reloads, **Then** only that salesperson's orders are shown and the facet is
   reflected in the address and in the drawer's active-filter count.
4. **Given** an administrator viewing another facility, **When** they start a new
   order, **Then** the order is created in **their own** facility regardless of
   the facet, and the screen says so before they begin.
5. **Given** an ordinary user, **When** they open the filter drawer, **Then**
   neither the salesperson nor the facility facet is present, and no request they
   can make from this screen returns another user's order.

---

### Edge Cases

- **No point of sale configured.** Creation is impossible (the backend refuses an
  order without a register). Listing, searching and reading are unaffected. The
  screen must say which setting is missing rather than surfacing a raw server
  refusal after the user has already typed an order (FR-014).
- **An ordinary user hand-edits the address.** A salesperson or facility facet
  typed into the address by a non-administrator MUST be ignored, not honoured and
  not merely hidden: the list still returns only that user's own orders in their
  own facility (FR-006). The screen must not rely on the facets being absent from
  the interface to keep the scope correct.
- **No facility configured.** The user's own facility cannot be resolved; the
  list has nothing to scope to. The screen shows the same class of explanatory
  blocked state rather than an empty list that looks like "no orders".
- **Credit terms on a customer without credit.** Selecting deferred payment terms
  for a customer with no credit limit, or whose credit is exhausted, is refused by
  the server; the refusal is shown against the terms control and the previous
  terms remain in force.
- **Currency changed after lines exist.** Changing the currency re-expresses every
  line; the user sees the recomputed totals and is told the change applied to the
  whole order, not just to lines added afterwards.
- **A line's product needs stock but no warehouse is chosen.** Confirmation is
  refused and the offending line is named; the line must be able to name its
  warehouse before confirming.
- **A field is left mid-typing.** Typed-but-unconfirmed text is discarded and the
  field returns, visibly, to the order's own value (FR-037). Pressing confirm with
  such text pending raises the keep/discard/keep-editing decision instead
  (FR-036); it never silently saves and never silently discards.
- **Draft was confirmed or cancelled elsewhere.** Any edit is refused; the screen
  reloads the order and shows its true state rather than leaving stale controls.
- **Search or filter yields nothing.** An explicit "no orders match" state,
  distinguishable from "this facility has no orders at all" and from a load error.
- **Page beyond the end.** A page index past the last page (from an old link, or
  after a filter narrows the result set) clamps to the last available page rather
  than showing a blank list.
- **Very long product names, customer names and comments.** Rows and line cards
  truncate with the full value available on hover, and never truncate the folio,
  quantity, price or total.
- **Compact width.** Every column that carries identity or money survives the
  compact layout; the list degrades to the card/row treatment already used by the
  point-of-sale sales list rather than scrolling horizontally.

## Requirements *(mandatory)*

### Functional Requirements

#### Entry point and access

- **FR-001**: The application MUST offer a "Sales Orders" destination in the
  Sales section of the navigation, distinct from the existing Point of Sale and
  Cash Sessions destinations.
- **FR-002**: The destination MUST be gated on read access to the *sales orders*
  object — **not** on the point-of-sale object — so that a back-office salesperson
  with no register privileges reaches it and a cashier without sales-order rights
  does not see it.
- **FR-003**: Creating, editing, confirming and cancelling MUST each be hidden
  (not merely disabled) from a user lacking the corresponding right, per the
  deny-by-default rule.
- **FR-004**: Addressability: the list, its filters and page, and each order MUST
  be reachable by a stable address that survives a reload and can be shared.

#### List

- **FR-005**: The list MUST show, per order: its **reference** — the folio once
  assigned, its internal identifier before that, in one column rather than two —
  its date, the customer, its status, its total and its outstanding balance.
- **FR-006**: For an ordinary (non-administrator) user, the list MUST show only
  the orders that user created, last edited, or is the salesperson of, within their
  own facility, newest first. There MUST be no control — and no address, facet or
  page state — by which such a user can widen the list to another user's orders or
  another facility; the own-orders constraint MUST be applied on every request the
  screen makes, regardless of what the address asks for.
- **FR-006a**: For an administrator, the list MUST show every user's orders in the
  facility in force, newest first.
- **FR-007**: The list MUST support free-text search where a numeric term matches
  the order identifier or the folio and a non-numeric term matches the customer
  name.
- **FR-008**: The list MUST offer, behind the shared filters drawer, a date-range
  facet and a status facet (Draft, Completed, Paid, Cancelled), with the count of
  active facets shown on the drawer's badge.
- **FR-009**: The date-range facet MUST default to a bounded range rather than
  "all time", because an unbounded listing returns tens of thousands of rows on a
  live tenant; the default MUST be documented on the screen (for example, the
  current month) and MUST be clearable back to that default, never to unbounded.
- **FR-010**: The list MUST be paginated server-side with a visible page indicator
  and total count, and MUST clamp an out-of-range page to the last available page.
- **FR-011**: Administrators — and only administrators — MUST additionally be
  offered two facets in the filter drawer: a **facility** facet, selecting exactly
  one facility at a time and defaulting to their own; and a **salesperson** facet,
  choosing one salesperson from the employees marked as such and defaulting to
  "everyone". Both MUST count toward the drawer's active-filter badge and both MUST
  be part of the addressable state.
- **FR-011a**: There is no filter by the order's creating *user*. The list neither
  shows nor filters by who captured an order — only by salesperson (Assumption A4).
- **FR-012**: A row MUST open the order; the row's single direct action MUST be
  Edit and MUST appear only for orders that are still editable (drafts). No print
  or delete row action is offered.
- **FR-013**: The list MUST distinguish "no orders match these filters" from "no
  orders exist" and from a failed load, and MUST offer a retry on failure.

#### Capture and confirm

- **FR-014**: When the signed-in user has no point of sale configured, the
  screen MUST hide the "New order" action and explain, before any order is
  captured, which setting is missing and who can supply it — never surfacing a
  raw server refusal after the user has typed an order. Listing, searching and
  reading orders MUST stay fully available to that user.
- **FR-015**: A "New order" action MUST open an empty capture screen without
  writing anything to the server; the order MUST be created by the first action
  that needs one (adding a line, or editing the header), so that abandoning the
  screen leaves no empty draft behind.
- **FR-016**: The capture screen MUST let the user set the customer, and MUST show
  the customer's identifying details and the fact that changing the customer
  reprices existing lines.
- **FR-017**: The capture screen MUST let the user set payment terms, currency,
  promise date, priority, salesperson, contact, ship-to address and an order-level
  comment, and MUST display the order's identifier, date, exchange rate, folio
  (once assigned), status and derived due date.
- **FR-018**: The due date MUST be shown but MUST NOT be editable — it is derived
  from the payment terms and the customer's credit days.
- **FR-019**: The user MUST be able to find a product by code, name or scan and add
  it as a line, with the price defaulted from the customer's price list, the
  quantity from the product's minimum order quantity (floored at one) and the tax
  rate from the product.
- **FR-020**: Each line MUST allow editing quantity, discount, tax rate, source
  warehouse and a per-line comment, and MUST allow removing the line. Quantity is
  a stepped control floored at one — a line is removed with its own action, never
  stepped to zero — and a burst of steps MUST coalesce into a single write. The unit
  price MUST be shown but MUST NOT be editable: it comes from the customer's price
  list, the shared capture surface already makes it read-only, and legacy
  "Pedidos" shows it read-only too (corrected during planning — research §R9.1).
- **FR-021**: Subtotal, tax and total MUST always be the values the server
  returned for the order; the screen MUST NOT compute or "correct" them locally.
- **FR-022**: The screen MUST show, per line, what stock the chosen warehouse can
  supply, so that a line that will fail confirmation is visible before confirming.
- **FR-023**: Confirming MUST be unavailable until the order has at least one line.
- **FR-024**: A refused confirmation MUST be shown inline, naming every offending
  line the server reported (zero price, insufficient stock, missing warehouse),
  and MUST leave the order an editable draft.
- **FR-025**: A successful confirmation MUST show the assigned folio and switch
  the screen to its read-only presentation.
- **FR-026**: Cancelling MUST be offered on the order's own screen (never as a row
  action), MUST require an explicit confirmation, and MUST be refused with a clear
  message when the server rejects it (an order with money against it, or already
  cancelled).
- **FR-027**: A confirmed, paid or cancelled order MUST render read-only, with
  priority the single exception that remains editable for a user with update
  rights.
- **FR-028**: Every server refusal MUST be surfaced in place, with the user's
  entered values preserved, and MUST never silently discard captured work.

#### Consistency

- **FR-029**: The capture surface MUST be the same one the point-of-sale capture
  step uses — the same customer area, product search, line rows/cards and totals
  bar — so that behaviour cannot diverge between the two screens.
- **FR-030**: Reusing that surface MUST NOT let the two screens share one sale:
  an order open in the back-office screen and a sale in progress at the register
  MUST be independent, and neither may overwrite or close the other.
- **FR-031**: This feature MUST NOT change the point-of-sale screen's behaviour;
  any refactor made to enable reuse MUST leave the register's flow — including its
  step sequence, payment and delivery steps — observably identical.
- **FR-032**: The list, its filters and its pagination MUST follow the shared
  catalog conventions already used across the application (drawer-based facets,
  mandatory pagination, hover and border treatment, consistent action iconography
  and order).
- **FR-033**: Every user-visible string MUST be localized in both supported
  languages, authored in the primary locale first, and every date, money and
  percentage MUST be rendered through the shared formatting surface.
- **FR-034**: The screen MUST be usable at the compact width tier, degrading to
  the established card presentation instead of scrolling horizontally.

#### Outstanding writes and unconfirmed edits

> These four requirements exist because the capture surface this feature reuses
> gained a write-gating mechanism and a visible field-discard rule after this
> spec was first written (specs 030 and 031). The back-office screen inherits
> both, and its own critical action must honour them.

- **FR-035**: Confirming MUST be unavailable while any change this screen started
  is still outstanding — including a stepped value still inside its coalescing
  window, before any request exists. Confirming on figures the order does not yet
  hold is the failure this prevents.
- **FR-036**: If any field on the screen holds typed text the user never
  confirmed when they press confirm, the screen MUST ask rather than decide:
  keep the typed values, discard them, or go back to editing. "Keep" MUST commit
  every one of them and confirm only once they have all landed; a refusal MUST
  leave the order editable with the refusal shown. "Go back to editing" MUST
  restore the typed text, not the stored value.
- **FR-037**: Every editable text field on the order screen MUST discard typed
  text that was never confirmed — on focus loss, on unparseable input, and on a
  server refusal — returning to the value the order actually holds, and MUST make
  that discard visible enough that the user registers their typing was not saved.
- **FR-038**: The screen's outstanding-writes and unconfirmed-edits state MUST be
  independent of the register's. Neither screen's confirm gate may be held open —
  or held shut — by the other's edits.

### Key Entities

- **Sales order**: the document being captured. Identity (internal id, and a
  folio assigned only at confirmation), the facility and register it belongs to,
  its customer and optional per-document customer name, salesperson, payment
  terms, currency and exchange rate, order date, promise date, derived due date,
  priority, comment, contact and ship-to address, its status (draft, completed,
  paid, cancelled), its totals and its outstanding balance.
- **Sales order line**: a product on the order — product identity, unit of
  measure, quantity, unit cost and price, discount rate, tax rate, source
  warehouse, per-line comment, and the derived subtotal, tax and total.
- **Customer**: who the order is for; supplies the price list that prices every
  line, the credit terms that decide the due date, and the contacts and addresses
  offered on the header.
- **Facility**: the site the order belongs to and the only scope a listing can
  have; also the source of the warehouses a line may draw stock from.
- **Product availability**: what a warehouse can still promise for a product —
  what confirmation is judged against, shown per line before confirming.
- **User configuration**: the signed-in user's facility and point of sale, which
  decide what the list shows by default and whether creating an order is possible
  at all.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A salesperson can capture and confirm a three-line order for an
  existing customer in under two minutes, without touching a register or opening
  a cash session.
- **SC-002**: 100% of the header fields legacy "Pedidos" exposes and this feature
  keeps in scope (customer, contact, fiscal recipient, delivery address, priority,
  salesperson, comment, date, promise date, currency, exchange rate, payment terms,
  due date) are visible on the order screen, and every one the backend accepts is
  editable while the order is a draft.
- **SC-003**: A named order can be found from the list in under 15 seconds given
  either its folio or its customer's name.
- **SC-004**: The first page of the list renders in under 2 seconds against the
  reference tenant with its default filters in force, and no view of the list ever
  requests an unbounded date range.
- **SC-005**: An abandoned capture screen leaves zero orders behind on the server —
  measured by opening the screen 10 times without adding a line and observing no
  new orders.
- **SC-006**: Confirming an order that violates a business rule (zero price, short
  stock, missing warehouse) reports every offending line by product name in one
  message, with zero data loss on the draft.
- **SC-007**: The point-of-sale screen's behaviour is unchanged: its existing
  automated tests pass without modification to their assertions.
- **SC-008**: A user without sales-order create rights, and a user with no point of
  sale configured, both reach a state that explains what they cannot do and why,
  in zero failed server round-trips.
- **SC-009**: An ordinary user sees zero orders belonging to anyone else: with an
  order seeded against another employee in the same facility, no combination of
  search term, facet, page or hand-edited address exposes it to them.
- **SC-010**: An administrator can narrow the list to a single salesperson's orders
  in under 15 seconds, and the resulting view is shareable as a link that reproduces
  it exactly.
- **SC-011**: Confirming an order never acts on stale figures: with a quantity
  stepped and a discount typed but unconfirmed, pressing confirm either commits
  both first or discards both — the user's choice — and never confirms on the
  pre-edit totals.

## Assumptions

- **A1 (origin is not a concept this screen has)**: The list selects orders by who
  they belong to and when they were taken, never by where they originated. An order
  captured at a register and one captured here are the same document and appear on
  the same terms — as in legacy "Pedidos". Distinguishing them is not a goal, and
  would not be possible anyway: every order carries a mandatory register, the
  listing filter matches a register only by equality, and the list payload omits
  the register entirely.
- **A2 (scoping is enforced by the client, not the server)**: The backend scopes a
  listing to one facility, defaulting to the caller's own, and accepts an explicit
  facility — and an "everyone's orders" listing — from any caller holding
  sales-order read access. Restricting the facility and salesperson facets to
  administrators, and pinning an ordinary user to their own orders, are therefore
  user-interface decisions, not enforced boundaries. The spec treats them as
  product rules and requires them to hold for every request the screen issues
  (FR-006), not merely for the controls it draws. A user determined to see more can
  still call the backend directly; closing that would be a backend change and is
  not claimed here.
- **A3 (no backend change, no code generation)**: Every filter, field and action
  this feature needs is already exposed by the existing sales-order endpoints and
  the generated client. If planning discovers otherwise, the gap is filed as a
  backend issue and recorded as an external dependency rather than patched across
  repository boundaries.
- **A4 (no creating-user column and no creating-user filter)**: The list payload
  carries the order id, folio, customer, salesperson, date, due date, currency,
  status, total and balance. Legacy's "Usuario" (creating user) and "Forma de Pago"
  (payment terms) columns have no source in it, so they are not reproduced, and the
  backend offers no filter by creating user either — only by salesperson. Filtering
  by user was asked for on 2026-08-19 and dropped for that reason rather than
  deferred; adding it would need both a new backend filter and a new field on the
  list payload. Legacy's "Pagado" tick is represented by the status and balance
  already available.
- **A4a (own orders means creator, last editor or salesperson)**: "My orders" is
  the backend's own definition — orders where the signed-in user's employee is the
  creator, the last updater, or the named salesperson. Every authenticated user has
  an employee record, so the narrowing always applies and never silently degrades
  to "everything".
- **A5 (no printing)**: There is no server-rendered document for a sales order, so
  legacy's printer row action has no counterpart here. Documents remain
  server-rendered when they exist; nothing is rendered client-side (OS-4).
- **A6 (due date is derived)**: The due date follows from the payment terms and the
  customer's credit days and is not accepted as input; it is displayed only.
- **A7 (creation needs a configured register)**: Creating an order requires the
  signed-in user to have a point of sale configured. Users expected to use this
  screen are assumed to have one; those who do not get an explanatory blocked
  state for creation only (FR-014), not a broken screen.
- **A8 (default range)**: The default date range is assumed to be the current
  month, chosen so that a back-office user's recent work is visible without an
  unbounded query. It is a facet the user can widen or narrow.
- **A9 (reuse is a refactor, not a copy)**: The point-of-sale capture widgets
  currently read a single, screen-scoped piece of sale state directly. Sharing them
  is assumed to require parameterizing that state so two screens can hold two
  independent orders — a refactor of existing code, whose success condition is that
  the register's behaviour is observably unchanged (FR-030, FR-031, SC-007).
- **A10 (the capture surface arrives with its own behaviour)**: The shared surface
  already carries the debounced, floored-at-one quantity stepper and the
  confirm-or-visibly-discard text-field rule that specs 030 and 031 added, plus a
  scoped outstanding-writes signal and an unconfirmed-edits registry. The
  back-office screen **inherits** all of it and MUST NOT re-implement any of it;
  what it adds is its own scope (FR-038) and its own critical-action gate
  (FR-035, FR-036).

## Out of Scope

- **OS-1**: Filtering or labelling orders by where they originated (register versus
  back office), and filtering by the order's creating user. Both were considered and
  dropped on 2026-08-19; neither is expressible without a backend change.
- **OS-2**: Collecting payment. Payments remain their own screen and their own
  privilege; this feature neither collects nor reverses money.
- **OS-3**: Delivery and fulfilment planning — delivery orders, destinations and
  line distribution — even though the order header carries a fulfilment intent and
  a ship-to address.
- **OS-4**: Printing or exporting an order.
- **OS-5**: Converting a quotation into an order, and any change to quotations.
- **OS-6**: Changes to the point-of-sale flow's own behaviour, its sales list, its
  cash sessions, or its payment and delivery steps.
- **OS-7**: Bulk actions on the list (multi-select, bulk cancel, bulk export).

## Dependencies

- The existing sales-order endpoints (list, create, read, update header, add /
  update / remove line, confirm, cancel, product lookup) and their privilege
  model.
- The existing customer, contact, address, facility, employee and warehouse
  catalogs — for the header pickers, the per-line warehouse choice, and the
  administrator's salesperson and facility facets.
- The existing point-of-sale capture user interface, which this feature makes
  reusable and shares (FR-029).
- The shared list conventions (filters drawer, search bar, pagination), the design
  tokens, and the shared formatting surface.
