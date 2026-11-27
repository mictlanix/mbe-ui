# Contract: PurchaseRequestRepository

Interface in `lib/features/purchases/domain/repositories/purchase_request_repository.dart`; implementation `PurchaseRequestRepositoryImpl` in `lib/features/purchases/data/purchase_request_repository_impl.dart` over the generated `PurchaseRequestsApi(dio, appSerializers)`, exposed as `purchaseRequestRepositoryProvider`. Every method throws `AppError` (from `mapDioException`) on failure.

| Method | Endpoint | Right (server) | Returns |
|---|---|---|---|
| `list(PurchaseRequestsFilter, {skip, limit})` | `GET /purchase-requests` (`all`, `status`, `facility`, `warehouse`, `creator`, `serial`, `from`, `to`) | read 86 | `PurchaseRequestPage` |
| `approvalQueue({facilityId, skip, limit})` | `GET /purchase-requests/approval-queue` | read 96 | `PurchaseRequestPage` |
| `get(id)` | `GET /purchase-requests/{id}` | read 86 | `PurchaseRequest` |
| `create({warehouseId, comment})` | `POST /purchase-requests` | create 86 | `PurchaseRequest` |
| `updateHeader(id, {warehouseId?, comment?, clearComment})` | `PUT /purchase-requests/{id}` | update 86, facility | `PurchaseRequest` |
| `addLine(id, {productId})` | `POST /purchase-requests/{id}/lines` | update 86, facility | `PurchaseRequest` |
| `updateLine(id, lineId, {quantity?, productName?, warehouseId?})` | `PUT /purchase-requests/{id}/lines/{lineId}` | update 86, facility | `PurchaseRequest` |
| `removeLine(id, lineId)` | `DELETE /purchase-requests/{id}/lines/{lineId}` | update 86, facility | `PurchaseRequest` |
| `submit(id)` | `POST /purchase-requests/{id}/submit` | update 86, facility | `PurchaseRequest` |
| `cancel(id)` | `POST /purchase-requests/{id}/cancel` | delete 86, facility | `PurchaseRequest` |
| `markLine(id, lineId, {toPurchase})` | `PUT /purchase-requests/{id}/lines/{lineId}/to-purchase` | update 20 | `PurchaseRequest` |
| `approve(id)` | `POST /purchase-requests/{id}/approve` | update 96 | `PurchaseRequest` |
| `approveMany(ids)` | `POST /purchase-requests/approve` (`ids`, 1–100) | update 96 | `List<BulkApproveOutcome>` |
| `reject(id, reason)` | `POST /purchase-requests/{id}/reject` (`reason`, 1–500) | update 96 | `PurchaseRequest` |

Notes:
- `quantity` is a `Decimal`, sent as `Quantity6` through the shared setter pattern (research R6).
- `updateHeader` sends `warehouse` only when it changed and `comment: ""` when cleared (research R8).
- `approveMany` never throws for a per-id refusal; only a whole-call failure (network, 403, 422 on the id count) throws.
- The server's `warnings` are not surfaced (research R7).
