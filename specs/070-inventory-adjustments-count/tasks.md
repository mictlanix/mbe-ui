---
description: "Task list for 070-inventory-adjustments-count"
---

# Tasks: Physical Inventory Counts

**Input**: Design documents from `specs/070-inventory-adjustments-count/`

**Prerequisites**: plan.md, spec.md (with its Clarifications), research.md (R1–R13), data-model.md, contracts/ui-contract.md, contracts/repository.md, contracts/error-messages.md, quickstart.md, wireframes.md

**Tests**: The spec doesn't ask for a test suite as such, but the constitution's quality gates require tests. Test tasks sit inside each story, after the code they cover. The paste parser is the exception: it is pure logic, so its test is written first (T020).

**Organization**: Grouped by user story (US1–US5, spec.md). US1 and US2 are P1 and together are the MVP: find counts, then count a warehouse and confirm. US3 (load a large count fast) and US4 (the confirm warnings) are P2. US5 (correct a draft's header, or drop it) is P3. Phase 2 holds what two or more stories share.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: parallelizable (different files, no dependency on an incomplete task)
- **[Story]**: US1 find a count · US2 count and confirm · US3 load a large count fast · US4 review the warnings · US5 header and cancel

## Cross-story notes

- **This feature builds on specs 067–069.** `lib/features/inventory/` and its tests already exist, and the shared inventory parts (`InventoryDocumentStatus`, the name cells, the warehouse options, `InventoryDocumentsFilter`) are reused as they are (research R1). No shipped receipts, issues or transfers file is edited, except the routing, navigation, error-catalog, l10n and test-harness files named below. Open the issues counterpart of every file before writing the count version, and mirror it with the differences research.md and ui-contract.md list: lines replace instead of adding, drafts are blind, quick entry and paste exist, warnings come back on confirm, and a completed count can't be cancelled.
- **Shared files.** Do these sequentially, not in parallel:
  - `lib/features/inventory/presentation/counts/inventory_count_detail_screen.dart`: T017 (US2) creates it with the facts, the blind/completed lines table with in-memory paging and search, Confirmar and the line actions. T023 (US3) adds the quick-entry row and Pegar lista, T026 (US4) adds the warnings band, and T029 (US5) adds Editar encabezado and Cancelar. Every control is a nullable callback or a collection-`if`, so an absent right means the control is not in the tree.
  - `lib/features/inventory/presentation/counts/count_dialogs.dart`: T014 (US2) creates it with the quantity, remove-line and confirm prompts, and T028 (US5) adds the cancel prompt.
  - `lib/features/inventory/presentation/counts/inventory_counts_list_screen.dart`: T011 (US1) creates it, and T018 (US2) adds the Nuevo conteo button.
  - `lib/app/router/app_router.dart` and `lib/core/navigation/nav_destinations.dart`: T012 (US1) adds the list branch, the nav entry and the gate, and T018 (US2) adds the detail route.
  - `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb`: T002 adds the error and resource keys, and T003 adds every count key once. If a later task needs another, add it there and run `flutter gen-l10n`. Never hand-edit `lib/l10n/app_localizations*.dart`.
  - `test/widget/features/inventory/inventory_harness.dart`: T010 extends it, and later tests only use it.
- **Generated code.** After editing a freezed or `@riverpod` file, run `dart run build_runner build --delete-conflicting-outputs` at the repo root. Never run two build_runner processes at once: tasks that both need it are not marked [P] against each other. No client regeneration is needed: `InventoryCountsApi` already has every operation this spec calls (list, get, create, update, set lines, update line, delete line, confirm, cancel).
- **Formatting.** Format only the files you changed (`dart format <files>`). Never `dart format .`, and never format `lib/generated/`.
- **Quantities and dates** go through `formattersProvider` (constitution §V). No `NumberFormat`, no `toStringAsFixed`. Quantities are `Decimal`, never `double`; the wire carries them as strings. The paste parser reads user input, so it parses decimals itself (plan, Constitution Check V).
- **Spacing tokens, not literals** (`Theme.of(context).spacing`). No automated guard catches a literal, so check it in review.
- **Never match or show server prose** (§III). Show refusals through `AppError.localizedMessage` / `ErrorBanner`, which build the text from the error's `code`. Recognition keys on the code, and on `extra['index']` for batch parts.
- **Status names come from l10n**, never from `enum.name`. Counts use the masculine labels (research R2).
- **Row icons (§VI document reading).** List rows have no icons, and only draft line rows get ✎ and 🗑. This is intentional; see the Complexity Tracking row in plan.md. Don't add a row Edit icon or a View toggle.
- **Rights.** Every control follows the availability table in data-model.md and the rights lines in contracts/ui-contract.md. A missing right means the control is absent, never disabled. The one exception is Enviar in the paste dialog, which is a validity gate (wireframes). Document the system-object code (PhysicalCountAdjustment = 74; Warehouses = 4) in a comment where a route, nav entry or control is gated.
- **Blind drafts (SC-003).** No widget may read `quantityOnHand` or `difference` unless the count is completed.
- **Simplifications.** Any shortcut carries a comment `// simplified: <ceiling>, <what to do when it binds>`.
- **Closest precedents** (all in `lib/features/inventory/` and `test/*/features/inventory/`): each count file mirrors its issue file.
  - `inventory_issues_list_screen.dart`, `inventory_issue_detail_screen.dart`, `inventory_issue_actions.dart`, `new_issue_dialog.dart`, `issue_header_dialog.dart`, `add_issue_line_dialog.dart`, `issue_dialogs.dart`.
  - Post-confirm notice: `receipts/receipt_warnings.dart` (`ReceiptCostNotice`).
  - In-memory paging: `lib/features/auth/presentation/admin/privileges_grid.dart`.
  - Repository: `data/inventory_issue_repository_impl.dart`, with its test.
  - Test builders: `test/unit/features/inventory/inventory_issue_fixtures.dart`. Widget harness: `test/widget/features/inventory/inventory_harness.dart`.
  - Live test: `test/integration/inventory_issues_live_test.dart`. Device test: `integration_test/inventory_issues_quickstart_test.dart`.

---

## Phase 1: Setup

**Purpose**: a known-good baseline, so later failures are attributable.

- [ ] T001 Run `flutter analyze` and the tests this feature touches: all of `test/unit/features/inventory/` and `test/widget/features/inventory/`, plus `test/unit/core/errors/catalog_coverage_test.dart`, `test/unit/app/router/app_router_test.dart` and `test/unit/core/formatting_guard_test.dart`. Record any failure that predates this feature, so it isn't blamed on the new code.

---

## Phase 2: Foundational (blocks all user stories)

**Purpose**: what two or more stories share: the error messages, the strings, the entities, the repository, the controllers, the action notifier and the status chip.

- [ ] T002 Add the error coverage (research R10, contracts/error-messages.md).
  - In `lib/core/errors/localize_problem.dart`, add the six codes to `localizedErrorCodes` and to the `localizeProblem` switch: `inventoryCountPeriodBatchInvalid`, `inventoryCountPeriodConfirmedCannotCancel`, `inventoryCountLinePeriodProductUnknown`, `inventoryCountLinePeriodNotStockable`, `inventoryCountLinePeriodRepeated` and `inventoryCountLinePeriodProductReference`.
  - Add `'inventory_count'` to both resource switches, after `'inventory_issue'` (about L697 and L757): `l10n.apiResourceInventoryCount(count)` and `l10n.apiResourceGenderInventoryCount`.
  - In `lib/l10n/app_es.arb` and `app_en.arb`, add the six `apiError…` keys with the texts in the contract (follow the existing `apiErrorLockBusy` naming), plus `apiResourceInventoryCount` (es "{count, plural, one{conteo} other{conteos}}") and `apiResourceGenderInventoryCount` (es "masculine"; en as the sibling nouns do). Run `flutter gen-l10n`.
  - **Check:** `flutter test test/unit/core/errors/catalog_coverage_test.dart` passes, and a quick unit assertion shows `inventory_document.no_lines` with `resource: inventory_count` reads "El conteo no tiene partidas."

- [ ] T003 [P] Add every count string (depends on nothing; ui-contract.md and wireframes.md are the wording authority) to `lib/l10n/app_es.arb` and `app_en.arb`, with `@` entries for placeholders. Run `flutter gen-l10n`.
  - **Nav:** `navInventoryCounts` "Conteos físicos".
  - **Status:** `inventoryCountStatusDraft/Completed/Cancelled` "Borrador" / "Confirmado" / "Cancelado" (research R2).
  - **List:** the columns Folio, Almacén, Sucursal, Estado, Creado por, Fecha; the facets Estado, Almacén and All; the empty text "No hay conteos físicos"; the filtered-empty text "Ningún conteo coincide con los filtros."
  - **Detail:** the fact labels (Comentario, Partidas), the draft title with a placeholder `id` ("Conteo · Borrador #{id}"), the completed title with a `folio`, the lines table columns (Código, Producto, Contado, Esperado, Diferencia), the line search hint, and the empty-draft text ("Registra lo que contaste. Las existencias esperadas se muestran al confirmar."). The in-memory pager needs no new key: `CatalogPagination` takes its text from the shared table's built-in localizations.
  - **Quick entry:** the labels (Captura rápida, Código, Cantidad, Registrar) and the feedback line with and without "(reemplazada)" (placeholders `code`, `name`, `old`, `new`).
  - **Actions and dialogs:** "Nuevo conteo", edit header, "Pegar lista", add product, confirm and cancel actions; the dialog titles; the field labels (Almacén, Comentario, Producto, Contado); the replace note "Ya contado: {qty}. Se reemplazará."; and the prompts, using the wording in ui-contract.md and wireframes.md "Dialogs": confirm (it says the warehouse's stock is set to the counted quantities and that a confirmed count can't be cancelled, with the checkbox text "Contar en 0 los productos con existencia que no están en este conteo"), and cancel draft ("Cancelar el borrador #{id}. No se modifica ninguna existencia.").
  - **Paste dialog:** the instructions, "{n} filas leídas · {m} con problemas", one reason text per `CountPasteProblemKind`, the progress text ("Lote {k} de {n}"), the stop text with the applied count ("Se detuvo el envío. Se aplicaron {applied} de {total} filas."), the rejected-code line ("{code} {reason}", with row number), and the note that pasting the corrected list again is safe because quantities replace.
  - **Warnings band:** the title ("Conteo confirmado con avisos"), the two section headings, the negative-available line (`code`, `counted`, `reserved`, `available`) and the corrected-by-other line ("conteo {serial}").
  - No error-message keys here: T002 added them.

- [ ] T004 [P] Create the entities (data-model.md): `lib/features/inventory/domain/entities/inventory_count.dart` (freezed) with `InventoryCountSummary`, `InventoryCount` (adding `comment`, `updaterId`, `updatedAt` and `lines`, with `isDraft`, `isCompleted`, `isCancelled`), `InventoryCountLine` (with nullable `quantityOnHand` and `difference`), `InventoryCountPage`, `CountWarnings` (with `NegativeAvailableItem`, `CorrectedByOtherCountItem` and `isEmpty`), `CountConfirmResult` and `CountLineInput` (`byProduct` and `byCode`). Use `InventoryDocumentStatus`. Run build_runner.

- [ ] T005 Create the repository (contracts/repository.md, depends on T004).
  - In `lib/features/inventory/domain/repositories/inventory_count_repository.dart` declare `list`, `get`, `create`, `updateHeader`, `setLines`, `updateLine`, `removeLine`, `confirm` and `cancel`.
  - In `lib/features/inventory/data/inventory_count_repository_impl.dart`, implement them over the generated `InventoryCountsApi(dio, appSerializers)`, with `inventoryCountRepositoryProvider`. Map `DocumentStatus` to `InventoryDocumentStatus`, a null `lines` to empty, and `InventoryCountConfirmResponse` to `CountConfirmResult` (its `negativeAvailable` and `correctedByOtherCounts` to `CountWarnings`). Map `DioException` to `AppError`, keeping the `ApiProblem` and its parts, as the issues impl does. Verify the generated `Quantity2` type's wire form against a live response before trusting a string quantity (constitution §III).
  - `setLines` asserts 1 ≤ items ≤ 2,000. `updateHeader` always sends `comment` (null clears it).
  - Create `test/unit/features/inventory/inventory_count_fixtures.dart` (builders for summaries, counts, lines with and without on-hand figures, and warnings) and `test/unit/features/inventory/inventory_count_repository_impl_test.dart`: the list params, each mapping case (draft with no serial, blind lines with nulls, completed lines, null lines, empty comment, warnings), `setLines` building exactly one of `product` and `productCode` per item, and a `DioException` becoming a coded `AppError` whose batch parts keep their `index`.

- [ ] T006 [P] Create the status chip (research R2, depends on T003): `lib/features/inventory/presentation/counts/inventory_count_status_chip.dart` with `inventoryCountStatusLabel` and `InventoryCountStatusChip`, using `inventoryDocumentStatusColors` and the masculine labels, with the widget key `inventory_count_status_chip`. Add a small widget test `test/widget/features/inventory/inventory_count_status_chip_test.dart`.

- [ ] T007 Create the list controller (depends on T005): `lib/features/inventory/presentation/counts/inventory_counts_list_controller.dart`, an `AsyncNotifier` family keyed by `InventoryDocumentsFilter`, 20 per page, page clamped with `fetchClampedPage`. The server orders newest first, and the client sends no sort and no scope parameter (spec FR-002). Add `test/unit/features/inventory/inventory_counts_list_controller_test.dart`: the params sent, page clamping and an error kept as an `AppError`. Run build_runner.

- [ ] T008 Create the detail controller (depends on T005): `lib/features/inventory/presentation/counts/inventory_count_detail_controller.dart`, a `@riverpod` family keyed by the count id that loads the count and exposes a `refresh()` that re-fetches. Add `test/unit/features/inventory/inventory_count_detail_controller_test.dart`: a load, a not-found error kept as an `AppError`, and `refresh()`. Run build_runner.

- [ ] T009 Create the write controller (contracts/repository.md, depends on T005, T008): `lib/features/inventory/presentation/counts/inventory_count_actions.dart`, a keep-alive notifier with `create`, `updateHeader`, `setLines`, `updateLine`, `removeLine`, `confirm` and `cancel`.
  - Each returns `AppError?` (null on success), except `confirm`, which returns a `CountConfirmOutcome` (a small freezed or record type declared in this file) with the `AppError?` and the `CountWarnings` from the repository's `CountConfirmResult` (empty on a refusal). On success it writes the returned count into `inventoryCountDetailControllerProvider(id)` and invalidates the list family. `create` also returns the new count's id so the caller can navigate. `setLines` takes the already-split items for one batch (the paste sender owns the splitting, T021).
  - After a refusal with `document.not_editable`, `inventory_document.already_cancelled`, `inventory_count.confirmed_cannot_cancel` or `lock.busy`, it calls `refresh()` on the detail controller (spec edge cases: concurrent edits and a stale screen).
  - Add `test/unit/features/inventory/inventory_count_actions_test.dart`: each action's success and refusal, the invalidations, the new id from `create`, the warnings coming out of `confirm`, and the refresh after each of the four codes. Run build_runner.

---

## Phase 3: User Story 1 — Find a count (Priority: P1) 🎯 MVP

**Goal**: a supervisor opens Conteos físicos and sees the counts the server grants them, newest first, filtered by state and warehouse, with each count's folio, warehouse, facility, state, creator and date.

**Independent Test**: as a non-administrator with read on 74, open the list and check that only counts for their warehouse or created by them appear. Filter by state, then by warehouse. As an administrator every count appears. As `qanoaccess`, the entry is missing and the URL is redirected to the home page (the app's route gate).

- [ ] T010 [US1] Extend the widget harness (depends on T005): in `test/widget/features/inventory/inventory_harness.dart`, add a mocktail `MockInventoryCountRepository`, its `inventoryCountRepositoryProvider` override, and a helper to pump the count screens with it, mirroring how the issue repository is wired there. Every later widget test uses it.

- [ ] T011 [US1] Create the list screen (ui-contract "List screen", wireframes "Screen: Conteos físicos list", depends on T003, T006, T007): `lib/features/inventory/presentation/counts/inventory_counts_list_screen.dart`. Declare `const inventoryCountsPath = '/inventory/counts';` at the top of this file; T012 and later tasks import it.
  - Filter row: `CatalogFilterBar` with **no search control**. Its actions are, in order, the (later) Nuevo conteo button and then the badged filters `IconButton.outlined(Icons.tune)` that opens `showCatalogFilterSheet`. The drawer holds Estado (choice chips with the masculine labels, single select or none) and, with read on Warehouses (4), Almacén (a `CatalogEntityPicker<Warehouse>` using `inventoryFilterWarehouseOptions`).
  - Table: `DataTableView<InventoryCountSummary>` with the columns in order: Folio (right-aligned; the serial, or "Borrador #{id}" when there is none, including cancelled counts), Almacén, Sucursal, Estado (`InventoryCountStatusChip`), Creado por, Fecha. Names come from the shared `InventoryWarehouseName`, `InventoryFacilityName` and `InventoryEmployeeName` with `name: null`, so they use the id lookup (research R12). The row tap pushes `'$inventoryCountsPath/${id}'`.
  - `CatalogListStateView` for loading, empty, filtered-empty (with "Limpiar filtros") and error; `CatalogPagination`; the page lives in the URL. Dates through `formattersProvider`.
  - No Nuevo conteo button yet (T018).

- [ ] T012 [US1] Add the navigation and the list route (ui-contract "Routes and nav", depends on T011).
  - In `lib/core/navigation/nav_destinations.dart`, add `NavBranch.inventoryCounts = 33` and a fourth destination in the existing `inventory` group, after Traspasos (first confirm that `inventoryTransfers = 32` is still the highest `NavBranch` value and that `SystemObject.physicalCountAdjustment` (74) exists in `lib/core/access/system_object.dart`; if the next free index differs, use it and update this task's number): `navInventoryCounts` (`Icons.fact_check_outlined` / `Icons.fact_check`, `PrivilegeGate(SystemObject.physicalCountAdjustment, AccessRight.read)`), with a comment naming system object 74.
  - In `lib/app/router/app_router.dart`, add the `StatefulShellBranch` at the end, with `GoRoute(path: inventoryCountsPath, builder: InventoryCountsListScreen(query: ListQuery.fromUri(state.uri)))`, and the `_routeGate` clause for the `/inventory/counts` prefix returning the same gate.
  - Add the nav and router cases to `test/unit/app/router/app_router_test.dart` and the navigation tests: the entry appears after Traspasos with read on 74, is absent without it, the group stays when the user can read only some of the documents, and the URL is redirected to the home page (the app's route gate).

- [ ] T013 [US1] Test the list (depends on T010, T011, T012): create `test/widget/features/inventory/inventory_counts_list_screen_test.dart`: rows render with a draft and a cancelled count showing "Borrador #{id}" and a completed count showing its folio, the chips read "Confirmado" and "Cancelado", there are no row icons, the filter button shows its badge count, the state and warehouse filters change the query, the Almacén facet is absent without read on 4, empty, filtered-empty and error states render, and the action order is the Nuevo conteo slot first, filters last once T018 adds the button.

**Checkpoint**: US1 is demonstrable on its own: open the list, filter it, and open a (still empty) detail URL.

---

## Phase 4: User Story 2 — Count a warehouse and confirm (Priority: P1) 🎯 MVP

**Goal**: a supervisor creates a count, enters products with counted quantities (a repeat replaces), edits and removes lines, and confirms, choosing whether uncounted stock is counted as 0. The count then shows its folio, Esperado and Diferencia per line, and is read-only with no cancel.

**Independent Test**: note a product's stock in a warehouse, create a count for it, enter that product with its stock + 3 and a second product with 0, enter the first again with another quantity and check the line was replaced, then confirm. The count shows a folio and Confirmado, each line shows Esperado and Diferencia, and the warehouse's stock of each product equals the counted quantity. No expected quantity appears anywhere while it was a draft.

- [ ] T014 [US2] Create the dialogs file (ui-contract "Dialogs", wireframes "Dialogs", depends on T003, T009): `lib/features/inventory/presentation/counts/count_dialogs.dart`, built on `showResponsiveDialog`, mirroring `issue_dialogs.dart`.
  - `showCountLineQuantityDialog` (quantity ≥ 0 with up to 4 decimals, 0 valid, prefilled, `hasUnsavedChanges`, busy flag, refusal in `FormErrorBanner`, stays open on refusal).
  - `showRemoveCountLineDialog` (the remove-line prompt).
  - `showConfirmCountDialog`: the confirm prompt per FR-012, with the `CheckboxListTile` (off by default). It returns the checkbox value on accept, and null on dismissal. It takes the warehouse name. It never states how many products will be zeroed (SC-003).
  - The cancel prompt comes in T028.

- [ ] T015 [P] [US2] Create the add-line dialog (spec FR-008 to FR-011, depends on T003, T009): `lib/features/inventory/presentation/counts/add_count_line_dialog.dart`, mirroring `add_issue_line_dialog.dart`. A `CatalogEntityPicker<Product>` fed by `productRepositoryProvider.list(search:, status: active, stockable: true, limit: 10)`, shown only with read on Products. A Contado field (≥ 0, up to 4 decimals, through `fmt.field.quantity`). The dialog receives the count's lines: when the chosen product is already a line it shows the note "Ya contado: {qty}. Se reemplazará." (FR-009). The button reads "Registrar" and calls `setLines` with one `CountLineInput.byProduct`. A refusal (for example `inventory_count.batch_invalid` with one part) shows the part's message, not the batch text, in `FormErrorBanner`, with the dialog staying open.

- [ ] T016 [P] [US2] Create the new-count dialog (spec FR-005, depends on T003, T009): `lib/features/inventory/presentation/counts/new_count_dialog.dart`, mirroring `new_issue_dialog.dart`. An Almacén picker from `inventoryWarehouseOptions` (a non-administrator is offered only their own facility, and a user without a facility sees the no-sucursal text), starting on `inventoryStartingWarehouse`. A Comentario field (≤ 500, optional). It calls `create`, then pushes `'$inventoryCountsPath/${id}'`. `hasUnsavedChanges`, a busy flag, and refusals (the in-transit warehouse) in `FormErrorBanner` with the dialog staying open.

- [ ] T017 [US2] Create the detail screen (ui-contract "Detail screen", wireframes "Screen: Count detail", data-model "Action availability", research R5 and R13, depends on T003, T006, T008, T009, T014, T015): `lib/features/inventory/presentation/counts/inventory_count_detail_screen.dart`, mirroring `inventory_issue_detail_screen.dart`.
  - Title: "Conteo {serial}" when completed, otherwise "Conteo · Borrador #{id}" (also when cancelled). No AppBar actions.
  - Facts (`FactStripRow` in a `ResponsiveFormGrid`): Estado (chip), Folio ("—" on a draft), Almacén, Sucursal, Comentario, Partidas (`lines.length`), Creado por and Modificado por with dates.
  - Lines section (`_LinesSection`): a `CatalogSearchBar` (key `count_lines_search`) filtering the loaded lines by code or name, case-insensitively, before paging; then `DataTableView<InventoryCountLine>` paged in memory at 100 rows with `CatalogPagination` and `CatalogPage`, following `privileges_grid.dart` (research R5). Changing the search returns to page 1, and a write keeps the current page when it still exists. Columns: Código, Producto, Contado, and, **only when the count is completed**, Esperado and Diferencia (signed, "+" for positive, through `fmt.display.quantity`). On a draft with update on 74, ✎ and 🗑 via `buildCatalogRowActions` (✎ opens `showCountLineQuantityDialog`, 🗑 the remove prompt). Empty-draft text per T003. Add `// simplified: the whole count is held in memory, a count of ~15,000 lines is fine; if counts grow past that, page on the server.`
  - Action area, left to right: Agregar producto (update on 74, read on Products, draft only) and Confirmar (update on 74, draft only, through `showConfirmCountDialog` then `confirm` with its `includeUncounted`). Cancelar, Editar encabezado, Pegar lista and the quick-entry row come later (T029, T023).
  - Refusals show in an `ErrorBanner` above the action area, kept in local state so they survive the reload a write triggers (as `_IssueBody` does). The confirm outcome's warnings are not shown yet (T026).
  - Loading, not-found and forbidden states use the shared error view.
  - Names, quantities and dates go through the shared name cells and `formattersProvider`.

- [ ] T018 [US2] Wire creation and the detail route (depends on T012, T016, T017).
  - In `lib/app/router/app_router.dart`, add the top-level `GoRoute(path: '$inventoryCountsPath/:id', builder: InventoryCountDetailScreen(id))`, gated by the same `_routeGate` clause as the list (read on 74). Reject a non-numeric id as the issue route does.
  - In `inventory_counts_list_screen.dart`, add the "Nuevo conteo" `FilledButton.icon(Icons.add)` **before** the filter button in the filter bar's actions, shown when `can(74, create)` and `can(4, read)`, opening `new_count_dialog` (T016).
  - Extend `test/unit/app/router/app_router_test.dart` with the detail route's gate.

- [ ] T019 [US2] Test the dialogs and the detail screen (depends on T013, T017, T018): create `test/widget/features/inventory/new_count_dialog_test.dart`, `add_count_line_dialog_test.dart`, `count_dialogs_test.dart` and `inventory_count_detail_screen_test.dart`.
  - New dialog: the starting warehouse, a non-administrator's own-facility options, the no-facility text, the 500-character limit, and a refusal staying in the dialog.
  - Add-line dialog: a negative quantity refused, 0 accepted, the stockable-only picker, the replace note when the product is already a line, and a `batch_invalid` refusal with one part shown as the part's Spanish message with the dialog staying open (FR-016).
  - Prompts: the confirm prompt says the stock is set to the counted quantities and a confirmed count can't be cancelled, its checkbox is off by default and its value is returned.
  - Detail: a draft shows "Conteo · Borrador #{id}", no folio, and **no Esperado or Diferencia column and no on-hand figure anywhere** (SC-003); Confirmar and the line icons appear with update on 74 and are absent for a read-only user and on a completed count; a completed count shows its folio, Esperado and a signed Diferencia, and no edit or cancel action; a cancelled count keeps the draft title and has no actions; the empty-draft text; the line search narrows the table by code and by name; with 250 lines the table shows 100 and the pager moves between pages, and a search returns to page 1; refusals (`inventory_document.no_lines`, `lock.busy`) show in Spanish and the count stays a draft.

**Checkpoint**: US1 and US2 together are the MVP: find, count, confirm, and see expected stock and differences afterward.

---

## Phase 5: User Story 3 — Load a large count fast (Priority: P2)

**Goal**: on a draft, enter products by scanning or typing a code and a quantity with the keyboard only, and paste a code/quantity list that is checked first and sent in batches of up to 2,000, with every bad row listed.

**Independent Test**: on a draft, enter three products with the quick-entry row using only the keyboard. Paste 2,500 rows with one quantity "abc": the screen lists that row and does not send. Fix it and paste again: the rows are sent in two batches and the count shows 2,500 lines. Paste a list with one unknown code in its second batch: the first batch is applied, sending stops, the unknown code is listed, and the screen says how many rows were applied.

- [ ] T020 [P] [US3] Test-first, then create the paste parser (research R7, data-model "CountPaste"): write `test/unit/features/inventory/count_paste_test.dart` first, then `lib/features/inventory/domain/count_paste.dart` with `CountPaste`, `CountPasteRow`, `CountPasteProblem`, `CountPasteProblemKind` and the pure function `parseCountPaste(String text)`. Cases to cover:
  - tab, `;` and `,` separators (the first of tab, `;`, `,` found in the row);
  - a decimal comma with a tab or `;` separator ("4,5" → 4.5), and `.` as the decimal point;
  - `A-100,4,5` (three fields) reported as `fieldCount`, not guessed;
  - blank rows skipped but counted in row numbers (rows are 1-based);
  - missing code, non-numeric quantity (including a header row such as "Código / Cantidad"), negative quantity, more than 4 decimals;
  - a repeated code compared case-insensitively, reported on every repeat after the first;
  - 0 as a valid quantity, Windows line breaks, and `readCount` and `canSend`.
  Add `// simplified: thousands separators are not accepted, add a locale-aware reader if clerks paste "1,234.5".`

- [ ] T021 [US3] Create the paste dialog and its sender (research R8, ui-contract "Dialogs", wireframes "Pegar lista", depends on T003, T009, T020): `lib/features/inventory/presentation/counts/count_paste_dialog.dart`.
  - `CountPasteSender`: an auto-dispose notifier scoped to the dialog. It splits the good rows into chunks of 2,000 and sends them one at a time through the actions notifier's `setLines` with `CountLineInput.byCode`, publishing the batch number and rows sent. On a `inventory_count.batch_invalid` refusal it stops and maps each `ApiProblemPart` back to its row (`extra['index']` plus the batch offset), with the part's code as the reason. On any other refusal it stops with that `AppError`. In both cases it reports the rows applied (whole batches before the refused one).
  - `showCountPasteDialog`: a multi-line `TextField` that re-parses on every edit, "N filas leídas · M con problemas", the problem list with row numbers, and Enviar enabled only when `canSend`. While sending it shows a `LinearProgressIndicator` with "Lote k de n" and can't be dismissed. On a refusal it lists the rejected rows (code, row, reason), the applied count and the "pegar de nuevo es seguro" note. Closing re-fetches the count. Closing with pasted text that was not sent asks before discarding it (`hasUnsavedChanges`, spec edge case). If the dialog is torn down while a batch is in flight (the user navigates away), the sender's dispose calls `refresh()` on the detail controller, so the count shows the batches already applied (spec edge case "Paste interrupted").
  - Run build_runner.

- [ ] T022 [P] [US3] Create the quick-entry row (research R6, ui-contract "Detail screen", depends on T003, T009): `lib/features/inventory/presentation/counts/count_quick_entry.dart`. Two `TextField`s (keys `count_quick_entry_code`, `count_quick_entry_quantity`) and a Registrar button. Enter in Código moves to Cantidad; Enter in Cantidad submits. It looks up the trimmed code among the loaded lines (case-insensitively) to know whether the entry replaces, then calls `setLines` with one `CountLineInput.byCode`. On success it clears both fields, returns focus to Código and shows the feedback line (key `count_quick_entry_feedback`) with the old and new quantity and "(reemplazada)" when it replaced. On a refusal it keeps the values and shows the part's localized message inline. Owns its own controllers and focus nodes, so a rebuild from the detail never drops keystrokes (as `ProductSearchField` does). Quantity validation as in T014.

- [ ] T023 [US3] Wire both into the detail screen (depends on T017, T021, T022): in `inventory_count_detail_screen.dart`, add the quick-entry row (draft + update on 74) between the facts and the lines section, and Pegar lista (draft + update on 74) in the action area, before Agregar producto, opening `showCountPasteDialog`.

- [ ] T024 [US3] Test quick entry and paste (depends on T019, T023): create `test/widget/features/inventory/count_quick_entry_test.dart` and `count_paste_dialog_test.dart`, and add cases to the detail test.
  - Quick entry: the keyboard-only flow (Enter moves, Enter submits, focus returns), the feedback with and without "(reemplazada)", an unknown code keeps the values and shows "El producto no existe.", and the row is absent for a read-only user and on a completed count.
  - Paste dialog: the live counts and problem list, a header row reported as row 1 with Enviar disabled, a clean list sending, 2,500 rows going as two batches with progress, a refused second batch listing the code with its row number and "se aplicaron 2,000 de 2,500", a non-batch refusal (`lock.busy`) stopping with the banner, the dialog not dismissible while sending, and closing re-fetching the count.
  - Sender unit test in `test/unit/features/inventory/count_paste_sender_test.dart`: chunking at exactly 2,000, row mapping through `extra['index']` plus the batch offset, stopping after the first refusal, the refresh on dispose mid-send, and a 15,000-row paste sent as 8 batches (7 × 2,000 + 1,000) through a fake repository with every row applied (SC-007).
  - Paste dialog: closing with unsent text asks before discarding it.

**Checkpoint**: US3 works on its own on top of US2: a 15,000-row opening count can be pasted without entering a product by hand.

---

## Phase 6: User Story 4 — Review the warnings of a confirmed count (Priority: P2)

**Goal**: right after confirming, the supervisor sees which products were counted below what is reserved, and which were already corrected by another count. The warnings never block and are not shown as errors.

**Independent Test**: reserve stock of a product with an open order, count it below the reserved quantity and confirm: the band names the product with counted, reserved and available quantities. Confirm two counts of one warehouse with the same product, the later-started one last: its band names the product and the other count's folio. Leaving and reopening the count shows no band.

- [ ] T025 [US4] Create the notice provider and band (research R9, depends on T004, T003): `lib/features/inventory/presentation/counts/count_confirm_notice.dart` with `CountConfirmNotice`, an auto-dispose `@riverpod` family keyed by the count id holding `CountWarnings`, mirroring `ReceiptCostNotice`, and `CountWarningsBand`, a dismissible warning-tone band (not an `ErrorBanner`) with the two optional sections. Negative-available rows show the product code with counted, reserved and available through `formattersProvider`. Corrected-by-other rows show the product code and "conteo {serial}" as plain text, or "Borrador #{id}" if `serial` is null. Key `count_confirm_warnings`. Run build_runner.

- [ ] T026 [US4] Show the warnings after confirm (depends on T017, T025): in `inventory_count_detail_screen.dart`, after a successful `confirm`, store the outcome's non-empty warnings in `CountConfirmNotice(id)` (as the receipt screen's `_settled` does) and show `CountWarningsBand` above the lines; the ✕ clears the notice. A reload inside the screen keeps it, and leaving the count drops it.

- [ ] T027 [US4] Test the warnings (depends on T019, T026): create `test/widget/features/inventory/count_confirm_warnings_test.dart` and add cases to the detail test: both sections render with their figures, a confirm with no warnings shows no band, the band uses the warning tone and not the error banner, ✕ dismisses it, it survives `refresh()`, and it is gone after leaving and reopening the count. Unit test for `CountConfirmNotice` in `test/unit/features/inventory/count_confirm_notice_test.dart`.

---

## Phase 7: User Story 5 — Correct a draft's header, or drop it (Priority: P3)

**Goal**: on a draft, change the warehouse or the comment, or cancel the draft with nothing posted. A completed count offers neither.

**Independent Test**: as an administrator, change a draft's warehouse to one in another facility and edit the comment. After reopening, both changes are kept and Sucursal shows the new facility. Cancel another draft and check it shows Cancelado. Open a completed count: no header edit and no cancel.

- [ ] T028 [US5] Create the header dialog and the cancel prompt (spec FR-006, FR-014, depends on T003, T009, T014).
  - `lib/features/inventory/presentation/counts/count_header_dialog.dart`, mirroring `issue_header_dialog.dart`: Almacén is a picker with read on Warehouses (4), otherwise read-only text, using `inventoryWarehouseOptions` (own facility only for a non-administrator); Comentario (≤ 500, counter). Send only changed fields; cleared text sends an empty comment. `hasUnsavedChanges`, a busy flag, and refusals (the in-transit warehouse) in `FormErrorBanner` with the dialog staying open.
  - In `count_dialogs.dart`, add `showCancelCountDialog` ("Cancelar el borrador #{id}. No se modifica ninguna existencia."). There is no variant for completed counts, because they can't be cancelled.

- [ ] T029 [US5] Add Editar encabezado and Cancelar to the detail screen (depends on T017, T028): Editar encabezado, an `OutlinedButton` shown when `can(74, update)` and the count is a draft, opening `showCountHeaderDialog`, placed before Pegar lista in the action area. Cancelar, an `OutlinedButton` in the error tone, first in the action area, shown when `can(74, delete)` **and the count is a draft** (never on completed or cancelled counts), opening `showCancelCountDialog` then `cancel`. A refusal shows in the banner.

- [ ] T030 [US5] Test the header and cancel (depends on T019, T029): create `test/widget/features/inventory/count_header_dialog_test.dart` and add cases to the detail and dialogs tests: only changed fields are sent, a cleared comment, the 500-character limit, a non-administrator's own-facility options, read-only warehouse text without read on Warehouses, the in-transit refusal staying in the dialog; Editar encabezado and Cancelar absent on a completed and a cancelled count and without their rights; the cancel prompt wording; a cancelled draft showing Cancelado; and a stale `inventory_count.confirmed_cannot_cancel` refusal showing "Un conteo confirmado no se puede cancelar. Corrígelo con un conteo nuevo." and re-fetching.

---

## Phase 8: Polish & cross-cutting

- [ ] T031 [P] Live API test (depends on T009): `test/integration/inventory_counts_live_test.dart`, mirroring `inventory_issues_live_test.dart`, with fixtures discovered at runtime: two stockable products with stock in a warehouse that isn't in transit (read with `StockApi`), a non-stockable product, and, when one exists, a product reserved by an open sales order (skip the warning case when none). Read-only cases always run; the write cases only with `MBE_WRITE=true`:
  - list and get;
  - create a draft, set lines by id and by code, replace a line's quantity (one line stays), edit and remove a line, update the header;
  - a blind draft: `quantityOnHand` and `difference` are null (SC-003);
  - a batch with an unknown, a non-stockable and a repeated product: 422 `inventory_count.batch_invalid` with parts keyed by `index`, and nothing applied;
  - confirm: stock of each product equals the counted quantity (SC-002), lines carry on-hand and difference, and a zero difference posts nothing;
  - `include_uncounted` adds 0-quantity lines;
  - the warnings: a product counted below its reservation, and two counts of one warehouse (the other count's serial in `correctedByOtherCounts`);
  - cancel: a draft cancels, a completed count answers 409 `inventory_count.confirmed_cannot_cancel`;
  - an empty draft confirm (`no_lines`);
  - a final count restores the products' original quantities.
  Note in the file header which accounts it needs. No seeded non-administrator has rights on 74, so the non-administrator cases stay manual.

- [ ] T032 [P] Device test (quickstart.md, depends on T018, T029): `integration_test/inventory_counts_quickstart_test.dart`, mirroring `inventory_issues_quickstart_test.dart` and the macOS traps in memory (frame-stall watchdog, picker and back-button finders, `caffeinate -dimsu`). Walk quickstart steps 1 to 8 and 11 to 12 as the administrator. Run with `flutter test integration_test/inventory_counts_quickstart_test.dart -d macos --dart-define-from-file=.env`.

- [ ] T033 [P] Largest text level (quickstart step 13, depends on T024, T027): `test/widget/features/inventory/inventory_counts_large_text_test.dart`, mirroring `inventory_issues_large_text_test.dart`. At the largest text scale, the list, the detail with the quick-entry row, the lines table with Esperado and Diferencia, the warnings band and the paste dialog don't clip or scroll sideways at 1280 px.

- [ ] T034 Large-count timing (quickstart step 9, research R4, depends on T031): against the dev tenant, build a 15,000-row paste (or as many stockable products as the tenant has, recording the actual number; when it is under 15,000, SC-007 rests on T024's 15,000-row sender test and this task measures the largest count the tenant allows), apply it through the live test's repository in 2,000-row batches, and time one `updateLine` or one-item `setLines` on that count. Record the figure in the PR description. If it takes more than about 2 s, file an mbe-api issue asking for a lighter line-write response (not a patch from here, constitution §III) and link it. Cancel the draft afterward.

- [ ] T035 Final checks (depends on all previous tasks).
  - Run `flutter analyze` (no new warnings), `dart format` on the changed files only, and `flutter test test/unit/features/inventory test/widget/features/inventory test/unit/core/errors/catalog_coverage_test.dart test/unit/core/formatting_guard_test.dart test/unit/app/router/app_router_test.dart`.
  - Run the issues, receipts and transfers live tests (read-only) and the counts live test (read-only, then with `MBE_WRITE=true`).
  - Search `lib/features/inventory/presentation/counts/` for literal colours, sizes and spacing (§V), for `NumberFormat` and `toStringAsFixed`, for any display of `enum.name` or server message text (§III), and for any read of `quantityOnHand` or `difference` outside the completed-count branch (SC-003).
  - Check FR-020: no screen, nav entry or gate uses `SystemObject.inventoryAdjustments` (93) (`grep -rn inventoryAdjustments lib/`).
  - Check that no `core/widgets/` file or generated file was added or edited, and that no shipped receipts, issues or transfers file changed apart from the shared registration files.

- [ ] T036 Validate against the quickstart (depends on T035). Run the walkthrough in quickstart.md against the dev mbe-api. Time SC-001 (enter and confirm a 20-product count, under 4 minutes) and SC-008 (enter 20 products with the quick-entry row using only the keyboard or a scanner) and record both. Then check FR-019 by opening Salidas de almacén and Conteos físicos side by side: the column order, the filter drawer, the facts strip, the button order (Nuevo first, filters last) and the prompt wording must match, apart from the documented differences. Steps 14's non-administrator parts need an account with rights on 74 that isn't seeded, so list them as manual checks to track in a GitHub issue after merge, as 067–069 did. Record the result and any deviation in the PR description, with `Closes mictlanix/mbe-roadmap#65` under "Roadmap".

---

## Dependencies & execution order

- **Phase 1** (T001) first.
- **Phase 2**: T002, T003 and T004 can run in parallel (T002 and T003 both touch the ARB files, so do them one after the other if one person does both). Then T005 needs T004, T006 needs T003, T007 and T008 need T005, and T009 needs T005 and T008.
- **US1** (T010–T013) needs Phase 2. **US2** (T014–T019) needs US1's list, route and harness. **US3** (T020–T024) and **US4** (T025–T027) each need only US2's detail screen. T020 (the parser) has no dependency at all and can start as early as Phase 1. **US5** (T028–T030) needs US2's detail screen.
- T023, T026 and T029 all edit `inventory_count_detail_screen.dart`, and T014 and T028 both edit `count_dialogs.dart`: do those one after the other.
- **Polish** (T031–T033) can start once the code it covers exists, T034 needs the live test, and T035 and T036 come last.

### Parallel opportunities

- T002 ∥ T003 ∥ T004 (error messages, strings, entities), keeping the shared-ARB caution above.
- T006 ∥ T007 ∥ T008 once T005 is done (and T003 for T006).
- T015 ∥ T016 (two new dialog files).
- T020 ∥ T022 (the parser and the quick-entry row).
- T031 ∥ T032 ∥ T033 (three independent test files).
- Across stories: US3, US4 and US5 after US2.

## Implementation strategy

- **MVP**: Phase 1, Phase 2 and US1 + US2 (T001–T019). That delivers find, count, confirm and the read-only completed count with differences, and it is the most valuable increment. Day-to-day counts work with the product picker alone.
- **Increment 2**: US3 (quick entry and paste), which makes opening counts practical, and US4 (the warnings). Either order.
- **Increment 3**: US5 (header edits and cancelling drafts).
- **Then**: Polish, the live and device checks, the timing check and the quickstart.
- **Risks to watch**:
  - Every line write returns the whole count (research R4). T034 measures it, and the answer decides whether an mbe-api follow-up is needed.
  - Blind drafts (SC-003): T019, T031 and T035 each check that no on-hand figure leaks onto a draft.
  - The generated `Quantity2` type's wire form (T005): verify it against a live response before trusting string quantities.
