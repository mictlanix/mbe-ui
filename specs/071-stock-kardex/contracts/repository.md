# Contract: Stock and Kardex repositories ↔ endpoints

Interfaces: `lib/features/inventory/domain/repositories/stock_repository.dart` and `kardex_repository.dart`.
Implementations: `lib/features/inventory/data/stock_repository_impl.dart` (`stockRepositoryProvider`, over `StockApi`) and `kardex_repository_impl.dart` (`kardexRepositoryProvider`, over `KardexApi`), both built with `appSerializers`. `DioException` is mapped to `AppError` as in `inventory_issue_repository_impl.dart`.

| Method | Endpoint | Params | Returns |
|---|---|---|---|
| `StockRepository.list({warehouseId, q, includeZero, skip, limit})` | `GET /stock` | `warehouse` (required), `q` (only when non-empty), `include_zero`, `skip`, `limit` (≤ 500) | `StockPage(items, total)` |
| `StockRepository.product(productId)` | `GET /stock/products/{product}` | — | `ProductStock` |
| `KardexRepository.read({productId, warehouseId, from, to})` | `GET /kardex` | `product`, `warehouse`, `from`, `to` (all required; dates as `Date`) | `Kardex` |

Notes:
- The repositories don't validate the range. The presentation layer checks it first (research R4), and the server's `kardex.*` codes still come back as coded `AppError`s.
- A 422 `warehouse.in_transit_location` from `list` becomes a coded `AppError`. The screen shows it through `CatalogListStateView`'s error state.
- Quantities parse with `Decimal.parse`.
