# Tasks: Bulk Pricing Grid

**Input**: Design documents from `/specs/033-bulk-pricing-grid/`
**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md), [data-model.md](data-model.md), [contracts/](contracts/), [quickstart.md](quickstart.md)

**Tests**: Included. The constitution mandates unit/widget/integration coverage, and three success criteria (SC-006 constant request count, SC-004 any change including a bulk action reverses in one step, SC-007 a read-only user reaches no editing affordance) are only verifiable with tests.

**Organization**: Phase 2 is a genuine blocker — every story reads the batched price fetch and the grid's shared state shape. After that, every remaining story is buildable.

> **Revised 2026-08-29 — mbe-api#182–#185 all landed** (`98d3254`). **US2 and US3 are unblocked**; their phases below were single blocking tasks and are now real task lists. **US7's gate (T049) resolves to outcome (a)** — the margin validation was retired outright and all four profit fields deprecated, so the price-list form/list removal may proceed. Tasks whose wording assumed a missing endpoint are corrected in place, with the original intent noted where it explains a choice.

**Note on US7**: two of its removals (the standalone pricing screen's profit columns/dialog) were always safe. The price-list form/list removal was gated on #185's direction, because relocating the band onto the price list's own margins would have un-deprecated the exact fields that phase removes. **That gate is now answered — proceed.**

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: US1–US7, matching [spec.md](spec.md)
- Every task names an exact file path from the repo root

## Path Conventions

Flutter application, single project. `lib/` for source, `test/` for tests, both at repo root (plan.md Project Structure). Generated companions (`*.g.dart`, `*.freezed.dart`) are produced by `dart run build_runner build --delete-conflicting-outputs` and are never hand-edited.

---

## Phase 1: Setup

**Purpose**: Nothing to initialize — this feature adds files to an already-configured project and introduces no dependency, script or tool.

- [X] T001 Confirm `flutter analyze` is clean and `flutter test` is fully green on a clean checkout of `033-bulk-pricing-grid` **before any change**, and record the pass/fail counts — every later regression is attributable to this feature from that baseline

**Checkpoint**: Baseline recorded. No other setup exists.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: The batched price read, the grid's shared state shapes, and the shared table's width escape hatch. Nothing in any grid-facing story (US1–US5) can be built until this phase is done.

**⚠️ CRITICAL** *(historical — resolved)*: T004's read path shipped as a deliberate fan-out, so that the only thing #182 changed was the body of one method. #182 has since landed and that collapse has happened: `listForProducts` is one request, its signature and call site untouched. The seam did its job; leave it in place.

### Repository

- [X] T002 [P] Declare `listForProducts({required List<int> productIds, required List<int> priceListIds})` returning `Future<List<ProductPrice>>` in `lib/features/pricing/domain/repositories/product_price_repository.dart`, documenting the batching (it shipped as a fan-out and collapsed to one request when mbe-api#182 landed) and the `kProductPriceBulkLimit` bound (contracts/mbe-api-pricing.md §4)
- [X] T003 [P] Extend `create`/`update` doc comments in `lib/features/pricing/domain/repositories/product_price_repository.dart` to note the profit-band rule new callers must follow (research.md §R6). **Since #185 both margins are optional and deprecated** — the signature now takes `String?` and omits them by default, so a caller sends the price alone
- [X] T004 Implement `listForProducts` in `lib/features/pricing/data/product_price_repository_impl.dart` (empty `productIds` returns `[]` without a request) (depends on T002). **Shipped as a `Future.wait` fan-out; collapsed to one request with a repeated `product` param when mbe-api#182 landed** — signature and call site unchanged, as designed
- [X] T005 [P] Unit-test `listForProducts` in `test/unit/features/pricing/product_price_repository_impl_test.dart` — **one** request repeating `product` (asserting dio's `ListParam` value *and* `ListFormat.multi`, since CSV would not parse server-side), a `limit` of `kProductPriceBulkLimit`, filtering by the given price-list ids, and zero requests for an empty product list (depends on T004)

### Shared table width

- [X] T006 [P] Add an optional `minWidth` parameter to `DataTableView` in `lib/core/widgets/data_table_view.dart`, threading it into both the `PaginatedDataTable2` and `DataTable2` constructors so a wide column set scrolls within the table's own region rather than the page (research.md §R2, constitution §VI)
- [X] T007 [P] Widget-test the new parameter in `test/widget/core/widgets/data_table_view_test.dart` — a `minWidth` wider than the viewport produces a horizontally scrollable table with the page itself unaffected (depends on T006)

### Grid state shapes

- [X] T008 [P] Create `lib/features/pricing/presentation/pricing_grid_row.dart` with the `PricingGridRow` freezed class (`product: ProductListItem`, `prices: Map<int, ProductPrice>`) and `buildPricingGridRows({products, prices})`, mirroring `product_price_row.dart`'s join helper (data-model.md §2)
- [X] T009 [P] Create `lib/features/pricing/domain/entities/price_cell_key.dart` with the `PriceCellKey` freezed class (`productId`, `priceListId`) (data-model.md §3)
- [X] T010 Create `lib/features/pricing/presentation/pricing_grid_controller.dart` with `PricingGridFilter` (built from `ListQuery` exactly as `ProductFilter.fromQuery` is, plus `missingPriceList`, which stayed `null` until US2's Phase 4 wired it — data-model.md §7), `RejectedEdit`, `PriceChangeKind`, `PriceWrite`, `PriceChange`, and `PricingGridState` (data-model.md §4–§6), with no controller logic yet (depends on T008, T009)
- [X] T011 Run `dart run build_runner build --delete-conflicting-outputs` and confirm every new freezed file regenerates cleanly (depends on T010)
- [X] T012 [P] Unit-test `buildPricingGridRows` in `test/unit/features/pricing/pricing_grid_row_test.dart` — a product with no matching price is absent from its `prices` map (not present with a null value), proving "not set" is representable (FR-005; depends on T008)
- [X] T013 [P] Unit-test `PricingGridFilter.fromQuery` in `test/unit/features/pricing/pricing_grid_controller_test.dart` — round-trips every facet the products filter drawer already covers, and `missingPriceList` is `null` while unwired (superseded by T030e, which reads it from the `missing` facet) (depends on T010, T011)

**Checkpoint**: The batched read exists and is tested, the shared table can be told to scroll internally, and the grid's state types compile. No screen exists yet.

---

## Phase 3: User Story 1 - See and edit many products' prices at once (Priority: P1) 🎯 MVP

**Goal**: `/pricing` renders a paginated grid with no product selection required, and a user with update rights can click any cell, type a price, and have it saved.

**Independent Test**: Open `/pricing` with no product selected — a populated grid renders; change a price and re-read it after a reload.

### The controller

- [X] T014 [US1] Implement `PricingGridController` (`@riverpod` family keyed by `PricingGridFilter`) in `lib/features/pricing/presentation/pricing_grid_controller.dart` — loads a page of `ProductListItem` via the existing `ProductRepository.list`, the full price-list set via `PriceListRepository.list(limit: 100)`, and prices for that page via `listForProducts` scoped to the **shown** columns only (research.md §R5's cap note), joining with `buildPricingGridRows` (depends on T004, T010, T011)
- [X] T015 [US1] Add `commitCell({productId, priceListId, typed})` to `PricingGridController` — parses via `fmt.input.parsePrice`/`PricingValidators.isNonNegativeDecimal`; on parse failure sets `rejected[key]` and issues no request (FR-009); on a value equal to the stored price, issues no request (FR-010); otherwise routes to `create` or `update` sending **the price alone**, marking the cell `inFlight` for the duration and appending one single-write `PriceChange` to `history` on success (depends on T014; contracts/mbe-api-pricing.md §5). *(Originally carried research.md §R6's client-side profit-band rule; #185 moved that default server-side and `_bandFor` was deleted.)*
- [X] T016 [US1] Add `retry()` to `PricingGridController` re-issuing the current page's load unchanged, mirroring `PricingController.retry` (depends on T014)
- [X] T017 [P] [US1] Unit-test `commitCell`'s three outcomes (rejected, no-op on unchanged value, accepted) in `test/unit/features/pricing/pricing_grid_controller_test.dart` (depends on T015)
- [X] T018 [P] [US1] Unit-test the create-vs-update routing in `test/unit/features/pricing/pricing_grid_controller_test.dart` — both paths send the price and **name no profit band at all**, since #185 defaults it server-side on create and leaves it alone on update (depends on T015; research.md §R6)

### The cell widget

- [X] T019 [US1] Create `lib/features/pricing/presentation/price_cell.dart` — a `StatefulWidget` holding a plain `TextEditingController`/`FocusNode` (created/disposed in `State`, never in Riverpod, per research.md §R3), rendering the reading state (`fmt.display.currency`, or the existing "not set" treatment for FR-005) and, when active, an editable `TextField` whose commit calls `PricingGridController.commitCell` — **not** `ConfirmableFieldController`/`ConfirmableTextField` as originally planned; corrected during implementation because that controller discards a rejected value instead of keeping it flagged (research.md §R3) (contracts/pricing-grid-screen.md §1–§3)
- [X] T020 [US1] Wire keyboard traversal on `PriceCell`'s `Focus` — Enter (commit, open same column next row), Tab/Shift+Tab (commit, open next/previous column, wrapping at row ends), ArrowUp/Down (commit, open same column adjacent row), ArrowRight/Left only at caret end/start (commit, move one column), Escape (discard, no commit) — every handler returns `KeyEventResult.handled` (research.md §R4; contracts/pricing-grid-screen.md §2; depends on T019). Movement resolution (which cell is "next") lives in the grid screen, which owns the row/column order — `PriceCell` only reports the direction via `onMove`.
- [X] T021 [P] [US1] Widget-test `PriceCell` in `test/widget/features/pricing/price_cell_test.dart` against contracts/pricing-grid-screen.md §2's full input table (depends on T020)

### The screen

- [X] T022 [US1] Create `lib/features/pricing/presentation/pricing_grid_screen.dart` — `CatalogFilterBar` (search + badged filter button) → `DataTableView<PricingGridRow>(minWidth: …)` with photo/code+copy/name columns plus one `PriceCell`-backed column per shown price list → `CatalogPagination` → hint line, following `products_list_screen.dart`'s structure (depends on T006, T019, T022 n/a — self)
- [X] T023 [US1] Wire the empty/error/filtered-empty states via the existing `CatalogListStateView`/`ListFailedView`/`ListEmptyView` (no price lists → reuse `pricingNoPriceListsEmptyState`) (contracts/pricing-grid-screen.md §4; depends on T022)
- [X] T024 [US1] Ellipsize the name column with a hover tooltip fallback, matching `products_list_screen.dart`'s pattern (constitution §VI; depends on T022)
- [X] T025 [P] [US1] Add `l10n` keys for the grid (screen hint, "not set" reuse, any new labels) to `lib/l10n/app_es.arb` first, then `lib/l10n/app_en.arb`
- [X] T026 [P] [US1] Widget-test `PricingGridScreen` in `test/widget/features/pricing/pricing_grid_screen_test.dart` — renders with no product selected (FR-001), a page of rows with one column per shown list, and the "not set" vs `$0.00` distinction (FR-005) (depends on T022, T023, T025)

### Routing

- [X] T027 [US1] Replace `PricingScreen(standalone: false)` at `/pricing` with `PricingGridScreen` in `lib/app/router/app_router.dart`, keeping the existing `PrivilegeGate(SystemObject.pricing, AccessRight.read)` clause unchanged (contracts/routes.md §2; depends on T022)
- [X] T028 [US1] Remove the `!standalone` picker branch and the `standalone` parameter from `PricingScreen` in `lib/features/pricing/presentation/pricing_screen.dart`, making `initialProductId`/`initialProductDisplayText` required, and update its call site at `/products/:productId/pricing` in `lib/app/router/app_router.dart` accordingly (research.md §R1; depends on T027)
- [X] T029 [P] [US1] Update `test/widget/features/pricing/pricing_screen_test.dart` to drop the picker-mode assertions, keeping only the standalone-mode ones (depends on T028)

**Checkpoint**: `/pricing` is the grid. A user with update rights can read and edit any price; `/products/:productId/pricing` still works unchanged.

---

## Phase 4: User Story 2 - Find what still needs pricing (Priority: P1)

**Goal**: worklist chips ("All products" + one "Missing «list» (count)" per shown list) narrow the grid to unpriced products.

**Independent Test**: with at least one product unpriced on a list, that list's chip shows a non-zero count and selecting it shows only unpriced rows.

✅ **Unblocked — mbe-api#184 landed.** `GET /products?missing_price_list=` and `GET /products/prices/missing-facets` both exist, and `missingPriceList` is already wired through `ProductRepository.list` (done while reconciling the API change; pinned by `repository_list_params_audit_test.dart`).

⚠️ **`0` is a real price list id** (`Costo`). Every check on a price-list id in this phase MUST test for null, never for falsiness, or the cost list's chip silently vanishes (FR-019a).

- [X] T030 [US2] ~~Confirm the grid renders no worklist chip row~~ — **superseded by T030h**, which replaced the absence assertion with the real chip tests when mbe-api#184 landed (as this task anticipated)
- [X] T030a [P] [US2] Declare `productMissingPriceFacets({search, status, stockable, salable, purchasable, supplier, labels})` returning `Future<List<ProductMissingPriceFacet>>` in `lib/features/catalog/domain/repositories/product_repository.dart`, mirroring the existing `productLabelFacets` declaration (contracts/mbe-api-pricing.md §2)
- [X] T030b [US2] Add a `ProductMissingPriceFacet` domain entity (`priceListId`, `missingCount`) in `lib/features/catalog/domain/entities/`, mapped from the generated `ProductMissingPriceFacet`, mirroring `product_label_facet.dart` (depends on T030a)
- [X] T030c [US2] Implement `productMissingPriceFacets` in `lib/features/catalog/data/product_repository_impl.dart` over `getProductMissingPriceFacetsApiV1ProductsPricesMissingFacetsGet` (depends on T030a, T030b)
- [X] T030d [P] [US2] Unit-test the facet call in `test/unit/features/catalog/product_repository_impl_test.dart` — filter pass-through and mapping, including a list whose `missing_count` is `0` and a `price_list` of `0` (depends on T030c)
- [X] T030e [US2] Read `missingPriceList` from the URL in `PricingGridFilter.fromQuery` (facet key `missing`), pass it to `ProductRepository.list` in `PricingGridController._fetchPage`, and drop the "always null" comment (FR-017, FR-019a; depends on T030c)
- [X] T030f [US2] Add a `pricingGridMissingFacets` provider keyed by the filter, `autoDispose`, reading `productMissingPriceFacets` — `valueOrNull == null` (loading/error) means "counts unknown", which renders no chips rather than zeroed ones (FR-019; depends on T030c)
- [X] T030g [US2] Render the chip row in `lib/features/pricing/presentation/pricing_grid_screen.dart` above the grid — an "All products" chip plus one per **shown** price list with its count, keys `pricing_grid_worklist_all` / `pricing_grid_worklist_<priceListId>`, each navigating via `context.go` so it participates in back/forward and clear-all (FR-017, FR-018; depends on T030e, T030f)
- [X] T030h [P] [US2] Widget-test the chips in `test/widget/features/pricing/pricing_grid_screen_test.dart` — counts render, selecting one narrows the grid and marks that chip selected, the count falls after pricing a row, a facet failure renders no chips at all, and a price list with id `0` still gets its chip (FR-017–FR-019a; depends on T030g). **Replaces T030's absence assertion** — delete that assertion in the same change rather than leaving both

**Checkpoint**: "what still needs pricing?" is answerable from the screen in one click, with the count visible before clicking (SC-005).

---

## Phase 5: User Story 3 - Move a whole price list in one action (Priority: P2)

**Goal**: a column ⋮ menu offers fill-down, copy-from-cost, and adjust-by-percent, each atomic and one undo.

**Independent Test**: with a filtered set of rows on screen, apply a percentage adjustment to one column — every shown row in that column moved, and no row outside the shown set did.

✅ **Unblocked — mbe-api#183 landed.** `PUT /product-prices` upserts a page in one transaction keyed on `(product, price_list)`, so FR-015's all-or-nothing guarantee is reachable without any client-side rollback.

⚠️ **Three server rules this phase must respect** (contracts/mbe-api-pricing.md §6): a repeated `(product, price_list)` in one body is a **400**, so a column action must de-duplicate by cell before sending; the body is capped at **500** items; and every id is validated up front, so one bad id refuses the whole body.

- [X] T031 [US3] ~~Confirm the grid renders no column ⋮ menu~~ — **superseded by T031i**, which replaced the absence assertion with the real menu tests when mbe-api#183 landed
- [X] T031a [P] [US3] Declare `applyPriceChanges(List<PriceWrite> writes)` returning `Future<List<ProductPrice>>` in `lib/features/pricing/domain/repositories/product_price_repository.dart`, documenting the duplicate-pair 400 and the 500-item cap (contracts/mbe-api-pricing.md §6)
- [X] T031b [US3] Implement it in `lib/features/pricing/data/product_price_repository_impl.dart` over `bulkUpsertProductPricesApiV1ProductPricesPut`, sending `price` alone per item (the profit band defaults server-side, research.md §R6) (depends on T031a)
- [X] T031c [P] [US3] Unit-test the bulk write in `test/unit/features/pricing/product_price_repository_impl_test.dart` — body shape and decimal-string encoding, no profit fields sent, a 400 on a duplicate pair mapping to a domain error, and the whole-body-or-nothing response mapping (depends on T031b)
- [X] T031d [US3] Add `fillDown`, `copyFromCostList` and `adjustByPercent` to `PricingGridController`, each computing its writes over the **currently shown rows only**, de-duplicating by `PriceCellKey`, skipping cells the action cannot act on (an unpriced cell has nothing to adjust — never created at `0`), issuing one `applyPriceChanges`, and appending **one** `PriceChange` carrying every write (FR-013–FR-016; depends on T031b)
- [X] T031e [US3] Resolve the cost list from the deployment's configured cost price list; when that setting names no existing list, the copy-from-cost action MUST be absent rather than broken (FR-013; depends on T031d)
- [X] T031f [US3] Render the column ⋮ menu in `lib/features/pricing/presentation/pricing_grid_screen.dart` — key `pricing_grid_column_menu_<priceListId>`, shown only with update rights (FR-013, FR-026), with the percent input and Apply for the adjust action (depends on T031d)
- [X] T031g [US3] Report how many rows each action changed, through the shared feedback mechanism (FR-014; depends on T031f)
- [X] T031h [P] [US3] Unit-test each action in `test/unit/features/pricing/pricing_grid_controller_test.dart` — shown rows only, skipped cells, one `PriceChange` per action regardless of row count, and a failure leaving no row changed (FR-014–FR-016, SC-004; depends on T031d)
- [X] T031i [P] [US3] Widget-test the menu in `test/widget/features/pricing/pricing_grid_screen_test.dart` — present with update rights, absent without, and each action reachable (depends on T031f). **Replaces T031's absence assertion**

**Checkpoint**: repricing a filtered set on one list is one action, one undo, and all-or-nothing (SC-002).

---

## Phase 6: User Story 4 - Trust what just happened, and take it back (Priority: P2)

**Goal**: every touched cell shows saving/saved/rejected; a summary bar counts changes and rejections; undo-last and revert-all both work, with a column action (once US3 ships) reversing as a single unit.

**Independent Test**: Change three cells, then undo — each reverses individually; "revert all" restores every price to the view's load-time baseline.

- [X] T032 [US4] Add per-cell badge rendering to `PriceCell` — saving while `inFlight`, saved + "was X" tooltip while `baseline[key] != current`, rejected + reason on hover while `rejected[key]` is set (contracts/pricing-grid-screen.md §3; depends on T019, T014)
- [X] T033 [US4] Add `undoLast()` and `revertAll()` to `PricingGridController` — `undoLast` pops the newest `PriceChange` and re-issues writes restoring every `PriceWrite.previous` in it as **one** operation regardless of how many writes it holds (FR-016, FR-024); `revertAll` does the same for every cell against `baseline` and clears `history`/`rejected` (data-model.md §5; depends on T015)
- [X] T034 [US4] Wire `⌘Z`/`Ctrl+Z` to `undoLast()` via a `Shortcuts`/`Actions` pair scoped to `PricingGridScreen`, not a global handler (research.md §R4; depends on T022, T033)
- [X] T035 [US4] Create the change-summary bar in `lib/features/pricing/presentation/pricing_grid_screen.dart` — visible whenever `hasChanges`, stating changed/rejected counts, with "undo last" and "revert all" actions (FR-023; depends on T033)
- [X] T036 [US4] Warn before discarding outstanding changes on page/filter/search/worklist navigation, reusing the `UnconfirmedEdits`/`ConfirmableFieldController` confirm-or-discard machinery rather than a bespoke dialog (FR-025, research.md §R3; depends on T033)
- [X] T037 [P] [US4] Unit-test `undoLast`/`revertAll` in `test/unit/features/pricing/pricing_grid_controller_test.dart` — a multi-write `PriceChange` reverses as one undo (SC-004), and `revertAll` restores the load-time baseline exactly (depends on T033)
- [X] T038 [P] [US4] Widget-test the summary bar and its two actions, plus the navigate-away warning, in `test/widget/features/pricing/pricing_grid_screen_test.dart` (depends on T035, T036)

**Checkpoint**: Editing on the grid is now safe to use — every change is visible, countable, and reversible.

---

## Phase 7: User Story 5 - Look without touching (Priority: P3)

**Goal**: without `pricing` update rights, the grid is fully legible and nothing is editable.

**Independent Test**: sign in as a profile with pricing read and no update; open `/pricing`; confirm no cell opens and no column menu exists.

- [X] T039 [US5] Gate `PriceCell`'s click-to-edit and `PricingGridScreen`'s column-menu affordance (once US3 exists) behind `access.can(SystemObject.pricing, AccessRight.update)`, hidden rather than disabled (FR-026, FR-027; depends on T019, T022)
- [X] T040 [US5] Add the read-only hint line to `PricingGridScreen`, mirroring `pricing_screen.dart`'s existing read-only hint text (depends on T039)
- [X] T041 [P] [US5] Widget-test the read-only path in `test/widget/features/pricing/pricing_grid_screen_test.dart` — every price renders, no cell enters edit mode on click, no summary bar can appear, and the hint line is present (depends on T039, T040)

**Checkpoint**: All grid-facing stories buildable today (US1, US4, US5) are complete and independently testable. US2/US3 remain blocked (Phases 4–5).

---

## Phase 8: User Story 6 - Read the products filter drawer without guessing (Priority: P3)

**Goal**: the products filter drawer's attribute chips get a heading, and supplier moves before labels.

**Independent Test**: open the products filter drawer and read it top to bottom — every group has a heading, and supplier precedes labels.

- [X] T042 [P] [US6] Add `productsAttributesFilterLabel` to `lib/l10n/app_es.arb` ("Atributos del producto") then `lib/l10n/app_en.arb` ("Product attributes") (research.md §R12)
- [X] T043 [US6] Add a `titleSmall`-styled heading above the Stockable/Salable/Purchasable `Wrap` in `_ProductFiltersPanel` (`lib/features/catalog/presentation/products_list_screen.dart:262-355`), matching the existing Status/Labels/Supplier heading style (FR-030; depends on T042)
- [X] T044 [US6] Move the `CatalogEntityPicker<SupplierListItem>` supplier block above the `if (allLabels.isNotEmpty)` labels block in the same panel, changing no query, facet or controller (FR-031, FR-032; depends on T043)
- [X] T045 [P] [US6] Widget-test the new heading's presence and localization, and the status→attributes→supplier→labels order, in `test/widget/features/catalog/products_list_screen_test.dart`, asserting every existing filter assertion (facet counts included) still passes unchanged (FR-032; depends on T044)

**Checkpoint**: Drawer corrections shipped, independent of everything else in this feature.

---

## Phase 9: User Story 7 - Stop maintaining numbers nobody edits (Priority: P3)

**Goal**: no low-profit/high-profit field appears on any screen.

**Independent Test**: open the price-list form, the price-lists list, and both pricing surfaces — no profit field appears on any of them, and saving each record still works.

### Safe under every outcome of mbe-api#185

- [X] T046 [P] [US7] Remove the `columnLowProfit`/`columnHighProfit` table columns and the low/high-profit dialog inputs from `lib/features/pricing/presentation/pricing_screen.dart` (the standalone per-product screen kept by T028); the entity fields and the save call's `lowProfit`/`highProfit` arguments stay (per data-model.md §1, the write path still needs them) but are no longer user-editable — echo the row's existing values unchanged on save (FR-034; research.md §R11)
- [X] T047 [P] [US7] Remove the two profit-related `PricingRowEditState` fields' UI bindings in `pricing_screen.dart` accordingly; keep the state fields themselves only if `saveRow` still needs to pass them through unchanged (depends on T046)
- [X] T048 [P] [US7] Update `test/widget/features/pricing/pricing_screen_test.dart` — no profit input rendered; editing price alone still saves successfully (depends on T046, T047)

### ✅ Gate resolved — mbe-api#185 landed with outcome (a)

- [X] T049 [US7] **Confirmation gate**: mbe-api#185 landed 2026-08-29 (`98d3254`) with **outcome (a)** — the sales-order margin validation is retired outright (`assert_margin_in_range`, both call sites, the `EXCLUDE_PRICE_RANGE_VALIDATION` bypass and the `price_validation_in_range_required` setting all gone) and **all four** profit fields are deprecated, the price list's two included. Nothing was relocated onto them, so T050–T054 proceed as written
- [X] T050 [US7] Remove the two `columnHighProfitMargin`/`columnLowProfitMargin` columns from `lib/features/pricing/presentation/price_lists_list_screen.dart:92-103` (FR-034; depends on T049 outcome a)
- [X] T051 [US7] Remove the two profit-margin `TextFormField`s from `lib/features/pricing/presentation/price_list_detail_screen.dart:134-166` (FR-034; depends on T049 outcome a)
- [X] T052 [US7] Remove `highProfitMargin`/`lowProfitMargin` state, their change handlers, and the `marginInvalid` validation from `lib/features/pricing/presentation/price_list_form_controller.dart`, leaving `create`/`update` to omit both fields entirely — verified safe by `PriceListCreate` defaulting both to `0` server-side and `PriceListUpdate` treating both as optional (FR-035; research.md §R11; depends on T049 outcome a)
- [X] T053 [P] [US7] Remove `priceListHighProfitMarginLabel`, `priceListLowProfitMarginLabel`, `columnHighProfitMargin`, `columnLowProfitMargin`, `columnHighProfit`, `columnLowProfit` from `lib/l10n/app_es.arb` and `lib/l10n/app_en.arb` (FR-036; depends on T046, T050, T051)
- [X] T053a [US7] Once no screen reads them, drop `lowProfit`/`highProfit` from `ProductPrice` and `lowProfitMargin`/`highProfitMargin` from `PriceList`, together with the `// ignore: deprecated_member_use` comments their mappings now carry — an entity field no screen maps is exactly the dead weight #185 is retiring, and the ignores exist only to keep the analyzer honest until then (research.md §R11; depends on T046, T050, T051, T052)
- [X] T054 [P] [US7] Update `test/widget/features/pricing/price_lists_list_screen_test.dart`, `test/widget/features/pricing/price_list_detail_screen_test.dart` and `test/unit/features/pricing/price_list_form_controller_test.dart` — no profit field/column anywhere; create and update still succeed with only a name (FR-035; depends on T050, T051, T052)
- [X] T055 [US7] Rewrite `test/integration/pricing_flow_test.dart` against the grid and the profit-free price-list form (depends on T027, T052) — **verified live against mbe-api**: it now covers `listForProducts` (#182's batched read), `applyPriceChanges` (#183's transactional upsert), a margin-free price-list create and product-price create (#185), and the cascade delete (#181). Its first real run found the `Numeric(18,4)` scale mismatch behind research.md §R10a

**Checkpoint**: Every low/high profit field is gone from the UI (or the sub-phase is explicitly re-scoped per T049's outcome).

---

## Phase 10: Polish & Cross-Cutting Concerns

**Purpose**: Final consistency pass across everything buildable in this iteration (US1, US4, US5, US6, and US7's unconditional half).

- [X] T056 Run `flutter analyze` and fix any warnings introduced by this feature — clean
- [X] T057 Run the full `flutter test` suite and confirm the T001 baseline is not regressed — **2302 passed / 48 skipped / 0 failed**, against a T001 baseline of 2221/48/0; the whole delta is this feature's own new tests
- [ ] T058 Walk [quickstart.md](quickstart.md)'s manual steps 1–16 end to end against a local mbe-api, including the sales-order acceptance check in step 11 (research.md §R6)
- [ ] T059 [P] Confirm steps 17–18 of [quickstart.md](quickstart.md) — no column menu, no worklist chips — hold on the shipped grid

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: no dependencies
- **Foundational (Phase 2)**: depends on Setup — BLOCKS US1, US4, US5 (all read the grid's state shapes and the batched fetch)
- **US1 (Phase 3)**: depends on Foundational
- **US2 (Phase 4)**: unblocked (mbe-api#184 landed). Depends on Foundational; `missingPriceList` is already wired through the repository
- **US3 (Phase 5)**: unblocked (mbe-api#183 landed). Depends on US1's controller and cell (T014, T015, T019)
- **US4 (Phase 6)**: depends on US1 (T014, T015, T019)
- **US5 (Phase 7)**: depends on US1 (T019, T022)
- **US6 (Phase 8)**: no dependency on any other phase — can run any time, including in parallel with Phases 2–7
- **US7 (Phase 9)**: `T046`–`T048` have no dependency on any other phase; `T049`'s gate is resolved so `T050`–`T055` may proceed, with `T053a` last (it needs every screen off the fields) and `T055` additionally depending on US1's routing (T027)
- **Polish (Phase 10)**: depends on every phase attempted in this iteration (US1, US4, US5, US6, and US7's unconditional half)

### Parallel Opportunities

- All Foundational tasks marked [P] (T002, T003, T005–T009, T012, T013) can run in parallel once their stated single dependency is met
- US6 (Phase 8) can be staffed independently of the entire grid effort (Phases 2–7)
- US7's unconditional tasks (T046–T048) can be staffed independently of the grid effort
- Within US1: T017/T018 (controller tests), T021 (cell test), T025 (l10n), T026 (screen test), T029 (screen test update) are parallelizable once their single dependency lands

---

## Parallel Example: Foundational Phase

```bash
# Once T002 lands, in parallel:
Task: "Implement listForProducts in lib/features/pricing/data/product_price_repository_impl.dart"
Task: "Unit-test listForProducts in test/unit/features/pricing/product_price_repository_impl_test.dart"

# Independently, in parallel:
Task: "Add minWidth to DataTableView in lib/core/widgets/data_table_view.dart"
Task: "Create PricingGridRow in lib/features/pricing/presentation/pricing_grid_row.dart"
Task: "Create PriceCellKey in lib/features/pricing/domain/entities/price_cell_key.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: quickstart.md steps 6–11 pass; `/pricing` is a working grid with single-cell editing
5. Deploy/demo if ready — this alone already replaces the picker-first screen with something strictly more capable

### Incremental Delivery

1. Setup + Foundational → foundation ready
2. US1 → validate → deploy (MVP)
3. US4 → validate (undo/badges) → deploy
4. US5 → validate (read-only) → deploy
5. US6, US7 (unconditional half) → validate → deploy, any time, in parallel with the above
6. US7's second half → now ungated (mbe-api#185 outcome (a)), ending with T053a's entity cleanup
7. US2, US3 → both unblocked; implement from the task lists in Phases 4 and 5

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - Developer A: US1 → US4 → US5 (the grid, in order — each depends on the previous)
   - Developer B: US6 (drawer) and US7's unconditional half, in parallel with Developer A
3. US2 and US3 are now staffable too — US2 is independent of US4/US5, while US3 builds on US1's controller and cell

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- US2 and US3 were single blocking-assertion tasks until their endpoints landed; each phase now carries real tasks, and each phase's absence assertion (T030, T031) is deleted by the widget test that replaces it rather than left contradicting it
- US7's price-list form/list removal is no longer gated: T049 records mbe-api#185's outcome (a)
- `0` is a real price list id (`Costo`). Anywhere this feature tests a price-list id, test for null — never for falsiness (FR-019a)
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
