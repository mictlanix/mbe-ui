# Contract: Error Messages (§III coverage)

These are the codes the 9 inventory-issue routes can return, measured from mbe-api's `app/services/inventory_documents.py` (shared with receipts) and `warehouse_service`. The list matches 067's [error-messages contract](../../067-warehouse-receipts/contracts/error-messages.md) without the two receipt-only codes (`inventory_receipt.warehouse_fixed`, `inventory_receipt.complementary_unavailable`).

**No new codes.** Every code below is already in `localizedErrorCodes`, the `localizeProblem` switch, `app_es.arb` and `app_en.arb`.

| Code | Where it arises on issues |
|---|---|
| `resource.not_found` | unknown issue, line or product |
| `auth.forbidden` | missing right |
| `document.not_editable` | editing or confirming a non-draft |
| `facility.other_facility` | non-administrator on another facility's issue (confirm, cancel) |
| `warehouse.in_transit_location` | create or header with an in-transit warehouse |
| `lock.busy` | concurrent stock lock; retry |
| `request.*` | body validation |
| `inventory_document.insufficient_stock` | **confirm**, when available stock is short (on receipts it arises only on cancel) |
| `inventory_document.no_lines` | confirm with no lines ("La salida de almacén no tiene partidas.") |
| `inventory_document.line_without_quantity` | confirm with a zero-quantity legacy line |
| `inventory_document.already_cancelled` | cancel twice ("La salida de almacén ya está cancelada.") |
| `product.not_stockable` | add line, confirm |
| `facility.no_in_transit_location` | confirm or cancel when the facility has no transit warehouse (the serial lock) |
| `status_filter.unsupported` | list with an unsupported status |

The resource noun and its gender for `inventory_issue` (`apiResourceInventoryIssue`, `apiResourceGenderInventoryIssue` = feminine) already exist.

## Screen-side enrichment (research R5)

On the detail screen, an `inventory_document.insufficient_stock` refusal on confirm shows the shared message (with `requested` and `available`), then one extra line: "Producto: {code} · Almacén: {warehouse name}".
- The code is looked up from `product_id` among the issue's lines, falling back to `#{id}`.
- The warehouse is the issue's own, from `warehouseDisplayNameProvider`.

The shared message stays generic. New `.arb` keys: `inventoryIssueRefusalProductWarehouse` (es/en).
