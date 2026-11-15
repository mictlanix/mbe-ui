# Data Model: For Delivery Queue

**Spec**: [spec.md](./spec.md) | **Research**: [research.md](./research.md)

All types are client-side views of `GET /delivery-itineraries/deliveries` (research R1). Nothing is persisted (§VII).

## 1. `PendingDeliveryPeriod` (enum, domain)

| Value | Server key | Label (es) | Has date |
|---|---|---|---|
| `earlier` | `earlier` | Anteriores | no |
| `yesterday` | `yesterday` | Ayer | yes |
| `today` | `today` | Hoy | yes |
| `tomorrow` | `tomorrow` | Mañana | yes |
| `dayAfter` | `day_after` | Pasado mañana | yes |
| `later` | `later` | Posteriores | no |

- Declaration order is the display order (FR-002).
- `key` is the server's bucket key and the URL facet value (R3).
- `fromKey(String?)` returns `today` for null or unknown input.
- A bucket key the client doesn't know is ignored when mapping.

## 2. `PendingDeliveryLine` (domain entity)

| Field | Type | From | Notes |
|---|---|---|---|
| `deliveryOrderId` | int | `delivery_order` | row tap target |
| `lineId` | int | `delivery_order_detail` | row key |
| `serial` | int? | `serial` | folio; null shows the placeholder |
| `customerId` | int | `customer` | name via lookup (R7) |
| `shipToId` | int? | `ship_to` | address via lookup (R7); null shows the placeholder |
| `scheduledDate` | DateTime? | `date` | null shows "Sin fecha" (FR-005) |
| `priority` | int | `priority` | right-aligned |
| `productId` | int | `product` | not shown |
| `productCode` | String | `product_code` | shown with the name |
| `productName` | String | `product_name` | |
| `warehouseId` | int | `warehouse` | name via lookup (R7) |
| `openQuantity` | String | `open_quantity` | decimal string, shown through `formattersProvider.display.quantity` |

## 3. `PendingDeliveryPeriodSummary` and `PendingDeliveriesView` (presentation)

`PendingDeliveryPeriodSummary`: `period`, `date` (DateTime?, from the bucket), `total` (int).

`PendingDeliveriesView`, the controller's state (R4):

| Field | Type | Notes |
|---|---|---|
| `periods` | `List<PendingDeliveryPeriodSummary>` | all six, display order; feeds the panel counts (FR-003) |
| `page` | `CatalogPage<PendingDeliveryLine>` | the selected period's page and total (FR-006) |

`LastPendingDeliverySummaries` (keep-alive) holds the `periods` of the last successful load, so the panel's counts survive a period change (research R5).

The bucket `date` arrives as the generated `Date?` type, not `DateTime?`; the repository converts it (`Date.toDateTime()` or the equivalent) when mapping.

The repository returns `PendingDeliveriesResult`: `Map<PendingDeliveryPeriod, (DateTime? date, int total, List<PendingDeliveryLine> items)>`, from which the controller builds the view.

## 4. `PendingDeliveriesFilter` (presentation, freezed)

| Field | Type | Default | URL |
|---|---|---|---|
| `period` | `PendingDeliveryPeriod` | `today` | facet `period`, omitted when `today` |
| `pageIndex` | int | 0 | `page` (1-based in the URL, as elsewhere) |

- `fromQuery(ListQuery)`, `toQuery()`.
- `activeFilterCount` = `period == today ? 0 : 1`. `isNarrowed` = `activeFilterCount > 0`.
- `cleared()` = default filter.

## 5. Rights

| Surface | Right |
|---|---|
| Nav entry, route | ForDeliver (91) read |
| Row tap → order detail | DeliveryOrders (71) read |
| Customer name, ship-to address | Customers read (else `#id` / placeholder) |
| Warehouse name | Warehouses read (else `#id`) |
