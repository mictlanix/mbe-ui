# Contract: Error Messages (§III coverage)

These are the codes the 14 purchase-request endpoints can return, read from mbe-api `app/services/purchase_request_service.py`, `inventory_documents.assert_facility` and `warehouse_service.assert_sellable`. The generated enum spells the dot as `Period` (`purchase_request.not_draft` → `purchaseRequestPeriodNotDraft`). The `purchase_order.*` codes are left to the purchase-orders spec (#71).

## Already localized (no change)

| Code | Where it arises |
|---|---|
| `resource.not_found` | unknown request, line or product |
| `auth.forbidden` | missing right |
| `facility.other_facility` | non-administrator editing, submitting or cancelling another facility's request (the UI hides those, research R12) |
| `facility.no_in_transit_location` | submit when the facility has no transit warehouse to lock |
| `warehouse.in_transit_location` | create, header or line with an in-transit warehouse |
| `warehouse.required` | create with no warehouse and no point-of-sale warehouse |
| `status_filter.unsupported` | list with a bad state |
| `lock.busy` | concurrent submit or cancel; retry |
| `request.*` | body validation (reason length, ids count) |

## New: add to `localizedErrorCodes`, the `localizeProblem` switch, `app_es.arb` and `app_en.arb`

| Code | Status | Params | es | en |
|---|---|---|---|---|
| `purchase_request.not_draft` | 409 | status | Solo se puede modificar o enviar una solicitud en borrador. | Only a draft request can be changed or submitted. |
| `purchase_request.not_submitted` | 409 | status | La solicitud ya no está enviada; alguien más la aprobó, rechazó o canceló. | The request is no longer submitted; someone else approved, rejected or cancelled it. |
| `purchase_request.no_lines` | 409 | — | La solicitud no tiene partidas. | The request has no lines. |
| `purchase_request.line_without_quantity` | 409 | line_id | Una partida de la solicitud no tiene cantidad. | A line of the request has no quantity. |
| `purchase_request.facility_locked` | 409 | — | Una solicitud con folio solo puede cambiar a un almacén de su misma sucursal. | A numbered request can only move to a warehouse of its own facility. |
| `purchase_request.warehouse_facility_changed` | 409 | — | El almacén cambió de sucursal mientras se guardaba. Intenta de nuevo. | The warehouse changed facility while saving. Try again. |
| `purchase_request.already_cancelled` | 409 | — | La solicitud ya está cancelada. | The request is already cancelled. |
| `purchase_request.lines_on_live_order` | 409 | count | {count, plural, =1{Una partida de la solicitud está} other{{count} partidas de la solicitud están}} en una orden de compra vigente. | {count, plural, =1{One line of the request is} other{{count} lines of the request are}} on a live purchase order. |
| `purchase_request.lines_not_markable` | 409 | status | Solo se pueden marcar partidas de una solicitud enviada o aprobada. | Lines can be marked only on a submitted or approved request. |
| `purchase_request.line_on_live_order` | 409 | line_id | La partida está en una orden de compra vigente y no se puede desmarcar. | The line is on a live purchase order and can't be unmarked. |
| `product.not_purchasable` | 422 | product_id, product_code | El producto {product_code} no se puede comprar. | Product {product_code} isn't purchasable. |

Rules:
- `purchase_request.lines_on_live_order` and `product.not_purchasable` need their param; they go in `needParams`, and the shared path falls back without it, as spec 058 set up. The other nine are fixed sentences; their `status` and `line_id` params are not used.
- On the detail screen, `purchase_request.line_on_live_order` names the order: the banner adds "Orden de compra {n}" by looking up `line_id` among the request's lines (presentation-side, like 067's "Producto:" line). The shared message stays generic.
- The bulk approval result localizes each refused id's `code` + `params` with the same `localizeProblem`; in practice `purchase_request.not_submitted` and `resource.not_found`.
- `test/unit/core/errors/catalog_coverage_test.dart` covers all 11 in both locales.
