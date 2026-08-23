# Feature Specification: Point of Sale — Sale & Delivery Refinements

**Feature Branch**: `030-pos-sales-refinements`

**Created**: 2026-08-20

**Status**: Draft

**Input**: User description: "1. I'd like that the quantity field that is currently used at the sales order lines at the `lib/features/sales/presentation/capture/capture_step.dart`, to be replaced with the stepper that is used at the `lib/features/sales/presentation/delivery/delivery_step.dart`. This will make it inherit the debounce behavior that was recently implemented. Also, make this widget reset its value if the text field is left without value confirmation (currently the value is confirmed if user presses enter when the value is affected through the text field). Add a transition animation of the value's reset to let user acknowledge this change easily. 2. Add edit button to `lib/features/sales/presentation/delivery/destination_card.dart` so user can edit destination details. This button is in the mock `artifacts/point_of_sale/POS_Adaptativo.dc.html` but didn't reach the final UI. 3. Make the `lib/features/sales/presentation/delivery/destination_counter_row.dart` expandible too, so users can have a better picture of the qty that is delivered at store. This is the only destination that is not editable and can't be removed."

## Clarifications

### Session 2026-08-20

- Q: The debounced stepper lives as a private control inside the delivery destination card. How should the sale lines get it? → A: Extract it into **one** reusable quantity-stepper widget and use it in all three places (the wide sale-line row, the compact sale-line card, and the destination card), so there is a single implementation of the behaviour rather than two that drift.
- Q: What counts as confirmation of a typed quantity, and what happens when the field is left? → A: Pressing Enter confirms; stepping with −/+ confirms through the debounce as it does today. Losing focus, tapping elsewhere, or leaving the surface **discards** the typed text and returns the field to the last confirmed value.
- Q: How should that reset animate? → A: A brief cross-fade of the old value out and the restored value in, together with a short colour pulse of the control that settles back to normal — calm, but impossible to miss.
- Q: When the store row is expanded, which lines should it list? → A: **All** of the sale's lines, mirroring the destination card's own read-only body shape, with the quantity staying at the store shown against each — zeros included.

## Overview

Three unrelated gaps in the point-of-sale flow, all of them small, all of them
in the two steps a cashier spends the most time on.

**The sale lines still fight a burst of taps.** Spec 026 gave the delivery
step's quantity control a pending local value, a ~400 ms debounce that
coalesces a burst of taps into one write, and controls that stay live while a
request is in flight. The capture step never got any of it: every press of −/+
on a sale line fires its own request and inerts the whole line — quantity,
warehouse, discount and tax — until the round trip settles. Holding + on a
line of 30 units means 30 requests and 30 freezes. The behaviour that fixed
this already exists, thirty lines away, as a private control inside
`destination_card.dart`. This feature extracts it once and uses it in all
three places.

**A half-typed quantity looks accepted.** Today a cashier who types `25` over
a quantity and then clicks away — to the warehouse picker, to the next line,
to the payment step — leaves `25` sitting in the field while the line, the
totals and the server all still say `7`. Nothing was confirmed and nothing
warned. The field must return to the value that is actually on the line, and
must do it visibly enough that the cashier registers that their typing was
discarded rather than saved.

**A destination cannot be corrected, and the store's share cannot be read.**
The mock draws an `edit` action in every destination card header, before the
delete action and the chevron; it never reached the Flutter UI, so a wrong
address, a wrong recipient or a wrong delivery date can only be fixed by
cancelling the destination and building it again — losing every line
assignment with it. The endpoint for the edit has existed since spec 026
(`PUT /delivery-orders/{id}`, already wired down to the repository) and is
simply never called. The same mock draws an `expand_more` chevron on the
"Recoge en tienda" row, which in the product is a flat, unopenable card: the
cashier can see *that* 18 units stay at the store but not *which* ones.

None of the three needs a backend change, a new dependency or codegen.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Step a line's quantity as fast as I can tap (Priority: P1)

A cashier adds a product to the sale and needs 24 of it. They hold or
repeatedly tap the + control on the line. The number in the field follows
every press immediately, the line stays live throughout — they can keep
tapping, and can change the warehouse in the middle of it — and one write of
the final quantity reaches the server once they stop. The line total, the
sale's totals and any stock warning settle on the figure they stopped at.

**Why this priority**: It is the single most-used control on the busiest
screen, and today it is the slowest. It also removes a duplicate
implementation of the same behaviour, which is what keeps items 1 and 2 from
having to be built twice.

**Independent Test**: Tap + five times in quick succession on a sale line and
confirm the field reads the fifth value throughout, that the controls never
grey out mid-burst, and that the line ends at the fifth value.

**Acceptance Scenarios**:

1. **Given** a sale line of 1 unit, **When** the cashier taps + five times
   within one debounce window, **Then** the field shows 2, 3, 4, 5, 6 as they
   tap, the controls stay enabled throughout, and the line settles at 6.
2. **Given** a sale line of 3 units, **When** the cashier taps − once,
   **Then** the field shows 2 immediately and the line settles at 2.
3. **Given** a sale line of 1 unit, **When** the cashier taps −, **Then**
   nothing is sent and the field stays at 1 — a line's quantity cannot reach
   zero on the capture surface (a line is removed with its delete action, not
   by stepping it down).
4. **Given** a quantity change still waiting out its debounce window,
   **When** the cashier leaves the capture step or the line is removed from
   the screen, **Then** the pending change is still sent — nothing typed or
   tapped is silently lost.
5. **Given** a destination card on the delivery step, **When** the cashier
   uses its stepper, **Then** it behaves exactly as it does today, including
   its ceiling of what the line still owes plus what this destination already
   holds.

---

### User Story 2 - Know when my typing was discarded (Priority: P1)

A cashier types a new quantity into a line's field and then, without pressing
Enter, clicks the warehouse picker (or another line, or the continue button).
The typed text is discarded and the field animates back to the quantity the
line actually carries, with a brief pulse that makes the reversal obvious.
Nothing was sent; nothing was quietly changed.

**Why this priority**: The current silence is a correctness problem dressed as
a UI nit — the screen shows a figure the sale does not have, right next to the
total the cashier is about to charge.

**Independent Test**: Type over a quantity, click elsewhere without pressing
Enter, and confirm the field animates back to the original value and that the
line was never updated.

**Acceptance Scenarios**:

1. **Given** a line of 7 units, **When** the cashier types `25` and moves
   focus away without pressing Enter, **Then** the field animates back to 7
   and the line stays at 7.
2. **Given** a line of 7 units, **When** the cashier types `25` and presses
   Enter, **Then** 25 is confirmed and sent, and no reset animation plays.
3. **Given** a line of 7 units, **When** the cashier types `abc` (or a value
   outside the control's allowed range) and presses Enter, **Then** nothing is
   sent and the field animates back to 7.
4. **Given** a typed but unconfirmed value, **When** the cashier taps + or −
   instead of pressing Enter, **Then** the step is applied to the **confirmed**
   value, not to the unconfirmed text, and the field animates to that result.
5. **Given** a typed but unconfirmed value, **When** the surface is torn down
   (step change, sale closed), **Then** the typed text is discarded and never
   sent.
6. **Given** a destination card's stepper, **When** a typed value is abandoned
   or out of range, **Then** it resets with the same animation — the behaviour
   is the widget's, not one surface's.

---

### User Story 3 - Correct a destination I got wrong (Priority: P2)

A cashier has recorded a destination and assigned six lines to it, then
notices the delivery date is a day off, or that the recipient should be the
site foreman rather than the buyer. They press the edit action in that
destination's card header, the same sheet they composed it in opens with its
address, recipient, date and instructions already filled in, they change what
is wrong and save. The card's header updates in place; every line assignment
it holds is untouched.

**Why this priority**: A mistake in a destination header currently costs the
cashier the destination's whole line distribution, which is the most tedious
work on the step. High value, and the endpoint already exists.

**Independent Test**: Record a destination, assign lines to it, edit its date
through the new action, and confirm the header shows the new date while the
assigned quantities and the distribution rail are unchanged.

**Acceptance Scenarios**:

1. **Given** a destination card, **When** the cashier presses its edit
   action, **Then** the destination composer opens — as a side sheet at the
   two-region tier and a bottom sheet below it, exactly as adding one does —
   prefilled with that destination's address, recipient, date and
   instructions.
2. **Given** the edit sheet open with a changed date, **When** the cashier
   saves, **Then** the sheet closes, that destination's header shows the new
   date, and no other destination changes.
3. **Given** the edit sheet open, **When** the cashier changes the address to
   another of the customer's addresses and saves, **Then** the card's header
   shows the new address summary without the destination list being refetched,
   and the line assignments are unchanged.
4. **Given** the edit sheet open, **When** the server refuses the change,
   **Then** the sheet stays open showing the server's own message, and the
   destination on screen still shows its previous details.
5. **Given** the edit sheet open, **When** the cashier cancels, **Then**
   nothing is sent and the destination is unchanged.
6. **Given** the store ("Recoge en tienda") row, **Then** it offers no edit
   action and no delete action — it is not a destination the cashier composed.
7. **Given** a sale being closed (the finish action is in flight), **Then**
   the edit action is unavailable, like the other destination actions.

---

### User Story 4 - See what stays at the store (Priority: P3)

A mixed sale: part of it is delivered, part of it the customer takes now. The
cashier presses the chevron on the "Recoge en tienda" row and it opens like a
destination card, listing every line of the sale with the quantity staying at
the store beside it. Nothing in it can be edited or removed — the store's
share is a consequence of what was assigned elsewhere, not something composed
here.

**Why this priority**: Purely informational, and the figure it explains is
already visible in aggregate on the row's header and in the distribution rail.
Valuable for confidence at handover, but it blocks nothing.

**Independent Test**: On a mixed sale with two lines partly assigned to a
delivery destination, expand the store row and confirm each line appears with
the quantity left for the counter.

**Acceptance Scenarios**:

1. **Given** a mixed sale whose remainder has not yet been swept, **When**
   the cashier expands the store row, **Then** every sale line is listed with
   the quantity that will stay at the store, zeros included.
2. **Given** a resumed sale that already carries a recorded store-pickup
   destination, **When** the cashier expands the store row, **Then** the same
   list is shown, drawn from that recorded destination's own quantities.
3. **Given** the store row expanded, **Then** it shows no stepper, no
   assign-all action, no edit action and no delete action.
4. **Given** the store row, **When** the cashier assigns more of a line to a
   delivery destination, **Then** the expanded list's figure for that line
   falls by the same amount, and the row's header counts follow it.
5. **Given** the store row collapsed by default, **When** it is expanded and
   the cashier then works elsewhere on the step, **Then** it stays expanded
   until they collapse it — its expansion is independent of every destination
   card's.

---

### Edge Cases

- **A pending quantity and another edit at once.** The cashier taps + and,
  before the debounce fires, changes the same line's warehouse. Both are
  writes to the same line: they must not overlap, and neither may be lost —
  the line applies them one at a time and the later one is sent against the
  result of the earlier.
- **A refused quantity.** The server refuses the coalesced write (insufficient
  stock is only a warning on this surface, but a closed sale or a stale line
  is not). The field returns to the line's actual quantity with the same
  reset animation, and the refusal is surfaced the way line-edit refusals
  already are.
- **A quantity typed, then the line changes underneath.** Another write (a
  discount edit, a re-fetched sale) replaces the line while unconfirmed text
  sits in the field. The unconfirmed text loses: the field shows the line's
  own value.
- **Stepping from an empty or non-numeric field.** −/+ act on the last
  confirmed value, never on unparseable text, so a cleared field cannot turn
  a tap into an error.
- **Editing a destination whose address list changed.** The customer's
  addresses are re-read when the sheet opens; a destination pointing at an
  address that no longer exists opens with nothing preselected and cannot be
  saved until an address is chosen.
- **An edit that changes nothing.** Saving without touching a field leaves the
  destination exactly as it was, and is not an error.
- **Clearing an optional field.** Removing a recipient or a date that was
  previously set is **not** offered by this feature (see Assumptions) — the
  sheet has no "clear" affordance today and none is added.
- **A store row with nothing at the store.** A mixed sale that has been fully
  assigned to delivery destinations shows the row (it always does on a mixed
  sale) with zero lines and zero units; expanded, it lists the sale's lines
  with zero against each.
- **A single line split three ways.** Its store figure is what is left after
  every destination's share, and the expanded list, the row's header counts
  and the distribution rail all agree on it.
- **Larger text sizes and narrow widths.** The stepper and the expanded store
  list must hold at the product's compact tier and at the larger text-size
  levels without clipping or horizontal scrolling.

## Requirements *(mandatory)*

### Functional Requirements

**One quantity control (US1)**

- **FR-001**: The system MUST provide a single quantity-stepper control —
  a decrement action, an editable value, an increment action — used by the
  wide sale-line row, the compact sale-line card, and the delivery
  destination card. There MUST NOT be two implementations of the stepping,
  debouncing or reset behaviour.
- **FR-002**: The control MUST render the value the cashier last stepped or
  confirmed immediately, before any write reaches the server, and MUST step
  from that value rather than from the server's older copy.
- **FR-003**: Consecutive steps within a short window (~400 ms, the delivery
  step's existing window) MUST be coalesced into a single write of the final
  value.
- **FR-004**: The control MUST stay interactive while a write is in flight;
  a step taken during a flight MUST be applied after it rather than dropped.
- **FR-005**: A write still pending when the control is removed from the
  screen MUST be sent, not discarded.
- **FR-006**: Writes for the same line MUST NOT overlap: at most one is in
  flight at a time, and a newer value supersedes an older pending one.
- **FR-007**: The control MUST accept a lower bound and an optional upper
  bound from its host. On the capture surface the bound MUST be a floor of
  one unit with no ceiling (stock remains a non-blocking warning, unchanged).
  On the delivery surface the existing ceiling — what the line still owes plus
  what this destination already holds — MUST be preserved, along with its
  floor of zero and its drop-to-zero behaviour.
- **FR-008**: A step that would cross a bound MUST NOT be sent, and the
  action that would cross it MUST be unavailable rather than silently inert.
- **FR-009**: Adopting the control MUST NOT change what else a sale line
  does: the warehouse picker, the read-only price, the discount field, the
  tax picker, the delete action, the stock-shortfall warning and its
  adjust-to-available action all keep their current behaviour, including
  becoming read-only when the sale is no longer editable.

**Confirming and discarding a typed value (US2)**

- **FR-010**: Typed text MUST be confirmed only by an explicit submit
  (pressing Enter). Stepping with −/+ confirms through the debounce as in
  FR-003.
- **FR-011**: When the control loses focus, or is removed from the screen,
  with typed text that was never confirmed, the system MUST discard that text
  and restore the last confirmed value. Nothing is sent.
- **FR-012**: A confirmed value that is unparseable, or outside the control's
  bounds, MUST be discarded and the last confirmed value restored. Nothing is
  sent.
- **FR-013**: A restore under FR-011 or FR-012 MUST be animated: the
  displayed value cross-fades from the discarded text to the restored value,
  accompanied by a brief colour emphasis of the control that returns to its
  resting appearance, over roughly a quarter of a second.
- **FR-014**: The reset animation MUST NOT play when a value is confirmed and
  accepted, so that the animation means exactly one thing: "what you typed
  was not kept".
- **FR-015**: A step taken while unconfirmed text is in the field MUST be
  computed from the last confirmed value, and MUST leave the field showing
  that result.
- **FR-016**: The colours and durations of the animation MUST come from the
  design system, not from literal values in the widget, and the animation
  MUST respect the platform's reduced-motion preference by settling on the
  restored value without motion while keeping the colour emphasis.

**Editing a destination (US3)**

- **FR-017**: Each addressed destination card MUST offer an edit action in its
  header, placed before the remove action and the expansion chevron, matching
  the mock's own order.
- **FR-018**: The edit action MUST open the destination composer prefilled
  with that destination's address, recipient, delivery date and instructions,
  presented exactly as adding a destination is: a right-anchored side sheet at
  the two-region tier, a full-width bottom sheet below it.
- **FR-019**: The sheet MUST make plain that it is editing rather than adding
  — its title and its confirm action say so — and MUST offer the same address,
  recipient and date pickers, restricted to the sale's customer's own records,
  as the add flow does.
- **FR-020**: Saving MUST update only that destination's header details
  through the existing update endpoint, MUST leave its line assignments
  untouched, and MUST NOT create a second destination.
- **FR-021**: On success the destination's card MUST show the new details —
  including its re-resolved address and recipient labels — without the
  destination list being refetched.
- **FR-022**: A refused save MUST keep the sheet open with the server's own
  message and leave the destination, and every other destination, unchanged.
- **FR-023**: The store row MUST NOT offer an edit action, and MUST keep
  offering no remove action.
- **FR-024**: The edit action MUST be unavailable while the sale is being
  closed, consistent with the card's other actions.

**The store row (US4)**

- **FR-025**: The store row MUST be expandable and collapsible, with the same
  chevron affordance and expansion behaviour as a destination card, starting
  collapsed, and with its own expansion state independent of every card's.
- **FR-026**: Expanded, it MUST list every line of the sale with the quantity
  staying at the store beside it, zeros included, in the sale's own line
  order.
- **FR-027**: The quantity shown per line MUST be the total that will be at
  the store: what a recorded store-pickup destination already holds for that
  line, plus any of that line still unassigned to any destination.
- **FR-028**: The row's header counts (lines and units) MUST agree with the
  body's figures by construction — the header and the body MUST read from one
  computed source, never from two.
- **FR-029**: The expanded rows MUST be read-only: no stepper, no assign-all
  action, no edit and no remove.
- **FR-030**: The expanded list MUST update as assignments change elsewhere on
  the step, without the row having to be collapsed and reopened.

**Cross-cutting**

- **FR-031**: All new user-visible text MUST be localized in both language
  files, authored in es-MX first, with no literal strings in widgets.
- **FR-032**: All three changes MUST hold at the product's compact, expanded
  and large tiers, and at the larger text-size levels, with no horizontal
  scrolling and no clipped text.
- **FR-033**: No mbe-api change, no client regeneration and no new dependency
  is introduced; every server interaction uses an endpoint the client already
  calls or already exposes.

### Key Entities

- **Quantity stepper**: a reusable control holding a *displayed* value, a
  *last confirmed* value, optional lower and upper bounds, a pending write and
  its debounce timer. It owns no domain state; the surface hosting it owns
  what the value means.
- **Destination header**: the editable part of a delivery destination —
  address, recipient, delivery date, instructions — as distinct from its line
  assignments, which this feature never touches.
- **Store share**: per sale line, the quantity that will be handed over at the
  counter: the recorded store-pickup destination's share plus whatever is
  still unassigned.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Ten rapid presses of + on a sale line produce exactly one
  quantity change on the sale, and the displayed figure never lags behind the
  presses.
- **SC-002**: No control on a sale line becomes unavailable as a result of
  stepping its quantity; the cashier can change the line's warehouse in the
  middle of a burst of taps.
- **SC-003**: A quantity typed and abandoned without confirmation never
  reaches the sale, in 100% of attempts, and the field always ends showing the
  sale's own figure.
- **SC-004**: In an unprompted trial, a cashier who abandons a typed quantity
  can say afterwards that the value was not saved — the reset is noticed
  without being explained.
- **SC-005**: A wrong delivery date, recipient or address on a destination can
  be corrected in under 20 seconds without losing a single line assignment;
  today it cannot be corrected at all.
- **SC-006**: After a destination is edited, the number of destinations on the
  sale is unchanged and every assigned quantity is identical to before the
  edit.
- **SC-007**: For any sale, the units listed in the expanded store row sum to
  the units shown on its collapsed header, and to the store's share in the
  distribution rail — verified across a mixed sale, a resumed sale with a
  recorded store destination, and a fully-assigned sale.
- **SC-008**: The three surfaces render without overflow at the narrowest
  supported width and at the largest supported text-size level.
- **SC-009**: The stepping, debounce and reset behaviour exists in exactly one
  place in the codebase, and all three host surfaces exercise it.

## Assumptions

- The delivery step's existing debounce window (~400 ms) is the right one for
  the capture step too; it was tuned by hand against a live register and is
  not re-derived here.
- "Left without confirmation" includes losing focus by any means — clicking
  another control, tabbing away, closing the surface — and does not include a
  successful Enter.
- The capture surface's quantity floor is one unit: a line is removed with its
  own delete action, and stepping down to zero is not a way to remove it.
- The discount field, the price field and the tax picker keep their current
  commit behaviour; the confirm-and-reset rule in this feature applies to the
  quantity stepper only (see Out of Scope).
- Editing a destination submits the header as the sheet shows it. Clearing a
  recipient or a date that was previously set is not offered, because the
  sheet has no clear affordance today; whether the update endpoint even
  distinguishes "unset" from "unchanged" is a question for the design phase,
  not a promise of this spec.
- The existing "Editar" and "Guardar" strings are reused where they fit; only
  genuinely new text (an edit-sheet title, the store row's body heading) needs
  new keys.
- The store row's counts today read from one of two sources depending on
  whether a store-pickup destination exists; FR-027/FR-028 make that one sum,
  which reduces to today's figure in each of the two single-source cases.
- Widget tests are the primary verification for the reset animation, the
  debounce coalescing and the store row's two sources; the destination edit
  path is additionally checked against a live backend, as spec 026's delivery
  work was.

## Dependencies

- **`PUT /delivery-orders/{id}`** — already implemented in mbe-api and already
  exposed by the client's delivery-order repository (`updateHeader`); this
  feature is its first caller. No new endpoint, no new field.
- **Spec 026's delivery surface** — the debounced stepper being extracted, the
  destination composer being reused, the counter row being made expandable and
  the distribution rail that must keep agreeing with them all ship from it.
- **Spec 023's capture surface** — the sale-line row's fixed-height control
  band and its column sizing constrain how the shared stepper may be styled at
  the wide tier.
- **Spec 028's presentation rules** — spacing, formatting and typography for
  every new or moved widget come from the design system it consolidated.

## Out of Scope

- Any change to what a sale line writes besides its quantity — price stays
  read-only, discount and tax keep their current fields and commit behaviour.
- Extending the confirm-and-animated-reset rule to the discount field or to
  other numeric fields elsewhere in the product.
- Editing a destination's **line assignments** through the sheet; those stay
  on the card's own stepper.
- Editing or removing the store row's share directly; it remains a
  consequence of what is assigned elsewhere.
- Recording an edit history or showing who changed a destination.
- Any change to how the remainder is swept at close, to the finish gate, or to
  the distribution rail's own layout.
- Persisting a control's expansion state across sessions or step changes.

## Verbatim Constraints

The following are quoted from the request and are binding:

1. "the quantity field that is currently used at the sales order lines … to be
   replaced with the stepper that is used at the [delivery step]. This will
   make it inherit the debounce behavior that was recently implemented."
2. "make this widget reset its value if the text field is left without value
   confirmation (currently the value is confirmed if user presses enter when
   the value is affected through the text field)."
3. "Add a transition animation of the value's reset to let user acknowledge
   this change easily."
4. "Add edit button to [`destination_card.dart`] so user can edit destination
   details. This button is in the mock … but didn't reach the final UI."
5. "Make the [`destination_counter_row.dart`] expandible too, so users can have
   a better picture of the qty that is delivered at store. This is the only
   destination that is not editable and can't be removed."
