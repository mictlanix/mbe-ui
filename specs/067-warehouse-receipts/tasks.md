---
description: "Task list for 067-warehouse-receipts"
---

# Tasks: Warehouse Receipts

**Input**: Design documents from `specs/067-warehouse-receipts/`

**Prerequisites**: plan.md, spec.md (with its Clarifications), research.md (R1–R12), data-model.md, contracts/ui-contract.md, contracts/repository.md, contracts/error-messages.md, quickstart.md, wireframes.md

**Tests**: The spec doesn't ask for a test suite as such, but the constitution's quality gates require tests. Test tasks sit inside each story, after the code they cover.

**Organization**: Grouped by user story (US1–US5, spec.md). US1 and US2 are P1 and together are the MVP: find receipts, then record and confirm one. US3 (correct a draft's header) and US4 (cancel) are P2. US5 (purchase-order figures, warnings, complementary receipt) is P3. Phase 2 holds what two or more stories share.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: parallelizable (different files, no dependency on an incomplete task)
- **[Story]**: US1 find a receipt · US2 record and confirm · US3 correct the header · US4 cancel · US5 purchase-order figures, warnings and complementary receipt

## Cross-story notes

- **Shared files.** Do these sequentially, not in parallel:
  - `lib/features/inventory/presentation/receipts/inventory_receipt_detail_screen.dart`: T018 (US2) creates it with the facts, the lines table and the Confirmar and line actions. T022 (US3) adds Editar encabezado, T025 (US4) adds Cancelar, and T028 (US5) adds the linked columns, the bands and Entrada complementaria. Every control is a nullable callback or a collection-`if`, so an absent right means the control is not in the tree.
  - `lib/features/inventory/presentation/receipts/receipt_dialogs.dart`: T015 (US2) creates it with the quantity, remove-line and confirm prompts, and T024 (US4) adds the cancel prompt. T028 (US5) adds the warning list to the confirm prompt.
  - `lib/features/inventory/presentation/receipts/inventory_receipts_list_screen.dart`: T012 (US1) creates it, and T019 (US2) adds the Nueva entrada button.
  - `lib/app/router/app_router.dart` and `lib/core/navigation/nav_destinations.dart`: T013 (US1) adds the list branch, the nav entry and the gate, and T019 (US2) adds the detail route.
  - `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb`: T002 adds every key once. If a later task needs another, add it there and run `flutter gen-l10n`. Never hand-edit `lib/l10n/app_localizations*.dart`.
- **Generated code.** After editing a freezed or `@riverpod` file, run `dart run build_runner build --delete-conflicting-outputs` at the repo root. Never run two build_runner processes at once: tasks that both need it are not marked [P] against each other. No client regeneration is needed: `InventoryReceiptsApi` already has every operation this spec calls (list, get, create, update, add/update/delete line, confirm, cancel, complementary).
- **Formatting.** Format only the files you changed (`dart format <files>`). Never `dart format .`, and never format `lib/generated/`.
- **Quantities and dates** go through `formattersProvider` (constitution §V). No `NumberFormat`, no `toStringAsFixed`. Quantities are `Decimal`, never `double`; the wire carries them as strings.
- **Spacing tokens, not literals** (`Theme.of(context).spacing`). No automated guard catches a literal, so check it in review.
- **Never match or show server prose** (§III). Show refusals through `AppError.localizedMessage` / `ErrorBanner`, which build the text from the error's `code`. Recognition keys on the code. The server's `warnings[]` text is never shown (spec FR-015a); only its count is used.
- **Status names come from l10n**, never from `enum.name`.
- **Row icons (§VI document reading).** List rows have no icons, and only draft line rows get ✎ and 🗑. This is intentional; see the note under Complexity Tracking in plan.md. Don't add a row Edit icon or a View toggle.
- **Rights.** Every control follows the availability table in data-model.md and the rights lines in contracts/ui-contract.md. A missing right means the control is absent, never disabled. Document the system-object code (InventoryReceipts = 15; Warehouses = 4) in a comment where a route, nav entry or control is gated.
- **Simplifications.** Any shortcut carries a comment `// simplified: <ceiling>, <what to do when it binds>`.
- **Mirror, don't copy blindly.** Closest precedents:
  - List screen, filter and controller: `lib/features/sales/presentation/delivery_orders/{delivery_orders_list_screen, delivery_orders_filter, delivery_orders_list_controller}.dart`, and the `fiscal_documents_*` files under `lib/features/invoicing/presentation/`.
  - Document detail screen (facts strip, lines table, action area, not-found and load-failed views): `delivery_orders/delivery_order_detail_screen.dart`.
  - Write controller returning `AppError?`: `delivery_orders/delivery_order_actions.dart`.
  - Dialog with a busy flag and an inline refusal: `delivery_orders/delivery_order_dialogs.dart` and `add_line_dialog.dart`. "New draft" dialog: `lib/features/invoicing/presentation/new_invoice_dialog.dart`. Product picker dialog: `lib/features/invoicing/presentation/add_product_dialog.dart`.
  - Line row icons: `buildCatalogRowActions` as in `delivery_order_detail_screen.dart`.
  - Repository with a `_toAppError`: `lib/features/sales/data/delivery_order_admin_repository_impl.dart`; its test: `test/unit/features/sales/delivery_order_admin_repository_impl_test.dart`.
  - Widget harness: `test/widget/features/invoicing/invoicing_harness.dart` (mocktail `Mock implements XRepository` plus provider overrides); unit fixtures: `test/unit/features/invoicing/fiscal_document_fixtures.dart`.

---

## Phase 1: Setup

**Purpose**: a known-good baseline, so later failures are attributable.

- [ ] T001 Run `flutter analyze` and the existing tests this feature touches: `test/unit/core/errors/catalog_coverage_test.dart`, `test/unit/core/errors/resource_noun_test.dart`, `test/unit/app/router/app_router_test.dart`, and `test/unit/core/formatting_guard_test.dart`. Record any failure that predates this feature, so it isn't blamed on the new code.

---

## Phase 2: Foundational (blocks all user stories)

**Purpose**: the pieces two or more stories use: strings, error codes, entities and the over-receipt calculator, the repository, the warehouse options, the filter, the controllers and the status chip.

- [ ] T002 Add every new string to `lib/l10n/app_es.arb` and `lib/l10n/app_en.arb`, then run `flutter gen-l10n`. Each key gets an `@key` description starting "spec 067". Check `app_es.arb` first and reuse existing keys (filters button, clear filters, apply, cancel, save, loading and error texts). Keys use the prefix `inventoryReceipt…`; the list is in contracts/ui-contract.md ("Spanish labels") and wireframes.md:
  - **Navigation and titles:** `navInventoryGroup` ("Inventario"), `navInventoryReceipts` ("Entradas de almacén"), `inventoryReceiptTitle` (placeholder `folio`: "Entrada {folio}"), `inventoryReceiptTitleDraft` (placeholder `id`: "Entrada · Borrador #{id}"), `inventoryReceiptDraftFolio` (placeholder `id`: "Borrador #{id}").
  - **Status labels (3):** `inventoryReceiptStatusDraft` ("Borrador"), `…Completed` ("Confirmada"), `…Cancelled` ("Cancelada").
  - **List:** column headers (Folio, Almacén, Sucursal, Orden de compra, Estado, Creado por, Fecha), the facets (Estado, Almacén, "Todos"), the empty ("No hay entradas de almacén") and filtered-empty ("Ninguna entrada coincide con los filtros.") texts.
  - **Detail:** header fact labels (Estado, Folio, Almacén, Sucursal, Orden de compra, Notas, Creado por, Modificado por), the lines table headers (Código, Producto, Cantidad recibida, Ordenado, Recibido en otras entradas), the empty-draft text ("Agrega los productos recibidos."), and the no-sucursal text ("Tu usuario no tiene una sucursal asignada.").
  - **Actions and dialogs:** `inventoryReceiptNewAction` ("Nueva entrada"), `…EditHeader`, `…AddProduct`, `…Confirm`, `…Cancel`, `…Complementary` ("Entrada complementaria"), dialog titles and field labels (Almacén, Notas, Producto, Cantidad), and the confirm, cancel-draft, cancel-completed and remove-line prompts, using the wording in research R11.
  - **Warnings:** the over-receipt line (placeholders `code`, `excess`, `received`, `ordered`: "Se recibió de más {code}: {excess} (recibido {received} de {ordered} ordenado)") and the cost notice ("Se actualizaron los costos con excepciones.") with its close tooltip.
  - **Error messages:** the nine keys in contracts/error-messages.md (T003 wires them).

- [ ] T003 [P] Localize the nine new codes (contracts/error-messages.md, depends on T002).
  - In `lib/core/errors/localize_problem.dart`, add the generated `api.ErrorCode` members `inventoryReceiptPeriodWarehouseFixed`, `inventoryReceiptPeriodComplementaryUnavailable`, `inventoryDocumentPeriodInsufficientStock`, `inventoryDocumentPeriodNoLines`, `inventoryDocumentPeriodLineWithoutQuantity`, `inventoryDocumentPeriodAlreadyCancelled`, `productPeriodNotStockable`, `facilityPeriodNoInTransitLocation` and `statusFilterPeriodUnsupported` to `localizedErrorCodes`, with a case each in the `localizeProblem` switch. `complementary_unavailable` switches on its `reason` param, with the generic fallback for an unknown or missing one. `insufficient_stock` formats `requested` and `available` with the quantity formatter. `no_lines` and `already_cancelled` use `resourceNoun` / `resourceGender` for `resource`. Every missing or mistyped param falls back to the param-less wording.
  - In `test/unit/core/errors/problem_fixtures.dart`, add a fixture for each code, and add the parameterized ones to `needParams` in `catalog_coverage_test.dart`.
  - In `specs/058-localized-api-errors/contracts/code-scope.tsv`, flip these nine `code` rows from `OUT` to `IN`, setting `example_routes` to the receipt endpoint (for example `POST /inventory-receipts/{}/confirm`) and the note to "reachable from the Entradas de almacén screens (spec 067)".
  - Raise the `checked` count in `catalog_coverage_test.dart` by nine (confirm the current value first; it was 143).
  - Run `flutter test test/unit/core/errors/`.

- [ ] T004 [P] Create the entities and the over-receipt calculator (data-model.md).
  - In `lib/features/inventory/domain/entities/inventory_receipt.dart` (freezed): `ReceiptStatus` (`draft`, `completed`, `cancelled`), `InventoryReceiptSummary`, `InventoryReceipt`, `InventoryReceiptLine` and `InventoryReceiptPage`, with the fields, derived values (`displayFolio`, `isDraft`, `isLinked`, `overReceipts`, `hasUnmappedWarnings`) and rules in data-model.md. `displayFolio` is the serial, or "Borrador #{id}" built by the presentation layer from l10n; the entity keeps only the nullable serial and the id.
  - In `lib/features/inventory/domain/over_receipt.dart`: `OverReceipt` and the pure `computeOverReceipts(lines)`, with the four-step grouping in data-model.md (group by purchase-order line, first-seen order; `received = elsewhere + sum`; emit when `received > ordered`).
  - Add `test/unit/features/inventory/over_receipt_test.dart` with the six cases listed in data-model.md: no linked lines, exactly at ordered, above ordered, two lines on one order line, elsewhere counted, null elsewhere as 0.
  - Run build_runner.

- [ ] T005 Create the repository (contracts/repository.md, research R8, depends on T004).
  - In `lib/features/inventory/domain/repositories/inventory_receipt_repository.dart` declare `list`, `get`, `create`, `updateHeader`, `addLine`, `updateLine`, `removeLine`, `confirm`, `cancel` and `complementary`, as in contracts/repository.md.
  - In `lib/features/inventory/data/inventory_receipt_repository_impl.dart`, implement them over the generated `InventoryReceiptsApi(dio, appSerializers)`, with `inventoryReceiptRepositoryProvider`. Map `DocumentStatus` to `ReceiptStatus` (a `paid` value is a mapping error, never guessed), parse the wire quantity strings into `Decimal`, treat a null `lines` as empty, keep only `warnings.length` as `serverWarningCount`, and map `DioException` to `AppError` as `delivery_order_admin_repository_impl.dart` does. `status` goes on the wire as `draft` / `completed` / `cancelled`.
  - `updateHeader` sends `warehouse` only when given. For `clearComment`, follow research R8: send an empty string first; if a live check (T030) shows the client drops it, fall back to a raw `dio.put` with `{"comment": null}` deserialized with `appSerializers`. Leave a `// simplified:` comment naming the live check.
  - Create `test/unit/features/inventory/inventory_receipt_fixtures.dart` (builders for summaries, receipts and lines) and `test/unit/features/inventory/inventory_receipt_repository_impl_test.dart`: the list params, each mapping case above, `complementary` returning both a 200 and a 201 body, `updateHeader` sending only changed fields, and a `DioException` becoming a coded `AppError`.

- [ ] T006 [P] Create the status chip (depends on T002, T004): `lib/features/inventory/presentation/receipts/inventory_receipt_status_chip.dart` with `InventoryReceiptStatusChip` on `StatusChip<ReceiptStatus>` (key `inventory_receipt_status_chip`), with its colours from the theme scheme and its labels from l10n. Add a small widget test in `test/widget/features/inventory/inventory_receipt_status_chip_test.dart`.

- [ ] T007 [P] Create the warehouse options (research R5, spec FR-005 and FR-017, depends on T002): `lib/features/inventory/presentation/receipts/receipt_warehouse_options.dart`.
  - A function or provider that returns active warehouses for a search text through `warehouseRepositoryProvider.list(search:, status: active, facilityId:, limit: 10)`. `facilityId` is the session user's facility (`AuthAuthenticated.user.settings.facilityId`; see how `lib/core/widgets/user_menu_button.dart` reads settings) for a non-administrator, and null for an administrator (`accessControlProvider.isAdministrator`).
  - A non-administrator with no facility gets an empty result and a flag the dialogs use to show the no-sucursal text.
  - A provider for the starting warehouse: `pointSaleRepositoryProvider.get(pointSaleId: settings.pointSaleId).warehouseId`, null when the user has no point of sale or the lookup fails. For a non-administrator it is also null when that warehouse's facility is not the user's own facility (spec FR-005), so the starting value is always one the picker would offer. For the starting warehouse's display name use `warehouseDisplayNameProvider`.
  - A variant without `facilityId` for the list filter (every warehouse, for everyone).
  - Add `test/unit/features/inventory/receipt_warehouse_options_test.dart`: an administrator gets no facility filter, a non-administrator gets their own, no facility gives the flag, a failed point-of-sale lookup gives null, a non-administrator whose point-of-sale warehouse is in another facility gets null (an administrator still gets it), the filter variant never limits.

- [ ] T008 [P] Create the filter (research R9, depends on T004): `lib/features/inventory/presentation/receipts/inventory_receipts_filter.dart` (freezed), with `fromQuery(ListQuery)`, `toQuery`, `activeFilterCount`, `isNarrowed` and `cleared()`. Keys: `status` (`draft` | `completed` | `cancelled`) and `warehouse` (int), plus the page. An unknown status value in the URL is ignored. Add `test/unit/features/inventory/inventory_receipts_filter_test.dart`: round trip, the count, an unknown status, and `cleared()`.

- [ ] T009 Create the list controller (depends on T005, T008): `lib/features/inventory/presentation/receipts/inventory_receipts_list_controller.dart`, an `AsyncNotifier` family keyed by the filter, 20 per page, page clamped with `fetchClampedPage`. The server orders newest first and the client sends no sort and no scope parameter (spec FR-002). Add `test/unit/features/inventory/inventory_receipts_list_controller_test.dart`: the params sent, page clamping, and an error becoming `AsyncError`.

- [ ] T010 Create the detail controller (depends on T005): `lib/features/inventory/presentation/receipts/inventory_receipt_detail_controller.dart`, a `@riverpod` family keyed by the receipt id that loads the receipt and exposes a `refresh()` that re-fetches. Add `test/unit/features/inventory/inventory_receipt_detail_controller_test.dart`: a load, a not-found error kept as an `AppError`, and `refresh()`.

- [ ] T011 Create the write controller (contracts/repository.md "Actions notifier", research R6 and R7, depends on T005, T010): `lib/features/inventory/presentation/receipts/inventory_receipt_actions.dart`, a keep-alive notifier with `create`, `updateHeader`, `addLine`, `updateLine`, `removeLine`, `confirm`, `cancel` and `complementary`.
  - Each returns `AppError?` (null on success). On success it writes the returned receipt into `inventoryReceiptDetailControllerProvider(id)` and invalidates the list family. `create` and `complementary` also return the new receipt's id so the caller can navigate; `confirm` and `cancel` also return `hasUnmappedWarnings` (the server's warning count is greater than `computeOverReceipts` of the returned lines).
  - After a refusal with `document.not_editable`, `inventory_document.already_cancelled` or `lock.busy`, it calls `refresh()` on the detail controller (spec edge case: concurrent edits).
  - Add `test/unit/features/inventory/inventory_receipt_actions_test.dart`: each action's success and refusal, the invalidations, the new id from `create` and `complementary`, `hasUnmappedWarnings` true and false, and the refresh after each of the three codes.

---

## Phase 3: User Story 1 — Find a receipt (Priority: P1) 🎯 MVP

**Goal**: a clerk opens Entradas de almacén and sees the receipts the server grants them, newest first, filtered by state and warehouse, with each receipt's folio, warehouse, facility, purchase order, state, creator and date.

**Independent Test**: as a non-administrator with read on 15, open the list and check that only receipts for their warehouse or created by them appear. Filter by state, then by warehouse. As an administrator every receipt appears. As `qanoaccess`, the entry is missing and the URL shows the no-access screen.

- [ ] T012 [US1] Create the list screen (ui-contract "List screen", wireframes "Screen: Entradas de almacén list", depends on T006, T007, T009): `lib/features/inventory/presentation/receipts/inventory_receipts_list_screen.dart`. Declare `const inventoryReceiptsPath = '/inventory/receipts';` at the top of this file; T013 and later tasks import it.
  - Filter row: `CatalogFilterBar` with **no search control**, and the badged filters `IconButton.outlined(Icons.tune)` that opens `showCatalogFilterSheet` with `CurrentListQueryBuilder`. The drawer holds Estado (choice chips, single select or none) and, with read on Warehouses (4), Almacén (a `CatalogEntityPicker<Warehouse>` using the unlimited variant from T007).
  - Table: `DataTableView<InventoryReceiptSummary>` with the columns in order: Folio (right-aligned; the serial, or "Borrador #{id}" for a draft), Almacén, Sucursal, Orden de compra, Estado (`InventoryReceiptStatusChip`), Creado por, Fecha. Names come from `warehouseDisplayNameProvider`, `facilityDisplayNameProvider` and `employeeDisplayNameProvider` (`creator` is an employee id). Those providers return null when the lookup fails (for example, no read right on that catalog); show "#{id}" then, here and on the detail screen (T018). The row tap pushes `'$inventoryReceiptsPath/${id}'`. No row icons.
  - `CatalogListStateView` for loading, empty, filtered-empty (with "Limpiar filtros") and error; `CatalogPagination`; the page lives in the URL.
  - Dates through `formattersProvider`. No Nueva entrada button yet (T019).

- [ ] T013 [US1] Add the navigation and the list route (ui-contract "Routes and navigation", depends on T012).
  - In `lib/core/navigation/nav_destinations.dart`, add `NavBranch.inventoryReceipts = 30` (confirm the next free index first; `fiscalDocuments` was 29) and a new `NavGroup(id: 'inventory', label: navInventoryGroup)` between Logística and Facturación, with one destination, "Entradas de almacén" (`Icons.move_to_inbox_outlined` / `Icons.move_to_inbox`, `PrivilegeGate(SystemObject.inventoryReceipts, AccessRight.read)`). Update the comments there that describe the order of the groups.
  - In `lib/app/router/app_router.dart`, add the `StatefulShellBranch` at the end, with `GoRoute(path: inventoryReceiptsPath, builder: InventoryReceiptsListScreen(query: ListQuery.fromUri(state.uri)))`, and the `_routeGate` clause for the `/inventory/receipts` prefix returning `PrivilegeGate(SystemObject.inventoryReceipts, AccessRight.read)`.
  - Add the nav and router cases to `test/unit/app/router/app_router_test.dart` and the navigation tests: the group and entry appear with read on 15, are absent without it, and the URL shows the no-access screen.

- [ ] T014 [US1] Test the list: create `test/widget/features/inventory/inventory_harness.dart` (a mocktail `MockInventoryReceiptRepository`, the warehouse, facility and employee name providers overridden, and a signed-in user with configurable rights, as in `invoicing_harness.dart`) and `test/widget/features/inventory/inventory_receipts_list_screen_test.dart`: rows render with a draft showing "Borrador #{id}" and no folio, a confirmed receipt showing its folio and its purchase order, there are no row icons, the filter badge shows the active count, the status and warehouse facets are sent to the repository, no search control is present, the empty and filtered-empty states render with the "Limpiar filtros" action, a failed name lookup shows "#{id}", and a read error shows the banner.

**Checkpoint**: US1 is demonstrable on its own: open the list, filter it, and open a (still empty) detail URL.

---

## Phase 4: User Story 2 — Record and confirm a receipt (Priority: P1) 🎯 MVP

**Goal**: a clerk creates a receipt, adds the products received, edits quantities, removes lines, and confirms it. The receipt then shows its folio and is read-only.

**Independent Test**: as the non-administrator, create a receipt (starting on their point-of-sale warehouse), add two stockable products, add one again and check that its quantity grows, edit and remove a line, then confirm. The receipt shows its folio and Confirmada, and the warehouse stock has grown. Confirm an empty draft and check the Spanish reason.

- [ ] T015 [US2] Create the dialogs file (research R11, wireframes "Dialogs", depends on T002, T011): `lib/features/inventory/presentation/receipts/receipt_dialogs.dart`, built on `showResponsiveDialog`.
  - `showReceiptLineQuantityDialog` (quantity > 0, prefilled, `hasUnsavedChanges`, busy flag, refusal in `FormErrorBanner`, stays open on refusal).
  - `showRemoveReceiptLineDialog` (the delivery-orders remove prompt).
  - `showConfirmReceiptDialog` (explanation text from research R11; the over-receipt list is added in T028).
  - Each returns after calling the matching `InventoryReceiptActions` method, and shows the `AppError?` it returns.

- [ ] T016 [US2] Create the new-receipt dialog (research R4 and R5, depends on T007, T011): `lib/features/inventory/presentation/receipts/new_receipt_dialog.dart`, modelled on `new_invoice_dialog.dart`.
  - Almacén (required, a `CatalogEntityPicker<Warehouse>` over T007's own-facility options; it starts as the point-of-sale warehouse when T007 returns one, and the starting value alone doesn't count as an unsaved change) and Notas (`maxLength` 500 with a counter). When T007 flags no facility, show the no-sucursal text and disable nothing else.
  - "Crear" calls `InventoryReceiptActions.create` and, on success, pushes `'$inventoryReceiptsPath/$newId'`. A refusal such as `warehouse.in_transit_location` shows in the dialog.
  - The dialog is only reachable with create on 15 and read on 4 (T019 gates the button).

- [ ] T017 [US2] Create the add-line dialog (research R5, depends on T011): `lib/features/inventory/presentation/receipts/add_receipt_line_dialog.dart`, modelled on `add_product_dialog.dart`. Producto is a `CatalogEntityPicker<Product>` fed by `productRepositoryProvider.list(search:, status: EntityStatus.active, stockable: true, limit: 10)`; Cantidad is a quantity field (`fmt.field.quantity` / `parseQuantity`, must be > 0). The dialog sets `hasUnsavedChanges` once a product or quantity is entered, and has a busy flag. "Agregar" calls `addLine`; the dialog stays open on refusal and shows it. Adding a product already on the receipt merges on the server and the screen shows the returned receipt.

- [ ] T018 [US2] Create the detail screen (ui-contract "Detail screen", wireframes "Screen: Receipt detail", depends on T006, T010, T011, T015, T017): `lib/features/inventory/presentation/receipts/inventory_receipt_detail_screen.dart`.
  - Title: "Entrada {folio}" for a confirmed or cancelled receipt, and "Entrada · Borrador #{id}" for a draft (FR-004a). AppBar actions empty.
  - Header facts in `FactStripRow`s inside a `ResponsiveFormGrid` (names through the same providers as T012, with the "#{id}" fallback): Estado (chip), Folio, Almacén, Sucursal, Orden de compra (when linked), Notas, Creado por with date, Modificado por with date.
  - Lines table (`DataTableView`): Código, Producto, Cantidad recibida (right-aligned). On a draft with update on 15, rows get ✎ and 🗑 through `buildCatalogRowActions` (quantity dialog, remove prompt). The empty draft shows "Agrega los productos recibidos."
  - Action area in the body, with each control absent without its right: Agregar producto (update on 15, a draft, read on Products) and Confirmar (update on 15, a draft; `showConfirmReceiptDialog`, then `confirm`).
  - Refusals show in an `ErrorBanner` above the action area. Not-found and load-failed views follow `delivery_order_detail_screen.dart`.

- [ ] T019 [US2] Add the detail route and the Nueva entrada button (depends on T016, T018).
  - In `lib/app/router/app_router.dart`, add the top-level `GoRoute('$inventoryReceiptsPath/:id')` for `InventoryReceiptDetailScreen`, with the same read-on-15 gate, and update `app_router_test.dart`.
  - In `inventory_receipts_list_screen.dart`, add the "Nueva entrada" `FilledButton.icon` (`Icons.add`) to `CatalogFilterBar.actions`, shown only with create on 15 and read on 4, opening `showNewReceiptDialog`.

- [ ] T020 [US2] Test the creation, lines and confirm (depends on T014, T019).
  - `test/widget/features/inventory/new_receipt_dialog_test.dart`: the starting warehouse (and an empty start for a non-administrator whose point-of-sale warehouse is in another facility), own-facility options for a non-administrator and all of them for an administrator, the no-sucursal text, notes over 500 characters can't be submitted, a refusal stays in the dialog, and success pushes the detail.
  - `test/widget/features/inventory/add_receipt_line_dialog_test.dart` (the picker asks for stockable products, a quantity of 0 can't be submitted, a refusal stays) and `receipt_dialogs_test.dart` (quantity, remove and confirm prompts).
  - `test/widget/features/inventory/inventory_receipt_detail_screen_test.dart`: a draft shows the "Borrador #{id}" title and its actions per rights, a read-only user and a completed receipt show no actions or line icons, adding the same product twice shows the single merged line the repository returns, confirm shows the folio and the read-only state, confirming an empty draft shows the localized `no_lines` text, and a `facility.other_facility` refusal shows its Spanish message.

**Checkpoint**: US1 and US2 together are the MVP: clerks can record and confirm deliveries.

---

## Phase 5: User Story 3 — Correct a draft's header (Priority: P2)

**Goal**: on a draft, the clerk changes the destination warehouse or the notes. Changing the warehouse moves the draft to that warehouse's facility.

**Independent Test**: as an administrator, change a draft's warehouse to one of another facility and edit the notes; both persist and the facility changes. As a non-administrator the picker offers only their own facility. A receipt linked to a purchase order shows its warehouse read-only. Clear the notes and confirm that no note shows after reopening.

- [ ] T021 [US3] Create the header dialog (ui-contract "Dialogs", depends on T007, T011): `lib/features/inventory/presentation/receipts/receipt_header_dialog.dart`. Almacén is a `CatalogEntityPicker<Warehouse>` over T007's own-facility options, shown only with read on Warehouses (4) (FR-016). It is read-only text when the receipt is linked to a purchase order (FR-006) or when the user lacks read on 4. Notas has `maxLength` 500. "Guardar" sends only the changed fields (`updateHeader`; clearing the notes uses `clearComment`, research R8). `hasUnsavedChanges`, busy flag, inline refusal.

- [ ] T022 [US3] Add Editar encabezado to the detail screen (depends on T018, T021): in `inventory_receipt_detail_screen.dart`, add an `OutlinedButton` shown only with update on 15 and a draft, opening `showReceiptHeaderDialog`. After saving, the screen shows the returned receipt.

- [ ] T023 [US3] Test the header (depends on T020, T022): create `test/widget/features/inventory/receipt_header_dialog_test.dart`: only changed fields are sent, notes over 500 characters can't be saved, a linked receipt shows the warehouse as text, a user without read on Warehouses (4) sees the warehouse as text and can still save the notes, a non-administrator's picker is limited to their facility, a clearing of the notes is sent as `clearComment`, and a refusal (`warehouse.in_transit_location`) stays in the dialog. Extend the detail screen test: Editar encabezado is absent for a completed or cancelled receipt, and for a user without update on 15.

---

## Phase 6: User Story 4 — Cancel a receipt (Priority: P2)

**Goal**: the clerk cancels a draft, or cancels a confirmed receipt, which takes its stock back out. The server refuses a confirmed cancel when the goods have already left.

**Independent Test**: cancel a draft and see Cancelada. Confirm another receipt, cancel it, and check the stock is back. Confirm a third, move part of its goods out, cancel it, and see the insufficient-stock message with the quantities and the product code; the receipt stays Confirmada. As a user without delete on 15 the action is absent.

- [ ] T024 [US4] Add the cancel prompt to `receipt_dialogs.dart` (research R11, depends on T015): `showCancelReceiptDialog`, with "Cancelar el borrador" wording for a draft and, for a confirmed receipt, text saying its stock will be taken back out of the warehouse. There is no reason field. "Cancelar entrada" calls `cancel`.

- [ ] T025 [US4] Add Cancelar to the detail screen (depends on T018, T024): in `inventory_receipt_detail_screen.dart`, add the error-toned `OutlinedButton`, shown only with delete on 15 and a status other than cancelled, first in the action area. On an `inventory_document.insufficient_stock` refusal, the banner adds "Producto: {code}" by looking up `product_id` among the receipt's lines (research R7); the shared message stays generic. Leave a `// simplified:` comment: the lookup covers only products on this receipt, which is every product the refusal can name.

- [ ] T026 [US4] Test the cancel (depends on T020, T025): extend `test/widget/features/inventory/receipt_dialogs_test.dart` and `inventory_receipt_detail_screen_test.dart`: draft and confirmed wording, cancel success shows Cancelada, the action is absent without delete on 15 and on a cancelled receipt, `insufficient_stock` shows the localized message with the quantities and the product code and leaves the receipt unchanged, and `already_cancelled` shows its message and refreshes.

---

## Phase 7: User Story 5 — Purchase-order figures, warnings and complementary receipt (Priority: P3)

**Goal**: a receipt linked to a purchase order shows what was ordered and received elsewhere, warns without blocking when a line goes over, and offers the complementary receipt.

**Independent Test**: open a confirmed legacy receipt of an under-received order: linked lines show Ordenado and the others' totals. Choose Entrada complementaria: a draft opens with the remaining quantities; choose it again: the same draft opens. Raise a line above what is left: the over-receipt band names the product and the excess, and Confirmar still works. After a confirm that returns cost warnings, the notice band shows until it is closed.

- [ ] T027 [US5] Create the warnings widgets and notice state (research R6, depends on T002, T004): `lib/features/inventory/presentation/receipts/receipt_warnings.dart`.
  - `ReceiptOverReceiptBand`: a warning-toned, feature-local band (wireframes Open Question 1 records that no shared warning widget exists) listing one line per `OverReceipt`; nothing when the list is empty.
  - `ReceiptCostNoticeBand`: an info-toned band with the cost notice text and a close button (key `receipt_cost_notice_close`).
  - A small `@riverpod` autodispose `Notifier` family keyed by receipt id that holds whether the cost notice is showing: `show()` after an action reports `hasUnmappedWarnings`, `dismiss()` from the close button. Being autodispose, it clears when the user leaves the receipt (spec FR-015a).
  - Colours and spacing from the theme and tokens.

- [ ] T028 [US5] Complete the detail screen for linked receipts (depends on T011, T018, T027).
  - In `inventory_receipt_detail_screen.dart`: when `isLinked`, add the Ordenado and Recibido en otras entradas columns (right-aligned; a hand-added line shows "—" in both). Show `ReceiptOverReceiptBand` for a draft or confirmed receipt whenever `overReceipts` is non-empty, and `ReceiptCostNoticeBand` while the notice state says so. After `confirm` or `cancel` reports `hasUnmappedWarnings`, call the notice state's `show()`.
  - Add Entrada complementaria: an `OutlinedButton` shown only with create on 15, a linked receipt and a status other than cancelled. It calls `complementary` and pushes `'$inventoryReceiptsPath/$returnedId'`, for both the 200 and the 201 case. A 409 `complementary_unavailable` shows its reason in the banner.
  - In `receipt_dialogs.dart`, extend `showConfirmReceiptDialog` so the prompt lists the current over-receipts (research R11).

- [ ] T029 [US5] Test the purchase-order behaviour (depends on T020, T028):
  - `test/widget/features/inventory/receipt_warnings_test.dart`: the over-receipt band lists each excess and is absent when there is none; the cost band shows and the close button dismisses it; it clears when the screen is rebuilt for another receipt.
  - Extend `inventory_receipt_detail_screen_test.dart`: linked columns appear only when linked and show "—" on a hand-added line; the confirm prompt lists the over-receipts and confirming still works; after a confirm and a cancel that report extra warnings, the cost band shows; Entrada complementaria is absent without create on 15, on an unlinked receipt and on a cancelled one, and pushes the returned id for a 200 and for a 201; each of the four `complementary_unavailable` reasons shows its Spanish text.

---

## Phase 8: Polish and cross-cutting

**Purpose**: live verification, the device walkthrough, text-size checks and the release notes.

- [ ] T030 Create `test/integration/inventory_receipts_live_test.dart` (follow `test/integration/fiscal_documents_live_test.dart` and `TEST_ACCOUNTS.md`; `--dart-define-from-file=.env.settings`; writes only with `MBE_WRITE=true`). Discover its fixtures at runtime (research R12): an active stockable product, a warehouse in the account's facility, and any receipt with a purchase order for the complementary path, which is skipped when none exists. Read-only part: the list (scope and the status and warehouse filters) and a receipt detail. Write part: create, add the same product twice (one merged line), edit, remove, confirm with a stock check through `StockApi` before and after (SC-002), cancel a draft, cancel a confirmed receipt, and the insufficient-stock refusal. **Also record two answers in the file's header comment**, because the plan left them as live checks: whether clearing the notes with `""` leaves no note (research R8), and whether the warehouse list returns in-transit warehouses (quickstart step 4).

- [ ] T031 [P] Create `integration_test/inventory_receipts_quickstart_test.dart` (follow `integration_test/delivery_orders_quickstart_test.dart` and the traps in the macOS integration-test notes: the frame-stall watchdog, the login finder and the picker finders). Cover quickstart steps 1–3, 5–7 and 9 on a macOS device.

- [ ] T032 [P] Check the largest text level (constitution §V, quickstart step 10): add widget cases at the largest of the four text levels for the list and the lines table, asserting no overflow, following the pattern the earlier specs use (`grep -rn "textScale\|textScaler" test/widget/features`).

- [ ] T033 Run the quickstart (`specs/067-warehouse-receipts/quickstart.md`) against the dev backend, steps 1–10, and note each result. Mark which steps need a legacy purchase-order fixture and were skipped, if any.

- [ ] T034 Final checks: `dart format` on only the changed files, `flutter analyze` (no new issues), `flutter test` for the whole suite (including `catalog_coverage_test.dart`, `formatting_guard_test.dart` and `app_router_test.dart`), and confirm no hand-edited generated files (`git status` shows no `lib/generated/` changes).

- [ ] T035 Record the release notes for the PR description: under "Roadmap", `Closes mictlanix/mbe-roadmap#59`; list what stays manual (the purchase-order fixture steps if skipped, the largest-text check on a real device, and the two live answers from T030); and name mictlanix/mbe-api#322 (coded warnings) as the follow-up that lets the client drop `computeOverReceipts` and the generic cost notice.

---

## Dependencies and execution order

- **Phase 1 → Phase 2 → stories.** T001 first. Phase 2 blocks every story.
- **Phase 2 order:** T002 first (strings). Then T003, T004 and T007, T008 in parallel (T003 needs T002; T007 needs T002). T005 needs T004. T006 needs T002 and T004. T009 needs T005 and T008. T010 needs T005. T011 needs T005 and T010.
- **Stories:** US1 (T012–T014) needs Phase 2. US2 (T015–T020) needs Phase 2 and builds on US1's list files (T019). US3 (T021–T023), US4 (T024–T026) and US5 (T027–T029) each need US2's detail screen (T018) but not each other, and none depends on US1's list beyond the shared files noted above.
- **Shared files** (see the cross-story notes) mean the detail-screen tasks T018 → T022 → T025 → T028 run in that order. If US3, US4 and US5 are done by different people, agree that order.
- **Polish** needs every story it covers: T030 and T033 need US1–US5, T031 needs US1–US4.

### Parallel opportunities

- Phase 2: after T002, T003, T004 and T007 can run at the same time. T006 and T008 follow T004 and can run beside each other; they touch different files.
- Within US2: T016 (new-receipt dialog) and T017 (add-line dialog) are independent files, but both depend on T011. T015 can run beside them.
- After T018: T021, T024 and T027 (dialog and widget files) can be written in parallel, then their detail-screen edits (T022, T025, T028) applied in order.
- Phase 8: T031 and T032 are parallel.

### Implementation strategy

1. **MVP:** Phase 1, Phase 2, US1 and US2. That records and confirms deliveries.
2. **Next:** US3 and US4 in either order (header correction, cancellation).
3. **Last:** US5 for the purchase-order views and the complementary receipt, which can only be checked against legacy receipts.
4. After each story, run its tests and its slice of the quickstart before starting the next.
