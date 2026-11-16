# Contract: InventoryReceiptRepository

`lib/features/inventory/domain/repositories/inventory_receipt_repository.dart`. It is implemented by `InventoryReceiptRepositoryImpl(dio)` over the generated `InventoryReceiptsApi(dio, appSerializers)` and exposed as `inventoryReceiptRepositoryProvider`. Every method throws `AppError` (mapped from `DioException`) on failure.

| Method | Endpoint | Right (server) | Returns |
|---|---|---|---|
| `list({ReceiptStatus? status, int? warehouseId, required int skip, required int limit})` | `GET /inventory-receipts?status&warehouse&skip&limit` | Read 15 | `InventoryReceiptPage` |
| `get(int id)` | `GET /inventory-receipts/{id}` | Read 15 | `InventoryReceipt` |
| `create({required int warehouseId, String? comment})` | `POST /inventory-receipts` | Create 15 | `InventoryReceipt` (draft) |
| `updateHeader(int id, {int? warehouseId, String? comment, bool clearComment = false})` | `PUT /inventory-receipts/{id}` | Update 15 | `InventoryReceipt` |
| `addLine(int id, {required int productId, required Decimal quantity})` | `POST /inventory-receipts/{id}/lines` | Update 15 | `InventoryReceipt` |
| `updateLine(int id, int lineId, {required Decimal quantity})` | `PUT /inventory-receipts/{id}/lines/{lineId}` | Update 15 | `InventoryReceipt` |
| `removeLine(int id, int lineId)` | `DELETE /inventory-receipts/{id}/lines/{lineId}` | Update 15 | `InventoryReceipt` |
| `confirm(int id)` | `POST /inventory-receipts/{id}/confirm` | Update 15 | `InventoryReceipt` |
| `cancel(int id)` | `POST /inventory-receipts/{id}/cancel` | Delete 15 | `InventoryReceipt` |
| `complementary(int id)` | `POST /inventory-receipts/{id}/complementary` | Create 15 | `InventoryReceipt` (200 existing draft or 201 new) |

Notes:
- `status` goes on the wire as `draft` | `completed` | `cancelled`.
- `updateHeader` sends `warehouse` only when it is given. The `clearComment` behaviour follows research R8.
- Quantities go on the wire as decimal strings (`Quantity5`).
- Every mutation returns the full receipt. Controllers show it directly and invalidate the list (FR-019).

## Actions notifier

`InventoryReceiptActions` (`@Riverpod(keepAlive: true)`) wraps each mutation. It returns `AppError?` (null on success) and, on success, writes the returned receipt into `inventoryReceiptDetailControllerProvider(id)` and invalidates the list family.

`create` and `complementary` return the new receipt's id so the caller can navigate. `confirm` and `cancel` also return `hasUnmappedWarnings` for the cost notice (research R6).
