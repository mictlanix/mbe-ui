# Tasks: Bulk Pricing Grid

**Input**: Design documents from `/specs/033-bulk-pricing-grid/`
**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md), [data-model.md](data-model.md), [contracts/](contracts/), [quickstart.md](quickstart.md)

**Tests**: Included. The constitution mandates unit/widget/integration coverage, and three success criteria (SC-006 constant request count, SC-004 any change including a bulk action reverses in one step, SC-007 a read-only user reaches no editing affordance) are only verifiable with tests.

**Organization**: Phase 2 is a genuine blocker — every story reads the batched price fetch and the grid's shared state shape. After that, **US1 → US4 → US5 → US6 → US7 are buildable now** and proceed in that order (US6/US7 have no dependency on the others and can run in parallel with them). **US2 and US3 cannot be implemented** — they depend on mbe-api endpoints that do not exist yet (#184, #183 respectively). Their phases contain a single blocking task each, per [plan.md](plan.md)'s delivery-order table, and no further work until the dependency lands.

**Note on US7**: two of its removals (the standalone pricing screen's profit columns/dialog, T0xx below) are safe under every outcome of mbe-api#185. The price-list form/list removal is **not** — #185 asks mbe-api to decide whether the per-price margin band is retired or relocated to the price list's own margins, and the second answer would un-deprecate the exact fields this phase removes. That subset is marked accordingly and gated on an explicit confirmation task.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: US1–US7, matching [spec.md](spec.md)
- Every task names an exact file path from the repo root

## Path Conventions

Flutter application, single project. `lib/` for source, `test/` for tests, both at repo root (plan.md Project Structure). Generated companions (`*.g.dart`, `*.freezed.dart`) are produced by `dart run build_runner build --delete-conflicting-outputs` and are never hand-edited.

---

## Phase 1: Setup

**Purpose**: Nothing to initialize — this feature adds files to an already-configured project and introduces no dependency, script or tool.

- [ ] T001 Confirm `flutter analyze` is clean and `flutter test` is fully green on a clean checkout of `033-bulk-pricing-grid` **before any change**, and record the pass/fail counts — every later regression is attributable to this feature from that baseline

**Checkpoint**: Baseline recorded. No other setup exists.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: The batched price read, the grid's shared state shapes, and the shared table's width escape hatch. Nothing in any grid-facing story (US1–US5) can be built until this phase is done.

**⚠️ CRITICAL**: T004's read path is deliberately a fan-out today (research.md §R5) — it must NOT be written as a single request pretending mbe-api#182 already exists, and its call site must be the only place that changes when #182 lands.

### Repository

- [ ] T002 [P] Declare `listForProducts({required List<int> productIds, required List<int> priceListIds})` returning `Future<List<ProductPrice>>` in `lib/features/pricing/domain/repositories/product_price_repository.dart`, documenting that it batches today via fan-out and will collapse to one request when mbe-api#182 lands (contracts/mbe-api-pricing.md §3)
- [ ] T003 [P] Extend `create`/`update` doc comments in `lib/features/pricing/domain/repositories/product_price_repository.dart` to note the profit-band rule new callers must follow (research.md §R6; no signature change)
- [ ] T004 Implement `listForProducts` in `lib/features/pricing/data/product_price_repository_impl.dart` as `Future.wait` over the existing `listByProduct`, filtering each result to `priceListIds`, deduplicating nothing (empty `productIds` returns `[]` without a request) (depends on T002)
- [ ] T005 [P] Unit-test `listForProducts` in `test/unit/features/pricing/product_price_repository_impl_test.dart` — issues one request per product id, filters by the given price-list ids, and issues zero requests for an empty product list (depends on T004)

### Shared table width

- [ ] T006 [P] Add an optional `minWidth` parameter to `DataTableView` in `lib/core/widgets/data_table_view.dart`, threading it into both the `PaginatedDataTable2` and `DataTable2` constructors so a wide column set scrolls within the table's own region rather than the page (research.md §R2, constitution §VI)
- [ ] T007 [P] Widget-test the new parameter in `test/widget/core/widgets/data_table_view_test.dart` — a `minWidth` wider than the viewport produces a horizontally scrollable table with the page itself unaffected (depends on T006)

### Grid state shapes

- [ ] T008 [P] Create `lib/features/pricing/presentation/pricing_grid_row.dart` with the `PricingGridRow` freezed class (`product: ProductListItem`, `prices: Map<int, ProductPrice>`) and `buildPricingGridRows({products, prices})`, mirroring `product_price_row.dart`'s join helper (data-model.md §2)
- [ ] T009 [P] Create `lib/features/pricing/domain/entities/price_cell_key.dart` with the `PriceCellKey` freezed class (`productId`, `priceListId`) (data-model.md §3)
- [ ] T010 Create `lib/features/pricing/presentation/pricing_grid_controller.dart` with `PricingGridFilter` (built from `ListQuery` exactly as `ProductFilter.fromQuery` is, plus `missingPriceList` always `null` until US2 — data-model.md §7), `RejectedEdit`, `PriceChangeKind`, `PriceWrite`, `PriceChange`, and `PricingGridState` (data-model.md §4–§6), with no controller logic yet (depends on T008, T009)
- [ ] T011 Run `dart run build_runner build --delete-conflicting-outputs` and confirm every new freezed file regenerates cleanly (depends on T010)
- [ ] T012 [P] Unit-test `buildPricingGridRows` in `test/unit/features/pricing/pricing_grid_row_test.dart` — a product with no matching price is absent from its `prices` map (not present with a null value), proving "not set" is representable (FR-005; depends on T008)
- [ ] T013 [P] Unit-test `PricingGridFilter.fromQuery` in `test/unit/features/pricing/pricing_grid_controller_test.dart` — round-trips every facet the products filter drawer already covers, and `missingPriceList` is always `null` (depends on T010, T011)

**Checkpoint**: The batched read exists and is tested, the shared table can be told to scroll internally, and the grid's state types compile. No screen exists yet.

---

## Phase 3: User Story 1 - See and edit many products' prices at once (Priority: P1) 🎯 MVP

**Goal**: `/pricing` renders a paginated grid with no product selection required, and a user with update rights can click any cell, type a price, and have it saved.

**Independent Test**: Open `/pricing` with no product selected — a populated grid renders; change a price and re-read it after a reload.

### The controller

- [ ] T014 [US1] Implement `PricingGridController` (`@riverpod` family keyed by `PricingGridFilter`) in `lib/features/pricing/presentation/pricing_grid_controller.dart` — loads a page of `ProductListItem` via the existing `ProductRepository.list`, the full price-list set via `PriceListRepository.list(limit: 100)`, and prices for that page via `listForProducts` scoped to the **shown** columns only (research.md §R5's cap note), joining with `buildPricingGridRows` (depends on T004, T010, T011)
- [ ] T015 [US1] Add `commitCell({productId, priceListId, typed})` to `PricingGridController` — parses via `fmt.input.parsePrice`/`PricingValidators.isNonNegativeDecimal`; on parse failure sets `rejected[key]` and issues no request (FR-009); on a value equal to the stored price, issues no request (FR-010); otherwise routes to `create` (with the research.md §R6 profit-band rule: copy the target price list's margins, or `[0, 1]` when they are `0/0`) or `update` (echoing existing `lowProfit`/`highProfit` unchanged), marking the cell `inFlight` for the duration and appending one single-write `PriceChange` to `history` on success (depends on T014; contracts/mbe-api-pricing.md §4)
- [ ] T016 [US1] Add `retry()` to `PricingGridController` re-issuing the current page's load unchanged, mirroring `PricingController.retry` (depends on T014)
- [ ] T017 [P] [US1] Unit-test `commitCell`'s three outcomes (rejected, no-op on unchanged value, accepted) in `test/unit/features/pricing/pricing_grid_controller_test.dart` (depends on T015)
- [ ] T018 [P] [US1] Unit-test the create-vs-update routing and the profit-band rule (list margins copied; `[0,1]` fallback when the list's margins are `0/0`; update echoes the existing band unchanged) in `test/unit/features/pricing/pricing_grid_controller_test.dart` (depends on T015; research.md §R6)

### The cell widget

- [ ] T019 [US1] Create `lib/features/pricing/presentation/price_cell.dart` — a `StatefulWidget` holding one `ConfirmableFieldController` (created/disposed in `State`, never in Riverpod, per research.md §R3), rendering the reading state (`fmt.display.currency`, or the existing "not set" treatment for FR-005) and, when active, a `ConfirmableTextField` with `parse: fmt.input.parsePrice` and `commit` calling `PricingGridController.commitCell` (contracts/pricing-grid-screen.md §1–§3)
- [ ] T020 [US1] Wire keyboard traversal on `PriceCell`'s `Focus` — Enter (commit, open same column next row), Tab/Shift+Tab (commit, open next/previous column, wrapping at row ends), ArrowUp/Down (commit, open same column adjacent row), ArrowRight/Left only at caret end/start (commit, move one column), Escape (discard, no commit) — every handler returns `KeyEventResult.handled` (research.md §R4; contracts/pricing-grid-screen.md §2; depends on T019)
- [ ] T021 [P] [US1] Widget-test `PriceCell` in `test/widget/features/pricing/price_cell_test.dart` against contracts/pricing-grid-screen.md §2's full input table (depends on T020)

### The screen

- [ ] T022 [US1] Create `lib/features/pricing/presentation/pricing_grid_screen.dart` — `CatalogFilterBar` (search + badged filter button) → `DataTableView<PricingGridRow>(minWidth: …)` with photo/code+copy/name columns plus one `PriceCell`-backed column per shown price list → `CatalogPagination` → hint line, following `products_list_screen.dart`'s structure (depends on T006, T019, T022 n/a — self)
- [ ] T023 [US1] Wire the empty/error/filtered-empty states via the existing `CatalogListStateView`/`ListFailedView`/`ListEmptyView` (no price lists → reuse `pricingNoPriceListsEmptyState`) (contracts/pricing-grid-screen.md §4; depends on T022)
- [ ] T024 [US1] Ellipsize the name column with a hover tooltip fallback, matching `products_list_screen.dart`'s pattern (constitution §VI; depends on T022)
- [ ] T025 [P] [US1] Add `l10n` keys for the grid (screen hint, "not set" reuse, any new labels) to `lib/l10n/app_es.arb` first, then `lib/l10n/app_en.arb`
- [ ] T026 [P] [US1] Widget-test `PricingGridScreen` in `test/widget/features/pricing/pricing_grid_screen_test.dart` — renders with no product selected (FR-001), a page of rows with one column per shown list, and the "not set" vs `$0.00` distinction (FR-005) (depends on T022, T023, T025)

### Routing

- [ ] T027 [US1] Replace `PricingScreen(standalone: false)` at `/pricing` with `PricingGridScreen` in `lib/app/router/app_router.dart`, keeping the existing `PrivilegeGate(SystemObject.pricing, AccessRight.read)` clause unchanged (contracts/routes.md §2; depends on T022)
- [ ] T028 [US1] Remove the `!standalone` picker branch and the `standalone` parameter from `PricingScreen` in `lib/features/pricing/presentation/pricing_screen.dart`, making `initialProductId`/`initialProductDisplayText` required, and update its call site at `/products/:productId/pricing` in `lib/app/router/app_router.dart` accordingly (research.md §R1; depends on T027)
- [ ] T029 [P] [US1] Update `test/widget/features/pricing/pricing_screen_test.dart` to drop the picker-mode assertions, keeping only the standalone-mode ones (depends on T028)

**Checkpoint**: `/pricing` is the grid. A user with update rights can read and edit any price; `/products/:productId/pricing` still works unchanged.

---

## Phase 4: User Story 2 - Find what still needs pricing (Priority: P1)

**Goal**: worklist chips ("All products" + one "Missing «list» (count)" per shown list) narrow the grid to unpriced products.

**Independent Test**: N/A — see below.

⚠️ **BLOCKED — mbe-api#184 not yet implemented.** `GET /products` has no price-related filter and no facet endpoint to source the chip counts (research.md §R8). Per FR-019, the chips MUST be omitted entirely rather than shown with wrong or zero counts.

- [ ] T030 [US2] Confirm `PricingGridScreen` renders **no** worklist chip row at all while `PricingGridFilter.missingPriceList` stays permanently `null` (T010) — add a widget-test assertion of absence, not a placeholder chip row, to `test/widget/features/pricing/pricing_grid_screen_test.dart` (FR-019)

**No further tasks until mbe-api#184 lands.** When it does: add the filter param and its repository plumbing (mirroring T002–T005's pattern), the chip row UI, and the count-badge wiring — re-run `/speckit-tasks` for this phase at that point rather than guessing the endpoint's shape now.

---

## Phase 5: User Story 3 - Move a whole price list in one action (Priority: P2)

**Goal**: a column ⋮ menu offers fill-down, copy-from-cost, and adjust-by-percent, each atomic and one undo.

**Independent Test**: N/A — see below.

⚠️ **BLOCKED — mbe-api#183 not yet implemented.** FR-015 requires a column action to be all-or-nothing; only per-row `POST`/`PUT` exist today, which cannot give that guarantee (research.md §R7). Faking atomicity client-side (issue N requests, roll back on partial failure) is explicitly rejected — a rollback fan-out can itself fail.

- [ ] T031 [US3] Confirm `PricingGridScreen` renders **no** column ⋮ menu on any price-list header — add a widget-test assertion of absence to `test/widget/features/pricing/pricing_grid_screen_test.dart`

**No further tasks until mbe-api#183 lands.** When it does: add `applyPriceChanges` to the repository (contracts/mbe-api-pricing.md §5), the column menu UI, and the three actions — re-run `/speckit-tasks` for this phase at that point. Landing #183 also deletes the research.md §R6 profit-band fallback in T015/T018, since the bulk upsert defaults the band server-side.

---

## Phase 6: User Story 4 - Trust what just happened, and take it back (Priority: P2)

**Goal**: every touched cell shows saving/saved/rejected; a summary bar counts changes and rejections; undo-last and revert-all both work, with a column action (once US3 ships) reversing as a single unit.

**Independent Test**: Change three cells, then undo — each reverses individually; "revert all" restores every price to the view's load-time baseline.

- [ ] T032 [US4] Add per-cell badge rendering to `PriceCell` — saving while `inFlight`, saved + "was X" tooltip while `baseline[key] != current`, rejected + reason on hover while `rejected[key]` is set (contracts/pricing-grid-screen.md §3; depends on T019, T014)
- [ ] T033 [US4] Add `undoLast()` and `revertAll()` to `PricingGridController` — `undoLast` pops the newest `PriceChange` and re-issues writes restoring every `PriceWrite.previous` in it as **one** operation regardless of how many writes it holds (FR-016, FR-024); `revertAll` does the same for every cell against `baseline` and clears `history`/`rejected` (data-model.md §5; depends on T015)
- [ ] T034 [US4] Wire `⌘Z`/`Ctrl+Z` to `undoLast()` via a `Shortcuts`/`Actions` pair scoped to `PricingGridScreen`, not a global handler (research.md §R4; depends on T022, T033)
- [ ] T035 [US4] Create the change-summary bar in `lib/features/pricing/presentation/pricing_grid_screen.dart` — visible whenever `hasChanges`, stating changed/rejected counts, with "undo last" and "revert all" actions (FR-023; depends on T033)
- [ ] T036 [US4] Warn before discarding outstanding changes on page/filter/search/worklist navigation, reusing the `UnconfirmedEdits`/`ConfirmableFieldController` confirm-or-discard machinery rather than a bespoke dialog (FR-025, research.md §R3; depends on T033)
- [ ] T037 [P] [US4] Unit-test `undoLast`/`revertAll` in `test/unit/features/pricing/pricing_grid_controller_test.dart` — a multi-write `PriceChange` reverses as one undo (SC-004), and `revertAll` restores the load-time baseline exactly (depends on T033)
- [ ] T038 [P] [US4] Widget-test the summary bar and its two actions, plus the navigate-away warning, in `test/widget/features/pricing/pricing_grid_screen_test.dart` (depends on T035, T036)

**Checkpoint**: Editing on the grid is now safe to use — every change is visible, countable, and reversible.

---

## Phase 7: User Story 5 - Look without touching (Priority: P3)

**Goal**: without `pricing` update rights, the grid is fully legible and nothing is editable.

**Independent Test**: sign in as a profile with pricing read and no update; open `/pricing`; confirm no cell opens and no column menu exists.

- [ ] T039 [US5] Gate `PriceCell`'s click-to-edit and `PricingGridScreen`'s column-menu affordance (once US3 exists) behind `access.can(SystemObject.pricing, AccessRight.update)`, hidden rather than disabled (FR-026, FR-027; depends on T019, T022)
- [ ] T040 [US5] Add the read-only hint line to `PricingGridScreen`, mirroring `pricing_screen.dart`'s existing read-only hint text (depends on T039)
- [ ] T041 [P] [US5] Widget-test the read-only path in `test/widget/features/pricing/pricing_grid_screen_test.dart` — every price renders, no cell enters edit mode on click, no summary bar can appear, and the hint line is present (depends on T039, T040)

**Checkpoint**: All grid-facing stories buildable today (US1, US4, US5) are complete and independently testable. US2/US3 remain blocked (Phases 4–5).

---

## Phase 8: User Story 6 - Read the products filter drawer without guessing (Priority: P3)

**Goal**: the products filter drawer's attribute chips get a heading, and supplier moves before labels.

**Independent Test**: open the products filter drawer and read it top to bottom — every group has a heading, and supplier precedes labels.

- [ ] T042 [P] [US6] Add `productsAttributesFilterLabel` to `lib/l10n/app_es.arb` ("Atributos del producto") then `lib/l10n/app_en.arb` ("Product attributes") (research.md §R12)
- [ ] T043 [US6] Add a `titleSmall`-styled heading above the Stockable/Salable/Purchasable `Wrap` in `_ProductFiltersPanel` (`lib/features/catalog/presentation/products_list_screen.dart:262-355`), matching the existing Status/Labels/Supplier heading style (FR-030; depends on T042)
- [ ] T044 [US6] Move the `CatalogEntityPicker<SupplierListItem>` supplier block above the `if (allLabels.isNotEmpty)` labels block in the same panel, changing no query, facet or controller (FR-031, FR-032; depends on T043)
- [ ] T045 [P] [US6] Widget-test the new heading's presence and localization, and the status→attributes→supplier→labels order, in `test/widget/features/catalog/products_list_screen_test.dart`, asserting every existing filter assertion (facet counts included) still passes unchanged (FR-032; depends on T044)

**Checkpoint**: Drawer corrections shipped, independent of everything else in this feature.

---

## Phase 9: User Story 7 - Stop maintaining numbers nobody edits (Priority: P3)

**Goal**: no low-profit/high-profit field appears on any screen.

**Independent Test**: open the price-list form, the price-lists list, and both pricing surfaces — no profit field appears on any of them, and saving each record still works.

### Safe under every outcome of mbe-api#185

- [ ] T046 [P] [US7] Remove the `columnLowProfit`/`columnHighProfit` table columns and the low/high-profit dialog inputs from `lib/features/pricing/presentation/pricing_screen.dart` (the standalone per-product screen kept by T028); the entity fields and the save call's `lowProfit`/`highProfit` arguments stay (per data-model.md §1, the write path still needs them) but are no longer user-editable — echo the row's existing values unchanged on save (FR-034; research.md §R11)
- [ ] T047 [P] [US7] Remove the two profit-related `PricingRowEditState` fields' UI bindings in `pricing_screen.dart` accordingly; keep the state fields themselves only if `saveRow` still needs to pass them through unchanged (depends on T046)
- [ ] T048 [P] [US7] Update `test/widget/features/pricing/pricing_screen_test.dart` — no profit input rendered; editing price alone still saves successfully (depends on T046, T047)

### ⚠️ Gated on mbe-api#185's decision — do not start until answered

- [ ] T049 [US7] **Confirmation gate**: verify mbe-api#185 has been answered and record which outcome applies — (a) validation retired with the fields (proceed with T050–T054 as written), or (b) the band relocated to the price list's own margins (STOP — `price_list.low_profit_margin`/`high_profit_margin` become load-bearing again and T050–T054 must not run; re-scope this sub-phase instead)
- [ ] T050 [US7] Remove the two `columnHighProfitMargin`/`columnLowProfitMargin` columns from `lib/features/pricing/presentation/price_lists_list_screen.dart:92-103` (FR-034; depends on T049 outcome a)
- [ ] T051 [US7] Remove the two profit-margin `TextFormField`s from `lib/features/pricing/presentation/price_list_detail_screen.dart:134-166` (FR-034; depends on T049 outcome a)
- [ ] T052 [US7] Remove `highProfitMargin`/`lowProfitMargin` state, their change handlers, and the `marginInvalid` validation from `lib/features/pricing/presentation/price_list_form_controller.dart`, leaving `create`/`update` to omit both fields entirely — verified safe by `PriceListCreate` defaulting both to `0` server-side and `PriceListUpdate` treating both as optional (FR-035; research.md §R11; depends on T049 outcome a)
- [ ] T053 [P] [US7] Remove `priceListHighProfitMarginLabel`, `priceListLowProfitMarginLabel`, `columnHighProfitMargin`, `columnLowProfitMargin`, `columnHighProfit`, `columnLowProfit` from `lib/l10n/app_es.arb` and `lib/l10n/app_en.arb` (FR-036; depends on T046, T050, T051)
- [ ] T054 [P] [US7] Update `test/widget/features/pricing/price_lists_list_screen_test.dart`, `test/widget/features/pricing/price_list_detail_screen_test.dart` and `test/unit/features/pricing/price_list_form_controller_test.dart` — no profit field/column anywhere; create and update still succeed with only a name (FR-035; depends on T050, T051, T052)
- [ ] T055 [US7] Rewrite `test/integration/pricing_flow_test.dart` against the grid and the profit-free price-list form (depends on T027, T052)

**Checkpoint**: Every low/high profit field is gone from the UI (or the sub-phase is explicitly re-scoped per T049's outcome).

---

## Phase 10: Polish & Cross-Cutting Concerns

**Purpose**: Final consistency pass across everything buildable in this iteration (US1, US4, US5, US6, and US7's unconditional half).

- [ ] T056 Run `flutter analyze` and fix any warnings introduced by this feature
- [ ] T057 Run the full `flutter test` suite and confirm the baseline recorded in T001 is not regressed anywhere outside the files this feature touches
- [ ] T058 Walk [quickstart.md](quickstart.md)'s manual steps 1–16 end to end against a local mbe-api, including the sales-order acceptance check in step 11 (research.md §R6)
- [ ] T059 [P] Confirm steps 17–18 of [quickstart.md](quickstart.md) — no column menu, no worklist chips — hold on the shipped grid

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: no dependencies
- **Foundational (Phase 2)**: depends on Setup — BLOCKS US1, US4, US5 (all read the grid's state shapes and the batched fetch)
- **US1 (Phase 3)**: depends on Foundational
- **US2 (Phase 4)**: blocked on mbe-api#184 — only the absence-assertion task (T030) is actionable
- **US3 (Phase 5)**: blocked on mbe-api#183 — only the absence-assertion task (T031) is actionable
- **US4 (Phase 6)**: depends on US1 (T014, T015, T019)
- **US5 (Phase 7)**: depends on US1 (T019, T022)
- **US6 (Phase 8)**: no dependency on any other phase — can run any time, including in parallel with Phases 2–7
- **US7 (Phase 9)**: `T046`–`T048` have no dependency on any other phase; `T049`–`T055` are gated on mbe-api#185's answer (see Phase 9 header) and `T055` additionally depends on US1's routing (T027)
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
6. US7's gated half → only once mbe-api#185 is answered
7. US2, US3 → re-run `/speckit-tasks` for their phases once mbe-api#184/#183 land, then implement

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - Developer A: US1 → US4 → US5 (the grid, in order — each depends on the previous)
   - Developer B: US6 (drawer) and US7's unconditional half, in parallel with Developer A
3. Nobody is staffed on US2/US3 until their mbe-api dependency lands

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- US2 and US3 are intentionally left as single blocking-assertion tasks — do not write speculative implementation against an endpoint that does not exist
- US7's price-list form/list removal (T050–T052) MUST NOT proceed without T049's confirmation — a wrong guess there deletes fields mbe-api#185 might reinstate
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
