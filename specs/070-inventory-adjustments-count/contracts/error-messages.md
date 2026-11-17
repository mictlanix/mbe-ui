# Contract: Error Messages (§III coverage)

These are the codes the 9 inventory-count routes can return, measured from mbe-api's `app/services/inventory_count_service.py`, `app/services/inventory_documents.py` (the `COUNT` kind) and `app/api/v1/endpoints/inventory_counts.py`.

## New codes (6)

Each is added to `localizedErrorCodes`, the `localizeProblem` switch (`lib/core/errors/localize_problem.dart`), `app_es.arb` and `app_en.arb`. `test/unit/core/errors/catalog_coverage_test.dart` covers them.

| Code | Where | es | en |
|---|---|---|---|
| `inventory_count.batch_invalid` | `PUT /lines` (422) | Algunos productos de la lista no se pueden registrar. Revisa los renglones marcados. | Some products in the list cannot be recorded. Check the marked rows. |
| `inventory_count.confirmed_cannot_cancel` | cancel a completed count (409) | Un conteo confirmado no se puede cancelar. Corrígelo con un conteo nuevo. | A confirmed count cannot be cancelled. Correct it with a new count. |
| `inventory_count_line.product_unknown` | batch part | El producto no existe. | The product does not exist. |
| `inventory_count_line.not_stockable` | batch part | El producto no es inventariable. | The product is not stockable. |
| `inventory_count_line.repeated` | batch part | El producto está repetido en la lista. | The product is repeated in the list. |
| `inventory_count_line.product_reference` | batch part (not reachable from this UI) | Indica el producto por su id o por su código, no ambos. | Name the product by its id or by its code, not both. |

The part messages carry no params. The paste dialog puts the code (from the part's `extra['product_code']`) and the row number in front of them (research R8). Quick entry and Agregar producto send one item, so a refusal there is a `batch_invalid` with one part. The screen shows **the part's message** (for example "El producto no existe.") with the typed code, not the batch-level text.

## New resource noun

`resource` = `inventory_count` (sent by `inventory_document.no_lines`, `facility.other_facility`, `inventory_document.already_cancelled`, `resource.not_found`):
- `apiResourceInventoryCount`: es "{count, plural, one{conteo} other{conteos}}", en "{count, plural, one{count} other{counts}}".
- `apiResourceGenderInventoryCount`: es masculine.

The existing gendered messages then read, for example, "El conteo no tiene partidas."

## Existing codes (already localized)

| Code | Where it arises on counts |
|---|---|
| `resource.not_found` | unknown count or line |
| `auth.forbidden` | missing right |
| `document.not_editable` | editing, setting lines on or confirming a non-draft |
| `facility.other_facility` | a non-administrator on another facility's count |
| `warehouse.in_transit_location` | create or header with an in-transit warehouse |
| `lock.busy` | the warehouse or count is held by another request; retry |
| `inventory_document.no_lines` | confirm with no lines after adding the uncounted ones |
| `inventory_document.already_cancelled` | cancel twice |
| `request.*` | body validation (for example a negative quantity, if the client check is bypassed) |
| `status_filter.unsupported` | list with an unsupported status |
