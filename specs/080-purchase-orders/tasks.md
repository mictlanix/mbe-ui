---
description: "Task list for 080-purchase-orders"
---

# Tasks: Purchase Orders with Receipts, PDF and Email

**Input**: Design documents from `specs/080-purchase-orders/`

**Prerequisites**: plan.md, spec.md (with its Clarifications), research.md (R1–R18), data-model.md, contracts/ui-contract.md, contracts/repository.md, contracts/error-messages.md, quickstart.md, wireframes.md

**Tests**: The spec doesn't ask for a test suite as such, but the constitution's quality gates require tests. Test tasks sit inside each story, after the code they cover.

**Organization**: Grouped by user story (US1–US5, spec.md). US1 (Por comprar) and US2 (write and confirm) are P1 and together are the MVP. US3 (list and receiving progress) and US4 (print and email) are P2. US5 (edit and cancel a draft) is P3. Phase 2 holds what two or more stories share.

**Deviations from the spec's story order**: the order detail screen is where every story lands, so it grows story by story (v1 in US1 … v5 in US5; see the shared-files note). US1 ends on the detail (Crear orden opens the new order), so it builds a read-only draft view first. The only way to start an order by hand is the list's "Nueva orden" button, so US2 builds the list's default view (table, pagination, the button) and US3 adds what makes it searchable (the "Todas" switch, the filter drawer, the number search).

## Format: `[ID] [P?] [Story] Description`

- **[P]**: parallelizable (different files, no dependency on an incomplete task)
- **[Story]**: US1 Por comprar · US2 write and confirm · US3 list and receiving · US4 print and email · US5 edit and cancel

## Cross-story notes

- **Shared files.** Do these sequentially, not in parallel:
  - `lib/features/purchases/presentation/orders/purchase_order_detail_screen.dart`: T013 (US1) creates it read-only with the facts, totals, price-0 band and the draft lines table. T022 (US2) adds Agregar producto, Agregar solicitud, Confirmar and the Entradas section. T024 (US3) adds the confirmed columns. T029 (US4) adds Imprimir and Enviar por correo. T033 (US5) adds Editar encabezado, ✎ 🗑 and Cancelar orden. Every control is a nullable callback or a collection-`if`, so an absent right means the control is not in the tree.
  - `lib/features/purchases/presentation/orders/order_dialogs.dart`: T021 (US2) creates it with the confirm prompt, T032 (US5) adds the remove-line and cancel prompts.
  - `lib/features/purchases/presentation/orders/purchase_orders_list_screen.dart`: T017 (US2) creates it, T023 (US3) adds the scope switch, the filters and the number search.
  - `lib/app/router/app_router.dart` and `lib/core/navigation/nav_destinations.dart`: T015 (US1) adds branch 40, the detail route and the gates; T018 (US2) adds branch 41 and its gate.
  - `lib/features/purchases/presentation/requests/purchase_request_detail_screen.dart` and `lib/features/inventory/presentation/receipts/inventory_receipt_detail_screen.dart`: only T025 (US3) touches them, to render `PurchaseOrderLink`.
  - `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb`: T002 adds every key once. If a later task needs another, add it there and run `flutter gen-l10n`. Never hand-edit `lib/l10n/app_localizations*.dart`.
- **Generated code.** After editing a freezed or `@riverpod` file, run `dart run build_runner build --delete-conflicting-outputs` at the repo root. Never run two build_runner processes at once: tasks that both need it are not marked [P] against each other. No client regeneration is needed: `PurchaseOrdersApi` already has every operation this spec calls (mbe-api#353–#355 will need one later; they are not in this scope).
- **Formatting.** Format only the files you changed (`dart format <files>`). Never `dart format .`, and never format `lib/generated/`.
- **Quantities, prices and dates** go through `formattersProvider` (constitution §V). No `NumberFormat`, no `toStringAsFixed`. Quantities, prices and tax rates are `Decimal`, never `double`; the wire carries them as strings.
- **Spacing tokens, not literals** (`Theme.of(context).spacing`). No automated guard catches a literal, so check it in review.
- **Never match or show server prose** (§III). Show refusals through `AppError.localizedMessage` / `ErrorBanner`, which build the text from the error's `code`. Recognition keys on the code. The server's `warnings` and `skipped[].reason` text is never shown (research R10); `skipped` is used only for its length.
- **Status names come from l10n** (`InventoryDocumentStatusChip`), never from `enum.name`.
- **Row icons (§VI document reading).** List rows have no icons; only draft line rows get ✎ and 🗑. This is intentional; see the Complexity Tracking rows in plan.md. Don't add a row Edit icon or a View toggle.
- **Rights.** Every control follows the availability table in data-model.md. A missing right means the control is absent, never disabled (the one exception is Confirmar on a draft with no lines). Document the system-object code (PurchasesOrders = 20, InventoryReceipts = 15, PurchaseRequest = 86, Warehouses = 4) in a comment where a route, nav entry or control is gated.
- **Simplifications.** Any shortcut carries a comment `// simplified: <ceiling>, <what to do when it binds>`. The ones this plan already records: Por comprar has no search or pagination (mbe-api#354); the receipts section is empty on reload (mbe-api#355); no supplier-mismatch warning (mbe-api#353). Mark each with a comment naming its issue.
- **Precedents to mirror**:
  - Document list, detail, actions and dialogs: spec 079's `lib/features/purchases/presentation/requests/` (list screen, controller, filter, detail screen and controller, `purchase_request_actions.dart`, `purchase_request_availability.dart`, `new_request_dialog.dart`, `request_header_dialog.dart`, `request_line_dialog.dart`, `request_dialogs.dart`, `request_minimum_band.dart`) and its tests under `test/unit/features/purchases/` and `test/widget/features/purchases/` (use `purchases_harness.dart` and extend `purchase_request_fixtures.dart`'s style in a new `purchase_order_fixtures.dart`).
  - Name cells, warehouse options and the status chip: import as they are from `lib/features/inventory/presentation/shared/` (`inventory_name_cells.dart`, `inventory_warehouse_options.dart`, `inventory_document_status_chip.dart`). Read each file's API before using it.
  - Repository with `_toAppError`, `_page`, `_request` and the quantity wire setter: `lib/features/purchases/data/purchase_request_repository_impl.dart`, `lib/features/sales/data/wire_value_setters.dart`.
  - Cross-record link: `_OrderLink` in `lib/features/sales/presentation/payments/refund_detail_screen.dart` (~:598) and `orderLinkTargetProvider`; copy its look, not its provider.
  - Email dialog: `lib/features/sales/presentation/quotes/quote_email_dialog.dart` and `quote_email_controller.dart`; import `isPlausibleEmail`, `RecipientChip` and the 10-recipient limit from `lib/features/sales/domain/quote_email.dart`.
  - Printing: `DocumentRef`/`documentActionsProvider.preview`, example at `lib/features/invoicing/presentation/fiscal_document_detail_screen.dart` (~:252).
- **Test-run traps**: never run the whole suite with the `.env` defines (they flip tests that expect no credentials); run live and device tests with `--dart-define-from-file=.env.settings --dart-define-from-file=.env` on their own. Device tests need `caffeinate -dims`.

---

## Phase 1: Setup

**Purpose**: a known-good baseline, so later failures are attributable.

- [ ] T001 Run `flutter analyze` and the existing tests this feature touches: `test/unit/core/errors/catalog_coverage_test.dart`, `test/unit/core/errors/resource_noun_test.dart`, `test/unit/app/router/app_router_test.dart`, `test/unit/core/navigation/nav_destinations_test.dart`, `test/unit/core/documents/` and `test/unit/core/formatting_guard_test.dart`. Record any failure that predates this feature, so it isn't blamed on the new code.

---

## Phase 2: Foundational (blocks all user stories)

**Purpose**: the pieces two or more stories use: strings, error codes, entities, the repository, the order filter, the controllers, the availability rules and the request-folio lookup.

- [ ] T002 Add every new string to `lib/l10n/app_es.arb` and `lib/l10n/app_en.arb`, then run `flutter gen-l10n`. Each key gets an `@key` description starting "spec 080". Check `app_es.arb` first and reuse existing keys (filters button, clear filters, apply, cancel, save, close, loading and error texts, the three inventory document status labels, the quote email keys where the wording fits). Keys use the prefix `purchaseOrder…` (Por comprar: `toPurchase…`); the wording is in contracts/ui-contract.md, research R5–R14 and wireframes.md:
  - **Navigation and titles:** `navToPurchase` ("Por comprar"), `navPurchaseOrders` ("Órdenes de compra"), `purchaseOrderTitle` (placeholder `id`: "Orden de compra {id}").
  - **Por comprar:** the "Sin proveedor" group name, "{n} partidas" (ICU plural), "est. {total}", "Crear orden", "Actualizar", "Agrégalas a mano en una orden.", the column headers (Solicitud, Código, Producto, Cantidad, Almacén, Costo), "sin costo", the facility facet label, the empty text ("No hay partidas pendientes de comprar."), and the create SnackBar ("Orden {id} creada con {n} partidas.") plus its left-out sentence (" {k} partidas ya estaban en otra orden.", ICU plural).
  - **List:** column headers (Número, Proveedor, Estado, Entrega, Creó, Fecha, Partidas, Total), the number search hint, the facets (Mostrar with "Mis órdenes" and "Todas", Estado, Proveedor, Creó, Fecha), the empty ("No tienes órdenes de compra." and, for Todas, "No hay órdenes de compra.") and filtered-empty ("Ninguna orden coincide con los filtros.") texts, "Nueva orden".
  - **Detail:** fact labels (Estado, Proveedor, Entrega, Notas, Creó), the lines table headers (Código, Producto, Almacén, Cantidad, Precio, IVA, Importe, Recibido, Pendiente), "Sol. {serial}", the totals labels (Subtotal, IVA, Total), the empty-draft text ("Agrega productos o las partidas de una solicitud aprobada."), the Entradas section ("Entradas", "Entrada {id}", "{n} partidas", "Abrir").
  - **Actions and dialogs:** every action label (Editar encabezado, Agregar producto, Agregar solicitud, Confirmar, Cancelar orden, Imprimir, Enviar por correo, Quitar), dialog titles and field labels, "antes de IVA", the tax-rate option label ("{rate} %"), the confirm prompt ("Se crearán entradas en {warehouses}.", "Ya no se podrá editar."), the cancel prompt, the remove-line prompt, the add-request SnackBar ("Se agregaron {n} partidas." plus the left-out sentence), the confirmed SnackBar ("Orden confirmada; se crearon {n} entradas."), the Confirmar tooltip for a draft with no lines, and the email dialog and SnackBar ("Orden enviada a {n} destinatarios.", the message field, "0 / 1000").
  - **Warning:** the price-0 line (placeholders `code`, `name`: "{code} {name}: precio 0; no actualizará el costo.").
  - **Error messages:** the nine keys in contracts/error-messages.md (T003 wires them).

- [ ] T003 [P] Localize the nine new codes (contracts/error-messages.md, depends on T002).
  - In `lib/core/errors/localize_problem.dart`, add the generated `api.ErrorCode` members `purchaseOrderPeriodNoSupplier`, `purchaseOrderPeriodNoLines`, `purchaseOrderPeriodLineWithoutQuantity`, `purchaseOrderPeriodAlreadyCancelled`, `purchaseOrderPeriodConfirmedCannotCancel`, `purchaseOrderPeriodNotConfirmed`, `purchaseOrderPeriodNothingPending`, `purchaseOrderPeriodNothingToAdd` and `purchaseOrderPeriodRequestNotApproved` to `localizedErrorCodes` and to the `localizeProblem` switch. None of the messages uses the server's params.
  - In `test/unit/core/errors/problem_fixtures.dart`, add a fixture for each code.
  - In `specs/058-localized-api-errors/contracts/code-scope.tsv`, flip these nine `code` rows (lines ~191–199) from `OUT` to `IN`, setting `example_routes` to a purchase-order endpoint (for example `POST /purchase-orders/{}/confirm`) and the note to "reachable from the Órdenes de compra screens (spec 080)". Leave the `supplier_payment.*` rows `OUT`.
  - Raise the `checked` count in `catalog_coverage_test.dart` by nine (confirm the current value first; it is 225, so 234).
  - Run `flutter test test/unit/core/errors/`.

- [ ] T004 [P] Create the entities and the price-0 function (data-model.md, research R10).
  - In `lib/features/purchases/domain/entities/purchase_order.dart` (freezed): `PurchaseOrderSummary`, `PurchaseOrder`, `PurchaseOrderLine`, `OrderReceipt`, `ToPurchaseGroup`, `ToPurchaseLine`, `OrderEmailReceipt` and `typedef PurchaseOrderPage = CatalogPage<PurchaseOrderSummary>`, with the fields in data-model.md. The status is the existing `InventoryDocumentStatus`.
  - In `lib/features/purchases/domain/zero_price.dart`: the pure `zeroPriceLines(lines)` returning the lines whose `price` is zero.
  - Add `test/unit/features/purchases/zero_price_test.dart`: none, one, several, a tiny non-zero price (not flagged), and a cancelled order's lines (the function is state-blind; the screen decides when to show it).
  - Run build_runner.

- [ ] T005 Create the repository (contracts/repository.md, research R7 and R8, depends on T004).
  - In `lib/features/purchases/domain/repositories/purchase_order_repository.dart` declare every method in contracts/repository.md.
  - In `lib/features/purchases/data/purchase_order_repository_impl.dart`, implement them over the generated `PurchaseOrdersApi(dio, appSerializers)`, with `purchaseOrderRepositoryProvider`, reusing `_toAppError` as the request repository does. Map `DocumentStatus` to `InventoryDocumentStatus` (an unknown value is a mapping error, never guessed); parse the wire strings into `Decimal`; treat a null `lines`, `receipts` or `skipped` as empty; drop `warnings`; map `skipped` to a count only; map `GeneratedReceipt` to `OrderReceipt`.
  - Send quantity, price and tax rate with the setter pattern in `lib/features/sales/data/wire_value_setters.dart` (the generated types are `Quantity4`, `Quantity5`, `Price`, `TaxRate1`; add setters there if one is missing).
  - `updateHeader` sends `supplier` only when given. For `clearComment`, send an empty string. For `clearDate`, send an explicit `estimated_receipt_date: null`: if the generated serializer omits nulls, fall back to a raw `dio.put` with the JSON body deserialized with `appSerializers` (research R7; leave a `// simplified:` comment naming the live check, T036).
  - Create `test/unit/features/purchases/purchase_order_fixtures.dart` (builders for summaries, orders, lines, groups and receipts) and `test/unit/features/purchases/purchase_order_repository_impl_test.dart`: the list params (`all`, each filter, `id`, `skip`, `limit`), the to-purchase `facility` param, each status mapping, the decimal strings on the wire, `updateHeader` sending only changed fields (and the two clears), the `skipped` count, the receipts mapping, `createFromGroup` and `email` bodies, and a `DioException` becoming a coded `AppError`.

- [ ] T006 [P] Create the order filter (data-model.md, research R15, depends on T004): `lib/features/purchases/presentation/orders/purchase_orders_filter.dart` (freezed), with `fromQuery(ListQuery)`, `toQuery`, `activeFilterCount`, `isNarrowed` and `cleared()`. Keys: `all` (bool), `status`, `supplier`, `creator`, `from`, `to`, `q` (the order number) and the page. `activeFilterCount` counts `all` when true, status, supplier, creator and the date range (as one); not `q`, which is the search box. An unknown status value in the URL is ignored; a non-numeric `q` is kept for the box but sends no `id`. Add `test/unit/features/purchases/purchase_orders_filter_test.dart`: the round trip, the count, the bad status, the non-numeric `q`, and `cleared()`.

- [ ] T007 Create the detail controller (research R11, depends on T005): `lib/features/purchases/presentation/orders/purchase_order_detail_controller.dart`, a `@riverpod` family keyed by the order id whose state is the order plus the receipts from the last confirm (empty after a plain load, since `GET` returns none until mbe-api#355). It exposes `refresh()` (keeps nothing from before: a reload drops the receipts, as the server does) and `put(order)` (keeps the receipts already held unless the response carries some). Add `test/unit/features/purchases/purchase_order_detail_controller_test.dart`: a load, a not-found error kept as an `AppError`, `refresh()` dropping the receipts, `put()` keeping them, `put()` replacing them when the response has some.

- [ ] T008 Create the write controller (contracts/repository.md, research R17, depends on T005, T007): `lib/features/purchases/presentation/orders/purchase_order_actions.dart`, a `keepAlive` notifier with `create`, `createFromGroup`, `updateHeader`, `addLine`, `updateLine`, `removeLine`, `addRequestLines`, `confirm` and `cancel`.
  - Each returns `AppError?` (null on success), except `create` and `createFromGroup` (also return the new id and the `skipped` count) and `addRequestLines` (also returns the number added and the `skipped` count). On success a method writes the returned order into `purchaseOrderDetailControllerProvider(id)` and invalidates the orders list family and the Por comprar provider (created in T011; until then invalidate nothing for it and add the call in T011). `confirm` and `cancel` also invalidate the list.
  - After a refusal with `purchase_order.already_cancelled`, `.confirmed_cannot_cancel`, `.not_confirmed`, `document.not_editable` or `lock.busy`, the method refreshes the detail controller if it is loaded (spec edge case: concurrent confirm).
  - Add `test/unit/features/purchases/purchase_order_actions_test.dart`: each action's success and refusal, the invalidations, the ids and counts returned, the receipts kept after `confirm`, and the refresh after each of the five codes.

- [ ] T009 [P] Create the availability rules (data-model.md "Action availability", depends on T004): `lib/features/purchases/presentation/orders/purchase_order_availability.dart`, a pure class built from an order's `status` and an `AccessControlService`, exposing one getter per action (`canCreate`, `canEditHeader`, `canAddLine`, `canAddRequestLines`, `canEditLines`, `canConfirm` (and `confirmNeedsLines`), `canCancel`, `canPrint`, `canEmail`, `canOpenReceipt`, `canCreateFromGroup`). No facility rule (FR-003). Absent, never disabled, except `confirmNeedsLines` which the screen turns into a disabled Confirmar with a tooltip. Add `test/unit/features/purchases/purchase_order_availability_test.dart`: every action across draft, confirmed and cancelled, with and without each right (20 read/create/update/delete, 15 read, suppliers, products, warehouses, 86 read).

- [ ] T010 [P] Create the request-folio lookup (research R8): `lib/features/purchases/presentation/orders/purchase_request_serial.dart`, a `FutureProvider.family<int?, int>` over `purchaseRequestRepositoryProvider.get(id)` returning the request's `serial`, cached for the session. A failure (for example no read on 86) resolves to null so the cell shows `#id`. Add `test/unit/features/purchases/purchase_request_serial_test.dart`: a serial, a null serial (an unsubmitted draft), a failure, and one `get` for two lookups of the same id.

**Checkpoint**: Run `flutter test test/unit/features/purchases test/unit/core/errors`.

---

## Phase 3: User Story 1 — Order the pending request lines by supplier (Priority: P1) 🎯 MVP

**Goal**: A buyer sees the pending lines grouped by supplier and facility and turns a supplier group into a draft order in one step, landing on it.

**Independent Test** (quickstart steps 1–3): with an approved request whose lines are marked, open Por comprar, create the order for its group, and check that the draft holds those lines priced at cost and that the group is gone from Por comprar.

- [ ] T011 [US1] Create the Por comprar filter and controller (research R5, depends on T005): `lib/features/purchases/presentation/to_purchase/to_purchase_filter.dart` (freezed, one facet: `facility`, in the URL, `activeFilterCount` 0 or 1) and `to_purchase_controller.dart` (an `AsyncNotifier` family keyed by the filter, no paging, `// simplified: no search or pagination until mictlanix/mbe-api#354`). Then, in `purchase_order_actions.dart`, add the Por comprar invalidation to every action that changes pending lines (T008's note). Add `test/unit/features/purchases/to_purchase_controller_test.dart`: the facility reaching the repository, the groups kept in the server's order, an error kept as an `AppError`, and the invalidation after `createFromGroup` and `cancel`.

- [ ] T012 [P] [US1] Create the warnings band (research R10, depends on T004): `lib/features/purchases/presentation/orders/order_warnings_band.dart`, a feature-local `OrderWarningsBand({required List<PurchaseOrderLine> zeroPriceLines})` on theme tokens, copying `request_minimum_band.dart`'s look (`tertiaryContainer`, `warning_amber`), one line per product with the T002 text, nothing when the list is empty. Add `test/widget/features/purchases/order_warnings_band_test.dart`.

- [ ] T013 [US1] Create the detail screen, read-only (contracts/ui-contract.md "Orden de compra detail", depends on T007, T009, T010, T012): `lib/features/purchases/presentation/orders/purchase_order_detail_screen.dart` (`PurchaseOrderDetailScreen(orderId)`, `purchaseOrdersPath = '/purchases/orders'` declared in the list screen's file in T017; until then declare the constant here and move it in T017). Show the title, the facts (`InventoryDocumentStatusChip`, supplier, delivery date, notes, creator with `InventoryEmployeeName`, creation date) in a `ResponsiveFormGrid` of `FactStripRow`s, the totals band (Subtotal, IVA, Total), the price-0 band for a draft, and the lines table in the draft columns (Código, Producto with "Sol. {serial}" under it for a line from a request, Almacén with `InventoryWarehouseName`, Cantidad, Precio, IVA, Importe) in a `DataTableView`. Loading, not found and error use the shared views. No actions yet (the action area is added in T022). Add `test/widget/features/purchases/purchase_order_detail_screen_test.dart`: a draft with lines, the price-0 band, the folio on a request line, an empty draft, loading and error.

- [ ] T014 [US1] Create the Por comprar screen (contracts/ui-contract.md "Por comprar", research R5, depends on T011, T009): `lib/features/purchases/presentation/to_purchase/to_purchase_screen.dart` (`toPurchasePath = '/purchases/to-purchase'`). A `CatalogFilterBar` with no search, the badged filters button (only with read on facilities) opening a drawer with the Sucursal picker, and "Actualizar". Below it, one card per group: supplier name or "Sin proveedor", `InventoryFacilityName`, line count, estimated total, and "Crear orden" (an `OutlinedButton`, only on a group with a supplier and with create on 20); the body, shown when expanded (collapsed by default, expanded when there is a single group), is a `DataTableView<ToPurchaseLine>` (Solicitud, Código, Producto, Cantidad, Almacén, Costo or "sin costo"). A "Sin proveedor" group shows "Agrégalas a mano en una orden." and no button. Crear orden calls `createFromGroup`, pushes the new order, and shows the SnackBar (created count plus the left-out sentence when `skipped > 0`); a refusal shows in a dialog banner or SnackBar from its code. Loading, empty, filtered-empty and error use `CatalogListStateView`. Add `test/widget/features/purchases/to_purchase_screen_test.dart`: groups with totals, "sin costo", the no-supplier group without a button, no button without create on 20, the facility facet present or absent by right, create success with and without skipped lines, a refusal, empty and error.

- [ ] T015 [US1] Wire Por comprar and the detail into the app (research R1, depends on T013, T014): in `lib/core/navigation/nav_destinations.dart` add `NavBranch.toPurchase = 40` and a "Por comprar" destination (`Icons.shopping_cart_outlined`/`shopping_cart`, gate `PrivilegeGate(SystemObject.purchasesOrders, AccessRight.read)`) to the `purchases` group after Aprobación de solicitudes; in `lib/app/router/app_router.dart` append the shell branch 40 (`ToPurchaseScreen(query: ListQuery.fromUri(state.uri))`), add the top-level `GoRoute` `'$purchaseOrdersPath/:orderId'` outside the shell (`PurchaseOrderDetailScreen(orderId: int.tryParse(...))`, like requests), and add `_routeGate` clauses for `toPurchasePath` and `purchaseOrdersPath` (read 20). Update `test/unit/core/navigation/nav_destinations_test.dart` and `test/unit/app/router/app_router_test.dart`: the new destination and its order, the gate, the redirect without the right, and `/purchases/orders/:id` not being shadowed by `/purchases/requests`.

**Checkpoint**: US1 works alone: Por comprar lists groups, Crear orden opens a read-only draft. Run `flutter test test/unit/features/purchases test/widget/features/purchases test/unit/core/navigation test/unit/app/router`, then quickstart steps 1–3.

---

## Phase 4: User Story 2 — Write and confirm an order (Priority: P1) 🎯 MVP

**Goal**: A buyer starts an order by hand, adds products or a request's lines, reviews the totals and confirms; confirming creates the receipts and the order lists them.

**Independent Test** (quickstart steps 4, 6–8): create an order by hand with lines for two warehouses, confirm it, and check that it shows as confirmed with two linked draft receipts, each holding its warehouse's stockable lines.

- [ ] T016 [P] [US2] Create the new-order dialog (research R6, depends on T008): `lib/features/purchases/presentation/orders/new_order_dialog.dart`. A `ResponsiveDialog` with the supplier (`CatalogEntityPicker<SupplierListItem>`, required, `'{code} — {name}'`), the estimated receipt date (`showDatePicker`, `firstDate` today, optional) and notes (`maxLength` 500). `create` then `context.push` the new order's detail; refusals in `FormErrorBanner`; both buttons disabled while submitting. Add `test/widget/features/purchases/new_order_dialog_test.dart`: the required supplier, the date floor, the notes limit, success pushing the detail, and a refusal.

- [ ] T017 [US2] Create the list controller and the list screen's default view (contracts/ui-contract.md "Órdenes de compra list", research R15, depends on T006, T005, T009): `lib/features/purchases/presentation/orders/purchase_orders_list_controller.dart` (an `AsyncNotifier` family keyed by the filter, 20 per page, `fetchClampedPage`; the server decides the default scope and order, the client only sends `all` and the filters) and `purchase_orders_list_screen.dart` (declare `purchaseOrdersPath` here and remove it from the detail screen). A `CatalogFilterBar` with the number search and "Nueva orden" (create 20 and read suppliers), a `DataTableView` (Número, Proveedor truncated with a tooltip, Estado chip, Entrega, Creó via `InventoryEmployeeName`, Fecha, Partidas, Total never truncated), `CatalogPagination`, and `CatalogListStateView` states. Row tap pushes the detail; no row icons. The filters button and drawer are added in T023. Add `test/unit/features/purchases/purchase_orders_list_controller_test.dart` (filter reaching the repository, paging, an error kept) and `test/widget/features/purchases/purchase_orders_list_screen_test.dart`: rows and columns, Nueva orden present or absent by right, row tap, empty and error.

- [ ] T018 [US2] Wire the list into the app (depends on T017): in `lib/core/navigation/nav_destinations.dart` add `NavBranch.purchaseOrders = 41` and an "Órdenes de compra" destination (`Icons.receipt_long_outlined`/`receipt_long`, read 20) after Por comprar; in `lib/app/router/app_router.dart` append the shell branch 41 (`PurchaseOrdersListScreen(query: ListQuery.fromUri(state.uri))`). Update the nav and router tests from T015 for the new destination and branch (a gap-free positional index check).

- [ ] T019 [P] [US2] Create the add-product dialog (research R8, depends on T008): `lib/features/purchases/presentation/orders/add_order_line_dialog.dart`. A product picker (`CatalogEntityPicker<ProductListItem>` over `productRepositoryProvider.list(search:, status: EntityStatus.active, purchasable: true, limit: 10)`, copy `add_request_line_dialog.dart`) and a quantity field (`parseQuantity`, > 0, ≤ 4 decimals, default 1). Warehouse, price and tax rate come from the server's defaults. `addLine`; refusals (not purchasable, warehouse required, in transit) in `FormErrorBanner`. Add `test/widget/features/purchases/add_order_line_dialog_test.dart`: the picker filter, the quantity validation (0, 1.23456), success, and a refusal.

- [ ] T020 [P] [US2] Create the add-request-lines dialog (research R9, depends on T008): `lib/features/purchases/presentation/orders/add_request_lines_dialog.dart`. A `CatalogEntityPicker<PurchaseRequestSummary>` over `purchaseRequestRepositoryProvider.list(status: PurchaseRequestStatus.approved, all: true, serial: int.tryParse(search), skip: 0, limit: 10)`, options "{serial} · {facility} · {warehouse}" (names via the cached lookups; read on 86 needed). `addRequestLines`, then a SnackBar "Se agregaron {n} partidas." plus the left-out sentence when `skipped > 0`; `nothing_to_add` and `request_not_approved` show in the dialog banner. Add `test/widget/features/purchases/add_request_lines_dialog_test.dart`: the picker query, success with and without skipped lines, the two refusals.

- [ ] T021 [US2] Create the confirm prompt and the receipts section (research R11, depends on T008, T004): `lib/features/purchases/presentation/orders/order_dialogs.dart` with `showConfirmOrderDialog(order)`: supplier, line count, total, "Se crearán entradas en {warehouses}." (the distinct destination warehouses by name), the price-0 lines when any, and "Ya no se podrá editar."; and `order_receipts_section.dart` with `OrderReceiptsSection(receipts)`: one row per receipt (`RecordIdText`, `InventoryWarehouseName`, `InventoryFacilityName`, "{n} partidas", an "Abrir" button pushing `'$inventoryReceiptsPath/$id'` only with read on 15; `// simplified: no state chip until mictlanix/mbe-api#355`). Nothing renders for an empty list. Add `test/widget/features/purchases/order_dialogs_test.dart` and `order_receipts_section_test.dart`: the prompt with and without price-0 lines, the warehouses named once each, the section's rows, "Abrir" present or absent by right, the empty case.

- [ ] T022 [US2] Add the draft actions and Confirmar to the detail screen (spec FR-013, FR-017, FR-021, FR-022, depends on T013, T019, T020, T021): in `purchase_order_detail_screen.dart` add the action area (a `Wrap`, filled Confirmar last): "Agregar solicitud" (update 20 and read 86), "Agregar producto" (update 20 and read products) and "Confirmar" (update 20, disabled with the tooltip while there are no lines). Confirmar opens the prompt; on success a SnackBar "Orden confirmada; se crearon {n} entradas." and `OrderReceiptsSection` shows the confirm response's receipts. Show refusals in an `ErrorBanner` above the action area; a stale code makes the detail re-fetch (T008). Extend `purchase_order_detail_screen_test.dart`: each control present or absent by right and state, Confirmar disabled on an empty draft, the confirm flow with receipts shown, a refusal (`no_supplier`, `line_without_quantity`) in the banner, and a stale-state reload.

**Checkpoint**: US1 and US2 work: orders can be started and confirmed. Run `flutter test test/unit/features/purchases test/widget/features/purchases`, then quickstart steps 4, 6–8.

---

## Phase 5: User Story 3 — Find an order and follow its receiving (Priority: P2)

**Goal**: A buyer filters the list by state, supplier, creator, date and number, switches to everyone's orders, and sees what each confirmed order has received and still has pending; the request and receipt screens link back to the order.

**Independent Test** (quickstart steps 9, 12): with two confirmed orders, one partly received, filter the list by supplier, open the partly received one and check the received and pending quantities against its confirmed receipts.

- [ ] T023 [US3] Add the filters to the list (research R15, FR-004, FR-005, depends on T017): in `purchase_orders_list_screen.dart` add the badged filters button to the filter row and its drawer (`showCatalogFilterSheet`): Mostrar ("Mis órdenes" default, "Todas", counted in the badge), Estado (Borrador, Confirmada, Cancelada), Proveedor and Creó (`CatalogEntityPicker`s, each only with read on its catalog), Fecha (`DateRangeFilterChip`). "Limpiar filtros" on the filtered-empty state. Extend `purchase_orders_list_screen_test.dart` and `purchase_orders_filter_test.dart`: each facet reaching the query, the badge count, the scope switch, a facet absent without its read right, the number search, and clearing.

- [ ] T024 [US3] Add the confirmed columns to the detail screen (research R8, FR-023, depends on T013): in `purchase_order_detail_screen.dart`, a confirmed order's lines table swaps Precio and IVA for Recibido and Pendiente ("—" when null, a non-stockable line); draft and cancelled keep the draft columns. Extend `purchase_order_detail_screen_test.dart`: a confirmed order partly received (received and pending figures), a non-stockable line showing "—", and a cancelled order keeping the draft columns read-only with its lines.

- [ ] T025 [P] [US3] Link the order number from existing screens (research R16, FR-030, depends on T009): create `lib/features/purchases/presentation/orders/purchase_order_link.dart` with `PurchaseOrderLink(orderId)`: a compact `TextButton` (padding zero, shrink-wrapped, start-aligned) pushing `'$purchaseOrdersPath/$orderId'` when `can(purchasesOrders, read)`, else `RecordIdText('$orderId')`. In `purchase_request_detail_screen.dart` (the order column, ~:661–682) render it before the existing chip, replacing the "Text, not a link" comment; in `inventory_receipt_detail_screen.dart` (the "Orden de compra" fact, ~:464–470) render it instead of the plain `Text`. Add `test/widget/features/purchases/purchase_order_link_test.dart` (link with the right, text without it, the push target) and extend `purchase_request_detail_screen_test.dart` and `test/widget/features/inventory/inventory_receipt_detail_screen_test.dart` for the link and its fallback.

**Checkpoint**: Run `flutter test test/unit/features/purchases test/widget/features/purchases test/widget/features/inventory`, then quickstart steps 9, 12, 13.

---

## Phase 6: User Story 4 — Print and email a confirmed order (Priority: P2)

**Goal**: A buyer prints a confirmed order's PDF and emails it to the supplier's contacts.

**Independent Test** (quickstart step 10): print a confirmed order and check the PDF opens; email it to one address and check the success message; try a draft and check neither action is offered.

- [ ] T026 [P] [US4] Add the print document kind (research R13, depends on T001): in `lib/core/documents/domain/document_kind.dart` add `purchaseOrder(SystemObject.purchasesOrders)` with a doc comment (`GET /purchase-orders/{id}/document`, a draft or cancelled order is a 409 `purchase_order.not_confirmed`, so call sites offer it only for a confirmed one) and the fallback `'orden-compra-${_pad(recordId, 8)}.pdf'`; in `lib/core/documents/data/document_source_impl.dart` add the arm calling `PurchaseOrdersApi.printPurchaseOrderDocumentApiV1PurchaseOrdersOrderIdDocumentGet(orderId: ref.recordId)` (mirror the `salesQuote` arm; add the `PurchaseOrdersApi` field). Extend `test/unit/core/documents/document_source_impl_test.dart` (the arm and the request path) and `document_actions_test.dart` (the gate: a reader of 20 can open it, a reader of sales quotes cannot).

- [ ] T027 [US4] Create the email controller (research R14, depends on T005): `lib/features/purchases/presentation/orders/purchase_order_email_controller.dart`, a family on the order id. State: the recipient chips (typed and suggested), the message, the sending flag and the failure. Reuse `isPlausibleEmail`, `RecipientChip` and `quoteEmailMaxRecipients` from `lib/features/sales/domain/quote_email.dart`. Suggestions: `supplierRepositoryProvider.get(supplierId:)` → `Supplier.contacts` with an email (needs read on suppliers; none otherwise, a failure leaves typing working). `send` returns the `OrderEmailReceipt` or an `AppError`; recognition keys on the error code (`email.send_failed`, `email.not_configured`, `purchase_order.not_confirmed`), never on the status. Add `test/unit/features/purchases/purchase_order_email_controller_test.dart`: seeding from contacts, adding and removing, the limit of 10, an invalid address, the message passed through, and each failure.

- [ ] T028 [US4] Create the email dialog (depends on T027): `lib/features/purchases/presentation/orders/purchase_order_email_dialog.dart` with `showPurchaseOrderEmailDialog(context, order)`: the chip input and suggestions laid out as `quote_email_dialog.dart`, a message field (`maxLength` 1000, counter), "Enviar"/"Cancelar". Refusals show in a `FormErrorBanner` keeping the input; success closes with the SnackBar "Orden enviada a {n} destinatarios.". Add `test/widget/features/purchases/purchase_order_email_dialog_test.dart`: suggestions shown, a typed address, the limit hint, the message counter, success, and the three refusals keeping the input.

- [ ] T029 [US4] Add Imprimir and Enviar por correo to the detail screen (FR-026, FR-027, depends on T022, T026, T028): in `purchase_order_detail_screen.dart`, for a confirmed order, "Imprimir" (read 20) calling `documentActionsProvider.preview(context, DocumentRef(kind: DocumentKind.purchaseOrder, recordId: id, title: <"Orden de compra {id}">))` and "Enviar por correo" (update 20) opening the dialog. Neither shows on a draft or a cancelled order. Extend `purchase_order_detail_screen_test.dart`: both present for a confirmed order with the rights, absent without them and on draft and cancelled, and each opening its target.

**Checkpoint**: Run `flutter test test/unit/core/documents test/unit/features/purchases test/widget/features/purchases`, then quickstart step 10.

---

## Phase 7: User Story 5 — Correct or cancel a draft (Priority: P3)

**Goal**: A buyer edits a draft's header and lines, removes lines, or cancels the draft; cancelling keeps the lines as history and puts their request lines back in Por comprar.

**Independent Test** (quickstart steps 5, 6, 11): create an order from Por comprar, cancel it, and check that its lines reappear in Por comprar and that the cancelled order still shows its lines read-only.

- [ ] T030 [P] [US5] Create the header dialog (research R7, depends on T008): `lib/features/purchases/presentation/orders/order_header_dialog.dart`. The new-order fields, prefilled; the supplier picker; clearing the notes sends `clearComment`, clearing the date sends `clearDate`; the supplier is sent only when changed. Refusals in `FormErrorBanner`. Add `test/widget/features/purchases/order_header_dialog_test.dart`: prefill, only the changed fields sent, both clears, the date floor, and a refusal.

- [ ] T031 [P] [US5] Create the line dialog and the tax-rate options (research R8, depends on T008): `lib/features/purchases/presentation/orders/order_line_dialog.dart`. Warehouse (`CatalogEntityPicker<Warehouse>` over `inventoryWarehouseOptions`, unscoped), quantity (> 0, ≤ 4 decimals), unit price (≥ 0, ≤ 7 decimals, helper "antes de IVA", shown at full precision) and IVA (a dropdown of `{0, 0.08, 0.16} ∪ {the line's current rate}`, ascending, labelled "{rate} %"); only changed fields are sent. Put the options in a small pure function `taxRateOptions(current)` in the same file. Refusals (including an in-transit warehouse) in `FormErrorBanner`. Add `test/widget/features/purchases/order_line_dialog_test.dart`: prefill, the validations (0, 1.23456, a negative price, 8 decimals of price), changed-only payload, and the options for 0.16, 0.08, 0 and an odd rate such as 0.10.

- [ ] T032 [US5] Add the remove-line and cancel prompts (depends on T021): in `order_dialogs.dart` add `showRemoveOrderLineDialog(line)` (names the product) and `showCancelOrderDialog(order)` ("La orden queda cancelada. Sus partidas de solicitud vuelven a Por comprar."). Extend `order_dialogs_test.dart` with both.

- [ ] T033 [US5] Add the edit and cancel actions to the detail screen (FR-011, FR-013, FR-024, FR-025, depends on T029, T030, T031, T032): in `purchase_order_detail_screen.dart`, on a draft: "Editar encabezado" (update 20 and read suppliers), ✎ and 🗑 on each line via `buildCatalogRowActions` (update 20; ✎ also needs read on warehouses), and "Cancelar orden" (delete 20) at the left of the action area. A cancelled order keeps its lines read-only with no actions; a confirmed order offers no cancel. Extend `purchase_order_detail_screen_test.dart`: each control by state and right, the header edit, a line edit and removal updating the totals, cancel success (the order becomes read-only and its lines stay), and the `confirmed_cannot_cancel` refusal reloading the screen.

**Checkpoint**: All five stories work. Run `flutter test test/unit/features/purchases test/widget/features/purchases test/unit/core`, then quickstart steps 5, 6, 11, 14.

---

## Phase 8: Polish & cross-cutting concerns

- [ ] T034 Account for the legacy actions (SC-006): write `specs/080-purchase-orders/legacy-actions.md`, a table of the 17 legacy purchase-order actions (take them from mictlanix/mbe-roadmap#71's weight and the legacy `mbe` repo's `docs/specs/05-purchases.md` and the old controller's actions), each marked covered (with the FR and task that deliver it) or dropped (approval, §4; anything else with its reason). Flag any that matches neither so the user can decide.

- [ ] T035 [P] Add the large-text test and run the static checks (quickstart step 15): `test/widget/features/purchases/purchase_orders_large_text_test.dart` renders the list, Por comprar and a draft and a confirmed detail at the largest text scale without overflow, as `purchases_large_text_test.dart` does for requests. Then `flutter analyze` (no new issues) and `dart format` on the changed files only.

- [ ] T036 [P] Add the live repository test (research R18, quickstart): `test/integration/purchase_orders_live_test.dart`, discovering its fixtures at run time (an approved request with marked lines is made through the 079 repository; skip with a clear message when the tenant lacks a purchasable product with a supplier). With `MBE_WRITE=true`: create by hand, add lines, edit and read back the quantity, price and tax-rate strings, clear the notes and the date and read them back (settles research R7's raw-`dio.put` fallback), add a request's lines, confirm (receipts returned, one per warehouse, none for a service line), `get` the order (receipts empty until mbe-api#355), print (non-empty PDF bytes), email (success, or the 503 code when mail is not configured), cancel a second draft and see its lines back in `toPurchase`, and create from a group. Run: `flutter test test/integration/purchase_orders_live_test.dart --dart-define-from-file=.env.settings --dart-define-from-file=.env --dart-define=MBE_WRITE=true`.

- [ ] T037 [P] Add the device walkthrough (quickstart): `integration_test/purchase_orders_quickstart_test.dart`, steps 1–12 and 14 on macOS, following the macOS integration-test traps (frame-stall watchdog, hitTestable login, picker and back-button finders; memory `reference_macos_integration_test_traps`). Run with `caffeinate -dims flutter test integration_test/purchase_orders_quickstart_test.dart -d macos --dart-define-from-file=.env.settings --dart-define-from-file=.env`.

- [ ] T038 Run the quickstart (depends on T036, T037 and every story): execute `specs/080-purchase-orders/quickstart.md` against the dev tenant, including the steps the device test skips (the received-then-reopened check in step 9, the emailed PDF arriving in step 10, the read-only account in step 13), and record each result and any deviation in `specs/080-purchase-orders/quickstart-results.md`. Steps that cannot run (no mail, no second account) are listed as manual, not skipped silently.

- [ ] T039 Record the release notes for the PR description in `specs/080-purchase-orders/pr-description.md`: under "Roadmap", `Closes mictlanix/mbe-roadmap#71`; list what stays manual (the steps skipped in T038, the timed checks for SC-001 and SC-002 in quickstart steps 3 and 10, the largest-text check on a real device); and name the follow-ups: mictlanix/mbe-api#353 (coded warnings, the supplier-mismatch warning and per-line skip reasons), #354 (Por comprar filters and paging, removing the §VI exception) and #355 (receipts with state on every order response). Mention that supplier payments (roadmap#75) and cost-change history are out of scope. The `[UI]` follow-up issue for the manual checks is opened together with the PR.

---

## Dependencies and execution order

- **Phase 1 → Phase 2 → stories.** T001 first. Phase 2 blocks every story.
- **Phase 2 order:** T002 first (strings). Then T003 and T004 in parallel (T003 needs T002). T005 needs T004. T006, T009 and T010 need T004 (T010 also needs the request repository from 079, already in place). T007 needs T005. T008 needs T005 and T007.
- **Stories:** US1 (T011–T015) needs Phase 2. US2 (T016–T022) needs Phase 2 and US1's detail screen (T013) and router work (T015, for T018). US3 (T023–T025) needs US2's list (T017, for T023) and US1's detail screen (T013, for T024). US4 (T026–T029) needs US2's detail actions (T022, for T029). US5 (T030–T033) needs US2's detail actions (T022) and dialogs file (T021, for T032).
- **Shared files** (see the cross-story notes) mean the detail-screen tasks T013 → T022 → T024 → T029 → T033 run in that order, the dialogs-file tasks T021 → T032, and the router and navigation tasks T015 → T018. If the stories are split between people, agree that order.
- **Polish** needs every story it covers: T034 needs the FRs it cites, T036 and T038 need US1–US5, T035 needs US1–US3.

### Parallel opportunities

- Phase 2: after T002, T003 and T004 run together. T006, T009 and T010 follow T004 and run beside T005 (different files).
- Within US1: T012 runs beside T011. T013 and T014 are different screens and can proceed together once T011 and T012 are done; T015 follows both.
- Within US2: T016, T019, T020 and T021 are different files and run in parallel after Phase 2; T017 and T018 are a sequence; T022 follows them all.
- US3's T025 is independent of T023 and T024. US4's T026 is independent of T027–T028. US5's T030 and T031 are independent.
- Phase 8: T035, T036 and T037 are parallel.

### Requirement coverage

| Requirement | Task |
|---|---|
| FR-001–FR-003 (nav, rights, no facility limit) | T009, T015, T018 |
| FR-004–FR-006 (list) | T017, T023 |
| FR-007–FR-009, FR-031 (Por comprar) | T011, T014 |
| FR-010 (create by hand) | T016 |
| FR-011 (edit header) | T030, T033 |
| FR-012, FR-016, FR-020 (detail facts, lines, hidden fields) | T013 |
| FR-013–FR-015 (lines) | T019, T031, T033 |
| FR-017, FR-018 (request lines, left-out count) | T020, T014 |
| FR-019 (price-0 warning) | T004, T012, T013 |
| FR-021–FR-023 (confirm, receipts, received and pending) | T021, T022, T024 |
| FR-024, FR-025 (cancel, cancelled read-only) | T032, T033 |
| FR-026–FR-028 (print, email, failures) | T026–T029 |
| FR-029 (localized refusals) | T003 and every dialog task |
| FR-030 (links from existing screens) | T025 |

### Implementation strategy

1. **MVP:** Phase 1, Phase 2, US1 and US2. That orders the pending lines or a hand-written order and confirms it into receipts.
2. **Next:** US3 (find and follow, plus the links) and US4 (print and email), in either order.
3. **Last:** US5 (edit and cancel a draft), the least frequent actions.
4. After each story, run its tests and its slice of the quickstart before starting the next.
