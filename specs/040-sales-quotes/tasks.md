---

description: "Task list for Sales Quotes"
---

# Tasks: Sales Quotes — Cotizaciones

**Input**: Design documents from `/specs/040-sales-quotes/`
**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/](./contracts/), [quickstart.md](./quickstart.md)

**Tests**: Included. The constitution's Development Workflow & Quality Gates
mandate unit/widget/integration coverage for this kind of change, and
[research.md](./research.md) and both files under [contracts/](./contracts/)
already specify, file by file, what changes and what stays behaviour-identical
— this task list follows that disposition exactly.

**Organization**: Tasks are grouped by user story (spec.md's US1–US5), in
priority order. Unlike spec 039, **there is no deferred phase**: every
dependency this feature needs — the host-agnostic capture step (039), the
quote list's customer name and search (mbe-api#213), and order-origin
recording on conversion (mbe-api#209) — has already shipped. All five stories
can be built end to end in this pass.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no unresolved dependency)
- **[Story]**: US1–US5, or omitted for Setup/Foundational/Polish
- File paths are exact and relative to the repository root

---

## Phase 1: Setup

**Purpose**: Confirm the branch and establish a pre-change baseline so any
later regression in shared POS/order code is attributable to this feature.

- [ ] T001 Confirm `040-sales-quotes` is checked out and run `flutter pub get`
      at the repository root
- [ ] T002 [P] Run `flutter test test/unit/features/sales test/widget/features/sales test/integration` and `flutter analyze`, and record the baseline pass
      count — every currently-passing POS and back-office order test in this
      baseline must still pass, **unmodified in assertion**, at the end of
      Phase 8 (FR-040, SC-007)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Widen the shared `Sale`/`SaleLine` entities so a quote can be one
(data-model.md §1–§2), make the shared capture step tolerate a document with
no warehouse (contracts/quote-capture-host.md), and stand up the quote's own
repository, controller and screen shells. **No user story is independently
testable until this phase is complete** — every story renders through
`quote_screen.dart`, and US1 specifically needs a `Sale` that can hold a quote
at all.

**⚠️ CRITICAL**: the entity and capture-step edits touch files the register
and the back-office order workspace also render. None may change what either
one shows, enables, or writes (constitution: no speculative change; spec
FR-040–FR-042).

### Entity widening (research.md R2, data-model.md §1–§2)

- [ ] T003 [P] In `lib/features/sales/domain/entities/sale.dart`: make
      `pointSale` (`int`), `promiseDate` (`DateTime`), `priority` (`Priority`)
      and `balance` (`String`) nullable; add `@Default(false) bool hasExpired`;
      add `String get balanceOrZero => balance ?? '0';` with a doc comment
      stating the assumption it encodes ("an order always has a balance; only
      a quote does not") — data-model.md §1
- [ ] T004 [P] In `lib/features/sales/domain/entities/sale_line.dart`: make
      `cost` (`String`) nullable; add `String? priceAdjustment` — data-model.md
      §2. `cost` has exactly one reader in `lib/` (the mapping itself,
      `sale_line.dart:63`), verified by grep
- [ ] T005 Run `dart run build_runner build --delete-conflicting-outputs` to
      regenerate `sale.freezed.dart` and `sale_line.freezed.dart` (depends on
      T003, T004)
- [ ] T006 [P] Add `Sale.fromQuoteResponse(api.SalesQuoteResponse r)` factory
      to `sale.dart`, alongside the existing `Sale.fromResponse`: leaves
      `pointSale`/`promiseDate`/`priority`/`balance` null, sets `hasExpired:
      r.hasExpired`, maps `lines` through `SaleLine.fromQuoteLineResponse`
      (depends on T005, T007)
- [ ] T007 [P] Add `SaleLine.fromQuoteLineResponse(api.SalesQuoteLineResponse
      r)` factory to `sale_line.dart`: maps `priceAdjustment`, leaves
      `cost`/`unit`/`photo`/`warehouse` null (depends on T005)
- [ ] T008 [P] Fix the 3 now-nullable `pointSale` reads in
      `lib/features/sales/presentation/pos_workspace_screen.dart:231,253,277`
      (depends on T005)
- [ ] T009 [P] Fix the 3 now-nullable `promiseDate`/`priority` reads in
      `lib/features/sales/presentation/orders/order_header_panel.dart:162,410,222`
      (depends on T005)
- [ ] T010 [P] Replace the 10 `sale.balance` reads with `sale.balanceOrZero`
      in `lib/features/sales/presentation/payment/payment_summary_panel.dart:53,63,66,67,88`,
      `payment_capture_pane.dart:110,112,119` and `payment_controller.dart:137,138`
      (depends on T003)
- [ ] T011 [P] Replace `order.balance` with `order.balanceOrZero` in
      `lib/features/sales/presentation/orders/foreign_order_guard.dart:49`
      (depends on T003)

### The capture step becomes stock-optional (research.md R1, contracts/quote-capture-host.md §2–§3)

- [ ] T012 In `lib/features/sales/presentation/capture/capture_step.dart`:
      add `showWarehouse`, `showAction`, `actionKey` and `showComment`
      constructor parameters (all defaulting to today's behaviour); when
      `showWarehouse` is `false`, skip the stock-cache seed (`:119-121`) and
      the point-of-sale/default-warehouse resolution (`:189-192`) entirely and
      pass `warehouse: null` on add (`:132`) — **never read
      `registerPointSaleProvider` for such a host**; forward `showAction` and
      `actionKey` to `SaleTotalsBar` (`:386-402`, not forwarded today) and
      `showWarehouse`/`showComment` to the line row/card calls (`:423-436`)
      — contracts/quote-capture-host.md §2
- [ ] T013 [P] In `lib/features/sales/presentation/capture/sale_line_row.dart`:
      add `showWarehouse` (`bool`, default `true`); make `_warehouseCell`
      (`:219-222`) conditional and drop its gap in `_singleRow` (`:381`) and
      `_twoRow` (`:433`) — contracts/quote-capture-host.md §3
- [ ] T014 [P] In `lib/features/sales/presentation/capture/sale_line_card.dart`:
      add `showWarehouse` (`bool`, default `true`); make its warehouse picker
      (`:192`) conditional — contracts/quote-capture-host.md §3
- [ ] T015 In `lib/features/sales/presentation/capture/sale_line_layout.dart`:
      add a warehouse-less single-row threshold (≈ `950.0 − 168 − 8`) and a
      `warehouse`-aware overload of `SaleLineColumns.of()` / `saleLineLayoutFor()`
      (`:42`, `:141-187`), so a quote row reaches single-row layout at its own,
      lower threshold instead of falling back to two rows — contracts/quote-capture-host.md
      §3 (depends on T013, T014)
- [ ] T016 [P] Extend `test/widget/features/sales/sale_line_symmetry_test.dart`
      with a warehouse-less counterpart to its row-band assertions: a row
      rendered `showWarehouse: false`, at the lower single-row threshold from
      T015, keeps symmetric vertical padding and shares one text baseline
      across its product/quantity/total band. Constitution VI requires this
      explicitly — "a screen with a non-trivial control band MUST assert it
      with widget tests measuring real insets and baselines" — and removing a
      168 px column is exactly that kind of change. The existing `:157`
      assertion names the warehoused composition (product/warehouse/total)
      and **stays**; this adds its counterpart rather than replacing it
      (depends on T013, T014, T015)
- [ ] T017 [P] Update the register's `CaptureStep` call site
      (`pos_workspace_screen.dart`) and the order workspace's
      (`order_workspace_screen.dart`) to pass `showWarehouse: true` explicitly;
      confirm neither host's rendering changes (depends on T012)
- [ ] T018 [P] In `lib/features/sales/presentation/capture/product_stock_cache.dart`,
      document that `productStockCacheProvider` and `productTaxRateCacheProvider`
      are intentionally shared across all three capture hosts, keyed only by
      product id; a quote host seeds the tax cache but never the stock cache
      — research.md R8

### Editing machinery (research.md R3)

- [ ] T019 Extract the generic ~15 lines of
      `lib/features/sales/presentation/sale_editing.dart` (`ref`/`state`/
      `writesScope` declarations, `tracked()`, `openSale`) into a new
      `TrackedEditing` mixin in `lib/features/sales/presentation/tracked_editing.dart`;
      have `SaleEditing` mix it in, keeping every sales-order-specific body
      unchanged — research.md R3
- [ ] T020 [P] Create `lib/features/sales/presentation/sales_quote_write_scope.dart`:
      `const salesQuoteWritesScope = 'back-office-quote';` — a distinct scope
      from `posWritesScope`/`salesOrderWritesScope`, so a quote's outstanding
      writes and unconfirmed edits never gate or are gated by either other
      host (FR-041)

### The quote repository (contracts/sales-quote-repository.md)

- [ ] T021 [P] Create `lib/features/sales/domain/entities/sales_quote_summary.dart`:
      `SalesQuoteSummary` (`id, serial, customer, customerDisplayName,
      salesperson, date, dueDate, currency, status, hasExpired, total`) with a
      `fromResponse(api.SalesQuoteSummary r)` factory, plus `SalesQuotePage
      { List<SalesQuoteSummary> items; int total; }` — data-model.md §3
- [ ] T022 Create `lib/features/sales/domain/repositories/sales_quote_repository.dart`:
      the 11-method interface (`open, getById, updateHeader, addLine,
      updateLine, removeLine, confirm, cancel, duplicate, convert, listQuotes`)
      — contracts/sales-quote-repository.md §1 (depends on T006, T007, T021)
- [ ] T023 [P] Promote the five `anyOf: [string, num]` wire-value setters
      (`_setQuantity`/`_setPrice1`/`_setDiscountRate`/`_setDiscountRate1`/
      `_setTaxRate1`, `sales_order_repository_impl.dart:429-447`) to a shared
      file `lib/features/sales/data/wire_value_setters.dart`; add two new ones
      for `PriceAdjustment` (create) and `PriceAdjustment1` (update); repoint
      `sales_order_repository_impl.dart` to the shared file — contracts/sales-quote-repository.md
      §3
- [ ] T024 Create `lib/features/sales/data/sales_quote_repository_impl.dart`:
      `SalesQuoteRepositoryImpl` + `final salesQuoteRepositoryProvider`,
      backed by `api.SalesQuotesApi`, every method mapping its response
      through `Sale.fromQuoteResponse`; `cancel`, `duplicate` and `convert`
      each return the response **directly** — no read-back, unlike the order
      repository's `cancel` — contracts/sales-quote-repository.md §1 (depends
      on T022, T023)
- [ ] T025 In `sales_quote_repository_impl.dart`, add `_toQuoteError`: a 422
      whose `detail` is a plain string → `AppError.creditHold(detail)`; apply
      it to `open`, `updateHeader` and `convert` — contracts/sales-quote-repository.md
      §2 (depends on T024). **This is the highest-risk omission in the
      feature.** Without it, `mapDioException`'s 422 arm reads `detail` only
      as a list, so FR-030's "no point of sale configured" refusal — and any
      credit-check refusal on `convert` — silently becomes a bare "validation
      failed" with no message at all
- [ ] T026 Create `lib/features/sales/presentation/quote_editing.dart`:
      `QuoteEditing` mixin (mixes in `TrackedEditing`, `implements SaleEditor`),
      whose bodies call `salesQuoteRepositoryProvider`; explicitly ignore
      `fulfillmentIntent`/`promiseDate`/`priority`/`recipient`/`customerName`
      (header) and `warehouse`/`taxRate` (lines) with a one-line documented
      comment each ("quotes carry no …") — research.md R3 (depends on T019,
      T024)
- [ ] T027 Create `lib/features/sales/presentation/quotes/quote_editor_controller.dart`:
      `QuoteEditorController` (`@riverpod`, family `int? quoteId`, autoDispose,
      mixes `QuoteEditing`); `build` returns `null` for a new quote, else
      `getById`; `refresh()`; and, **outside** `SaleEditor` (no shared widget
      calls them): `cancel()` (single call, quote returned directly),
      `duplicate()` and `convert()` (each returning the **new** document's id
      for the caller to navigate to — neither writes `state`) — research.md R3,
      contracts/sales-quote-repository.md (depends on T026)

### Screens and routing scaffolding

- [ ] T028 [P] In `lib/core/navigation/nav_destinations.dart`: add
      `static const int salesQuotes = 21;` to `NavBranch` (appended last,
      never renumbered) and a `NavDestination` entry in the `sales`
      `NavGroup`, placed after `sales-orders`, gated
      `PrivilegeGate(SystemObject.salesQuotes, AccessRight.read)` — research.md
      R6
- [ ] T029 [P] Add l10n key `salesQuotesMenuTitle` ("Sales Quotes"/
      "Cotizaciones") to `lib/l10n/app_en.arb` and `app_es.arb`, in parity —
      used for both the nav label and the app-bar title
- [ ] T030 Create `lib/features/sales/presentation/quotes/quote_screen.dart`:
      `QuoteScreen({int? quoteId})` — installs the nested `ProviderScope`
      overriding `saleEditorProvider`, `saleWritesScopeProvider`,
      `saleConfirmErrorProvider` and `saleConfirmFailureProvider` (all four —
      contracts/quote-capture-host.md §1); renders `CaptureStep(sale:,
      onContinue: null, showFulfillmentSelector: false,
      excludeGenericCustomer: true, showWarehouse: false)` — `onContinue`
      and `headerExtra` are both wired in US1 (T041, T042); mirrors
      `order_workspace_screen.dart`'s shell shape, which renders its own
      `OrderHeaderPanel` through that same `headerExtra` slot. This
      single call is what satisfies FR-005 (customer-only opening), FR-007
      (generic customer excluded from search), FR-009 (draft opens carrying
      the picked customer) and FR-012 (the capture surface is rendered, not
      copied) — all four are `CustomerBar`/`CaptureStep` behaviour this task
      only configures (depends on T027, T012)
- [ ] T031 [P] Create `lib/features/sales/presentation/quotes/sales_quotes_list_controller.dart`:
      `SalesQuotesFilter` (`search, status, customer, salesperson, pageIndex`,
      `fromQuery(ListQuery)`, an `activeFilterCount` extension — **no date
      field and no `today` parameter**, the endpoint has neither) and
      `SalesQuotesListController` (`@riverpod` family →
      `fetchClampedPage` → `CatalogPage<SalesQuoteSummary>`) — data-model.md
      §4, research.md R5 (depends on T021, T022)
- [ ] T032 [P] Create `lib/features/sales/presentation/quotes/sales_quotes_list_screen.dart`:
      a skeleton screen (no columns/rows yet — added in US3) so the router has
      a builder target (depends on T031)
- [ ] T033 In `lib/app/router/app_router.dart`: append a new last
      `StatefulShellBranch` for `/sales/quotes` → `SalesQuotesListScreen`
      (position matching `NavBranch.salesQuotes`); add two top-level
      `GoRoute`s, `/sales/quotes/new` → `QuoteScreen()` and
      `/sales/quotes/:quoteId` → `QuoteScreen(quoteId:
      int.parse(state.pathParameters['quoteId']!))`; add a `_routeGate` clause
      `if (location.startsWith('/sales/quotes')) return
      PrivilegeGate(SystemObject.salesQuotes, AccessRight.read);` — research.md
      R6, FR-001, FR-002 (every quote route, including `/new` and `/:id`,
      matches this prefix and is gated the same way) (depends on T028, T030,
      T032)

### Test infrastructure

- [ ] T034 [P] Extend `test/widget/features/sales/pos_test_harness.dart`:
      add `testQuote()` / `testQuoteLine()` fixture builders (twins of
      `testSale()`/`testLine()`, using the now-nullable fields from T003/T004)
      and a `pumpQuotesRouted()` helper mirroring `pumpOrdersRouted()` —
      research.md R7 (depends on T003, T004)
- [ ] T035 Generalize `test/widget/features/sales/sale_editor_isolation_test.dart`
      from its current hardcoded POS↔order pair to **three hosts**
      (register, order, quote): parametrize the override block and the
      `pumpBoth` helper; add the two assertions the shared-step-seam contract
      already requires but nothing covers today — `saleConfirmErrorProvider`
      isolation and `unconfirmedEditsProvider` scope isolation — contracts/quote-capture-host.md
      §4 (depends on T027, T030, T034)

**Checkpoint**: `flutter analyze` is clean; every point-of-sale and
back-office order widget/unit test from the T002 baseline still passes with
**unchanged assertions**; the three-host isolation test (T035) passes. User
story implementation can now begin.

---

## Phase 3: User Story 1 - Write and confirm a quote for a named customer (Priority: P1) 🎯 MVP

**Goal**: Open a new quote, pick a real customer, add priced lines, and
confirm it into a read-only, folio-bearing document.

**Independent Test**: Sign in with quote-create rights, start a new quote,
pick a customer, add at least one product, and confirm — the quote returns
with a folio, a confirmed status, and totals matching the lines.

### Tests for User Story 1

- [ ] T036 [P] [US1] Unit test in
      `test/unit/features/sales/sales_quote_repository_impl_test.dart`:
      DTO→entity mapping for `open`/`getById`/`addLine` including
      `priceAdjustment` and `hasExpired`; and the error-mapping shapes from
      T025 (plain-string 422 → `creditHold`, map-with-message 409, plain
      string 409) — research.md R4
- [ ] T037 [P] [US1] Widget test in
      `test/widget/features/sales/quote_screen_test.dart`: the customer band
      opens already searching; the generic walk-in customer never appears in
      results; **nothing is written before a customer is picked**
      (`verifyNever(open())` while the screen is merely rendered and
      searched — FR-006); picking a customer opens the draft with that
      customer in **one** request (assert on the captured `SalesQuoteCreate`,
      not just the resulting `Sale`) — this is also what proves FR-008: the
      quote is never opened by an empty-body `POST` that would fall back to
      the server's generic-customer default; product capture becomes
      available on the same screen, with pricing, minimum-quantity
      defaulting, discount/tax editing and read-only price behaving exactly
      as they do on the other two hosts (FR-013) and totals read from the
      server, never recomputed (FR-017); **no warehouse column, no stock
      badge, no shortfall warning, no fulfilment-mode selector** anywhere
      (FR-014, FR-015, FR-016); confirm is unavailable with zero lines and
      available with one;
      confirm is unavailable while a write is outstanding or an edit is
      unconfirmed (FR-019); a draft shows a provisional reference, not a
      folio (FR-022)
- [ ] T038 [P] [US1] Widget test extension: confirming assigns a folio and
      makes the screen read-only; the primary action is **absent, not
      greyed** once confirmed (FR-021, FR-023)
- [ ] T039 [P] [US1] Widget test in `quote_screen_test.dart`'s header group:
      while the quote is a draft, the **expiry date** and the **comment** are
      editable and each commits through `updateHeader` (assert on the captured
      `SalesQuoteUpdate`, one field at a time); the payment-terms control
      inherited from `CustomerBar` still commits; **currency is rendered
      read-only** (spec A11 — this feature introduces no currency selector);
      once the quote is confirmed or cancelled all of them are read-only
      (FR-020, FR-023)
- [ ] T040 [P] [US1] Integration test in
      `test/integration/sales_quotes_flow_test.dart` (live mbe-api, model on
      `sales_orders_flow_test.dart`): discover a non-generic customer with a
      price list → open a quote with that customer → add a line → confirm →
      verify via `SalesQuoteRepository.getById` that the quote is `completed`
      with a folio and totals matching the line

### Implementation for User Story 1

- [ ] T041 [US1] Create `lib/features/sales/presentation/quotes/quote_header_panel.dart`:
      the quote's own header panel, rendered through `CaptureStep`'s
      `headerExtra` slot directly below the customer band — the same seam
      `OrderHeaderPanel` uses for orders. It shows the reference (the folio,
      or `Sale.provisionalReference` while draft — FR-022), the status and the
      expired marker (FR-024), and the **currency read-only** (spec A11: no
      currency selector is introduced by this feature). While
      `sale.isEditable`, it **edits the expiry date** (spec A12) **and the
      comment**, each committing through `saleEditor.updateHeader(...)`.
      Customer and payment terms are **not** duplicated here — `CustomerBar`
      already renders and edits both. Gate every editable control on
      `access.can(SystemObject.salesQuotes, AccessRight.update)` (FR-003), and
      use the shared responsive form-grid and spacing tokens rather than a
      full-width single-column stack (constitution VI) — FR-020, FR-022,
      FR-024 (depends on T030)
- [ ] T042 [US1] In `quote_screen.dart`, wire `onContinue` to call
      `ref.read(saleEditorProvider).confirm()` through the confirm-failure
      seam (`saleConfirmFailureProvider`) **only when
      `access.can(SystemObject.salesQuotes, AccessRight.update)`** — pass
      `null` otherwise, so the action is absent rather than greyed for a
      read-only user (FR-003); `continueLabel: l10n.salesQuoteConfirmAction`;
      set `showAction: sale?.isEditable ?? true` so the action disappears
      once confirmed rather than being greyed out; pass the quote header
      panel (T041) as `CaptureStep`'s `headerExtra`, so the reference, status,
      currency, expiry and comment sit beside the customer band — FR-003,
      FR-018, FR-020, FR-021, FR-023
- [ ] T043 [P] [US1] Add l10n keys: `salesQuoteConfirmAction`,
      `salesQuoteStatusDraft`, `salesQuoteStatusCompleted`,
      `salesQuoteStatusCancelled`, plus the header panel's own (T041)
      `salesQuoteReferenceLabel`, `salesQuoteExpiryLabel`,
      `salesQuoteCurrencyLabel` and `salesQuoteCommentLabel` — research.md R6

**Checkpoint**: User Story 1 is fully functional and independently testable.
This is the MVP.

---

## Phase 4: User Story 2 - Turn an accepted quote into a back-office order (Priority: P1)

**Goal**: Convert a confirmed, unexpired quote into a back-office order that
carries its customer, terms and lines, landing the user in the order
workspace ready to assign warehouses.

**Independent Test**: Take a confirmed, unexpired quote and convert it — an
order exists carrying the quote's customer and lines, the quote is recorded
as its origin, and the user lands in that order's workspace on the goods
step.

### Tests for User Story 2

- [ ] T044 [P] [US2] Widget test in `quote_screen_test.dart`'s convert group:
      convert is offered only when `status == completed && !hasExpired` and
      `can(salesOrders, create)`; each of the four refusals (draft,
      cancelled, expired, no point of sale) shows a distinct message
      (FR-028); the expired refusal additionally offers Duplicate, **driven
      by the quote's own `hasExpired`, not by matching the refusal's prose**
      (FR-029, research.md R4); a successful convert navigates to the
      resulting order's workspace
- [ ] T045 [P] [US2] Extend `sales_quotes_flow_test.dart` (T040): confirm →
      convert → assert the resulting order carries the quote's customer,
      salesperson, payment terms, currency, contact, ship-to, comment and
      lines (FR-026), the quote's id as `sales_quote` and `origin:
      backOffice`, and is a draft with no warehouse on any line; **convert
      the same quote a second time** and assert a second, independent order
      is created rather than a refusal (FR-031)

### Implementation for User Story 2

- [ ] T046 [US2] In `quote_screen.dart`, add the Convert action: visible only
      when `status == completed && !hasExpired` and `access.can(salesOrders,
      create)` (FR-025, FR-004); on success, `context.go('/sales/orders/
      $newOrderId')` (T027's `convert()`) — the order workspace resumes new
      drafts on its goods step by construction (FR-027); on failure, render
      the server's message via `ErrorBanner` (FR-028)
- [ ] T047 [US2] In `quote_screen.dart`, wire a **working** Duplicate action
      for the expired case: when the quote `hasExpired`, render a Duplicate
      call-to-action beside the refusal that calls T027's `duplicate()` and
      navigates to `/sales/quotes/$newQuoteId`, gated on
      `access.can(SystemObject.salesQuotes, AccessRight.create)` (FR-003,
      FR-029). **This is US2's own acceptance scenario 5, not US5's** — an
      expired quote's only way forward is Duplicate, so a call-to-action that
      renders but does nothing would leave US2 incomplete and its own test
      (T044) unsatisfiable. US5 later widens the same action to every quote
      state (depends on T027)
- [ ] T048 [P] [US2] Add l10n keys `salesQuoteConvertAction` and
      `salesQuoteDuplicateAction` — the latter is used first by T047's
      expired-quote recovery, and again by US5's general-purpose action

**Checkpoint**: User Stories 1 and 2 are both independently functional.

---

## Phase 5: User Story 3 - Find, reopen, amend and cancel quotes (Priority: P2)

**Goal**: A facility-wide, filterable list of quotes; reopening resumes a
draft editable and a confirmed/cancelled quote read-only; cancelling retires
a quote.

**Independent Test**: With several quotes in different states, open the
list, filter by status, reopen a draft, change a line, and cancel a
different quote — each action is reflected on the list.

### Tests for User Story 3

- [ ] T049 [P] [US3] Unit test in
      `test/unit/features/sales/sales_quotes_filter_test.dart`:
      `SalesQuotesFilter.fromQuery` decode and `activeFilterCount` (search
      excluded from the count, per house convention)
- [ ] T050 [P] [US3] Unit test in
      `test/unit/features/sales/sales_quotes_scoping_test.dart`: the
      controller's request always passes `mine: false` (FR-034) and
      correctly threads `customer`/`salesperson`/`status`/`search`
- [ ] T051 [P] [US3] Widget test in
      `test/widget/features/sales/sales_quotes_list_screen_test.dart`: the
      six columns render (Reference, Customer, Date, Expiry, Status, Total);
      `hasExpired` renders as a **separate marker**, never folded into the
      status chip (FR-024, FR-037); row Edit present only when
      `canUpdate && status == draft`; create button present only with
      `salesQuotes/create`; status and customer facets round-trip through
      the URL; a non-numeric search term **narrows** the list (FR-036 —
      regression guard for mbe-api#213)
- [ ] T052 [P] [US3] Widget test: reopening a draft resumes it editable with
      its customer and lines intact; reopening a confirmed or cancelled
      quote is read-only and offers only its available actions (FR-039)
- [ ] T053 [P] [US3] Router test group in
      `test/unit/app/router/app_router_test.dart`, copied from the
      `/sales/orders` group (`:939-1035`) **including the branch-index
      assertion** (`shell.navigationShell.currentIndex ==
      NavBranch.salesQuotes`) — research.md R6, R7

### Implementation for User Story 3

- [ ] T054 [US3] Flesh out `sales_quotes_list_screen.dart`: a
      `CatalogFilterBar` carrying **only** the search box and the create
      action, with the status and customer facets (`CatalogEntityPicker` for
      customer) rendered **inside the filter drawer** via
      `showCatalogFilterSheet`, wrapped in `CurrentListQueryBuilder` as the
      orders list does — constitution VI forbids placing facet controls
      inline in the filter row, which it reserves for the search box and the
      screen's entity actions; `DataTableView<SalesQuoteSummary>` with the six columns
      (FR-035); row actions (Edit when `canUpdate && status == draft`);
      create button gated on `salesQuotes/create` (FR-003); pagination via
      `fetchClampedPage` (FR-038) — research.md R5, R6
- [ ] T055 [P] [US3] Create `SalesQuoteStatusChip` (built on
      `core/widgets/status_chip.dart`) plus a separate expired-marker widget
      — FR-024, FR-037
- [ ] T056 [US3] In `quote_screen.dart`, add the Cancel action, visible only
      when `access.can(SystemObject.salesQuotes, AccessRight.update)` and
      `status in {draft, completed}` and not already cancelled (FR-003,
      FR-032); on success,
      `ref.invalidate(salesQuotesListControllerProvider)` **bare**, so every
      live list instance re-fetches under its own already-applied filter
      (research.md R5)
- [ ] T057 [P] [US3] Add l10n keys: `salesQuotesColumnReference`,
      `salesQuotesColumnCustomer`, `salesQuotesColumnDate`,
      `salesQuotesColumnExpiry`, `salesQuotesColumnStatus`,
      `salesQuotesColumnTotal`, `salesQuotesSearchLabel`,
      `salesQuotesStatusFilterLabel`, `salesQuotesCustomerFilterLabel`,
      `salesQuoteExpiredBadge`, `salesQuoteNewAction`,
      `salesQuoteCancelAction`, `salesQuoteCancelDialogTitle`,
      `salesQuoteCancelDialogMessage`, `salesQuoteCancelDialogConfirm`

**Checkpoint**: User Stories 1 through 3 are all independently functional.

---

## Phase 6: User Story 4 - Quote a customer who is not registered yet (Priority: P2)

**Goal**: Create a customer inline from the quote's own customer band,
without leaving the workspace.

**Independent Test**: From the customer band of a new quote, create a
customer that does not exist, and confirm the quote proceeds with that new
customer attached.

### Tests for User Story 4

- [ ] T058 [P] [US4] Widget test: from `quote_screen.dart`'s customer band,
      inline-creating a customer attaches it and makes capture available
      without leaving the screen; cancelling the inline form leaves no
      customer and no quote created; a server refusal keeps the form's input
      and opens no quote (FR-010, FR-011)

### Implementation for User Story 4

- [ ] T059 [US4] **Needs no new code.** `CustomerBar`'s existing inline-create
      entry point (`_createCustomer` → `showCustomerInlineCreate` →
      `_updateHeader(customer:)`) already renders whenever
      `excludeGenericCustomer: true` shows the searching face — which
      `quote_screen.dart` (T030) already sets. This task is verification
      only: confirm T058 passes with no change to `customer_bar.dart` or
      `quote_screen.dart`

**Checkpoint**: User Stories 1 through 4 are all independently functional.

---

## Phase 7: User Story 5 - Re-quote by duplicating (Priority: P3)

**Goal**: Duplicate any quote into a new, independent draft re-priced at
today's prices — the sanctioned recovery for an expired quote and for
re-quoting in general.

**Independent Test**: Duplicate a confirmed or expired quote and confirm a
new editable draft appears with the same products and today's prices.

### Tests for User Story 5

- [ ] T060 [P] [US5] Widget test: duplicating a quote in any state (draft,
      completed, cancelled, expired) creates a new **draft** with the same
      customer and products priced at today's prices; the original is
      untouched; the new quote has no folio
- [ ] T061 [P] [US5] Widget test: from an expired quote's failed-convert
      state (T044), the offered Duplicate action navigates to the new draft

### Implementation for User Story 5

- [ ] T062 [US5] In `quote_screen.dart`, **widen** T047's Duplicate action
      from the expired-refusal case to every quote state — draft, confirmed,
      cancelled and expired alike (FR-033) — keeping its
      `access.can(SystemObject.salesQuotes, AccessRight.create)` gate
      (FR-003). The repository call and the navigation are already wired by
      T047, so this task changes only *where* the action is offered. If US5 is
      built before US2, the wiring lands here instead and T047 narrows to the
      expired-case placement — the two MUST NOT both implement it
      independently (depends on T027; T047 when US2 was built first)
- [ ] T063 [P] [US5] Confirm `salesQuoteDuplicateAction` (added by T048 for
      T047) reads correctly as a general-purpose action and not only as
      expired-quote recovery; adjust the English and Spanish wording if not

**Checkpoint**: All five user stories are independently functional.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Confirm the two hosts this feature edits but does not own are
still unharmed (FR-040–FR-042, SC-007), and close the loop on
quickstart.md.

- [ ] T064 [P] Re-run the three-host isolation test (T035) after all five
      stories have landed; confirm it is still green
- [ ] T065 [P] Confirm `git diff --stat main --
      lib/features/sales/presentation/pos_workspace_screen.dart
      lib/features/sales/presentation/orders/` touches only the edits this
      plan documents (T008, T009, T011, T017) — no incidental change to
      either host
- [ ] T066 [P] `flutter analyze` clean; full suite green, including T002's
      baseline re-run with unchanged assertions
- [ ] T067 Run quickstart.md's full validation: the automated commands, then
      manual scenarios 1–30, including its two live release checks (the
      quote list's server-side facility scoping, and the live shape of
      convert's refusal bodies) — record the result of both against the
      target deployment
- [ ] T068 [P] Diff `lib/l10n/app_en.arb` and `app_es.arb` against their
      pre-feature state; confirm no key outside this feature's own changed
- [ ] T069 Manually confirm each of SC-001 through SC-008 against the
      finished feature, one pass per criterion

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: none
- **Foundational (Phase 2)**: depends on Setup; **blocks every user story** —
  it is where the entity widening, the capture-step change and the quote's
  repository/controller/screen shells live
- **User Stories (Phases 3–7)**: all depend on Phase 2. US1 (Phase 3) is the
  critical path — every later story adds an action to the screen US1 wires
  the first (and only) forward action onto. US2, US3's cancel, and US5 each
  add one button to `quote_screen.dart`; US3's list and US4's inline create
  depend only on Phase 2's shells, not on US1's confirm wiring specifically
- **Polish (Phase 8)**: depends on Phases 3–7

### User Story Dependencies

- **US1 (P1)**: depends on Foundational only
- **US2 (P1)**: depends on Foundational's `QuoteEditorController.convert()`
  **and `duplicate()`** (T027) and `quote_screen.dart` (T030) existing — not
  on the rest of US1. FR-029 puts Duplicate inside US2's own scope (T047);
  see the US5 note below
- **US3 (P2)**: depends on Foundational's list controller/screen shells
  (T031, T032) and `QuoteEditorController.cancel()` (T027) — not on US1/US2
- **US4 (P2)**: depends on Foundational's `quote_screen.dart` (T030) only;
  independent of US1–US3, though in practice it verifies work Phase 2 already
  did
- **US5 (P3)**: depends on Foundational's `QuoteEditorController.duplicate()`
  (T027) and `quote_screen.dart` (T030). **US2 and US5 share the Duplicate
  action.** FR-029 makes it part of US2's own acceptance scenario 5 — an
  expired quote has no other way forward — so T047 wires it there and T062
  widens it to every state. Whichever story is built first owns the wiring
  and the other narrows to the delta; neither blocks the other, but they MUST
  NOT both implement it independently

### Within Each Phase

- Tests before the implementation they cover, and written to fail first
- Entity widening (T003–T011) before anything that reads the widened fields
- The capture-step change (T012–T018) before the quote screen that relies on
  `showWarehouse: false` (T030)
- The repository (T021–T025) before the controller (T026–T027)
- The controller and screen shells (T026–T030) before any story's screen work
- The quote header panel (T041) before the `headerExtra` wiring that renders
  it (T042)

### Parallel Opportunities

- Within Phase 2: T003, T004, T008–T011, T013, T014, T016, T017, T018, T020,
  T021, T023, T028, T029, T031, T034 are marked `[P]` — different files, no
  cross-dependency
- Within each story's test block, all `[P]`-marked tests can be written
  together
- US3's list work (T049–T057) and US4's inline-create verification
  (T058–T059) can proceed concurrently with US2 (T044–T048) once Phase 2
  completes — they touch no file any of the others own
- Every `[P]` task in Phase 8 targets a different file

---

## Parallel Example: Phase 2 (Foundational)

```bash
# After T003/T004/T005 (the widened entities) land, these can proceed together:
Task: "Fix pos_workspace_screen.dart's 3 pointSale reads (T008)"
Task: "Fix order_header_panel.dart's promiseDate/priority reads (T009)"
Task: "Replace 10 sale.balance reads with balanceOrZero (T010)"
Task: "Replace foreign_order_guard.dart's balance read (T011)"
Task: "Add showWarehouse to sale_line_row.dart (T013)"
Task: "Add showWarehouse to sale_line_card.dart (T014)"
Task: "Add NavBranch.salesQuotes + destination entry (T028)"
Task: "Promote the 5 anyOf wire-value setters, add 2 for priceAdjustment (T023)"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Phase 1: Setup
2. Phase 2: Foundational — **the bulk of the risk lives here, not in US1's
   own code**: the entity widening and the capture-step change are both
   behaviour-preserving refactors of shared files
3. Phase 3: User Story 1
4. **STOP and VALIDATE**: quickstart.md's US1 section (steps 1–8), plus
   T035's isolation assertion — confirm the register and the order workspace
   are unharmed before calling US1 done
5. Demo: a confirmed, folio-bearing quote for a named customer

### Incremental Delivery

1. Setup + Foundational → the entity, the capture step, and the quote's
   repository/controller/screen all exist
2. US1 → the MVP: write and confirm a quote
3. US2 → convert an accepted quote into an order — the feature's commercial
   payoff
4. US3 → the list: find, reopen, amend, cancel
5. US4 → inline customer creation (mostly verification)
6. US5 → duplicate, the recovery path for an expired quote
7. Polish → close the loop on quickstart.md and the two host-regression
   checks

### Notes

- No team-parallelization section is included: this is sized for one
  implementer working phase by phase. The `[P]` markers still tell you which
  tasks have no reason to wait on each other.
- T025 and T035 are this feature's two most important checks — not because
  they are hard to write, but because each is the only place a specific
  silent failure would be caught: T025 catches a destroyed error message
  before it reaches a live user with no point of sale configured; T035
  catches a cross-host write before it reaches a register or an order in
  daily use.
- Every task above traces to a spec FR, a research decision, or a contract
  clause named inline — if a task's rationale is unclear during
  implementation, the citation is where to look before guessing.
