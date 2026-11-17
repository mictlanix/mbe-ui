# Data Model: Stock and Kardex (071)

Domain entities are freezed and live in `lib/features/inventory/domain/`. Quantities are `Decimal` (the wire carries strings) and are formatted by `formattersProvider`. Nothing here is written: every entity is read-only.

## Entities

### StockRow (Existencias row, and one warehouse in the product view)

| Field | Type | From `StockRow` |
|---|---|---|
| productId | int | `product` |
| productCode | String | `productCode ?? ''` |
| productName | String | `productName ?? ''` |
| warehouseId | int | `warehouse` |
| onHand | Decimal | `onHand` |
| reserved | Decimal | `reserved` |
| available | Decimal | `available` |
| incoming | Decimal | `incoming` |

`StockPage` holds `{items, total}`.

### ProductStock (product view)

| Field | Type | From `ProductStock` |
|---|---|---|
| productId | int | `product` |
| warehouses | `List<StockRow>` | `warehouses` (null → empty) |
| inTransit | `List<InTransitStock>` | `inTransit` (null → empty) |

Derived values:
- `totals`: the four figures summed over `warehouses`.
- `isEmpty`: true when both lists are empty.

### InTransitStock

`{facilityId, warehouseId, onHand: Decimal}`, from `InTransitStock` (`facility`, `warehouse`, `on_hand`).

### Kardex

| Field | Type | From `Kardex` |
|---|---|---|
| productId | int | `product` |
| warehouseId | int | `warehouse` |
| from, to | Date (`DateTime` at midnight) | `from`, `to` |
| opening | Decimal | `opening` |
| movements | `List<KardexMovement>` | `rows` (null → empty) |
| totalIn, totalOut | Decimal | `totalIn`, `totalOut` |
| closing | Decimal | `closing` |

### KardexMovement

| Field | Type | From `KardexRow` |
|---|---|---|
| id | int | `lotSerialTrackingId` |
| date | DateTime | `date` (wall clock, through `appSerializers`) |
| sourceType | int | `source_` |
| reference | int | `reference` (0 means no document) |
| quantityIn | Decimal | `quantityIn` |
| quantityOut | Decimal | `quantityOut` |
| balance | Decimal | `balance` |
| document | `KardexDocumentRef?` | `document` |

`sourceName` is not mapped, because it is server text (§III). The label comes from `sourceType` (research R5).

### KardexDocumentRef

`{type: int, id: int, facilityId: int?, serial: int?}`, from `KardexDocument`.

### KardexSelection (presentation, URL state)

`{productId?, warehouseId?, from, to}`. Its `from` and `to` default to today − 29 days through today.

| Check | Result |
|---|---|
| product or warehouse missing | `incomplete` (prompt, no request) |
| `to < from` | `reversed` (localized text, no request) |
| `(to − from).days + 1 > 366` | `tooLong` (localized text, no request) |
| otherwise | `ready` |

### StockQuery (presentation, URL state)

`{warehouseId?, q, includeZero (default false), pageIndex}`, carried by `ListQuery` (research R7).

## Source mapping (research R5)

`kardexSourceLabel(l10n, type)` gives the Spanish label for each source type.

`kardexDocumentRoute(ref, access)` gives the path to push, or null when the type has no screen or the user lacks the read right on it:

| Type | Route | Gate |
|---|---|---|
| 1 | `/sales/orders/{id}` | SalesOrders read |
| 2 | `/sales/refunds/{id}` | CustomerRefunds read |
| 3 | `/inventory/issues/{id}` | InventoryIssues read |
| 4 | `/inventory/receipts/{id}` | InventoryReceipts read |
| 8 | `/inventory/receipts/{id}` | InventoryReceipts read |
| 5 | `/inventory/transfers/{id}` | InventoryTransfers read |
| 12 | `/inventory/counts/{id}` | PhysicalCountAdjustment read |
| 13 | `/sales/delivery-orders/{id}` | DeliveryOrders read |
| 6, 10 or any other | none | — |

## Rights

| Surface | Needs |
|---|---|
| Existencias (nav, route, list) | WarehouseStockReport (67) read |
| Product view | 67 read |
| Kardex (nav, route) | Kardex (32) read |
| "Ver kardex" row action | 32 read |
| "Ver existencias" on product detail (View mode, existing product) | 67 read |
| Warehouse pickers | Warehouses (4) read |
| Kardex product picker | Products read |
| A movement's link | that document type's read right (table above) |
