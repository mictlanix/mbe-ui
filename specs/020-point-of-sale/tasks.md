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

**Revised 2026-08-04** after `/speckit-analyze` found 2 critical and 3 high
findings: 3 tasks inserted (T030 and two compact-layout tests, now T097/T098
after the second revision below) and 9 existing tasks amended. Every
renumbered ID reflects that pass — see the per-task notes citing "analysis
finding *Nx/Cx*" for what changed and why.

**Revised again 2026-08-04** after mbe-api's team confirmed the legacy system
re-priced a sale's lines on a customer change, which the current backend does
not (verified against `update_order`'s source — research.md §17). FR-015 was
redesigned around that intended behavior; the "show a notice" task (old T089)
is removed — there is nothing to notify once repricing genuinely happens, since
the screen already reflects every server-driven change automatically (FR-007,
FR-008) — and its test (old T091) is repurposed rather than deleted. Filed as
[mbe-api#131](https://github.com/mictlanix/mbe-api/issues/131), tracked as a
**blocking** dependency in spec.md D-005. Net: −1 task (104 total), Phases 6–8
renumbered.

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
- [ ] T012 Create `PosSaleController` (`AsyncNotifier<Sale>`) in `lib/features/sales/presentation/pos_sale_controller.dart` — `build()` opens a sale (T009's `open()`) when none is selected; every mutation method calls its repository endpoint and replaces state wholesale with the response, never recomputing totals locally (research.md §1, FR-007, FR-008); a rejected mutation MUST leave `state` at its last accepted value (not `AsyncError`, which would blank the sale from view) while surfacing the failure for the caller to render inline (FR-009, analysis finding C6); and a `refresh()` method re-fetches via `getById()` for callers outside this controller's own mutations — notably `PaymentController` (T037), since applying a payment changes `Sale.balance` through a different repository entirely (analysis finding I1, [contracts/pos-screen.md](./contracts/pos-screen.md) §3–§4) — depends on T010, T011
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
- [ ] T022 [P] [US1] Create `ProductSearchField` in `lib/features/sales/presentation/capture/product_search_field.dart` — one field for scan and search, submits on Enter, keeps focus and clears after a successful add, shows a results list on multiple matches (FR-020, FR-021); owns its own `TextEditingController`/`FocusNode`, independent of `Sale` rebuilds, so an in-flight mutation elsewhere on the screen never drops keystrokes or steals focus here (FR-010, analysis finding C6) — depends on T021
- [ ] T023 [P] [US1] Create `CustomerBar` in `lib/features/sales/presentation/capture/customer_bar.dart` — walk-in customer preselected, shows name/credit line/balance/price list, offers search-a-different-customer via the existing catalog customer picker wired to `PosSaleController.updateHeader(customer: …)` (FR-011, FR-012), and an immediate/credit payment-terms toggle wired the same way, surfacing the server's refusal when the customer has no available credit line (FR-016, analysis finding C2); no special handling is needed for FR-015's repricing — once [mbe-api#131](https://github.com/mictlanix/mbe-api/issues/131) ships, the `updateHeader` response already carries repriced lines through T012's normal wholesale replace. **Until #131 ships**, a customer switch here silently leaves lines at their old price (spec.md D-005, accepted interim risk) — flag this to whoever schedules the P1 release
- [ ] T024 [US1] Create `FulfillmentModeSelector` in `lib/features/sales/presentation/capture/fulfillment_mode_selector.dart` — the three-chip Tienda/Domicilio/Mixta control (FR-017); in this phase only Tienda is wired to `PosSaleController.updateHeader`, Domicilio/Mixta are rendered but inert until US2 (T060) makes them functional
- [ ] T025 [US1] Create `SaleLineRow` (expanded tier) in `lib/features/sales/presentation/capture/sale_line_row.dart` — product, warehouse picker with availability, quantity stepper, in-place price/discount edit, read-only tax rate (FR-023, amended per research §12), line total, delete, and the non-blocking shortfall warning (FR-025, FR-026) — depends on T012
- [ ] T026 [P] [US1] Create `SaleTotalsBar` in `lib/features/sales/presentation/capture/sale_totals_bar.dart` — line count, unit count, subtotal, discount, tax, grand total, all read from `Sale` (FR-028)
- [ ] T027 [US1] Create `CaptureStep` in `lib/features/sales/presentation/capture/capture_step.dart` composing T022–T026: wires a selected search/scan result to `PosSaleController.addLine()`, defaulting `warehouse` to the cashier's point-of-sale warehouse (`UserSettings`) unless the cashier overrides it on the line afterward (FR-024, analysis finding C7), with "Continuar al cobro" enabled only once at least one line exists (FR-038) — depends on T022, T023, T024, T025, T026
- [ ] T028 [US1] Wire `CaptureStep` into `PosScreen`'s step host in `lib/features/sales/presentation/pos_screen.dart`, replacing the T016 placeholder for the `venta` step — depends on T027
- [ ] T029 [US1] Wire "Continuar al cobro" to `PosSaleController.confirm()` and the `PosStepController` transition to `cobro`, rendering the two confirmation failure modes — zero-priced lines, insufficient stock — inline on the named offending lines while staying on the capture step (FR-039, [contracts/pos-screen.md](./contracts/pos-screen.md) §6); on success, every reference display (this screen's own header, and later `PosHeaderBand`, T081) MUST read `Sale.serial` once it is non-null instead of the provisional `Sale.id` (FR-040, analysis finding C8) — depends on T028
- [ ] T030 [US1] Derive each capture widget's enabled state from `Sale.isEditable` (data-model.md §1.1, [contracts/pos-screen.md](./contracts/pos-screen.md) §2 "Editability"): disable `SaleLineRow`'s (T025) in-place edits, `CustomerBar`'s (T023) customer-change and payment-terms controls, and `FulfillmentModeSelector` (T024) once the sale is confirmed, replacing them with an explanatory banner rather than offering an action the server will reject with 409 (FR-041, analysis finding C3) — depends on T023, T024, T025, T029
- [ ] T031 [P] [US1] Create the `SalePayment` entity in `lib/features/sales/domain/entities/sale_payment.dart` per [data-model.md](./data-model.md) §7
- [ ] T032 [P] [US1] Create `payment_method_rules.dart` in `lib/features/sales/domain/payment_method_rules.dart` — the client-side table of which `PaymentMethod` values require a reference/authorization (card, transfer, cheque), per [research.md](./research.md) §6
- [ ] T033 [US1] Create the `CustomerPaymentRepository` interface in `lib/features/sales/domain/repositories/customer_payment_repository.dart` — `createPayment()`, `applyPayment()`, `reverseApplication()` per [contracts/mbe-api-pos.md](./contracts/mbe-api-pos.md) §3 — depends on T031
- [ ] T034 [US1] Implement `CustomerPaymentRepositoryImpl` in `lib/features/sales/data/customer_payment_repository_impl.dart` wrapping the generated `CustomerPaymentsApi` — depends on T033
- [ ] T035 [US1] Run `dart run build_runner build --delete-conflicting-outputs` to generate the freezed companions for T019, T031
- [ ] T036 [P] [US1] Create the shared `NumberPad` widget in `lib/core/widgets/number_pad.dart` — 0–9, decimal point, backspace, fully keyboard-equivalent (FR-043)
- [ ] T037 [US1] Create `PaymentController` (`Notifier<PaymentDraft>`) in `lib/features/sales/presentation/payment/payment_controller.dart` — amount entry, method selection, reference, the session-scoped applied-payments list (research.md §11), and the add-payment sequence (create, then apply, per [contracts/mbe-api-pos.md](./contracts/mbe-api-pos.md) §3); after each successful application, calls `PosSaleController.refresh()` (T012) so `Sale.balance` reflects the payment immediately — the balance the close gate (T041) reads is otherwise never updated (analysis finding I1) — and computes change when the tender exceeds the balance (FR-047) — depends on T034, T032, T012
- [ ] T038 [P] [US1] Create `PaymentAmountField` with quick-amount chips ("Restante", fixed amounts, "Mitad") in `lib/features/sales/presentation/payment/payment_amount_field.dart` — depends on T036
- [ ] T039 [P] [US1] Create `PaymentMethodGrid` in `lib/features/sales/presentation/payment/payment_method_grid.dart` — built from the facility's `PaymentMethodOption`s, falling back to the fixed `PaymentMethod` list when none are configured (research.md §6), each tile showing whether a reference is required (T032)
- [ ] T040 [P] [US1] Create `AppliedPaymentsPanel` in `lib/features/sales/presentation/payment/applied_payments_panel.dart` — lists applied payments with method/amount/reference/validation state, reversible with a mandatory reason (FR-048)
- [ ] T041 [US1] Create `PaymentStep` in `lib/features/sales/presentation/payment/payment_step.dart` composing T037–T040: total/paid/balance header (FR-042), amount field, method grid, reference field, applied payments, and the close action gated on zero balance or credit terms (FR-049, FR-051) — depends on T037, T038, T039, T040
- [ ] T042 [US1] Wire `PaymentStep` into `PosScreen`'s step host for the `cobro` step; on close for a counter-pickup sale, show the change due and offer to start a new sale (FR-050) — depends on T028, T041
- [ ] T043 [P] [US1] Add the Venta/Cobro `es-MX` strings (customer bar, payment-terms toggle, mode selector, search placeholder, line-grid headers, totals labels, payment step labels, quick amounts, method names, confirm-gate messages, the post-confirmation read-only banner) to `lib/l10n/app_es.arb`
- [ ] T044 [P] [US1] Add the same keys with English wording and `@` metadata to `lib/l10n/app_en.arb`
- [ ] T045 [US1] Run `flutter gen-l10n` — depends on T043, T044
- [ ] T046 [P] [US1] Unit test `Sale`/`SaleLine` DTO-to-entity mapping in `test/unit/features/sales/sale_mapping_test.dart`
- [ ] T047 [P] [US1] Unit test `payment_method_rules.dart` in `test/unit/features/sales/payment_method_rules_test.dart`
- [ ] T048 [P] [US1] Widget test `SaleLineRow`'s in-place edit affordances and shortfall warning in `test/widget/features/sales/sale_line_row_test.dart`
- [ ] T049 [P] [US1] Widget test `PaymentStep`'s close gate — disabled above zero balance, enabled at zero once `PaymentController` has refreshed `Sale` (T037), the credit-terms exception (FR-051) — in `test/widget/features/sales/payment_step_gate_test.dart`
- [ ] T050 [P] [US1] Widget test the step indicator shows exactly two steps for a counter-pickup sale in `test/widget/features/sales/step_indicator_test.dart`
- [ ] T051 [US1] Integration test the full counter-sale flow against a live mbe-api, discovering its fixtures at runtime (a real stockable product, a real customer) rather than hardcoding ids, per [quickstart.md](./quickstart.md) Scenario 1, in `test/integration/pos_counter_sale_flow_test.dart`

**Checkpoint**: User Story 1 is fully functional and independently testable — the MVP.

---

## Phase 4: User Story 2 — Send the goods to one or more addresses (Priority: P2)

**Goal**: Delivery and mixed fulfilment: the main address at capture time, the
delivery step after payment, per-destination address/contact/date, per-line
quantity splitting with the create-then-trim sequence, and the close gate.

**Independent Test**: Capture and pay a two-line sale in delivery mode, split one
line between two addresses, close the sale — two delivery records exist, one per
address, holding exactly the quantities entered (SC-005).

- [ ] T052 [P] [US2] Create the `Destination` entity in `lib/features/sales/domain/entities/destination.dart` per [data-model.md](./data-model.md) §5
- [ ] T053 [P] [US2] Create the `DestinationLine` entity in `lib/features/sales/domain/entities/destination_line.dart` per [data-model.md](./data-model.md) §5.1
- [ ] T054 [P] [US2] Create the `LineDistribution` view model in `lib/features/sales/domain/entities/line_distribution.dart` per [data-model.md](./data-model.md) §6 — `perDestination`, `atCounter`, `isComplete`, and a pure function computing it from a `Sale` and its `Destination`s
- [ ] T055 [US2] Run `dart run build_runner build --delete-conflicting-outputs` to generate the freezed companions for T052–T054
- [ ] T056 [US2] Unit test the distribution invariant — Σ`perDestination` + `atCounter` == `ordered`, for every line, after every operation the step can perform — against a fake repository in `test/unit/features/sales/destination_split_test.dart`, **before** any UI depends on it (plan.md's own instruction; this is the highest-risk logic in the feature) — depends on T054
- [ ] T057 [US2] Create the `DeliveryOrderRepository` interface in `lib/features/sales/domain/repositories/delivery_order_repository.dart` — `create()`, `updateHeader()`, `updateLine()`, `removeLine()` per [contracts/mbe-api-pos.md](./contracts/mbe-api-pos.md) §2 — depends on T052, T053
- [ ] T058 [US2] Implement `DeliveryOrderRepositoryImpl` in `lib/features/sales/data/delivery_order_repository_impl.dart` wrapping the generated `DeliveryOrdersApi`, encoding contact name/phone into `comment` per the [research.md](./research.md) §10 stopgap — depends on T057
- [ ] T059 [US2] Implement the create-then-trim orchestrator in `lib/features/sales/domain/destination_split.dart` (research.md §3): creating a destination claims everything not yet covered by another; the client then `PUT`s/`DELETE`s its lines down to the cashier's entry; writes for one destination must complete before the next destination is created — depends on T056 (test exists first), T058
- [ ] T060 [US2] Fully wire `FulfillmentModeSelector` (T024): selecting Domicilio or Mixta first checks the selected customer's `shipping` flag and refuses the switch with the reason shown when the customer isn't permitted to receive deliveries (FR-019, analysis finding C4); otherwise it requires naming the sale's main delivery address before capture continues (FR-056), via the existing address entity picker and `showAddressInlineCreateDialog`, writing it through `PosSaleController.updateHeader(shipTo: …)` (research.md §4) — depends on T024
- [ ] T061 [US2] Extend `PosStepController` (T013) so a mode other than counter pickup inserts the `entrega` step and updates the step count (FR-005, FR-018) — depends on T060
- [ ] T062 [US2] Create `DeliveryController` (`AsyncNotifier<List<Destination>>`) in `lib/features/sales/presentation/delivery/delivery_controller.dart` — loads existing destinations on entry (the resume case), and drives every add/edit/remove through `destination_split.dart`, recomputing `LineDistribution` after each write (FR-030) — depends on T059
- [ ] T063 [US2] Run `dart run build_runner build --delete-conflicting-outputs` to generate the riverpod companion for T062
- [ ] T064 [P] [US2] Create `DestinationCard` in `lib/features/sales/presentation/delivery/destination_card.dart` — address, contact, date, line/unit counts, edit/remove (FR-029)
- [ ] T065 [P] [US2] Create `DestinationEditor` in `lib/features/sales/presentation/delivery/destination_editor.dart` — address picker/inline-create, contact name and phone, delivery date, per-line quantity inputs that refuse to exceed what remains undistributed (FR-031, FR-032)
- [ ] T066 [P] [US2] Create `LineDistributionPanel` in `lib/features/sales/presentation/delivery/line_distribution_panel.dart` — per line: ordered, assigned per destination, at counter, and the running distributed/total count (FR-033)
- [ ] T067 [US2] Create `DeliveryStep` in `lib/features/sales/presentation/delivery/delivery_step.dart` composing T064–T066, with the mode-specific close gate: mixed sweeps the remainder as a `COUNTER_PICKUP` destination (FR-036), pure delivery blocks and names the unassigned units (FR-035) — depends on T062, T064, T065, T066
- [ ] T068 [US2] Wire `DeliveryStep` into `PosScreen`'s step host, opening after payment for delivery/mixed sales, with per-destination failure isolation so one refusal never affects an already-recorded destination (FR-037) — depends on T042, T067
- [ ] T069 [US2] Extend the resume logic (T028/T042) so a paid sale with an incomplete distribution reopens directly on `entrega`, per [contracts/pos-screen.md](./contracts/pos-screen.md) §5 — depends on T068
- [ ] T070 [P] [US2] Add the Entrega `es-MX` strings (destination card, editor fields, distribution panel, close-gate messages, the shipping-not-permitted refusal from T060) to `lib/l10n/app_es.arb`
- [ ] T071 [P] [US2] Add the same keys with English wording to `lib/l10n/app_en.arb`
- [ ] T072 [US2] Run `flutter gen-l10n` — depends on T070, T071
- [ ] T073 [P] [US2] Widget test that a destination the server refuses leaves every other destination and its own entered values intact (FR-037) in `test/widget/features/sales/destination_editor_error_test.dart`
- [ ] T074 [US2] Integration test a delivery split across two addresses plus a mixed-mode remainder, asserting server-side that each line's quantities across delivery orders sum to its ordered quantity (SC-005), per [quickstart.md](./quickstart.md) Scenarios 2–3, in `test/integration/pos_delivery_split_flow_test.dart`

**Checkpoint**: User Stories 1 and 2 both independently functional.

---

## Phase 5: User Story 3 — Pick up a sale that was left open (Priority: P2)

**Goal**: The open-sales selector, and resuming a sale at whichever step its
server-side state implies — including a paid, delivery/mixed sale whose
distribution is still incomplete (FR-058).

**Independent Test**: Start a sale with two lines, leave the screen, reopen the
point of sale and select the earlier sale from the selector — both lines and the
selected customer are still there (SC-004).

- [ ] T075 [P] [US3] Create the `OpenSale` entity in `lib/features/sales/domain/entities/open_sale.dart` per [data-model.md](./data-model.md) §8
- [ ] T076 [US3] Extend `SalesOrderRepository`/`SalesOrderRepositoryImpl` with `listOpen({status})` — `mine=true` plus `status`/`dateFrom` per [research.md](./research.md) §5, covering all three reachable open statuses: `draft`, `completed`, and `paid` for a delivery/mixed sale awaiting distribution (analysis finding C1 — omitting `paid` would make such a sale unreachable from the selector, contradicting FR-058) — depends on T075
- [ ] T077 [US3] Run `dart run build_runner build --delete-conflicting-outputs` to generate the freezed companion for T075
- [ ] T078 [US3] Create `openSalesControllerProvider` (autodispose `AsyncNotifier<List<OpenSale>>`) in `lib/features/sales/presentation/open_sales_selector_controller.dart` — three calls, `draft`, `completed` and `paid` (the last filtered client-side to sales whose `LineDistribution` is incomplete, since mbe-api cannot filter on that server-side), invalidated after a confirm, after a payment closes a delivery/mixed sale, and after a new sale starts (FR-058) — depends on T076
- [ ] T079 [US3] Create `OpenSalesSelector` in `lib/features/sales/presentation/open_sales_selector.dart` — reference, customer, total, newest first (US3 scenario 1) — depends on T078
- [ ] T080 [US3] Create `PosHeaderBand` in `lib/features/sales/presentation/pos_header_band.dart` composing `OpenSalesSelector` and the step indicator directly beneath the app bar (research.md §13, spec.md FR-004 as amended), reading `Sale.serial ?? Sale.id` for the reference chip so it reflects the same provisional→folio swap as T029 (FR-040, analysis finding C8), superseding the T016 placeholder — depends on T079
- [ ] T081 [US3] Wire `PosHeaderBand` into `pos_screen.dart` — depends on T080
- [ ] T082 [US3] Selecting a sale loads it (`GET`) and resolves the entry step from `status` and `shipTo` — draft → Venta, completed → Cobro, paid-and-undistributed → Entrega, per [contracts/pos-screen.md](./contracts/pos-screen.md) §5; "start a new sale" opens a fresh draft alongside it (US3 scenario 3) — depends on T081
- [ ] T083 [US3] Abandoning an open sale with no lines cancels it via the sales order cancel endpoint rather than leaving an empty open sale behind (US3 scenario 6 / Edge Cases) — depends on T082
- [ ] T084 [P] [US3] Unit test the status/`shipTo` → entry-step resolution in `test/unit/features/sales/open_sale_resolution_test.dart`
- [ ] T085 [P] [US3] Widget test `OpenSalesSelector` renders open sales — including a paid, undistributed delivery sale (FR-058, analysis finding C1) — and restores a selected sale's customer/lines/mode in `test/widget/features/sales/open_sales_selector_test.dart`
- [ ] T086 [US3] Integration test interrupting and resuming at each reachable step — draft, completed-unpaid, paid-undistributed — per [quickstart.md](./quickstart.md) Scenario 4, in `test/integration/pos_resume_flow_test.dart`

**Checkpoint**: User Stories 1, 2 and 3 all independently functional.

---

## Phase 6: User Story 4 — Register a customer without losing the sale (Priority: P3)

**Goal**: Create a customer from the sale without discarding what has been
captured, and attach it immediately.

**Independent Test**: From an open sale, create a customer through the inline
form and confirm the sale is now attached to that customer with their price list
applied to subsequently added lines.

- [ ] T087 [US4] Create `customer_inline_create.dart` in `lib/features/sales/presentation/customer_inline_create.dart` wrapping the existing `lib/features/catalog/presentation/customer_form_controller.dart` behind a dialog (≥ 600 px) / full-screen route (< 600 px), per FR-013 and A-002 (the cashier types the code)
- [ ] T088 [US4] Wire `CustomerBar`'s "create customer" affordance (T023) to open the dialog and, on save, attach the new customer via `PosSaleController.updateHeader(customer: …)` (FR-014); like T023's customer-switch path, this needs no separate handling for FR-015 — the `updateHeader` response already carries repriced lines once [mbe-api#131](https://github.com/mictlanix/mbe-api/issues/131) ships — depends on T087
- [ ] T089 [P] [US4] Add the customer-inline-create strings to `lib/l10n/app_es.arb` and `lib/l10n/app_en.arb`; run `flutter gen-l10n`
- [ ] T090 [P] [US4] Widget test that creating a customer attaches it to the sale (FR-014) and that its line list reflects whatever `Sale` the fake repository returns after the header update — the general server-truth-reflection behavior FR-015 now relies on, exercised concretely via a customer attach rather than a bespoke notice (analysis follow-up: this task replaces the old "renders an FR-015 notice" test, which no longer applies now that FR-015 describes a reprice, not a preservation, of existing prices) — in `test/widget/features/sales/customer_inline_create_test.dart`

**Checkpoint**: User Stories 1 through 4 all independently functional.

---

## Phase 7: User Story 5 — Work the counter from a phone (Priority: P3)

**Goal**: Every step usable at 390 px with no horizontal scroll — single-column
lines, a collapsed stepper, and a pinned bottom action — for **all five**
journeys, not only the counter sale (SC-007).

**Independent Test**: Drive the complete counter-sale story at 390 px wide
without horizontal scrolling and with every control reachable (SC-007).

- [ ] T091 [P] [US5] Create `SaleLineCard` (compact tier) in `lib/features/sales/presentation/capture/sale_line_card.dart`
- [ ] T092 [US5] Switch `CaptureStep` between `SaleLineRow` (≥ 600 px) and `SaleLineCard` (< 600 px) via the central breakpoints, pinning `SaleTotalsBar` and the primary action to the bottom (FR-053) — depends on T027, T091
- [ ] T093 [US5] Collapse `PosHeaderBand`'s stepper to a "Paso N de M" label and the selector to a compact chip below 600 px — depends on T080
- [ ] T094 [US5] Verify/adjust `PaymentStep`'s compact layout so amount entry, quick amounts, the method grid and applied payments are all reachable by vertical scroll alone, reusing `NumberPad` as-is — depends on T041
- [ ] T095 [US5] Verify/adjust `DeliveryStep`'s compact layout as stacked expandable destination cards — depends on T067
- [ ] T096 [P] [US5] Widget test the complete counter-sale journey at 390 px renders with zero horizontal scroll and every control reachable, in `test/widget/features/sales/pos_compact_layout_test.dart` — depends on T092, T093, T094
- [ ] T097 [P] [US5] Widget test the delivery-mode journey (US2) at 390 px — mode selection, the main-address requirement, destination cards, the editor and the distribution panel all reachable by vertical scroll alone with zero horizontal scroll (SC-007, analysis finding C5) — in `test/widget/features/sales/pos_compact_delivery_test.dart` — depends on T095
- [ ] T098 [P] [US5] Widget test resuming an open sale and creating a customer inline (US3, US4) at 390 px, confirming both are reachable with zero horizontal scroll (SC-007, analysis finding C5) — in `test/widget/features/sales/pos_compact_resume_and_customer_test.dart` — depends on T082, T087

**Checkpoint**: All five user stories independently functional, at every supported width.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Close out the backend gaps this feature documented rather than
silently accepted, and verify the whole feature once more as a whole.

- [ ] T099 [P] Check the status of all 8 filed mbe-api issues ([contracts/mbe-api-pos.md](./contracts/mbe-api-pos.md) §5: #131–#138) and, for any that have shipped, remove the corresponding stopgap and its "analysis finding"/gap notes from spec.md, research.md, contracts/ and this file rather than leaving a superseded workaround in place
- [ ] T100 Re-verify codegen parity once more against the mbe-api revision this feature actually ships against, confirming today's stopgaps (research.md §9–§12, §17) are still accurate — in particular, confirm whether #131 has landed and, if so, remove the D-005 interim-risk note from spec.md
- [ ] T101 [P] Accessibility pass: tooltip or semantic label on every icon-only control across the capture, payment and delivery steps
- [ ] T102 `flutter analyze` across `lib/features/sales/` with zero warnings
- [ ] T103 Run the complete [quickstart.md](./quickstart.md) scenario set manually against a live mbe-api and record the results
- [ ] T104 Run the full automated suite — unit, widget and integration — and confirm green

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: no dependencies — start immediately
- **Foundational (Phase 2)**: depends on Setup — **blocks all user stories**
- **User Stories (Phase 3–7)**: all depend on Foundational
  - US1 (P1) has no dependency on any other story
  - US2 (P2) extends `FulfillmentModeSelector` (T024) and `PosStepController` (T013) from US1, and its `PosScreen` wiring (T068) depends on US1's payment wiring (T042) — genuinely sequential, not merely ordered by priority
  - US3 (P2) can start once Foundational is done; its header-band wiring (T080/T081) supersedes the US1 placeholder, and its own resume-step resolution (T082) builds on the delivery-incomplete case US2 already extended (T069) — build after US1+US2 for a working resume target, though its own tasks touch no US1/US2 file
  - US4 (P3) depends only on US1's `CustomerBar` (T023)
  - US5 (P3) depends on US1's `CaptureStep`/`PaymentStep`, US2's `DeliveryStep`, and US3's `PosHeaderBand`/resume logic existing to restyle and re-test at compact width
- **Polish (Phase 8)**: depends on every user story that will ship

### Within Each User Story

- Entities before repositories before controllers before widgets before step composition before wiring into `PosScreen`
- The riskiest logic is tested before it is wired to UI: T056 (distribution invariant) before T059 (the orchestrator that uses it)
- l10n keys are added and generated before the widgets that reference them are wired into the step host
- Integration tests come last in each phase — they exercise the whole story against a live server

### Parallel Opportunities

- T005–T008 (all four foundational entities) — different files, no dependency on each other
- T017, T018 — independent unit tests, once T013/T008 exist
- Within US1: T019, T023, T024, T026, T031, T032, T036 — independent files
- Within US1's test batch: T046–T050 — independent files
- Within US2: T052–T054 — independent files; T064–T066 — independent widgets once T062 exists
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
5. + US5 → compact tier, tested across all five journeys
6. Phase 8 → backend issues filed, full suite green

Each checkpoint above is a shippable increment; nothing later in the list is
required for an earlier increment to work correctly on its own.
