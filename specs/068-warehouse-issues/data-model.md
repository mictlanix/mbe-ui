# Data Model: Warehouse Issues (068)

Domain entities are freezed classes in `lib/features/inventory/domain/entities/inventory_issue.dart`. They are mapped from the generated DTOs in `data/` and never reach `presentation` as DTOs (§III).

## InventoryDocumentStatus (shared, moved from 067)

`lib/features/inventory/domain/entities/inventory_document_status.dart`. An enum: `draft`, `completed`, `cancelled`. It replaces 067's `ReceiptStatus` (research R1). It is mapped from `DocumentStatus`. `paid` is never returned for an inventory document, and if it were, the mapper throws rather than guess.

| From | To | Action | Right |
|---|---|---|---|
| — | draft | create | Create (16) |
| draft | completed | confirm (takes stock out; refused when available stock is short) | Update (16) |
| draft | cancelled | cancel | Delete (16) |
| completed | cancelled | cancel (puts stock back) | Delete (16) |

## InventoryIssueSummary (list row)

| Field | Type | From | Notes |
|---|---|---|---|
| id | int | `inventoryIssueId` | |
| facilityId | int | `facility` | Name via `facilityDisplayNameProvider` |
| warehouseId | int | `warehouse` | Name via `warehouseDisplayNameProvider` |
| serial | int? | `serial` | Null until confirmed |
| status | InventoryDocumentStatus | `status` | |
| creatorId | int | `creator` | An employee id; name via `employeeDisplayNameProvider` |
| createdAt | DateTime | `creationTime` | |

The summary's `supplierReturn` is not mapped, because the list has no column for it (FR-007).

`InventoryIssuePage` = `CatalogPage<InventoryIssueSummary>`.

## InventoryIssue (detail)

The summary's fields, plus:

| Field | Type | From | Notes |
|---|---|---|---|
| supplierReturnId | int? | `supplierReturn` | Legacy only; shown read-only when set (R7) |
| comment | String? | `comment` | The reason; ≤ 500 chars; an empty string maps to null |
| updaterId | int | `updater` | |
| modifiedAt | DateTime | `modificationTime` | |
| lines | List<InventoryIssueLine> | `lines` | Null maps to an empty list |

Derived:
- `isDraft` = `status == draft`.
- The display folio is `serial`, or "Borrador #{id}" for a draft. It is built in presentation from l10n, as in 067 (FR-004, FR-004a).

There is no warnings field (research R4).

## InventoryIssueLine

| Field | Type | From | Notes |
|---|---|---|---|
| id | int | `issueDetailId` | |
| productId | int | `product` | |
| productCode | String? | `productCode` | Snapshot |
| productName | String? | `productName` | Snapshot |
| quantity | Decimal | `quantity` (string) | > 0 |

## Validation mirrored in the UI

| Rule | Where | Server code if it slips through |
|---|---|---|
| Quantity > 0 | add-line and quantity dialogs | request validation |
| Notes ≤ 500 chars | new-issue and header dialogs (`maxLength`) | request validation |
| Warehouse required on create | new-issue dialog | request validation |
| Non-administrators pick only their own facility's warehouses | shared warehouse options | `facility.other_facility` on confirm or cancel |
| Product stockable | picker filter `stockable: true` | `product.not_stockable` |
| Edits only on drafts | actions absent unless `isDraft` | `document.not_editable` |

These rules exist only on the server and are shown from their codes:
- in-transit warehouse
- no lines
- **insufficient available stock on confirm** (enriched with product and warehouse, research R5)
- the facility rule
- a busy warehouse

## Action availability (detail screen)

| Action | Shown when |
|---|---|
| Editar encabezado | `can(16, update)` && `isDraft` |
| Agregar producto | `can(16, update)` && `isDraft` && `can(products, read)` |
| ✎ / 🗑 on a line | `can(16, update)` && `isDraft` |
| Confirmar | `can(16, update)` && `isDraft` |
| Cancelar | `can(16, delete)` && status ≠ cancelled |

In the header dialog, the warehouse is a picker when the user has `can(warehouses, read)`, and read-only text otherwise.
