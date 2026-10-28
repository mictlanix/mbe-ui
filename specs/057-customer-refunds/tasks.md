---
description: "Task list for 057-customer-refunds"
---

# Tasks: Customer Refunds

**Input**: Design documents from `specs/057-customer-refunds/`

**Prerequisites**: plan.md, spec.md, research.md (R1–R12), data-model.md, contracts/ui-contracts.md (C1–C8), quickstart.md, wireframes.md (its Open Questions are answered in contracts C8)

**Tests**: The spec doesn't ask for a test suite as such, but the constitution's quality gates and research R12 require tests. Test tasks sit inside each story, after the code they cover.

**Organization**: Grouped by user story (US1–US3, spec.md). US1 is the MVP and carries the detail screen. US2 adds the list and cancel on top of it. US3 is blocked on mbe-api#287.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: parallelizable (different files, no dependency on an incomplete task)
- **[Story]**: US1 refund returned goods from a paid order · US2 find, resume and cancel refunds · US3 print a refund receipt

## Cross-story notes

- **Shared files.** Do these sequentially, not in parallel:
  - `lib/features/sales/presentation/refunds/refund_detail_screen.dart`: US1 (T015), then US2 (T032), then US3 (T045).
  - `lib/features/sales/presentation/refunds/refund_editor_controller.dart`: US1 (T012), then US2 (T032).
  - `lib/app/router/app_router.dart`: US1 (T016, the detail route and the gate), then US2 (T031, the list branch).
  - `lib/features/sales/data/credit_note_repository_impl.dart` and its interface: US1 only (T013).
  - `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb`: every key is added once, in T003. If a later task needs another, add it there and run `flutter gen-l10n`. Never hand-edit `lib/l10n/app_localizations*.dart`.
- **Generated code.** After editing a freezed or `@riverpod` file, run `dart run build_runner build --delete-conflicting-outputs` at the repo root. Never run two build_runner processes at once: tasks that both need it are not marked [P] against each other. No client regeneration is needed for US1 and US2: `CustomerRefundsApi`, `RefundPayout` and `CustomerRefundConfirm` already exist in `lib/generated/openapi`. US3 does need one, through `tool/generate_api_client.sh`, once mbe-api#287 ships.
- **Formatting.** Format only the files you changed (`dart format <files>`). Never `dart format .`, and never format `lib/generated/`.
- **Amounts and dates** go through `formattersProvider` (constitution §V). No `NumberFormat`, no `toStringAsFixed`. Amount arithmetic goes only through `features/sales/domain/money.dart`.
- **Spacing tokens, not literals** (`Theme.of(context).spacing`). No automated guard catches a literal, so check it in review.
- **The app never computes a total or a refundable quantity (FR-006).** Every write replaces the whole refund with the server's response.
- **Interim code carries a marker.** Each gets a comment `// simplified: <ceiling>, <what to do when it binds>`:
  - the per-row customer name in the list (T027, until mbe-api#284);
  - `findByRefund` (T013, until mbe-api#286).
- **Never match server prose** (R3). Classify refusals from the order's own status. A server detail may be shown, never parsed.
- **Mirror, don't copy blindly.** Closest precedents:
  - Detail screen with its own route: `payment_detail_screen.dart`.
  - List screen, filter and paging: `credit_notes_list_screen.dart`, `credit_notes_list_controller.dart`, `credit_notes_filter.dart`.
  - Line stepper and warehouse tap-field: `capture/sale_line_editing.dart`, `delivery/destination_card.dart`.
  - Serialized writes: `tracked_editing.dart`, `orders/order_editor_controller.dart`.
  - Cash-session check: `PaymentController._sessionIsValid` and `PosSessionBlockedBanner`.
  - Repository and its test: `credit_note_repository_impl.dart` and its `_test.dart`.
  - Widget harness: `pos_test_harness.dart`, `order_workspace_cancel_test.dart`, `payment_detail_screen_test.dart`.

---

## Phase 1: Setup

**Purpose**: a known-good baseline, so later failures are attributable.

- [ ] T001 Run `flutter analyze` and the existing tests this feature touches: `test/**/credit_notes*_test.dart`, `test/widget/features/sales/pos_sale_detail_view_test.dart`, `test/widget/features/sales/order_workspace_*_test.dart`, `test/unit/app/router/app_router_test.dart`, `test/unit/core/navigation/nav_destinations_test.dart`, `test/unit/core/formatting_guard_test.dart`. Note any pre-existing failures so they aren't blamed on this feature. The six failures in `test/golden/core_widgets_golden_test.dart` are already known.

---

## Phase 2: Foundational (blocks every story)

**Purpose**: the entities, repository, wire format, strings and test fixtures every story uses.

- [ ] T002 [P] Create the freezed entities in `lib/features/sales/domain/entities/customer_refund.dart` (data-model): `CustomerRefund`, `RefundLine`, `CustomerRefundSummary`, `RefundStatus`, `RefundPayout`, `RefundOutcome`, `RefundRefusal`. Add `fromResponse` mappers from `api.CustomerRefundResponse`, `api.CustomerRefundLineResponse` and `api.CustomerRefundSummary`. Keep amounts and quantities as the server's strings. Map `api.DocumentStatus.paid` to `RefundStatus.completed`. Add `isDraft` and `hasReturn` (any line quantity above zero, using `isZeroAmount` from `money.dart`). Run build_runner.
- [ ] T003 [P] Add every l10n key from contracts C3 to C7 to `lib/l10n/app_en.arb` (the template, with `@key` descriptions) and `lib/l10n/app_es.arb`, using the Spanish copy in the contracts and wireframes. That covers the menu title, list columns and facets, the new-refund dialog, the four refusals, the detail labels, the confirm dialog, the cancel prompt, the session banner, the payout lines, the adjustment banner and the edit-without-confirm hint. Run `flutter gen-l10n`.
- [ ] T004 Add a `Quantity3` setter to `lib/features/sales/data/wire_value_setters.dart`, one small setter in the style of the existing ones, which sends a quantity through the `AnyOf` String arm (R4).
- [ ] T005 Create `CustomerRefundRepository` and `RefundListResult` in `lib/features/sales/domain/repositories/customer_refund_repository.dart` (contracts C2), and the implementation in `lib/features/sales/data/customer_refund_repository_impl.dart` with `customerRefundRepositoryProvider`. Wrap `api.CustomerRefundsApi(dio, appSerializers)` and map errors with `mapDioException`. A null `response.data` throws `const AppError.server()`. `list` sends `customer`, `sales_order`, `status` (`draft`, `completed` or `cancelled`), `skip` and `limit`. `updateLine` builds a `CustomerRefundLineUpdate` using T004. `confirm` sends `CustomerRefundConfirm(payout)`. Depends on T002 and T004.
- [ ] T006 Add test fixtures to `test/widget/features/sales/pos_test_harness.dart`: `MockCustomerRefundRepository`, `customerRefundOverride`, and `testRefund` and `testRefundLine` builders, following the existing mocks and `testSale`. Depends on T002 and T005.
- [ ] T007 [P] Repository tests in `test/unit/features/sales/customer_refund_repository_impl_test.dart`, using the `_FakeHttpClientAdapter` pattern. Cover:
  - `list` sends the filters and paging as given, and sends no `status` when the filter is null.
  - `open` sends `sales_order`.
  - `updateLine` sends `quantity` as a string and omits an unset `warehouse`.
  - `confirm` sends the payout's wire value.
  - A null body gives `AppError.server`, and a 404 gives `NotFoundError`.
  Depends on T005.
- [ ] T008 [P] Entity test in `test/unit/features/sales/customer_refund_entity_test.dart`: `fromResponse` carries totals and quantities exactly as the server sent them, `paid` maps to `completed`, `hasReturn` is false for `"0"` and `"0.000000"` and true once any line is above zero, and a null customer and null serial survive the mapping. Depends on T002.

**Checkpoint**: the app can read and write refunds. Nothing is visible yet.

---

## Phase 3: User Story 1 — Refund returned goods from a paid order (P1)

**Story goal**: "Devolver" on a paid order opens (or resumes) a refund. The clerk sets return quantities and warehouses, confirms with cash or a credit note, and sees a read-only refund showing how the money went back.

**Independent test**: with an open cash session, take a paid order, tap "Devolver", return part of one line, confirm as cash, and check the refund is completed with a folio. Repeat on another order as a credit note and check the payout line shows the note number (quickstart steps 1–3 and 5–7).

- [ ] T009 [US1] Create `lib/features/sales/presentation/refunds/refund_open_or_resume.dart` with `openOrResume(WidgetRef ref, int salesOrderId)` returning `RefundOpened(refundId, resumed)` or `RefundRefused(RefundRefusal, serverDetail?)` (R2, R3, contracts C3):
  1. List the order's drafts: `list(salesOrderId: id, status: draft, limit: 1)`. A hit returns `RefundOpened(resumed: true)`.
  2. Otherwise read the order through `SalesOrderRepository.getById`. A `NotFoundError` gives `orderNotFound`. A draft or cancelled order gives `notCompleted`. A completed order that is not `paid` gives `notPaid`.
  3. Otherwise `open(id)`. A 409 gives `nothingToReturn` with the server's detail attached. Any other `AppError` is rethrown.
  Depends on T005.
- [ ] T010 [P] [US1] Create `lib/features/sales/presentation/refunds/refund_confirm_dialog.dart` (contracts C5): a `ResponsiveDialog` showing "Se devolverán {total} al cliente." through `fmt.display.currency`, with two `RadioListTile`s, none selected (keys `refund_payout_cash`, `refund_payout_credit_note`). Its confirm button is disabled until one is chosen. It returns the chosen `RefundPayout?`. Depends on T002 and T003.
- [ ] T011 [P] [US1] Create `lib/features/sales/presentation/refunds/refund_outcome_provider.dart`: `refundOutcomeProvider(CustomerRefund)`, a `FutureProvider.family` returning `RefundOutcome` (R6). A draft or cancelled refund gives no outcome. A refund with no customer gives `unknown`. Otherwise it asks `findByRefund` and gives `creditNote(note)`, `cash` when no note is found, or `unknown` when the lookup throws. Mark it `// simplified: scans the customer's notes; replace with the refund's own payout fields when mbe-api#286 ships`. Run build_runner. Depends on T013.
- [ ] T012 [US1] Create `lib/features/sales/presentation/refunds/refund_editor_controller.dart`, an `AsyncNotifier` family keyed by refund id (R4, R5):
  - `build` loads the refund through `getById`.
  - `setQuantity(lineId, quantity)` and `setWarehouse(lineId, warehouseId)` each call `updateLine` and publish the response as the new state. Run them under `tracked()` with write scope `customer-refund`, one at a time per refund. A refused write rethrows its `AppError` to the caller so the line can show it, and leaves the state unchanged.
  - `confirm(RefundPayout)` first refreshes `currentSessionControllerProvider`. `none` or `stale` returns a `sessionInvalid` result carrying the stale session's id, without calling the repository. Otherwise it captures the entered quantities, calls `confirm`, publishes the response, and sets an `adjusted` flag when any line is lower or missing compared to what was captured (FR-011). After a network `AppError` it re-reads the refund and publishes it before rethrowing, so a refund that went through isn't confirmed twice.
  Depends on T005. Run build_runner.
- [ ] T013 [US1] Add `findByRefund({required int customerId, required int refundId, required DateTime refundDate})` returning `Future<CreditNote?>` to `lib/features/sales/domain/repositories/credit_note_repository.dart`, and implement it in `lib/features/sales/data/credit_note_repository_impl.dart` (R6). Page `GET /credit-notes?customer=<id>` newest first. Stop at the first note whose `customerRefundId == refundId` and return it. Stop and return null at a page whose oldest note is dated before `refundDate`, or at the end of the list. Mark it `// simplified: scans the customer's notes; replace with the refund's own payout fields when mbe-api#286 ships`.
- [ ] T014 [P] [US1] Create the `RefundLineBlock` widget used on compact screens in `lib/features/sales/presentation/refunds/refund_line_block.dart` (contracts C8): product, price · Por devolver, then the stepper, the warehouse tap-field and the total, built from `CompactField`s. It takes the same callbacks as a table row, so T015 uses one set of handlers for both layouts. Depends on T002.
- [ ] T015 [US1] Create `lib/features/sales/presentation/refunds/refund_detail_screen.dart` (contracts C5, wireframes), taking `refundId`:
  - **Loading and errors:** a progress indicator while loading, "No existe la devolución {id}." with a Back button for a 404, and an `ErrorBanner` with Reintentar otherwise.
  - **Header:** a `FactStripRow` of `CompactField`s: folio or "Borrador", date, customer through `PaymentCustomerName`, the order as a link through `orderLinkTargetProvider`, and a `StatusChip<RefundStatus>`.
  - **Lines:** a `DataTableView<RefundLine>`, or `RefundLineBlock`s below the compact breakpoint (T014). On a draft with update access, Devolver is a `QuantityStepper` (`min: 0`, `max: refundableQuantity`, key `refund_line_qty_<lineId>`) and Almacén is a tap-field (key `refund_line_warehouse_<lineId>`) opening `showWarehousePicker` with `facilityWarehousesControllerProvider(refund.facilityId)`. A refused write shows its `serverMessage` under that line, and the warehouse picker is re-keyed so it shows the accepted value. Without update access, or once confirmed, both are plain text.
  - **Totals:** subtotal, tax and total, straight from the server.
  - **Confirm:** "Confirmar devolución" (key `refund_confirm_button`) shown only on a draft with `can(customerRefundConfirm, update)` and `hasReturn`. It runs `controller.confirm` after the dialog (T010). On `sessionInvalid` it shows the banner (key `refund_session_banner`) with a button to `/sales/cash-sessions`, or to `/sales/cash-sessions/{id}` for a stale session. With update access but no confirm access, it shows the hint (key `refund_needs_confirmer_hint`) instead of the button.
  - **Completed:** the "Devuelto" column in place of Devolver and "Por dev.", the payout line (key `refund_payout_line`) from `refundOutcomeProvider` with a link to `/sales/payments/{customerPaymentId}` when the user has `can(customerPayments, read)`, and the adjustment banner (key `refund_adjusted_banner`) when the controller's `adjusted` flag is set.
  - **Cancelled:** the read-only layout with the "Cancelada" chip and no actions.
  Actions sit in the body, not the app bar (§VI). Depends on T010–T014.
- [ ] T016 [US1] In `lib/app/router/app_router.dart`, add the top-level full-screen route `/sales/refunds/:refundId` (using `int.tryParse`, like `/sales/payments/:paymentId` at around line 515) opening `RefundDetailScreen`, and a `_routeGate` clause for the `/sales/refunds` prefix returning `PrivilegeGate(SystemObject.customerRefunds, AccessRight.read)` (contracts C1). The list branch comes in T031. Depends on T015.
- [ ] T017 [US1] Add the "Devolver" button (key `order_refund_button`) to `OrderHeaderPanel`'s trailing `Wrap`, next to "Ver pedido", in `lib/features/sales/presentation/orders/order_header_panel.dart` (R9, contracts C3). Shown only when `sale.isPaid && can(customerRefunds, create) && can(customerRefunds, read)`, otherwise not built. A tap shows a spinner, runs `openOrResume`, and on `RefundOpened` pushes `/sales/refunds/{id}`. On `RefundRefused` it shows a SnackBar with the matching refusal copy, followed by the server detail for `nothingToReturn`. Depends on T009, T003 and T016.
- [ ] T018 [US1] Add the same button (same key, same rules) to `_Facts` in `lib/features/sales/presentation/pos_sale_detail_view.dart`, next to the ticket button. To avoid writing the tap handler twice, put the shared "tap → openOrResume → navigate or SnackBar" logic in `refund_open_or_resume.dart` as `startRefundFromOrder(BuildContext, WidgetRef, int orderId)` and have both T017 and T018 call it. Depends on T009 and T016.
- [ ] T019 [P] [US1] Unit tests for `openOrResume` in `test/unit/features/sales/refund_open_or_resume_test.dart`: an existing draft resumes without a POST; no draft and a completed, paid order opens a new refund; a draft order gives `notCompleted`; a completed but unpaid order gives `notPaid`; a 404 on the order gives `orderNotFound`; a 409 on the POST gives `nothingToReturn` with the server's detail; any other error is rethrown. Depends on T009.
- [ ] T020 [P] [US1] Controller tests in `test/unit/features/sales/refund_editor_controller_test.dart`: a quantity write publishes the server's totals; two quick writes run one after the other; a refused write rethrows and leaves the state unchanged; confirm with no session, or a stale one, returns `sessionInvalid` and never calls the repository; confirm sets `adjusted` when the response lowers or drops a line, and not otherwise; a network error during confirm re-reads the refund, and a refund that came back completed is published as completed. Depends on T012.
- [ ] T021 [P] [US1] Tests for `findByRefund` and the outcome provider, in `test/unit/features/sales/credit_note_repository_impl_test.dart` (extended) and `test/unit/features/sales/refund_outcome_provider_test.dart`: a match on page 1 stops without reading page 2; a page ending before the refund's date stops and gives null; the end of the list gives null; the provider maps a match to `creditNote`, no match to `cash`, no customer to `unknown`, a thrown error to `unknown`, and a draft to no outcome. Depends on T011 and T013.
- [ ] T022 [US1] Widget tests: `test/widget/features/sales/refund_detail_screen_test.dart` covering a draft with update and confirm access (steppers live, confirm shown only once a line is above zero), update without confirm (the hint, no button), no update access (plain text, no actions), the session banner for none and for stale, a completed refund (payout line for cash, credit note and unknown; the adjustment banner), a cancelled refund, a 404, and the compact layout; `test/widget/features/sales/refund_confirm_dialog_test.dart` (nothing selected and confirm disabled until a choice, then each choice returns its payout). Depends on T015.
- [ ] T023 [US1] Widget tests for the "Devolver" button in `test/widget/features/sales/order_header_refund_button_test.dart` and an extension of `test/widget/features/sales/pos_sale_detail_view_test.dart`: shown for a paid order with create and read access; hidden for an unpaid order, a missing create privilege and a missing read privilege; a tap navigates on `RefundOpened` and shows the refusal SnackBar otherwise. Depends on T017 and T018.
- [ ] T024 [US1] In `test/unit/app/router/app_router_test.dart`, add cases for `/sales/refunds/:refundId`: a user without `customerRefunds` read is redirected, a user with it reaches the screen, and a non-numeric id gives the not-found state. Depends on T016. (The stubbed repository for the eager detail load follows the existing note on needing one, or a real request leaves a timer pending.)
- [ ] T025 [US1] Create `integration_test/customer_refunds_quickstart_test.dart`, modelled on `credit_notes_quickstart_test.dart` (R12): discover a paid order with returnable lines at runtime, skip with `markTestSkipped` when the tenant has none or the admin credentials are missing, then walk quickstart steps 1–3 and 5 (open, resume, quantity cap, session gate), and always cancel the draft it opened in a `tearDown` so the tenant is left as it was. Steps 6–7 (confirm as cash, confirm as credit note) run only behind `--dart-define=MBE_REFUND_CONFIRM=1`. Depends on T017.

**Checkpoint**: US1 works end to end against mocks, and against the dev tenant (quickstart steps 1–3 and 5–7).

---

## Phase 4: User Story 2 — Find, resume and cancel refunds (P2)

**Story goal**: "Devoluciones" lists refunds with status, customer and order filters. A clerk can start a refund from an order number, open any refund, and cancel one that isn't confirmed. Credit notes link back to their refund.

**Independent test**: open a refund and leave it, confirm another, find both in Devoluciones by order number and status, and cancel the open one (quickstart steps 8–10).

- [ ] T026 [P] [US2] Create `lib/features/sales/presentation/refunds/refunds_filter.dart` (data-model): a freezed `RefundsFilter{status, customerId, salesOrderId, pageIndex}` with `fromQuery(ListQuery)` reading the facets `status`, `customer` and `order`, plus `activeFilterCount` and `isNarrowed`, mirroring `credit_notes_filter.dart`. Run build_runner. Depends on T002.
- [ ] T027 [US2] Create `lib/features/sales/presentation/refunds/refunds_list_controller.dart`, a `@riverpod` family keyed by the filter with a page size of 20 (R8). When `can(customerRefunds, read)` is false, return an empty `CatalogPage` without a request. Otherwise call `fetchClampedPage` over `customerRefundRepositoryProvider.list`. Run build_runner. Depends on T005 and T026.
- [ ] T028 [US2] Create `lib/features/sales/presentation/refunds/refunds_list_screen.dart` (contracts C4, wireframes), taking `ListQuery query`:
  - **Header:** `CatalogFilterBar` with the badge and tune icon, opening `showCatalogFilterSheet` with the Estado `SegmentedButton`, `CatalogEntityPicker<CustomerListItem>` and the Pedido number field. Each change writes its facet with `withFacet` and resets the page to 0. The "Nueva devolución" button (key `refunds_new_button`) goes in the trailing slot, only with `can(customerRefunds, create)`.
  - **Table:** `DataTableView<CustomerRefundSummary>` with `CatalogPagination`. Columns: Folio (or "—"), Fecha (or "—"), Cliente through `PaymentCustomerName(customerId:, name: null)` (mark it `// simplified: one lookup per distinct customer; map customer_display_name when mbe-api#284 ships`), Pedido as a link through `orderLinkTargetProvider`, Estado as a `StatusChip<RefundStatus>`, and Total right-aligned and untruncated. A null customer shows "—". A row tap pushes `/sales/refunds/{id}`. No row Edit icon.
  - **Compact:** Folio · Pedido (with a status dot) · Total, and "Nueva" for the button (contracts C8).
  - **States:** `CatalogListStateView` for empty, filtered-empty, retry, and a 403 shown as forbidden without retry.
  - **New-refund dialog** (key `refund_new_order_input` for the field): a `ResponsiveDialog` with an order number field. Enter submits it and runs `openOrResume`. On `RefundOpened` it closes and pushes the refund. On `RefundRefused` it shows the matching copy inline, with the server detail under `nothingToReturn`, and stays open.
  Depends on T009, T026, T027 and T003.
- [ ] T029 [US2] Add the nav entry in `lib/core/navigation/nav_destinations.dart`: `NavBranch.customerRefunds = 24` and an entry in the `sales` group right after `credit-notes`, with `id: 'refunds'`, label `refundsMenuTitle`, icon `Icons.assignment_return_outlined`, and a gate of `customerRefunds` read (contracts C1). Depends on T003.
- [ ] T030 [P] [US2] In `lib/features/sales/presentation/credit_notes/credit_notes_list_screen.dart`, split the origin string at both `#{refund}` and `#{order}` in `_OriginCell` and render two `WidgetSpan` links (R11, contracts C6). The refund link has key `credit_note_refund_link_<id>`, is shown only with `can(customerRefunds, read)`, and pushes `/sales/refunds/{id}`. The order link and its key are unchanged. Update the doc comment that says refunds have no screen yet.
- [ ] T031 [US2] In `lib/app/router/app_router.dart`, append the shell branch for `/sales/refunds` at index 24, opening `RefundsListScreen(query: ListQuery.fromUri(state.uri))`. The branch is appended last and never inserted, since indexes are positional. Depends on T028 and T029. (T016 already added the detail route and the gate.)
- [ ] T032 [US2] Add cancel. In `refund_editor_controller.dart`, add `cancel()`, which calls `cancel` and publishes the response, under `tracked()`. In `refund_detail_screen.dart`, add "Cancelar devolución" (key `refund_cancel_button`) on a draft with `can(customerRefunds, update)`, which asks first with an `AlertDialog` (wireframes) and then calls `cancel()`. A completed or cancelled refund shows no cancel (FR-012). Depends on T012 and T015.
- [ ] T033 [P] [US2] Unit tests: `test/unit/features/sales/refunds_filter_test.dart` (the `ListQuery` round trip, `activeFilterCount`, `isNarrowed`) and `test/unit/features/sales/refunds_list_controller_test.dart` (the filters reach the repository, an empty page without a request when read access is missing, the page clamps). Depends on T026 and T027.
- [ ] T034 [US2] Widget tests: `test/widget/features/sales/refunds_list_screen_test.dart` (columns and "—" for drafts; each facet narrows the list and resets the page; empty, filtered-empty, forbidden and error states; "Nueva devolución" hidden without create and, with it, the dialog opens a refund, resumes one, and shows each refusal inline; a row tap navigates; the compact columns); extend `refund_detail_screen_test.dart` with cancel (shown on a draft with update access only; the prompt, then the cancelled state; absent on completed and cancelled). Depends on T028 and T032.
- [ ] T035 [P] [US2] Extend the credit-notes list widget test with the refund link: the refund segment is a link when the user has `customerRefunds` read and plain text otherwise, a tap pushes `/sales/refunds/{id}`, and the order link still works. Depends on T030.
- [ ] T036 [US2] Update `test/unit/app/router/app_router_test.dart` and `test/unit/core/navigation/nav_destinations_test.dart`: the branch is at index 24, the gate redirects a user without read access, and the nav entry shows only with read access and sits right after Notas de crédito. The router test needs a stubbed repository for the eager list screen. Depends on T029 and T031.
- [ ] T037 [US2] Extend `integration_test/customer_refunds_quickstart_test.dart` with quickstart steps 4 and 8–10: the unpaid-order and draft-order refusals in the new-refund dialog, cancelling a draft, the list filters, and the no-access account (`qanoaccess`) finding no nav entry, a redirect from `/sales/refunds`, and no "Devolver". Depends on T031, T032 and T025.

**Checkpoint**: US2 works end to end (quickstart steps 4 and 8–10).

---

## Phase 5: User Story 3 — Print a refund receipt (P3)

**Story goal**: a confirmed refund prints a receipt, which for a credit note shows the note's ticket number.

**Blocked on mbe-api#287.** Do not start until the receipt endpoint ships. No code is written against an endpoint that doesn't exist (R10, Clarifications).

**Independent test**: confirm a refund as a credit note for the walk-in customer, print it, and redeem the note at the POS payment step with the number on the receipt (quickstart, once added).

- [ ] T038 [US3] Gate check. Confirm mbe-api#287 is closed and its endpoint is in the running API's OpenAPI. If not, stop here and leave T039–T044 unchecked. Then regenerate the client with `tool/generate_api_client.sh`, and confirm `CustomerRefundsApi` now has a ticket method. Commit the regenerated client on its own, as past specs did (`Generated api client code updated`).
- [ ] T039 [US3] Add `DocumentKind.customerRefundReceipt(SystemObject.customerRefunds)` in `lib/core/documents/domain/document_kind.dart`, its switch arm in `lib/core/documents/data/document_source_impl.dart` calling the new generated method, and the fallback filename `devolucion-{serial}.pdf` (R10). Depends on T038.
- [ ] T040 [US3] In `refund_detail_screen.dart`, add the "Imprimir" `OutlinedButton.icon` (key `refund_print_button`), right-aligned on the payout row, on a completed refund only, through `documentActionsProvider` and gated by `canOpenDocument` (FR-018). Follow `payment_detail_screen.dart:281-299`. Open and cancelled refunds show no print action. Depends on T039 and T015.
- [ ] T041 [P] [US3] Tests: extend the documents tests for the new kind (the switch arm, the fallback filename, the `%PDF-` check), and extend `refund_detail_screen_test.dart` so the print button shows on a completed refund with the right access and not on open, cancelled or access-less views. Depends on T040.
- [ ] T042 [US3] Add a step to `integration_test/customer_refunds_quickstart_test.dart`, behind `MBE_REFUND_CONFIRM=1`: after confirming, open the receipt through the document actions and check that it is a PDF. Add the matching step to `quickstart.md` ("Not covered yet" becomes a numbered step), and confirm the walk-in redemption by the printed number in a manual pass. Depends on T040.

**Checkpoint**: US3 works end to end (printing).

---

## Phase 6: Polish and cross-cutting

- [ ] T043 Run `flutter analyze` (must be clean), `dart format` on only the changed files, and the full set of tests this feature touched plus `test/unit/core/formatting_guard_test.dart`. Check by eye that no spacing literal, no `NumberFormat` and no `toStringAsFixed` was added, and that no string is hard-coded outside `.arb`. Re-check the compact layouts of the list and the detail at the largest text size.
- [ ] T044 Write `specs/057-customer-refunds/pr-description.md`. Under "Roadmap": `Closes mictlanix/mbe-roadmap#29` if US3 shipped, otherwise `Part of mictlanix/mbe-roadmap#29` with a line saying printing waits for mbe-api#287. List the four upstream issues and what each interim marker stands in for, so reviewers know what to remove when they ship. Add the "Where this changes existing behaviour" notes: the new button on the order header and POS detail, and the refund link in Notas de crédito. Use `gh api -X PATCH` to edit the PR body if `gh pr edit` fails on the Projects-classic error.

---

## Dependencies and order

```text
Phase 1 (T001) ─▶ Phase 2 (T002–T008) ─▶ US1 (T009–T025) ─▶ US2 (T026–T037) ─▶ Phase 6
                                                              └──▶ US3 (T038–T042, blocked on mbe-api#287) ─▶ T043–T044
```

- **US1 before US2.** The list opens the detail screen and uses `openOrResume`, and cancel is an edit to the US1 controller and screen.
- **US2's tasks T026, T030 and T033** don't depend on each other and can start together once Phase 2 is done.
- **US3** is independent of US2, and only needs the detail screen from US1.
- **Within US1,** T010, T011 and T014 are independent files, and can be done in parallel after T002. T012 needs T005. T013 must be done before T011, though its number is higher.

### Parallel examples

- **After Phase 2:** T010, T014 and (once T013 is done) T011.
- **After T015:** T019, T020 and T021 (three different test files).
- **In US2:** T026 and T030, then T033 and T035 once their code exists.

## Implementation strategy

**MVP: User Story 1 alone** (T001–T025). It delivers the whole refund flow from a paid order, including confirm as cash or credit note, and it can ship without the list.

**Increments:**
1. Phase 2 and US1, which is the MVP.
2. US2, adding Devoluciones, cancel and the credit-notes link. Releasable on its own as the roadmap close if printing is deferred, as `Part of mictlanix/mbe-roadmap#29`.
3. US3 as a follow-up PR when mbe-api#287 ships, which then closes the issue.
