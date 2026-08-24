# Phase 0 Research: POS Sale & Delivery Refinements

**Feature**: 030-pos-sales-refinements | **Date**: 2026-08-20

Twelve findings. Four of them contradict a naive reading of the spec: the
shared control cannot live where the constitution's letter would put it (R1),
the widget alone cannot own the behaviour without losing an existing instant
affordance (R2), the design system has no motion scale for FR-016 to draw on
(R4), and "clearing a destination's optional field" is refused by mbe-api
itself, not merely unbuilt in the client (R9).

---

## R1 — Where the shared quantity control lives

**Decision**: `lib/features/sales/presentation/widgets/quantity_stepper.dart`
— module-local shared widget, not `lib/core/widgets/`.

**Rationale**: the control does exact decimal-string arithmetic (`+1`, `−1`,
compare, clamp) and the one correct implementation of that in this codebase is
`lib/features/sales/domain/money.dart` (`addAmounts`, `subtractAmounts`,
`compareAmounts`, `isZeroAmount`) — a sales-feature file, imported by 17 files
today, and deliberately "the one file in the feature that imports
`package:decimal`". Putting the widget in `core/widgets/` makes `core` import
`features/sales/domain`, or forces money.dart's generic half into `core/` as a
cross-cutting refactor this feature does not need. Both consumers — the
capture lines and the delivery destination card — are the sales module, and the
module already holds shared widgets of exactly this kind
(`presentation/widgets/customer_address_picker.dart`,
`denomination_count_table.dart`).

**Constitutional note**: §VI says "Shared data tables, formatted fields, date
pickers, status badges, and form-field wrappers MUST live in `core/widgets/`
rather than being reimplemented per module." A quantity stepper is arguably a
form-field wrapper, so this is recorded in the plan's Complexity Tracking
rather than waved through. The rule's stated purpose — "avoids four
slightly-different implementations across sales/inventory/invoicing/
accounting" — is served: there is one implementation, and the module boundary
is the only thing that differs. Promotion to `core/widgets/` is a two-line
move the day a second module needs it, and would carry money.dart's generic
helpers with it.

**Alternatives considered**: `core/widgets/quantity_stepper.dart` with a
`core → features/sales/domain` import (precedent exists —
`core/widgets/label_multi_picker.dart` imports a catalog entity — but each such
import is a layering debt, and this one buys nothing today); duplicating the
decimal helpers inside a core widget (rejected: two ways to add two numbers).

---

## R2 — One widget, or a widget plus a controller

**Decision**: two collaborators in one file — `QuantityStepperController`
(a `ChangeNotifier` owning value, pending write, debounce, bounds and the
reset signal) and `QuantityStepper` (a `StatelessWidget`-shaped view owning
the pill/field chrome, focus handling and the reset animation). Hosts create
one controller per line and dispose it with their own `State`.

**Rationale**: three host needs cannot be met by a `value` + `onCommit` widget
alone.

1. **Host-driven sets that must feel instant.** Two existing affordances set a
   quantity without a tap on the stepper: the delivery card's "assign
   everything still pending" (`destination_claim_all_*`) and the capture row's
   "adjust to available" under a stock shortfall. Today both land in the field
   immediately. With display state private to the widget, the host could only
   set them by round-tripping the server and waiting for a new `value` — a
   regression against spec FR-002 ("MUST render the value the cashier last
   stepped or confirmed immediately").
2. **Bounds that move.** The delivery ceiling is `claimable + already held`,
   recomputed on every rebuild of the card. A controller takes a new ceiling
   without discarding a pending write.
3. **Testability.** Debounce coalescing (FR-003), write serialization (FR-006)
   and the value-precedence rule (R7) become unit-testable without pumping a
   widget tree — which matters because they are the parts most likely to
   regress silently.

The split also keeps the animation where it belongs: the controller says *a
reset happened*, the widget decides what that looks like.

**Alternatives considered**: widget-only with `value`/`onCommit` (rejected:
loses instant claim-all, and pushes the debounce back into both hosts, which
is the duplication FR-001 exists to remove); a `GlobalKey<_QuantityStepperState>`
handle for host-driven sets (rejected: works, but a `ChangeNotifier` is the
idiom every Flutter developer already reads correctly, and Flutter's own
`TextEditingController`/`ScrollController` set the precedent); keeping the
pending/debounce maps in each host and sharing only the chrome (rejected: two
implementations of the behaviour, which is exactly what FR-001 forbids).

---

## R3 — The commit contract

**Decision**: `Future<bool> Function(String value) onCommit` — the host
performs the write, surfaces its own refusal, and returns `false` when the
value was not accepted. The controller then restores the last accepted value
and raises the reset signal.

**Rationale**: the two hosts surface refusals differently and must keep doing
so. `DestinationCard` renders the server's own message under the offending
line (`posDeliveryAssignmentRefused`); the capture line silently restores the
last accepted values and re-keys its pickers (`SaleLineEditing.update`'s
`catch`). A contract that let the exception escape into the controller would
force one of those behaviours onto both. A `bool` keeps error *policy* in the
host and error *display state* (the value on screen) in the controller, which
is the only thing the controller can honestly own.

**Alternatives considered**: `Future<void>` and let it throw, controller
catches and resets (rejected: the host then cannot both handle and observe the
error without rethrowing, and a rethrow inside a debounce timer is an
unhandled async error); returning the server's accepted value as
`Future<String?>` (rejected: neither host knows the accepted value
independently of the state it already updates — the delivery controller
replaces the destination, the sale controller replaces the whole sale).

---

## R4 — The reset animation, and the motion-token gap

**Decision**: one `AnimationController` at **250 ms** per stepper instance.
The value is faded out and the restored value faded in through it (the text is
swapped at the animation's midpoint, so the two never overlap and no second
copy of the field is laid out), while a `ColorTween` tints the control's
background from its resting colour to `colorScheme.errorContainer` and back.
Under `MediaQuery.disableAnimationsOf(context) == true` the value is restored
without motion and the tint is applied and cleared on the same schedule
(spec FR-016).

**Rationale**: the value lives inside a `TextField`, and there is no way to
cross-fade two strings *inside* one — the practical options are to fade the
field through zero opacity and swap at the bottom (one field, no duplicate
metrics, works identically in both skins of R5), or to stack a static `Text`
over the field and fade between them (two sets of text metrics to keep aligned
at four text-size levels, for no visible gain). `errorContainer` is the
container role for "this did not stick"; the spec's own accepted option named
it. Flutter 3.44 (this project's toolchain) exposes
`MediaQuery.disableAnimationsOf`, so reduced motion needs no shim.

**The gap**: spec FR-016 requires the animation's colours *and durations* to
come from the design system. `lib/core/design/` (spec 022) defines spacing,
shape, elevation, density and type-role scales — and **no motion scale**;
`grep -rn "Duration" lib/core/design/*.dart` returns nothing, and the app's
existing animations carry literal durations at their call sites
(`destination_card.dart`'s `AnimatedSize`, the delivery side sheet's
`transitionDuration`, both 200 ms). Two ways to satisfy FR-016:

- add a `Motion` theme extension to `core/design/` and route the two new
  durations through it — a design-token change, i.e. spec 022's territory,
  which would then leave every existing literal inconsistent with it; or
- declare the durations as named constants in the shared stepper file, so the
  feature has one source for them rather than three call sites.

**Chosen**: the second, recorded in the plan's Complexity Tracking as a
partial satisfaction of FR-016 — colours come from the theme (`colorScheme`),
durations come from one named constant in one file. A motion scale for the
whole product is a separate, product-wide job, and inventing one for two
durations would leave the design system less coherent, not more.

---

## R5 — Two skins, and why the capture step must look identical

**Decision**: `QuantityStepper` takes an optional `InputDecoration` and a
`dense` flag. With no decoration it draws the delivery pill (44 px, filled,
outlined, `xlRadius`). With one, it renders the plain `TextField` the capture
tiers use today, inside the host's own fixed-height band.

**Rationale**: the capture surface's control band is load-bearing. Spec 023
FR-038a requires every control in a line — warehouse, quantity, price,
discount, tax — to be the same height, on one baseline, in one text style, and
the unit rides inside the quantity field's floating label (`Cant. (Pza)`)
precisely because a column of its own cost more than it earned. Dropping the
delivery pill into that band would take the label with it, break the shared
baseline the constitution §VI requires of a control band, and force
re-baselining of all four capture goldens
(`test/golden/goldens/pos_sale_line_{light,dark}_{narrow,wide}.png`). The
`dense` flag preserves the wide row's deliberate 32 px shrink-wrapped stepper
buttons (below Material's 48 px target, justified in `sale_line_row.dart` for
pointer-only widths) while the compact card and the delivery pill keep
Material's full touch target.

**Consequence, stated as a goal**: at the default text-size level the capture
line renders byte-identically after the swap, so **no golden is re-baselined**.
A golden diff on `pos_sale_line_*` is a signal that the swap changed something
it should not have, not a file to regenerate.

**Precedent**: this is the same idiom `SaleLineEditing` already uses for its
two pickers — `warehousePicker({InputDecoration? decoration, TextStyle? style})`
— where each tier supplies the sizing and the behaviour is shared.

---

## R6 — Capture-side writes: `_busy`, and the ordering hazard

**Decision**: quantity commits stop going through `SaleLineEditing.update`'s
`_busy` gate. `_busy` keeps guarding the fields that still block (discount,
tax, warehouse). All writes for one line — quantity included — are serialized
through one per-line async queue in the mixin.

**Rationale**: `PosSaleController.updateLine` returns *the whole sale* and
assigns it to `state`. Two overlapping writes therefore race at the level of
the entire document: the later response wins and silently reverts the earlier
change, even though both were accepted server-side. Today that cannot happen
because `_busy` inerts the line for the whole round trip; removing `_busy`
from the quantity path (FR-004 requires the control to stay live) removes that
accidental protection, so FR-006's "writes for the same line MUST NOT overlap"
has to be made explicit. A `Future` chain — `_writes = _writes.then(...)` — is
sufficient and needs no new dependency: the debounce already guarantees at
most one *pending* quantity, so the queue never grows past a couple of entries.

**Alternatives considered**: keep `_busy` for quantity too (rejected: fails
FR-004, and is the freeze the feature exists to remove); optimistic local sale
state (rejected: a second source of truth for the sale, for a race a queue
already closes).

---

## R7 — Whose value wins when the server's changes underneath

**Decision**, in precedence order, when a new authoritative value arrives:

| Controller state | New server value | Outcome |
|---|---|---|
| Pending commit (stepped or Enter-confirmed) | any | Pending value stays displayed; it is newer than the server's copy. |
| No pending, unconfirmed typed text | differs | Typed text is discarded, new value displayed, **reset animation plays**. |
| No pending, no typed text | differs | New value displayed, no animation. |
| Pending commit just accepted | equals pending | Pending cleared, no animation. |
| Pending commit refused (`onCommit → false`) | unchanged | Last accepted value restored, **reset animation plays**. |

**Rationale**: the capture line rebuilds on *any* change to the sale — a
discount edit, a tax change, a re-fetch — and each rebuild pushes
`line.quantity` at the controller. Without the first row of that table, a
discount edit landing mid-burst would yank the quantity back to the server's
older figure while the cashier is still tapping. Without the second, typed
text that was never confirmed would survive a change it knows nothing about
and keep showing a figure the sale does not have (the exact defect US2
exists to fix). Both are exercised by the spec's own edge cases.

---

## R8 — Flush on teardown, discard on abandonment

**Decision**: the controller's `dispose()` cancels the debounce and fires any
**pending commit** (fire-and-forget, wrapped so a throw cannot escape
`dispose`), and discards any **unconfirmed typed text** without sending it.

**Rationale**: this is spec FR-005 and FR-011 side by side, and the delivery
card already does the first half — its `dispose` sends what is pending
"because a cashier who taps + and immediately collapses the card, or leaves
the step, must not silently lose the change". Moving it into the controller
keeps that guarantee for all three hosts. The wrapping matters: the host's
`onCommit` closure reaches a Riverpod notifier through the host's `ref`, and a
whole-step teardown may dispose the host before the child, in which case the
call throws — a throw from `dispose()` is an unrecoverable framework error, so
it is caught and dropped rather than allowed to take the frame down.

---

## R9 — Editing a destination header: verified against mbe-api

Read directly from the sibling repo (`../mbe-api`) rather than inferred:

- **Route**: `PUT /api/v1/delivery-orders/{delivery_order_id}`
  (`app/api/v1/endpoints/delivery_orders.py:179`), guarded by
  `require_privilege(SystemObject.DELIVERY_ORDERS, AccessRight.UPDATE)` —
  **the same privilege** the card's existing assign/adjust/drop calls already
  require. Adding the edit action therefore reaches nothing the surface cannot
  already do, and needs no new client-side gate to stay consistent with
  §IV (the delivery step gates no action client-side today; the POS route
  itself is gated).
- **Editable only while draft**: `assert_editable` (`delivery_order_service
  .py:47`) raises **409** for any status other than `DRAFT`. The POS step only
  ever shows draft destinations, so this is a guard, not a flow — but it is the
  refusal FR-022 has to render if a destination is confirmed in another
  session.
- **`None` means "unchanged", server-side too**: `update_order` loops
  `for field in ('date','priority','ship_to','contact','comment')` and assigns
  only `if value is not None`. The generated client agrees — 
  `DeliveryOrderUpdate`'s serializer emits a field only `if object.<field> !=
  null`. So **clearing** a recipient, date or instruction is impossible
  through this endpoint from any client, at any layer.
- **No customer check on `ship_to`**: `update_order` does not verify the
  address belongs to the order's customer (unlike `add_line`, which does check
  the sale's customer). The client's own address picker is the only thing
  keeping that honest — one more reason the edit sheet reuses it rather than
  accepting an id.

**Consequence**: the spec's "clearing an optional field is out of scope" is a
description of the API, not a client shortcut. Recorded so nobody spends a
task looking for the affordance.

---

## R10 — Reuse the composer, or write an edit form

**Decision**: `DestinationEditor` grows one optional `Destination?
destination` parameter. Non-null means edit: the pickers open prefilled, the
confirm action reads `saveButton`, and `_submit` calls a new
`DeliveryController.updateDestination` instead of `addDestination`. The sheet
presentation (side sheet ≥ 1200 px, bottom sheet below, `useRootNavigator:
true`) moves out of `_openAddDestinationSheet` into one opener both paths
call.

**Rationale**: the two forms are the same four fields against the same
customer's records, with the same refusal handling and the same
tier-dependent presentation — spec 026 built all of it. A second widget would
duplicate the two pickers, the date picker, the error banner and the sheet
mechanics to change one verb. The `useRootNavigator: true` detail is not
optional and is easy to lose in a copy: the POS lives inside a
`StatefulShellBranch` with its own nested `Navigator`, which tears the sheet
down the moment the step's state changes underneath it.

**FR-021's "without refetching"**: `DeliveryController.updateDestination`
takes the server's response through the existing private `_labelled` join
(which re-resolves the address summary, contact name and phone from the
customer's own records) and replaces that one entry in `state` — the same
`_replace` path `assignLine`/`adjustLine`/`dropLine` already use. Nothing new
is fetched, and the card's header re-renders with the new address label.

**Alternatives considered**: a dedicated `DestinationHeaderEditor` (rejected,
above); inline editing in the card header (rejected: the mock draws a sheet,
and the card's header is already at its width budget with three trailing
controls).

---

## R11 — The counter row already has everything it needs

**Finding**: `DestinationCounterRow` is handed both sources it needs —
`distribution` (every sale line, with `perDestination` and `atCounter`) and
`counterDestination` — so the expanded body needs **no new plumbing** from
`delivery_step.dart`.

**Decision**: per sale line, the store's share is

```text
storeShare(line) = perDestination[counterDestination.id] ?? 0   // recorded
                 + atCounter                                    // still unassigned
```

and the header's counts are derived from that same list (`lines` = entries
with a non-zero share, `units` = their sum), satisfying FR-028 by
construction. The widget becomes a `ConsumerStatefulWidget` for its own
`_expanded` flag (independent per FR-025), reusing `DestinationCard`'s
`AnimatedSize` + `Divider` + read-only row shape.

**Behaviour change, deliberate**: today the header reads *either* the recorded
destination's counts *or* the preview's, never both. The sum reduces to
today's figure in each single-source case, and differs in exactly one
situation — a resumed mixed sale that carries a recorded counter destination
*and* still has an unassigned remainder — where today's header under-reports
what will actually stay at the store. Called out in the spec (FR-027) and
covered by a widget test with both sources non-zero.

**Note for the tasks phase**: `DestinationCard`'s `_readOnlyRow` is the row
shape to reuse, but it lives in that widget's private API. Either lift it into
a tiny shared `DestinationLineRow` or duplicate ~15 lines of layout. Lifting
is preferred; it is the same "one row shape, two hosts" argument as R1, at a
much smaller scale.

---

## R12 — The existing test surface this lands on

Verified by inspection; every one of these files exercises code this feature
changes.

| File | What it pins | Effect |
|---|---|---|
| `test/widget/features/sales/destination_assignment_test.dart` | Finds `TextField` by `Key('destination_quantity_5')`, reads `controller!.text`, enters text | The shared widget MUST keep that key **on the `TextField` itself**, and MUST expose a `TextEditingController` — not a `Text` widget |
| `test/widget/features/sales/destination_card_test.dart` | Header, expansion, counts | Header gains one trailing icon; assertions on trailing controls may need widening |
| `test/widget/features/sales/sale_line_row_test.dart` | FR-037a: no overflow at a real 1024-px `CaptureStep` | The single-row layout's 132 px quantity column must still fit the swapped control |
| `test/widget/features/sales/sale_line_symmetry_test.dart` | Symmetric insets and shared baselines in the control band | Guards R5's "look identical" goal |
| `test/widget/features/sales/pos_compact_layout_test.dart` | Compact card's quantity label | Label must survive the swap |
| `test/widget/features/sales/pos_compact_delivery_test.dart` | Absence of the stepper when read-only | Enabled/disabled wiring |
| `test/golden/pos_capture_golden_test.dart` (4 goldens) | Capture line, light/dark × narrow/wide | Must pass **unchanged** (R5) |
| `test/unit/core/formatting_guard_test.dart` | No widget formats numbers itself | The stepper's displayed value must go through `formattersProvider.field.quantity` |

**Debounce in tests**: advanced with `tester.pump(const Duration(milliseconds:
400))`; the controller's window is a single named constant so a test can
reference it instead of hard-coding 400. Unit tests for the controller drive
`Timer`s through `fakeAsync` or `FakeTimers`-free `Future.delayed` pumping —
whichever the repo's existing unit tests already use for debounced code
(`product_search_field`'s debounce is the precedent to follow).

---

## Open questions

None. The two questions that could have blocked design — how the endpoint
treats a null field (R9) and whether the design system has a motion scale
(R4) — were resolved by reading mbe-api and `core/design/` respectively, and
both resolutions are recorded above rather than deferred.
