# Tasks: POS Sale & Delivery Refinements

**Input**: Design documents from `/specs/030-pos-sales-refinements/`

**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/quantity-stepper.md](./contracts/quantity-stepper.md), [contracts/delivery-surface.md](./contracts/delivery-surface.md), [quickstart.md](./quickstart.md)

**Tests**: Included — the spec's own acceptance scenarios (burst-tap coalescing,
Enter-only confirmation, the reset animation, the edit sheet's prefill and
refusal handling, the store row's two sources) are only checkable with tests,
and four existing goldens are a regression gate this feature must pass
**unchanged** (research R5). No mbe-api dependency blocks anything — the one
endpoint this feature newly calls, `PUT /delivery-orders/{id}`, is already
live (research R9).

**Organization**: Tasks are grouped by user story (spec.md priorities). US1 and
US2 share one file (`quantity_stepper.dart`) by design (plan Summary) but are
still independently testable increments: US1 ships the stepping/debounce
mechanics with today's silent-revert-on-blur behavior unchanged; US2 adds the
Enter-only confirmation, the discard and the reset animation on top. US3 and
US4 touch `destination_card.dart` too, but in different methods, and depend on
neither US1 nor US2 — implementable and testable in any order once Setup is
done.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: Maps to US1–US4 from spec.md
- File paths are exact and relative to the repository root

## Path Conventions

Single Flutter project. `lib/` for source, `test/` for tests — no `src/`/
`backend/`/`frontend/` split (per plan.md's Project Structure).

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: The two new labels US3/US4 need, built and parity-checked before
any widget references them.

- [X] T001 [P] Add `posEditDestinationSheetTitle` ("Editar destino") and
  `posCounterPickupLinesTitle` ("Cantidad que se queda en tienda") to
  `lib/l10n/app_es.arb`, matching the neighbouring `posAddDestinationSheetTitle`/
  `posDestinationLinesTitle` entries' style (no placeholders on either key).
- [X] T002 [P] Add the same two keys, English text ("Edit destination" /
  "Quantity staying at the store"), to `lib/l10n/app_en.arb`.
- [X] T003 Run `flutter gen-l10n` and confirm
  `test/unit/core/l10n_parity_test.dart` passes with both new keys present in
  both locales (depends on T001, T002).

**Checkpoint**: The two new labels exist and are parity-checked. No
presentation widget has changed yet.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: None. Every user story below is reachable straight from Setup —
US1/US2 build a new file no other story touches until it exists; US3/US4 touch
`destination_card.dart` in methods US1 also touches, but sequentially, not
through a shared prerequisite. There is nothing here that would block more
than one story, so nothing is extracted into this phase.

**Checkpoint**: Skip straight to Phase 3.

---

## Phase 3: User Story 1 - Step a line's quantity as fast as I can tap (Priority: P1) 🎯 MVP

**Goal**: One quantity-stepper control — debounced, live during a write,
bounded per surface — used by the wide sale-line row, the compact sale-line
card and the delivery destination card. Typing-and-confirming keeps today's
behavior (Enter commits; leaving the field without Enter still silently
reverts) — US2 is what makes that reversal visible.

**Independent Test**: Tap **+** five times fast on a capture sale line; the
field follows every tap, the line's other controls (warehouse, discount, tax)
never grey out, and exactly one write reaches the server. Repeat on a
delivery destination's line and confirm nothing changed from before this
feature.

### Tests for User Story 1

> Written first; confirmed failing before the implementation tasks below.

- [X] T004 [P] [US1] Unit tests for `QuantityStepperController` in
  `test/unit/features/sales/quantity_stepper_controller_test.dart`: burst of
  `step()` calls within the debounce window coalesces into one `onCommit`
  (FR-003); `step()` past `min`/`max` is a no-op and `canDecrement`/
  `canIncrement` report it (FR-007/FR-008); a `step()`/`set()` landing while a
  commit is in flight is applied after it, never dropped or overlapped
  (FR-004/FR-006 — two `onCommit` futures for the same controller never
  overlap); `dispose()` fires a still-pending commit rather than dropping it
  (FR-005); `sync(value)` leaves the displayed value alone while a commit is
  pending, and adopts the new value otherwise (research R7, the two rows of
  its precedence table that do not involve `typed`).
- [X] T005 [P] [US1] Extend
  `test/widget/features/sales/sale_line_row_test.dart` with a burst-tap case:
  pump a `CaptureStep`/`SaleLineRow` at the tablet-landscape width (FR-037a's
  existing 1024 px fixture), tap **+** five times within 400 ms, and assert
  the field shows the fifth value throughout with no `RenderFlex` overflow —
  the single-row quantity column (132 px) must still fit the swapped control.
- [X] T006 [P] [US1] Extend
  `test/widget/features/sales/destination_assignment_test.dart` (or confirm
  unchanged if it already does) to assert `Key('destination_quantity_5')`
  still resolves to a `TextField` with a real `TextEditingController` after
  the swap, and that the existing claim-all/stepper/type-and-submit
  assertions in that file keep passing verbatim.

### Implementation for User Story 1

- [X] T007 [US1] Create
  `lib/features/sales/presentation/widgets/quantity_stepper.dart` with
  `QuantityStepperController extends ChangeNotifier`: `accepted`, `pending`,
  `min`, `max`, `displayed` (`pending ?? accepted` at this stage — `typed`
  arrives in US2), `canDecrement`/`canIncrement` via
  `features/sales/domain/money.dart`'s `compareAmounts`/`addAmounts`/
  `subtractAmounts`, `sync({value, min, max})`, `step(int delta)`, `set(String
  value)`, the `kQuantityCommitDebounce = Duration(milliseconds: 400)` timer
  that calls `Future<bool> Function(String) onCommit`, serialized so at most
  one commit is in flight per controller, and a `dispose()` that cancels the
  timer and fires any pending commit (swallowing a throw — research R8)
  (depends on T004 existing and failing).
- [X] T008 [US1] In the same file, add `QuantityStepper extends
  ConsumerStatefulWidget`: `controller`, `enabled`, `fieldKey`, `decoration`,
  `textStyle`, `dense`, `decrementTooltip`, `incrementTooltip`. Render the pill
  skin when `decoration` is `null` (44 px, `surfaceContainerHighest` fill,
  `outlineVariant` border, `theme.shapes.xlRadius`, matching
  `destination_card.dart`'s current `_stepper` exactly) and the plain-field
  skin otherwise (matching `sale_line_row.dart`'s `_quantityStepper`/
  `sale_line_card.dart`'s quantity row exactly), with `dense: true` giving the
  32 px shrink-wrapped buttons `sale_line_row.dart` uses today. The displayed
  value renders through `ref.watch(formattersProvider).field.quantity(...)`.
  No animation yet (depends on T007).
- [X] T009 [US1] In
  `lib/features/sales/presentation/capture/sale_line_editing.dart`: replace
  `quantityField`/`step(int)` with one `QuantityStepperController` per line
  (created lazily, `sync`ed from `line.quantity` in `syncFields`), `min:
  '1'`, `max: null`. Route its `onCommit` through a new per-line `Future`
  chain shared with the existing discount/tax/warehouse writes (research R6)
  so no two writes for the same line overlap — `update(...)` keeps its
  current signature and `_busy` gating for discount/tax/warehouse, but the
  quantity commit no longer sets `_busy` (FR-004). `onCommit` returns `false`
  on a caught `AppError` (research R3) instead of only calling `syncFields()`.
  The shortfall action's `update(quantity: availableQuantity)` becomes
  `quantityStepper.set(availableQuantity)` (depends on T007).
- [X] T010 [P] [US1] In `lib/features/sales/presentation/capture/sale_line_row.dart`:
  replace `_quantityStepper` with `QuantityStepper(controller:
  quantityStepperController, decoration: _fieldDecoration(...), dense: true,
  fieldKey: Key('...'))`, keeping the SAT-unit label logic
  (`posLineQuantityLabel`/`posLineQuantityWithUnitLabel`) exactly as it reads
  today (depends on T008, T009).
- [X] T011 [P] [US1] In `lib/features/sales/presentation/capture/sale_line_card.dart`:
  replace the quantity `Row` (its own `IconButton`s + `TextField`) with
  `QuantityStepper(controller: ..., decoration: InputDecoration(labelText:
  ..., suffixText: line.unit))`, same behavior, same visual result (depends
  on T008, T009).
- [X] T012 [US1] In
  `lib/features/sales/presentation/delivery/destination_card.dart`: replace
  `_quantityControllers`, `_pending`, `_debounce`, `_inFlight` and the
  display half of `_request`/`_send` with one `QuantityStepperController` per
  sale line (`min: '0'`, `max: _ceilingFor(line)` re-synced every build),
  rendered via `QuantityStepper(controller: ..., fieldKey:
  Key('destination_quantity_${line.saleLineId}'))` — no `decoration`, so the
  pill skin renders. `onCommit` keeps the existing assign/adjust/drop dispatch
  (`_lineErrors` on refusal, returning `false`) and the existing
  `_ceilingFor`/claim-all wiring: `destination_claim_all_*` calls
  `controller.set(_ceilingFor(line))`. The dispose-time pending-write flush
  moves to the controller (research R8); the card's own `dispose` no longer
  needs to do it by hand (depends on T008).
- [X] T013 [US1] Run `flutter test test/golden/pos_capture_golden_test.dart`
  and confirm all four `pos_sale_line_*` goldens pass **unchanged**. If any
  diffs, fix the widget until they don't — do not regenerate the baseline
  (research R5) (depends on T010, T011).

**Checkpoint**: Sale lines on both steps step as fast as the cashier taps, with
no control disabled mid-burst and exactly one write per burst. Typing behavior
is unchanged from before this feature (Enter commits; a value left in the
field without Enter still silently reverts on the next value it disagrees
with). Independently testable and demoable now.

---

## Phase 4: User Story 2 - Know when my typing was discarded (Priority: P1)

**Goal**: A quantity typed and abandoned without pressing Enter never reaches
the sale, and the field visibly, animatedly, returns to the value the sale
actually has.

**Independent Test**: Type `25` over a quantity, click elsewhere without
pressing Enter, and confirm the field fades back to the original value with a
brief tint and that the line was never updated. Type an out-of-range or
non-numeric value and press Enter; same result.

### Tests for User Story 2

- [X] T014 [P] [US2] Extend
  `test/unit/features/sales/quantity_stepper_controller_test.dart`: `submit()`
  with unparseable or out-of-bounds text discards and bumps `resetTick`
  (FR-012); `abandon()` with `typed != null` discards and bumps `resetTick`
  (FR-011); `abandon()` with `typed == null` is a no-op; `step()`/`set()`
  while `typed != null` computes from `accepted`, not from `typed`, and clears
  `typed` (FR-015); `onCommit → false` restores `accepted` and bumps
  `resetTick` (research R3); `sync(value)` with `typed != null` and a
  differing `value` discards `typed` and bumps `resetTick` (research R7);
  `resetTick` does **not** change on a plain accepted commit or a `sync` that
  agrees with `typed` (FR-014).
- [X] T015 [P] [US2] New widget test
  `test/widget/features/sales/quantity_stepper_widget_test.dart`: typing over
  a value and losing focus without Enter shows the reset animation and leaves
  the original value; typing an accepted value and pressing Enter shows no
  animation; `MediaQuery(data: MediaQueryData(disableAnimations: true))`
  makes the same abandonment resolve instantly while still applying and
  clearing the color tint (FR-016).
- [X] T016 [US2] Extend
  `test/widget/features/sales/destination_assignment_test.dart`: typing a
  quantity above `_ceilingFor(line)` and pressing Enter now shows the reset
  animation (today it snaps back silently) — assert the value still ends at
  the pre-edit figure and that no request was sent.

### Implementation for User Story 2

- [X] T017 [US2] In `quantity_stepper.dart`'s `QuantityStepperController`: add
  `typed`, `edit(String text)`, `submit(String text)` (parses via the same
  `compareAmounts`/bounds check as `step`; valid → behaves like `set`; invalid
  → discard + `resetTick++`), `abandon()` (discard + `resetTick++` only if
  `typed != null`), and thread the new `sync`/`onCommit-false` precedence rows
  from research R7 through the existing `sync` and commit-completion logic
  (depends on T007, T014 existing and failing).
- [X] T018 [US2] In `QuantityStepper`'s `State`: wire a `FocusNode` around the
  field — `onEditingComplete`/`onSubmitted` calls `controller.submit(text)`;
  the focus-loss listener calls `controller.abandon()` when focus is lost and
  `typed != null`; every keystroke calls `controller.edit(text)`. Listen to
  `controller.resetTick` (via `AnimatedBuilder` or an explicit listener) to
  drive the animation added in T019 (depends on T008, T017).
- [X] T019 [US2] In the same `State`: on a `resetTick` change, run a 250 ms
  (`kQuantityResetAnimation`) cross-fade of the field's text (swap at the
  midpoint, so only one copy is ever laid out) plus a `ColorTween` from the
  skin's resting color to `colorScheme.errorContainer` and back (text color
  following to `onErrorContainer` at the peak); under
  `MediaQuery.disableAnimationsOf(context)`, swap the value instantly while
  still applying and clearing the tint on the same schedule (FR-016) (depends
  on T018).
- [X] T020 [P] [US2] In
  `lib/features/sales/presentation/capture/sale_line_editing.dart`: confirm
  `update(...)`'s `AppError` path returns `false` from the quantity
  controller's `onCommit` (already true from T009) rather than only calling
  `syncFields()` — no behavior change needed if T009 was done per its
  description, but add a one-line comment noting the reset now animates
  (depends on T009, T017).
- [X] T021 [US2] Run
  `flutter test test/golden/pos_capture_golden_test.dart` again to confirm the
  four goldens still pass unchanged at rest (the animation only plays on a
  discard, never on first paint) (depends on T017–T019).

**Checkpoint**: US1 + US2 together fully replace the two quantity controls
this feature exists to fix. Independently testable and demoable; ships
alongside US1 as one P1 increment (spec Assumptions).

---

## Phase 5: User Story 3 - Correct a destination I got wrong (Priority: P2)

**Goal**: An edit action on each addressed destination card opens the same
composer used to add one, prefilled, saving through the already-implemented
`PUT /delivery-orders/{id}` without touching that destination's line
assignments.

**Independent Test**: Record a destination, assign lines to it, edit its date
through the new action, and confirm the header shows the new date while the
assigned quantities and the distribution rail are unchanged. Independent of
US1/US2/US4.

### Tests for User Story 3

- [X] T022 [P] [US3] Add a `group('updateHeader —` block to
  `test/unit/features/sales/delivery_order_repository_impl_test.dart`
  (mirror the existing `create`/`addLine` group style and
  `_FakeHttpClientAdapter`): a successful update returns the changed
  destination; a 409 body (non-draft order) surfaces as the app's conflict
  error; a 422 body surfaces as a validation error (research R9).
- [X] T023 [P] [US3] Extend
  `test/widget/features/sales/destination_card_test.dart`: the edit action
  (`Key('destination_edit_<id>')`) is present and precedes the remove action
  in tab/paint order when `enabled` and an `onEdit` callback are supplied;
  absent when `onEdit` is `null`; absent/disabled when `enabled: false`
  (closing).
- [X] T024 [P] [US3] Extend
  `test/widget/features/sales/destination_editor_error_test.dart`: passing a
  non-null `destination` prefills the address/contact/date buttons and the
  instructions field from it, the confirm button reads `saveButton`, saving
  calls `DeliveryController.updateDestination` (not `addDestination`), and a
  refused save keeps the sheet open with the server's message while the
  destination on screen is unchanged (FR-022).
- [X] T025 [US3] Extend
  `test/widget/features/sales/delivery_step_layout_test.dart`: pressing a
  card's edit action opens the composer as a right side sheet at ≥ 1200 px and
  as a bottom sheet below it — the same two presentations `_openAddDestinationSheet`
  already produces.

### Implementation for User Story 3

- [X] T026 [US3] Add `Future<Destination> updateDestination({required int
  destinationId, int? shipTo, int? contact, DateTime? date, String?
  comment})` to `DeliveryController` in
  `lib/features/sales/presentation/delivery/delivery_controller.dart`,
  calling `deliveryOrderRepositoryProvider.updateHeader(...)` and replacing
  the entry through the existing `_replace` helper (which re-runs
  `_labelled`) — no refetch of the list (depends on T022 existing and
  failing).
- [X] T027 [US3] In
  `lib/features/sales/presentation/delivery/destination_editor.dart`: add an
  optional `Destination? destination` constructor parameter. When non-null,
  initialize `_shipTo`/`_addressLabel` from `destination.shipTo`/
  `addressSummary`, `_contact`/`_contactLabel` from `destination.contact`/
  `contactName`, `_date` from `destination.date`, and the instructions
  controller from `destination.comment ?? ''`; the confirm button's label
  becomes `l10n.saveButton`; `_submit` calls
  `deliveryControllerProvider(...).updateDestination(destinationId:
  destination.id, shipTo: _shipTo, contact: _contact, date: _date, comment:
  ...)` instead of `addDestination`. Every existing key
  (`destination_editor`, `destination_address_button`, etc.) is unchanged
  (depends on T026, T024 existing and failing).
- [X] T028 [US3] In
  `lib/features/sales/presentation/delivery/delivery_step.dart`: rename/
  generalize `_openAddDestinationSheet` to accept an optional `Destination?
  destination`, threading it into the `DestinationEditor` it builds and into
  the sheet's title (`posAddDestinationSheetTitle` vs
  `posEditDestinationSheetTitle`, from T001/T002); keep `useRootNavigator:
  true` in both branches (spec 026 research R10 — the nested
  `StatefulShellBranch` Navigator would otherwise tear the sheet down). Wire
  each `DestinationCard`'s new `onEdit` to `() =>
  _openDestinationSheet(destination: destination)` (depends on T025 existing
  and failing).
- [X] T029 [US3] In
  `lib/features/sales/presentation/delivery/destination_card.dart`: add an
  `onEdit` `VoidCallback?` parameter and render its `IconButton`
  (`Key('destination_edit_${destination.id}')`, `CatalogAction.edit.icon`,
  `l10n.editActionTooltip`) first among the trailing header controls, before
  the existing remove `IconButton`, shown only when `widget.enabled &&
  widget.onEdit != null` (depends on T023 existing and failing).

**Checkpoint**: A wrong address, recipient or date on any destination is
correctable without losing its line assignments. Independently testable and
demoable; does not depend on US1, US2 or US4.

---

## Phase 6: User Story 4 - See what stays at the store (Priority: P3)

**Goal**: The "Recoge en tienda" row expands like a destination card, listing
every sale line with the quantity staying at the store — read-only, no edit,
no remove.

**Independent Test**: On a mixed sale with two lines partly assigned to a
delivery destination, expand the store row and confirm each line appears with
the quantity left for the counter, and that the sum agrees with the row's
header and the distribution rail.

### Tests for User Story 4

- [X] T030 [P] [US4] New widget test
  `test/widget/features/sales/destination_counter_row_test.dart`: collapsed by
  default; tapping the header expands it and shows every sale line
  (`Key('counter_line_<saleLineId>')`) with its store share, zeros included;
  header line/unit counts match the sum of the body's own figures
  (data-model §3); the row renders correctly from the preview-only source (no
  `counterDestination`), from the recorded-destination-only source, and from
  a case where **both** contribute non-zero shares to the same line (research
  R11's behavior-change case); no stepper, claim-all, edit or remove control
  appears anywhere in the expanded body.
- [X] T031 [P] [US4] Extend
  `test/widget/features/sales/pos_compact_delivery_test.dart` if it asserts on
  the counter row's fixed (non-expandable) shape today — update the
  expectation to allow expansion, or add a case confirming it still renders
  correctly at the compact tier.

### Implementation for User Story 4

- [X] T032 [P] [US4] Extract the read-only line-row shape from
  `DestinationCard._readOnlyRow` in
  `lib/features/sales/presentation/delivery/destination_card.dart` into a
  shared function/widget in a new
  `lib/features/sales/presentation/delivery/destination_line_row.dart`
  (product name + formatted quantity, `Key('...')` parameterized by caller),
  and update `DestinationCard._readOnlyRow`'s call site to use it — same
  visual result, so no `DestinationCard` test changes (depends on T030
  existing and failing, since the new file's shape is asserted through the
  counter row test).
- [X] T033 [US4] In
  `lib/features/sales/presentation/delivery/destination_counter_row.dart`:
  change `DestinationCounterRow` from `ConsumerWidget` to
  `ConsumerStatefulWidget` with its own `_expanded` (default `false`); wrap
  the existing header `Row` in an `InkWell`/`Padding` matching
  `DestinationCard`'s header treatment, add the `expand_more`/`expand_less`
  trailing icon, and reveal the body through the same `AnimatedSize` (200 ms)
  + `Divider(height: 1, color: outlineVariant)` pattern `DestinationCard`
  uses (depends on T032).
- [X] T034 [US4] In the same file: compute `storeShare(line)` per
  `distribution` entry as `(counterDestination?.lines-derived per-destination
  share ?? '0') + line.atCounter` (data-model §3), render one row per **sale
  line** in `distribution` order via T032's shared row widget under the
  heading `l10n.posCounterPickupLinesTitle` (from T001/T002), and derive the
  header's `lines`/`units` counts from this same computed list rather than
  from `counterDestination`/the preview separately (FR-028) (depends on
  T033).

**Checkpoint**: The store's share is as legible as any other destination's.
Independently testable and demoable; does not depend on US1, US2 or US3.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Whole-feature verification once every story above is in.

- [X] T035 Run `flutter analyze` clean across the changed files. Clean
  across the whole repo, not just the changed files.
- [X] T036 Run the full suite — `flutter test` — and confirm
  `test/unit/features/sales/line_distribution_test.dart`,
  `test/unit/features/sales/delivery_order_repository_impl_test.dart`,
  `test/unit/core/formatting_guard_test.dart`, and
  `test/unit/core/l10n_parity_test.dart` all still pass untouched (research
  R12, plan's Constitution Check). 2074 passed, 47 skipped (live-backend
  integration tests, per repo convention), 0 failed. One unrelated suite —
  `test/screenshots/` (a documentation screenshot generator, not a
  regression gate per its own file doc) — needed regenerating: FR-008 now
  correctly greys out the decrement button at the capture floor, which a
  pre-feature screenshot didn't reflect. Regenerated via
  `flutter test test/screenshots/ --update-goldens`, re-verified clean
  afterward. `test/golden/` (the real pixel gate) was untouched throughout.
- [X] T037 Work through [quickstart.md](./quickstart.md) §3 and §5. Note:
  this session has no interactive browser — the by-hand checks were
  exercised through equivalent automated widget tests instead (burst-tap
  coalescing and live controls: `sale_line_row_test.dart`; type-and-abandon,
  step-from-confirmed, reduced motion: `quantity_stepper_widget_test.dart`,
  `quantity_stepper_controller_test.dart`; the store row's two sources:
  `destination_counter_row_test.dart`). FR-032/SC-008's width and text-scale
  coverage rides on the existing `sale_line_symmetry_test.dart` and the
  no-overflow sweep in `delivery_step_layout_test.dart`. The actual
  `flutter run -d chrome` walkthrough at 1440/1024/380 px and the largest
  text-size level is still owed as a human pass before shipping.
- [X] T038 Work through [quickstart.md](./quickstart.md) §4 and §6 against a
  live mbe-api (confirmed reachable at `127.0.0.1:8000`): logged in as the
  admin account, `PUT /api/v1/delivery-orders/28237` (a real draft delivery
  order) with `{"comment": "..."}` — the response confirmed the comment
  changed, `ship_to`/`fulfillment_type` were untouched (null-means-unchanged,
  research R9, live), and both lines were byte-identical before and after
  (FR-020). Also ran `pos_delivery_split_flow_test.dart` (spec 026's own
  live integration test) against the same server to confirm the refactored
  stepper's assign/adjust/drop dispatch still works end to end. Not done:
  watching the server log for a live burst-tap producing exactly one `PUT` —
  covered instead by the controller's own unit tests and by
  `destination_assignment_test.dart`'s `verify(...).called(1)` against a
  live-shaped mock.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: no dependencies — start immediately.
- **Foundational (Phase 2)**: empty — nothing blocks more than one story.
- **User Stories (Phase 3–6)**: each depends only on Setup (for US3/US4's
  l10n keys). US2 additionally depends on US1 (same file, extended state
  machine) — implement in that order. US3 and US4 have no dependency on US1,
  US2, or each other, and no dependency on US1/US2's completion even though
  US3 touches `destination_card.dart`'s header (a different region of the
  same file US1 also edits in T012).
- **Polish (Phase 7)**: depends on every story you choose to ship.

### User Story Dependencies

- **US1 (P1)**: Setup only.
- **US2 (P1)**: Setup + **US1** (extends `QuantityStepperController`/
  `QuantityStepper` in place).
- **US3 (P2)**: Setup only. Independently shippable before or after US1/US2.
- **US4 (P3)**: Setup only. Independently shippable before or after US1/US2/US3.

### Within Each User Story

- Tests are written first and confirmed failing before their implementation
  task.
- The controller (US1: T007, US2: T017) lands before the widget/view work
  that depends on it.
- Each host file (`sale_line_row.dart`, `sale_line_card.dart`,
  `destination_card.dart`) is edited once per story that touches it — T010/
  T011/T012 for US1, T029 for US3's header — never twice in the same task.

### Parallel Opportunities

- T001/T002 (the two `.arb` files) in parallel.
- T004/T005/T006 (three independent test files) in parallel, before any US1
  implementation task.
- T010/T011 (the two capture hosts) in parallel once T008/T009 land; T012
  (the delivery host) is independent of both and can run alongside them.
- T014/T015 in parallel before US2's implementation tasks.
- T022/T023/T024 in parallel before US3's implementation tasks; T026
  (controller) and T029 (card header) touch different files and can proceed
  in parallel once T022/T023 exist.
- T030/T031 in parallel before US4's implementation tasks.
- **US3 and US4 can be built entirely in parallel with US1+US2**, by a second
  contributor, from the moment Setup finishes.

---

## Parallel Example: Setup → three independent story starts

```bash
# After T001–T003 (Setup) complete, three workstreams can start together:

# Workstream A — US1/US2 (one file, sequential internally)
Task: "Unit tests for QuantityStepperController in test/unit/features/sales/quantity_stepper_controller_test.dart"
Task: "Create lib/features/sales/presentation/widgets/quantity_stepper.dart (controller)"

# Workstream B — US3
Task: "Add group('updateHeader —' to test/unit/features/sales/delivery_order_repository_impl_test.dart"
Task: "Add updateDestination to DeliveryController in lib/features/sales/presentation/delivery/delivery_controller.dart"

# Workstream C — US4
Task: "New widget test test/widget/features/sales/destination_counter_row_test.dart"
Task: "Extract destination_line_row.dart from DestinationCard._readOnlyRow"
```

---

## Implementation Strategy

### MVP First (User Story 1 + 2)

1. Complete Phase 1: Setup.
2. Complete Phase 3: US1 — the debounced stepper, everywhere.
3. Complete Phase 4: US2 — the confirm/discard/animation on top of it.
4. **STOP and VALIDATE**: run quickstart.md §3 by hand.
5. Deploy/demo — this alone fixes the freeze-on-burst-tap defect the feature
   opens with.

### Incremental Delivery

1. Setup → Foundation ready (nothing to wait on beyond it).
2. US1 + US2 → validate → deploy (the stepper, everywhere it's used).
3. US3 → validate → deploy (destination edit).
4. US4 → validate → deploy (expandable store row).
5. Each story adds value without breaking a previously shipped one — verified
   by that story's own tests staying green as later stories land.

### Parallel Team Strategy

With two contributors: one takes US1 → US2 (the shared control, sequential by
nature); the other takes US3 and US4 in either order, both independent of the
first. Both workstreams only share Setup as a prerequisite.
