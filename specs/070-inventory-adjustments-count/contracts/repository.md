# Contract: InventoryCountRepository ↔ endpoints

Interface: `lib/features/inventory/domain/repositories/inventory_count_repository.dart`.
Implementation: `lib/features/inventory/data/inventory_count_repository_impl.dart` (`inventoryCountRepositoryProvider`), over the generated `InventoryCountsApi`. `DioException` is mapped to `AppError` as in `inventory_issue_repository_impl.dart`, keeping the `ApiProblem` with its parts.

| Method | Endpoint | Body | Returns |
|---|---|---|---|
| `list({status, warehouseId, skip, limit})` | `GET /inventory-counts` | — | `InventoryCountPage(items, total)` |
| `get(id)` | `GET /inventory-counts/{id}` | — | `InventoryCount` |
| `create({warehouseId, comment})` | `POST /inventory-counts` | `CountCreate` | `InventoryCount` |
| `updateHeader(id, {warehouseId, comment})` | `PUT /inventory-counts/{id}` | `CountUpdate` | `InventoryCount` |
| `setLines(id, List<CountLineInput>)` | `PUT /inventory-counts/{id}/lines` | `CountLinesSet` (1–2,000 items) | `InventoryCount` |
| `updateLine(id, lineId, quantity)` | `PUT /inventory-counts/{id}/lines/{line_id}` | `CountLineUpdate` | `InventoryCount` |
| `removeLine(id, lineId)` | `DELETE /inventory-counts/{id}/lines/{line_id}` | — | `InventoryCount` |
| `confirm(id, {includeUncounted})` | `POST /inventory-counts/{id}/confirm` | `CountConfirm` | `CountConfirmResult(count, warnings)` |
| `cancel(id)` | `POST /inventory-counts/{id}/cancel` | — | `InventoryCount` |

Notes:
- `list` sends `status` as the wire name (`draft`, `completed`, `cancelled`) and `warehouse` only when set. The server decides the scope.
- `setLines` asserts 1 ≤ items ≤ 2,000. Splitting into batches is the caller's job (research R8).
- `CountLineInput` maps to `CountLineSet` with exactly one of `product` and `productCode`. Quantities go as decimal strings.
- `updateHeader` always sends `comment` (null clears it), as the issues repository does.
