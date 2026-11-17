# Contract: Error Messages (§III coverage)

These are the codes the 13 inventory-transfer routes can return. They were measured from mbe-api's `app/services/inventory_transfer_service.py`, `app/services/inventory_documents.py`, `app/services/documents.py` and `app/api/v1/endpoints/inventory_transfers.py` (research R11).

## New (add to `localizedErrorCodes`, the `localizeProblem` switch, `app_es.arb`, `app_en.arb`, `problem_fixtures.dart`; flip `code-scope.tsv` to `IN`)

| Code | Status | Params | Route | es |
|---|---|---|---|---|
| `inventory_transfer.same_warehouse` | 422 | — | create, header | El almacén de origen y el de destino deben ser distintos. |
| `inventory_transfer.not_in_transit` | 409 | — | receive, close | El traspaso no está en tránsito. |
| `inventory_transfer.over_received` | 409 | `product_code`, `received`, `outstanding` | receive | {product_code}: se intentan recibir {received} y solo hay {outstanding} pendientes. |
| `inventory_transfer.line_repeated` | 422 | `line_id` | receive | Una partida se recibe más de una vez. |
| `sales_order.not_confirmed` | 409 | `sales_order_id` | sales-order-items | El pedido no está confirmado o está cancelado. |
| validation type `inventory_transfer_duplicate_line` | 422 | — | receive (body schema) | Una partida se recibe más de una vez. |

- `over_received` joins `needParams` in `catalog_coverage_test.dart`. Missing params fall back to the generic message (§III resilience).
- `received` and `outstanding` are formatted as quantities by the shared formatter.
- `catalog_coverage_test.dart`: `expect(checked, 152)` → `157`. It counts only `code` rows marked `IN`, so the 5 codes count and the validation type doesn't.
- `localize_validation_type_test.dart`: `hasLength(11)` → `12`, for the new validation type.

## Already localized, reused

| Code | Where it arises on transfers |
|---|---|
| `resource.not_found` | unknown transfer, line, product or sales order (`inventory_transfer`, `sales_order` nouns exist) |
| `auth.forbidden` | missing right |
| `document.not_editable` | header, line or sales-order edits and dispatch on a non-draft |
| `facility.other_facility` | non-administrator at the wrong end (dispatch, receive, close, cancel) |
| `facility.required` | in-transit view without a facility (the UI avoids sending it, research R9) |
| `facility.no_in_transit_location` | dispatch, receive, close or cancel when the facility has no in-transit warehouse |
| `warehouse.in_transit_location` | create or header with an in-transit warehouse |
| `lock.busy` | concurrent stock lock; retry |
| `request.*` | body validation |
| `inventory_document.insufficient_stock` | dispatch (origin short) and cancel (destination short) |
| `inventory_document.no_lines` | dispatch with no lines ("El traspaso no tiene partidas.") |
| `inventory_document.line_without_quantity` | dispatch with a zero-quantity legacy line |
| `inventory_document.already_cancelled` | cancel twice ("El traspaso ya está cancelado.") |
| `product.not_stockable` | add line, dispatch |
| `status_filter.unsupported` | list with an unsupported status |

## Screen-side enrichment (research R6)

On the detail screen, `inventory_document.insufficient_stock` on dispatch or cancel shows the shared message, then "Producto: {code} · Almacén: {warehouse name}".
- The code is looked up from `product_id` among the transfer's lines, falling back to `#{id}`.
- The warehouse name comes from the error's `warehouse_id` via `warehouseDisplayNameProvider`, falling back to `#{id}`.

New key: `inventoryTransferRefusalProductWarehouse` (es/en).
