# Contract: InventoryTransferRepository

`lib/features/inventory/domain/repositories/inventory_transfer_repository.dart`. It is implemented by `InventoryTransferRepositoryImpl(dio)` over the generated `InventoryTransfersApi(dio, appSerializers)` and exposed as `inventoryTransferRepositoryProvider`. Every method throws `AppError` on failure, mapped from `DioException` as in 068's `_toAppError`.

| Method | Endpoint | Right (server) | Returns |
|---|---|---|---|
| `list({InventoryTransferStatus? status, int? warehouseId, required int skip, required int limit})` | `GET /inventory-transfers?status&warehouse&skip&limit` | Read 17 | `InventoryTransferPage` |
| `get(int id)` | `GET /inventory-transfers/{id}` | Read 17 | `InventoryTransfer` |
| `create({required int warehouseId, required int warehouseToId, String? comment})` | `POST /inventory-transfers` | Create 17 | `InventoryTransfer` (draft) |
| `updateHeader(int id, {int? warehouseId, int? warehouseToId, String? comment, bool clearComment = false})` | `PUT /inventory-transfers/{id}` | Update 17 | `InventoryTransfer` |
| `addLine(int id, {required int productId, required Decimal quantity})` | `POST /{id}/lines` | Update 17 | `InventoryTransfer` |
| `updateLine(int id, int lineId, {required Decimal quantity})` | `PUT /{id}/lines/{lineId}` | Update 17 | `InventoryTransfer` |
| `removeLine(int id, int lineId)` | `DELETE /{id}/lines/{lineId}` | Update 17 | `InventoryTransfer` |
| `addSalesOrderItems(int id, {required int salesOrderId})` | `POST /{id}/sales-order-items` | Update 17 | `InventoryTransfer` |
| `dispatch(int id)` | `POST /{id}/dispatch` | Update 17 | `InventoryTransfer` |
| `receive(int id, {Map<int, Decimal>? lines})` | `POST /{id}/receive` | Update 17 | `InventoryTransfer` |
| `close(int id)` | `POST /{id}/close` | Delete 17 | `InventoryTransfer` |
| `cancel(int id)` | `POST /{id}/cancel` | Delete 17 | `InventoryTransfer` |
| `inTransit({required int facilityId})` | `GET /inventory-transfers/in-transit?facility` | Read 17 | `InTransitView` |

Notes:
- `status` goes on the wire as the generated `TransferStatus` enum (typed, unlike issues' string).
- `updateHeader` sends only the fields given. `clearComment` sends `comment: ""`.
- `receive` with `lines == null` sends no body, which receives everything outstanding. Otherwise it sends `TransferReceive(lines: [TransferReceiveLine(lineId, quantity)])`, with the quantity as the string arm of `Quantity5`.
- Quantities go on the wire as decimal strings, as in 068.
- Every mutation returns the full transfer. Controllers show it directly (FR-023).

## Actions notifier

`InventoryTransferActions` (`@Riverpod(keepAlive: true)`) wraps each mutation, as `InventoryIssueActions` does.
- It returns `AppError?`, null on success.
- On success it writes the returned transfer into `inventoryTransferDetailControllerProvider(id)`, invalidates the transfers list family, and invalidates `inTransitControllerProvider` after dispatch, receive, close and cancel.
- `create` returns the new id.
- `addSalesOrderItems` returns `(AppError?, int addedCount)`, where `addedCount` = lines after minus lines before (research R8).
- Stale codes that refresh the detail: 068's set (`document.not_editable`, `inventory_document.already_cancelled`, `lock.busy`), plus `inventory_transfer.not_in_transit` and `inventory_transfer.over_received`.

## Controllers

- `inventoryTransfersListControllerProvider(InventoryTransfersFilter)`: paged, page size 20.
- `inventoryTransferDetailControllerProvider(int id)`: `refresh()`, `put(InventoryTransfer)`.
- `inTransitControllerProvider(int facilityId)`: a single load, with `refresh()`.
