# Data Model: Warehouse Receipts (067)

The domain entities are freezed classes in `lib/features/inventory/domain/entities/inventory_receipt.dart`. They are mapped from the generated DTOs in `data/` and never reach `presentation` as DTOs (§III).

## ReceiptStatus

An enum: `draft`, `completed`, `cancelled`. It is mapped from `DocumentStatus`. The server never returns `paid` for a receipt; if it did, the mapper would throw a mapping error rather than guess.

| From | To | Action | Right |
|---|---|---|---|
| — | draft | create, complementary | Create (15) |
| draft | completed | confirm | Update (15) |
| draft | cancelled | cancel | Delete (15) |
| completed | cancelled | cancel (reverses stock) | Delete (15) |

## InventoryReceiptSummary (list row)

| Field | Type | From | Notes |
|---|---|---|---|
| id | int | `inventoryReceiptId` | |
| facilityId | int | `facility` | Name shown via `facilityDisplayNameProvider` |
| warehouseId | int | `warehouse` | Name shown via `warehouseDisplayNameProvider` |
| purchaseOrderId | int? | `purchaseOrder` | |
| serial | int? | `serial` | null until confirmed |
| status | ReceiptStatus | `status` | |
| creatorId | int | `creator` | An employee id; name shown via `employeeDisplayNameProvider` |
| createdAt | DateTime | `creationTime` | Displayed with `fmt.display.dateTime` |

`InventoryReceiptPage` = `CatalogPage<InventoryReceiptSummary>` (items, total, page index, page size).

## InventoryReceipt (detail)

The summary's fields, plus:

| Field | Type | From | Notes |
|---|---|---|---|
| comment | String? | `comment` | ≤ 500 chars; empty string is treated as no note |
| updaterId | int | `updater` | |
| modifiedAt | DateTime | `modificationTime` | |
| lines | List<InventoryReceiptLine> | `lines` | null maps to an empty list |
| serverWarningCount | int | `warnings.length` | Only the count is kept; the text is never shown (FR-015a) |

Derived values:
- `displayFolio` = `serial` when set, or `"Borrador #{id}"` for a draft (FR-004, FR-004a). The list's Folio column and the detail title both use it.
- `isDraft` = `status == draft`.
- `isLinked` = `purchaseOrderId != null`.
- `overReceipts` = `computeOverReceipts(lines)`.
- `hasUnmappedWarnings` = `serverWarningCount > overReceipts.length`. It is read only from a confirm or cancel response.

## InventoryReceiptLine

| Field | Type | From | Notes |
|---|---|---|---|
| id | int | `receiptDetailId` | |
| productId | int | `product` | |
| productCode | String? | `productCode` | Snapshot from when the line was added |
| productName | String? | `productName` | Snapshot |
| quantity | Decimal | `quantity` (string) | > 0 |
| purchaseOrderLineId | int? | `purchaseOrderDetail` | null for a line added by hand |
| quantityOrdered | Decimal | `quantityOrdered` | Shown only when linked (0 on hand-added lines) |
| quantityReceivedElsewhere | Decimal? | `quantityReceivedElsewhere` | Shown only when linked |

Quantities use the decimal type the app already uses for quantities, and are parsed from the wire string in the mapper.

## OverReceipt (derived, FR-015)

`lib/features/inventory/domain/over_receipt.dart`

| Field | Type |
|---|---|
| productCode | String (falls back to the product id as text) |
| received | Decimal (elsewhere + this receipt's sum for the order line) |
| ordered | Decimal |
| excess | Decimal (received − ordered, > 0) |

`computeOverReceipts(lines)`:
1. Keep the lines with `purchaseOrderLineId != null`.
2. Group them by `purchaseOrderLineId`, in first-seen order.
3. For each group: `sum = Σ quantity`, `elsewhere = first.quantityReceivedElsewhere ?? 0`, `ordered = first.quantityOrdered`, `received = elsewhere + sum`.
4. Emit an `OverReceipt` when `received > ordered`.

Unit cases:
- No linked lines gives no warnings.
- Exactly at ordered gives none.
- Above ordered gives one, with the correct excess.
- Two lines on the same order line are summed.
- Elsewhere quantities are counted.
- A null elsewhere counts as 0.

## Validation mirrored in the UI

| Rule | Where | Server code if it slips through |
|---|---|---|
| Quantity > 0 | add-line and quantity dialogs | request validation (`request.malformed`) |
| Notes ≤ 500 chars | new-receipt and header dialogs (`maxLength`) | request validation |
| Warehouse required on create | new-receipt dialog | request validation |
| Non-administrators pick only their own facility's warehouses | new-receipt and header pickers (`facilityId` = the user's facility) | `facility.other_facility`, on confirm or cancel |
| Warehouse fixed on a PO-linked receipt | header dialog shows it read-only | `inventory_receipt.warehouse_fixed` |
| Product stockable | picker filter `stockable: true` | `product.not_stockable` |
| Edits only on drafts | actions absent unless `isDraft` | `document.not_editable` |

The server-only rules (in-transit warehouse, no lines, insufficient stock on cancel, the facility rule, complementary availability) are shown from their codes (contracts/error-messages.md).

## Action availability (detail screen)

| Action | Shown when |
|---|---|
| Editar encabezado | `can(15, update)` && `isDraft` |
| Agregar producto | `can(15, update)` && `isDraft` && `can(products, read)` |
| ✎ / 🗑 on a line | `can(15, update)` && `isDraft` |
| Confirmar | `can(15, update)` && `isDraft` |
| Cancelar | `can(15, delete)` && status ≠ cancelled |
| Entrada complementaria | `can(15, create)` && `isLinked` && status ≠ cancelled |

The facility rule is not mirrored. The server refuses with `facility.other_facility` (FR-017).
