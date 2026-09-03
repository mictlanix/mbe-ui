# Tasks: Live Testing Session Fixes

**Input**: Design documents from `/specs/036-live-testing-fixes/`
**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/](./contracts/)

**Tests**: Not explicitly requested as TDD, but three of these nine fixes are bugs a passing suite
already failed to catch once (a silent data-loss bug, a business rule with no test coverage, and
a status-model assumption baked into several files) — so test tasks are included per story,
immediately after implementation, matching this project's own established practice (see
specs/035-crud-ui-refinements/tasks.md).

**Organization**: Phases 3+ follow spec.md's priority order (P1 stories first: US1, US2, US3; then
P2: US4, US5, US6, US7; then P3: US8, US9) — this is the standard task-generation order, and is
**not** the same as plan.md's own "Implementation Sequencing" (which reorders by risk/blast-radius
for a human choosing where to start). Both are valid; see Implementation Strategy below for how
to reconcile them.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependency on an incomplete task)
- **[Story]**: US1–US9, matching spec.md
- Every description carries its exact file path

---

## Phase 1: Setup

**Purpose**: Nothing to initialize — this feature adds two config fields and a handful of
call-site edits to an existing, fully configured project. No new dependency or scaffolding.

- [ ] T001 Confirm the working tree is clean and `flutter analyze && flutter test` pass before any
      change, as the pre-change baseline for every later regression check.

---

## Phase 2: Foundational

**Purpose**: The one primitive two different-priority stories (US1, US4) both depend on.

**⚠️ Nothing in US1 or US4's phases may start until this task lands.**

- [ ] T002 Add `bool isGenericCustomer(int customerId)` to `lib/core/config/app_settings.dart`
      (or a small helper beside `posDefaultCustomerId` in `lib/features/sales/pos_defaults.dart`),
      returning `customerId == posDefaultCustomerId`. Both the Sales Order customer-picker
      exclusion (US1) and the fulfillment-mode gate + mid-sale demote (US4) MUST call this one
      function — no independent id comparison anywhere else (data-model.md §5,
      `contracts/customer-form-and-fulfillment.md` C2).

**Checkpoint**: Foundation ready — US1 and US4 (and, transitively, US5) can now proceed.

---

## Phase 3: User Story 1 — Sales orders are always billed to a real, named customer (Priority: P1)

**Goal**: Choosing a customer is the first step of Sales Order creation, and the generic "Público
en General" customer is never selectable there.

**Independent Test**: Start a new Sales Order; confirm the customer step is presented first, the
generic customer never appears in the picker, and no product line can be added until a specific
customer is chosen.

### Implementation for User Story 1

- [ ] T003 [US1] In `lib/features/sales/presentation/orders/order_screen.dart`, add
      `bool get _needsCustomer` (`sale == null || sale.customer == appSettings.posDefaultCustomerId`);
      while true, render only `CustomerBar` plus an inline hint and omit `ProductSearchField`
      entirely (absent, not disabled); fold `!_needsCustomer` into the existing confirm/save gate
      (`contracts/sales-order-customer-flow.md` C1).
- [ ] T004 [US1] In `lib/features/sales/presentation/capture/customer_bar.dart`, add
      `bool excludeGenericCustomer = false` to the constructor, thread it into `_SearchingView`'s
      `optionsBuilder`, and filter results with T002's `isGenericCustomer` when true. Pass
      `excludeGenericCustomer: true` only from `order_screen.dart` (T003); every POS `CustomerBar`
      usage keeps the default `false` (`contracts/sales-order-customer-flow.md` C2).
- [ ] T005 [P] [US1] *(optional refinement, not required for correctness)* In
      `lib/features/sales/domain/repositories/sales_order_repository.dart` and
      `lib/features/sales/data/sales_order_repository_impl.dart`, add optional
      `{int? customer, int? salesperson}` params to `open()` so the very first customer pick can
      be a single POST instead of create-then-PATCH (research.md R5).

### Tests for User Story 1

- [ ] T006 [P] [US1] Update `test/widget/features/sales/order_screen_test.dart`: a brand-new order
      shows only the customer bar (no product search field), and the confirm action is disabled
      until a specific customer is attached.
- [ ] T007 [P] [US1] Update `test/widget/features/sales/customer_bar_test.dart`: with
      `excludeGenericCustomer: true`, the generic customer is excluded from search results; with
      the default `false` (POS usage), it still appears.
- [ ] T008 [US1] Fix the existing `order_screen_test.dart` cases that assumed the search field is
      always present on mount (research.md R5 flags this as a known break from T003).
- [ ] T071 [P] [US1] *(added post-`/speckit-analyze`, closes FR-004 coverage gap)* Add a
      regression case to `test/widget/features/sales/order_screen_test.dart`: open an existing
      order whose `customer` is already `posDefaultCustomerId` (saved before this feature
      shipped) and confirm it still opens and displays correctly under T003's customer-first
      gate — the gate must block only new selections, never reading existing data.

**Checkpoint**: US1 is independently shippable and testable.

---

## Phase 4: User Story 2 — A cashier can correct a sale before it is paid (Priority: P1)

**Goal**: A cashier can return from the Cobro/Entrega step to the cart and edit line items, for
as long as the sale has no payment recorded — implemented by moving *when* the sale is confirmed
server-side, not by loosening the existing editability check.

**Independent Test**: Start a sale, add items, advance to Cobro without paying; confirm the cart
can be reopened and changed. Record a payment; confirm the cart can no longer be changed.

### Implementation for User Story 2

- [ ] T009 [US2] In `lib/features/sales/presentation/pos_step_controller.dart`, add
      `bool canReturnToCapture({required bool isEditable, required bool hasNonCancelledPayments})`
      and `void returnToVenta()`, mirroring the existing guard+transition pairing
      (`contracts/pos-sale-lifecycle.md` C2).
- [ ] T010 [US2] In `lib/features/sales/presentation/sale_editing.dart` /
      `lib/features/sales/presentation/capture/capture_step.dart`, remove the `confirm()` call
      from the Venta → Cobro transition — advancing to Cobro no longer calls the server.
- [ ] T011 [US2] In `lib/features/sales/presentation/payment/payment_controller.dart`, call
      `confirm()` before `createPayment` in `submit`; route a `confirm()` failure (empty order /
      zero-priced line / stock shortfall) back to Venta using the existing `_toConfirmError`
      rendering rather than surfacing it as a payment failure (`contracts/pos-sale-lifecycle.md`
      C1).
- [ ] T012 [US2] In `lib/features/sales/presentation/delivery/delivery_controller.dart`, at the
      first delivery-order `create` call site (Entrega step, delivery/mixed fulfillment), call
      `confirm()` first; route failures back to Venta the same way as T011.
- [ ] T013 [US2] At the credit-terms leave-Cobro path (wherever `canLeavePayment`/
      `advanceFromCobro` is invoked, e.g. `payment_step.dart`), call `confirm()` before leaving
      Cobro when no cash payment was posted.
- [ ] T014 [US2] In `lib/features/sales/presentation/pos_workspace_screen.dart`, make the Venta
      `_StepPill` tappable (desktop/web) when `canReturnToCapture` passes, calling `returnToVenta()`.
- [ ] T015 [US2] Add a compact-tier back-navigation affordance (the payment/delivery footer band,
      since compact renders a text progress indicator instead of pills) — same guard as T014.
- [ ] T016 [US2] *(pending requester sign-off — see plan.md Risks; do not ship until approved)* In
      `lib/features/sales/presentation/open_sales_selector.dart` and
      `open_sales_selector_controller.dart`, merge the "Borrador"/"Sin pagar" buckets into one,
      since a captured-but-unpaid sale is now `draft`, indistinguishable from an in-progress draft.

### Tests for User Story 2

- [ ] T017 [P] [US2] Add cases to `test/unit/features/sales/pos_step_controller_test.dart` for
      `canReturnToCapture`/`returnToVenta`.
- [ ] T018 [P] [US2] Add a `PaymentController.submit` test asserting `confirm()` is called exactly
      once, before `createPayment`, and not again on a second tender.
- [ ] T019 [P] [US2] Add a delivery-step test asserting `confirm()` precedes the first
      delivery-order create.
- [ ] T020 [P] [US2] Add a widget test: a draft sale on Cobro exposes the Venta pill/affordance; a
      sale with ≥1 non-cancelled payment does not.
- [ ] T021 [US2] Update `test/integration/pos_counter_sale_flow_test.dart`,
      `pos_delivery_split_flow_test.dart` and `pos_resume_flow_test.dart` for the new call
      ordering (they currently assert `confirm()` at Venta→Cobro).

**Checkpoint**: US2 is independently shippable and testable (T016 excepted, pending sign-off).

---

## Phase 5: User Story 3 — Every price edit is saved, however the user leaves the field (Priority: P1)

**Goal**: No case exists in which moving to another price-grid cell — by click, Tab, Enter, or an
arrow key — leaves the outgoing cell's edit uncommitted.

**Independent Test**: Edit a price, click directly into a different row's price field, reload;
the edited value persisted.

### Implementation for User Story 3

- [ ] T022 [US3] In `lib/features/pricing/presentation/pricing_grid_controller.dart`, add
      `activeDraft` to `PricingGridState`; `openCell(next)` MUST commit the outgoing active cell's
      draft (via the existing `commitCell` path) before reassigning `active`, whenever the draft
      differs from the last committed value; guard `commitCell` against a duplicate in-flight
      commit for the same cell (`contracts/pricing-grid-commit.md` C1, C2).
- [ ] T023 [US3] In `lib/features/pricing/presentation/price_cell.dart`, wire the `TextField`'s
      `onChanged` to update the controller's `activeDraft` instead of relying solely on
      focus-loss to commit; keep Escape discarding the draft without committing.

### Tests for User Story 3

- [ ] T024 [P] [US3] Add to `test/widget/features/pricing/price_cell_test.dart`: type into cell A,
      click directly into cell B → exactly one write for A's value, B ends active.
- [ ] T025 [P] [US3] Add the same case via keyboard (Enter/Tab/arrow) asserting exactly one write
      (no double-commit from T022's guard).
- [ ] T026 [P] [US3] Confirm the existing Escape-discards-nothing test still passes unchanged.
- [ ] T027 [P] [US3] Add an unmount-while-active case (page/filter change) that still commits.
- [ ] T028 [P] [US3] Add an invalid-value-then-tap-away case: the rejected badge/reason renders
      (FR-010).

**Checkpoint**: US3 is independently shippable and testable.

---

## Phase 6: User Story 4 — The customer form matches how customers are actually captured (Priority: P2)

**Goal**: `code` is optional and sits after `credit days`; the two shipping toggles are gone from
every form and the entity; the fulfillment-mode gate and its mid-sale-switch edge case are
re-derived from the generic-customer identity instead of the removed flag.

**Independent Test**: Save a customer with no code; confirm field order; confirm no shipping
toggles anywhere; confirm delivery/mixed is available to every customer except the generic one,
and that switching to the generic customer mid-sale resets fulfillment mode.

### Implementation for User Story 4

- [ ] T029 [US4] Check whether [mbe-api#198](https://github.com/mictlanix/mbe-api/issues/198) and
      [#199](https://github.com/mictlanix/mbe-api/issues/199) have landed and the client
      regenerated (`./tool/generate_api_client.sh`) — determines whether T030's create-path
      omission of `code` is possible yet, or must still send `""` (research.md R14).
- [ ] T072 [US4] *(added post-`/speckit-analyze`, closes a constitution Development-Workflow gap)*
      Once T029 confirms mbe-api#198/#199 have landed: run `./tool/generate_api_client.sh` to
      regenerate `lib/generated/openapi/`, then update the domain-entity mapping so `code` is
      read as nullable (if the regenerated response schema makes it so) and the two shipping
      fields are fully gone from the generated DTOs, not just unread by T032/T033. This is the
      constitution-mandated codegen re-run for a feature depending on an mbe-api schema change —
      do not treat T029's landed/regenerated *check* as having done this step.
- [ ] T030 [US4] **Depends on T033 landing first (or in the same commit)** — dropping the two
      shipping args from this file's create/update calls only compiles once T033 removes them
      from `CustomerRepository`'s method signatures. In
      `lib/features/catalog/presentation/customer_form_controller.dart`: drop the code-required
      validation and its error code; drop the two shipping fields from state, setters, load, and
      create/update payloads; change the update path to omit `code` when blank instead of sending
      `""`.
- [ ] T031 [US4] In `lib/features/catalog/presentation/customer_form.dart`: move the `code` field
      to immediately after `credit_days`; remove the two shipping `SwitchListTile`s.
- [ ] T032 [P] [US4] In `lib/features/catalog/domain/entities/customer.dart` (and
      `customer_list_item.dart` if applicable), drop `shipping`/`shippingRequiredDocument`.
- [ ] T033 [US4] **Not parallel with T030 — do this first, or in the same commit**: T030 stops
      passing these two args and will not compile until this signature change lands. In
      `lib/features/catalog/domain/repositories/customer_repository.dart` and
      `lib/features/catalog/data/customer_repository_impl.dart`, drop the two shipping fields from
      create/update payloads.
- [ ] T034 [P] [US4] In `lib/features/sales/presentation/customer_inline_create.dart` (POS
      inline-create mini-form), remove the two shipping switches.
- [ ] T035 [P] [US4] Remove the orphaned l10n keys (`shippingLabel`,
      `shippingRequiredDocumentLabel`, `customerCodeRequiredError`) from `lib/l10n/app_en.arb` and
      `lib/l10n/app_es.arb`; reword `posDeliveryNotPermitted` if needed to match the new refusal
      reason.
- [ ] T036 [US4] In `lib/features/sales/presentation/capture/fulfillment_mode_selector.dart`,
      replace the `!customer.shipping` check with T002's `isGenericCustomer`; allow delivery/mixed
      when `sale == null` (`contracts/customer-form-and-fulfillment.md` C3).
- [ ] T037 [US4] In `lib/features/sales/presentation/capture/customer_bar.dart`'s
      `_updateHeader`, after a successful customer change, when the new customer
      `isGenericCustomer` and the sale's mode isn't `counterPickup`: reset mode to
      `counterPickup` (local + persisted `fulfillmentIntent`) and show a one-time notice
      (`contracts/customer-form-and-fulfillment.md` C4, FR-016).

### Tests for User Story 4

- [ ] T038 [P] [US4] Update `test/unit/features/catalog/customer_form_controller_test.dart`: code
      not required; create/update stub assertions drop the shipping args.
- [ ] T039 [P] [US4] Update `test/widget/features/catalog/customer_form_test.dart`: no shipping
      switches render; `code_field`'s position is after `credit_days_field`; saving with an empty
      code succeeds.
- [ ] T040 [P] [US4] Update `test/widget/features/sales/customer_inline_create_test.dart`: remove
      the 8 shipping-arg mocktail stubs; add a no-code save case.
- [ ] T041 [P] [US4] Rewrite `test/widget/features/sales/fulfillment_mode_selector_test.dart`'s
      refusal test to key on the generic-customer id instead of a `shipping` flag; add a positive
      case for an ordinary customer that previously had `shipping: false`.
- [ ] T042 [P] [US4] Add a `customer_bar_test.dart` case: switching to the generic customer while
      in delivery/mixed mode resets to pickup and shows the notice.

**Checkpoint**: US4 is independently shippable and testable.

---

## Phase 7: User Story 5 — A sales order fills in the customer's salesperson automatically (Priority: P2)

**Goal**: Selecting a customer with an associated salesperson pre-fills the order's salesperson
field; it stays overridable.

**Independent Test**: Select a customer with a known salesperson — the field fills in and shows
the name. Select one with none — the field stays as it was.

### Implementation for User Story 5

- [ ] T043 [US5] In `customer_bar.dart`'s customer-picker `onSelected` (same `_updateHeader` call
      site as T004/T037 — sequence after Phase 6), also set `salesperson: c.salesperson?.id` when
      present (`contracts/sales-order-customer-flow.md` C3).
- [ ] T044 [US5] In `lib/features/sales/presentation/orders/order_header_panel.dart`, pass
      `initialDisplayText` from the resolved customer's salesperson name so an autofilled value
      renders, not a blank field.

### Tests for User Story 5

- [ ] T045 [P] [US5] Add cases (order_screen_test.dart / customer_bar_test.dart): selecting a
      customer with a salesperson autofills it and shows the name; one with none leaves the field
      unchanged; a manual override is then overwritten by a subsequent customer change (documented
      trade-off, FR-018).

**Checkpoint**: US5 is independently shippable and testable.

---

## Phase 8: User Story 6 — A cashier sees which warehouse actually has stock before choosing one (Priority: P2)

**Goal**: The warehouse picker visibly flags a warehouse that lacks enough stock, without
disabling any option.

**Independent Test**: Open the picker for a product short in one warehouse; that warehouse is
visibly flagged; selecting it still succeeds.

### Implementation for User Story 6

- [ ] T046 [US6] **Spike, do first**: verify against a live mbe-api whether the product-lookup
      call's `warehouse:` param filters the returned `stock` list to one warehouse (research.md
      R11) — if so, this story needs a per-warehouse stock fetch added before T047 is useful.
- [ ] T047 [US6] In `lib/features/sales/presentation/capture/sale_line_editing.dart`, extend
      `_availabilityIn`/`_stockIn` into a 4-state flag (enough / short / none / unknown) reusing
      `shortfall()`'s exact comparison (data-model.md §6).
- [ ] T048 [US6] In the same file's `warehousePicker()`, render the flag per `DropdownMenuItem`
      (icon + short wording; keep `enabled: true`) and add `selectedItemBuilder` so the closed
      display stays name-only.
- [ ] T049 [P] [US6] Add l10n keys `posLineWarehouseStockUnknown`/`Short`/`None` to both
      `app_en.arb` and `app_es.arb`.

### Tests for User Story 6

- [ ] T050 [P] [US6] Add to `test/widget/features/sales/sale_line_row_test.dart`: the four stock
      states render correctly; a flagged warehouse is still selectable and still fires
      `updateLine`; the closed-display height/baseline invariant is unaffected.
- [ ] T051 [P] [US6] Add to `test/widget/features/sales/sale_line_symmetry_test.dart`: the largest
      text-scale level (1.3) with the dropdown open produces no overflow.

**Checkpoint**: US6 is independently shippable and testable (pending T046's live-backend check).

---

## Phase 9: User Story 7 — The first delivery destination absorbs the full order automatically (Priority: P2)

**Goal**: Adding the first delivery destination assigns every line's full remaining quantity to
it in one call; later destinations default to zero as today.

**Independent Test**: Add a first destination to a multi-line delivery sale; every line is fully
assigned with no manual entry. Add a second; it defaults to zero.

### Implementation for User Story 7

- [ ] T052 [US7] In `lib/features/sales/presentation/delivery/delivery_controller.dart`'s
      `addDestination`: when the current destination list is empty, build an explicit line list
      from `distributionFor(...)`'s `claimable` per line (skipping zero amounts) and pass it to
      `create`; keep `lines: const []` for subsequent destinations (data-model.md §7).

### Tests for User Story 7

- [ ] T053 [P] [US7] Add a `delivery_controller` unit test: first destination's `create` carries
      every line's `claimable`; second destination sends `[]`; a refused create adds nothing.
- [ ] T054 [P] [US7] Add to `test/widget/features/sales/destination_assignment_test.dart`: after
      the first destination, every stepper shows the full ordered quantity and is still
      adjustable; deleting it returns the quantity to unassigned.

**Checkpoint**: US7 is independently shippable and testable.

---

## Phase 10: User Story 8 — Every peso amount on screen honors one decimal-digit setting (Priority: P3)

**Goal**: The pricing grid's editable cell and the single-product pricing dialog format and parse
through the existing `currencyDecimalDigits` setting, closing the one gap live testing found.

**Independent Test**: A price stored with more decimal digits than configured displays and edits
at the configured digit count, not the raw stored value.

### Implementation for User Story 8

- [ ] T055 [US8] *(sequence after Phase 5 — same file/functions as T022/T023)* In `price_cell.dart`,
      seed the edit field from `AppFormatters.field.price()` and commit through
      `field.parsePrice()`, instead of the raw wire string (`contracts/app-settings-additions.md`
      C3).
- [ ] T056 [P] [US8] Apply the same fix to `lib/features/pricing/presentation/pricing_screen.dart`'s
      single-product edit dialog.
- [ ] T057 [P] [US8] In `pricing_grid_controller.dart`, parameterize the adjust-percent rounding on
      `currencyDecimalDigits` instead of a hardcoded `2`.
- [ ] T058 [P] [US8] Audit `lib/features/sales/presentation/payment/payment_capture_pane.dart` for
      the same raw-seed/raw-commit bypass; fix if found.

### Tests for User Story 8

- [ ] T059 [P] [US8] Add/update widget and unit tests: a `20.0000`-stored price renders as `20.00`
      with the default setting and `20.000` with digits=3, for both the grid cell and the dialog;
      update `pricing_grid_screen_test.dart`'s existing `20.0000` expectation to `20.00`.

**Checkpoint**: US8 is independently shippable and testable.

---

## Phase 11: User Story 9 — One configurable pace governs each kind of debounced field (Priority: P3)

**Goal**: Two new deployment settings — one for search-style debounce, one for the
quantity-commit window — replace three independently-hardcoded delays.

**Independent Test**: Changing the search-debounce setting shifts both search fields together
without affecting the quantity stepper; changing the quantity-commit setting shifts the stepper
without affecting search.

### Implementation for User Story 9

- [ ] T060 [US9] In `lib/core/config/app_settings.dart`, add `inputDebounce`
      (`INPUT_DEBOUNCE_MS`, default 300ms) and `quantityCommitDebounce`
      (`QUANTITY_COMMIT_DEBOUNCE_MS`, default 400ms), parsed with the same fallback-not-crash
      pattern as `FormattingSettings._parseDigits` (`contracts/app-settings-additions.md` C1).
- [ ] T061 [US9] Add `inputDebounceProvider` and `quantityCommitDebounceProvider` (derived from
      `appSettingsProvider`) beside `formattersProvider`.
- [ ] T062 [P] [US9] Convert `lib/core/widgets/catalog_entity_picker.dart` to
      `ConsumerStatefulWidget` and read `inputDebounceProvider` for its debounce timer.
- [ ] T063 [P] [US9] In `lib/features/sales/presentation/capture/product_search_field.dart`, read
      `inputDebounceProvider` instead of the hardcoded 300ms.
- [ ] T064 [P] [US9] In `lib/features/sales/presentation/widgets/quantity_stepper.dart`, add a
      `Duration debounce` constructor param (default `kQuantityCommitDebounce`); its two hosts
      (`sale_line_editing.dart`, `delivery/destination_card.dart`) pass
      `ref.read(quantityCommitDebounceProvider)`.
- [ ] T065 [P] [US9] Document both new env vars, with defaults and one-line descriptions, in
      `.env.template`.

### Tests for User Story 9

- [ ] T066 [P] [US9] Add an `AppSettings` parse-table unit test for both new fields: valid, empty,
      non-numeric, negative → documented default.
- [ ] T067 [P] [US9] Update `catalog_entity_picker_test.dart`, `product_search_field_test.dart`,
      and the quantity-stepper tests to derive their pump durations from the provider/constant
      instead of literal 300/350ms; add one overridden-setting case per call site proving SC-008.

**Checkpoint**: US9 is independently shippable and testable.

---

## Phase 12: Polish & Cross-Cutting Concerns

**Purpose**: Final verification across the whole feature, not owned by any single story.

- [ ] T068 [P] Run `flutter analyze` and `flutter test` (full suite, including `test/golden` and
      `test/screenshots`) across every phase's changes; review and regenerate any diverged goldens
      (pricing cell, POS capture step pills, warehouse dropdown) before accepting them.
- [ ] T069 [P] Walk `quickstart.md`'s full manual section end-to-end against a live mbe-api,
      confirming every numbered step under every user story.
- [ ] T070 Update `TODO.md`'s 2026-09-01 entry, marking each addressed bullet done with the
      existing `~~strikethrough~~` convention.

---

## Dependencies & Execution Order

- **Phase 1 (Setup)** → **Phase 2 (Foundational)**: sequential, blocks US1 and US4.
- **Phase 2** → **Phase 3 (US1)** and **Phase 6 (US4)**: both need T002's `isGenericCustomer`.
- **Phase 3 (US1)** → **Phase 7 (US5)**: T043 edits the same `customer_bar.dart` call site as T004
  (US1) and T037 (US4) — do T004 → T037 → T043 in that order to avoid merge churn, even though the
  three are logically independent additions to different concerns within one method.
- **Phase 6 (US4)** → **Phase 7 (US5)**: see above; US5 also benefits from US4's fulfillment-gate
  rewrite having already landed in the same file region.
- **Phase 5 (US3)** → **Phase 10 (US8)**: T055 edits the same `price_cell.dart` functions T022/T023
  (US3) already changed — US8 must sequence after US3, not run in parallel with it.
- **Within Phase 6 (US4)**: T033 (repository signature) MUST land before or with T030 (form
  controller) — T030 stops passing the two shipping args and will not compile until T033 removes
  them from `CustomerRepository`'s required params. Do T033 → T030, or both in one commit.
- **Phases 4 (US2), 8 (US6), 9 (US7), 11 (US9)**: each fully independent of every other story;
  may run in parallel with anything except their own stated file-level dependency above.
- `sale_line_editing.dart` is also touched by both Phase 8 (US6 — T047/T048, warehouse stock
  flag) and Phase 11 (US9 — T064, quantity-commit debounce wiring). Low conflict risk (different
  functions: `warehousePicker()` vs. the stepper's debounce param), listed here for the same
  reason the `customer_bar.dart` and `price_cell.dart` overlaps above are called out.
- **Phase 12 (Polish)** runs last, after every story phase reaches its checkpoint.

### Parallel opportunities

- T032, T033, T034, T035 (US4's entity/repository/inline-form/l10n edits) — different files.
- T006, T007 (US1 tests) — different files.
- T017-T020 (US2 tests) — different files/concerns.
- T024-T028 (US3 tests) — different cases in the same file, but independent of each other.
- T038-T042 (US4 tests) — different files.
- T056, T057, T058 (US8) — different files, once T055 has landed.
- T062, T063, T064, T065 (US9) — different files.

## Implementation Strategy

**MVP = Phase 1 + Phase 2 + Phase 3 (US1)**: prevents a real data-integrity problem (orders
billed to no one) with the smallest of the three P1 stories.

**Recommended actual build order** (plan.md's risk-based sequencing, distinct from the phase
numbering above, which follows spec priority for organization only):
1. Phase 5 (US3, pricing bug) + Phase 10 (US8, currency audit) — smallest blast radius, highest
   severity, do these first regardless of their P1/P3 labels.
2. Phase 2 + Phase 6 (US4, shared predicate + form) — unblocks Phase 3 and Phase 7.
3. Phase 8 (US6) + Phase 9 (US7) — isolated, independent of everything else.
4. Phase 11 (US9, debounce) — pure infrastructure, independent.
5. Phase 3 (US1) + Phase 7 (US5) — depend on Phase 6's predicate.
6. Phase 4 (US2, edit-before-payment) — the one item needing a genuinely new interaction pattern
   (back-navigation) and touching three call sites (payment, delivery, credit-terms); ships last,
   after everything above has proven stable. T016 (resume-bucket merge) waits on requester
   sign-off independently of the rest of this phase.

**Incremental delivery**: every phase's Checkpoint marks an independently shippable increment;
ship in whichever order suits capacity, respecting only the file-level dependencies noted above.
