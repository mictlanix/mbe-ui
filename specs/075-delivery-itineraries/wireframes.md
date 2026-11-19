# Wireframes: Delivery Itineraries

**Spec**: [spec.md](./spec.md) | **Drawn**: 2026-11-18 | **Fidelity**: low

Drawn from the spec. **Out of order**: `plan.md` already existed when these were drawn. The Open Questions below are feedback for both the spec and the plan, and each says which one it touches. Layout is indicative, not prescriptive. Every dimension, colour and spacing resolves through the design tokens, per constitution §V.

The screens follow the shipped document screens:
- 061 "Órdenes de entrega": status chip, detail with lines, proof;
- 069 "Traspasos": a list with no search, a header band, body actions.

The driver-mobile design in `artifacts/delivery_itineraries/` belongs to mbe-roadmap#119 and isn't drawn here. Only its one-form closure idea (its 1d) survives, as the Cerrar parada dialog.

## Screen: Itinerarios list (`/sales/delivery-itineraries`)

### State: populated

```
┌ Logística ▸ Itinerarios ────────────────────────────────────────────────────────────────┐
│                                              [⚲ Filtros ①]  [＋ Nuevo itinerario]         │
├──────┬────────┬──────────────┬─────────────┬──────────────┬────────────┬────────┬────────┤
│ Núm. │ Fecha  │ Vehículo     │ Operador    │ Almacén      │ Estado     │ Salida │ Regreso│
├──────┼────────┼──────────────┼─────────────┼──────────────┼────────────┼────────┼────────┤
│   58 │ 18/11  │ MBE-114      │ Juan Rivas  │ Bodega Norte │ (Abierto)  │   —    │   —    │
│   57 │ 18/11  │ Torton 3     │ C. Rivas    │ Bodega Norte │ (En ruta)  │ 07:04  │   —    │
│   56 │ 17/11  │ MBE-114      │ Juan Rivas  │ Bodega Sur   │ (Cerrado)  │ 07:10  │ 15:22  │
│   55 │ 17/11  │ —            │ —           │ Bodega Norte │ (Cancelado)│   —    │   —    │
├──────┴────────┴──────────────┴─────────────┴──────────────┴────────────┴────────┴────────┤
│                                                  1–20 de 58   ‹  1  2  3  ›              │
└──────────────────────────────────────────────────────────────────────────────────────────┘
```

- **Nav**: the 4th entry in "Logística", after "Por entregar", shown with read on 87 (FR-001).
- **Filter row**: `CatalogFilterBar` with **no search control**, because the endpoint has none (FR-003). Its actions slot holds the badged filter `IconButton` and "Nuevo itinerario" (`FilledButton.icon`), which needs create on 87 (FR-005).
- **Table**: `DataTableView` (FR-002).
  - Núm. is right-aligned, and Salida and Regreso are times via `formattersProvider`.
  - Vehículo, Operador and Almacén are name cells that fill in after lookup and fall back to the number (FR-024). "—" means none assigned.
  - Estado is a `StatusChip<ItineraryStatus>` with four tones.
  - A row tap opens the trip (FR-004). There are no row icons (document reading, as 067–069).
- **Pagination**: `CatalogPagination`, newest first.

### State: filter drawer open

```
┌───────────────────────────────────┐
│ Filtros                        ✕  │
│ Estado                            │
│ (Todos) (Abierto) (En ruta)       │
│ (Cerrado) (Cancelado)             │
│ Fecha                             │
│ [ 01/11/2026 – 18/11/2026     ▾ ] │
│ Vehículo                          │
│ [ MBE-114                     ▾ ] │
│ Operador                          │
│ [ Cualquiera                  ▾ ] │
│ Almacén de salida                 │
│ [ Cualquiera                  ▾ ] │
│ [Limpiar]              [Aplicar]  │
└───────────────────────────────────┘
```

- `showCatalogFilterSheet` holds the status chips (one at a time; the server takes one) and a date range.
- Three `CatalogEntityPicker`s (vehicle, operator, warehouse), each needing read on its catalog. A picker the user can't read is left out (FR-003, §IV).

### State: loading / empty / filtered-empty / error

```
┌──────────────────────────────────────┐ ┌──────────────────────────────────────┐
│           [⚲]  [＋ Nuevo itinerario]  │ │         [⚲ ①]  [＋ Nuevo itinerario] │
│                                      │ │                                      │
│        Aún no hay itinerarios        │ │  Ningún itinerario coincide con los  │
│                                      │ │  filtros.   [Limpiar filtros]        │
└──────────────────────────────────────┘ └──────────────────────────────────────┘
```

- `ListStateViews`: loading skeleton, empty, filtered-empty with "Limpiar filtros", and error with "Reintentar" (shared `ErrorBanner` text built from the code).

### Compact tier

```
┌ Itinerarios ─────────────────────┐
│              [⚲ ①] [＋ Nuevo]     │
├──────────────────────────────────┤
│ 58 · 18/11          (Abierto)    │
│ MBE-114 · Juan Rivas             │
├──────────────────────────────────┤
│ 57 · 18/11          (En ruta)    │
│ Torton 3 · C. Rivas · 07:04      │
└──────────────────────────────────┘
```

- Each row becomes two lines: number, date and status, then vehicle, operator and departure time. Almacén and Regreso are dropped; the trip screen shows them. The status is never truncated (§VI).

## Screen: Trip (`/sales/delivery-itineraries/:itineraryId`)

### State: Abierto, being loaded (update right)

```
┌ ← Itinerario 58 ─────────────────────────────────────────────────────────────────────────┐
│ (Abierto)  Fecha 18/11/2026 · Vehículo MBE-114 · Operador Juan Rivas · Almacén B. Norte  │
│ Comentario: Salida temprana por la zona industrial                 [✎ Editar encabezado] │
│ ⚠ La licencia de Juan Rivas venció el 02/11/2026.                                         │
├──────────────────────────────────────────────────────────────────────────────────────────┤
│                      [Cancelar itinerario]  [＋ Agregar parada]  [▶ Dar salida]            │
│                                       La parada 3 no tiene nada cargado.                 │
├──────────────────────────────────────────────────────────────────────────────────────────┤
│ Parada 1 · Orden 1532 ↗ · Abarrotes La Central · Mercado 2, Local L-14                ⋮  │
│                                                  [Cargar todo]  [＋ Cargar línea]         │
│ ┌──────────┬───────────────────────────┬────────┬───────────┬───────────┬──────────┐     │
│ │ Código   │ Producto                  │ Unidad │ Pendiente │   Cargado │          │     │
│ ├──────────┼───────────────────────────┼────────┼───────────┼───────────┼──────────┤     │
│ │ CLA-25   │ Clavo 2½"                 │ kg     │      0.00 │     25.00 │  ✎   🗑  │     │
│ │ CEM-50   │ Cemento gris 50 kg        │ bulto  │      0.00 │     10.00 │  ✎   🗑  │     │
│ └──────────┴───────────────────────────┴────────┴───────────┴───────────┴──────────┘     │
│ Parada 2 · Orden 1540 ↗ · Materiales Herrera · Av. Juárez 120                         ⋮  │
│ │ CEM-50   │ Cemento gris 50 kg        │ bulto  │      4.00 │      6.00 │  ✎   🗑  │     │
│ Parada 3 · Orden 1544 ↗ · Ferretería Soto · Calle 5 #33                               ⋮  │
│   Nada cargado todavía.                          [Cargar todo]  [＋ Cargar línea]         │
└──────────────────────────────────────────────────────────────────────────────────────────┘
```

- **AppBar**: title only, no actions (§VI).
- **Header band**: `FactStripRow` (FR-006, FR-013). "Editar encabezado" is an `OutlinedButton`, shown on Abierto with update.
- **Licence warning**: `ErrorBanner` in warning tone. It's advisory and blocks nothing (FR-007).
- **Action bar**: body buttons (§VI).
  - "Dar salida" is a `FilledButton`. It's disabled with the caption below it while nothing is loaded or a stop is empty (FR-012).
  - "Cancelar itinerario" is an `OutlinedButton` (FR-014).
  - "Agregar parada" is an `OutlinedButton.icon` (FR-008).
- **Stop card**: a titled section per stop (FR-009).
  - The title has sequence, order folio as a link to the 061 screen (with 71 read), customer and ship-to.
  - ⋮ is the overflow with "Quitar parada" (FR-011).
  - "Cargar todo" and "Cargar línea" sit on the right (FR-010).
  - The line table is a non-paginated `DataTableView` (bounded by the order's lines). "Pendiente" is the order line's open quantity, and quantities are right-aligned. ✎ and 🗑 change and release a loaded line (FR-011).
- **Unidad** is the line's unit symbol (mbe-api#343, research R2).

### State: Abierto, a legacy stop with no stored order (rare; created before #343)

```
│ Parada 2                                                                              ⋮  │
│                                                  [Cargar todo]  [＋ Cargar línea]         │
│ Parada 2 · Órdenes 1498, 1502                                                         ⋮  │
│ │ CLA-25   │ Clavo 2½"                 │ kg     │      0.00 │      6.00 │  ✎   🗑  │     │
```

- Spec Edge Cases. Lines still carry product and order (#343); the folios come from the lines. "Cargar todo" and "Cargar línea" first ask for the order (the Agregar parada list). ✎ and 🗑 still work, because they need only the line id.

### State: Abierto, read-only user (read on 87, no update)

```
┌ ← Itinerario 58 ─────────────────────────────────────────────────────────────────────────┐
│ (Abierto)  Fecha 18/11/2026 · Vehículo MBE-114 · Operador Juan Rivas · Almacén B. Norte  │
├──────────────────────────────────────────────────────────────────────────────────────────┤
│ Parada 1 · Orden 1532 ↗ · Abarrotes La Central · Mercado 2, Local L-14                   │
│ │ CLA-25   │ Clavo 2½"                 │ kg     │      0.00 │     25.00 │                │
```

- No edit, action-bar, ⋮, load, ✎ or 🗑 controls (FR-021, SC-006). The licence warning is still shown.

### State: En ruta, stops being closed

```
┌ ← Itinerario 57 ─────────────────────────────────────────────────────────────────────────┐
│ (En ruta)  Fecha 18/11/2026 · Vehículo Torton 3 · Operador C. Rivas · Salida 07:04       │
├──────────────────────────────────────────────────────────────────────────────────────────┤
│                               [🖨 Imprimir ticket]  [🖨 Imprimir notas de entrega]         │
├──────────────────────────────────────────────────────────────────────────────────────────┤
│ Parada 1 · Orden 1532 ↗ · Abarrotes La Central           (Entregada) · cerrada 13:48    │
│ │ Código │ Producto           │ Unidad │ Enviado │ Entregado │ Devuelto │ Motivo      │   │
│ │ CLA-25 │ Clavo 2½"          │ kg     │   25.00 │     25.00 │     0.00 │             │   │
│ Parada 2 · Orden 1540 ↗ · Materiales Herrera   (Entregada parcialmente) · cerrada 14:20 │
│ │ CEM-50 │ Cemento gris 50 kg │ bulto  │    6.00 │      4.00 │     2.00 │ Merc. dañada│   │
│ Parada 3 · Orden 1544 ↗ · Ferretería Soto                              (Pendiente)       │
│ │ Código │ Producto           │ Unidad │ Enviado │                                    │   │
│ │ VAR-38 │ Varilla 3/8"       │ pieza  │   40.00 │                                    │   │
│                                                                    [✓ Cerrar parada]     │
└──────────────────────────────────────────────────────────────────────────────────────────┘
```

- The header gains Salida (FR-013). There's no edit, stop or load action.
- **Print**: two `OutlinedButton.icon`s with read on 87, opening the spec 044 preview (FR-020).
- **Closed stops** show a `StatusChip<StopOutcome>` and "cerrada {hora}" (the stop's `arrival_time`, which the server sets at closure), plus Entregado, Devuelto and Motivo columns (FR-018). The folio link leads to the 061 screen with the proof and any child order (US3 scenario 8).
- **A pending stop** has "Cerrar parada" (`FilledButton`, update on 87) (FR-015).

### State: Cerrado

```
┌ ← Itinerario 56 ─────────────────────────────────────────────────────────────────────────┐
│ (Cerrado)  Fecha 17/11/2026 · MBE-114 · Juan Rivas · Salida 07:10 · Regreso 15:22        │
├──────────────────────────────────────────────────────────────────────────────────────────┤
│                               [🖨 Imprimir ticket]  [🖨 Imprimir notas de entrega]         │
├──────────────────────────────────────────────────────────────────────────────────────────┤
│ Parada 1 · … (Entregada) · cerrada 10:12      Parada 2 · … (Fallida) · cerrada 12:40     │
```

- Every stop is resolved. Regreso shows (FR-019). The screen is read-only except for printing.

### State: Cancelado

```
┌ ← Itinerario 55 ─────────────────────────────────────────────────────────────────────────┐
│ (Cancelado)  Fecha 17/11/2026 · Almacén Bodega Norte                                     │
├──────────────────────────────────────────────────────────────────────────────────────────┤
│   Este itinerario se canceló antes de salir. Lo cargado volvió a estar pendiente.        │
└──────────────────────────────────────────────────────────────────────────────────────────┘
```

- The server deletes a cancelled trip's stops, so nothing remains to list. There's no print and no action (FR-014, FR-020).

### State: loading / not found / error

```
┌ ← Itinerario 58 ──────────────────────┐ ┌ ← Itinerario 999 ─────────────────────┐
│ ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ │ │ No se encontró el itinerario 999.     │
│ ░░░░░░░░░░░░░░░░░░                    │ │ [Volver a Itinerarios]                │
└───────────────────────────────────────┘ └───────────────────────────────────────┘
```

- `ListStateViews` skeleton. `resource.not_found` uses the `delivery_itinerary` noun (FR-022).

### Compact tier

```
┌ ← Itinerario 58 ─────────────────┐
│ (Abierto) 18/11 · MBE-114        │
│ Juan Rivas · B. Norte       [✎]  │
│ ⚠ Licencia vencida 02/11         │
│ [▶ Dar salida]                   │
│ [＋ Parada] [Cancelar]            │
├──────────────────────────────────┤
│ 1 · Orden 1532 · La Central   ⋮  │
│ CLA-25 Clavo 2½"                 │
│   Pend. 0 · Carg. 25 kg  ✎ 🗑    │
│ [Cargar todo] [＋ Línea]          │
└──────────────────────────────────┘
```

- The header stacks. The action bar wraps, with Dar salida first and full width.
- Each line row becomes two lines (code and name, then quantities and icons).
- In En ruta and Cerrado, the Devuelto and Motivo columns move into a line under each row.

## Dialog: Nuevo itinerario

```
┌ Nuevo itinerario ────────────────────────────┐
│ Fecha             [ 18/11/2026          📅 ] │
│ Vehículo          [ MBE-114              ▾ ] │
│ Operador          [ Juan Rivas           ▾ ] │
│ Almacén de salida [ (del punto de venta) ▾ ] │
│   Vacío usa el almacén de tu punto de venta. │
│ Comentario        [                        ] │
│ ⚠ Este vehículo ya tiene abierto el          │
│   itinerario 54.                             │
│                     [Cancelar]  [Crear]      │
└──────────────────────────────────────────────┘
```

- `ResponsiveDialog` + `ResponsiveFormGrid` (one column). Pickers are `CatalogEntityPicker`. Everything is optional (FR-005).
- The ⚠ line is the `FormErrorBanner` after a `vehicle.open_itinerary_exists` refusal. The dialog stays open (US1 scenario 4).

## Dialog: Agregar parada

```
┌ Agregar parada ──────────────────────────────────────────────┐
│ [⚲ Folio                           ]                          │
│ ┌───────┬────────────────────┬──────────────────┬──────────┐ │
│ │ Folio │ Cliente            │ Dirección        │ Fecha    │ │
│ │  1544 │ Ferretería Soto    │ Calle 5 #33      │ 18/11    │ │
│ │  1547 │ Constructora Lara  │ Km 4 carr. Norte │ 19/11    │ │
│ └───────┴────────────────────┴──────────────────┴──────────┘ │
│                                   1–20 de 34  ‹ 1 2 ›        │
│                               [Cancelar]  [Agregar]          │
└──────────────────────────────────────────────────────────────┘
```

- Delivery-type orders in En preparación, with orders already on this trip hidden (FR-008). `CatalogSearchBar` (folio), `DataTableView` with single selection, `CatalogPagination`. Empty state: "No hay órdenes en preparación."

## Dialog: Cargar línea / Cantidad cargada

```
┌ Cargar línea · Orden 1540 ───────────────────┐   ┌ Cantidad cargada · CEM-50 ──────┐
│ ( ) CEM-50  Cemento gris 50 kg   4.00 pend.  │   │ Cantidad [   6.00   ] bulto     │
│ ( ) ARE-01  Arena m³             2.00 pend.  │   │ Máximo 10.00 (4 pend. + 6 carg.)│
│ Cantidad [   4.00   ]   máximo 4.00          │   │         [Cancelar] [Guardar]    │
│                     [Cancelar]  [Cargar]     │   └─────────────────────────────────┘
└──────────────────────────────────────────────┘
```

- `CompactField` with a quantity formatter. Lines with open = 0 aren't offered. The default is the open quantity (FR-010, FR-011). A value above the maximum is refused in the field.

## Dialog: Dar salida

```
┌ ¿Dar salida al itinerario 58? ───────────────┐
│ Vehículo MBE-114 · Operador Juan Rivas       │
│ 3 paradas · 5 partidas                       │
│ Después de la salida no se puede cambiar lo  │
│ cargado.                                     │
│                 [Cancelar]  [Dar salida]     │
└──────────────────────────────────────────────┘
```

- `ResponsiveDialog` confirmation (US2 scenario 1). With no operator: "Sin operador".

## Dialog: Cerrar parada

### State: filling in, image proof

```
┌ Cerrar parada 2 · Orden 1540 · Materiales Herrera ───────────────────────────────┐
│ Quién recibió                                                                     │
│ Nombre [ Ana Domínguez         ]   Identificación [ INE 0123456789        ]       │
│ ───────────────────────────────────────────────────────────────────────────────── │
│ Qué recibió                              [Todo entregado]  [Nada entregado]       │
│ │ CEM-50 Cemento gris 50 kg │ Enviado 6.00 │ Entregado [ 4.00 ] │ Motivo [Merc. dañada ▾] │
│ │ ARE-01 Arena m³           │ Enviado 2.00 │ Entregado [ 2.00 ] │                         │
│ ───────────────────────────────────────────────────────────────────────────────── │
│ Prueba de entrega        ( Imagen | Firma )                                       │
│ [📎 Elegir imagen]  nota-1540.jpg · 840 KB                         [Quitar]       │
│                                                                                   │
│                                         [Cancelar]  [Cerrar parada]               │
└───────────────────────────────────────────────────────────────────────────────────┘
```

### State: signature proof, incomplete

```
│ Prueba de entrega        ( Imagen | Firma )                                       │
│ ┌───────────────────────────────────────────────────────────────┐                 │
│ │                     ~~~~ firma ~~~~                           │      [Borrar]   │
│ └───────────────────────────────────────────────────────────────┘                 │
│ ✕ Falta el motivo de CEM-50.                                                      │
│                                         [Cancelar]  [Cerrar parada]  (disabled)   │
```

- `ResponsiveDialog`, sections split by the M3 divider.
  - **Who received**: two `CompactField`s, not blank (FR-016).
  - **What they took**: one row per loaded line. Delivered starts at Enviado, between 0 and Enviado. The Motivo dropdown (5 reasons) appears only when Entregado < Enviado (FR-016). "Todo entregado" and "Nada entregado" set every row.
  - **Proof**: an M3 `SegmentedButton`, Imagen | Firma (FR-017). Imagen uses the 061 `FilePicker` flow (jpg, jpeg or png, at most 2 MB, checked before sending). Firma is the signature pad (Open Question 1).
- "Cerrar parada" stays disabled while anything is missing, and a list under the form names what's missing (US3 scenario 5).
- A server refusal shows in `FormErrorBanner`, and the trip reloads (FR-022).

### Compact tier

```
┌ Cerrar parada 2 ─────────────────┐
│ Nombre [ Ana Domínguez        ]  │
│ Identif. [ INE 0123456789     ]  │
│ CEM-50 · enviado 6               │
│   Entregado [ 4 ]  [Merc. dañ ▾] │
│ ARE-01 · enviado 2               │
│   Entregado [ 2 ]                │
│ ( Imagen | Firma )               │
│ [firma …………………………………] [Borrar]   │
│ [Cerrar parada]                  │
└──────────────────────────────────┘
```

- `ResponsiveDialog` goes full screen. Each line becomes two rows. The pad takes the full width, and its output keeps the fixed aspect ratio (research R9).

## Open Questions

1. **The signature pad has no shared component.** `lib/core/widgets/` has nothing that captures a drawing. Options: (a) a feature-local widget, (b) a new `core/widgets/` component, (c) a pub package. The wireframe assumed (a), which is what plan research R9 already chose. *Touches the plan; no change needed.*
2. **"Nada entregado" needs a reason on every line.** Options:
   - (a) the button also shows one "Motivo para todas" picker that fills every row;
   - (b) the user picks a reason row by row;
   - (c) "Nada entregado" asks for the reason first.

   The wireframe assumed (b), the simplest: the per-row dropdowns appear and the missing list names each. A failed delivery (nobody home, wrong address) usually has one reason for the whole stop, so (a) would save clicks. *Touches the spec (FR-016) and research R8.*
3. ~~**Unit column before #343.**~~ **Resolved 2026-11-18**: #343 shipped with `unit_of_measurement` on every line, so Unidad shows the symbol.
4. **An Abierto stop card shows only loaded lines.** The order's unloaded open lines are reachable only through "Cargar línea". Options: (a) loaded lines only (drawn), (b) every open line of the order, with unloaded ones at "Cargado 0" and a load icon. (b) shows at a glance what's left behind, but it adds a third row icon and a row state. The wireframe assumed (a). *Touches the spec (FR-009, FR-010).*
5. **Cancelled trips show nothing.** The server deletes a cancelled trip's stops and lines, so the screen can't show what was on it. The wireframe assumed a single explanatory line. *A spec Edge Cases addition, no requirement change.*
6. **When a stop closed.** The server sets the stop's `arrival_time` at closure, so the card shows "cerrada {hora}" from it (US3 scenario 6's "when it was closed"). *Confirms the spec; Key Entities could name it.*
