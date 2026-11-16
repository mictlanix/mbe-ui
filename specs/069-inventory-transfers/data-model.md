# Data Model: Inventory Transfers (069)

The domain entities are `freezed` and live in `lib/features/inventory/domain/entities/inventory_transfer.dart`. They are mapped from the generated client in `data/inventory_transfer_repository_impl.dart`. Quantities are `Decimal`, parsed from the wire's decimal strings.

## InventoryTransferStatus

```
enum InventoryTransferStatus { draft, inTransit, received, cancelled }
```

| Domain | Wire (`TransferStatus`) | Label (es) | Tone |
|---|---|---|---|
| `draft` | `draft` | Borrador | `surfaceContainerHighest` |
| `inTransit` | `in_transit` | En tránsito | `tertiaryContainer` |
| `received` | `received` | Recibido | `secondaryContainer` |
| `cancelled` | `cancelled` | Cancelado | `errorContainer` |

### Transitions (server-driven)

```
draft ──dispatch──▶ inTransit ──receive (all outstanding)──▶ received
  │                  │   ▲ receive (part) ─┘                   │
  │                  │   └──────────── stays inTransit         │
  │                  ├──close remainder──▶ received            │
  └──cancel──▶ cancelled ◀──cancel── inTransit ◀───────────────┘ (cancel from received too)
```

- Legacy single-step transfers arrive as `received`.
- `cancelled` is terminal.

## InventoryTransferSummary (list row)

| Field | Source | Notes |
|---|---|---|
| `id` | `inventoryTransferId` | |
| `facilityId` | `facility` | the origin's facility |
| `warehouseId` | `warehouse` | origin |
| `warehouseToId` | `warehouseTo` | destination |
| `serial` | `serial` | null until dispatch |
| `status` | `status` | |
| `creatorId` | `creator` | employee id |
| `creationTime` | `creationTime` | |

`InventoryTransferPage = CatalogPage<InventoryTransferSummary>`.

## InventoryTransfer (detail)

The summary fields, plus:

| Field | Source | Notes |
|---|---|---|
| `comment` | `comment` | `""` maps to null |
| `updaterId` | `updater` | |
| `modificationTime` | `modificationTime` | |
| `lines` | `lines` | empty list when null |

Derived:
- `isDraft` ⇔ `status == draft`
- `isInTransit` ⇔ `status == inTransit`
- `isDispatched` ⇔ `serial != null`. This selects the three-quantity line table and the "Traspaso {folio}" title (research R10).
- `outstandingLines` = the lines with `quantityOutstanding > 0`

## InventoryTransferLine

| Field | Source | Notes |
|---|---|---|
| `id` | `transferDetailId` | |
| `productId` | `product` | |
| `productCode` | `productCode` | snapshot |
| `productName` | `productName` | snapshot |
| `quantity` | `quantity` | sent |
| `quantityReceived` | `quantityReceived` | the server already resolves legacy NULL |
| `quantityOutstanding` | `quantityOutstanding` | 0 unless in transit |

## InTransitView

From `InTransitResponse`:

| Entity | Fields |
|---|---|
| `InTransitView` | `facilityId`, `products: List<InTransitProductTotal>`, `lines: List<InTransitLineItem>` |
| `InTransitProductTotal` | `productId`, `productCode`, `productName`, `quantity` |
| `InTransitLineItem` | `transferId`, `serial`, `warehouseId`, `warehouseToId`, `lineId`, `productId`, `productCode`, `productName`, `quantityOutstanding` |

## InventoryTransfersFilter (presentation)

| Field | URL param | Notes |
|---|---|---|
| `status: InventoryTransferStatus?` | `status` (wire value) | |
| `warehouseId: int?` | `warehouse` | matches the origin or the destination on the server |

`activeCount` = the number of non-null fields, shown on the filter badge.

## Validation (client-side)

| Field | Rule | Where |
|---|---|---|
| Origin | required | Nuevo traspaso, Editar encabezado |
| Destination | required. Same-as-origin is refused by the server (R5) | Nuevo traspaso, Editar encabezado |
| Notes | optional, ≤ 500 characters | dialogs |
| Line quantity | > 0 | Agregar producto, line quantity |
| Receive quantity | 0 ≤ q ≤ outstanding, and at least one q > 0 | Recibir |
| Sales order | required | Agregar desde pedido |

## Action availability

`R` = read on 17, `C` = create, `U` = update, `D` = delete. Every action also needs the right named.

| Action | Draft | In transit | Received | Cancelled | Right | Also needs |
|---|---|---|---|---|---|---|
| Nuevo traspaso (list) | — | — | — | — | C | read warehouses |
| Editar encabezado | ✓ | | | | U | read warehouses |
| Agregar producto / ✎ / 🗑 | ✓ | | | | U | read products (add) |
| Agregar desde pedido | ✓ | | | | U | read sales orders |
| Despachar | ✓ | | | | U | |
| Recibir | | ✓ | | | U | |
| Cerrar pendiente | | ✓ | | | D | |
| Cancelar | ✓ | ✓ | ✓ | | D | |
| En tránsito (list) | — | — | — | — | R | read facilities (admin switch only) |
