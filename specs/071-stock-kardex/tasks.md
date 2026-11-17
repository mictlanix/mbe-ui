---
description: "Task list for 071-stock-kardex"
---

# Tasks: Stock and Kardex

**Input**: Design documents from `specs/071-stock-kardex/`

**Prerequisites**: plan.md, spec.md (with its Clarifications), research.md (R1–R13), data-model.md, contracts/ui-contract.md, contracts/repository.md, contracts/error-messages.md, quickstart.md, wireframes.md

**Tests**: The spec doesn't ask for a test suite as such, but the constitution's quality gates require tests. Test tasks sit inside each story, after the code they cover. The two pure pieces, the range check and the source mapping (T017, T018), are written test-first.

**Organization**: Grouped by user story (US1–US3, spec.md). All three are P1. US1 (Existencias) is the MVP. US2 (the product view and the catalog shortcut) and US3 (the Kardex) each need only Phase 2. Phase 2 holds what the stories share.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: parallelizable (different files, no dependency on an incomplete task)
- **[Story]**: US1 Existencias · US2 product view and "Ver existencias" · US3 Kardex

## Cross-story notes

- **This feature builds on specs 067–070.** `lib/features/inventory/` and its tests already exist, and the shared inventory parts (name cells, warehouse options, `InventoryDocumentsFilter`) are reused as they are. Open the closest shipped counterpart of every file before writing the new one: the counts list (`counts/inventory_counts_list_screen.dart`, `inventory_counts_list_controller.dart`) for lists, and the count detail screen (`inventory_count_detail_screen.dart`) for in-memory paging.
- **Both screens are read-only.** Nothing here writes, so there are no actions notifiers, no confirm prompts and no `MBE_WRITE` cases.
- **Research overrides the wireframes** where they differ (plan, "Where the plan departs"): the required pickers live in the filter sheet with a facts strip above the table (R2), the date chip passes its real range with `isToday: false` (R3), and the product view's totals are a facts strip above the table (R6).
- **Shared files.** Do these sequentially, not in parallel:
  - `lib/app/router/app_router.dart` and `lib/core/navigation/nav_destinations.dart`: T009 (US1) adds branch 34, its nav entry and gate. T013 (US2) adds the product view route. T021 (US3) adds branch 35.
  - `lib/features/inventory/presentation/stock/stock_list_screen.dart`: T008 (US1) creates it. Nothing later edits it.
  - `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb`: T002 adds the error keys, and T003 adds every stock and kardex key once. If a later task needs another, add it there and run `flutter gen-l10n`. Never hand-edit `lib/l10n/app_localizations*.dart`.
  - `test/widget/features/inventory/inventory_harness.dart`: T006 extends it, and later tests only use it.
- **Generated code.** After editing a freezed or `@riverpod` file, run `dart run build_runner build --delete-conflicting-outputs` at the repo root. Never run two build_runner processes at once. If it rewrites the unrelated `lib/features/sales/presentation/delivery_orders/delivery_orders_filter.freezed.dart`, revert that file with `git checkout`. No client regeneration is needed: `StockApi` and `KardexApi` already have every operation this spec calls.
- **Formatting.** Format only the files you changed (`dart format <files>`). Never `dart format .`, and never format `lib/generated/`.
- **Quantities and dates** go through `formattersProvider` (constitution §V). No `NumberFormat`, no `toStringAsFixed`. Quantities are `Decimal`, never `double`; the wire carries them as strings. Negative quantities are shown as negative, never clamped.
- **Spacing tokens, not literals** (`Theme.of(context).spacing`). No automated guard catches a literal, so check it in review.
- **Never match or show server prose** (§III). Show refusals through `AppError.localizedMessage` / `ErrorBanner`, built from the error's `code`. A kardex row's `sourceName` is server text: the label comes from the numeric source type (research R5).
- **Row icons (§VI).** Existencias rows have no icons. The product view's rows carry exactly one direct action, "Ver kardex". Don't add an Edit icon or a View toggle.
- **Rights.** A missing right means the control is absent, never disabled. Document the system-object code (WarehouseStockReport = 67, Kardex = 32, Warehouses = 4) in a comment where a route, nav entry or control is gated.
- **Simplifications.** Any shortcut carries a comment `// simplified: <ceiling>, <what to do when it binds>`.
- **Core widgets and goldens.** T014 is the only task that edits a shared `core/widgets` file. The `core_widgets` golden tests fail on main for reasons unrelated to this feature (spec 067 recorded 6 such failures, and goldens run only in CI, mbe-ui#209). Run `flutter test test/golden/core_widgets_golden_test.dart` before and after T014 and report that the failure set is identical.

---

## Phase 1: Setup

**Purpose**: a known-good baseline, so later failures are attributable.

- [ ] T001 Run `flutter analyze` and the tests this feature touches: all of `test/unit/features/inventory/`, `test/widget/features/inventory/`, `test/widget/features/catalog/` and `test/widget/core/`, plus `test/unit/core/errors/catalog_coverage_test.dart`, `test/unit/app/router/app_router_test.dart`, `test/unit/core/navigation/` and `test/unit/core/formatting_guard_test.dart`. Also run `test/golden/core_widgets_golden_test.dart` and record which tests fail. Record any failure that predates this feature, so it isn't blamed on the new code.

---

## Phase 2: Foundational (blocks all user stories)

**Purpose**: what two or more stories share: the error messages, the strings, the entities, the repositories and the test harness.

- [ ] T002 Add the error coverage (research R10, contracts/error-messages.md).
  - In `lib/core/errors/localize_problem.dart`, add `kardexPeriodRangeReversed` and `kardexPeriodRangeTooLong` to `localizedErrorCodes` and to the `localizeProblem` switch. The second takes the `max_days` param.
  - In `lib/l10n/app_es.arb` and `app_en.arb`, add the two `apiError…` keys with the texts in the contract (follow the existing `apiErrorLockBusy` naming and how other int params are declared). Run `flutter gen-l10n`.
  - In `specs/058-localized-api-errors/contracts/code-scope.tsv`, change the two `kardex.range_*` rows from `OUT` to `IN`, with the route `GET /kardex` and the note "reachable from the Kardex screen (spec 071)". In `test/unit/core/errors/catalog_coverage_test.dart`, change `expect(checked, 163)` to `165`. Add fixtures for the two codes to `test/unit/core/errors/problem_fixtures.dart` (the coverage test requires them).
  - **Check:** `flutter test test/unit/core/errors` passes.

- [ ] T003 [P] Add every stock and kardex string (depends on nothing; ui-contract.md and wireframes.md are the wording authority) to `lib/l10n/app_es.arb` and `app_en.arb`, with `@` entries for placeholders. Run `flutter gen-l10n`. Use key prefixes `inventoryStock…` and `inventoryKardex…`, and the nav keys `navInventoryStock` ("Existencias") and `navInventoryKardex` ("Kardex").
  - **Existencias:** the columns (Código, Producto, Existencia, Apartado, Disponible, Por recibir), the facets (Almacén, "Mostrar sin existencia"), the facts-strip label, the no-warehouse prompt ("Elige un almacén para ver sus existencias.") with its button "Elegir almacén", the empty text ("Este almacén no tiene existencias."), and the filtered-empty text ("Ningún producto coincide con la búsqueda.").
  - **Product view:** the title with placeholders `code` and `name` ("Existencias · {code} {name}"), the extra column Sucursal, the totals labels, the tooltip "Ver kardex", the "En tránsito" heading, and the empty text ("Este producto no tiene existencias en ningún almacén.").
  - **Kardex:** the facets (Producto, Almacén, Rango), the facts-strip labels, the summary labels (Saldo inicial, Entradas, Salidas, Saldo final), the columns (Fecha, Origen, Documento, Entrada, Salida, Saldo), the incomplete prompt ("Elige un producto y un almacén para ver su kardex.") with its button "Elegir", the two range texts (the client-side wording from contracts/error-messages.md, with `max` as a placeholder), and the no-movements text ("Sin movimientos en este rango.").
  - **Source labels** (research R5), one key per type: Pedido (1), Devolución (2), Salida de almacén (3), Entrada de almacén (4), Traspaso (5), Orden de compra (6), Ajuste (sistema anterior) (8), Itinerario de reparto (10), Conteo físico (12), Entrega en mostrador (13), and the fallback Movimiento.
  - **Catalog:** the button "Ver existencias".
  - No error-message keys here: T002 added them.

- [ ] T004 [P] Create the entities (data-model.md): `lib/features/inventory/domain/entities/stock.dart` (freezed) with `StockRow`, `StockPage`, `ProductStock` (with `totals` and `isEmpty`) and `InTransitStock`, and `lib/features/inventory/domain/entities/kardex.dart` (freezed) with `Kardex`, `KardexMovement` and `KardexDocumentRef`. Quantities are `Decimal`. Run build_runner.

- [ ] T005 Create the repositories (contracts/repository.md, research R1, R13, depends on T004).
  - In `lib/features/inventory/domain/repositories/stock_repository.dart` and `kardex_repository.dart`, declare `list`, `product` and `read`.
  - In `lib/features/inventory/data/stock_repository_impl.dart` and `kardex_repository_impl.dart`, implement them over the generated `StockApi(dio, appSerializers)` (`listStockApiV1StockGet`, `getProductStockApiV1StockProductsProductGet`) and `KardexApi(dio, appSerializers)` (`readKardexApiV1KardexGet`), with `stockRepositoryProvider` and `kardexRepositoryProvider`. Map null lists to empty, parse quantity strings with `Decimal.parse`, send `q` only when non-empty, and map `DioException` to `AppError` as `inventory_issue_repository_impl.dart` does. Do not map `sourceName`.
  - Create `test/unit/features/inventory/stock_fixtures.dart` and `kardex_fixtures.dart` (builders), and `stock_repository_impl_test.dart` and `kardex_repository_impl_test.dart`: the params sent (`warehouse` always, `q` omitted when empty, `include_zero`, `skip`, `limit`; the kardex's four params), each mapping case (null lists, a negative on-hand, a kardex row with and without `document`, a row with reference 0), and a `DioException` becoming a coded `AppError` (for `warehouse.in_transit_location` and `kardex.range_too_long`, keeping its params).

- [ ] T006 Extend the widget harness (depends on T005): in `test/widget/features/inventory/inventory_harness.dart`, add mocktail `MockStockRepository` and `MockKardexRepository`, their provider overrides, a `stockUser()` builder granting WarehouseStockReport (67), a `kardexUser()` granting Kardex (32), and helpers to stub a stock page, a product's stock and a kardex. Mirror how the count repository and `countUser()` are wired there. The screens' pump helpers come with the screens (T010, T016, T022).

---

## Phase 3: User Story 1 — See a warehouse's stock (Priority: P1) 🎯 MVP

**Goal**: a supervisor opens Existencias, picks a warehouse and sees one row per product with on-hand, reserved, available and incoming quantities, sorted by code. They search by code or name, and a switch includes products with nothing in stock.

**Independent Test**: with read on 67, open Existencias, pick a warehouse with known stock, and compare two products' figures with the stock the records hold. Search by part of a code. Turn on the zero-stock switch and check that products with no stock appear. Reload: the warehouse, search and switch survive. As `qanoaccess`, the entry is missing and the URL redirects to home.

- [ ] T007 [US1] Create the list controller (research R7, depends on T005): `lib/features/inventory/presentation/stock/stock_list_controller.dart`, an `AsyncNotifier` family keyed by a `StockQuery` (`warehouseId?`, `q`, `includeZero`, `pageIndex`, freezed, built from `ListQuery` facets `warehouse`, `q`, `include_zero` and `page`). 50 per page, page clamped with `fetchClampedPage`. With no `warehouseId` it makes no request and returns an empty page. Add `test/unit/features/inventory/stock_list_controller_test.dart`: the params sent, no request without a warehouse, page clamping, a search or switch change returning to page 1, and an error kept as an `AppError`. Run build_runner.

- [ ] T008 [US1] Create the list screen (ui-contract "Existencias", wireframes "Screen: Existencias", research R2 and R7, depends on T003, T007): `lib/features/inventory/presentation/stock/stock_list_screen.dart`. Declare `const stockPath = '/inventory/stock';` at the top of this file.
  - Filter row: `CatalogFilterBar` with `search` a `CatalogSearchBar` (key `stock_search`), no actions, and `filters` the badged filters button (key `stock_filter_button`) opening `showCatalogFilterSheet`. The sheet holds Almacén (`CatalogEntityPicker<Warehouse>` using `inventoryFilterWarehouseOptions`, key `stock_warehouse_filter`, shown only with read on Warehouses (4)) and the "Mostrar sin existencia" switch (key `stock_include_zero`).
  - **Starting warehouse:** when the URL has no `warehouse`, read the user's point-of-sale warehouse from the session settings, the same source `inventoryStartingWarehouse` reads, but **without** its own-facility rule (stock has no facility scope), and write it into the URL. With none, show the no-warehouse state.
  - Facts strip (key `stock_selection`): the chosen warehouse's name through `InventoryWarehouseName`.
  - Table: `DataTableView<StockRow>` (key `stock_table`) with Código, Producto, Existencia, Apartado, Disponible, Por recibir, the four numbers through `fmt.display.quantity` and negatives kept. Row tap pushes `'$stockPath/products/${row.productId}'` (the route comes in T013). No row icons.
  - `CatalogListStateView` for the no-warehouse state (with the "Elegir almacén" button opening the sheet), loading, empty, filtered-empty and error (including `warehouse.in_transit_location`); `CatalogPagination`; the page lives in the URL.

- [ ] T009 [US1] Add the navigation and the list route (ui-contract "Routes and nav", research R11, depends on T008).
  - In `lib/core/navigation/nav_destinations.dart`, add `NavBranch.inventoryStock = 34` (first confirm that `inventoryCounts = 33` is still the highest value) and a fifth destination in the `inventory` group, after Conteos físicos: `navInventoryStock`, `Icons.inventory_2_outlined` / `Icons.inventory_2`, `PrivilegeGate(SystemObject.warehouseStockReport, AccessRight.read)`, with a comment naming object 67.
  - In `lib/app/router/app_router.dart`, add the `StatefulShellBranch` at the end with `GoRoute(path: stockPath, builder: StockListScreen(query: ListQuery.fromUri(state.uri)))`, and the `_routeGate` clause for the `/inventory/stock` prefix returning the same gate (it also covers the product view route that T013 adds).
  - Add the nav and router cases to `test/unit/app/router/app_router_test.dart` and `test/unit/core/navigation/nav_destinations_test.dart`: the entry is the fifth, after Conteos físicos, on branch 34; it is absent without read on 67; the group stays when the user can read only some of its documents; and the URL redirects to home without the right.

- [ ] T010 [US1] Test the list (depends on T006, T008, T009): add a `pumpStock` helper and its `GoRoute` to the harness, then create `test/widget/features/inventory/stock_list_screen_test.dart`: rows render with the four figures and negatives shown as negative; the point-of-sale warehouse is the start and is written to the URL; a user without a point of sale sees the prompt and its button; there are no row icons; a row tap pushes the product route; the search and the switch change the query and the repository request, and return to page 1; the Almacén facet is absent without read on 4; filtered-empty, empty and error states render, and the in-transit refusal shows its Spanish message with an empty list; the filters badge counts the active facets.

**Checkpoint**: US1 is demonstrable on its own: open Existencias, filter it, and tap a row.

---

## Phase 4: User Story 2 — See one product across every warehouse (Priority: P1)

**Goal**: from an Existencias row, or from the product catalog, a supervisor opens a product's stock in every warehouse, with totals and its in-transit stock, and can jump to its kardex.

**Independent Test**: open a product that has stock in two warehouses and is on a dispatched transfer, once from Existencias and once from the catalog's "Ver existencias". Both open the same view, which lists both warehouses, the totals and the in-transit quantity under the origin's facility. In edit mode the catalog button is absent.

- [ ] T011 [US2] Create the product stock controller (research R6, depends on T005): `lib/features/inventory/presentation/stock/product_stock_controller.dart`, a `@riverpod` family keyed by the product id that loads the `ProductStock` and the product's code and name (through the catalog `productRepositoryProvider` `get`). Add `test/unit/features/inventory/product_stock_controller_test.dart`: a load, `totals` summing the rows (including negatives), a not-found error kept as an `AppError`, and an empty product. Run build_runner.

- [ ] T012 [US2] Create the product view screen (ui-contract "Product view", wireframes "Screen: Product view", depends on T003, T011): `lib/features/inventory/presentation/stock/product_stock_screen.dart`. Title "Existencias · {code} {name}", no AppBar actions.
  - Totals `FactStripRow` (key `product_stock_totals`) with the four sums.
  - `DataTableView<StockRow>` (key `product_stock_table`): Almacén and Sucursal through `InventoryWarehouseName` and `InventoryFacilityName` (the facility comes from the warehouse lookup), then the four figures. Row action "Ver kardex" via `buildCatalogRowActions(onEdit: null, extraActions: [...])` (key `product_stock_kardex_{warehouseId}`, `Icons.receipt_long_outlined`), shown only with `can(32, read)` (object 32 in a comment), pushing `/inventory/kardex?product={id}&warehouse={w}` (the route comes in T021).
  - "En tránsito" (key `product_stock_in_transit`): facility name through `InventoryFacilityName` and the quantity, shown only when non-empty.
  - The empty text when both lists are empty, and the shared error view for loading, not-found and forbidden.

- [ ] T013 [US2] Add the product view route (depends on T009, T012): in `lib/app/router/app_router.dart`, add the top-level `GoRoute(path: '$stockPath/products/:id', builder: ProductStockScreen(id))`, rejecting a non-numeric id as the count detail route does. The `/inventory/stock` gate clause already covers it. Add its gate case to `test/unit/app/router/app_router_test.dart`.

- [ ] T014 [P] [US2] Add the `leading` slot to `RecordFormActions` (research R9, depends on nothing): in `lib/core/widgets/record_form_actions.dart`, add an optional `List<Widget>? leading`, rendered first in the end-aligned `Wrap`. With null or empty it must render exactly as today. Add cases to `test/widget/core/widgets/record_form_actions_test.dart`: `leading` renders before the other buttons, and nothing extra renders when null or empty. Run the existing `RecordFormActions` tests and `test/golden/core_widgets_golden_test.dart` before and after, and report that the pass/fail set is identical (cross-story notes). This is the only shared-widget edit in this feature.

- [ ] T015 [US2] Add "Ver existencias" to the product detail screen (spec FR-013a, research R9, depends on T003, T013, T014): in `lib/features/catalog/presentation/product_detail_screen.dart`, pass `leading: [OutlinedButton.icon(key: Key('view_stock_button'), icon: Icons.inventory_2_outlined, label: l10n "Ver existencias")]` to `RecordFormActions` (about L431). It shows only in View mode (`forceReadOnly` / `?view=true`), for an existing product (`widget.productId != null`), and with `can(67, read)` (object 67 in a comment). It pushes `'/inventory/stock/products/${widget.productId}'`. Do not change the products list. Add `test/widget/features/catalog/product_detail_view_stock_test.dart`: the button shows in View mode with 67, is absent without 67, absent in edit mode and on a new product, and pushes the right route.

- [ ] T016 [US2] Test the product view (depends on T006, T012, T013): add a `pumpProductStock` helper and route to the harness, then create `test/widget/features/inventory/product_stock_screen_test.dart`: the title, the rows with their facility, the totals strip (including a negative total), "Ver kardex" present with 32 and absent without it and pushing the right URL, the En tránsito section present only when non-empty, the empty product text, and the not-found state.

**Checkpoint**: US1 and US2 together: from a warehouse's stock, open a product everywhere, or reach it from the catalog.

---

## Phase 5: User Story 3 — Read a product's kardex (Priority: P1)

**Goal**: pick a product, a warehouse and a date range, and see the opening balance, every movement with its running balance, the totals and the closing balance. A movement opens its source document when the app has a screen for it and the user can read it.

**Independent Test**: pick a product and warehouse, with a range that includes a receipt and a count made during testing. Opening plus ins minus outs equals closing, and for a range ending today closing equals Existencias' on-hand figure. The count's row opens that count, and back returns to the same kardex. A range over 366 days shows the explanation and doesn't load.

- [ ] T017 [P] [US3] Test-first, then create the selection and range check (research R4, data-model "KardexSelection"): write `test/unit/features/inventory/kardex_selection_test.dart` first, then `lib/features/inventory/presentation/kardex/kardex_selection.dart` with `KardexSelection` (`productId?`, `warehouseId?`, `from`, `to`; `fromUri` and `toUri` using `product`, `warehouse`, `from`, `to` as `yyyy-MM-dd`; the default range of today − 29 days through today) and a `state` getter returning `incomplete`, `reversed`, `tooLong` or `ready`. Cases: a missing product or warehouse; `to` before `from`; a 365-, 366- and 367-day range (both ends inclusive); a one-day range; the default range; and a URL round trip. Plain Dart, no codegen.

- [ ] T018 [P] [US3] Test-first, then create the source mapping (research R5, data-model "Source mapping"): write `test/unit/features/inventory/kardex_sources_test.dart` first, then `lib/features/inventory/presentation/kardex/kardex_sources.dart` with `kardexSourceLabel(l10n, int type)` (one label per type 1, 2, 3, 4, 5, 6, 8, 10, 12, 13, and the fallback) and `kardexDocumentRoute(KardexDocumentRef? ref, AccessControl access)` returning the path or null. Cases: every type's label; every linked type's route with its read right and null without it; types 8 and 13 mapping to the receipt and delivery order routes; types 6, 10 and an unknown type never linking; and a null document. Depends on T003 for the labels.

- [ ] T019 [US3] Create the kardex controller (depends on T005, T017): `lib/features/inventory/presentation/kardex/kardex_controller.dart`, a `@riverpod` family keyed by `KardexSelection`. It reads only when the selection's state is `ready`, and otherwise returns an empty result with no request. Add `test/unit/features/inventory/kardex_controller_test.dart`: no request when `incomplete`, `reversed` or `tooLong`; one request when `ready` with the right params; an error kept as an `AppError`; and the movements, totals and balances passing through unchanged. Run build_runner.

- [ ] T020 [US3] Create the kardex screen (ui-contract "Kardex", wireframes "Screen: Kardex", research R2, R3, R8, R12, depends on T003, T018, T019): `lib/features/inventory/presentation/kardex/kardex_screen.dart`. Declare `const kardexPath = '/inventory/kardex';` at the top of this file.
  - Filter row: `CatalogFilterBar` with no search and no actions, and `filters` the badged filters button (key `kardex_filter_button`) opening the sheet. The sheet holds Producto (`CatalogEntityPicker<Product>` from `productRepositoryProvider.list(search:, stockable: true, status: null, limit: 10)`, key `kardex_product_filter`, shown only with read on Products), Almacén (key `kardex_warehouse_filter`, read on 4) and Rango (`DateRangeFilterChip` with the real range, `isToday: false`, `firstDate: DateTime(2000)`, `onClear` restoring the last 30 days). The selection lives in the URL through `KardexSelection`.
  - Selection facts strip (key `kardex_selection`) and summary facts strip (key `kardex_summary`): Saldo inicial, Entradas, Salidas, Saldo final.
  - Table: `DataTableView<KardexMovement>` (key `kardex_table`) in server order with Fecha (date and time through `formattersProvider`), Origen (`kardexSourceLabel`), Documento (the folio, "#{id}", "#{reference}" or "—"; a linked row's cell reads as a link, key `kardex_doc_{id}`), Entrada, Salida and Saldo. A linked row's tap pushes its `kardexDocumentRoute`; other rows do nothing. In-memory pages of 100 with `CatalogPagination`, back to page 1 when the selection changes. Add `// simplified: the whole range is held in memory (at most 366 days); if a product's range grows past a few thousand rows, ask mbe-api to page it.`
  - States: incomplete (with the "Elegir" button opening the sheet), reversed and tooLong (the localized texts, no request), loading, no movements (the summary strip plus the text), and error.
  - If the live run (T023) shows that omitting `status` doesn't return inactive products, make the picker query both statuses and merge, with a `// simplified:` comment (research R12).

- [ ] T021 [US3] Add the navigation and the route (research R11, depends on T009, T020).
  - In `lib/core/navigation/nav_destinations.dart`, add `NavBranch.inventoryKardex = 35` and a sixth destination after Existencias: `navInventoryKardex`, `Icons.receipt_long_outlined` / `Icons.receipt_long`, `PrivilegeGate(SystemObject.kardex, AccessRight.read)`, with a comment naming object 32.
  - In `lib/app/router/app_router.dart`, add the `StatefulShellBranch` at the end with `GoRoute(path: kardexPath, builder: KardexScreen(selection: KardexSelection.fromUri(state.uri)))` and a `_routeGate` clause for the `/inventory/kardex` prefix.
  - Add the nav and router cases to `app_router_test.dart` and `nav_destinations_test.dart`: the entry is the sixth on branch 35, absent without read on 32 (a user with only 67 sees Existencias but not Kardex), and the URL redirects to home without the right.

- [ ] T022 [US3] Test the kardex (depends on T006, T020, T021): add a `pumpKardex` helper and its route to the harness, then create `test/widget/features/inventory/kardex_screen_test.dart`: the default last-30-days range; the incomplete state and its button; the reversed and tooLong states making no request; a populated kardex with the summary strip and rows in server order, including a negative balance; a linked row (a count, a receipt, a sales order) pushing its route and a row for a user without that read right doing nothing; an itinerary and a purchase order row showing "#{reference}" and doing nothing; the Spanish source labels, never `sourceName`; a row with no document and reference 0 showing "—"; the no-movements state; 250 rows shown as 100 with the pager moving between pages; the range chip showing real dates and its clear restoring the default; the Producto facet absent without read on Products; and a coded error rendering in Spanish.

**Checkpoint**: all three stories work: from stock to a product, to its kardex, to the document behind a movement.

---

## Phase 6: Polish & cross-cutting

- [ ] T023 [P] Live API test (depends on T005): `test/integration/stock_kardex_live_test.dart`, read-only, mirroring `inventory_counts_live_test.dart`'s login and discovery, with fixtures discovered at run time (a non-transit warehouse with stock rows, and a product with stock in it). Cases:
  - the stock list: a page sorted by code, `q` narrowing it, `include_zero` adding rows, and an in-transit warehouse refused with `warehouse.in_transit_location`;
  - `available == onHand − reserved` for every row of a page;
  - a product's stock listing its warehouses, and the totals summing;
  - a kardex over the last 30 days: opening + totalIn − totalOut equals closing, the running balance of each row follows from the one before, and for a range ending today the closing equals the product's on-hand figure in that warehouse (SC-002);
  - a range of 367 days refused with `kardex.range_too_long` (with `max_days`), and a reversed range with `kardex.range_reversed`;
  - the product list returning an inactive stockable product when `status` is omitted (research R12), skipping when the tenant has none;
  - a kardex row of each source type present, with its `document`, so the source mapping is checked against real data.
  Note in the file header that it makes no writes and which account it needs.

- [ ] T024 [P] Device test (quickstart.md, depends on T015, T021): `integration_test/stock_kardex_quickstart_test.dart`, mirroring `inventory_counts_quickstart_test.dart` and the macOS traps in memory (frame watchdog, picker and back-button finders, `caffeinate -dimsu`). Walk quickstart steps 1–11 as the administrator, plus the `qanoaccess` gate. Run with `caffeinate -dimsu flutter test integration_test/stock_kardex_quickstart_test.dart -d macos --dart-define-from-file=.env`. It writes nothing.

- [ ] T025 [P] Largest text level (quickstart step 12, depends on T010, T016, T022): `test/widget/features/inventory/stock_kardex_large_text_test.dart`, mirroring `inventory_counts_large_text_test.dart`. At the largest text scale and 1280 px, Existencias with long product names, the product view with its totals and in-transit section, and the Kardex with its two strips and a linked row don't clip or scroll sideways.

- [ ] T026 Final checks (depends on all previous tasks).
  - Run `flutter analyze` (no new warnings), `dart format` on the changed files only, and the commands in quickstart.md "Automated checks".
  - Run the live test and the other Inventario live tests (read-only).
  - Search `lib/features/inventory/presentation/stock/` and `kardex/` for literal colours, sizes and spacing (§V), for `NumberFormat` and `toStringAsFixed`, for any display of `enum.name`, `sourceName` or server message text (§III), and for `.clamp` or `max(0` on a quantity.
  - Check the diff against main: `lib/core/widgets/` changes only `record_form_actions.dart`, `lib/generated/` is untouched, and no shipped receipts, issues, transfers or counts file changed.

- [ ] T027 Validate against the quickstart (depends on T026). Run the walkthrough in quickstart.md against the dev mbe-api. Step 13's rights checks need two accounts that aren't seeded (67 without 32, and 32 without 67), so list them as manual checks to track in a GitHub issue after merge, as 067–070 did, together with a real-device largest-text check and SC-001 (a supervisor finds a product's available stock in their warehouse in under 15 seconds). Record the result and any deviation in the PR description, with `Closes mictlanix/mbe-roadmap#67` under "Roadmap".

---

## Dependencies & execution order

- **Phase 1** (T001) first.
- **Phase 2**: T002, T003 and T004 can run in parallel (T002 and T003 both touch the ARB files, so do them one after the other if one person does both). T005 needs T004, and T006 needs T005.
- **US1** (T007–T010) needs Phase 2. **US2** (T011–T016) needs Phase 2, and its route (T013) needs US1's branch (T009). **US3** (T017–T022) needs Phase 2, and its route (T021) needs T009.
- T014 (the `RecordFormActions` slot) has no dependency and can start at any time. T017 and T018 (the pure range check and source mapping) need nothing but T003 (for T018's labels), so they can start early.
- T009, T013 and T021 all edit `app_router.dart` and `nav_destinations.dart`: do them one after the other.
- **Polish** (T023–T025) can start once the code it covers exists, and T026 and T027 come last.

### Parallel opportunities

- T002 ∥ T003 ∥ T004 (error messages, strings, entities), keeping the shared-ARB caution above.
- T014 ∥ any other task (a standalone shared-widget change).
- T017 ∥ T018 (two pure files).
- After Phase 2, US1, US2 and US3 can proceed in parallel, with the routing tasks taken in turn.
- T023 ∥ T024 ∥ T025 (three independent test files).

## Implementation strategy

- **MVP**: Phase 1, Phase 2 and US1 (T001–T010). That delivers Existencias: pick a warehouse, see every figure, search, and reload to the same view.
- **Increment 2**: US2 (the product view and the catalog shortcut) and US3 (the Kardex), in either order. The kardex is the more valuable, since it explains discrepancies.
- **Then**: Polish, the live and device checks, and the quickstart.
- **Risks to watch**:
  - The kardex link table (research R5) depends on routes that already exist. T018's tests pin every type, so a new source type from the server falls back to plain text, not a broken link.
  - The shared `RecordFormActions` edit (T014) must leave every existing caller unchanged. The `core_widgets` golden failures on main make that check a before-and-after comparison, not a pass/fail.
  - Whether omitting `status` returns inactive products (T023, R12) decides if the kardex picker needs a second query.
