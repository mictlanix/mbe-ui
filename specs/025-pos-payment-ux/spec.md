# Feature Specification: Point of Sale — Payment Step Look & Feel

**Feature Branch**: `025-pos-payment-ux`

**Created**: 2026-08-15

**Status**: Draft

**Input**: User description: "Improve the POS payment step screen and make its design more like `artifacts/point_of_sale/POS_Adaptativo.dc.html`. The screen currently works fine; we are aiming to improve its look & feel. From the mockup, ignore the order of the screens — it figures there as the last step, but during development we moved payment to the second step. Also keep the keypad buttons' aspect ratio, because on the mock they look vertically stretched."

## Clarifications

### Session 2026-08-15

- Q: How far should this go beyond look & feel? → A: Visual and layout only. Re-shape what already exists; add no behaviour, no new calls, no new capability.
- Q: What layout should the payment step take on a wide screen? → A: The mock's two-pane shape — capture on the left, a rail on the right listing the applied payments with the money summary and the step's exit action pinned at its foot. It collapses to one scrolling column on a phone.
- Q: How should the payment method selector be presented? → A: The mock's grid of tiles — method icon, name and a secondary line — with the selected tile outlined and check-marked, replacing today's row of chips.

## Overview

Spec 020 built the payment step and it works: a cashier can tender an amount,
pick a method, record a reference, see the change, watch the balance fall to
zero and move on. What it does not do is *look* like the screen it was drawn
from. Spec 023 took the capture step to its own reference frame and explicitly
left this one alone — "the payment step's internal layout (mock frame `2c`),
including the touch keypad and the applied-payments panel" is listed in that
spec's Out of Scope. This feature is that deferred half.

**Everything is one scrolling column.** Today the step is a single list:
a card with three figures, a row of method chips, a reference field, the amount
field, the quick-amount chips, the keypad, an apply button, a divider, the
applied payments, and finally the continue button. On a 1440-pixel display that
column runs down the left of a mostly empty screen, and the cashier scrolls
past the keypad to reach the payments they have already taken. The mock spends
the same screen as two panes and needs no scrolling at all.

**The amount does not look like the number being typed.** It is an ordinary
labelled text field, the same size as every other field on the screen. In the
mock it is the largest thing on the screen — a right-aligned figure with the
currency beside it — because it is the one number the cashier is watching while
they key it in.

**What has been taken and what is still owed are in three different places.**
The total, paid and balance sit in a card at the top; the change appears
under the amount field, but only while a tender exceeds the balance; the
applied payments sit at the bottom under a divider; and the action that leaves
the step sits below them, far from the balance that gates it. The mock puts all
four in one place — the rail's foot — so the figure and the action that depends
on it are read together.

**Two buttons compete at the bottom.** "Aplicar pago" and "Continuar" sit in
the same column, one above the other, distinguished only by fill. They belong to
different things: one records a tender in the capture pane, the other ends the
step. The mock separates them by pane, which is what makes them tell apart.

Five decisions shape everything below.

1. **The wide layout is two panes.** Capture on the left — amount, quick
   amounts, methods, reference, apply — and a rail on the right holding the
   applied payments, the money summary and the step's exit. Below the width
   where a rail earns its keep, the same content becomes one column with the
   summary and exit pinned as a footer band, which is the shape the capture
   step already uses.

2. **The amount is the headline.** The tender being keyed is the visually
   dominant element of the capture pane: large, right-aligned, tabular figures
   with the currency beside them. It stays a real, typable, focusable field —
   the keypad and the physical keyboard remain two paths to the same place, as
   they are today.

3. **The money and the exit are read together.** Total, paid, remaining and
   change sit in one block with the continue action directly beneath it. The
   change stops being a line that appears and disappears under the amount field
   and becomes a permanent row of that block.

4. **Methods become tiles, not chips.** Each configured payment option gets a
   tile with an icon, its name and a secondary line saying what it will ask for
   (a reference, or nothing), and the chosen one is outlined and check-marked.
   A chip row says only "these are the words"; the tile says what picking it
   will cost the cashier.

5. **The keypad keeps its key proportions.** In the mock the keypad stretches
   its keys to fill the pane's height, which is what the shipped `NumberPad`
   deliberately stopped doing after a live-driving session where inflated keys
   pushed the submit button below the fold. The pad keeps its width cap and its
   key aspect ratio at every width; the mock's stretched keys are not adopted.

Nothing about the money changes. No rule about what may be tendered, applied,
reversed or gated is touched; no request is added or removed; the step order is
unchanged — payment is the second step and delivery follows it, whatever the
mock's "Paso 3 de 3" says.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Take a payment without scrolling (Priority: P1)

A cashier on the counter workstation confirms a sale and lands on the payment
step. The whole step is on screen at once: the amount being keyed, the quick
amounts, the method tiles, the keypad, and — on the right — the payments
already applied with the balance beneath them. They key an amount, tap a
method, press apply, and the rail updates. Nothing scrolled.

**Why this priority**: It is the complaint. Everything else in this feature is
detail work inside the shape this story establishes.

**Independent Test**: Open the payment step on a sale at a wide window and take
a full-balance cash payment end to end, without scrolling any region.

**Acceptance Scenarios**:

1. **Given** a confirmed sale with an outstanding balance on a 1440×900 window,
   **When** the payment step opens, **Then** the amount display, the quick
   amounts, the method tiles, the keypad, the reference slot, the apply action,
   the applied payments, the money summary and the continue action are all
   visible without scrolling.
2. **Given** that screen, **When** the cashier keys an amount and applies it,
   **Then** the applied payment appears in the rail and the summary's paid and
   remaining figures move, with no scrolling required to see either.
3. **Given** a sale with more applied payments than the rail can show,
   **When** the cashier looks at the rail, **Then** the payments region scrolls
   on its own and the money summary and continue action stay pinned at its foot.

---

### User Story 2 - Read what is owed and leave the step (Priority: P1)

A cashier has taken two partial payments. They need to know what is left before
asking for more money, and they need the exit to become available the moment
the balance clears. Total, paid, remaining and change are one block; the
continue action is directly beneath it; while it is disabled, a line says what
would enable it.

**Why this priority**: This is the step's purpose — the money's state and the
decision it drives, side by side.

**Independent Test**: With a part-paid sale, read all four figures in one place,
then apply the remainder and watch the exit become available in the same block.

**Acceptance Scenarios**:

1. **Given** a sale with a partial payment applied, **When** the cashier reads
   the summary, **Then** total, paid, remaining and change are all shown, in
   that block, at the same time.
2. **Given** a remaining balance greater than zero on a cash-terms sale,
   **When** the cashier looks at the continue action, **Then** it is disabled
   and a short line states that it opens when the balance is settled.
3. **Given** a tender larger than the remaining balance, **When** the amount is
   keyed, **Then** the change figure in the summary shows the excess, and it
   returns to zero when the amount is cleared.
4. **Given** the balance reaches zero, or the sale carries credit terms,
   **When** the gate is evaluated, **Then** the continue action becomes
   available — the same condition as today, in its new position.

---

### User Story 3 - Take a payment on a phone (Priority: P2)

A cashier working from a handheld opens the payment step. There is no room for
a rail, so the same pieces stack in one scrolling column in the mock's phone
order — balance and total first, then the amount, the quick amounts, the
methods, the reference, the apply action, and the payments taken so far. The
money summary and the continue action stay pinned to the bottom edge.

**Why this priority**: The phone tier already exists and must not regress; it
is not the primary counter surface.

**Independent Test**: Open the step at a phone width and take a payment without
losing sight of the balance or the exit.

**Acceptance Scenarios**:

1. **Given** a window below the phone breakpoint, **When** the payment step
   opens, **Then** the content is one scrolling column and the money summary
   with the continue action is pinned to the bottom edge.
2. **Given** that column scrolled to its end, **When** the cashier reads the
   screen, **Then** nothing is clipped and no region overflows horizontally.

---

### User Story 4 - Choose a method and know what it will ask for (Priority: P2)

The facility's configured payment options are shown as tiles: an icon, the
option's name, and a line saying whether it needs a reference. The cashier taps
one; it is outlined and check-marked, and the reference slot appears only when
that option asks for one.

**Why this priority**: It removes a guess the cashier currently makes by
tapping and watching whether a field appears.

**Independent Test**: With a facility that has both reference-requiring and
reference-free options configured, read each tile's secondary line and confirm
it matches what selecting it does.

**Acceptance Scenarios**:

1. **Given** a facility with configured payment options, **When** the step
   renders, **Then** each option is a tile with its icon, its name and its
   reference requirement.
2. **Given** an option that requires a reference, **When** it is selected,
   **Then** the tile is marked as selected and the reference field is shown.
3. **Given** a facility with no configured options, **When** the step renders,
   **Then** the same tile treatment is used for the fallback tenders, which
   ask for no reference — unchanged from today's fallback behaviour.
4. **Given** the options are still loading or failed to load, **When** the step
   renders, **Then** it reports that state exactly as it does today and the
   rest of the step stays usable.

---

### User Story 5 - Key an amount on a pad sized for fingers (Priority: P3)

The cashier keys the amount on the touch keypad. The keys are the size they
were drawn for — never inflated to fill the pane, never shrunk below a touch
target — and the apply action is reachable without scrolling past them.

**Why this priority**: A regression here was already found and fixed once in
production use; this feature must not reintroduce it while re-laying out the
pane around the pad.

**Independent Test**: Render the step at the phone, tablet and wide widths and
compare the key proportions; they must not vary with the pane's height.

**Acceptance Scenarios**:

1. **Given** any supported width, **When** the keypad renders, **Then** its
   keys keep the same aspect ratio and the pad never exceeds its width cap.
2. **Given** a tall pane, **When** the keypad renders, **Then** the keys do not
   grow to consume the extra height.
3. **Given** the keypad, **When** a key is pressed, **Then** the amount display
   updates exactly as typing into it does — both paths edit the same value.

---

### Edge Cases

- **A sale with no payments yet.** The rail shows its empty state and the
  summary reads paid zero, remaining equal to the total, change zero.
- **A tender that exceeds the balance.** The change row shows the excess while
  the amount is being keyed; applying it behaves exactly as today.
- **A reversed payment.** It stays listed, struck through, and the summary's
  figures follow the sale as they do today.
- **A read-only sale** (finished, or opened for inspection). Every control the
  step disables today is disabled in the new shape too, and the disabled state
  is visible on a tile, not only on a chip.
- **A refusal from the server** while applying. The message is shown inside the
  capture pane, near the action that caused it, and the draft is kept.
- **A very large amount.** No figure in the summary, the amount display or a
  payment row is truncated or clipped at any supported width; figures wrap or
  scale rather than being cut.
- **A long option name** on a method tile — it wraps or ellipsizes within the
  tile without breaking the grid.
- **A window resized across the two-pane threshold** mid-tender. The draft
  amount, the selected method and the reference survive the reflow.
- **Credit terms.** The exit is available with a balance outstanding, and the
  line that explains the gate is not shown, since nothing is being gated.

## Requirements *(mandatory)*

### Functional Requirements

**Scope fence**

- **FR-001**: This feature MUST NOT change any payment rule, gate or server
  interaction — the conditions for applying a tender, computing change,
  reversing an application and leaving the step MUST behave exactly as they do
  today.
- **FR-002**: This feature MUST NOT change the step order: payment remains the
  second step, with delivery following it, and the exit action MUST keep its
  current label and destination.

**The payment surface**

- **FR-003**: At wide widths the step MUST render as two panes — a capture pane
  and a rail — with the applied payments, the money summary and the exit action
  in the rail.
- **FR-004**: Below the two-pane threshold the step MUST render as one column
  in the mock's phone order, with the money summary and the exit action pinned
  to the bottom edge rather than scrolling with the content.
- **FR-005**: The step MUST spend the full width and height it is given: no
  centred or width-bounded region, and no unused vertical band between the
  capture pane's content and the bottom edge.
- **FR-006**: In the two-pane shape, only the applied-payments list MUST
  scroll; the capture pane and the summary MUST stay put at the widths the
  two-pane shape is used at.
- **FR-007**: A server refusal or a load failure MUST be reported inside the
  capture pane, above the controls that produced it, and MUST be dismissible or
  self-clearing exactly as today.

**The amount**

- **FR-008**: The tender amount MUST be the visually dominant element of the
  capture pane, right-aligned, in tabular figures, with the currency indicated
  beside it.
- **FR-009**: The amount MUST remain a real, focusable, typable field that
  accepts decimal entry from a physical keyboard.
- **FR-010**: The quick-amount actions MUST sit directly beneath the amount as
  one row — the remaining balance, the round notes above it and the half —
  unchanged in which amounts they offer.
- **FR-011**: The keypad MUST keep its current key aspect ratio and its maximum
  pad width at every supported width, and MUST NOT scale its keys to the height
  of the pane it sits in.
- **FR-012**: The keypad and the amount field MUST remain two paths to the same
  value, neither privileged.

**The method tiles**

- **FR-013**: Payment methods MUST be presented as a grid of tiles, each
  carrying the method's icon, its name and a secondary line stating whether it
  requires a reference.
- **FR-014**: The selected tile MUST be visually distinguished by both an
  outline and a check mark, not by fill alone.
- **FR-015**: The tiles MUST be built from the facility's own configured
  payment options, keeping today's fallback to the common tenders when none are
  configured, and keeping today's loading and failure treatments.
- **FR-016**: The reference field MUST be shown only when the selected option
  requires one, and MUST sit in the capture pane beneath the tiles.
- **FR-017**: Every tile MUST be reachable by keyboard and MUST announce its
  name and selected state to a screen reader.

**The rail**

- **FR-018**: The rail MUST list the payments already applied to the sale, each
  showing its amount, its method, its reference when it has one, and its
  pending-validation or reversed state.
- **FR-019**: Each listed payment MUST keep its reversal action, with the same
  mandatory-reason confirmation as today, and a reversed payment MUST remain
  visible and marked as reversed.
- **FR-020**: The rail MUST show how many payments have been applied, and MUST
  show an empty state when none have been.
- **FR-021**: The rail MUST show the money summary — total, paid, remaining and
  change — as one block at its foot, above the exit action.
- **FR-022**: The change figure MUST be a permanent row of that block, reading
  zero when there is no change, rather than a line that appears only when a
  tender exceeds the balance.
- **FR-023**: The exit action MUST sit directly beneath the money summary and
  MUST be enabled by exactly the condition that governs it today.
- **FR-024**: While the exit action is disabled because the balance is
  outstanding, a short line MUST state what would enable it; it MUST NOT be
  shown when the action is available.

**Actions**

- **FR-025**: The action that applies a tender MUST belong to the capture pane,
  sit at its foot, and remain the pane's own primary action.
- **FR-026**: The action that applies a tender and the action that leaves the
  step MUST NOT be adjacent in the same column at any width, and MUST be
  distinguishable by more than fill.
- **FR-027**: Both actions MUST keep today's in-flight and disabled treatments.

**Styling and parity**

- **FR-028**: Every colour, spacing, radius, elevation and type size introduced
  by this feature MUST resolve through the product's theme and design tokens;
  no literal value from the mock's palette may be hard-coded.
- **FR-029**: Every label this feature introduces MUST exist in both supported
  locales.
- **FR-030**: Every control disabled while the sale is read-only or a request
  is in flight today MUST remain disabled under the same conditions.
- **FR-031**: The test keys of the controls that survive this feature MUST be
  preserved, so the existing widget tests keep addressing them.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: On a 1440×900 window, a sale with two applied payments shows the
  amount entry, the methods, the keypad, both payments, all four money figures
  and both actions with zero scrolling.
- **SC-002**: Taking a full-balance payment on that window requires the same or
  fewer interactions than before this feature, and zero scroll gestures.
- **SC-003**: The total, paid, remaining and change figures are readable in one
  glance region at 100% of supported widths — never split across two areas of
  the screen.
- **SC-004**: The keypad's key aspect ratio measured at the phone, tablet and
  1440 px widths differs by zero, and the pad never exceeds its width cap.
- **SC-005**: The step renders without clipping or horizontal overflow at every
  width from 320 px to 1920 px, at both text scales the product supports.
- **SC-006**: Zero literal colour, spacing or font-size values are introduced in
  the changed components; every one resolves through the theme.
- **SC-007**: Zero labels introduced by this feature are missing from either
  locale.
- **SC-008**: 100% of the payment step's existing widget tests pass unchanged,
  or changed only where a widget they addressed was intentionally replaced.
- **SC-009**: Zero network requests are added or removed by this feature — the
  step issues exactly the calls it issues today, in the same order.
- **SC-010**: A cashier can tell which action records a tender and which leaves
  the step without reading their labels, at every supported width.

## Assumptions

- **The two-pane threshold is the product's Large tier (1200 px).** The mock is
  drawn at 1440 px with a 400 px rail; below roughly 1200 px the capture pane
  would be too narrow to hold the methods and the keypad beside each other and
  still leave the rail useful. Between the phone breakpoint and that threshold
  the step uses the one-column shape with the pinned footer, which is the shape
  the capture step already uses at those widths. If driving the real screen
  shows the rail earns its keep earlier, the threshold moves — nothing else in
  this spec depends on the number.
- **Within the capture pane, the methods and the keypad sit side by side only
  when the pane is wide enough**; otherwise the keypad follows the methods.
  This is a decision about the pane's own width, not the window's.
- **The mock's currency indicator is the sale's own currency**, already carried
  by the sale; nothing new is fetched to display it.
- **The mock's palette, font sizes and pixel dimensions are a presentation.**
  They are read as proportions and hierarchy, not as values to reproduce.
- **Method icons come from the standard icon set**, chosen per method family,
  as the mock does — no new asset is introduced.
- **The keypad's visual restyle, if any, may require its golden images to be
  regenerated**; the aspect-ratio and width-cap assertions are what must not
  change.
- **Nothing about the payment step's controllers or repositories changes.**
  This feature is confined to presentation.

## Dependencies

- Spec 020 (Point of Sale) — the payment step, its controllers and its gate.
- Spec 022 (Design System Tokens) — the spacing, shape, elevation and type-role
  scales every value in this feature resolves through.
- Spec 023 (POS UX Improvements) — the full-width workspace this step renders
  inside, and the footer-band pattern the one-column shape reuses.
- `artifacts/point_of_sale/POS_Adaptativo.dc.html` — the visual reference,
  frames `2c` (expanded) and the phone frame labelled "Paso 3 · cobro".

## Out of Scope

- The mock's "Validar" action on a payment pending terminal validation.
- The mock's dashed "pago en captura" row previewing the draft tender inside
  the applied-payments list.
- The mock's header chips — folio, customer, payment terms, currency and
  exchange rate — above the panes.
- Multi-currency display or exchange-rate entry of any kind.
- The mock's step order and its "Paso 3 de 3" labelling.
- The delivery step's layout, and any further change to the capture step.
- Any change to mbe-api, to the payment controllers, or to the repositories.
- Any new payment method, validation state or reversal rule.

## Verbatim Constraints

- The visual reference: `artifacts/point_of_sale/POS_Adaptativo.dc.html`,
  frame `2c` and the phone frame labelled "Paso 3 · cobro".
- The screens and widgets in scope:
  `lib/features/sales/presentation/payment/payment_step.dart`,
  `payment/payment_amount_field.dart`, `payment/payment_method_grid.dart`,
  `payment/applied_payments_panel.dart`, and
  `lib/core/widgets/number_pad.dart`.
- The gate that governs the exit action: `PosStepController.canLeavePayment`.
- The token access rule this feature's styling follows:
  `Theme.of(context).spacing` / `.shapes` / `.typeRoles` / `.elevations`.
- The pad's width cap that must be preserved: `NumberPad.maxPadWidth`.
- The test keys that must keep working: `payment_amount_field`,
  `payment_reference_field`, `payment_submit_button`, `payment_close_button`,
  `payment_method_*`, `payment_option_*`, `applied_payment_*`, `number_pad_*`.
