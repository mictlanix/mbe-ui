---
description: "Task list for 069-inventory-transfers"
---

# Tasks: Inventory Transfers

**Input**: Design documents from `specs/069-inventory-transfers/`

**Prerequisites**: plan.md, spec.md, research.md (R1–R12), data-model.md, contracts/ui-contract.md, contracts/repository.md, contracts/error-messages.md, quickstart.md, wireframes.md

**Tests**: The spec doesn't ask for a test suite as such, but the constitution's quality gates require tests. Test tasks sit inside each story, after the code they cover.

**Organization**: Grouped by user story (US1–US8, spec.md).
- **P1 (the MVP)**: US1 find a transfer, US2 prepare and dispatch, US3 receive.
- **P2**: US4 close the remainder, US5 correct the header, US6 cancel.
- **P3**: US7 in-transit view, US8 fill from a sales order.

Phase 2 holds what two or more stories share: the error messages, strings, entities, repository, controllers and the status chip and filter. Unlike 068, nothing shipped is moved or renamed (research R1).

## Format: `[ID] [P?] [Story] Description`

- **[P]**: parallelizable (different files, no dependency on an incomplete task)
- **[Story]**: US1 find · US2 prepare and dispatch · US3 receive · US4 close the remainder · US5 correct the header · US6 cancel · US7 in transit · US8 fill from a sales order

## Cross-story notes

- **This feature builds on specs 067 and 068.** `lib/features/inventory/` and its tests already exist. Open the issues counterpart of every file below (`presentation/issues/…`, `data/inventory_issue_repository_impl.dart`, and the tests named `*_issue_*`) before writing the transfer version, and mirror it with the differences research.md and ui-contract.md list: two warehouses, four states, the received and outstanding quantities, and the extra actions.
- **Shared files.** Do these sequentially, not in parallel:
  - `lib/features/inventory/presentation/transfers/inventory_transfer_detail_screen.dart`: T016 (US2) creates it with the facts, both lines tables (the draft one and the dispatched one), the line actions, Agregar producto, Despachar and the refusal enrichment. T020 (US3) adds Recibir, T023 (US4) Cerrar pendiente, T026 (US5) Editar encabezado, T029 (US6) Cancelar and T036 (US8) Agregar desde pedido. Every control is a nullable callback or a collection-`if`, so an absent right means the control is not in the tree.
  - `lib/features/inventory/presentation/transfers/transfer_dialogs.dart`: T013 (US2) creates it with the quantity, remove-line and dispatch prompts, T022 (US4) adds the close prompt, and T028 (US6) adds the cancel prompt.
  - `lib/features/inventory/presentation/transfers/inventory_transfers_list_screen.dart`: T010 (US1) creates it, T017 (US2) adds Nuevo traspaso, and T033 (US7) adds En tránsito.
  - `lib/app/router/app_router.dart` and `lib/core/navigation/nav_destinations.dart`: T011 (US1) adds the list branch, the nav entry and the gate, T017 (US2) adds the detail route, and T033 (US7) adds the in-transit route. **In-transit must be declared before `/:id`**, or `in-transit` is read as an id.
  - `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb`: T002 adds the error-message keys and T003 adds every transfer key once. If a later task needs another, add it there and run `flutter gen-l10n`. Never hand-edit `lib/l10n/app_localizations*.dart`.
  - `test/widget/features/inventory/inventory_harness.dart`: T012 extends it, and later tests only use it.
- **Generated code.** After editing a freezed or `@riverpod` file, run `dart run build_runner build --delete-conflicting-outputs` at the repo root. Never run two build_runner processes at once: tasks that both need it are not marked [P] against each other. No client regeneration is needed: `InventoryTransfersApi` already has every operation this spec calls.
- **Formatting.** Format only the files you changed (`dart format <files>`). Never `dart format .`, and never format `lib/generated/`.
- **Quantities and dates** go through `formattersProvider` (constitution §V). No `NumberFormat`, no `toStringAsFixed`. Quantities are `Decimal`, never `double`; the wire carries them as strings.
- **Spacing tokens, not literals** (`Theme.of(context).spacing`). No automated guard catches a literal, so check it in review.
- **Never match or show server prose** (§III). Show refusals through `AppError.localizedMessage` / `ErrorBanner`, which build the text from the error's `code`. Recognition keys on the code.
- **Status names come from l10n**, never from `enum.name`.
- **Row icons (§VI document reading).** List rows have no icons, and only draft line rows get ✎ and 🗑. This is intentional; see the Complexity Tracking row in plan.md. Don't add a row Edit icon or a View toggle. The AppBar has no actions, and "En tránsito" is a filter-row button.
- **Rights.** Every control follows the availability table in data-model.md and the rights lines in contracts/ui-contract.md. A missing right means the control is absent, never disabled. Document the system-object code (InventoryTransfers = 17; Warehouses = 4) in a comment where a route, nav entry or control is gated. The facility rule is not mirrored in the UI (research R5): show the server's refusal.
- **Simplifications.** Any shortcut carries a comment `// simplified: <ceiling>, <what to do when it binds>`.
- **Closest precedents**, each transfer file mirroring its issue file:
  - `inventory_issues_list_screen.dart`, `inventory_issue_detail_screen.dart`, `inventory_issue_actions.dart`, `new_issue_dialog.dart`, `issue_header_dialog.dart`, `add_issue_line_dialog.dart`, `issue_dialogs.dart`.
  - Repository: `data/inventory_issue_repository_impl.dart`, with its test.
  - Test builders: `test/unit/features/inventory/inventory_issue_fixtures.dart`. Widget harness: `test/widget/features/inventory/inventory_harness.dart`.
  - Live test: `test/integration/inventory_issues_live_test.dart`. Device test: `integration_test/inventory_issues_quickstart_test.dart`.
  - For the facility picker (US7): `lib/features/sales/presentation/delivery_orders/delivery_orders_list_screen.dart` (the inline `CatalogEntityPicker<FacilityListItem>` with "Mi sucursal"). For the order search (US8): the `listOrders` call in `lib/features/sales/presentation/delivery_orders/add_line_dialog.dart` and the one-step `lib/features/invoicing/presentation/add_sales_order_dialog.dart`.

---

## Phase 1: Setup

**Purpose**: a known-good baseline, so later failures are attributable.

- [X] T001 Run `flutter analyze` and the tests this feature touches: all of `test/unit/features/inventory/` and `test/widget/features/inventory/`, plus `test/unit/core/errors/catalog_coverage_test.dart`, `test/unit/core/navigation/nav_destinations_test.dart`, `test/unit/app/router/app_router_test.dart` and `test/unit/core/formatting_guard_test.dart`. Record any failure that predates this feature, so it isn't blamed on the new code. (The 6 `core_widgets` golden failures recorded in spec 067 fail identically on main and are outside these folders.)

---

## Phase 2: Foundational (blocks all user stories)

**Purpose**: the error messages, strings, entities, repository, controllers, status chip and filter that two or more stories share.

- [X] T002 Localize the transfer error codes (research R11, contracts/error-messages.md "New"). Mirror how `inventory_document.insufficient_stock` is wired end to end.
  - In `lib/core/errors/localize_problem.dart`:
    - add `inventory_transfer.same_warehouse`, `inventory_transfer.not_in_transit`, `inventory_transfer.over_received` (params `product_code`, `received`, `outstanding`; the two quantities go through the shared formatter), `inventory_transfer.line_repeated` and `sales_order.not_confirmed` to `localizedErrorCodes` and the `switch`;
    - add the validation type `inventory_transfer_duplicate_line` to `localizedValidationTypes` and its switch.
  - Add the es and en text for each (the Spanish is in contracts/error-messages.md) to `lib/l10n/app_es.arb` and `app_en.arb`, then `flutter gen-l10n`.
  - In `test/unit/core/errors/problem_fixtures.dart`, add a fixture for each. In `test/unit/core/errors/catalog_coverage_test.dart`, add `inventory_transfer.over_received` to the `needParams` set and change `expect(checked, 152)` to `157`. The test counts only `code` rows marked `IN`, so the 4 `inventory_transfer.*` codes and `sales_order.not_confirmed` add 5. The validation-type row is not counted there.
  - In `test/unit/core/errors/localize_validation_type_test.dart`, change `expect(localizedValidationTypes, hasLength(11))` to `12`. That test also requires the new type's es and en text to differ and to contain no `{}` placeholders.
  - In `specs/058-localized-api-errors/contracts/code-scope.tsv`, switch the six rows to `IN` (L140–143, L225 and L260 in the current file) and fill their route and note columns, as the neighbouring `IN` rows do: `POST /inventory-transfers/{}/receive` for the receive codes, `POST /inventory-transfers/{}/sales-order-items` for `sales_order.not_confirmed`, create and update for `same_warehouse`, and "reachable from the Traspasos screens (spec 069)".
  - **Check:** `flutter test test/unit/core/errors/` passes, including `catalog_coverage_test.dart` and `localize_validation_type_test.dart`.

- [X] T003 Add every transfer string to `lib/l10n/app_es.arb` and `lib/l10n/app_en.arb`, then run `flutter gen-l10n`. Each key gets an `@key` description starting "spec 069".

**Key rule (one rule, no exceptions):**
- Transfer code never uses an `inventoryIssue…` or `inventoryReceipt…` key.
- It uses the shared `inventoryDocument…` keys that already exist (`inventoryDocumentDraftFolio`, `inventoryDocumentNoFacility`), app-wide generic keys already in the file (filters, clear filters, apply, cancel, save, back), and its own `inventoryTransfer…` keys for everything else. Mirror the `inventoryIssue…` key names.
- A transfer key whose text happens to match an issue key (for example "Folio") is still its own key.

The text is in contracts/ui-contract.md and wireframes.md:
  - **Navigation and titles:** `navInventoryTransfers` ("Traspasos"), `inventoryTransferTitle` (placeholder `folio`: "Traspaso {folio}"), `inventoryTransferTitleDraft` (placeholder `id`: "Traspaso · Borrador #{id}").
  - **Status:** `inventoryTransferStatusDraft/InTransit/Received/Cancelled` (Borrador, En tránsito, Recibido, Cancelado).
  - **List:** the columns `inventoryTransferCol…` (Folio, Origen, Destino, Sucursal, Estado, Creado por, Fecha); the facets (Estado, "Almacén (origen o destino)", Todos); the empty text ("No hay traspasos"); and the filtered-empty text ("Ningún traspaso coincide con los filtros.").
  - **Detail:** the fact labels (Origen, Destino, Notas, and so on), the lines tables (Código, Producto, Cantidad; Enviado, Recibido, Pendiente), the empty-draft text ("Agrega los productos que se van a traspasar."), and `inventoryTransferRefusalProductWarehouse` (placeholders `code`, `warehouse`: "Producto: {code} · Almacén: {warehouse}").
  - **Actions and dialogs:** `inventoryTransferNewAction` ("Nuevo traspaso"), "En tránsito", Editar encabezado, Agregar producto, "Agregar desde pedido", Despachar, Recibir, "Cerrar pendiente", Cancelar; the dialog titles and field labels (Origen, Destino, Notas, Producto, Cantidad, Pedido, Recibir); the receive hint ("Deja en 0 lo que no llegó. Lo pendiente se puede recibir después."), the field error "Máximo {outstanding}"; the sales-order snackbars (research R8: "Se agregaron {n} productos al traspaso. Los que ya estaban no se modificaron." and "Los productos del pedido ya estaban en el traspaso."); and the prompts in ui-contract.md "Dialogs" (dispatch, close with its `{n}` partidas, cancel-draft, cancel-dispatched with and without the "y lo que {destino} ya recibió" part, remove-line).
  - **In transit:** the title with and without the facility, "Por producto", "Por traspaso", "Selecciona una sucursal.", "Mi sucursal" if no shared key exists, and "No hay mercancía en tránsito.".

- [X] T004 [P] Create the entities (data-model.md, depends on T003): `lib/features/inventory/domain/entities/inventory_transfer.dart` (freezed) with `InventoryTransferStatus`, `InventoryTransferSummary`, `InventoryTransfer` (adding `comment`, `updaterId`, `modifiedAt`, `lines`, and `isDraft`, `isInTransit`, `isDispatched`, `outstandingLines`), `InventoryTransferLine`, `InventoryTransferPage`, `InTransitView`, `InTransitProductTotal` and `InTransitLineItem`. Run build_runner.

- [X] T005 Create the repository (contracts/repository.md, depends on T004).
  - In `lib/features/inventory/domain/repositories/inventory_transfer_repository.dart` declare `list`, `get`, `create`, `updateHeader`, `addLine`, `updateLine`, `removeLine`, `addSalesOrderItems`, `dispatch`, `receive`, `close`, `cancel` and `inTransit`.
  - In `lib/features/inventory/data/inventory_transfer_repository_impl.dart`, implement them over the generated `InventoryTransfersApi(dio, appSerializers)` (methods named like `inventoryTransfersGet`, `inventoryTransfersInventoryTransferIdDispatchPost`; read the generated file for the exact names and the wire types `TransferCreate`, `TransferUpdate`, `TransferReceive`, `TransferReceiveLine`, `SalesOrderItemsAdd`), with `inventoryTransferRepositoryProvider`.
  - Map the generated `TransferStatus` to `InventoryTransferStatus` (`in_transit` → `inTransit`), parse wire quantity strings into `Decimal`, treat a null `lines` as empty and an empty `comment` as null, and map `DioException` to `AppError` as `inventory_issue_repository_impl.dart` does.
  - `receive` with `lines == null` sends no body. Otherwise it sends `TransferReceive` with each line's quantity as the string arm of `Quantity5`, as 068 does for line quantities.
  - `updateHeader` sends `warehouse` and `warehouseTo` only when given, and `clearComment` sends `comment: ""`.
  - Create `test/unit/features/inventory/inventory_transfer_fixtures.dart` (builders for summaries, transfers, lines and the in-transit view) and `test/unit/features/inventory/inventory_transfer_repository_impl_test.dart`: the list params (status on the wire as `in_transit`), each mapping case (draft with no serial, in transit with partial receipt, legacy-style received, null lines, empty comment), `updateHeader` sending only changed fields, `receive` with and without a body, the in-transit mapping, and a `DioException` becoming a coded `AppError`.

- [X] T006 [P] Create the status chip and the filter (research R3, R4, depends on T003, T004).
  - `lib/features/inventory/presentation/transfers/inventory_transfer_status_chip.dart`: `inventoryTransferStatusLabel`, `inventoryTransferStatusColors` (draft `surfaceContainerHighest`, in transit `tertiaryContainer`, received `secondaryContainer`, cancelled `errorContainer`) and `InventoryTransferStatusChip` (key `inventory_transfer_status_chip`), mirroring `inventory_document_status_chip.dart`.
  - `lib/features/inventory/presentation/transfers/inventory_transfers_filter.dart`: freezed `InventoryTransfersFilter` (`status`, `warehouseId`) with `activeCount` and the URL query round trip (`status=in_transit`, `warehouse=12`), mirroring `inventory_documents_filter.dart`.
  - Tests: `test/widget/features/inventory/inventory_transfer_status_chip_test.dart` (the four labels and tones) and `test/unit/features/inventory/inventory_transfers_filter_test.dart` (the round trip, `activeCount`, an unknown status ignored). Run build_runner.

- [X] T007 Create the list controller (depends on T005, T006): `lib/features/inventory/presentation/transfers/inventory_transfers_list_controller.dart`, an `AsyncNotifier` family keyed by `InventoryTransfersFilter`, 20 per page, page clamped with `fetchClampedPage`. The server orders newest first, and the client sends no sort and no scope parameter (spec FR-002). Add `test/unit/features/inventory/inventory_transfers_list_controller_test.dart`: the params sent, page clamping, and an error becoming `AsyncError`. Run build_runner.

- [X] T008 Create the detail and in-transit controllers (depends on T005).
  - `lib/features/inventory/presentation/transfers/inventory_transfer_detail_controller.dart`: a `@riverpod` family keyed by the transfer id that loads the transfer and exposes `refresh()` and `put(InventoryTransfer)`.
  - `lib/features/inventory/presentation/transfers/in_transit_controller.dart`: `inTransitControllerProvider`, an `@riverpod` family keyed by the facility id that calls `inTransit(facilityId:)`, with `refresh()` (research R9). It is created here, not in US7, so T009 can invalidate it directly.
  - Add `test/unit/features/inventory/inventory_transfer_detail_controller_test.dart` (a load, a not-found error kept as an `AppError`, `refresh()` and `put`) and `test/unit/features/inventory/in_transit_controller_test.dart` (a load for a facility, an error, `refresh()`). Run build_runner.

- [X] T009 Create the write controller (contracts/repository.md "Actions notifier", depends on T005, T008): `lib/features/inventory/presentation/transfers/inventory_transfer_actions.dart`, a keep-alive notifier with `create`, `updateHeader`, `addLine`, `updateLine`, `removeLine`, `addSalesOrderItems`, `dispatch`, `receive`, `close` and `cancel`.
  - Each returns `AppError?` (null on success). On success it writes the returned transfer into `inventoryTransferDetailControllerProvider(id)` and invalidates the list family. `create` also returns the new id so the caller can navigate. `addSalesOrderItems` also returns the added count: the new line count minus the old (research R8).
  - After `dispatch`, `receive`, `close` and `cancel` succeed it also invalidates the `inTransitControllerProvider` family (T008).
  - After a refusal with `document.not_editable`, `inventory_document.already_cancelled`, `lock.busy`, `inventory_transfer.not_in_transit` or `inventory_transfer.over_received`, it calls `refresh()` on the detail controller (spec edge cases: concurrent edits).
  - Add `test/unit/features/inventory/inventory_transfer_actions_test.dart`: each action's success and refusal, the invalidations, the new id from `create`, the added count, the in-transit invalidation after dispatch, receive, close and cancel, and the refresh after each of the five codes. Run build_runner.

---

## Phase 3: User Story 1 — Find a transfer (Priority: P1) 🎯 MVP

**Goal**: a clerk opens Traspasos and sees the transfers the server grants them, newest first, filtered by state and warehouse, with each transfer's folio, origin, destination, facility, state, creator and date.

**Independent Test**: as a non-administrator with read on 17, open the list and check that only transfers to or from their warehouse, or created by them, appear. Filter by En tránsito, then by warehouse (it matches the origin or the destination). As an administrator every transfer appears. As `qanoaccess`, the entry is missing and the URL is redirected to the home page (the app's route gate).

- [X] T010 [US1] Create the list screen (ui-contract "List screen", wireframes "Screen: Traspasos list", depends on T003, T006, T007): `lib/features/inventory/presentation/transfers/inventory_transfers_list_screen.dart`. Declare `const inventoryTransfersPath = '/inventory/transfers';` at the top of this file; later tasks import it.
  - Filter row: `CatalogFilterBar` with **no search control**, and the badged filters `IconButton.outlined(Icons.tune)` that opens `showCatalogFilterSheet`. The drawer holds Estado (four choice chips, single select or none) and, with read on Warehouses (4), "Almacén (origen o destino)" (a `CatalogEntityPicker<Warehouse>` using `inventoryFilterWarehouseOptions`).
  - Table: `DataTableView<InventoryTransferSummary>` with the columns in order: Folio (right-aligned; the serial, or "Borrador #{id}" for a draft via `inventoryDocumentDraftFolio`), Origen, Destino, Sucursal, Estado (`InventoryTransferStatusChip`), Creado por, Fecha. Names come from the shared `InventoryWarehouseName`, `InventoryFacilityName` and `InventoryEmployeeName`. The row tap pushes `'$inventoryTransfersPath/${id}'`. No row icons.
  - `CatalogListStateView` for loading, empty, filtered-empty (with "Limpiar filtros") and error; `CatalogPagination`; the page lives in the URL. Dates through `formattersProvider`.
  - No Nuevo traspaso (T017) and no En tránsito button (T033) yet.

- [X] T011 [US1] Add the navigation and the list route (ui-contract "Routes and navigation", depends on T010).
  - In `lib/core/navigation/nav_destinations.dart`, add `NavBranch.inventoryTransfers = 32` (confirm the next free index first; `inventoryIssues` is 31) and a third destination in the existing `inventory` group, after Salidas de almacén: "Traspasos" (`id: 'inventory-transfers'`, `Icons.swap_horiz`, `PrivilegeGate(SystemObject.inventoryTransfers, AccessRight.read)`). `SystemObject.inventoryTransfers` (17) already exists. Update the comment above the group, which says transfers will join it.
  - In `lib/app/router/app_router.dart`, add the `StatefulShellBranch` at the end, in `NavBranch` order, with `GoRoute(path: inventoryTransfersPath, builder: InventoryTransfersListScreen(query: ListQuery.fromUri(state.uri)))`, and the `_routeGate` clause for the `/inventory/transfers` prefix returning `PrivilegeGate(SystemObject.inventoryTransfers, AccessRight.read)`. That prefix also covers the detail and in-transit routes added later.
  - Update `test/unit/core/navigation/nav_destinations_test.dart` (the inventory group's ordered child ids become `['inventory-receipts','inventory-issues','inventory-transfers']`, plus the gating cases) and `test/unit/app/router/app_router_test.dart` (a gate case with `currentIndex == NavBranch.inventoryTransfers`, and the reader constant if it lists objects): the entry appears after Salidas de almacén with read on 17, is absent without it, the group stays when the user can read any one of the three, and the URL is redirected to the home page.

- [X] T012 [US1] Test the list: extend `test/widget/features/inventory/inventory_harness.dart` with a mocktail `MockInventoryTransferRepository` and its provider override, then create `test/widget/features/inventory/inventory_transfers_list_screen_test.dart`: rows render with a draft showing "Borrador #{id}" and no folio, a dispatched transfer showing its folio, both Origen and Destino shown, all four state chips, no row icons, the filter badge shows the active count, the status and warehouse facets are sent to the repository, the drawer label reads "Almacén (origen o destino)", no search control is present, the empty and filtered-empty states render with the "Limpiar filtros" action, a failed name lookup shows "#{id}", and a read error shows the banner.

**Checkpoint**: US1 is demonstrable on its own: open the list, filter it, and open a (still empty) detail URL.

---

## Phase 4: User Story 2 — Prepare and dispatch a transfer (Priority: P1) 🎯 MVP

**Goal**: a clerk creates a transfer between two warehouses, adds the products, edits quantities, removes lines, and dispatches it. The transfer then shows its folio and En tránsito and is no longer editable. A short-stock dispatch is refused with the product and warehouse named, and the transfer stays a draft.

**Independent Test**: create a transfer W1 → W2 (the origin starting on the point-of-sale warehouse), add two stockable products, add one again and check that its quantity grows, edit and remove a line, then dispatch. The transfer shows its folio and En tránsito, W1's stock has dropped and W2's has not. Ask for more than W1 has and check the Spanish refusal with the product code and warehouse. Choose W1 → W1 and check the same-warehouse refusal.

- [X] T013 [US2] Create the dialogs file (ui-contract "Dialogs", wireframes "Dialogs", depends on T003, T009): `lib/features/inventory/presentation/transfers/transfer_dialogs.dart`, built on `showResponsiveDialog`, mirroring `issue_dialogs.dart`.
  - `showTransferLineQuantityDialog` (quantity > 0, prefilled, `hasUnsavedChanges`, busy flag, refusal in `FormErrorBanner`, stays open on refusal).
  - `showRemoveTransferLineDialog` (the remove-line prompt).
  - `showDispatchTransferDialog`: it names the origin and the destination, and says the stock leaves the origin and stays in transit until the destination receives it (FR-013).
  - The close prompt comes in T022 and the cancel prompt in T028.

- [X] T014 [P] [US2] Create the add-line dialog (spec FR-008 to FR-011, depends on T003, T009): `lib/features/inventory/presentation/transfers/add_transfer_line_dialog.dart`, mirroring `add_issue_line_dialog.dart`. A `CatalogEntityPicker<Product>` fed by `productRepositoryProvider.list(search:, status: active, stockable: true, limit: 10)`, shown only with read on Products. A Cantidad field (> 0, through `fmt.field.quantity` / `parseQuantity`). The dialog stays open on refusal, and adding an existing product merges server-side.

- [X] T015 [P] [US2] Create the new-transfer dialog (spec FR-005, FR-021, research R5, depends on T003, T009): `lib/features/inventory/presentation/transfers/new_transfer_dialog.dart`, mirroring `new_issue_dialog.dart`.
  - Origen: a picker from `inventoryWarehouseOptions` (a non-administrator is offered only their own facility, and a user without a facility sees the no-sucursal text), starting on `inventoryStartingWarehouse`.
  - Destino: a `CatalogEntityPicker<Warehouse>` from `inventoryFilterWarehouseOptions` (every warehouse), starting empty.
  - Notas (optional, `maxLength` 500, counter).
  - "Crear" calls `create` and pushes the new detail. Both warehouses are required. Origin = destination is **not** pre-checked: `inventory_transfer.same_warehouse` and the in-transit warehouse refusal show in the dialog's `FormErrorBanner` (research R5). The starting warehouse alone doesn't count as an unsaved change.

- [X] T016 [US2] Create the detail screen (ui-contract "Detail screen", wireframes "Screen: Transfer detail", data-model "Action availability", research R6 and R10, depends on T008, T009, T013, T014): `lib/features/inventory/presentation/transfers/inventory_transfer_detail_screen.dart`, mirroring `inventory_issue_detail_screen.dart`.
  - Title: "Traspaso {serial}", or "Traspaso · Borrador #{id}" when there is no serial. No AppBar actions.
  - Facts (`FactStripRow` in a `ResponsiveFormGrid`): Estado (`InventoryTransferStatusChip`), Folio, Origen, Destino, Sucursal, Notas, Creado por and Modificado por with dates.
  - Lines table (`DataTableView`), chosen by `isDispatched` (research R10):
    - not dispatched: Código, Producto, Cantidad. On a draft with update on 17, ✎ and 🗑 via `buildCatalogRowActions` (✎ opens `showTransferLineQuantityDialog`, 🗑 the remove prompt). The empty-draft text is "Agrega los productos que se van a traspasar."
    - dispatched: Código, Producto, Enviado, Recibido, Pendiente, all right-aligned, no row actions.
  - Action area, left to right: Agregar producto (update on 17, read on Products, draft only) and Despachar (update on 17, draft only, a `FilledButton`, through `showDispatchTransferDialog` then `dispatch`). The other buttons come in T020, T023, T026, T029 and T036.
  - Refusals show in an `ErrorBanner` above the action area. For `inventory_document.insufficient_stock`, add the line `inventoryTransferRefusalProductWarehouse` (research R6): the product code is looked up from the error's `product_id` among the transfer's lines (falling back to `#{id}`), and the warehouse name is looked up from the error's `warehouse_id` through `warehouseDisplayNameProvider` (falling back to `#{id}`). **Do not use the transfer's own warehouse**: on cancel it can be the destination. Mirror the issue screen's product lookup. Show the banner and the extra line only while the refusal is current, and clear them on the next action.
  - Loading, not-found and forbidden states use the shared error view, as the issue detail does.
  - Names, quantities and dates go through the shared name cells and `formattersProvider`.

- [X] T017 [US2] Wire creation and the detail route (depends on T011, T015, T016).
  - In `lib/app/router/app_router.dart`, add the top-level `GoRoute(path: '$inventoryTransfersPath/:id', builder: InventoryTransferDetailScreen(id))`, gated by the same `_routeGate` clause as the list. Reject a non-numeric id as the issue route does. (T033 adds `/in-transit` before it.)
  - In `inventory_transfers_list_screen.dart`, add the "Nuevo traspaso" `FilledButton.icon(Icons.add)` to the filter bar's actions, shown when `can(17, create)` and `can(4, read)`, opening `new_transfer_dialog` (T015).
  - Extend `test/unit/app/router/app_router_test.dart` with the detail route's gate.

- [X] T018 [US2] Test the dialogs and the detail screen (depends on T012, T016, T017): create `test/widget/features/inventory/new_transfer_dialog_test.dart`, `add_transfer_line_dialog_test.dart`, `transfer_dialogs_test.dart` and `inventory_transfer_detail_screen_test.dart`.
  - New dialog: the starting origin, a non-administrator's own-facility origin options, every warehouse offered as destination, the no-facility text, the 500-character limit, and `same_warehouse` and `warehouse.in_transit_location` refusals staying in the dialog in Spanish.
  - Add-line dialog: quantity ≤ 0 refused, stockable-only picker, and a `product.not_stockable` refusal shown in Spanish with the dialog staying open (FR-022).
  - Prompts: the dispatch prompt names both warehouses and says the stock stays in transit until received.
  - Detail: a draft shows "Traspaso · Borrador #{id}" and no folio, Despachar and the line icons appear with update on 17 and are absent for a read-only user and on a dispatched transfer, a dispatched transfer shows its folio and the three-quantity table with no row icons, the empty draft text, an `insufficient_stock` refusal on dispatch shows the Spanish message plus "Producto: {code} · Almacén: {name}" with the name taken from the error's `warehouse_id` (use a warehouse that is not the transfer's origin, to prove it isn't assumed), the transfer stays a draft, `no_lines` shows "El traspaso no tiene partidas.", `facility.no_in_transit_location` and `facility.other_facility` show in Spanish, and `lock.busy` re-fetches.

**Checkpoint**: US1 and US2 together: find, prepare, dispatch, and be refused on short stock.

---

## Phase 5: User Story 3 — Receive a transfer (Priority: P1) 🎯 MVP

**Goal**: at the destination, a clerk receives what arrived, in full or in part. The transfer stays En tránsito while anything is outstanding and becomes Recibido when nothing is.

**Independent Test**: dispatch 10 of P1 and 5 of P2. Receive 8 and 5: the transfer stays En tránsito with 2 outstanding on P1, and the destination's stock has grown by 8 and 5. Receive the 2: the transfer becomes Recibido. In the dialog, a quantity above Pendiente disables Recibir.

- [X] T019 [US3] Create the receive dialog (research R7, ui-contract "Dialogs", wireframes "Dialogs", depends on T003, T009): `lib/features/inventory/presentation/transfers/receive_transfer_dialog.dart`, a `ResponsiveDialog` built from `DataTableView` rows and `CompactField`s.
  - One row per line with `quantityOutstanding > 0`: Código, Producto, Pendiente and an editable Recibir quantity. Each controller starts with the outstanding quantity, formatted through `fmt.field.quantity`. Input is parsed with `fmt.field.parseQuantity`.
  - Per-row validation: empty or unparseable → field error; below 0 → field error; above outstanding → "Máximo {outstanding}". Recibir is disabled while any row has an error, and when every row is 0. Show the hint "Deja en 0 lo que no llegó. Lo pendiente se puede recibir después."
  - Submit: if every row still equals its outstanding quantity, call `receive(id)` with no lines. Otherwise send only the rows above 0. One request either way.
  - Refusal: `inventory_transfer.over_received` and `inventory_transfer.not_in_transit` refresh the detail (the actions notifier does it) and close the dialog, with the message left in the detail's banner. Any other refusal (`facility.other_facility`, `lock.busy`, `inventory_transfer.line_repeated`) stays in the dialog's `FormErrorBanner`.
  - `hasUnsavedChanges` is true once any quantity differs from its starting value.
  - It returns the refusal to the caller, or null on success, as the other dialogs do. Read `issue_dialogs.dart` for how a dialog hands a refusal to the detail screen's banner.

- [X] T020 [US3] Add Recibir to the detail screen (data-model "Action availability", depends on T016, T019): a `FilledButton` shown when `can(17, update)` and the transfer is in transit, last in the action area, opening `showReceiveTransferDialog`. Do not check the user's facility (research R5). Recibir is absent on drafts, received and cancelled transfers.

- [X] T021 [US3] Test receive (depends on T018, T020): create `test/widget/features/inventory/receive_transfer_dialog_test.dart` and add cases to `inventory_transfer_detail_screen_test.dart`.
  - Dialog: only outstanding lines are listed and each is prefilled; an unchanged submit calls `receive` with no lines; lowering one row sends **every** row above 0, the untouched rows included at their prefilled quantity (for example P1 lowered to 4 and P2 left at 3 sends both); a line at 0 is left out; all rows at 0 disables Recibir; a quantity above Pendiente shows "Máximo {n}" and disables Recibir; a fractional quantity parses; `over_received` closes the dialog and leaves the Spanish message in the detail's banner with the transfer reloaded; `lock.busy` stays in the dialog.
  - Detail: Recibir shows only in transit with update on 17, is absent without the right and in every other state, and an in-transit transfer shows Enviado / Recibido / Pendiente per line. A received transfer shows Pendiente 0. A transfer with partial receipt shows the outstanding figure.

**Checkpoint**: P1 complete. A transfer can be found, prepared, dispatched and received, in whole or in parts.

---

## Phase 6: User Story 4 — Close the remainder (Priority: P2)

**Goal**: someone with the delete right closes what never arrived. The outstanding quantities go back to the origin and the transfer becomes Recibido, each line keeping what it received.

**Independent Test**: dispatch 10, receive 8, close the remainder. The transfer shows Recibido with 10 / 8 / 0 on the line, and the origin's stock has grown back by 2.

- [X] T022 [US4] Add the close prompt (ui-contract "Dialogs", depends on T013): in `transfer_dialogs.dart`, `showCloseTransferDialog`. It says the outstanding quantities (with the number of lines still outstanding) go back to the origin, the transfer becomes Recibido, and a loss is registered afterwards with a Salida de almacén. It names the origin.

- [X] T023 [US4] Add Cerrar pendiente to the detail screen (depends on T016, T022): an `OutlinedButton` shown when `can(17, delete)` and the transfer is in transit, after Cancelar in the action area, opening `showCloseTransferDialog`, then calling `close`. A refusal shows in the banner.

- [X] T024 [US4] Test close (depends on T018, T023): add to `inventory_transfer_detail_screen_test.dart` and `transfer_dialogs_test.dart`: the prompt wording with the outstanding line count and the origin's name, Cerrar pendiente present with delete on 17 and absent without it and in every state but in transit, a successful close showing Recibido with the line's received figure unchanged and Pendiente 0, and `inventory_transfer.not_in_transit` and `facility.other_facility` showing in Spanish and re-fetching.

---

## Phase 7: User Story 5 — Correct a draft's header (Priority: P2)

**Goal**: on a draft, change the origin, the destination or the notes. Changing the origin moves the draft to that warehouse's facility.

**Independent Test**: as an administrator, change a draft's origin to a warehouse in another facility and change its destination. After reopening the draft, both are kept and Sucursal shows the new facility. As a non-administrator, the origin picker offers only their own facility's warehouses. A dispatched, received or cancelled transfer has no header edit.

- [X] T025 [US5] Create the header dialog (spec FR-006, ui-contract "Dialogs", depends on T003, T009): `lib/features/inventory/presentation/transfers/transfer_header_dialog.dart`, mirroring `issue_header_dialog.dart`.
  - Origen is a picker with read on Warehouses (4), otherwise read-only text, using `inventoryWarehouseOptions` (own facility only for a non-administrator). Destino is a picker over every warehouse with read on Warehouses, otherwise read-only text.
  - Notas (≤ 500, counter). Send only changed fields. Cleared notes send `""`.
  - `hasUnsavedChanges`, a busy flag, and refusals in `FormErrorBanner` with the dialog staying open (the same-warehouse and in-transit warehouse refusals show here).

- [X] T026 [US5] Add Editar encabezado to the detail screen (depends on T016, T025): an `OutlinedButton` shown when `can(17, update)` and the transfer is a draft, opening `showTransferHeaderDialog`, placed before Agregar producto in the action area.

- [X] T027 [US5] Test the header (depends on T018, T026): create `test/widget/features/inventory/transfer_header_dialog_test.dart` and add cases to the detail test: only changed fields are sent, cleared notes send `""`, the 500-character limit, a non-administrator's own-facility origin options with every warehouse offered as destination, read-only text without read on Warehouses, the same-warehouse and in-transit refusals staying in the dialog, and Editar encabezado absent on a dispatched transfer and for a read-only user.

---

## Phase 8: User Story 6 — Cancel a transfer (Priority: P2)

**Goal**: cancel a draft (nothing posted) or a dispatched or received transfer (everything goes back to the origin).

**Independent Test**: cancel a draft and check it shows Cancelado. Dispatch another transfer, receive part of it, cancel it, and check the origin and destination stocks are back to what they were before the dispatch. A cancelled transfer offers no actions, and a user without the delete right never sees Cancelar.

- [X] T028 [US6] Add the cancel prompt (ui-contract "Dialogs", depends on T013): in `transfer_dialogs.dart`, `showCancelTransferDialog`. For a draft it reads "Cancelar el borrador". For a dispatched transfer it names the folio and the origin and says what is in transit goes back to it, adding "y lo que {destino} ya recibió" only when any line has `quantityReceived > 0`. There is no reason field, because the endpoint takes none.

- [X] T029 [US6] Add Cancelar to the detail screen (depends on T016, T028): an `OutlinedButton` in the error tone, first in the action area, shown when `can(17, delete)` and the status is not cancelled (a draft, in transit or received transfer). It opens `showCancelTransferDialog`, then calls `cancel`. A refusal shows in the banner, with the product and warehouse line for `insufficient_stock`.

- [X] T030 [US6] Test cancel (depends on T018, T029): add to `inventory_transfer_detail_screen_test.dart` and `transfer_dialogs_test.dart`: the draft, in-transit and received wordings including the conditional "ya recibió" part, Cancelar present with delete on 17 and absent without it, absent on a cancelled transfer, a cancelled transfer showing Cancelado and no actions at all (and keeping its received figures), a cancelled draft keeping "Traspaso · Borrador #{id}" and the simple table, `insufficient_stock` on a received transfer showing the Spanish message with the destination's name from the error's `warehouse_id` (US6 #3), `inventory_document.already_cancelled` showing "El traspaso ya está cancelado." and re-fetching, and `facility.other_facility` showing in Spanish.

---

## Phase 9: User Story 7 — See what is in transit (Priority: P3)

**Goal**: a manager opens the in-transit view and sees a facility's outstanding lines, in both directions, with the total outstanding per product.

**Independent Test**: with two transfers in transit for a facility, one sending and one receiving, open the view and check both appear with the right outstanding quantities and per-product totals. As an administrator, switch to another facility. As a non-administrator, there is no facility switch.

- [X] T031 [US7] Create the facility selection (research R9, plan Constitution I, depends on T008): in `in_transit_controller.dart`, add `inTransitFacilityProvider`, a `@riverpod` notifier holding the facility the view shows.
  - It starts on the user's facility, read from the auth session settings (`authProvider` → `AuthAuthenticated.user.settings?.facilityId`) through a private helper that mirrors `_settings` in `presentation/shared/inventory_warehouse_options.dart`. Do not edit that shared file, and do not import the sales `userFacilityIdProvider`.
  - `select(int facilityId)` changes it (administrators only; the screen hides the picker otherwise) and `reset()` returns to the user's own ("Mi sucursal"). A null state means no facility.
  - Extend `test/unit/features/inventory/in_transit_controller_test.dart`: the starting facility from settings, null without one, `select` and `reset`. Run build_runner.

- [X] T032 [US7] Create the in-transit screen (ui-contract "In-transit screen", wireframes "Screen: En tránsito", depends on T003, T031): `lib/features/inventory/presentation/transfers/in_transit_screen.dart`. Declare `const inTransitPath = '/inventory/transfers/in-transit';` at its top.
  - Facility: starts on `inTransitFacilityProvider` (T031), the user's facility from the auth session settings. Do not import `userFacilityIdProvider` from `sales/presentation/register_controller.dart`: inventory must not depend on a sales screen controller (plan, Constitution I). An administrator with read on facilities gets an inline `CatalogEntityPicker<FacilityListItem>` over `facilityRepositoryProvider.list(search:)` with a "Mi sucursal" reset, as the delivery-orders list does. A non-administrator gets no picker, and the title reads "En tránsito · {facility name}".
  - No facility: an administrator sees "Selecciona una sucursal." and no request is sent. A non-administrator sees `inventoryDocumentNoFacility`, and no request is sent.
  - Two unpaginated `DataTableView`s: "Por producto" (Código, Producto, Pendiente) then "Por traspaso" (Folio, Origen, Destino, Código, Producto, Pendiente). A line row pushes `'$inventoryTransfersPath/${transferId}'`. Add `// simplified: unpaginated, the endpoint takes no paging and returns only transfers in flight; paginate client-side if a facility ever has hundreds of lines.`
  - Loading, error with retry, and empty ("No hay mercancía en tránsito.") through `CatalogListStateView`. Only dispatched transfers are listed, so a serial should always be present. If one is null anyway, show `#{id}` in the Folio column.

- [X] T033 [US7] Add the route and the list button (depends on T017, T032).
  - In `lib/app/router/app_router.dart`, add `GoRoute(path: inTransitPath, builder: InTransitScreen())` **before** the `'$inventoryTransfersPath/:id'` route, under the same gate.
  - In `inventory_transfers_list_screen.dart`, add the "En tránsito" `OutlinedButton.icon(Icons.local_shipping_outlined)` to the filter bar's actions, before the filters button, shown to every user who can see the screen (the route already needs read on 17).
  - Extend `test/unit/app/router/app_router_test.dart`: `/inventory/transfers/in-transit` is gated by read on 17 and is not read as an id.

- [X] T034 [US7] Test the in-transit view (depends on T012, T033): create `test/widget/features/inventory/in_transit_screen_test.dart`: both tables render with the right quantities and totals, a row opens its transfer, an administrator sees the facility picker and switching reloads, a non-administrator sees no picker and a title naming their facility, the no-facility prompts and that no request is sent, the empty state, and a read error with retry. Add a case to the list test: the En tránsito button is present and opens the route.

---

## Phase 10: User Story 8 — Fill a draft from a sales order (Priority: P3)

**Goal**: add a completed sales order's stockable items to a draft in one step. Products already on the transfer are left as they are, so repeating it changes nothing.

**Independent Test**: on a draft holding one of an order's products, add a completed order with three stockable products. The two missing products are added at the ordered quantities and the existing line is unchanged. Repeat: nothing changes and the snackbar says the products were already there.

- [X] T035 [US8] Create the dialog (research R8, ui-contract "Dialogs", depends on T003, T009): `lib/features/inventory/presentation/transfers/add_from_sales_order_dialog.dart`, a one-step `ResponsiveDialog` with a `CatalogEntityPicker` over sales orders, mirroring `lib/features/invoicing/presentation/add_sales_order_dialog.dart` without its customer binding.
  - The search calls `salesOrderRepositoryProvider.listOrders(status: SaleStatus.completed, search: <digits>, limit: 10)` with no customer and no facility. Read the delivery-orders `add_line_dialog.dart` for the debounce. Each option shows "{folio} · {customer} · {date}".
  - "Agregar" calls `addSalesOrderItems`. On success it closes and the caller shows the snackbar: "Se agregaron {n} productos al traspaso. Los que ya estaban no se modificaron." with `n` from the actions notifier, or "Los productos del pedido ya estaban en el traspaso." when `n` is 0.
  - `sales_order.not_confirmed` and `resource.not_found` show in the dialog's `FormErrorBanner`, and the dialog stays open.

- [X] T036 [US8] Add Agregar desde pedido to the detail screen (depends on T016, T035): an `OutlinedButton` shown when `can(17, update)`, `can(SystemObject.salesOrders, read)` (7, the right the Pedidos screen and nav entry gate on) and the transfer is a draft, placed before Agregar producto, opening the dialog and showing the snackbar.

- [X] T037 [US8] Test the dialog (depends on T018, T036): create `test/widget/features/inventory/add_from_sales_order_dialog_test.dart` and add cases to the detail test: the search sends `status: completed` and no customer, selecting an order and adding calls `addSalesOrderItems` with its id, both snackbar wordings, `sales_order.not_confirmed` shown in Spanish with the dialog open, and the button absent without read on sales orders, without update on 17 and on a non-draft.

---

## Phase 11: Polish & cross-cutting

- [X] T038 [P] Live API test (research R12, depends on T009): `test/integration/inventory_transfers_live_test.dart`, mirroring `inventory_issues_live_test.dart`, with fixtures discovered at runtime: two warehouses W1 and W2 that aren't in transit (preferably in one facility with an in-transit warehouse, plus a warehouse W3 in another facility if one exists), an active stockable product with available stock ≥ 5 at W1 (read with `StockApi`), and a completed sales order with stockable lines (skip that case when none). Writes run only with `MBE_WRITE=true`, tagged `QA069 <n>`. Cover:
  - list (including the `warehouse` filter matching the destination) and get;
  - create a draft, add and merge lines, edit a line, remove a line, update the header (including clearing the notes);
  - `same_warehouse` on create and on the header;
  - dispatch: W1's stock drops by the quantity and W2's is unchanged (SC-003);
  - a partial receive: W2's stock grows by the received quantity and the transfer stays in transit with the right outstanding; a receive above outstanding gives 409 `over_received`; then a full receive with no body gives `received`; and `not_in_transit` on a further receive;
  - close on a second transfer (cross-facility when W3 exists): W1 regains the remainder and each line keeps its received quantity;
  - cancel on a third after a partial receive: both ends return to their starting stock;
  - the insufficient-stock path: a line of available + 1, dispatch, expect the 409 `inventory_document.insufficient_stock` with the transfer still a draft;
  - an empty-draft dispatch (`no_lines`) and a draft cancel;
  - add from sales order, twice (the second changes nothing);
  - the in-transit view for the origin's facility lists the outstanding lines.

  Note in the file header which accounts it needs and that each facility used must have an in-transit warehouse. No seeded non-administrator has rights on 17, so the non-administrator cases stay manual (research R12).

- [X] T039 [P] Device test (quickstart.md, depends on T033, T029): `integration_test/inventory_transfers_quickstart_test.dart`, mirroring `inventory_issues_quickstart_test.dart` and the macOS traps in memory (frame-stall watchdog, picker and back-button finders). Walk quickstart steps 1 to 8, 10 and 11 as the administrator. Run with `caffeinate -dimsu flutter test integration_test/inventory_transfers_quickstart_test.dart -d macos --dart-define-from-file=.env`, since without `caffeinate` it stalls silently.

- [X] T040 [P] Largest text level (quickstart step 12, depends on T034, T021): `test/widget/features/inventory/inventory_transfers_large_text_test.dart`, mirroring `inventory_issues_large_text_test.dart`. At the largest text scale, the list, the detail's dispatched lines table, the receive dialog and the in-transit tables don't clip or scroll sideways at 1280 px.

- [X] T041 Final checks (depends on all previous tasks).
  - Run `flutter analyze` (no new warnings), `dart format` on the changed files only, and `flutter test test/unit/features/inventory test/widget/features/inventory test/unit/core/errors test/unit/core/navigation test/unit/core/formatting_guard_test.dart test/unit/app/router/app_router_test.dart`.
  - Run the transfers live test (read-only, then with `MBE_WRITE=true`), and the issues and receipts live tests once, to prove the shared areas are untouched.
  - Search `lib/features/inventory/` for literal colours, sizes and spacing (§V), for `NumberFormat` and `toStringAsFixed`, and for any display of `enum.name` or server message text (§III).
  - Check that no `core/widgets/` file was added, that nothing under `presentation/shared/`, `presentation/issues/` or `presentation/receipts/` changed (`git diff --stat main -- lib/features/inventory/presentation/{shared,issues,receipts}` is empty), and that no generated file was hand-edited.

- [ ] T042 Validate against the quickstart (depends on T041). Run the walkthrough in quickstart.md against the dev mbe-api. Then check FR-025 by opening Salidas de almacén and Traspasos side by side. These must match, apart from the documented differences (two warehouses, four states, the received and outstanding columns, and the extra actions):
  - the filter drawer;
  - the facts strip;
  - the button order in the action area;
  - the wording and shape of the prompts.

  Step 9's non-administrator parts need an account with rights on 17 that isn't seeded, so list them as manual checks to track in a GitHub issue after merge, as 067 and 068 did (ui#262, ui#263). Record the result and any deviation in the PR description, with `Closes mictlanix/mbe-roadmap#63` under "Roadmap".

  **Status 2026-11-16 (implement run):** the automated part is done. `integration_test/inventory_transfers_quickstart_test.dart` walked steps 1–8 and 10 as the administrator, plus the `qanoaccess` gate, all passing on macOS. `inventory_transfers_live_test.dart` covered the API side. Still manual, for the post-merge manual-checks issue:
  - **FR-025:** a side-by-side visual check of Salidas de almacén against Traspasos.
  - **Step 9 (non-administrator):** no seeded account has rights on 17.
  - **Step 11 (read-only user):** `qareadonly` has no read on 17, so the route redirects home.
  - **SC-001 timing:** only a 2-product draft was timed (about 48 s to dispatch), not the 10 products the criterion calls for.
  - **SC-002 timing:** receive times of 4–5 s (unchanged dialog) and 13–18 s (two lowered lines plus a follow-up receive) are within the limits.
  - **Layout difference:** the shared `CatalogFilterBar` puts actions before the filters button, so "En tránsito" sits before "Nuevo traspaso". That matches the other inventory lists; the wireframe drew it between them.

---

## Dependencies & execution order

- **Phase 1** (T001) first.
- **Phase 2**:
  - T002 (errors) and T003 (strings) can run in parallel. T004 needs T003. T005 needs T004. T006 needs T003 and T004, and can run in parallel with T005. T007 needs T005 and T006. T008 needs T005. T009 needs T005 and T008.
  - Nothing in a story phase starts until T009 is green.
- **US1** (T010–T012) needs Phase 2. **US2** (T013–T018) needs US1's list and route. **US3** (T019–T021) needs US2's detail screen.
- **US4** (T022–T024), **US5** (T025–T027), **US6** (T028–T030) and **US8** (T035–T037) each need only US2's detail screen, so they can run in parallel with each other if different people take them. All of them edit `inventory_transfer_detail_screen.dart`, and US4 and US6 also edit `transfer_dialogs.dart`, so do T020, T023, T026, T029 and T036 one after the other.
- **US7** (T031–T034) needs Phase 2 (its controller is created in T008) and US1's list. Its T033 also needs US2's T017 for the router.
- **Polish** (T038–T040) can start once the code it covers exists, and T041 and T042 come last.

### Parallel opportunities

- T002 ∥ T003 (error messages and strings).
- T004 then T005 ∥ T006 (repository and status chip + filter).
- T014 ∥ T015 (two new dialog files).
- US4, US5, US6, US7 and US8 after US2, with the shared-file caveat above.
- T038 ∥ T039 ∥ T040 (three independent test files).

## Implementation strategy

- **MVP**: Phase 1, Phase 2 and US1 + US2 + US3 (T001–T021). That delivers find, prepare, dispatch and receive with the short-stock refusal, which is the whole movement of stock. Without US3 a dispatched transfer can never complete, so US3 belongs in the MVP.
- **Increment 2**: US4 (close the remainder), US5 (header corrections) and US6 (cancel), in any order.
- **Increment 3**: US7 (in transit) and US8 (fill from a sales order). Both are P3 and can be dropped without affecting anything above.
- **Then**: Polish, the live and device checks, and the quickstart.
- **Risks to watch**:
  - The refusal's warehouse name must come from the error's `warehouse_id`, not from the transfer (T016, T018, T030).
  - The in-transit route must be declared before `/:id` (T033).
  - Receive with an unchanged dialog must send no body (T019, T021).
  - The generated method names for transfers are long and unusual (`inventoryTransfersInventoryTransferIdDispatchPost`); read the generated file before writing T005.
