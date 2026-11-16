# Research: Warehouse Issues (068)

Sources: mbe-api `docs/specs/04-inventory.md` §2 and Common Patterns, `app/services/inventory_documents.py`, `app/core/error_codes.py`, and the generated client (`InventoryIssuesApi`, `InventoryIssueResponse`, `InventoryIssueSummary`, `IssueCreate`, `IssueUpdate`). The mbe-ui precedent is the shipped warehouse receipts feature, `lib/features/inventory/` (spec 067, whose [research](../067-warehouse-receipts/research.md) R1–R12 this builds on).

## R1. Reuse of the receipts code

- **Decision**: Move the parts of 067 that don't depend on the document type into shared inventory code, and point receipts at them. This is a rename and move with no behaviour change. Issues get their own entity, repository, actions, controllers, screens and dialogs, copied from receipts and simplified. The user chose this on 2026-11-16.

  | 067 symbol (file) | Shared symbol (new file) |
  |---|---|
  | `ReceiptStatus` (`domain/entities/inventory_receipt.dart`) | `InventoryDocumentStatus` (`domain/entities/inventory_document_status.dart`) |
  | `InventoryReceiptStatusChip`, `inventoryReceiptStatusLabel`, `inventoryReceiptStatusColors` (`inventory_receipt_status_chip.dart`) | `InventoryDocumentStatusChip`, `inventoryDocumentStatusLabel`, `inventoryDocumentStatusColors` (`presentation/shared/inventory_document_status_chip.dart`) |
  | `ReceiptWarehouseName`, `ReceiptFacilityName`, `ReceiptEmployeeName` (`receipt_name_cells.dart`) | `InventoryWarehouseName`, `InventoryFacilityName`, `InventoryEmployeeName` (`presentation/shared/inventory_name_cells.dart`) |
  | `ReceiptWarehouseScope`, `receiptWarehouseScope`, `receiptWarehouseOptions`, `receiptFilterWarehouseOptions`, `receiptStartingWarehouse` (`receipt_warehouse_options.dart`) | `InventoryWarehouseScope`, `inventoryWarehouseScope`, `inventoryWarehouseOptions`, `inventoryFilterWarehouseOptions`, `inventoryStartingWarehouse` (`presentation/shared/inventory_warehouse_options.dart`) |
  | `InventoryReceiptsFilter` (`inventory_receipts_filter.dart`) | `InventoryDocumentsFilter` (`presentation/shared/inventory_documents_filter.dart`) |

  - The l10n keys `inventoryReceiptStatusDraft/Completed/Cancelled` become `inventoryDocumentStatusDraft/Completed/Cancelled` ("Borrador", "Confirmada", "Cancelada"; "salida" is feminine like "entrada", so the labels fit both).
  - The chip's test key `inventory_receipt_status_chip` becomes `inventory_document_status_chip`.
  - The moved tests (`inventory_receipts_filter_test`, `receipt_warehouse_options_test`, `inventory_receipt_status_chip_test`) are renamed with their subjects. The rest of the 067 suite must pass unchanged, apart from imports and names, before any issue code is written. That is the guard that the move changed nothing.
- **Rationale**: FR-018 asks that the two screens look and behave alike. One status chip, one warehouse scope and one filter guarantee that, where copies would drift. These pieces are already document-agnostic (verified by reading them). Only their names say "receipt". Transfers and counts (04 §3, §5) will reuse them.
- **Alternatives**:
  - Copying everything into `presentation/issues/` was rejected because about 300 identical lines would exist twice.
  - A generic, parameterized document screen serving both was rejected. It means a large refactor of code that has just shipped, and it would bend the receipt-only features (warnings, complementary action, PO columns) into hooks.
- **Not shared**: the detail screen, actions notifier, controllers and dialogs. Their receipt versions carry warnings, the complementary action, PO columns and receipt wording, and the issue versions are simpler without them. The repository stays one per document, because each wraps its own generated API.

## R2. Where the feature lives, and navigation

- **Decision**: `lib/features/inventory/presentation/issues/`, with routes `/inventory/issues` and `/inventory/issues/:id`. The nav gets a second destination in the existing `inventory` group, after Entradas de almacén: `id: 'inventory-issues'`, label "Salidas de almacén", icon `Icons.outbox_outlined` / `Icons.outbox`, `NavBranch.inventoryIssues = 31` (appended last, since branch indexes are positional), gate `PrivilegeGate(SystemObject.inventoryIssues, AccessRight.read)`. `SystemObject.inventoryIssues(16)` already exists.
- **Rationale**: This is 067's R1 and R3. The Inventario group was opened for exactly this.

## R3. Record surface, creating, pickers

- **Decision**: Same as 067's R2, R4 and R5, through the shared pieces (R1):
  - A full detail screen, with no row icons on the list.
  - A draft is edited in place on the detail screen.
  - The "Nueva salida" button opens `new_issue_dialog` and pushes the new detail.
  - The warehouse picker uses `inventoryWarehouseOptions`, so a non-administrator gets their own facility only.
  - The starting warehouse comes from `inventoryStartingWarehouse`.
  - The product picker offers active, stockable products only.
- **Difference**: Editar encabezado always offers the warehouse picker. An issue has no purchase-order link, so nothing fixes its warehouse (`inventory_receipt.warehouse_fixed` has no counterpart).

## R4. No warnings

- **Decision**: An issue has no warnings, no warning band and no cost notice. `InventoryIssueResponse` has no `warnings` field (04 §2: "without warnings").
- **Consequence**: Issues don't depend on mictlanix/mbe-api#322.

## R5. Insufficient stock on confirm

- **Decision**: Confirm can return `inventory_document.insufficient_stock` (409; params `product_id`, `warehouse_id`, `requested`, `available`). Its shared Spanish message already exists (067). The detail screen adds the same enrichment line as receipts: "Producto: {code}", looked up from `product_id` among the issue's lines. The short product is always one of them, because the server sums the issue's own lines per product. The line also adds "Almacén: {warehouse name}", the issue's own warehouse and the only one an issue checks. The issue stays a draft and no folio is used (the server takes the serial only after the stock check).
- **Rationale**: FR-012 says the refusal names the product and warehouse. The error's params carry only ids, and §III forbids showing the server's English text, which does name both.
- **Cancel**: cancelling a confirmed issue puts stock back in. It can't run short, so the cancel prompt has no stock caveat.

## R6. Notes: label, hint, clearing

- **Decision**:
  - The field is labelled "Motivo / notas" in the dialogs and on the detail screen, with the hint "p. ej. merma, daño, consumo interno". It stays optional and is limited to 500 characters (spec clarification 1, FR-006).
  - Clearing sends `comment: ""`. This was verified live for receipts in 067: the server keeps `""`, and the mapper treats an empty string as no note. Issues use the same shared `inventory_documents.update_header` path on the server.

## R7. Supplier-return link

- **Decision**: `supplierReturn` is mapped to `InventoryIssue.supplierReturnId` (int?). When it is set, the detail screen shows a read-only fact, "Devolución a proveedor #{id}", as plain text. It is not on the list or the summary row (spec clarification 2, FR-007).

## R8. Error coverage

- **Decision**: No new error codes or messages. Every code the 9 issue routes can return is already in `localizedErrorCodes` and both `.arb` files (added by 067 or earlier). The `inventory_issue` resource noun and its feminine gender already exist (`apiResourceInventoryIssue`, `apiResourceGenderInventoryIssue`), so `no_lines` and `already_cancelled` read "La salida de almacén …". See [contracts/error-messages.md](contracts/error-messages.md).

## R9. Test fixtures and live verification

- **Decision**:
  - Unit and widget tests use mocktail fakes, with fixture builders in `test/unit/features/inventory/inventory_issue_fixtures.dart`.
  - The live test `test/integration/inventory_issues_live_test.dart` discovers at runtime an active stockable product with available stock in a warehouse that is not in transit. It reads that stock with `StockApi` before and after confirm and cancel (SC-002).
  - For the insufficient-stock path it adds a line for that product at available stock + 1 and expects the 409, with the issue still a draft (SC-003).
  - Writes run only with `MBE_WRITE=true`.
  - No seeded non-administrator has rights on 16, as was the case for 15 in 067. The non-administrator checks (own-facility picker, `facility.other_facility`) stay manual and are tracked in a manual-checks issue after merge.
