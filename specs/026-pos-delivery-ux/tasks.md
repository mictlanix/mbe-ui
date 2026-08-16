# Tasks: Point of Sale — Delivery Step Look & Feel

**Input**: Design documents from `/specs/026-pos-delivery-ux/`

**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/delivery-surface.md](./contracts/delivery-surface.md), [quickstart.md](./quickstart.md)

**Tests**: Included — FR-042/SC-009 require the existing widget-test keys to
keep passing, and this feature adds specific guarantees (independent card
expansion, badge↔chip agreement, clamp-before-send, dispatch correctness) that
are only checkable with new widget tests. The three mbe-api dependencies this
plan carried ([#163](https://github.com/mictlanix/mbe-api/issues/163),
[#165](https://github.com/mictlanix/mbe-api/issues/165),
[#171](https://github.com/mictlanix/mbe-api/pull/171)) have all landed and the
client is regenerated — nothing below is blocked.

Phase 9 is **retrospective**: work done after T031 in response to live driving
and to #171 arriving mid-flight.

**Organization**: Tasks are grouped by user story (spec.md priorities), so each
story is a complete, independently testable increment. Build order follows
plan.md's dependency chain (A→H) rather than story-number order in places: US2
extends the card US1 builds, and US4's sheet reuses US2's `addLine` dispatch
groundwork, so both land after US1 even though US2 is also P1.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Maps to US1–US5 from spec.md
- File paths are exact and relative to the repository root

## Path Conventions

Single Flutter project. `lib/` for source, `test/` for tests — no `src/`/
`backend/`/`frontend/` split (per plan.md's Project Structure).

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: The nine new labels and one removal every later widget references,
built and verified in isolation before any presentation file consumes them.

- [X] T001 [P] Add eight of the nine new keys from
  [research.md §R11](./research.md#r11--localization-inventory) to
  `lib/l10n/app_es.arb`: `posDestinationBadge`, `posDeliveryDestinationsTitle`,
  `posDistributionRailSubtitle`, `posDeliveryAssignedUnits`,
  `posDestinationLinesTitle`, `posAddDestinationSheetTitle`,
  `posDestinationCounterChip`, `posDeliveryAssignmentRefused`. Leave
  `posDestinationQuantitiesTitle` (line 943) and `posAddDestinationNothingLeft`
  in place for now — the former is removed in T030 once nothing references it,
  the latter is added in T002 alongside its English pair for FR-016.
- [X] T002 [P] Add the same eight keys plus `posAddDestinationNothingLeft` (the
  ninth, FR-016/R14's disabled-add reason) to `lib/l10n/app_en.arb`, matching
  the `@key: {}`/placeholder metadata pattern already used by neighbouring
  entries (e.g. `posDestinationCounts`'s `{lines}`/`{units}` placeholders).
- [X] T003 Also add `posAddDestinationNothingLeft` to `lib/l10n/app_es.arb`
  (kept separate from T001 since it was decided later, per R14) — do this
  before T004 so both locales gain it together.
- [X] T004 Run `flutter gen-l10n` and confirm
  `test/unit/core/l10n_parity_test.dart` passes with all nine new keys present
  in both locales (depends on T001–T003).

**Checkpoint**: The full label set exists and is parity-checked. No
presentation widget has changed yet.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: The one piece of new production code every later story needs
before it can be exercised end to end: adding a line to a delivery order that
already exists. Built and unit-tested against the real service semantics
before any widget calls it, since two of those semantics
([research R13](./research.md#r13--add_lines-semantics)) are easy to get wrong
from the endpoint's name alone.

**⚠️ CRITICAL**: T005–T007 must land before any US2 task that calls `addLine`.
US1, US3 and US5 do not touch these files and are not blocked by this phase.

- [X] T005 Add `Future<Destination> addLine({required int destinationId, required int salesLineId, required String quantity})`
  to the `DeliveryOrderRepository` interface in
  `lib/features/sales/domain/repositories/delivery_order_repository.dart`,
  documented like its `updateLine`/`removeLine` neighbours.
- [X] T006 Implement `addLine` in
  `lib/features/sales/data/delivery_order_repository_impl.dart`, calling
  `DeliveryOrdersApi.addDeliveryOrderLineApiV1DeliveryOrdersDeliveryOrderIdLinesPost`
  and mapping the response through `Destination.fromResponse`, mirroring
  `updateLine`'s try/`DioException` shape (depends on T005).
- [X] T007 [P] Add a `group('addLine —` block to
  `test/unit/features/sales/delivery_order_repository_impl_test.dart` (mirror
  the existing `create`/`listForSale` group style and `_FakeHttpClientAdapter`)
  covering: a successful add returns the updated destination; a 409 body
  (duplicate line) surfaces as the app's conflict error; a 422 body
  (over-claim or unknown line) surfaces as a validation error — per
  [research R13](./research.md#r13--add_lines-semantics) (depends on T006).

**Checkpoint**: `addLine` is real, tested against realistic server responses,
and ready for US2 to call. US1/US3/US4/US5 can proceed without waiting for it.

---

## Phase 3: User Story 1 - Read every destination and what is left, without scrolling (Priority: P1) 🎯 MVP

**Goal**: At ≥ 1200 px the step is two regions — destinations left, a
distribution rail right — with a counter row, one collapsible card per
addressed destination (read-only line list for now), and the rail's chips
agreeing with the cards' badges. Below 1200 px the same content is one column.
Nothing scrolls except the two independent lists.

**Independent Test**: Open the Entrega step on a two-destination sale at
1440×900 and read every destination, every line's distribution and the finish
action without a scroll gesture (spec.md US1).

### Tests for User Story 1

- [X] T008 [P] [US1] Create `test/widget/features/sales/delivery_step_layout_test.dart`
  with cases per [quickstart §3](./quickstart.md#3-the-width-table): at 1440 px
  the counter row, both cards, the add action and the rail are all visible with
  no `Scrollable` needed to reach any of them (mirror
  `payment_step_layout_test.dart`'s no-scroll assertion style); at 1200 px the
  same holds and no card header wraps; at 1199 px the content is one column
  with the rail's foot pinned to the bottom edge; at 320–1920 px nothing
  overflows horizontally (`expectNoHorizontalScroll` from `pos_test_harness.dart`).
  These must fail against today's single-`ListView` `DeliveryStep`.
- [X] T009 [P] [US1] Create `test/widget/features/sales/destination_card_test.dart`
  asserting, per [contract §4](./contracts/delivery-surface.md#4-destination-card--destination_carddart):
  the collapsed header shows badge, address (or the pending-address fallback),
  contact/phone/date, and line/unit counts on one line; tapping the header
  expands it to list every sale line; two cards' expanded states are
  independent (expanding one does not change the other, and the list does not
  reorder); the remove action's key (`destination_remove_${id}`) is present on
  an addressed card and absent on the counter row.
- [X] T010 [P] [US1] Create `test/widget/features/sales/line_distribution_rail_test.dart`
  asserting, per [contract §5](./contracts/delivery-surface.md#5-distribution-rail--line_distribution_paneldart):
  the header states line and destination counts
  (`posDistributionRailSubtitle`); each `distribution_row_*` shows one chip per
  destination holding any of that line, each chip carrying the same badge
  letter (`D1`, `D2`, …) the matching `destination_card_*` shows in its header;
  a line still outstanding is marked by more than colour alone (an icon plus
  its chip treatment).

### Implementation for User Story 1

- [X] T011 [P] [US1] Rewrite `destination_card.dart`
  (`lib/features/sales/presentation/delivery/destination_card.dart`) as a
  `StatefulWidget` with its own `_expanded` flag
  ([research R5](./research.md#r5--card-expansion-hand-rolled-not-expansiontile)):
  a custom `InkWell` header row (badge, identity, `VerticalDivider`, counts,
  remove icon, chevron — [contract §4.1](./contracts/delivery-surface.md#41-header-always-visible-fr-013))
  and an `AnimatedSize` body listing **every** sale line (not only the ones
  this destination carries — FR-018), read-only for now: product name and the
  quantity this destination takes, with no stepper yet (US2 adds it in T017).
  Keeps `destination_card_${destination.id}` and `destination_remove_${id}`
  keys verbatim. Takes the badge label as a constructor parameter rather than
  computing it itself, so it agrees with the rail by construction
  ([research R8](./research.md#r8--badges-and-the-idbadge-map)).
- [X] T012 [P] [US1] Create `destination_counter_row.dart`
  (`lib/features/sales/presentation/delivery/destination_counter_row.dart`)
  per [contract §3](./contracts/delivery-surface.md#3-counter-row): a `Card`
  with no expand affordance and no remove action, reading its line/unit counts
  from the counter-pickup `Destination` when one exists, otherwise (mixed sale
  only) from the distribution's non-zero `atCounter` lines
  ([research R4](./research.md#r4--the-counter-row-without-a-counter-pickup-record)).
- [X] T013 [US1] Rewrite `line_distribution_panel.dart`
  (`lib/features/sales/presentation/delivery/line_distribution_panel.dart`) as
  the rail per [contract §5.1–§5.2](./contracts/delivery-surface.md#5-distribution-rail--line_distribution_paneldart):
  header with `posDistributionTitle` + `posDistributionRailSubtitle`; one
  `distribution_row_${saleLineId}` per sale line rendering per-destination
  chips from the badge map (taken as a parameter) plus a counter chip
  (`posDestinationCounterChip`) when anything remains unassigned; the ordered
  quantity right-aligned in `typeRoles.recordId`. The foot (assigned total,
  gate line, finish action) is US3's — leave a `foot` slot/parameter this task
  does not fill in yet (depends on T011 for the badge shape, but not on its
  implementation body).
- [X] T014 [US1] Rewrite `delivery_step.dart`
  (`lib/features/sales/presentation/delivery/delivery_step.dart`) as the
  two-shape host per [contract §1–§2](./contracts/delivery-surface.md#1-step-host--delivery_stepdart):
  build the badge map once over the addressed destinations in list order
  (`data-model.md §2.1`) and pass it to both the cards (T011) and the rail
  (T013); at ≥ 1200 px a `Row[Expanded(destinations region), gutter, SizedBox(360, rail)]`;
  below it a `Column` with the destinations region and rail list scrolling and
  the rail's foot pinned; only the destination list and the distribution list
  scroll (FR-007); no `Center`/`contentMaxWidth` clamp (FR-006); keep the
  `ErrorBanner`/load-failure handling exactly as today (FR-008). Destinations
  region order: counter row (T012, mixed sales only — **widened by T036** to
  any sale with a counter-pickup destination) → cards (T011) → add
  action (key `delivery_add_destination_button`, unchanged label/icon for now)
  → empty state when the list is empty (depends on T011, T012, T013).

**Checkpoint**: US1 is fully functional and testable independently — every
destination and the distribution are visible without scrolling, though
quantities are still read-only and the add action still opens today's
composer (US2/US4 change that next).

---

## Phase 4: User Story 3 - Know where every line is going and finish the sale (Priority: P1)

**Goal**: The assigned-units total, the outstanding-lines reason, and the
finish action are one pinned block at the rail's foot, exactly reproducing
today's gate (FR-001) in its new position.

**Independent Test**: With a part-assigned pure-delivery sale, read which lines
are short from one region, assign the remainder, and watch the finish action
become available in that same region (spec.md US3).

### Tests for User Story 3

- [X] T015 [P] [US3] Add cases to `line_distribution_rail_test.dart` (T010)
  asserting, per [contract §5.3](./contracts/delivery-surface.md#53-foot-pinned):
  the foot shows `posDeliveryAssignedUnits` against the sale's total; on a
  pure-delivery sale with a remainder, `delivery_outstanding_notice` names the
  short lines and `delivery_close_button` is disabled; once
  `isDistributionComplete` is satisfied the notice is gone and the button is
  enabled; on a mixed sale with a remainder the button is enabled and no
  notice is shown (mirrors today's `delivery_step.dart` gate logic, moved).

### Implementation for User Story 3

- [X] T016 [US3] Fill `LineDistributionPanel`'s foot (started as a slot in
  T013) per [contract §5.3](./contracts/delivery-surface.md#53-foot-pinned): the
  assigned-units line, then `delivery_outstanding_notice`
  (`posDeliveryOutstanding`) only while `isDistributionComplete(distribution, isMixed:)`
  is false on a non-mixed sale, then `delivery_close_button` — `FilledButton`,
  enabled by that same gate function, unchanged spinner-while-closing
  treatment. This is `isDistributionComplete` and the existing `_close`
  handling **moved from `delivery_step.dart` into the rail**, not reimplemented
  (FR-001) (depends on T013, T014).

**Checkpoint**: US1+US3 together give the full read-only Entrega surface: every
destination, the whole distribution, and a working finish action — this pair is
a strong MVP slice even before assignment or the sheet exist.

---

## Phase 5: User Story 2 - Assign a destination's quantities in its own card (Priority: P1)

**Goal**: Every sale line inside an expanded card gets a stepper pill —
decrement, typable figure, increment — clamped to what the sale still owes,
dispatching to `addLine`/`updateLine`/`removeLine` correctly, with the rail
moving live and a refusal reverting the displayed figure.

**Independent Test**: With one recorded destination, assign three lines to it
from its card, take one back to zero, and confirm the rail and the
assigned-units total agree with the cards throughout (spec.md US2).

### Tests for User Story 2

- [X] T017 [P] [US2] Create `test/widget/features/sales/destination_assignment_test.dart`
  covering, per [contract §4.3–§4.4](./contracts/delivery-surface.md#43-line-row)
  and [quickstart §4.3](./quickstart.md#43-assignment-us2): raising a line
  within its ceiling calls `addLine` when the destination does not yet carry it
  and `updateLine` when it does (assert via a mocked
  `deliveryOrderRepositoryProvider`, not a live server); raising a line past
  its ceiling (`data-model.md §2.2`) sends **no request**; lowering a line to
  zero calls `removeLine`, not `updateLine` with `quantity: '0'`; the assign-all
  affordance (`destination_claim_all_${saleLineId}`) sets a line to its full
  claimable amount; a refused call restores the field to the value `state`
  still holds and shows the message on that row; while a call is in flight the
  row's controls are inert.

### Implementation for User Story 2

- [X] T018 [US2] Add `assignLine`, `adjustLine` and `dropLine` to
  `DeliveryController`
  (`lib/features/sales/presentation/delivery/delivery_controller.dart`) per
  [data-model §3](./data-model.md#3-the-one-new-controller-surface): each calls
  the matching repository method (`addLine`/`updateLine`/`removeLine`) and
  replaces that one destination in `state` with the response — no refetch
  (SC-010). A refusal propagates by throwing, leaving `state` untouched, which
  is what makes the caller's re-read a revert rather than a rollback (depends
  on T006).
- [X] T019 [US2] Build the stepper pill in `destination_card.dart`'s line rows
  (extends T011) per [contract §4.4](./contracts/delivery-surface.md#44-stepper-pill),
  mirroring `SaleLineEditing`'s per-edit-round-trip/`_busy`/`syncFields()` shape
  ([research R6](./research.md#r6--the-stepper-reuse-the-pattern-not-the-code)):
  `IconButton(Icons.remove)` — `TextField` — `IconButton(Icons.add)` in a
  `shapes.xl`-radius container; keys `destination_quantity_${saleLineId}` /
  `destination_claim_all_${saleLineId}`; tooltips `posLineDecreaseQuantity` /
  `posLineIncreaseQuantity` (existing keys, no new label); client-side clamp
  `0 … ceiling` (`data-model.md §2.2`) before sending anything
  ([research R7](./research.md#r7--the-clamp-ceiling)); dispatch on whether
  `Destination.lines` already carries the sale line
  ([research R13](./research.md#r13--add_lines-semantics)) — `assignLine` the
  first time, `adjustLine` after, `dropLine` at zero (depends on T011, T018).

**Checkpoint**: US1+US2+US3 together are the feature's core: a cashier can see
every destination, assign quantities inside its card, and finish the sale, all
without the old composer's quantity form.

---

## Phase 6: User Story 4 - Add a destination from a side sheet (Priority: P2)

**Goal**: "Agregar destino" opens a side sheet (bottom sheet on phone) asking
only for the header — no quantities — and saving it appends an expanded, empty
card that US2's steppers immediately make usable.

**Independent Test**: Add a destination from the sheet and confirm the
resulting card is present, badged, expanded and holding nothing yet (spec.md
US4).

### Tests for User Story 4

- [X] T020 [P] [US4] Rewrite the pump in
  `test/widget/features/sales/destination_editor_error_test.dart` to open the
  sheet (via the add action) rather than pumping `DestinationEditor` inline,
  keeping its assertions on `destination_editor` and `destination_editor_error`
  unchanged (the widget behind those keys still exists — only how it opens
  changes).
- [X] T021 [P] [US4] Add cases to `delivery_step_layout_test.dart` (T008) per
  [quickstart §4.4](./quickstart.md#44-adding-a-destination-us4): at ≥ 1200 px
  the sheet is right-anchored over the rail and the destination cards remain
  visible behind it; below 1200 px it is a full-width bottom sheet; a refused
  create keeps the sheet open with the entered values and leaves every
  recorded destination untouched; on a sale with nothing left unassigned,
  `delivery_add_destination_button` is disabled and states
  `posAddDestinationNothingLeft`.

### Implementation for User Story 4

- [X] T022 [US4] Rewrite `destination_editor.dart`
  (`lib/features/sales/presentation/delivery/destination_editor.dart`) as the
  header-only sheet per [contract §6](./contracts/delivery-surface.md#6-add-sheet--destination_editordart):
  keep the address/contact/date/instructions controls
  (`destination_address_button`, `destination_contact_button`,
  `destination_date_button`, `destination_comment_field`) and
  `destination_save_button`/`destination_editor_error`; **remove** the
  per-line quantity fields and `posDestinationQuantitiesTitle`'s usage; call
  `addDestination` with `lines: const []` — an explicit empty list, never
  omitted ([research R14](./research.md#r14--the-empty-create)).
- [X] T023 [US4] Drop the `quantities` parameter from
  `DeliveryController.addDestination`
  (`lib/features/sales/presentation/delivery/delivery_controller.dart`), since
  the sheet no longer supplies any (depends on T022).
- [X] T024 [US4] Add a delivery-specific side-sheet opener (a small function
  in or alongside `delivery_step.dart`, modelled on
  `showCatalogFilterSheet` in `lib/core/widgets/catalog_filter_sheet.dart` per
  [research R10](./research.md#r10--the-side-sheet)): right-anchored
  `showGeneralDialog` at ≥ `LayoutBreakpoints.large`, `showModalBottomSheet`
  below it, both `useRootNavigator: true` (the POS's nested
  `StatefulShellBranch` navigator would otherwise tear the sheet down);
  presents `posAddDestinationSheetTitle` and hosts `DestinationEditor` (T022).
  Wire `delivery_step.dart`'s add action (T014) to call it (depends on T022).
- [X] T025 [US4] In `delivery_step.dart`, disable
  `delivery_add_destination_button` and show `posAddDestinationNothingLeft`
  when every line is fully distributed — an empty create is refused by the
  server in that state ([research R14](./research.md#r14--the-empty-create))
  (depends on T014, T024).

**Checkpoint**: The full destination lifecycle works end to end — add from the
sheet, assign in the card, remove if needed, finish the sale — matching the
mock's grouping throughout.

---

## Phase 7: User Story 5 - Work the step on a phone (Priority: P3)

**Goal**: Below the two-region threshold, the same pieces stack in the mock's
phone order with the rail's foot pinned to the bottom edge; nothing regresses
what `pos_compact_delivery_test.dart` already covers.

**Independent Test**: Open the step at a phone width, add a destination, assign
two lines to it and finish the sale without losing sight of the total or the
finish action (spec.md US5).

### Tests for User Story 5

- [X] T026 [P] [US5] Update `pos_compact_delivery_test.dart`'s quantity-field
  assertions to address `destination_quantity_*`/`destination_claim_all_*`
  inside an expanded `destination_card_*` rather than inside
  `destination_editor` (they moved there in T019); keep its existing
  card-presence, joined-address/contact, and `expectNoHorizontalScroll`
  assertions unchanged.

### Implementation for User Story 5

- [X] T027 [US5] No dedicated phone-tier widget: `delivery_step.dart` (T014)
  already renders the one-column shape below `LayoutBreakpoints.large`, using
  the same `DestinationCard`/`DestinationCounterRow`/`LineDistributionPanel`
  built for US1–US4. This task is the explicit acknowledgment that US5 is
  satisfied by construction once T014/T024's breakpoint branches are correct,
  verified by T008's 1199 px/320 px cases and T026 rather than by new phone-only
  code (mirrors spec 025's T024 precedent for `NumberPad`).

**Checkpoint**: All three width tiers (two-region, one-column, phone) render
correctly with the full feature working at each.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Whole-feature verification that spans every story.

- [X] T028 [P] Run `flutter analyze` from the repo root and resolve any warning
  introduced by this feature's files.
- [X] T029 [P] Grep the diff of every changed file under
  `lib/features/sales/presentation/delivery/` for literal `Color(`, hex colors,
  bare numeric font sizes, or `EdgeInsets` values not sourced from
  `Theme.of(context).spacing`/`.shapes`/`.typeRoles`/`.elevations` — confirms
  SC-008/FR-039 (zero literal design values).
- [X] T030 Remove `posDestinationQuantitiesTitle` from `lib/l10n/app_es.arb` and
  `lib/l10n/app_en.arb` (depends on T022 removing its last usage); re-run
  `flutter gen-l10n` and confirm `test/unit/core/l10n_parity_test.dart` still
  passes and `grep -rn posDestinationQuantitiesTitle lib/` returns nothing
  outside the generated localization files.
- [X] T031 Run the full suite —
  `flutter test test/widget/features/sales/ test/unit/features/sales/ test/unit/core/l10n_parity_test.dart`
  — and confirm everything is green, including
  `line_distribution_test.dart` and `delivery_order_repository_impl_test.dart`
  passing **unchanged** except for T007's addition (FR-001,
  [research R12](./research.md#r12--test-impact)).
- [ ] T032 Walk [quickstart.md](./quickstart.md)'s width table and every
  scenario in §4 against a live register, confirming SC-001–SC-010 by hand
  where no automated test already does — in particular the network-panel
  checks that a clamped over-claim sends nothing (§4.3) and that the create
  body carries `"lines": []`, never an omitted `lines` (§4.4).

---

## Phase 9: Live-Driving Fixes and mbe-api#171

**Purpose**: everything found after T031, by driving the real screen and by
absorbing an API change that landed mid-flight. Not part of the original plan —
recorded here so the task list matches what was actually built.

Four of these are defects the automated suite could not have caught, for a
reason worth carrying forward: three were invisible because the widget tests
mock the repository (so serialization never runs) or assert on *calls* rather
than on *displayed state*; the fourth was an API renumber that keeps compiling.

- [X] T033 Pass every `DateTime` through `wireDate()` in
  `lib/features/sales/data/delivery_order_repository_impl.dart` (`create` and
  `updateHeader`), and add a real-serialization regression test to
  `test/unit/features/sales/delivery_order_repository_impl_test.dart` — a local
  `DateTime` throws inside dio and surfaces as `NetworkError`
  ([research R16](./research.md)). Pre-existing since spec 020.
- [X] T034 Write the requested value into the stepper's `TextEditingController`
  in `lib/features/sales/presentation/delivery/destination_card.dart` before
  sending, mirroring `SaleLineEditing.step()`; assert the controller's *text*
  in `destination_assignment_test.dart`, not just which method was called
  ([research R6](./research.md)).
- [X] T035 Debounce assignment (~400 ms per line) in `destination_card.dart`:
  a `_pending` value the row renders and clamps against, one write per line in
  flight, coalescing a mid-flight tap, and a flush on dispose. Keep the
  out-of-range snap-back. Rewrite FR-025 to match, and add the
  three-taps-one-request test.
- [X] T036 Add the sweep escape hatch — `LineDistributionFoot.onSweepAndClose`
  and `_close(sweepRemainder:)` in `delivery_step.dart`, plus
  `posDeliverRestAtCounter` in both locales (FR-037a); and show the counter row
  whenever a counter-pickup destination exists, not only when the mode says
  mixed (FR-010, [research R4](./research.md)).
- [X] T037 Absorb mbe-api#171 — plan.md's Phase H, six steps: renumber
  `FulfillmentType`, give `FulfillmentMode` its API mapping, add
  `Sale.fulfillmentIntent` (+ freezed), thread it through
  `updateHeader` → `pos_sale_controller` → `fulfillment_mode_selector`, trust
  it in `resumeTargetFor`, and fix the two wire-number assertions. New:
  `test/unit/features/sales/fulfillment_mapping_test.dart`
  ([research R15](./research.md)).

**Checkpoint**: `flutter analyze` clean, 1822 tests passing. T032 (the live
width-table walk) remains the only open task.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately.
- **Foundational (Phase 2)**: Depends on nothing but is only truly blocking for
  US2 (T017–T019) — US1/US3/US4/US5 touch none of `addLine`'s files and are not
  blocked by it.
- **User Stories (Phase 3–7)**: All depend on Phase 1.
  - **US1 (T008–T014)** is the MVP slice and the foundation every later story
    composes with — US3's foot is added to US1's rail, US2's stepper is added
    to US1's card, US4's sheet is opened from US1's add action, US5 is US1's
    layout verified at another width.
  - **US3 (T015–T016)** depends on US1's `LineDistributionPanel` (T013) and
    `delivery_step.dart` (T014) existing — it fills the foot slot they leave.
  - **US2 (T017–T019)** depends on US1's `DestinationCard` (T011) and Phase 2's
    `addLine` (T006, T018). It does **not** depend on US3.
  - **US4 (T020–T025)** depends on US1's `delivery_step.dart` (T014, for the
    add action to wire) and on `DeliveryController.addDestination` existing
    (already does). It does not depend on US2's stepper being built, though
    the resulting empty card is only useful once US2 lands.
  - **US5 (T026–T027)** is a verification pass over US1's layout branches — it
    can run once T014/T024 exist.
  - **Polish (Phase 8)**: Depends on every story above being complete.

### Within Each User Story

- Tests before implementation, where a test is listed — each is written to
  fail against today's `delivery_step.dart`/`destination_card.dart`/
  `destination_editor.dart` first.
- Leaf widgets (`DestinationCounterRow`) before the composites that place them
  (`delivery_step.dart`).
- The rail's list (T013) before its foot (T016) — the foot fills a slot the
  list leaves.
- The card's header/expansion (T011) before its stepper (T019) — the stepper
  is added to rows the header task already lists read-only.

### Parallel Opportunities

- T001–T003 (Setup) can run together; T004 depends on all three.
- T005 → T006 → T007 (Foundational) are sequential within themselves but the
  whole chain is independent of every Setup task except needing T004's arb
  regen only if a new label were added here (it is not).
- T008, T009, T010 (US1 tests) in parallel with each other.
- T011, T012 (US1 leaf widgets) in parallel with each other; both must land
  before T013/T014.
- **US2's Phase 2 work (T005–T007) can run entirely in parallel with US1**,
  since it touches only `delivery_order_repository.dart`/`_impl.dart`, files
  US1 never opens.
- **US4's T020/T021 (tests) can be written in parallel with US1/US2/US3**,
  since they exercise `destination_editor.dart`'s existing form, not
  US1–US3's new widgets.
- T028, T029 (Polish) in parallel; T030–T032 depend on everything before them.

---

## Parallel Example: User Story 1

```bash
# Tests for User Story 1, in parallel:
Task: "delivery_step_layout_test.dart — two regions, reflow, no overflow"
Task: "destination_card_test.dart — header, independent expansion"
Task: "line_distribution_rail_test.dart — chips agree with badges"

# Leaf widgets for User Story 1, in parallel:
Task: "Rewrite DestinationCard's header and expansion (read-only lines)"
Task: "Create DestinationCounterRow"
```

## Parallel Example: Across stories (once Phase 1 is done)

```bash
Task: "US1 — rewrite DestinationCard's header/expansion (T011)"
Task: "Foundational/US2 — add DeliveryOrderRepository.addLine + impl + test (T005–T007)"
Task: "US4 — rewrite destination_editor_error_test.dart's pump (T020)"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 (Setup).
2. Complete Phase 3 (US1): the two-region/one-column shapes, the counter row,
   the read-only cards, the rail's list.
3. **STOP and VALIDATE**: run T008–T010, drive the 1440 px and 1199 px cases
   from quickstart.md by hand.
4. This alone delivers the complaint the feature exists to fix — everything
   visible, correctly grouped, no scrolling — even before assignment or the
   sheet change.

### Incremental Delivery

1. Setup → the ground is safe to build on.
2. US1 → validate → this is the MVP.
3. US3 in parallel with US1's later tasks → the finish action reads with the
   distribution the moment US1's rail exists.
4. US2 (with Foundational running alongside US1) → assignment inside the card,
   the feature's main new capability.
5. US4 → the header-only sheet, once US1's add action exists to wire it to.
6. US5 → the proof that the phone tier still works.
7. Polish → analyze, token-literal sweep, the removed key, full suite, live
   drive.

### Parallel Team Strategy

With three people, once Phase 1 is done: one takes US1's composites
(T011–T014), a second takes Foundational + US2 (T005–T007, then T017–T019
once T011 lands), a third takes US4's tests (T020–T021) against the existing
`destination_editor.dart` while waiting for T014's add action to wire into.
US3 and US5 are short passes best picked up by whoever finishes first.

---

## Notes

- [P] tasks touch different files with no unmet dependency.
- Every task names its exact file(s) — none should need re-reading the plan to
  start.
- Verify each "Tests" task fails before its matching implementation task, where
  both exist.
- No task in this list touches `line_distribution.dart`'s arithmetic,
  `isDistributionComplete`, or the counter-pickup sweep's *logic* — FR-001
  keeps those exactly as they are. T016 *moves* the gate's rendering, and T036
  adds a second caller for the existing sweep; neither changes what either
  computes.
- Phase 9 is retrospective: those tasks were done reactively, in response to
  live driving and to an API change, rather than planned up front. They are
  listed so the task list is a true record of the work.
- `lib/core/widgets/catalog_filter_sheet.dart` appears in no implementation
  task's file list on purpose (T024 only *models* its mechanics) — it is read,
  not edited.
