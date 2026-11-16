# Research: Warehouse Receipts (067)

Sources: mbe-api `docs/specs/04-inventory.md` §1, `app/services/inventory_documents.py`, `app/services/inventory_receipt_service.py`, `app/services/purchase_cost_service.py`, `specs/036-localizable-error-codes/contracts/error-codes.md`, and the generated client under `lib/generated/openapi/`. mbe-ui precedents are delivery orders (`lib/features/sales/presentation/delivery_orders/`, spec 061) and fiscal documents (`lib/features/invoicing/`, spec 066).

## R1. Where the feature lives

- **Decision**: `lib/features/inventory/`, routes `/inventory/receipts` and `/inventory/receipts/:id`.
- **Rationale**: §I names `inventory` as a feature folder, and the stack's route-mirrors-folders rule puts it under `/inventory`. Issues, transfers and counts (04 §2–§4) will join it.
- **Alternatives**: `lib/features/sales/`, where delivery orders live. Rejected because receipts are not sales, and the inventory documents share server mechanics that belong together.

## R2. Record surface and row actions

- **Decision**: A full detail screen. The row tap opens it. There is no row Edit icon and no View toggle. A draft is edited in place: a header dialog, line dialogs, and ✎/🗑 on line rows. Non-draft receipts are read-only. The AppBar has no actions.
- **Rationale**: A receipt owns lines (§VI criterion 1). This is the document reading recorded in specs 056, 057, 060, 061 and 066.
- **Alternatives**: A side panel was rejected because a receipt has child lines and the complementary action navigates by URL.

## R3. Navigation group

- **Decision**: A new `NavGroup(id: 'inventory', label: 'Inventario')` with one destination, Entradas de almacén, placed in `kNavigationTree` between Logística and Facturación. `NavBranch.inventoryReceipts = 30` is appended last, because branch indexes are positional in the `StatefulShellRoute`. Gate: `PrivilegeGate(SystemObject.inventoryReceipts, AccessRight.read)`. Icon: `Icons.move_to_inbox_outlined` / `Icons.move_to_inbox`.
- **Rationale**: The spec's assumption, and room for 04 §2 onward.

## R4. Creating a receipt

- **Decision**: A "Nueva entrada" `FilledButton.icon` in the list's `CatalogFilterBar.actions`, gated on create. It opens `new_receipt_dialog` (warehouse picker plus notes), sends `POST /inventory-receipts`, and `context.push`es the new receipt's detail. This follows `showNewInvoiceDialog` (spec 066).
- **Alternatives**: Creating an empty draft and picking the warehouse on the detail was rejected, because the warehouse is required on create.

## R5. Pickers

- **Warehouse (Nueva entrada, Editar encabezado)**: `CatalogEntityPicker<Warehouse>` fed by `warehouseRepositoryProvider.list(search:, status: active, facilityId:, limit: 10)`. Each option shows the warehouse name with the facility as its subtitle. It is shown only with read on Warehouses (4).
  - **Own facility only for non-administrators** (spec FR-017, clarification 1): `facilityId` is the session user's `UserSettings.facilityId` when `!accessControl.isAdministrator`, and null (every warehouse) for administrators. A non-administrator with no facility in their settings is offered no warehouses, and the dialog says their user has no sucursal assigned. The server applies the facility rule only on confirm and cancel, so without this filter a non-administrator could build a draft they can never confirm.
  - **Starting value** (spec FR-005, clarification 4): Nueva entrada starts with the warehouse of the user's point of sale (`UserSettings.pointSaleId` → `pointSaleRepositoryProvider.get(...).warehouseId`, as `default_warehouse_controller.dart` does for the POS). It starts empty when the user has no point of sale, or when that lookup fails (for example, no read right on points of sale). The lookup is called from the inventory feature through the catalog repository, not by importing the sales controller, which keeps the feature layers separate.
- **Warehouse (list filter)**: the same picker without `facilityId`, for everyone. Reading is not limited by facility. The warehouse record has no in-transit flag, so the picker cannot hide in-transit warehouses. The server refuses one with `warehouse.in_transit_location`, shown in the dialog. (Live check in quickstart step 4: whether the warehouse list returns in-transit rows at all.)
- **Product**: the `add_product_dialog.dart` pattern (spec 066). `CatalogEntityPicker<Product>` is fed by `productRepositoryProvider.list(search:, status: EntityStatus.active, stockable: true, limit: 10)`. `ProductRepository.list` already takes `stockable`. The product picker needs read on Products.
- **Quantity**: entered through `fmt.field.quantity` / `parseQuantity` and validated as greater than 0 before sending. The server's `Quantity5` takes a decimal string.

## R6. Warnings (FR-015, FR-015a)

- **Decision**: A pure domain function `computeOverReceipts(List<InventoryReceiptLine>)` returns `OverReceipt{productCode, excess, received, ordered}`, one per order line:
  - Group the lines with a non-null `purchaseOrderLineId` by that id, and sum their `quantity`.
  - Take `quantityOrdered` and `quantityReceivedElsewhere` (null counts as 0) from the group's first line. The server reports the same per-order-line figures on each linked line.
  - `received = elsewhere + sum`. Emit a warning when `received > ordered`, with `excess = received − ordered` and the product code of the group's first line.

  This mirrors `over_receipt_warnings` in mbe-api. The detail screen shows the list in a warning-toned banner whenever the receipt is a draft or completed, after load, save and confirm. It never blocks.
- **Cost notice** (spec FR-015a, clarification 3): The confirm and cancel actions compare `response.warnings.length` with the number of computed over-receipts. When the server sent more, the detail screen shows a notice band, "Se actualizaron los costos con excepciones.", with a close button. The band lives in the detail screen's local UI state (a `Notifier` keyed by receipt id, not persisted). It stays until the clerk closes it or leaves the receipt, because a later GET does not repeat the cost warnings. It never blocks.
- **Rationale**: §III forbids server prose on screen. The over-receipt figures are already on the lines. The two cost warnings (a product priced at 0, a cost not restored) cannot be rebuilt client-side.
- **Exit**: when mictlanix/mbe-api#322 ships coded warnings, map those codes and delete `computeOverReceipts`.
- **Alternatives**: Showing the raw English text, or blocking on #322, were both rejected by the user on 2026-11-16.

## R7. Error handling and coverage

- **Decision**: The repository maps `DioException` to `AppError` (the existing `_toAppError` pattern). Actions return `AppError?`, and dialogs and the detail show it through `ErrorBanner`. There are 15 reachable codes, 9 of them new; see [contracts/error-messages.md](contracts/error-messages.md).
- `inventory_document.insufficient_stock` carries `product_id`, `warehouse_id`, `requested` and `available`, but no code. The shared message doesn't name the product; it says the quantities and asks the user to check that product's stock. The detail screen's cancel refusal adds the product code by looking up `product_id` among the receipt's lines. This is a presentation-side enrichment, so the shared path stays generic.
- After a refusal from `document.not_editable`, `inventory_document.already_cancelled` or `lock.busy`, the detail re-fetches, which covers the spec's concurrent-edit edge case.

## R8. Clearing the notes

- **Risk**: `ReceiptUpdate.comment` is `str | None`, and the server applies `model_dump(exclude_unset=True)`. The built_value serializer drops null fields, so a cleared note sent as `comment: null` is omitted, and the server keeps the old note. Spec 049's logo removal hit the same trap.
- **Decision**: Send the header PUT through the generated method when the notes are non-empty. When the user clears the notes, send `""` first. If a live check (quickstart step 5) shows that the server keeps `""` as an empty string instead of null, that is acceptable: an empty note displays as no note. If the generated client also drops `""`, fall back to a raw `dio.put` with `{"comment": null}`, deserialized with `appSerializers`.
- **Header warehouse**: send `warehouse` only when it changed, and never for a PO-linked receipt (the field is read-only there, per FR-006).

## R9. List filters and columns

- **Decision**:
  - Facets: status (Borrador, Confirmada, Cancelada, sent as `draft`/`completed`/`cancelled`) and warehouse (picker). Both live in the URL query (`ListQuery`) as in other lists.
  - There is no search box, because the endpoint has none. The server's `DocumentStatus` also has `paid`, which receipts never use, so it is not offered.
  - Columns: Folio (`serial`, or "Borrador #{id}" for a draft, per spec FR-004 and clarification 2), Almacén, Sucursal, Orden de compra, Estado (chip), Creado por, Fecha. Names come from `warehouseDisplayNameProvider`, `facilityDisplayNameProvider` and `employeeDisplayNameProvider`. `creator` is an `employee.employee_id` in mbe-api.
  - Newest first is the server's order. Page size 20.
- **Scope**: The UI sends no scope parameter. The server applies "the user's POS warehouse or the user's own receipts", and widens to all receipts for administrators and the delete right (FR-002).

## R10. Complementary receipt

- **Decision**: An "Entrada complementaria" `OutlinedButton` on the detail. It is shown when the user has create on 15, the receipt has `purchaseOrder != null`, and its status is not cancelled. On success (200 or 201) it `context.push`es the returned receipt. A 409 `inventory_receipt.complementary_unavailable` shows its reason (4 variants).

## R11. Confirmation prompts

- **Confirm**: "Confirmar la entrada asigna un folio y agrega las existencias al almacén. Después ya no se puede editar." If over-receipt warnings exist, the prompt lists them, so the clerk sees them before posting stock.
- **Cancel**: for a draft, "Cancelar el borrador"; for a completed receipt, "Cancelar la entrada retira del almacén las existencias que agregó." There is no reason field, because the endpoint takes none.
- **Remove line**: the delivery-orders remove prompt.
- All prompts are built on `showResponsiveDialog`. The header and line dialogs set `hasUnsavedChanges`.

## R12. Test fixtures and live verification

- **Decision**:
  - Unit and widget tests use fakes (mocktail) with fixture builders in `test/unit/features/inventory/inventory_receipt_fixtures.dart`.
  - The live test (`test/integration/inventory_receipts_live_test.dart`) discovers its fixtures at runtime: a stockable active product, a non-in-transit warehouse, and any receipt with `purchaseOrder != null` for the complementary path. It skips the complementary case when none exists.
  - Writes run only with `MBE_WRITE=true`.
  - Stock before and after is read with `GET /stock/products/{product}` (`StockApi`), to prove SC-002.
- **Rationale**: The new MBE cannot create purchase orders yet, so PO-linked fixtures can only come from legacy data. This uses the runtime-discovery pattern from spec 009.
