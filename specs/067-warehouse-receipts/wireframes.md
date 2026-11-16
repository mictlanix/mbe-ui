# Wireframes: Warehouse Receipts

**Spec**: [spec.md](./spec.md) | **Drawn**: 2026-11-16 | **Fidelity**: low

These wireframes were drawn from the spec. They were drawn *after* the plan, because `/speckit-plan` ran first. Open Questions 2, 3 and 5 were settled by `/speckit-clarify` on 2026-11-16, and the drawings and ui-contract.md now agree. Layout is indicative, not prescriptive. Every dimension, colour and spacing resolves through the design tokens, per constitution §V.

## Screen: Entradas de almacén list (`/inventory/receipts`)

### State: populated

```
┌ Inventario ▸ Entradas de almacén ──────────────────────────────────────────────────────┐
│                                                       [⚲ Filtros ②]  [＋ Nueva entrada] │
├───────────────┬──────────────┬────────────┬──────────┬─────────────┬───────────┬───────┤
│         Folio │ Almacén      │ Sucursal   │ Orden c. │ Estado      │ Creado por│ Fecha │
├───────────────┼──────────────┼────────────┼──────────┼─────────────┼───────────┼───────┤
│ Borrador #318 │ Bodega Norte │ Matriz     │          │ (Borrador)  │ J. Pérez  │ 16/11 │
│          1043 │ Bodega Norte │ Matriz     │ 5512     │ (Confirmada)│ A. Ruiz   │ 15/11 │
│          1042 │ Piso venta   │ Sucursal 2 │          │ (Cancelada) │ J. Pérez  │ 14/11 │
├───────────────┴──────────────┴────────────┴──────────┴─────────────┴───────────┴───────┤
│                                             1–20 de 134   ‹  1  2  3 … 7  ›            │
└────────────────────────────────────────────────────────────────────────────────────────┘
```

- Filter row: `CatalogFilterBar` with **no search control** (FR-003; the endpoint has no search). Its actions slot holds a `Badge.count` + `IconButton.outlined(tune)` and the "Nueva entrada" `FilledButton.icon` (FR-005; shown only with create on 15 and read on 4).
- Table: `DataTableView`. Folio is right-aligned, "Borrador #{id}" for a draft (FR-004). Estado is a `StatusChip` (`InventoryReceiptStatusChip`). Names come from the warehouse, facility and employee display-name lookups (FR-004). The row tap opens the detail. There are **no row icons** (the document reading, plan §VI).
- Pagination: `CatalogPagination`, newest first (FR-001).

### State: filter drawer open

```
┌───────────────────────────────┐
│ Filtros                    ✕  │
│                               │
│ Estado                        │
│ (Borrador) (Confirmada)       │
│ (Cancelada)                   │
│                               │
│ Almacén                       │
│ [ Bodega Norte            ▾ ] │
│                               │
│ [Limpiar]          [Aplicar]  │
└───────────────────────────────┘
```

- `showCatalogFilterSheet` with choice chips (single select) and a `CatalogEntityPicker<Warehouse>`. The picker is shown only with read on 4 (FR-003, FR-016).

### State: loading / empty / filtered-empty / error

```
┌──────────────────────────────┐ ┌──────────────────────────────┐
│ [⚲ Filtros] [＋ Nueva entrada]│ │ [⚲ Filtros ①][＋ Nueva entrada]│
│                              │ │                              │
│     No hay entradas de       │ │  Ninguna entrada coincide    │
│     almacén                  │ │  con los filtros.            │
│                              │ │  [Limpiar filtros]           │
└──────────────────────────────┘ └──────────────────────────────┘
  empty                            filtered-empty
```

- `CatalogListStateView` renders all four states. Loading is its progress state; error is its `ErrorBanner` with retry.
- No access: the route gate shows the shared no-access screen, and the "Inventario" nav group is absent (FR-001, US1 #4).

### Compact tier

```
┌──────────────────────────────┐
│ [⚲ ②]            [＋ Nueva]   │
├──────────────────────────────┤
│ 1043 · Bodega Norte          │
│ (Confirmada)   OC 5512  15/11│
├──────────────────────────────┤
│ Borrador #318 · Bodega Norte │
│ (Borrador)              16/11│
└──────────────────────────────┘
```

- Sucursal and Creado por are dropped; they are on the detail. Orden de compra folds into the second line. This depends on the shared compact table behaviour (see Open Questions 6).

---

## Screen: Receipt detail (`/inventory/receipts/:id`)

### State: draft, not linked, no lines (non-admin with all rights)

```
┌ ← Entrada · Borrador #318 ───────────────────────────────────────────────────────┐
│ Estado (Borrador)   Folio —   Almacén Bodega Norte   Sucursal Matriz               │
│ Notas  Proveedor entregó sin factura                                              │
│ Creado por J. Pérez 16/11 10:02   ·   Modificado por J. Pérez 16/11 10:02          │
├──────────────────────────────────────────────────────────────────────────────────┤
│ Partidas                                                                         │
│                                                                                  │
│                    Agrega los productos recibidos.                               │
│                                                                                  │
├──────────────────────────────────────────────────────────────────────────────────┤
│ [Cancelar]            [Editar encabezado] [Agregar producto]        [Confirmar]   │
└──────────────────────────────────────────────────────────────────────────────────┘
```

- Header: `FactStripRow`s in a `ResponsiveFormGrid` (FR-007). The AppBar has no actions (§VI).
- Action area: `OutlinedButton`s plus a `FilledButton` Confirmar. Each is absent without its right (FR-016). Entrada complementaria is absent because the receipt is not linked (FR-021).
- Confirm on an empty draft returns `inventory_document.no_lines` in the banner (US2 #7).

### State: draft, linked to a PO, with an over-receipt warning

```
┌ ← Entrada · Borrador #321 ───────────────────────────────────────────────────────┐
│ Estado (Borrador)  Folio —  Almacén Bodega Norte  Sucursal Matriz  Orden c. 5512  │
├──────────────────────────────────────────────────────────────────────────────────┤
│ ⚠ Se recibió de más A-100: 3 (recibido 13 de 10 ordenado)                         │
├────────┬──────────────────────────┬──────────┬──────────┬────────────────┬───────┤
│ Código │ Producto                 │ Recibida │ Ordenado │ Otras entradas │       │
├────────┼──────────────────────────┼──────────┼──────────┼────────────────┼───────┤
│ A-100  │ Tornillo 1/4 caja        │        8 │       10 │              5 │ ✎  🗑 │
│ B-220  │ Taquete 5/16             │       20 │       20 │              0 │ ✎  🗑 │
│ C-007  │ Rondana (agregada a mano)│        4 │        — │              — │ ✎  🗑 │
├────────┴──────────────────────────┴──────────┴──────────┴────────────────┴───────┤
│ [Cancelar] [Entrada complementaria] [Editar encabezado] [Agregar producto] [Confirmar]│
└──────────────────────────────────────────────────────────────────────────────────┘
```

- Warning band: computed over-receipts, never blocking (FR-015). There is **no shared warning widget** (Open Question 1).
- Lines: `DataTableView`. Ordenado and Otras entradas columns appear only when the receipt is linked; a hand-added line shows "—" (FR-010). ✎ and 🗑 come from `buildCatalogRowActions`.

### State: completed (read-only), linked, after confirm returned cost warnings

```
┌ ← Entrada 1043 ──────────────────────────────────────────────────────────────────┐
│ Estado (Confirmada)  Folio 1043  Almacén Bodega Norte  Sucursal Matriz  OC 5512   │
├──────────────────────────────────────────────────────────────────────────────────┤
│ ⓘ Se actualizaron los costos con excepciones.                                 [✕] │
├──────────────────────────────────────────────────────────────────────────────────┤
│ Código │ Producto            │ Recibida │ Ordenado │ Otras entradas               │
│ A-100  │ Tornillo 1/4 caja   │        8 │       10 │              0               │
├──────────────────────────────────────────────────────────────────────────────────┤
│ [Cancelar] [Entrada complementaria]                                               │
└──────────────────────────────────────────────────────────────────────────────────┘
```

- Cost notice band: shown after a confirm or cancel that returned cost warnings. It stays until ✕ or until the user leaves the receipt (FR-015a). Same feature-local notice widget as the over-receipt band (Open Question 1).
- No edit actions and no line icons (US2 #6). Cancelar needs delete on 15 (FR-013). Complementaria needs create on 15 and a link (FR-014, FR-021).

### State: cancelled / read-only user

```
┌ ← Entrada 1042 ────────────────────────────┐  ┌ ← Entrada · Borrador #318 ─────────┐
│ Estado (Cancelada)  Folio 1042  …          │  │ Estado (Borrador) …                │
│ Partidas …                                 │  │ Partidas … (no ✎ 🗑)               │
│ (no actions)                               │  │ (no actions — qareadonly)          │
└────────────────────────────────────────────┘  └────────────────────────────────────┘
```

- Cancelled: no actions at all, not even Complementaria (FR-021). Read-only user: every action is absent (FR-016, SC-004).

### State: refusal (e.g. cancel with goods already gone)

```
├──────────────────────────────────────────────────────────────────────────────────┤
│ ⛔ No hay existencias suficientes: se requieren 5 y hay 2 disponibles.            │
│    Producto: A-100                                                                │
│ [Cancelar] [Entrada complementaria]                                               │
```

- `ErrorBanner` above the action area, with the localized code (FR-018). "Producto:" is added on the detail screen from the receipt's lines. After `not_editable`, `already_cancelled` or `lock.busy`, the screen re-fetches.

### State: loading / not found

- Loading: a progress indicator in the body. A not-found or forbidden id shows the shared error view with the localized `resource.not_found` or `auth.forbidden`.

### Compact tier

```
┌──────────────────────────────┐
│ ← Entrada 1043               │
│ (Confirmada) Bodega Norte    │
│ Matriz · OC 5512             │
├──────────────────────────────┤
│ A-100 Tornillo 1/4 caja      │
│ Recibida 8 · Ord. 10 · Otr. 0│
├──────────────────────────────┤
│ [Cancelar] [Complementaria]  │
│ ⋯ wraps to more rows         │
└──────────────────────────────┘
```

- The facts stack in one column. Each line folds into two text rows. The action area wraps (Open Question 6).

---

## Dialogs (all `ResponsiveDialog`, refusals in `FormErrorBanner`)

```
┌ Nueva entrada ──────────────────┐   ┌ Editar encabezado ─────────────────┐
│ Almacén*  [ Bodega Norte    ▾ ] │   │ Almacén  Bodega Norte  (fijo: OC)  │
│ Notas     [                   ] │   │ Notas    [ Proveedor entregó…    ] │
│                        0 / 500  │   │                          31 / 500  │
│            [Cancelar] [Crear]   │   │            [Cancelar] [Guardar]    │
└─────────────────────────────────┘   └────────────────────────────────────┘
```

- Nueva entrada: `CatalogEntityPicker<Warehouse>` plus a notes field with `maxLength` 500 (FR-005). The warehouse starts as the user's point-of-sale warehouse, and non-administrators are offered only their own facility's warehouses (FR-005, FR-017). It has an unsaved-changes guard. An in-transit warehouse is refused here with `warehouse.in_transit_location`.
- Editar encabezado: the warehouse is a picker when not linked, and read-only text when linked (FR-006).

```
┌ Agregar producto ───────────────┐   ┌ Confirmar entrada ─────────────────────────┐
│ Producto* [ tornillo…       ▾ ] │   │ Confirmar asigna un folio y agrega las     │
│ Cantidad* [ 3               ]   │   │ existencias a Bodega Norte. Después ya no  │
│          [Cancelar] [Agregar]   │   │ se puede editar.                           │
└─────────────────────────────────┘   │ ⚠ Se recibió de más A-100: 3 …             │
                                      │           [Volver] [Confirmar]             │
┌ Cantidad de la partida ─────────┐   └────────────────────────────────────────────┘
│ A-100 Tornillo 1/4 caja         │   ┌ Cancelar entrada ──────────────────────────┐
│ Cantidad* [ 8               ]   │   │ Cancelar la entrada 1043 retira de Bodega  │
│          [Cancelar] [Guardar]   │   │ Norte las existencias que agregó.          │
└─────────────────────────────────┘   │           [Volver] [Cancelar entrada]      │
                                      └────────────────────────────────────────────┘
```

- Agregar producto: the picker offers only active, stockable products. Quantity must be > 0 (FR-008, FR-011). Adding an existing product merges server-side (FR-009).
- The confirm prompt lists the over-receipts. For a draft, the cancel prompt says "Cancelar el borrador" (FR-012, FR-013).

---

## Open Questions

1. **There is no shared warning banner in `core/widgets/`.** Only feature-local notices exist (`OrderNoRegisterNotice`, `_ForeignOrderNotice`). Options:
   - (a) a feature-local `ReceiptWarnings` widget on theme tokens;
   - (b) add a shared warning-tone banner beside `ErrorBanner`.

   The wireframe assumed **(a)**, as the plan does. (b) is the better fit once issues and transfers also warn.
2. **A draft's title.** ~~Open~~ **Resolved 2026-11-16 (spec clarification 2, FR-004/FR-004a):** "Entrada · Borrador #{id}" on the detail, and "Borrador #{id}" in the list's Folio column. ui-contract.md was updated to match.
3. **Preselecting the warehouse in Nueva entrada.** **Resolved 2026-11-16 (spec clarification 4, FR-005):** it starts with the user's point-of-sale warehouse when they have one, and empty otherwise. Non-administrators are offered only their own facility's warehouses (clarification 1, FR-017).
4. **Sucursal column on the list.** It repeats what the warehouse already implies. Options: (a) keep it, as FR-004 says; (b) drop it and show "Almacén · Sucursal" in one cell. The wireframe assumed **(a)**.
5. **Cost-warning notice.** **Resolved 2026-11-16 (spec clarification 3, FR-015a):** a band on the detail screen with a close button, which stays until the clerk closes it or leaves the receipt. The drawing above shows it.
6. **Compact tier.** §VI defers the phone tier. The drawings show how the screens would reflow, but nothing here builds a compact layout beyond what `DataTableView` and the action area already do. The wireframe assumed **no compact-specific work in this feature**.
