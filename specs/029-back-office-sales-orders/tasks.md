# Tasks: Back-Office Sales Orders ("Pedidos")

**Input**: Design documents from `/specs/029-back-office-sales-orders/`
**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md), [data-model.md](data-model.md), [contracts/](contracts/), [quickstart.md](quickstart.md)

**Tests**: Included. The constitution mandates unit/widget/integration coverage, and three of this feature's success criteria (SC-005 zero writes on mount, SC-007 the register is unchanged, SC-009 no cross-user leakage) are only verifiable with tests — SC-007 in particular is the safety net the whole Phase 2 refactor rests on.

**Organization**: Phase 2 is a genuine blocker — every story reads the extended `Sale`, and the three shared capture widgets must be routed through `saleEditorProvider` before a second screen can use them. After that, US3 and US5 (the list's filtering) are independent of US2 and US4 (the order screen's states) and can proceed in parallel.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: US1–US5, matching [spec.md](spec.md)
- Every task names an exact file path from the repo root

## Path Conventions

Flutter application, single project. `lib/` for source, `test/` for tests, both at repo root (plan.md Project Structure). Generated companions (`*.g.dart`, `*.freezed.dart`) are produced by `dart run build_runner build --delete-conflicting-outputs` and are never hand-edited.

---

## Phase 1: Setup

**Purpose**: Nothing to initialize — this feature adds files to an already-configured project and introduces no dependency, script or tool.

- [ ] T001 Confirm `flutter analyze` is clean and `flutter test` is fully green on a clean checkout of `029-back-office-sales-orders` **before any change**, and record the pass/fail counts — every later regression, especially in the POS suite, is attributable to this feature from that baseline

**Checkpoint**: Baseline recorded. No other setup exists.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: The extended domain entity, the new repository method, and the shared-editor seam. Nothing in any user story can be built until this phase is done and the POS suite is still green.

**⚠️ CRITICAL**: T012–T016 are the refactor described in [research.md](research.md) §R1. They must land **with every pre-existing POS test passing unmodified** (SC-007). If a POS test needs an assertion changed to go green, stop — the refactor went further than the default-provider decision intended.

### Domain entity

- [ ] T002 [P] Add the `Priority` enum to `lib/features/sales/domain/entities/sale.dart` — four members `low(0)`, `normal(1)`, `high(2)`, `critical(3)` per `mbe-api/app/enums.py:115`, with `fromApi` switching on `value.name` (`number0`…`number3`) falling back to `normal`, and `toApi`; follow the hand-mapping convention `PaymentTerms` and `currencyFromApi` already use in the same file (data-model.md §1.1)
- [ ] T003 Extend the `Sale` freezed class in `lib/features/sales/domain/entities/sale.dart` with `date` (required `DateTime`), `dueDate` (required `DateTime`), `contact` (`int?`), `recipient` (`String?`), `recipientName` (`String?`), `priority` (required `Priority`) and `comment` (`String?`), and map all seven in `Sale.fromResponse` from the fields `SalesOrderResponse` already carries (data-model.md §1; depends on T002)
- [ ] T004 Run `dart run build_runner build --delete-conflicting-outputs` and confirm `sale.freezed.dart` regenerates cleanly (depends on T003)
- [ ] T005 [P] Extend `test/unit/features/sales/sale_mapping_test.dart` with the seven new fields and all four `Priority` members plus the unknown-value fallback, asserting `dueDate` is mapped but never sent (data-model.md §1)

### Repository

- [ ] T006 [P] Declare `listOrders({bool mine, int? facility, int? salesperson, SaleStatus? status, DateTime? dateFrom, DateTime? dateTo, String? search, int skip, int limit})` returning `Future<OpenSalePage>` in `lib/features/sales/domain/repositories/sales_order_repository.dart`, documenting the three server behaviours the caller must respect (unconditional single-facility predicate, non-exclusive `status`, `mine` = creator OR updater OR salesperson) per contracts/mbe-api-sales-orders.md §1
- [ ] T007 Add the optional header parameters `promiseDate`, `salesperson`, `priority`, `comment` and `recipient` to `updateHeader` in `lib/features/sales/domain/repositories/sales_order_repository.dart`, noting that `dueDate` is **derived server-side and must never be sent** (contracts/mbe-api-sales-orders.md §3)
- [ ] T008 Implement `listOrders` in `lib/features/sales/data/sales_order_repository_impl.dart` over the existing generated `listSalesOrdersApiV1SalesOrdersGet`, mapping rows with `OpenSale.fromResponse` and reusing the existing error mapping (depends on T006)
- [ ] T009 Implement the new `updateHeader` parameters in `lib/features/sales/data/sales_order_repository_impl.dart`, passing `Priority.toApi()` for priority and omitting every unset field so a partial update stays partial (depends on T007)
- [ ] T010 [P] Unit-test `listOrders` against a mocked API in `test/unit/features/sales/sales_order_list_orders_test.dart` — parameter pass-through, `OpenSalePage.total`, and that omitting `facility` sends no facility param at all (depends on T008)
- [ ] T011 [P] Unit-test the extended `updateHeader` in `test/unit/features/sales/sales_order_update_header_test.dart` — each new field reaches the request, unset fields are absent, and no request ever carries a due date (depends on T009)

### The shared-editor seam (research §R1)

- [ ] T012 Create `lib/features/sales/presentation/sale_editor.dart` with the `SaleEditor` interface (`ensureOpen`, `updateHeader`, `addLine`, `updateLine`, `removeLine`, `confirm` — the union of what the *shared* widgets call, not of what both controllers do) and `saleEditorProvider`, a `@riverpod` provider whose **default returns `ref.watch(posSaleControllerProvider.notifier)`** (data-model.md §6.1–§6.2)
- [ ] T013 Extract the shared mutation bodies from `lib/features/sales/presentation/pos_sale_controller.dart` into a `SaleEditing` mixin in `lib/features/sales/presentation/sale_editing.dart` — each method calls its repository method and assigns `AsyncValue.data(response)` wholesale, rethrowing on refusal so `state` keeps its last accepted value — and make `PosSaleController` `with SaleEditing implements SaleEditor`, keeping its own `startNew`, `load` and `refresh` (depends on T012)
- [ ] T014 [P] Swap the single POS-singleton read in `lib/features/sales/presentation/capture/customer_bar.dart` (line ~75) to `ref.read(saleEditorProvider)` (depends on T012)
- [ ] T015 [P] Swap the single POS-singleton read in `lib/features/sales/presentation/capture/product_lookup_controller.dart` (line ~26) to `ref.read(saleEditorProvider)`, keeping the "a lookup is one of the actions that opens the sale" comment accurate (depends on T012)
- [ ] T016 [P] Swap the two POS-singleton reads in `lib/features/sales/presentation/capture/sale_line_editing.dart` (lines ~90 and ~189) to `ref.read(saleEditorProvider)`, updating the comment that names `PosSaleController` by name (depends on T012)
- [ ] T017 **Regression gate** — run `flutter test test/widget/features/sales/ test/unit/features/sales/` and confirm every pre-existing POS test passes with **zero edits to any existing test file** (SC-007). Do not proceed past this task until it holds (depends on T013–T016)

**Checkpoint**: The register behaves exactly as before, the domain entity carries every field the back-office screen needs, and the capture widgets can be pointed at a second sale. No new screen exists yet.

---

## Phase 3: User Story 1 - Capture and confirm an order for a customer (Priority: P1) 🎯 MVP

**Goal**: A salesperson reaches Sales Orders from the rail, starts an order, adds priced lines, fills the header, and confirms it into a folio — without a register, a cash session, or the point-of-sale step sequence.

**Independent Test**: Sign in as a salesperson with sales-order create rights, open **Pedidos**, start a new order, add a product, confirm — the order comes back with a folio and a Completed status, and its totals match the confirmed document. Opening the screen and walking away leaves no order behind.

### Entry point

- [ ] T018 [P] [US1] Add `NavBranch.salesOrders = 20` (**appended**, never renumbered) and the `sales-orders` destination — label `l10n.salesOrdersMenuTitle`, icons `Icons.receipt_long_outlined`/`Icons.receipt_long`, route `/sales/orders`, gate `PrivilegeGate(SystemObject.salesOrders, AccessRight.read)` — placed **before** the Point of Sale destination in the Sales group of `lib/core/navigation/nav_destinations.dart` (contracts/routes.md §1)
- [ ] T019 [US1] Add the `/sales/orders` `StatefulShellBranch` **appended last** in `lib/app/router/app_router.dart` (so its positional index matches `NavBranch.salesOrders`), plus the top-level `/sales/orders/new` and `/sales/orders/:orderId` routes, parsing `:orderId` defensively so a non-numeric segment renders the not-found treatment rather than throwing (contracts/routes.md §2; depends on T018)
- [ ] T020 [US1] Add the `startsWith('/sales/orders')` clause to `_gateFor` in `lib/app/router/app_router.dart` returning `PrivilegeGate(SystemObject.salesOrders, AccessRight.read)` — deliberately **not** `SystemObject.pos`, and as its own clause rather than widening an existing one (contracts/routes.md §3; depends on T019)
- [ ] T021 [P] [US1] Router test in `test/unit/app/router/app_router_test.dart` asserting all three `/sales/orders*` paths are gated on `salesOrders` read (a user with only `pos` is redirected), and that `AppShell.navigationShell.currentIndex` resolves to the sales-orders branch for `/sales/orders` — the assertion standing between a renumbering slip and a silently wrong screen

### The order controller

- [ ] T022 [US1] Create `lib/features/sales/presentation/orders/order_editor_controller.dart` — a `@riverpod` autoDispose family keyed by `int? orderId`, `with SaleEditing implements SaleEditor`, whose `build` returns `null` for `null` (writing **nothing** on mount) and `getById(saleId: id)` for an existing order (data-model.md §5.2; depends on T013)
- [ ] T023 [P] [US1] Unit-test `orderEditorController` in `test/unit/features/sales/order_editor_controller_test.dart` — `build(null)` issues no request; the first `addLine` opens the order then adds the line; a refused mutation leaves state at its last accepted value and rethrows (SC-005, FR-028; depends on T022)

### The order screen

- [ ] T024 [US1] Create `lib/features/sales/presentation/orders/order_screen.dart` — `Scaffold` with an empty `AppBar.actions` (constitution §VI), wrapping its body in a nested `ProviderScope` that overrides `saleEditorProvider` with `orderEditorController(orderId)`, and composing `ErrorBanner`, the header panel, `CustomerBar`, `ProductSearchField`, the line rows/cards, `SaleTotalsBar` and `RecordFormActions` (contracts/sales-orders-screen.md §2.1; depends on T022)
- [ ] T025 [US1] Create `lib/features/sales/presentation/orders/order_header_panel.dart` laying out the header fields in a `ResponsiveFormGrid` per contracts/sales-orders-screen.md §2.2 — read-only reference, status, date, **due date**, exchange rate and terms; editable promise date (date picker), currency, priority, salesperson (`CatalogEntityPicker<EmployeeListItem>` with `salesPerson: true`), contact (`CustomerContactPicker`), ship-to (`CustomerAddressPicker`), fiscal recipient (`CatalogEntityPicker` over taxpayer recipients, showing `recipientName` beneath) and a multiline comment — each edit one `updateHeader` call, no batching Save button (depends on T024)
- [ ] T026 [P] [US1] Add an opt-in `bool showComment` (default `false`) to `lib/features/sales/presentation/capture/sale_line_row.dart` and `lib/features/sales/presentation/capture/sale_line_card.dart`, rendering `SaleLine.comment` as an editable field routed through the existing `SaleLineEditing.update` path only when true — the register passes nothing and is untouched (research §R9.2)
- [ ] T027 [US1] Wire confirm into `order_screen.dart`: disabled until `lineCount > 0` (FR-023), rendering a refusal's every named line in the banner without leaving the screen (FR-024), and flipping the screen to its read-only face with the folio shown on success (FR-025) (depends on T024)
- [ ] T028 [P] [US1] Create `lib/features/sales/presentation/orders/order_no_register_notice.dart` — the FR-014 blocked state, reading `registerPointSaleProvider` and naming the missing `user_settings.point_sale` setting and who can set it; it replaces the create action only, never the list or an open order (contracts/sales-orders-screen.md §2.6)

### The list, default view only

- [ ] T029 [US1] Create `lib/features/sales/presentation/orders/sales_orders_list_controller.dart` with the `SalesOrdersFilter` freezed value and its `fromQuery(ListQuery, {required DateTime today, required bool isAdministrator})`, defaulting the range to the **current calendar month** with `today` truncated to a calendar date before use — an untruncated anchor makes the family never reuse an instance and the list spins forever (data-model.md §4.1, research §R5)
- [ ] T030 [US1] Add the `salesOrdersListController(SalesOrdersFilter)` `@riverpod` family to the same file, building the request with `mine: !isAdministrator` and dropping `facility`/`salesperson` for a non-administrator — read from `access.isAdministrator`, **never** from URL state (data-model.md §5.1, FR-006; depends on T029)
- [ ] T031 [US1] Create `lib/features/sales/presentation/orders/sales_orders_list_screen.dart` with `CatalogFilterBar` (New order action only, for now), `CatalogListStateView<OpenSale>` over a `DataTableView` with the six columns of contracts/sales-orders-screen.md §1.2, and `CatalogPagination`; the whole row opens the order (depends on T030)
- [ ] T032 [US1] Add the full-screen "no facility configured" blocked state to `sales_orders_list_screen.dart` — **no request is issued at all** in that state, distinguishing it from an empty result (spec Edge Cases; depends on T031)
- [ ] T033 [P] [US1] Add the US1 strings to `lib/l10n/app_es.arb` **first**, then `lib/l10n/app_en.arb` — menu title, screen title, the six column headers, New order, the four priority labels, every header field label, the no-register and no-facility notices — then run `flutter gen-l10n`

### Tests for User Story 1

- [ ] T034 [P] [US1] Widget test in `test/widget/features/sales/order_screen_test.dart` — mounting `/sales/orders/new` issues **zero** writes; the first added line opens the order and the URL/state carries its id; the header fields each issue exactly one `updateHeader`; confirm is disabled with no lines and enabled with one; a refused confirm names every offending line and leaves the order a draft
- [ ] T035 [P] [US1] Widget test in `test/widget/features/sales/sale_editor_isolation_test.dart` proving an order open on `/sales/orders/:id` and a sale held by the register are two independent `Sale`s — mutating one leaves the other untouched (FR-030, the refactor's worst failure mode)
- [ ] T036 [P] [US1] Widget test in `test/widget/features/sales/sales_orders_list_screen_test.dart` for the default view — six columns, newest-first order, row click opens the order, and the no-facility state issuing no request
- [ ] T037 [P] [US1] Widget test in `test/widget/features/sales/order_no_register_test.dart` — with no configured register the list still loads and an order still opens, but the create action is replaced by the notice and **no request 422s** (FR-014)

**Checkpoint**: US1 is shippable. A salesperson can find the screen, capture an order and confirm it. Filtering, cancelling and the admin facets do not exist yet.

---

## Phase 4: User Story 2 - Resume, amend or abandon a draft (Priority: P2)

**Goal**: A draft survives being left; it can be reopened, edited, confirmed later, or cancelled.

**Independent Test**: Create a draft, navigate away, reopen it from the list, change a line, reload — the change stuck. Cancel a draft and confirm it becomes Cancelled and read-only.

- [ ] T038 [US2] Add the Edit row action to `lib/features/sales/presentation/orders/sales_orders_list_screen.dart` using `catalog_action_icons.dart`, visible **only** for drafts and only with `can(salesOrders, update)` — the single direct row action, with the whole row still opening the order read-only (constitution §VI, contracts/routes.md §5)
- [ ] T039 [US2] Add the cancel action to `lib/features/sales/presentation/orders/order_screen.dart` via `RecordFormActions` — on the order's own screen only, behind an explicit confirmation dialog, with a server refusal (paid order, live payments, already cancelled) rendered in the same banner (FR-026)
- [ ] T040 [US2] Handle the stale-draft case in `order_screen.dart`: a mutation refused because the order is no longer editable re-reads the order and re-renders its true state rather than leaving stale controls (spec US2 scenario 5, Edge Cases)
- [ ] T041 [P] [US2] Add the US2 strings (cancel action, confirmation dialog title/body/confirm, the stale-state message) to `lib/l10n/app_es.arb` then `lib/l10n/app_en.arb`, and run `flutter gen-l10n`
- [ ] T042 [P] [US2] Widget test in `test/widget/features/sales/order_resume_test.dart` — reopening an existing order loads header and lines editable; removing the last line leaves a zero-total draft with confirm unavailable; a stale draft's refused edit refreshes to the confirmed state
- [ ] T043 [P] [US2] Widget test in `test/widget/features/sales/order_cancel_test.dart` — cancel requires the dialog, a confirmed cancel flips status and read-only mode, and a refused cancel keeps the order untouched with the message shown

**Checkpoint**: The full draft lifecycle works. US1 and US2 together are the working feature for a single salesperson.

---

## Phase 5: User Story 3 - Find an order (Priority: P2)

**Goal**: Search by folio or customer, narrow by date range and status, page through the result — all addressable and shareable.

**Independent Test**: With more than one page of orders, apply each facet and the search box in turn and confirm the rows, the total count and the page controls agree, and that copying the URL reproduces the view exactly.

- [ ] T044 [US3] Add `CatalogSearchBar` to `lib/features/sales/presentation/orders/sales_orders_list_screen.dart`, wired to `ListQuery.search` — numeric terms match id or folio and text terms match the customer name, both **server-side**; nothing is filtered client-side (FR-007)
- [ ] T045 [US3] Create `lib/features/sales/presentation/orders/sales_orders_filters_panel.dart` with the date-range and status facets, shown through `showCatalogFilterSheet` behind a badged `IconButton.outlined(Icons.tune)` — no inline chips, pickers or menus anywhere in the filter row (constitution §VI rule (a), contracts/sales-orders-screen.md §1.3)
- [ ] T046 [US3] Wire `onClearAll` to clear `date-from`, `date-to` and `status` and reset to page 0, returning the range to the **current month — never to unbounded** (FR-009; depends on T045)
- [ ] T047 [US3] Complete the four list states in `sales_orders_list_screen.dart` — loading, error with Retry invalidating the page provider, empty-unfiltered, and empty-filtered with Clear filters — driving `isFiltered` from "range is not the default month, or any facet or search term is set" (FR-013)
- [ ] T048 [US3] Confirm page clamping in `sales_orders_list_controller.dart`: a page index past the last page shows the last available page rather than a blank list (FR-010)
- [ ] T049 [P] [US3] Add the US3 strings (search placeholder, filter labels, status facet labels, both empty-state messages) to `lib/l10n/app_es.arb` then `lib/l10n/app_en.arb`, and run `flutter gen-l10n`
- [ ] T050 [P] [US3] Unit test in `test/unit/features/sales/sales_orders_filter_test.dart` — month default, `yyyy-MM-dd` round-trip, unparseable values degrading to defaults rather than throwing, `activeFilterCount` excluding `search`, and that the `today` anchor is date-truncated (the confirmed infinite-loop trap, research §R5)
- [ ] T051 [P] [US3] Widget test in `test/widget/features/sales/sales_orders_filters_test.dart` — each facet narrows the list and appears in the address, the badge counts active facets, clear-all returns to the month, and an out-of-range page clamps

**Checkpoint**: The list is complete for an ordinary user.

---

## Phase 6: User Story 4 - Read a finished order (Priority: P3)

**Goal**: A confirmed, paid or cancelled order reads cleanly, with priority the one thing still changeable and every mutating affordance absent for a read-only user.

**Independent Test**: Open a paid order — everything read-only, balance and paid state visible, priority still editable. Sign in read-only — no create, edit, confirm or cancel affordance anywhere.

> Partly seeded by US1, whose confirm already flips the screen to a read-only face. This story completes it.

- [ ] T052 [US4] Complete read-only mode in `lib/features/sales/presentation/orders/order_screen.dart` and `order_header_panel.dart` — `!sale.isEditable` disables every control, add-line/remove-line/confirm/cancel are **absent rather than disabled**, and priority alone ignores the flag (FR-027, contracts/sales-orders-screen.md §2.5)
- [ ] T053 [US4] Render the payment facts an order carries — outstanding balance and paid state — on the order screen without leaving it, reading them off the `Sale` the server already returns (FR-026; no payments endpoint is called, OS-2)
- [ ] T054 [US4] Gate every mutating affordance in `order_screen.dart`, `order_header_panel.dart` and `sales_orders_list_screen.dart` on `can(salesOrders, create|update)`, hidden not disabled (constitution §IV, contracts/routes.md §5)
- [ ] T055 [US4] Resolve the duplicate terms control: the header grid shows payment terms **read-only** while `CustomerBar` keeps the live control, so two controls never race each other through `updateHeader` (contracts/sales-orders-screen.md §2.5)
- [ ] T056 [P] [US4] Widget test in `test/widget/features/sales/order_screen_readonly_test.dart` — a confirmed order is read-only **except priority**; a cancelled one offers nothing; a read-only user sees no create, edit, confirm or cancel affordance on either screen

**Checkpoint**: Every order state reads correctly for every privilege level.

---

## Phase 7: User Story 5 - Supervise everyone's orders (Priority: P3)

**Goal**: An administrator sees every user's orders and can narrow by salesperson or switch facility — while an ordinary user provably cannot, whatever the address says.

**Independent Test**: As an administrator, confirm other users' orders are listed and both facets work and appear in the address with resolved names. As an ordinary user, paste the administrator's filtered URL and confirm only your own orders come back.

- [ ] T057 [US5] Decode the `salesperson` and `facility` facets in `SalesOrdersFilter.fromQuery` **only when `isAdministrator`** — a non-administrator's filter carries neither, whatever the URL says; this is where the hand-edited-address edge case is closed, not in the drawer (data-model.md §4.1, FR-006)
- [ ] T058 [US5] Add the salesperson and facility facets to `lib/features/sales/presentation/orders/sales_orders_filters_panel.dart` as `CatalogEntityPicker`s over `employeeRepositoryProvider.list(salesPerson: true)` and `facilityRepositoryProvider`, each seeded from `employeeDisplayNameProvider` / `facilityDisplayNameProvider` so a facet arriving as a bare id still renders a name — rendered only for an administrator, and both counted in the badge (contracts/sales-orders-screen.md §1.3; copy `cash_sessions_screen.dart:475-535`)
- [ ] T059 [US5] Include both new facets in `onClearAll` and in `activeFilterCount` in `sales_orders_list_controller.dart` and the filters panel (depends on T057, T058)
- [ ] T060 [US5] Tell an administrator viewing another facility that a new order is created in **their own** facility, before they start — the facility comes from the token, never the request body (US5 scenario 4, contracts/mbe-api-sales-orders.md §2)
- [ ] T061 [P] [US5] Add the US5 strings (both facet labels, the "everyone" salesperson default, the cross-facility creation notice) to `lib/l10n/app_es.arb` then `lib/l10n/app_en.arb`, and run `flutter gen-l10n`
- [ ] T062 [P] [US5] Unit test in `test/unit/features/sales/sales_orders_scoping_test.dart` — `mine` is `true` for an ordinary user and `false` for an administrator; `salesperson`/`facility` present **in the URL** are dropped before the request is built for a non-administrator (SC-009)
- [ ] T063 [P] [US5] Widget test in `test/widget/features/sales/sales_orders_admin_facets_test.dart` — the two facets are present for an administrator and absent for an ordinary user, resolve ids to names, and appear in the address

**Checkpoint**: All five stories are independently functional.

---

## Phase 8: Polish & Cross-Cutting Concerns

- [ ] T064 [P] Compact-tier widget test in `test/widget/features/sales/sales_orders_compact_test.dart` — the list degrades to the established card treatment and the order screen's header grid collapses to one column, with **no horizontal scrolling of the page body** at 390 px (FR-034, constitution §VI)
- [ ] T065 [P] Confirm `test/unit/core/l10n_parity_test.dart` passes — both `.arb` files in parity, `es-MX` authored first for every key added in T033, T041, T049 and T061
- [ ] T066 Audit the feature's new files for formatting violations: no `DateFormat`, no `toStringAsFixed`, no hand-built percentage strings — every date, money and percentage through `formattersProvider` (constitution §V, spec 028)
- [ ] T067 Live golden-path test in `test/integration/sales_orders_flow_test.dart` — create, add a line, confirm, then find the order in the list; discovers its fixtures at runtime, never hard-coded ids, and skips cleanly without `.env` credentials like its siblings. Record as comments in the test what it settles: whether `date_to` includes its own day, and that `mine=true` really matches creator **and** updater **and** salesperson
- [ ] T068 Re-run the full suite and `flutter analyze`; confirm against T001's baseline that **no pre-existing test file was modified** (SC-007) and nothing regressed
- [ ] T069 Walk [quickstart.md](quickstart.md)'s manual validation for all five stories with all four accounts, at both the expanded and compact width tiers

---

## Dependencies & Execution Order

### Phase dependencies

- **Phase 1 (Setup)** — no dependencies.
- **Phase 2 (Foundational)** — depends on Phase 1. **Blocks every user story.** T017 is a hard gate.
- **Phase 3 (US1, P1)** — depends on Phase 2. Delivers the MVP.
- **Phase 4 (US2, P2)** — depends on Phase 3 (the order screen and the list must exist).
- **Phase 5 (US3, P2)** — depends on Phase 3's list (T029–T031). **Independent of Phase 4.**
- **Phase 6 (US4, P3)** — depends on Phase 3's order screen. Independent of Phases 4 and 5.
- **Phase 7 (US5, P3)** — depends on Phase 5's filters panel (T045). Independent of Phases 4 and 6.
- **Phase 8 (Polish)** — depends on every story you intend to ship.

### Within Phase 2

`T002 → T003 → T004` (entity, then codegen) and `T006/T007 → T008/T009 → T010/T011` (repository) are two independent chains that can run in parallel. `T012 → T013 → T014/T015/T016 → T017` is the third and is the one that must not be rushed.

### Parallel opportunities

- **Phase 2**: the entity chain, the repository chain and the editor chain are three independent tracks. Within them, T005, T010, T011 and T014–T016 are all `[P]`.
- **Phase 3**: T018/T021 (navigation), T026 (the line comment flag), T028 (the notice) and T033 (strings) are independent of the order-screen chain T022→T024→T025→T027. All four US1 test tasks (T034–T037) are `[P]`.
- **After Phase 3**: US2, US3 and US4 can be worked simultaneously by three people; US5 joins once T045 lands.
- **Every `.arb` task** (T033, T041, T049, T061) is `[P]` within its phase but the four must not run concurrently with each other — they edit the same two files.

## Implementation Strategy

**MVP = Phase 1 + Phase 2 + Phase 3 (US1).** That is a salesperson capturing and confirming an order without a register — the feature's whole reason to exist. It ships with a working list (default view, own orders, current month) but no search, no facets, no cancel.

**Increment 2 = US2 + US3.** The draft lifecycle and finding an order. After this the feature is complete for the salespeople it was built for.

**Increment 3 = US4 + US5.** Read-only polish across privilege levels, and supervision.

**The one thing not to defer**: T017. Every later phase builds on the assumption that the register still works; discovering otherwise in Phase 7 means unwinding four phases of work.
