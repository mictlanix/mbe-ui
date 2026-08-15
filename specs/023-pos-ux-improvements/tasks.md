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

- [X] T001 Run `flutter pub get` from the repo root to confirm the branch resolves cleanly
- [X] T002 [P] Run `flutter analyze` and `flutter test` from the repo root and record the pre-change baseline (no code changes) — a later regression is then attributable to this feature, not the branch point (baseline: 0 analyze issues, 1549 tests passing)

---

## Phase 2: Foundational (blocking prerequisites)

**Purpose**: the domain/data pieces both P1 stories need, and the mechanical
route split that makes `/sales/pos/new` and `/sales/pos/:saleId` resolve to
*something* — with no visual or behavioural change yet. US1 and US2 build on
top of this; neither can be meaningfully tested without it.

- [X] T003 [P] Extract `wireDate(DateTime local) → DateTime` (midnight of the local date, flagged UTC) as a top-level helper in `lib/features/sales/data/sales_order_repository_impl.dart`, mirroring `open_sales_selector_controller.dart`'s `_startOfToday` (research R3, R6) — `_startOfToday` now delegates to it
- [X] T004 [P] Add `Future<OpenSalePage> listSales({required int pointSale, SaleStatus? status, DateTime? dateFrom, DateTime? dateTo, String? search, int skip = 0, int limit = 20})` to `SalesOrderRepository` in `lib/features/sales/domain/repositories/sales_order_repository.dart` (data-model §4.1)
- [X] T005 Implement `listSales()` in `lib/features/sales/data/sales_order_repository_impl.dart` via `listSalesOrdersApiV1SalesOrdersGet`, mapping the response with `OpenSale.fromResponse`/`OpenSalePage` and encoding `dateFrom`/`dateTo` through `wireDate()` (depends on T003, T004)
- [X] T006 [P] Add a `listSales` stub and a multi-item `testSalesPage(...)` fixture helper to `test/widget/features/sales/pos_test_harness.dart`'s `MockSalesOrderRepository` (depends on T004) — added `testOpenSale`, `testSalesPage`, `stubListSales`
- [X] T007 [P] Create `lib/features/sales/domain/sale_workability.dart` with `bool saleIsWorkable(OpenSale sale, {required Set<int> resumableIds})` per the six-case table in data-model §3, using `isZeroAmount` from `features/sales/domain/money.dart` for the balance check
- [X] T008 [P] Unit test `test/unit/features/sales/pos_sale_workability_test.dart` covering all six status/balance combinations, including a zero-balance paid sale outside `resumableIds` (not workable) and an unresolved/empty `resumableIds` (provisionally not workable) (depends on T007) — 8 tests, all passing
- [X] T009 [P] Create `PosSalesFilter` (freezed: `from`, `to`, `status`, `search`, `pageIndex`) with `PosSalesFilter.fromQuery(ListQuery, {required DateTime today})` and the `activeFilterCount`/`hasActiveFilters`/`isToday` extension in `lib/features/sales/presentation/pos_sales_list_controller.dart` (data-model §2)
- [X] T010 Add `PosSalesListController` (`@riverpod`, family over `PosSalesFilter`) to the same file, using `fetchClampedPage` (page size 20) and narrowing each page to `filter.status` client-side since mbe-api's `status` filter is not exclusive (research R3); the "no register configured" case yields a distinct state rather than an unscoped query (depends on T005, T009)
- [X] T011 Run `dart run build_runner build --delete-conflicting-outputs` to generate `.freezed.dart`/`.g.dart` for T009/T010 and confirm they compile
- [X] T012 Create `lib/features/sales/presentation/pos_workspace_screen.dart` absorbing `PosScreen`'s `_PosBody`, `_StepHost`, `_discardIfEmpty`, `_selectSale`, `_startNewSale`, `_finish`, `_closePayment` and the cash-session gate verbatim, as a `ConsumerStatefulWidget` taking an optional `int? saleId` that dispatches `load(saleId)` exactly once on mount (guarded like today's `_syncedSaleId`) when non-null (contracts/pos-workspace.md §1, §5) — includes a minimal `AppBar(leading: BackButton(key: pos_workspace_back))` for functional navigation ahead of US2's full chrome (T034)
- [X] T013 Add the `/sales/pos/new` → real-id URL rewrite in `pos_workspace_screen.dart`: once the held sale is non-null and the current route came from `/new`, call `GoRouter.of(context).replace('/sales/pos/${sale.id}')` exactly once (contracts §1.1) (depends on T012)
- [X] T014 Add the unreachable-sale panel (key `pos_sale_unreachable`) to `pos_workspace_screen.dart` for a 404, a cancelled sale, or a sale belonging to another register, each with its own message and a `posSaleBackToListAction` button; no sale is opened in these cases (contracts §1.2) (depends on T012) — added the 5 new l10n keys (`posSaleUnreachable*`, `posSaleBackToListAction`) to both `.arb` files as part of this task, since T014 needs them to compile; T039 no longer needs to re-add them
- [X] T015 [P] Create a minimal `PosSalesListScreen` scaffold in `lib/features/sales/presentation/pos_sales_list_screen.dart` (a `ConsumerWidget` taking `ListQuery query`, rendering a placeholder body) — just enough for T016 to reference; fully implemented in US1 (T026)
- [X] T016 Update `lib/app/router/app_router.dart`: the `/sales/pos` shell-branch route now builds `PosSalesListScreen(query: ListQuery.fromUri(state.uri))`; add top-level `GoRoute`s for `/sales/pos/new` and `/sales/pos/:saleId` (parsed `int`) building `PosWorkspaceScreen`, placed after the `/sales/cash-sessions/:cashSessionId` route; the existing `startsWith('/sales/pos')` gate entry needs no change (depends on T012, T015)
- [X] T017 Delete `lib/features/sales/presentation/pos_screen.dart` — its content now lives in `pos_workspace_screen.dart` (T012) and `pos_sales_list_screen.dart` (T015) (depends on T016)
- [X] T018 Update `test/unit/app/router/app_router_test.dart`: the POS branch index still resolves for `/sales/pos`, the two new top-level routes are reachable and carry the `pos` read gate, and any pump helper that fetches on `/sales/pos` mount gets the `listSales`/`PosSalesListController` override it now needs (depends on T016, T006) — added a `MockSalesOrderRepository` + `listSales` stub to the shared `pumpAt` helper and 8 new tests (gate pass/redirect × 3 routes + branch-index + no-shell assertions)
- [X] T019 [P] Add a `pumpPosRouted` helper to `test/widget/features/sales/pos_test_harness.dart` that pumps a `MaterialApp.router` configured with the two new routes, for tests that need real navigation rather than a bare widget pump (depends on T016)
- [X] T020 ~~Update every existing POS test that pumps `PosScreen` directly~~ — **premise was wrong, verified by grep**: none of the listed files (`pos_lazy_open_test.dart`, `pos_compact_*_test.dart`, `pos_gate_screen_test.dart`, the three `test/integration/pos_*_flow_test.dart`) ever pumped `PosScreen` — the widget tests pump `CaptureStep`/`DeliveryStep` directly via `pumpPos`, `pos_gate_screen_test.dart` builds its own tiny router around `PosGateScreen`, and the "integration" tests are pure repository-layer tests against a live backend with no widget tree at all. Zero test files needed the swap. Updated only the two doc-comment references to the deleted class (`step_indicator_test.dart`, `customer_inline_create_test.dart`) and `pos_gate_screen.dart`'s own docstring, for accuracy.

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

- [X] T021 [P] [US1] Widget test `test/widget/features/sales/pos_sales_list_screen_test.dart`: rows render, Edit is shown/absent per `saleIsWorkable` × RBAC (contracts/pos-sales-list.md §3 — simplified during implementation to absent-only, never disabled-with-tooltip; see contract update), a row click always navigates, the default range and no-register/empty states render correctly — 12 tests, all passing. Two real bugs found and fixed while writing this: (1) `PosSalesFilter.fromQuery`'s `today` fallback used raw `DateTime.now()` precision, so every rebuild built an unequal filter and the `@riverpod` family never reused a provider instance — an actual infinite loop (permanent loading spinner), fixed by truncating `today` to its calendar date, with a regression test in `pos_sales_filter_test.dart`; (2) `CatalogListStateView`'s filtered-empty state always renders its own shared generic message, ignoring `emptyMessage` — `posSalesEmptyFiltered` was dead code, removed from both `.arb` files and the contract
- [X] T022 [P] [US1] "Nueva venta" gating folded into the same test file: enabled with an open session, disabled with none, absent without `pos` create (contracts §7)

### Implementation for User Story 1

- [X] T023 [P] [US1] Create `lib/core/widgets/date_range_filter_chip.dart` — a `FilterChip` showing the active range that opens `showDateRangePicker`, encoding into `ListQuery` facets as `date-from`/`date-to` (`yyyy-MM-dd`), omitted when both equal today (research R6)
- [X] T024 [US1] Add `DateRangeFilterChip`'s scenario to `test/golden/core_widgets_golden_test.dart`'s covered-files list — required, or the file's directory-scan test fails by design (spec 022 FR-023) (depends on T023)
- [X] T025 [US1] Generate the golden image: `flutter test test/golden/core_widgets_golden_test.dart --update-goldens`, then review the new PNG before committing it (depends on T024) — 2 scenarios (today / custom range) × 2 themes × 2 widths = 8 images, reviewed
- [X] T026 [US1] Fully implement `PosSalesListScreen` — `CatalogFilterBar` (search, "Nueva venta" action, `DateRangeFilterChip` + a `PopupMenuButton`-based `_StatusFilterChip` as filters), `DataTableView<OpenSale>` with the six columns, `buildCatalogRowActions` for Edit gated by `saleIsWorkable` + `salesOrders` update, whole-row `onRowTap` (depends on T009, T010, T015, T023, T007). Simplified from the original contract: Edit is **absent** (never shown-disabled) whether the reason is privilege or workability — matches `buildCatalogRowActions`'s actual capability and the constitution's own row-action convention; the status chip already explains a finished/cancelled row
- [X] T027 [US1] Wire "Nueva venta": `context.push('/sales/pos/new')` when a cash session is open, disabled with the blocked message when none, absent without `pos` create (contracts §7) (depends on T026)
- [X] T028 [US1] Wire the return-from-workspace refresh: `await context.push(...)`, then `ref.invalidate(posSalesListControllerProvider(pointSale, filter))` and `ref.invalidate(openSalesSelectorControllerProvider(pointSale))` (contracts §8, FR-009) (depends on T026, T027)
- [X] T029 [P] [US1] Add the list and date-range l10n keys to both `.arb` files: `posSalesSearchLabel`, `posSalesNewSaleAction`, six `posSalesColumn*`, `posSalesEmptyToday`, `posSalesNoRegister`, `posSalesNewSaleBlockedNoSession`, `posSalesStatusFilterLabel`, `posSalesStatusFilterAll`, `dateRangeFilterLabel`, `dateRangeFilterToday`, `dateRangeFilterRange`, `dateRangeFilterClear`, `posSaleStatusDraft`/`Completed`/`Paid`/`Cancelled` — no `posSalesListTitle` (shell already titles it) and no `posSalesEmptyFiltered` (dead per T026's finding)
- [X] T030 [US1] Run `flutter gen-l10n` and reference the new keys (depends on T029, T023, T026)
- [X] T031 [US1] Run `flutter test test/unit/core/l10n_parity_test.dart` — passes (depends on T030)

**Checkpoint**: US1 is independently functional — the list is reachable, correctly gated, filterable and paged. Full suite green: 1582 tests passing, `flutter analyze` clean.

---

## Phase 4: User Story 2 - Work the sale on the whole screen (Priority: P1)

**Goal**: the workspace has no rail, a Back button and the sale's identity/step
chrome in the app bar, and no dead vertical band above the footer.

**Independent Test**: open a sale with several lines at 1440×900 and confirm no
rail is present, Back returns to the list, and the lines region reaches the
footer with no empty band.

### Tests for User Story 2

- [X] T032 [P] [US2] Widget test `test/widget/features/sales/pos_workspace_route_test.dart`: `/sales/pos/new` creates nothing until the first action; the URL rewrites to `/sales/pos/<id>` once a sale exists; `/sales/pos/:saleId` loads via `getById`, never `open`; a cancelled/unknown/other-register sale renders `pos_sale_unreachable` with no sale opened; Back discards an empty draft then returns to the list — 7 tests. Found and fixed a real gap while writing this: the Back button had no `onPressed` override at all (a plain `BackButton`), so `_discardIfEmpty` was never wired to it — replaced with an `IconButton` that discards, then pops-or-goes-to-list
- [X] T033 [P] [US2] Widget test (same file, new group): no `AppNavigation`/`NavigationDrawer` descendant; `SaleTotalsBar`'s rendered width equals the full window width (nothing bounds/centres it); `pos_continue_to_payment` is a descendant of `SaleTotalsBar` (one footer band, not two) — 3 tests. Also fixed a `pumpPosRouted` harness bug found here: its `/sales/pos` route built `PosSalesListScreen` with no `Scaffold` ancestor (unlike the real `AppShell`), which crashed `PopupMenuButton`'s `Material` lookup

### Implementation for User Story 2

- [X] T034 [US2] Compose the workspace `AppBar`: `leading` an `IconButton` (key `pos_workspace_back`, discard-then-leave — see T032) rather than a plain `BackButton`, `title` a `Row` with the step title, a `_SaleIdentityChip`, the `OpenSalesSelector`, a `Spacer`, and `_StepIndicator`; `actions: const []` (contracts §2) (depends on T012)
- [X] T035 [US2] Delete `pos_header_band.dart`, having moved `OpenSalesSelector`/`_StepIndicator` into T034 and `PosGateScreen` to the top of the workspace body — one existing test (`pos_compact_resume_and_customer_test.dart`) pumped `PosHeaderBand` directly; migrated to a local stand-in widget, mirroring `step_indicator_test.dart`'s own established precedent (depends on T034)
- [X] T036 [US2] Removed the doubled inset around `CustomerBar`; every header item in `capture_step.dart` now gets one horizontal margin (`spacing.screenMargin`) applied consistently, replacing the ad-hoc `EdgeInsets.all(12)`/`symmetric(horizontal:12)` mix (contracts/pos-workspace.md §3, capture-surface.md §1.4) (depends on T035)
- [X] T037 [US2] Merged the primary action into `SaleTotalsBar` (`onContinue`/`confirming`/`compact` params, same `FilledButton` inside); `capture_step.dart`'s separate button `Padding` band is gone (contracts §3.1) (depends on T036). Fixed a regression found via an existing test (`pos_lazy_open_test.dart`'s "cannot be confirmed"): the button must stay visible-but-disabled even when `sale == null`, so `SaleTotalsBar.sale` became nullable rather than gating the whole bar on `sale != null`
- [X] T038 [US2] Confirmed: no `spacing.contentMaxWidth`/bounding `ConstrainedBox` anywhere in the workspace or capture step; every `Center` present is a transient state (loading/empty/error), not a content wrapper. Verified by a widget-test width assertion (T033), not just a grep (depends on T037)
- [X] T039 [US2] `posSaleUnreachable*`/`posSaleBackToListAction` were already added in T014 (Foundational), since the unreachable panel needed them to compile there. `posWorkspaceBackTooltip` was never added — the Back button uses `MaterialLocalizations.of(context).backButtonTooltip`, the standard platform tooltip, which fits better than a bespoke string (depends on T030)
- [X] T040 [US2] No new keys were needed beyond T014's — `flutter gen-l10n` already current (depends on T039)

**Checkpoint**: US1 + US2 together deliver the whole navigation change — list → full-width workspace, no dead band — with every pre-existing POS flow still green. Full suite green: 1592 tests passing, `flutter analyze` clean. **MVP complete.**

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

- [X] T041 [P] [US3] Rewrote `test/widget/features/sales/customer_bar_test.dart`: the resolved name is visible in facts and searching states (the blank-field regression test); the terms dropdown shows `sale.paymentTerms`, shows the credit limit as supporting text or the no-credit hint, and issues zero writes on customer attach; dismissing the picker restores facts with the sale unchanged; picking a customer attaches it and returns to facts — 11 tests (contracts/capture-surface.md §1)

### Implementation for User Story 3

- [X] T042 [US3] Fixed the blank-name bug (resolved name is `customerRecord.name ?? sale.customerName ?? placeholder`) and introduced `_CustomerBandMode { facts, searching }` (research R8, data-model §5)
- [X] T043 [US3] Built the `searching` face: `AnimatedSize` + `AnimatedSwitcher` swap to `CatalogEntityPicker`, autofocused via a new `autofocus` param added to that shared widget (it had no focus-control API at all); dismissing (Escape or the cancel button) returns to facts with no mutation (contracts §1.1, §1.2) (depends on T042)
- [X] T044 [US3] Replaced the `SegmentedButton<PaymentTerms>` with a `DropdownButton<PaymentTerms>` (key `pos_payment_terms_dropdown`) in the credit-line slot, `PaymentTerms.netD` enabled only when the customer has a credit line, always showing `sale.paymentTerms`, writing only on explicit selection; the credit-limit figure the slot used to show becomes supporting text beneath it per research R9, rather than being dropped (contracts §1.3, FR-030) (depends on T042). Found and fixed a real bug here: `DropdownButton`'s own widest-item auto-sizing overflowed by a sub-pixel hair at 390 px (a known Flutter quirk, reproduced live by three existing compact-tier tests) — fixed with a fixed-width `SizedBox` + `isExpanded: true` rather than fighting the auto-sizing path
- [X] T045 [US3] Moved `FulfillmentModeSelector` beside `CustomerBar` in one `Row` at `LayoutBreakpoints.isExpanded` (≥840 px), stacked in a `Column` otherwise, in `capture_step.dart` (contracts §2) (depends on T036, T044)
- [X] T046 [P] [US3] Added `posCustomerSearchAction`, `posCustomerSearchCancelAction`, `posCustomerNoCreditHint` to both `.arb` files; removed the now-superseded `posCustomerNoCredit` (its one use site is gone)
- [X] T047 [US3] Ran `flutter gen-l10n`

**Checkpoint**: US1–US3 all independently functional. Migrated 3 pre-existing tests that asserted on the old `pos_customer_picker`-by-default behavior (`pos_compact_layout_test.dart`, `pos_lazy_open_test.dart`) to the new facts-by-default one. Full suite green.

---

## Phase 6: User Story 4 - Find a product while typing (Priority: P2)

**Goal**: the product field offers candidates as the cashier types without
breaking the scanner's type-and-Enter path.

**Independent Test**: type three characters of a product name and confirm
candidates appear without pressing Enter; then simulate a scan (a full code
followed by Enter) and confirm the line is added directly.

### Tests for User Story 4

- [X] T048 [P] [US4] New widget test `test/widget/features/sales/product_search_field_test.dart`: typing offers candidates after the debounce with no Enter pressed and never auto-adds a line; Enter with exactly one match still adds the line directly, clears the field and keeps focus; a lookup superseded by later typing is dropped even if it resolves last; Escape dismisses the candidate list without clearing the typed text — 7 tests, all passing (contracts/capture-surface.md §3)

### Implementation for User Story 4

- [X] T049 [US4] Added a debounced `onChanged` path (300 ms) that offers results without auto-adding; `onSubmitted` (the scanner's Enter) cancels any pending debounce and is the only path that auto-adds a single exact match; every lookup carries a monotonic request id so a stale result is dropped even if it resolves after a newer one (contracts §3)
- [X] T050 [US4] `flutter analyze` clean; the live `pos_counter_sale_flow_test.dart` (gated on `MBE_POS_*` env vars, absent here) is unaffected in shape — its scan path still goes through `onSubmitted`, unchanged

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

- [X] T051 [P] [US5] Extend `test/widget/features/sales/sale_line_row_test.dart`: a single row with no overflow at 1024 px available width (FR-037a, the tablet-landscape case), the two-row fallback at ~700 px, the unchanged `SaleLineCard` at 390 px, a fixed-size placeholder thumbnail present in every layout, and the product name rendered prominently with the code as a secondary line (contracts §4). Added the `'layout thresholds (spec 023 FR-037, FR-037a)'` group (1024 px singleRow, 700 px twoRow); the pre-existing groups already covered the placeholder thumbnail and the name/code split once T053/T054 landed.

### Implementation for User Story 5

- [X] T052 [P] [US5] Create `lib/features/sales/presentation/capture/sale_line_layout.dart`: `enum SaleLineLayout { singleRow, twoRow, card }` and `SaleLineLayout saleLineLayoutFor(double availableWidth)` using the 950 px / 600 px thresholds from research R10 and data-model §5, as the single place these numbers live
- [X] T053 [US5] Rework `capture/sale_line_row.dart` into a `LayoutBuilder` that calls `saleLineLayoutFor` on its own available width: the single-row grid per contracts/capture-surface.md §4.2 column widths and the two-row fallback per §4.3, both including the `ProductPhoto(photoUrl: null, size: 36)` slot and the name/code split (depends on T052). Found and fixed a real bug here: the quantity column's first budget (104 px — two 28×28 `IconButton`s plus a 36 px field) overflowed by ~12 px in practice, because `IconButton`'s own sizing didn't shrink as far as its `constraints`/`padding` overrides implied; widened to 128 px, matching the mock's own column width, per contracts §4.2's "budget, not measurement" note. Also caught and fixed the quantity field's `labelText` being dropped while tightening the stepper, which had silently broken an existing label-lookup assertion; restored it and widened the field to 44 px to fit.
- [X] T054 [US5] Add the same thumbnail slot and name/code split to `capture/sale_line_card.dart` — cosmetic only, its stacked layout is otherwise unchanged (depends on T052)
- [X] T055 [US5] Rename the row's widget key to `sale_line_row_<id>` per data-model §8 (depends on T053)

`test/widget/features/sales/sale_line_row_test.dart` gained a `'layout thresholds (spec 023 FR-037, FR-037a)'` group beyond T051's original scope: a 1024 px single-row overflow check (the tablet-landscape case FR-037a specifically asks for) and a 700 px two-row check confirming every FR-022 field is still present and editable. Full suite after this story: 1606 passing, 46 skipped, 0 failures — no ripple effects from the row/card rework. `flutter analyze`: clean.

**Checkpoint**: US1–US5 all independently functional.

---

## Phase 8: User Story 6 - Read the sale's money in one place (Priority: P3)

**Goal**: the footer reports labelled stat groups with a dominant total and the
primary action on the same band.

**Independent Test**: open a sale with a discounted line and confirm every
figure is present and labelled, the total is visually dominant, and the primary
action sits on the same band.

### Tests for User Story 6

- [X] T056 [P] [US6] New widget test `test/widget/features/sales/sale_totals_bar_test.dart`: labelled Artículos/Subtotal/Descuentos/IVA groups, the discount group omitted when zero, the total right-aligned and visually dominant with its currency stated, and the primary action present on the same band and correctly disabled at zero lines, mid-confirm, and on a non-editable sale (contracts/capture-surface.md §5). 8 tests. The confirming/spinner case needed its own `pumpWidget`+`pump()` (not `pumpPos`'s `pumpAndSettle`), since the indeterminate `CircularProgressIndicator` never settles.

### Implementation for User Story 6

- [X] T057 [US6] Restyle `capture/sale_totals_bar.dart` into the labelled-group layout from contracts §5 — group labels in `TypeRoles.metricLabel` (uppercased, letter-spaced per the existing `facility_child_section.dart` precedent), figures in `TypeRoles.money`, the total in `TypeRoles.metricValue`, right-aligned — reusing the `onContinue`/`enabled` button plumbing T037 added, key `pos_totals_footer` (depends on T037). Added l10n label-only keys (`posTotalsArticlesLabel`/`SubtotalLabel`/`DiscountLabel`/`TaxLabel`/`TotalLabel`) and removed the four now-dead combined `"Label: {amount}"` keys (`posTotalsSubtotal`/`Discount`/`Tax`/`Total`) they replaced; `posTotalsCounts` is unchanged, just repositioned as the Artículos group's figure. The discount figure gets a display-only `−` prefix to match the mock — a formatting choice, not a new computation (see T058). Updated 4 pre-existing tests whose fixtures happened to give a sale line the same total as the sale itself (`testLine()`'s default `total: '116.00'` coincides with `testSale()`'s default), which the old combined "Total: $116.00" string never collided with but the new bare "$116.00" figure does; scoped those finders to descend from `pos_totals_footer`.
- [X] T058 [US6] Review `sale_totals_bar.dart` against FR-047: every figure still derives from `Sale` as the server returned it (`subtotal`, `taxTotal`, `total`, the `addAmounts`/`subtractAmounts` discount derivation, and the quantity sum) — nothing locally recomputed beyond what already existed (depends on T057). Confirmed clean: the restyle only changed which `TextStyle`/label wraps each figure; the one new string operation (the discount's `−` prefix) is display formatting on an already-derived value, not a new computation.

Full suite after this story: 1614 passing, 46 skipped, 0 failures. `flutter analyze`: clean.

**Checkpoint**: all six user stories independently functional.

---

## Phase 9: Polish & Cross-Cutting Concerns

- [X] T059 [P] Create `test/golden/pos_capture_golden_test.dart` capturing the restyled customer band, sale line row and totals footer at 400 px and 1024 px, light and dark (spec 022's two-width convention; 1024 px doubles as the FR-037a tablet check) (depends on T044, T053, T057). The line-item scenario switches widget by width, `SaleLineCard` below 600 px and `SaleLineRow` above — the same choice `capture_step.dart`'s own `_lines` makes — so the 400 px golden shows what a cashier actually sees there rather than `SaleLineRow` squeezed into a width it's never asked to fit. 3 scenarios × 4 combinations = 12 images.
- [X] T060 Run `flutter test test/golden/ --update-goldens` and review every diff before accepting — this is what FR-051 exists for (depends on T059, T025). No prior baselines existed for these 3 scenarios, so "review" meant inspecting all 12 fresh images directly: customer facts band, line item (row and card), and totals footer all match the mock's intent — labelled groups, dominant right-aligned total, thumbnail placeholder, name/code split. Full `test/golden/` suite: 24 tests passing.
- [X] T061 [P] Write `test/integration/pos_sales_list_flow_test.dart` (live backend, skips cleanly without `MBE_POS_*` in `.env`, discovering its fixtures at runtime) to settle research U1 (what `search` matches) and U2 (whether `date_to` is day-inclusive), recording the findings back into `research.md`'s Unresolved table (depends on T005). Written and verified to skip cleanly (`flutter test` → "All tests skipped") — this environment's `.env` has no `MBE_POS_*` credentials (same pre-existing gap as `pos_counter_sale_flow_test.dart` and its siblings), so U1/U2 could not actually be settled here; `research.md`'s Unresolved table now points at the test and says so honestly rather than reporting invented findings. Also added the missing `MBE_POS_*` section to `.env.template` — it documented none of the four existing POS live tests' vars either, a pre-existing gap this task's fifth consumer made worth closing.
- [X] T062 File the mbe-api issue for exposing `photo` on `ProductLookupResponse` and `SalesOrderLineResponse` (research R11, U3); record the issue reference in `research.md`. Filed as [mictlanix/mbe-api#157](https://github.com/mictlanix/mbe-api/issues/157), following the same template `#145` (the unit-of-measurement gap) used; reference recorded in both R11 and the Unresolved table.
- [X] T063 Run `flutter analyze` from the repo root and grep the full diff for literal `fontSize:`, `Color(0x` and bare `EdgeInsets.all(1` outside test files, confirming FR-048 (depends on T026, T034–T038, T042–T045, T049, T053–T054, T057). `flutter analyze`: clean. No `fontSize:`/`Color(0x` in the diff at all. Several bare `EdgeInsets.all(N)` turned up in `lib/`, sorted into two buckets by checking each against `git diff main`: (1) unmodified context lines this feature didn't touch (`sale_line_row.dart`, `sale_line_card.dart`, `product_search_field.dart`, `pos_gate_screen.dart`) or values matching an established repo-wide convention this feature correctly replicated (`pos_sales_list_screen.dart`'s `EdgeInsets.all(8)`/`(24)`, identical to every other catalog list/detail screen) — left alone, since "fix" would mean deviating from the rest of the codebase, not converging on it; (2) two real inconsistencies in `pos_workspace_screen.dart`, both fixed: its error-state padding used `16` where every sibling detail screen (e.g. `cash_session_detail_screen.dart`) uses `24`, and the step-indicator's chevron separator used a bare `8` where `theme.spacing.xs` was available and already in scope. Full targeted re-run (`sales/`, router, golden): 389 tests passing.
- [X] T064 Run the `quickstart.md` manual validation pass (all 22 checks) at 1440 px, ~1024 px, ~800 px and 390 px (depends on T063). **Not run** — this is an interactive pass against a real signed-in session (register assignment, an open cash session, seeded draft/confirmed/paid sales) in an actual browser, judged by eye across 4 window widths; nothing in this environment can drive that (no browser/session available to this agent). Everything automatable stands in for it as far as it can: `pos_capture_golden_test.dart` (T059) pixel-captures checks 20–22 at exactly the widths this checklist asks for, and the widget/unit/integration suites cover the logic behind checks 1–19. Left for a human to run before calling the feature done.

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
