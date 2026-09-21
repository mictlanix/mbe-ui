# Feature Specification: Sales Quotes — Cotizaciones

**Feature Branch**: `040-sales-quotes`

**Created**: 2026-09-12

**Status**: Draft

**Input**: User description: "Sales quotes, reusing the point-of-sale capture step, targeted only at customers other than 'Público en General', with capture as the only step. A quote the customer accepts can be turned into a back-office sale."

## Amendments

- **2026-09-20 — the quote is one step, and three dependencies have cleared.**
  This spec was drafted while `039-back-office-order-workspace` was unbuilt, and
  took two things from its then-current design that are no longer true.
  - **The customer is not a step.** `039` shipped, and was then directly
    corrected: its Cliente step was removed and naming a customer folded into
    the capture step itself, which now opens with its customer band already
    searching and withholds product capture until a real customer is attached.
    A quote therefore has **one step**, not two — which is what the original
    feature description said ("capture will be the only step"). **A1 is
    reversed**, and FR-005 and the affected scenarios are rewritten below.
  - **Everything this spec listed as an unresolved dependency has shipped**:
    the shared capture step is host-agnostic and in `main`; mbe-api#213 added
    the quote list's customer name *and* name search; mbe-api#209 shipped, and
    conversion stamps the resulting order's origin as back-office.
  Because nothing has been planned or built from this document yet, the body is
  **rewritten in place** rather than layered with corrections — there is no
  implementation whose history needs preserving. Requirement numbering is
  unchanged. This differs from the amendment convention in `039` and `041`
  deliberately, and for that reason.

## Context

A **sales quote** ("cotización") is a priced, non-binding offer made to a named customer.
The salesperson prices the goods, the customer takes the offer away to think about it, and
if they accept, the quote becomes an order. It is the one sales document that exists to be
*declined* — which is exactly why it must not be an order until the customer says yes.

mbe-ui has never had this screen. The legacy system did, and every prior mbe-ui sales
feature deliberately excluded it: the point-of-sale spec listed "sales quotes and
converting a quote into a sale" as out of scope, and the back-office order specs left the
originating quote out of the order entity. Salespeople therefore have no way to put a price
in a customer's hands without either committing to an order or working outside the system.

Two things make this feature unusually cheap for its value, and one makes it unusually
constrained:

- **The server already does all of it.** Quotes are fully implemented server-side, including
  a first-class operation that turns an accepted quote into a sales order and records which
  quote it came from. Nothing needs to be built or changed on the backend to ship this.
- **The permission slot already exists.** Quotes have had a reserved, unused permission
  object since the permission catalog was ported from legacy.
- **The screen it needs already exists.** This feature renders the *same* capture
  surface the register and the back-office order workspace use, as a third host of it.
  `039-back-office-order-workspace` made that surface host-agnostic and has landed, so
  this feature adds a caller rather than a capability. See **Dependencies**.

> **Relationship to the point of sale and to back-office orders.** A quote is captured the
> same way a sale is: same customer band, same product search, same line rows, same totals.
> This feature adds a third host for that shared surface and must not change how it behaves
> for the other two. Where a register sale continues to payment and a back-office order
> continues to delivery, a quote simply ends.

The full research basis for this feature — API behaviour, server-side defaults, refusal
messages, divergences from legacy, and the reasoning behind the decisions recorded in
**Assumptions** — is in [`docs/sales-quotes-research.md`](../../docs/sales-quotes-research.md).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Write and confirm a quote for a named customer (Priority: P1)

A salesperson is asked what a basket of goods would cost. They start a new quote. The screen
asks first for the customer — the customer band opens already searching, and they pick one by
name or code. Only then does the quote exist, and only then can they add products: they
search, add lines, adjust quantity,
discount and tax, and watch the totals build. When the numbers are right they confirm the
quote. It is assigned a folio, becomes read-only, and can be given to the customer.

**Why this priority**: This is the feature's reason to exist. Without it there is no quote
at all, and nothing for any other story to act on.

**Independent Test**: Sign in as a user with quote-create rights, start a new quote, pick a
customer, add at least one product, and confirm — the quote comes back with a folio, a
confirmed status, and totals that match the lines.

**Acceptance Scenarios**:

1. **Given** a user with quote-create rights, **When** they choose "Nueva cotización",
   **Then** the quote screen opens with its customer band **already searching**, product
   capture withheld until a customer exists, and **no quote written to the server**.
2. **Given** the customer band, **When** the user searches for customers, **Then** the
   generic walk-in customer ("Público en General") never appears among the results,
   whatever they type.
3. **Given** the customer band, **When** the user picks a customer, **Then** the draft quote
   is created at that moment carrying that customer and that customer's implied payment
   terms, and product capture becomes available on the same screen — without a step change.
4. **Given** a quote with a customer attached, **When** the user adds the first
   product, **Then** the line appears priced from that customer's price list, with its
   quantity defaulted to the product's minimum order quantity (or 1 when that minimum is
   zero) and its own tax rate.
5. **Given** a quote line, **When** the user views it, **Then** no source
   warehouse is shown and no stock or shortfall warning appears, because a quote commits no
   goods.
6. **Given** a draft quote with at least one line and nothing left unconfirmed, **When** the
   user confirms it, **Then** the quote is assigned a folio, becomes read-only, and the
   screen shows it as confirmed.
7. **Given** a draft quote with no lines, **When** the user looks at the confirm action,
   **Then** it is unavailable.
8. **Given** a draft quote, **When** the user views its reference, **Then** a provisional
   reference is shown in place of a folio, because a folio is only assigned on confirmation.

---

### User Story 2 - Turn an accepted quote into a back-office order (Priority: P1)

The customer accepts. Rather than retype the whole basket, the salesperson opens the
confirmed quote and converts it. An order is raised carrying the same customer, terms and
lines, and permanently recording which quote it came from. The salesperson lands in the
back-office order workspace, ready to say which warehouse each line ships from and where the
goods are going.

**Why this priority**: This is the feature's commercial payoff — the moment a quote earns
its keep. It is equal in priority to US1 because a quote nobody can act on is a dead
document, but it is worthless without US1 to produce the quote.

**Independent Test**: Take a confirmed, unexpired quote and convert it — an order exists
carrying the quote's customer and lines, the quote is recorded as its origin, and the user
is placed in the order workspace with the goods step active.

**Acceptance Scenarios**:

1. **Given** a confirmed, unexpired quote and a user who may also create orders, **When**
   they convert it, **Then** an order is created carrying the quote's customer,
   salesperson, payment terms, currency, contact, ship-to, comment and every line, and the
   user is taken to that order's workspace **on the goods step**.
2. **Given** the converted order, **When** the user inspects its lines, **Then** each line
   still needs a source warehouse before the order can be completed, and the user can set
   them and proceed to plan delivery as they would for any back-office order.
3. **Given** a quote that is still a draft, **When** the user attempts to convert it,
   **Then** the attempt is refused and the user is told the quote must be confirmed first.
4. **Given** a cancelled quote, **When** the user attempts to convert it, **Then** the
   attempt is refused.
5. **Given** an expired quote, **When** the user attempts to convert it, **Then** the
   attempt is refused, the reason names expiry, and the user is offered **Duplicate** as the
   way forward.
6. **Given** a user with no point of sale configured, **When** they attempt to convert a
   quote, **Then** the refusal is shown plainly and explains that their user needs a point
   of sale, rather than presenting as an unexplained failure.
7. **Given** a user who may read and write quotes but may **not** create orders, **When**
   they open a confirmed quote, **Then** the convert action is not offered.
8. **Given** a quote that has already been converted once, **When** the user converts it
   again, **Then** a second, independent order is created — conversion is not treated as a
   one-time event.

---

### User Story 3 - Find, reopen, amend and cancel quotes (Priority: P2)

Quotes outlive the sitting in which they were written. A salesperson comes back the next day
to a list of the facility's quotes, filters to the ones still open, reopens a draft to change
a quantity, and cancels one the customer turned down.

**Why this priority**: Without it, a quote is only reachable in the session that created it,
which makes the follow-up conversation — the whole point of a quote — impossible. It is P2
only because US1 and US2 deliver a complete, demonstrable loop without it.

**Independent Test**: With several quotes in different states, open the list, filter by
status, reopen a draft, change a line, and cancel a different quote — each action is
reflected on the list.

**Acceptance Scenarios**:

1. **Given** a user with quote-read rights, **When** they open the quotes screen, **Then**
   they see the facility's quotes — **all of them, not only their own** — most recent first.
2. **Given** the quotes list, **When** the user filters by status, **Then** they can narrow
   to drafts, confirmed quotes, or cancelled quotes.
3. **Given** the quotes list, **When** the user filters by customer, **Then** only that
   customer's quotes are shown.
4. **Given** a quote in the list that has passed its expiry date, **When** the user views the
   row, **Then** it is visibly marked as expired, distinctly from its status.
5. **Given** a draft quote, **When** the user reopens it, **Then** it opens with its
   customer and lines intact and fully editable.
6. **Given** a confirmed quote, **When** the user reopens it, **Then** it opens read-only and
   offers only the actions still available to it.
7. **Given** a draft or confirmed quote, **When** the user cancels it, **Then** it becomes
   cancelled and can no longer be edited or converted.
8. **Given** an already-cancelled quote, **When** the user attempts to cancel it again,
   **Then** the action is not offered.

---

### User Story 4 - Quote a customer who is not registered yet (Priority: P2)

The enquiry comes from someone who has never bought before — which is the normal case for a
quote. Rather than abandon the quote, open the customers screen, create the record and start
over, the salesperson creates the customer from the quote's own customer band. The new customer is
attached to the quote the moment it is saved.

**Why this priority**: The customer is a hard gate, and quotes are disproportionately
written for prospects rather than established customers. Without inline creation the gate
becomes a dead end for exactly the enquiries a quote exists to answer.

**Independent Test**: From the customer band of a new quote, create a customer that does not
exist, and confirm the quote opens for capture with that new customer attached.

**Acceptance Scenarios**:

1. **Given** the customer band, **When** the user chooses to create a customer and completes
   the form, **Then** the customer is created, attached to a newly opened draft quote, and
   product capture becomes available — without the user having left the screen.
2. **Given** the inline customer form, **When** the user cancels it, **Then** no customer and
   no quote are created and the screen is unchanged.
3. **Given** the inline customer form, **When** creation is refused by the server, **Then**
   the refusal is shown, the form keeps what was typed, and no quote is opened.

---

### User Story 5 - Re-quote by duplicating (Priority: P3)

A quote has expired, or the customer wants the same basket priced again months later. The
salesperson duplicates it and gets a fresh draft, re-priced at today's prices, without
rebuilding the basket by hand.

**Why this priority**: It is the sanctioned recovery path for an expired quote, but every
case it handles can be worked around by writing a new quote, so it is the last thing to
build.

**Independent Test**: Duplicate a confirmed or expired quote and confirm a new editable
draft appears with the same products and today's prices.

**Acceptance Scenarios**:

1. **Given** any quote, **When** the user duplicates it, **Then** a new draft quote is
   created with the same customer and the same products, priced from the customer's price
   list **as it stands today**, and the original is untouched.
2. **Given** an expired quote whose conversion was refused, **When** the user takes the
   offered Duplicate action, **Then** they land on the new draft ready to re-quote.
3. **Given** a duplicated quote, **When** the user views it, **Then** it is a draft with no
   folio, independent of the quote it came from.

---

### Edge Cases

- **A quote whose prices have moved.** A confirmed quote keeps the prices it was confirmed
  at; it is a promise. Only Duplicate re-prices. Conversion carries the quote's prices into
  the order, not today's.
- **A pre-existing quote attached to the generic walk-in customer**, created before this
  screen existed or by another client. It must remain readable and cancellable rather than
  crashing the screen, even though the screen would never create one.
- **A quote that expires while it is open on screen.** Expiry is a function of the due date
  passing, not of an action; a conversion attempted after that point is refused by the
  server even though the screen was opened before it.
- **Attempting to edit a confirmed or cancelled quote**, including from a stale screen. The
  server refuses; the refusal must be surfaced and the screen brought back into agreement
  with the server's state.
- **A quote with no lines.** It can exist as a draft — a customer was chosen and nothing was
  added — but cannot be confirmed.
- **Searching the list by customer name.** The server matches a numeric term against the
  quote's reference and a non-numeric term against the customer's name, so both are
  meaningful searches and neither silently returns the unfiltered list.
- **Losing the right to create orders between opening a quote and converting it.** The
  convert action must be gated on the permission at the time it is offered, and the server's
  refusal handled if it changes underneath.
- **Two users acting on the same quote.** The last write wins as it does elsewhere in the
  application; a refused write must not leave the screen showing values the server rejected.

## Requirements *(mandatory)*

### Functional Requirements

**Access and navigation**

- **FR-001**: The application MUST expose a Sales Quotes screen in the sales area of the
  navigation, visible only to users who may read quotes.
- **FR-002**: Every quote route MUST be gated on read permission for quotes; a user without
  it MUST NOT be able to reach the screen by any route.
- **FR-003**: Creating, editing, confirming, cancelling and duplicating quotes MUST be gated
  on the corresponding quote permissions, and actions the user may not perform MUST NOT be
  offered.
- **FR-004**: Converting a quote MUST additionally require permission to create orders, and
  MUST NOT be offered to a user who lacks it.

**Naming the customer**

- **FR-005**: A new quote MUST open with its customer band already searching, and MUST
  withhold product capture until a customer is attached. Naming the customer MUST NOT be a
  step of its own.
- **FR-006**: Nothing MUST be written to the server until a customer has been chosen.
- **FR-007**: The generic walk-in customer MUST NOT appear in the customer search results,
  whatever the user types.
- **FR-008**: The system MUST NOT attach the generic walk-in customer to a quote by any
  route, including by allowing the server to apply it as a default.
- **FR-009**: Choosing a customer MUST open the draft quote already carrying that customer.
- **FR-010**: The user MUST be able to create a new customer from the customer band without
  leaving the quote screen, and that customer MUST be attached to the quote on save.
- **FR-011**: Cancelling inline customer creation MUST leave no customer and no quote
  created.

**Capturing the quote**

- **FR-012**: The quote MUST be captured on the same capture surface the point of sale and
  the back-office order workspace use, rendered as a third host of it rather than copied.
- **FR-013**: Adding, editing and removing lines MUST behave as they do on the other two
  hosts, including price-list pricing, minimum-order-quantity defaulting, discount and tax
  editing, and read-only line prices.
- **FR-014**: Quote lines MUST NOT show a source warehouse.
- **FR-015**: Quote lines MUST NOT show stock availability or shortfall warnings.
- **FR-016**: The step MUST NOT offer a fulfilment-mode choice, a payment step or a delivery
  step.
- **FR-017**: Totals MUST be shown as the server reports them and MUST NOT be recomputed
  locally.
- **FR-018**: The forward action on the capture surface MUST confirm the quote rather than
  advance to another step, and MUST be unavailable while the quote has no lines.
- **FR-019**: The user MUST NOT be able to confirm while a write is outstanding or an edit is
  unconfirmed.
- **FR-020**: A quote MUST show the customer, the payment terms, the expiry date, the
  currency and the comment, and MUST allow editing those the server accepts while the quote
  is a draft.

**Confirmation and read-only state**

- **FR-021**: Confirming a quote MUST assign it a folio and make it read-only.
- **FR-022**: A draft quote MUST display a provisional reference in place of a folio.
- **FR-023**: A confirmed or cancelled quote MUST NOT offer line or header editing.
- **FR-024**: A quote that has passed its expiry date MUST be visibly marked as expired,
  distinctly from its status, both in the list and on the quote itself.

**Conversion**

- **FR-025**: A confirmed, unexpired quote MUST offer conversion into a back-office order.
- **FR-026**: Conversion MUST produce an order carrying the quote's customer, salesperson,
  payment terms, currency, contact, ship-to, comment and lines.
- **FR-027**: After a successful conversion the user MUST be taken to the resulting order's
  back-office workspace **on the goods step**, from which they can assign warehouses and
  plan delivery.
- **FR-028**: A refused conversion MUST show the reason in the user's language and leave the
  quote unchanged.
- **FR-029**: A conversion refused because the quote is expired MUST offer Duplicate as the
  recovery action.
- **FR-030**: A conversion refused because the user has no point of sale configured MUST say
  so plainly rather than presenting as a generic failure.
- **FR-031**: The system MUST NOT prevent a quote from being converted more than once, and
  MUST NOT present conversion as irreversible or one-time.

**Cancellation and duplication**

- **FR-032**: A draft or confirmed quote MUST be cancellable; a cancelled quote MUST NOT be
  editable or convertible.
- **FR-033**: Any quote MUST be duplicable, producing a new independent draft with the same
  customer and products, priced as of today.

**The quotes list**

- **FR-034**: The list MUST show the facility's quotes, **not** filtered to the current user
  by default.
- **FR-035**: Each row MUST show enough to identify the quote: its reference, its customer,
  its date, its expiry, its status and its total.
- **FR-036**: The list MUST offer filtering by status and by customer, and MUST support
  searching by the quote's reference or the customer's name.
- **FR-037**: The list MUST mark expired quotes distinctly from their status.
- **FR-038**: The list MUST page through results rather than loading all quotes at once.
- **FR-039**: Opening a draft from the list MUST resume it with its customer and lines
  intact and editable.

**Behaviour shared with the other capture hosts**

- **FR-040**: Point-of-sale and back-office order behaviour MUST remain observably unchanged
  by this feature.
- **FR-041**: A quote's outstanding writes and unconfirmed edits MUST be tracked separately
  from the register's and the order workspace's, so that work in one never gates or commits
  work in another.
- **FR-042**: A quote screen MUST never write to, confirm or otherwise affect a sale or order
  open elsewhere in the application.

### Key Entities

- **Sales Quote**: A priced offer to a named customer. Carries a facility, a customer, a
  salesperson, payment terms, a currency and exchange rate, an issue date, an expiry date, an
  optional contact, ship-to and comment, a status (draft, confirmed, cancelled), a separate
  expired indicator, a folio assigned only on confirmation, its lines, and its subtotal, tax
  and total. Never carries a fulfilment intent, a payment, or a delivery.
- **Quote Line**: One product on a quote — the product with its code and name as they stood
  when added, a quantity, a price, a discount rate, a tax rate, an optional comment, and the
  line's own subtotal, tax and total. Has **no** source warehouse and **no** stock
  availability, which is what distinguishes it from an order line.
- **Sales Order (existing)**: The document a converted quote becomes. Gains a permanent
  reference to the quote it originated from. Everything else about it is unchanged by this
  feature.
- **Customer (existing)**: Supplies the price list that prices every line, the payment terms
  the quote defaults to, and the salesperson where one is assigned. The generic walk-in
  customer is excluded from quotes entirely.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A salesperson can produce a confirmed, folio-bearing quote for an existing
  customer with three products in under two minutes, without leaving the quote screen.
- **SC-002**: A quote for a customer who is not yet registered can be completed without
  navigating away from the quote screen at any point.
- **SC-003**: Converting an accepted quote into an order requires no re-entry of the
  customer or any line — 100% of the quote's products arrive on the order with matching
  quantities and prices.
- **SC-004**: Every refused conversion tells the user why and, where a recovery exists,
  offers it — measured as 4 of 4 refusal cases (draft, cancelled, expired, no point of sale)
  producing a distinct, actionable message.
- **SC-005**: The generic walk-in customer cannot be attached to a quote by any route
  available in the interface, verified across the customer search, inline creation, and
  quote creation itself.
- **SC-006**: A user without quote permissions cannot reach the quotes screen or any quote,
  and a user without order-create permission is never offered conversion.
- **SC-007**: Point-of-sale and back-office order behaviour is unchanged: the existing
  automated checks for both continue to pass without modification to their expectations.
- **SC-008**: A quote left in progress can be found and resumed the following day with its
  lines intact.

## Assumptions

Decisions taken where the description left room, and the reasoning behind each. The
supporting evidence is in [`docs/sales-quotes-research.md`](../../docs/sales-quotes-research.md).

- **A1 — One step, with the customer named inside it.** The description called capture "the
  only step". This was briefly specified as two steps (Cliente → Cotización) to mirror the
  back-office order workspace as it then stood; `039` was subsequently corrected to drop its
  own Cliente step, on the grounds that naming a customer was never meant to be a screen of
  its own. A quote follows suit: one screen, whose customer band opens already searching and
  which withholds product capture until a real customer is attached — the same gate, without
  a step. *(User decision 2026-09-12, reversed 2026-09-20 per `039`'s correction; see
  Amendments.)*
- **A2 — Conversion lands on the goods step of the order workspace.** The converted order
  arrives with no fulfilment intent and no warehouse on any line, so it is not finishable as
  it stands. Dropping the user anywhere else would leave them holding an order they cannot
  complete. *(User decision, 2026-09-12.)*
- **A3 — Line prices stay read-only; absolute price adjustment is deferred, not dropped.**
  The shared line row treats price as read-only and expresses adjustments as a discount.
  Quotes support an absolute per-line markup that orders do not, but conversion folds it
  into the price anyway, so anything expressible one way is expressible the other. Adopting
  it would diverge the quote host from the other two for no functional gain in v1.
  *(User decision, 2026-09-12.)*
- **A4 — The list shows the whole facility by default.** The server can filter to the
  current user's own quotes, and legacy did so by default. Showing everything matches how
  the orders list behaves today and suits a back office where quoting is a shared activity.
  *(User decision, 2026-09-12.)*
- **A5 — An expired quote is a dead end that offers a way out.** Expiry is reported
  separately from status, so a quote can be both confirmed and expired. Rather than hide or
  auto-renew it, the screen marks it clearly and offers Duplicate — which re-prices at
  today's prices and is the server's own suggested recovery.
- **A6 — A draft quote shows a provisional reference.** Folios are assigned on confirmation
  so abandoned drafts leave no gaps in the sequence. Drafts therefore have no folio, and
  reuse the provisional-reference treatment orders already have.
- **A7 — Warehouses and stock are absent, not hidden-but-implied.** A quote commits no goods
  and reserves no stock. Showing a warehouse picker or a shortfall warning would imply a
  commitment the document does not make.
- **A8 — Quotes are for named customers, permanently.** This is treated as a property of the
  document, not a screen-level rule: the walk-in customer is excluded at the picker, at
  creation, and anywhere else a customer could be attached.
- **A9 — Pre-existing quotes are tolerated, not validated.** Quotes created before this
  screen existed may violate its rules — most plausibly by carrying the walk-in customer.
  They must remain readable and cancellable. The screen does not retro-fix them.
- **A10 — Conversion is repeatable.** The server permits a quote to be converted more than
  once, each time producing an independent order. The interface neither prevents this nor
  implies it is a one-time act.
- **A11 — Currency and exchange rate follow the server's defaults.** No currency selector is
  introduced by this feature; quotes take the deployment's default as orders do.
- **A12 — The expiry date's default comes from the server** (30 days at present). It is
  displayed, and editable while the quote is a draft, but this feature does not introduce a
  client-side default of its own.

## Dependencies

All three dependencies this spec was drafted against have since **cleared**. They are kept
here because each one shaped a requirement, and because the plan needs to build on what
actually shipped rather than on what was promised.

- **`039-back-office-order-workspace` — landed (merged to `main`).** The capture step is now
  host-agnostic, and a quote is its third host. Two consequences for planning:
  - The shipped widget takes **more** than the published contract records. Beyond
    `sale`, `onContinue`, `continueLabel` and `showFulfillmentSelector`, it also accepts
    `excludeGenericCustomer`, `attachFulfillmentIntent`, `headerExtra` and
    `secondaryAction`. `continueLabel` is optional, not required. The quote host needs
    `excludeGenericCustomer: true` and `showFulfillmentSelector: false`, and needs
    **neither** `attachFulfillmentIntent` (a quote has no fulfilment intent) nor a step
    machine. `contracts/shared-step-seam.md` still documents the pre-shipping signature —
    **build against the code, not that file.**
  - The generic-customer gate this feature needs is already implemented inside that widget:
    with `excludeGenericCustomer: true` it opens the customer band in search mode while no
    document exists and withholds product capture until one does. FR-005 and FR-007 are
    therefore satisfied by configuring the shared step, not by new gating logic.
- **mbe-api#213 — shipped, and closed.** Quote list rows now carry the customer's display
  name, and list search matches a non-numeric term against the customer's name instead of
  silently returning the unfiltered page. US3 is no longer degraded, and FR-035 and FR-036
  are directly supported.
- **mbe-api#209 — shipped, and conversion is accounted for.** Orders now record which
  workflow raised them, and **conversion stamps the resulting order as back-office**
  explicitly rather than leaving it unrecorded. Combined with `041-fix-list-origin-refresh`,
  which scopes the back-office "Pedidos" list by *excluding* register sales and the
  point-of-sale list by *including* only them, this means a converted quote's order appears
  in "Pedidos" and not in the register's list, with no further work in this feature. The
  order summary also now exposes the originating quote, so a quote-origin badge on that list
  is newly feasible — though still out of scope here.

## Out of Scope

- **Payment.** Quotes are never paid. Collecting money remains a separate concern, as it is
  for back-office orders.
- **Delivery.** A quote commits no goods and schedules no delivery. Delivery is planned on
  the order that a conversion produces, not on the quote.
- **Printing, PDF and email.** Legacy could print a quote and email it as a PDF attachment.
  No server-side rendering exists for quotes today, and document rendering must stay
  server-side. This is a real functional gap for a document whose purpose is to be handed to
  a customer, and it is named here so it is not discovered late. A sibling effort is
  researching document rendering, but its current scope does **not** include quotes.
- **Absolute per-line price adjustment.** Deferred per A3.
- **Profit-margin and credit checks on quotes.** Legacy warned when a quoted price fell
  outside a product's margin band, and required a credit check before allowing deferred
  terms. Neither is enforced for quotes server-side today, and neither is added here.
- **Changing the orders list.** Whether an order shows that it came from a quote is not part
  of this feature. Note this became *feasible* while this spec was in draft — the order list
  row now carries its originating quote — so it is a deliberate exclusion rather than a
  blocked one.
