---

description: "Task list for Back-Office Order Workspace"
---

# Tasks: Back-Office Order Workspace — Customer, Capture, Delivery

**Input**: Design documents from `/specs/039-back-office-order-workspace/`
**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/](./contracts/), [quickstart.md](./quickstart.md)

**Tests**: Included. The constitution's Development Workflow & Quality Gates
mandate unit/widget/integration coverage for this kind of change, and
[research.md](./research.md) R7 and [contracts/order-workspace.md](./contracts/order-workspace.md)
§6 already specify, file by file, what survives, what is re-homed and what is
new — this task list follows that disposition exactly.

**Organization**: Tasks are grouped by user story (spec.md's US1–US4). A fifth
slice — recording and checking order origin (FR-051–FR-054) — is deliberately
**not** one of the four numbered stories: it is blocked on
[mbe-api#209](https://github.com/mictlanix/mbe-api/issues/209), which is still
open, and research R5 already designed the interim so the other four stories
do not wait on it. It appears at the end as its own phase, to be picked up
whole once #209 lands.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no unresolved dependency)
- **[Story]**: US1–US4, or omitted for Setup/Foundational/Polish/Deferred
- File paths are exact and relative to the repository root

---

## Phase 1: Setup

**Purpose**: Confirm the branch and establish a pre-change baseline so later
regressions are attributable.

- [ ] T001 Confirm `039-back-office-order-workspace` is checked out and run
      `flutter pub get` at the repository root
- [ ] T002 [P] Run `flutter test test/unit/features/sales test/widget/features/sales test/integration` and `flutter analyze`, and record the baseline pass count — every currently-passing POS test in this baseline must still pass, unmodified in assertion, at the end of Phase 6 (SC-007)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Finish the shared-step seam ([contracts/shared-step-seam.md](./contracts/shared-step-seam.md))
and stand up the workspace's own base infrastructure. **No user story is
independently testable until this phase is complete** — US1 needs a
host-agnostic `CaptureStep`/`DeliveryStep` and somewhere to render them; US4 is
literally proof that this migration left the register unchanged.

**⚠️ CRITICAL**: every task in this phase is a **behaviour-preserving**
refactor of existing point-of-sale code. None may change what a register
sale's screen shows, enables, or does (constitution: online-only, no
speculative change; spec FR-046).

### The seam itself

- [ ] T003 Add `saleConfirmErrorProvider` (`StateProvider<AppError?>`, default
      `null`) and `saleConfirmFailureProvider` (`void Function(AppError)`,
      default: write `saleConfirmErrorProvider` then
      `ref.read(posStepControllerProvider.notifier).jumpTo(PosStep.venta)`) to
      `lib/features/sales/presentation/sale_editor.dart`, both declared
      `@Riverpod(dependencies: [saleEditor])` alongside the existing
      `saleEditorProvider`/`saleWritesScopeProvider` — contracts/shared-step-seam.md §1
- [ ] T004 In `lib/features/sales/presentation/pos_confirm.dart`, delete the
      module-level `confirmErrorProvider` and rewrite
      `confirmBeforePayableAction` to call `read(saleEditorProvider).confirm()`
      and, on failure, `read(saleConfirmFailureProvider)(e)` instead of the two
      hard-coded POS singletons — contracts/shared-step-seam.md §4 (depends on T003)
- [ ] T005 In `lib/features/sales/presentation/capture/capture_step.dart`: add
      `onContinue` (`VoidCallback?`), `continueLabel` (`String`) and
      `showFulfillmentSelector` (`bool`, default `true`) constructor
      parameters; remove the direct reads of `posStepControllerProvider`
      (lines 61, 85) and the old `confirmErrorProvider` (lines 127, 135); read
      `saleWritesScopeProvider` for the write-gate check and
      `saleConfirmErrorProvider` for the banner; make `_onContinuePressed`
      resolve unconfirmed edits against `ref.read(saleWritesScopeProvider)`
      then call `widget.onContinue`; wrap `FulfillmentModeSelector` in
      `if (widget.showFulfillmentSelector)`; pass `continueLabel` and
      `writesPending` through to `SaleTotalsBar` — contracts/shared-step-seam.md §2
      (depends on T003, T004)
- [ ] T006 [P] In `lib/features/sales/presentation/capture/fulfillment_mode_selector.dart`,
      replace the four reads of `posStepControllerProvider`/`posSaleControllerProvider`
      (lines 245, 268, 270, 281) with `saleEditorProvider` and, where the mode
      itself is read, a value passed down from `CaptureStep` rather than read
      independently — contracts/shared-step-seam.md, research R1 (depends on T003)
- [ ] T007 [P] In `lib/features/sales/presentation/capture/customer_bar.dart`
      line 127, replace the direct `posStepControllerProvider` read (the
      generic-customer pickup-reset snackbar) with a call routed through the
      seam, or accept it as a POS-only no-op guarded by a check that this bar
      is not rendered with `excludeGenericCustomer: true` — research R1
      (depends on T003)
- [ ] T008 [P] In `lib/features/sales/presentation/delivery/delivery_step.dart`
      line 259, replace `pendingWritesProvider(posWritesScope)` with
      `pendingWritesProvider(ref.watch(saleWritesScopeProvider))` —
      contracts/shared-step-seam.md §3 (depends on T003)
- [ ] T009 In `lib/features/sales/presentation/delivery/delivery_controller.dart`:
      replace `pendingWritesProvider(posWritesScope)` (line 82) with the seam's
      write scope, and replace the two `confirmBeforePayableAction` call sites
      (lines 105, 172, unchanged signature) so they resolve through the now
      host-agnostic helper from T004 — contracts/shared-step-seam.md §3–§4
      (depends on T003, T004)
- [ ] T010 [P] In `lib/features/sales/presentation/delivery/line_distribution_panel.dart`,
      add a `closeLabel` (`String`) parameter to the widget that owns
      `delivery_close_button` (default: the existing `posFinishSale` text), so
      a host can supply its own close-button wording without a second seam
      provider — contracts/order-workspace.md §7

### Cliente-step data path (research R3)

- [ ] T011 [P] Add an optional `fulfillmentIntent` (`FulfillmentMode?`)
      parameter to `SalesOrderRepository.open()`
      (`lib/features/sales/domain/repositories/sales_order_repository.dart`)
      and its implementation
      (`lib/features/sales/data/sales_order_repository_impl.dart:28-43`),
      threaded to `SalesOrderCreate.fulfillmentIntent` — research R3, no
      codegen required
- [ ] T012 In `lib/features/sales/presentation/sale_editing.dart`, widen
      `updateHeader`'s one-shot fast-path condition (the `state.valueOrNull ==
      null && …` check) to also allow `fulfillmentIntent` through the single
      `repository.open(customer:, salesperson:, fulfillmentIntent:)` call,
      instead of falling through to `ensureOpen()` + `PUT` — research R3
      (depends on T011). **This is load-bearing for FR-014**: without it, a
      Cliente-step attach that also sets `fulfillmentIntent` opens the order
      with no customer for one round trip before correcting it.
- [ ] T013 Add an `attachFulfillmentIntent` (`FulfillmentMode?`, default
      `null`) constructor parameter to `CustomerBar`
      (`lib/features/sales/presentation/capture/customer_bar.dart`); when set
      and `_attachCustomer`/`_createCustomer` are attaching a first customer to
      a sale that does not yet exist, include it in the same `_updateHeader`
      call (composed with, not overriding, the existing `demoteToPickup`
      computation) — research R3 (depends on T012)

### Credit-refusal plumbing (research R8)

- [ ] T014 [P] Add `AppError.creditHold([String? message]) = CreditHoldError`
      to the sealed union in `lib/core/errors/app_error.dart`; run
      `dart run build_runner build` to regenerate `app_error.freezed.dart` —
      research R8
- [ ] T015 In `lib/features/sales/data/sales_order_repository_impl.dart`, add
      a shared helper that recognises a 422 whose `detail` is a plain string
      as `AppError.creditHold(detail)`, and use it — alongside the existing
      `{"message","lines"}` handling, unchanged — in `_toConfirmError` (used by
      `confirm()`), and add equivalent handling to `open()` and
      `updateHeader()`, which currently use the bare `_toAppError` and lose a
      credit-hold message entirely — research R8 (depends on T014)

### The workspace's own base

- [ ] T016 [P] Create `lib/features/sales/presentation/orders/order_step_controller.dart`:
      `OrderStep` enum (`cliente`, `venta`, `entrega`), `OrderStepState`
      (`current`, defaulting to `cliente`), and `OrderStepController` (a
      `@riverpod` `Notifier`) with `advanceToVenta()`, `advanceToEntrega()`,
      `returnToVenta()` (only when the order is still a draft),
      `returnToCliente()` and `resumeTo(Sale sale)` (data-model §2 and §4: draft
      with no real customer → `cliente`; draft → `venta`; completed/paid →
      `entrega`) — data-model.md §2, §4
- [ ] T017 In `lib/features/sales/presentation/orders/order_editor_controller.dart`,
      thread `fulfillmentIntent` through wherever it opens/attaches (it
      inherits `updateHeader` from `SaleEditing`, so this is mostly verifying
      T012/T013 flow through unchanged) — data-model.md §3 note (origin itself
      is deferred; see Phase 8)
- [ ] T018 [P] Add four new l10n keys to `lib/l10n/app_en.arb` and
      `app_es.arb`, in parity: `salesOrderStepCliente` ("Cliente"/"Cliente"),
      `salesOrderStepVenta` ("Sale"/"Venta"), `salesOrderStepEntrega`
      ("Delivery"/"Entrega"), `salesOrderStepProgress` ("Step {current} of
      {total}"/"Paso {current} de {total}") — contracts/order-workspace.md §7
- [ ] T019 [P] Add l10n key `salesOrderContinueToDeliveryAction` ("Continue to
      delivery"/"Continuar a entrega") to `lib/l10n/app_en.arb` and
      `lib/l10n/app_es.arb`, in parity — contracts/order-workspace.md §7
- [ ] T020 [P] Add l10n key `salesOrderCompleteDeliveryAction` ("Complete
      order"/"Completar pedido") to `lib/l10n/app_en.arb` and
      `lib/l10n/app_es.arb`, for the `closeLabel` added in T010 —
      contracts/order-workspace.md §7
- [ ] T021 Create `lib/features/sales/presentation/orders/order_workspace_screen.dart`:
      the top-level host. Installs the nested `ProviderScope` overriding
      `saleEditorProvider`, `saleWritesScopeProvider`,
      `saleConfirmErrorProvider` and `saleConfirmFailureProvider` (all four —
      contracts/shared-step-seam.md §5); renders a step indicator
      (Cliente/Venta/Entrega, using T018's keys) and switches on
      `OrderStepController`'s current step; mirrors
      `pos_workspace_screen.dart`'s shape (full-screen, no shell, the
      `/new` → `/:orderId` URL rewrite on first write) —
      contracts/order-workspace.md §1–§2 (depends on T003, T016, T018)
- [ ] T022 In `lib/app/router/app_router.dart`, replace the `OrderScreen`
      builders at `/sales/orders/new` and `/sales/orders/:orderId` with
      `OrderWorkspaceScreen()` / `OrderWorkspaceScreen(orderId:)`; leave
      `/sales/orders`'s branch, its `PrivilegeGate(SystemObject.salesOrders,
      AccessRight.read)`, and every other route untouched —
      contracts/order-workspace.md §1 (depends on T021)
- [ ] T023 [P] In `lib/features/sales/presentation/pos_workspace_screen.dart`,
      update the `CaptureStep` call site to pass
      `onContinue: () => ref.read(posStepControllerProvider.notifier).advanceToCobro()`,
      `continueLabel` (the existing payment-step label) and
      `showFulfillmentSelector: true`, so register behaviour is supplied
      explicitly rather than assumed by the widget — contracts/shared-step-seam.md §2
      (depends on T005)
- [ ] T024 Delete `lib/features/sales/presentation/orders/order_screen.dart`
      (FR-048) once T021/T022 render in its place

**Checkpoint**: `flutter analyze` is clean; every point-of-sale widget/unit
test from the T002 baseline still passes with **unchanged assertions**
(three of them — `pos_write_gating_test.dart`, `pos_compact_delivery_test.dart`,
`delivery_step_layout_test.dart` — need a constructor-signature-only edit for
the new parameters, per contracts/order-workspace.md §6). User story
implementation can now begin.

---

## Phase 3: User Story 1 - Take an order for a customer and schedule its delivery (Priority: P1) 🎯 MVP

**Goal**: The full happy path for an existing customer — Cliente → Venta →
Entrega → committed, read-only.

**Independent Test**: Sign in with sales-order create rights, start a new
order, pick a customer, add one product, assign every unit to one destination,
close the delivery step — the order comes back with a folio, a non-draft
status, and a delivery order recorded against it (spec.md US1).

### Tests for User Story 1

- [ ] T025 [P] [US1] Unit test in
      `test/unit/features/sales/order_step_controller_test.dart`: forward
      transitions (`cliente → venta → entrega`), `returnToVenta()` refused
      once the order is not a draft, `resumeTo` maps draft/no-customer →
      `cliente`, draft → `venta`, completed/paid → `entrega` — model on
      `pos_step_controller_test.dart`
- [ ] T026 [P] [US1] Widget test in
      `test/widget/features/sales/order_customer_step_test.dart`: the generic
      walk-in customer never appears in search results; picking a customer
      opens the draft with that customer and `fulfillmentIntent: delivery` in
      one request (assert on the fake repository's captured `SalesOrderCreate`,
      not just the resulting `Sale`); the step advances to Venta
- [ ] T027 [P] [US1] Widget test in
      `test/widget/features/sales/order_workspace_test.dart`: Venta shows the
      product search and totals bar once a customer is attached; "Continuar a
      entrega" is disabled with zero lines and enabled with one; the
      fulfilment-mode selector is never rendered; Entrega requires every unit
      assigned before its close action enables; closing commits the order
      (folio assigned, `status != draft`) and the screen goes read-only with
      only priority still editable
- [ ] T028 [P] [US1] Integration test in
      `test/integration/order_workspace_flow_test.dart` (live mbe-api, model on
      `sales_orders_flow_test.dart`): customer attach → add line → add
      destination with full quantity → close → verify via
      `SalesOrderRepository`/`DeliveryOrderRepository` that the order is
      committed and the delivery order exists

### Implementation for User Story 1

- [ ] T029 [US1] Create `lib/features/sales/presentation/orders/customer_step.dart`:
      renders `CustomerBar` in its searching mode with
      `excludeGenericCustomer: true` and `attachFulfillmentIntent:
      FulfillmentMode.delivery` (T013), plus the inline-create entry point
      already on `CustomerBar`; on a successful attach, calls
      `ref.read(orderStepControllerProvider.notifier).advanceToVenta()` —
      research R3 (depends on T013, T016)
- [ ] T030 [US1] In `order_workspace_screen.dart`, wire the `venta` case to
      render `CaptureStep(sale:, onContinue: () =>
      orderStepControllerProvider.notifier.advanceToEntrega(),
      continueLabel: l10n.salesOrderContinueToDeliveryAction (T019),
      showFulfillmentSelector: false)` alongside `OrderHeaderPanel` below the
      customer bar (spec 037's ordering, unchanged) — contracts/order-workspace.md §3
      (depends on T005, T021)
- [ ] T031 [US1] In `order_workspace_screen.dart`, wire the `entrega` case to
      render `DeliveryStep(sale:, mode: FulfillmentMode.delivery, onClose: …)`
      with `LineDistributionFoot`'s `closeLabel` (T010) set from
      `l10n.salesOrderCompleteDeliveryAction` (T020) —
      contracts/order-workspace.md §3 (depends on T010, T021)
- [ ] T032 [US1] Using T028's integration test as the check, verify (and
      adjust `order_workspace_screen.dart` / T009's migration if needed) that
      creating the first destination — which triggers
      `confirmBeforePayableAction` through the migrated seam — commits the
      **order**, not a register sale open at the same time; this is the
      single most important behaviour in this story (spec A2, FR-032, FR-044)
- [ ] T033 [P] [US1] In `lib/features/sales/presentation/orders/order_header_panel.dart`,
      remove the ship-to and contact fields (FR-050) — the two fields, their
      labels, and their disclosure-order entries; retire
      `salesOrderContactLabel`/`salesOrderShipToLabel` from both `.arb` files
      once nothing references them — contracts/order-workspace.md §6, §7
- [ ] T034 [P] [US1] In `lib/features/sales/presentation/orders/customer_step.dart`
      or `order_workspace_screen.dart`, surface an `AppError.creditHold`
      (T014) from the Cliente step's attach without advancing past it, letting
      the user pick a different customer (FR-055)
- [ ] T035 [P] [US1] Give the workspace's `saleConfirmFailureProvider`
      override (in `order_workspace_screen.dart`) two branches: an
      `AppError.creditHold` (T014) is shown without implying the lines are at
      fault and without navigating away from Entrega's own banner slot; every
      other `AppError` is shown as today (naming the offending products for a
      goods refusal) and returns the user to Venta (FR-033, FR-056)
- [ ] T036 [US1] Move (not delete) the eight `order_screen.dart` l10n keys this
      story still needs — `salesOrderConfirmAction`→(repurposed as the commit
      confirmation, if any), `salesOrderNoLinesYet`,
      `salesOrderChooseCustomerFirst` — into use by the new files before T024
      deletes their old home

**Checkpoint**: User Story 1 is fully functional and independently testable.
This is the MVP.

---

## Phase 4: User Story 2 - Register a customer that does not exist yet (Priority: P1)

**Goal**: Inline customer creation from the Cliente step, with no detour.

**Independent Test**: From the Cliente step of a new order, create a customer
that does not exist, and confirm the order proceeds to Venta with that new
customer attached (spec.md US2).

### Tests for User Story 2

- [ ] T037 [P] [US2] Widget test, added to
      `test/widget/features/sales/order_customer_step_test.dart`: the
      inline-create action opens `showCustomerInlineCreate`; on success the
      new customer is attached (one request, customer id from the dialog) and
      the step advances; on cancel, nothing is created and the step is
      unchanged; on a refused create, the refusal is shown and the form keeps
      what was typed

### Implementation for User Story 2

- [ ] T038 [US2] Confirm `customer_step.dart` (T029) exposes `CustomerBar`'s
      existing "create customer" action unmodified — `_createCustomer`
      already routes through the same `_updateHeader` path FR-014/FR-015 use,
      so this story is largely already satisfied by T029; this task is the
      explicit check plus any wiring `showCustomerInlineCreate`'s dialog vs.
      full-screen split needs inside the workspace's own navigation context
      (depends on T029)
- [ ] T039 [US2] Verify a refused create (server-side validation on the new
      customer) leaves the inline form open with its typed values intact and
      opens no order — `customer_form_controller.dart`'s existing refusal
      handling, exercised from this new host

**Checkpoint**: User Stories 1 and 2 both work independently.

---

## Phase 5: User Story 3 - Resume, amend or abandon an order in progress (Priority: P2)

**Goal**: Reopening an order lands on the step its own state implies; a draft
can be cancelled; an order this workspace did not raise is declined rather than
mishandled.

**Independent Test**: Leave an order part-way through each step, reopen it from
the list, confirm it resumes on the implied step; open a register sale from the
list and confirm the workspace declines it (spec.md US3).

### Tests for User Story 3

- [ ] T040 [P] [US3] Widget test, re-homed from `order_resume_test.dart` to
      `test/widget/features/sales/order_workspace_resume_test.dart`: a draft
      with lines and no destinations reopens on Venta with lines/totals
      restored; a committed order with a destination reopens on Entrega
      showing it; a stale-draft write refusal re-reads the order rather than
      leaving stale figures on screen
- [ ] T041 [P] [US3] Widget test, re-homed from `order_cancel_test.dart` to
      `test/widget/features/sales/order_workspace_cancel_test.dart`: the
      cancel action (behind confirmation) is offered only on a draft; a
      cancelled or already-committed order shows read-only with no
      destructive action
- [ ] T042 [P] [US3] Widget test in
      `test/widget/features/sales/order_workspace_foreign_order_test.dart`:
      opening an order on the generic walk-in customer, or with
      `fulfillmentIntent: counterPickup`, or carrying a non-cancelled payment,
      is declined with an explanation and no editable control — this is the
      interim guard (research R5), explicitly a stop-gap pending Phase 8

### Implementation for User Story 3

- [ ] T043 [US3] In `order_workspace_screen.dart`, on opening an existing
      order call `OrderStepController.resumeTo(sale)` (T016) once, mirroring
      `pos_workspace_screen.dart`'s `_syncStepTo` guard against re-deriving on
      every rebuild — data-model.md §4 (depends on T016, T021)
- [ ] T044 [US3] Create the interim foreign-order guard as a pure function
      (e.g. `lib/features/sales/presentation/orders/foreign_order_guard.dart`):
      returns true when the order's customer `isGenericCustomer`, or
      `fulfillmentIntent == FulfillmentMode.counterPickup`, or it carries any
      non-cancelled payment; call it from `order_workspace_screen.dart` before
      `resumeTo` and render a declined state (explanation, no editable
      control) when it returns true — research R5. **Mark this function and
      its call site with a comment naming
      [mbe-api#209](https://github.com/mictlanix/mbe-api/issues/209) and Phase
      8: this is a proxy, not FR-052, and must be deleted when the real field
      lands.**
- [ ] T045 [US3] Wire `OrderEditorController.cancel()` (already implemented)
      to a cancel action visible only while `sale.isEditable`, behind the
      existing `AlertDialog` confirmation pattern from the deleted
      `order_screen.dart` — re-home its dialog keys
      (`sales_order_cancel_button`, `sales_order_cancel_confirm_button`) rather
      than inventing new ones (contracts/order-workspace.md §8)
- [ ] T046 [P] [US3] Confirm the five cancel-dialog l10n keys —
      `salesOrderCancelAction`, `salesOrderCancelDialogTitle`,
      `salesOrderCancelDialogMessage`, `salesOrderCancelDialogKeepEditing`,
      `salesOrderCancelDialogConfirm` — survive in `lib/l10n/app_en.arb` and
      `lib/l10n/app_es.arb` unchanged once T024 deletes `order_screen.dart`;
      they belong to no file being deleted, only re-pointed to by T045
- [ ] T047 [P] [US3] Add l10n keys `salesOrderForeignOrderTitle` and
      `salesOrderForeignOrderMessage` for the declined-order explanation to
      `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb`, in parity

**Checkpoint**: User Stories 1, 2 and 3 all work independently.

---

## Phase 6: User Story 4 - The register is unaffected (Priority: P1)

**Goal**: Prove Phase 2's migration changed nothing observable at the
register, and that a register sale and a back-office order never interfere.

**Independent Test**: Run the existing point-of-sale regression suite
unchanged; with a register sale and a back-office order open at once, confirm
edits to one never gate or alter the other (spec.md US4).

This phase is almost entirely **verification** — the production code it
depends on already shipped in Phase 2. What it adds is the one test that does
not exist yet.

### Tests for User Story 4

- [ ] T048 [US4] Extend `test/widget/features/sales/sale_editor_isolation_test.dart`
      (today the only guard on the seam, and covering the capture surface
      only) to also assert: a register sale and a back-office order can each
      have a destination created without affecting the other's status or
      pending-writes count; creating the *first* destination on the
      back-office order commits it while the register's sale — mid-capture at
      the same moment — stays a draft (spec A2, FR-044; contracts/shared-step-seam.md §6
      invariant 3, the highest-value assertion this feature adds)
- [ ] T049 [P] [US4] Run `flutter test test/integration/pos_counter_sale_flow_test.dart
      test/integration/pos_delivery_split_flow_test.dart
      test/integration/pos_resume_flow_test.dart` and confirm they pass
      **byte-identical** to the T002 baseline — no edits permitted to these
      three files by this feature
- [ ] T050 [P] [US4] Run `flutter test test/widget/features/sales/pos_write_gating_test.dart
      test/widget/features/sales/pos_compact_delivery_test.dart
      test/widget/features/sales/delivery_step_layout_test.dart
      test/widget/features/sales/pos_workspace_route_test.dart
      test/unit/features/sales/pos_step_controller_test.dart` and confirm every
      assertion in them is unchanged from baseline — only the constructor
      call sites touched in T005/T023 may differ

### Implementation for User Story 4

- [ ] T051 [US4] Manually walk a counter-pickup sale through capture → payment
      at the register (quickstart.md Scenario 4 step 5): two steps, not three;
      the fulfilment-mode selector present; the label reads for payment —
      confirms FR-046 end to end, not just by test assertion

**Checkpoint**: All four user stories are independently functional. This is
also SC-007's operational proof.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Tidy what the story phases left, and re-home the tests whose
disposition is "modify" or "re-home" per contracts/order-workspace.md §6 rather
than new.

- [ ] T052 [P] Re-home `order_screen_test.dart` →
      `test/widget/features/sales/order_workspace_test.dart`'s assertions
      (folded into T027 where they overlap; anything not yet covered — lazy
      open, `verifyNever(open())` before a customer is chosen — moves here)
- [ ] T053 [P] Re-home the one surviving test in `order_screen_readonly_test.dart`
      (list-side, "no `sales_orders_new_order_button`" on a no-register
      account) into `sales_orders_list_screen_test.dart`, and delete the rest
      of the file — its read-only assertions are covered by T027
- [ ] T054 [P] Modify `order_header_disclosure_test.dart`: drop the
      `salesOrderContactLabel`/`salesOrderShipToLabel` assertions (T033),
      re-point its pump host to the new workspace, keep everything else
- [ ] T055 [P] Modify `order_header_density_test.dart`: same re-point, and
      adjust the collapsed/expanded `CompactField` counts down by 2
- [ ] T056 [P] Modify `order_no_register_test.dart`: keep its list-side test
      verbatim, re-point its workspace-side test
- [ ] T057 [P] Modify `sales_orders_compact_test.dart`: re-point every test
      after its first (list-side) one to the new workspace at 390px —
      contracts/order-workspace.md flagged this file as in-scope despite its
      name
- [ ] T058 [P] Extend `pos_test_harness.dart`: add `pumpOrdersRouted`
      (consolidating the private copy `sales_orders_filters_test.dart` already
      carries), `fixedOrderSale` (twin of `fixedPosSale`), a shared
      auth/privilege fixture (currently redeclared in 7 files), and
      `MockCustomerRepository` (currently duplicated in 6 files) —
      contracts/order-workspace.md §6
- [ ] T059 [P] Delete `order_write_gating_test.dart`'s assertions only after
      confirming they are folded into T027/T048 — this was flagged as the
      highest-value of the re-homed suite; do not lose coverage in the move
- [ ] T060 Confirm `order_editor_controller_test.dart` still passes unmodified
      (T017 should not have changed its observable behaviour)
- [ ] T061 [P] Diff `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb` against
      their pre-feature state and confirm the two shared, do-not-touch keys —
      `salesOrdersMenuTitle` (`lib/core/navigation/nav_destinations.dart`) and
      `salesOrderPaymentTermsLabel` (`lib/features/sales/presentation/capture/customer_bar.dart`)
      — are byte-identical to before
- [ ] T062 Run the full quickstart.md validation: automated commands, then
      manual Scenarios 1–4 (Scenario 5 is Phase 8's, per quickstart's own note)
- [ ] T063 `flutter analyze` clean; full suite green; manually confirm the two
      remaining deployment checks from quickstart.md (`SCHEDULED_ORDER_EXPIRY_DAYS`
      sized to real delivery lead times per mbe-api#210's fix, and
      `delivery_order_requires_paid_or_credit_sales_order` off) against the
      target deployment

---

## Phase 8: Deferred — Origin tracking (blocked on mbe-api#209)

**Do not start until [mbe-api#209](https://github.com/mictlanix/mbe-api/issues/209)
lands, its backfill policy is settled, and codegen has been re-run.** Nothing
in Phases 1–7 depends on this phase; it is what finally satisfies FR-051–FR-054
and SC-010–SC-012, and what deletes T044's interim guard.

- [ ] T064 Re-run OpenAPI codegen (`lib/generated/openapi/`) against
      mbe-api's updated spec once #209 ships; extend the `Sale.fromResponse`
      mapping in `lib/features/sales/domain/entities/sale.dart` with `origin`
      (data-model.md §3) — constitution III
- [ ] T065 In `sale_editing.dart`'s `ensureOpen`/`open()` path (or wherever the
      Cliente step's attach ultimately posts), send the origin value this
      workspace always writes — never editable afterwards
- [ ] T066 Replace T044's `foreign_order_guard.dart` with a check against the
      real `Sale.origin` field; delete the proxy conditions (generic customer,
      counter-pickup intent, non-cancelled payment) entirely — FR-052 is only
      satisfied once nothing here infers origin from anything else
- [ ] T067 Update `test/widget/features/sales/order_workspace_foreign_order_test.dart`
      (T042) to assert against `Sale.origin` instead of the proxy conditions;
      add a case for an order whose origin is `null` (predates the field) and
      confirm it is still declined exactly as a proxy-matched order was —
      FR-054, SC-012
- [ ] T068 Confirm no existing order's list/open/read behaviour changed by
      this phase (SC-012) — a spot check against orders raised before #209
      shipped, which all have `origin: null`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: none
- **Foundational (Phase 2)**: depends on Setup; **blocks every user story** —
  it is where the seam migration and the workspace's base infrastructure live
- **User Stories (Phases 3–6)**: all depend on Phase 2. US1 (Phase 3) is the
  critical path — US2 depends on US1's Cliente step existing (T029); US3's
  resume logic depends on US1's workspace shell; US4 depends only on Phase 2's
  migration itself and can run as soon as that lands, in parallel with US1–US3
- **Polish (Phase 7)**: depends on Phases 3–6 (the re-homed tests need the new
  files they point at to exist)
- **Deferred (Phase 8)**: depends on Phases 1–7 **and** an external event
  (mbe-api#209 landing) — not on a timeline this task list controls

### User Story Dependencies

- **US1 (P1)**: depends on Foundational only
- **US2 (P1)**: depends on US1's `customer_step.dart` (T029) existing —
  narrowly, not on the rest of US1
- **US3 (P2)**: depends on US1's workspace shell (T021, T043 needs
  `resumeTo` from T016, already Foundational) — not on US2
- **US4 (P1)**: depends on Foundational only; independent of US1–US3, though in
  practice it validates work Phase 2 already did

### Within Each Phase

- Tests before the implementation they cover, and written to fail first
- The seam (T003–T010) before anything that reads it
- The Cliente-step data path (T011–T013) before the Cliente step widget (T029)
- Models/controllers before the screens that render them

### Parallel Opportunities

- Within Phase 2: T006, T007, T008, T010, T011, T014, T016, T018, T019, T020
  are marked `[P]` — different files, no cross-dependency
- Within each story's test block, all `[P]`-marked tests can be written
  together
- US4 (Phase 6) can run concurrently with US1–US3 once Phase 2 completes — it
  touches no file any of them own
- Every `[P]` task in Phase 7 targets a different file

---

## Parallel Example: Phase 2 (Foundational)

```bash
# After T003 (the new providers) lands, these can proceed together:
Task: "Replace fulfillment_mode_selector.dart's singleton reads (T006)"
Task: "Replace customer_bar.dart's one singleton read (T007)"
Task: "Fix delivery_step.dart's write-scope read (T008)"
Task: "Add closeLabel to line_distribution_panel.dart (T010)"
Task: "Widen SalesOrderRepository.open() with fulfillmentIntent (T011)"
Task: "Add AppError.creditHold (T014)"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Phase 1: Setup
2. Phase 2: Foundational — **the bulk of the risk lives here, not in US1's own
   code**; this is where the seam migration happens
3. Phase 3: User Story 1
4. **STOP and VALIDATE**: quickstart.md Scenario 1, plus T048's isolation
   assertion — even though US4 is a separate phase, do not skip validating
   that the register is unharmed before calling US1 done
5. Demo: a full order, customer through committed delivery

### Incremental Delivery

1. Setup + Foundational → seam proven, workspace shell exists
2. US1 → the MVP: a complete order, start to commit
3. US4 → run alongside or immediately after US1; it is largely verification of
   Phase 2, so do not leave it until last out of habit
4. US2 → inline customer creation
5. US3 → resume, cancel, decline foreign orders (with the interim guard)
6. Polish → re-home the remaining tests, close the loop on quickstart.md
7. Phase 8, whenever mbe-api#209 lands — a self-contained final slice

### Notes

- No team-parallelization section is included: this is sized for one
  implementer working phase by phase, per the project's usual delivery
  pattern. The `[P]` markers still tell you which tasks have no reason to wait
  on each other.
- T032 and T048 are this feature's two most important checks — not because
  they are hard to write, but because they are the only two places a silent
  cross-host write would be caught before it reached a register in daily use
  (spec A10).
- Every task above traces to a spec FR, a research decision, or a contract
  clause named inline — if a task's rationale is unclear during
  implementation, the citation is where to look before guessing.
