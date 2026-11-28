# Contract: Error Messages (§III coverage)

The codes the purchase-order endpoints can return, read from mbe-api `app/services/purchase_order_service.py`, `app/api/v1/endpoints/purchase_orders.py`, `inventory_documents.busy_as_conflict` and `warehouse_service.assert_sellable`. The generated enum spells the dot as `Period` (`purchase_order.no_lines` → `purchaseOrderPeriodNoLines`).

## Already localized (no change)

| Code | Where it arises |
|---|---|
| `resource.not_found` | unknown order, line, supplier, product or request |
| `auth.forbidden` | missing right |
| `document.not_editable` | editing a confirmed or cancelled order (stale screen) |
| `product.not_purchasable` | adding a product that isn't purchasable |
| `warehouse.in_transit_location`, `warehouse.in_transit_managed` | a line's warehouse is in transit |
| `warehouse.required` | adding a line when the user has no point-of-sale warehouse |
| `status_filter.unsupported` | list with a bad state |
| `lock.busy` | concurrent confirm, cancel or line ordering; retry |
| `email.send_failed` (502) | mail server refused the send |
| `email.not_configured` (503) | mail not configured |
| `request.*` | body validation (quantity, price, tax rate, notes length, recipients, message length, date in the past) |

## New: add to `localizedErrorCodes`, the `localizeProblem` switch, `app_es.arb` and `app_en.arb`

| Code | Status | es | en |
|---|---|---|---|
| `purchase_order.no_supplier` | 409 | La orden no tiene proveedor. | The order has no supplier. |
| `purchase_order.no_lines` | 409 | La orden no tiene partidas. | The order has no lines. |
| `purchase_order.line_without_quantity` | 409 | Todas las partidas deben tener una cantidad mayor que cero. | Every line must have a quantity above zero. |
| `purchase_order.already_cancelled` | 409 | La orden ya está cancelada. | The order is already cancelled. |
| `purchase_order.confirmed_cannot_cancel` | 409 | Una orden confirmada no se puede cancelar. | A confirmed order cannot be cancelled. |
| `purchase_order.not_confirmed` | 409 | Solo se puede imprimir o enviar una orden confirmada. | Only a confirmed order can be printed or emailed. |
| `purchase_order.nothing_pending` | 409 | No hay partidas pendientes por comprar para ese proveedor y sucursal. | There are no pending lines to order for that supplier and facility. |
| `purchase_order.nothing_to_add` | 409 | La solicitud no tiene partidas pendientes por comprar. | The request has no pending lines to order. |
| `purchase_order.request_not_approved` | 409 | La solicitud no está aprobada. | The request is not approved. |

None carries params the message needs. Stale-state codes (`already_cancelled`, `confirmed_cannot_cancel`, `not_confirmed`, `document.not_editable`, `lock.busy`) also make the detail re-fetch (research R17).
