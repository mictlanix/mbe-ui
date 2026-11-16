# Contract: Error Messages (§III coverage)

These are the codes the 9 inventory-receipt endpoints can return, measured from mbe-api's `app/services/inventory_documents.py`, `inventory_receipt_service.py` and `warehouse_service.assert_sellable`, against `specs/036-localizable-error-codes/contracts/error-codes.md`. Codes that only other inventory documents raise (`inventory_count.confirmed_cannot_cancel`, `inventory_transfer.same_warehouse`, `warehouse.in_transit_managed`) cannot be reached from receipts and are left to the features that call those endpoints.

## Already localized (no change)

| Code | Where it arises |
|---|---|
| `resource.not_found` | unknown receipt, line or product |
| `auth.forbidden` | missing right |
| `document.not_editable` | editing or confirming a non-draft |
| `facility.other_facility` | non-administrator on another facility's receipt (confirm, cancel) |
| `warehouse.in_transit_location` | create or header with an in-transit warehouse |
| `lock.busy` | concurrent stock lock; retry |
| `request.malformed` (and other request.* codes) | body validation |

## New — add to `localizedErrorCodes`, the `localizeProblem` switch, `app_es.arb` and `app_en.arb`

| Code | Status | Params | es | en |
|---|---|---|---|---|
| `inventory_receipt.warehouse_fixed` | 409 | — | El almacén de una entrada de orden de compra no se puede cambiar. | A purchase order's receipt can't move to another warehouse. |
| `inventory_receipt.complementary_unavailable` (reason `no_purchase_order`) | 409 | reason | La entrada no está ligada a una orden de compra. | The receipt isn't linked to a purchase order. |
| … (reason `purchase_order_cancelled`) | | | La orden de compra está cancelada. | The purchase order is cancelled. |
| … (reason `purchase_order_not_completed`) | | | La orden de compra aún no está completada. | The purchase order isn't completed yet. |
| … (reason `purchase_order_fully_received`) | | | La orden de compra ya se recibió completa en este almacén. | The purchase order was already fully received in this warehouse. |
| … (unknown or missing reason) | | | No se puede crear una entrada complementaria para esta entrada. | No complementary receipt can be created for this receipt. |
| `inventory_document.insufficient_stock` | 409 | product_id, warehouse_id, requested, available | No hay existencias suficientes: se requieren {requested} y hay {available} disponibles. | Not enough stock: {requested} required, {available} available. |
| `inventory_document.no_lines` | 409 | resource | {Resource} no tiene partidas. | The {resource} has no lines. |
| `inventory_document.line_without_quantity` | 422 | product_code | La partida {product_code} no tiene cantidad. | Line {product_code} has no quantity. |
| `inventory_document.already_cancelled` | 409 | resource | {Resource} ya está cancelada. | The {resource} is already cancelled. |
| `product.not_stockable` | 422 | product_code | El producto {product_code} no maneja existencias. | Product {product_code} isn't stockable. |
| `facility.no_in_transit_location` | 422 | facility_ids | La sucursal no tiene almacén de tránsito configurado. | The facility has no in-transit location configured. |
| `status_filter.unsupported` | 422 | allowed | El filtro de estado no es válido. | The status filter isn't valid. |

Rules:
- `{Resource}` uses the existing `resourceNoun`/`resourceGender` helpers. `inventory_receipt` is already registered, so the message agrees in gender ("La entrada de almacén … cancelada").
- `{requested}` and `{available}` are formatted with `fmt.display.quantity`.
- A missing or mistyped param never fails (§III resilience). Following spec 058's convention, the five codes whose sentence needs a param (`inventory_document.already_cancelled`, `.insufficient_stock`, `.line_without_quantity`, `.no_lines`, `product.not_stockable`) have no message without it, and the shared message path falls back as it does for every such code; they are listed in `needParams`. The other four codes are fixed sentences. The server always sends these params. `test/unit/core/errors/catalog_coverage_test.dart` covers every new member in both locales.
- `insufficient_stock` on the detail screen: a line under the cancel refusal banner adds "Producto: {code}" (the shared `ErrorBanner` takes no extra lines) by looking up `product_id` in the receipt's lines (research R7). The shared message stays generic.
