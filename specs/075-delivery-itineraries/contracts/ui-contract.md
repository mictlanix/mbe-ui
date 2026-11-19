# Contract: Routes, Navigation, Screens, Dialogs

## Routes and navigation

| Route | Screen | Gate |
|---|---|---|
| `/sales/delivery-itineraries` | `DeliveryItinerariesListScreen` (branch `NavBranch.deliveryItineraries = 36`) | `can(87, read)` via `_routeGate`, a clause before `deliveryOrdersPath` |
| `/sales/delivery-itineraries/:itineraryId` | `DeliveryItineraryDetailScreen` | same |

Nav: Logística group, the fourth entry ("Itinerarios", `Icons.route_outlined` / `Icons.route`), after "Por entregar" and before "Vehículos". Remove the "Delivery itineraries join this group when they ship" comment.

## List screen

- **Filter row**: the badged filters button (drawer) and "Nuevo itinerario" (`FilledButton.icon`, only with `can(87, create)`). No search box (R14).
- **Drawer**: status (Todos, Abierto, En ruta, Cerrado, Cancelado), a date range, vehicle, operator and dispatch warehouse pickers.
- **Table** (`DataTableView`, paginated 20): Núm., Fecha, Vehículo, Operador, Almacén, Estado (`StatusChip<ItineraryStatus>`), Salida, Regreso. Name cells come from the row (#343). There is no row Edit icon. A row click opens the trip.

## Trip screen

The AppBar has the title "Itinerario {id}" and no actions (§VI).

1. **Header band** (`FactStripRow`): status chip, date, vehicle, operator, dispatch warehouse, departure and return times, and comment.
   - An Abierto trip with update right shows "Editar encabezado" (`OutlinedButton`).
   - When the operator's licence has expired, a warning banner shows "La licencia de {operador} venció el {fecha}" (R4).
2. **Action bar** (body, right-aligned, per status):
   - **Abierto**: "Agregar parada", "Cancelar itinerario", and "Dar salida" (`FilledButton`). "Dar salida" is disabled while the guard fails, with a caption naming the empty stops or saying nothing is loaded.
   - **En ruta** and **Cerrado**: "Imprimir ticket" and "Imprimir notas de entrega".
   - **Cancelado**: nothing.
3. **Stops**: one card per stop, in sequence.
   - **Card title**: "Parada {n}", the order's folio as a link to `/sales/delivery-orders/{id}` (with 71 read), customer, ship-to, and an outcome chip once departed.
   - **Abierto**: "Cargar todo", "Cargar línea" and "Quitar parada" (overflow).
   - **En ruta, pending**: "Cerrar parada".
   - **Table**: Código, Producto, Unidad (the line's unit symbol), and the quantities for the status:
     - Abierto: Pendiente (open on the order), Cargado, with ✎ and 🗑;
     - En ruta: Enviado;
     - closed stop: Enviado, Entregado, Devuelto, Motivo.
   - **Legacy stop, no stored order** (R2): the title is "Parada {n}" with the folios of the stop's lines. Lines still show product names. On an Abierto trip, "Cargar línea" first asks for the order.

## Dialogs (`ResponsiveDialog`)

| Dialog | Fields | Confirm enabled when |
|---|---|---|
| Nuevo itinerario | date (today), vehicle, operator, dispatch warehouse (optional; helper text: blank uses the point of sale's) | always |
| Editar encabezado | date, vehicle, operator, comment | something changed |
| Agregar parada | paged list of delivery-type orders in En preparación, with folio search; existing stops hidden | one chosen |
| Cargar línea | order lines with open > 0; quantity (default open, max open) | 0 < q ≤ open |
| Cantidad cargada (✎) | quantity, max open + loaded | 0 < q ≤ max |
| Liberar partida / Quitar parada / Cancelar itinerario | confirmation text naming what's released | n/a |
| Dar salida | summary: vehicle, operator or "Sin operador", stops, lines; "the load can't change after departure" | n/a |
| Cerrar parada | Receptor (name, ID shown); Líneas (delivered per line, reason when short; "Todo entregado" / "Nada entregado"); Prueba (Imagen \| Firma) | FR-016 holds |

## Shared pieces used

`CatalogFilterBar`, `showCatalogFilterSheet`, `DataTableView`, the pagination bar, `StatusChip`, `FactStripRow`, `CatalogEntityPicker`, `CompactField`, `ResponsiveDialog`, the document preview actions (spec 044), and `formattersProvider`.

The only new widget is `SignaturePad` (feature-local, R9).
