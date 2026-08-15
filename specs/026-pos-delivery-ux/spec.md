# Feature Specification: Point of Sale — Delivery Step Look & Feel

**Feature Branch**: `026-pos-delivery-ux`

**Created**: 2026-08-15

**Status**: Draft

**Input**: User description: "Improve the POS delivery step screen (`lib/features/sales/presentation/delivery/delivery_step.dart` and its widgets `destination_card.dart`, `destination_editor.dart`, `line_distribution_panel.dart`) and make its design more like `artifacts/point_of_sale/POS_Adaptativo.dc.html`. The screen currently works fine; we are aiming to improve its look & feel — visual and layout only, no new behaviour or server calls. From the mockup, ignore the order of the screens — delivery figures there as the second step ("Paso 2 de 3"), but during development we moved it to the last step. Keep the delivery destinations grouped just as shown on the mock (a counter-pickup row plus one collapsible card per destination, with the per-line quantities inside the expanded card). Also keep the items distribution summary panel (the mock's right-hand "Distribución por línea" rail)."

## Overview

Spec 020 built the Entrega step and it works: a cashier can record a
destination against a customer's own address and contact, split each sale line
across destinations, watch the remainder fall to zero and finish the sale. What
it does not do is *look* like the screen it was drawn from. Spec 023 took the
capture step to its own reference frame and listed "the delivery step's internal
layout (mock frame `2b`)" in its Out of Scope; spec 025 did the payment step and
listed "the delivery step's layout" in its Out of Scope too. This feature is the
last of those three deferred halves.

**Everything is one scrolling column.** Today the step is a single list: the
destination cards, then the distribution panel, then an "Agregar destino"
button, then the outstanding notice, then the finish button — and when the
editor opens, the distribution panel and the add button are replaced by the
editor, which itself ends with a second copy of the distribution panel. On a
1440-pixel display that column runs down the left of a mostly empty screen. The
mock spends the same screen as two regions: the destinations on the left and a
permanent distribution rail on the right, and needs no scrolling at all.

**A destination is a list tile, not a card the cashier can read at a glance.**
Today each destination is a `ListTile` with the address as its title, the
contact and date stacked in the subtitle, and a counts line under those. The
mock gives each destination an index badge (`D1`, `D2`), one dense header line —
address, then recipient · phone · date, then the line and unit counts set off by
a divider — and, when expanded, the lines that destination actually takes. That
last part matters: today the quantities a destination holds are visible only
indirectly, by reading the distribution panel's arithmetic backwards.

**What stays at the counter is invisible until it is too late.** In a mixed
sale the remainder goes to the counter on close (FR-036), but nothing on the
screen says so while the cashier is still assigning. The mock puts a
"Recoge en tienda" row at the top of the destination list, with its own line and
unit counts, so the counter is one of the destinations being read rather than a
consequence discovered at the end.

**The distribution is a wide table of four numbers per line.** Today each row
reads `Pedido: 10 · Asignado: 4 · En tienda: 6` in four equal columns. The mock
renders the same information as the product name, a row of small per-destination
chips (`D1 32`, `D2 0`, `Tienda 18`) and the ordered quantity on the right —
which answers "where is this line going" directly rather than making the cashier
subtract to find out.

**The finish action is at the bottom of a scroll.** It sits below the
outstanding notice, below the editor, below however many destinations exist,
far from the figure that gates it. The mock pins the assigned-units total and
the action that depends on it together at the rail's foot, exactly as the
payment step now does with the balance and its exit.

Five decisions shape everything below.

1. **The wide layout is two regions.** The destinations on the left — the
   counter row, the destination cards, the editor and the add action — and a
   distribution rail on the right holding the per-line distribution, the
   assigned-units total, the gate line and the finish action. Below the width
   where a rail earns its keep, the same content becomes one column with the
   total and the finish action pinned as a footer band, which is the shape the
   capture and payment steps already use.

2. **The destinations stay grouped as the mock groups them.** A counter-pickup
   row first, then one card per addressed destination, then the add action.
   Each card is collapsible and carries its own index badge; expanding it shows
   the lines that destination takes, with their quantities.

3. **The distribution panel stays, and becomes the rail.** It is not replaced
   by anything and it does not disappear while the editor is open — it is the
   running answer to "is this sale fully distributed yet", and the editor's
   draft continues to move its figures as it does today.

4. **Destinations are identified by badge everywhere they are named.** The
   badge on a destination's card is the badge on that destination's chip in the
   distribution rail, so a cashier reading `D2 242` in the rail knows which card
   to open without counting.

5. **The gate and the action are read together.** The unassigned remainder that
   blocks a pure-delivery close (FR-035) is stated directly above the finish
   action, in the same block as the assigned-units total, rather than as a line
   floating between the add button and the bottom of the page.

Nothing about the delivery rules changes. No condition for creating, removing,
sweeping or closing is touched; no request is added or removed; the step order
is unchanged — Entrega is the last step and finishing it completes the sale,
whatever the mock's "Paso 2 de 3" says.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Read every destination and what is left, without scrolling (Priority: P1)

A cashier on the counter workstation reaches the Entrega step of a sale with
two destinations. The whole step is on screen at once: the counter row, both
destination cards, the add action, and — on the right — every sale line with
where its units are going, the assigned-units total, and the finish action.
Nothing scrolled.

**Why this priority**: It is the complaint. Everything else in this feature is
detail work inside the shape this story establishes.

**Independent Test**: Open the Entrega step on a two-destination sale at a
1440×900 window and read every destination, every line's distribution and the
finish action without a scroll gesture.

**Acceptance Scenarios**:

1. **Given** a sale with two destinations at a 1440×900 window, **When** the
   Entrega step opens, **Then** the destination list, the add action, the
   per-line distribution, the assigned-units total and the finish action are all
   visible without scrolling.
2. **Given** that screen, **When** the cashier records another destination,
   **Then** the new card appears in the list and the rail's chips and total move,
   with no scrolling required to see either.
3. **Given** a sale with more destinations or more lines than a region can show,
   **When** the cashier looks at the step, **Then** the destination list and the
   distribution list scroll on their own, and the assigned-units total, the gate
   line and the finish action stay pinned.

---

### User Story 2 - Know where every line is going and finish the sale (Priority: P1)

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
   step, **Then** the finish action is available and the remainder is presented
   as the counter's share, not as an error.

---

### User Story 3 - Add a destination without losing sight of the rest (Priority: P2)

The cashier opens the composer for a new destination: address, contact, date,
instructions, and a quantity per line. While they type, the distribution keeps
updating, the destinations already recorded stay on screen, and an over-claim is
named on the line that caused it. A refusal from the server keeps the composer
open with what they entered.

**Why this priority**: Composing a destination is the step's main act; today it
replaces the distribution panel and the add action with itself, which is the
part of the current layout that loses the most context.

**Independent Test**: With one destination already recorded, open the composer,
claim more than a line has left, read the error on that line, correct it, and
save — with the first destination visible throughout.

**Acceptance Scenarios**:

1. **Given** a sale with one destination recorded, **When** the composer opens,
   **Then** the recorded destination and the distribution remain visible.
2. **Given** the composer open, **When** a quantity is typed, **Then** the
   distribution's figures move with the draft, exactly as they do today.
3. **Given** a quantity larger than the line still has, **When** it is entered,
   **Then** that line is marked over-claimed and the save action is unavailable.
4. **Given** the server refuses the create, **When** the refusal arrives,
   **Then** the message is shown inside the composer, the entered values are
   kept, and every already-recorded destination is untouched.
5. **Given** a line with quantity still unassigned, **When** the cashier uses
   the assign-all affordance, **Then** that line's field takes the claimable
   quantity, as it does today.

---

### User Story 4 - Inspect what one destination takes (Priority: P2)

The cashier wants to check the second destination before finishing. They expand
its card and see the lines it takes with their quantities; they collapse it
again and the list is compact. Removing a destination is still one action on the
card, and the counter row cannot be removed.

**Why this priority**: It surfaces data the screen already holds but never
shows, and it is what makes the destination list readable when several exist.

**Independent Test**: With two destinations, expand one, read its lines and
quantities, collapse it, and confirm the other card is unaffected.

**Acceptance Scenarios**:

1. **Given** a destination with lines, **When** its card is expanded, **Then**
   each line it takes is listed with the quantity this destination takes.
2. **Given** several destinations, **When** one is expanded, **Then** the others
   keep their own expanded or collapsed state and the list does not jump.
3. **Given** a collapsed card, **When** the cashier reads it, **Then** it shows
   its badge, its address, its recipient, its date and its line and unit counts.
4. **Given** a counter-pickup row, **When** the cashier reads it, **Then** it
   names the counter, shows its line and unit counts, and offers no removal
   action — unchanged from today.
5. **Given** an addressed destination, **When** the cashier removes it, **Then**
   the same confirmation-free removal with its fixed reason happens as today and
   the quantities return to the pool.

---

### User Story 5 - Work the step on a phone (Priority: P3)

A cashier working from a handheld reaches the Entrega step. There is no room for
a rail, so the same pieces stack in one scrolling column in the mock's phone
order — the counter row, the destination cards, the add action, then the
distribution — with the assigned-units total, the gate line and the finish
action pinned to the bottom edge.

**Why this priority**: The phone tier already exists and must not regress; it is
not the primary counter surface.

**Independent Test**: Open the step at a phone width, record a destination, and
finish the sale without losing sight of the total or the finish action.

**Acceptance Scenarios**:

1. **Given** a window below the two-region threshold, **When** the step opens,
   **Then** the content is one scrolling column and the assigned-units total
   with the finish action is pinned to the bottom edge.
2. **Given** that column scrolled to its end, **When** the cashier reads the
   screen, **Then** nothing is clipped and no region overflows horizontally.
3. **Given** a phone width, **When** the composer is open, **Then** its address,
   contact and date controls and its per-line quantities all fit the width
   without horizontal scrolling.

---

### Edge Cases

- **A sale with no destinations yet.** The list shows its empty state and the
  distribution reads everything as still at the counter; the counter row is
  shown when the sale is mixed, since that is where the units would go.
- **A mixed sale with a remainder.** The counter row states the remainder's line
  and unit counts, and the finish action is available; nothing is marked as an
  error.
- **A resumed sale that already has a counter-pickup destination.** It renders
  as the counter row with its recorded lines, not as a preview.
- **An over-claim in the composer.** Named on the offending line; the save
  action stays unavailable until it is corrected.
- **A destination whose address or contact could not be joined.** The card falls
  back to the same pending-address wording it uses today and still shows its
  badge and counts.
- **A long address, a long recipient name or a long product name.** It wraps or
  ellipsizes inside its card or row without widening the layout.
- **Many destinations, or a sale with many lines.** Each region scrolls on its
  own; the pinned block never scrolls away.
- **A very large quantity.** No figure in a card, a chip, a composer field or
  the total is truncated or clipped at any supported width.
- **A window resized across the two-region threshold** while the composer is
  open. The entered address, contact, date, instructions and quantities survive
  the reflow.
- **A close already in flight.** Every control the step disables today stays
  disabled, and the finish action shows the same in-flight treatment.
- **The destination list fails to load.** The step reports it exactly as it does
  today, with the same retry affordance.

## Requirements *(mandatory)*

### Functional Requirements

**Scope fence**

- **FR-001**: This feature MUST NOT change any delivery rule, gate or server
  interaction — the conditions for creating a destination, removing one,
  sweeping the remainder to the counter and closing the step MUST behave exactly
  as they do today.
- **FR-002**: This feature MUST NOT change the step order: Entrega remains the
  last step, and the step's exit action MUST keep its current label and
  destination (the sale-completed outcome).

**The delivery surface**

- **FR-003**: At wide widths the step MUST render as two regions — a
  destinations region and a distribution rail — with the per-line distribution,
  the assigned-units total, the gate line and the finish action in the rail.
- **FR-004**: Below the two-region threshold the step MUST render as one column
  in the mock's phone order — counter row, destination cards, add action,
  distribution — with the assigned-units total, the gate line and the finish
  action pinned to the bottom edge rather than scrolling with the content.
- **FR-005**: The step MUST spend the full width and height it is given: no
  centred or width-bounded region, and no unused vertical band between the
  destinations region's content and the bottom edge.
- **FR-006**: In the two-region shape, the destination list and the distribution
  list MUST each scroll independently, and the assigned-units total, the gate
  line and the finish action MUST stay pinned.
- **FR-007**: A load failure or a server refusal MUST be reported in the same
  place it is reported today — the step's own banner for a load failure, the
  composer's banner for a refused create — and MUST stay dismissible or
  self-clearing exactly as today.

**The destination group**

- **FR-008**: The destinations MUST be grouped as the mock groups them: a
  counter-pickup row first, then one card per addressed destination in the order
  they were recorded, then the add action.
- **FR-009**: The counter row MUST be shown when the sale has a counter-pickup
  destination, and — for a mixed sale — when the distribution still leaves a
  remainder; it MUST state its line and unit counts and MUST offer no removal
  action.
- **FR-010**: Each addressed destination MUST carry a positional index badge
  (`D1`, `D2`, …) in its card header, and the same badge MUST identify that
  destination wherever else the step names it.
- **FR-011**: A collapsed destination card MUST show its badge, its address, its
  recipient and phone, its delivery date, and its line and unit counts on one
  header, with the counts visually set apart from the identity.
- **FR-012**: A destination card MUST be expandable to list the lines that
  destination takes with the quantity it takes of each, and MUST be collapsible
  again; each card's expanded state MUST be independent of the others'.
- **FR-013**: The lines listed inside an expanded destination card MUST be
  read-only — this feature adds no way to edit a recorded destination.
- **FR-014**: The removal action MUST remain available on every addressed
  destination and absent on the counter row, with today's fixed removal reason
  and today's disabled-while-closing behaviour.
- **FR-015**: The add action MUST sit at the end of the destination list, styled
  as the mock's full-width dashed affordance, and MUST be unavailable while the
  composer is open or a close is in flight.
- **FR-016**: When no destinations exist and the composer is closed, the step
  MUST show its empty state within the destination region.

**The composer**

- **FR-017**: The composer MUST open in place within the destination region,
  keeping the already-recorded destinations and the distribution visible.
- **FR-018**: The composer MUST keep today's controls — address picker, contact
  picker, date picker, instructions field, one quantity field per sale line,
  the per-line assign-all affordance, cancel and save — with no control added or
  removed.
- **FR-019**: Each quantity row MUST read as the mock's line row: the product
  name, what that line still has available, and the quantity field, with the
  assign-all affordance presented as the row's or the section's own action.
- **FR-020**: Each quantity control MUST remain a real, focusable, typable field
  accepting decimal entry from a physical keyboard.
- **FR-021**: An over-claimed line MUST be marked on that line, and the save
  action MUST stay unavailable while any line is over-claimed or no line is
  claimed — the same conditions as today.
- **FR-022**: The composer MUST NOT render its own second copy of the
  distribution; the step's single distribution region MUST reflect the composer's
  draft while it is open.

**The distribution rail**

- **FR-023**: The distribution MUST list every sale line with its product name,
  the quantity ordered, and the quantity each destination takes.
- **FR-024**: Each line's per-destination quantities MUST be presented as the
  mock's row of small chips, one per destination that takes any of it plus one
  for the counter when any remains there, each chip carrying the destination's
  badge and its quantity.
- **FR-025**: A line whose remainder is over-claimed MUST be visually
  distinguished from one that is fully assigned and from one that still has
  units at the counter, without relying on colour alone.
- **FR-026**: The rail MUST state how many lines it is showing and across how
  many destinations, as the mock's rail header does.
- **FR-027**: The rail MUST show the assigned-units total against the sale's own
  total units as one figure at its foot.
- **FR-028**: While the finish action is disabled because units are unassigned
  on a pure-delivery sale, the line naming the outstanding lines and their
  quantities MUST be shown directly above the action; it MUST NOT be shown when
  the action is available.
- **FR-029**: The finish action MUST sit directly beneath the assigned-units
  block and MUST be enabled by exactly the condition that governs it today,
  keeping today's in-flight treatment.

**Styling and parity**

- **FR-030**: Every colour, spacing, radius, elevation and type size introduced
  by this feature MUST resolve through the product's theme and design tokens; no
  literal value from the mock's palette may be hard-coded.
- **FR-031**: Every label this feature introduces MUST exist in both supported
  locales.
- **FR-032**: Every control disabled while a close or a create is in flight
  today MUST remain disabled under the same conditions.
- **FR-033**: The test keys of the controls that survive this feature MUST be
  preserved, so the existing widget tests keep addressing them.
- **FR-034**: Every affordance this feature introduces — expanding a card,
  removing a destination, adding one, finishing the sale — MUST be reachable by
  keyboard and MUST announce its purpose and state to a screen reader.

### Key Entities

- **Destination**: one place the goods go — an address, a recipient, a date and
  the lines it takes — or the counter, which has no address and cannot be
  removed. Unchanged by this feature; only how it is rendered changes.
- **Line distribution**: for one sale line, the quantity ordered, the quantity
  each destination takes, whatever a draft claims, and the remainder at the
  counter. Unchanged by this feature; the rail is a new rendering of it.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: On a 1440×900 window, a sale with two destinations and six lines
  shows both destination cards, the add action, every line's distribution, the
  assigned-units total and the finish action with zero scrolling.
- **SC-002**: Recording a destination on that window requires the same or fewer
  interactions than before this feature, and zero scroll gestures.
- **SC-003**: A cashier can name which destination takes a given line's units
  without opening any card, at 100% of supported widths.
- **SC-004**: The quantities a single destination takes are readable in one
  place — its own card — rather than derived by subtraction, in 100% of cases.
- **SC-005**: The assigned-units total, the reason the finish action is
  disabled, and the action itself are in one glance region at 100% of supported
  widths.
- **SC-006**: The step renders without clipping or horizontal overflow at every
  width from 320 px to 1920 px, at both text scales the product supports.
- **SC-007**: Zero literal colour, spacing or font-size values are introduced in
  the changed components; every one resolves through the theme.
- **SC-008**: Zero labels introduced by this feature are missing from either
  locale.
- **SC-009**: 100% of the delivery step's existing widget tests pass unchanged,
  or changed only where a widget they addressed was intentionally replaced.
- **SC-010**: Zero network requests are added or removed by this feature — the
  step issues exactly the calls it issues today, in the same order.

## Assumptions

- **The two-region threshold is the product's Large tier (1200 px)**, the same
  threshold the payment step adopted in spec 025. The mock is drawn at 1440 px
  with a 380 px rail; below roughly 1200 px the destination region would be too
  narrow to hold a card's header and its counts on one line while leaving the
  rail useful. Between the phone breakpoint and that threshold the step uses the
  one-column shape with the pinned footer. If driving the real screen shows the
  rail earns its keep earlier, the threshold moves — nothing else in this spec
  depends on the number.
- **The counter row is presentation of state the step already computes.** For a
  mixed sale it previews where the remainder will go on close (FR-036's existing
  sweep); it is not a destination created early, and no request is issued to
  show it. For a sale that already has a counter-pickup destination, the same
  row renders that record.
- **Destination badges are positional**, derived from the order the destinations
  are listed in, and are display-only — nothing is persisted and no identifier
  is invented.
- **Cards are collapsed by default** except when a single addressed destination
  exists, where the mock shows the first one expanded. This is a starting state,
  not a rule the cashier cannot change.
- **The mock's palette, font sizes and pixel dimensions are a presentation.**
  They are read as proportions and hierarchy, not as values to reproduce.
- **The mock's `D1`/`D2`/`Tienda` chip vocabulary maps to the product's own
  wording in both locales**; the badge letter is not hard-coded Spanish.
- **Nothing about the delivery step's controllers or repositories changes.**
  This feature is confined to presentation; the distribution arithmetic,
  the completion gate and the sweep stay exactly where they are.

## Dependencies

- Spec 020 (Point of Sale) — the delivery step, its controller, its
  distribution arithmetic and its completion gate.
- Spec 022 (Design System Tokens) — the spacing, shape, elevation and type-role
  scales every value in this feature resolves through.
- Spec 023 (POS UX Improvements) — the full-width workspace this step renders
  inside, and the footer-band pattern the one-column shape reuses.
- Spec 025 (POS Payment Step Look & Feel) — the two-region-with-pinned-foot
  pattern this step mirrors, so the two steps read as one product.
- `artifacts/point_of_sale/POS_Adaptativo.dc.html` — the visual reference,
  frame `2b` (expanded) and the phone frame labelled "Paso 2 · entrega".

## Out of Scope

- The mock's per-destination edit action, and any way to change a recorded
  destination's address, recipient, date or quantities after it is created.
- The mock's `−`/`+` steppers and the per-line `swap_horiz` "move this line to
  another destination" action inside a destination card — both are new
  behaviour, not new styling.
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
- Any change to mbe-api, to the delivery controllers, or to the repositories.

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
- The token access rule this feature's styling follows:
  `Theme.of(context).spacing` / `.shapes` / `.typeRoles` / `.elevations`.
- The two-region threshold: `LayoutBreakpoints.large`.
- The test keys that must keep working: `delivery_add_destination_button`,
  `delivery_close_button`, `delivery_outstanding_notice`, `destination_card_*`,
  `destination_remove_*`, `destination_editor`, `destination_editor_error`,
  `destination_address_button`, `destination_contact_button`,
  `destination_date_button`, `destination_comment_field`,
  `destination_quantity_*`, `destination_claim_all_*`,
  `destination_save_button`, `line_distribution_panel`, `distribution_row_*`.
