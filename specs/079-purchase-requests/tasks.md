---
description: "Task list for 079-purchase-requests"
---

# Tasks: Purchase Requests with Approval

**Input**: Design documents from `specs/079-purchase-requests/`

**Prerequisites**: plan.md, spec.md (with its Clarifications), research.md (R1–R14), data-model.md, contracts/ui-contract.md, contracts/repository.md, contracts/error-messages.md, quickstart.md, wireframes.md

**Tests**: The spec doesn't ask for a test suite as such, but the constitution's quality gates require tests. Test tasks sit inside each story, after the code they cover.

**Organization**: Grouped by user story (US1–US6, spec.md). US1 (create and submit) and US2 (approve and reject) are P1 and together are the MVP. US3 (find and follow) and US4 (correct and resubmit) are P2. US5 (mark lines) and US6 (cancel) are P3. Phase 2 holds what two or more stories share.

**One deviation from the spec's story order**: the only way to reach US1 is the list's "Nueva solicitud" button, so US1 builds the list screen's default view (table, pagination, the button). US3 then adds what makes the list searchable: the "Todas" switch, the filter drawer and the folio search.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: parallelizable (different files, no dependency on an incomplete task)
- **[Story]**: US1 create and submit · US2 approve and reject · US3 find and follow · US4 correct and resubmit · US5 mark lines · US6 cancel

## Cross-story notes

- **Shared files.** Do these sequentially, not in parallel:
  - `lib/features/purchases/presentation/requests/purchase_request_detail_screen.dart`: T018 (US1) creates it with the facts, the minimum band, the lines table with ✎ 🗑, Agregar producto and Enviar. T024 (US2) adds Aprobar and Rechazar, T027 (US3) adds the approver facts and the purchase-order column, T029 (US4) adds Editar encabezado, T031 (US5) makes the Comprar cells interactive, and T033 (US6) adds Cancelar. Every control is a nullable callback or a collection-`if`, so an absent right means the control is not in the tree.
  - `lib/features/purchases/presentation/requests/request_dialogs.dart`: T017 (US1) creates it with the remove-line and submit prompts, T023 (US2) adds the approve and reject dialogs, and T033 (US6) adds the cancel prompt.
  - `lib/features/purchases/presentation/requests/purchase_requests_list_screen.dart`: T012 (US1) creates it, and T026 (US3) adds the scope switch, the filters and the folio search.
  - `lib/app/router/app_router.dart` and `lib/core/navigation/nav_destinations.dart`: T013 (US1) adds the group, the requests branch and its gate; T018 (US1) adds the detail route; T022 (US2) adds the approval branch and its gate.
  - `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb`: T002 adds every key once. If a later task needs another, add it there and run `flutter gen-l10n`. Never hand-edit `lib/l10n/app_localizations*.dart`.
- **Generated code.** After editing a freezed or `@riverpod` file, run `dart run build_runner build --delete-conflicting-outputs` at the repo root. Never run two build_runner processes at once: tasks that both need it are not marked [P] against each other. No client regeneration is needed: `PurchaseRequestsApi` already has every operation this spec calls.
- **Formatting.** Format only the files you changed (`dart format <files>`). Never `dart format .`, and never format `lib/generated/`.
- **Quantities and dates** go through `formattersProvider` (constitution §V). No `NumberFormat`, no `toStringAsFixed`. Quantities are `Decimal`, never `double`; the wire carries them as strings.
- **Spacing tokens, not literals** (`Theme.of(context).spacing`). No automated guard catches a literal, so check it in review.
- **Never match or show server prose** (§III). Show refusals through `AppError.localizedMessage` / `ErrorBanner`, which build the text from the error's `code`. Recognition keys on the code. The server's `warnings` text is never shown (research R7).
- **Status names come from l10n**, never from `enum.name`.
- **Row icons (§VI document reading).** List rows have no icons; only draft line rows get ✎ and 🗑; queue rows get one ✓. This is intentional; see the Complexity Tracking row in plan.md. Don't add a row Edit icon or a View toggle.
- **Rights.** Every control follows the availability table in data-model.md. A missing right means the control is absent, never disabled (the one exception is "Aprobar seleccionadas" with nothing selected). Document the system-object code (PurchaseRequest = 86, PurchaseRequestApproval = 96, PurchasesOrders = 20, Warehouses = 4) in a comment where a route, nav entry or control is gated.
- **Simplifications.** Any shortcut carries a comment `// simplified: <ceiling>, <what to do when it binds>`.
- **Reuse, don't copy** (research R5). Import these from `lib/features/inventory/presentation/shared/` as they are, with no copy: `inventory_name_cells.dart` (`InventoryWarehouseName`, `InventoryFacilityName`, `InventoryEmployeeName`), `inventory_warehouse_options.dart` (`inventoryWarehouseScopeProvider`, `inventoryStartingWarehouseProvider`, `inventoryWarehouseOptions`) and `inventory_document_status_chip.dart` (for a purchase order's state). Read each file's API before using it.
- **Precedents to mirror**:
  - Document list, detail, actions and dialogs: `lib/features/inventory/presentation/receipts/` (spec 067): list screen and controller, detail screen and controller, `inventory_receipt_actions.dart`, `new_receipt_dialog.dart`, `receipt_dialogs.dart`, `receipt_warnings.dart` (the band), `receipt_header_dialog.dart` (the notes-clearing trap).
  - Approval queue: `lib/features/sales/presentation/delivery_order_approval/delivery_order_approval_screen.dart` and its `…_queue_controller.dart` (spec 062): no filter bar, the `primaryAction` ✓, the not-tappable-rows state, the empty state.
  - Checkbox column: `lib/features/sales/presentation/capture/advanced_search_screen.dart` (around line 163). **That checkbox is inert** (`IgnorePointer`, `onChanged: null`) because the row tap toggles the selection there. In the approval queue the row tap opens the detail, so the checkbox must be a live `Checkbox` with its own `onChanged`. T025 tests that tapping it does not navigate.
  - Repository with `_toAppError`: `lib/features/inventory/data/inventory_receipt_repository_impl.dart` and its test. Quantity wire setter: `lib/features/sales/data/wire_value_setters.dart`.
  - Widget harness: `test/widget/features/inventory/inventory_harness.dart`. Unit fixtures: `test/unit/features/inventory/inventory_receipt_fixtures.dart`.
- **Test-run traps**: never run the whole suite with the `.env` defines (they flip tests that expect no credentials); run live and device tests with `--dart-define-from-file=.env.settings --dart-define-from-file=.env` on their own. Device tests need `caffeinate -dims`.

---

## Phase 1: Setup

**Purpose**: a known-good baseline, so later failures are attributable.

- [ ] T001 Run `flutter analyze` and the existing tests this feature touches: `test/unit/core/errors/catalog_coverage_test.dart`, `test/unit/core/errors/resource_noun_test.dart`, `test/unit/app/router/app_router_test.dart`, `test/unit/core/navigation/nav_destinations_test.dart` and `test/unit/core/formatting_guard_test.dart`. Record any failure that predates this feature, so it isn't blamed on the new code.

---

## Phase 2: Foundational (blocks all user stories)

**Purpose**: the pieces two or more stories use: strings, error codes, entities and the minimum-quantity function, the repository, the status chip, the filter, the controllers and the availability rules.

- [ ] T002 Add every new string to `lib/l10n/app_es.arb` and `lib/l10n/app_en.arb`, then run `flutter gen-l10n`. Each key gets an `@key` description starting "spec 079". Check `app_es.arb` first and reuse existing keys (filters button, clear filters, apply, cancel, save, close, loading and error texts). Keys use the prefix `purchaseRequest…`; the wording is in contracts/ui-contract.md, research R11 and wireframes.md:
  - **Navigation and titles:** `navPurchasesGroup` ("Compras"), `navPurchaseRequests` ("Solicitudes de compra"), `navPurchaseRequestApproval` ("Aprobación de solicitudes"), `purchaseRequestTitle` (placeholder `folio`: "Solicitud {folio}"), `purchaseRequestTitleDraft` (placeholder `id`: "Solicitud · Borrador #{id}"), `purchaseRequestDraftFolio` (placeholder `id`: "Borrador #{id}").
  - **Status labels (4):** `purchaseRequestStatusDraft` ("Borrador"), `…Submitted` ("Enviada"), `…Approved` ("Aprobada"), `…Cancelled` ("Cancelada").
  - **List:** column headers (Folio, Sucursal, Almacén, Estado, Solicitó, Fecha, Partidas), the folio search hint, the facets (Mostrar with its choices "Mis solicitudes" and "Todas", Estado, Sucursal, Almacén, Solicitó, Fecha), the empty ("No tienes solicitudes de compra." and, for Todas, "No hay solicitudes de compra.") and filtered-empty ("Ninguna solicitud coincide con los filtros.") texts.
  - **Detail:** fact labels (Estado, Folio, Almacén, Sucursal, Notas, Solicitó, Aprobó), the lines table headers (Código, Producto, Cantidad, Destino, Comprar, Orden de compra), the empty-draft text ("Agrega los productos que necesitas."), the no-sucursal text ("Tu usuario no tiene una sucursal asignada.").
  - **Actions and dialogs:** `purchaseRequestNewAction` ("Nueva solicitud"), `…EditHeader`, `…AddProduct`, `…Submit` ("Enviar"), `…Cancel`, `…Approve`, `…Reject`, dialog titles and field labels (Almacén, Notas, Producto, Nombre, Cantidad, Destino, Motivo), the "mínimo {n}" helper, the "solo almacenes de {sucursal}" helper, and the submit (first and resubmit), approve, reject, cancel-draft, cancel and remove-line prompts, using research R11.
  - **Queue:** "Aprobar seleccionadas ({n})", the empty text ("No hay solicitudes pendientes de aprobación."), the single-approve SnackBar ("Solicitud {folio} aprobada."), the bulk SnackBar ("Se aprobaron {n} solicitudes."), and the result dialog ("Se aprobaron {a} de {n} solicitudes.", "No se aprobaron:").
  - **Warning:** the minimum line (placeholders `code`, `quantity`, `minimum`: "{code}: {quantity} es menos que el mínimo de compra ({minimum}).").
  - **Error messages:** the eleven keys in contracts/error-messages.md (T003 wires them).

- [ ] T003 [P] Localize the eleven new codes (contracts/error-messages.md, depends on T002).
  - In `lib/core/errors/localize_problem.dart`, add the generated `api.ErrorCode` members `purchaseRequestPeriodNotDraft`, `purchaseRequestPeriodNotSubmitted`, `purchaseRequestPeriodNoLines`, `purchaseRequestPeriodLineWithoutQuantity`, `purchaseRequestPeriodFacilityLocked`, `purchaseRequestPeriodWarehouseFacilityChanged`, `purchaseRequestPeriodAlreadyCancelled`, `purchaseRequestPeriodLinesOnLiveOrder`, `purchaseRequestPeriodLinesNotMarkable`, `purchaseRequestPeriodLineOnLiveOrder` and `productPeriodNotPurchasable` to `localizedErrorCodes` and to the `localizeProblem` switch. `lines_on_live_order` takes `count` (an ICU plural) and `product.not_purchasable` takes `product_code`; both go in `needParams`. Read the spelling of each member from `lib/generated/openapi/lib/src/model/error_code.dart` first.
  - In `test/unit/core/errors/problem_fixtures.dart`, add a fixture for each code, and add the two parameterized ones to `needParams` in `catalog_coverage_test.dart`.
  - In `specs/058-localized-api-errors/contracts/code-scope.tsv`, flip these eleven `code` rows from `OUT` to `IN` (the ten `purchase_request.*` rows and `product.not_purchasable`), setting `example_routes` to a purchase-request endpoint (for example `POST /purchase-requests/{}/submit`) and the note to "reachable from the Solicitudes de compra screens (spec 079)". Leave the `purchase_order.*` rows `OUT`.
  - Raise the `checked` count in `catalog_coverage_test.dart` by eleven (confirm the current value first; it is 214, so 225).
  - Run `flutter test test/unit/core/errors/`.

- [ ] T004 [P] Create the entities and the minimum-quantity function (data-model.md).
  - In `lib/features/purchases/domain/entities/purchase_request.dart` (freezed): `PurchaseRequestStatus` (`draft`, `submitted`, `approved`, `cancelled`), `PurchaseRequestSummary`, `PurchaseRequest`, `PurchaseRequestLine`, `PurchaseRequestPage` and `BulkApproveOutcome`, with the fields and derived values in data-model.md (`folioLabel`: the serial, or "Borrador #{id}" when it is null).
  - In `lib/features/purchases/domain/below_minimum.dart`: `BelowMinimum` and the pure `belowMinimum(lines)`: one entry per line where `minOrderQty != null && minOrderQty > 1 && quantity < minOrderQty`.
  - Add `test/unit/features/purchases/below_minimum_test.dart`: no minimum, a minimum of 0, a minimum of 1 (never warns), exactly at the minimum, below it, and two lines of one product.
  - Run build_runner.

- [ ] T005 Create the repository (contracts/repository.md, research R6 and R8, depends on T004).
  - In `lib/features/purchases/domain/repositories/purchase_request_repository.dart` declare every method in contracts/repository.md.
  - In `lib/features/purchases/data/purchase_request_repository_impl.dart`, implement them over the generated `PurchaseRequestsApi(dio, appSerializers)`, with `purchaseRequestRepositoryProvider`. Map `RequestStatus` to `PurchaseRequestStatus`, and a line's `DocumentStatus` to the shared `InventoryDocumentStatus` (a `paid` value is a mapping error, never guessed, as in 067); parse the wire quantity strings into `Decimal`; treat a null `lines` as empty; drop `warnings`. Build each `BulkApproveOutcome.problem` from the result's `code` and `params`.
  - Send the quantity as `Quantity6` with the setter pattern in `lib/features/sales/data/wire_value_setters.dart`.
  - `updateHeader` sends `warehouse` only when given. For `clearComment`, follow research R8: send an empty string; if the live check (T035) shows the client drops it, fall back to a raw `dio.put` with `{"comment": null}` deserialized with `appSerializers`. Leave a `// simplified:` comment naming the live check.
  - Create `test/unit/features/purchases/purchase_request_fixtures.dart` (builders for summaries, requests and lines) and `test/unit/features/purchases/purchase_request_repository_impl_test.dart`: the list params (`all`, each filter, `skip`, `limit`), the queue params, each status mapping, the quantity string on the wire, `updateHeader` sending only changed fields, `approveMany` returning approved and refused results (with a localizable problem), and a `DioException` becoming a coded `AppError`.

- [ ] T006 [P] Create the status chip (depends on T002, T004): `lib/features/purchases/presentation/requests/purchase_request_status_chip.dart` with `PurchaseRequestStatusChip` on `StatusChip<PurchaseRequestStatus>` (key `purchase_request_status_chip`), tones and icons from data-model.md, labels from l10n. Follow `lib/features/inventory/presentation/shared/inventory_document_status_chip.dart`. Add `test/widget/features/purchases/purchase_request_status_chip_test.dart`.

- [ ] T007 [P] Create the filter (research R9, depends on T004): `lib/features/purchases/presentation/requests/purchase_requests_filter.dart` (freezed), with `fromQuery(ListQuery)`, `toQuery`, `activeFilterCount`, `isNarrowed` and `cleared()`. Keys: `all` (bool), `status`, `facility`, `warehouse`, `creator`, `from`, `to`, `serial` and the page. `activeFilterCount` counts `all` when true, status, facility, warehouse, creator and the date range (as one); not `serial`, which is the search box (research R9). An unknown status value in the URL is ignored; a non-numeric `serial` is ignored. Add `test/unit/features/purchases/purchase_requests_filter_test.dart`: the round trip, the count (including `all`), `cleared()` keeping nothing, and the ignored values.

- [ ] T008 Create the list controller (depends on T005, T007): `lib/features/purchases/presentation/requests/purchase_requests_list_controller.dart`, an `AsyncNotifier` family keyed by the filter, 20 per page, page clamped with `fetchClampedPage`. The server orders newest first and decides the default scope; the client only sends `all` and the filters (spec FR-002). Add `test/unit/features/purchases/purchase_requests_list_controller_test.dart`: the filter reaching the repository, paging, and an error kept as an `AppError`.

- [ ] T009 Create the detail controller (depends on T005): `lib/features/purchases/presentation/requests/purchase_request_detail_controller.dart`, a `@riverpod` family keyed by the request id that loads it and exposes `refresh()` and `put(request)`. Add `test/unit/features/purchases/purchase_request_detail_controller_test.dart`: a load, a not-found error kept as an `AppError`, `refresh()` and `put()`.

- [ ] T010 Create the write controller (contracts/repository.md, research R11 and R13, depends on T005, T009): `lib/features/purchases/presentation/requests/purchase_request_actions.dart`, a `keepAlive` notifier with `create`, `updateHeader`, `addLine`, `updateLine`, `removeLine`, `submit`, `cancel`, `markLine`, `approve`, `approveMany` and `reject`.
  - Each returns `AppError?` (null on success), except `create` (also returns the new id) and `approveMany` (returns the list of outcomes, or an `AppError` for a whole-call failure). On success a method writes the returned request into `purchaseRequestDetailControllerProvider(id)` and invalidates the list family and the approval queue (the queue provider is created in T020; until then invalidate nothing for it and add the call in T020). `approveMany` invalidates both without writing a detail.
  - After a refusal with `purchase_request.not_draft`, `.not_submitted`, `.already_cancelled`, `.lines_not_markable`, `.warehouse_facility_changed` or `lock.busy`, the method refreshes the detail controller if it is loaded (spec edge case: concurrent decisions).
  - Add `test/unit/features/purchases/purchase_request_actions_test.dart`: each action's success and refusal, the invalidations, the new id from `create`, `approveMany` with mixed results, and the refresh after each of the six codes.

- [ ] T011 [P] Create the availability rules (data-model.md "Action availability", research R12, depends on T004): `lib/features/purchases/presentation/requests/purchase_request_availability.dart`, a pure class built from a request's `status` and `facilityId` (which both `PurchaseRequestSummary` and `PurchaseRequest` carry, so the detail and the queue rows use the same rules), an `AccessControlService` and the user's `facilityId`, exposing one getter per action (`canEditHeader`, `canAddLine`, `canEditLines`, `canSubmit`, `canCancel`, `canMarkLines`, `canApprove`, `canReject`, `canOpenFromQueue`, `canApproveFromQueue`). `own` is true for an administrator, a null request facility, or a facility equal to the user's. Add `test/unit/features/purchases/purchase_request_availability_test.dart`: a table-driven test over rights (86 read/create/update/delete, 96 update, 20 update), the four states and own/foreign facility, including that a cancelled request offers nothing and that approve, reject and marks ignore the facility.

---

## Phase 3: User Story 1 — Create and submit a request (Priority: P1) 🎯 MVP

**Goal**: a store employee opens Solicitudes de compra, creates a request, adds products, edits their quantities, names and destinations, and submits it. The request then shows its folio and is read-only.

**Independent Test**: as the non-administrator with rights on 86, create a request (starting on their point-of-sale warehouse), add two purchasable products, edit one line's quantity below its minimum (a warning appears) and its destination, then submit. The request shows a folio and Enviada with no edit actions. Submit an empty draft and check the Spanish reason.

- [ ] T012 [US1] Create the list screen's default view (ui-contract "Solicitudes de compra list", wireframes "Screen: Solicitudes de compra list", depends on T006, T008): `lib/features/purchases/presentation/requests/purchase_requests_list_screen.dart`. Declare `const purchaseRequestsPath = '/purchases/requests';` at the top of this file; later tasks import it.
  - Filter row: `CatalogFilterBar` whose actions slot holds the "Nueva solicitud" `FilledButton.icon` (create on 86 and read on Warehouses 4, per FR-006 and FR-025; wired in T014). No search, scope switch or filters button yet (T026).
  - Table: `DataTableView<PurchaseRequestSummary>` with the columns in order: Folio (right-aligned; the serial, or "Borrador #{id}"), Sucursal, Almacén, Estado (`PurchaseRequestStatusChip`), Solicitó, Fecha, Partidas (right-aligned). Names come from `InventoryFacilityName`, `InventoryWarehouseName` and `InventoryEmployeeName`. Row tap pushes `$purchaseRequestsPath/${id}` (route added in T018). No row icons.
  - `CatalogListStateView` for loading, empty (the "Mis solicitudes" text), and error with retry; `CatalogPagination`; the page lives in the URL through `ListQuery`. Dates through `formattersProvider`.

- [ ] T013 [US1] Add the navigation group and the requests branch (ui-contract "Routes and navigation", depends on T012).
  - In `lib/core/navigation/nav_destinations.dart`, add `NavBranch.purchaseRequests = 38` (confirm the next free index first; `commissions` is 37) and a new `NavGroup(id: 'purchases', label: navPurchasesGroup)` between the `inventory` and `finance` groups, with one destination for now, "Solicitudes de compra" (`Icons.assignment_outlined` / `Icons.assignment`, `PrivilegeGate(SystemObject.purchaseRequest, AccessRight.read)`).
  - In `lib/app/router/app_router.dart`, append the `StatefulShellBranch` at index 38 with `GoRoute(path: purchaseRequestsPath, builder: PurchaseRequestsListScreen(query: ListQuery.fromUri(state.uri)))`, and the `_routeGate` clause for the `/purchases/requests` prefix returning `PrivilegeGate(SystemObject.purchaseRequest, AccessRight.read)`.
  - Add the nav and router cases to `test/unit/app/router/app_router_test.dart` and `test/unit/core/navigation/nav_destinations_test.dart`: the group and entry appear with read on 86, are absent without it, and the URL is redirected to the home page.

- [ ] T014 [US1] Create the new-request dialog (research R6, spec FR-006 and FR-008, depends on T002, T010, and T012, whose file it edits): `lib/features/purchases/presentation/requests/new_request_dialog.dart` with `showNewRequestDialog`, wired to the list's "Nueva solicitud" button in T012's file (a one-line `onPressed`; do it here). A `CatalogEntityPicker<Warehouse>` over `inventoryWarehouseOptions` with `inventoryWarehouseScopeProvider`, starting at `inventoryStartingWarehouseProvider`; a notes field with `maxLength` 500; `hasUnsavedChanges`; a busy flag; refusals in `FormErrorBanner` (the dialog stays open). A non-administrator without a facility sees the no-sucursal text and no picker options. On success, `context.push` the new request's detail.

- [ ] T015 [P] [US1] Create the line dialogs (research R6, spec FR-010 to FR-014, depends on T002, T010):
  - `lib/features/purchases/presentation/requests/add_request_line_dialog.dart`: a product picker only (`CatalogEntityPicker<ProductListItem>` over `productRepositoryProvider.list(search:, status: EntityStatus.active, purchasable: true, limit: 10)`, shown with read on products). The server fills the name, quantity and destination. `hasUnsavedChanges` once a product is picked, a busy flag, and refusals in `FormErrorBanner` with the dialog staying open: `product.not_purchasable`, `warehouse.in_transit_location` (the line defaults to the header's warehouse) and `purchase_request.not_draft` among them (spec edge cases, FR-027).
  - `lib/features/purchases/presentation/requests/request_line_dialog.dart`: Nombre (≤ 250), Cantidad (through `fmt.field.quantity` / `parseQuantity`; greater than 0 and at most 2 decimals, with the "mínimo {n}" helper) and Destino (an unscoped warehouse picker, offering every warehouse). Prefilled, `hasUnsavedChanges`, a busy flag, refusals in `FormErrorBanner`. Send only the changed fields.

- [ ] T016 [P] [US1] Create the minimum band (research R7, depends on T004): `lib/features/purchases/presentation/requests/request_minimum_band.dart` with `RequestMinimumBand(belowMinimum:)`, a widget in the look of `ReceiptOverReceiptBand` (`lib/features/inventory/presentation/receipts/receipt_warnings.dart`: `tertiaryContainer`, `warning_amber`), one line per `BelowMinimum`, rendering nothing for an empty list. Add `test/widget/features/purchases/request_minimum_band_test.dart`.

- [ ] T017 [US1] Create the dialogs file (research R11, depends on T002, T010): `lib/features/purchases/presentation/requests/request_dialogs.dart`, built on `showResponsiveDialog`.
  - `showRemoveRequestLineDialog` ("Quitar {código} de la solicitud.").
  - `showSubmitRequestDialog`: for a request without a folio, "Enviar la solicitud a aprobación. Recibirá su folio y ya no se podrá editar."; for one with a folio (a rejected draft), "Volverá a aprobación con el folio {serial}." Both list the minimum warnings (`belowMinimum`) when there are any. Refusals in `FormErrorBanner`; both buttons disabled while submitting.

- [ ] T018 [US1] Create the detail screen and its route (ui-contract "Solicitud detail", wireframes "Screen: Solicitud detail", depends on T011, T014 to T017): `lib/features/purchases/presentation/requests/purchase_request_detail_screen.dart`.
  - Title "Solicitud {folio}" or "Solicitud · Borrador #{id}"; the AppBar has no actions. Header facts (`FactStripRow` in `ResponsiveFormGrid`): Estado (chip), Folio, Almacén, Sucursal, Notas, Solicitó with the date.
  - `RequestMinimumBand` for draft, submitted and approved requests.
  - Lines: `DataTableView<PurchaseRequestLine>` with Código, Producto, Cantidad, Destino and a read-only Comprar cell (a check or empty box). Draft rows for users who can edit get ✎ (`request_line_dialog`) and 🗑 (`showRemoveRequestLineDialog`) through `buildCatalogRowActions`. The empty draft shows "Agrega los productos que necesitas."
  - Action area (end-aligned `Wrap`): "Agregar producto" (outlined) and "Enviar" (filled, calls `showSubmitRequestDialog`), each from `purchase_request_availability.dart`.
  - `ErrorBanner` above the action area for refusals; loading spinner; not found or forbidden through the shared error view.
  - Add the detail `GoRoute` to `lib/app/router/app_router.dart`: a top-level route (outside the shell) at `'$purchaseRequestsPath/:requestId'` building `PurchaseRequestDetailScreen(requestId: int.tryParse(...))`, as the receipts detail does.

- [ ] T019 [US1] Test the list and the draft flow: create `test/widget/features/purchases/purchases_harness.dart` (a mocktail `MockPurchaseRequestRepository`, the warehouse, facility, employee and product providers overridden, and a signed-in user with configurable rights and facility, as in `inventory_harness.dart`), then:
  - `purchase_requests_list_screen_test.dart`: rows render with a never-submitted draft showing "Borrador #{id}", a numbered draft showing its folio, names resolved, "Nueva solicitud" present only with create on 86 and read on 4, the empty state, and a row tap pushing the detail.
  - `new_request_dialog_test.dart`: the warehouse starts at the point-of-sale warehouse; a non-administrator is offered only their facility's warehouses and starts empty when the point-of-sale warehouse is elsewhere; the notes limit; a refusal stays inside the dialog.
  - `request_line_dialogs_test.dart`: the add dialog asks only for the product, and a `product.not_purchasable` refusal shows its Spanish message inside the dialog, which stays open; the edit dialog refuses 0, a negative value and more than 2 decimals, shows the "mínimo {n}" helper, and sends only changed fields.
  - `purchase_request_detail_screen_test.dart`: the draft state (lines, ✎ 🗑, the band when below the minimum, Agregar producto and Enviar), the empty draft, the submit prompt (first submit and resubmit wording), a refusal in the banner, and a submitted request showing no edit actions.
  - Run them.

**Checkpoint**: US1 is demonstrable on its own: open the list, create a request, add and edit lines, submit it.

---

## Phase 4: User Story 2 — Approve or reject requests (Priority: P1) 🎯 MVP

**Goal**: a supervisor opens Aprobación de solicitudes, sees every facility's submitted requests, approves one, rejects one with a reason from its detail, or approves several at once.

**Independent Test**: as an administrator, approve one submitted request from its detail (it leaves the queue and shows the approver and time), reject another with a reason (it is a draft again, with its folio), and select three requests and approve them together, one of which was cancelled meanwhile (the result names it). As a user with 96 but not 86 read, check that approve works but rows don't open.

- [ ] T020 [US2] Create the queue controller and the selection (research R10, depends on T005, T010): `lib/features/purchases/presentation/approval/approval_queue_controller.dart`, an `AsyncNotifier` family keyed by `ApprovalQueueFilter` (`facilityId`, `pageIndex`; add this small freezed class in the same file), 20 per page with `fetchClampedPage`. `lib/features/purchases/presentation/approval/approval_selection.dart`: a `Set<int>` notifier with `toggle`, `selectAll(ids)`, `clear()` and `count`, which clears on page change, filter change and after any approval. Then update T010's actions to also invalidate the queue provider on every success and every stale refusal, and extend `test/unit/features/purchases/purchase_request_actions_test.dart` to assert that the queue is invalidated after `approve`, `reject`, `approveMany` and a stale refusal (spec FR-024). Add `test/unit/features/purchases/approval_queue_controller_test.dart` and `approval_selection_test.dart`.

- [ ] T021 [US2] Create the approval screen (ui-contract "Aprobación de solicitudes", wireframes "Screen: Aprobación de solicitudes", depends on T011, T020): `lib/features/purchases/presentation/approval/purchase_request_approval_screen.dart`. Declare `const purchaseRequestApprovalPath = '/purchases/request-approval';`.
  - Filter row: `CatalogFilterBar` with no search (the endpoint has none). Its actions slot holds the badged filters `IconButton.outlined(Icons.tune)`, opening `showCatalogFilterSheet` with one facet, Sucursal (a facility `CatalogEntityPicker`), and "Aprobar seleccionadas ({n})" (update on 96; disabled until something is selected). The facility picker MUST NOT sit inline in the row (constitution §VI, analysis finding C1). Without read on facilities there is no facet, so the filters button is left out.
  - Table: `DataTableView<PurchaseRequestSummary>` in the server's order. A leading checkbox column (with update on 96): `fixedWidth: 48`, a live `Checkbox` per row bound to the selection, and a tristate `Checkbox` in `DataTableColumn.header` for select-all on the page. Then Folio, Sucursal, Almacén, Solicitó, Fecha, Partidas, Notas (truncated with a tooltip), and the ✓ "Aprobar" row action as `primaryAction` of `buildCatalogRowActions` (update on 96). No Estado column and no row ✕.
  - Row tap pushes the detail only when `canOpenFromQueue` (read on 86); otherwise rows don't respond (no hover, no pointer).
  - With 96 read only (no update): no checkbox column, no ✓, no bulk button.
  - `CatalogListStateView`: empty "No hay solicitudes pendientes de aprobación." (with the shared "Limpiar filtros" when a facility is chosen), loading, error with retry. `CatalogPagination`. After an approval, an emptied page steps back one page.

- [ ] T022 [US2] Add the approval branch (depends on T021): in `lib/core/navigation/nav_destinations.dart`, add `NavBranch.purchaseRequestApproval = 39` and the second destination of the `purchases` group, "Aprobación de solicitudes" (`Icons.fact_check_outlined` / `Icons.fact_check`, `PrivilegeGate(SystemObject.purchaseRequestApproval, AccessRight.read)`); in `lib/app/router/app_router.dart`, append the branch at index 39 and the `_routeGate` clause for the `/purchases/request-approval` prefix (read on 96). Extend the router and navigation tests: the entry appears with read on 96 only, the group shows with either entry, and `/purchases/request-approval` redirects without the right.

- [ ] T023 [US2] Add the approval dialogs (research R10 and R11, depends on T010, T017):
  - In `lib/features/purchases/presentation/requests/request_dialogs.dart`: `showApproveRequestDialog` (folio, sucursal, almacén, partidas; "Aprobar" filled) and `showRejectRequestDialog` (a multi-line Motivo with `maxLength` 500, "Rechazar" disabled while the trimmed reason is empty, the note that the request returns to draft keeping its folio). Both disable their buttons while submitting and show refusals in `FormErrorBanner`; after a refusal with a stale code the dialog's button becomes "Cerrar".
  - `lib/features/purchases/presentation/approval/bulk_approve_result_dialog.dart`: `showBulkApproveResultDialog` ("Se aprobaron {a} de {n} solicitudes." and, for each refused request, its folio, facility and the localized reason of its problem). The folio and facility come from the summaries of the page the screen held before the call; keep them by id.
  - Wire the ✓ row action and the bulk button in T021's screen: single approve → `showApproveRequestDialog` then a SnackBar; bulk → one call, then a SnackBar when all succeeded and the result dialog when any was refused; the queue reloads and the selection clears either way.

- [ ] T024 [US2] Add Aprobar and Rechazar to the detail screen (depends on T018, T023): in `purchase_request_detail_screen.dart`, add "Rechazar" (outlined) and "Aprobar" (filled) to the action area for a submitted request, from `canReject` and `canApprove`. After either, the screen shows the returned request.

- [ ] T025 [US2] Test approval: `test/widget/features/purchases/purchase_request_approval_screen_test.dart` and additions to `purchase_request_detail_screen_test.dart` and the dialog tests.
  - Queue: rows in server order with no Estado column; the three rights variants (96 update + 86 read: checkboxes, ✓, tappable rows; 96 update only: checkboxes and ✓ but rows don't respond; 96 read only: none of them); selecting rows enables the bulk button and shows its count; select-all selects the page; **tapping a checkbox does not open the detail**; changing page clears the selection; the facility facet is reached through the filters button and its sheet (not inline in the row), counts in the badge, and is absent without read on facilities; the empty state.
  - Dialogs: the approve dialog; the reject dialog keeps "Rechazar" disabled for an empty or whitespace reason and sends the trimmed reason; a stale refusal turns the button into "Cerrar".
  - Bulk: all approved gives the SnackBar; one refused gives the result dialog naming its folio, facility and Spanish reason; the queue reloads.
  - Detail: Aprobar and Rechazar appear only for a submitted request and update on 96.
  - Run them.

**Checkpoint**: US1 and US2 together are the MVP: requests are created, submitted, and decided.

---

## Phase 5: User Story 3 — Find a request and follow it (Priority: P2)

**Goal**: a requester finds their requests (by default, their own without cancelled ones), widens to everyone's, filters and searches, and sees on a request who approved it and which purchase order holds each line.

**Independent Test**: as a non-administrator, open the list (only their non-cancelled requests); switch to Todas; filter by Aprobada and a facility; search a known folio; open an approved request and check the approver, the time and a line's purchase order.

- [ ] T026 [US3] Complete the list screen (research R9, wireframes "State: filter drawer open", depends on T012): in `purchase_requests_list_screen.dart`, add to the `CatalogFilterBar`: the numeric folio search (digits only, sent as `serial`) and the badged filters `IconButton.outlined(Icons.tune)` that opens `showCatalogFilterSheet` with `CurrentListQueryBuilder`. Nothing else goes in the row: §VI keeps facet controls out of it (analysis finding C2). The drawer holds Mostrar (two choice chips, "Mis solicitudes" by default and "Todas", which sets `all` and counts in the badge), Estado (single-select choice chips), and, each with read on its catalog, Sucursal, Almacén and Solicitó (`CatalogEntityPicker`s; the warehouse picker unscoped) and `DateRangeFilterChip` for `from`/`to`. Add the filtered-empty state with "Limpiar filtros" and the "Todas" empty text.

- [ ] T027 [US3] Add the approval and purchase-order facts to the detail (spec FR-009 and FR-015, depends on T018): in `purchase_request_detail_screen.dart`, add "Aprobó" with the approver's name (`InventoryEmployeeName`) and the approval time to the header facts when `approver` is set, and an "Orden de compra" column (the number, and `InventoryDocumentStatusChip` for its state) that appears only when any line has `purchaseOrderId`. It is text, not a link (research: no purchase-order screen yet).

- [ ] T028 [US3] Test: additions to `purchase_requests_list_screen_test.dart` (Mostrar → Todas in the drawer sends `all=true` and adds one to the badge; the filter row holds only the search, the filters button and "Nueva solicitud"; each facet reaches the repository; a folio search sends `serial`; the pickers appear only with read on their catalogs; the filtered-empty state clears) and to `purchase_request_detail_screen_test.dart` (an approved request shows its approver and time; a line on a purchase order shows its number and state; a request with no such line has no Orden de compra column). Run them.

---

## Phase 6: User Story 4 — Correct and resubmit a rejected request (Priority: P2)

**Goal**: a requester opens a request that was rejected (a draft that keeps its folio), changes its notes or its warehouse (within the same facility), edits lines, and submits it again under the same folio.

**Independent Test**: reject a submitted request, open it as its requester, edit a line and the notes, resubmit it, and check it is Enviada with the same folio and back in the queue. Change the draft's warehouse to another facility's: the server's refusal is shown.

- [ ] T029 [US4] Create the header dialog and its button (research R6 and R8, spec FR-007 and FR-008, depends on T018): `lib/features/purchases/presentation/requests/request_header_dialog.dart` with `showRequestHeaderDialog`. Almacén through the scoped picker (administrator: every warehouse; others: their facility); for a request that already has a folio add the helper "solo almacenes de {sucursal}". Notas with `maxLength` 500. Send `warehouse` only when it changed; clearing the notes sends an empty string (research R8, T005). `hasUnsavedChanges`, a busy flag, refusals in `FormErrorBanner` (`purchase_request.facility_locked` among them). Add "Editar encabezado" to the detail's action area, from `canEditHeader`.

- [ ] T030 [US4] Test: `test/widget/features/purchases/request_header_dialog_test.dart` (the scope per user kind; the helper for a numbered request; sends only changed fields; clearing the notes sends an empty string; the 500 limit; `facility_locked` shown in the dialog) and a resubmit flow in `purchase_request_detail_screen_test.dart` (a numbered draft shows its folio and the "Volverá a aprobación con el folio {serial}" prompt; after submit it shows Enviada with the same folio). Run them.

---

## Phase 7: User Story 5 — Mark lines for purchase (Priority: P3)

**Goal**: purchasing unmarks or re-marks a submitted or approved request's lines; a line on a live purchase order cannot be unmarked.

**Independent Test**: on an approved request, unmark a line and reopen the request: it stays unmarked. On a draft, the checkboxes are read-only. A refusal for a line on an order shows its Spanish reason.

- [ ] T031 [US5] Make the Comprar column interactive (research R11, spec FR-017, depends on T018): in `purchase_request_detail_screen.dart`, the Comprar cell is a live `Checkbox` when `canMarkLines` (update on 20, request submitted or approved), calls `markLine`, and is disabled while that line's call is in flight (one at a time per line); otherwise it stays read-only. A refusal appears in the banner. For `purchase_request.line_on_live_order`, the banner adds "Orden de compra {n}", found by looking up the refused `line_id` among the request's lines (presentation-side, like 067's "Producto:" line; the shared message stays generic).

- [ ] T032 [US5] Test: additions to `purchase_request_detail_screen_test.dart`: the checkbox is live only with update on 20 on a submitted or approved request; a tap calls `markLine` with the flipped value and shows the returned request; it is disabled while in flight; a `line_on_live_order` refusal shows the Spanish message with the order number; a draft and a cancelled request show it read-only. Run them.

---

## Phase 8: User Story 6 — Cancel a request (Priority: P3)

**Goal**: a user with the delete right cancels a draft, submitted or approved request; a request with a line on a live purchase order refuses.

**Independent Test**: cancel a draft and an approved request: both show Cancelada with no actions. A request with a line on a live order shows the server's Spanish reason and stays as it was.

- [ ] T033 [US6] Add Cancelar (depends on T017, T018): in `request_dialogs.dart`, `showCancelRequestDialog` ("Cancelar el borrador" for a draft, otherwise "Cancelar la solicitud {folio}: queda cancelada y ya no se podrá usar"; the confirm button "Cancelar solicitud"). In `purchase_request_detail_screen.dart`, add "Cancelar" (outlined, first in the action area) from `canCancel` (delete on 86, state draft, submitted or approved, own facility). `purchase_request.lines_on_live_order` shows its pluralized reason in the banner.

- [ ] T034 [US6] Test: dialog and detail tests: Cancelar appears only with delete on 86 on a live state and an own-facility request; both prompt wordings; success shows Cancelada with no actions; `lines_on_live_order` shows the singular and plural Spanish messages and leaves the request unchanged. Run them.

---

## Phase 9: Polish and cross-cutting

**Purpose**: live verification, the device walkthrough, text-size checks and the release notes.

- [ ] T035 Create `test/integration/purchase_requests_live_test.dart` (follow `test/integration/inventory_receipts_live_test.dart`; `--dart-define-from-file=.env.settings --dart-define-from-file=.env`; writes only with `MBE_WRITE=true`; accounts per the dev-tenant notes, with `tool/seed_test_accounts.py` after a DB reset). Discover its fixtures at runtime: an active purchasable product with `minOrderQty > 1`, a non-transit warehouse in the account's facility and one in another, and any request line with a purchase order (the "on a live order" cases are skipped when none exists). Read-only part: the list (default scope, `all=true`, each facet, the folio search) and the queue. Write part (quickstart steps 2–11): create, add lines (check the line's defaults), edit a quantity (check the string that went on the wire), clear the notes (record what the server stores), submit an empty one (`purchase_request.no_lines`), submit, approve, reject and resubmit (same serial), bulk approve with one stale id (one refused with `not_submitted`), mark and unmark, cancel. Record the answers it finds: the clearing of notes (R8), the quantity wire value, and whether the default scope omits cancelled requests but a `status=cancelled` filter shows them.

- [ ] T036 [P] Create `integration_test/purchase_requests_quickstart_test.dart` (follow `integration_test/inventory_receipts_quickstart_test.dart` and the macOS integration-test notes: the frame-stall watchdog, the login finder and the picker finders; run under `caffeinate -dims`). Cover quickstart steps 1–11 on a macOS device.

- [ ] T037 [P] Check the largest text level (constitution §V, quickstart step 14): add widget cases at the largest of the four text levels for the list, the lines table and the queue, asserting no overflow, following the pattern the earlier specs use (`grep -rn "textScale\|textScaler" test/widget/features`). Name the file `test/widget/features/purchases/purchases_large_text_test.dart`.

- [ ] T038 Run the quickstart (`specs/079-purchase-requests/quickstart.md`) against the dev backend, steps 1–14, and note each result. Mark which steps need a fixture that does not exist (a non-administrator with 86 rights in another facility; a request line on a live purchase order) and were skipped.

- [ ] T039 Final checks: `dart format` on only the changed files, `flutter analyze` (no new issues), `flutter test` for the whole suite **without** the `.env` defines (including `catalog_coverage_test.dart`, `formatting_guard_test.dart`, `app_router_test.dart` and `nav_destinations_test.dart`), and confirm no hand-edited generated files (`git status` shows no `lib/generated/` changes).

- [ ] T040 Record the release notes for the PR description: under "Roadmap", `Closes mictlanix/mbe-roadmap#69`; list what stays manual (the steps skipped in T038, the timed checks for SC-001 and SC-002 in quickstart steps 5 and 8, the largest-text check on a real device, and the live answers from T035); and name the follow-ups: mictlanix/mbe-api#352 (the latest rejection reason on the request, so the detail can show it) and mictlanix/mbe-roadmap#71 (purchase orders, which turns the order number on a line into a link and makes the live-order refusals reachable). Open a `[UI]` follow-up issue for the manual checks, as earlier specs did.

---

## Dependencies and execution order

- **Phase 1 → Phase 2 → stories.** T001 first. Phase 2 blocks every story.
- **Phase 2 order:** T002 first (strings). Then T003, T004 in parallel (T003 needs T002). T005 needs T004. T006 needs T002 and T004. T007 and T011 need T004. T008 needs T005 and T007. T009 needs T005. T010 needs T005 and T009.
- **Stories:** US1 (T012–T019) needs Phase 2. US2 (T020–T025) needs Phase 2 and US1's detail screen (T018, for T024) and dialogs file (T017, for T023). US3 (T026–T028) needs US1's list and detail screens (T012, T018). US4 (T029–T030), US5 (T031–T032) and US6 (T033–T034) each need US1's detail screen (T018); US6 also needs T017.
- **Shared files** (see the cross-story notes) mean the detail-screen tasks T018 → T024 → T027 → T029 → T031 → T033 run in that order, the dialogs-file tasks T017 → T023 → T033 in that order, and the router and navigation tasks T013 → T018 → T022 in that order. If the stories are split between people, agree that order.
- **Polish** needs every story it covers: T035 and T038 need US1–US6, T036 needs US1–US4.

### Parallel opportunities

- Phase 2: after T002, T003 and T004 can run at the same time. T006, T007 and T011 follow T004 and can run beside each other; they touch different files.
- Within US1: T015 and T016 are independent files and can run beside T012 and T013 (T015 depends on T010). T014 edits T012's list screen, so it follows T012. T017 follows T010.
- After T018: T029, T031 and T033's dialog work are different files and can be written in parallel, then their detail-screen edits applied in order. US3's T026 (list screen) is independent of those.
- Phase 9: T036 and T037 are parallel.

### Requirement coverage

| Requirement | Task |
|---|---|
| FR-001–FR-005 (list, folio, titles) | T012, T026, T018 |
| FR-006–FR-009 (header) | T014, T029, T027 |
| FR-010–FR-015 (lines, minimum warning, destination picker, PO reference) | T015, T016, T018, T027 |
| FR-016, FR-017, FR-018 (submit, mark, cancel) | T017–T018, T031, T033 |
| FR-019–FR-024 (queue, approve, reject, bulk) | T020–T025 |
| FR-025, FR-026 (rights, facility) | T011, T018, T021, T013, T022 |
| FR-027 (localized refusals) | T003 and every dialog task |
| FR-028, FR-029 (server response shown, Spanish and formatting) | T009, T010, T002 |

### Implementation strategy

1. **MVP:** Phase 1, Phase 2, US1 and US2. That creates, submits and decides requests.
2. **Next:** US3 (find and follow) and US4 (correct and resubmit), in either order.
3. **Last:** US5 (mark lines) and US6 (cancel), which are the least frequent actions.
4. After each story, run its tests and its slice of the quickstart before starting the next.
