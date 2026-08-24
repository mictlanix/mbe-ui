# Phase 0 Research: POS Write Gating & Field Discard

**Feature**: `031-pos-write-gating` | **Date**: 2026-08-23 | **Spec**: [spec.md](./spec.md)

Everything the spec left to the design phase, resolved against the code as it
stands on `main` (through f900684) rather than against how it is remembered.
Findings are ordered by how much they shape the work; **R4** is the one that
was measured rather than reasoned about, and **R3** and **R5** are the two
that a reviewer should push on hardest.

---

## R1 — Where the gating mechanism lives, and what shape it takes

**Decision**: a new core mechanism, `lib/core/async/critical_action_guard.dart`,
exposing two Riverpod family providers keyed by an opaque scope string:

- `pendingWritesProvider(scope)` → `int`, the number of changes begun and not
  yet settled in that scope;
- `unconfirmedEditsProvider(scope)` → the fields in that scope currently
  holding text the user has not confirmed (R5).

The point of sale declares one scope constant (`posWritesScope`) in the sales
feature and is the mechanism's first adopter. Both providers are
`@Riverpod(keepAlive: true)`.

**Rationale**: the spec's clarification puts it in core (FR-011), and the
constitution's §II leaves no room for a hand-rolled singleton — this is state
shared across widgets *and* controllers, which is exactly what §II reserves
for providers. Contrast spec 030's `QuantityStepperController`, deliberately a
plain `ChangeNotifier` because it is per-widget input state with no consumer
outside its own widget; this one has consumers in three step widgets and
writers in three controllers, so the same reasoning points the other way.

`keepAlive: true` is not decoration. An autoDisposed family entry is recreated
at zero once its last listener leaves, and the writers here (`read`, not
`watch`) do not hold it alive — a write could begin against one instance and
end against another, silently. The precedent in this codebase for
long-lived UI-wide state is the same:
[user_display_preferences_controller.dart:31](../../lib/core/settings/user_display_preferences_controller.dart#L31)
and the auth notifier both use it. The cost is one `int` per live scope.

**Alternatives considered**:

- *A counter on `PosSaleController`* — the issue's own suggestion, and the
  smallest change. Rejected: the delivery and payment writes do not go through
  that controller (`DeliveryController`, `PaymentController`), so a counter
  there could not see them, and it fails FR-011 outright.
- *A `bool`* — rejected by FR-002: spec 030 deliberately allows concurrent
  edits on different lines, so a bool is lost the moment two overlap.
- *An `AsyncValue`-shaped provider* — carries a value and an error this
  mechanism has no use for; a count is the whole state.
- *A scope-less global counter* — one register per app makes the family
  argument look redundant today, but the mechanism is meant to be adopted by
  other screens (FR-011) and two screens sharing one counter would gate each
  other's buttons.

---

## R2 — A counter alone cannot satisfy FR-004; the mechanism needs two registration modes

**Decision**: the guard registers work two ways.

- `track<T>(Future<T> Function())` — wraps an ordinary write: increment,
  run, decrement in a `finally`. This is what the three controllers use.
- `begin()` → token, `end(token)` — a **hold** for work that is outstanding
  before any future exists. `end` is idempotent, so a double release is a
  no-op rather than a counter that drifts below zero.

**Rationale**: the clarified FR-004 requires the ~400 ms coalescing window to
count as outstanding, and during that window there is no future to wrap — the
value lives in `QuantityStepperController._pending` with a `Timer` and nothing
else. Only a hold can express it. Wrapping the *timer* in a future was
considered and rejected: the window is cancelled and restarted by every tap,
so its future would be a lie about what is outstanding.

**The release must not depend on the holder being alive.** Spec 030's
`QuantityStepperController.dispose` deliberately fires a still-pending write
fire-and-forget (its FR-005), so the hold that write carries has to be
released by something that outlives the controller. Because the guard is a
keepAlive provider, attaching the release to that future
(`.whenComplete(release)`) is safe and is the contract's rule.

**Leaks are the failure mode worth designing against.** A hold never released
is a step action disabled forever, which FR-006 forbids in the strongest
terms — a register you cannot ring up a sale on. Two mitigations, both cheap:

1. every acquisition is paired in a `finally` or a `whenComplete`, never by
   hand at each exit;
2. `PosSaleController.startNew()` and `.load()` reset the scope, bounding any
   leak to the sale it happened on, and the reset asserts in debug when it
   drops a non-zero count — so a leak fails a test rather than stranding a
   cashier.

---

## R3 — What registers as a write, and what deliberately does not

**Decision**: registration goes at the controller methods, not at the
repository or the widget.

| Registers (FR-003) | Why |
|---|---|
| `PosSaleController.updateHeader`, `.addLine`, `.updateLine`, `.removeLine`, `.confirm` | every one of them republishes the whole `Sale`, so every one of them can move the totals |
| `DeliveryController.addDestination`, `.updateDestination`, `.removeDestination`, `.assignLine`/`.adjustLine`/`.dropLine`, `.sweepRemainderToCounter` | the assigned/outstanding figures the finish gate reads |
| `PaymentController.submit`, `.reverse` | the balance the payment step's own gate reads |

| Does not register | Why |
|---|---|
| `.load`, `.refresh` | reads. A refresh in flight is not a change the cashier made, and gating on it would disable the button on every poll |
| `.ensureOpen` | opens a sale; changes no figure. `addLine`'s own registration already spans the open-then-add case |
| product lookup, warehouse list, stock cache | reads feeding pickers |

**Rationale**: the controller method is the only layer that knows when the new
state has been *published*. That matters more than it looks — see the ordering
rule in R6.

**Alternative considered**: a dio interceptor counting in-flight mutating
requests. Tempting (nothing to remember to annotate) but wrong on both ends:
it cannot see the debounce window (R2), and it counts writes from screens that
have nothing to do with the sale in hand.

---

## R4 — Measured: tapping the continue button does **not** discard the typed text first

FR-024's whole premise is that the cashier's unconfirmed text is still there
to be asked about when the step action fires. Spec 030's rule discards on
focus loss, and pressing a button plausibly moves focus — which would mean the
press destroys the very thing it should ask about. This was measured rather
than argued:

```
PROBE: focus->true | --- typed, hasFocus=true --- | pointerDown hasFocus=true
      | onPressed hasFocus=true | --- after tap, hasFocus=true ---
```

A `TextField` focused and typed into, then a `FilledButton` tapped: the field
still holds focus inside `onPressed`, and no focus event fires at all. Flutter's
Material buttons take focus through keyboard traversal, not through a tap.

**Decision**: the step action's own handler reads the unconfirmed state
directly. No pointer-down snapshot, no grace window, no deferred discard — all
three were sketched before the probe and all three are unnecessary.

**The keyboard path needs nothing either**, and this is the part worth
stating: activating the button from the keyboard requires tabbing to it, and
tabbing away from the field already discarded the text by FR-031. So that path
correctly has nothing to ask about.

**Degradation if this ever changes** (a Flutter upgrade, a platform
difference on web): the discard would run first, the registry would be empty,
and the prompt would not appear — the pre-feature behaviour, not a crash. A
widget test asserting the text is still unconfirmed inside the action's
callback keeps the premise honest instead of leaving it to a comment.

---

## R5 — How the step action finds unconfirmed fields (FR-024, FR-030)

**Decision**: the fields say so. `unconfirmedEditsProvider(scope)` holds one
entry per field currently carrying unconfirmed text — an id, the text, and two
callbacks (`confirm`, `discard`) that do exactly what Enter and a focus loss
would have done in that field. A field registers when its typed text becomes
non-empty-and-unconfirmed and deregisters when it is confirmed, discarded, or
disposed.

The step action then reads the registry: empty → proceed; non-empty → ask once
(FR-030), and apply the answer to every entry.

**Rationale**: this is the only approach that keeps the answer *correct* for
the "keep" case. Keeping has to commit through the field's own path (FR-026 —
indistinguishable from Enter), which means the step action needs a handle on
the field, not just knowledge that one is dirty. It also gives FR-030 for free:
one list, one answer, applied to all of it.

**Alternatives considered**:

- *Walk the focus tree / hunt `TextField`s in the widget tree* — brittle,
  and cannot commit through a controller it cannot reach.
- *Ask each controller through the host mixin* — works for the capture step
  (one mixin, all lines) and not for the delivery step (per-destination cards),
  so it would need a second mechanism for the same rule.
- *A flag on the field controller plus a callback the host wires up* — the
  registry with less structure and more wiring per host.

**The registry holds callbacks, which is unusual for a provider.** It is
deliberate and bounded: it is UI-scoped input state that lives exactly as long
as the fields do, entries are removed on dispose, and nothing serializes or
persists it (§VII).

---

## R6 — The ordering rule that makes SC-002 true

**Decision**: a write's registration is released **after** its new state is
published, never before. In practice: `state = AsyncValue.data(updated)` and
then the decrement, inside the same synchronous block.

**Rationale**: SC-002 asks for the action to become available in the same
frame the totals update. Releasing first opens a window — one microtask, but a
real one — in which the button is pressable and the figures are still the old
ones. That is the original bug in miniature. Stated as a contract rule because
it is invisible in review unless you are looking for it.

---

## R7 — Extracting the confirm-or-discard rule without touching how anything looks

**Decision**: split spec 030's `QuantityStepperController` in two.

- `lib/core/widgets/confirmable_text_field.dart` gains
  `ConfirmableFieldController` (accepted value, typed text, `resetTick`,
  `edit`/`submit`/`abandon`/`sync`, and host-supplied `parse` + `commit`
  callbacks) and `ConfirmableTextField` — the field plus the 250 ms
  cross-fade-and-tint wrapper, lifted verbatim from
  `_QuantityStepperState._animatedField`.
- `QuantityStepperController` (staying in `features/sales/presentation/widgets/`)
  extends the base and keeps everything the base has no business knowing:
  decimal bounds, `stepBy`, the debounce, `step`/`set`, and its `money.dart`
  arithmetic. `QuantityStepper` composes `ConfirmableTextField` between its
  −/+ buttons.

**The discount field needs no subclass.** Because the base takes `parse` and
`commit` as callbacks, `SaleLineEditing` instantiates it directly with the
formatters' rate parsing and `updateRate`'s write. No abstraction for a single
use (CLAUDE.md §2), and FR-020's "one implementation" is satisfied by the base
rather than by a family of controllers.

**This also settles a debt.** Spec 030's plan recorded a §VI divergence —
"the shared control cannot go in `core/widgets/` for free" — because the whole
control needed `money.dart`. That was true of the *stepper*; it is not true of
the confirm-or-discard core, which handles opaque strings and never does
arithmetic. Half of that divergence goes away here rather than being inherited.

**Alternatives considered**: a mixin instead of a base class (no state of its
own to own — rejected); leaving the rule in the sales feature and having the
discount field import the stepper's controller (works, but puts a generic rule
behind a feature boundary and keeps §VI's divergence alive for no reason).

---

## R8 — Pixel parity is a test, not an intention

`test/golden/goldens/pos_sale_line_{light,dark}_{narrow,wide}.png` and
`pos_sale_totals_bar_*` exist and cover exactly the two surfaces this feature
refactors.

**Decision**: they must pass **unchanged**. The refactor moves code, not
pixels: the tint wrapper is a `DecoratedBox` + `Opacity` around the field,
which adds no insets, and the discount field gains the same wrapper at rest —
transparent, fully opaque, layout-neutral. A golden that diffs means something
moved that should not have, and re-baselining is the wrong fix (spec 030 set
this rule for the same reason; it is inherited deliberately).

The busy state of the three step actions is a *new* visual, and it is the
existing one: `SaleTotalsBar`'s `confirming` spinner,
`LineDistributionFoot`'s `closing`, and the payment FAB's disabled treatment
already exist for each surface's own submissions (FR-008 says reuse, not
invent).

---

## R9 — Retiring `PosStepController.writeInFlight` (FR-010)

**Decision**: remove it — the field, its `copyWith` parameter, and
`setWriteInFlight` — along with the two assertions in
`test/unit/features/sales/pos_step_controller_test.dart` that are its only
readers. Nothing else in `lib/` references it.

**Rationale**: FR-010 allows wiring it up instead, but it is the wrong shape
twice over: a `bool` where FR-002 needs a count, and inside the step machine
where the writes are not. Keeping it as a mirror of the counter would be the
"two competing mechanisms" the spec forbids.

---

## R10 — The three gates, and what each one already had

| Step | Action | Gated today on | Adds |
|---|---|---|---|
| Venta | `SaleTotalsBar.onContinue` → `_confirm` ([capture_step.dart:243](../../lib/features/sales/presentation/capture/capture_step.dart#L243)) | `sale.isEditable`, `lineCount > 0`, local `_confirming` | pending writes == 0 |
| Cobro | the summary panel's FAB ([payment_summary_panel.dart:106](../../lib/features/sales/presentation/payment/payment_summary_panel.dart#L106)) | `canLeavePayment(balance, isCreditTerms)` only | pending writes == 0 |
| Entrega | `LineDistributionFoot.onClose` ([delivery_step.dart:430](../../lib/features/sales/presentation/delivery/delivery_step.dart#L430)) | `complete`, local `_closing` | pending writes == 0 |

Two things this table makes concrete. The payment step's FAB is gated on the
*sale's* balance and nothing about its own writes — the issue's suspicion
("not itself audited here") was right. And the delivery step's `complete` is
computed from a distribution that an in-flight assignment has not reached, so
its gate is stale rather than wrong — the same defect wearing different
clothes.

`_confirming` and `_closing` stay. They are per-press re-entrancy guards for
the action's own submission, and they are what makes FR-008's busy visual
possible; the counter is about *other* writes.

---

## R11 — The unconfirmed-changes dialog

**Decision**: a Material `AlertDialog` with three actions —
keep / discard / keep editing — `barrierDismissible: false`, and a `null`
result (Esc, a dismissal we did not anticipate) treated as **keep editing**:
the answer that changes nothing. Three new l10n keys plus a title and a body,
`es-MX` authored first, `en` alongside it, `l10n_parity_test.dart` keeping them
honest.

**Rationale**: the spec's assumption is explicit that this is a decision and
not a warning to dismiss — no answer may fire on a stray tap. Mapping the
unanswerable cases onto the one harmless answer is how that gets guaranteed
rather than hoped for.

**On "keep"**: commit through the field's own path, `await` it, and only then
run the step action — the gate is already closed for the duration by R2's
registration, so the button shows its busy state throughout and the transition
lands on figures the server confirmed (FR-026). A refusal leaves the sale
where it is, with the field restored and the refusal surfaced by the path that
already surfaces line-edit refusals.

---

## R12 — What the per-line write queue keeps doing

`SaleLineEditing._enqueue` (spec 030 research R6) serializes writes for one
line so two never overlap in flight. The counter does not replace it and must
not be read as replacing it: the queue is about *correctness of one line's
writes*, the counter is about *whether the step may be left*. A reviewer
seeing both should see two different jobs.

Likewise `SaleLineEditing._busy` stays exactly as it is: the line's non-quantity
controls still go inert for their own write (FR-019), and the quantity stepper
still does not touch it (spec 030 FR-004, preserved by FR-009).

---

## R13 — The cost the cashier actually pays

A tapped quantity followed immediately by pressing continue now waits the
remainder of the ~400 ms window **plus** the round trip, with the action
visibly busy for all of it. That is the clarified decision (the window is not
cut short), and it is worth naming because it is the one place this feature
makes the register feel slower rather than safer. Two things keep it
tolerable: the wait only happens when the cashier presses continue *inside*
the window, and FR-008's busy visual makes it read as "working" rather than
"broken".

No other path gains latency: an untouched sale advances exactly as fast as it
does today, and a sale whose last edit settled a second ago sees a counter at
zero and an unchanged button.
