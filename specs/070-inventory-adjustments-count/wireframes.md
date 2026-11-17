# Wireframes: Physical Inventory Counts

**Spec**: [spec.md](./spec.md) | **Drawn**: 2026-11-17 | **Fidelity**: low

Drawn from the spec before planning. They follow the shipped Inventario screens (specs 067–069; see [068's wireframes](../068-warehouse-issues/wireframes.md)), as FR-019 asks. Where a region is the same as in 068, the annotation says so and the drawing is kept short. Layout is indicative, not prescriptive. Every dimension, colour and spacing resolves through the design tokens, per constitution §V.

What 070 adds to the 068 pattern: the quick-entry row and the Pegar lista dialog, a line search, Esperado and Diferencia columns on a completed count, the "count uncounted as 0" option in the confirm prompt, and the post-confirm warnings band. What it drops: Cancelar on a completed count, and the add-to-quantity merge (lines replace).

## Screen: Conteos físicos list (`/inventory/counts`)

### State: populated

```
┌ Inventario ▸ Conteos físicos ─────────────────────────────────────────────────────┐
│ [＋ Nuevo conteo]  [⚲ ②]                                                          │
├───────────────┬──────────────┬────────────┬─────────────┬────────────┬────────────┤
│         Folio │ Almacén      │ Sucursal   │ Estado      │ Creado por │ Fecha      │
├───────────────┼──────────────┼────────────┼─────────────┼────────────┼────────────┤
│  Borrador #31 │ Bodega Norte │ Matriz     │ (Borrador)  │ J. Pérez   │ 2026-11-17 │
│            12 │ Bodega Norte │ Matriz     │ (Confirmado)│ A. Ruiz    │ 2026-11-01 │
│  Borrador #27 │ Piso venta   │ Sucursal 2 │ (Cancelado) │ J. Pérez   │ 2026-10-30 │
├───────────────┴──────────────┴────────────┴─────────────┴────────────┴────────────┤
│                                           1–20 de 41   ‹  1  2  3  ›              │
└───────────────────────────────────────────────────────────────────────────────────┘
```

- Nav: a fourth entry in the "Inventario" group, after Traspasos, shown with read on 74 (FR-001).
- Filter row: `CatalogFilterBar` with no search, as in 068. Its actions slot holds, left-aligned and in this order, the "Nuevo conteo" `FilledButton.icon` and then the filter `Badge.count` + `IconButton.outlined(tune)`, as on the shipped Entradas de almacén list. "Nuevo conteo" is shown only with create on 74 and read on warehouses (FR-005, FR-015).
- Table: `DataTableView` with 068's columns (FR-004). Estado is the shared `InventoryDocumentStatusChip`. A cancelled count was always a draft, so it keeps "Borrador #{id}" (FR-004a). Names come from `inventory_name_cells`. A row tap opens the detail.
- Pagination: `CatalogPagination`, newest first (FR-001).

### State: filter drawer open / loading / empty / filtered-empty / error

- Identical to 068: `showCatalogFilterSheet` with single-select state chips and a `CatalogEntityPicker<Warehouse>` offering every warehouse (FR-003, FR-015). `CatalogListStateView` renders loading, "No hay conteos físicos", the filtered-empty state with "Limpiar filtros", and the `ErrorBanner` with retry.
- No access: the route gate redirects to home, and the entry is absent from the nav (US1 #4).

### Compact tier

```
┌──────────────────────────────┐
│ [＋ Nuevo]  [⚲ ②]             │
├──────────────────────────────┤
│ 12 · Bodega Norte            │
│ (Confirmado)       2026-11-01│
└──────────────────────────────┘
```

- Sucursal and Creado por are dropped, as in 068 (Open Question 9).

---

## Screen: Count detail (`/inventory/counts/:id`)

### State: draft, no lines (non-admin with all rights)

```
┌ ← Conteo · Borrador #31 ────────────────────────────────────────────────────────┐
│ Estado (Borrador)   Folio —   Almacén Bodega Norte   Sucursal Matriz             │
│ Comentario  Conteo mensual pasillo 3                     Partidas 0              │
│ Creado por J. Pérez 17/11 09:10   ·   Modificado por J. Pérez 17/11 09:10        │
├─────────────────────────────────────────────────────────────────────────────────┤
│ Captura rápida  Código [ A-100        ]  Cantidad [ 12      ]  [Registrar ⏎]     │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│        Registra lo que contaste. Las existencias esperadas se muestran          │
│        al confirmar.                                                            │
│                                                                                 │
├─────────────────────────────────────────────────────────────────────────────────┤
│ [Cancelar]   [Editar encabezado] [Pegar lista] [Agregar producto]  [Confirmar]   │
└─────────────────────────────────────────────────────────────────────────────────┘
```

- Header: `FactStripRow`s in a `ResponsiveFormGrid`, as in 068 (FR-007). "Partidas" shows the line count, which matters on large counts (Open Question 7). There is no expected-stock fact anywhere on a draft (SC-003).
- Captura rápida: two `TextField`s and a button, shown only on a draft with update on 74 (FR-011b). Enter in Código moves to Cantidad. Enter in Cantidad submits, clears both fields and returns focus to Código. The code goes to the server as `product_code` exactly as typed or scanned, with no search (Open Question 1). Refusals (`inventory_count_line.product_unknown`, `.not_stockable`) appear in an inline error under the row, and the typed values stay (US3 #2).
- Action area: 068's order, plus Pegar lista. Each button is absent without its right (FR-015). Confirm on an empty draft with the uncounted option off shows the server's no-lines reason (US2 #9).

### State: draft with lines

```
┌ ← Conteo · Borrador #31 ────────────────────────────────────────────────────────┐
│ Estado (Borrador)   Folio —   Almacén Bodega Norte   Sucursal Matriz             │
│ Comentario  Conteo mensual pasillo 3                     Partidas 1,240          │
├─────────────────────────────────────────────────────────────────────────────────┤
│ Captura rápida  Código [            ]  Cantidad [         ]  [Registrar ⏎]       │
│ ✓ A-100 Tornillo 1/4 caja: 8 → 12 (reemplazada)                                  │
├─────────────────────────────────────────────────────────────────────────────────┤
│ [🔍 Buscar por código o nombre           ]                                       │
├────────┬──────────────────────────────────────────────┬──────────────┬──────────┤
│ Código │ Producto                                     │      Contado │          │
├────────┼──────────────────────────────────────────────┼──────────────┼──────────┤
│ A-100  │ Tornillo 1/4 caja                            │           12 │  ✎   🗑  │
│ B-220  │ Taquete 5/16                                 │            0 │  ✎   🗑  │
├────────┴──────────────────────────────────────────────┴──────────────┴──────────┤
│                                     1–100 de 1,240   ‹  1  2 … 13  ›            │
├─────────────────────────────────────────────────────────────────────────────────┤
│ [Cancelar]   [Editar encabezado] [Pegar lista] [Agregar producto]  [Confirmar]   │
└─────────────────────────────────────────────────────────────────────────────────┘
```

- Feedback line under Captura rápida: after each entry it names the product and, when the product was already counted, shows the old and new quantity with "(reemplazada)" (FR-009). This is the "make clear the quantity is replaced" requirement for quick entry (Open Question 2).
- Line search: `CatalogSearchBar`, filtering the lines already loaded by code or name (FR-011a).
- Lines: `DataTableView` with Código, Producto and Contado only, with no Esperado and no Diferencia on a draft (FR-010). ✎ and 🗑 come from `buildCatalogRowActions` (FR-008). A quantity of 0 is a normal row.
- Lines are paged on the client with `CatalogPagination`, because a count can have thousands of lines and the server returns them all at once (Open Question 3).

### State: completed (read-only), with warnings just returned

```
┌ ← Conteo 12 ────────────────────────────────────────────────────────────────────┐
│ Estado (Confirmado)   Folio 12   Almacén Bodega Norte   Sucursal Matriz          │
│ Comentario  Conteo mensual pasillo 3                     Partidas 3              │
├─────────────────────────────────────────────────────────────────────────────────┤
│ ⚠ Conteo confirmado con avisos                                              ✕   │
│   Contado por debajo de lo apartado:                                            │
│     A-100  contado 2 · apartado 5 · disponible −3                               │
│   Corregido también por otro conteo de este almacén:                            │
│     B-220  conteo 14                                                            │
├─────────────────────────────────────────────────────────────────────────────────┤
│ [🔍 Buscar por código o nombre           ]                                       │
├────────┬────────────────────────────┬──────────┬──────────┬────────────┤
│ Código │ Producto                   │  Contado │ Esperado │ Diferencia │
├────────┼────────────────────────────┼──────────┼──────────┼────────────┤
│ A-100  │ Tornillo 1/4 caja          │        2 │        8 │         −6 │
│ B-220  │ Taquete 5/16               │       20 │       17 │         +3 │
│ C-310  │ Ancla plástica             │        4 │        4 │          0 │
├────────┴────────────────────────────┴──────────┴──────────┴────────────┤
│ (no actions)                                                           │
└────────────────────────────────────────────────────────────────────────┘
```

- Warnings band: shown once, in the same screen session as the confirm, from the confirm response (FR-013, US4). It uses the warning tone, not the `ErrorBanner` error tone, because the count is already posted. It can be dismissed and does not come back on reload, since the server does not store warnings (spec assumption). It is drawn as a band like 067's `ReceiptOverReceiptBand` (Open Question 5).
- "Conteo 14" is the other count's folio from `corrected_by_other_counts` (US4 #2). The folio is plain text (Open Question 6).
- Lines gain Esperado and Diferencia, a signed quantity (FR-010). A 0 difference is shown as 0 (spec edge case).
- No actions at all: no edit and no Cancelar on a completed count (FR-014, US5 #5).

### State: confirm or line refused, or warehouse busy

```
├─────────────────────────────────────────────────────────────────────────────────┤
│ ⛔ El almacén está ocupado. Intenta de nuevo en un momento.                       │
│ [Cancelar]   [Editar encabezado] [Pegar lista] [Agregar producto]  [Confirmar]   │
```

- `ErrorBanner` above the action area with the localized code (FR-016): `lock.busy`, the no-lines reason, the other-facility refusal, `inventory_count.confirmed_cannot_cancel` from a stale screen. After a "not a draft" refusal the screen re-fetches (spec edge cases).

### State: cancelled / read-only user / loading / not found

- Cancelled: title stays "Conteo · Borrador #{id}" with the Cancelado chip, lines without Esperado or Diferencia, and no actions (FR-004a, FR-010).
- Read-only on 74: no Captura rápida row, no row icons, no actions (FR-015, SC-006).
- Loading and not-found or forbidden: as in 068.

### Compact tier

```
┌──────────────────────────────┐
│ ← Conteo · Borrador #31      │
│ (Borrador) Bodega Norte      │
│ Partidas 1,240               │
├──────────────────────────────┤
│ Código   [            ]      │
│ Cantidad [        ] [⏎]      │
├──────────────────────────────┤
│ A-100 Tornillo 1/4 caja      │
│ Contado 12                   │
├──────────────────────────────┤
│ [Pegar lista] [Confirmar] …  │
└──────────────────────────────┘
```

- The quick-entry row stacks. On a completed count each line folds into "Contado · Esperado · Diferencia" on a second text row. The action area wraps. No compact-specific work, as in 067–069 (Open Question 9).

---

## Dialogs (all `ResponsiveDialog`, refusals in `FormErrorBanner`)

```
┌ Nuevo conteo ───────────────────────┐   ┌ Editar encabezado ──────────────────┐
│ Almacén*  [ Bodega Norte        ▾ ] │   │ Almacén*  [ Bodega Norte        ▾ ] │
│ Comentario                          │   │ Comentario                          │
│ [                                 ] │   │ [ Conteo mensual pasillo 3        ] │
│              [Cancelar] [Crear]     │   │              [Cancelar] [Guardar]   │
└─────────────────────────────────────┘   └─────────────────────────────────────┘
```

- As in 068, with "Comentario" instead of "Motivo / notas" and the server's length limit (FR-005, FR-006, FR-015). `CatalogEntityPicker<Warehouse>`, preselected with the point-of-sale warehouse, offering a non-administrator only their own facility's warehouses. An in-transit warehouse is refused with `warehouse.in_transit_location`.

```
┌ Agregar producto ─────────────────────┐   ┌ Cantidad contada ───────────────┐
│ Producto* [ tornillo…             ▾ ] │   │ A-100 Tornillo 1/4 caja         │
│ Contado*  [ 12                    ]   │   │ Contado* [ 12               ]   │
│ ⓘ Ya contado: 8. Se reemplazará.      │   │          [Cancelar] [Guardar]   │
│              [Cancelar] [Registrar]   │   └─────────────────────────────────┘
└───────────────────────────────────────┘
```

- Agregar producto: the picker offers active, stockable products (FR-011). Quantity ≥ 0 with up to 4 decimals (FR-008). When the chosen product is already a line, a note shows its current quantity and says it will be replaced (FR-009). The button reads "Registrar", not "Agregar", because the quantity does not add.

```
┌ Pegar lista ───────────────────────────────────────────────────────────┐
│ Pega dos columnas desde tu hoja de cálculo: código y cantidad.         │
│ ┌────────────────────────────────────────────────────────────────────┐ │
│ │ A-100	12                                                         │ │
│ │ B-220	0                                                          │ │
│ │ C-310	4,5                                                        │ │
│ │ …                                                                  │ │
│ └────────────────────────────────────────────────────────────────────┘ │
│ 2,500 filas leídas · 1 con problemas                                   │
│ ⚠ Fila 1: "Código / Cantidad" — la cantidad no es un número            │
│                                               [Cancelar] [Enviar]      │
└────────────────────────────────────────────────────────────────────────┘
```

- A multi-line `TextField` in a `ResponsiveDialog` (FR-011c). Each edit re-reads the text and updates "N filas leídas" and the problem list (missing code, bad or negative quantity, more than 4 decimals, repeated code), each with its row number (US3 #3). "Enviar" is disabled while any row has a problem. That is a validity gate on a form, not an action hidden by rights.
- Accepted format: one row per line, code and quantity separated by a tab (what a spreadsheet copy produces), a semicolon or a comma (Open Question 4).

```
┌ Pegar lista ─────────────────────────────┐   ┌ Pegar lista ──────────────────────────────┐
│ Enviando…                                │   │ ⛔ Se detuvo el envío. Se aplicaron 2,000  │
│ ████████████░░░░░░░░  2,000 de 2,500     │   │ de 2,500 filas.                           │
│ Lote 2 de 2                              │   │ Códigos rechazados en el lote 2:          │
│                                          │   │   Z-999  no existe                        │
│                                          │   │   K-010  no es inventariable              │
│                                          │   │ Corrige tu lista y pégala de nuevo: las   │
│                                          │   │ cantidades se reemplazan, no se suman.    │
│                                          │   │                              [Cerrar]     │
└──────────────────────────────────────────┘   └───────────────────────────────────────────┘
```

- Progress: a `LinearProgressIndicator` with batch count (FR-011d). The dialog cannot be dismissed while a batch is in flight (Open Question 8).
- Refused batch: the `inventory_count.batch_invalid` problem lists its bad entries by index within the batch (one part per entry: `product_unknown`, `not_stockable`, `repeated`). The UI maps each index back to the row it sent to show the code. The applied count and the "safe to paste again" sentence are FR-011d. Closing reloads the count.

```
┌ Confirmar conteo ──────────────────────────────────────────┐   ┌ Cancelar borrador ──────────────────┐
│ Al confirmar, las existencias de Bodega Norte quedan igual │   │ Cancelar el borrador #31. No se     │
│ a lo contado y se asigna un folio. Un conteo confirmado no │   │ modifica ninguna existencia.        │
│ se puede cancelar: se corrige con un conteo nuevo.         │   │      [Volver] [Cancelar borrador]   │
│                                                            │   └─────────────────────────────────────┘
│ ☐ Contar en 0 los productos con existencia que no están    │
│   en este conteo                                           │
│                                    [Volver] [Confirmar]    │
└────────────────────────────────────────────────────────────┘
```

- Confirmar conteo: a `CheckboxListTile`, off by default, sends `include_uncounted` (FR-012, US2 #6). With the box ticked, the wording does not say how many products will be zeroed: the server never exposes expected stock on a draft (SC-003).
- Cancelar borrador: only for drafts (FR-014).

---

## Open Questions

1. **Does quick entry search, or only take an exact code?** Options: (a) send the typed code to the server as is, exact match, with no search (the server resolves `product_code`); (b) reuse the POS `ProductSearchField`, which searches by code, name or brand and lists matches. The wireframe assumed **(a)**. Scanners send exact codes, the picker already covers searching by name, and `ProductSearchField` lives in the POS capture screen (`lib/features/sales/`), so reusing it would mean moving it into a shared module first. Note that this matches the product code only, not a barcode distinct from the code.
2. **How does quick entry say a quantity was replaced?** Options: (a) a feedback line under the row, "8 → 12 (reemplazada)", after the fact; (b) ask before replacing, which interrupts a scanner run; (c) say nothing. The wireframe assumed **(a)**. FR-009 says "at the moment of entry", and (a) shows it right after the entry without stopping the clerk. The Agregar producto dialog can warn before, because it is not a scanner flow.
3. **How are thousands of lines shown?** The server returns every line in the count response. Options: (a) client-side paging of 100 rows with `CatalogPagination` plus client-side search; (b) one long lazy-scrolling table. The wireframe assumed **(a)**, which keeps 068's table and footer. Whether a 15,000-line response is fast enough to reload after every quick entry is a plan question; reloading just the changed line is the alternative.
4. **Which paste formats are accepted?** Spanish-locale spreadsheets copy decimals with a comma ("4,5") and columns with a tab. Options: (a) tab, semicolon or comma as separator, and a decimal comma accepted when the separator is a tab or semicolon; (b) tab only, decimal point only. The wireframe assumed **(a)**. A comma-separated row with a decimal comma (`A-100,4,5`) is ambiguous and is reported as a problem row.
5. **Warning band vs. dialog after confirm.** Options: (a) a dismissible warning band on the detail, as drawn; (b) a dialog the user must close. The wireframe assumed **(a)**, which follows 067's receipt warning band. If the user navigates away, the warnings are gone for good. The spec accepts that, but (b) would make sure they are read.
6. **Is "conteo 14" a link?** The warning gives the other count's id and folio. Options: (a) plain text; (b) a link that opens that count. The wireframe assumed **(a)**, matching 068's plain supplier-return fact. A link is cheap if wanted.
7. **"Partidas" fact.** Not in the spec. The wireframe added a line-count fact to the header because large counts need it and it costs nothing. Drop it if unwanted.
8. **Can a paste be stopped midway?** Options: (a) no, the dialog stays until all batches finish or one is refused; (b) a "Detener" button that stops after the current batch. The wireframe assumed **(a)**. A full 15,000-row paste is 8 batches, and the spec's edge case already covers an interrupted paste (re-pasting is safe).
9. **Compact tier.** As in 067–069, §VI defers the phone tier. The drawings show how the screens would reflow. The wireframe assumed **no compact-specific work in this feature**.
