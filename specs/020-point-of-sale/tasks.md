---

description: "Task list for 020-point-of-sale"
---

# Tasks: Point of Sale — Sale Capture

**Input**: Design documents from `/specs/020-point-of-sale/`

**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/](./contracts/), [quickstart.md](./quickstart.md)

**Tests**: Included. Constitution "Development Workflow & Quality Gates" requires
unit, widget and integration coverage, and this feature is the first to do money
arithmetic — the distribution invariant (SC-005) and the payment gate (FR-049)
are exactly the kind of logic plan.md flags as worth testing before it is wired
to a screen.

**Organization**: Grouped by user story. Phases 3–7 map to the spec's P1–P5.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Parallelizable — different file, no dependency on an incomplete task
- **[Story]**: US1–US5, on user-story phases only

## Path Conventions

Single Flutter app. Source under `lib/`, tests under `test/unit/features/sales/`,
`test/widget/features/sales/` and `test/integration/` — matching this repo's
existing test layout (`test/unit/features/<name>/…`), not the shorter
`test/unit/sales/` sketch in plan.md's first draft, which has been corrected to
match. Generated `*.freezed.dart` / `*.g.dart` files are never hand-edited —
they are produced by the `build_runner` tasks below.

---

## Phase 1: Setup

**Purpose**: Establish a clean baseline and the one new dependency this feature
needs.

- [ ] T001 Confirm a clean baseline on branch `020-point-of-sale`: run `flutter pub get`, `dart run build_runner build --delete-conflicting-outputs`, `flutter gen-l10n`, `flutter analyze` and `flutter test`, and record any pre-existing failure before changing code
- [ ] T002 [P] Add the `decimal` package to `pubspec.yaml` (research.md §8 — the only new dependency this feature introduces) and run `flutter pub get`
- [ ] T003 Re-verify codegen parity per research.md §15: regenerate the client against a running mbe-api's `/openapi.json` via `tool/generate_api_client.sh` and confirm `git diff --stat lib/generated` is empty — `sales_orders_api.dart`, `delivery_orders_api.dart` and `customer_payments_api.dart` were verified present during planning but must be re-checked against whatever mbe-api revision implementation actually targets
- [ ] T004 [P] Promote money formatting to shared code: move `lib/features/pricing/presentation/pricing_formatters.dart` to `lib/core/widgets/money_formatters.dart` (rename the class to `MoneyFormatters`), update its two call sites in `lib/features/pricing/`, per plan.md's Project Structure

**Checkpoint**: Dependencies resolved, codegen confirmed current, shared money formatting in `core/`.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: The one sale record, the one controller that owns it, and the step
machine every story runs inside. No user story can be demonstrated without this.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [ ] T005 [P] Create the `Sale` freezed entity in `lib/features/sales/domain/entities/sale.dart` — fields and `SaleStatus` enum per [data-model.md](./data-model.md) §1, with `fromResponse(SalesOrderResponse)` and the derived `isEditable`/`isPaid` getters (§1.1)
- [ ] T006 [P] Create the `SaleLine` freezed entity in `lib/features/sales/domain/entities/sale_line.dart` per [data-model.md](./data-model.md) §2, including the joined-not-stored `availability` field for the shortfall warning
- [ ] T007 [P] Create `FulfillmentMode` (enum + `shipTo` encode/decode helpers against a facility's own address) in `lib/features/sales/domain/entities/fulfillment_mode.dart` per [data-model.md](./data-model.md) §4 and [research.md](./research.md) §4
- [ ] T008 [P] Create the decimal arithmetic helpers (`parse`, `add`, `subtract`, `compare`, `isZero`) in `lib/features/sales/domain/money.dart`, wrapping `package:decimal` per [research.md](./research.md) §8 — values stay `String` at the domain boundary; `Decimal` is used only inside this file's computations
- [ ] T009 Create the `SalesOrderRepository` interface in `lib/features/sales/domain/repositories/sales_order_repository.dart` — `open()`, `updateHeader()`, `addLine()`, `updateLine()`, `removeLine()`, `confirm()`, `getById()`, `productLookup()` per [contracts/mbe-api-pos.md](./contracts/mbe-api-pos.md) §1 — depends on T005, T006 (parameter/return types)
- [ ] T010 Implement `SalesOrderRepositoryImpl` in `lib/features/sales/data/sales_order_repository_impl.dart` wrapping the generated `SalesOrdersApi`, mapping every DTO to/from the T005/T006 entities and mbe-api errors to the shared domain error types (constitution §III) — depends on T009
- [ ] T011 Run `dart run build_runner build --delete-conflicting-outputs` to generate the freezed companions for T005–T008
- [ ] T012 Create `PosSaleController` (`AsyncNotifier<Sale>`) in `lib/features/sales/presentation/pos_sale_controller.dart` — `build()` opens a sale (T009's `open()`) when none is selected, and every mutation method calls its repository endpoint and replaces state wholesale with the response, never recomputing totals locally (research.md §1, FR-007, FR-008) — depends on T010, T011
- [ ] T013 Create `PosStepController` (`Notifier<PosStepState>`) in `lib/features/sales/presentation/pos_step_controller.dart` implementing the step machine from [contracts/pos-screen.md](./contracts/pos-screen.md) §2 — `venta`/`cobro`/`entrega` steps, the 2-vs-3-step shape driven by fulfilment mode, and the transition guards (≥1 line to confirm, balance-zero-or-netD to leave payment)
- [ ] T014 Run `dart run build_runner build --delete-conflicting-outputs` to generate the riverpod companions for T012–T013
- [ ] T015 Add the `/sales/pos` route gated on `salesOrders:read` to `lib/app/router/app_router.dart`, and a Point of Sale destination to `lib/core/navigation/nav_destinations.dart` — depends on T012, T013
- [ ] T016 Create a minimal `PosScreen` scaffold in `lib/features/sales/presentation/pos_screen.dart`: watches `PosSaleController`, renders a header-band placeholder and a step host that switches on `PosStepController`'s current step with empty placeholders for each — depends on T015
- [ ] T017 [P] Unit test `PosStepController`'s transition guards in `test/unit/features/sales/pos_step_controller_test.dart`: 2 steps for counter pickup, 3 for delivery/mixed, confirm blocked with no lines, payment-step exit blocked above zero balance except on credit terms
- [ ] T018 [P] Unit test the decimal helpers in `test/unit/features/sales/money_test.dart`, including the exact-sum property SC-005 depends on

**Checkpoint**: The Point of Sale nav entry is reachable, opening it creates a real sale, and the empty step host renders. No capture, payment or delivery UI exists yet.

---

## Phase 3: User Story 1 — Sell across the counter and take the money (Priority: P1) 🎯 MVP

**Goal**: The complete two-step counter-sale flow: search/scan and capture lines
with warehouse, quantity, price, discount and tax; confirm; take one or more
payments to a zero balance; close.

**Independent Test**: Add two products, take a single cash payment for the full
amount, and confirm — the resulting order exists, is confirmed, carries both
lines and shows a zero balance (SC-001).

- [ ] T019 [P] [US1] Create the `ProductLookupResult` and `WarehouseStock` entities in `lib/features/sales/domain/entities/product_lookup_result.dart` per [data-model.md](./data-model.md) §3
- [ ] T020 [US1] Add `productLookup()` mapping to `SalesOrderRepository`/`SalesOrderRepositoryImpl` (T009/T010), returning `List<ProductLookupResult>` — depends on T019
- [ ] T021 [P] [US1] Create `productLookupControllerProvider`, an autodispose family keyed by search text and warehouse, in `lib/features/sales/presentation/capture/product_lookup_controller.dart` — depends on T020
- [ ] T022 [P] [US1] Create `ProductSearchField` in `lib/features/sales/presentation/capture/product_search_field.dart` — one field for scan and search, submits on Enter, keeps focus and clears after a successful add, shows a results list on multiple matches (FR-020, FR-021) — depends on T021
- [ ] T023 [P] [US1] Create `CustomerBar` in `lib/features/sales/presentation/capture/customer_bar.dart` — walk-in customer preselected, shows name/credit line/balance/price list, offers search-a-different-customer via the existing catalog customer picker (FR-011, FR-012)
- [ ] T024 [US1] Create `FulfillmentModeSelector` in `lib/features/sales/presentation/capture/fulfillment_mode_selector.dart` — the three-chip Tienda/Domicilio/Mixta control (FR-017); in this phase only Tienda is wired to `PosSaleController.updateHeader`, Domicilio/Mixta are rendered but inert until US2 (T059) makes them functional
- [ ] T025 [US1] Create `SaleLineRow` (expanded tier) in `lib/features/sales/presentation/capture/sale_line_row.dart` — product, warehouse picker with availability, quantity stepper, in-place price/discount edit, read-only tax rate (FR-023, amended per research §12), line total, delete, and the non-blocking shortfall warning (FR-025, FR-026) — depends on T012
- [ ] T026 [P] [US1] Create `SaleTotalsBar` in `lib/features/sales/presentation/capture/sale_totals_bar.dart` — line count, unit count, subtotal, discount, tax, grand total, all read from `Sale` (FR-028)
- [ ] T027 [US1] Create `CaptureStep` in `lib/features/sales/presentation/capture/capture_step.dart` composing T022–T026, with "Continuar al cobro" enabled only once at least one line exists (FR-038) — depends on T022, T023, T024, T025, T026
- [ ] T028 [US1] Wire `CaptureStep` into `PosScreen`'s step host in `lib/features/sales/presentation/pos_screen.dart`, replacing the T016 placeholder for the `venta` step — depends on T027
- [ ] T029 [US1] Wire "Continuar al cobro" to `PosSaleController.confirm()` and the `PosStepController` transition to `cobro`, rendering the two confirmation failure modes — zero-priced lines, insufficient stock — inline on the named offending lines while staying on the capture step (FR-039, [contracts/pos-screen.md](./contracts/pos-screen.md) §6) — depends on T028
- [ ] T030 [P] [US1] Create the `SalePayment` entity in `lib/features/sales/domain/entities/sale_payment.dart` per [data-model.md](./data-model.md) §7
- [ ] T031 [P] [US1] Create `payment_method_rules.dart` in `lib/features/sales/domain/payment_method_rules.dart` — the client-side table of which `PaymentMethod` values require a reference/authorization (card, transfer, cheque), per [research.md](./research.md) §6
- [ ] T032 [US1] Create the `CustomerPaymentRepository` interface in `lib/features/sales/domain/repositories/customer_payment_repository.dart` — `createPayment()`, `applyPayment()`, `reverseApplication()` per [contracts/mbe-api-pos.md](./contracts/mbe-api-pos.md) §3 — depends on T030
- [ ] T033 [US1] Implement `CustomerPaymentRepositoryImpl` in `lib/features/sales/data/customer_payment_repository_impl.dart` wrapping the generated `CustomerPaymentsApi` — depends on T032
- [ ] T034 [US1] Run `dart run build_runner build --delete-conflicting-outputs` to generate the freezed companions for T019, T030
- [ ] T035 [P] [US1] Create the shared `NumberPad` widget in `lib/core/widgets/number_pad.dart` — 0–9, decimal point, backspace, fully keyboard-equivalent (FR-043)
- [ ] T036 [US1] Create `PaymentController` (`Notifier<PaymentDraft>`) in `lib/features/sales/presentation/payment/payment_controller.dart` — amount entry, method selection, reference, the session-scoped applied-payments list (research.md §11), and the add-payment sequence (create, then apply, per [contracts/mbe-api-pos.md](./contracts/mbe-api-pos.md) §3), computing change when the tender exceeds the balance (FR-047) — depends on T033, T031
- [ ] T037 [P] [US1] Create `PaymentAmountField` with quick-amount chips ("Restante", fixed amounts, "Mitad") in `lib/features/sales/presentation/payment/payment_amount_field.dart` — depends on T035
- [ ] T038 [P] [US1] Create `PaymentMethodGrid` in `lib/features/sales/presentation/payment/payment_method_grid.dart` — built from the facility's `PaymentMethodOption`s, falling back to the fixed `PaymentMethod` list when none are configured (research.md §6), each tile showing whether a reference is required (T031)
- [ ] T039 [P] [US1] Create `AppliedPaymentsPanel` in `lib/features/sales/presentation/payment/applied_payments_panel.dart` — lists applied payments with method/amount/reference/validation state, reversible with a mandatory reason (FR-048)
- [ ] T040 [US1] Create `PaymentStep` in `lib/features/sales/presentation/payment/payment_step.dart` composing T036–T039: total/paid/balance header (FR-042), amount field, method grid, reference field, applied payments, and the close action gated on zero balance or credit terms (FR-049, FR-051) — depends on T036, T037, T038, T039
- [ ] T041 [US1] Wire `PaymentStep` into `PosScreen`'s step host for the `cobro` step; on close for a counter-pickup sale, show the change due and offer to start a new sale (FR-050) — depends on T028, T040
- [ ] T042 [P] [US1] Add the Venta/Cobro `es-MX` strings (customer bar, mode selector, search placeholder, line-grid headers, totals labels, payment step labels, quick amounts, method names, confirm-gate messages) to `lib/l10n/app_es.arb`
- [ ] T043 [P] [US1] Add the same keys with English wording and `@` metadata to `lib/l10n/app_en.arb`
- [ ] T044 [US1] Run `flutter gen-l10n` — depends on T042, T043
- [ ] T045 [P] [US1] Unit test `Sale`/`SaleLine` DTO-to-entity mapping in `test/unit/features/sales/sale_mapping_test.dart`
- [ ] T046 [P] [US1] Unit test `payment_method_rules.dart` in `test/unit/features/sales/payment_method_rules_test.dart`
- [ ] T047 [P] [US1] Widget test `SaleLineRow`'s in-place edit affordances and shortfall warning in `test/widget/features/sales/sale_line_row_test.dart`
- [ ] T048 [P] [US1] Widget test `PaymentStep`'s close gate — disabled above zero balance, enabled at zero, the credit-terms exception (FR-051) — in `test/widget/features/sales/payment_step_gate_test.dart`
- [ ] T049 [P] [US1] Widget test the step indicator shows exactly two steps for a counter-pickup sale in `test/widget/features/sales/step_indicator_test.dart`
- [ ] T050 [US1] Integration test the full counter-sale flow against a live mbe-api, discovering its fixtures at runtime (a real stockable product, a real customer) rather than hardcoding ids, per [quickstart.md](./quickstart.md) Scenario 1, in `test/integration/pos_counter_sale_flow_test.dart`

**Checkpoint**: User Story 1 is fully functional and independently testable — the MVP.

---

## Phase 4: User Story 2 — Send the goods to one or more addresses (Priority: P2)

**Goal**: Delivery and mixed fulfilment: the main address at capture time, the
delivery step after payment, per-destination address/contact/date, per-line
quantity splitting with the create-then-trim sequence, and the close gate.

**Independent Test**: Capture and pay a two-line sale in delivery mode, split one
line between two addresses, close the sale — two delivery records exist, one per
address, holding exactly the quantities entered (SC-005).

- [ ] T051 [P] [US2] Create the `Destination` entity in `lib/features/sales/domain/entities/destination.dart` per [data-model.md](./data-model.md) §5
- [ ] T052 [P] [US2] Create the `DestinationLine` entity in `lib/features/sales/domain/entities/destination_line.dart` per [data-model.md](./data-model.md) §5.1
- [ ] T053 [P] [US2] Create the `LineDistribution` view model in `lib/features/sales/domain/entities/line_distribution.dart` per [data-model.md](./data-model.md) §6 — `perDestination`, `atCounter`, `isComplete`, and a pure function computing it from a `Sale` and its `Destination`s
- [ ] T054 [US2] Run `dart run build_runner build --delete-conflicting-outputs` to generate the freezed companions for T051–T053
- [ ] T055 [US2] Unit test the distribution invariant — Σ`perDestination` + `atCounter` == `ordered`, for every line, after every operation the step can perform — against a fake repository in `test/unit/features/sales/destination_split_test.dart`, **before** any UI depends on it (plan.md's own instruction; this is the highest-risk logic in the feature) — depends on T053
- [ ] T056 [US2] Create the `DeliveryOrderRepository` interface in `lib/features/sales/domain/repositories/delivery_order_repository.dart` — `create()`, `updateHeader()`, `updateLine()`, `removeLine()` per [contracts/mbe-api-pos.md](./contracts/mbe-api-pos.md) §2 — depends on T051, T052
- [ ] T057 [US2] Implement `DeliveryOrderRepositoryImpl` in `lib/features/sales/data/delivery_order_repository_impl.dart` wrapping the generated `DeliveryOrdersApi`, encoding contact name/phone into `comment` per the [research.md](./research.md) §10 stopgap — depends on T056
- [ ] T058 [US2] Implement the create-then-trim orchestrator in `lib/features/sales/domain/destination_split.dart` (research.md §3): creating a destination claims everything not yet covered by another; the client then `PUT`s/`DELETE`s its lines down to the cashier's entry; writes for one destination must complete before the next destination is created — depends on T055 (test exists first), T057
- [ ] T059 [US2] Fully wire `FulfillmentModeSelector` (T024): selecting Domicilio or Mixta requires naming the sale's main delivery address before capture continues (FR-056), via the existing address entity picker and `showAddressInlineCreateDialog`, writing it through `PosSaleController.updateHeader(shipTo: …)` (research.md §4) — depends on T024
- [ ] T060 [US2] Extend `PosStepController` (T013) so a mode other than counter pickup inserts the `entrega` step and updates the step count (FR-005, FR-018) — depends on T059
- [ ] T061 [US2] Create `DeliveryController` (`AsyncNotifier<List<Destination>>`) in `lib/features/sales/presentation/delivery/delivery_controller.dart` — loads existing destinations on entry (the resume case), and drives every add/edit/remove through `destination_split.dart`, recomputing `LineDistribution` after each write (FR-030) — depends on T058
- [ ] T062 [US2] Run `dart run build_runner build --delete-conflicting-outputs` to generate the riverpod companion for T061
- [ ] T063 [P] [US2] Create `DestinationCard` in `lib/features/sales/presentation/delivery/destination_card.dart` — address, contact, date, line/unit counts, edit/remove (FR-029)
- [ ] T064 [P] [US2] Create `DestinationEditor` in `lib/features/sales/presentation/delivery/destination_editor.dart` — address picker/inline-create, contact name and phone, delivery date, per-line quantity inputs that refuse to exceed what remains undistributed (FR-031, FR-032)
- [ ] T065 [P] [US2] Create `LineDistributionPanel` in `lib/features/sales/presentation/delivery/line_distribution_panel.dart` — per line: ordered, assigned per destination, at counter, and the running distributed/total count (FR-033)
- [ ] T066 [US2] Create `DeliveryStep` in `lib/features/sales/presentation/delivery/delivery_step.dart` composing T063–T065, with the mode-specific close gate: mixed sweeps the remainder as a `COUNTER_PICKUP` destination (FR-036), pure delivery blocks and names the unassigned units (FR-035) — depends on T061, T063, T064, T065
- [ ] T067 [US2] Wire `DeliveryStep` into `PosScreen`'s step host, opening after payment for delivery/mixed sales, with per-destination failure isolation so one refusal never affects an already-recorded destination (FR-037) — depends on T041, T066
- [ ] T068 [US2] Extend the resume logic (T028/T041) so a paid sale with an incomplete distribution reopens directly on `entrega`, per [contracts/pos-screen.md](./contracts/pos-screen.md) §5 — depends on T067
- [ ] T069 [P] [US2] Add the Entrega `es-MX` strings (destination card, editor fields, distribution panel, close-gate messages) to `lib/l10n/app_es.arb`
- [ ] T070 [P] [US2] Add the same keys with English wording to `lib/l10n/app_en.arb`
- [ ] T071 [US2] Run `flutter gen-l10n` — depends on T069, T070
- [ ] T072 [P] [US2] Widget test that a destination the server refuses leaves every other destination and its own entered values intact (FR-037) in `test/widget/features/sales/destination_editor_error_test.dart`
- [ ] T073 [US2] Integration test a delivery split across two addresses plus a mixed-mode remainder, asserting server-side that each line's quantities across delivery orders sum to its ordered quantity (SC-005), per [quickstart.md](./quickstart.md) Scenarios 2–3, in `test/integration/pos_delivery_split_flow_test.dart`

**Checkpoint**: User Stories 1 and 2 both independently functional.

---

## Phase 5: User Story 3 — Pick up a sale that was left open (Priority: P2)

**Goal**: The open-sales selector, and resuming a sale at whichever step its
server-side state implies.

**Independent Test**: Start a sale with two lines, leave the screen, reopen the
point of sale and select the earlier sale from the selector — both lines and the
selected customer are still there (SC-004).

- [ ] T074 [P] [US3] Create the `OpenSale` entity in `lib/features/sales/domain/entities/open_sale.dart` per [data-model.md](./data-model.md) §8
- [ ] T075 [US3] Extend `SalesOrderRepository`/`SalesOrderRepositoryImpl` with `listOpen({status})` — `mine=true` plus `status`/`dateFrom` per [research.md](./research.md) §5 — depends on T074
- [ ] T076 [US3] Run `dart run build_runner build --delete-conflicting-outputs` to generate the freezed companion for T074
- [ ] T077 [US3] Create `openSalesControllerProvider` (autodispose `AsyncNotifier<List<OpenSale>>`) in `lib/features/sales/presentation/open_sales_selector_controller.dart` — two calls, `draft` and `completed`, invalidated after a confirm and after a new sale starts — depends on T075
- [ ] T078 [US3] Create `OpenSalesSelector` in `lib/features/sales/presentation/open_sales_selector.dart` — reference, customer, total, newest first (US3 scenario 1) — depends on T077
- [ ] T079 [US3] Create `PosHeaderBand` in `lib/features/sales/presentation/pos_header_band.dart` composing `OpenSalesSelector` and the step indicator directly beneath the app bar (research.md §13), superseding the T016 placeholder — depends on T078
- [ ] T080 [US3] Wire `PosHeaderBand` into `pos_screen.dart` — depends on T079
- [ ] T081 [US3] Selecting a sale loads it (`GET`) and resolves the entry step from `status` and `shipTo` — draft → Venta, completed → Cobro, paid-and-undistributed → Entrega, per [contracts/pos-screen.md](./contracts/pos-screen.md) §5; "start a new sale" opens a fresh draft alongside it (US3 scenario 3) — depends on T080
- [ ] T082 [US3] Abandoning an open sale with no lines cancels it via the sales order cancel endpoint rather than leaving an empty open sale behind (US3 scenario 6 / Edge Cases) — depends on T081
- [ ] T083 [P] [US3] Unit test the status/`shipTo` → entry-step resolution in `test/unit/features/sales/open_sale_resolution_test.dart`
- [ ] T084 [P] [US3] Widget test `OpenSalesSelector` renders open sales and restores a selected sale's customer/lines/mode in `test/widget/features/sales/open_sales_selector_test.dart`
- [ ] T085 [US3] Integration test interrupting and resuming at each reachable step — draft, completed-unpaid, paid-undistributed — per [quickstart.md](./quickstart.md) Scenario 4, in `test/integration/pos_resume_flow_test.dart`

**Checkpoint**: User Stories 1, 2 and 3 all independently functional.

---

## Phase 6: User Story 4 — Register a customer without losing the sale (Priority: P3)

**Goal**: Create a customer from the sale without discarding what has been
captured, and attach it immediately.

**Independent Test**: From an open sale, create a customer through the inline
form and confirm the sale is now attached to that customer with their price list
applied to subsequently added lines.

- [ ] T086 [US4] Create `customer_inline_create.dart` in `lib/features/sales/presentation/customer_inline_create.dart` wrapping the existing `lib/features/catalog/presentation/customer_form_controller.dart` behind a dialog (≥ 600 px) / full-screen route (< 600 px), per FR-013 and A-002 (the cashier types the code)
- [ ] T087 [US4] Wire `CustomerBar`'s "create customer" affordance (T023) to open the dialog and, on save, `PUT` the sale's customer and refresh `Sale` via `PosSaleController` (FR-014) — depends on T086
- [ ] T088 [US4] Render the FR-015 notice when the customer changes on a sale that already has lines, stating that existing lines keep their captured prices — depends on T087
- [ ] T089 [P] [US4] Add the customer-inline-create strings to `lib/l10n/app_es.arb` and `lib/l10n/app_en.arb`; run `flutter gen-l10n`
- [ ] T090 [P] [US4] Widget test that creating a customer attaches it to the sale and shows the FR-015 notice when lines already exist, in `test/widget/features/sales/customer_inline_create_test.dart`

**Checkpoint**: User Stories 1 through 4 all independently functional.

---

## Phase 7: User Story 5 — Work the counter from a phone (Priority: P3)

**Goal**: Every step usable at 390 px with no horizontal scroll — single-column
lines, a collapsed stepper, and a pinned bottom action.

**Independent Test**: Drive the complete counter-sale story at 390 px wide
without horizontal scrolling and with every control reachable (SC-007).

- [ ] T091 [P] [US5] Create `SaleLineCard` (compact tier) in `lib/features/sales/presentation/capture/sale_line_card.dart`
- [ ] T092 [US5] Switch `CaptureStep` between `SaleLineRow` (≥ 600 px) and `SaleLineCard` (< 600 px) via the central breakpoints, pinning `SaleTotalsBar` and the primary action to the bottom (FR-053) — depends on T027, T091
- [ ] T093 [US5] Collapse `PosHeaderBand`'s stepper to a "Paso N de M" label and the selector to a compact chip below 600 px — depends on T079
- [ ] T094 [US5] Verify/adjust `PaymentStep`'s compact layout so amount entry, quick amounts, the method grid and applied payments are all reachable by vertical scroll alone, reusing `NumberPad` as-is — depends on T040
- [ ] T095 [US5] Verify/adjust `DeliveryStep`'s compact layout as stacked expandable destination cards — depends on T066
- [ ] T096 [US5] Widget test the complete counter-sale journey at 390 px renders with zero horizontal scroll and every control reachable, in `test/widget/features/sales/pos_compact_layout_test.dart` — depends on T092, T093, T094

**Checkpoint**: All five user stories independently functional, at every supported width.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Close out the backend gaps this feature documented rather than
silently accepted, and verify the whole feature once more as a whole.

- [ ] T097 [P] File the five mbe-api issues from [contracts/mbe-api-pos.md](./contracts/mbe-api-pos.md) §5 (customer addresses, contacts API, sale-payments listing, optional line tax rate, optional `point_sale` filter) and link them back from research.md
- [ ] T098 Re-verify codegen parity once more against the mbe-api revision this feature actually ships against, confirming today's stopgaps (research.md §9–§12) are still accurate
- [ ] T099 [P] Accessibility pass: tooltip or semantic label on every icon-only control across the capture, payment and delivery steps
- [ ] T100 `flutter analyze` across `lib/features/sales/` with zero warnings
- [ ] T101 Run the complete [quickstart.md](./quickstart.md) scenario set manually against a live mbe-api and record the results
- [ ] T102 Run the full automated suite — unit, widget and integration — and confirm green

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: no dependencies — start immediately
- **Foundational (Phase 2)**: depends on Setup — **blocks all user stories**
- **User Stories (Phase 3–7)**: all depend on Foundational
  - US1 (P1) has no dependency on any other story
  - US2 (P2) extends `FulfillmentModeSelector` (T024) and `PosStepController` (T013) from US1, and its `PosScreen` wiring (T067) depends on US1's payment wiring (T041) — genuinely sequential, not merely ordered by priority
  - US3 (P2) can start once Foundational is done; its header-band wiring (T079/T080) supersedes the US1 placeholder and its resume logic (T068) extends US2's step resolution — build after US1+US2 for a working resume target, though its own tasks touch no US1/US2 file
  - US4 (P3) depends only on US1's `CustomerBar` (T023)
  - US5 (P3) depends on US1's `CaptureStep`/`PaymentStep` and US2's `DeliveryStep` existing to restyle
- **Polish (Phase 8)**: depends on every user story that will ship

### Within Each User Story

- Entities before repositories before controllers before widgets before step composition before wiring into `PosScreen`
- The riskiest logic is tested before it is wired to UI: T055 (distribution invariant) before T058 (the orchestrator that uses it)
- l10n keys are added and generated before the widgets that reference them are wired into the step host
- Integration tests come last in each phase — they exercise the whole story against a live server

### Parallel Opportunities

- T005–T008 (all four foundational entities) — different files, no dependency on each other
- T017, T018 — independent unit tests, once T013/T008 exist
- Within US1: T019, T023, T024, T026, T030, T031, T035 — independent files
- Within US1's test batch: T045–T049 — independent files
- Within US2: T051–T053 — independent files; T063–T065 — independent widgets once T061 exists
- US4 and US5 can proceed in parallel once US1–US3 are done, since neither depends on the other

---

## Implementation Strategy

### MVP First

Phases 1–3 (Setup, Foundational, US1) are the deliverable minimum: a cashier can
open the screen, capture a counter sale, and take payment to a zero balance. This
matches the spec's own P1 designation and SC-001.

### Incremental Delivery

1. Setup + Foundational + US1 → **MVP**, demoable and independently testable
2. + US2 → delivery and mixed fulfilment
3. + US3 → interrupted sales are recoverable, closing the live-recording promise
4. + US4 → inline customer creation
5. + US5 → compact tier
6. Phase 8 → backend issues filed, full suite green

Each checkpoint above is a shippable increment; nothing later in the list is
required for an earlier increment to work correctly on its own.
