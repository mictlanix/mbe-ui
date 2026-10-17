---

description: "Task list for POS Sales Fixes"
---

# Tasks: POS Sales Fixes

**Input**: Design documents from `/specs/047-pos-sales-fixes/`

**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/ui-contracts.md](./contracts/ui-contracts.md), [quickstart.md](./quickstart.md)

**Tests**: Included. The plan's quality gates and the constitution call for unit and widget tests, and §VI requires measuring tests for any change to the sale-line band.

**Organization**: Tasks are grouped by user story. Paths are relative to the repository root. `P` is the plan's section number; `R#` and `C#` refer to [research.md](./research.md) and [contracts/ui-contracts.md](./contracts/ui-contracts.md).

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependency on an unfinished task)
- **[Story]**: The user story the task belongs to (US1–US6)

## Path Conventions

Flutter, feature-first. Source is under `lib/features/sales/presentation/` (shortened to `sales/presentation/` below), tests are under `test/unit/` and `test/widget/features/sales/`.

---

## Phase 1: Setup

**Purpose**: Establish a clean baseline before changing anything.

- [ ] T001 Run `flutter analyze` and `flutter test test/unit/features/sales test/widget/features/sales` on the branch, and record any pre-existing failures in a comment on this task so they are not mistaken for regressions (research R9 notes stale failure images in `test/golden/failures`)

---

## Phase 2: Foundational (blocking prerequisites)

**Purpose**: Shared pieces that more than one story needs. Nothing below starts until these are done.

- [ ] T002 Add all new strings to both `lib/l10n/app_es.arb` and `lib/l10n/app_en.arb`, following the existing `pos*` key naming, then regenerate `lib/l10n/app_localizations*.dart` (do not hand-edit them). Keys:
  - `posSessionExpiredRedirect`
  - `posSessionExpiredPaymentsBlocked`
  - `posSessionCloseAction` ("Cerrar sesión")
  - `posCaptureShortLines(count)` ("{count} partidas sin existencia suficiente")
  - `posWarehousePickerTitle`
  - `posPaymentAmountRequired`
  - `posPaymentOverpayNonCash` ("Solo el efectivo puede exceder el saldo")
  - `posPaymentChangeDue` ("Cambio a entregar")
  - `posPaymentReferenceTitle`
  - `posPaymentReferenceConfirm`
  - `posPaymentDismissChange`
  - `posPaymentSessionInvalid`
- [ ] T003 [P] Add an `isValid` getter (`state == SessionState.open`) to `CurrentSession` in `lib/features/sales/domain/entities/current_session.dart`, and regenerate the freezed output if the entity is generated (data-model, CurrentSession)
- [ ] T004 [P] Add a `/sales/cash-sessions/:cashSessionId` stub route to `pumpPosRouted` in `test/widget/features/sales/pos_test_harness.dart`, so tests can assert a redirect landed there (research R9)
- [ ] T005 Replace the cache value with `ProductStock` in `lib/features/sales/presentation/capture/product_stock_cache.dart`: a type with `stockable`, `stockRequired`, `warehouses` and a derived `checked` (`stockable && stockRequired`); change `productStockCacheProvider` to `Map<int, ProductStock>`. Update the readers in `capture/sale_line_editing.dart` (`_stockIn`, `_stockLevelIn`, `shortfall`) and the seeding in `capture/capture_step.dart:148-152` to the new type, **keeping behavior identical** (data-model, ProductStock). Used by US3 and US4.
- [ ] T006 Run the existing sales tests to confirm T005 changed no behavior: `flutter test test/widget/features/sales test/unit/features/sales`

**Checkpoint**: Strings, the session getter, the harness stub and the typed stock cache are in place.

---

## Phase 3: User Story 1 - Selling requires a valid cash session (Priority: P1)

**Goal**: No sale starts, and no payment is applied, without an open session. A stale session redirects to its close screen.

**Independent Test**: With a stale session, tap *New sale* and land on that session's close screen. Close it and open a new one, and sales work again (quickstart scenarios 1–3).

### Tests for User Story 1

- [ ] T007 [P] [US1] Extend `test/widget/features/sales/pos_sales_list_screen_test.dart`: with `stale`, tapping *New sale* re-reads the session and lands on `/sales/cash-sessions/<id>` with the redirect snackbar; with `none`, the button is disabled; with `open`, it opens `/sales/pos/new`; a session that turns stale between render and tap is caught by the re-read (C1)
- [ ] T008 [P] [US1] Extend `test/widget/features/sales/pos_workspace_route_test.dart`: `/sales/pos/new` under `stale` redirects to the close screen and creates no sale; `/sales/pos/:saleId` under `stale` and `none` still renders the sale (C2)
- [ ] T009 [P] [US1] Extend `test/widget/features/sales/pos_gate_screen_test.dart`: under `stale` the payment step shows `pos_session_blocked_banner` and `pos_session_blocked_action` (to the close screen), and under `none` the action goes to `/sales/cash-sessions` (C2)

### Implementation for User Story 1

- [ ] T010 [US1] In `lib/features/sales/presentation/pos_sales_list_screen.dart` (around lines 95-136 and 288-315): enable *New sale* for `open` and `stale`, keep it disabled for `none`. On tap, `await ref.refresh(currentSessionControllerProvider.future)`, then push `/sales/pos/new` for `open`, `go` to `/sales/cash-sessions/<cashSessionId>` plus the `posSessionExpiredRedirect` snackbar for `stale`, and the existing `none` message for `none` (C1, R1, R2)
- [ ] T011 [US1] In `lib/features/sales/presentation/pos_workspace_screen.dart` (around lines 51-74 and 362): when the route is `/new` and the state is `stale`, replace the route with the close screen and show the same snackbar before any `ensureOpen` runs. Narrow the full-screen `PosGateScreen` swap at lines 52-56 to the `/new` route (`saleId == null`): under `none`, `/sales/pos/new` keeps the full-screen gate, but `/sales/pos/:saleId` renders the sale, with payments blocked by T012/T013 (FR-004, C2, R2)
- [ ] T012 [US1] In `lib/features/sales/presentation/pos_gate_screen.dart`: replace `_StaleSessionBanner` with a blocking banner (`pos_session_blocked_banner`) and an action button (`pos_session_blocked_action`) that navigates to the stale session's close screen, or to `/sales/cash-sessions` for `none` (C2)
- [ ] T013 [US1] In `lib/features/sales/presentation/payment/payment_step.dart` and `payment/payment_method_grid.dart`: show the blocking banner on the payment step and disable the method tiles while the session is not `open`, and show the `posPaymentSessionInvalid` message when `PaymentDraft.error` is `sessionInvalid` (set by T014) (C2, C6). *Coordinate with T034, which changes the same tiles; do this task first.*
- [ ] T014 [US1] In `lib/features/sales/presentation/payment/payment_controller.dart`: before creating a payment, re-read the session with `ref.refresh(currentSessionControllerProvider.future)`. When it is not `open`, set `PaymentDraft.error` to a new `sessionInvalid` value and return without any API call (FR-005, R1). This is the guard for a session that expires or is closed after the screen was rendered. Cover it in a new `payment_controller_test` case in `test/unit/features/sales/payment_controller_test.dart`

**Checkpoint**: Story 1 works on its own. It is the first deliverable together with US2.

---

## Phase 4: User Story 2 - Label filter in Advanced search works (Priority: P1)

**Goal**: Selected labels, the other facets and the search term survive each filter change, however the screen was opened.

**Independent Test**: From a sale, open Advanced search, type a term, pick two labels, toggle *stockable*. Everything is kept (quickstart scenario 4).

### Tests for User Story 2

- [ ] T015 [P] [US2] Create `test/unit/core/navigation/list_query_test.dart`: `currentRouteUri` returns the pushed route's URI when the top match is an `ImperativeRouteMatch`, and `currentConfiguration.uri` otherwise (C3)
- [ ] T016 [P] [US2] Extend `test/widget/features/sales/advanced_search_screen_test.dart`: using the existing `/host` plus `router.push` variant (around line 158), select three labels one after the other, toggle *stockable*, and assert all three still show as selected, the term is kept, and `ProductFilter` sent all three (SC-003). Also deselect one label and assert only that one is removed. This test must **fail before T017**

### Implementation for User Story 2

- [ ] T017 [US2] In `lib/core/navigation/list_query.dart` (lines 150-165): add `Uri currentRouteUri(GoRouter router)` that returns the top-most match's URI (an `ImperativeRouteMatch`'s own `matches.uri`, else `currentConfiguration.uri`), and make `CurrentListQueryBuilder` use it (C3, R3)
- [ ] T018 [US2] Run the other 14 `CurrentListQueryBuilder` screens' tests (the list-screen widget tests under `test/widget/features/`) to confirm no `go`-reached screen changed behavior. If the `ImperativeRouteMatch` lookup proves fragile, fall back to passing `widget.query` into the panel in `sales/presentation/capture/advanced_search_screen.dart:137-142` (research R3, alternatives)

**Checkpoint**: Stories 1 and 2 are both done and can ship as the P1 release.

---

## Phase 5: User Story 3 - Sale lines cannot exceed available stock (Priority: P2)

**Goal**: *Continue* is blocked while a draft sale has a short stock-tracked line. Unknown stock only warns, and nothing overrides the block.

**Independent Test**: Set a quantity above what the warehouse has, confirm Continue is blocked with a reason, then fix it by lowering the quantity or switching warehouse (quickstart scenarios 5–6).

### Tests for User Story 3

- [ ] T019 [P] [US3] Create `test/unit/features/sales/stock_gate_test.dart` for `evaluateStock`:
  - a single short line, and an exact fit (not short);
  - two lines of the same product and warehouse that are short together;
  - the same product in two warehouses, each judged separately;
  - a product with `checked == false` is never short;
  - a product with no cache entry goes into `unknownLineIds` and does not block;
  - a non-draft sale never blocks;
  - there is no override input (data-model, Stock gate)
- [ ] T020 [P] [US3] Create `test/widget/features/sales/capture_step_gate_test.dart`: *Continue* is disabled with `capture_continue_blocked_reason` while a line is short, becomes enabled after lowering the quantity or switching warehouse, and is enabled when stock is unknown. A resumed sale's stock is loaded, so the gate still blocks (FR-008, FR-010)

### Implementation for User Story 3

- [ ] T021 [P] [US3] Create `lib/features/sales/presentation/capture/stock_gate.dart` with `StockGate` (`shortLineIds`, `unknownLineIds`, `blocks`) and `StockGate evaluateStock(Sale sale, Map<int, ProductStock> cache)`, implemented per the data-model rules and R5
- [ ] T022 [US3] Add `ensureStockFor(Sale sale)` to the stock cache notifier in `capture/product_stock_cache.dart`: for each distinct product on the sale without a cache entry, call `productLookup(pattern: line.productCode, customer: sale.customer)` concurrently, keep the row whose `product` matches, and leave a failed or missing product uncached (R4, Q1). **Known limitation, do not work around it:** per mbe-api#208, a 13-digit `code` with no matching barcode returns an empty lookup, so such products stay "unknown" on a resumed sale and the gate does not apply to them. Add a code comment citing #208. Seed the new `ProductStock` fields from the lookup in `_addLine` (`capture/capture_step.dart:148-152`)
- [ ] T023 [US3] In `capture/capture_step.dart`: call `ensureStockFor` when the step opens for a sale (including a resumed one, not only on `_addLine`), watch the cache, and compute `evaluateStock`. Set `SaleTotalsBar.onContinue` to `null` while `gate.blocks` (around lines 438-444), and show `capture_continue_blocked_reason` with `posCaptureShortLines(count)` (C4)
- [ ] T024 [US3] In `capture/sale_line_editing.dart`: make the per-line short indicator and `shortfall()` agree with `evaluateStock` (so a line is marked short exactly when it blocks), keeping the existing "unknown" flag for `unknownLineIds` (C4). Do not cap the quantity field (the note at lines 52-56 stays)

**Checkpoint**: Story 3 works with the existing dropdown. Stories 1–3 are independent of US4–US6.

---

## Phase 6: User Story 4 - Warehouse selector as a pop-up (Priority: P2)

**Goal**: Tapping a line's warehouse opens a readable pop-up with full names, stock and the current choice marked.

**Independent Test**: Open the selector on a line and pick another warehouse. At 390 px there is no horizontal scroll (quickstart scenario 7).

### Tests for User Story 4

- [ ] T025 [P] [US4] Create `test/widget/features/sales/warehouse_picker_dialog_test.dart`: rows show the full name, stock (or "unknown") and the short/no-stock indicator for the given quantity; the current warehouse shows `Icons.check`; picking returns the id; cancel returns `null`; at a 390 px surface there is no horizontal scroll (`expectNoHorizontalScroll` from the harness) (C5)
- [ ] T026 [P] [US4] Extend `test/widget/features/sales/sale_line_row_test.dart` and `test/widget/features/sales/sale_line_symmetry_test.dart`: tapping `sale_line_warehouse_<lineId>` opens `warehouse_picker_dialog`, picking a row updates the line, the field does nothing on a non-editable sale, and the line band's measured height and baseline are unchanged (§VI)

### Implementation for User Story 4

- [ ] T027 [P] [US4] Create `lib/features/sales/presentation/capture/warehouse_picker_dialog.dart` with `Future<int?> showWarehousePicker(BuildContext, {required List<Warehouse> warehouses, required int? selected, required ProductStock? stock, required Decimal quantity})`: an `AlertDialog` built like `showCustomerAddressPicker` (width cap 480, list height cap 320, 16 px inset on compact), rows keyed `warehouse_option_<id>`, dialog keyed `warehouse_picker_dialog` (R6, C5)
- [ ] T028 [US4] Replace `warehousePicker()` in `capture/sale_line_editing.dart:337-391` (and the stock-flag helpers at 405-445 as needed) with an `InputDecorator`-styled tap field keyed `sale_line_warehouse_<lineId>` that shows the name and stock flag and opens `showWarehousePicker`. Ignore a `null` result or the current id. Make it inert when the line is not editable. Keep the field inside the existing `saleLineRowHeight` band
- [ ] T029 [US4] Update the wiring in `capture/sale_line_row.dart:233-236` (and the single-row and two-row bands) and `capture/sale_line_card.dart:198` for the new field. Then run `flutter test test/widget/features/sales/sale_line_symmetry_test.dart` and the compact tests to confirm alignment and no overflow at the largest text size (§V, §VI)

**Checkpoint**: Stories 3 and 4 together give the full stock workflow (see a short line, open the pop-up, fix it).

---

## Phase 7: User Story 5 - Payment is applied when the method is chosen (Priority: P2)

**Goal**: Tapping a method applies the payment immediately. The *Apply payment* button is removed.

**Independent Test**: With a balance of 100, enter 60 and tap *Efectivo*: 60 is applied and the amount becomes 40 (quickstart scenario 8).

### Tests for User Story 5

- [ ] T030 [P] [US5] Extend `test/unit/features/sales/payment_controller_test.dart` for `tender`:
  - applies at once for a method without a reference;
  - ignores a second tap while `submitting`;
  - rejects an empty or zero amount with `amountRequired` and makes no API call;
  - for `requiresReference`, applies nothing until a reference is supplied and nothing on cancel;
  - after success the amount is the new balance (pre-fill), and the method is not kept selected;
  - on an `AppError` the draft keeps its amount and sets `error`
- [ ] T031 [P] [US5] Update `test/widget/features/sales/payment_step_gate_test.dart`, `payment_step_layout_test.dart`, `payment_capture_pane_reflow_test.dart`, `payment_method_grid_test.dart` and `pos_compact_layout_test.dart` (lines 227-290): there is no `payment_submit_button`, tapping a tile applies the payment, the amount field is pre-filled with the balance, and the reference dialog (`payment_reference_dialog`, `payment_reference_input`, `payment_reference_confirm`) appears for a reference method. Compact (390 px) shows no horizontal scroll

### Implementation for User Story 5

- [ ] T032 [US5] In `sales/presentation/payment/payment_controller.dart`: add `tender(Sale sale, PaymentMethodOption option)`. It ignores the tap while `submitting`, validates the amount (`amountRequired`), re-checks the session (T014), and, for `requiresReference`, returns a request so the UI collects the reference before the existing submit pipeline runs (confirm draft → create → apply → refresh). After success, set the amount to the new remaining balance instead of `''`. Remove the persistent method selection (`methodCode`, `paymentCharge`, `requiresReference` live only for one call) (R7, data-model). Pre-fill the amount with the balance when the step opens (FR-016)
- [ ] T033 [P] [US5] Create `payment/payment_reference_dialog.dart`: a small dialog with one field (`payment_reference_input`), confirm (`payment_reference_confirm`) and cancel, returning the reference or `null` (C6)
- [ ] T034 [US5] In `payment/payment_method_grid.dart` (lines 38-88): make each tile's `onTap` call `tender`, show the reference dialog when asked, drop the "selected" visual state, and disable tiles while `submitting` or while the session is invalid (C6). This includes the fallback cash/credit/debit/eft tiles at lines 58-72
- [ ] T035 [US5] In `payment/payment_capture_pane.dart`: remove `payment_submit_button` (lines 161-171) and the inline `payment_reference_field` (151-159); seed the amount field from the pre-filled draft amount (lines 40-49 and 92-94) (C6)
- [ ] T036 [US5] Run the payment and compact tests from T031 and fix layout fallout. Confirm the number pad and quick chips (`Restante`, notes, half) still work and reflow correctly at 390 px

**Checkpoint**: Story 5 works. It builds on T014 for the session guard.

---

## Phase 8: User Story 6 - Cash overpayment and change (Priority: P2)

**Goal**: Only cash may exceed the balance, and the change due stays visible after the payment.

**Independent Test**: A balance of 87.50 paid with 100 in cash shows a change card of 12.50. The same overpayment by card is refused (quickstart scenarios 9–10).

*Depends on Story 5: it extends `tender`.*

### Tests for User Story 6

- [ ] T037 [P] [US6] Extend `test/unit/features/sales/payment_controller_test.dart`:
  - a cash overpayment applies only the balance, sends `amountChange`, and sets `lastChange`;
  - a non-cash overpayment is refused with `overpayNonCash` and makes no API call;
  - a cash payment at or below the balance leaves `lastChange` null;
  - `lastChange` is cleared by the next `tender`
- [ ] T038 [P] [US6] Create `test/widget/features/sales/payment_change_card_test.dart`: `payment_change_card` shows the amount from `formattersProvider` after a cash overpayment and stays until `payment_change_dismiss` is tapped, and the summary's live "Cambio" row still previews while typing. Extend `payment_summary_panel_test.dart` if its layout changes

### Implementation for User Story 6

- [ ] T039 [US6] In `payment/payment_controller.dart`: add `lastChange` to `PaymentDraft`. In `tender`, refuse a non-cash method whose amount exceeds the balance with `overpayNonCash` before any API call (cash is identified by `PaymentMethod.cash`). After a cash payment with change > 0, set `lastChange`; clear it on dismiss, on the next `tender`, and when the step is left (R8, data-model)
- [ ] T040 [P] [US6] Create `payment/payment_change_card.dart`: a card keyed `payment_change_card` with the `posPaymentChangeDue` label, the amount in a large display style via `formattersProvider` (no `NumberFormat` or `toStringAsFixed`, §V), and a dismiss button `payment_change_dismiss` (C7)
- [ ] T041 [US6] In `payment/payment_step.dart` (and `payment_summary_panel.dart` if needed): render the change card above the summary while `lastChange != null`, show the `posPaymentOverpayNonCash` and `posPaymentAmountRequired` errors, and keep the summary's live "Cambio" row as the preview (C7, FR-020)

**Checkpoint**: All six stories work.

---

## Phase 9: Polish & Cross-Cutting

**Purpose**: Regressions, goldens and end-to-end checks across stories.

- [ ] T042 [P] Update the POS integration tests that go through the payment step so they tap a method instead of pressing apply: `test/integration/pos_counter_sale_flow_test.dart`, `pos_delivery_split_flow_test.dart`, `pos_resume_flow_test.dart`
- [ ] T043 Regenerate the POS goldens and screenshots (`test/golden/pos_capture_golden_test.dart`, `test/screenshots/pos_screens_screenshot_test.dart`) with `--update-goldens`, review every diff, and delete stale failure images only after reviewing them
- [ ] T044 [P] Verify the largest text-size level and the 390 px compact surface for the capture and payment steps (§V, §VI): no clipping or horizontal scroll
- [ ] T045 [P] Run `flutter test test/unit/core/formatting_guard_test.dart` to confirm the change card and any new amount displays use `formattersProvider`
- [ ] T046 Run `flutter analyze` and the full test suite, then walk through every scenario in [quickstart.md](./quickstart.md) against a live mbe-api, including checking the session's cash cut after scenario 9. Also resume a sale holding a product with a 13-digit code (mbe-api#208) and confirm its line shows "unknown stock" and does not block, as documented in T022
- [ ] T047 Update `specs/047-pos-sales-fixes/spec.md` status to Implemented when everything passes

---

## Dependencies & Execution Order

### Phase dependencies

- **Setup (Phase 1)** → **Foundational (Phase 2)** → user stories. T005 and T006 block US3 and US4. T002 blocks every story that shows text. T004 blocks US1 tests.
- **US1 and US2** are the P1 pair and have no dependency on each other.
- **US3** needs T005. **US4** needs T005 and is independent of US3 apart from sharing `sale_line_editing.dart`.
- **US5** needs T014 (the session guard) because `tender` reuses it, and T013 must land before T034 (same tiles).
- **US6** needs US5 (it extends `tender`).
- **Polish** needs every story you intend to ship.

### Story dependency graph

```text
Foundational ─┬─ US1 ──────────────┐
              ├─ US2               │
              ├─ US3 ─ (US4 shares sale_line_editing.dart; do US3 first)
              ├─ US4
              └─ US1.T014 ─ US5 ─ US6
```

### File-overlap warnings (do not run these in parallel)

- `capture/sale_line_editing.dart`: T005, T024, T028
- `payment/payment_controller.dart`: T014, T032, T039
- `payment/payment_method_grid.dart`: T013, T034
- `payment/payment_step.dart`: T013, T041
- `capture/capture_step.dart`: T005, T022, T023
- `lib/l10n/*.arb`: T002 only. Add any missing key there rather than in a story phase

### Parallel opportunities

- Foundational: T003 and T004 together.
- US1 tests T007, T008, T009 together. US2 tests T015 and T016 together.
- US3 tests T019 and T020 and the pure function T021 together.
- US4 tests T025, T026 and the dialog T027 together.
- US5 tests T030, T031 and the dialog T033 together. US6 tests T037, T038 and the card T040 together.
- With two developers: one takes US1 + US5 + US6 (payment side), the other takes US2 + US3 + US4 (capture side).

---

## Implementation Strategy

### MVP first (the P1 pair)

1. Phases 1–2 (setup and foundations).
2. US1 and US2.
3. Validate with quickstart scenarios 1–4, then ship. The two P1 fixes are a financial control and a functional bug.

### Incremental delivery

1. Add US3 + US4 (the stock workflow). Validate scenarios 5–7.
2. Add US5 then US6 (the payment flow). Validate scenarios 8–10.
3. Polish (Phase 9) and a live walk-through.

### Notes

- Each story keeps the app shippable. US5 is the only change to how a payment is started, so keep it and US6 in the same release, so the overpayment rule and tap-to-apply never ship half-way.
- Commit after each task or small group. Run the related tests before moving on.
- Do not edit mbe-api. The optional batch stock lookup remains a proposal only (research R4).
