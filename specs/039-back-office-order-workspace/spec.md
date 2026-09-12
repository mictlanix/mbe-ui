# Feature Specification: Back-Office Order Workspace — Customer, Capture, Delivery

**Feature Branch**: `039-back-office-order-workspace`

**Created**: 2026-09-11

**Status**: Draft

**Input**: User description: "Let's create a spec to implement backoffice sales orders from scratch. It should reuse the point of sales capture step and delivery step, so all backoffice sales will be scheduled for delivery. These type of sales first step is to set a customer, either an existing one, or a new one. And the user must not be able to select customer 'Publico en General'." — later confirmed as a **redo**, not an addition.

## Context

The back-office order screen shipped in three passes — spec 029 built it, spec 032
reshaped its header, spec 037 corrected duplicated and mis-ordered fields — and
each pass worked on the same shape: **one screen, no steps, ending at confirm**.
That shape is now wrong in three ways at once, which is why this is a redo rather
than a fourth refinement.

- **It ends too early.** A back-office order is taken to be *delivered*. Today
  the screen confirms the order and stops; nobody ever says where the goods go.
  Fulfilment has to be planned somewhere else, or not at all.
- **It reuses the point of sale in name only.** The screen was specified to share
  the capture surface, and it does share the individual *parts* — the customer band,
  the product search, the line rows, the totals bar. But the step that arranges
  them is copied, not shared: the back-office screen carries its own near-copy of
  the point-of-sale capture step's body. A change to how capture works lands in
  one place and not the other, which is the opposite of what sharing was for.
- **The customer is a gate, not a step.** Spec 036 made the screen refuse to add
  lines until a real customer is attached, and hid the generic walk-in customer
  from the picker. The rule is right; its expression is a disabled search field
  and a hint, on a screen that otherwise looks ready to use.

This feature replaces the editor with a three-step workspace — **Cliente → Venta
→ Entrega** — that renders the point of sale's *actual* capture and delivery
steps rather than copies of them. There is no payment step: collecting money
stays a separate concern, as it is today and as legacy keeps "Caja de Cobro"
separate from "Pedidos".

The "Pedidos" list screen is **not** part of this feature and does not change.

> **Relationship to the point of sale (specs 020, 023, 025, 026, 030, 031, 036).**
> The back-office order and a register sale are the same document captured by
> different people under different circumstances. This feature makes the capture
> and delivery surfaces genuinely one surface serving two hosts. Point-of-sale
> behaviour must remain observably identical throughout: this feature changes
> *who can host* those steps, never what they do at a register.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Take an order for a customer and schedule its delivery (Priority: P1)

A salesperson takes an order over the phone or at a desk. They open Sales Orders
and start a new order. The screen asks first for the customer — they search by
name or code and pick one. Only then does the order exist, and only then can they
add products: they search, add lines, adjust quantity, price, discount, tax and
source warehouse, and watch the totals build. When the goods are right they move
on to delivery, name one or more destinations with an address, a contact, a
delivery date and any instructions, and assign every unit to a destination.
Closing that step commits the order.

**Why this priority**: This is the feature's reason to exist and the whole of the
happy path. Without it a back-office order still stops short of saying where the
goods go.

**Independent Test**: Sign in as a user with sales-order create rights, start a
new order, pick a customer, add at least one product, assign every unit to one
destination with an address and a delivery date, and close the delivery step —
the order comes back with a folio, a non-draft status, and a delivery order
recorded against it.

**Acceptance Scenarios**:

1. **Given** a user with sales-order create rights, **When** they choose "New
   order", **Then** the workspace opens on the **Cliente** step showing a
   customer search and nothing else to fill in, and **no order has been written
   to the server**.
2. **Given** the Cliente step, **When** the user searches for customers, **Then**
   the generic walk-in customer ("Público en General") never appears among the
   results, whatever they type.
3. **Given** the Cliente step, **When** the user picks a customer, **Then** the
   draft order is created at that moment carrying that customer, that customer's
   implied payment terms, and an intent to deliver — and the workspace advances
   to the **Venta** step.
4. **Given** the Venta step with a customer attached, **When** the user adds the
   first product, **Then** the line appears priced from that customer's price
   list, with its quantity defaulted to the product's minimum order quantity (or
   1 when that minimum is zero) and its own tax rate.
5. **Given** the Venta step with at least one line and nothing left unconfirmed,
   **When** the user chooses "Continuar a entrega", **Then** the workspace
   advances to the **Entrega** step.
6. **Given** the Entrega step, **When** the user adds a destination, **Then**
   they are asked for a ship-to address, and may also give a contact, a delivery
   date and a comment; the first destination is pre-filled with every line's
   full outstanding quantity.
7. **Given** the Entrega step with every unit assigned to a destination,
   **When** the user closes the step, **Then** the order is committed: it is
   assigned a folio, leaves draft status, and the workspace shows it read-only.
8. **Given** the Entrega step with units still unassigned, **When** the user
   tries to close it, **Then** the close is refused and the products still
   owing quantity are named.

---

### User Story 2 - Register a customer that does not exist yet (Priority: P1)

The caller is a new customer. Rather than abandon the order, open the customers
screen, create the record and start over, the salesperson creates the customer
from the Cliente step itself. The new customer is attached to the order the
moment it is saved, and the order proceeds normally.

**Why this priority**: The Cliente step is a hard gate — nothing can happen
before it is satisfied. Without inline creation the gate becomes a dead end for
exactly the orders a back office most often takes.

**Independent Test**: From the Cliente step of a new order, create a customer
that does not exist, and confirm the order proceeds to Venta with that new
customer attached.

**Acceptance Scenarios**:

1. **Given** the Cliente step, **When** the user chooses to create a customer and
   completes the form, **Then** the customer is created, attached to a newly
   opened draft order, and the workspace advances to Venta — without the user
   having left the workspace.
2. **Given** the inline customer form, **When** the user cancels it, **Then** no
   customer and no order are created and the step is unchanged.
3. **Given** the inline customer form, **When** creation is refused by the
   server, **Then** the refusal is shown, the form keeps what was typed, and no
   order is opened.

---

### User Story 3 - Resume, amend or abandon an order in progress (Priority: P2)

An order captured yesterday, or interrupted by a phone call, is reopened from the
"Pedidos" list. It comes back at the point it was left: still choosing goods, or
already planning delivery. A draft that is no longer wanted can be cancelled.

**Why this priority**: Back-office orders are not taken in one sitting the way a
register sale is. Without this, an interrupted order is an orphan.

**Independent Test**: Leave an order part-way through each step, reopen it from
the list, and confirm it resumes on the step its own recorded state implies.

**Acceptance Scenarios**:

1. **Given** a draft order with lines and no destinations, **When** it is
   reopened, **Then** the workspace opens on **Venta** with its lines and totals
   restored.
2. **Given** a committed order that has destinations, **When** it is reopened,
   **Then** the workspace opens on **Entrega** showing those destinations.
3. **Given** an order that was not raised by this workspace — a register sale,
   or an order predating this feature — **When** it is opened from the list,
   **Then** the workspace declines to edit it, explains that it belongs to
   another workflow, and offers no action that would alter it.
4. **Given** a draft order, **When** the user cancels it and confirms the
   warning, **Then** the order is cancelled and the workspace shows it
   read-only.
5. **Given** an order that is already cancelled or committed, **When** it is
   reopened, **Then** it is shown read-only with no destructive action offered.

---

### User Story 4 - The register is unaffected (Priority: P1)

A cashier's experience of the point of sale does not change in any way: the same
steps, the same actions, the same gates, the same behaviour when a sale and a
back-office order are open at the same time.

**Why this priority**: This feature's whole method is to make point-of-sale
surfaces serve a second host. The register is live, in daily use, and is the
larger of the two surfaces. A regression there costs more than this feature is
worth.

**Independent Test**: Run the existing point-of-sale regression suite unchanged;
then, with a register sale and a back-office order open at once, confirm that
edits to one never gate, block or alter the other.

**Acceptance Scenarios**:

1. **Given** a cashier mid-sale at a register, **When** this feature ships,
   **Then** the capture, payment and delivery steps behave exactly as before,
   including the fulfilment-mode choice and the counter-pickup two-step flow.
2. **Given** a register sale and a back-office order open at the same time,
   **When** a line is edited on one, **Then** the other's ability to proceed is
   unaffected, and the edit is written to the correct document.
3. **Given** a back-office order's delivery step, **When** its first destination
   is created, **Then** the back-office order is committed and the register's
   own sale is untouched.

---

### Edge Cases

- **A line is missing or unpriced at commit.** Closing the delivery step
  commits the order, which the server may refuse — a zero-priced line, or a
  quantity beyond available stock. The refusal names the offending products, the
  order stays an editable draft, and the workspace returns the user to the step
  where the problem can be fixed.
- **Lines lock once delivery planning begins.** Creating the first destination
  is what commits the order, so from that moment the lines are fixed. The user
  may return to Venta from Entrega only while the order is still a draft — that
  is, before the first destination exists. Once one does, the goods can no
  longer be changed, and the workspace says so rather than offering a control
  that refuses.
- **An order from the other workflow is opened.** The "Pedidos" list does not
  distinguish where an order came from, so a register sale can be opened from
  it. The workspace recognises that the order is not its own and declines to
  edit it, rather than applying rules it was never meant to obey — demanding a
  different customer, or pushing a counter-pickup sale toward mandatory
  delivery.
- **A committed order waits longer than the collection window.** A back-office
  order is committed but unpaid, and its delivery may be days away. If the
  deployment runs the sweep that cancels committed, unpaid, undelivered orders
  holding stock, such an order can be cancelled out from under the customer
  (A13).
- **No point of sale configured.** A user whose account has no register
  configured cannot raise an order at all, because the server refuses to create
  one. Existing orders still open and read normally; the "New order" action is
  unavailable with an explanation of what to ask an administrator for.
- **The customer is changed after lines exist.** Every line is repriced against
  the new customer's price list and the totals update. The generic walk-in
  customer is refused as a replacement, exactly as it is refused as the original
  choice.
- **A customer with no addresses on file.** The destination editor lets the user
  record a ship-to address without leaving the step; a customer with none is not
  a dead end.
- **Someone else changed the order in the meantime.** A write refused as stale
  re-reads the order and shows the server's version rather than leaving a figure
  on screen that the order does not hold.
- **Unconfirmed typing when leaving a step.** Text typed into a line or header
  field but not committed raises a keep / discard / keep-editing decision before
  the step advances — never a silent discard and never a silent commit.
- **A write is still in flight.** Advancing a step or closing delivery is
  refused while any write against this order is outstanding, so no decision is
  ever taken on figures the order does not yet hold.

## Requirements *(mandatory)*

### Functional Requirements

#### The workspace and its steps

- **FR-001**: The system MUST present a back-office order as a three-step
  workspace with the steps **Cliente**, **Venta** and **Entrega**, in that
  order, with the current step always identifiable.
- **FR-002**: The workspace MUST occupy the whole screen, outside the
  application's navigation shell, as the point-of-sale workspace does.
- **FR-003**: The workspace MUST be reachable both as a new order and as an
  existing order addressed by its identifier, and a newly opened order MUST
  become addressable by its own identifier once it exists.
- **FR-004**: The system MUST NOT offer a payment step, a payment action, or any
  means of recording money against the order from this workspace.
- **FR-005**: The system MUST NOT write anything to the server until the user
  chooses a customer.
- **FR-006**: Users MUST be able to move forward through the steps and to return
  to an earlier step for as long as the order remains an editable draft.
- **FR-007**: The system MUST refuse to advance from a step, and MUST refuse to
  close the delivery step, while any write against this order is outstanding.
- **FR-008**: When text has been typed into a field and not committed, the system
  MUST raise a keep / discard / keep-editing decision before advancing a step,
  and MUST make a discard visible in the field it affects.

#### Cliente step

- **FR-009**: The Cliente step MUST require exactly one customer before any other
  part of the order may be worked on.
- **FR-010**: Users MUST be able to find an existing customer by searching on
  name or code.
- **FR-011**: The system MUST exclude the generic walk-in customer ("Público en
  General") from customer search results in this workspace.
- **FR-012**: The system MUST refuse the generic walk-in customer if it is
  reached by any route other than search, and MUST explain the refusal.
- **FR-013**: Users MUST be able to create a new customer from within the
  workspace, and the created customer MUST be attached to the order without
  further action.
- **FR-014**: Attaching a customer MUST open the draft order with that customer
  already set, so that the server never falls back to its own default customer.
- **FR-015**: Attaching a customer MUST record the order's intent to deliver at
  the same time.
- **FR-016**: Attaching a customer MUST apply that customer's implied payment
  terms, defaulting to credit terms when the customer has a credit line.

#### Venta step

- **FR-017**: The Venta step MUST be the same capture surface the point of sale
  uses, rendered from one shared definition rather than a copy of it.
- **FR-018**: Users MUST be able to find products by name, code or barcode, and
  through the advanced product search, and add them as order lines.
- **FR-019**: Users MUST be able to edit a line's quantity, price, discount, tax
  rate, source warehouse and comment, and to remove a line, subject to their
  access rights.
- **FR-020**: The system MUST show a running subtotal, tax and total that reflect
  what the order holds on the server.
- **FR-021**: The system MUST NOT offer a fulfilment-mode choice in this
  workspace; every back-office order is for delivery.
- **FR-022**: The Venta step's forward action MUST be labelled for delivery, not
  for payment, and MUST be available only when the order has at least one line.
- **FR-023**: Users MUST be able to view and edit the order's own header
  information — priority, currency, exchange rate, tax-recipient, promise date,
  salesperson and comment — from the Venta step, with the server-derived due date
  shown but not editable.

#### Entrega step

- **FR-024**: The Entrega step MUST be the same delivery surface the point of
  sale uses, rendered from one shared definition rather than a copy of it.
- **FR-025**: Users MUST be able to create one or more destinations, each with a
  ship-to address, and optionally a contact, a delivery date and a comment.
- **FR-026**: Users MUST be able to edit and to remove a destination.
- **FR-027**: Users MUST be able to record a new ship-to address for the customer
  without leaving the step.
- **FR-028**: The system MUST let the user assign each line's quantity across
  destinations, and MUST show at all times what remains unassigned.
- **FR-029**: The first destination created MUST be pre-filled with every line's
  full outstanding quantity.
- **FR-030**: The system MUST require every unit to be assigned before the
  delivery step may be closed, and MUST name the products still owing when it
  refuses.
- **FR-031**: The system MUST NOT offer a counter-pickup destination or a
  remainder sweep in this workspace.

#### Commitment and read-only

- **FR-032**: The order MUST be committed — assigned a folio and moved out of
  draft status — as part of planning its delivery, and MUST NOT be committed
  merely by reaching a step. This ordering is not a preference: delivery cannot
  be recorded against an uncommitted order at all (A2).
- **FR-033**: When commitment is refused, the system MUST show the reason, keep
  the order an editable draft, and return the user to the step where the problem
  can be corrected.
- **FR-034**: Once the order is no longer a draft, the system MUST show it
  read-only in place, withdrawing rather than disabling the actions that no
  longer apply.
- **FR-035**: Priority MUST remain editable after the order is committed, for
  users with update rights.
- **FR-036**: Users MUST be able to cancel a draft order, behind a confirmation,
  and the workspace MUST then show the cancelled order read-only.

#### Resuming

- **FR-037**: Reopening an order MUST place the user on the step that the
  order's own recorded state implies, derived independently of the point of
  sale's payment-based rules.
- **FR-038**: An order that this workspace did not raise MUST NOT be resumed
  into the flow at all; it is declined under FR-053 before any step is chosen.
- **FR-039**: A draft order with a real customer and no destinations MUST resume
  on Venta.
- **FR-040**: An order that has at least one destination MUST resume on Entrega.

#### Sharing the point-of-sale surfaces

- **FR-041**: The capture and delivery surfaces MUST be hostable by both the
  register and this workspace, with the host determining which document is
  edited and which set of pending writes and uncommitted edits applies.
- **FR-042**: An action taken in one host MUST affect only that host's document.
- **FR-043**: An outstanding write or uncommitted edit in one host MUST NOT gate
  any action in the other.
- **FR-044**: Committing an order from the delivery surface MUST commit the
  document that surface is hosting, never the register's own sale.
- **FR-045**: Each step's forward action MUST be supplied by its host, so that
  the shared surfaces carry no knowledge of what follows them.
- **FR-046**: Point-of-sale behaviour MUST remain observably unchanged: the same
  steps, gates, labels, fulfilment-mode choice and resume behaviour as before
  this feature.
- **FR-047**: Access to this workspace MUST continue to be governed by
  sales-order rights, independently of point-of-sale rights.

#### Telling the two workflows apart

- **FR-051**: Every order raised by this workspace MUST be recorded as having
  originated in the back office, durably and as part of the order itself.
- **FR-052**: The workspace MUST be able to determine, from an order alone,
  whether it raised that order, without inferring it from the customer, the
  register, the fulfilment intent or any other proxy.
- **FR-053**: The workspace MUST decline to edit an order it did not raise, and
  MUST say why rather than failing silently or partially.
- **FR-054**: Recording the origin MUST NOT change how any existing order
  behaves, and an order whose origin was never recorded MUST remain readable and
  usable exactly as it is today.

#### Replacing what exists

- **FR-048**: The previous single-screen order editor MUST be removed, not left
  reachable alongside the workspace.
- **FR-049**: The "Pedidos" list MUST continue to open orders into the
  workspace, and MUST otherwise be unchanged by this feature.
- **FR-050**: Header information that a destination now owns — ship-to address
  and contact — MUST NOT also be edited on the order header, so that one fact
  has one place.

### Key Entities

- **Order**: The document being captured. Carries a customer, a status
  (draft, committed, cancelled), a folio once committed, payment terms, currency
  and exchange rate, priority, promise date, a server-derived due date, a
  salesperson, a comment, an intent to deliver, and its lines.
- **Order line**: One product on the order, with quantity, unit price, discount,
  tax rate, source warehouse and an optional comment.
- **Customer**: Who the order is for. Carries a price list that determines line
  prices, an optional credit line that determines default payment terms, an
  outstanding balance, and the addresses and contacts a destination draws on.
  Exactly one customer — the deployment's generic walk-in customer — is not
  eligible for a back-office order.
- **Destination**: One planned shipment for the order, with a ship-to address, an
  optional contact, an optional delivery date, an optional comment, and the
  quantities of each order line it carries.
- **Step**: Which of Cliente, Venta or Entrega the user is on. A property of the
  session, not of the order; reconstructed from the order's own state when it is
  reopened.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A salesperson can take an order for an existing customer — customer,
  three products, one destination — and commit it, in under 3 minutes, without
  leaving the workspace.
- **SC-002**: A salesperson can take an order for a customer who does not yet
  exist, including creating that customer, without leaving the workspace.
- **SC-003**: 100% of back-office orders committed through this workspace have a
  named customer other than the generic walk-in customer, and at least one
  destination.
- **SC-004**: The generic walk-in customer cannot be attached to a back-office
  order by any route available in the workspace.
- **SC-005**: No back-office order can be committed while any of its units remain
  unassigned to a destination.
- **SC-006**: The capture surface and the delivery surface each exist in exactly
  one definition, used by both the register and this workspace; a change to
  either is observable in both without further edits.
- **SC-007**: The existing point-of-sale regression suite passes unchanged, and
  a register sale and a back-office order edited concurrently never gate or
  alter one another.
- **SC-008**: An order interrupted at any step resumes on that step in 100% of
  cases, including orders raised before this feature.
- **SC-009**: No screen in the workspace offers an action for recording payment.
- **SC-010**: Every order raised through this workspace can be identified as
  back-office in origin from the order alone, with no reliance on its customer,
  its register or its fulfilment intent.
- **SC-011**: No order raised at a register can be edited through this
  workspace, and attempting to open one produces an explanation rather than a
  partially working screen.
- **SC-012**: Recording origin changes nothing observable about orders that
  predate this feature: they list, open and read exactly as before.

## Assumptions

- **A1 — The list screen is out of scope.** The "Pedidos" list, its filters, its
  administrator-only facets and the scoping rules spec 029 settled are unchanged.
  Only how a row opens changes, and only in that it opens the new workspace.
- **A2 — Commitment happens when delivery planning begins, and could not
  happen later.** The server refuses to record a delivery against an order that
  is not yet committed, so the first destination created is necessarily what
  commits the order. This is not a choice between designs: the consequence —
  once a destination exists the lines are fixed, and returning to Venta is
  offered only while the order is still a draft — is inherent, and is stated in
  the edge cases rather than hidden.
- **A3 — Delivery only, with no remainder.** Counter pickup and the mixed mode
  are not offered, so every unit must be assigned before the step closes. This is
  the existing behaviour of the delivery surface for a pure-delivery sale; no new
  rule is being invented.
- **A4 — The generic walk-in customer is a configured identity.** The deployment
  names one customer as the generic walk-in customer. The workspace refuses that
  one customer and no other; there is no blacklist, credit hold or status check
  on customer choice, and none is added here.
- **A5 — A register must still be configured to raise an order.** The server
  refuses to create an order for a user with no point of sale. This feature keeps
  the existing blocked state for creation, and keeps reading and editing existing
  orders working regardless.
- **A6 — Due date stays server-derived.** It is shown and never edited, as today.
- **A7 — Promise date and delivery date are different facts.** The order's
  promise date is the commitment to the customer and stays on the order header;
  a destination's date is when that particular shipment goes out. Both are kept.
- **A8 — Ship-to and contact move to destinations.** They were order-header
  fields when there was no delivery step. Now that destinations carry them
  per-shipment, the header no longer does (FR-050).
- **A9 — Orders raised before this feature are left alone.** Nothing is
  rewritten or backfilled. Their origin is unknowable from their own data —
  which is precisely why a recorded origin is needed going forward — so they are
  treated as belonging to another workflow and declined by FR-053.
- **A10 — Making the surfaces shared is the main technical risk.** The capture
  and delivery surfaces currently reach the register's own sale and the
  register's own set of pending writes directly in about a dozen places. Reuse
  means routing every one of those through the host. Missing one is not a
  compile error and not necessarily a visible bug at a register — it is a
  back-office action silently taken against the cashier's sale. FR-042, FR-043,
  FR-044 and SC-007 exist to pin this down.
- **A11 — Access rights are unchanged.** Sales-order read, create and update
  rights govern this workspace exactly as they govern the screen it replaces.
- **A12 — One server change is required.** Every other capability this feature
  needs — raising an order with a customer, recording an intent to deliver,
  creating and editing delivery orders and their line assignments, committing,
  cancelling — is already served. The exception is FR-051/FR-052: nothing on an
  order today records which workflow raised it, and the two produce documents
  that are identical in every readable field. The precedent for adding one is
  the fulfilment intent, itself added as an optional field whose absence means
  "never recorded"; the same shape satisfies FR-054.
- **A13 — Back-office orders sit committed and unpaid by design, and something
  already collects such orders.** An automated sweep cancels orders that are
  committed, unpaid, undelivered and still holding stock, a short interval after
  their order date — which describes the normal resting state of a back-office
  order awaiting a delivery date further out than that interval. Whether this
  matters depends on whether that sweep runs in the target deployment, and it is
  a deployment question rather than a design one. If it does run, this feature
  needs it to spare orders whose delivery is already planned, or to allow a
  longer window.
- **A14 — Delivery must not be gated on payment in the target deployment.**
  A server-side option can refuse to record a delivery unless the order is paid
  or on credit terms. It is off by default. Left on, it would block every
  back-office order for a non-credit customer, since this workspace never
  collects payment.
- **A15 — A register is recorded on the order and cannot be changed afterwards.**
  Every order carries a register, back-office orders included, and it is fixed
  at creation. This is why the register cannot itself serve as the origin
  marker (FR-052) without dedicating one, and why A5's blocked state stands.

## Out of Scope

- **OS-1 — Collecting payment.** Money against a back-office order is recorded
  elsewhere, as it is today.
- **OS-2 — The "Pedidos" list screen.** See A1. In particular, the list is
  **not** narrowed to back-office orders in this feature, even though FR-051
  would make that expressible for the first time. Doing so would either hide
  every order predating this feature or admit every historical register sale,
  and choosing between those depends on a backfill policy that belongs with the
  origin field itself, not with this screen. The list may adopt the distinction
  later.
- **OS-3 — Dispatch, routing and itineraries.** This feature plans destinations;
  it does not schedule vehicles, operators or routes.
- **OS-4 — Printing or sending the order.** No document output is added.
- **OS-5 — Changing point-of-sale behaviour.** Point-of-sale files are edited
  only to let their steps serve a second host; no register-visible behaviour
  changes.
- **OS-6 — Customer management beyond inline creation.** Editing or merging
  customers stays on the customers screen.
