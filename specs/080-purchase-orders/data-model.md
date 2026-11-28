# Data Model: Purchase Orders with Receipts, PDF and Email (080)

Domain entities are freezed classes in `lib/features/purchases/domain/entities/purchase_order.dart`, mapped from the generated `mbe_api_client` models in the repository impl. No hand-written DTOs (§III). Decimal strings are parsed to `Decimal`; an unparseable value maps to `AppError.server`, as receipts do.

## Entities

### Order status

Reuses `InventoryDocumentStatus` (research R4).

| Value | Wire (`DocumentStatus`) | Label (es) | Editable |
|---|---|---|---|
| `draft` | `draft` | Borrador | Yes |
| `completed` | `completed` | Confirmada | No |
| `cancelled` | `cancelled` | Cancelada | No |

### PurchaseOrderSummary

From `PurchaseOrderSummary` (list rows).

| Field | Type | From | Notes |
|---|---|---|---|
| id | int | `purchaseOrderId` | the order number |
| status | InventoryDocumentStatus | `status` | |
| supplierId | int? | `supplier` | |
| supplierName | String? | `supplierName` | shown as is |
| estimatedReceiptDate | DateTime? | `estimatedReceiptDate` | date only in the UI |
| comment | String? | `comment` | |
| creatorId | int | `creator` | name via `InventoryEmployeeName` |
| updaterId | int | `updater` | |
| createdAt | DateTime | `creationTime` | local wall clock (spec 043) |
| modifiedAt | DateTime | `modificationTime` | |
| lineCount | int | `lineCount` | |
| subtotal, tax, total | Decimal | `subtotal`, `tax`, `total` | money |

`typedef PurchaseOrderPage = CatalogPage<PurchaseOrderSummary>`.

### PurchaseOrder

From `PurchaseOrderResponse`: every summary field, plus:

| Field | Type | From | Notes |
|---|---|---|---|
| lines | List<PurchaseOrderLine> | `lines` | |
| skippedCount | int | `skipped.length` | only the count is used (FR-018); reasons are uncoded (mbe-api#353) |
| receipts | List<OrderReceipt> | `receipts` | filled only by the confirm response until mbe-api#355 |

`warnings` is not mapped (research R10).

### PurchaseOrderLine

| Field | Type | From | Notes |
|---|---|---|---|
| id | int | `purchaseOrderDetailId` | |
| productId | int | `product` | |
| productCode, productName | String | `productCode`, `productName` | snapshotted on the order |
| warehouseId | int? | `warehouse` | name via `InventoryWarehouseName` |
| quantity | Decimal | `quantity` | > 0, ≤ 4 decimals |
| price | Decimal | `price` | ≥ 0, ≤ 7 decimals, before tax |
| taxRate | Decimal | `taxRate` | 0 ≤ rate < 1 |
| amount | Decimal | `amount` | |
| requestLineId | int? | `purchaseRequestDetail` | |
| requestId | int? | `purchaseRequest` | folio via `purchaseRequestSerialProvider` (research R8) |
| quantityReceived | Decimal? | `quantityReceived` | null = non-stockable |
| quantityPending | Decimal? | `quantityPending` | null = non-stockable |

### OrderReceipt

From `GeneratedReceipt`.

| Field | Type | From |
|---|---|---|
| id | int | `inventoryReceiptId` |
| warehouseId | int | `warehouse` |
| facilityId | int | `facility` |
| lineCount | int | `lineCount` |

When mictlanix/mbe-api#355 ships it gains `status: InventoryDocumentStatus`.

### ToPurchaseGroup / ToPurchaseLine

From `ToPurchaseResponse.groups`.

| Group field | Type | From | Notes |
|---|---|---|---|
| supplierId | int? | `supplier` | null = "Sin proveedor"; no Crear orden |
| supplierName | String? | `supplierName` | |
| facilityId | int | `facility` | |
| lineCount | int | `lineCount` | |
| estimatedTotal | Decimal | `estimatedTotal` | |
| lines | List<ToPurchaseLine> | `lines` | |

| Line field | Type | From |
|---|---|---|
| requestLineId | int | `purchaseRequestDetailId` |
| requestId | int | `purchaseRequest` |
| serial | int? | `serial` |
| productId, productCode, productName | int, String, String? | `product`, `productCode`, `productName` |
| quantity | Decimal | `quantity` |
| warehouseId | int | `warehouse` |
| cost | Decimal | `cost` (0 = "sin costo") |

### OrderEmailReceipt

From `QuoteEmailResponse`: `recipients` (List<String>), `sentAt` (DateTime).

## Filters

### PurchaseOrdersFilter (URL query via `ListQuery`)

| Facet | Query key | Wire param | Badge |
|---|---|---|---|
| scope | `all` | `all=true` | counts when Todas |
| status | `status` | `status` | counts |
| supplier | `supplier` | `supplier` | counts |
| creator | `creator` | `creator` | counts |
| from / to | `from`, `to` | `from`, `to` | counts once |
| number search | `q` | `id` (int; non-numeric search sends nothing and shows the filtered-empty state) | — |

### ToPurchaseFilter

| Facet | Query key | Wire param |
|---|---|---|
| facility | `facility` | `facility` |
| page | `page` | none: the loaded groups are paged on the client, 20 per page, until mbe-api#354 |

## State transitions

```text
          create (hand / Por comprar group)
                     │
                     ▼
               ┌──────────┐  confirm (supplier, ≥1 line, qty>0)   ┌────────────┐
               │  draft   │ ─────────────────────────────────────▶│ completed  │
               └──────────┘   creates 1 draft receipt / warehouse  └────────────┘
                     │
                     │ cancel (request lines pending again)
                     ▼
               ┌──────────┐
               │cancelled │
               └──────────┘
```

No transition out of `completed` or `cancelled` in this UI.

## Action availability

`can(o, r)` is `accessControlProvider.can`. Orders are not facility-scoped (FR-003), so there is no facility column here.

| Action | Where | State | Rights |
|---|---|---|---|
| Open list / Por comprar | nav | — | read 20 |
| Nueva orden | list bar | — | create 20 + read suppliers |
| Crear orden | Por comprar filter row | a selected group with a supplier | create 20 |
| Editar encabezado | detail | draft | update 20 + read suppliers |
| Agregar producto | detail | draft | update 20 + read products |
| Agregar solicitud | detail | draft | update 20 + read 86 |
| Line ✎ / 🗑 | detail lines | draft | update 20 (✎ also read on warehouses for the picker) |
| Confirmar | detail | draft | update 20 |
| Cancelar orden | detail | draft | delete 20 |
| Imprimir | detail | completed | read 20 |
| Enviar por correo | detail | completed | update 20 |
| Abrir entrada | detail receipts | completed | read 15 |
| Order link | request detail, receipt detail | — | read 20 (else plain text) |
| Filter: supplier / creator / facility | list, Por comprar | — | read on suppliers / employees / facilities |

Absent, never disabled (§IV). The disabled controls are Confirmar on a draft with no lines (with a tooltip) and Crear orden in Por comprar while no group is selected: both depend on state, not rights, and the user can act once the state changes.
