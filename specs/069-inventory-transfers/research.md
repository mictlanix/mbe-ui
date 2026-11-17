# Research: Inventory Transfers (069)

Sources:
- mbe-api `docs/specs/04-inventory.md` §3 and Common Patterns.
- mbe-api `app/services/inventory_transfer_service.py`, `app/services/inventory_documents.py`, `app/api/v1/endpoints/inventory_transfers.py` and `app/core/error_codes.py`.
- The generated client: `InventoryTransfersApi`, `InventoryTransferResponse`, `InventoryTransferSummary`, `InventoryTransferLineResponse`, `TransferCreate`, `TransferUpdate`, `TransferReceive`, `TransferReceiveLine`, `SalesOrderItemsAdd`, `InTransitResponse`, `InTransitLine`, `InTransitProduct` and `TransferStatus`.

The mbe-ui precedent is `lib/features/inventory/`: receipts (spec 067), issues (spec 068), and the shared parts 068 extracted ([068 research](../068-warehouse-issues/research.md) R1). Wireframe open questions are answered here: Q1 → R2, Q2 → R3, Q3 → R6, Q4 → R5, Q5 → R10, Q6 → R9, Q7 → R5, Q8 → R8, Q9 → R2, Q10 → R7.

## R1. What transfers reuse

- **Decision**: Reuse these shared pieces as they are:
  - `inventory_name_cells.dart`: `InventoryWarehouseName` works for both the origin and the destination.
  - `inventory_warehouse_options.dart`: the origin picker uses `inventoryWarehouseOptions` with `inventoryWarehouseScopeProvider`, and starts from `inventoryStartingWarehouseProvider`. The destination picker and the list filter use `inventoryFilterWarehouseOptions`, which offers every warehouse.
  - The repository → actions → controllers pattern of issues (068), copied into `presentation/transfers/`.

  Do not reuse these, because they are tied to the three-state `InventoryDocumentStatus`:
  - `InventoryDocumentStatusChip`
  - `InventoryDocumentsFilter`

  Transfers get their own status enum, chip and filter (R3). The receipt and issue code is not touched.
- **Rationale**: Transfers have four states, masculine labels and two warehouses. Making the shared chip and filter generic over the status type would touch both shipped screens and their tests for one new caller. Copying the small chip (about 50 lines) and filter (about 40 lines) is cheaper and keeps 067 and 068 unchanged.
- **Alternatives**: A generic `StatusChip` adapter over any enum was rejected. The core `StatusChip<T>` already is that, and each document's chip is only its label and tone switch. Extending `InventoryDocumentStatus` with `inTransit` and `received` was rejected, because receipts and issues would then carry states they can never be in.

## R2. Where the feature lives, and navigation

- **Decision**:
  - Code goes in `lib/features/inventory/presentation/transfers/`.
  - Routes are `/inventory/transfers`, `/inventory/transfers/:id` and `/inventory/transfers/in-transit`.
  - The nav gets a third destination in the `inventory` group, after Salidas de almacén:
    - `id: 'inventory-transfers'`, label "Traspasos", icon `Icons.swap_horiz` / `Icons.swap_horiz` (filled weight).
    - `NavBranch.inventoryTransfers = 32`, appended last.
    - Gate `PrivilegeGate(SystemObject.inventoryTransfers, AccessRight.read)`. `SystemObject.inventoryTransfers(17)` already exists.
  - **In-transit view** (wireframe Q1, option a): an "En tránsito" `OutlinedButton.icon` in the list's `CatalogFilterBar` actions slot pushes `/inventory/transfers/in-transit`. That route is a top-level `GoRoute`, like the detail route, declared before `/:id` so `in-transit` is not read as an id. The `/inventory/transfers` prefix in `_routeGate` covers it.
  - **Compact tier** (wireframe Q9): no compact-specific work, as in 067 and 068.
- **Rationale**: This matches 067's R1/R3 and 068's R2. §VI forbids an AppBar shortcut but allows filter-row actions. The view is P3, so it doesn't need a fourth nav entry.
- **Touch points**:
  - `nav_destinations.dart`: the `NavBranch` value and a child of the `inventory` group.
  - `app_router.dart`: the branch, the detail and in-transit routes, and the `_routeGate` prefix.
  - Both `.arb` files: `navInventoryTransfers`.
  - `nav_destinations_test.dart`: the group's ordered child ids.
  - `app_router_test.dart`: the gate group.

## R3. Transfer status

- **Decision**: A domain `enum InventoryTransferStatus { draft, inTransit, received, cancelled }` in `domain/entities/inventory_transfer.dart`, mapped from the generated `TransferStatus` (wire values `draft`, `in_transit`, `received`, `cancelled`). It is not named `TransferStatus`, to avoid clashing with the generated type.
  - The chip is `InventoryTransferStatusChip` in `presentation/transfers/inventory_transfer_status_chip.dart`.
  - The labels are Borrador / En tránsito / Recibido / Cancelado (keys `inventoryTransferStatus*`).
  - The tones: draft neutral (`surfaceContainerHighest`), in transit `tertiaryContainer`, received `secondaryContainer` (the same as a confirmed receipt), cancelled `errorContainer`.
- **Rationale**: In transit is the state that still needs action. A tone distinct from received and draft makes it findable in the list. The other three tones match receipts and issues (FR-025).

## R4. List and filter

- **Decision**: `InventoryTransfersFilter` (freezed, in `presentation/transfers/`) with `InventoryTransferStatus? status` and `int? warehouseId`. Both are kept in the URL query as in 068 (`status=in_transit`, `warehouse=12`).
  - The repository passes `TransferStatus?` and `warehouse` to `listInventoryTransfers…Get`.
  - The server matches `warehouse` against the origin or the destination (`inventory_documents.py:802`), so the drawer label reads "Almacén (origen o destino)".
  - Page size is 20, newest first.
  - The columns: Folio | Origen | Destino | Sucursal | Estado | Creado por | Fecha.
- **Rationale**: FR-003 and FR-004. The summary carries both warehouse ids, so the list needs no extra calls beyond the cached name lookups.

## R5. Facility rule and wrong-end actions

- **Decision** (wireframe Q4, option a): Actions are gated by rights only, as the spec says (FR-020). The UI does not compare the user's facility with the origin's or the destination's. A non-administrator acting at the wrong end gets `facility.other_facility` in the banner.
- **Rationale**: The rule differs per step (dispatch and cancel: origin; receive: destination; close: either). Mirroring it would copy server logic that can change. The spec's edge cases accept the refusal. It can be revisited after the manual non-administrator checks.
- **Same-warehouse pre-check** (wireframe Q7): none in the dialogs. `inventory_transfer.same_warehouse` comes back from create and from the header update, and is shown in the dialog's `FormErrorBanner` (US2 #2).

## R6. Insufficient stock: which warehouse

- **Decision** (wireframe Q3): `inventory_document.insufficient_stock` carries `product_id`, `warehouse_id`, `requested` and `available` (mbe-api `inventory_documents.py:377`). It is reachable on **dispatch** (origin short) and on **cancel** (destination short, when the destination has used what it received). The detail screen keeps 068's extra line, "Producto: {code} · Almacén: {name}":
  - The product code is looked up from `product_id` among the transfer's lines, falling back to `#{id}`.
  - The warehouse name comes from the error's `warehouse_id` through `warehouseDisplayNameProvider`. It is not taken from the document, unlike 068, because it can be either end.
- **Rationale**: FR-013 and US6 #3 both name the product and warehouse. §III forbids using the server's English text, which names both.

## R7. Receive dialog

- **Decision** (wireframe Q10): `ReceiveTransferDialog` (`presentation/transfers/receive_transfer_dialog.dart`), a `ResponsiveDialog` with one row per line whose `quantityOutstanding > 0`:
  - Each row shows the code, the name, the outstanding quantity and a quantity `CompactField`.
  - Each `TextEditingController` starts with the outstanding quantity, formatted.
  - Input is parsed with `formattersProvider.field.parseQuantity`, as the delivery-order add-line step 2 does.
  - Validation, per row: empty or unparseable → field error; below 0 → field error; above outstanding → field error "Máximo {outstanding}". Recibir is disabled while any row has an error, or when every row is 0.
  - **Submit**: if every row still equals its outstanding quantity, call `receive(id)` with no body, which receives everything. Otherwise send `lines` holding every row above 0, the untouched rows included at their prefilled quantity. Sending only the changed rows would leave the untouched ones unreceived. One request either way.
  - **Refusal**: `inventory_transfer.over_received` (a concurrent receipt) and `inventory_transfer.not_in_transit` refresh the detail and close the dialog, with the banner on the detail. `facility.other_facility` and `lock.busy` stay in the dialog's `FormErrorBanner`.
- **Rationale**: No shared widget has editable quantity rows (agent survey). The delivery-order add-line step 2 is the closest pattern, a map of per-line controllers, but it submits row by row. Receive is a single atomic call, so one request is simpler and has no partial-failure state. Sending no body when nothing changed is the server's own "receive everything" path (04 §3).
- **Alternatives**: Editing quantities inline in the detail table was rejected, because it would add a second edit mode to a read-only table. Per-line steppers (the refund pattern) were rejected, because quantities can be fractional.

## R8. Fill from a sales order

- **Decision** (wireframe Q8, option a): `AddFromSalesOrderDialog` (`presentation/transfers/add_from_sales_order_dialog.dart`), a one-step dialog with a `CatalogEntityPicker<SalesOrderSummary>`. Its search calls `salesOrderRepositoryProvider.listOrders(status: SaleStatus.completed, search: digits, limit: 10)`.
  - It sends no customer and no facility, so the server limits the list to the caller's own facility.
  - Each option shows "{folio} · {customer} · {date}".
  - On success the snackbar reads "Se agregaron {n} productos al traspaso. Los que ya estaban no se modificaron.", with `n` = the new line count minus the old. When `n` is 0 it reads "Los productos del pedido ya estaban en el traspaso." The server doesn't report what it skipped, and this needs no count of the order's lines (FR-012, US8 #2).
  - `sales_order.not_confirmed` shows in the dialog banner.
  - The dialog needs read on sales orders (`SystemObject.salesOrders`) as well as update on 17.
- **Rationale**: The server's `status=completed` filter is `completed && !cancelled` (`sales_order_service.py:1202`), the same rule the add route checks (`inventory_transfer_service.py:366`). So the picker offers only orders the server accepts. The delivery-order picker is private and bound to a customer, so this is a small new dialog over the same repository call.

## R9. In-transit view

- **Decision**: `InTransitScreen` (`presentation/transfers/in_transit_screen.dart`) with `inTransitControllerProvider(facilityId)` calling `getInventoryInTransit…(facility:)`.
  - **Facility**: it starts on the user's facility, read from the auth session settings (`authProvider` → `user.settings?.facilityId`) through a private helper in the in-transit controller file, mirroring `_settings` in `inventory_warehouse_options.dart`. It does not use the sales POS `userFacilityIdProvider`. Administrators with read on facilities get an inline `CatalogEntityPicker<FacilityListItem>` over `facilityRepositoryProvider.list(search:)`, the delivery-orders list pattern, with a "Mi sucursal" reset. Non-administrators get no picker, and the title reads "En tránsito · {facility}".
  - **No facility**: an administrator without one starts with no request, and a prompt to choose. A non-administrator without one sees the shared `inventoryDocumentNoFacility` message, which receipts and issues already use. No request is sent, since the server would answer `facility.required`.
  - **Tables**: two unpaginated `DataTableView`s, "Por producto" (`products`) and "Por traspaso" (`lines`, ordered by transfer then product). A line row pushes `/inventory/transfers/{inventoryTransferId}`.
  - **Pagination** (wireframe Q6): none. The endpoint returns the whole set for one facility, and outstanding lines are few by nature. §VI's pagination rule targets unbounded datasets, and this one is bounded by the transfers in flight.
- **Rationale**: FR-018, FR-019 and US7. The facility switch is admin-only by spec decision, because the server would answer any facility to any reader.

## R10. Closed shortfall, legacy and cancelled drafts

- **Decision** (wireframe Q5, option a): No extra fact. After Cerrar pendiente the state is Recibido, and the lines show Recibido < Enviado with Pendiente 0.
  - A legacy transfer has `quantity_received` NULL, and the server already reports it as `quantity` once completed, so nothing special is needed.
  - A cancelled draft (no serial) keeps "Traspaso · Borrador #id" and the draft line table: the three-quantity table shows only when `serial != null`.
- **Rationale**: The server has no "closed" flag. Inferring one from line figures would misfire on legacy rows.

## R11. Error coverage

- **Decision**: Add messages (es and en) for the codes the transfer routes can return that are not yet localized:

  | Code | Params | Spanish |
  |---|---|---|
  | `inventory_transfer.same_warehouse` | — | "El almacén de origen y el de destino deben ser distintos." |
  | `inventory_transfer.not_in_transit` | — | "El traspaso no está en tránsito." |
  | `inventory_transfer.over_received` | `product_code`, `received`, `outstanding` | "{product_code}: se intentan recibir {received} y solo hay {outstanding} pendientes." |
  | `inventory_transfer.line_repeated` | `line_id` | "Una partida se recibe más de una vez." |
  | `sales_order.not_confirmed` | `sales_order_id` | "El pedido no está confirmado o está cancelado." |
  | validation type `inventory_transfer_duplicate_line` | — | "Una partida se recibe más de una vez." |

  Then switch their `code-scope.tsv` rows (L140–143, L225, L260) to `IN`, add fixtures to `problem_fixtures.dart`, and raise `expect(checked, 152)` to 157 in `catalog_coverage_test.dart`, which counts only `code` rows, so the validation type adds nothing there. Adding the validation type raises `hasLength(11)` to 12 in `localize_validation_type_test.dart`. `over_received` joins the `needParams` set.
  - Already localized and reused: `inventory_document.*`, `facility.no_in_transit_location`, `facility.required`, `facility.other_facility`, `warehouse.in_transit_location`, `document.not_editable`, `lock.busy`, `product.not_stockable`, `resource.not_found` (`inventory_transfer` and `sales_order` nouns exist) and `status_filter.unsupported`.
  - `warehouse.in_transit_managed` is not reachable from transfer routes. It is already localized anyway.
- **Rationale**: §III coverage requires a message for every code an endpoint the app starts calling can return. The `line_repeated` and validation-type paths are unreachable through the dialog, which sends each line once, but the rule counts reachable endpoints, not reachable paths.

## R12. Test fixtures and live verification

- **Decision**:
  - Unit and widget tests use mocktail fakes, with fixture builders in `test/unit/features/inventory/inventory_transfer_fixtures.dart`.
  - The live test `test/integration/inventory_transfers_live_test.dart` follows `inventory_issues_live_test.dart`. It discovers at run time:
    - two warehouses (W1 origin, W2 destination; a second facility's warehouse if one exists)
    - an active stockable product with available stock ≥ 5 at W1
    - a completed sales order with stockable lines
  - It checks stock with `StockApi` at W1 and W2 after:
    - dispatch (W1 −q, W2 unchanged)
    - a partial receipt (W2 +r)
    - the full receipt
    - close on a second transfer (W1 regains the remainder)
    - cancel on a third (both ends back)
  - It also checks:
    - the 409 on dispatch at available + 1
    - `inventory_transfer.same_warehouse`
    - `over_received`
    - `not_in_transit`
    - the in-transit view's lines for W1's facility
  - Writes run only with `MBE_WRITE=true` and are tagged `QA069 <n>`.
  - No seeded non-administrator has rights on 17. The non-administrator checks (own-facility origin picker, wrong-end refusals, no facility switch) stay manual, in a manual-checks issue after merge.
- **Dev-tenant prerequisite**: every facility used needs an in-transit warehouse. Otherwise dispatch answers `facility.no_in_transit_location`. That is itself a check worth recording.
