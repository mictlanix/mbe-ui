# Feature Specification: Live Testing Session Fixes

**Feature Branch**: `036-live-testing-fixes`

**Created**: 2026-09-02

**Status**: Draft

**Input**: User description: "Nine issues observed on a live testing session, spanning Customers CRUD (optional/reordered code field, removal of the shipping booleans), POS Sales (warehouse stock visibility, editing a sale before payment, auto-assigning the first delivery destination), back-office Sales Orders (blocking 'Público en General' and making customer selection the first step, auto-filling the salesperson from the customer), Pricing (a price edit lost when the user moves to the next row), and general app settings (one configurable currency decimal-digit format, one configurable debounce duration)."

## Overview

A live testing session surfaced nine issues across five parts of the product that are
otherwise unrelated in code but share a common thread: each is a small, already-diagnosed
correction to a screen already in daily use, not new functionality. Three are outright bugs
that lose or block real work — a price edit that silently fails to save, a sale that cannot
be corrected once past a certain step, and a sales order that can be billed to the generic
walk-in customer by mistake. The remaining six are friction and consistency fixes: a
required field that should not be required, two fields nobody uses anymore, a picker that
hides the one fact (available stock) a cashier needs to choose correctly, a delivery step
that makes the cashier retype what the system already knows, a salesperson field the system
could fill in on its own, and two settings (currency decimals, debounce delay) that today are
hardcoded in more than one place instead of configured once.

Nothing here introduces a new screen or a new business capability; every item corrects how
an existing screen behaves.

## User Scenarios & Testing

### User Story 1 - Sales orders are always billed to a real, named customer (Priority: P1)

A back-office clerk creates a Sales Order and, out of habit or because it is quicker, either
leaves the customer as the generic "Público en General" walk-in record or fills in product
lines before ever picking a customer. The resulting order cannot be correctly invoiced,
delivered, or followed up with, because there is no real customer behind it.

**Why this priority**: This produces orders that are functionally useless downstream
(invoicing, delivery, collections) and is a data-integrity problem, not a preference — it
ranks with the other bugs.

**Independent Test**: Start a new Sales Order and confirm the customer step is presented
first and that "Público en General" does not appear as a selectable choice; confirm no
product line can be added until a specific customer is chosen.

**Acceptance Scenarios**:

1. **Given** a new Sales Order, **When** the creation flow opens, **Then** choosing a customer
   is the first step presented, before any product line or other order detail can be entered.
2. **Given** the customer picker on a Sales Order, **When** the user searches or browses it,
   **Then** the generic "Público en General" customer does not appear as a selectable result.
3. **Given** a Sales Order with no customer chosen yet, **When** the user attempts to add a
   product line or save the order, **Then** the system blocks the action and directs the user
   to choose a customer first.
4. **Given** a Sales Order already saved against "Público en General" before this change,
   **When** it is opened afterward, **Then** it still opens and displays correctly — this
   feature only blocks new selections, not existing data (see Edge Cases).

---

### User Story 2 - A cashier can correct a sale before it is paid (Priority: P1)

Partway through a point-of-sale transaction — already on the payment or delivery step — a
cashier or customer realizes an item is wrong or missing. Today the only way to fix this is
to cancel the entire sale and start over, because there is no way back to the cart once past
the first step.

**Why this priority**: Forcing a full restart for a correctable mistake, on every sale that
reaches this point, is a recurring operational cost and the single most disruptive item in
the POS flow.

**Independent Test**: Start a sale, add items, advance to the payment step without recording
any payment, and confirm the cart can be reopened and changed; then record a payment and
confirm the cart can no longer be changed.

**Acceptance Scenarios**:

1. **Given** a sale on the payment step with no payment recorded yet, **When** the cashier
   asks to return to the cart, **Then** they can add, remove, or change line items.
2. **Given** a sale on the delivery step with no payment recorded yet, **When** the cashier
   asks to return to the cart, **Then** they can add, remove, or change line items.
3. **Given** a sale with at least one payment already recorded, **When** the cashier tries to
   change a line item, **Then** the system prevents it, exactly as it does today.
4. **Given** a sale the cashier has just corrected, **When** they advance again, **Then** the
   payment and delivery steps reflect the corrected items, not the original ones.

---

### User Story 3 - Every price edit is saved, however the user leaves the field (Priority: P1)

Someone editing a price list moves down the grid row by row, typing a new price and clicking
straight into the next row instead of pressing Enter or Tab. The price they just typed is
silently lost — the app shows no error, but the value was never saved.

**Why this priority**: A save that silently fails is the worst class of bug — the user has no
way to know it happened without re-checking every row, and lost pricing data has direct
financial consequences.

**Independent Test**: Edit a price in the grid, then click directly into a different row's
price field without pressing Enter or Tab first, reload the screen, and confirm the edited
value persisted.

**Acceptance Scenarios**:

1. **Given** an edited, uncommitted price value, **When** the user presses Enter, Tab, an
   arrow key, or clicks directly into a different cell, **Then** the edited value is saved
   before the new cell becomes active.
2. **Given** a saved price edit, **When** the screen is reloaded, **Then** the new value is
   the one shown — never the value from before the edit.
3. **Given** an edit that fails validation, **When** the user moves away from the cell by any
   of the means above, **Then** the failure is shown to the user rather than silently
   discarded or silently accepted.

---

### User Story 4 - The customer form matches how customers are actually captured (Priority: P2)

Registering a new customer, a clerk is blocked by a required "code" field that the business
does not actually assign at intake, and must scroll past two shipping-related toggles that
no longer mean anything to how the business operates.

**Why this priority**: A required field with no real value forces clerks to type a
placeholder just to get past validation, and the two toggles are dead weight on every
customer record — cheap to fix, but every customer created or edited encounters it.

**Independent Test**: Open the customer form and confirm a customer can be saved with no code
entered, that the code field appears directly after credit days, and that no shipping-related
toggle is present anywhere on the form.

**Acceptance Scenarios**:

1. **Given** the customer creation form, **When** the clerk fills in every field except code,
   **Then** the customer saves successfully.
2. **Given** the customer form, **When** it renders, **Then** the code field appears
   immediately after the credit days field, not in its previous position.
3. **Given** the customer form, **When** it renders, **Then** no "shipping" or "shipping
   required document" toggle is present.
4. **Given** the POS delivery-method selector, which today gates shipping on a customer's
   `shipping` flag, **When** that flag is removed, **Then** shipping and mixed (part-pickup,
   part-delivery) fulfillment become available for every customer except the generic "Público
   en General" customer, which remains restricted to pickup-only.
5. **Given** the generic "Público en General" customer is the one selected for a POS sale,
   **When** the cashier opens the fulfillment/delivery-method selector, **Then** shipping and
   mixed fulfillment are not offered — only pickup.

---

### User Story 5 - A sales order fills in the customer's salesperson automatically (Priority: P2)

A back-office clerk selects the customer for a Sales Order and then has to separately look up
and select that same customer's usual salesperson, even though the system already knows the
association from the customer's own record.

**Why this priority**: A small but repeated piece of redundant data entry, once per order,
that the system already has the information to avoid.

**Independent Test**: Select a customer that has an associated salesperson on file and
confirm the order's salesperson field is pre-filled; select a customer with none and confirm
it is left blank for manual entry.

**Acceptance Scenarios**:

1. **Given** a customer with an associated salesperson, **When** that customer is selected for
   a Sales Order, **Then** the order's salesperson field is pre-filled with that salesperson.
2. **Given** the pre-filled salesperson, **When** the clerk wants a different one, **Then** it
   can still be changed before the order is saved.
3. **Given** a customer with no associated salesperson, **When** that customer is selected,
   **Then** the salesperson field is left blank, unchanged from today.

---

### User Story 6 - A cashier sees which warehouse actually has stock before choosing one (Priority: P2)

Selecting the source warehouse for a product line in a POS sale, a cashier has no way to tell,
from the picker itself, whether a listed warehouse actually has enough stock — they find out
only after selecting it and seeing a shortfall warning.

**Why this priority**: This is friction rather than a hard failure — the shortfall is still
caught — but it is encountered on every warehouse selection and forces a guess-then-check
workflow instead of an informed choice.

**Independent Test**: Open the warehouse picker for a product line whose stock is known to be
short in at least one warehouse and confirm that warehouse is visibly flagged before it is
selected.

**Acceptance Scenarios**:

1. **Given** the warehouse picker for a product line, **When** it lists a warehouse known to
   lack enough stock for the requested quantity, **Then** that warehouse is visibly flagged as
   such in the list itself.
2. **Given** that same picker, **When** a listed warehouse has enough stock, **Then** it is not
   flagged.
3. **Given** a warehouse whose stock has not yet been checked this session, **When** it is
   listed, **Then** it is shown as unknown rather than implied to have stock.
4. **Given** a warehouse flagged as lacking stock, **When** the cashier selects it anyway,
   **Then** the selection still succeeds — the flag is informational, not a block.

---

### User Story 7 - The first delivery destination absorbs the full order automatically (Priority: P2)

Adding the first delivery destination to a sale, a cashier must manually type or step the
quantity for every single line item, even though — with only one destination on the order so
far — the obvious, almost-always-correct assignment is "all of it."

**Why this priority**: Repeated, unnecessary manual entry on the most common case (one
destination), while remaining easy to override for the less common one (multiple
destinations).

**Independent Test**: Add a first delivery destination to a sale with several line items and
confirm every line's full remaining quantity is already assigned to it without manual entry;
then add a second destination and confirm its quantities still default to zero.

**Acceptance Scenarios**:

1. **Given** a sale with no delivery destinations yet, **When** the cashier adds the first
   one, **Then** every line's full remaining quantity is assigned to it automatically.
2. **Given** that auto-assigned destination, **When** the cashier wants to change a quantity,
   **Then** it can still be adjusted exactly as a manually-entered quantity can today.
3. **Given** a sale that already has one destination, **When** the cashier adds a second one,
   **Then** its quantities default to zero, unchanged from today, since the remaining stock
   must now be split between destinations.

---

### User Story 8 - Every peso amount on screen honors one decimal-digit setting (Priority: P3)

Currency amounts are shown with a consistent number of decimal digits almost everywhere
already, by way of an existing deployment-level setting — but the live session found at least
one field where that was not the case. The fix is to close that gap and confirm nothing bypasses
the shared setting, not to invent a new mechanism.

**Why this priority**: Purely a consistency/audit fix with an existing setting and default —
lowest risk and narrowest scope of everything in this feature.

**Independent Test**: Change the deployment's currency decimal-digit setting away from its
default and confirm every currency-displaying field across the app reflects the new value with
no exceptions.

**Acceptance Scenarios**:

1. **Given** the deployment's currency decimal-digit setting at its default, **When** any
   currency field renders, **Then** it shows two decimal digits.
2. **Given** that setting changed to a different value, **When** the app is restarted, **Then**
   every currency-displaying field across the app reflects the new value — none is left showing
   its own hardcoded digit count.

---

### User Story 9 - One configurable pace governs each kind of debounced field (Priority: P3)

Several fields across the app — product/customer search boxes, a quantity stepper's
confirm-and-commit — each wait a fixed, separately hardcoded delay after the user stops typing
or adjusting before acting. Nothing lets a deployment tune that pace in one place. Search boxes
and the quantity-commit step serve different purposes and already default to different delays,
so this closes into two settings — one per kind — rather than a single shared knob.

**Why this priority**: A tuning knob with no reported malfunction today — worth having, but
the lowest-impact item here.

**Independent Test**: Change the search-debounce setting and confirm every search-style field's
delay shifts together, with no such field left on its own hardcoded delay; separately, change the
quantity-commit setting and confirm every quantity-commit field's delay shifts together.

**Acceptance Scenarios**:

1. **Given** either setting at its default, **When** a field in that category is used, **Then**
   it waits the same, current delay it does today (no behavior change for a deployment that
   leaves both settings unset).
2. **Given** the search-debounce setting changed to a different value, **When** the app is
   restarted, **Then** every search-style field across the app waits the new delay, and every
   quantity-commit field is unaffected.
3. **Given** the quantity-commit setting changed to a different value, **When** the app is
   restarted, **Then** every quantity-commit field across the app waits the new delay, and every
   search-style field is unaffected.

---

### Edge Cases

- A Sales Order already saved against "Público en General" before this change continues to
  open and display normally; only new selection of that customer is blocked (User Story 1).
- A Sales Order resumed later, part-way through creation, from before this change shipped, and
  that has no customer yet — it must still be routed back through the customer step before any
  further edit.
- A sale is fully covered by credit terms with no cash actually collected — this still counts
  as a recorded payment and locks item editing, consistent with today's definition of "paid"
  (User Story 2).
- Committing a price edit on the very first or very last row/column of the pricing grid, where
  "move to the next cell" has no further cell in that direction.
- A delivery destination that was auto-assigned the full order is then deleted — the quantity
  it held becomes unassigned again, exactly as deleting any manually-assigned destination does
  today (User Story 7).
- A warehouse whose available stock has never been looked up in the current session shows as
  unknown in the picker, never as falsely "in stock" (User Story 6).
- A deployment sets the currency decimal-digit setting to a value other than two (e.g. a whole-
  currency deployment using zero) — every on-screen currency field follows it; server-rendered
  documents (invoices, POS tickets) are generated by the backend and are unaffected by this
  client-side setting (see Out of Scope).
- A deployment sets either debounce setting to zero or a very large value — the setting
  is applied as given; guarding against a value so small it floods the backend, or so large the
  UI feels unresponsive, is a deployment configuration concern, not a client-side validation
  this feature adds.
- A sale already in delivery or mixed fulfillment mode has its customer switched to "Público en
  General" — the sale is automatically reset to pickup-only and the user is notified, rather than
  left in an inconsistent state (FR-016).

## Requirements

### Functional Requirements

#### Sales order customer integrity

- **FR-001**: Choosing a customer MUST be the first step presented when creating a new Sales
  Order, before any product line or other order detail can be entered.
- **FR-002**: The generic "Público en General" customer MUST NOT appear as a selectable result
  in the Sales Order customer picker.
- **FR-003**: The system MUST prevent adding a product line or saving a Sales Order that has no
  specific customer chosen, and MUST tell the user to choose a customer first.
- **FR-004**: A Sales Order already saved against "Público en General" before this change MUST
  continue to open and display correctly; this feature only blocks new selections of that
  customer, not existing data.

#### Editing a POS sale before payment

- **FR-005**: While a sale has no payment recorded, the cashier MUST be able to return from the
  payment or delivery step to the cart and add, remove, or change line items.
- **FR-006**: Once at least one payment is recorded against a sale, line-item edits MUST remain
  blocked, unchanged from today.
- **FR-007**: After the cart is corrected and the cashier advances again, the payment and
  delivery steps MUST reflect the corrected items.
- **FR-008**: A sale's status MUST remain `draft` when the cashier advances to the Cobro or
  Entrega step; it MUST transition away from `draft` only once a payment is actually recorded
  against the sale, not merely by reaching a later step.

#### Pricing grid commit bug

- **FR-009**: Editing a price value and moving away from that field — by Enter, Tab, an arrow
  key, or clicking directly into a different cell — MUST commit (save) the edited value before
  the newly-focused cell becomes active. No case exists in which moving to another cell leaves
  an edit uncommitted.
- **FR-010**: A committed edit that fails validation MUST surface that failure to the user;
  it MUST NOT be silently discarded or silently accepted as valid.

#### Customer form field changes

- **FR-011**: The Customer form MUST allow saving a customer record with no value entered for
  `code`.
- **FR-012**: The Customer form MUST present the `code` field immediately after the `credit
  days` field.
- **FR-013**: The Customer form MUST NOT present a "shipping" toggle or a "shipping required
  document" toggle.
- **FR-014**: A customer record MUST NOT store a shipping flag or a shipping-required-document
  flag.
- **FR-015**: The POS delivery-method selector MUST offer shipping and mixed (part-pickup,
  part-delivery) fulfillment to every customer, replacing today's check of the removed
  `shipping` flag, **except** for the generic "Público en General" customer, which MUST remain
  restricted to pickup-only.
- **FR-016**: If a sale already in delivery or mixed fulfillment mode has its customer changed to
  "Público en General", the system MUST automatically reset that sale to pickup-only fulfillment
  and notify the user why, rather than leaving a delivery/mixed sale attached to a customer that
  cannot use it.

#### Sales order salesperson autofill

- **FR-017**: When a customer with an associated salesperson is selected for a Sales Order, the
  order's salesperson field MUST be pre-filled with that salesperson.
- **FR-018**: The pre-filled salesperson MUST remain changeable by the user before the order is
  saved.
- **FR-019**: When the selected customer has no associated salesperson, the salesperson field
  MUST remain blank for manual entry, unchanged from today.

#### Warehouse stock visibility

- **FR-020**: The warehouse picker used to choose a product line's source warehouse MUST
  visibly flag, within the picker itself, any listed warehouse that lacks enough stock for the
  quantity being requested.
- **FR-021**: A warehouse whose stock has not yet been checked in the current session MUST be
  shown as unknown, not implied to have stock.
- **FR-022**: Flagging a warehouse as short on stock MUST remain informational — the cashier
  MUST still be able to select it, exactly as today.

#### Delivery destination auto-assignment

- **FR-023**: When the first delivery destination is added to a sale with no existing
  destinations, every line's full remaining (unassigned) quantity MUST be assigned to it
  automatically.
- **FR-024**: Quantities assigned this way MUST remain adjustable by the user afterward, the
  same as a manually-entered quantity.
- **FR-025**: Adding a second or later delivery destination MUST continue to default its
  quantities to zero, unchanged from today.

#### Currency decimal-digit consistency

- **FR-026**: Every currency-displaying or currency-editing field in the app MUST format its
  amount using one single, deployment-configurable decimal-digit count, with no field applying
  its own separately-hardcoded digit count.
- **FR-027**: That decimal-digit count MUST default to two when the deployment does not set it
  explicitly.

#### Debounce duration consistency

- **FR-028**: The system MUST provide one deployment-configurable setting for the delay a
  search-style field (one that waits after the user stops typing before issuing a request) uses,
  and a second, separate deployment-configurable setting for the delay a quantity-commit field
  (one that waits after the user stops adjusting a value before saving it) uses. These are two
  settings, not one, because they govern different kinds of behavior — a search delay versus a
  save-commit window — with different existing defaults.
- **FR-029**: Every search-style field in the app MUST use the first setting's value, and every
  quantity-commit field MUST use the second setting's value; none MUST be left on its own
  independently-hardcoded delay.
- **FR-030**: Each setting MUST default to the value already in effect today for its category when
  the deployment does not set it explicitly, so an unconfigured deployment sees no behavior
  change.

### Key Entities

- **Sales Order (Pedido)**: a back-office order tied to a specific customer. Gains a hard
  requirement that the customer be chosen first and never be the generic walk-in record, and a
  salesperson that can now be derived from the customer.
- **Customer**: the party a Sales Order or POS sale is billed to. Loses two attributes
  (shipping flag, shipping-required-document flag), gains an optional rather than required
  code, and carries an associated salesperson already usable to autofill orders.
- **POS Sale**: a point-of-sale transaction moving through cart, payment and delivery steps.
  Gains the ability to return to the cart from a later step while unpaid; item-editability
  remains governed by whether a payment has been recorded.
- **Delivery Destination**: a shipping address attached to a sale, carrying a per-line quantity
  assignment. The first one added to a sale now starts pre-filled with the full order instead
  of zero.
- **Warehouse Stock**: the known available quantity of a product at a warehouse, already used
  to warn about shortfalls after the fact; now also surfaced directly in the warehouse picker.
- **Price List Entry**: an individual product price within a price list, edited in a grid whose
  commit behavior must trigger on every way of leaving the field, not only some.
- **App Setting**: deployment-level configuration resolved once at startup, covering currency
  decimal digits (already present) and debounce duration (added by this feature).

## Success Criteria

### Measurable Outcomes

- **SC-001**: 100% of price edits are saved regardless of whether the user leaves the field via
  keyboard or by clicking directly into another cell — zero silently-lost edits.
- **SC-002**: 0% of newly created Sales Orders reference the generic "Público en General"
  customer.
- **SC-003**: A cashier can correct an unpaid sale's items after reaching the payment or
  delivery step without cancelling and restarting the sale.
- **SC-004**: A new customer can be saved with the `code` field left empty.
- **SC-005**: Adding a single delivery destination to a sale requires zero manual quantity
  entries to deliver the full order.
- **SC-006**: A Sales Order's salesperson field is pre-filled for 100% of customers that have an
  associated salesperson on file, requiring no manual selection in that case.
- **SC-007**: Changing the deployment's currency decimal-digit setting changes 100% of
  currency-displaying fields in the app, from one place.
- **SC-008**: Changing the deployment's search-debounce setting changes 100% of search-style
  fields in the app from one place, without affecting quantity-commit fields; changing the
  quantity-commit setting changes 100% of quantity-commit fields without affecting search-style
  fields.
- **SC-009**: A cashier can identify, from the warehouse picker alone and before selecting a
  warehouse, which listed warehouses lack enough stock for the product being sold.
- **SC-010**: Every customer except the generic "Público en General" can select shipping or
  mixed fulfillment for a POS sale; that one customer cannot select either.

## Out of Scope

- The two Login items noted in the same testing session (requiring a password reset on first
  login, requiring a strong password) are unrelated to these nine issues and are explicitly
  excluded from this feature.
- Introducing a formal "customer type" or "is generic" flag on the Customer record is out of
  scope; User Story 1 targets the one specific, already-known generic customer record, not a
  new general-purpose classification.
- A per-user override of the currency decimal-digit count is out of scope. Formatting
  configuration is deployment-level app settings, not personal display preference, and this
  feature does not blur that line.
- Hard-blocking a POS sale from using a warehouse that lacks stock is out of scope; User Story 6
  asks only for visibility in the picker, not a new restriction.
- Server-rendered documents (invoices, POS tickets) are unaffected by the currency
  decimal-digit setting introduced here; that setting governs the client's own screens only.

## Assumptions

- Removing the shipping flag from Customer means the one place today that reads it — the POS
  delivery-method selector — can no longer use it to decide who may ship. Confirmed with the
  requester: shipping and mixed fulfillment become available for every customer **except** the
  generic "Público en General" customer, which stays pickup-only. That one exception is
  recognized the same way as in Sales Order customer selection (see next bullet), not via any
  new field.
- "Público en General" is excluded from Sales Order customer selection, and from shipping/mixed
  fulfillment in POS sales, by recognizing it as the one specific, already-configured generic
  customer record for the deployment, not by any new customer classification (see Out of
  Scope).
- A customer has at most one associated salesperson, matching how the customer record already
  models that relationship today; User Story 5 does not change that model.
- The currency decimal-digit setting requested in User Story 8 already exists as a
  deployment-level app setting defaulting to two digits; this feature's work is to close any
  remaining field that does not yet honor it, not to build a new setting.
- Confirmed with the requester: the debounce setting in User Story 9 is a deployment-level app
  setting, like the currency setting above, not a personal display preference — and it is two
  settings, not one, because search-style fields and the quantity-commit step already default to
  different delays (300 ms and 400 ms respectively) and a single shared value could not preserve
  both without changing one of them. Each setting defaults to the delay already in effect today
  for its own category, so an unconfigured deployment is unaffected either way.
- Confirmed with the requester: if a sale already in delivery or mixed fulfillment mode has its
  customer switched to "Público en General" mid-sale, the sale is automatically reset to
  pickup-only and the user is notified (FR-016), rather than left attached to a customer that
  cannot use that mode.
- The `code`-optional change and the removal of the two shipping fields both require a
  corresponding mbe-api schema change. These are filed as
  [mictlanix/mbe-api#198](https://github.com/mictlanix/mbe-api/issues/198) (`code` optional) and
  [mictlanix/mbe-api#199](https://github.com/mictlanix/mbe-api/issues/199) (remove
  `shipping`/`shipping_required_document`), and are expected to be completed the same day as
  this spec. This feature's mbe-ui-side work (FR-011 through FR-016) is planned against the
  updated contract landing on that timeline, not against an indefinite external dependency.
