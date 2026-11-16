# Wireframes: Inventory Transfers

**Spec**: [spec.md](./spec.md) | **Drawn**: 2026-11-16 | **Fidelity**: low

Drawn from the spec before planning. They follow the shipped Entradas and Salidas de almacén screens (specs 067 and 068, [068's wireframes](../068-warehouse-issues/wireframes.md)), as FR-025 asks. Where a region is the same as there, the annotation says so and the drawing is kept short. Layout is indicative, not prescriptive. Every dimension, colour and spacing resolves through the design tokens, per constitution §V.

What 069 adds to 068: a second warehouse (Destino) on the list, header and dialogs. Four states instead of three. Sent, received and outstanding columns on dispatched lines. The Despachar, Recibir and Cerrar pendiente actions, and the receive dialog. Agregar desde pedido. A new En tránsito screen.

## Screen: Traspasos list (`/inventory/transfers`)

### State: populated

```
┌ Inventario ▸ Traspasos ───────────────────────────────────────────────────────────────────┐
│                               [⇄ En tránsito]  [⚲ Filtros ②]  [＋ Nuevo traspaso]           │
├───────────────┬──────────────┬──────────────┬────────────┬───────────────┬──────────┬───────┤
│         Folio │ Origen       │ Destino      │ Sucursal   │ Estado        │ Creado   │ Fecha │
├───────────────┼──────────────┼──────────────┼────────────┼───────────────┼──────────┼───────┤
│ Borrador #318 │ Bodega Norte │ Sucursal 2 P │ Matriz     │ (Borrador)    │ J. Pérez │ 16/11 │
│           142 │ Bodega Norte │ Piso venta   │ Matriz     │ (En tránsito) │ A. Ruiz  │ 15/11 │
│           141 │ Bodega Sur   │ Bodega Norte │ Sucursal 2 │ (Recibido)    │ L. Soto  │ 14/11 │
│           140 │ Bodega Norte │ Bodega Sur   │ Matriz     │ (Cancelado)   │ J. Pérez │ 13/11 │
├───────────────┴──────────────┴──────────────┴────────────┴───────────────┴──────────┴───────┤
│                                                 1–20 de 73   ‹  1  2  3  4  ›              │
└────────────────────────────────────────────────────────────────────────────────────────────┘
```

- Nav: a third entry in the "Inventario" group, after Salidas de almacén, shown with read on 17 (FR-001).
- Filter row: `CatalogFilterBar` with no search control (FR-003). Its actions slot holds:
  - "En tránsito", an `OutlinedButton.icon` that opens the in-transit screen. It needs only read on 17 (FR-018). The constitution forbids a new AppBar action, so it goes here (Open Question 1).
  - The `Badge.count` + `IconButton.outlined(tune)` filter button.
  - "Nuevo traspaso", a `FilledButton.icon`, shown only with create on 17 and read on warehouses (FR-005, FR-020).
- Table: `DataTableView`. Folio is right-aligned, "Borrador #{id}" for a draft (FR-004). Origen and Destino replace 068's single Almacén. Sucursal is the origin's facility. Estado is a `StatusChip` with four tones (Open Question 2). A row tap opens the detail, with no row icons (FR-025).
- Pagination: `CatalogPagination`, newest first (FR-001).

### State: filter drawer open

```
┌───────────────────────────────────┐
│ Filtros                        ✕  │
│ Estado                            │
│ (Borrador) (En tránsito)          │
│ (Recibido) (Cancelado)            │
│ Almacén (origen o destino)        │
│ [ Bodega Norte                ▾ ] │
│ [Limpiar]              [Aplicar]  │
└───────────────────────────────────┘
```

- `showCatalogFilterSheet`, as in 068 with four state chips. One `CatalogEntityPicker<Warehouse>` offering every warehouse to everyone. The server matches it against origin or destination, and the label says so (FR-003, FR-021).

### State: loading / empty / filtered-empty / error

```
┌──────────────────────────────────────┐ ┌──────────────────────────────────────┐
│ [⇄ En tránsito] [⚲] [＋ Nuevo trasp.] │ │ [⇄ En tránsito] [⚲ ①] [＋ Nuevo …]    │
│                                      │ │                                      │
│          No hay traspasos            │ │  Ningún traspaso coincide con los    │
│                                      │ │  filtros.   [Limpiar filtros]        │
└──────────────────────────────────────┘ └──────────────────────────────────────┘
  empty                                    filtered-empty
```

- `CatalogListStateView` for all four states, as in 068. No access: route-gate redirect, and the entry is absent from the nav (US1 #4).

### Compact tier

```
┌──────────────────────────────┐
│ [⇄]   [⚲ ②]      [＋ Nuevo]   │
├──────────────────────────────┤
│ 142 · Bodega Norte → Piso v. │
│ (En tránsito)           15/11│
├──────────────────────────────┤
│ Borrador #318 · B. Norte → … │
│ (Borrador)              16/11│
└──────────────────────────────┘
```

- Sucursal and Creado por are dropped (they are on the detail). Origin and destination fold into one "A → B" line. This is the shared compact behaviour, as in 068 (Open Question 9).

---

## Screen: Transfer detail (`/inventory/transfers/:id`)

### State: draft, no lines

```
┌ ← Traspaso · Borrador #318 ─────────────────────────────────────────────────────────────┐
│ Estado (Borrador)   Folio —   Origen Bodega Norte   Destino Sucursal 2 Piso            │
│ Sucursal Matriz     Notas  Surtido semanal                                             │
│ Creado por J. Pérez 16/11 10:02   ·   Modificado por J. Pérez 16/11 10:02              │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│ Partidas                                                                                │
│                    Agrega los productos que se van a traspasar.                         │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│ [Cancelar]   [Editar encabezado] [Agregar desde pedido] [Agregar producto]  [Despachar]  │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

- Header: `FactStripRow`s in a `ResponsiveFormGrid`, as in 068, with an added Destino fact. Sucursal follows the origin (FR-007). The AppBar has no actions.
- Action area: `OutlinedButton`s plus a `FilledButton` Despachar, in 068's order, with "Agregar desde pedido" next to "Agregar producto" (FR-012). Each is absent without its right, and Agregar desde pedido also needs read on sales orders (FR-020).
- Despachar on an empty draft shows `inventory_document.no_lines` in the banner.

### State: draft with lines

```
┌ ← Traspaso · Borrador #318 ─────────────────────────────────────────────────────────────┐
│ Estado (Borrador)   Folio —   Origen Bodega Norte   Destino Sucursal 2 Piso            │
├────────┬──────────────────────────────────────────────────────┬──────────────┬──────────┤
│ Código │ Producto                                             │     Cantidad │          │
├────────┼──────────────────────────────────────────────────────┼──────────────┼──────────┤
│ A-100  │ Tornillo 1/4 caja                                    │           10 │  ✎   🗑  │
│ B-220  │ Taquete 5/16                                         │            5 │  ✎   🗑  │
├────────┴──────────────────────────────────────────────────────┴──────────────┴──────────┤
│ [Cancelar]   [Editar encabezado] [Agregar desde pedido] [Agregar producto]  [Despachar]  │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

- Lines: `DataTableView` with Código, Producto and Cantidad, as on 068 (FR-010). ✎ and 🗑 come from `buildCatalogRowActions`, shown only on a draft with update on 17 (FR-008).

### State: dispatch refused

```
├─────────────────────────────────────────────────────────────────────────────────────────┤
│ ⛔ No hay existencias suficientes: se requieren 10 y hay 6 disponibles.                   │
│    Producto: A-100 · Almacén: Bodega Norte                                               │
│ [Cancelar]   [Editar encabezado] [Agregar desde pedido] [Agregar producto]  [Despachar]  │
```

- `ErrorBanner` above the action area with the localized `inventory_document.insufficient_stock` (FR-013, FR-022), plus 068's "Producto · Almacén" line. The warehouse is taken from the error's `warehouse_id`, not assumed to be the origin, because on cancel the short warehouse is the destination (Open Question 3).
- The same banner shows `facility.no_in_transit_location` ("Matriz no tiene almacén en tránsito"), `inventory_transfer.same_warehouse`, `facility.other_facility` and `lock.busy`. The transfer stays a draft and no folio is used.

### State: in transit, partly received

```
┌ ← Traspaso 142 ─────────────────────────────────────────────────────────────────────────┐
│ Estado (En tránsito)   Folio 142   Origen Bodega Norte   Destino Piso venta            │
│ Sucursal Matriz        Notas  —                                                        │
├────────┬────────────────────────────────────────┬──────────┬──────────┬────────────────┤
│ Código │ Producto                               │  Enviado │ Recibido │      Pendiente │
├────────┼────────────────────────────────────────┼──────────┼──────────┼────────────────┤
│ A-100  │ Tornillo 1/4 caja                      │       10 │        8 │              2 │
│ B-220  │ Taquete 5/16                           │        5 │        5 │              0 │
├────────┴────────────────────────────────────────┴──────────┴──────────┴────────────────┤
│ [Cancelar]  [Cerrar pendiente]                                              [Recibir]    │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

- Lines show Enviado, Recibido and Pendiente once dispatched (FR-010). No line icons.
- Recibir (`FilledButton`, update on 17) opens the receive dialog (FR-014). Cerrar pendiente and Cancelar are `OutlinedButton`s needing delete on 17 (FR-015, FR-016, FR-017).
- The actions show whenever the rights allow, at either end. A non-administrator at the wrong facility gets `facility.other_facility` in the banner (Open Question 4).

### State: received (in full, or after closing the remainder)

```
┌ ← Traspaso 141 ─────────────────────────────────────────────────────────────────────────┐
│ Estado (Recibido)   Folio 141   Origen Bodega Sur   Destino Bodega Norte               │
├────────┬────────────────────────────────────────┬──────────┬──────────┬────────────────┤
│ Código │ Producto                               │  Enviado │ Recibido │      Pendiente │
│ A-100  │ Tornillo 1/4 caja                      │       10 │        8 │              0 │
├────────┴────────────────────────────────────────┴──────────┴──────────┴────────────────┤
│ [Cancelar]                                                                              │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

- After a close, a line shows Recibido below Enviado and Pendiente 0 ("8 de 10"). The state is the plain Recibido (Open Question 5). Only Cancelar remains (FR-017).
- Cancel refused because the destination already used the goods: banner with `inventory_document.insufficient_stock`, "Almacén: Bodega Norte" (the destination), US6 #3.

### State: cancelled / read-only user / legacy

```
┌ ← Traspaso 140 ─────────────────────────┐  ┌ ← Traspaso 97 ──────────────────────────┐
│ Estado (Cancelado)  Folio 140  …        │  │ Estado (Recibido)  Folio 97  …          │
│ Enviado / Recibido / Pendiente …        │  │ A-100 …   12   12   0                   │
│ (no actions)                            │  │ (legacy: full quantity reads received)  │
└─────────────────────────────────────────┘  └─────────────────────────────────────────┘
```

- Cancelled: no actions, and the lines keep their received figures (US6 #2, #5). Read-only user: every action is absent (FR-020, SC-006). A legacy single-step transfer reads Recibido in full, with nothing special drawn (edge case).
- A draft that was cancelled keeps "Traspaso · Borrador #id" and the simple Cantidad table (FR-004a).

### State: loading / not found

- As in 068: a progress indicator. A not-found or forbidden id shows the shared error view with `resource.not_found` or `auth.forbidden`.

### Compact tier

```
┌──────────────────────────────┐
│ ← Traspaso 142               │
│ (En tránsito)                │
│ Bodega Norte → Piso venta    │
├──────────────────────────────┤
│ A-100 Tornillo 1/4 caja      │
│ Env 10 · Rec 8 · Pend 2      │
├──────────────────────────────┤
│ [Cancelar] [Cerrar pend.]    │
│ [Recibir]                    │
└──────────────────────────────┘
```

- The facts stack, each line folds the three quantities into one text row, and the action area wraps.

---

## Screen: En tránsito (`/inventory/transfers/in-transit`)

### State: populated (administrator)

```
┌ ← En tránsito ──────────────────────────────────────────────────────────────────────────┐
│ Sucursal [ Matriz                  ▾ ]                                                   │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│ Por producto                                                                            │
│ Código │ Producto                                         │                  Pendiente │
│ A-100  │ Tornillo 1/4 caja                                │                         14 │
│ B-220  │ Taquete 5/16                                     │                          3 │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│ Por traspaso                                                                            │
│  Folio │ Origen       │ Destino      │ Código │ Producto                  │  Pendiente │
│    142 │ Bodega Norte │ Piso venta   │ A-100  │ Tornillo 1/4 caja         │          2 │
│    139 │ Bodega Sur   │ Bodega Norte │ A-100  │ Tornillo 1/4 caja         │         12 │
│    139 │ Bodega Sur   │ Bodega Norte │ B-220  │ Taquete 5/16              │          3 │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

- Facility selector: a `CatalogEntityPicker<Facility>` shown only to administrators with read on facilities. It starts on the user's own facility (FR-019).
- Two `DataTableView`s, the per-product totals first, then the outstanding lines. A line row opens its transfer (FR-018). Neither is paginated: the server returns the whole set for one facility (Open Question 6).
- Includes both directions: lines this facility is sending and lines it is receiving.

### State: non-administrator / empty / no facility / error

```
┌ ← En tránsito · Matriz ────────────────┐  ┌ ← En tránsito ──────────────────────────┐
│ (no facility picker)                   │  │ Selecciona una sucursal.                │
│     No hay mercancía en tránsito.      │  │ (admin without a facility: picker only) │
└────────────────────────────────────────┘  └─────────────────────────────────────────┘
```

- Non-administrator: the facility is fixed to their own and named in the title. No picker (US7 #3).
- No facility: an administrator with none sees the prompt and the picker. A non-administrator with none sees `facility.required` localized (US7 #4).
- Loading and error through `CatalogListStateView`.

### Compact tier

- Each table folds as the list does. "Por producto" stays first.

---

## Dialogs (all `ResponsiveDialog`, refusals in `FormErrorBanner`)

```
┌ Nuevo traspaso ─────────────────────┐   ┌ Editar encabezado ──────────────────┐
│ Origen*   [ Bodega Norte        ▾ ] │   │ Origen*   [ Bodega Norte        ▾ ] │
│ Destino*  [                     ▾ ] │   │ Destino*  [ Sucursal 2 Piso     ▾ ] │
│ Notas                               │   │ Notas                               │
│ [                                 ] │   │ [ Surtido semanal                 ] │
│                            0 / 500  │   │                           16 / 500  │
│              [Cancelar] [Crear]     │   │              [Cancelar] [Guardar]   │
└─────────────────────────────────────┘   └─────────────────────────────────────┘
```

- Origen: `CatalogEntityPicker<Warehouse>` through the shared warehouse options, own facility only for a non-administrator. It starts on the point-of-sale warehouse (FR-005, FR-021).
- Destino: every warehouse, starting empty (FR-021). Choosing the same warehouse as the origin is refused by the server (`inventory_transfer.same_warehouse`) and shown in the banner (US2 #2). The dialog doesn't pre-check it (Open Question 7).
- Notas: plain optional notes, 500 max. Transfers have no "Motivo" wording (FR-006).

```
┌ Agregar producto ───────────────┐   ┌ Agregar desde pedido ───────────────────────┐
│ Producto* [ tornillo…       ▾ ] │   │ Pedido*  [ buscar folio o cliente…      ▾ ] │
│ Cantidad* [ 3               ]   │   │          Solo pedidos confirmados.          │
│          [Cancelar] [Agregar]   │   │                  [Cancelar] [Agregar]       │
└─────────────────────────────────┘   └─────────────────────────────────────────────┘
```

- Agregar producto and the line-quantity dialog: identical to 068 (FR-008, FR-009, FR-011).
- Agregar desde pedido: a search picker over sales orders (Open Question 8). On success, a snackbar says how many products were added and that products already present were skipped (FR-012). `sales_order.not_confirmed` shows in the banner (US8 #3).

```
┌ Recibir traspaso 142 ───────────────────────────────────────────────┐
│ Código │ Producto                 │ Pendiente │ Recibir             │
│ A-100  │ Tornillo 1/4 caja        │         2 │ [ 2               ] │
│ B-220  │ Taquete 5/16             │         3 │ [ 3               ] │
│                                                                     │
│ Deja en 0 lo que no llegó. Lo pendiente se puede recibir después.   │
│                                   [Cancelar] [Recibir]              │
└─────────────────────────────────────────────────────────────────────┘
```

- Lists only lines with something outstanding, each filled in with its outstanding quantity (FR-014). A quantity above Pendiente shows a field error and disables Recibir. Lines at 0 are left out, and Recibir is disabled when all are 0. Built from `ResponsiveDialog` + `DataTableView` + `CompactField` (Open Question 10).
- When nothing was changed, the dialog sends the receive-everything request (no body). Otherwise it sends every row above 0, the untouched ones included, so lowering one line doesn't drop the others. `inventory_transfer.over_received` (a concurrent receipt) shows in the banner, and the transfer is reloaded.

```
┌ Despachar traspaso ─────────────────────────┐  ┌ Cerrar pendiente ───────────────────────────┐
│ Despachar asigna un folio y retira las      │  │ Lo pendiente (2 unidades en 1 partida)      │
│ existencias de Bodega Norte. Quedan en      │  │ regresa a Bodega Norte y el traspaso queda  │
│ tránsito hasta que Piso venta las reciba.   │  │ como Recibido. Si se perdió, regístralo     │
│ Después ya no se puede editar.              │  │ después con una salida de almacén.          │
│            [Volver] [Despachar]             │  │          [Volver] [Cerrar pendiente]        │
└─────────────────────────────────────────────┘  └─────────────────────────────────────────────┘
┌ Cancelar traspaso ──────────────────────────────────────────┐
│ Cancelar el traspaso 142 regresa a Bodega Norte lo que está │
│ en tránsito y lo que Piso venta ya recibió.                 │
│                       [Volver] [Cancelar traspaso]          │
└─────────────────────────────────────────────────────────────┘
```

- Prompts name the warehouses involved (FR-013, FR-015, FR-016). A draft's cancel prompt reads "Cancelar el borrador" and mentions no stock. A cancel with nothing received yet omits "y lo que … ya recibió".

---

## Open Questions

All ten were answered at plan time (2026-11-16) with the option the wireframe assumed. [research.md](research.md) records each answer: Q1 → R2, Q2 → R3, Q3 → R6, Q4 → R5, Q5 → R10, Q6 → R9, Q7 → R5, Q8 → R8, Q9 → R2, Q10 → R7. None changed the spec.

1. **Where does the in-transit view live?** Options: (a) an "En tránsito" button in the Traspasos filter row, opening its own route; (b) its own nav entry in Inventario; (c) a tab on the Traspasos list. The wireframe assumed **(a)**: §VI forbids a new AppBar shortcut and allows filter-row actions, and the spec ranks the view P3. (b) would add a fourth Inventario entry for a secondary view.
2. **Status labels and the shared chip.** "Traspaso" is masculine and has four states, while the shared `InventoryDocumentStatus` chip (from 068) has three feminine labels (Borrador, Confirmada, Cancelada). Options: (a) a transfer-specific status enum and chip with labels Borrador / En tránsito / Recibido / Cancelado, reusing the shared tones; (b) extend the shared enum with the two transfer states and gendered labels. The wireframe assumed **(a)**. Plan decides the code shape.
3. **Which warehouse does an insufficient-stock refusal name?** On dispatch it is the origin. On cancel of a received transfer it is the destination. The wireframe assumed the warehouse comes from the error's `warehouse_id` param, looked up by name, unlike 068 which used the document's single warehouse.
4. **Should actions hide at the wrong end?** A non-administrator with update rights at the origin facility could be offered Recibir, which the server will refuse (receive belongs to the destination facility). Options: (a) show whenever the rights allow and let the server refuse, as the spec says; (b) hide Recibir unless the user's facility is the destination's, and Despachar/Cancelar unless it is the origin's. The wireframe assumed **(a)**, per the spec's edge case. (b) is friendlier but duplicates a server rule in the UI.
5. **Is a closed shortfall visible?** After Cerrar pendiente the state is plain Recibido, and lines show Recibido < Enviado. Options: (a) leave it to the line figures; (b) add a "Cerrado con faltante" fact when any line received less than it was sent. The wireframe assumed **(a)**. The server has no flag for it, and legacy transfers would need care.
6. **Pagination of the in-transit view.** The endpoint returns the full set for a facility, with no paging. The wireframe assumed two unpaginated tables. A facility with hundreds of outstanding lines would make a long page.
7. **Same-warehouse pre-check.** The dialog could block origin = destination before sending. The wireframe assumed it relies on the server's refusal, as 068 relies on the server for in-transit warehouses. A client check is cheap if wanted.
8. **Which sales orders does Agregar desde pedido offer?** Options: (a) reuse the delivery-orders sale search, filtered to completed orders; (b) a plain number field for the order id. The wireframe assumed **(a)**. Plan must confirm the search can filter to completed, non-cancelled orders.
9. **Compact tier.** As in 067 and 068, §VI defers the phone tier. The wireframe assumed **no compact-specific work**.
10. **Receive dialog with an editable table.** No shared widget is a table with editable quantity cells. The wireframe draws `DataTableView` rows with a `CompactField` in the last column. Plan should check whether 067's purchase-order receipt or the delivery-order pickup dialog already has this shape to reuse.
