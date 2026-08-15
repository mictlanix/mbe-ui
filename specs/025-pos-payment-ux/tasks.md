# Tasks: Point of Sale — Payment Step Look & Feel

**Input**: Design documents from `/specs/025-pos-payment-ux/`

**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/payment-surface.md](./contracts/payment-surface.md), [quickstart.md](./quickstart.md)

**Tests**: Included — spec 025 FR-031/SC-008 require the existing widget-test
keys to keep passing, and this feature adds specific layout/regression
guarantees (aspect ratio, no-scroll, reflow survival) that are only checkable
with new widget tests.

**Organization**: Tasks are grouped by user story (spec.md priorities), so each
story is a complete, independently testable increment.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Maps to US1–US5 from spec.md
- File paths are exact and relative to the repository root

## Path Conventions

Single Flutter project. `lib/` for source, `test/` for tests — no `src/`/
`backend/`/`frontend/` split (per plan.md's Project Structure).

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: The one piece every user story reads — the icon mapping and the
copy — built and verified before any presentation widget consumes them.

- [ ] T001 [P] Add `IconData paymentMethodIcon(int code)` to
  `lib/core/domain/payment_method.dart`, beside the existing
  `paymentMethodLabel`, switching on `PaymentMethod.fromCode` per the mapping
  table in [research.md §R7](./research.md#r7--method-icons-need-a-mapping-and-it-belongs-beside-the-label-mapping),
  falling back to `Icons.payments_outlined` for an unmapped code — mirroring
  `paymentMethodLabel`'s documented fallback posture.
- [ ] T002 [P] Create `test/unit/core/domain/payment_method_test.dart`
  asserting `paymentMethodIcon` returns the mapped icon for `cash`,
  `creditCard`, `debitCard`, `eft` and one code from every other group in the
  table, and falls back to `Icons.payments_outlined` for an unrecognized code
  (no existing test file covers `payment_method.dart`; this is a new file).
- [ ] T003 Add the five new keys to `lib/l10n/app_es.arb` and
  `lib/l10n/app_en.arb` per [research.md §R10](./research.md#r10--copy-four-new-keys-one-reworded-value-one-orphan-removed):
  `posPaymentChangeLabel`, `posPaymentGateHint`,
  `posPaymentMethodRequiresReference`, `posPaymentMethodNoReference`,
  `posPaymentMethodSectionLabel`; reword `posPaymentBalance`'s value to
  "Restante" (es) / "Remaining" (en) — the key itself is unchanged.
- [ ] T004 Run `flutter gen-l10n` and confirm
  `test/unit/core/l10n_parity_test.dart` passes with the three new keys
  present in both locales (the removal of `posPaymentChange` happens in T016,
  once nothing references it — attempting it here would fail parity against a
  still-live usage).

**Checkpoint**: `paymentMethodIcon` and the reworded/added copy exist and are
tested in isolation. No presentation widget has changed yet.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: The one latent defect research found that every user story would
otherwise inherit — an unseeded controller that loses a keyed amount on the
very reflow this feature introduces.

**⚠️ CRITICAL**: T005 must land before any layout task that can trigger a
reflow (all of US1, US3).

- [ ] T005 In `lib/features/sales/presentation/payment/payment_amount_field.dart`,
  seed `_controller` from the current draft on construction —
  `TextEditingController(text: ref.read(paymentControllerProvider).amount)` in
  `initState` — per [research.md §R5](./research.md#r5--the-draft-has-to-survive-the-reflow-and-today-it-would-not).
  Leave the existing post-frame "clear on reset" listener as it is.
- [ ] T006 [P] Add a regression test to
  `test/widget/features/sales/payment_step_gate_test.dart` (or a new file
  alongside it) that types an amount into `payment_amount_field`, disposes and
  remounts `PaymentAmountField` against the same provider container (simulating
  the widget being torn down and rebuilt under a new ancestor), and asserts the
  field still shows the keyed amount — this must **fail before T005** and pass
  after it.

**Checkpoint**: The reflow hazard is closed and proven closed. Every later
layout task can freely restructure the widget tree without losing state.

---

## Phase 3: User Story 1 - Take a payment without scrolling (Priority: P1) 🎯 MVP

**Goal**: At ≥ 1200 px, the whole step — amount, quick amounts, methods,
keypad, reference, apply, the applied-payments rail — is visible with zero
scrolling, and applying a tender updates the rail in place.

**Independent Test**: Open the payment step on a sale with an outstanding
balance at a 1440×900 surface; take a full-balance cash payment end to end
without scrolling any region.

### Tests for User Story 1

- [ ] T007 [P] [US1] Create
  `test/widget/features/sales/payment_step_layout_test.dart` with a case
  asserting that at a 1280×900 surface, `payment_amount_field`,
  `payment_method_1` (fallback cash tile), a `NumberPad` key, and
  `payment_close_button` are **all simultaneously present** with no
  `Scrollable` needed to reach any of them (query `find.byType(Scrollable)`
  count/position, or assert each target's `Offset` lies within the surface
  bounds without a preceding scroll) — this is SC-001's assertion and must
  fail against today's single-`ListView` step before implementation.
- [ ] T008 [P] [US1] In the same file, add a case that applies a cash payment
  end to end at 1280×900 (tap `payment_method_1`, enter an amount into
  `payment_amount_field`, tap `payment_submit_button`) and asserts an
  `applied_payment_*` row appears without any `tester.drag`/`scrollUntilVisible`
  call in the test body.

### Implementation for User Story 1

- [ ] T009 [US1] Create
  `lib/features/sales/presentation/payment/payment_summary_panel.dart` as a
  `ConsumerWidget` per
  [contract §6](./contracts/payment-surface.md#6-paymentsummarypanel-new--one-widget-two-homes):
  total/paid/remaining rows from `sale`, a divider, then the change row from
  `PaymentController.changeFor(sale.balance)` (watched, so it tracks the keyed
  amount live), the `payment_close_button` `FilledButton.tonal` gated on
  `PosStepController.canLeavePayment`, and the `posPaymentGateHint` line shown
  only while that button is disabled with a balance outstanding. Surface:
  `theme.elevations.raised.surfaceColor` with a top `outlineVariant` hairline,
  matching `SaleTotalsBar`'s footer treatment.
- [ ] T010 [US1] Create
  `lib/features/sales/presentation/payment/payment_capture_pane.dart`
  composing, top to bottom, per
  [contract §3](./contracts/payment-surface.md#3-paymentcapturepane-new): the
  amount label + `PaymentAmountField` (restyled in T012), the quick-amount
  chips row (moved from `PaymentAmountField`, unchanged content), a
  `LayoutBuilder` that places `PaymentMethodGrid` and `NumberPad` side by side
  when the pane is ≥ 900 px wide and stacked otherwise (research R2), the
  reference field (shown only when `draft.requiresReference`), and
  `payment_submit_button` at the pane's foot. Takes `enabled: !draft.submitting`
  and passes it through to every child.
- [ ] T011 [US1] Rewrite
  `lib/features/sales/presentation/payment/payment_step.dart` as the composer:
  a `LayoutBuilder`/`MediaQuery` check on
  `LayoutBreakpoints.large` (research R1) building either a two-pane `Row`
  (`Expanded(PaymentCapturePane)` beside a fixed 360 px rail —
  `Column[header, Expanded(AppliedPaymentsPanel), PaymentSummaryPanel]`) or the
  one-column shape (built fully in US3, T014); keeps the `ErrorBanner` at the
  top of the capture pane; keeps the constructor signature
  `PaymentStep({required Sale sale, required VoidCallback onClose})` unchanged.
- [ ] T012 [P] [US1] In
  `lib/features/sales/presentation/payment/payment_amount_field.dart`, restyle
  the amount `TextField` per
  [research.md §R4](./research.md#r4--the-amount-display-is-still-a-textfield-dressed-as-the-mocks-figure):
  `textAlign: TextAlign.end`, `prefixText` from the sale's currency,
  `filled: true`, style `typeRoles.heroHeading` with `TypeRoles.monoFamily` and
  `FontFeature.tabularFigures()`. Extract the quick-amount chips row out of
  this widget into whatever `PaymentCapturePane` (T010) renders next to it —
  `PaymentAmountField` keeps the field and the label only. Preserve the
  `payment_amount_field` key.
- [ ] T013 [US1] In
  `lib/features/sales/presentation/payment/applied_payments_panel.dart`,
  restyle each `ListTile` as a card per
  [contract §5](./contracts/payment-surface.md#5-appliedpaymentspanel--the-rails-list):
  a leading circular icon from `paymentMethodIcon` (T001), the amount as the
  row's headline (`typeRoles.money`), method + reference as the supporting
  line, keeping the pending-validation and cancelled/struck-through treatments
  and the reversal `IconButton` exactly as they are. Preserve the
  `applied_payment_<id>` key and the reversal dialog's keys verbatim.

**Checkpoint**: At ≥ 1200 px the step is a full working two-pane payment
surface — this alone is the MVP slice.

---

## Phase 4: User Story 2 - Read what is owed and leave the step (Priority: P1)

**Goal**: Total, paid, remaining and change are one block with the exit action
directly beneath it; the gate hint explains a disabled exit; the change row is
permanent, not a line that appears only on an over-tender.

**Independent Test**: With a part-paid sale, read all four figures in one
block, then apply the remainder and watch the exit become available in that
same block, with the hint disappearing.

### Tests for User Story 2

- [ ] T014 [P] [US2] Create
  `test/widget/features/sales/payment_summary_panel_test.dart` asserting: all
  four labeled rows (`posPaymentTotal`, `posPaymentPaid`, `posPaymentBalance`,
  `posPaymentChangeLabel`) render simultaneously; the change row reads the
  zero-amount formatting with no tender keyed; keying an amount larger than the
  balance updates the change row to the excess and clearing it returns the row
  to zero; `posPaymentGateHint` is visible only while
  `payment_close_button.onPressed` is `null` and the balance is non-zero, and
  absent once the gate opens or on credit terms (mirrors the existing gate
  cases in `payment_step_gate_test.dart`, applied to the new panel directly).

### Implementation for User Story 2

- [ ] T015 [US2] Confirm `PaymentSummaryPanel` (built in T009) reads
  `PaymentController.changeFor` via `ref.watch` (not `ref.read`) so the change
  row updates live as the amount field changes — add the watch if T009 used
  `read`. This is the one line research R9 flags as easy to get wrong.
- [ ] T016 In `lib/l10n/app_es.arb` and `lib/l10n/app_en.arb`, remove the now-
  unused `posPaymentChange` key (its interpolated "Cambio: {amount}" sentence
  is fully superseded by the permanent `posPaymentChangeLabel` row from T009);
  re-run `flutter gen-l10n` and confirm
  `test/unit/core/l10n_parity_test.dart` still passes and nothing else
  references `posPaymentChange` (`grep -rn posPaymentChange lib/` returns
  nothing outside the generated localization files).

**Checkpoint**: The money block and the exit read as one unit, in both the
rail (US1) and — once US3 lands — the pinned footer.

---

## Phase 5: User Story 4 - Choose a method and know what it will ask for (Priority: P2)

**Goal**: Payment methods render as tiles — icon, name, a "requires reference"
line — with the selected tile outlined and check-marked, replacing today's
`ChoiceChip` row.

**Independent Test**: With a facility that has both reference-requiring and
reference-free options configured, read each tile's secondary line and confirm
it matches what selecting it does.

### Tests for User Story 4

- [ ] T017 [P] [US4] Create
  `test/widget/features/sales/payment_method_grid_test.dart` covering: one tile
  per configured `PaymentMethodOption`, each showing its icon (via
  `paymentMethodIcon`) and name; the secondary line reads
  `posPaymentMethodRequiresReference` or `posPaymentMethodNoReference`
  according to `option.requiresReference`; tapping a tile marks it with both a
  border change and a visible `Icons.check_circle` (not fill alone — FR-014);
  selecting a reference-requiring tile is what the capture pane uses to decide
  whether to show `payment_reference_field` (verify via the controller's
  `requiresReference` state, not by re-testing `PaymentCapturePane` here); a
  facility with zero configured options renders the fallback tiles at keys
  `payment_method_<code>` for `cash`/`creditCard`/`debitCard`/`eft`, none
  requiring a reference; the loading state still shows
  `LinearProgressIndicator` and the error state still renders nothing that
  blocks the rest of the step.

### Implementation for User Story 4

- [ ] T018 [US4] Rewrite
  `lib/features/sales/presentation/payment/payment_method_grid.dart` to render
  tiles per
  [contract §4](./contracts/payment-surface.md#4-paymentmethodgrid--tiles):
  a `LayoutBuilder` + `Wrap` (never a `GridView`/aspect-ratio grid — research
  R6) sizing two `SizedBox`-width columns when the available width admits two
  ≥ 260 px tiles, one column otherwise; each tile a `Material`+`InkWell` with
  `shapes.md` radius, 1 px `outlineVariant` border unselected, 2 px
  `colorScheme.primary` border + `elevations.engaged.surfaceColor` fill +
  trailing check when selected, wrapped in
  `Semantics(button: true, selected: …, label: name)`. Preserve
  `payment_option_<id>` and `payment_method_<code>` keys and the existing
  fallback-set logic verbatim — only the rendered widget changes.

**Checkpoint**: Tiles work standalone, independent of the pane layout around
them (already exercised inside US1's `PaymentCapturePane`).

---

## Phase 6: User Story 3 - Take a payment on a phone (Priority: P2)

**Goal**: Below 1200 px, the same content stacks in one column in the mock's
phone order, with the money summary and the exit pinned to the bottom edge —
scrolling only above that footer, never past it.

**Independent Test**: Open the step at a phone width and take a payment
without losing sight of the balance or the exit; confirm nothing is clipped or
scrolls horizontally.

### Tests for User Story 3

- [ ] T019 [P] [US3] Rewrite the phone-tier cases in
  `test/widget/features/sales/pos_compact_layout_test.dart`'s "the Cobro step
  on a phone" group: replace the `dragUntilVisible`-to-reach-`payment_close_button`
  assertion with one that finds `payment_close_button` **without** any scroll
  gesture (it is now in a pinned footer, not inside the scrolling `ListView`),
  and keep the existing `expectNoHorizontalScroll` assertions for both the
  ordinary and the wide-amount (`1234567.89`) cases.
- [ ] T020 [P] [US3] In `payment_step_layout_test.dart` (from T007), add a
  1024×768 case (the one-column, non-phone tier) asserting: the method grid
  and the keypad stack vertically (not side by side, since the pane is
  narrower than 900 px — research R2), and `PaymentSummaryPanel`'s content is
  pinned at the bottom edge rather than scrolling with the header content.

### Implementation for User Story 3

- [ ] T021 [US3] Complete the one-column branch of `PaymentStep`
  (`lib/features/sales/presentation/payment/payment_step.dart`, started in
  T011): below `LayoutBreakpoints.large`, render
  `Column[ Expanded(scrolling content: header/error, PaymentCapturePane's
  non-action content, AppliedPaymentsPanel), PaymentSummaryPanel as a pinned
  footer band ]`; below `LayoutBreakpoints.compact`
  (`LayoutBreakpoints.isCompact`) the scrolling region becomes a single
  `ListView` per spec 020 FR-053, unchanged from today's scrolling posture —
  only the footer pinning and the content order are new.

**Checkpoint**: All three width tiers (two-pane, one-column, phone) render
correctly; `pos_compact_layout_test.dart` and the new layout tests are green.

---

## Phase 7: User Story 5 - Key an amount on a pad sized for fingers (Priority: P3)

**Goal**: The keypad's keys never change proportion or exceed their width cap,
regardless of the pane they are dropped into by US1/US3's new layout.

**Independent Test**: Render the step at phone, tablet and 1440 px widths and
compare the keypad's key proportions — they must not vary with the pane's
height.

### Tests for User Story 5

- [ ] T022 [P] [US5] Add a case to `payment_step_layout_test.dart` that
  renders the full `PaymentStep` (not the bare `NumberPad`) at 390×900,
  1024×768 and 1440×900, and asserts the `number_pad_7` key's rendered
  `Size` has the same width/height **ratio** at all three surfaces — proving
  the pad does not inherit a stretch from whatever pane `PaymentCapturePane`
  (T010) or the one-column body (T021) hands it. This is the guarantee
  `number_pad_test.dart` gives the widget in isolation; this task proves it
  survives composition.
- [ ] T023 [P] [US5] Confirm (no code change expected) that
  `flutter test test/widget/core/widgets/number_pad_test.dart` and the four
  `test/golden/goldens/number_pad_*.png` goldens are untouched and green —
  this is the explicit non-regression check research R3 and FR-011 call for.
  If either fails, the defect is in T010/T021's placement of `NumberPad`, not
  in the widget itself — fix the placement, never `number_pad.dart`.

### Implementation for User Story 5

- [ ] T024 [US5] No changes to `lib/core/widgets/number_pad.dart` (research
  R3, FR-011) — this task is the explicit acknowledgment that "keep the
  keypad's aspect ratio" is satisfied by construction once T010/T021 place the
  pad inside a `ConstrainedBox`/fixed-width slot rather than stretching it,
  and is verified by T022/T023 rather than by editing the widget.

**Checkpoint**: The keypad's proportions are proven stable under every layout
this feature introduces, with zero edits to the shared widget.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Whole-feature verification that spans every story.

- [ ] T025 [P] Run `flutter analyze` from the repo root and resolve any
  warning introduced by this feature's files.
- [ ] T026 [P] Grep the diff of every changed file under
  `lib/features/sales/presentation/payment/` and `lib/core/domain/payment_method.dart`
  for literal `Color(`, hex colors, bare numeric font sizes, or `EdgeInsets`
  values not sourced from `Theme.of(context).spacing`/`.shapes`/`.typeRoles`/
  `.elevations` — confirms SC-006/FR-028 (zero literal design values).
- [ ] T027 Run the full suite —
  `flutter test test/widget/features/sales/ test/widget/core/widgets/number_pad_test.dart test/unit/core/domain/payment_method_test.dart test/unit/core/l10n_parity_test.dart`
  — and confirm everything is green, including every test listed in
  [quickstart.md](./quickstart.md)'s risk table.
- [ ] T028 Walk [quickstart.md](./quickstart.md)'s "Driving the real screen"
  width table (1440, 1200/1199 boundary, 1024, 390 px) against a live register
  with an open cash session, confirming SC-001–SC-010 by hand where they are
  not already covered by an automated test (the network-panel check for
  SC-009 in particular has no automated equivalent in this feature).

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately.
- **Foundational (Phase 2)**: Depends on Setup (T001/T003 exist, since the
  test infra and icon helper are referenced elsewhere) but is really only
  blocking because of the reflow bug — T005/T006 must land before any task
  that restructures the widget tree (T010, T011, T021).
- **User Stories (Phase 3–7)**: All depend on Phase 1 + Phase 2.
  - **US1 (T007–T013)** is the MVP slice and the one every other story
    composes with — US2's panel is *placed* by US1's composer, US3's footer
    reuses US1's `PaymentSummaryPanel`, US4's tiles are *placed* inside US1's
    `PaymentCapturePane`, US5's proof runs against US1's composed tree.
  - **US2 (T014–T016)** can be built in parallel with US1's T010/T011 — it only
    needs `PaymentSummaryPanel`'s existence (T009), not the composer around it.
  - **US4 (T017–T018)** is fully independent of US1/US2/US3 — it can be built,
    tested and reviewed against `PaymentMethodGrid` alone, in parallel with
    everything else in Phase 3–4.
  - **US3 (T019–T021)** depends on US1's `PaymentCapturePane` (T010) and
    `PaymentSummaryPanel` (T009) existing, since it composes the same pieces
    into the narrower shapes.
  - **US5 (T022–T024)** depends on US1's T010 and US3's T021 being in place —
    it is a proof over the composed tree, not a standalone build.
- **Polish (Phase 8)**: Depends on every story above being complete.

### Within Each User Story

- Tests before implementation, where a test is listed — each is written to
  fail against today's code first.
- `PaymentSummaryPanel`/`PaymentMethodGrid` (the leaves) before `PaymentCapturePane`/`PaymentStep`
  (the composites) that place them.
- Composite widgets before the cross-composition proofs (US5).

### Parallel Opportunities

- T001–T004 (Setup) can mostly run together; T004 depends on T003.
- T006 depends on T005 (test-first, but the fix and its proof are one unit —
  write T006 first, watch it fail, then do T005).
- T007, T008 (US1 tests) in parallel with each other; T012, T013 (US1 leaf
  widgets) in parallel with each other and with the US2/US4 tracks.
- **US2 and US4 can be executed entirely in parallel with US1's T010/T011**,
  by different people, since they touch disjoint files
  (`payment_summary_panel.dart` / `payment_method_grid.dart` vs.
  `payment_capture_pane.dart` / `payment_step.dart`).
- T025, T026 (Polish) in parallel; T027/T028 depend on everything before them.

---

## Parallel Example: User Story 1

```bash
# Tests for User Story 1, in parallel:
Task: "payment_step_layout_test.dart — everything visible at 1280x900, no scroll"
Task: "payment_step_layout_test.dart — apply a payment end to end, no scroll"

# Leaf widgets for User Story 1, in parallel:
Task: "Restyle PaymentAmountField's TextField to the headline treatment"
Task: "Restyle AppliedPaymentsPanel's rows to cards"
```

## Parallel Example: Across stories (once Phase 1+2 are done)

```bash
Task: "US1 — build PaymentSummaryPanel (T009)"
Task: "US4 — rewrite PaymentMethodGrid to tiles (T018), fully independent file"
Task: "US2 — write payment_summary_panel_test.dart (T014) against T009's contract"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 (Setup) and Phase 2 (Foundational — the reflow fix).
2. Complete Phase 3 (US1): the two-pane shape, the amount headline, the applied
   payments cards, the summary panel, the composer.
3. **STOP and VALIDATE**: run T007/T008, drive the 1440 px case from
   quickstart.md by hand.
4. This alone delivers the complaint the feature exists to fix — everything
   visible on a wide screen, no scrolling.

### Incremental Delivery

1. Setup + Foundational → the ground is safe to build on.
2. US1 → validate → this is the MVP.
3. US2 in parallel with US1's composer work → the money block reads as one
   unit the moment US1 lands.
4. US4 in parallel with both → tiles are a drop-in replacement, provable alone.
5. US3 → the phone/tablet shapes, once US1's pieces exist to reuse.
6. US5 → the proof that nothing above regressed the keypad.
7. Polish → analyze, token-literal sweep, full suite, live drive.

### Parallel Team Strategy

With three people, once Phase 1+2 are done: one takes US1's composer track
(T009–T011, T012, T013), a second takes US4 (T017–T018) entirely independently,
a third takes US2's test (T014) against US1's emerging `PaymentSummaryPanel`
contract. US3 and US5 wait for US1's pieces, so they are the natural next
assignment for whoever finishes first.

---

## Notes

- [P] tasks touch different files with no unmet dependency.
- Every task names its exact file(s) — none should need re-reading the plan to
  start.
- Verify each "Tests" task fails before its matching implementation task, where
  both exist.
- No task in this list adds a request, a provider, or a controller method —
  per FR-001/FR-002/SC-009, this feature is presentation-only.
- `lib/core/widgets/number_pad.dart` appears in no implementation task on
  purpose (T024) — the requirement about it is a non-regression, not a change.
