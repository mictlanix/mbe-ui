# Tasks: POS Write Gating & Field Discard

**Input**: Design documents from `/specs/031-pos-write-gating/`

**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/critical-action-guard.md](./contracts/critical-action-guard.md), [contracts/confirmable-field.md](./contracts/confirmable-field.md), [contracts/pos-step-gates.md](./contracts/pos-step-gates.md), [quickstart.md](./quickstart.md)

**Tests**: Included — this feature is almost entirely timing and state-machine
behaviour (a counter, a debounce window, a focus-loss discard, a dialog that
must never appear spuriously); none of it is checkable by inspection, and four
existing goldens are a regression gate this feature must pass **unchanged**
(research R8). No mbe-api dependency blocks anything — every write this
feature instruments already exists (FR-012).

**Organization**: Tasks are grouped by user story (spec.md priorities). US1,
US3 and US4 all read the same guard and the same registry built in
Foundational, but gate three different, independent actions — each is its own
shippable increment. US2 and US3 both touch the discount field's rendering,
but US2 lands the field's own rule first and US3 lands the step-boundary
question on top; US3 depends on US2. US5 has no user-facing surface of its own
— it is a test proving the Foundational mechanism needs nothing from sales,
and is listed last because it can only be written once the mechanism exists.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: Maps to US1–US5 from spec.md
- File paths are exact and relative to the repository root

## Path Conventions

Single Flutter project. `lib/` for source, `test/` for tests — no `src/`/
`backend/`/`frontend/` split (plan.md's Project Structure).

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: The five l10n keys the unconfirmed-changes dialog needs, built
and parity-checked before any widget references them.

- [X] T001 [P] Add `posUnconfirmedChangesTitle` ("Cambios sin confirmar"),
  `posUnconfirmedChangesBody` ("Hay valores escritos que no se han
  confirmado. ¿Qué deseas hacer?"), `posUnconfirmedChangesKeep` ("Conservar"),
  `posUnconfirmedChangesDiscard` ("Descartar"), and
  `posUnconfirmedChangesKeepEditing` ("Seguir editando") to
  `lib/l10n/app_es.arb`, matching the neighbouring `posLine*`/`pos*Sheet*`
  entries' style (no placeholders on any key).
- [X] T002 [P] Add the same five keys, English text ("Unconfirmed changes" /
  "There are typed values that were never confirmed. What would you like to
  do?" / "Keep" / "Discard" / "Keep editing"), to `lib/l10n/app_en.arb`.
- [X] T003 Run `flutter gen-l10n` and confirm
  `test/unit/core/l10n_parity_test.dart` passes with all five new keys present
  in both locales (depends on T001, T002).

**Checkpoint**: The dialog's strings exist and are parity-checked. No
mechanism, no widget has changed yet.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: The one mechanism every user story reads or writes through
([contracts/critical-action-guard.md](./contracts/critical-action-guard.md),
[contracts/confirmable-field.md](./contracts/confirmable-field.md)). Nothing
below is reachable until this phase is green.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [X] T004 Create `lib/core/async/critical_action_guard.dart` with
  `pendingWritesProvider` (`@Riverpod(keepAlive: true)`, family keyed by an
  opaque `String` scope): `int` state starting at 0, `Future<T>
  track<T>(Future<T> Function())` (increment, run, decrement in `finally`,
  rethrow unchanged — FR-006, FR-012), `Object begin()` / `void end(Object
  token)` (idempotent — a token released twice is a no-op, never negative —
  research R2), and `void reset()` (drops to zero; asserts in debug when the
  dropped count was non-zero — research R2, Complexity Tracking).
- [X] T005 Add `unconfirmedEditsProvider` (same file, same `keepAlive`
  family pattern) holding `List<UnconfirmedEdit>` per scope, where
  `UnconfirmedEdit` is `({Object id, String text, Future<bool> Function()
  confirm, void Function() discard})`; `void put(UnconfirmedEdit edit)` (add or
  replace by `id`) and `void remove(Object id)` (depends on T004, same file).
- [X] T006 Run `dart run build_runner build --delete-conflicting-outputs` to
  generate `lib/core/async/critical_action_guard.g.dart` (depends on T005).
- [X] T007 [P] Unit tests in `test/unit/core/critical_action_guard_test.dart`:
  two concurrent `track` calls → count 2, first settles → 1, second → 0; a
  `track`ed action that throws → count returns to 0 and the error still
  reaches the caller; `begin`/`end`/`end`-again → 1, 0, 0; a `track`ed write's
  new state (a plain counter in the test's own fixture) is observable before
  the count reaches 0 (research R6's ordering rule, exercised generically);
  `reset()` zeroes the count and a non-zero reset trips the debug assertion
  (`expect(() => ..., throwsAssertionError)` or equivalent); `put`/`put`(same
  `id`)/`remove` → one entry, replaced, then none; two distinct scope strings
  count independently (depends on T006).
- [X] T008 Create `lib/core/widgets/confirmable_text_field.dart` with
  `ConfirmableFieldController extends ChangeNotifier`: constructor taking
  `{required String value, required String? Function(String) parse, required
  Future<bool> Function(String) commit}`; `_accepted`, `_typed`, `_resetTick`;
  `displayed` (`typed ?? accepted`), `accepted`, `hasUnconfirmedText`,
  `resetTick`; `edit(String text)` (sets `_typed`, never sends — FR-013);
  `submit(String text)` (parse; invalid → discard+`resetTick++` — FR-016;
  valid → `commit`, `false` → discard+`resetTick++` — FR-017, `true` →
  `_accepted = value`); `abandon()` (discard+`resetTick++` only if `_typed !=
  null` — FR-014, a no-op otherwise per the "Enter pressed twice" edge case);
  `sync({required String value})` (differing value while `_typed != null` →
  discard+`resetTick++` — FR-018; same value → no-op on the typed text).
  Register/deregister with `unconfirmedEditsProvider` on every transition into
  and out of "has unconfirmed text" (data-model.md §2).
- [X] T009 Add `ConfirmableTextField` (`ConsumerStatefulWidget`) to the same
  file: a `TextField` wrapped in the 250 ms cross-fade-and-tint (`peak` driven
  off `resetTick`, `Color.lerp(transparent, colorScheme.errorContainer,
  peak)`, swap landing at `peak >= 0.5`), reduced-motion fallback (swap at
  once, hold the tint for the same duration), `onChanged` → `controller.edit`,
  `onSubmitted` → `controller.submit`, a `FocusNode` listener calling
  `controller.abandon()` on focus loss (FR-031) — lifted verbatim from
  `_QuantityStepperState._animatedField` in
  `lib/features/sales/presentation/widgets/quantity_stepper.dart` (depends on
  T008).
- [X] T010 [P] Widget tests in `test/widget/core/confirmable_text_field_test.dart`:
  Enter confirms (one `commit` call, no reset animation); focus loss discards
  (no `commit`, field shows accepted value, `resetTick` bumped); unparseable
  text + Enter → no `commit`, reset plays; `commit` → `false` → field
  restored, reset plays; `sync` with a different value while dirty → typed
  text lost; `sync` with the same value while dirty → typed text survives;
  Enter then Enter again on the unchanged value → one `commit`, no reset;
  `MediaQuery(disableAnimations: true)` → value swaps immediately, tint still
  shown; the field registers exactly one `unconfirmedEditsProvider` entry
  while dirty and none after confirm/discard/dispose; the wrapper adds no
  insets (`tester.getSize` identical with and without pending `resetTick`
  activity) (depends on T009).
- [X] T011 Refactor `QuantityStepperController` in
  `lib/features/sales/presentation/widgets/quantity_stepper.dart` to `extends
  ConfirmableFieldController`, passing `parse: (t) => tryParseAmount(t)` and a
  `commit` that funnels through the existing debounce (`_pending`,
  `_scheduleFlush`, `_flush`, `dispose`'s fire-and-forget). Keep `min`, `max`,
  `stepBy`, `canDecrement`/`canIncrement`, `step(int delta)`, `set(String
  value)` exactly as they behave today; `displayed` becomes `typed ?? pending
  ?? accepted` (the base's `typed ?? accepted` plus this subclass's own
  `pending`). Add a guard hold: `critical_action_guard.begin()` when a value
  becomes `_pending`, `.end(token)` attached via `.whenComplete` to the flush's
  future so a `dispose`-time fire-and-forget still releases it (FR-004,
  research R2) — the controller takes the scope string as a constructor
  parameter so it stays sale-agnostic in principle even though only
  `posWritesScope` is passed today.
- [X] T012 Update `QuantityStepper` (same file) to compose the new
  `ConfirmableTextField` between its −/+ buttons in both the pill skin and the
  field skin, deleting `_QuantityStepperState`'s now-duplicated
  `_animatedField`/reset-animation code (superseded by T009) while keeping
  `_pillSkin`/`_fieldSkin`/`_pillButton`/`_fieldButton` and every existing
  constructor parameter (`decoration`, `textStyle`, `dense`, tooltips)
  unchanged (depends on T011).
- [X] T013 Verify `test/unit/features/sales/quantity_stepper_controller_test.dart`,
  `test/widget/features/sales/quantity_stepper_widget_test.dart`,
  `test/widget/features/sales/sale_line_symmetry_test.dart`, and
  `flutter test test/golden/` (specifically
  `pos_sale_line_{light,dark}_{narrow,wide}.png`,
  `pos_sale_totals_bar_{light,dark}_{narrow,wide}.png`) all pass **unchanged**
  after T011/T012 — no edits to these files, no re-baselined goldens (research
  R8; a failure here means the extraction leaked into behaviour or pixels and
  must be fixed in T011/T012, not worked around here) (depends on T012).
- [X] T014 [P] Create `lib/features/sales/presentation/pos_write_scope.dart`
  exporting `const posWritesScope = 'pos-sale';` with a doc comment noting it
  is the only sales-specific line in this feature's core-adjacent wiring
  (FR-011).
- [X] T015 Remove `writeInFlight` from `PosStepState` (field, `copyWith`
  parameter) and remove `PosStepController.setWriteInFlight` in
  `lib/features/sales/presentation/pos_step_controller.dart`; remove the two
  assertions in `test/unit/features/sales/pos_step_controller_test.dart` that
  read it (lines exercising `writeInFlight`) — the only two references outside
  this file (FR-010, research R9).

**Checkpoint**: The guard counts and registers; the confirmable-field rule
exists once in core; the quantity stepper behaves and renders exactly as
before on top of it; the dead flag is gone. Every user story below builds on
this without touching it again.

---

## Phase 3: User Story 1 - Never leave a step with figures that are not the sale's (Priority: P1) 🎯 MVP

**Goal**: The Venta step's "Continuar al cobro" is unavailable for the whole
of an outstanding line write — including a stepped quantity still inside its
coalescing window — and becomes available again in the same frame the totals
catch up, with no sequence of refusals able to leave it stuck.

**Independent Test**: On a sale with two lines, edit one line's discount and
immediately press continue: it must be unavailable, then available with the
discounted total on screen. Force a refusal and confirm the button recovers.
Edit both lines in quick succession and confirm the button stays unavailable
until both settle.

### Tests for User Story 1

> Written first; confirmed failing before the implementation tasks below.

- [X] T016 [P] [US1] Widget tests in
  `test/widget/features/sales/pos_write_gating_test.dart` (new file, built on
  `pos_test_harness.dart`'s `pumpPos`/`testSale`/`MockSalesOrderRepository`
  pattern): pump `CaptureStep` with a `MockSalesOrderRepository` whose
  `updateLine` returns a delayed future; tap the discount field's confirm path,
  assert `SaleTotalsBar`'s continue button is disabled while the future is
  pending and enabled once it resolves, with the totals shown at that instant
  equal to the resolved `Sale`'s own (SC-002); make the future reject and
  assert the button re-enables rather than staying disabled (SC-003); resolve
  two overlapping `updateLine` calls (two lines) and assert the button stays
  disabled until the second settles (SC-004).
- [X] T017 [P] [US1] Widget test, same file: step a line's quantity via
  `QuantityStepper` (tap `+`) and press the continue button before the ~400 ms
  debounce fires; assert the sale does not advance and the button stays
  disabled until the coalesced write lands (FR-004, contracts/pos-step-gates.md
  §4 "Coalescing window").
- [X] T018 [P] [US1] Widget test, same file: during an outstanding line write,
  assert the warehouse picker, the tax picker, and the quantity stepper on
  *other* lines remain enabled and responsive (FR-009, SC-005 — the freeze
  spec 030 removed must not come back).

### Implementation for User Story 1

- [X] T019 [US1] In `lib/features/sales/presentation/pos_sale_controller.dart`,
  wrap the bodies of `updateHeader`, `addLine`, `updateLine`, `removeLine`, and
  `confirm` in `ref.read(criticalActionGuardProvider...).track(...)` (or the
  equivalent generated accessor) keyed on `posWritesScope`, with the guard's
  `track` call ordered so `state = AsyncValue.data(updated)` happens inside
  the tracked closure, before `track`'s own decrement (research R6 — release
  after publish). Add `ref.read(pendingWritesProvider(posWritesScope).notifier)
  .reset()` at the top of `startNew()` and at the top of `load()` (depends on
  T004, T014).
- [X] T020 [US1] In `lib/features/sales/presentation/capture/capture_step.dart`,
  add `ref.watch(pendingWritesProvider(posWritesScope)) == 0` to the existing
  `onContinue` condition (alongside `enabled`, `lineCount > 0`, `!_confirming`)
  so the continue action is additionally gated (depends on T019).
- [X] T021 [US1] Run T016–T018 and confirm they pass; run
  `test/widget/features/sales/sale_totals_bar_test.dart`,
  `capture_step`-covering tests, and `flutter test test/golden/` to confirm no
  regression on the surfaces touched (depends on T020).

**Checkpoint**: Issue #164 no longer reproduces on the Venta step. User Story
1 is independently shippable.

---

## Phase 4: User Story 2 - Know when my typing was discarded (Priority: P1)

**Goal**: The sale line's discount field, on both layouts, confirms only on
Enter and visibly discards — the same 250 ms cross-fade-and-tint the quantity
field uses — on focus loss, on an unparseable entry, and on a server refusal.

**Independent Test**: Type `15` over a line's 0% discount, click the warehouse
picker without pressing Enter: the field returns to 0% with the
acknowledgement and no write is made. Press Enter on a valid value: it
commits with no acknowledgement. Type garbage and press Enter: it discards
with the acknowledgement.

### Tests for User Story 2

> Written first; confirmed failing before the implementation tasks below.

- [X] T022 [P] [US2] Widget tests in
  `test/widget/features/sales/sale_line_discount_test.dart` (new file):
  pump `SaleLineRow` (wide layout) with a line at 0% discount; type `15`,
  tap away to the warehouse picker (no Enter) — assert the discount field
  shows `0%` again, the reset animation's tint appears (pump through
  `kFieldResetAnimation`'s duration), and `MockSalesOrderRepository.updateLine`
  is never called with a `discountRate` argument; type `15` and press Enter —
  assert `updateLine` is called once with `discountRate` reflecting `0.15`
  and no reset animation plays; type unparseable text (`abc`) and press
  Enter — assert no call and the reset plays; stub `updateLine` to throw and
  confirm the field restores with the reset playing rather than the prior
  silent `syncFields()` rewrite (FR-017).
- [X] T023 [P] [US2] Widget test, same file, compact tier: repeat the
  Enter-confirms / focus-loss-discards pair against `SaleLineCard` at a narrow
  width (FR-013's "both layouts").
- [X] T024 [P] [US2] Extend
  `test/widget/features/sales/sale_line_symmetry_test.dart` (or confirm
  unchanged) to assert the discount field's measured height/baseline in the
  control band is identical before and after this feature — no regression to
  the band spec 023 fixed (FR-021).

### Implementation for User Story 2

- [X] T025 [US2] In
  `lib/features/sales/presentation/capture/sale_line_editing.dart`, replace
  `discountField` (a bare `TextEditingController`) with a
  `ConfirmableFieldController` instance: `parse:
  ref.read(formattersProvider).field.parseRate`, `commit: (raw) async { try {
  await update(discountRate: raw); return true; } on Object { return false; }
  }` (mirroring `_commitQuantity`'s shape), seeded from
  `ref.read(formattersProvider).field.rate(line.discountRate)`; update
  `syncFields()` to call the new controller's `sync(value: ...)` instead of
  setting `.text` directly; update `dispose()` to dispose it (depends on T008,
  T014 for the scope constant used by the registry).
- [X] T026 [US2] In `lib/features/sales/presentation/capture/sale_line_row.dart`,
  replace the `_rateField`-rendered discount `TextField` with
  `ConfirmableTextField(controller: discountField, decoration:
  _fieldDecoration(l10n.posLineDiscountLabel), style: _fieldStyle, enabled:
  enabled)`, keeping the surrounding `_band`/width/padding exactly as they are
  (FR-021).
- [X] T027 [US2] In
  `lib/features/sales/presentation/capture/sale_line_card.dart`, replace the
  discount `TextField` (inside the `Row` beside the tax picker) with the same
  `ConfirmableTextField` wiring, keeping its `Expanded` sizing unchanged.
- [X] T028 [US2] Run T022–T024 and confirm they pass; run
  `test/widget/features/sales/sale_line_row_test.dart` and
  `flutter test test/golden/` to confirm `pos_sale_line_*` still passes
  unchanged (depends on T027).

**Checkpoint**: The discount field never shows a value the line does not
carry, on either layout, and the acknowledgement is the same one the quantity
field already uses. User Story 2 is independently shippable.

---

## Phase 5: User Story 3 - Be asked before my typing is thrown away at the till (Priority: P1)

**Goal**: Pressing the Venta step's continue action with unconfirmed text
anywhere on the step asks — keep / discard / keep editing — instead of
silently discarding or silently advancing; answering "keep" commits exactly as
Enter would and the step advances only once that write settles.

**Independent Test**: Type an unconfirmed discount, press continue, and
exercise each of the three answers in separate attempts; confirm every edit
and press continue, and confirm no dialog appears.

### Tests for User Story 3

> Written first; confirmed failing before the implementation tasks below.

- [X] T029 [P] [US3] Widget tests in
  `test/widget/features/sales/unconfirmed_changes_test.dart` (new file): type
  an unconfirmed discount and press continue — assert the sale does not
  advance and a dialog with the five l10n strings from T001–T003 appears;
  choose **keep** — assert one `updateLine(discountRate: ...)` call, the
  action shows its busy state until it resolves, and the sale then advances;
  make that resolved call a refusal — assert the sale does **not** advance,
  the field restores with the reset animation, and the refusal is surfaced;
  choose **discard** — assert no write, the reset animation plays, and the
  sale advances; choose **keep editing** — assert no write, no advance, and
  the typed text is still in the field; with every line's edits confirmed,
  press continue — assert **no** dialog is ever pumped (SC-013); with two
  lines both carrying unconfirmed discounts, press continue — assert exactly
  one dialog and that choosing **keep** commits both (FR-030).
- [X] T030 [P] [US3] Widget test, same file: focused on the premise research
  R4 measured — type into the discount field, press the continue button, and
  assert (inside a hook exposed by the test, e.g. by inspecting
  `FocusManager.instance.primaryFocus` or the controller's own
  `hasUnconfirmedText` at the moment `onPressed` fires) that the typed text is
  still unconfirmed when the handler runs, so the dialog path in T029 is
  exercising a real state rather than a state that was already discarded.

### Implementation for User Story 3

- [X] T031 [US3] Create
  `lib/features/sales/presentation/widgets/unconfirmed_changes_dialog.dart`:
  a function `Future<UnconfirmedChangesAnswer?> showUnconfirmedChangesDialog
  (BuildContext context)` returning an `enum UnconfirmedChangesAnswer { keep,
  discard, keepEditing }`, rendering `AlertDialog(barrierDismissible: false,
  title: Text(l10n.posUnconfirmedChangesTitle), content:
  Text(l10n.posUnconfirmedChangesBody), actions: [TextButton (keep editing,
  pops keepEditing), TextButton (discard, pops discard), FilledButton (keep,
  pops keep)])`, with the dialog's own `PopScope`/back-button handling mapping
  to `keepEditing` (research R11 — an unanswerable dismissal is the answer
  that changes nothing).
- [X] T032 [US3] In `lib/features/sales/presentation/capture/capture_step.dart`,
  change `_confirm`'s entry (or add a wrapper the continue button calls) to:
  read `ref.read(unconfirmedEditsProvider(posWritesScope))`; if empty, proceed
  exactly as today; if non-empty, call
  `showUnconfirmedChangesDialog(context)` and branch on the result — `keep` →
  `await Future.wait(entries.map((e) => e.confirm()))`, proceed only if every
  result is `true` (a `false` leaves the step where it is, since the entry's
  own `commit` already restored and surfaced the refusal per T025's `commit`
  shape); `discard` → call every entry's `discard()`, then proceed; `null`/
  `keepEditing` → return without proceeding (depends on T031, T020, T005).
- [X] T033 [US3] Run T029–T030 and confirm they pass; run T016–T018 (US1)
  again to confirm the new question does not interfere with the plain gate
  path when the registry is empty (depends on T032).

**Checkpoint**: The Venta step never silently drops or silently commits a
typed value at its own boundary. User Story 3 is independently shippable
(it builds on US1's gate and US2's field, but is testable and demoable on its
own once both exist).

---

## Phase 6: User Story 4 - The same guarantee on the other two steps (Priority: P2)

**Goal**: The Cobro step's continue action and the Entrega step's finish
action are each unavailable while their own writes (a payment, a reversal, a
destination create/edit/remove/assignment) are outstanding, and recover from a
refusal exactly as the Venta gate does.

**Independent Test**: Apply a payment and press continue before it settles —
unavailable, then available with the confirmed balance. Step a destination's
quantity and press finish before it settles — unavailable, then available
with the confirmed distribution.

### Tests for User Story 4

> Written first; confirmed failing before the implementation tasks below.

- [X] T034 [P] [US4] Widget tests in
  `test/widget/features/sales/pos_write_gating_test.dart` (same file as
  T016–T018): pump `PaymentStep` with a `MockCustomerPaymentRepository` whose
  `apply` (or equivalent submit call) returns a delayed future; assert the
  summary panel's FAB is disabled while pending and enabled with the resolved
  balance once it settles; repeat with a delayed `reverseApplication` call.
- [X] T035 [P] [US4] Widget tests, same file: pump `DeliveryStep` with a
  `MockDeliveryOrderRepository` (the pattern in
  `destination_assignment_test.dart`) whose `assignLine`/`addDestination`/
  `updateDestination`/`removeDestination`/`sweepRemainderToCounter` each
  return a delayed future in turn; assert `LineDistributionFoot`'s finish
  action is disabled for the duration of each and available again once it
  resolves, including after a refusal (SC-003 extended to this step).

### Implementation for User Story 4

- [X] T036 [P] [US4] In
  `lib/features/sales/presentation/payment/payment_controller.dart`, wrap
  `submit` and `reverse` in `pendingWritesProvider(posWritesScope).notifier
  .track(...)`, ordered so `state = ...` (or the draft's success transition)
  happens before the tracked closure returns (research R6) (depends on T004,
  T014).
- [X] T037 [US4] In
  `lib/features/sales/presentation/payment/payment_summary_panel.dart`, add
  `ref.watch(pendingWritesProvider(posWritesScope)) == 0` to the FAB's
  `onPressed: canClose ? onClose : null` condition (depends on T036).
- [X] T038 [P] [US4] In
  `lib/features/sales/presentation/delivery/delivery_controller.dart`, wrap
  `addDestination`, `updateDestination`, `removeDestination`, `assignLine`,
  `adjustLine`, `dropLine`, and `sweepRemainderToCounter` in the same
  `track(...)` call, same ordering rule (depends on T004, T014).
- [X] T039 [US4] In
  `lib/features/sales/presentation/delivery/delivery_step.dart`, add
  `ref.watch(pendingWritesProvider(posWritesScope)) == 0` to both
  `LineDistributionFoot.onClose` conditions (the wide-tier and narrow-tier
  render paths, both currently `(complete && !_closing) ? () => _close(...) :
  null`) (depends on T038).
- [X] T040 [US4] Run T034–T035 and confirm they pass; run
  `test/widget/features/sales/payment_step_gate_test.dart`,
  `test/widget/features/sales/destination_assignment_test.dart`,
  `test/widget/features/sales/line_distribution_rail_test.dart`, and
  `flutter test test/golden/` to confirm no regression (depends on T039).

**Checkpoint**: All three POS steps share one gate. User Story 4 is
independently shippable and completes issue #164's full scope.

---

## Phase 7: User Story 5 - One mechanism, adoptable beyond the register (Priority: P3)

**Goal**: Prove the guard built in Foundational carries no sales-specific
concept, by driving it from an operation that has nothing to do with a sale.

**Independent Test**: A test exercises `track`/`begin`/`end`/`reset` and the
unconfirmed-edits registry against a scope and a fake async operation with no
`Sale`, no `PosSaleController`, no sales import anywhere in the test.

### Tests for User Story 5

- [X] T041 [P] [US5] Add a test to
  `test/unit/core/critical_action_guard_test.dart` (extending T007's file): a
  fixture representing an unrelated critical action — e.g. a fake "apply
  profile" operation styled after
  `lib/features/auth/presentation/admin/apply_profile_dialog.dart`'s shape,
  with its own scope string (`'test-critical-action'`) — driven entirely
  through `track`, gated the same way a POS step is, with **zero** imports
  from `features/sales/` anywhere in the test file (SC-010).

### Implementation for User Story 5

- [X] T042 [US5] No production code — this story is verification-only.
  Confirm (by reading the diff, not by adding code) that
  `lib/core/async/critical_action_guard.dart` imports nothing from
  `lib/features/`, matching the existing `layering_test.dart`'s spirit; if
  T041 fails for a reason that traces to a sales-specific assumption baked
  into T004/T005, fix it there rather than special-casing this test.

**Checkpoint**: FR-011 and SC-010 are demonstrated, not just asserted in prose.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: The full-suite and live-backend passes the quickstart calls for,
plus the one dead reference cleanup FR-010 requires be visible in the diff.

- [X] T043 [P] Run `flutter analyze` and fix any warning introduced by this
  feature (no pre-existing warning is in scope to fix).
- [X] T044 Run the full suite — `flutter test` — and confirm it is green,
  including every "must stay green unchanged" file listed in
  [quickstart.md §1](./quickstart.md).
- [X] T045 Follow [quickstart.md §5](./quickstart.md) against a live mbe-api
  (network throttled): the reported issue #164 sequence on all three steps,
  the coalescing-window race, a forced refusal on each step, and a burst on
  the capture stepper still producing one `PUT` (spec 030's guarantee,
  unshaken by the new hold).
- [X] T046 Grep the repository for `writeInFlight` and confirm zero
  remaining references outside git history (FR-010's "no two competing
  mechanisms", verified rather than assumed).

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately.
- **Foundational (Phase 2)**: No dependency on Setup's l10n keys (different
  files); BLOCKS every user story below.
- **User Story 1 (Phase 3)**: Depends on Foundational (T004, T014, T015).
  Independent of Setup, US2, US4, US5.
- **User Story 2 (Phase 4)**: Depends on Foundational (T008–T012). Independent
  of US1, US4, US5. Shares no file with US1.
- **User Story 3 (Phase 5)**: Depends on Foundational (T005), Setup (the l10n
  keys, T001–T003), User Story 1's gate existing in `capture_step.dart` (T020)
  and User Story 2's discount controller (T025, so there is something to
  `confirm()`). This is the one story that is not fully order-independent —
  it composes US1 and US2's outputs rather than duplicating them.
- **User Story 4 (Phase 6)**: Depends on Foundational (T004, T014). Independent
  of US1, US2, US3, US5. Can be built in parallel with US1/US2/US3 by a
  different developer.
- **User Story 5 (Phase 7)**: Depends on Foundational only (T004–T007).
  Independent of every other story; sequenced last here only because writing
  it first would mean writing it twice if Foundational's shape changes.
- **Polish (Phase 8)**: Depends on every story you choose to ship.

### Within Each User Story

- Tests are written first and confirmed failing before implementation.
- Each story's own checkpoint task re-runs its tests plus the named regression
  files before the story is considered done.

### Parallel Opportunities

- T001/T002 in parallel; T003 after both.
- T004→T005→T006 are sequential (same file, generated output depends on the
  finished source); T007 after T006.
- T008→T009 sequential (same file); T010 after T009.
- T011→T012→T013 sequential (same file, then its own regression check).
- T014 and T015 are independent of the T004–T013 chain and of each other —
  parallelizable with everything in Foundational except where noted.
- Once Foundational (Phase 2) is done: **US1, US2, US4, US5 can all start in
  parallel** (different developers, different files). **US3 cannot start**
  until US1's T020 and US2's T025 land.
- Within US1: T016/T017/T018 in parallel (one new file, independent test
  cases); T019 before T020 before T021.
- Within US2: T022/T023/T024 in parallel; T025 before T026/T027 (T026, T027
  parallel with each other once T025 lands); T028 last.
- Within US4: T034/T035 in parallel; T036 and T038 in parallel (different
  controllers); T037 after T036; T039 after T038; T040 last.

---

## Parallel Example: Foundational + User Story 1 + User Story 4

```bash
# Two developers, once Setup is done:

# Developer A — Foundational, the guard:
Task: "T004 Create critical_action_guard.dart: pendingWritesProvider"
Task: "T005 Add unconfirmedEditsProvider to the same file"
Task: "T006 build_runner for critical_action_guard.g.dart"
Task: "T007 Unit tests for the guard"

# Developer B — Foundational, the confirmable field (independent file):
Task: "T008 Create confirmable_text_field.dart: ConfirmableFieldController"
Task: "T009 Add ConfirmableTextField widget to the same file"
Task: "T010 Widget tests for the confirmable field"

# --- Foundational checkpoint reached ---

# Developer A continues into US4 (payment + delivery gates):
Task: "T036 [US4] Instrument PaymentController.submit/reverse"
Task: "T038 [US4] Instrument DeliveryController's six methods"

# Developer B continues into US1 (Venta gate):
Task: "T019 [US1] Instrument PosSaleController's five methods"
Task: "T020 [US1] Gate CaptureStep's onContinue"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (the l10n keys — needed later, cheap now).
2. Complete Phase 2: Foundational (CRITICAL — the guard, the confirmable
   field base, the scope constant, the dead-flag removal).
3. Complete Phase 3: User Story 1 — the Venta gate, issue #164's original
   report.
4. **STOP and VALIDATE**: run quickstart.md §3 items 1–5 against a throttled
   live backend.
5. Ship if ready — US1 alone closes the reported bug on the step it was
   reported on.

### Incremental Delivery

1. Setup + Foundational → mechanism ready, nothing user-visible yet.
2. Add US1 → Venta gate live → validate → ship (closes the reported bug).
3. Add US2 → discount field discards visibly → validate → ship.
4. Add US3 → the step-boundary question, composing US1 + US2 → validate →
   ship (closes the "silently drops a discount" risk US1+US2 leave open at
   the step boundary).
5. Add US4 → Cobro and Entrega gates → validate → ship (closes issue #164's
   full scope, all three steps).
6. Add US5 → the reusability proof → ship (no user-visible change).

### Parallel Team Strategy

With multiple developers, after Foundational:

- Developer A: US1 (Venta gate) → then US3 (needs US1 + US2's outputs)
- Developer B: US2 (discount field)
- Developer C: US4 (Cobro + Entrega gates) — fully independent throughout
- US5 is a half-day add-on any developer can pick up once Foundational lands

---

## Notes

- [P] tasks touch different files, or the same file in a way the sequencing
  above already accounts for.
- [Story] labels map every implementation and test task to its user story for
  traceability; Setup, Foundational and Polish carry none by design.
- `pos_sale_line_*` and `pos_sale_totals_bar_*` goldens are a hard gate in
  Phase 2 and again in US2 — a diff there is a defect in the extraction, never
  a re-baseline (research R8).
- The coalescing-window wait (T017) is a clarified product decision, not a
  bug to optimize away: the window runs its course, and the busy visual is
  what keeps it from reading as broken.
- Commit after each task or logical group; stop at any checkpoint to validate
  a story independently before moving on.
