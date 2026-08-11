# Feature Specification: Point of Sale — Sales List, Full-Width Workspace and Capture Polish

**Feature Branch**: `023-pos-ux-improvements`

**Created**: 2026-08-10

**Status**: Draft

**Input**: User description: "Improve POS UX, focusing on point-of-sale navigation and the capture step. (1) Add a screen that lists the sales created at the point of sale, where the edit button is enabled only for open sales and reopens the sale at its current step, plus a New Sale action. (2) When opening or editing a sale, give the workspace more room by following the child-navigation pattern — a Back button in the app bar, the shell navigation hidden — and make the POS screens maximize space: no centered content, no unused space, unlike the editing forms. (3) Bring the capture step closer to `artifacts/point_of_sale/POS_Adaptativo.dc.html`, honoring spec 020's final decisions, respecting Material Design and the current design system: (3.1) customer area with Buscar/Nuevo actions that swap the customer facts for the picker with animated, progress-showing feedback, the fulfilment mode selector beside it, payment terms as a dropdown replacing the segmented control, and the odd padding fixed; (3.2) product search that shows options as the user types rather than only on Enter; (3.3) sale line rows with corrected field sizes, a product image and better name/code presentation, on one row until it no longer fits; (3.4) a footer closer to the proposal's sizes and placements."

## Clarifications

### Session 2026-08-10

- Q: Where should the sales list live relative to the capture workspace? → A: The point-of-sale destination becomes the sales list inside the application shell; the sale workspace moves to full-screen child routes with a Back button.
- Q: Which sales does the list show, and how far back? → A: The signed-in cashier's own register, defaulting to the current trading day, with a filterable date range, status facets, search and server-side paging.
- Q: When a customer that has a credit line is selected, what should the new payment-terms control do? → A: Reflect the sale's own current terms and never switch them by itself; offer credit only when the customer has a credit line.
- Q: Sale lines need a product thumbnail, but no payload carries a photo URL. How should the image be sourced? → A: Require an mbe-api change to expose it, and until then reserve the thumbnail slot and draw the placeholder.

## Overview

Spec 020 shipped the counter screen and spec 021 gave it a cash session to
open against. Working the shipped screen for real surfaced three complaints,
and this feature answers exactly those three — it adds no new selling
capability, changes no money rule, and moves no step.

**The register's sales are invisible.** The only way to see what has been rung
up is a dropdown of *unfinished* sales, reachable only from inside the sale
screen itself. A cashier who wants to see the day's sales, or reopen the one
they abandoned twenty minutes ago, has nowhere to look. Every other record in
this product has a list screen; sales do not.

**The screen is starved of the width it needs.** The capture surface renders
inside the ordinary shell, beside the navigation rail, with form-style paddings
and a totals bar that leaves a large empty band between the last line and the
footer — visible in the screenshot that prompted this feature, where a
1440-pixel display shows a single sale line and roughly four hundred pixels of
nothing. A counter screen is not a form; density is the whole point.

**The capture surface drifted from its own reference.** The mock's frame `2a`
puts the customer's standing facts and the fulfilment mode on one band, the
lines on one row each with a thumbnail and proportionate fields, and the money
in a footer with the primary action on it. What shipped stacks those pieces
vertically, prices a three-segment terms control at the width of the customer
picker, and pads the customer card twice.

Five decisions shape everything below.

1. **The sales list is what the navigation destination opens.** `/sales/pos`
   becomes a list screen built the way every catalog list screen in this
   product is built. The sale itself moves to a child route. This is the
   ordinary list→record shape, applied to a record that never had it.

2. **The sale workspace leaves the shell.** This deliberately revises spec
   020's decision 2 ("the screen lives inside the ordinary application shell.
   It is not a kiosk"), and only for the workspace: reopening or capturing a
   sale is now a full-screen child route with a Back button and no rail or
   drawer, exactly as every record detail route already behaves. The reasoning
   that made decision 2 right still holds for *reaching* the point of sale —
   which is now the list, and the list stays in the shell. What changed is
   that the sale screen turned out to need the rail's width more than it needs
   the rail's presence, and the mock's own header (frame `2a`: a back affordance,
   the folio chip, the step indicator) is the shape that fits.

3. **The workspace spends every pixel it is given.** No centering, no maximum
   content width, no dead vertical band. The lines area absorbs whatever the
   header and footer do not use, at every form factor. This is the one place in
   the product where the form-grid conventions (centered, bounded, generously
   padded) are the wrong answer.

4. **Payment terms stop being a control of their own.** The segmented
   Contado/Crédito pair is removed; the terms live where the customer's credit
   line is already reported, as a dropdown. It shows what the sale actually
   carries and changes only when the cashier changes it — a screen that
   silently rewrites a sale's payment terms because of who the customer is
   would be changing the money without being asked.

5. **The line thumbnail is a reserved slot, not a fetch.** Neither the
   product-lookup response nor the sale-line response carries a photo, and
   resolving one per line would mean a per-product round trip on a screen whose
   entire premise is speed — on a privilege (`products` read) a cashier may not
   even hold. The layout reserves the slot and draws the existing placeholder;
   an mbe-api change to expose the photo is recorded as the dependency that
   lights it up.

The mock remains the visual reference, with the two caveats spec 020 already
established: its dark canvas palette is a presentation, not a requirement — the
screen uses the application theme and the design tokens spec 022 shipped — and
its step *order* is superseded by spec 020's decision 3. Venta → Cobro →
Entrega stands.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - See the register's sales and pick one up (Priority: P1)

A cashier opens the point of sale and sees the sales rung up on their register
today: reference, time, customer, status, total and outstanding balance, newest
first. They can narrow by date range, by status, or by searching. A sale that is
still open offers an edit action; pressing it reopens that sale at the step its
own state implies — still capturing, still owing money, or still owing a
delivery. A sale that is finished or cancelled shows the same information with
no edit action. A prominent action starts a new sale.

**Why this priority**: It is the missing half of the feature spec 020 shipped —
the cashier's own record of what they sold — and it is what makes every other
story in this feature reachable. It stands alone: even with the workspace
untouched, a list that reopens sales at the right step is immediately useful.

**Independent Test**: Ring up two sales on a register, leave one unconfirmed,
open the point of sale, and confirm both appear with the correct status; the
unconfirmed one reopens on Venta and the finished one offers no edit.

**Acceptance Scenarios**:

1. **Given** a register with sales rung up today, **When** the cashier opens
   the point of sale, **Then** those sales are listed newest first with
   reference, date and time, customer, status, total and balance, and the list
   is scoped to that register.
2. **Given** the list is showing today, **When** the cashier widens the date
   range to cover an earlier day, **Then** the register's sales from that day
   are included, paged.
3. **Given** a sale still being captured, **When** the cashier presses its edit
   action, **Then** the sale workspace opens on the Venta step with that sale's
   customer, mode and lines loaded.
4. **Given** a confirmed sale that still owes money, **When** the cashier
   presses its edit action, **Then** the workspace opens on the Cobro step.
5. **Given** a paid delivery sale whose destinations are not fully assigned,
   **When** the cashier presses its edit action, **Then** the workspace opens on
   the Entrega step.
6. **Given** a paid counter sale or a cancelled sale, **When** the cashier
   looks at its row, **Then** the row shows its information and offers no edit
   action.
6a. **Given** a finished sale, **When** the cashier clicks its row anywhere
   outside the edit action, **Then** the sale opens read-only — every value
   legible, every control inert — so a stray click can never start an edit.
7. **Given** the cashier is on the list, **When** they press the new-sale
   action, **Then** the workspace opens on a fresh sale for their register.
8. **Given** the cashier reopened a sale and returns to the list, **When** the
   list renders, **Then** it reflects what changed while they were away —
   including a sale that is no longer open.
9. **Given** a register with no sales in the selected range, **When** the list
   renders, **Then** it says so and still offers the new-sale action.
10. **Given** the sales cannot be read, **When** the list renders, **Then** the
    failure is reported and can be retried without leaving the screen.

---

### User Story 2 - Work the sale on the whole screen (Priority: P1)

A cashier opening or reopening a sale gets the entire window for it: the
navigation rail and drawer step aside, a Back affordance in the app bar returns
them to the list, and the sale's reference and the step indicator sit in that
same bar rather than costing a band of their own. The lines fill everything
between the search field and the footer — no centered column, no bounded
content width, no empty band above the totals. On a phone the surface keeps the
stacked, scroll-as-one behaviour it already has.

**Why this priority**: This is the complaint with the most screen behind it —
the shipped screen wastes roughly half of a desktop display — and it is what the
mock's density depends on. It is independently valuable: the capture polish in
US3–US6 improves what is inside the workspace, but the workspace being
full-width is felt without any of it.

**Independent Test**: Open a sale with several lines on a 1440×900 display and
confirm that no rail is present, that the Back affordance returns to the list,
and that the lines region extends to the footer with no empty band.

**Acceptance Scenarios**:

1. **Given** the cashier opens a sale from the list, **When** the workspace
   renders, **Then** no navigation rail or drawer is shown and the app bar
   carries a Back affordance that returns to the list.
2. **Given** the workspace is open on a wide display, **When** it renders,
   **Then** the content spans the full width — it is neither centered nor
   bounded by a maximum content width.
3. **Given** a sale with fewer lines than fit, **When** the workspace renders,
   **Then** the lines region occupies all the space between the search field and
   the footer, and the footer stays at the bottom edge with no empty band
   between them.
4. **Given** a sale with more lines than fit, **When** the workspace renders,
   **Then** the lines scroll while the header, the search field and the footer
   stay put.
5. **Given** the workspace is open, **When** it renders, **Then** the sale's
   reference (and its folio once assigned) and the step indicator are in the app
   bar area, not in a separate band below it.
6. **Given** a sale with no lines on it, **When** the cashier presses Back,
   **Then** the empty draft is abandoned rather than left to accumulate in the
   register's list, exactly as leaving an empty sale already behaves.
7. **Given** a link to a sale that does not exist, is cancelled, or belongs to
   another register, **When** the workspace opens, **Then** it explains why the
   sale cannot be worked on and offers a way back to the list, and no new sale
   is created.
8. **Given** a cashier with no open cash session, **When** they open the
   workspace by any route, **Then** the existing shift gate is shown and no sale
   is opened.
9. **Given** a phone-width display, **When** the workspace renders, **Then**
   the capture surface keeps its stacked, single-scroll behaviour and the
   totals and primary action stay pinned.

---

### User Story 3 - Identify the customer without leaving the sale (Priority: P2)

By default the customer band reports who the sale is for and what that means:
name, credit line, price list and outstanding balance, read as information
rather than as form fields. Two actions sit at its end — one to search for a
different customer, one to register a new one. Pressing search replaces the
reported facts, in place and with a visible transition, with the customer
picker; while the lookup or the attach is in flight the control says so, and
when it settles the band reports the new customer. The fulfilment mode sits
beside this band rather than beneath it, and the payment terms are chosen from a
dropdown where the credit line is reported.

**Why this priority**: It is the most-used part of the capture surface after the
product field and the part the mock differs from most, but the sale can be
captured without it — the walk-in customer is preselected.

**Independent Test**: Open a sale, confirm the preselected customer's name and
facts are visible, search and attach a different customer, and confirm the band
returns to reporting facts — with the new name — and that the terms dropdown
reflects the sale rather than changing it.

**Acceptance Scenarios**:

1. **Given** a sale on the walk-in customer, **When** the capture step renders,
   **Then** the customer's name, credit line, price list and balance are
   reported, and the customer's name is visible without opening anything.
2. **Given** the customer band is reporting facts, **When** the cashier presses
   the search action, **Then** the facts are replaced in place by the customer
   picker with a visible transition, and the picker takes focus.
3. **Given** the picker is open, **When** the cashier types, **Then** progress
   is shown while candidates are being fetched.
4. **Given** the picker is open, **When** the cashier picks a customer, **Then**
   progress is shown while the sale is updated, and on success the band returns
   to reporting facts for the new customer with every line re-priced as the
   server returned them.
5. **Given** the picker is open, **When** the cashier dismisses it without
   picking, **Then** the band returns to reporting the current customer and
   nothing about the sale changes.
6. **Given** a customer that has a credit line, **When** the terms dropdown
   renders, **Then** it shows the terms the sale currently carries and offers
   both immediate and credit.
7. **Given** a customer with no credit line, **When** the terms dropdown
   renders, **Then** credit is not selectable and the absence of a credit line
   is stated.
8. **Given** a customer with a credit line is attached to the sale, **When**
   the attach completes, **Then** the sale's payment terms are whatever the
   server reports and no additional update is sent on the screen's own
   initiative.
9. **Given** a display wide enough for both, **When** the capture step renders,
   **Then** the fulfilment mode control sits beside the customer band on the
   same row; **and** on narrower displays it sits below it.
10. **Given** any form factor, **When** the customer band renders, **Then** it
    spans the width available to it — no nested padding narrows it against the
    surrounding content.

---

### User Story 4 - Find a product while typing (Priority: P2)

A cashier who does not have a barcode to scan types part of a code, name, brand
or SKU and sees matching products appear as they type, without pressing anything.
A cashier holding a scanner keeps the behaviour they have: the scanner types the
code, sends Enter, and a single exact match becomes a line with no further
interaction.

**Why this priority**: It removes a keystroke from the second most frequent
action on the screen and brings the field in line with every other picker in the
product. It is independent of everything else in this feature.

**Independent Test**: Type three characters of a product name and confirm
candidates appear without pressing Enter; then simulate a scan (type a full code
followed by Enter) and confirm the line is added directly.

**Acceptance Scenarios**:

1. **Given** the product field has focus, **When** the cashier types enough
   characters to search, **Then** matching products are offered shortly after
   they stop typing, without Enter being pressed.
2. **Given** the cashier keeps typing, **When** a previous lookup is still in
   flight, **Then** only the result for what is currently typed is offered.
3. **Given** candidates are being fetched, **When** the cashier looks at the
   field, **Then** it shows that a search is in progress.
4. **Given** a scanned code that matches exactly one product, **When** the
   scanner sends Enter, **Then** that product is added as a line with no further
   interaction and the field clears and keeps focus.
5. **Given** a search that matches nothing, **When** it settles, **Then** the
   field says so rather than offering an empty list.
6. **Given** candidates are being offered, **When** the cashier dismisses them,
   **Then** they close and the typed text is left alone.

---

### User Story 5 - Read a sale line at a glance (Priority: P3)

Each line reads as one row: a thumbnail, the product's name with its code
beneath, the warehouse it comes from with its availability, a quantity stepper,
the unit, price, discount, tax, the line total, and a way to remove it — each
field only as wide as it needs to be. A tablet in landscape is wide enough for
that one row and must use it. Where the display is genuinely too narrow, the
line wraps to two rows instead of squeezing; on a phone it keeps the stacked
card it already has. A stock shortfall still reports itself under the line
without blocking anything.

**Why this priority**: It is the density the mock is really about — eight lines
on screen instead of three — but it is cosmetic: every field it rearranges is
already editable and correct.

**Independent Test**: Add four products to a sale on a wide display and confirm
each renders as a single row with proportionate fields and a legible name/code
pair; narrow the window and confirm the fallback to two rows, then to the card.

**Acceptance Scenarios**:

1. **Given** a wide display, **When** a line renders, **Then** it occupies a
   single row containing the thumbnail slot, product name and code, warehouse
   with availability, quantity stepper, unit, price, discount, tax, line total
   and remove action.
2. **Given** a line renders, **When** the cashier reads it, **Then** the product
   name is the prominent element and the code is a secondary line beneath it —
   not a single run-together string.
3. **Given** a line renders, **When** the fields are compared, **Then** each is
   sized for the value it holds: the discount and tax fields are narrow, and the
   product area takes the space that is left.
4. **Given** a tablet held in landscape, **When** a line renders, **Then** it
   occupies a single row — the two-row fallback is not used at tablet-landscape
   width.
5. **Given** the display is narrower than the single-row layout supports,
   **When** a line renders, **Then** it lays out over two rows with nothing
   clipped or overflowing.
6. **Given** a phone-width display, **When** a line renders, **Then** the
   existing stacked card is used and every field remains editable.
7. **Given** a line whose product has no photo available, **When** it renders,
   **Then** the thumbnail slot shows the product placeholder at the same size,
   so rows do not differ in height.
8. **Given** a line whose chosen warehouse cannot cover the quantity, **When**
   it renders, **Then** the shortfall and its adjust action appear beneath the
   line without blocking capture.
9. **Given** a sale that can no longer be edited, **When** its lines render,
   **Then** every control is inert while the values stay legible.

---

### User Story 6 - Read the sale's money in one place (Priority: P3)

The footer reports the sale as the mock does: item and unit counts, subtotal,
discounts and tax as labelled figures, the grand total set apart and
right-aligned, and the action that moves the sale forward on the same band —
not stacked beneath it.

**Why this priority**: It is the last piece of the mock's frame `2a`, it
reclaims the vertical space the current two-band arrangement spends, and it
depends on nothing else here.

**Independent Test**: Open a sale with a discounted line and confirm every
figure is present and labelled, the total is the visually dominant figure, and
the primary action sits on the same band.

**Acceptance Scenarios**:

1. **Given** a sale with lines, **When** the footer renders, **Then** the line
   and unit counts, subtotal, discounts (when any) and tax are shown as
   label-and-figure pairs.
2. **Given** a sale with lines, **When** the footer renders, **Then** the grand
   total is the most prominent figure and is right-aligned, with its currency
   stated.
3. **Given** a sale with lines, **When** the footer renders, **Then** the action
   that advances the sale is on the same band as the figures.
4. **Given** a sale with no lines, **When** the footer renders, **Then** the
   advancing action is present but not usable, and the figures read as zero.
5. **Given** any supported width, **When** the footer renders, **Then** it stays
   visible without scrolling and nothing in it is clipped.

---

### Edge Cases

- A cashier whose account has no point of sale configured opens the list: it
  explains that a register is needed rather than showing an empty table or
  every sale in the business.
- The date range is set to a span that returns thousands of sales: paging keeps
  the screen responsive and the count is reported honestly.
- A sale is finished by another till between the list rendering and the cashier
  pressing edit: opening it lands on the step its *current* state implies, not
  the one the stale row implied.
- A sale is deep-linked from a browser history entry or a bookmark after being
  cancelled: the workspace explains and offers the list, and does not open a
  replacement sale.
- The cashier presses Back mid-mutation (a line being priced, a customer being
  attached): the in-flight write is either completed or has no effect, and the
  list does not show a half-edited sale.
- The shift is closed while a sale is open in the workspace: the existing
  session gate governs; nothing about this feature bypasses it.
- The customer picker is open when a line mutation completes and replaces the
  held sale: the picker keeps its typed text and focus rather than being rebuilt
  from underneath the cashier.
- A scanner sends Enter while a search-as-you-type lookup for a shorter prefix
  is still in flight: the scan's own result wins and no unintended product is
  added.
- A product with no unit on file, no photo, or an empty name renders without a
  gap where the missing value would be.
- A window resized across the one-row/two-row threshold while a line is being
  edited: the field being typed into keeps its text and focus.
- A sale whose customer record cannot be read: the band still reports the name
  the sale carries and the missing facts leave a blank, not an error, exactly as
  it behaves today.
- Both locales: every label introduced by this feature exists in each, including
  the empty-list, blocked-sale and no-credit-line messages.

## Requirements *(mandatory)*

### Functional Requirements

**The sales list**

- **FR-001**: The point-of-sale navigation destination MUST open a list of
  sales, replacing the capture surface as what that destination renders.
- **FR-002**: The list MUST show, per sale: its reference and its folio once
  assigned, its date and time, its customer, its status, its total and its
  outstanding balance.
- **FR-003**: The list MUST be scoped to the signed-in cashier's own point of
  sale and MUST default to the current trading day.
- **FR-004**: The list MUST offer a date-range filter, a status filter and a
  free-text search, and MUST page results rather than loading a whole history.
- **FR-005**: The list MUST order sales newest first.
- **FR-006**: The list MUST offer an edit action only on sales that are still
  workable — being captured, confirmed with an outstanding balance, or paid with
  an unfinished delivery distribution — and MUST NOT offer it on finished or
  cancelled sales.
- **FR-006a**: Clicking a row anywhere outside its edit action MUST open that
  sale read-only, never an editable form — the safe-click rule every list screen
  in this product follows. A finished sale is therefore readable, without a new
  screen being introduced for it.
- **FR-007**: Pressing a sale's edit action MUST open the sale workspace at the
  step that sale's own status and delivery destination imply, using the same
  resolution the register's open-sales selector already uses.
- **FR-008**: The list MUST offer a primary action that starts a new sale and
  opens the workspace on it.
- **FR-009**: Returning to the list from the workspace MUST re-read the sales,
  so a sale that was finished or abandoned is no longer shown as open.
- **FR-010**: The list MUST report its empty, loading and failure states the way
  every other list screen in this product does, and a failure MUST be retryable
  without leaving the screen.
- **FR-011**: The list MUST remain inside the application shell, keeping the
  navigation rail, the drawer and the existing point-of-sale access gate.

**The sale workspace**

- **FR-012**: The sale workspace MUST render as a full-screen child of the list
  with its own app bar, and MUST NOT show the shell's navigation rail or
  drawer.
- **FR-013**: The workspace's app bar MUST carry a Back affordance that returns
  to the list.
- **FR-014**: The workspace's app bar area MUST carry the sale's reference, its
  folio once assigned and the step indicator, so no separate band below the app
  bar is spent on them.
- **FR-015**: The workspace MUST NOT centre or width-bound its content: every
  step MUST use the full width available.
- **FR-016**: The workspace MUST leave no unused vertical space — the lines
  region MUST absorb whatever the header and footer do not use, with the footer
  at the bottom edge.
- **FR-017**: All three steps — Venta, Cobro and Entrega — MUST render inside
  the workspace, in the order spec 020 fixed.
- **FR-018**: Leaving the workspace with a sale that has no lines MUST abandon
  that draft, as leaving an empty sale already does.
- **FR-019**: Opening the workspace for a sale that cannot be *reached* —
  unknown, cancelled, or belonging to another register — MUST explain why and
  offer a way back to the list, and MUST NOT open a sale in its place. A sale
  that is merely **finished** is not in this category: it opens read-only
  (FR-006a).
- **FR-020**: The cash-session gate MUST govern the workspace on every entry
  path, including a direct link.
- **FR-021**: At phone widths the workspace MUST keep the existing stacked,
  single-scroll capture behaviour with the totals and primary action pinned.

**The customer band**

- **FR-022**: The customer band MUST, by default, report the customer's name,
  credit line, price list and outstanding balance as information rather than as
  editable fields.
- **FR-023**: The customer band MUST always show the resolved customer name,
  including while a customer change is in flight.
- **FR-024**: The customer band MUST offer a search action and a create action,
  the latter only to a cashier permitted to create customers.
- **FR-025**: Pressing search MUST replace the reported facts, in place, with
  the customer picker, using a visible transition, and MUST give the picker
  focus.
- **FR-026**: Dismissing the picker without choosing MUST restore the reported
  facts and change nothing about the sale.
- **FR-027**: The band MUST show progress while candidates are being fetched
  and while a chosen customer is being attached.
- **FR-028**: The segmented immediate/credit control MUST be replaced by a
  payment-terms dropdown presented where the credit line is reported.
- **FR-029**: The terms dropdown MUST show the terms the sale currently carries,
  MUST offer credit only when the customer has a credit line, and MUST state the
  absence of a credit line when there is none.
- **FR-030**: The screen MUST NOT change a sale's payment terms other than in
  response to the cashier choosing them.
- **FR-031**: The fulfilment mode control MUST sit beside the customer band
  where the width allows and below it where it does not; its existing delivery
  permission and delivery-address rules are unchanged.
- **FR-032**: The customer band MUST span the width available to it, with its
  insets taken from the design system's spacing scale and no nested padding
  narrowing it against surrounding content.

**The product field**

- **FR-033**: The product field MUST offer matching products as the cashier
  types, debounced, without requiring Enter.
- **FR-034**: The product field MUST keep the scanner path intact: a typed code
  followed by Enter that matches exactly one product MUST add that line
  directly, then clear the field and keep focus.
- **FR-035**: Only the result for the currently typed text MUST be offered — a
  superseded lookup MUST NOT replace it.
- **FR-036**: The product field MUST show that a search is in progress, MUST
  state when a search matched nothing, and MUST allow the candidate list to be
  dismissed without clearing the typed text.

**The sale line**

- **FR-037**: A sale line MUST render as a single row at and above a defined
  width, MUST fall back to two rows below it, and MUST keep the existing stacked
  card at phone widths — with the same fields, in the same form, in all three
  (revised: this said "every field editable" before FR-038b and FR-038c made
  the price read-only and the tax a choice).
- **FR-037a**: The single-row width MUST be low enough that a tablet in
  landscape uses it — a line MUST render as one row at 1024 px of available
  width, and SHOULD do so as far down as the expanded tier's lower bound where
  the fields still fit legibly. The two-row fallback is for widths below that,
  not for tablets.
- **FR-038**: Each of a line's fields MUST be sized for the value it holds, with
  the product area taking the remaining space; no field may be wider than its
  content warrants.
- **FR-038a**: Every control on a line MUST share one height, and every value on
  it — the line total included — MUST sit on one baseline, so the line reads as a
  single band rather than as differently-sized boxes with text at differing
  heights. This holds across control *kinds*: a picker and a text field must
  agree, not merely each agree with its own sort. The product's unit of
  measurement MUST travel with the quantity field rather than occupying a column
  of its own.
- **FR-038b**: A line's tax rate MUST be **chosen**, not typed: the only rates
  offered are the product's own rate and none. A rate a line already carries
  MUST remain selectable so that rendering a line never rewrites it.
- **FR-038c**: A line's price MUST be shown but MUST NOT be editable on the
  capture surface. A price that needs adjusting is adjusted through the
  discount, which is what the discount is for — decided 2026-08-11, and this
  narrows spec 020 FR-023 ("every field the cashier can touch is editable in
  place") for the price alone. mbe-api still accepts a price on a line, so this
  is a deliberate policy in the UI, not a backend limitation.
- **FR-039**: A line MUST present the product name as its prominent element with
  the code as a secondary line beneath it.
- **FR-040**: A line MUST show the product's photo in a fixed thumbnail slot,
  and MUST render the shared placeholder in that same slot for a product with no
  photo, at a size that keeps every row the same height either way. (Satisfied
  by the reserved slot alone until mbe-api#157 shipped the photo on both
  payloads on 2026-08-11; satisfied fully since.)
- **FR-041**: A line MUST keep its warehouse choice and that warehouse's
  availability visible, and MUST keep the non-blocking shortfall warning and its
  adjust action.
- **FR-042**: A line belonging to a sale that can no longer be edited MUST
  render every value legibly with every control inert.

**The totals footer**

- **FR-043**: The footer MUST report the item and unit counts, subtotal,
  discounts when any, and tax as labelled figures.
- **FR-044**: The footer MUST set the grand total apart as its most prominent
  figure, right-aligned, with its currency stated.
- **FR-045**: The footer MUST carry the action that advances the sale on the
  same band as the figures, disabled until the sale can advance.
- **FR-046**: The footer MUST stay visible without scrolling at every supported
  width.
- **FR-047**: Every figure the footer reports MUST come from the sale as the
  server returned it, never recomputed on the screen.

**Across the feature**

- **FR-048**: Every colour, spacing, radius, elevation and text size introduced
  or changed by this feature MUST come from the design system's tokens and type
  roles through the active theme — no literal sizes or colours at the call site.
- **FR-049**: Every control introduced or changed MUST meet the design system's
  touch-target and contrast rules at each form factor, and MUST be reachable by
  keyboard as well as pointer.
- **FR-050**: Every label, message and empty state introduced by this feature
  MUST exist in both supported locales.
- **FR-051**: The shared components this feature restyles MUST have their visual
  reference images refreshed, so the change is reviewed rather than absorbed
  silently.

### Key Entities

- **Sale summary** — one row of the list: reference, folio, date and time,
  customer name, status, total, outstanding balance. Carries no lines; the
  workspace reads the full sale when it opens one.
- **Sales list query** — what the cashier has narrowed the list to: register
  (fixed to their own), date range (defaulting to the trading day), status,
  search text, and the page being viewed. Shareable through the address bar the
  way every other list screen's query is.
- **Workability verdict** — whether a sale can still be worked on and, if so,
  which step it reopens at. Derived from the sale's status and its delivery
  destination, not stored.
- **Payment terms choice** — the sale's current terms, plus whether credit is
  available at all (which follows from the customer's credit line).
- **Line layout tier** — which of the three line arrangements applies at the
  current width: one row, two rows, or the stacked card.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: From the point-of-sale destination, any sale the register rang up
  in the selected range is reachable in at most two interactions, and starting a
  new sale takes one.
- **SC-002**: Every workable sale reopens on the correct step — captured on
  Venta, owing money on Cobro, owing a delivery on Entrega — in 100% of cases
  across those three states.
- **SC-003**: On a 1440×900 display, a sale with nine lines shows at least eight
  of them without scrolling, against three today.
- **SC-004**: In the workspace, the space between the product field and the
  footer is occupied by the lines region at every supported width — zero
  unused vertical band, at any line count.
- **SC-005**: In the workspace, content spans the full window width at 1280 px,
  1440 px and 1920 px — zero centred or width-bounded regions.
- **SC-006**: Candidate products appear within 500 ms of the cashier's last
  keystroke, with no Enter pressed.
- **SC-007**: A scanned code with exactly one match still adds its line with
  zero extra interactions — unchanged from today's behaviour.
- **SC-008**: A sale line renders without clipping or horizontal overflow at
  every width from the phone breakpoint to 1920 px, using one row, two rows or
  the card as defined.
- **SC-008a**: A sale line renders as a single row at 1024 px of available width
  — a tablet in landscape — with every field legible and nothing clipped.
- **SC-009**: The customer's name is visible in 100% of the band's states —
  reporting facts, picker open, and mid-attach.
- **SC-010**: Attaching a customer that has a credit line results in zero
  payment-terms updates that the cashier did not initiate.
- **SC-011**: Zero literal colour, spacing or font-size values are introduced in
  the changed components; every one resolves through the theme.
- **SC-012**: Zero labels introduced by this feature are missing from either
  locale.
- **SC-013**: A cashier can complete a counter sale end to end — list, new sale,
  two lines, payment, finish, back to list — with the same or fewer interactions
  than before this feature.

## Assumptions

- **Sales made at the point of sale are identified by their register.** No
  origin flag distinguishes a POS sale from one entered elsewhere; the sale
  carries the point of sale it was opened for, and the list filters on it. For a
  register used only by this screen those two sets are the same, which is what
  the request asked for as its first preference.
- **The workspace keeps a quick switch between open sales.** The register's
  open-sales selector shipped by spec 020 is retained inside the workspace app
  bar, as the mock's frame `2a` shows it — the list is how a cashier *finds* a
  sale, but moving between two sales at a busy counter should not require
  leaving the workspace.
- **No *new* read-only screen is added.** A finished sale opens into the
  workspace's existing read-only rendering — the sale is already displayed with
  every control inert once it is past draft — so FR-006a's safe-click rule is
  satisfied without a second screen. Amended during planning: the spec first put
  read-only viewing out of scope, which would have left the list with no row
  click at all, against the standing rule that a stray click must open a
  read-only view rather than an editable form.
- **The one-row line threshold is chosen during design, but its ceiling is
  fixed.** The exact number follows from measuring the fields against the type
  scale; what is settled is that it must be at or below 1024 px so a tablet in
  landscape gets the single row (FR-037a). The workspace hiding the navigation
  rail is what makes that width available in the first place.
- **The list reuses this product's list-screen building blocks**, so its filter
  behaviour, its URL-shareable query, its paging and its empty and error states
  follow the conventions already established rather than being specified again
  here.
- **The customer facts the band reports are the ones already available** — name,
  credit line, price list, and the balance summed from open orders — with the
  same degradation when a customer record cannot be read.

## Dependencies

- **Spec 020 (Point of Sale)** — the capture, payment and delivery steps, the
  live-recording rule, the step order, and the resume resolution this feature's
  list reuses. This feature revises 020's decision 2 for the workspace only, as
  stated in the Overview.
- **Spec 021 (Cash Sessions)** — the shift gate, unchanged and still governing
  every entry into the workspace.
- **Spec 022 (Design System Tokens)** — the spacing, shape, elevation, density
  and type-role tokens this feature's styling must resolve through, and the
  visual reference images FR-051 refreshes.
- **Spec 010 (Adaptive Navigation Layout)** — the shell, and the full-screen
  child-route pattern the workspace adopts.
- **mbe-api sales-order listing** — the register, status, date-range, search and
  paging filters the list needs already exist on the sales-order listing
  endpoint; no backend change is required for US1.
- **mbe-api product photo (new, blocking only the thumbnail image)** — the
  product-lookup and sale-line payloads carry no photo URL. An mbe-api change to
  expose it is a prerequisite for showing a real thumbnail; FR-040 ships the
  reserved slot and the placeholder in the meantime.

## Out of Scope

- Changing the step order. Venta → Cobro → Entrega stands (spec 020 decision 3).
- The payment step's internal layout (mock frame `2c`), including the touch
  keypad and the applied-payments panel.
- The delivery step's internal layout (mock frame `2b`).
- The inline customer-create dialog's layout (mock frame `2d`); it is reached
  from the customer band unchanged.
- Fetching product photos per line, or any other client-side workaround for the
  missing photo field.
- Facility-wide or supervisor-oriented sales browsing, and any filter that
  crosses registers.
- Reprinting, invoicing, cancelling or refunding a sale from the list.
- Any change to mbe-api itself.

## Verbatim Constraints

- Routes: `/sales/pos` (the sales list), `/sales/pos/new` and
  `/sales/pos/:saleId` (the sale workspace).
- The listing filter that scopes the list to the cashier's register:
  `point_sale`.
- The backend field the thumbnail waits on: `photo`, on the product-lookup and
  sale-line payloads.
- The visual reference: `artifacts/point_of_sale/POS_Adaptativo.dc.html`,
  frames `2a` (expanded capture) and `2e` (compact).
- The token access rule this feature's styling follows:
  `Theme.of(context).spacing` / `.shapes` / `.typeRoles`.
- The screens and widgets in scope:
  `lib/features/sales/presentation/pos_screen.dart`,
  `capture/capture_step.dart`, `capture/customer_bar.dart`,
  `capture/fulfillment_mode_selector.dart`, `capture/product_search_field.dart`,
  `capture/sale_line_row.dart`, `capture/sale_line_card.dart`,
  `capture/sale_totals_bar.dart`, `pos_header_band.dart`,
  `open_sales_selector.dart`, `lib/app/router/app_router.dart`.
