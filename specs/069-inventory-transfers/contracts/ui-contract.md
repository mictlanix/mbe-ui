# Contract: UI — Traspasos

SystemObject: **InventoryTransfers (17)**. Related reads:
- Warehouses (4), for the origin and destination pickers and the filter.
- Products, for the line picker.
- Sales orders, for Agregar desde pedido.
- Facilities, for the in-transit view's administrator switch.

Wherever this contract says "as 068", the [issues UI contract](../../068-warehouse-issues/contracts/ui-contract.md) applies with "salida" read as "traspaso". Drawings are in [wireframes.md](../wireframes.md).

## Routes and navigation

| Route | Screen | Gate |
|---|---|---|
| `/inventory/transfers` | `InventoryTransfersListScreen(query: ListQuery.fromUri(uri))`, `StatefulShellBranch` index 32 | `can(17, read)` via `_routeGate` |
| `/inventory/transfers/in-transit` | `InTransitScreen()`, top-level `GoRoute` declared before `/:id` | `can(17, read)` |
| `/inventory/transfers/:id` | `InventoryTransferDetailScreen(id)`, top-level `GoRoute` | `can(17, read)` |

- Nav: the third destination in the "Inventario" group, after Salidas de almacén. It is "Traspasos" (`id: 'inventory-transfers'`, `NavBranch.inventoryTransfers = 32`, `Icons.swap_horiz`). The group shows when the user can read 15, 16 or 17.

## List screen

- **Filter row** (`CatalogFilterBar`, no search), actions in order:
  1. "En tránsito" (`OutlinedButton.icon`, `Icons.local_shipping_outlined`), always shown, since the route already needs read on 17.
  2. The filters button with the active count.
  3. "Nuevo traspaso" (`FilledButton.icon`, `Icons.add`), shown when `can(17, create)` and `can(4, read)`.
- **Filter drawer**: Estado chips (Borrador, En tránsito, Recibido, Cancelado; single-select). An "Almacén (origen o destino)" picker over every warehouse, shown with `can(4, read)`. Backed by `InventoryTransfersFilter`.
- **Table** (`DataTableView`), in column order:

  | Folio | Origen | Destino | Sucursal | Estado | Creado por | Fecha |
  |---|---|---|---|---|---|---|

  - Folio is the serial, right-aligned, or "Borrador #{id}" (shared `inventoryDocumentDraftFolio`).
  - Estado is `InventoryTransferStatusChip`.
  - Names come from the shared name cells.
  - A row tap pushes the detail. There are no row icons.
- **States**: `CatalogListStateView`. The empty text is "No hay traspasos". Filtered-empty has "Limpiar filtros".
- **Pagination**: `CatalogPagination`, 20 per page.

## Detail screen

- **Title**: "Traspaso {serial}", or "Traspaso · Borrador #{id}" when there is no serial. The AppBar has no actions.
- **Header facts** (`FactStripRow` / `ResponsiveFormGrid`, read-only):
  - Estado (chip), Folio, Origen, Destino, Sucursal.
  - Notas.
  - Creado por with its date, and Modificado por with its date.
- **Lines table**:
  - No serial (draft, or a cancelled draft): Código, Producto, Cantidad. On a draft with update, rows have ✎ and 🗑 via `buildCatalogRowActions`. The empty-draft text is "Agrega los productos que se van a traspasar."
  - Dispatched: Código, Producto, Enviado, Recibido, Pendiente, all right-aligned, with no row actions.
- **Action area** (left to right, each absent unless allowed; see [data-model.md](../data-model.md#action-availability)):
  - Draft: `[Cancelar]` … `[Editar encabezado] [Agregar desde pedido] [Agregar producto]` … `[Despachar]` (filled).
  - In transit: `[Cancelar] [Cerrar pendiente]` … `[Recibir]` (filled).
  - Received: `[Cancelar]`.
  - Cancelled: none.
- **Refusals**: an `ErrorBanner` above the action area, built from the code. `insufficient_stock` gets the extra product and warehouse line ([error-messages.md](error-messages.md)). A stale code refreshes the transfer.
- **Not found / forbidden / loading**: as 068.

## Dialogs (`ResponsiveDialog`, refusals in `FormErrorBanner`)

| Dialog | Fields / content | Submit | Notes |
|---|---|---|---|
| Nuevo traspaso | Origen* (scoped options, starts at the POS warehouse), Destino* (every warehouse), Notas (≤ 500) | Crear → push detail | Unsaved-changes guard |
| Editar encabezado | the same three fields, prefilled | Guardar | Only the changed fields are sent. Clearing notes sends `""` |
| Agregar producto | Producto* (active, stockable), Cantidad* > 0 | Agregar | As 068 |
| Cantidad de la partida | Cantidad* > 0 | Guardar | As 068 |
| Quitar partida | prompt | Quitar | As 068 |
| Agregar desde pedido | Pedido* (`CatalogEntityPicker`, completed orders, "{folio} · {customer} · {date}") | Agregar → snackbar | research R8 |
| Recibir traspaso {folio} | a row per outstanding line: Código, Producto, Pendiente, Recibir (prefilled) | Recibir | research R7. Hint: "Deja en 0 lo que no llegó. Lo pendiente se puede recibir después." |
| Despachar traspaso | "Despachar asigna un folio y retira las existencias de {origen}. Quedan en tránsito hasta que {destino} las reciba. Después ya no se puede editar." | Despachar | |
| Cerrar pendiente | "Lo pendiente ({n} partidas) regresa a {origen} y el traspaso queda como Recibido. Si se perdió, regístralo después con una salida de almacén." | Cerrar pendiente | |
| Cancelar traspaso | Draft: "Cancelar el borrador." Dispatched: "Cancelar el traspaso {folio} regresa a {origen} lo que está en tránsito[ y lo que {destino} ya recibió]." The bracketed part is shown only when any line has `quantityReceived > 0`. | Cancelar traspaso | |

## In-transit screen

- **Title**: "En tránsito" for an administrator, who gets the picker. "En tránsito · {facility}" for everyone else.
- **Facility**: starts on the user's facility. Administrators with `can(facilities, read)` get an inline `CatalogEntityPicker<FacilityListItem>` with a "Mi sucursal" reset, as on the delivery-orders list. With no facility: an administrator sees "Selecciona una sucursal." and no request is sent; a non-administrator sees `inventoryDocumentNoFacility`.
- **Tables** (unpaginated `DataTableView`s):
  - "Por producto": Código, Producto, Pendiente.
  - "Por traspaso": Folio, Origen, Destino, Código, Producto, Pendiente. A row tap pushes the transfer.
- **States**: loading, error with retry, and empty ("No hay mercancía en tránsito.").

## Text

Every string is a new `inventoryTransfer…` key in both `.arb` files. The exceptions are the reused `inventoryDocumentDraftFolio`, `inventoryDocumentNoFacility` and `navInventoryTransfers`. Quantities, dates and folios go through `formattersProvider` (§V).
