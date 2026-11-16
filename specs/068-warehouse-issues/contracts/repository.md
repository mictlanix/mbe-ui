# Contract: InventoryIssueRepository

`lib/features/inventory/domain/repositories/inventory_issue_repository.dart`. It is implemented by `InventoryIssueRepositoryImpl(dio)` over the generated `InventoryIssuesApi(dio, appSerializers)` and exposed as `inventoryIssueRepositoryProvider`. Every method throws `AppError` (mapped from `DioException`) on failure.

| Method | Endpoint | Right (server) | Returns |
|---|---|---|---|
| `list({InventoryDocumentStatus? status, int? warehouseId, required int skip, required int limit})` | `GET /inventory-issues?status&warehouse&skip&limit` | Read 16 | `InventoryIssuePage` |
| `get(int id)` | `GET /inventory-issues/{id}` | Read 16 | `InventoryIssue` |
| `create({required int warehouseId, String? comment})` | `POST /inventory-issues` | Create 16 | `InventoryIssue` (draft) |
| `updateHeader(int id, {int? warehouseId, String? comment, bool clearComment = false})` | `PUT /inventory-issues/{id}` | Update 16 | `InventoryIssue` |
| `addLine(int id, {required int productId, required Decimal quantity})` | `POST /inventory-issues/{id}/lines` | Update 16 | `InventoryIssue` |
| `updateLine(int id, int lineId, {required Decimal quantity})` | `PUT /inventory-issues/{id}/lines/{lineId}` | Update 16 | `InventoryIssue` |
| `removeLine(int id, int lineId)` | `DELETE /inventory-issues/{id}/lines/{lineId}` | Update 16 | `InventoryIssue` |
| `confirm(int id)` | `POST /inventory-issues/{id}/confirm` | Update 16 | `InventoryIssue` |
| `cancel(int id)` | `POST /inventory-issues/{id}/cancel` | Delete 16 | `InventoryIssue` |

Notes:
- `status` goes on the wire as `draft` | `completed` | `cancelled`.
- `updateHeader` sends `warehouse` only when it is given. `clearComment` sends `comment: ""` (research R6).
- Quantities go on the wire as decimal strings.
- Every mutation returns the full issue. Controllers show it directly (FR-016).

## Actions notifier

`InventoryIssueActions` (`@Riverpod(keepAlive: true)`) wraps each mutation, as `InventoryReceiptActions` does. It returns `AppError?`, null on success. On success it writes the returned issue into `inventoryIssueDetailControllerProvider(id)` and invalidates the list family. `create` returns the new issue's id so the caller can navigate. Unlike receipts, there is no `complementary` method, and confirm and cancel return no warning flag.
