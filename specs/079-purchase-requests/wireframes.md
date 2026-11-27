# Wireframes: Purchase Requests with Approval

**Spec**: [spec.md](./spec.md) | **Drawn**: 2026-11-26 | **Fidelity**: low

Drawn from the spec before planning. Layout is indicative, not prescriptive. Every dimension, colour and spacing comes from the design tokens (constitution §V). Names of warehouses, facilities and employees are drawn as names; how they are resolved from the ids the server returns is Open Question 1.

## Screen: Solicitudes de compra list (`/purchases/requests`)

A new "Compras" navigation group, after Inventario and before Finanzas, gated on `PrivilegeGate(SystemObject.purchaseRequest, AccessRight.read)` (FR-001).

### State: populated, default scope ("Mis solicitudes")

```text
┌ Compras ▸ Solicitudes de compra ────────────────────────────────────────────────────────┐
│ [⌕ Folio            ]                                [⚲ Filtros ①]  [＋ Nueva solicitud] │
├───────────────┬────────────┬──────────────┬─────────────┬───────────┬───────┬───────────┤
│         Folio │ Sucursal   │ Almacén      │ Estado      │ Solicitó  │ Fecha │ Partidas  │
├───────────────┼────────────┼──────────────┼─────────────┼───────────┼───────┼───────────┤
│ Borrador #212 │ Matriz     │ Bodega Norte │ (Borrador)  │ J. Pérez  │ 26/11 │         0 │
│           571 │ Matriz     │ Bodega Norte │ (Enviada)   │ J. Pérez  │ 25/11 │         7 │
│           569 │ Matriz     │ Piso venta   │ (Borrador)  │ J. Pérez  │ 24/11 │         3 │
│           566 │ Matriz     │ Bodega Norte │ (Aprobada)  │ J. Pérez  │ 22/11 │        12 │
├───────────────┴────────────┴──────────────┴─────────────┴───────────┴───────┴───────────┤
│                                                1–20 de 41   ‹  1  2  3  ›               │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

- Filter row: `CatalogFilterBar`. Its search slot is a numeric folio field (FR-003, server `serial`). The scope ("Mis solicitudes" or "Todas") is in the filter drawer, not the row: §VI keeps facet controls out of the filter row (FR-002, Open Question 3). The actions slot holds the filters `IconButton.outlined` with `Badge.count` and the "Nueva solicitud" `FilledButton.icon`, shown only with create on 86 and read on warehouses (FR-006, FR-025).
- Table: `DataTableView`. Folio is right-aligned; a request never submitted shows "Borrador #{id}" (FR-004). Folio 569 is a rejected request: a draft that keeps its folio (US4). Estado is a `StatusChip`. Partidas is right-aligned. Row tap opens the detail; no row icons (§VI).
- Pagination: `CatalogPagination`, newest first (FR-001).

### State: filter drawer open

```text
┌───────────────────────────────┐
│ Filtros                    ✕  │
│ Mostrar                       │
│ (Mis solicitudes) (Todas)     │
│ Estado                        │
│ (Borrador) (Enviada)          │
│ (Aprobada) (Cancelada)        │
│ Sucursal  [ Matriz        ▾ ] │
│ Almacén   [ Todos         ▾ ] │
│ Solicitó  [ Todos         ▾ ] │
│ Fecha     [ 01/11 – 26/11   ] │
│ [Limpiar]          [Aplicar]  │
└───────────────────────────────┘
```

- Mostrar: two choice chips, "Mis solicitudes" by default; "Todas" sends `all=true` and counts as one active filter in the badge, so the wider scope is visible from the row (FR-002).
- `showCatalogFilterSheet` with single-select choice chips, `CatalogEntityPicker`s for facility, warehouse and employee, and `DateRangeFilterChip` (FR-003). Each picker is shown only with read on its catalog (FR-025). Picking Cancelada shows cancelled requests, which the default scope leaves out.

### State: loading / empty / filtered-empty / error / no access

```text
┌──────────────────────────────────┐ ┌──────────────────────────────────┐
│ [⌕ Folio] [⚲] [＋ Nueva solicitud]│ │ [⌕ Folio] [⚲ ①] [＋ Nueva solic…]│
│   No tienes solicitudes de       │ │  Ninguna solicitud coincide con  │
│   compra.                        │ │  los filtros. [Limpiar filtros]  │
└──────────────────────────────────┘ └──────────────────────────────────┘
  empty                                filtered-empty
```

- `CatalogListStateView` renders loading, empty, filtered-empty and error (`ErrorBanner` with retry). The empty text depends on the scope ("No hay solicitudes de compra." under Todas).
- No access: the route gate redirects and the entry is absent; the whole Compras group is absent when neither of its entries is visible (US3 #6).

### Compact tier

```text
┌──────────────────────────────┐
│ [⌕ Folio]             [⚲ ①]  │
│                   [＋ Nueva]  │
├──────────────────────────────┤
│ 571 · Bodega Norte           │
│ (Enviada)        7 · 25/11   │
├──────────────────────────────┤
│ Borrador #212 · Bodega Norte │
│ (Borrador)       0 · 26/11   │
└──────────────────────────────┘
```

- Sucursal and Solicitó are dropped; they are on the detail. As in 067, this depends on the shared table's compact behaviour (Open Question 8).

---

## Screen: Solicitud detail (`/purchases/requests/:id`)

### State: new draft, no lines

```text
┌ ← Solicitud · Borrador #212 ──────────────────────────────────────────────────────┐
│ Estado (Borrador)   Folio —   Almacén Bodega Norte   Sucursal Matriz               │
│ Notas  Para el pedido de diciembre                                                │
│ Solicitó J. Pérez 26/11 09:40                                                     │
├───────────────────────────────────────────────────────────────────────────────────┤
│ Partidas                                                                          │
│                  Agrega los productos que necesitas.                              │
├───────────────────────────────────────────────────────────────────────────────────┤
│ [Cancelar]                     [Editar encabezado] [Agregar producto]  [Enviar]   │
└───────────────────────────────────────────────────────────────────────────────────┘
```

- Header: `FactStripRow`s in a `ResponsiveFormGrid` (FR-005, FR-009). The AppBar has no actions (§VI).
- Action area: outlined buttons plus a filled "Enviar". Each is absent without its right: Cancelar needs delete on 86, the rest update on 86 (FR-016, FR-018, FR-025). Enviar on an empty draft shows the server's refusal (US1 #7).

### State: draft with lines and a minimum-quantity warning

```text
┌ ← Solicitud · Borrador #212 ──────────────────────────────────────────────────────┐
│ Estado (Borrador)   Folio —   Almacén Bodega Norte   Sucursal Matriz               │
├───────────────────────────────────────────────────────────────────────────────────┤
│ ⚠ A-100 Tornillo 1/4 caja: 5 es menos que el mínimo de compra (12).               │
├────────┬────────────────────────────┬──────────┬───────────────┬────────┬─────────┤
│ Código │ Producto                   │ Cantidad │ Destino       │ Comprar│         │
├────────┼────────────────────────────┼──────────┼───────────────┼────────┼─────────┤
│ A-100  │ Tornillo 1/4 caja          │     5.00 │ Bodega Norte  │   ✓    │  ✎  🗑  │
│ B-220  │ Taquete 5/16 (nombre edit.)│    24.00 │ Bodega Sur ²  │   ✓    │  ✎  🗑  │
├────────┴────────────────────────────┴──────────┴───────────────┴────────┴─────────┤
│ [Cancelar]                     [Editar encabezado] [Agregar producto]  [Enviar]   │
└───────────────────────────────────────────────────────────────────────────────────┘
  ² a warehouse of another facility; its facility shows in the tooltip
```

- Warning band: computed by the UI from `quantity` and `min_order_qty`, one line per product below its minimum, never blocking (FR-013). Same open gap as 067: no shared warning banner (Open Question 6).
- Lines: `DataTableView` with ✎ and 🗑 from `buildCatalogRowActions` (FR-010, FR-015). Comprar is read-only on a draft (US5 #3).

### State: submitted, viewed by an approver who can also mark lines

```text
┌ ← Solicitud 571 ──────────────────────────────────────────────────────────────────┐
│ Estado (Enviada)   Folio 571   Almacén Bodega Norte   Sucursal Matriz              │
│ Solicitó J. Pérez 25/11 17:02                                                     │
├────────┬────────────────────────────┬──────────┬───────────────┬────────┬─────────┤
│ Código │ Producto                   │ Cantidad │ Destino       │ Comprar│ Orden c.│
├────────┼────────────────────────────┼──────────┼───────────────┼────────┼─────────┤
│ A-100  │ Tornillo 1/4 caja          │    12.00 │ Bodega Norte  │  [✓]   │         │
│ C-007  │ Rondana                    │   100.00 │ Bodega Norte  │  [ ]   │         │
├────────┴────────────────────────────┴──────────┴───────────────┴────────┴─────────┤
│ [Cancelar]                                          [✕ Rechazar]   [✓ Aprobar]    │
└───────────────────────────────────────────────────────────────────────────────────┘
```

- Comprar is a `Checkbox` cell, interactive only with update on PurchasesOrders (20) on a submitted or approved request (FR-017). Each tap saves that line and shows what the server returned (FR-028, Open Question 4).
- Rechazar and Aprobar need update on 96; they are reached only by users who could open the request, so read on 86 is implied (FR-021, FR-022). There is no Editar or Enviar: a submitted request is read-only for its requester.

### State: approved, with lines on purchase orders

```text
┌ ← Solicitud 566 ──────────────────────────────────────────────────────────────────┐
│ Estado (Aprobada)  Folio 566  Almacén Bodega Norte  Sucursal Matriz                │
│ Solicitó J. Pérez 22/11 12:10      Aprobó M. Soto 23/11 08:31                     │
├────────┬────────────────────────────┬──────────┬───────────────┬────────┬─────────┤
│ Código │ Producto                   │ Cantidad │ Destino       │ Comprar│ Orden c.│
├────────┼────────────────────────────┼──────────┼───────────────┼────────┼─────────┤
│ A-100  │ Tornillo 1/4 caja          │    12.00 │ Bodega Norte  │  [✓]   │ 5530 (B)│
│ B-220  │ Taquete 5/16               │    24.00 │ Bodega Sur    │  [✓]   │         │
├────────┴────────────────────────────┴──────────┴───────────────┴────────┴─────────┤
│ [Cancelar]                                                                        │
└───────────────────────────────────────────────────────────────────────────────────┘
```

- Aprobó: approver and approval time (FR-009, US3 #4).
- Orden c.: the live purchase order's number with its state chip, (B) Borrador here (FR-015, US3 #5). It is text, not a link: there is no purchase-order screen yet (Open Question 7).
- Unmarking A-100 is refused by the server because it is on order 5530; the refusal shows in the banner (US5 #2).

### State: cancelled / read-only user / foreign facility

```text
┌ ← Solicitud 560 ─────────────────────────┐  ┌ ← Solicitud 569 ─────────────────────────┐
│ Estado (Cancelada) Folio 560 …           │  │ Estado (Borrador) … Sucursal Sucursal 2  │
│ Partidas … (Comprar read-only, no ✎ 🗑)  │  │ Partidas … (no ✎ 🗑)                     │
│ (no actions)                             │  │ (no actions: another facility's draft)   │
└──────────────────────────────────────────┘  └──────────────────────────────────────────┘
```

- Cancelled and read-only: every action and line icon is absent (FR-025, SC-005).
- Foreign facility (right): for a non-administrator, editing, line, submit and cancel actions are absent (FR-026, research R12). Approve, reject and marks would still show on a submitted or approved request.

### State: refusal / loading / not found

```text
├───────────────────────────────────────────────────────────────────────────────────┤
│ ⛔ La partida está en la orden de compra 5530 y no se puede desmarcar.             │
│ [Cancelar]                                                                        │
```

- `ErrorBanner` above the action area, text from `localizeProblem` (FR-027). After a state conflict (already approved, rejected or cancelled by someone else) the screen re-fetches (edge case).
- Loading: a progress indicator in the body. Not found or forbidden: the shared error view.

### Compact tier

```text
┌──────────────────────────────┐
│ ← Solicitud 571              │
│ (Enviada) Bodega Norte       │
│ Matriz · J. Pérez 25/11      │
├──────────────────────────────┤
│ A-100 Tornillo 1/4 caja  [✓] │
│ 12.00 → Bodega Norte         │
├──────────────────────────────┤
│ [✓ Aprobar]                  │
│ [✕ Rechazar] [Cancelar]      │
└──────────────────────────────┘
```

- Facts stack in one column; each line folds into two rows; the action `Wrap` breaks with the primary action first (Open Question 8).

---

## Screen: Aprobación de solicitudes (`/purchases/request-approval`)

A second entry in Compras, gated on `PrivilegeGate(SystemObject.purchaseRequestApproval, AccessRight.read)` (FR-019).

### State: populated, approver with 96 read + update and 86 read

```text
┌ Compras ▸ Aprobación de solicitudes ────────────────────────────────────────────────────┐
│                                             [⚲ Filtros]   [✓ Aprobar seleccionadas (2)]│
├───┬───────┬────────────┬──────────────┬───────────┬───────┬──────────┬───────────────┬───┤
│ ☐ │ Folio │ Sucursal   │ Almacén      │ Solicitó  │ Fecha │ Partidas │ Notas         │   │
├───┼───────┼────────────┼──────────────┼───────────┼───────┼──────────┼───────────────┼───┤
│ ☑ │   318 │ Sucursal 2 │ Piso venta   │ L. Ríos   │ 20/11 │        4 │ Urgente para… │ ✓ │
│ ☑ │   571 │ Matriz     │ Bodega Norte │ J. Pérez  │ 25/11 │        7 │               │ ✓ │
│ ☐ │    92 │ Sucursal 5 │ Bodega 5     │ R. Díaz   │ 26/11 │       15 │ Revisar can…  │ ✓ │
├───┴───────┴────────────┴──────────────┴───────────┴───────┴──────────┴───────────────┴───┤
│                                                 1–3 de 3   ‹ 1 ›                         │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

- Filter row: `CatalogFilterBar` with no search (the endpoint has none). Its actions slot holds the badged filters button, whose drawer has one facet, Sucursal (a `CatalogEntityPicker`, shown with read on facilities; §VI keeps pickers out of the row), and the bulk button, shown only with update on 96 and disabled until something is selected (FR-019, FR-023). Without read on facilities there is no facet, so the filters button is left out.
- Table: `DataTableView`, oldest first as the server returns it, no Estado column (every row is Enviada, as in 062). Notas is truncated with a tooltip.
- Selection: a checkbox column for bulk approve, within the current page (FR-023). The header holds a select-all checkbox for the page (Open Question 2).
- Row ✓ "Aprobar" is the `primaryAction` of `buildCatalogRowActions` (FR-021). There is no row ✕: rejecting happens on the detail (Clarification 1).
- Row tap pushes the request detail, so back returns to the queue (FR-020).

### State: approver with 96 only (no read on 86)

The same table, but rows don't respond to a tap: no hover, no pointer (FR-020, Clarification 1). Selection, row ✓ and bulk approve still work.

### State: 96 read only (no update)

No checkbox column, no ✓ column and no bulk button; the queue is look-only (FR-025).

### State: empty / loading / error

```text
┌ Compras ▸ Aprobación de solicitudes ──────────────────────────────────────────────┐
│                                                   [⚲ Filtros ①]                   │
│            No hay solicitudes pendientes de aprobación.                           │
└───────────────────────────────────────────────────────────────────────────────────┘
```

- `CatalogListStateView`; with a facility chosen the empty state offers "Limpiar filtros".

### State: after approve / bulk approve

```text
│ ✓ Solicitud 571 aprobada.                                                          │  ← SnackBar
```

```text
┌ Resultado de la aprobación ─────────────────────────────────┐
│ Se aprobaron 2 de 3 solicitudes.                            │
│                                                             │
│ No se aprobaron:                                            │
│  • 92 (Sucursal 5): la solicitud ya no está enviada.        │
│                                     [Cerrar]                │
└─────────────────────────────────────────────────────────────┘
```

- Single approve: SnackBar, then the queue reloads (FR-024). If the page empties, it steps back one page.
- Bulk: a `ResponsiveDialog` when anything was refused, with each refused folio, its facility (folios repeat across facilities) and the localized reason from its error code (FR-023). When all succeed, a SnackBar "Se aprobaron 3 solicitudes." The queue reloads and the selection clears either way.

### Compact tier

```text
┌──────────────────────────────┐
│ [⚲ ①]        [✓ Aprobar (2)] │
├───┬──────┬──────────┬────┬───┤
│ ☑ │  318 │ Sucurs.2 │  4 │ ✓ │
│ ☐ │   92 │ Sucurs.5 │ 15 │ ✓ │
└───┴──────┴──────────┴────┴───┘
```

- Drops Almacén, Solicitó, Fecha and Notas; they are on the detail.

---

## Dialogs (all `ResponsiveDialog`, refusals in `FormErrorBanner`)

```text
┌ Nueva solicitud ────────────────┐   ┌ Editar encabezado ────────────────────┐
│ Almacén*  [ Bodega Norte    ▾ ] │   │ Almacén  [ Bodega Norte          ▾ ]  │
│ Notas     [                   ] │   │          solo almacenes de Matriz     │
│                        0 / 500  │   │ Notas    [ Para el pedido de dic…   ] │
│            [Cancelar] [Crear]   │   │            [Cancelar] [Guardar]       │
└─────────────────────────────────┘   └───────────────────────────────────────┘
```

- Nueva solicitud: `CatalogEntityPicker<Warehouse>` starting at the point-of-sale warehouse; non-administrators see only their facility's warehouses (FR-006, FR-008). Notes `maxLength` 500.
- Editar encabezado: on a draft that already has a folio, the helper text says the warehouse must stay in its facility; the server enforces it (FR-008, US4 #2).

```text
┌ Agregar producto ───────────────────┐   ┌ Editar partida ─────────────────────────┐
│ Producto*  [ tornillo…          ▾ ] │   │ A-100                                   │
│ (the line opens with its defaults)  │   │ Nombre*    [ Tornillo 1/4 caja       ]  │
│              [Cancelar] [Agregar]   │   │ Cantidad*  [ 5.00 ]  mínimo 12          │
└─────────────────────────────────────┘   │ Destino*   [ Bodega Norte         ▾ ]   │
                                          │               [Cancelar] [Guardar]      │
                                          └─────────────────────────────────────────┘
```

- Agregar producto: product only; the server fills name, minimum quantity and destination (FR-011). Whether to ask for quantity up front is Open Question 9.
- Editar partida: name up to 250, quantity > 0 with at most 2 decimals (FR-010, FR-012), the minimum shown as helper text (FR-013), and a destination picker offering every warehouse (FR-014).

```text
┌ Enviar solicitud ───────────────────────────┐   ┌ Rechazar solicitud 571 ───────────────┐
│ Enviar la solicitud a aprobación. Recibirá  │   │ Matriz · J. Pérez · 7 partidas        │
│ su folio y ya no se podrá editar.           │   │ Motivo *                              │
│ ⚠ A-100: 5 es menos que el mínimo (12).     │   │ [                                   ] │
│                   [Volver] [Enviar]         │   │                               0/500   │
└─────────────────────────────────────────────┘   │ Regresa a borrador para que se        │
                                                  │ corrija; conserva su folio.           │
┌ ¿Aprobar solicitud 571? ────────────────────┐   │             [Volver] [Rechazar]       │
│ Matriz · Bodega Norte · 7 partidas          │   └───────────────────────────────────────┘
│                   [Volver] [Aprobar]        │
└─────────────────────────────────────────────┘   ┌ Cancelar solicitud 566 ───────────────┐
                                                  │ La solicitud queda cancelada y ya no  │
                                                  │ se podrá usar.                        │
                                                  │      [Volver] [Cancelar solicitud]    │
                                                  └───────────────────────────────────────┘
```

- Enviar: a resubmission says "Volverá a aprobación con el folio 569." instead (US4 #1). It repeats the minimum warnings (FR-013, FR-016).
- Rechazar: `maxLength` 500, the button disabled while the trimmed reason is empty (FR-022). The note doesn't promise the requester will see the reason (mbe-api#352).
- Every dialog disables both buttons while submitting, and a lost connection reloads the request or queue behind it, as in 062.

---

## Open Questions

Settled by the plan (2026-11-26, see [research.md](research.md)): 1 → R4, 2 → R10 (a checkbox column built with the existing `DataTableColumn.header`, not a `DataTableView` change), 3 → R9 (the scope moved into the filter drawer after `/speckit-analyze`: §VI keeps facet controls out of the filter row; the queue's facility picker moved there too, R10), 4 → R11, 5 → R12 (hide; spec FR-026 updated), 9 → R6, 10 → R9. Questions 6 and 7 stand as drawn; 8 stays deferred.

1. **Names for warehouse, facility and requester.** Rows carry ids only. Options: (a) the display-name lookups 067 uses (warehouses, facilities, employees); (b) ask mbe-api for names on the summary, as #324–#330 did. *Assumed:* (a), since those lookups already exist; planning confirms.
2. **Row selection for bulk approve.** `DataTableView` sets `showCheckboxColumn: false` and has no selection API. Options: (a) add opt-in selection to `DataTableView` (shared change); (b) a leading `Checkbox` cell column built by this screen; (c) an "Aprobar varias" dialog listing the page's requests with checkboxes, like `copy_invoice_lines_dialog`. *Assumed:* (a) as drawn; (c) avoids touching the shared widget.
3. **Scope switch.** The server's `all` flag could be a `SegmentedButton` in the bar (drawn) or a filter in the drawer. ~~*Assumed:* the bar.~~ **Resolved 2026-11-26 (analysis finding C2):** the drawer, as a "Mostrar" facet counted in the badge. §VI forbids facet controls inline in the filter row, and the drawings above now show it there.
4. **Marking control.** A `Checkbox` cell that saves on tap (drawn), or a row action "Marcar / Desmarcar". *Assumed:* the checkbox; it shows the state and the action in one place, and saves immediately with no prompt because it is easy to reverse.
5. **Foreign-facility requests for a non-administrator.** The UI knows the request's facility and the user's, so it could hide Editar, Enviar and Cancelar instead of letting the server refuse. *Assumed:* show them and let the server refuse, as FR-026 says. Hiding them is kinder and costs one comparison; worth deciding in planning.
6. **No shared warning banner** (same gap as 067 Open Question 1). *Assumed:* reuse 067's feature-local warning widget pattern, or promote it to `core/widgets/` now that a third feature needs it.
7. **Purchase order reference is plain text.** It becomes a link when the purchase-order screen ships (#71). *Assumed:* text now.
8. **Compact tier.** §VI defers phone layouts; the drawings show the reflow but nothing beyond what `DataTableView` and the action `Wrap` already do. *Assumed:* no compact-specific work.
9. **Quantity on Agregar producto.** The server defaults the quantity to the minimum order quantity, so the dialog asks only for the product and the user edits afterwards. Alternative: ask for quantity up front, prefilled with the minimum. *Assumed:* product only, matching FR-011's server defaults; one extra step when the default is wrong.
10. **Folios repeat across facilities.** A request's folio is its facility's serial, so "571" is ambiguous on everyone's list and in the queue. *Assumed:* the Sucursal column sits next to Folio everywhere and the bulk result names the facility; the detail title stays "Solicitud 571".
