# Feature Specification: Point of Sale — Delivery Step Look & Feel

**Feature Branch**: `026-pos-delivery-ux`

**Created**: 2026-08-15

**Status**: Draft — unblocked; [mbe-api#163](https://github.com/mictlanix/mbe-api/issues/163), [#165](https://github.com/mictlanix/mbe-api/issues/165) and [#171](https://github.com/mictlanix/mbe-api/pull/171) all landed 2026-08-15

**Input**: User description: "Improve the POS delivery step screen (`lib/features/sales/presentation/delivery/delivery_step.dart` and its widgets `destination_card.dart`, `destination_editor.dart`, `line_distribution_panel.dart`) and make its design more like `artifacts/point_of_sale/POS_Adaptativo.dc.html`. The screen currently works fine; we are aiming to improve its look & feel. From the mockup, ignore the order of the screens — delivery figures there as the second step ("Paso 2 de 3"), but during development we moved it to the last step. Keep the delivery destinations grouped just as shown on the mock, and also keep the items distribution summary panel."

## Clarifications

### Session 2026-08-15

- Q: When should the "Recoge en tienda" counter row appear in the destination list? → A: On mixed sales only, always as the first destination in the list, with addressed destinations added after it. **Widened during implementation** — it also shows whenever a counter-pickup destination actually exists, whatever the mode says, or a resumed sale hides units it is still counting (FR-010).
- Q: How far should the quantity control follow the mock's `−`/`+` pill? → A: All the way — a working stepper pill, not a restyled plain field.
- Q: Where should the new-destination composer open at wide widths? → A: As a side sheet over the distribution rail.
- Q: At what width should the step switch from one column to two regions? → A: The product's Large tier (1200 px), matching the payment step.
- Q: What should the side sheet capture? → A: The header only — address, contact, date and instructions. Every quantity is assigned afterwards, inside the destination's own card, as the mock draws it.
- Q: There is no endpoint to add a line to an existing delivery order, which the header-only flow requires. How should the feature handle it? → A: Block on mbe-api. The gap is filed as mbe-api#163 and recorded here as a blocking external dependency; no client-side workaround is to be built.
- Q: A mixed sale reopened after a restart could never be finished — its remainder blocked the close with no way out, because `resumeTargetFor` reconstructs only `delivery`/`counterPickup` and never `mixed`. How should the step recover? → A: The step asks. An explicit secondary "leave the rest at the counter" action appears beside the blocking notice and performs the sweep (FR-037a), and the counter row is now shown whenever a counter-pickup destination actually exists, not only when the mode says mixed (FR-010).
- Q: Every stepper press fired its own request and inerted the row for the round trip, so a burst of taps felt frozen. Should the writes be debounced? → A: Yes — coalesce a burst into one write of the final value (~400 ms), keep the controls live throughout, and flush anything pending before the card is disposed. FR-025 was rewritten from "disable the row in flight" to this.
- Q: `FulfillmentMode.mixed` is UI-only state, so a resumed sale cannot tell mixed from delivery. Should mbe-api persist the cashier's intent? → A: Filed as mbe-api#170. Declined at first — the intent gates one decision at one moment, and the step now asks — then **reconsidered and shipped as #171**: `sales_order.fulfillment_intent`, a nullable field on a scale unified with `delivery_order.fulfillment_type`. The client records it alongside `ship_to` and trusts it on resume, falling back to the address heuristic only when it is `null`. The step's "leave the rest at the counter" action (FR-037a) stays regardless: it is what recovers a sale whose intent was never recorded.
- Q: #163 shipped, but `DeliveryOrderCreate.lines` keeps `min_length=1`, so a destination still cannot be created empty. How should the header-only sheet get its destination? → A: File the follow-up (mbe-api#165) and keep blocking. Deferring creation to the first assignment was rejected: a card with no server record behind it is a state the whole step would have to reason about. **Resolved 2026-08-15** — #165 landed; the sheet creates with an explicit `lines: []`.

## Overview

Spec 020 built the Entrega step and it works: a cashier can record a
destination against a customer's own address and contact, split each sale line
across destinations, watch the remainder fall to zero and finish the sale. What
it does not do is *look* like the screen it was drawn from — or work the way
that screen works. Spec 023 took the capture step to its own reference frame and
listed "the delivery step's internal layout (mock frame `2b`)" in its Out of
Scope; spec 025 did the payment step and listed the delivery step's layout in
its Out of Scope too. This feature is the last of those three deferred halves.

**Everything is one scrolling column.** Today the step is a single list: the
destination cards, then the distribution panel, then an "Agregar destino"
button, then the outstanding notice, then the finish button — and when the
editor opens, the distribution panel and the add button are replaced by the
editor, which itself ends with a second copy of the distribution panel. On a
1440-pixel display that column runs down the left of a mostly empty screen. The
mock spends the same screen as two regions: the destinations on the left and a
permanent distribution rail on the right, and needs no scrolling at all.

**Quantities are decided before the destination exists.** Today the composer
asks for the address, the contact, the date *and* every line's quantity in one
form, and submits them together. The mock does it the way the counter actually
works: name the destination first, then stand at its card and assign what goes
in it, line by line, watching the distribution move. A mistake today is not
editable at all — a recorded destination is read-only, so fixing one unit means
cancelling the destination and starting it again.

**A destination is a list tile, not a card the cashier can read at a glance.**
Today each destination is a `ListTile` with the address as its title and the
contact, date and counts stacked beneath. The mock gives each one an index badge
(`D1`, `D2`), one dense header — address, then recipient · phone · date, then
the line and unit counts set off by a divider — and, when expanded, the sale's
lines with the quantity this destination takes of each.

**What stays at the counter is invisible until it is too late.** In a mixed sale
the remainder goes to the counter on close (FR-036 of spec 020), but nothing on
the screen says so while the cashier is still assigning. The mock puts a
"Recoge en tienda" row at the top of the destination list, with its own line and
unit counts, so the counter is one of the destinations being read rather than a
consequence discovered at the end.

**The distribution is a wide table of four numbers per line.** Today each row
reads `Pedido: 10 · Asignado: 4 · En tienda: 6` in four equal columns. The mock
renders the same information as the product name, a row of small
per-destination chips (`D1 32`, `D2 0`, `Tienda 18`) and the ordered quantity on
the right — which answers "where is this line going" directly rather than making
the cashier subtract to find out.

**The finish action is at the bottom of a scroll**, below the outstanding
notice, below the editor, below however many destinations exist — far from the
figure that gates it. The mock pins the assigned-units total and the action that
depends on it together at the rail's foot, exactly as the payment step now does
with the balance and its exit.

Five decisions shape everything below.

1. **The wide layout is two regions.** The destinations on the left — the
   counter row, the destination cards and the add action — and a distribution
   rail on the right holding the per-line distribution, the assigned-units
   total, the gate line and the finish action. Below the Large tier the same
   content becomes one column with the total and the finish action pinned as a
   footer band, which is the shape the capture and payment steps already use.

2. **A destination is created from its header, then filled.** The add action
   opens a side sheet asking only where it goes, who receives it, when, and any
   instructions. Saving it produces a new card, expanded and empty, and the
   quantities are assigned there.

3. **Assignment happens inside the destination's own card**, on the mock's
   stepper pill: every sale line is listed, each with what this destination
   takes of it, adjustable up and down and typable, clamped to what the sale
   still owes. A line taken to zero leaves the destination.

4. **The distribution panel stays, and becomes the rail.** It is the running
   answer to "is this sale fully distributed yet", it is never replaced by
   another region, and it moves as each quantity is assigned.

5. **Destinations are identified by badge everywhere they are named**, so a
   cashier reading `D2 242` in the rail knows which card to open without
   counting — and the gate and the action that depends on it are read together
   at the rail's foot.

The step order is unchanged: Entrega is the last step and finishing it completes
the sale, whatever the mock's "Paso 2 de 3" says. The distribution arithmetic,
the completion gate and the counter sweep are untouched.

**Every API gap this design needed is closed.**
[mbe-api#163](https://github.com/mictlanix/mbe-api/issues/163) added a line to a
destination that already exists, and
[#165](https://github.com/mictlanix/mbe-api/issues/165) made an explicit
`lines: []` create a destination carrying nothing — the two things decisions 2
and 3 required. [#171](https://github.com/mictlanix/mbe-api/pull/171) then added
`sales_order.fulfillment_intent`, so the cashier's choice of pickup, delivery or
mixed is recorded rather than smuggled into `ship_to`, and a resumed sale knows
which it was. All three landed on 2026-08-15 and the client is regenerated, so
every requirement below is buildable as written.

#171 also **renumbered** `delivery_order.fulfillment_type` — `0`/`1` used to
mean delivery/pickup and now mean the reverse, on one scale shared with the new
intent field — which is a silent-corruption hazard for any client that keeps
the old mapping ([research R15](./research.md)).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Read every destination and what is left, without scrolling (Priority: P1)

A cashier on the counter workstation reaches the Entrega step of a mixed sale
with two addressed destinations. The whole step is on screen at once: the
counter row, both destination cards, the add action, and — on the right — every
sale line with where its units are going, the assigned-units total, and the
finish action. Nothing scrolled.

**Why this priority**: It is the complaint. Everything else in this feature is
detail work inside the shape this story establishes.

**Independent Test**: Open the Entrega step on a two-destination sale at a
1440×900 window and read every destination, every line's distribution and the
finish action without a scroll gesture.

**Acceptance Scenarios**:

1. **Given** a mixed sale with two destinations at a 1440×900 window, **When**
   the Entrega step opens, **Then** the counter row, both destination cards, the
   add action, the per-line distribution, the assigned-units total and the
   finish action are all visible without scrolling.
2. **Given** that screen, **When** a quantity is assigned in a card, **Then** the
   rail's chips and total move with it, with no scrolling required to see either.
3. **Given** a sale with more destinations or more lines than a region can show,
   **When** the cashier looks at the step, **Then** the destination list and the
   distribution list scroll on their own, and the assigned-units total, the gate
   line and the finish action stay pinned.

---

### User Story 2 - Assign a destination's quantities in its own card (Priority: P1)

The cashier expands a destination and works down the sale's lines, taking each
one up or down on its stepper until that destination holds what it should. The
distribution rail moves as they go. Nothing lets them take more than the sale
still owes, and a line taken to zero drops off that destination.

**Why this priority**: This is the step's main act, and it is the part today's
screen cannot do at all — a recorded destination is read-only, so the only
correction available is cancelling it.

**Independent Test**: With one recorded destination, assign three lines to it
from its card, take one back down to zero, and confirm the rail and the
assigned-units total agree with the cards throughout.

**Acceptance Scenarios**:

1. **Given** an expanded destination card, **When** the cashier reads it,
   **Then** every sale line is listed with the quantity this destination takes
   of it, reading zero for a line it does not carry yet.
2. **Given** a line with units still unassigned, **When** the cashier raises its
   quantity, **Then** the card, the rail's chip for that line and the
   assigned-units total all move together.
3. **Given** a line already claiming everything the sale still owes, **When** the
   cashier tries to raise it further, **Then** the control refuses rather than
   sending a request that would be refused.
4. **Given** a quantity at zero, **When** the cashier tries to lower it further,
   **Then** the control refuses.
5. **Given** a line this destination carries, **When** its quantity is taken to
   zero, **Then** that line leaves the destination and its units return to the
   pool.
6. **Given** a line with units unassigned, **When** the cashier uses the
   assign-all affordance, **Then** that line takes everything the sale still
   owes for it.
7. **Given** the server refuses an adjustment, **When** the refusal arrives,
   **Then** it is reported on that line and the displayed quantity returns to
   the value the server still holds.

---

### User Story 3 - Know where every line is going and finish the sale (Priority: P1)

A cashier has assigned most of a sale but not all of it. They need to see which
lines are still short and by how much, and the finish action must become
available the moment nothing is outstanding. The per-line distribution, the
assigned-units total, the reason the finish action is disabled, and the action
itself are one block.

**Why this priority**: This is the step's purpose — the distribution's state and
the decision it drives, side by side.

**Independent Test**: With a part-assigned pure-delivery sale, read which lines
are short from one region, assign the remainder, and watch the finish action
become available in that same region.

**Acceptance Scenarios**:

1. **Given** a sale with several lines split across destinations, **When** the
   cashier reads the distribution, **Then** each line shows its product, the
   quantity each destination takes, whatever is still at the counter, and the
   quantity ordered.
2. **Given** a pure-delivery sale with an unassigned remainder, **When** the
   cashier looks at the finish action, **Then** it is disabled and a line
   directly above it names the lines still outstanding and their quantities —
   the same message as today, in its new position.
3. **Given** the remainder is assigned, **When** the gate is evaluated, **Then**
   the finish action becomes available and the outstanding line is no longer
   shown.
4. **Given** a mixed sale with a remainder, **When** the cashier looks at the
   step, **Then** the counter row states that remainder, the finish action is
   available, and nothing is marked as an error.

---

### User Story 4 - Add a destination from a side sheet (Priority: P2)

The cashier taps "Agregar destino". A side sheet opens over the rail asking only
where it goes, who receives it, when, and any instructions — no quantities. On
save it closes, and the new destination is a card in the list, expanded and
ready to be filled.

**Why this priority**: It is the entry point to US2, but it is a smaller surface
than the assignment it leads into.

**Independent Test**: Add a destination from the sheet and confirm the resulting
card is present, badged, expanded and holding nothing yet.

**Acceptance Scenarios**:

1. **Given** the destination list, **When** the add action is used at a wide
   width, **Then** a side sheet opens over the rail with the address, contact,
   date and instructions controls and no quantity control.
2. **Given** the sheet open, **When** the cashier reads the screen behind it,
   **Then** the destinations already recorded remain visible.
3. **Given** a completed sheet, **When** it is saved, **Then** it closes and the
   new destination appears as the last card in the list, expanded, with every
   line reading zero.
4. **Given** the server refuses the create, **When** the refusal arrives,
   **Then** the message is shown inside the sheet, the entered values are kept,
   and every already-recorded destination is untouched.
5. **Given** a destination that is no longer wanted, **When** it is removed,
   **Then** the same removal with its fixed reason happens as today and its
   quantities return to the pool.

---

### User Story 5 - Work the step on a phone (Priority: P3)

A cashier working from a handheld reaches the Entrega step. There is no room for
a rail, so the same pieces stack in one scrolling column in the mock's phone
order — the counter row, the destination cards, the add action, then the
distribution — with the assigned-units total, the gate line and the finish
action pinned to the bottom edge. The add sheet takes the whole width.

**Why this priority**: The phone tier already exists and must not regress; it is
not the primary counter surface.

**Independent Test**: Open the step at a phone width, add a destination, assign
two lines to it and finish the sale without losing sight of the total or the
finish action.

**Acceptance Scenarios**:

1. **Given** a window below the two-region threshold, **When** the step opens,
   **Then** the content is one scrolling column and the assigned-units total
   with the finish action is pinned to the bottom edge.
2. **Given** that column scrolled to its end, **When** the cashier reads the
   screen, **Then** nothing is clipped and no region overflows horizontally.
3. **Given** a phone width, **When** a destination card is expanded, **Then**
   each line's name and its stepper fit the width without horizontal scrolling.

---

### Edge Cases

- **A sale with no destinations yet.** The list shows its empty state; on a
  mixed sale the counter row is present and holds everything, since that is
  where the units would go.
- **A sale with every unit already assigned.** The add action is unavailable and
  says so; freeing units from an existing destination makes it available again.
- **A pure-delivery sale.** No counter row is shown while nothing has been swept
  to the counter; an unassigned remainder is an outstanding condition, not a
  destination. Once the cashier uses the sweep action (FR-037a), the resulting
  counter-pickup destination does show as the counter row.
- **A sale resumed with no recorded intent** — captured before mbe-api#171, or
  by a client that does not set it. The address heuristic decides, so a mixed
  sale reads as plain delivery and its remainder blocks the close until the
  cashier uses the sweep action. This is the case FR-037a exists for.
- **A mixed sale fully assigned to addresses.** The counter row remains, reading
  zero lines and zero units, and the finish action is available.
- **A resumed sale that already has a counter-pickup destination.** It renders
  as the same counter row, showing its recorded lines.
- **A destination whose address or contact could not be joined.** The card falls
  back to the same pending-address wording it uses today and still shows its
  badge, counts and lines.
- **A quantity entered by keyboard rather than stepper.** It is subject to the
  same clamping and the same refusal handling as the stepper.
- **A destination given a delivery date.** It saves like any other. The date is
  a calendar day as the cashier picked it, neither shifted by the local UTC
  offset nor able to fail the request before it is sent
  ([research R16](./research.md)).
- **A fractional unit** (a line sold by weight or length). The stepper's step
  does not force the quantity onto whole numbers, and a typed fraction survives.
- **Two cards expanded at once**, both showing the same sale line. Raising it in
  one lowers what the other may still take, and the other's ceiling follows.
- **A long address, a long recipient name or a long product name.** It wraps or
  ellipsizes inside its card or row without widening the layout.
- **Many destinations, or a sale with many lines.** Each region scrolls on its
  own; the pinned block never scrolls away.
- **A very large quantity.** No figure in a card, a chip, a stepper or the total
  is truncated or clipped at any supported width.
- **A window resized across the two-region threshold** while the add sheet is
  open. The entered address, contact, date and instructions survive the reflow.
- **A close already in flight.** Every control the step disables today stays
  disabled, and the finish action shows the same in-flight treatment.
- **The destination list fails to load.** The step reports it exactly as it does
  today, with the same retry affordance.

## Requirements *(mandatory)*

### Functional Requirements

**Scope fence**

- **FR-001**: The only behaviour this feature adds is assigning a destination's
  line quantities after that destination exists. The distribution arithmetic,
  the completion gate, the counter-pickup sweep on close, and the removal of a
  destination MUST behave exactly as they do today.
- **FR-002**: This feature MUST NOT change the step order: Entrega remains the
  last step, and the step's exit action MUST keep its current label and outcome.
- **FR-003**: Quantity assignment MUST go through the delivery order's own line
  endpoints — add, update and remove. A client-side substitute for a missing
  endpoint — cancelling and re-creating a destination to add a line, creating it
  with a placeholder line, or showing a destination that has no server record
  behind it — MUST NOT be built.

**The delivery surface**

- **FR-004**: At wide widths the step MUST render as two regions — a
  destinations region and a distribution rail — with the per-line distribution,
  the assigned-units total, the gate line and the finish action in the rail.
- **FR-005**: Below the two-region threshold the step MUST render as one column
  in the mock's phone order — counter row, destination cards, add action,
  distribution — with the assigned-units total, the gate line and the finish
  action pinned to the bottom edge rather than scrolling with the content.
- **FR-006**: The step MUST spend the full width and height it is given: no
  centred or width-bounded region, and no unused vertical band between the
  destinations region's content and the bottom edge.
- **FR-007**: In the two-region shape, the destination list and the distribution
  list MUST each scroll independently, and the assigned-units total, the gate
  line and the finish action MUST stay pinned.
- **FR-008**: A load failure MUST be reported by the step, a refused create by
  the add sheet, and a refused assignment on the line that caused it; each MUST
  stay dismissible or self-clearing exactly as its equivalent does today.

**The destination group**

- **FR-009**: The destinations MUST be grouped as the mock groups them: the
  counter row first, then one card per addressed destination in the order they
  were recorded, then the add action.
- **FR-010**: The counter row MUST be shown, always in first position, for a
  mixed sale and for any sale that already has a recorded counter-pickup
  destination. The second clause is not redundant: a sale captured before
  mbe-api#171, or by any client that does not record `fulfillment_intent`,
  resumes with a `null` intent and falls back to the address heuristic, which
  reads a swept sale as plain delivery — without this clause its counter units
  would count toward the total while being invisible on screen.
- **FR-011**: The counter row MUST state its line and unit counts and MUST offer
  no removal action.
- **FR-012**: Each addressed destination MUST carry a positional index badge
  (`D1`, `D2`, …) in its card header, and the same badge MUST identify that
  destination wherever else the step names it.
- **FR-013**: A collapsed destination card MUST show its badge, its address, its
  recipient and phone, its delivery date, and its line and unit counts on one
  header, with the counts visually set apart from the identity.
- **FR-014**: A destination card MUST be expandable and collapsible, and each
  card's expanded state MUST be independent of the others'.
- **FR-015**: The removal action MUST remain available on every addressed
  destination, with today's fixed removal reason and today's
  disabled-while-closing behaviour.
- **FR-016**: The add action MUST sit at the end of the destination list, styled
  as the mock's full-width dashed affordance, and MUST be unavailable while the
  add sheet is open, while a close is in flight, and when no line has anything
  left unassigned — in the last case it MUST state why, rather than making a
  request the server would refuse.
- **FR-017**: When no destinations exist, the destinations region MUST show its
  empty state.

**Assignment inside a card**

- **FR-018**: An expanded destination card MUST list every line of the sale,
  each with the quantity this destination takes of it, reading zero for a line
  it does not carry.
- **FR-019**: Each line's quantity MUST be presented as the mock's stepper pill —
  a decrement control, the figure, an increment control — with the product's
  name and what the sale still owes for that line beside it.
- **FR-020**: The figure MUST remain a real, focusable, typable field accepting
  decimal entry from a physical keyboard; the stepper and the field MUST be two
  paths to the same value, neither privileged.
- **FR-021**: The quantity MUST be clamped client-side to the range zero through
  what the sale still owes for that line plus what this destination already
  takes of it, so an over-claim is refused before a request is made.
- **FR-022**: Taking a line's quantity to zero MUST remove that line from the
  destination, and its units MUST return to the pool.
- **FR-023**: Each card MUST offer the mock's assign-all-remaining affordance,
  which sets a line to everything the sale still owes for it.
- **FR-024**: A refused assignment MUST be reported on the offending line, and
  the displayed quantity MUST return to the value the server still holds.
- **FR-025**: A line's controls MUST stay responsive while an assignment is in
  flight — a burst of steps MUST be coalesced into a single write of the final
  value rather than one round trip per press, and the row MUST show each step
  immediately. Two conflicting writes for the same line MUST NOT be in flight
  at once; a step that lands mid-flight is sent after the one before it
  settles. Whatever is still pending MUST be sent before the card goes away,
  so a step followed immediately by leaving the step is not silently lost.

**The add sheet**

- **FR-026**: The add action MUST open a side sheet over the rail at wide
  widths, and a full-width sheet below the two-region threshold; the recorded
  destinations MUST remain visible behind it at wide widths.
- **FR-027**: The sheet MUST capture the destination's header only — address,
  contact, date and instructions — and MUST NOT ask for any quantity.
- **FR-028**: The address MUST remain a linked record picked from the customer's
  own, never free text, exactly as today; the same holds for the contact.
- **FR-029**: Saving the sheet MUST close it and add the new destination as the
  last card in the list, expanded and ready to be assigned.
- **FR-030**: A refused create MUST keep the sheet open with what was entered
  and MUST leave every already-recorded destination untouched.

**The distribution rail**

- **FR-031**: The distribution MUST list every sale line with its product name,
  the quantity ordered, and the quantity each destination takes.
- **FR-032**: Each line's per-destination quantities MUST be presented as the
  mock's row of small chips, one per destination that takes any of it plus one
  for the counter when any remains there, each chip carrying the destination's
  badge and its quantity.
- **FR-033**: The rail MUST move as quantities are assigned in a card, without
  the cashier leaving the card or refreshing the step.
- **FR-034**: A line whose remainder is outstanding MUST be visually
  distinguished from one that is fully assigned, without relying on colour
  alone.
- **FR-035**: The rail MUST state how many lines it is showing and across how
  many destinations, as the mock's rail header does.
- **FR-036**: The rail MUST show the assigned-units total against the sale's own
  total units as one figure at its foot.
- **FR-037**: While the finish action is disabled because units are unassigned
  on a pure-delivery sale, the line naming the outstanding lines and their
  quantities MUST be shown directly above the action; it MUST NOT be shown when
  the action is available.
- **FR-037a**: While that line is shown, the step MUST offer an explicit,
  secondary action that sweeps the remainder to the counter and finishes — the
  cashier answering, for a sale whose recorded intent cannot answer it, the
  question the mode would otherwise settle. Since mbe-api#171 a sale captured
  with `fulfillment_intent` resumes as `mixed` and never reaches this state;
  the action remains for the sales that resume with a `null` intent, and for a
  cashier who changes their mind. It MUST NOT be the primary action, and MUST
  disappear the moment nothing is outstanding.
- **FR-038**: The finish action MUST sit directly beneath the assigned-units
  block and MUST be enabled by exactly the condition that governs it today,
  keeping today's in-flight treatment.

**Styling and parity**

- **FR-039**: Every colour, spacing, radius, elevation and type size introduced
  by this feature MUST resolve through the product's theme and design tokens; no
  literal value from the mock's palette may be hard-coded.
- **FR-040**: Every label this feature introduces MUST exist in both supported
  locales, including the destination badge's wording and the counter chip's.
- **FR-041**: Every control disabled while a close, a create or an assignment is
  in flight MUST remain disabled under the same conditions that govern its
  equivalent today.
- **FR-042**: The test keys of the controls that survive this feature MUST be
  preserved, so the existing widget tests keep addressing them.
- **FR-043**: Every affordance this feature introduces — expanding a card,
  stepping a quantity, assigning all of a line, opening and saving the sheet,
  removing a destination, finishing the sale — MUST be reachable by keyboard and
  MUST announce its purpose, value and state to a screen reader.

### Key Entities

- **Destination**: one place the goods go — an address, a recipient, a date and
  the lines it takes — or the counter, which has no address and cannot be
  removed. Its shape is unchanged; what changes is that its lines become
  editable after creation.
- **Line distribution**: for one sale line, the quantity ordered, the quantity
  each destination takes, and the remainder at the counter. Unchanged by this
  feature; the rail is a new rendering of it, and the draft-quantity concept it
  carries for the old composer is no longer needed.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: On a 1440×900 window, a mixed sale with two destinations and six
  lines shows the counter row, both destination cards, the add action, every
  line's distribution, the assigned-units total and the finish action with zero
  scrolling.
- **SC-002**: Correcting one line's quantity on a recorded destination takes at
  most two interactions and zero destinations cancelled — today it is impossible
  without cancelling and re-creating the destination.
- **SC-003**: A cashier can name which destination takes a given line's units
  without opening any card, at 100% of supported widths.
- **SC-004**: The quantities a single destination takes are readable and
  adjustable in one place — its own card — rather than derived by subtraction.
- **SC-005**: The assigned-units total, the reason the finish action is
  disabled, and the action itself are in one glance region at 100% of supported
  widths.
- **SC-006**: Zero over-claims reach the server from the stepper or the typed
  field — the client refuses them first — and any refusal that does arrive
  leaves the displayed quantity equal to the server's.
- **SC-007**: The step renders without clipping or horizontal overflow at every
  width from 320 px to 1920 px, at both text scales the product supports.
- **SC-008**: Zero literal colour, spacing or font-size values are introduced in
  the changed components; every one resolves through the theme.
- **SC-009**: Zero labels introduced by this feature are missing from either
  locale.
- **SC-010**: The step issues no request beyond the delivery order's own
  create, list, per-line add, per-line update, per-line remove and cancel
  calls — no polling, and no refetch of the whole list after an assignment.

## Assumptions

- **The two-region threshold is the product's Large tier (1200 px)**, the same
  threshold the payment step adopted in spec 025, so the two steps change shape
  together. If driving the real screen shows the rail earns its keep earlier,
  the threshold moves — nothing else in this spec depends on the number.
- **A newly created destination opens expanded**, since it holds nothing and the
  next thing the cashier must do is fill it. Destinations loaded with the step
  open collapsed. This is a starting state, not a rule the cashier cannot
  change.
- **The stepper's step is one unit.** For a line sold by weight or length this
  is a coarse but harmless default, because the field remains typable; the plan
  may refine it per unit of measure if driving the real screen shows the need.
- **Assignment persists per change** rather than being batched behind a save
  action — the card is not a form and has no submit. Rapid changes *are*
  coalesced: settled during implementation as a ~400 ms debounce per line
  (FR-025), after live driving showed one round trip per press felt frozen.
- **The counter row's figures come from the distribution the step already
  computes** for a mixed sale with no counter-pickup record yet; nothing is
  created early and no request is issued to draw it.
- **Destination badges are positional**, derived from the order the destinations
  are listed in, and are display-only — nothing is persisted and no identifier
  is invented.
- **The mock's palette, font sizes and pixel dimensions are a presentation.**
  They are read as proportions and hierarchy, not as values to reproduce.
- **A recorded `fulfillment_intent` is trusted over the address.** Since
  mbe-api#171 the sale carries the cashier's own answer; the `ship_to`
  heuristic is the fallback for a `null` intent, not a cross-check. The two can
  legitimately disagree — a mixed sale writes a customer address exactly as a
  pure-delivery one does — and the recorded answer is the one that means
  anything.
- **Nothing about the distribution arithmetic, the completion gate or the sweep
  changes.** They stay exactly where they are.

## Dependencies

- **[mbe-api#163](https://github.com/mictlanix/mbe-api/issues/163) — landed
  2026-08-15.** `POST /api/v1/delivery-orders/{delivery_order_id}/lines`, adding
  a line to a delivery order that already exists. The client is regenerated.
  This unblocks in-card assignment (FR-018 → FR-025) in full, including
  restoring a line dropped to zero.
- **[mbe-api#165](https://github.com/mictlanix/mbe-api/issues/165) — landed
  2026-08-15.** An explicit `lines: []` on create now makes a destination that
  carries nothing, distinct from omitting the field (which still claims
  everything the sale owes). This unblocks FR-027 and FR-029. One consequence
  reaches the requirements: creating an empty destination is refused on a sale
  with nothing left unassigned, which is why FR-016 disables the add action in
  that state.
- **[mbe-api#171](https://github.com/mictlanix/mbe-api/pull/171) — landed
  2026-08-15**, resolving [#170](https://github.com/mictlanix/mbe-api/issues/170).
  Adds `sales_order.fulfillment_intent` (nullable) and unifies the vocabulary
  onto one `FulfillmentType` — `PICKUP=0, DELIVERY=1, MIXED=2` — serving both
  that field and `delivery_order.fulfillment_type`. Two consequences reach this
  feature: the capture step records the intent alongside `ship_to` so a mixed
  sale survives a resume as itself, and the delivery order's wire numbers are
  **reversed from what the client previously sent**, which had to be remapped
  ([research R15](./research.md)).
- Spec 020 (Point of Sale) — the delivery step, its controller, its distribution
  arithmetic and its completion gate.
- Spec 022 (Design System Tokens) — the spacing, shape, elevation and type-role
  scales every value in this feature resolves through.
- Spec 023 (POS UX Improvements) — the full-width workspace this step renders
  inside, and the footer-band pattern the one-column shape reuses.
- Spec 025 (POS Payment Step Look & Feel) — the two-region-with-pinned-foot
  pattern this step mirrors, so the two steps read as one product.
- `artifacts/point_of_sale/POS_Adaptativo.dc.html` — the visual reference,
  frame `2b` (expanded) and the phone frame labelled "Paso 2 · entrega".

## Out of Scope

- The mock's per-line `swap_horiz` action, moving a whole line from one
  destination to another in one gesture.
- Editing a recorded destination's header — its address, recipient, date or
  instructions — after it is created. The endpoint exists and is implemented in
  the repository; wiring it up is its own change.
- The mock's shipping-cost line ("Costo de envío") and any notion of a delivery
  charge.
- The mock's "Descartar cambios" action beneath the primary one.
- The mock's header chips — folio, mixed-delivery summary, step pills and the
  assigned-units badge in the app bar — which belong to the workspace shell, not
  to this step.
- The mock's "Ver N líneas más" progressive-disclosure truncation inside a card
  or the rail.
- The mock's step order and its "Paso 2 de 3" labelling.
- The capture and payment steps' layouts, both already shipped.
- Any change to mbe-api made from this repository. The dependency above is
  filed as an issue and consumed once it ships upstream (constitution §III).

## Verbatim Constraints

- The visual reference: `artifacts/point_of_sale/POS_Adaptativo.dc.html`,
  frame `2b` and the phone frame labelled "Paso 2 · entrega (solo
  Domicilio/Mixta)".
- The screens and widgets in scope:
  `lib/features/sales/presentation/delivery/delivery_step.dart`,
  `delivery/destination_card.dart`, `delivery/destination_editor.dart`, and
  `delivery/line_distribution_panel.dart`.
- The gate that governs the finish action: `isDistributionComplete` in
  `lib/features/sales/domain/entities/line_distribution.dart`.
- The repository methods the assignment work uses:
  `DeliveryOrderRepository.updateLine` and `.removeLine`, plus the `addLine`
  method to be added over mbe-api#163's endpoint.
- The token access rule this feature's styling follows:
  `Theme.of(context).spacing` / `.shapes` / `.typeRoles` / `.elevations`.
- The two-region threshold: `LayoutBreakpoints.large`.
- The test keys that must keep working: `delivery_add_destination_button`,
  `delivery_close_button`, `delivery_outstanding_notice`, `destination_card_*`,
  `destination_remove_*`, `destination_editor`, `destination_editor_error`,
  `destination_address_button`, `destination_contact_button`,
  `destination_date_button`, `destination_comment_field`,
  `destination_save_button`, `line_distribution_panel`, `distribution_row_*`.
  `destination_quantity_*` and `destination_claim_all_*` keep their names but
  move from the composer into the destination card, since that is where the
  controls they address now live.
