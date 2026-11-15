# Data Model: Delivery Order Print

No new server data. This feature adds client-side types that route two existing documents through the spec 044 module. Decisions are in [research.md](research.md).

## DocumentKind (extended)

`lib/core/documents/domain/document_kind.dart`

| Value | gateObject | gateRight | fallbackFilename(id) |
|---|---|---|---|
| `deliveryTicket` | `SystemObject.deliveryOrders` (71) | read | `entrega-{id:08d}.pdf` |
| `deliveryOrderDocument` | `SystemObject.deliveryOrders` (71) | read | `orden-entrega-{id:08d}.pdf` |

`recordId` is the delivery order's **id**, not its folio (serial). The server's filename uses the id.

## DocumentRef (extended)

`lib/core/documents/domain/document_ref.dart`

| Field | Type | Rule |
|---|---|---|
| `kind` | `DocumentKind` | unchanged |
| `recordId` | `int` | unchanged, > 0 |
| `title` | `String` | unchanged |
| `warehouseId` | `int?` **new** | > 0 when set. Non-null only for `deliveryTicket` (assert) |

Equality and `hashCode` cover all four fields. Existing callers don't pass `warehouseId` and are unaffected.

## DeliveryTicketScope (new)

`lib/features/sales/presentation/delivery_orders/` (presentation-only value)

The chooser's result:

- `DeliveryTicketScope.all()`: every line, no `warehouse` query.
- `DeliveryTicketScope.warehouse(int id, String name)`: the ticket is limited to that warehouse, and `name` goes into the title.

When the chooser is dismissed it returns `null`, and nothing is fetched.

## Printability (derived)

`canPrintDeliveryOrder(AccessControlService access, DeliveryOrderStatus status)`

- **true** when the user holds Delivery Orders (71) read (administrators always do) **and** the status is any of: approved, readyForPickup, pickedUp, inPreparation, inTransit, delivered, partiallyDelivered, failed, cancelled.
- **false** for draft and pendingApproval.

## Order warehouses (derived)

`distinctWarehouses(List<DeliveryOrderLine> lines) → List<int>`: the distinct `warehouseId`s in first-appearance order.

| Count | Behaviour |
|---|---|
| 0 (no lines) | Preview opens unlimited. The server renders an empty body. Printable orders always have lines in practice |
| 1 | Preview opens unlimited, with no chooser (FR-011) |
| ≥ 2 | Chooser first (FR-010) |

Source:
- **Detail screen:** `DeliveryOrder.lines`, already loaded.
- **List row:** `DeliveryOrderAdminRepository.getById(id).lines`, looked up when the action is tapped.

## Existing entities used unchanged

- `DeliveryOrder`, `DeliveryOrderSummary`, `DeliveryOrderLine`, `DeliveryOrderStatus`, `FulfillmentType` (`lib/features/sales/domain/entities/delivery_order.dart`, `destination.dart`).
- `RenderedDocument{bytes, filename}`.
- `Warehouse` (names via `facilityWarehousesControllerProvider(facilityId)`).
