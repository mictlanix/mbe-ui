---
description: "Task list for 061-delivery-orders"
---

# Tasks: Delivery Orders

**Input**: Design documents from `specs/061-delivery-orders/`

**Prerequisites**: plan.md, spec.md, research.md (R1–R12), data-model.md, contracts/ui-contracts.md (C1–C12), quickstart.md, wireframes.md (its Open Questions are resolved in plan.md and research.md)

**Tests**: The spec doesn't ask for a test suite as such, but the constitution's quality gates and research R12 require tests. Test tasks sit inside each story, after the code they cover.

**Organization**: Grouped by user story (US1–US7, spec.md). US1 and US2 are both P1 and together are the MVP: find orders, read one, and confirm a POS draft. US3 (edit a draft), US4 (cancel) and US5 (history) are P2. US6 (requeue) and US7 (pickup) are P3. Phase 2 holds what two or more stories share.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: parallelizable (different files, no dependency on an incomplete task)
- **[Story]**: US1 find orders and read one · US2 confirm a draft · US3 correct a draft · US4 cancel · US5 history · US6 requeue · US7 pickup handover

## Cross-story notes

- **Shared files.** Do these sequentially, not in parallel:
  - `lib/features/sales/presentation/delivery_orders/delivery_order_detail_screen.dart`: T015 (US1) creates it, then T020 (US2), T026 (US3), T029 (US4), T031 (US5), T033 (US6) and T035/T036 (US7) each edit it.
  - `lib/features/sales/presentation/delivery_orders/delivery_order_dialogs.dart`: T019 (US2) creates it, then T023 (US3), T028 (US4), T033 (US6) and T037 (US7) add to it.
  - `lib/features/sales/presentation/delivery_orders/delivery_order_detail_controller.dart`: T010 creates it, T036 (US7) edits it.
  - `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb`: every key is added once, in T002. If a later task needs another, add it there and run `flutter gen-l10n`. Never hand-edit `lib/l10n/app_localizations*.dart`.
- **Generated code.** After editing a freezed or `@riverpod` file, run `dart run build_runner build --delete-conflicting-outputs` at the repo root. Never run two build_runner processes at once: tasks that both need it are not marked [P] against each other. No client regeneration is needed: `DeliveryOrdersApi` already has every operation (list, get, update header, add/update/delete line, confirm, cancel, requeue, `markReadyForPickupApiV1DeliveryOrdersDeliveryOrderIdReadyForPickupPost`, `confirmPickupApiV1DeliveryOrdersDeliveryOrderIdPickupPost`, events, proof, proof image).
- **Formatting.** Format only the files you changed (`dart format <files>`). Never `dart format .`, and never format `lib/generated/`.
- **Amounts, quantities and dates** go through `formattersProvider` (constitution §V). No `NumberFormat`, no `toStringAsFixed`. Quantities are `Decimal`, never `double`.
- **Spacing tokens, not literals** (`Theme.of(context).spacing`). No automated guard catches a literal, so check it in review.
- **Never match server prose** (§III). Show refusals through `AppError.localizedMessage` / `FormErrorBanner`, which build the text from the error's `code`. Recognition keys on the code.
- **Status and type names come from l10n**, never from `enum.name` (plan, Constraints).
- **Simplifications.** Any shortcut carries a comment `// simplified: <ceiling>, <what to do when it binds>`.
- **Mirror, don't copy blindly.** Closest precedents:
  - List screen, filter and controller: `sales/presentation/refunds/{refunds_list_screen, refunds_filter, refunds_list_controller}.dart`, and `payments/payments_filter.dart` for the date range.
  - Document detail screen (facts strip, lines, action area, `_NotFound`, `_LoadFailed`): `refunds/refund_detail_screen.dart`.
  - Write controller returning `AppError?`: `payments/payment_editor_controller.dart` and `payment_verification/payment_verification_controller.dart`.
  - Dialog with a busy flag and `FormErrorBanner`: `payments/apply_payment_dialog.dart`.
  - Name fallbacks: `PaymentCustomerName` in `payments/payment_widgets.dart`, `_EmployeeName` in `payments/payment_detail_screen.dart`, `_WarehouseCell` in `refunds/refund_detail_screen.dart`.
  - Protected image bytes: `licensePhotoProvider` (`lib/features/catalog/presentation/license_photo_provider.dart`) and `VehicleOperatorRepositoryImpl.getLicensePhoto`. File upload: `FilePicker` and `MultipartFile.fromBytes` in `vehicle_operator_repository_impl.dart`.
  - Status chip: `RefundStatusChip` in `refund_detail_screen.dart`.
  - Widget harness: `test/widget/features/sales/refunds_list_screen_test.dart` and `refund_detail_screen_test.dart`; unit harness: `test/unit/features/sales/refunds_filter_test.dart`, `refunds_list_controller_test.dart` and `delivery_order_repository_impl_test.dart`.

---

## Phase 1: Setup

**Purpose**: a known-good baseline, so later failures are attributable.

- [ ] T001 Run `flutter analyze` and the existing tests this feature touches: `test/unit/features/sales/delivery_order_repository_impl_test.dart`, `delivery_controller_test.dart`, `sales_order_repository_impl_test.dart` (find it with `grep -rl SalesOrderRepositoryImpl test`), `test/unit/core/errors/catalog_coverage_test.dart`, and any navigation or router test (find them with `grep -rl nav_destinations test`). Note any pre-existing failures so they aren't blamed on this feature. The failures in `test/golden/core_widgets_golden_test.dart` are already known (mbe-ui#209).

---

## Phase 2: Foundational (blocks all user stories)

**Purpose**: the pieces two or more stories use: strings, error codes, entities, the repositories, the filter, the controllers and the status chip.

- [ ] T002 Add every new string to `lib/l10n/app_es.arb` and `lib/l10n/app_en.arb`, then run `flutter gen-l10n`. Each key gets an `@key` description starting "spec 061". Check `app_es.arb` before adding anything, and reuse existing keys (`filtersTooltip`, `filtersButton`, `clearAllFilters`, `applyFilters`, `clearFiltersButton`, `retryButton`, `cancelButton`, `apiResourceDeliveryOrder`, the `apiErrorDeliveryOrder*` set). Keys (C1–C11):
  - **Navigation and titles:** `navDeliveryOrders` ("Órdenes de entrega" / "Delivery orders"), `deliveryOrderTitle` (placeholder `serial`: "Orden de entrega {serial}"), `deliveryOrderTitleDraft` ("Orden de entrega · Borrador"), `deliveryOrderDraftFolio` ("Borrador"), `deliveryOrdersEmpty` ("No hay órdenes de entrega con estos filtros."), `deliveryOrdersSearchHint` ("Folio"), `deliveryOrdersNoFacilityTitle` and `deliveryOrdersNoFacilityMessage` (the notice for a user with no facility, worded like `salesOrderNoFacilityTitle`/`Message`), `deliveryOrderBackToList` ("Volver a órdenes de entrega").
  - **Status labels (11) and types (2):** `deliveryOrderStatusDraft` ("Borrador"), `…PendingApproval` ("Pendiente de aprobación"), `…Approved` ("Aprobada"), `…ReadyForPickup` ("Lista para recoger"), `…PickedUp` ("Recogida"), `…InPreparation` ("En preparación"), `…InTransit` ("En tránsito"), `…Delivered` ("Entregada"), `…PartiallyDelivered` ("Entregada parcialmente"), `…Failed` ("Fallida"), `…Cancelled` ("Cancelada"); `deliveryOrderTypeDelivery` ("Entrega"), `deliveryOrderTypePickup` ("Recoge en tienda").
  - **Columns, fields and sections:** the list columns (Folio, Cliente, Tipo, Programada, Destino, Pedidos, Estado), the facts (Sucursal, Prioridad, Contacto, Comentario, "De la orden", "Orden derivada"), the lines columns (Código, Producto, Almacén, Pedido, Ordenada, Comprometida, Entregada, Devuelta, Abierta), and the section titles "Líneas", "Historial", "Comprobante de entrega".
  - **Filters:** Estado, Tipo, Fecha programada, Cliente, Pedido, Sucursal, "Todas", "Todos", "Mi sucursal".
  - **Actions and dialogs:** `deliveryOrderEditHeader`, `deliveryOrderAddLine`, `deliveryOrderConfirmAction` ("Confirmar"), `deliveryOrderCancelAction` ("Cancelar orden"), `deliveryOrderRequeueAction` ("Reprogramar"), `deliveryOrderReadyAction` ("Lista para recoger"), `deliveryOrderPickupAction` ("Entregar al cliente"), the dialog titles and bodies of C5–C10, `deliveryOrderConfirmIrreversible` ("Una vez confirmada, ya no podrá editarse."), `deliveryOrderConfirmNeedsLines`, `deliveryOrderCancelReasonLabel`, the pickup field labels ("Nombre de quien recibe", "Identificación mostrada", "Foto", "Elegir archivo"), the add-line step texts and empty states, and the remove-line confirmation.
  - **Feedback:** one snackbar key per action naming the folio (placeholder `serial`), `deliveryOrderActionUnknown` ("No sabemos si se completó: se perdió la conexión. La orden se actualizó."), `deliveryOrderProofLoadFailed` ("No se pudo cargar el comprobante").
  - **API errors:** `apiErrorDeliveryOrderInsufficientNotice` (placeholders `minHours`, `earliest`), `apiErrorDeliveryOrderNoLines`, `apiErrorDeliveryOrderNotFailed`, `apiErrorDeliveryOrderProofIncomplete`.

- [ ] T003 [P] Localize four error codes (R10, depends on T002):
  - In `lib/core/errors/localize_problem.dart`, add the generated `api.ErrorCode` members for `delivery_order.insufficient_notice`, `.no_lines`, `.not_failed` and `.proof_incomplete` to `localizedErrorCodes`, and map each to its `l10n.apiErrorDeliveryOrder*` key in the switch. Find the member names in `lib/generated/openapi/lib/src/model/error_code.g.dart` (they follow the `deliveryOrderPeriod…` pattern).
  - Add a private `_dateTime(problem, 'earliest', fmt)` helper beside `_date`, formatting with `fmt.display.dateTime`, and use it with `_quantity`-style `_count` for `min_hours` in `insufficient_notice`.
  - In `test/unit/core/errors/problem_fixtures.dart`, add fixtures (`insufficient_notice` carries `min_hours` and `earliest`).
  - In `specs/058-localized-api-errors/contracts/code-scope.tsv`, flip the four rows from `OUT` to `IN`. Set `example_routes` to the endpoint (`POST /delivery-orders/{}/confirm`, `/requeue` or `/pickup`) and the note to "reachable from the delivery order detail screen (spec 061)".
  - Add the delivery-order routes to the `example_routes` of the reused rows that become reachable here: `lock.busy` (`POST /delivery-orders/{}/confirm`), `image.too_large` and `image.unsupported_format` (`POST /delivery-orders/{}/pickup`), `state.transition_invalid` (`/ready-for-pickup`, `/pickup`) and `delivery_order.not_editable` (`PUT /delivery-orders/{}`, `/confirm`). Research R10 has the full per-endpoint table.
  - In `test/unit/core/errors/catalog_coverage_test.dart`, raise the `checked` count by 4 (it is 105 now, so 109; confirm the current value first).
  - Run `flutter test test/unit/core/errors/`.

- [ ] T004 [P] Create the entities (data-model §1) in `lib/features/sales/domain/entities/delivery_order.dart` (freezed): `DeliveryOrderSummary`, `DeliveryOrder` (the summary's fields plus contact, comment, rejection reason, proof id, timestamps and lines), `DeliveryOrderLine`, `DeliveryOrderEvent` and `ProofOfDelivery`. Import `DeliveryOrderStatus` and `FulfillmentType` from `destination.dart`; don't move them. Add the getters `isDraft`, `isPickup`, `isTerminal` and `hasProof`. Run build_runner.

- [ ] T005 Create the admin repository (R2, depends on T004). In `lib/features/sales/domain/repositories/delivery_order_admin_repository.dart` declare `list`, `getById`, `events`, `proof`, `proofImage`, `updateHeader`, `addLine`, `updateLine`, `removeLine`, `confirm`, `cancel`, `requeue`, `markReadyForPickup` and `confirmPickup`, each with a doc comment naming its endpoint.
  - In `lib/features/sales/data/delivery_order_admin_repository_impl.dart`, implement them over the generated `DeliveryOrdersApi`, with `deliveryOrderAdminRepositoryProvider`. `list` takes the filter's fields and returns the page plus its total. `confirmPickup` takes bytes and a filename and sends `MultipartFile.fromBytes`. `proofImage` checks the PNG signature as `getLicensePhoto` does.
  - Make `_setQuantity1` in `lib/features/sales/data/delivery_order_repository_impl.dart` a top-level function and use it from both impls. Reuse `wireDate` from `sales_order_repository_impl.dart` for dates.
  - Create `test/unit/features/sales/delivery_order_admin_repository_impl_test.dart` (follow `delivery_order_repository_impl_test.dart`): status and type mapping from `number0…number10`, the four quantities and `open`, null `serial`, the events mapping with a null `from`, a multipart pickup request, a non-PNG image rejected, and each write returning the mapped order.

- [ ] T006 [P] Add `customer` to the sales-order list (R8): in `lib/features/sales/domain/repositories/sales_order_repository.dart` add an optional `int? customer` to `listOrders`, and pass it through in `lib/features/sales/data/sales_order_repository_impl.dart`. Every existing caller stays unchanged. Extend the sales-order repository test with a case that `customer` reaches the request.

- [ ] T007 [P] Stop the POS counting cancelled destinations (R9, C12): in `lib/features/sales/data/delivery_order_repository_impl.dart`, make `listForSale` skip summaries whose status is `cancelled`, before fetching their detail. Add a case to `test/unit/features/sales/delivery_order_repository_impl_test.dart`: a sale with one cancelled and one draft order returns only the draft.

- [ ] T008 [P] Create the filter (data-model §2, R3): `lib/features/sales/presentation/delivery_orders/delivery_orders_filter.dart` (freezed), with `fromQuery(ListQuery)`, `toQuery`, `activeFilterCount` and `isNarrowed`. Keys: `q` (digits only), `status` (wire number), `type`, `from`, `to` (a day), `customer`, `order`, `facility`. An absent `status` means every status. `fromQuery` takes `isAdministrator` and decodes `facility` only when it's true, as `SalesOrdersFilter.fromQuery` does (research R3, mbe-api#314). Create `test/unit/features/sales/delivery_orders_filter_test.dart` (follow `refunds_filter_test.dart`): round-trip, non-digit search dropped, unknown status ignored, counts, clearing, and `facility` ignored for a non-administrator. Run build_runner.

- [ ] T009 Create the list controller (depends on T005, T008): `lib/features/sales/presentation/delivery_orders/delivery_orders_list_controller.dart`, an `AsyncNotifier` family keyed by the filter, 20 per page, page clamped as `fetchClampedPage` does in the payments controller. In the fetch, drop `facility` again unless `isAdministrator`, independently of the filter (the double drop is load-bearing; never merge it into one site). When `userFacilityIdProvider` is null, send no request. Create `test/unit/features/sales/delivery_orders_list_controller_test.dart` (follow `refunds_list_controller_test.dart`): the filter reaches the repository with `limit 20`, the page is clamped when the last row goes, and an error surfaces. Also create `test/unit/features/sales/delivery_orders_scoping_test.dart`, following `sales_orders_scoping_test.dart`: for a non-administrator, a `facility` in the URL reaches neither the filter nor the request, even when the filter is built directly with one; for an administrator it reaches both; with no user facility, no request is sent. Run build_runner.

- [ ] T010 Create the detail controller (R5, depends on T005): `lib/features/sales/presentation/delivery_orders/delivery_order_detail_controller.dart`, a family keyed by id.
  - It loads the order and its events in parallel.
  - It exposes a `sales` map from sales-order detail id to sale id: for a single-sale order every line maps to that sale with no request, and for several sales it loads each with `SalesOrderRepository.getById` (needs Sales Orders read; a failure leaves the map empty).
  - For a `partiallyDelivered` order it finds children with one `list(salesOrder:, facility: order.facilityId)` call, keeping those whose `parentId` equals the id. Pass the facility: the server otherwise filters on the caller's (research R5).
  - Proof loading is added in T036.
  - Create `test/unit/features/sales/delivery_order_detail_controller_test.dart`: order and events load together, an events failure doesn't hide the order, the sale map for one and several sales, and the children lookup only for a partial delivery. Run build_runner.

- [ ] T011 Create the write controller (R6, depends on T005): `lib/features/sales/presentation/delivery_orders/delivery_order_actions.dart`, a keep-alive notifier with `confirm`, `cancel`, `requeue`, `markReady`, `confirmPickup`, `updateHeader`, `addLine`, `updateLine` and `removeLine`. Each returns `AppError?`.
  - On success it invalidates the order, its events and the list family.
  - On failure it invalidates the order, so the screen reloads (FR-023).
  - A connection error, or a timeout with no response, returns an "unknown result" error and reloads.
  - Create `test/unit/features/sales/delivery_order_actions_test.dart` (follow `payment_editor_controller_test.dart`): each action calls the right repository method, the invalidations happen on success and on failure, the server's error code passes through, and the unknown-result case. Run build_runner.

- [ ] T012 [P] Create the status chip (C11): `lib/features/sales/presentation/delivery_orders/delivery_order_status_chip.dart`, `DeliveryOrderStatusChip` on `StatusChip<DeliveryOrderStatus>` with key `delivery_order_status_chip_{name}`, labels from T002, and the colour groups in C11. Add a type-label helper there too. Create `test/widget/features/sales/delivery_order_status_chip_test.dart`: all 11 statuses render their Spanish label and don't clip at a narrow width.

---

## Phase 3: User Story 1 — Find delivery orders and read one (Priority: P1) 🎯 MVP

**Goal**: a clerk opens "Órdenes de entrega", narrows the list, and opens an order to see its header, lines and links.

**Independent Test**: seed orders in several statuses at the user's facility and one at another facility. As a user with Delivery Orders read, open the list, apply each filter, and open a row (quickstart steps 1–3).

- [ ] T013 [P] [US1] Create `lib/features/sales/presentation/delivery_orders/delivery_order_name_cells.dart` with the small read-only widgets both screens use, each falling back to `#id` without the right (R4, FR-025): customer name (`customerDisplayNameProvider`), facility name (`facilityDisplayNameProvider`), warehouse name (`facilityWarehousesControllerProvider`), ship-to (the customer's address through `saleCustomerControllerProvider`, or the facility name for a pickup), contact (the same source) and employee name (`employeeDisplayNameProvider`). This file isn't in the plan's source tree; note it there when committing.

- [ ] T014 [US1] Create `lib/features/sales/presentation/delivery_orders/delivery_orders_list_screen.dart` (C2, C3, FR-001–FR-006), following `refunds_list_screen.dart`:
  - When `userFacilityIdProvider` is null, show only the no-facility notice (key `delivery_orders_no_facility`), administrators included, as `sales_orders_list_screen.dart` does.
  - `CatalogFilterBar` with a digits-only `CatalogSearchBar` (key `delivery_orders_search`, hint `deliveryOrdersSearchHint`, "Folio") and the badged filters button; no create action.
  - `showCatalogFilterSheet` with Estado, Tipo, Fecha programada (`DateRangeFilterChip`), Cliente (`CatalogEntityPicker`, only with Customers read), Pedido (numeric) and Sucursal (only for administrators, first item "Mi sucursal").
  - `DataTableView<DeliveryOrderSummary>` with the seven columns, "Borrador" when `serial` is null, truncated Cliente and Destino with tooltips, Pedidos joined with ", ", and `DeliveryOrderStatusChip`. No row icons, and a row tap pushes `/sales/delivery-orders/{id}`.
  - `CatalogPagination`, and `CatalogListStateView` for loading, error and empty, with "Quitar filtros" only when `isNarrowed`.
  - The compact tier stacks rows and drops Pedidos.

- [ ] T015 [US1] Create `lib/features/sales/presentation/delivery_orders/delivery_order_detail_screen.dart` (C4, FR-007, FR-008), read-only for now, following `refund_detail_screen.dart`:
  - Title `deliveryOrderTitle` or `deliveryOrderTitleDraft`, with `AppBar.actions` empty.
  - The rejection banner (key `delivery_order_rejection_banner`) when `rejectionReason != null`.
  - A `FactStripRow` with Folio, Estado, Tipo, Cliente, Sucursal, Programada and Prioridad, and a `ResponsiveFormGrid` band with Destino, Contacto, Pedidos (links to `/sales/orders/{id}`), Comentario, "De la orden" (parent link) and "Orden derivada" (child links).
  - The lines `DataTableView` with the nine columns, quantities right-aligned, and the Pedido column from the controller's sale map ("—" when it can't tell). Lines stack as cards at the compact tier.
  - `_NotFound` (with "Volver a órdenes de entrega") and `_LoadFailed` (with retry) for a bad id or a load error.

- [ ] T016 [US1] Wire navigation and routes (C1, R11):
  - In `lib/core/navigation/nav_destinations.dart`, add `NavBranch.deliveryOrders = 26` and a `NavDestination(id: 'delivery-orders', …)` in Ventas right after `sales-orders`, gated on `PrivilegeGate(SystemObject.deliveryOrders, AccessRight.read)`.
  - In `lib/app/router/app_router.dart`, append a `StatefulShellBranch` for `/sales/delivery-orders` (`DeliveryOrdersListScreen(query: ListQuery.fromUri(state.uri))`), add the top-level detail `GoRoute('/sales/delivery-orders/:deliveryOrderId')` (non-integer id gives the not-found state), and add a `_routeGate` clause for any location starting with `/sales/delivery-orders`.
  - Document SystemObject 71 in a comment on the nav destination, both routes and the gate clause (constitution §IV).
  - Run the navigation and router tests found in T001 right after this change.

- [ ] T017 [P] [US1] Create `test/widget/features/sales/delivery_orders_list_screen_test.dart` (follow `refunds_list_screen_test.dart`):
  - It opens on every status with the filter badge at 0, and a draft row reads "Borrador".
  - The digits-only search finds by folio, and letters aren't accepted.
  - Each filter reaches the controller, and "Limpiar todo" returns to the opening state.
  - Loading, error and empty states, with "Quitar filtros" only when narrowed.
  - The customer facet is absent without Customers read, and the facility facet for a non-administrator.
  - A user with no facility sees the notice and no request is made.
  - A row tap navigates to the detail, and a user without Delivery Orders read is redirected.

- [ ] T018 [P] [US1] Create `test/widget/features/sales/delivery_order_detail_screen_test.dart` (follow `refund_detail_screen_test.dart`): header facts and chip, all five line quantities, the rejection banner only when a reason exists, the parent link, child links for a partial delivery, the Pedido column for one and several sales, names falling back to `#id`, not-found and load-error states, and no action or edit control for a user without update (this test file grows in later stories).

**Checkpoint**: US1 is demoable alone: find any order and read it.

---

## Phase 4: User Story 2 — Confirm a draft from the POS (Priority: P1) 🎯 MVP

**Goal**: a clerk confirms a draft; it gets its folio and the status the server chooses.

**Independent Test**: create a one-line draft through the POS, open it as a user with Delivery Orders update, confirm it, and check the folio, status and history (quickstart step 5).

- [ ] T019 [US2] Create `lib/features/sales/presentation/delivery_orders/delivery_order_dialogs.dart` with the confirm dialog (C5, FR-016, FR-017), a `ResponsiveDialog` naming the customer, scheduled date and line count, with `deliveryOrderConfirmIrreversible`.
  - It uses a busy flag and isn't dismissible while submitting.
  - On `delivery_order.insufficient_notice` it stays open with a `FormErrorBanner` carrying the localized message, which includes the earliest date and time.
  - Other errors close the dialog, show the localized error, and let the reload happen.

- [ ] T020 [US2] Edit `delivery_order_detail_screen.dart` (C4): add the end-aligned action area, built as a `Wrap`.
  - Add "Confirmar" (`FilledButton`, key `delivery_order_confirm`) for a draft with update. It is disabled, with the hint `deliveryOrderConfirmNeedsLines`, while the order has no lines.
  - Show a snackbar naming the folio the server assigned after success.
  - Gate it on `can(SystemObject.deliveryOrders, AccessRight.update)` and absent otherwise, never disabled (§VI).
  - The later stories add their buttons to this same area, following data-model §3.

- [ ] T021 [US2] Extend `test/widget/features/sales/delivery_order_detail_screen_test.dart` and create `test/widget/features/sales/delivery_order_dialogs_test.dart`: Confirmar shows only for a draft with update, is disabled with no lines, and names customer, date and line count; success shows the server's folio and status; `insufficient_notice` keeps the dialog open with the earliest date; other errors close it and reload.

**Checkpoint**: US1 + US2 are the MVP. POS drafts can now reach the warehouse.

---

## Phase 5: User Story 3 — Correct a draft before confirming (Priority: P2)

**Goal**: a clerk edits a draft's header and lines, including adding a line from another sale of the same customer.

**Independent Test**: edit each header field, change one line's quantity, remove a line and add one from another sale; reload and check each change stuck (quickstart step 4).

- [ ] T022 [US3] Create `lib/features/sales/presentation/delivery_orders/header_dialog.dart` (C10, FR-012): a `ResponsiveDialog` with a two-column `ResponsiveFormGrid` of scheduled date and time, priority (integer ≥ 0), ship-to (`CustomerAddressPicker`, deliveries only; read-only as the store on a pickup), contact (`CustomerContactPicker`) and comment. Send only changed fields, offer no clear option, and keep "Guardar" disabled until something changes.

- [ ] T023 [US3] Add the line dialogs to `delivery_order_dialogs.dart` (C8, FR-013): the quantity dialog (one decimal field prefilled with the current quantity, "Ordenada en la venta" above it, greater than 0 checked on the client, the server's `quantity_exceeds_remaining` shown inline), and the remove confirmation naming the product and saying its quantity becomes available again.

- [ ] T024 [P] [US3] Create `lib/features/sales/domain/entities/deliverable_lines.dart` (data-model §1, R8): `DeliverableLine` and the pure function `deliverableLines(Sale sale, List<DeliveryOrder> ordersOfSale, {required Set<int> excludeDetailIds})`. Remaining is the sale line's quantity minus the sum over non-cancelled orders; lines with nothing left and lines already on the order are dropped. Create `test/unit/features/sales/deliverable_lines_test.dart`: cancelled orders don't count, several orders sum, a partly covered line, a fully covered line is dropped, and excluded ids are dropped.

- [ ] T025 [US3] Create `lib/features/sales/presentation/delivery_orders/add_line_dialog.dart` (C7, FR-014), the two-step dialog:
  - Step 1 lists the customer's completed sales at the order's facility through `listOrders(customer:, status: completed, facility:)`, 20 at a time with "Cargar más", and a digits-only folio search.
  - Step 2 loads that sale (`getById`) and its delivery orders (`list(salesOrder:, facility: <sale's facility>)`, then each order's lines), computes `deliverableLines`, and shows the table with a quantity field per line validated `0 < q ≤ remaining` (blank means skip). It has an "Otra venta" back button.
  - "Agregar" sends one `addLine` per filled row in sequence, stops at the first error and shows it inline, and the lines already added stay. The detail reloads on close.
  - Both empty states from C7.

- [ ] T026 [US3] Edit `delivery_order_detail_screen.dart` (C4): for a draft with update, add "Editar encabezado" (key `delivery_order_edit_header`), the line ✎ and 🗑 icons built with `buildCatalogRowActions` (keys `delivery_order_line_edit_{id}`, `delivery_order_line_remove_{id}`), and "Agregar línea" (key `delivery_order_add_line`) in the lines header. "Agregar línea" also needs `can(SystemObject.salesOrders, AccessRight.read)`. All of it is absent for a non-draft or a user without update (FR-015).

- [ ] T027 [P] [US3] Create `test/widget/features/sales/header_dialog_test.dart` and `add_line_dialog_test.dart`, and extend the detail test:
  - Header: only changed fields are sent, Guardar is disabled until a change, a pickup's ship-to is read-only, priority rejects negatives.
  - Add line: step 1 lists the sales, step 2 shows only lines with something left and drops lines already on the order, a quantity above remaining is invalid, rows send in sequence and the first error stops the run.
  - Line quantity (T023): `quantity_exceeds_remaining` shows inline with the server's `remaining` and keeps the dialog open.
  - Detail: the edit controls show only for a draft with update, and "Agregar línea" needs Sales Orders read.

**Checkpoint**: US3 works on its own; a draft can be fully corrected, then confirmed (US2).

---

## Phase 6: User Story 4 — Cancel an order (Priority: P2)

**Goal**: a clerk cancels an order with a reason, and the sale's quantities become available again.

**Independent Test**: cancel an order in En preparación with a reason; check Cancelada, the history entry, and that it leaves the active view (quickstart step 7).

- [ ] T028 [US4] Add the cancel dialog to `delivery_order_dialogs.dart` (C6, FR-018): a multiline reason field (key `delivery_order_cancel_reason`), the confirm button disabled while the trimmed reason is empty. On `state.transition_invalid`, close the dialog, show the generic localized message, and let the reload show the new status.

- [ ] T029 [US4] Edit `delivery_order_detail_screen.dart`: add "Cancelar orden" (`OutlinedButton`, key `delivery_order_cancel`), offered with update in Borrador, Pendiente de aprobación, Aprobada, Lista para recoger, En preparación and Fallida (data-model §3), and in no other status. It is offered in En preparación even when the order may be on an open itinerary (mbe-api#311, accepted risk).

- [ ] T030 [P] [US4] Extend `delivery_order_dialogs_test.dart` and the detail test: Cancelar shows in exactly the six statuses and not in En tránsito or any terminal one, the confirm button stays disabled for a blank or whitespace reason, success shows Cancelada, and `state.transition_invalid` closes the dialog and reloads.

---

## Phase 7: User Story 5 — See an order's history (Priority: P2)

**Goal**: a supervisor reads who moved an order to each status, when, and why.

**Independent Test**: take an order through create, confirm and cancel; the history shows three entries in order with the right employee and the reason (quickstart step 3).

- [ ] T031 [US5] Edit `delivery_order_detail_screen.dart` (C4, FR-009): add the "Historial" section after the lines (and the proof section, when T036 adds it). One row per event, oldest first: date and time through the formatters, `from → to` (a dash for the creation event), the employee name from the name cells, and the reason truncated with a tooltip. It's a bounded list with no pagination. It refreshes with the order after every action (FR-022).

- [ ] T032 [P] [US5] Extend the detail widget test: events render oldest first with from and to labels, the creation event shows a dash, an approval rejection renders as Pendiente de aprobación → Borrador with its reason, employee names fall back to `#id`, and the history gains a row after a successful action.

---

## Phase 8: User Story 6 — Requeue a failed delivery (Priority: P3)

**Goal**: a clerk puts a failed delivery back in the queue.

**Independent Test**: take an order to Fallida through an itinerary, requeue it, and check En preparación and the restored open quantity (quickstart step 9).

- [ ] T033 [US6] Add the requeue confirmation to `delivery_order_dialogs.dart` (C5, FR-019), naming the folio and customer with no field, and edit `delivery_order_detail_screen.dart` to offer "Reprogramar" (`FilledButton`, key `delivery_order_requeue`) only in Fallida with update. Map `delivery_order.not_failed` through the localized errors (T003).

- [ ] T034 [P] [US6] Extend the dialogs and detail tests: Reprogramar shows only in Fallida with update, a success shows En preparación with Devuelta at 0, and `not_failed` shows its localized message and reloads.

---

## Phase 9: User Story 7 — Hand over a pickup order (Priority: P3)

**Goal**: a clerk marks a pickup order ready, then hands it over with receiver, identification and photo.

**Independent Test**: confirm a pickup draft, mark it ready, record the pickup with name, identification and a PNG, and check Recogida and the proof section (quickstart step 8).

- [ ] T035 [US7] Edit `delivery_order_detail_screen.dart`: add "Lista para recoger" (`FilledButton`, key `delivery_order_ready`) for a pickup order in Aprobada with update, and "Entregar al cliente" (`FilledButton`, key `delivery_order_pickup`) for a pickup order in Lista para recoger with update. Neither is offered on delivery orders (FR-020, FR-021).

- [ ] T036 [US7] Load and show the proof (R5, FR-010):
  - In `delivery_order_detail_controller.dart`, when `hasProof`, load `proof` and then the image bytes, with a failure kept inside the proof state so the rest of the screen still renders. Use a provider shaped like `licensePhotoProvider`, feeding `Image.memory`.
  - In `delivery_order_detail_screen.dart`, add the "Comprobante de entrega" section between Líneas and Historial: receiver name, identification shown, capture time, who captured it (employee name), and the photo thumbnail that opens larger in a `ResponsiveDialog` on tap. A load failure shows `deliveryOrderProofLoadFailed` inside the section only. The section is absent when there is no proof.
  - Extend `delivery_order_detail_controller_test.dart` for the proof and image load and the isolated failure.

- [ ] T037 [US7] Create `lib/features/sales/presentation/delivery_orders/pickup_dialog.dart` (C9, FR-021) and add the ready confirmation to `delivery_order_dialogs.dart` (names the folio and customer, no field):
  - The pickup dialog has "Nombre de quien recibe" (key `delivery_order_pickup_name`), "Identificación mostrada" (key `delivery_order_pickup_id`, free text), and a "Elegir archivo" button using `FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['jpg','jpeg','png'], withData: true)`, showing the chosen filename with ✕ to clear.
  - "Entregar" is enabled only when both texts are non-blank after trimming and a file is chosen.
  - On error (including `proof_incomplete`) the dialog stays open and keeps the chosen photo.

- [ ] T038 [P] [US7] Create `test/widget/features/sales/pickup_dialog_test.dart` and extend the dialogs and detail tests: "Lista para recoger" shows only for a pickup in Aprobada, "Entregar al cliente" only for a pickup in Lista para recoger, neither on a delivery order; the pickup button stays disabled until name, identification and a file are all given (each one missing in turn, and whitespace-only text); an error keeps the dialog and the photo, including `image.too_large` (a file over 2 MB) and `image.unsupported_format`; the proof section shows after success, shows a failure inside itself, and is absent without proof.

---

## Phase 10: Polish and cross-cutting

- [ ] T039 Add the action matrix test (SC-003, data-model §3, analysis E1) to `test/widget/features/sales/delivery_order_detail_screen_test.dart`: one table-driven test over all 11 statuses × both types × with and without `deliveryOrders` update. For each case, assert the exact set of action keys present (`delivery_order_confirm`, `_cancel`, `_requeue`, `_ready`, `_pickup`, `_edit_header`, `_add_line`, and the line ✎/🗑) and that every other key is absent. "Agregar línea" also varies with Sales Orders read. Without update, the set is empty. This needs every story's buttons, so it runs after T038.

- [ ] T040 [P] Create the live test `integration_test/delivery_orders_quickstart_test.dart` (R12), following `payment_verification_quickstart_test.dart` and `customer_refunds_quickstart_test.dart`:
  - Read-only by default: the list opens, a filter narrows it, and an order's detail loads with its events.
  - With `MBE_WRITE=true`, it raises a draft through the POS repository from a completed 1-unit sale, then edits the header, confirms and cancels it, and checks the history. It also confirms a pickup draft, marks it ready, and hands it over with a generated 1×1 PNG.
  - Discover its fixtures at run time (see the memory note on live-backend tests). Requeue isn't automated: it needs an itinerary, so quickstart step 9 covers it.

- [ ] T041 Run the manual checks in `quickstart.md` that automation can't prove: step 1 (`qanoaccess` has no entry and the URL is refused), step 6 (too little notice, only if the tenant has a minimum), step 9 (requeue through an itinerary), step 10 (a read-only user; give a test account right 71 read without update first), step 11 (the compact tier) and step 12 (the largest text size: the status chip, folio and quantities don't clip). Record the results in the PR description, and say plainly which checks were not run.

- [ ] T042 Final checks: `flutter analyze` is clean; `dart format` on only the files changed in this feature; the full `flutter test test/unit test/widget` passes apart from the known golden failures (mbe-ui#209); `catalog_coverage_test` passes. Check by search that no new `NumberFormat`, `toStringAsFixed`, `double` quantity, `enum.name` label or hard-coded spacing literal slipped in.

- [ ] T043 Write `specs/061-delivery-orders/pr-description.md` with a Roadmap section ("Closes mictlanix/mbe-roadmap#38"). Name the four upstream issues (mbe-api#311, #312, #313, #314), what each leaves temporarily different here (cancel on an open itinerary is allowed; the list opens on every status; add-line computes remaining; the facility facet is administrators-only and a hand-typed detail URL for another facility isn't blocked), the POS cancelled-destination fix (R9) and the §VI document reading. End it with the attribution line the session's reminder gives.

---

## Dependencies and execution order

```text
T001 ─▶ T002 ─▶ T003
T004 ─▶ T005 ─┬─▶ T009 (also T008)
              ├─▶ T010
              └─▶ T011
T006, T007, T008, T012  (independent of each other)

T009 + T012 + T013 ─▶ T014 ─┐
T010 + T012 + T013 ─▶ T015 ─┼─▶ T016 ─▶ T017, T018         (US1)
T011 + T015 ─▶ T019 ─▶ T020 ─▶ T021                         (US2)
T011 + T015 + T019 ─▶ T022, T023, T024 ─▶ T025 ─▶ T026 ─▶ T027   (US3)
T019 + T020 ─▶ T028 ─▶ T029 ─▶ T030                         (US4)
T015 ─▶ T031 ─▶ T032                                        (US5)
T019 + T020 ─▶ T033 ─▶ T034                                 (US6)
T020 + T010 ─▶ T035; T031 + T010 ─▶ T036; T035 + T036 ─▶ T037 ─▶ T038   (US7)
all stories ─▶ T039 ─▶ T040 ─▶ T041 ─▶ T042 ─▶ T043
```

- **US1** needs T002 to T013. **US2 to US7** each need the US1 detail screen (T015) and the action area T020 creates, so edit the detail screen one story at a time. US5 only needs T015.
- **Parallel:**
  - In Phase 2: T003, T004, T006, T007, T008 and T012 touch separate files and can run beside each other once T002's strings exist where they need them. T005 follows T004.
  - In US1: T013 runs beside T014 and T015's early work, and T017 and T018 run beside each other after T016.
  - In US3: T022 and T024 run beside T023.
  - Test tasks marked [P] can start as soon as their code compiles.

## Implementation strategy

- **MVP**: Phases 1–4 (T001–T021). That delivers the gap the feature exists for: find a POS draft, read it, and confirm it.
- **Then**, in priority order: US3 (correct a draft), US4 (cancel), US5 (history), then US6 (requeue) and US7 (pickup). Each is demoable alone, and none changes US1 or US2.
- **Order of risk:**
  - T016 changes the router and navigation, so run those tests right after it.
  - T005 touches `delivery_order_repository_impl.dart`, which the POS Entrega step uses, and T007 changes what `listForSale` returns. Run `delivery_order_repository_impl_test.dart` and `delivery_controller_test.dart` right after each.
  - T006 touches a repository the Pedidos and POS lists use, so run the sales-order tests right after it.

## Task count

43 tasks:

| Phase | Tasks |
|---|---|
| Setup | 1 |
| Foundational | 11 (T002–T012) |
| US1 | 6 (T013–T018) |
| US2 | 3 (T019–T021) |
| US3 | 6 (T022–T027) |
| US4 | 3 (T028–T030) |
| US5 | 2 (T031–T032) |
| US6 | 2 (T033–T034) |
| US7 | 4 (T035–T038) |
| Polish | 5 (T039–T043) |
