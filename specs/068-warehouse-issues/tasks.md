---
description: "Task list for 068-warehouse-issues"
---

# Tasks: Warehouse Issues

**Input**: Design documents from `specs/068-warehouse-issues/`

**Prerequisites**: plan.md, spec.md (with its Clarifications), research.md (R1–R9), data-model.md, contracts/ui-contract.md, contracts/repository.md, contracts/error-messages.md, quickstart.md, wireframes.md

**Tests**: The spec doesn't ask for a test suite as such, but the constitution's quality gates require tests. Test tasks sit inside each story, after the code they cover.

**Organization**: Grouped by user story (US1–US4, spec.md). US1 and US2 are P1 and together are the MVP: find issues, then record and confirm one. US3 (correct a draft's header) and US4 (cancel) are P2. Phase 2 holds the shared-code move from receipts (research R1) and what two or more stories share.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: parallelizable (different files, no dependency on an incomplete task)
- **[Story]**: US1 find an issue · US2 record and confirm · US3 correct the header · US4 cancel

## Cross-story notes

- **This feature builds on spec 067.** `lib/features/inventory/` and its tests already exist. Open the receipts counterpart of every file below before writing the issue version, and mirror it with the differences research.md and ui-contract.md list: no purchase order, no complementary action, no warnings, no cost notice, and an always-editable warehouse on a draft's header.
- **Shared files.** Do these sequentially, not in parallel:
  - `lib/features/inventory/presentation/issues/inventory_issue_detail_screen.dart`: T019 (US2) creates it with the facts, the lines table, Confirmar, the line actions and the refusal enrichment. T023 (US3) adds Editar encabezado, and T026 (US4) adds Cancelar. Every control is a nullable callback or a collection-`if`, so an absent right means the control is not in the tree.
  - `lib/features/inventory/presentation/issues/issue_dialogs.dart`: T016 (US2) creates it with the quantity, remove-line and confirm prompts, and T025 (US4) adds the cancel prompt.
  - `lib/features/inventory/presentation/issues/inventory_issues_list_screen.dart`: T013 (US1) creates it, and T020 (US2) adds the Nueva salida button.
  - `lib/app/router/app_router.dart` and `lib/core/navigation/nav_destinations.dart`: T014 (US1) adds the list branch, the nav entry and the gate, and T020 (US2) adds the detail route.
  - `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb`: T002 renames the shared keys to `inventoryDocument…`, and T007 adds every issue key once. If a later task needs another, add it there and run `flutter gen-l10n`. Never hand-edit `lib/l10n/app_localizations*.dart`.
  - `test/widget/features/inventory/inventory_harness.dart`: T015 extends it, and later tests only use it.
- **Generated code.** After editing a freezed or `@riverpod` file, run `dart run build_runner build --delete-conflicting-outputs` at the repo root. Never run two build_runner processes at once: tasks that both need it are not marked [P] against each other. No client regeneration is needed: `InventoryIssuesApi` already has every operation this spec calls (list, get, create, update, add/update/delete line, confirm, cancel).
- **Formatting.** Format only the files you changed (`dart format <files>`). Never `dart format .`, and never format `lib/generated/`.
- **Quantities and dates** go through `formattersProvider` (constitution §V). No `NumberFormat`, no `toStringAsFixed`. Quantities are `Decimal`, never `double`; the wire carries them as strings.
- **Spacing tokens, not literals** (`Theme.of(context).spacing`). No automated guard catches a literal, so check it in review.
- **Never match or show server prose** (§III). Show refusals through `AppError.localizedMessage` / `ErrorBanner`, which build the text from the error's `code`. Recognition keys on the code.
- **Status names come from l10n**, never from `enum.name`.
- **Row icons (§VI document reading).** List rows have no icons, and only draft line rows get ✎ and 🗑. This is intentional; see the Complexity Tracking row in plan.md. Don't add a row Edit icon or a View toggle.
- **Rights.** Every control follows the availability table in data-model.md and the rights lines in contracts/ui-contract.md. A missing right means the control is absent, never disabled. Document the system-object code (InventoryIssues = 16; Warehouses = 4) in a comment where a route, nav entry or control is gated.
- **Simplifications.** Any shortcut carries a comment `// simplified: <ceiling>, <what to do when it binds>`.
- **Closest precedents** (all in `lib/features/inventory/` and `test/*/features/inventory/`): each issue file mirrors its receipt file.
  - `inventory_receipts_list_screen.dart`, `inventory_receipt_detail_screen.dart`, `inventory_receipt_actions.dart`, `new_receipt_dialog.dart`, `receipt_header_dialog.dart`, `add_receipt_line_dialog.dart`, `receipt_dialogs.dart`.
  - Repository: `data/inventory_receipt_repository_impl.dart`, with its test.
  - Test builders: `test/unit/features/inventory/inventory_receipt_fixtures.dart`. Widget harness: `test/widget/features/inventory/inventory_harness.dart`.
  - Live test: `test/integration/inventory_receipts_live_test.dart`. Device test: `integration_test/inventory_receipts_quickstart_test.dart`.

---

## Phase 1: Setup

**Purpose**: a known-good baseline, so later failures are attributable.

- [X] T001 Run `flutter analyze` and the tests this feature touches: all of `test/unit/features/inventory/` and `test/widget/features/inventory/`, plus `test/unit/core/errors/catalog_coverage_test.dart`, `test/unit/app/router/app_router_test.dart` and `test/unit/core/formatting_guard_test.dart`. Record any failure that predates this feature, so it isn't blamed on the move or the new code. (Spec 067 recorded 6 `core_widgets` golden failures that fail identically on main; those are outside these folders.)

---

## Phase 2: Foundational (blocks all user stories)

**Purpose**: first move the receipts code that doesn't depend on the document type into shared files (research R1, a rename with no behaviour change), then create what two or more issue stories share: strings, entities, the repository and the controllers.

**Rename rule for T002–T005**:
- Use `git mv` for each moved file.
- Rename the symbols across `lib/`, `test/` and `integration_test/`, never inside `lib/generated/`. Do it one symbol at a time, in the order of the research.md R1 table, with word-boundary replacements (for example `perl -pi -e 's/\bReceiptStatus\b/InventoryDocumentStatus/g'`). Old names are substrings of one another (`ReceiptStatus` is inside `InventoryReceiptStatusChip`, `inventoryReceiptStatusLabel` and the l10n keys), so a plain replace clobbers names that are renamed differently.
- Run `flutter analyze` after each symbol, and build_runner once per task that touches a freezed or `@riverpod` file.

Names and paths change; no behaviour does. The table in research.md R1 is the authority for the new names.

- [X] T002 Move the status enum and chip (research R1).
  - Create `lib/features/inventory/domain/entities/inventory_document_status.dart` with `InventoryDocumentStatus` (`draft`, `completed`, `cancelled`), moved out of `inventory_receipt.dart` where it was `ReceiptStatus`. Update the receipt entities, repository impl and every other user of `ReceiptStatus` (about 7 lib files and 14 test files).
  - `git mv` `presentation/receipts/inventory_receipt_status_chip.dart` to `presentation/shared/inventory_document_status_chip.dart`. Rename `InventoryReceiptStatusChip`, `inventoryReceiptStatusLabel` and `inventoryReceiptStatusColors` to `InventoryDocumentStatusChip`, `inventoryDocumentStatusLabel` and `inventoryDocumentStatusColors`, and its widget key `inventory_receipt_status_chip` to `inventory_document_status_chip` (two test files use it).
  - In `lib/l10n/app_es.arb` and `app_en.arb`, rename the keys both documents share (research R1), with their `@` entries, keeping the text:
    - `inventoryReceiptStatusDraft/Completed/Cancelled` → `inventoryDocumentStatusDraft/Completed/Cancelled`;
    - `inventoryReceiptDraftFolio` → `inventoryDocumentDraftFolio` ("Borrador #{id}");
    - `inventoryReceiptNoFacility` → `inventoryDocumentNoFacility` ("Tu usuario no tiene una sucursal asignada.").

    Update their users in the receipts code, then run `flutter gen-l10n`.
  - `git mv` `test/widget/features/inventory/inventory_receipt_status_chip_test.dart` to `inventory_document_status_chip_test.dart`, and rename its subject.
  - Run build_runner, then `flutter analyze`.

- [X] T003 Move the name cells (research R1, depends on T002): `git mv` `presentation/receipts/receipt_name_cells.dart` to `presentation/shared/inventory_name_cells.dart`, and rename `ReceiptWarehouseName`, `ReceiptFacilityName` and `ReceiptEmployeeName` to `InventoryWarehouseName`, `InventoryFacilityName` and `InventoryEmployeeName`. Update their users in the receipts list and detail screens.

- [X] T004 Move the warehouse options (research R1, depends on T003): `git mv` `presentation/receipts/receipt_warehouse_options.dart` to `presentation/shared/inventory_warehouse_options.dart` (and its `.g.dart` through build_runner). Rename `ReceiptWarehouseScope`, `receiptWarehouseScope`, `receiptWarehouseOptions`, `receiptFilterWarehouseOptions` and `receiptStartingWarehouse` to `InventoryWarehouseScope`, `inventoryWarehouseScope`, `inventoryWarehouseOptions`, `inventoryFilterWarehouseOptions` and `inventoryStartingWarehouse`. Update the receipts dialogs and list screen. `git mv` `test/unit/features/inventory/receipt_warehouse_options_test.dart` to `inventory_warehouse_options_test.dart` and rename its subject. Run build_runner.

- [X] T005 Move the filter (research R1, depends on T004): `git mv` `presentation/receipts/inventory_receipts_filter.dart` to `presentation/shared/inventory_documents_filter.dart` (and its `.freezed.dart` through build_runner), rename `InventoryReceiptsFilter` to `InventoryDocumentsFilter`, and update the receipts list screen and list controller. `git mv` `test/unit/features/inventory/inventory_receipts_filter_test.dart` to `inventory_documents_filter_test.dart` and rename its subject. Run build_runner.

- [X] T006 Checkpoint for the move (depends on T002–T005). Run `flutter analyze` and all of `test/unit/features/inventory/`, `test/widget/features/inventory/` and `test/unit/app/router/app_router_test.dart`. They must pass with only names and imports changed since T001. Search `lib/`, `test/` and `integration_test/` for leftover old names (`ReceiptStatus`, `ReceiptWarehouse`, `receiptWarehouse`, `ReceiptEmployeeName`, `ReceiptFacilityName`, `InventoryReceiptsFilter`, `inventoryReceiptStatus`, `inventoryReceiptDraftFolio`, `inventoryReceiptNoFacility`, `inventory_receipt_status_chip`) and fix any. **The gate is analyze plus these unit and widget tests.** Do not start T007 until they are green. The live receipts test runs in T031. If the dev API is reachable now, run `flutter test test/integration/inventory_receipts_live_test.dart --dart-define-from-file=.env.settings` (read-only) as an early signal; if it isn't, note that and continue.

- [X] T007 Add every issue string to `lib/l10n/app_es.arb` and `lib/l10n/app_en.arb`, then run `flutter gen-l10n`. Each key gets an `@key` description starting "spec 068".

**Key rule (one rule, no exceptions):**
- Issue code never uses an `inventoryReceipt…` key.
- It uses the shared `inventoryDocument…` keys that T002 created (status labels, "Borrador #{id}", no-facility text), app-wide generic keys already in the file (filters, clear filters, apply, cancel, save, back), and its own `inventoryIssue…` keys for everything else. Mirror the `inventoryReceipt…` key names.
- An issue key whose text happens to match a receipt key (for example "Folio") is still its own key.

The list is in contracts/ui-contract.md ("Spanish labels") and wireframes.md:
  - **Navigation and titles:** `navInventoryIssues` ("Salidas de almacén"), `inventoryIssueTitle` (placeholder `folio`: "Salida {folio}"), `inventoryIssueTitleDraft` (placeholder `id`: "Salida · Borrador #{id}"). A draft's list folio uses the shared `inventoryDocumentDraftFolio`.
  - **List:** the columns `inventoryIssueColFolio`, `…ColWarehouse`, `…ColFacility`, `…ColStatus`, `…ColCreator` and `…ColDate` (Folio, Almacén, Sucursal, Estado, Creado por, Fecha); the facets `inventoryIssueFacetStatus`, `…FacetWarehouse` and `…FacetAll`; the empty text ("No hay salidas de almacén"); and the filtered-empty text ("Ninguna salida coincide con los filtros.").
  - **Detail:** the fact labels (the "Motivo / notas" label is new; Devolución a proveedor, with a placeholder `id`: "Devolución a proveedor #{id}"), the lines table (Código, Producto, Cantidad), the empty-draft text ("Agrega los productos que salen del almacén."), and the refusal line `inventoryIssueRefusalProductWarehouse` (placeholders `code`, `warehouse`: "Producto: {code} · Almacén: {warehouse}").
  - **Actions and dialogs:** `inventoryIssueNewAction` ("Nueva salida"), edit header, add product, confirm and cancel actions, the dialog titles, the field labels (Almacén, "Motivo / notas", Producto, Cantidad), the notes hint ("p. ej. merma, daño, consumo interno"), and the prompts using the wording in ui-contract.md "Dialogs": confirm ("Confirmar asigna un folio y retira las existencias de {almacén}. Después ya no se puede editar."), cancel-draft ("Cancelar el borrador"), cancel-completed ("Cancelar la salida {folio} regresa a {almacén} las existencias que retiró.") and remove-line.
  - No error-message keys: every code is already localized (contracts/error-messages.md).

- [X] T008 [P] Create the entities (data-model.md, depends on T002): `lib/features/inventory/domain/entities/inventory_issue.dart` (freezed) with `InventoryIssueSummary`, `InventoryIssue` (adding `supplierReturnId`, `comment`, `updaterId`, `modifiedAt` and `lines`, with `isDraft`), `InventoryIssueLine` and `InventoryIssuePage`, using `InventoryDocumentStatus`. The summary does not carry `supplierReturn`. Run build_runner.

- [X] T009 Create the repository (contracts/repository.md, research R6, depends on T008).
  - In `lib/features/inventory/domain/repositories/inventory_issue_repository.dart` declare `list`, `get`, `create`, `updateHeader`, `addLine`, `updateLine`, `removeLine`, `confirm` and `cancel`.
  - In `lib/features/inventory/data/inventory_issue_repository_impl.dart`, implement them over the generated `InventoryIssuesApi(dio, appSerializers)` (methods named `listInventoryIssuesApiV1InventoryIssuesGet`, `createInventoryIssueApiV1InventoryIssuesPost` and so on, with `IssueCreate`, `IssueUpdate`, `LineAdd` and `LineUpdate`), with `inventoryIssueRepositoryProvider`. Map `DocumentStatus` to `InventoryDocumentStatus` as the receipt impl does, parse wire quantity strings into `Decimal`, treat a null `lines` as empty and an empty `comment` as null, and map `DioException` to `AppError` as `inventory_receipt_repository_impl.dart` does.
  - `updateHeader` sends `warehouse` only when given, and `clearComment` sends `comment: ""` (research R6; verified live for receipts in 067).
  - Create `test/unit/features/inventory/inventory_issue_fixtures.dart` (builders for summaries, issues and lines) and `test/unit/features/inventory/inventory_issue_repository_impl_test.dart`: the list params, each mapping case (draft with no serial, supplier return, null lines, empty comment), `updateHeader` sending only changed fields, and a `DioException` becoming a coded `AppError`.

- [X] T010 Create the list controller (depends on T005, T009): `lib/features/inventory/presentation/issues/inventory_issues_list_controller.dart`, an `AsyncNotifier` family keyed by `InventoryDocumentsFilter`, 20 per page, page clamped with `fetchClampedPage`. The server orders newest first, and the client sends no sort and no scope parameter (spec FR-002). Add `test/unit/features/inventory/inventory_issues_list_controller_test.dart`: the params sent, page clamping, and an error becoming `AsyncError`. Run build_runner.

- [X] T011 Create the detail controller (depends on T009): `lib/features/inventory/presentation/issues/inventory_issue_detail_controller.dart`, a `@riverpod` family keyed by the issue id that loads the issue and exposes a `refresh()` that re-fetches. Add `test/unit/features/inventory/inventory_issue_detail_controller_test.dart`: a load, a not-found error kept as an `AppError`, and `refresh()`. Run build_runner.

- [X] T012 Create the write controller (contracts/repository.md "Actions notifier", depends on T009, T011): `lib/features/inventory/presentation/issues/inventory_issue_actions.dart`, a keep-alive notifier with `create`, `updateHeader`, `addLine`, `updateLine`, `removeLine`, `confirm` and `cancel`.
  - Each returns `AppError?` (null on success). On success it writes the returned issue into `inventoryIssueDetailControllerProvider(id)` and invalidates the list family. `create` also returns the new issue's id so the caller can navigate. There is no warning flag on `confirm` and `cancel`.
  - After a refusal with `document.not_editable`, `inventory_document.already_cancelled` or `lock.busy`, it calls `refresh()` on the detail controller (spec edge case: concurrent edits).
  - Add `test/unit/features/inventory/inventory_issue_actions_test.dart`: each action's success and refusal, the invalidations, the new id from `create`, and the refresh after each of the three codes. Run build_runner.

---

## Phase 3: User Story 1 — Find an issue (Priority: P1) 🎯 MVP

**Goal**: a clerk opens Salidas de almacén and sees the issues the server grants them, newest first, filtered by state and warehouse, with each issue's folio, warehouse, facility, state, creator and date.

**Independent Test**: as a non-administrator with read on 16, open the list and check that only issues for their warehouse or created by them appear. Filter by state, then by warehouse. As an administrator every issue appears. As `qanoaccess`, the entry is missing and the URL is redirected to the home page (the app's route gate).

- [X] T013 [US1] Create the list screen (ui-contract "List screen", wireframes "Screen: Salidas de almacén list", depends on T002–T005, T007, T010): `lib/features/inventory/presentation/issues/inventory_issues_list_screen.dart`. Declare `const inventoryIssuesPath = '/inventory/issues';` at the top of this file; T014 and later tasks import it.
  - Filter row: `CatalogFilterBar` with **no search control**, and the badged filters `IconButton.outlined(Icons.tune)` that opens `showCatalogFilterSheet`. The drawer holds Estado (choice chips, single select or none) and, with read on Warehouses (4), Almacén (a `CatalogEntityPicker<Warehouse>` using `inventoryFilterWarehouseOptions`).
  - Table: `DataTableView<InventoryIssueSummary>` with the columns in order: Folio (right-aligned; the serial, or "Borrador #{id}" for a draft), Almacén, Sucursal, Estado (`InventoryDocumentStatusChip`), Creado por, Fecha. Names come from the shared `InventoryWarehouseName`, `InventoryFacilityName` and `InventoryEmployeeName` (they show "#{id}" when a lookup fails). The row tap pushes `'$inventoryIssuesPath/${id}'`. No row icons and no purchase-order column.
  - `CatalogListStateView` for loading, empty, filtered-empty (with "Limpiar filtros") and error; `CatalogPagination`; the page lives in the URL. Dates through `formattersProvider`.
  - No Nueva salida button yet (T020).

- [X] T014 [US1] Add the navigation and the list route (ui-contract "Routes and navigation", depends on T013).
  - In `lib/core/navigation/nav_destinations.dart`, add `NavBranch.inventoryIssues = 31` (confirm the next free index first; `inventoryReceipts` is 30) and a second destination in the existing `inventory` group, after Entradas de almacén: "Salidas de almacén" (`Icons.outbox_outlined` / `Icons.outbox`, `PrivilegeGate(SystemObject.inventoryIssues, AccessRight.read)`). `SystemObject.inventoryIssues` (16) already exists in `lib/core/access/system_object.dart`. Update the comment above the group, which says issues will join it.
  - In `lib/app/router/app_router.dart`, add the `StatefulShellBranch` at the end, with `GoRoute(path: inventoryIssuesPath, builder: InventoryIssuesListScreen(query: ListQuery.fromUri(state.uri)))`, and the `_routeGate` clause for the `/inventory/issues` prefix returning `PrivilegeGate(SystemObject.inventoryIssues, AccessRight.read)`.
  - Add the nav and router cases to `test/unit/app/router/app_router_test.dart` and the navigation tests: the entry appears after Entradas de almacén with read on 16, is absent without it, the group stays when the user can read only one of the two, and the URL is redirected to the home page (the app's route gate).

- [X] T015 [US1] Test the list: extend `test/widget/features/inventory/inventory_harness.dart` with a mocktail `MockInventoryIssueRepository` and its provider override, then create `test/widget/features/inventory/inventory_issues_list_screen_test.dart`: rows render with a draft showing "Borrador #{id}" and no folio, a confirmed issue showing its folio, there are no row icons and no purchase-order column, the filter badge shows the active count, the status and warehouse facets are sent to the repository, no search control is present, the empty and filtered-empty states render with the "Limpiar filtros" action, a failed name lookup shows "#{id}", and a read error shows the banner.

**Checkpoint**: US1 is demonstrable on its own: open the list, filter it, and open a (still empty) detail URL.

---

## Phase 4: User Story 2 — Record and confirm an issue (Priority: P1) 🎯 MVP

**Goal**: a clerk creates an issue, adds the products that leave, edits quantities, removes lines, and confirms it. The issue then shows its folio and is read-only. A short-stock confirm is refused with the product and warehouse named, and the issue stays a draft.

**Independent Test**: as the non-administrator, create an issue (starting on their point-of-sale warehouse), add two stockable products, add one again and check that its quantity grows, edit and remove a line, then confirm. The issue shows its folio and Confirmada, and the warehouse stock has dropped. Ask for more than the warehouse has and check the Spanish refusal with the product code and warehouse. Confirm an empty draft and check the Spanish reason.

- [X] T016 [US2] Create the dialogs file (ui-contract "Dialogs", wireframes "Dialogs", depends on T007, T012): `lib/features/inventory/presentation/issues/issue_dialogs.dart`, built on `showResponsiveDialog`, mirroring `receipt_dialogs.dart`.
  - `showIssueLineQuantityDialog` (quantity > 0, prefilled, `hasUnsavedChanges`, busy flag, refusal in `FormErrorBanner`, stays open on refusal).
  - `showRemoveIssueLineDialog` (the remove-line prompt).
  - `showConfirmIssueDialog`: the confirm prompt that says the stock is taken out of the named warehouse (FR-012). It takes the warehouse name and has no warning list.
  - The cancel prompt comes in T025.

- [X] T017 [P] [US2] Create the add-line dialog (spec FR-008 to FR-011, depends on T007, T012): `lib/features/inventory/presentation/issues/add_issue_line_dialog.dart`, mirroring `add_receipt_line_dialog.dart`. A `CatalogEntityPicker<Product>` fed by `productRepositoryProvider.list(search:, status: active, stockable: true, limit: 10)`, shown only with read on Products. A Cantidad field (> 0, through `fmt.field.quantity` / `parseQuantity`). The dialog stays open on refusal, and adding an existing product merges server-side.

- [X] T018 [P] [US2] Create the new-issue dialog (spec FR-005, research R3, depends on T004, T007, T012): `lib/features/inventory/presentation/issues/new_issue_dialog.dart`, mirroring `new_receipt_dialog.dart`. An Almacén picker from `inventoryWarehouseOptions` (a non-administrator is offered only their own facility, and a user without a facility sees the no-sucursal text), starting on `inventoryStartingWarehouse`. A "Motivo / notas" field (optional, `maxLength` 500, counter, the hint "p. ej. merma, daño, consumo interno"). "Crear" calls `create` and pushes the new detail. The starting warehouse alone doesn't count as an unsaved change. An in-transit warehouse refusal shows in the dialog.

- [X] T019 [US2] Create the detail screen (ui-contract "Detail screen", wireframes "Screen: Issue detail", data-model "Action availability", research R5 and R7, depends on T011, T012, T016, T017): `lib/features/inventory/presentation/issues/inventory_issue_detail_screen.dart`, mirroring `inventory_receipt_detail_screen.dart` without its purchase-order, warning, notice and complementary code.
  - Title: "Salida {serial}" or "Salida · Borrador #{id}". No AppBar actions.
  - Facts (`FactStripRow` in a `ResponsiveFormGrid`): Estado (chip), Folio, Almacén, Sucursal, "Motivo / notas", Creado por and Modificado por with dates, and "Devolución a proveedor #{id}" only when `supplierReturnId` is set, as plain text.
  - Lines table (`DataTableView`): Código, Producto, Cantidad. On a draft with update on 16, ✎ and 🗑 via `buildCatalogRowActions` (✎ opens `showIssueLineQuantityDialog`, 🗑 the remove prompt). The empty-draft text is "Agrega los productos que salen del almacén."
  - Action area, left to right: Agregar producto (update on 16, read on Products, draft only) and Confirmar (update on 16, draft only, through `showConfirmIssueDialog` then `confirm`). Cancelar and Editar encabezado come in T026 and T023.
  - Refusals show in an `ErrorBanner` above the action area. For `inventory_document.insufficient_stock`, add the line `inventoryIssueRefusalProductWarehouse` (research R5): the code is looked up from the error's `product_id` among the issue's lines (falling back to `#{id}`), and the warehouse name is the issue's own, from `warehouseDisplayNameProvider`. Mirror `_refusalProductCode` in the receipt detail screen. Show the banner and the extra line only while the refusal is current, and clear them on the next action.
  - Loading, not-found and forbidden states use the shared error view, as the receipt detail does.
  - Names, quantities and dates go through the shared name cells and `formattersProvider`.

- [X] T020 [US2] Wire creation and the detail route (depends on T014, T018, T019).
  - In `lib/app/router/app_router.dart`, add the top-level `GoRoute(path: '$inventoryIssuesPath/:id', builder: InventoryIssueDetailScreen(id))`, gated by the same `_routeGate` clause as the list (read on 16). Reject a non-numeric id as the receipt route does.
  - In `inventory_issues_list_screen.dart`, add the "Nueva salida" `FilledButton.icon(Icons.add)` to the filter bar's actions, shown when `can(16, create)` and `can(4, read)`, opening `new_issue_dialog` (T018).
  - Extend `test/unit/app/router/app_router_test.dart` with the detail route's gate.

- [X] T021 [US2] Test the dialogs and the detail screen (depends on T015, T019, T020): create `test/widget/features/inventory/new_issue_dialog_test.dart`, `add_issue_line_dialog_test.dart`, `issue_dialogs_test.dart` and `inventory_issue_detail_screen_test.dart`.
  - New dialog: the starting warehouse, a non-administrator's own-facility options, the no-facility text, the 500-character limit, the hint, and a refusal staying in the dialog.
  - Add-line dialog: quantity ≤ 0 refused, stockable-only picker, and a `product.not_stockable` refusal from `addLine` shown in Spanish with the dialog staying open (FR-015).
  - Prompts: the confirm prompt names the warehouse and says the stock is taken out.
  - Detail: a draft shows "Salida · Borrador #{id}" and no folio, Confirmar and the line icons appear with update on 16 and are absent for a read-only user and on a completed issue, a completed issue shows its folio and no edit actions, "Devolución a proveedor #{id}" shows only when set, the empty draft text, no warning or notice band ever appears, an `insufficient_stock` refusal shows the Spanish message plus "Producto: {code} · Almacén: {name}" and the issue stays a draft, `no_lines` shows "La salida de almacén no tiene partidas.", and `lock.busy` re-fetches.

**Checkpoint**: US1 and US2 together are the MVP: find, record, confirm, and be refused on short stock.

---

## Phase 5: User Story 3 — Correct a draft's header (Priority: P2)

**Goal**: on a draft, change the source warehouse or the notes. Changing the warehouse moves the draft to that warehouse's facility.

**Independent Test**: as an administrator, change a draft's warehouse to one in another facility and edit the notes. After reopening the draft, both changes are kept and the Sucursal shows the new facility. As a non-administrator, the picker offers only their own facility's warehouses. A completed or cancelled issue has no header edit.

- [X] T022 [US3] Create the header dialog (spec FR-006, ui-contract "Dialogs", depends on T004, T007, T012): `lib/features/inventory/presentation/issues/issue_header_dialog.dart`, mirroring `receipt_header_dialog.dart` without its fixed-warehouse case.
  - Almacén is a picker with read on Warehouses (4), otherwise read-only text, using `inventoryWarehouseOptions` (own facility only for a non-administrator).
  - "Motivo / notas" (≤ 500, counter, the same hint). Send only changed fields. Cleared notes send `""` (research R6).
  - `hasUnsavedChanges`, a busy flag, and refusals in `FormErrorBanner` with the dialog staying open (the in-transit warehouse refusal shows here).

- [X] T023 [US3] Add Editar encabezado to the detail screen (depends on T019, T022): an `OutlinedButton` shown when `can(16, update)` and the issue is a draft, opening `showIssueHeaderDialog`, placed before Agregar producto in the action area.

- [X] T024 [US3] Test the header (depends on T021, T023): create `test/widget/features/inventory/issue_header_dialog_test.dart` and add cases to the detail test: only changed fields are sent, cleared notes send `""`, the 500-character limit, a non-administrator's own-facility options, read-only warehouse text without read on Warehouses, the in-transit refusal staying in the dialog, and Editar encabezado absent on a completed issue and for a read-only user.

---

## Phase 6: User Story 4 — Cancel an issue (Priority: P2)

**Goal**: cancel a draft (nothing posted) or a completed issue (its stock goes back into the warehouse).

**Independent Test**: cancel a draft and check it shows Cancelada. Confirm another issue, cancel it, and check the warehouse's stock is back to what it was before the confirm. A cancelled issue offers no actions, and a user without the delete right never sees Cancelar.

- [X] T025 [US4] Add the cancel prompt (research, ui-contract "Dialogs", depends on T016): in `issue_dialogs.dart`, `showCancelIssueDialog`. For a draft it reads "Cancelar el borrador". For a completed issue it names the folio and the warehouse and says the stock goes back into it ("Cancelar la salida {folio} regresa a {almacén} las existencias que retiró."). There is no reason field, because the endpoint takes none.

- [X] T026 [US4] Add Cancelar to the detail screen (depends on T019, T025): an `OutlinedButton` in the error tone, first in the action area, shown when `can(16, delete)` and the status is not cancelled (a draft or completed issue). It opens `showCancelIssueDialog`, then calls `cancel`. A refusal shows in the banner.

- [X] T027 [US4] Test cancel (depends on T021, T026): add to `inventory_issue_detail_screen_test.dart` and `issue_dialogs_test.dart`: the draft and completed wordings, Cancelar present with delete on 16 and absent without it, absent on a cancelled issue, a cancelled issue showing Cancelada and no actions at all, `inventory_document.already_cancelled` showing "La salida de almacén ya está cancelada." and re-fetching, and `facility.other_facility` showing in Spanish.

---

## Phase 7: Polish & cross-cutting

- [X] T028 [P] Live API test (research R9, depends on T012): `test/integration/inventory_issues_live_test.dart`, mirroring `inventory_receipts_live_test.dart`, with fixtures discovered at runtime: an active stockable product with available stock in a warehouse that isn't in transit (read with `StockApi`, as the receipts test does), and any issue with `supplierReturn != null`, skipping that case when none exists. Writes run only with `MBE_WRITE=true`. Cover:
  - list and get;
  - create a draft, add and merge lines, edit a line, remove a line, update the header (including clearing the notes);
  - confirm: the stock of the product drops by the quantity (SC-002);
  - cancel: the stock returns;
  - the insufficient-stock path: add a line of available stock + 1, confirm, expect the 409 `inventory_document.insufficient_stock` with the issue still a draft (SC-003);
  - an empty-draft confirm (`no_lines`) and a draft cancel.

  Note in the file header which accounts it needs. No seeded non-administrator has rights on 16, so the non-administrator cases stay manual (research R9).

- [X] T029 [P] Device test (quickstart.md, depends on T020, T026): `integration_test/inventory_issues_quickstart_test.dart`, mirroring `inventory_receipts_quickstart_test.dart` and the macOS traps in memory (frame-stall watchdog, picker and back-button finders). Walk steps 1, 2, 4 to 8 of the quickstart as the administrator. Run with `flutter test integration_test/inventory_issues_quickstart_test.dart -d macos --dart-define-from-file=.env`.

- [X] T030 [P] Largest text level (quickstart step 10, depends on T021): `test/widget/features/inventory/inventory_issues_large_text_test.dart`, mirroring `inventory_receipts_large_text_test.dart`. At the largest text scale, the list and the detail's lines table don't clip or scroll sideways at 1280 px.

- [X] T031 Final checks (depends on all previous tasks).
  - Run `flutter analyze` (no new warnings), `dart format` on the changed files only, and `flutter test test/unit/features/inventory test/widget/features/inventory test/unit/core/errors/catalog_coverage_test.dart test/unit/core/formatting_guard_test.dart test/unit/app/router/app_router_test.dart`.
  - Run the receipts live test and the issues live test again (read-only, then with `MBE_WRITE=true`) and the receipts device test, to prove the move changed nothing for receipts.
  - Search `lib/features/inventory/` for literal colours, sizes and spacing (§V), for `NumberFormat` and `toStringAsFixed`, and for any display of `enum.name` or server message text (§III).
  - Check that no new `core/widgets/` file or error code was added: the plan says none is needed.

- [X] T032 Validate against the quickstart (depends on T031). Run the walkthrough in quickstart.md against the dev mbe-api. Then check FR-018 by opening Entradas and Salidas de almacén side by side. These must match, apart from the documented differences (no Orden de compra, warnings or Entrada complementaria on issues):
  - the column order;
  - the filter drawer;
  - the facts strip;
  - the button order in the action area;
  - the wording of the prompts. Steps 3 and 8's non-administrator parts need an account with rights on 16 that isn't seeded, so list them as manual checks to track in a GitHub issue after merge, as 067 did (ui#262). Record the result and any deviation in the PR description, with `Closes mictlanix/mbe-roadmap#61` under "Roadmap".

---

## Dependencies & execution order

- **Phase 1** (T001) first.
- **Phase 2** has two parts:
  - The move runs strictly in order T002 → T003 → T004 → T005 → T006, since each task edits the same receipts files and runs build_runner. Nothing else starts until T006 is green.
  - Then T007 and T008 can run in parallel. T009 needs T008, T010 and T011 need T009 (T010 also T005), and T012 needs T011.
- **US1** (T013–T015) needs Phase 2. **US2** (T016–T021) needs US1's list and route. **US3** (T022–T024) and **US4** (T025–T027) each need only US2's detail screen, so they can run in parallel with each other if different people take them, but both edit `inventory_issue_detail_screen.dart` and `issue_dialogs.dart`, so do T023 and T026 one after the other.
- **Polish** (T028–T030) can start once the code it covers exists, and T031 and T032 come last.

### Parallel opportunities

- T007 ∥ T008 (strings and entities).
- T017 ∥ T018 (two new dialog files).
- T028 ∥ T029 ∥ T030 (three independent test files).
- Across stories, US3 and US4 after US2.

## Implementation strategy

- **MVP**: Phase 1, Phase 2 and US1 + US2 (T001–T021). That delivers find, record, confirm and the short-stock refusal, and it is the most valuable increment.
- **Increment 2**: US3 (header corrections) and US4 (cancel), in either order.
- **Then**: Polish, the live and device checks, and the quickstart.
- **Risk to watch**: the move in T002–T005 touches shipped receipts code. T006 is a hard gate: if any receipts test fails there, stop and fix the move before building any issue code.
