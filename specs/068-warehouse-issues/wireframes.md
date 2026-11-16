# Wireframes: Warehouse Issues

**Spec**: [spec.md](./spec.md) | **Drawn**: 2026-11-16 | **Fidelity**: low

Drawn from the spec before planning. They follow the shipped Entradas de almacén screens (spec 067, [its wireframes](../067-warehouse-receipts/wireframes.md)), as FR-018 asks. Where a region is the same as in 067, the annotation says so and the drawing is kept short. Layout is indicative, not prescriptive. Every dimension, colour and spacing resolves through the design tokens, per constitution §V.

What 068 drops from 067: the Orden de compra column and fact, the Ordenado and Otras entradas line columns, the over-receipt and cost-warning bands, and the Entrada complementaria action. What it adds: the Devolución a proveedor fact (only when stored), and the insufficient-stock refusal on Confirmar.

## Screen: Salidas de almacén list (`/inventory/issues`)

### State: populated

```
┌ Inventario ▸ Salidas de almacén ──────────────────────────────────────────────────┐
│                                                  [⚲ Filtros ②]  [＋ Nueva salida]  │
├───────────────┬──────────────┬────────────┬─────────────┬────────────┬────────────┤
│         Folio │ Almacén      │ Sucursal   │ Estado      │ Creado por │ Fecha      │
├───────────────┼──────────────┼────────────┼─────────────┼────────────┼────────────┤
│ Borrador #204 │ Bodega Norte │ Matriz     │ (Borrador)  │ J. Pérez   │ 16/11/2026 │
│           611 │ Bodega Norte │ Matriz     │ (Confirmada)│ A. Ruiz    │ 15/11/2026 │
│           610 │ Piso venta   │ Sucursal 2 │ (Cancelada) │ J. Pérez   │ 14/11/2026 │
├───────────────┴──────────────┴────────────┴─────────────┴────────────┴────────────┤
│                                           1–20 de 58   ‹  1  2  3  ›              │
└───────────────────────────────────────────────────────────────────────────────────┘
```

- Nav: a second entry in the "Inventario" group, after Entradas de almacén, shown with read on 16 (FR-001).
- Filter row: `CatalogFilterBar` with no search control (FR-003). Its actions slot holds the `Badge.count` + `IconButton.outlined(tune)` and the "Nueva salida" `FilledButton.icon`, shown only with create on 16 and read on warehouses (FR-005, FR-014).
- Table: `DataTableView`, the same columns as 067 minus Orden c. Folio is right-aligned, "Borrador #{id}" for a draft (FR-004). Estado is a `StatusChip` with the same three tones as receipts. Names come from the warehouse, facility and employee display-name lookups. A row tap opens the detail. There are no row icons (FR-018).
- Pagination: `CatalogPagination`, newest first (FR-001).

### State: filter drawer open

```
┌───────────────────────────────┐
│ Filtros                    ✕  │
│ Estado                        │
│ (Borrador) (Confirmada)       │
│ (Cancelada)                   │
│ Almacén                       │
│ [ Bodega Norte            ▾ ] │
│ [Limpiar]          [Aplicar]  │
└───────────────────────────────┘
```

- `showCatalogFilterSheet`, identical to 067: single-select state chips and a `CatalogEntityPicker<Warehouse>` offering every warehouse to everyone, shown only with read on warehouses (FR-003, FR-014).

### State: loading / empty / filtered-empty / error

```
┌───────────────────────────────┐ ┌───────────────────────────────┐
│ [⚲ Filtros]  [＋ Nueva salida] │ │ [⚲ Filtros ①] [＋ Nueva salida]│
│                               │ │                               │
│   No hay salidas de almacén   │ │  Ninguna salida coincide con  │
│                               │ │  los filtros.                 │
│                               │ │  [Limpiar filtros]            │
└───────────────────────────────┘ └───────────────────────────────┘
  empty                             filtered-empty
```

- `CatalogListStateView` renders all four states. Loading is its progress state. Error is its `ErrorBanner` with retry.
- No access: the route gate redirects to home, and the entry is absent from the nav (US1 #4).

### Compact tier

```
┌──────────────────────────────┐
│ [⚲ ②]            [＋ Nueva]   │
├──────────────────────────────┤
│ 611 · Bodega Norte           │
│ (Confirmada)            15/11│
├──────────────────────────────┤
│ Borrador #204 · Bodega Norte │
│ (Borrador)              16/11│
└──────────────────────────────┘
```

- Sucursal and Creado por are dropped (they are on the detail). This is the shared compact table behaviour, as in 067 (Open Question 5).

---

## Screen: Issue detail (`/inventory/issues/:id`)

### State: draft, no lines (non-admin with all rights)

```
┌ ← Salida · Borrador #204 ───────────────────────────────────────────────────────┐
│ Estado (Borrador)   Folio —   Almacén Bodega Norte   Sucursal Matriz             │
│ Motivo / notas  Caja golpeada en recepción, producto dañado                      │
│ Creado por J. Pérez 16/11 10:02   ·   Modificado por J. Pérez 16/11 10:02        │
├─────────────────────────────────────────────────────────────────────────────────┤
│ Partidas                                                                        │
│                                                                                 │
│                   Agrega los productos que salen del almacén.                   │
│                                                                                 │
├─────────────────────────────────────────────────────────────────────────────────┤
│ [Cancelar]            [Editar encabezado] [Agregar producto]       [Confirmar]   │
└─────────────────────────────────────────────────────────────────────────────────┘
```

- Header: `FactStripRow`s in a `ResponsiveFormGrid`, as in 067 (FR-007). The notes fact is labelled so the clerk reads it as the reason (FR-006; wording in Open Question 2). The AppBar has no actions.
- Action area: `OutlinedButton`s plus a `FilledButton` Confirmar, in 067's order. Each is absent without its right (FR-014).
- Confirm on an empty draft shows `inventory_document.no_lines` in the banner (US2 #8).

### State: draft with lines

```
┌ ← Salida · Borrador #204 ───────────────────────────────────────────────────────┐
│ Estado (Borrador)   Folio —   Almacén Bodega Norte   Sucursal Matriz             │
│ Motivo / notas  Caja golpeada en recepción, producto dañado                      │
├────────┬──────────────────────────────────────────────┬──────────────┬──────────┤
│ Código │ Producto                                     │     Cantidad │          │
├────────┼──────────────────────────────────────────────┼──────────────┼──────────┤
│ A-100  │ Tornillo 1/4 caja                            │            8 │  ✎   🗑  │
│ B-220  │ Taquete 5/16                                 │           20 │  ✎   🗑  │
├────────┴──────────────────────────────────────────────┴──────────────┴──────────┤
│ [Cancelar]            [Editar encabezado] [Agregar producto]       [Confirmar]   │
└─────────────────────────────────────────────────────────────────────────────────┘
```

- Lines: `DataTableView` with Código, Producto and Cantidad only (FR-010). ✎ and 🗑 come from `buildCatalogRowActions`, shown only on a draft with update on 16 (FR-008).
- No warning band ever appears on an issue: the server returns none.

### State: confirm refused for lack of stock

```
├─────────────────────────────────────────────────────────────────────────────────┤
│ ⛔ No hay existencias suficientes: se requieren 20 y hay 12 disponibles.          │
│    Producto: B-220 · Almacén: Bodega Norte                                       │
│ [Cancelar]            [Editar encabezado] [Agregar producto]       [Confirmar]   │
```

- `ErrorBanner` above the action area with the localized `inventory_document.insufficient_stock` (FR-012, FR-015). The issue stays a draft and keeps its title, so the clerk can lower the quantity and try again.
- "Producto:" is added from the issue's lines, as on receipts. "Almacén:" is the issue's own warehouse (Open Question 3).
- `lock.busy` uses the same banner with the retry text. After `document.not_editable` or `inventory_document.already_cancelled`, the screen re-fetches (spec edge cases).

### State: completed (read-only)

```
┌ ← Salida 611 ───────────────────────────────────────────────────────────────────┐
│ Estado (Confirmada)   Folio 611   Almacén Bodega Norte   Sucursal Matriz         │
│ Motivo / notas  Merma por caducidad                                              │
├─────────────────────────────────────────────────────────────────────────────────┤
│ Código │ Producto                                     │     Cantidad             │
│ A-100  │ Tornillo 1/4 caja                            │            8             │
├─────────────────────────────────────────────────────────────────────────────────┤
│ [Cancelar]                                                                      │
└─────────────────────────────────────────────────────────────────────────────────┘
```

- No edit actions and no line icons (US2 #6). Cancelar needs delete on 16 (FR-013).

### State: legacy issue linked to a supplier return

```
│ Estado (Confirmada)  Folio 488  Almacén Bodega Norte  Sucursal Matriz            │
│ Devolución a proveedor  #73                                                      │
```

- One more read-only `FactStripRow`, shown only when the link is stored (FR-007). It is plain text: there is no supplier-return screen to open (Open Question 1).

### State: cancelled / read-only user

```
┌ ← Salida 610 ──────────────────────────────┐  ┌ ← Salida · Borrador #204 ──────────┐
│ Estado (Cancelada)  Folio 610  …           │  │ Estado (Borrador) …                │
│ Partidas …                                 │  │ Partidas … (no ✎ 🗑)               │
│ (no actions)                               │  │ (no actions — read-only on 16)     │
└────────────────────────────────────────────┘  └────────────────────────────────────┘
```

- Cancelled: no actions (US4 #3). Read-only user: every action is absent (FR-014, SC-005).

### State: loading / not found

- Loading: a progress indicator in the body. A not-found or forbidden id shows the shared error view with the localized `resource.not_found` or `auth.forbidden`.

### Compact tier

```
┌──────────────────────────────┐
│ ← Salida 611                 │
│ (Confirmada) Bodega Norte    │
│ Matriz                       │
│ Merma por caducidad          │
├──────────────────────────────┤
│ A-100 Tornillo 1/4 caja      │
│ Cantidad 8                   │
├──────────────────────────────┤
│ [Cancelar]                   │
└──────────────────────────────┘
```

- The facts stack in one column, each line folds into two text rows, and the action area wraps, as in 067.

---

## Dialogs (all `ResponsiveDialog`, refusals in `FormErrorBanner`)

```
┌ Nueva salida ───────────────────────┐   ┌ Editar encabezado ──────────────────┐
│ Almacén*  [ Bodega Norte        ▾ ] │   │ Almacén*  [ Bodega Norte        ▾ ] │
│ Motivo / notas                      │   │ Motivo / notas                      │
│ [ p. ej. merma, daño, consumo     ] │   │ [ Caja golpeada en recepción…     ] │
│                            0 / 500  │   │                           44 / 500  │
│              [Cancelar] [Crear]     │   │              [Cancelar] [Guardar]   │
└─────────────────────────────────────┘   └─────────────────────────────────────┘
```

- Nueva salida: `CatalogEntityPicker<Warehouse>` plus a notes field with `maxLength` 500 and a hint naming typical reasons (FR-005, FR-006). The warehouse starts as the user's point-of-sale warehouse. Non-administrators are offered only their own facility's warehouses (FR-014). It has an unsaved-changes guard. An in-transit warehouse is refused with `warehouse.in_transit_location`.
- Editar encabezado: the warehouse is always a picker. An issue has no purchase-order link, so nothing fixes its warehouse (FR-006).

```
┌ Agregar producto ───────────────┐   ┌ Confirmar salida ──────────────────────────┐
│ Producto* [ tornillo…       ▾ ] │   │ Confirmar asigna un folio y retira las     │
│ Cantidad* [ 3               ]   │   │ existencias de Bodega Norte. Después ya no │
│          [Cancelar] [Agregar]   │   │ se puede editar.                           │
└─────────────────────────────────┘   │           [Volver] [Confirmar]             │
                                      └────────────────────────────────────────────┘
┌ Cantidad de la partida ─────────┐   ┌ Cancelar salida ───────────────────────────┐
│ A-100 Tornillo 1/4 caja         │   │ Cancelar la salida 611 regresa a Bodega    │
│ Cantidad* [ 8               ]   │   │ Norte las existencias que retiró.          │
│          [Cancelar] [Guardar]   │   │           [Volver] [Cancelar salida]       │
└─────────────────────────────────┘   └────────────────────────────────────────────┘
```

- Agregar producto: the picker offers only active, stockable products. Quantity must be > 0 (FR-008, FR-011). Adding an existing product merges on the server (FR-009). The dialog does not show available stock (spec assumption).
- Confirmar salida says the stock is taken out (FR-012). Cancelar salida says it is put back (FR-013). For a draft, the cancel prompt reads "Cancelar el borrador" and mentions no stock.

---

## Open Questions

1. **Resolved 2026-11-16 (spec clarification 2, FR-007):** option (a), as drawn. ~~How is the supplier-return link shown?~~ Options were: (a) a read-only "Devolución a proveedor #{id}" fact on the detail only; (b) also a list column; (c) not shown at all, since nothing creates it. The wireframe assumed **(a)**: FR-007 asks for it, and a list column would be empty on every new issue.
2. **Resolved 2026-11-16 (spec clarification 1, FR-006):** option (a), as drawn. ~~The notes field carries the reason. Should it say so, and should it be required?~~ Options were: (a) label "Motivo / notas" with a hint, still optional; (b) required on issues; (c) plain "Notas" as on receipts. The wireframe assumed **(a)**. The server allows an empty comment, and the spec keeps notes optional. (b) would be a UI-only rule the server does not enforce.
3. **What does the insufficient-stock refusal name?** Settled by checking the code: the error's params name the product only by `product_id` (its English text, which the UI never shows, has the codes). The receipt screen already looks the code up in its own lines and adds "Producto: {code}". On an issue the short product is always one of its lines, so the same lookup always finds it. The warehouse is the issue's own, the only one it checks. The wireframe assumed the receipt pattern plus "Almacén: {issue warehouse}". FR-012's "naming the product and warehouse" holds with no server change.
4. **Shared widgets with receipts.** Issues reuse 067's status chip, warehouse options, name cells, dialogs and action area with different text. Whether those become shared inventory-document widgets or are copied per document is a plan decision. The wireframe draws them as identical, as FR-018 requires.
5. **Compact tier.** As in 067, §VI defers the phone tier. The drawings show how the screens would reflow. The wireframe assumed **no compact-specific work in this feature**.
