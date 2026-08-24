# Feature Specification: Point of Sale — Write Gating & Field Discard

**Feature Branch**: `031-pos-write-gating`

**Created**: 2026-08-23

**Status**: Draft

**Input**: User description: "1. Fix issue #164. Let's check if this improvement can be planned as a reusable feature for critical operations that might require async operations control before submitting. 2. Setup a similar behavior of quantity stepper to other text fields: **The field must return to the value that is actually on the line, and must do it visibly enough that the cashier registers that their typing was discarded rather than saved.** Apply this to the discount field and check for other fields in the pos sale screens."

## Clarifications

### Session 2026-08-23

- Q: A cashier types a discount, never confirms it, and presses the step's own
  continue action. What should the press do? → A: **Ask.** Warn that there are
  unconfirmed changes that would be discarded, and offer three ways out: keep
  the new value, discard it, or go back to editing. Walking away from the field
  by any other means still discards silently, as it does today.
- Q: A stepped quantity waits out its ~400 ms coalescing window before any
  request exists. How does the step's action treat that window? → A: The
  pending change counts as outstanding for the whole window as well as for the
  write that follows it, and the window is allowed to run its course — a burst
  of taps still coalesces into one write.
- Q: Where does the gating mechanism live, given it must be adoptable outside
  point of sale? → A: As a **generic mechanism in the shared core**, with the
  point of sale as its first adopter, rather than inside the sales feature.

## Overview

Two gaps, one cause: the register can show a figure the server does not
actually hold, and nothing stops the cashier from acting on it.

**A step can be left before its edits land.** Issue #164: on the Venta step a
cashier changes a line's discount, tax, warehouse or quantity and
"Continuar al cobro" stays pressable while that change is still travelling.
Press it and the sale advances to Cobro with the pre-edit total still on
screen — and the cashier collects against it. The same shape of gap sits on
the other two steps: the payment step's "Continuar" is gated on the sale's
balance alone, so it is pressable while a payment is still being applied and
the balance it reads is the old one; the delivery step's finish action is
gated on a distribution computed from state that an assignment still in
flight has not reached yet. Nothing in the product expresses "a write is
outstanding" at a level the step buttons can see. What exists is scattered
and deliberately partial: a per-line busy flag that never leaves its own row,
a per-line write queue that only orders writes for *that* line, a payment
draft's own submitting flag, the delivery step's own closing flag — and
`PosStepController.writeInFlight`, a field added for exactly this purpose
that nothing has ever set or read. The fix is one signal per sale that every
mutating write registers in, and every step's own primary action respects.
The request also asks whether that signal should be built as a reusable
mechanism rather than a POS-only counter: any screen with a critical submit
has the same problem, and this feature builds it so they can adopt it,
without converting them here.

**A half-typed discount looks accepted.** Spec 030 gave the quantity field a
rule — typed text is confirmed by Enter and by nothing else, and text
abandoned without confirmation is discarded with a cross-fade and a colour
pulse that the cashier cannot miss — and then explicitly left every other
field out of it. The discount field is the one that most needs it. Today it
commits only on Enter, so a cashier who types `15`, clicks the warehouse
picker and moves on leaves `15` in the field while the line, the totals and
the server all still say `0`; and when the server refuses an edit, or the
text will not parse, the field is silently rewritten with no acknowledgement
at all. This feature applies spec 030's rule to the discount field on both
sale-line layouts, reusing the same behaviour and the same acknowledgement
rather than growing a second copy of it, and accounts for every other
editable field on the POS sale screens — each one either brought under the
rule or recorded as deliberately excluded, with the reason.

One boundary deliberately breaks that symmetry. Clicking another control is
walking away from a field, and the register is right to throw the typing away
behind the cashier's back — the acknowledgement is what makes that fair.
Pressing "Continuar al cobro" is not walking away: it is the last moment
before money is collected, and silently dropping a discount there is the
expensive version of the same mistake. So at a step boundary the register
asks instead of deciding: there are unconfirmed changes, keep them, discard
them, or go back to editing.

Neither item needs a backend change, a new dependency or codegen.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Never leave a step with figures that are not the sale's (Priority: P1)

A cashier lowers a line's discount and immediately reaches for
"Continuar al cobro". The edit is still on its way to the server, so the
total on screen is still the old one. The button is visibly unavailable for
the moment the write takes, and becomes available again the instant the
totals on screen are the sale's own. The cashier never collects against a
figure the sale does not hold.

**Why this priority**: This is issue #164, and it is a money bug — the
figure the cashier collects against can be wrong. It shares its priority with
the two stories that decide the same thing from the other direction (US2, US3):
what the customer is charged.

**Independent Test**: With a sale of several lines, change a line's discount
and press the step's continue action before the change settles. The action
must be unavailable while the write is outstanding, and the totals shown at
the moment it becomes available must equal the sale's own.

**Acceptance Scenarios**

1. **Given** a sale with at least one line, **When** the cashier changes a
   line's discount and the write has not yet settled, **Then** the step's
   continue action is unavailable and visibly so.
2. **Given** that same outstanding write, **When** it settles successfully,
   **Then** the totals on screen update and the continue action becomes
   available in the same moment.
3. **Given** that same outstanding write, **When** the server refuses it,
   **Then** the line returns to its previous values, the refusal is surfaced
   as line-edit refusals already are, and the continue action becomes
   available again — a failed write never leaves the step locked.
4. **Given** a quantity stepped with −/+ whose write is still waiting out its
   coalescing window, **When** the cashier presses the continue action,
   **Then** the sale does not advance on the pre-step total: the change is
   applied first and the action stays unavailable until it lands.
5. **Given** two lines edited in quick succession so both writes are
   outstanding, **When** the first settles, **Then** the continue action is
   still unavailable, and it becomes available only once the second settles.
6. **Given** an outstanding line write, **When** the cashier keeps working —
   stepping another line's quantity, changing a warehouse, scanning another
   product — **Then** none of that is blocked: only the step's own continue
   action is gated.

### User Story 2 - Know when my typing was discarded (Priority: P1)

A cashier types a discount over a line, then clicks away — to the warehouse
picker, to the next line, to the payment step — without pressing Enter. The
field returns to the discount the line actually carries, and does it with the
same brief fade and colour pulse the quantity field uses, so the cashier sees
that the typing was thrown away rather than saved. The same thing happens
when the entry will not parse, and when the server refuses it.

**Why this priority**: The failure is silent today and it is on the field
that changes what the customer pays. A discount that looks applied and is not
is discovered at the payment step, or not at all.

**Independent Test**: Type a discount into a line, click another control
without pressing Enter, and observe both the field and the sale: the field
shows the line's own discount, the acknowledgement plays, and the sale is
unchanged.

**Acceptance Scenarios**

1. **Given** a line whose discount is 0%, **When** the cashier types `15` and
   the field loses focus without Enter, **Then** the field returns to 0%, the
   acknowledgement plays, and no discount write is made.
2. **Given** the same typed `15`, **When** the cashier presses Enter,
   **Then** the discount is written, the line and the totals update, and no
   acknowledgement plays — a confirmed value is not a discarded one.
3. **Given** typed text that cannot be read as a rate, **When** the cashier
   presses Enter, **Then** nothing is sent, the field returns to the line's
   own discount, and the acknowledgement plays.
4. **Given** a confirmed discount the server refuses, **When** the refusal
   arrives, **Then** the field returns to the line's own discount with the
   acknowledgement, rather than being rewritten silently.
5. **Given** unconfirmed text in a line's discount field, **When** the line
   changes underneath for any other reason — another edit landing, the sale
   being re-read — **Then** the unconfirmed text loses and the field shows the
   line's value.
6. **Given** the device is set to reduce motion, **When** a discard happens,
   **Then** the acknowledgement is still perceptible without an animated
   transition.
7. **Given** unconfirmed text in a line's discount field, **When** the sale
   leaves the capture step by any means other than the step's own action —
   the sale being closed elsewhere, the register being reset — **Then** the
   text is discarded and never sent.

### User Story 3 - Be asked before my typing is thrown away at the till (Priority: P1)

A cashier types a discount, does not press Enter, and goes straight for
"Continuar al cobro". Rather than advancing with the old discount or
committing a value the cashier never confirmed, the register says there are
unconfirmed changes and offers three ways out: keep the new value, discard it,
or go back to editing. Whichever is chosen, what happens next is exactly what
the cashier picked.

**Why this priority**: This is the boundary where a lost discount stops being
recoverable — the next thing that happens is collecting money. It is P1 for
the same reason US1 is: it decides what the customer pays.

**Independent Test**: Type a value into a line field without confirming it,
press the step's continue action, and exercise each of the three answers;
each must produce its own outcome, and none may advance the sale on a figure
the cashier did not choose.

**Acceptance Scenarios**

1. **Given** unconfirmed text in a line field, **When** the cashier presses
   the step's continue action, **Then** the sale does not advance and the
   cashier is told there are unconfirmed changes, with the choice to keep,
   discard, or continue editing.
2. **Given** that prompt, **When** the cashier chooses to keep the value,
   **Then** it is committed exactly as pressing Enter would have committed it,
   the step's action stays unavailable until that write settles, and the sale
   advances with the new figure.
3. **Given** that prompt, **When** the server refuses the kept value,
   **Then** the sale stays on its current step, the field returns to the
   line's own value with the discard acknowledgement, and the refusal is
   surfaced as line-edit refusals already are.
4. **Given** that prompt, **When** the cashier chooses to discard,
   **Then** the text is discarded, the acknowledgement plays, and the sale
   advances with the value it actually had.
5. **Given** that prompt, **When** the cashier chooses to continue editing,
   **Then** the sale stays on its current step and the typed text is still
   there to be corrected — the choice is not itself a discard.
6. **Given** no unconfirmed text anywhere on the step, **When** the cashier
   presses the continue action, **Then** no prompt appears and the sale
   advances as it does today. The prompt never interrupts a cashier who
   confirmed their edits.
7. **Given** unconfirmed text in more than one field, **When** the cashier
   presses the continue action, **Then** they are asked once, and the answer
   applies to every unconfirmed field on the step.

### User Story 4 - The same guarantee on the other two steps (Priority: P2)

The cashier applies a payment and immediately presses "Continuar"; the
balance on screen is still the pre-payment one. On the delivery step, they
step a destination's quantity and immediately press finish while the
assignment is still travelling. In both cases the action is unavailable until
the sale's own figures are what is on screen.

**Why this priority**: Same class of defect, one step further along, and the
figures are the balance and the assigned quantities rather than the total.
It is P2 only because the capture step is where the cashier spends the most
time and where the report came from.

**Independent Test**: On each of the payment and delivery steps, start a
write and press the step's primary action before it settles; the action must
be unavailable, then available with figures that match the sale.

**Acceptance Scenarios**

1. **Given** a payment being applied, **When** the cashier presses the
   payment step's continue action, **Then** it is unavailable until the
   balance on screen is the sale's own.
2. **Given** a payment reversal in flight, **When** the cashier presses the
   payment step's continue action, **Then** it is likewise unavailable until
   the reversal settles.
3. **Given** a destination quantity just stepped, **When** the cashier
   presses the delivery step's finish action before the assignment settles,
   **Then** it is unavailable, and the finish gate is evaluated against the
   assignments the sale actually holds.
4. **Given** a destination being created, edited or removed, **When** that
   write is outstanding, **Then** the finish action is unavailable for its
   duration and available again once it settles or fails.
5. **Given** any outstanding write on either step, **When** it fails,
   **Then** the step's action becomes available again rather than staying
   locked.

### User Story 5 - One mechanism, adoptable beyond the register (Priority: P3)

A developer adding a screen whose submit must not fire while its own
background work is outstanding finds one mechanism to reach for, with no
knowledge of sales in it, and adopts it by registering that screen's writes —
without displacing the per-form submitting flags the product already uses for
their own purpose.

**Why this priority**: It is the request's own "check if this can be a
reusable feature", and it costs almost nothing to satisfy while the mechanism
is being written. It delivers no cashier-visible behaviour on its own, which
is why it is last.

**Independent Test**: Exercise the mechanism against an operation that has
nothing to do with a sale, and confirm the gate opens and closes correctly
without any sales concept present.

**Acceptance Scenarios**

1. **Given** the mechanism, **When** it is used to register an operation
   unrelated to point of sale, **Then** it reports outstanding correctly for
   that operation's duration and clears when it settles or fails.
2. **Given** the product's existing per-form submitting flags, **When** this
   feature ships, **Then** they continue to work unchanged and are not
   required to be replaced.
3. **Given** the codebase after this feature, **When** a developer looks for
   "is a write outstanding" for a POS step, **Then** there is exactly one
   answer — no second, competing flag left behind.

### Edge Cases

- **Continue pressed inside the coalescing window.** A stepped quantity that
  has been confirmed but has not yet left the client is a change the sale does
  not have yet. Pressing continue must not advance on the pre-step figures;
  the change is applied first and the transition waits for it.
- **Continue pressed with unconfirmed text in a field.** The cashier is asked
  what to do with it. The mechanics deserve care: pressing a button normally
  takes focus away from the field first, which is itself a discard — so what
  the cashier had typed must survive long enough for the question to be asked
  about it, rather than being thrown away by the very press that should raise
  the question.
- **The prompt answered with "keep" on a value the server then refuses.** The
  sale stays where it is; the field restores visibly; the cashier is not left
  on the payment step wondering what happened to their discount.
- **The prompt while a write is already outstanding.** The step's action is
  already unavailable for that reason (FR-007), so the question is not asked
  until the action is pressable again — the cashier is never asked to decide
  about typed text while the figures on screen are still moving.
- **A write that never settles.** A request that fails, times out, or is
  refused must clear the signal. There is no state in which the step's action
  is permanently unavailable while the cashier still has a sale in hand.
- **A write that lands after its own line is gone.** A line removed while an
  edit to it is outstanding: the removal and the edit are both writes on the
  same sale, so the gate covers both, and the sale's own copy is what is
  displayed once they settle.
- **Two steps' worth of writes.** A write started on one step and still
  outstanding cannot survive the transition, because the transition is what is
  gated — so the next step never opens on figures that a pending write is
  about to change.
- **A sale that stops being editable mid-edit.** The gate is additive: an
  action already unavailable because the sale is closed, because there are no
  lines, or because the balance is outstanding stays unavailable for those
  reasons, and the cashier is not told a different story about why.
- **Enter pressed twice on a discount.** The second confirmation of the same
  value writes nothing and shows no acknowledgement — nothing was discarded.
- **A discount typed with a percent sign, a stray separator, or emptied
  entirely.** Unreadable input is discarded with the acknowledgement, never
  sent and never silently coerced to zero.
- **Larger text sizes and the compact tier.** The acknowledgement must play
  inside the sale-line control band at the wide tier and inside the stacked
  card at the compact tier, at the largest supported text size, without
  clipping or shifting the band's layout.

## Requirements *(mandatory)*

### Functional Requirements

**One outstanding-writes signal (US1, US4)**

- **FR-001**: The system MUST maintain one signal per sale expressing whether
  any change to that sale is outstanding — begun and not yet settled.
- **FR-002**: The signal MUST support concurrent writes: it MUST count them
  rather than hold a single yes/no, so overlapping edits on different lines
  each register and the signal reports "outstanding" until the last of them
  settles.
- **FR-003**: Every operation that changes the sale MUST register in the
  signal for the whole time it is outstanding. This includes, at minimum:
  adding a line, changing a line (quantity, discount, tax, warehouse),
  removing a line, changing the sale's header, confirming the sale, applying
  and reversing a payment, and every delivery-side write (creating, editing
  and removing a destination, assigning a line to one, and sweeping the
  remainder).
- **FR-004**: A change the cashier has confirmed that has not yet left the
  client — one still waiting out its coalescing window — MUST count as
  outstanding for the whole of that window as well as for the write that
  follows it. The window MUST be allowed to run its course rather than being
  cut short by the gated action, so a burst of taps still coalesces into a
  single write. In no case may a step transition be evaluated against figures
  such a change is about to alter.
- **FR-005**: Text the cashier has typed but not confirmed MUST NOT count as
  outstanding — it is not a change to the sale, and it MUST NOT by itself make
  a step's action unavailable. What it does instead is raise a decision when
  that action is pressed (FR-024 … FR-031).
- **FR-006**: The signal MUST clear when a write settles, whether it
  succeeded or failed. A refused, failed or abandoned write MUST NOT leave a
  step's action permanently unavailable.
- **FR-007**: Each step's own primary action — the capture step's continue,
  the payment step's continue, and the delivery step's finish — MUST be
  unavailable while the signal reports outstanding, in addition to every
  condition that already gates it, and MUST become available again as soon as
  it clears.
- **FR-008**: That unavailability MUST be visible on the action itself rather
  than expressed only as a slow response, and MUST reuse the busy treatment
  those actions already have for their own submissions.
- **FR-009**: The gate MUST NOT extend to the rest of the surface: sale lines
  stay editable, quantity steppers stay live through their own writes, and
  products can still be scanned and added while a write is outstanding.
- **FR-010**: Exactly one mechanism in the codebase MUST express "a write is
  outstanding" for the POS steps. The existing unused write-in-flight flag
  MUST be either wired to this mechanism or removed; two competing
  mechanisms MUST NOT remain.
- **FR-011**: The mechanism MUST live in the product's shared core, reachable
  by any feature, rather than inside the sales feature. It MUST NOT depend on
  sale-specific concepts, MUST be adoptable by a critical action on any screen
  without copying it, and MUST coexist with the product's existing per-form
  submitting flags rather than requiring them to be replaced.
- **FR-012**: Registering a write MUST NOT change what that write does, what
  it returns, or how its refusals are surfaced.

**Typed values confirm or visibly discard (US2)**

- **FR-013**: On the sale line's discount field, at both the wide-row and the
  compact-card layout, typed text MUST be confirmed only by an explicit
  submit (pressing Enter).
- **FR-014**: When that field loses focus, or its surface is torn down, with
  typed text that was never confirmed, the system MUST discard the text and
  restore the discount the line actually carries. The text MUST NOT be sent.
- **FR-015**: A discard MUST be acknowledged perceptibly — the same
  cross-fade of the old value out and the restored value in, with the same
  brief colour pulse and the same duration the quantity field's reset already
  uses.
- **FR-016**: Typed text that cannot be read as a valid discount MUST be
  discarded with the same acknowledgement, and MUST NOT be sent.
- **FR-017**: A confirmed discount the server refuses MUST restore the line's
  own value with the same acknowledgement, instead of being rewritten
  silently as it is today.
- **FR-018**: When the line changes underneath for any other reason while
  unconfirmed text sits in the field, the unconfirmed text MUST lose: the
  field shows the line's value.
- **FR-019**: A confirmed discount edit MUST register in the outstanding-writes
  signal (FR-003), and MUST keep its current behaviour otherwise: the line's
  other controls stay inert for the duration of that write, exactly as today.
- **FR-020**: The confirm-or-discard rule and its acknowledgement MUST exist
  in one place in the codebase, shared with the quantity field, rather than
  reimplemented for the discount field.
- **FR-021**: Adopting the rule MUST NOT change the discount field's
  appearance, its position in the control band, its keyboard type, or the
  layout of the line at any width or text size.
- **FR-022**: Every editable field on the POS sale screens that displays a
  value the server already holds MUST either follow the confirm-or-discard
  rule or be recorded in this specification as deliberately excluded, with the
  reason. The audit MUST cover the capture, payment and delivery steps.
- **FR-023**: A field that holds no server value — a search box, a
  free-text reason on a dialog, a form field committed by an explicit save —
  MUST NOT be changed by this feature.

**Leaving a step with unconfirmed text (US3)**

- **FR-024**: When a step's primary action is pressed while any field on that
  step holds unconfirmed text, the system MUST NOT advance, MUST NOT discard
  the text silently, and MUST NOT commit it silently. It MUST tell the cashier
  there are unconfirmed changes and let them choose.
- **FR-025**: That choice MUST offer exactly three outcomes: keep the typed
  value, discard it, or return to editing.
- **FR-026**: Keeping the value MUST be indistinguishable from having
  confirmed it in the field: the same write, the same registration in the
  outstanding-writes signal, and the same handling of a refusal. The step MUST
  advance only once that write has settled successfully; a refusal MUST leave
  the sale on its current step with the field restored and the refusal
  surfaced.
- **FR-027**: Discarding MUST restore the line's own value with the same
  acknowledgement any other discard plays (FR-015), and MUST then let the step
  advance.
- **FR-028**: Returning to editing MUST leave the typed text intact and the
  sale on its current step — that answer is not itself a discard.
- **FR-029**: The prompt MUST appear only when unconfirmed text actually
  exists on the step. A cashier who confirms their edits MUST never see it, and
  it MUST NOT appear for a value that is merely still being written to the
  server.
- **FR-030**: With unconfirmed text in more than one field, the cashier MUST be
  asked once, and their answer MUST apply to every unconfirmed field on that
  step.
- **FR-031**: Leaving a field by any means other than the step's own action —
  clicking another control, tabbing away, the surface being torn down — MUST
  keep discarding silently with the acknowledgement (FR-014). The prompt is a
  step-boundary behaviour, not a replacement for that rule.

### Key Entities

- **Outstanding-writes signal**: per sale, how many changes to it have begun
  and not yet settled, including changes confirmed locally but not yet sent.
  It carries no information about *which* write or *what* it changes — only
  that the sale on screen may not yet be the sale the server holds.
- **Step action gate**: the set of conditions under which a step's primary
  action is available. This feature adds one condition to each of the three;
  it does not change the others.
- **Editable field value**: for a field that mirrors a server value — the
  text on screen, the value the line actually carries, and the rule that
  decides which one wins when the cashier walks away.
- **Unconfirmed-changes decision**: raised when a step's action is pressed with
  typed text still unconfirmed anywhere on that step. It knows which fields are
  unconfirmed and what the cashier chose — keep, discard, or keep editing — and
  nothing else; it holds no value of its own.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: In 100% of scripted attempts to change a line and immediately
  press the step's continue action, the sale does not advance until the
  change has landed, and the totals shown when it advances equal the sale's
  own.
- **SC-002**: The continue action becomes available again in the same frame
  the totals update — no perceptible lag between the figures being right and
  the action being pressable.
- **SC-003**: After a refused or failed write, the step's action is available
  again in 100% of attempts; no sequence of failures leaves a cashier unable
  to continue a sale they could otherwise continue.
- **SC-004**: With writes outstanding on two different lines, the action
  stays unavailable until both settle — verified with concurrent edits.
- **SC-005**: No control other than the three step actions changes its
  availability as a result of this feature: a burst of quantity taps still
  leaves every line control usable, exactly as it does today.
- **SC-006**: A discount typed and abandoned without confirmation never
  reaches the sale, in 100% of attempts, and the field always ends showing the
  sale's own figure.
- **SC-007**: In an unprompted trial, a cashier who abandons a typed discount
  can say afterwards that the value was not saved — the acknowledgement is
  noticed without being explained.
- **SC-008**: The confirm-or-discard rule and its acknowledgement exist in
  exactly one place in the codebase, exercised by both the quantity field and
  the discount field.
- **SC-009**: Every editable field on the three POS sale steps is accounted
  for — in scope or excluded with a reason — with no field left unexamined.
- **SC-010**: The gating mechanism is exercised by an operation with no
  sale-specific concept in it, proving a screen outside point of sale can
  adopt it as-is.
- **SC-011**: Pressing a step's action with unconfirmed text ends, in 100% of
  attempts, in the outcome the cashier chose — never in a value saved that
  they did not confirm, and never in a value lost that they meant to keep.
- **SC-012**: Keeping a value from that prompt produces exactly the same
  result as having pressed Enter in the field: the same write, the same
  gating, the same handling of a refusal — verified by comparing both paths.
- **SC-013**: A cashier who confirms every edit never sees the prompt: across
  a scripted sale of several lines with every value confirmed, it appears zero
  times.
- **SC-014**: The capture, payment and delivery surfaces render without
  overflow, and the discard acknowledgement plays without shifting the sale
  line's layout, at the narrowest supported width and the largest supported
  text-size level.

## Assumptions

- **The gate is additive.** Each step's existing conditions — an editable
  sale with at least one line, a settled balance or credit terms, a complete
  distribution — are unchanged; this feature only adds "and nothing is
  outstanding".
- **Two different boundaries, two different behaviours, deliberately.**
  Leaving a field discards silently with the acknowledgement; pressing a
  step's own action asks first. The cost of a silent discard scales with what
  happens next, and what happens next at a step boundary is collecting money.
- **The prompt is a decision, not a warning to dismiss.** It has no default
  answer that fires on a stray tap outside it; dismissing it without choosing
  leaves the cashier where they were, with their text intact.
- **The coalescing window runs its course.** A pending change is not flushed
  early to shorten the wait; the ~400 ms window tuned in spec 026 stays as it
  is, and the step's action is unavailable for the window plus the write.
- **The acknowledgement is spec 030's, unchanged.** Its duration, its
  cross-fade and its colour pulse were tuned there and are reused rather than
  re-derived, reduced-motion handling included.
- **The discount field is not given a stepper or a debounce.** It is a typed
  field that commits on Enter; only the discard side of the quantity field's
  rule applies to it.
- **The audit's findings, on the evidence in the code today.** In scope: the
  sale line's discount field, on both layouts. Deliberately excluded, with
  reasons: the line's **price** field is read-only and takes no keystrokes;
  the line's **tax** is a picker, not a field; the payment step's **amount**
  field pushes every keystroke into the payment draft and is committed by its
  own explicit action, so its text is never at odds with a value the server
  holds; the destination editor's **address, recipient, date and comment**
  are a form saved by an explicit action, with cancel as the discard; the
  payment reversal **reason** dialog and the capture step's **product
  search** box hold no server value at all; the cash-session open and close
  forms and their denomination fields are not sale screens. If the design
  phase finds a field this audit missed, FR-022 requires it be recorded
  either way.
- **Refusals keep their current presentation.** How a refused edit is shown
  to the cashier is not changed here; what changes is that the field restores
  visibly rather than silently.
- **Widget and unit tests are the primary verification** — the gate around
  concurrent writes, the coalescing-window case, the discard rule and the
  acknowledgement are all testable without a live backend; the three steps'
  end-to-end behaviour is additionally exercised against a live backend as
  the POS work has been since spec 020.

## Dependencies

- **Issue #164** — the report this feature closes, including its own reading
  of where the in-flight knowledge currently lives.
- **Spec 030's quantity field** — the confirm-or-discard rule, its
  acknowledgement, its coalescing window and its deliberate decision to stay
  live through its own writes. This feature generalizes that behaviour and
  must not regress it.
- **Spec 023's capture surface** — the sale-line control band's fixed height
  and column sizing, which the discount field must keep.
- **Spec 025's payment step and spec 026's delivery step** — the two other
  primary actions being gated, and the delivery writes that must register.
- **Spec 028's presentation rules** — spacing, motion and formatting for
  anything new, and the dialog treatment the unconfirmed-changes question
  inherits.
- **The constitution's shared-core rules** — the gating mechanism lands in
  core by decision (FR-011), so its placement, its state-management shape and
  its independence from any feature are governed there.
- No mbe-api change, no new endpoint, no codegen, no new dependency.

## Out of Scope

- Converting the product's existing per-form submitting flags — cash-session
  open and close, the inline customer form, the destination editor — to the
  new mechanism. It must be adoptable; adopting it there is separate work.
- Adopting the mechanism on any screen outside point of sale.
- Making the line's price writable, or returning tax to a typed field.
- Giving the discount field a stepper, a coalescing window, or any commit
  path other than Enter.
- Showing locally computed totals while a write is outstanding — the sale's
  figures still come from the server.
- Queueing, retrying or persisting failed writes.
- Changing the conditions that already gate each step's action, or how server
  refusals are surfaced.
- Any change to the delivery step's remainder sweep, its finish gate's own
  completeness rule, or the distribution rail's layout.
- A global "busy" overlay or blocking spinner over the register.
- Raising the unconfirmed-changes question anywhere outside the POS steps'
  own primary actions — no navigation guard, no browser-level warning, no
  prompt on closing the window.
- Flushing a pending change early to shorten the gate's wait.

## Verbatim Constraints

The following are quoted from the request and from issue #164, and are
binding:

1. "The field must return to the value that is actually on the line, and must
   do it visibly enough that the cashier registers that their typing was
   discarded rather than saved."
2. "Apply this to the discount field and check for other fields in the pos
   sale screens."
3. "Either wire up the existing (currently unused)
   `PosStepController.writeInFlight`, or retire it in favor of the new
   counter — don't leave two competing mechanisms."
4. "Each step's primary action gated on that counter being zero, in addition
   to its existing conditions — so the button is visibly disabled (not just
   slow) while any edit is still being processed, and re-enables the instant
   state (and therefore the totals shown) catches up."
5. "check if this improvement can be planned as a reusable feature for
   critical operations that might require async operations control before
   submitting."
