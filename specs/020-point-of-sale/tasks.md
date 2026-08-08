---

description: "Task list for 020-point-of-sale"
---

# Tasks: Point of Sale — Sale Capture

**Input**: Design documents from `/specs/020-point-of-sale/`

**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/](./contracts/), [quickstart.md](./quickstart.md)

**Tests**: Included. Constitution "Development Workflow & Quality Gates" requires
unit, widget and integration coverage.

**Organization**: Grouped by user story. Phases 3–7 map to the spec's P1–P5.

**Revised 2026-08-05 — third revision.** Two things happened since the prior
revision, both verified directly against source, not assumed:

1. **All 8 mbe-api issues this feature filed have shipped** (mbe-api PR #139,
   research.md top-of-file table). The heaviest consequence: `DeliveryOrderCreate`
   now accepts a named line subset in one call, so the entire create-then-trim
   orchestrator (old `destination_split.dart`, its dedicated risk-mitigation
   unit test, its per-destination serialization requirement) is **deleted**,
   not simplified. Three other stopgaps are deleted the same way: the
   global-address-search fallback, the comment-encoded destination contact, and
   the session-scoped applied-payments list. The line's tax rate is genuinely
   editable now, and FR-023's read-only amendment is reverted.
2. **A cash session is now a hard precondition** (research.md §18, spec.md
   D-006, FR-002a/FR-002b) — a deliberate, explicit reversal of spec 021's own
   "no coupling" decision, made now that 021 has actually shipped something to
   depend on (`lib/features/sales/`, already populated with
   `currentSessionControllerProvider`, `money.dart`, the promoted
   `MoneyFormatters`, and the shared `PaymentMethod` enum — all reused here,
   not rebuilt).

Every task ID below is fresh; nothing from the prior two revisions' numbering
survives unchanged, since the deletions and insertions touch nearly every
phase. Net change to the file plan:

- **5 files reused instead of created** — `money.dart` (extended, not
  duplicated), `money_formatters.dart`, `payment_method.dart`,
  `cash_session_repository.dart` and `current_session_controller.dart`, all
  already in `lib/features/sales/` or `lib/core/` courtesy of
  021-cash-sessions (research.md §14). The last two were never in this
  feature's own prior plan — they became relevant only because the cash-session
  gate is new in this revision.
- **2 files deleted from the plan entirely** — `destination_split.dart` (the
  create-then-trim orchestrator) and `payment_method_rules.dart` (the
  client-side reference-required table), both obsoleted by shipped backend
  capabilities rather than merely simplified.
- **6 new catalog-layer files added** that 021 didn't need but this feature
  does — `Contact` and its repository/impl/inline-create dialog, plus the
  `Customer` and `PaymentMethodOption` extensions.
- **1 new foundational screen state** — the cash-session gate.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Parallelizable — different file, no dependency on an incomplete task
- **[Story]**: US1–US5, on user-story phases only

## Path Conventions

Single Flutter app. Source under `lib/`, tests under `test/unit/features/sales/`,
`test/unit/features/catalog/`, `test/widget/features/sales/` and
`test/integration/`, matching this repo's existing test layout. Generated
`*.freezed.dart` / `*.g.dart` files are never hand-edited — they are produced
by the `build_runner` tasks below.

---

## Phase 1: Setup

**Purpose**: Confirm a clean baseline and the one small catalog-layer addition
every later phase can assume exists (plus a reuse-confirmation pass, so nothing
021 already built gets rebuilt under a new name).

- [X] T001 Confirm a clean baseline on branch `020-point-of-sale`: run `flutter pub get`, `dart run build_runner build --delete-conflicting-outputs`, `flutter gen-l10n`, `flutter analyze` and `flutter test`, and record any pre-existing failure before changing code
- [X] T002 **Verified against a live mbe-api 2026-08-05** (regenerated via `tool/generate_api_client.sh`; `git diff --stat lib/generated` empty; all 8 resolved fields confirmed present). Re-verify codegen parity per research.md §15: regenerate the client against a running mbe-api's `/openapi.json` via `tool/generate_api_client.sh` and confirm `git diff --stat lib/generated` is empty. Specifically confirm all 8 resolved fields are present: `SalesOrderLineCreate/Update.taxRate`, `CustomerCreate/Update/Response.addresses`/`.contacts`, `contacts_api.dart`, `DeliveryOrderCreate.lines`, `SalesOrdersApi.listSalesOrderPaymentsApiV1SalesOrdersSalesOrderIdPaymentsGet`, `SalesOrdersGet`'s `pointSale` parameter, `PaymentMethodOptionResponse.requiresReference`
- [X] T003 [P] Extend `PaymentMethodOption` in `lib/features/catalog/domain/entities/payment_method_option.dart` and its repository/impl to map the new `requiresReference` field from `PaymentMethodOptionResponse` (research.md §6, resolved)
- [X] T004 [P] Confirm reuse rather than re-creating: `lib/features/sales/domain/money.dart`, `lib/core/widgets/money_formatters.dart`, `lib/core/domain/payment_method.dart` and `lib/features/sales/domain/repositories/cash_session_repository.dart` all already exist (021-cash-sessions, research.md §14) — read each and note in a code comment or PR description which of this feature's later tasks extends them, so nobody duplicates them under a new name

**Checkpoint**: ✅ Codegen confirmed current against the shipped backend; the one small catalog gap this feature needs before Setup ends is closed.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: The cash-session gate, the one sale record, the one controller
that owns it, and the step machine every story runs inside. No user story can
be demonstrated until this phase is complete.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [X] T005 [P] Create the `Sale` freezed entity in `lib/features/sales/domain/entities/sale.dart` — fields and `SaleStatus` enum per [data-model.md](./data-model.md) §1, with `fromResponse(SalesOrderResponse)` and the derived `isEditable`/`isPaid` getters (§1.1)
- [X] T006 [P] Create the `SaleLine` freezed entity in `lib/features/sales/domain/entities/sale_line.dart` per [data-model.md](./data-model.md) §2 — `taxRate` is a normal editable field, not a read-only one (resolved, research §12)
- [X] T007 [P] Create `FulfillmentMode` (enum + `shipTo` encode/decode helpers against a facility's own address) in `lib/features/sales/domain/entities/fulfillment_mode.dart` per [data-model.md](./data-model.md) §4 and [research.md](./research.md) §4
- [X] T008 Extend `lib/features/sales/domain/money.dart` (021-cash-sessions' file — **edit, do not create**) with generic `add`/`subtract`/`compare`/`isZero` `Decimal` helpers alongside the existing `countedTotal`/`expectedCash`/`difference`, per [research.md](./research.md) §8 — this feature's balance/change/distribution arithmetic needs the generic operations 021's cash-specific ones don't provide
- [X] T009 Create the `SalesOrderRepository` interface in `lib/features/sales/domain/repositories/sales_order_repository.dart` — `open()`, `updateHeader()`, `addLine()`, `updateLine()`, `removeLine()`, `confirm()`, `getById()`, `productLookup()` per [contracts/mbe-api-pos.md](./contracts/mbe-api-pos.md) §1, `addLine`/`updateLine` accepting `taxRate` — depends on T005, T006 (also pulled forward `listOpen()`/T083 and `cancel()`/T090 into this same interface, and created `ProductLookupResult`/T021 + `OpenSale`/T082 early to satisfy its signature — one repository file, written once)
- [X] T010 Implement `SalesOrderRepositoryImpl` in `lib/features/sales/data/sales_order_repository_impl.dart` wrapping the generated `SalesOrdersApi`, mapping every DTO to/from the T005/T006 entities and mbe-api errors to the shared domain error types (constitution §III) — depends on T009
- [X] T011 Run `dart run build_runner build --delete-conflicting-outputs` to generate the freezed companions for T005–T007
- [X] T012 Create `PosSaleController` (`AsyncNotifier<Sale>`) in `lib/features/sales/presentation/pos_sale_controller.dart` — `build()` opens a sale (T009's `open()`) when none is selected; every mutation method calls its repository endpoint and replaces state wholesale with the response, never recomputing totals locally (research.md §1, FR-007, FR-008); a rejected mutation leaves `state` at its last accepted value while surfacing the failure for the caller to render inline (FR-009); and a `refresh()` method re-fetches via `getById()` for callers outside this controller's own mutations — notably `PaymentController` (T038), since applying a payment changes `Sale.balance` through a different repository entirely ([contracts/pos-screen.md](./contracts/pos-screen.md) §3–§4) — depends on T010, T011
- [X] T013 Create `PosStepController` (`Notifier<PosStepState>`) in `lib/features/sales/presentation/pos_step_controller.dart` implementing the step machine from [contracts/pos-screen.md](./contracts/pos-screen.md) §2 — `venta`/`cobro`/`entrega` steps, the 2-vs-3-step shape driven by fulfilment mode, and the transition guards (≥1 line to confirm, balance-zero-or-netD to leave payment)
- [X] T014 Run `dart run build_runner build --delete-conflicting-outputs` to generate the riverpod companions for T012–T013
- [X] T015 Create `PosGateScreen` in `lib/features/sales/presentation/pos_gate_screen.dart` — watches `currentSessionControllerProvider` (**reused from 021-cash-sessions, not created here**); `state == none` renders the explanation and a link into `/sales/cash-sessions`; `state == open`/`stale` renders nothing itself (the caller proceeds) but exposes whether the session is stale for the caller's banner (FR-002a, FR-002b, [contracts/pos-screen.md](./contracts/pos-screen.md) §0)
- [X] T016 Add the `/sales/pos` route gated on `pos:read` to `lib/app/router/app_router.dart`, and a Point of Sale destination gated the same way to `lib/core/navigation/nav_destinations.dart`, appended at the end of `NavBranch` rather than renumbered into the sequence — matching 021's own precedent (research.md §14, §18; plan.md RBAC table — this is `pos`, not `salesOrders`) — depends on T012, T013, T015
- [X] T017 Create the `PosScreen` scaffold in `lib/features/sales/presentation/pos_screen.dart`: watches `currentSessionControllerProvider` first — `state == none` renders `PosGateScreen` (T015) and stops there, no `Sale` is touched; otherwise renders a header-band placeholder and a step host that switches on `PosStepController`'s current step with empty placeholders for each, plus a stale-session banner when applicable — depends on T015, T016
- [X] T018 [P] Unit test `PosStepController`'s transition guards in `test/unit/features/sales/pos_step_controller_test.dart`: 2 steps for counter pickup, 3 for delivery/mixed, confirm blocked with no lines, payment-step exit blocked above zero balance except on credit terms
- [X] T019 [P] Unit test the new generic decimal helpers added in T008 (not `countedTotal`/`expectedCash`, which 021's own test suite already covers) in `test/unit/features/sales/money_test.dart`
- [X] T020 [P] Widget test `PosGateScreen` in `test/widget/features/sales/pos_gate_screen_test.dart`: `state == none` shows the explanation and the link, no `Sale` is opened; `state == open` proceeds with no banner; `state == stale` proceeds with the banner shown

**Checkpoint**: The Point of Sale nav entry is reachable; with no cash session it shows the gate and opens no sale; with one, it creates a real sale and the empty step host renders. No capture, payment or delivery UI exists yet.

---

## Phase 3: User Story 1 — Sell across the counter and take the money (Priority: P1) 🎯 MVP

**Goal**: The complete two-step counter-sale flow: search/scan and capture lines
with warehouse, quantity, price, discount and tax; confirm; take one or more
payments to a zero balance; close.

**Independent Test**: Add two products, take a single cash payment for the full
amount, and confirm — the resulting order exists, is confirmed, carries both
lines and shows a zero balance (SC-001).

- [X] T021 [P] [US1] Pulled forward into T009 (SalesOrderRepository interface design required its return type) — created the `ProductLookupResult` and `WarehouseStock` entities in `lib/features/sales/domain/entities/product_lookup_result.dart` per [data-model.md](./data-model.md) §3
- [X] T022 [US1] Pulled forward into T010 (implemented alongside T009's interface) — `productLookup()` mapping on `SalesOrderRepository`/`SalesOrderRepositoryImpl`, returning `List<ProductLookupResult>` — depends on T021
- [X] T023 [P] [US1] Create `productLookupControllerProvider`, an autodispose family keyed by search text and warehouse, in `lib/features/sales/presentation/capture/product_lookup_controller.dart` — depends on T022
- [X] T024 [P] [US1] Create `ProductSearchField` in `lib/features/sales/presentation/capture/product_search_field.dart` — one field for scan and search, submits on Enter, keeps focus and clears after a successful add, shows a results list on multiple matches (FR-020, FR-021); owns its own `TextEditingController`/`FocusNode`, independent of `Sale` rebuilds, so an in-flight mutation elsewhere never drops keystrokes or steals focus (FR-010) — depends on T023
- [X] T025 [P] [US1] **Revised after a live-UI review 2026-08-05** — the first pass showed only an empty picker, leaving FR-011 unmet. Now shows the customer's name, credit line and price list via `saleCustomerControllerProvider`, and the **outstanding balance** summed from `GET /customer-payments/outstanding-orders?customer=` (`CustomerResponse` exposes no aggregate) — FR-011 fully met, no gap remaining. Create `CustomerBar` in `lib/features/sales/presentation/capture/customer_bar.dart` — walk-in customer preselected, shows name/credit line/balance/price list, offers search-a-different-customer via the existing catalog customer picker wired to `PosSaleController.updateHeader(customer: …)` (FR-011, FR-012), and an immediate/credit payment-terms toggle wired the same way, surfacing the server's refusal when the customer has no available credit line (FR-016). No special handling is needed for FR-015's repricing: the `updateHeader` response already carries every line re-priced, and `PosSaleController`'s normal wholesale replace picks it up automatically
- [X] T026 [US1] Create `FulfillmentModeSelector` in `lib/features/sales/presentation/capture/fulfillment_mode_selector.dart` — the three-chip Tienda/Domicilio/Mixta control (FR-017); in this phase only Tienda is wired to `PosSaleController.updateHeader`, Domicilio/Mixta are rendered but inert until US2 (T067) makes them functional
- [X] T027 [US1] **Revised after a live-UI review 2026-08-05** — the first pass put raw wire decimals (`3.0000`, `50.0000000`, `0.1600`) straight into the editable fields and omitted per-warehouse availability. Now formats via `formatQuantity`/`formatPrice`/`formatRateAsPercent` (rates display as the percentage their label claims, converted back on submit) and shows availability beside each warehouse in the picker. FR-022's **unit** column now renders too, from the expanded `unitOfMeasurement` ([mbe-api#145](https://github.com/mictlanix/mbe-api/issues/145), shipped) — symbol preferred over name, absent rather than a placeholder when a product has none. FR-022 fully met. Create `SaleLineRow` (expanded tier) in `lib/features/sales/presentation/capture/sale_line_row.dart` — product, warehouse picker with availability, quantity stepper, in-place price/discount/**tax rate** edit (FR-023, resolved — no field is read-only), line total, delete, and the non-blocking shortfall warning (FR-025, FR-026) — depends on T012
- [X] T028 [P] [US1] Create `SaleTotalsBar` in `lib/features/sales/presentation/capture/sale_totals_bar.dart` — line count, unit count, subtotal, discount, tax, grand total, all read from `Sale` (FR-028)
- [X] T029 [US1] Create `CaptureStep` in `lib/features/sales/presentation/capture/capture_step.dart` composing T024–T028: wires a selected search/scan result to `PosSaleController.addLine()`, defaulting `warehouse` to the cashier's point-of-sale warehouse (`UserSettings`) unless the cashier overrides it on the line afterward (FR-024), with "Continuar al cobro" enabled only once at least one line exists (FR-038) — depends on T024, T025, T026, T027, T028
- [X] T030 [US1] Wire `CaptureStep` into `PosScreen`'s step host in `lib/features/sales/presentation/pos_screen.dart`, replacing the T017 placeholder for the `venta` step — depends on T017, T029
- [X] T031 [US1] Wire "Continuar al cobro" to `PosSaleController.confirm()` and the `PosStepController` transition to `cobro`, rendering the two confirmation failure modes — zero-priced lines, insufficient stock — inline on the named offending lines while staying on the capture step (FR-039, [contracts/pos-screen.md](./contracts/pos-screen.md) §6); on success, every reference display (this screen's own header, and later `PosHeaderBand`, T087) MUST read `Sale.serial` once it is non-null instead of the provisional `Sale.id` (FR-040) — depends on T030
- [X] T032 [US1] Built into T025–T029 at creation time rather than retrofitted (each widget already takes an `enabled` param sourced from `Sale.isEditable` in `CaptureStep`) — derives each capture widget's enabled state from `Sale.isEditable` (data-model.md §1.1, [contracts/pos-screen.md](./contracts/pos-screen.md) §2 "Editability"): disable `SaleLineRow`'s (T027) in-place edits, `CustomerBar`'s (T025) customer-change and payment-terms controls, and `FulfillmentModeSelector` (T026) once the sale is confirmed, replacing them with an explanatory banner rather than offering an action the server will reject with 409 (FR-041) — depends on T025, T026, T027, T031
- [X] T033 [P] [US1] Create the `SalePayment` entity in `lib/features/sales/domain/entities/sale_payment.dart` per [data-model.md](./data-model.md) §7 — mapped from `OrderApplicationResponse`, not session state
- [X] T034 [US1] Create the `CustomerPaymentRepository` interface in `lib/features/sales/domain/repositories/customer_payment_repository.dart` — `createPayment()`, `applyPayment()`, `reverseApplication()`, `listForOrder()` per [contracts/mbe-api-pos.md](./contracts/mbe-api-pos.md) §1/§3 — depends on T033
- [X] T035 [US1] Implement `CustomerPaymentRepositoryImpl` in `lib/features/sales/data/customer_payment_repository_impl.dart` wrapping the generated `CustomerPaymentsApi` and `SalesOrdersApi.listSalesOrderPaymentsApiV1SalesOrdersSalesOrderIdPaymentsGet` — depends on T034
- [X] T036 [US1] Run `dart run build_runner build --delete-conflicting-outputs` to generate the freezed companions for T021, T033
- [X] T037 [P] [US1] Create the shared `NumberPad` widget in `lib/core/widgets/number_pad.dart` — 0–9, decimal point, backspace, fully keyboard-equivalent (FR-043). 021-cash-sessions built no equivalent (its denomination-count entry is a different shape), so this is new
- [X] T038 [US1] Create `PaymentController` (`Notifier<PaymentDraft>`) in `lib/features/sales/presentation/payment/payment_controller.dart` — amount entry, method selection, reference, and the add-payment sequence (create, then apply, per [contracts/mbe-api-pos.md](./contracts/mbe-api-pos.md) §3); after each successful application, calls `PosSaleController.refresh()` (T012) so `Sale.balance` updates, and invalidates `orderPaymentsControllerProvider` (T039) so the applied-payments panel reflects it too; computes change when the tender exceeds the balance (FR-047) — depends on T035, T012
- [X] T039 [P] [US1] Create `orderPaymentsControllerProvider`, an autodispose family keyed by sale id, in `lib/features/sales/presentation/payment/order_payments_controller.dart` — `CustomerPaymentRepository.listForOrder()`, **not session-scoped** (resolved, research §11) — depends on T035
- [X] T040 [P] [US1] Create `PaymentAmountField` with quick-amount chips ("Restante", fixed amounts, "Mitad") in `lib/features/sales/presentation/payment/payment_amount_field.dart` — depends on T037
- [X] T041 [P] [US1] Create `PaymentMethodGrid` in `lib/features/sales/presentation/payment/payment_method_grid.dart` — built from the facility's `PaymentMethodOption`s (T003), falling back to the shared `PaymentMethod` enum (`core/domain/payment_method.dart`, reused from 021) when none are configured, each tile reading `requiresReference` directly off the option — no client-side reference table exists
- [X] T042 [P] [US1] Create `AppliedPaymentsPanel` in `lib/features/sales/presentation/payment/applied_payments_panel.dart` — reads `orderPaymentsControllerProvider` (T039), lists applied payments with method/amount/reference/validation state, reversible with a mandatory reason (FR-048) — depends on T039
- [X] T043 [US1] Create `PaymentStep` in `lib/features/sales/presentation/payment/payment_step.dart` composing T038–T042: total/paid/balance header (FR-042), amount field, method grid, reference field, applied payments, and the close action gated on zero balance or credit terms (FR-049, FR-051) — depends on T038, T039, T040, T041, T042
- [X] T044 [US1] Wire `PaymentStep` into `PosScreen`'s step host for the `cobro` step; on close for a counter-pickup sale, show the change due and offer to start a new sale (FR-050) — depends on T030, T043
- [X] T045 [P] [US1] Add the Venta/Cobro `es-MX` strings (customer bar, payment-terms toggle, mode selector, search placeholder, line-grid headers, totals labels, payment step labels, quick amounts, method names, confirm-gate messages, the post-confirmation read-only banner) to `lib/l10n/app_es.arb`
- [X] T046 [P] [US1] Add the same keys with English wording and `@` metadata to `lib/l10n/app_en.arb`
- [X] T047 [US1] Run `flutter gen-l10n` — depends on T045, T046
- [X] T048 [P] [US1] Unit test `Sale`/`SaleLine` DTO-to-entity mapping in `test/unit/features/sales/sale_mapping_test.dart`
- [X] T049 [P] [US1] Widget test `SaleLineRow`'s in-place edit affordances, including the tax-rate field, and the shortfall warning in `test/widget/features/sales/sale_line_row_test.dart`
- [X] T050 [P] [US1] Widget test `PaymentStep`'s close gate — disabled above zero balance, enabled at zero once `PaymentController` has refreshed `Sale` (T038), the credit-terms exception (FR-051) — in `test/widget/features/sales/payment_step_gate_test.dart`
- [X] T051 [P] [US1] Widget test the step indicator shows exactly two steps for a counter-pickup sale in `test/widget/features/sales/step_indicator_test.dart`
- [X] T052 **Passed against a live mbe-api 2026-08-05** (SC-001 end-to-end: open → 2 lines → confirm/folio → cash payment → zero balance). Integration test the full counter-sale flow against a live mbe-api, discovering its fixtures at runtime (a real stockable product, a real customer, a real open cash session) rather than hardcoding ids, per [quickstart.md](./quickstart.md) Scenario 1, in `test/integration/pos_counter_sale_flow_test.dart`

**Checkpoint**: User Story 1 is fully functional and independently testable — the MVP.

---

## Phase 4: User Story 2 — Send the goods to one or more addresses (Priority: P2)

**Goal**: Delivery and mixed fulfilment: the main address at capture time, the
delivery step after payment, per-destination address/contact/date, per-line
quantity splitting, and the close gate. Every destination is created complete
in one call (resolved, research §3) — this phase adds no orchestrator.

**Independent Test**: Capture and pay a two-line sale in delivery mode, split one
line between two addresses, close the sale — two delivery records exist, one per
address, holding exactly the quantities entered (SC-005).

- [X] T053 [US2] Extend `Customer` in `lib/features/catalog/domain/entities/customer.dart` to map `.addresses: List<AddressListItem>` and `.contacts: List<ContactRef>` from the now-embedded `CustomerResponse` fields (research §9, §10, resolved)
- [X] T054 [US2] Extend `CustomerRepository`/`CustomerRepositoryImpl`'s `create()`/`update()` to accept `addresses: List<int>?`/`contacts: List<int>?` — replace-all semantics, omitted leaves links alone — per [contracts/mbe-api-pos.md](./contracts/mbe-api-pos.md) §4 — depends on T053
- [X] T055 [P] [US2] Create the `Contact` entity in `lib/features/catalog/domain/entities/contact.dart` per [data-model.md](./data-model.md) §5.2 — mirrors `AddressListItem`
- [X] T056 [US2] Create the `ContactRepository` interface in `lib/features/catalog/domain/repositories/contact_repository.dart` — `list()`, `create()` only, mirroring `AddressRepository`'s deliberately-not-full-CRUD shape — depends on T055
- [X] T057 [US2] Implement `ContactRepositoryImpl` in `lib/features/catalog/data/contact_repository_impl.dart` wrapping the generated `ContactsApi` — depends on T056
- [X] T058 [US2] Create `contact_inline_create.dart` in `lib/features/catalog/presentation/contact_inline_create.dart` mirroring `address_inline_create.dart` — a dialog capturing name/phone/mobile/email — depends on T057
- [X] T059 [US2] Run `dart run build_runner build --delete-conflicting-outputs` to generate the freezed companions for T053 (Customer), T055 (Contact)
- [X] T060 [P] [US2] Create the `Destination` entity in `lib/features/sales/domain/entities/destination.dart` per [data-model.md](./data-model.md) §5 — `contact: int?` plus `contactName`/`contactPhone` joined for display, not comment-encoded
- [X] T061 [P] [US2] Create the `DestinationLine` entity in `lib/features/sales/domain/entities/destination_line.dart` per [data-model.md](./data-model.md) §5.1
- [X] T062 [P] [US2] Create the `LineDistribution` view model in `lib/features/sales/domain/entities/line_distribution.dart` per [data-model.md](./data-model.md) §6 (revised) — `perDestination` read directly from each already-created `Destination.lines`, plus `draftQuantity` for the destination currently being edited, `atCounter`, `isComplete`; a pure function, no server round trip
- [X] T063 [US2] Run `dart run build_runner build --delete-conflicting-outputs` to generate the freezed companions for T060–T062
- [X] T064 [US2] Unit test the distribution arithmetic — Σ`perDestination` + `draftQuantity` + `atCounter` == `ordered`, for every line — in `test/unit/features/sales/line_distribution_test.dart`. This replaces the prior revision's `destination_split_test.dart`: there is no multi-call sequencing left to test, only the arithmetic — depends on T062
- [X] T065 [US2] Create the `DeliveryOrderRepository` interface in `lib/features/sales/domain/repositories/delivery_order_repository.dart` — `create({salesOrder, fulfillmentType, shipTo, contact, date, comment, lines})` accepting the full distribution in one call, `updateHeader()`, `updateLine()`, `removeLine()` (for post-creation edits only) per [contracts/mbe-api-pos.md](./contracts/mbe-api-pos.md) §2 — depends on T060, T061
- [X] T066 [US2] Two spec assumptions failed against the live API and were filed as [mbe-api#146](https://github.com/mictlanix/mbe-api/issues/146) (no header on create) and [#147](https://github.com/mictlanix/mbe-api/issues/147) (no `sales_order` link); a third, [#149](https://github.com/mictlanix/mbe-api/issues/149), had `POST /delivery-orders` 500ing on every request. **All three shipped**, so the interim create-then-PUT rollback and the line-id reconstruction were both removed — a destination is now created complete in one call and found by its sale. Implement `DeliveryOrderRepositoryImpl` in `lib/features/sales/data/delivery_order_repository_impl.dart` wrapping the generated `DeliveryOrdersApi`, passing `contact` as a real id — **no comment-encoding stopgap** (resolved, research §10) — depends on T065
- [X] T067 [US2] Fully wire `FulfillmentModeSelector` (T026): selecting Domicilio or Mixta first checks the selected customer's `shipping` flag and refuses with the reason shown when not permitted (FR-019); otherwise requires naming the sale's main delivery address, picked from `Customer.addresses` (T053) or created inline via `showAddressInlineCreateDialog` and linked via `CustomerRepository.update` (T054) — no more global-search fallback (resolved, research §9) — writing the chosen address through `PosSaleController.updateHeader(shipTo: …)` (FR-056, research §4) — depends on T026, T053, T054
- [X] T068 [US2] Already satisfied by T013 — `PosStepState.stepCount` derives from `mode`, so setting a non-counter-pickup mode inserts `entrega` with no further change. Extend `PosStepController` (T013) so a mode other than counter pickup inserts the `entrega` step and updates the step count (FR-005, FR-018) — depends on T067
- [X] T069 [US2] Create `DeliveryController` (`AsyncNotifier<List<Destination>>`) in `lib/features/sales/presentation/delivery/delivery_controller.dart` — loads existing destinations on entry (the resume case); `addDestination()` is a single `DeliveryOrderRepository.create()` call carrying the full line distribution, no trim step; recomputes `LineDistribution` after each write (FR-030) — depends on T064 (test exists first), T066
- [X] T070 [US2] Run `dart run build_runner build --delete-conflicting-outputs` to generate the riverpod companion for T069
- [X] T071 [P] [US2] Create `DestinationCard` in `lib/features/sales/presentation/delivery/destination_card.dart` — address, contact, date, line/unit counts, edit/remove (FR-029)
- [X] T072 [P] [US2] Create `DestinationEditor` in `lib/features/sales/presentation/delivery/destination_editor.dart` — address picker (`Customer.addresses` or inline-create), **contact picker** (`Customer.contacts` or T058's inline-create dialog — a real `Contact`, not free-text name/phone fields), delivery date, per-line quantity inputs that refuse to exceed what remains undistributed (FR-031, FR-032) — depends on T058
- [X] T073 [P] [US2] Create `LineDistributionPanel` in `lib/features/sales/presentation/delivery/line_distribution_panel.dart` — per line: ordered, assigned per destination, at counter, and the running distributed/total count (FR-033)
- [X] T074 [US2] Create `DeliveryStep` in `lib/features/sales/presentation/delivery/delivery_step.dart` composing T071–T073, with the mode-specific close gate: mixed sweeps the remainder as a `COUNTER_PICKUP` destination with `lines` omitted (FR-036), pure delivery blocks and names the unassigned units (FR-035) — depends on T069, T071, T072, T073
- [X] T075 [US2] Wire `DeliveryStep` into `PosScreen`'s step host, opening after payment for delivery/mixed sales, with per-destination failure isolation — a refused create leaves that destination's editor open with the server's line/shortfall message and every other, already-created destination untouched (FR-037) — depends on T044, T074
- [X] T076 [US2] Extend the resume logic (T030/T044) so a paid sale with an incomplete distribution reopens directly on `entrega`, per [contracts/pos-screen.md](./contracts/pos-screen.md) §5 — depends on T075
- [X] T077 [P] [US2] Add the Entrega `es-MX` strings (destination card, editor fields incl. the contact picker, distribution panel, close-gate messages, the shipping-not-permitted refusal from T067) to `lib/l10n/app_es.arb`
- [X] T078 [P] [US2] Add the same keys with English wording to `lib/l10n/app_en.arb`
- [X] T079 [US2] Run `flutter gen-l10n` — depends on T077, T078
- [X] T080 [P] [US2] Widget test that a destination the server refuses (over-claim, duplicate line, foreign line) shows the server's own message inline and leaves every other already-created destination unaffected (FR-037) in `test/widget/features/sales/destination_editor_error_test.dart`
- [X] T081 [US2] **Passing against a live mbe-api 2026-08-05** — SC-005 verified server-side after mbe-api#146/#147/#149 all shipped. Run the POS live tests with `-j 1`: they commit stock against the same dataset and race otherwise. Integration test a delivery split across two addresses plus a mixed-mode remainder, asserting server-side that each line's quantities across delivery orders sum to its ordered quantity (SC-005), per [quickstart.md](./quickstart.md) Scenarios 2–3, in `test/integration/pos_delivery_split_flow_test.dart`

**Checkpoint**: User Stories 1 and 2 both independently functional.

---

## Phase 5: User Story 3 — Pick up a sale that was left open (Priority: P2)

**Goal**: The open-sales selector, scoped to this register, and resuming a sale
at whichever step its server-side state implies — including a paid,
delivery/mixed sale whose distribution is still incomplete (FR-058).

**Independent Test**: Start a sale with two lines, leave the screen, reopen the
point of sale and select the earlier sale from the selector — both lines and the
selected customer are still there (SC-004).

- [ ] T082 [P] [US3] Create the `OpenSale` entity in `lib/features/sales/domain/entities/open_sale.dart` per [data-model.md](./data-model.md) §8
- [ ] T083 [US3] Extend `SalesOrderRepository`/`SalesOrderRepositoryImpl` with `listOpen({status})` — `pointSale: <the cashier's point of sale>` plus `status` per [research.md](./research.md) §5 (resolved — was `facility` + `mine=true`), covering all three reachable open statuses: `draft`, `completed`, and `paid` for a delivery/mixed sale awaiting distribution (FR-058) — depends on T082
- [ ] T084 [US3] Run `dart run build_runner build --delete-conflicting-outputs` to generate the freezed companion for T082
- [ ] T085 [US3] Create `openSalesControllerProvider` (autodispose `AsyncNotifier<List<OpenSale>>`) in `lib/features/sales/presentation/open_sales_selector_controller.dart` — three calls, `draft`, `completed` and `paid` (the last filtered client-side to sales whose `LineDistribution` is incomplete, since mbe-api cannot filter on that server-side), invalidated after a confirm, after a payment closes a delivery/mixed sale, and after a new sale starts (FR-058) — depends on T083
- [ ] T086 [US3] Create `OpenSalesSelector` in `lib/features/sales/presentation/open_sales_selector.dart` — reference, customer, total, newest first (US3 scenario 1) — depends on T085
- [ ] T087 [US3] Create `PosHeaderBand` in `lib/features/sales/presentation/pos_header_band.dart` composing `OpenSalesSelector`, the step indicator, and the stale-session banner (T015/T017) directly beneath the app bar (research.md §13, spec.md FR-004), reading `Sale.serial ?? Sale.id` for the reference chip so it reflects the same provisional→folio swap as T031 (FR-040), superseding the T017 placeholder — depends on T086
- [ ] T088 [US3] Wire `PosHeaderBand` into `pos_screen.dart` — depends on T087
- [ ] T089 [US3] Selecting a sale loads it (`GET`) and resolves the entry step from `status` and `shipTo` — draft → Venta, completed → Cobro, paid-and-undistributed → Entrega, per [contracts/pos-screen.md](./contracts/pos-screen.md) §5; "start a new sale" opens a fresh draft alongside it (US3 scenario 3) — depends on T088
- [ ] T090 [US3] Abandoning an open sale with no lines cancels it via the sales order cancel endpoint rather than leaving an empty open sale behind (US3 scenario 6 / Edge Cases) — depends on T089
- [ ] T091 [P] [US3] Unit test the status/`shipTo` → entry-step resolution in `test/unit/features/sales/open_sale_resolution_test.dart`
- [ ] T092 [P] [US3] Widget test `OpenSalesSelector` renders open sales — including a paid, undistributed delivery sale (FR-058) — and restores a selected sale's customer/lines/mode in `test/widget/features/sales/open_sales_selector_test.dart`
- [ ] T093 [US3] Integration test interrupting and resuming at each reachable step — draft, completed-unpaid, paid-undistributed — per [quickstart.md](./quickstart.md) Scenario 4, in `test/integration/pos_resume_flow_test.dart`

**Checkpoint**: User Stories 1, 2 and 3 all independently functional.

---

## Phase 6: User Story 4 — Register a customer without losing the sale (Priority: P3)

**Goal**: Create a customer from the sale without discarding what has been
captured, and attach it immediately.

**Independent Test**: From an open sale, create a customer through the inline
form and confirm the sale is now attached to that customer with their price list
applied to subsequently added lines.

- [ ] T094 [US4] Create `customer_inline_create.dart` in `lib/features/sales/presentation/customer_inline_create.dart` wrapping the existing `lib/features/catalog/presentation/customer_form_controller.dart` behind a dialog (≥ 600 px) / full-screen route (< 600 px), per FR-013 and A-002 (the cashier types the code)
- [ ] T095 [US4] Wire `CustomerBar`'s "create customer" affordance (T025) to open the dialog and, on save, attach the new customer via `PosSaleController.updateHeader(customer: …)` (FR-014) — same automatic repricing-via-wholesale-replace as T025's customer-switch path, no special handling — depends on T094
- [ ] T096 [P] [US4] Add the customer-inline-create strings to `lib/l10n/app_es.arb` and `lib/l10n/app_en.arb`; run `flutter gen-l10n`
- [ ] T097 [P] [US4] Widget test that creating a customer attaches it to the sale (FR-014) and that its line list reflects whatever `Sale` the fake repository returns after the header update — the general server-truth-reflection behavior FR-015 relies on (no separate notice; repricing already shows up automatically) — in `test/widget/features/sales/customer_inline_create_test.dart`

**Checkpoint**: User Stories 1 through 4 all independently functional.

---

## Phase 7: User Story 5 — Work the counter from a phone (Priority: P3)

**Goal**: Every step usable at 390 px with no horizontal scroll — single-column
lines, a collapsed stepper, and a pinned bottom action — for **all five**
journeys, not only the counter sale (SC-007).

**Independent Test**: Drive the complete counter-sale story at 390 px wide
without horizontal scrolling and with every control reachable (SC-007).

- [ ] T098 [P] [US5] Create `SaleLineCard` (compact tier) in `lib/features/sales/presentation/capture/sale_line_card.dart`
- [ ] T099 [US5] Switch `CaptureStep` between `SaleLineRow` (≥ 600 px) and `SaleLineCard` (< 600 px) via the central breakpoints, pinning `SaleTotalsBar` and the primary action to the bottom (FR-053) — depends on T029, T098
- [ ] T100 [US5] Collapse `PosHeaderBand`'s stepper to a "Paso N de M" label and the selector to a compact chip below 600 px — depends on T087
- [ ] T101 [US5] Verify/adjust `PaymentStep`'s compact layout so amount entry, quick amounts, the method grid and applied payments are all reachable by vertical scroll alone, reusing `NumberPad` as-is — depends on T043
- [ ] T102 [US5] Verify/adjust `DeliveryStep`'s compact layout as stacked expandable destination cards — depends on T074
- [ ] T103 [P] [US5] Widget test the complete counter-sale journey at 390 px renders with zero horizontal scroll and every control reachable, in `test/widget/features/sales/pos_compact_layout_test.dart` — depends on T099, T100, T101
- [ ] T104 [P] [US5] Widget test the delivery-mode journey (US2) at 390 px — mode selection, the main-address requirement, destination cards, the editor (incl. the contact picker) and the distribution panel all reachable by vertical scroll alone with zero horizontal scroll (SC-007) — in `test/widget/features/sales/pos_compact_delivery_test.dart` — depends on T102
- [ ] T105 [P] [US5] Widget test resuming an open sale and creating a customer inline (US3, US4) at 390 px, confirming both are reachable with zero horizontal scroll (SC-007) — in `test/widget/features/sales/pos_compact_resume_and_customer_test.dart` — depends on T089, T094

**Checkpoint**: All five user stories independently functional, at every supported width.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Confirm no superseded workaround remains anywhere, and verify the
whole feature once more as a whole.

- [ ] T106 [P] Audit `lib/features/sales/`, `lib/features/catalog/` and this spec's own documents for any remaining reference to a superseded workaround — comment-encoded destination contact, session-scoped payment list, create-then-trim sequencing, a client-side payment-method-reference table — and remove it; none should exist after Phases 2–7, but this is the check that confirms it
- [ ] T107 Re-verify codegen parity one final time against the exact mbe-api revision this feature ships against
- [ ] T108 [P] Accessibility pass: tooltip or semantic label on every icon-only control across the gate, capture, payment and delivery steps
- [ ] T109 `flutter analyze` across `lib/features/sales/` and the `lib/features/catalog/` additions with zero warnings
- [ ] T110 Run the complete [quickstart.md](./quickstart.md) scenario set manually against a live mbe-api, including a real cash session as a precondition, and record the results
- [ ] T111 Run the full automated suite — unit, widget and integration — and confirm green

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: no dependencies — start immediately
- **Foundational (Phase 2)**: depends on Setup — **blocks all user stories**. Includes the cash-session gate, which every subsequent phase's "sale exists" assumption depends on.
- **User Stories (Phase 3–7)**: all depend on Foundational
  - US1 (P1) has no dependency on any other story
  - US2 (P2) extends `FulfillmentModeSelector` (T026) and `PosStepController` (T013) from US1, and its `PosScreen` wiring (T075) depends on US1's payment wiring (T044). It also opens with six catalog-layer tasks (T053–T059) with no story dependency of their own — genuinely prerequisite to the rest of the phase, not merely first in file order.
  - US3 (P2) can start once Foundational is done; its header-band wiring (T087/T088) supersedes the US1/Foundational placeholder, and its own resume-step resolution (T089) builds on the delivery-incomplete case US2 already extended (T076) — build after US1+US2 for a working resume target, though its own tasks touch no US1/US2 file
  - US4 (P3) depends only on US1's `CustomerBar` (T025)
  - US5 (P3) depends on US1's `CaptureStep`/`PaymentStep`, US2's `DeliveryStep`, and US3's `PosHeaderBand`/resume logic existing to restyle and re-test at compact width
- **Polish (Phase 8)**: depends on every user story that will ship

### Within Each User Story

- Entities before repositories before controllers before widgets before step composition before wiring into `PosScreen`
- The riskiest logic is tested before it is wired to UI: T064 (distribution arithmetic) before T069 (the controller that uses it) — a much smaller risk than the prior revision's create-then-trim orchestrator, since there is no multi-call sequencing left to get wrong
- l10n keys are added and generated before the widgets that reference them are wired into the step host
- Integration tests come last in each phase — they exercise the whole story against a live server

### Parallel Opportunities

- T005–T007 (foundational entities) — different files, no dependency on each other
- T018, T019 — independent unit tests, once T013/T008 exist
- Within US1: T021, T025, T028, T033, T037 — independent files
- Within US1's test batch: T048–T051 — independent files
- Within US2: T055 (Contact) is independent of T053–T054 (Customer extension) despite both being catalog work; T060–T062 — independent files; T071–T073 — independent widgets once T069 exists
- US4 and US5 can proceed in parallel once US1–US3 are done, since neither depends on the other

---

## Implementation Strategy

### MVP First

Phases 1–3 (Setup, Foundational, US1) are the deliverable minimum: a cashier
with an open cash session can capture a counter sale and take payment to a
zero balance. This matches the spec's own P1 designation and SC-001 — and,
new in this revision, SC-010 (no sale opens without a session).

### Incremental Delivery

1. Setup + Foundational + US1 → **MVP**, demoable and independently testable
2. + US2 → delivery and mixed fulfilment, with no orchestrator to get wrong
3. + US3 → interrupted sales are recoverable, closing the live-recording promise
4. + US4 → inline customer creation
5. + US5 → compact tier, tested across all five journeys
6. Phase 8 → final consistency audit, full suite green

Each checkpoint above is a shippable increment; nothing later in the list is
required for an earlier increment to work correctly on its own.
