# Feature Specification: Sales Order Refinements — Header, Customer Bar & Navigation

**Feature Branch**: `037-sales-order-refinements`

**Created**: 2026-09-04

**Status**: Draft

**Input**: User description (TODO.md, 2026-09-02): "Sales Orders: Balance field
shows on two places, on customer bar and order header panel. Remove the last one
because I think it doesn't show updated data. On Customer bar, change label
'Credit Line' to 'Payment terms'. On Order header panel, remove payment terms.
On Order header panel, reorder the fields that show after expanding details as:
1. Priority, 2. Currency, 3. Exchange rate, 4. Tax ID, 5. Delivery details,
6. Contact, 7. Comment. Move Order header panel, below customer bar. From nav,
move Sales Orders after Point of Sales. Improve design, too much wasted space
within the text fields. For selections, we can use a similar widget to the
formerly labeled 'Credit line'. Create a mock before implementation. If a
customer has a credit line, select it by default."

## Context

Spec 029 shipped the back-office "Pedidos" screen; spec 032 reshaped its header
into a fact strip, four always-visible fields and seven fields behind a "More
details" disclosure. Live use since then surfaced a set of small, unrelated
defects that share one root: the screen grew by accretion, so the same fact now
appears twice, in two different states of freshness, and the panel that carries
the least-used information sits above the one that carries the most-used.

Three things are wrong on the screen today:

- **Balance is shown twice.** The customer bar reports the customer's
  outstanding balance from its own live source; the header panel's fact strip
  reports the order's stored balance. Users read them as the same number and
  the header one is the one they distrust.
- **Payment terms are shown twice.** The customer bar carries the editable
  terms dropdown (mislabelled "Credit line" since spec 023 turned that slot
  from a figure into a control); the header panel repeats the same value
  read-only, directly beneath it.
- **Order metadata leads, customer identity follows.** The header panel renders
  above the customer bar, so the screen opens on reference numbers rather than
  on who the order is for.

Two further asks are about efficiency rather than correctness: the disclosed
fields are ordered by nothing in particular, and every field in the panel is a
full Material outlined box — a control sized for typing wrapped around a value
that is usually one short word.

Finally, one behavioural change: a customer who has a credit line is, in
practice, always sold to on credit, but every order still opens on immediate
terms and the salesperson must change it by hand.

Out of scope, deliberately: the product search field, the line rows, the totals
bar, the confirm/cancel actions, and the list screen — all must render exactly
as they do today.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Each fact appears once, and it is the live one (Priority: P1)

A salesperson opens an order to check what the customer owes. Today they see two
balances and must decide which to believe. After this change the screen carries
exactly one balance — the customer bar's, sourced live — and exactly one payment
terms control — the customer bar's dropdown, now labelled "Payment terms" so it
reads as the control it has been since spec 023 rather than as a credit figure.

**Why this priority**: This is the reported defect. A duplicated financial figure
where one copy is stale is worse than no figure at all, because it costs trust
in both.

**Independent Test**: Open a saved order for a customer with an outstanding
balance. Exactly one balance is on screen, in the customer bar, and it matches
the customer's record. Exactly one payment-terms control is on screen, in the
customer bar, labelled "Payment terms" / "Forma de pago".

**Acceptance Scenarios**:

1. **Given** a saved order for a customer with an outstanding balance, **When**
   the salesperson opens it, **Then** the balance appears in the customer bar and
   nowhere else on the screen.
2. **Given** that same order, **When** the salesperson expands or collapses the
   header's "More details" disclosure, **Then** no balance appears in either
   state.
3. **Given** any order, **When** the salesperson reads the customer bar,
   **Then** the payment-terms control is labelled "Payment terms" (Spanish:
   "Forma de pago"), and the customer's credit-limit figure still reads as
   supporting text beneath it.
4. **Given** any order, **When** the salesperson reads the header panel,
   **Then** no payment-terms field appears there, expanded or collapsed.
5. **Given** the point-of-sale register, **When** the cashier reads the customer
   bar, **Then** it carries the same "Payment terms" label — the two surfaces do
   not disagree about what the control is called.

---

### User Story 2 - A credit customer's order opens on credit terms (Priority: P1)

A salesperson raises an order for a customer who has a credit line. Today the
order opens on immediate terms and they must change it by hand on every order.
After this change, attaching that customer sets the order's terms to credit as
part of the same action, and the salesperson only intervenes in the exception —
a credit customer paying cash this time.

**Why this priority**: It removes a mandatory manual step from the most common
path, and it removes a class of error where an order is confirmed on the wrong
terms because the step was forgotten.

**Independent Test**: Attach a customer who has a credit line to a new order.
Without any further action, the order is on credit terms and stays there after
the screen is reloaded.

**Acceptance Scenarios**:

1. **Given** a new order with no customer, **When** the salesperson attaches a
   customer who has a credit line, **Then** the order's payment terms become
   credit, and remain credit after reloading the order.
2. **Given** a new order with no customer, **When** the salesperson attaches a
   customer with no credit line, **Then** the order's payment terms are
   immediate.
3. **Given** an order already on credit terms, **When** the salesperson replaces
   the customer with one who has no credit line, **Then** the order's terms fall
   back to immediate rather than remaining on terms the new customer cannot use.
4. **Given** an order for a credit customer that defaulted to credit, **When**
   the salesperson changes the terms to immediate, **Then** the change holds —
   nothing re-applies the default while that customer stays attached.
5. **Given** any customer, **When** the terms dropdown is opened, **Then** both
   immediate and credit remain selectable exactly as they are today for a
   customer with a credit line.

---

### User Story 3 - The header reads in a deliberate order, below the customer (Priority: P2)

A salesperson working through an order reads it top-down: who it is for, then
what it is. Today the order comes second. And when they expand "More details",
the seven fields arrive in no particular order, so finding the currency means
scanning.

**Why this priority**: Pure sequencing — no data changes and nothing is lost —
but it is what makes the screen scannable, and it is cheap.

**Independent Test**: Open an order and expand the disclosure. The customer bar
is above the header panel, and the disclosed fields appear in the stated order.

**Acceptance Scenarios**:

1. **Given** an order screen at any width, **When** it renders, **Then** the
   customer bar appears above the order header panel.
2. **Given** the header panel, **When** the disclosure is expanded, **Then** the
   fields appear in exactly this order: Priority, Currency, Exchange rate,
   Tax ID, Delivery details, Contact, Comment.
3. **Given** the header panel, **When** the disclosure is expanded, **Then**
   Comment is last and spans the full width, as it does today.
4. **Given** the header panel, **When** it is compared against today's, **Then**
   no field or fact has been lost other than balance and payment terms.

---

### User Story 4 - The header wastes less vertical space (Priority: P2)

The header panel's fields are full outlined input boxes — the affordance for
typing a paragraph — around values that are one word ("Alta", "MXN") or a date.
The panel is therefore much taller than the information in it warrants, pushing
the product lines below the fold. A denser presentation, taking its shape from
the compact control the customer bar already uses for payment terms, recovers
that space.

**Why this priority**: Real but cosmetic, and it depends on a mock being agreed
first — so it must not block the corrections in US1–US3.

**Independent Test**: With a mock approved, compare the expanded header panel
against today's at the same width and text scale: it is materially shorter, and
every field is still readable, still gated the same way, and still writes on
change.

**Acceptance Scenarios**:

1. **Given** the header panel's redesign, **When** the work begins, **Then** a
   visual mock has already been produced and approved by the user.
2. **Given** the approved mock, **When** the panel is expanded at desktop width,
   **Then** it is measurably shorter than today's panel at the same width and
   text scale.
3. **Given** the denser panel, **When** a selection field is used, **Then** it
   still opens, still writes on change, and still respects the same edit gating
   as today.
4. **Given** the denser panel, **When** the app runs at the largest supported
   text scale and at the compact tier, **Then** no field overflows or clips and
   every interactive control keeps a usable touch target.

---

### User Story 5 - Sales Orders sits after Point of Sale in the menu (Priority: P3)

The Sales group lists Sales Orders before Point of Sale. In practice the
register is the more frequently used destination, so it should come first.

**Why this priority**: A one-line ordering change with no behavioural
consequence.

**Independent Test**: Open the navigation with a user who can see both. Sales
Orders appears immediately after Point of Sale.

**Acceptance Scenarios**:

1. **Given** a user with access to both destinations, **When** the navigation
   renders, **Then** Sales Orders appears immediately after Point of Sale within
   the Sales group.
2. **Given** a user with access to Sales Orders but not to the register,
   **When** the navigation renders, **Then** Sales Orders is still visible — the
   move changes order only, never visibility.
3. **Given** any user, **When** they navigate to either destination by link or
   by menu, **Then** they arrive at the same screen as before.

### Edge Cases

- **The customer's balance cannot be loaded.** The customer bar already leaves
  its balance blank rather than failing the band. With the header's copy gone
  there is no second figure to fall back on; a blank is accepted, and the rest
  of the screen is unaffected.
- **A customer's credit line is zero.** Treated as no credit line, exactly as
  the customer bar treats it today — terms stay immediate and the credit option
  stays disabled in the dropdown.
- **The customer is changed on an order that already has priced lines.**
  Attaching a customer already re-prices every line; the terms default rides in
  the same write, so the order never sits in a state where one has landed and
  the other has not.
- **A terms-only edit, or any other header write.** The credit default is
  triggered by attaching a customer and by nothing else — editing the comment,
  the currency or the terms themselves must never re-apply it.
- **The order is no longer editable.** Confirmed and cancelled orders accept no
  header writes; the default cannot fire because no customer can be attached.
- **The register's walk-in customer.** It has no credit line, so the register's
  behaviour on the common path is unchanged by US2.
- **Compact tier.** The customer bar stacks its facts above its actions; the
  header panel follows beneath it in the same stacked order.

## Requirements *(mandatory)*

### Functional Requirements

**One place per fact (US1)**

- **FR-001**: The order header panel's fact strip MUST NOT show a balance. It
  carries reference, status and date only. This amends spec 032 FR-002.
- **FR-002**: The customer bar's outstanding balance MUST remain exactly as it
  is, as the order screen's only balance.
- **FR-003**: The order header panel MUST NOT show a payment-terms field in any
  disclosure state. Its always-visible field row therefore carries three fields
  — due date, promise date, salesperson. This amends spec 032 FR-003.
- **FR-004**: The customer bar's payment-terms control MUST be labelled "Payment
  terms" (English) and "Forma de pago" (Spanish), on every surface that renders
  the bar — the point-of-sale register and the back-office order screen alike.
- **FR-005**: The credit-limit figure rendered as supporting text beneath that
  control MUST remain, unchanged, including its "no credit line" variant.

**Credit terms by default (US2)**

- **FR-006**: Attaching a customer who has a non-zero credit line to an order
  MUST set that order's payment terms to credit, persisted as part of the same
  write that attaches the customer. This supersedes spec 023 FR-028/FR-029/
  FR-030, which required that terms never be written except by the user's own
  explicit choice.
- **FR-007**: Attaching a customer who has no credit line MUST leave the order
  on immediate terms, including when the order was on credit terms for a
  previously attached customer.
- **FR-008**: A user's own subsequent change of terms MUST hold — nothing may
  re-apply the default while the same customer remains attached.
- **FR-009**: Both terms options MUST remain selectable for a customer with a
  credit line, exactly as today. Restricting immediate payment for credit
  customers is explicitly out of scope.
- **FR-010**: No header write other than attaching a customer may apply the
  default.

**Order and placement (US3)**

- **FR-011**: The order header panel MUST render below the customer bar on the
  order screen, at every breakpoint.
- **FR-012**: The header panel's disclosed group MUST present its fields in
  exactly this order: Priority, Currency, Exchange rate, Tax ID, Delivery
  details, Contact, Comment. This supersedes spec 032 FR-004's ordering.
- **FR-013**: Comment MUST remain last and full-width (spec 032 FR-008 holds).
- **FR-014**: No field or fact present before this feature may be dropped other
  than the balance (FR-001) and the payment terms (FR-003). Spec 032 FR-012
  otherwise holds unchanged.

**Density (US4)**

- **FR-015**: A visual mock of the order screen's header stack — the customer
  bar with the header panel beneath it, in both collapsed and expanded states,
  reflecting FR-001/FR-003/FR-011/FR-012 — MUST be produced and approved by the
  user before any of FR-016's presentation work is implemented.
- **FR-016**: The header panel's fields MUST adopt a denser presentation than
  today's full outlined form fields. Selection fields MUST take the shape the
  customer bar's payment-terms control already uses: a small caption above a
  dense control, with optional supporting text beneath, rather than a labelled
  outlined box.
- **FR-017**: The denser presentation MUST NOT change any field's edit gating,
  and every field MUST keep writing through on change with no Save step (spec
  032 FR-010, FR-011 hold).
- **FR-018**: The denser presentation MUST remain legible and non-overflowing at
  the largest supported text scale and at the compact tier, and every
  interactive control MUST keep a usable touch target.
- **FR-019**: The presentation MUST resolve through the design system's tokens,
  never through hard-coded colours, sizes or type (constitution §V).

**Navigation (US5)**

- **FR-020**: The Sales Orders destination MUST appear immediately after Point
  of Sale within the Sales group.
- **FR-021**: The move MUST change display order only — each destination keeps
  its route, its access gate and its visibility rules unchanged.

**Containment**

- **FR-022**: The product search field, the line rows and cards, the totals bar,
  the confirm and cancel actions, and the orders list screen MUST render exactly
  as they do today.
- **FR-023**: Point-of-sale behaviour MUST be unchanged except where FR-004 and
  FR-006 deliberately change it, since both apply to the shared customer bar.

### Key Entities

No new entities. The feature reads and writes the same order header fields spec
029 defined, plus the customer's existing credit limit, which it reads to decide
the default in FR-006.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: The order screen shows the balance exactly once, and its value
  matches the customer's record at the moment of rendering.
- **SC-002**: The order screen shows payment terms exactly once, in an editable
  control, on both the collapsed and expanded header.
- **SC-003**: Raising an order for a customer with a credit line takes **zero**
  extra actions to reach credit terms, down from one on every order.
- **SC-004**: The expanded header panel is at least 20% shorter than today's at
  the same width and text scale, with no field removed beyond FR-001 and
  FR-003.
- **SC-005**: At the largest supported text scale and at the compact tier, the
  header panel renders with no overflow and no clipped labels.
- **SC-006**: Sales Orders appears immediately after Point of Sale for every
  user who can see both, and remains visible for users who can see only it.
- **SC-007**: The mock is approved by the user before the density work starts —
  verifiable as an artefact recorded against this spec.
- **SC-008**: Every existing point-of-sale and sales-order test passes
  unchanged, except those that assert the old "Credit line" label or the old
  never-write-terms rule, which are updated to the new behaviour and not merely
  deleted.

## Assumptions

- **"Remove the last one" means the header panel's balance.** The two figures
  are not the same quantity — the customer bar reports the customer's live
  outstanding balance, the header reports the order's stored balance — and the
  user's complaint ("doesn't show updated data") points at the stored one.
  Spec 032 recorded the strip's balance as satisfying spec 029 US4 scenario 3
  ("the outstanding balance stays visible without leaving the screen"); that
  coverage now falls to the customer bar's balance, so 029's intent still holds.
- **"Tax ID" and "Delivery details" are the existing recipient and ship-to
  fields.** The localized labels already read exactly that way, so the user's
  ordering list maps one-to-one onto the seven fields that exist today; nothing
  is added or removed by the reorder.
- **Spec 023 FR-028/FR-029/FR-030 are superseded, not violated.** That rule
  existed because writing terms on the customer's behalf could silently put a
  register sale on credit. The user has decided the opposite trade: for a
  customer who has a credit line, credit is the intended terms and having to
  set it by hand on every order is the greater cost. Both options stay
  selectable, so the user can still overrule it in one action.
- **The default persists rather than merely preselecting.** Decided with the
  user. A dropdown showing credit while the server holds immediate would be a
  worse failure than the manual step it replaces.
- **Restricting immediate payment for credit customers stays deferred.** It is
  the second half of TODO.md's 2026-07-28 item; only the default is in scope
  here, and the TODO entry remains open for it.
- **The label rename applies to the shared control on both surfaces.** Decided
  with the user — one control, one name, rather than a per-surface branch.
- **The mock is a presentation, not a pixel contract.** As with spec 032's
  artboard, its palette, spacing and type resolve through the spec 022 design
  tokens (constitution §V), and compact-tier behaviour derives from the existing
  responsive rules rather than from the mock.
- **Navigation display order comes from position in the navigation tree**, not
  from any branch index, so the reorder needs no route or index renumbering.
- **Both localization catalogues stay in sync.** English and Spanish are updated
  together for every label this feature touches.
