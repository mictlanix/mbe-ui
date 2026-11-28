# Contract: PurchaseOrderRepository

Interface in `lib/features/purchases/domain/repositories/purchase_order_repository.dart`; implementation `PurchaseOrderRepositoryImpl` in `lib/features/purchases/data/purchase_order_repository_impl.dart` over the generated `PurchaseOrdersApi(dio, appSerializers)`, exposed as `purchaseOrderRepositoryProvider`. Every method throws `AppError` (`_toAppError` / `mapDioException`, as the request repository does) on failure.

| Method | Endpoint | Right (server) | Returns |
|---|---|---|---|
| `list(PurchaseOrdersFilter, {skip, limit})` | `GET /purchase-orders` (`all`, `status`, `supplier`, `creator`, `id`, `from`, `to`) | read 20 | `PurchaseOrderPage` |
| `get(id)` | `GET /purchase-orders/{id}` | read 20 | `PurchaseOrder` (no receipts until mbe-api#355) |
| `create({supplierId, estimatedReceiptDate?, comment?})` | `POST /purchase-orders` | create 20 | `PurchaseOrder` |
| `updateHeader(id, {supplierId?, estimatedReceiptDate?, clearDate, comment?, clearComment})` | `PUT /purchase-orders/{id}` | update 20 | `PurchaseOrder` |
| `addLine(id, {productId, quantity})` | `POST /purchase-orders/{id}/lines` | update 20 | `PurchaseOrder` |
| `updateLine(id, lineId, {quantity?, warehouseId?, price?, taxRate?})` | `PUT /purchase-orders/{id}/lines/{lineId}` | update 20 | `PurchaseOrder` |
| `removeLine(id, lineId)` | `DELETE /purchase-orders/{id}/lines/{lineId}` | update 20 | `PurchaseOrder` |
| `addRequestLines(id, {requestId})` | `POST /purchase-orders/{id}/request-lines` | update 20 | `PurchaseOrder` (with `skippedCount`) |
| `confirm(id)` | `POST /purchase-orders/{id}/confirm` | update 20 | `PurchaseOrder` (with `receipts`) |
| `cancel(id)` | `POST /purchase-orders/{id}/cancel` | delete 20 | `PurchaseOrder` |
| `toPurchase({facilityId?})` | `GET /purchase-orders/to-purchase` | read 20 | `List<ToPurchaseGroup>` |
| `createFromGroup({supplierId, facilityId})` | `POST /purchase-orders/to-purchase` | create 20 | `PurchaseOrder` (with `skippedCount`) |
| `email(id, {recipients, message?})` | `POST /purchase-orders/{id}/email` (`to` 1–10, `message` ≤ 1000) | update 20 | `OrderEmailReceipt` |

Printing does not go through this repository: `DocumentKind.purchaseOrder` in `lib/core/documents/` calls `GET /purchase-orders/{id}/document` (research R13).

Not used: `GET /cost-changes` (out of scope), `GET /{id}/payments` (roadmap#75).

Notes:
- `quantity`, `price` and `taxRate` are `Decimal`, sent with the shared `AnyOf2<String, num>` setter pattern (research R8).
- `updateHeader` sends `supplier` only when changed; `clearComment` sends `comment: ""`; `clearDate` sends an explicit `estimated_receipt_date: null`, through a raw `dio.put` if the generated serializer omits nulls (research R7).
- `updateLine` sends only changed fields; the server ignores `null`.
- `warnings` and `skipped[].reason` are not surfaced (research R10).
