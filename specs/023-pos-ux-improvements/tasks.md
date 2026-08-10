# Tasks: POS Sales List, Full-Width Workspace and Capture Polish

**Input**: Design documents from `specs/023-pos-ux-improvements/`
**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/](./contracts/), [quickstart.md](./quickstart.md)

**Tests**: included throughout — this project's constitution (Development
Workflow & Quality Gates) requires unit tests on domain logic, widget tests on
critical screens, and integration tests on golden-path flows, and every prior
feature in this repo shipped that way.

**Organization**: grouped by user story from `spec.md`, in priority order. US1
and US2 are both P1 and mutually required for a working screen — Foundational
carries the routing skeleton both need (a mechanical lift-and-shift with no
visual change), US1 then delivers the list surface and US2 delivers the
full-width chrome and space rules on top of it.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: different files, no dependency on an incomplete task
- **[Story]**: which user story this task belongs to (US1–US6)
- Every task names its exact file path(s)

---

## Phase 1: Setup

- [ ] T001 Run `flutter pub get` from the repo root to confirm the branch resolves cleanly
- [ ] T002 [P] Run `flutter analyze` and `flutter test` from the repo root and record the pre-change baseline (no code changes) — a later regression is then attributable to this feature, not the branch point

---

## Phase 2: Foundational (blocking prerequisites)

**Purpose**: the domain/data pieces both P1 stories need, and the mechanical
route split that makes `/sales/pos/new` and `/sales/pos/:saleId` resolve to
*something* — with no visual or behavioural change yet. US1 and US2 build on
top of this; neither can be meaningfully tested without it.

- [ ] T003 [P] Extract `wireDate(DateTime local) → DateTime` (midnight of the local date, flagged UTC) as a top-level helper in `lib/features/sales/data/sales_order_repository_impl.dart`, mirroring `open_sales_selector_controller.dart`'s `_startOfToday` (research R3, R6)
- [ ] T004 [P] Add `Future<OpenSalePage> listSales({required int pointSale, SaleStatus? status, DateTime? dateFrom, DateTime? dateTo, String? search, int skip = 0, int limit = 20})` to `SalesOrderRepository` in `lib/features/sales/domain/repositories/sales_order_repository.dart` (data-model §4.1)
- [ ] T005 Implement `listSales()` in `lib/features/sales/data/sales_order_repository_impl.dart` via `listSalesOrdersApiV1SalesOrdersGet`, mapping the response with `OpenSale.fromResponse`/`OpenSalePage` and encoding `dateFrom`/`dateTo` through `wireDate()` (depends on T003, T004)
- [ ] T006 [P] Add a `listSales` stub and a multi-item `testSalesPage(...)` fixture helper to `test/widget/features/sales/pos_test_harness.dart`'s `MockSalesOrderRepository` (depends on T004)
- [ ] T007 [P] Create `lib/features/sales/domain/sale_workability.dart` with `bool saleIsWorkable(OpenSale sale, {required Set<int> resumableIds})` per the six-case table in data-model §3, using `isZeroAmount` from `features/sales/domain/money.dart` for the balance check
- [ ] T008 [P] Unit test `test/unit/features/sales/pos_sale_workability_test.dart` covering all six status/balance combinations, including a zero-balance paid sale outside `resumableIds` (not workable) and an unresolved/empty `resumableIds` (provisionally not workable) (depends on T007)
- [ ] T009 [P] Create `PosSalesFilter` (freezed: `from`, `to`, `status`, `search`, `pageIndex`) with `PosSalesFilter.fromQuery(ListQuery, {required DateTime today})` and the `activeFilterCount`/`hasActiveFilters`/`isToday` extension in `lib/features/sales/presentation/pos_sales_list_controller.dart` (data-model §2)
- [ ] T010 Add `PosSalesListController` (`@riverpod`, family over `PosSalesFilter`) to the same file, using `fetchClampedPage` (page size 20) and narrowing each page to `filter.status` client-side since mbe-api's `status` filter is not exclusive (research R3); the "no register configured" case yields a distinct state rather than an unscoped query (depends on T005, T009)
- [ ] T011 Run `dart run build_runner build --delete-conflicting-outputs` to generate `.freezed.dart`/`.g.dart` for T009/T010 and confirm they compile
- [ ] T012 Create `lib/features/sales/presentation/pos_workspace_screen.dart` absorbing `PosScreen`'s `_PosBody`, `_StepHost`, `_discardIfEmpty`, `_selectSale`, `_startNewSale`, `_finish`, `_closePayment` and the cash-session gate verbatim, as a `ConsumerStatefulWidget` taking an optional `int? saleId` that dispatches `load(saleId)` exactly once on mount (guarded like today's `_syncedSaleId`) when non-null (contracts/pos-workspace.md §1, §5)
- [ ] T013 Add the `/sales/pos/new` → real-id URL rewrite in `pos_workspace_screen.dart`: once the held sale is non-null and the current route came from `/new`, call `GoRouter.of(context).replace('/sales/pos/${sale.id}')` exactly once (contracts §1.1) (depends on T012)
- [ ] T014 Add the unreachable-sale panel (key `pos_sale_unreachable`) to `pos_workspace_screen.dart` for a 404, a cancelled sale, or a sale belonging to another register, each with its own message and a `posSaleBackToListAction` button; no sale is opened in these cases (contracts §1.2) (depends on T012)
- [ ] T015 [P] Create a minimal `PosSalesListScreen` scaffold in `lib/features/sales/presentation/pos_sales_list_screen.dart` (a `ConsumerWidget` taking `ListQuery query`, rendering a placeholder body) — just enough for T016 to reference; fully implemented in US1 (T026)
- [ ] T016 Update `lib/app/router/app_router.dart`: the `/sales/pos` shell-branch route now builds `PosSalesListScreen(query: ListQuery.fromUri(state.uri))`; add top-level `GoRoute`s for `/sales/pos/new` and `/sales/pos/:saleId` (parsed `int`) building `PosWorkspaceScreen`, placed after the `/sales/cash-sessions/:cashSessionId` route; the existing `startsWith('/sales/pos')` gate entry needs no change (depends on T012, T015)
- [ ] T017 Delete `lib/features/sales/presentation/pos_screen.dart` — its content now lives in `pos_workspace_screen.dart` (T012) and `pos_sales_list_screen.dart` (T015) (depends on T016)
- [ ] T018 Update `test/unit/app/router/app_router_test.dart`: the POS branch index still resolves for `/sales/pos`, the two new top-level routes are reachable and carry the `pos` read gate, and any pump helper that fetches on `/sales/pos` mount gets the `listSales`/`PosSalesListController` override it now needs (depends on T016, T006)
- [ ] T019 [P] Add a `pumpPosRouted` helper to `test/widget/features/sales/pos_test_harness.dart` that pumps a `MaterialApp.router` configured with the two new routes, for tests that need real navigation rather than a bare widget pump (depends on T016)
- [ ] T020 Update every existing POS test that pumps `PosScreen` directly — `pos_lazy_open_test.dart`, `pos_compact_resume_and_customer_test.dart`, `pos_compact_layout_test.dart`, `pos_compact_delivery_test.dart`, `pos_gate_screen_test.dart`, `test/integration/pos_counter_sale_flow_test.dart`, `pos_delivery_split_flow_test.dart`, `pos_resume_flow_test.dart` — to pump `PosWorkspaceScreen` instead, with no assertion changes (depends on T012, T017)

**Checkpoint**: the app builds, both new routes resolve to real screens, and every pre-existing POS test passes against the new skeleton with no visual change yet.

---

## Phase 3: User Story 1 - See the register's sales and pick one up (Priority: P1) 🎯 MVP

**Goal**: `/sales/pos` lists the register's sales for the selected range, with
Edit gated by workability and a "Nueva venta" action.

**Independent Test**: ring up two sales on a register, leave one unconfirmed,
open the point of sale, and confirm both appear with the correct status; the
unconfirmed one's Edit reopens on Venta and the finished one offers no Edit but
still opens read-only on a row click.

### Tests for User Story 1

- [ ] T021 [P] [US1] Widget test `test/widget/features/sales/pos_sales_list_screen_test.dart`: the six columns render correctly, Edit is shown/disabled/absent per `saleIsWorkable` × RBAC (contracts/pos-sales-list.md §3), a row click always navigates, the date-range default is today→today and clearing it returns to today (never unbounded), the status facet narrows client-side, and the three empty/no-register/failure states render correctly
- [ ] T022 [P] [US1] Extend the same test file (or a sibling) for "Nueva venta": enabled with an open/stale session, disabled with none (with `posSalesNewSaleBlockedNoSession` and a link to `/sales/cash-sessions`), absent without `pos` create (contracts §7)

### Implementation for User Story 1

- [ ] T023 [P] [US1] Create `lib/core/widgets/date_range_filter_chip.dart` — a `FilterChip` showing the active range that opens `showDateRangePicker`, encoding into `ListQuery` facets as `date-from`/`date-to` (`yyyy-MM-dd`), omitted when both equal today (research R6)
- [ ] T024 [US1] Add `DateRangeFilterChip`'s scenario to `test/golden/core_widgets_golden_test.dart`'s covered-files list — required, or the file's directory-scan test fails by design (spec 022 FR-023) (depends on T023)
- [ ] T025 [US1] Generate the golden image: `flutter test test/golden/core_widgets_golden_test.dart --update-goldens`, then review the new PNG before committing it (depends on T024)
- [ ] T026 [US1] Fully implement `PosSalesListScreen` in `lib/features/sales/presentation/pos_sales_list_screen.dart`: `CatalogFilterBar` (search box, "Nueva venta" as its `actions` slot, `DateRangeFilterChip` and a status `FilterChip`/sheet entry as `filters`), `DataTableView<OpenSale>` with the six columns from contracts/pos-sales-list.md §2 (folio/reference never truncated, customer ellipsis+tooltip, status centred, total/balance right-aligned never truncated), `buildCatalogRowActions` for Edit gated by `saleIsWorkable(sale, resumableIds: …)` from `openSalesSelectorControllerProvider` plus the `salesOrders` update privilege, and a whole-row `onRowTap` to `/sales/pos/${sale.id}` (depends on T009, T010, T015, T023, T007)
- [ ] T027 [US1] Wire "Nueva venta": `context.push('/sales/pos/new')` when a cash session is open/stale, disabled with the blocked message when none, absent without `pos` create (contracts §7) (depends on T026)
- [ ] T028 [US1] Wire the return-from-workspace refresh: `await context.push(...)`, then `ref.invalidate(posSalesListControllerProvider(filter))` and `ref.invalidate(openSalesSelectorControllerProvider(pointSale))` (contracts §8, FR-009) (depends on T026, T027)
- [ ] T029 [P] [US1] Add the list and date-range l10n keys to `lib/l10n/app_es.arb` and `lib/l10n/app_en.arb` (data-model §7: `posSalesListTitle`, `posSalesNewSaleAction`, six `posSalesColumn*`, `posSalesEmptyToday`, `posSalesEmptyFiltered`, `posSalesNoRegister`, `posSalesEditDisabledTooltip`, `posSalesNewSaleBlockedNoSession`, `dateRangeFilterLabel`, `dateRangeFilterToday`, `dateRangeFilterRange`, `dateRangeFilterClear`, and `posSaleStatusDraft`/`Completed`/`Paid`/`Cancelled`)
- [ ] T030 [US1] Run `flutter gen-l10n` and reference the new keys from T023/T026 (depends on T029, T023, T026)
- [ ] T031 [US1] Run `flutter test test/unit/core/l10n_parity_test.dart` from the repo root and confirm it passes (depends on T030)

**Checkpoint**: US1 is independently functional — the list is reachable, correctly gated, filterable and paged.

---

## Phase 4: User Story 2 - Work the sale on the whole screen (Priority: P1)

**Goal**: the workspace has no rail, a Back button and the sale's identity/step
chrome in the app bar, and no dead vertical band above the footer.

**Independent Test**: open a sale with several lines at 1440×900 and confirm no
rail is present, Back returns to the list, and the lines region reaches the
footer with no empty band.

### Tests for User Story 2

- [ ] T032 [P] [US2] Widget test `test/widget/features/sales/pos_workspace_route_test.dart`: `/sales/pos/new` creates nothing until the first action; the URL rewrites to `/sales/pos/<id>` once a sale exists; reloading that URL resumes the same sale rather than opening a second; a cancelled/unknown/other-register sale renders `pos_sale_unreachable` with no sale opened; Back on an empty draft discards it (contracts/pos-workspace.md §1, §6)
- [ ] T033 [P] [US2] Widget test asserting the workspace has no `AppNavigation`/`NavigationDrawer` descendant, no `Center`/width-bounded wrapper around the step content, exactly one `Expanded` (the lines list) between the search field and the footer, and one footer band rather than two (contracts §2, §3)

### Implementation for User Story 2

- [ ] T034 [US2] Compose the workspace `AppBar` in `pos_workspace_screen.dart`: `leading` a `BackButton` (key `pos_workspace_back`) popping to `/sales/pos`, `title` a `Row` with the step title, a `_SaleIdentityChip` (reference, folio once assigned), the `OpenSalesSelector`, a `Spacer`, and the `_StepIndicator`; `actions: const []` (contracts §2) (depends on T012)
- [ ] T035 [US2] Delete `lib/features/sales/presentation/pos_header_band.dart`, having moved `OpenSalesSelector` and `_StepIndicator` into T034 and `PosGateScreen` to the top of the workspace body (depends on T034)
- [ ] T036 [US2] Remove the doubled `EdgeInsets.all(12)` wrapping `CustomerBar` in `lib/features/sales/presentation/capture/capture_step.dart`; re-express every remaining inset in that file through `Theme.of(context).spacing.*` (contracts/pos-workspace.md §3, capture-surface.md §1.4) (depends on T035)
- [ ] T037 [US2] Move the primary action into `SaleTotalsBar` structurally — add an `onContinue`/`enabled` parameter and render the existing `FilledButton` (key `pos_continue_to_payment`) inside it — and delete the separate button `Padding` band from `capture_step.dart`, so the footer is one band; the button's own visual restyling is US6's job (contracts §3.1) (depends on T036)
- [ ] T038 [US2] Confirm the workspace body applies no `spacing.contentMaxWidth` at any tier and that the compact-tier single-`ListView` capture behaviour (spec 020 FR-053) is unchanged (depends on T037)
- [ ] T039 [US2] Add `posWorkspaceBackTooltip`, `posSaleUnreachableTitle`, `posSaleUnreachableCancelled`, `posSaleUnreachableUnknown`, `posSaleUnreachableOtherRegister`, `posSaleBackToListAction` to both `.arb` files (depends on T030)
- [ ] T040 [US2] Run `flutter gen-l10n` for the new keys (depends on T039)

**Checkpoint**: US1 + US2 together deliver the whole navigation change — list → full-width workspace, no dead band — with every pre-existing POS flow still green.

---

## Phase 5: User Story 3 - Identify the customer without leaving the sale (Priority: P2)

**Goal**: the customer band shows facts by default, swaps to the picker on
Buscar, always shows the resolved name, and offers payment terms as a
credit-gated dropdown instead of the segmented control.

**Independent Test**: open a sale, confirm the preselected customer's name and
facts are visible, search and attach a different customer, and confirm the band
returns to reporting facts with the new name and that the terms dropdown mirrors
the sale rather than changing it.

### Tests for User Story 3

- [ ] T041 [P] [US3] Extend `test/widget/features/sales/customer_bar_test.dart`: the resolved name is visible in the `facts`, `searching` and mid-attach states; the terms dropdown shows `sale.paymentTerms` and issues zero writes on customer attach; `Crédito` is disabled with `posCustomerNoCreditHint` when the customer has no credit line; dismissing the picker (Escape or its cancel affordance) restores `facts` with the sale unchanged (contracts/capture-surface.md §1)

### Implementation for User Story 3

- [ ] T042 [US3] In `lib/features/sales/presentation/capture/customer_bar.dart`, fix the blank-name bug (resolve the displayed name as `customerRecord.name ?? sale.customerName ?? placeholder`, not `sale.customerName` alone) and introduce a local `CustomerBandMode { facts, searching }` (research R8, data-model §5)
- [ ] T043 [US3] Build the `searching` face: an `AnimatedSwitcher` + `AnimatedSize` swap from the facts row to `CatalogEntityPicker` (seeded from the resolved name, autofocused) when `pos_customer_search_button` is pressed; dismissing it (Escape or cancel) returns to `facts` with no mutation; the existing `_busy` spinner covers the mid-attach state (contracts §1.1, §1.2) (depends on T042)
- [ ] T044 [US3] Replace `_paymentTermsControl`'s `SegmentedButton<PaymentTerms>` with a `DropdownButtonFormField<PaymentTerms>` (key `pos_payment_terms_dropdown`) in the credit-line slot of `_CustomerFacts`, offering `PaymentTerms.netD` only when `!isZeroAmount(customer.creditLimit)`, always displaying `sale.paymentTerms`, and calling `updateHeader(paymentTerms: …)` only on an explicit user selection (contracts §1.3, FR-030) (depends on T042)
- [ ] T045 [US3] Move `FulfillmentModeSelector` beside `CustomerBar` in the same `Row` at ≥ `LayoutBreakpoints.expanded` (840 px) and below it otherwise, in `capture/capture_step.dart` (contracts §2) (depends on T036, T044)
- [ ] T046 [P] [US3] Add `posCustomerSearchAction`, `posCustomerSearchCancelAction`, `posCustomerNoCreditHint` to both `.arb` files
- [ ] T047 [US3] Run `flutter gen-l10n` (depends on T046)

**Checkpoint**: US1–US3 all independently functional.

---

## Phase 6: User Story 4 - Find a product while typing (Priority: P2)

**Goal**: the product field offers candidates as the cashier types without
breaking the scanner's type-and-Enter path.

**Independent Test**: type three characters of a product name and confirm
candidates appear without pressing Enter; then simulate a scan (a full code
followed by Enter) and confirm the line is added directly.

### Tests for User Story 4

- [ ] T048 [P] [US4] New widget test `test/widget/features/sales/product_search_field_test.dart`: typing offers candidates after the debounce with no Enter pressed and never auto-adds a line; Enter with exactly one match still adds the line directly, clears the field and keeps focus; a lookup superseded by later typing is dropped even if it resolves last; Escape dismisses the candidate list without clearing the typed text (contracts/capture-surface.md §3)

### Implementation for User Story 4

- [ ] T049 [US4] In `capture/product_search_field.dart`, add a debounced `onChanged` path (300 ms) that offers results without auto-adding, keep `onSubmitted`'s immediate lookup as the only path that auto-adds a single exact match, cancel any pending debounce on submit, and tag every lookup with a monotonic request number so a stale result is dropped (contracts §3)
- [ ] T050 [US4] Run `flutter test test/integration/pos_counter_sale_flow_test.dart` (which scans a product) and confirm it still passes unchanged (depends on T049, T020)

**Checkpoint**: US1–US4 all independently functional.

---

## Phase 7: User Story 5 - Read a sale line at a glance (Priority: P3)

**Goal**: a line renders as one row down to a 1024 px tablet in landscape, two
rows below that, and the existing card at phone widths — with a reserved
thumbnail slot and a name-prominent/code-secondary product cell.

**Independent Test**: add four products to a sale on a wide display and confirm
each renders as a single row with proportionate fields; narrow the window and
confirm the fallback to two rows, then to the card; confirm a 1024-px-wide
window still uses the single row.

### Tests for User Story 5

- [ ] T051 [P] [US5] Extend `test/widget/features/sales/sale_line_row_test.dart`: a single row with no overflow at 1024 px available width (FR-037a, the tablet-landscape case), the two-row fallback at ~700 px, the unchanged `SaleLineCard` at 390 px, a fixed-size placeholder thumbnail present in every layout, and the product name rendered prominently with the code as a secondary line (contracts §4)

### Implementation for User Story 5

- [ ] T052 [P] [US5] Create `lib/features/sales/presentation/capture/sale_line_layout.dart`: `enum SaleLineLayout { singleRow, twoRow, card }` and `SaleLineLayout saleLineLayoutFor(double availableWidth)` using the 950 px / 600 px thresholds from research R10 and data-model §5, as the single place these numbers live
- [ ] T053 [US5] Rework `capture/sale_line_row.dart` into a `LayoutBuilder` that calls `saleLineLayoutFor` on its own available width: the single-row grid per contracts/capture-surface.md §4.2 column widths (36/flex-200min/140/104/36/84/68/68/96/40, `spacing.xs` gaps) and the two-row fallback per §4.3, both including the `ProductPhoto(photoUrl: null, size: 36)` slot and the name/code split (depends on T052)
- [ ] T054 [US5] Add the same thumbnail slot and name/code split to `capture/sale_line_card.dart` — cosmetic only, its stacked layout is otherwise unchanged (depends on T052)
- [ ] T055 [US5] Rename the row's widget key to `sale_line_row_<id>` per data-model §8 (depends on T053)

**Checkpoint**: US1–US5 all independently functional.

---

## Phase 8: User Story 6 - Read the sale's money in one place (Priority: P3)

**Goal**: the footer reports labelled stat groups with a dominant total and the
primary action on the same band.

**Independent Test**: open a sale with a discounted line and confirm every
figure is present and labelled, the total is visually dominant, and the primary
action sits on the same band.

### Tests for User Story 6

- [ ] T056 [P] [US6] New widget test `test/widget/features/sales/sale_totals_bar_test.dart`: labelled Artículos/Subtotal/Descuentos/IVA groups, the discount group omitted when zero, the total right-aligned and visually dominant with its currency stated, and the primary action present on the same band and correctly disabled at zero lines, mid-confirm, and on a non-editable sale (contracts/capture-surface.md §5)

### Implementation for User Story 6

- [ ] T057 [US6] Restyle `capture/sale_totals_bar.dart` into the labelled-group layout from contracts §5 — group labels in the smallest label role, figures in the body role, the total in the largest available type role, right-aligned — reusing the `onContinue`/`enabled` button plumbing T037 added, key `pos_totals_footer` (depends on T037)
- [ ] T058 [US6] Review `sale_totals_bar.dart` against FR-047: every figure still derives from `Sale` as the server returned it (`subtotal`, `taxTotal`, `total`, the `addAmounts`/`subtractAmounts` discount derivation, and the quantity sum) — nothing locally recomputed beyond what already existed (depends on T057)

**Checkpoint**: all six user stories independently functional.

---

## Phase 9: Polish & Cross-Cutting Concerns

- [ ] T059 [P] Create `test/golden/pos_capture_golden_test.dart` capturing the restyled customer band, sale line row and totals footer at 400 px and 1024 px, light and dark (spec 022's two-width convention; 1024 px doubles as the FR-037a tablet check) (depends on T044, T053, T057)
- [ ] T060 Run `flutter test test/golden/ --update-goldens` and review every diff before accepting — this is what FR-051 exists for (depends on T059, T025)
- [ ] T061 [P] Write `test/integration/pos_sales_list_flow_test.dart` (live backend, skips cleanly without `MBE_POS_*` in `.env`, discovering its fixtures at runtime) to settle research U1 (what `search` matches) and U2 (whether `date_to` is day-inclusive), recording the findings back into `research.md`'s Unresolved table (depends on T005)
- [ ] T062 File the mbe-api issue for exposing `photo` on `ProductLookupResponse` and `SalesOrderLineResponse` (research R11, U3); record the issue reference in `research.md`
- [ ] T063 Run `flutter analyze` from the repo root and grep the full diff for literal `fontSize:`, `Color(0x` and bare `EdgeInsets.all(1` outside test files, confirming FR-048 (depends on T026, T034–T038, T042–T045, T049, T053–T054, T057)
- [ ] T064 Run the `quickstart.md` manual validation pass (all 22 checks) at 1440 px, ~1024 px, ~800 px and 390 px (depends on T063)

---

## Dependencies & Execution Order

### Phase dependencies

- **Setup (Phase 1)**: no dependencies
- **Foundational (Phase 2)**: depends on Setup; blocks every user story — it is the routing skeleton and shared domain/data both P1 stories build on
- **US1 (Phase 3)** and **US2 (Phase 4)**: both depend only on Foundational; US2's app-bar/footer work (T034–T038) also touches files US3/US5/US6 later extend, so US1 → US2 → US3 → US4 → US5 → US6 is the safest linear order even though US1 and US2 do not depend on each other's *tasks*
- **US3 (Phase 5)**: depends on Foundational; T045 also depends on US2's T036 (the insets pass) to avoid re-touching `capture_step.dart` twice
- **US4 (Phase 6)**: depends on Foundational only; independent of US1–US3's files
- **US5 (Phase 7)**: depends on Foundational only
- **US6 (Phase 8)**: depends on US2's T037 (the button plumbing it reuses)
- **Polish (Phase 9)**: depends on the stories whose output it verifies

### Within each story

Tests are written alongside implementation, not strictly before it — this
codebase does not enforce red-green TDD, but every story's checkpoint requires
its test file passing before moving on.

### Parallel opportunities

- T003, T004 (Foundational, different files)
- T006, T007, T009 once T004/T005 land (different files)
- T021, T022 (US1 tests, same file but independent scenarios — fine to draft together)
- T023 (US1, new widget) alongside T007/T008 (Foundational, unrelated files)
- T032, T033 (US2 tests, different concerns, same file — draft together)
- US3 (Phase 5) and US4 (Phase 6) touch disjoint files (`customer_bar.dart` / `fulfillment_mode_selector.dart` vs `product_search_field.dart`) and can proceed in parallel once Foundational and US2's T036 are done
- US5 (Phase 7) and US6 (Phase 8) touch disjoint files (`sale_line_row.dart`/`sale_line_card.dart`/`sale_line_layout.dart` vs `sale_totals_bar.dart`) and can proceed in parallel once US2's T037 is done
- T046 (US3 l10n) and T048 (US4 test) — different files, no shared dependency

---

## Parallel Example: Foundational

```bash
# These touch different files and can run together:
Task: "Extract wireDate() in lib/features/sales/data/sales_order_repository_impl.dart"
Task: "Add listSales() to SalesOrderRepository in lib/features/sales/domain/repositories/sales_order_repository.dart"
```

## Parallel Example: after Foundational + US2's T036 land

```bash
# US3 and US4 do not share a file:
Task: "Fix the blank-name bug and add CustomerBandMode in capture/customer_bar.dart"     # US3
Task: "Add the debounced onChanged path in capture/product_search_field.dart"            # US4
```

---

## Implementation Strategy

### MVP first

1. Phase 1 (Setup) → Phase 2 (Foundational) — the app must build and route correctly before anything is user-visible
2. Phase 3 (US1) — the list is reachable and correctly gated
3. Phase 4 (US2) — the workspace is full-width with no dead band
4. **STOP and validate** with quickstart.md's US1/US2 manual checks (1–11): this alone is the two P1 complaints fixed

### Incremental delivery

5. Phase 5 (US3) — customer band polish → validate checks 12–16
6. Phase 6 (US4) — search-as-you-type → validate checks 17–19
7. Phase 7 (US5) + Phase 8 (US6), in parallel if staffed — line and footer polish → validate checks 20–22
8. Phase 9 (Polish) — goldens, the live integration test, the mbe-api issue, the final analyze/grep pass

### Notes

- [P] tasks touch different files and have no incomplete dependency
- Every widget key an existing test relies on (data-model §8) must survive the
  restyle unchanged — `pos_continue_to_payment`, `pos_customer_picker`,
  `pos_customer_facts`, `open_sales_selector`, `sale_line_card_<id>`, and
  `start_new_sale_button` above all
- Run `dart run build_runner build --delete-conflicting-outputs` after any
  freezed/riverpod-annotated class changes, not only where a task calls it out
  explicitly
- Stop at any checkpoint to run that story's own tests before continuing
