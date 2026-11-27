# Contract: UI (routes, navigation, screens, dialogs)

Layouts are in [wireframes.md](../wireframes.md); this lists what each surface must expose. Decisions cited as R# are in [research.md](../research.md).

## Routes and navigation

| Route | Where | Gate | Screen |
|---|---|---|---|
| `/purchases/to-purchase` | shell branch 40 | read 20 | `ToPurchaseScreen(query: ListQuery.fromUri)` |
| `/purchases/orders` | shell branch 41 | read 20 | `PurchaseOrdersListScreen(query: ListQuery.fromUri)` |
| `/purchases/orders/:orderId` | top-level `GoRoute` | read 20 (prefix) | `PurchaseOrderDetailScreen(orderId)` |

Compras group order: Solicitudes de compra (38), Aprobación de solicitudes (39), Por comprar (40), Órdenes de compra (41). Labels "Por comprar", "Órdenes de compra".

## Órdenes de compra list

- Filter row: number search, filters button (badged), "Nueva orden" (create 20 + read suppliers).
- Drawer: Mostrar, Estado, Proveedor, Creó, Fecha (R15).
- Table columns: Número, Proveedor, Estado, Entrega, Creó, Fecha, Partidas, Total. No row icons. Row tap → detail.
- States: loading, empty (text per scope), filtered-empty with "Limpiar filtros", error with retry.
- Pagination: 20 per page.

## Por comprar

- Filter row: no search; filters button with Sucursal (only with read on facilities); "Actualizar".
- One card per group: supplier name or "Sin proveedor", facility, "{n} partidas", "est. {total}", "Crear orden" (create 20, supplier groups only). "Sin proveedor" groups show "Agrégalas a mano en una orden."
- Expanded body: Solicitud, Código, Producto, Cantidad, Almacén, Costo ("sin costo" at 0).
- States: loading, empty "No hay partidas pendientes de comprar.", error with retry.
- Crear orden → push the new order, SnackBar with created and skipped counts (R5).

## Orden de compra detail

- Title: "Orden de compra {id}". AppBar: back only.
- Header facts: Estado chip, Proveedor, Entrega, Notas, Creó + date; Subtotal / IVA / Total band in every state.
- Draft: warning band for price-0 lines (R10); lines table Código, Producto (+ "Sol. {serial}"), Almacén, Cantidad, Precio, IVA, Importe, ✎ 🗑; action area: Cancelar orden, Editar encabezado, Agregar solicitud, Agregar producto, Confirmar (filled, disabled with tooltip when no lines).
- Confirmed: "Entradas" section when the response carries receipts (R11), each with number, warehouse, facility, line count, "Abrir" (read 15); lines table Código, Producto, Almacén, Cantidad, Recibido, Pendiente, Importe; action area: Enviar por correo (update 20), Imprimir (read 20).
- Cancelled: draft columns, read-only, no actions.
- Every action absent without its right (data-model action table). Refusals in `ErrorBanner` above the action area; stale codes re-fetch.

## Dialogs (`ResponsiveDialog`, refusals in `FormErrorBanner`, both buttons disabled while submitting)

| Dialog | Fields | Submit |
|---|---|---|
| Nueva orden de compra | Proveedor*, Entrega (≥ today), Notas (≤ 500) | Crear → push detail |
| Editar encabezado | same, prefilled; clearing Notas or Entrega clears them | Guardar |
| Agregar producto | Producto* (purchasable), Cantidad* (> 0, ≤ 4 dec., default 1) | Agregar |
| Editar partida | Almacén*, Cantidad*, Precio* (≥ 0, ≤ 7 dec., "antes de IVA"), IVA* (R8 options) | Guardar |
| Quitar partida | prompt naming the product | Quitar |
| Agregar partidas de una solicitud | Solicitud* (approved, "{serial} · {facility} · {warehouse}") | Agregar → SnackBar counts |
| ¿Confirmar orden {id}? | summary, warehouses, price-0 lines | Confirmar → SnackBar receipts count |
| Cancelar orden {id} | explanation | Cancelar orden |
| Enviar orden {id} por correo | Para* (1–10 chips, supplier contact suggestions), Mensaje (≤ 1000) | Enviar → SnackBar |

## Changes to existing screens (FR-030)

- `purchase_request_detail_screen.dart`: the order column renders `PurchaseOrderLink(orderId)` + the existing chip.
- `inventory_receipt_detail_screen.dart`: the "Orden de compra" fact renders `PurchaseOrderLink(orderId)`.
- `PurchaseOrderLink`: a link (push the order detail) with read 20, plain text otherwise.

## Printing

- `DocumentKind.purchaseOrder` (gate 20), previewed through `documentActionsProvider.preview` (R13).
