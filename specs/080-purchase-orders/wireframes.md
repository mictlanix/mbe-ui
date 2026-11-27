# Wireframes: Purchase Orders with Receipts, PDF and Email

**Spec**: [spec.md](./spec.md) | **Drawn**: 2026-11-27 | **Fidelity**: low

Drawn from the spec before planning. Layout is indicative, not prescriptive. Every dimension, colour and spacing comes from the design tokens (constitution §V). Names of suppliers, warehouses, facilities and employees are drawn as names; how they are resolved from the ids the server returns is Open Question 1.

Both screens join the "Compras" navigation group from spec 079, after Aprobación de solicitudes, gated on `PrivilegeGate(SystemObject.purchasesOrders, AccessRight.read)` (FR-001).

## Screen: Órdenes de compra list (`/purchases/orders`)

### State: populated, default scope ("Mis órdenes")

```text
┌ Compras ▸ Órdenes de compra ────────────────────────────────────────────────────────────┐
│ [⌕ Número           ]                                  [⚲ Filtros]  [＋ Nueva orden]    │
├────────┬──────────────────┬──────────────┬──────────┬───────────┬───────┬────┬──────────┤
│ Número │ Proveedor        │ Estado       │ Entrega  │ Creó      │ Fecha │ Pt.│    Total │
├────────┼──────────────────┼──────────────┼──────────┼───────────┼───────┼────┼──────────┤
│   5534 │ Tornillería del… │ (Borrador)   │ 05/12    │ M. Soto   │ 27/11 │  3 │ 1,240.00 │
│   5531 │ Ferretera Norte  │ (Confirmada) │ 02/12    │ M. Soto   │ 26/11 │ 12 │ 18,903.5 │
│   5530 │ —                │ (Borrador)   │ —        │ M. Soto   │ 26/11 │  0 │     0.00 │
├────────┴──────────────────┴──────────────┴──────────┴───────────┴───────┴────┴──────────┤
│                                                1–20 de 37   ‹  1  2  ›                  │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

- Filter row: `CatalogFilterBar` with `CatalogSearchBar` (number search, FR-005), the badged filters button and a filled "Nueva orden" (create on 20, FR-010).
- Table: `DataTableView`, `StatusChip` via the inventory document status chip (draft / completed / cancelled, the receipts' values; Open Question 4 for the labels). Proveedor is truncated with a tooltip; Total is never truncated (FR-006).
- Row: no icons; row tap opens the detail (research R2 dropped the ✎ first drawn here, to match 079's document reading).
- Pagination: `CatalogPagination`, newest first (FR-004).

### State: filter drawer open

```text
┌───────────────────────────────┐
│ Filtros                    ✕  │
│ Mostrar                       │
│ (Mis órdenes) (Todas)         │
│ Estado                        │
│ (Borrador) (Confirmada)       │
│ (Cancelada)                   │
│ Proveedor [ Todos         ▾ ] │
│ Creó      [ Todos         ▾ ] │
│ Fecha     [ 01/11 – 27/11   ] │
│ [Limpiar]          [Aplicar]  │
└───────────────────────────────┘
```

- `showCatalogFilterSheet`. Mostrar: "Todas" sends `all=true` and counts in the badge (FR-004, same as 079 R9). Proveedor and Creó are `CatalogEntityPicker`s, each shown only with read on its catalog; Fecha is `DateRangeFilterChip` (FR-005). No facility facet (FR-003).

### State: loading / empty / filtered-empty / error / no access

```text
┌──────────────────────────────────┐ ┌──────────────────────────────────┐
│ [⌕ Número] [⚲] [＋ Nueva orden]   │ │ [⌕ Número] [⚲ ①] [＋ Nueva orden]│
│   No tienes órdenes de compra.   │ │  Ninguna orden coincide con los  │
│                                  │ │  filtros. [Limpiar filtros]      │
└──────────────────────────────────┘ └──────────────────────────────────┘
  empty                                filtered-empty
```

- `CatalogListStateView` renders all four; error is `ErrorBanner` with retry. No access: the entry is absent and the route redirects.

### Compact tier

```text
┌──────────────────────────────┐
│ [⌕ Número]            [⚲ ①]  │
│                    [＋ Nueva] │
├──────────────────────────────┤
│ 5531 · Ferretera Norte       │
│ (Confirmada)       18,903.50 │
├──────────────────────────────┤
│ 5534 · Tornillería del Ce…   │
│ (Borrador)          1,240.00 │
└──────────────────────────────┘
```

- Drops Entrega, Creó, Fecha and Partidas; they are on the detail.

---

## Screen: Por comprar (`/purchases/to-purchase`)

Redrawn after `/speckit-analyze` (findings C1, C2): one toolbar "Crear orden" over a selected group, and pagination.

### State: populated, one group selected and expanded

```text
┌ Compras ▸ Por comprar ──────────────────────────────────────────────────────────────────┐
│                                   [⚲ Filtros]  [↻ Actualizar]  [＋ Crear orden]         │
├──────────────────────────────────────────────────────────────────────────────────────────┤
│ (•) ▾ Ferretera Norte · Matriz                          4 partidas   est. 8,410.00       │
│   ┌──────────┬────────┬──────────────────────┬──────────┬──────────────┬──────────────┐ │
│   │ Solicitud│ Código │ Producto             │ Cantidad │ Almacén      │        Costo │ │
│   ├──────────┼────────┼──────────────────────┼──────────┼──────────────┼──────────────┤ │
│   │      566 │ A-100  │ Tornillo 1/4 caja    │    12.00 │ Bodega Norte │       310.00 │ │
│   │      571 │ C-007  │ Rondana              │   100.00 │ Bodega Norte │    sin costo │ │
│   └──────────┴────────┴──────────────────────┴──────────┴──────────────┴──────────────┘ │
│ ( ) ▸ Ferretera Norte · Sucursal 2                      2 partidas   est. 1,020.00       │
│ ( ) ▸ Tornillería del Centro · Matriz                   1 partida      est. 95.00        │
│     ▸ Sin proveedor · Matriz                            3 partidas   est. 2,310.00       │
│         Agrégalas a mano en una orden.                                                   │
├──────────────────────────────────────────────────────────────────────────────────────────┤
│                                                1–4 de 4   ‹ 1 ›                         │
└──────────────────────────────────────────────────────────────────────────────────────────┘
```

- Filter row: `CatalogFilterBar` with no search (the endpoint has none); its actions slot holds the badged filters button (Sucursal facet, only with read on facilities), "Actualizar", and the filled "Crear orden" (create on 20, disabled until a group is selected) (FR-008, FR-031). Create stays a toolbar action (§VI).
- Each group is an expandable card with a `Radio` for selection (supplier groups only), supplier (or "Sin proveedor"), facility, line count and estimated total (FR-007). Its lines are a `DataTableView`. A line without cost shows "sin costo" and counts 0 in the estimate (edge case).
- Pagination: `CatalogPagination`, 20 groups per page over the loaded response, until mbe-api#354 pages on the server (§VI).
- The screen reloads when it regains focus and after any create (FR-009).

### State: after Crear orden with lines left out

```text
│ ✓ Orden 5535 creada con 3 partidas. 1 partida ya estaba en otra orden.            │ ← SnackBar
```

- The detail of the new order opens (US1 #2). The left-out count comes from `skipped` (FR-018); the reason text is not shown (spec Assumptions).

### State: empty / loading / error

```text
┌ Compras ▸ Por comprar ────────────────────────────────────────────────────────────┐
│                               [⚲ Filtros]  [↻ Actualizar]  [＋ Crear orden]       │
│                 No hay partidas pendientes de comprar.                            │
└───────────────────────────────────────────────────────────────────────────────────┘
```

- `CatalogListStateView`; error is `ErrorBanner` with retry; with a facility chosen the empty state offers "Limpiar filtros".

### Compact tier

```text
┌──────────────────────────────┐
│ [⚲ ①] [↻] [＋ Crear orden]    │
├──────────────────────────────┤
│ (•) ▾ Ferretera Norte·Matriz │
│   4 · est. 8,410.00          │
│   566 A-100 Tornillo 1/4…    │
│   12.00 → Bodega Norte 310.00│
└──────────────────────────────┘
```

---

## Screen: Orden de compra detail (`/purchases/orders/:id`)

A full detail screen: it owns a child collection (lines) and linked records (receipts), and needs its own URL (§VI record surface).

### State: draft with lines and warnings

```text
┌ ← Orden de compra 5534 ─────────────────────────────────────────────────────────────────┐
│ Estado (Borrador)   Proveedor Tornillería del Centro   Entrega 05/12/2026               │
│ Notas  Entregar en andén 2                    Creó M. Soto 27/11 10:12                  │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│ ⚠ C-007 Rondana: precio 0; no actualizará el costo.                                     │
│ ⚠ B-220 Taquete 5/16: su proveedor es Ferretera Norte, no el de la orden.               │
├────────┬────────────────────┬──────────────┬──────────┬──────────┬─────┬──────────┬──────┤
│ Código │ Producto           │ Almacén      │ Cantidad │   Precio │ IVA │  Importe │      │
├────────┼────────────────────┼──────────────┼──────────┼──────────┼─────┼──────────┼──────┤
│ A-100  │ Tornillo 1/4 caja  │ Bodega Norte │  12.0000 │  25.8333 │ 16% │   310.00 │ ✎ 🗑 │
│ C-007  │ Rondana   Sol. 571 │ Bodega Norte │ 100.0000 │   0.0000 │ 16% │     0.00 │ ✎ 🗑 │
│ B-220  │ Taquete 5/16       │ Bodega Sur   │  24.0000 │  38.7500 │ 16% │   930.00 │ ✎ 🗑 │
├────────┴────────────────────┴──────────────┴──────────┴──────────┴─────┴──────────┴──────┤
│                                    Subtotal 1,240.00   IVA 198.40   Total 1,438.40     │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│ [Cancelar orden]   [Editar encabezado] [Agregar solicitud] [Agregar producto] [Confirmar]│
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

- Header: `FactStripRow`s in a `ResponsiveFormGrid` (FR-011, FR-012). AppBar has no actions (§VI).
- Warning band: Spanish, computed by the UI (FR-019), one line per affected product; never blocks. Uses 067's band pattern (`receipt_warnings.dart`); Open Question 5 on promoting it.
- Lines: `DataTableView`; "Sol. 571" is the request folio for a line from a request (FR-016). ✎ 🗑 from `buildCatalogRowActions` with update on 20 (FR-013). Prices show their stored decimals (Open Question 6).
- Totals: a totals band below the lines (FR-012, shown in every state).
- Action area: `Wrap` of buttons, filled "Confirmar" last. Cancelar orden needs delete on 20, the rest update on 20 (FR-002, FR-024). Confirmar is disabled without a supplier or lines (US2 #6), with the reason as a tooltip.

### State: new draft, no supplier, no lines

```text
┌ ← Orden de compra 5530 ─────────────────────────────────────────────────────────────────┐
│ Estado (Borrador)   Proveedor —   Entrega —                                             │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│ Partidas                                                                                │
│        Agrega productos o las partidas de una solicitud aprobada.                       │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│ [Cancelar orden]   [Editar encabezado] [Agregar solicitud] [Agregar producto] [Confirmar]│
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

- Not reachable from the UI: the server's create requires a supplier and an update cannot clear it. Kept to show the empty-lines state (Open Question 7).

### State: confirmed, partly received

```text
┌ ← Orden de compra 5531 ─────────────────────────────────────────────────────────────────┐
│ Estado (Confirmada)  Proveedor Ferretera Norte  Entrega 02/12/2026  Creó M. Soto 26/11  │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│ Entradas                                                                                │
│   Entrada 8812 (Confirmada)  Bodega Norte · Matriz       9 partidas            [Abrir] │
│   Entrada 8813 (Borrador)    Bodega Sur · Sucursal 2     3 partidas            [Abrir] │
├────────┬────────────────────┬──────────────┬──────────┬──────────┬──────────┬───────────┤
│ Código │ Producto           │ Almacén      │ Cantidad │ Recibido │ Pendiente│   Importe │
├────────┼────────────────────┼──────────────┼──────────┼──────────┼──────────┼───────────┤
│ A-100  │ Tornillo 1/4 caja  │ Bodega Norte │  12.0000 │  12.0000 │   0.0000 │    310.00 │
│ B-220  │ Taquete 5/16       │ Bodega Sur   │  24.0000 │   0.0000 │  24.0000 │    930.00 │
│ S-001  │ Flete (servicio)   │ Bodega Norte │   1.0000 │        — │        — │    500.00 │
├────────┴────────────────────┴──────────────┴──────────┴──────────┴──────────┴───────────┤
│                                 Subtotal 18,903.50   IVA 3,024.56   Total 21,928.06    │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│                                                     [✉ Enviar por correo] [⎙ Imprimir] │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

- Entradas: the generated receipts with number, warehouse, facility and line count (FR-022). "Abrir" pushes the existing receipt detail (`/inventory/receipts/:id`). The response's `receipts` carries no state; the chip is drawn but needs a lookup (Open Question 8).
- Recibido / Pendiente replace Precio and IVA on a confirmed order (FR-023); a non-stockable line shows "—". Precio and IVA move to the tooltip or are dropped (Open Question 9).
- Imprimir: read on 20 (FR-026), opens the PDF through the shared printing flow (spec 044). Enviar por correo: update on 20 (FR-027).
- No Cancelar orden on a confirmed order (FR-024).

### State: read-only user / cancelled

```text
┌ ← Orden de compra 5534 ───────────────────┐  ┌ ← Orden de compra 5520 ───────────────────┐
│ Estado (Borrador) …                       │  │ Estado (Cancelada) …                      │
│ Partidas … (no ✎ 🗑)                      │  │ Partidas … (read-only, kept as history)   │
│ (no actions)                              │  │ (no actions)                              │
└───────────────────────────────────────────┘  └───────────────────────────────────────────┘
```

- Read-only draft: no edit, confirm or cancel (edge case, FR-002). Cancelled: lines stay, no print or email (FR-025, US4 #4).

### State: refusal / loading / not found

```text
├─────────────────────────────────────────────────────────────────────────────────────────┤
│ ⛔ La orden ya fue confirmada.                                                          │
│ [Cancelar orden]   [Editar encabezado] [Agregar solicitud] [Agregar producto] [Confirmar]│
```

- `ErrorBanner` above the action area, text from `localizeProblem` (FR-029). After a state conflict (confirmed or cancelled by someone else) the screen reloads (edge case).
- Loading: progress indicator. Not found or forbidden: the shared error view.

### Compact tier

```text
┌──────────────────────────────┐
│ ← Orden de compra 5531       │
│ (Confirmada) Ferretera Norte │
│ Entrega 02/12 · M. Soto      │
├──────────────────────────────┤
│ Entrada 8812 (Conf.) [Abrir] │
│ Entrada 8813 (Borr.) [Abrir] │
├──────────────────────────────┤
│ A-100 Tornillo 1/4 caja      │
│ 12 · rec. 12 · pend. 0 310.00│
├──────────────────────────────┤
│ Total 21,928.06              │
│ [⎙ Imprimir] [✉ Correo]      │
└──────────────────────────────┘
```

- Facts stack; lines fold into two rows; actions wrap with the primary first. No compact-specific work beyond what the shared widgets do (as 079 Open Question 8).

---

## Dialogs (all `ResponsiveDialog`, refusals in `FormErrorBanner`)

```text
┌ Nueva orden de compra ──────────────────┐   ┌ Editar encabezado ──────────────────────┐
│ Proveedor*  [ Ferretera Norte       ▾ ] │   │ Proveedor  [ Ferretera Norte        ▾ ] │
│ Entrega     [ 05/12/2026          📅  ] │   │ Entrega    [ 05/12/2026           📅  ] │
│ Notas       [                         ] │   │ Notas      [ Entregar en andén 2      ] │
│                               0 / 500   │   │                              18 / 500   │
│               [Cancelar] [Crear]        │   │               [Cancelar] [Guardar]      │
└─────────────────────────────────────────┘   └─────────────────────────────────────────┘
```

- Proveedor: `CatalogEntityPicker<Supplier>`. Entrega: date picker with `firstDate` today (FR-011, edge case). Notes `maxLength` 500.

```text
┌ Agregar producto ───────────────────┐   ┌ Editar partida ─────────────────────────┐
│ Producto*  [ tornillo…          ▾ ] │   │ A-100 Tornillo 1/4 caja                 │
│ Cantidad*  [ 1          ]           │   │ Almacén*   [ Bodega Norte          ▾ ]  │
│ (warehouse, price and tax rate come │   │ Cantidad*  [ 12.0000 ]                  │
│  from the server's defaults)        │   │ Precio*    [ 25.8333 ]  antes de IVA    │
│              [Cancelar] [Agregar]   │   │ IVA*       [ 16 %             ▾ ]       │
└─────────────────────────────────────┘   │               [Cancelar] [Guardar]      │
                                          └─────────────────────────────────────────┘
```

- Agregar producto: the server requires a quantity, so the dialog asks for it; product picker limited to purchasable products (FR-013, FR-014).
- Editar partida: quantity > 0, up to 4 decimals; price ≥ 0, up to 7 decimals (FR-015). The warehouse picker can't hide in-transit warehouses; the server's refusal shows (edge case). Tax-rate options: Open Question 10.

```text
┌ Agregar partidas de una solicitud ──────────────────┐
│ Solicitud*  [ 571 · Matriz · Bodega Norte       ▾ ] │
│             solo solicitudes aprobadas               │
│                         [Cancelar] [Agregar]        │
└─────────────────────────────────────────────────────┘
```

- Picker over approved requests (the requests list filtered to Aprobada, everyone's). Folios repeat across facilities, so the option shows the facility (079 Open Question 10). After adding: SnackBar with the count added and the count left out (FR-017, FR-018). Nothing pending or not approved: the coded refusal in the banner.

```text
┌ ¿Confirmar orden 5534? ───────────────────────────────┐   ┌ Cancelar orden 5534 ───────────────┐
│ Ferretera Norte · 3 partidas · Total 1,438.40         │   │ La orden queda cancelada. Sus      │
│ Se crearán entradas en Bodega Norte y Bodega Sur.     │   │ partidas de solicitud vuelven a    │
│ ⚠ 1 partida con precio 0: C-007 Rondana.              │   │ Por comprar.                       │
│ Ya no se podrá editar.                                │   │     [Volver] [Cancelar orden]      │
│                       [Volver] [Confirmar]            │   └────────────────────────────────────┘
└───────────────────────────────────────────────────────┘
```

- Confirmar: always asks (it is not reversible); names the warehouses that will get receipts and the zero-priced lines (FR-021). Afterwards, SnackBar "Orden confirmada; se crearon 2 entradas." and the detail reloads as confirmed.

```text
┌ Enviar orden 5531 por correo ─────────────────────────┐
│ Para*  (ventas@ferreteranorte.mx ✕) (j.luna@fn.mx ✕)  │
│        [ agregar correo…                            ] │
│        Sugeridos de los contactos del proveedor       │
│ Mensaje [                                           ] │
│                                            0 / 1000   │
│ ⛔ El servidor de correo rechazó el envío.             │
│                       [Cancelar] [Enviar]             │
└───────────────────────────────────────────────────────┘
```

- Same chip-input layout as the quote email dialog (`quote_email_dialog.dart`): suggestions from the supplier's contacts, 1–10 valid addresses, message up to 1,000 (FR-027). 502 and 503 have their own messages and keep the input (FR-028). Sharing that dialog or copying it is Open Question 11.

---

## Open Questions

Settled by `/speckit-clarify` (2026-11-27, see the spec's Clarifications): 2 → ask mbe-api#354 for supplier filter, search and paging; ship with the facility filter only until then (FR-031). 8 → ask mbe-api#355 to list linked receipts with state on every order response; until then the receipts show only right after confirming (FR-022). 12 → link both screens (FR-030). 13 → no client-side mismatch warning; coded warnings asked in mbe-api#353 (FR-019). The rest are left to planning. After `/speckit-analyze`: 2 → Por comprar also pages its loaded groups on the client (§VI); 3 → one toolbar Crear orden over a selected group (§VI: create is toolbar-only).

1. **Names for creator, warehouse and facility.** List rows carry `supplier_name` but only ids for creator; lines, groups and receipts carry warehouse and facility ids. *Assumed:* the name lookups 067 and 079 use (`inventory_name_cells.dart`), as for requests.
2. **Por comprar has no search, facets or pagination.** The endpoint returns every pending group at once. Options: (a) treat it as bounded (pending lines are cleared by ordering) and ship without; (b) filter client-side by supplier and facility in the drawer; (c) ask mbe-api for filters and paging. *Assumed:* (a), plus the expandable groups to keep it scannable. §VI needs this decided explicitly.
3. **One "Crear orden" per group.** §VI puts screen actions in the filter row or the record's action area; a per-group button is neither. Options: (a) the button in each group header (drawn); (b) select a group, then one toolbar "Crear orden". *Assumed:* (a); it is the group's own action, like a row action, and keeps it one click.
4. **State labels.** Orders use the receipt values draft/completed/cancelled. *Assumed:* "Borrador / Confirmada / Cancelada", reusing the inventory document status chip with "Confirmada" for completed, as the spec's "confirmed" says.
5. **Warning band.** A fourth feature needs a non-blocking warning band (067, 068, 079, now 080). *Assumed:* reuse 067's pattern; planning decides whether to promote it to `core/widgets/`.
6. **Price and quantity decimals.** The server keeps 7 decimals on price and 4 on quantity. *Assumed:* edit at full precision; show 4 decimals for price and quantity in the table, and money (2 decimals) for amounts and totals.
7. **Supplier on a new order.** The server's create requires a supplier, and an update can't clear it (a null `supplier` on update means "unchanged"). *Assumed:* supplier required in Nueva orden, so the "no supplier" draft never appears and FR-021's supplier check is only a server guard. The no-supplier drawing is kept only for completeness.
8. **Receipt state on the order.** `receipts` gives id, warehouse, facility and line count, not state. Options: (a) fetch each receipt's state; (b) show no state, just the link; (c) ask the server to include it. *Assumed:* (b) for now; received and pending on the lines already show progress.
9. **Columns on a confirmed order.** Adding Recibido and Pendiente to Precio and IVA overflows the regular tier. *Assumed:* confirmed orders swap Precio/IVA for Recibido/Pendiente; drafts show Precio/IVA. Alternative: keep all and truncate Producto harder.
10. **Tax-rate choices.** The server takes any rate and defaults to the product's. *Assumed:* a picker of the rates already offered elsewhere in the back office (0 %, 8 %, 16 %, exento), not free text; planning checks what product editing uses.
11. **Email dialog reuse.** The quote email dialog is sales-specific. Options: (a) generalize it into a shared document-email dialog (chips, suggestions, 502/503 messages, optional message field); (b) copy it into purchases. *Assumed:* (a), since a second document now needs it; the PO adds the message field.
12. **Links from existing screens.** The request detail (079) shows an order number as text, and so does the receipt detail (067), because there was no order screen. *Assumed:* turn both into links to the order detail in this feature; it is small and is what 079 Open Question 7 deferred. This touches two existing screens, so the spec should say so.
13. **Supplier mismatch warning needs the product's supplier.** Order lines carry the product id, not its supplier; the product record does have one. *Assumed:* the UI looks up the products on the order (batch product lookup) to compare suppliers. If that is too heavy, drop the warning and rely on Por comprar grouping by supplier.
