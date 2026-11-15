# Contract: mbe-api endpoints consumed

mbe-api owns these endpoints (mbe-api spec 026, mictlanix/mbe-roadmap#42). The normative source is mbe-api `specs/026-delivery-documents/contracts/delivery-documents.md`. This file records only what mbe-ui relies on.

**No mbe-api change is required** (constitution §III), and codegen is not re-run.

| Route | Generated method (`DeliveryOrdersApi`) | Gate |
|---|---|---|
| `GET /api/v1/delivery-orders/{delivery_order_id}/ticket?warehouse=` | `printDeliveryOrderTicketApiV1DeliveryOrdersDeliveryOrderIdTicketGet({required int deliveryOrderId, int? warehouse})` | DELIVERY_ORDERS (71) READ |
| `GET /api/v1/delivery-orders/{delivery_order_id}/document` | `printDeliveryOrderDocumentApiV1DeliveryOrdersDeliveryOrderIdDocumentGet({required int deliveryOrderId})` | DELIVERY_ORDERS (71) READ |

## Relied-on facts

| # | Fact | What breaks if it changes |
|---|---|---|
| E1 | A 200 response is `application/pdf`. The generated methods return `Future<Response<Uint8List>>` with `ResponseType.bytes`. | Corrupt PDFs. Guarded by `generated_client_bytes_test.dart` (research R10) |
| E2 | `Content-Disposition: inline; filename="entrega-{id:08d}.pdf"` / `orden-entrega-{id:08d}.pdf` | Only the download name. Falls back to `DocumentKind.fallbackFilename` |
| E3 | The server picks the pickup ticket for fulfillment type PICKUP and the delivery ticket otherwise | Nothing in mbe-ui. It never chooses (spec FR-022) |
| E4 | DRAFT and PENDING_APPROVAL → 409 `delivery_order.not_approved`. Every later status renders. CANCELLED renders stamped "CANCELADA" | Which orders offer print (research R3) |
| E5 | `warehouse` is only sent when it's set. When set, only that warehouse's lines print. An id that names no warehouse → 422 `delivery_order.unknown_warehouse`. A warehouse no line comes from → 422 `delivery_order.no_lines_from_warehouse` | The warehouse choice (spec FR-010–FR-013) |
| E6 | `/document` takes no warehouse and always prints every line | Spec FR-014 |
| E7 | Unknown id → 404 `resource.not_found`. Missing right → 403 `auth.forbidden`. No token → 401 | Shared error handling |
| E8 | Rendering is read-only. Nothing is recorded, and the order isn't changed | No reload after a print (spec FR-041) |

## Error codes and the messages this feature adds

These are the codes the two endpoints can return. They follow constitution §III and are detailed in research R9.

| Code | Status before | Status after |
|---|---|---|
| `delivery_order.not_approved` | OUT, no message | IN, fixed message es/en |
| `delivery_order.unknown_warehouse` | OUT, no message | IN, fixed message es/en |
| `delivery_order.no_lines_from_warehouse` | OUT, no message | IN, fixed message es/en |
| `resource.not_found` | IN | unchanged |
| `auth.forbidden` | IN | unchanged |

`specs/058-localized-api-errors/contracts/code-scope.tsv`: the three rows change to `IN`, and `catalog_coverage_test` changes from 110 to 113.

## Also read (already consumed by spec 061)

`GET /api/v1/delivery-orders/{id}` (`getById`) gives the lines' warehouses for a print started from the list row (research R4).
