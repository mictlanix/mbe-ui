# Wireframes: Stock and Kardex

**Spec**: [spec.md](./spec.md) | **Drawn**: 2026-11-17 | **Fidelity**: low

Drawn from the spec before planning. They follow the shipped Inventario list screens (specs 067–070) where the shapes match. Layout is indicative, not prescriptive. Every dimension, colour and spacing resolves through the design tokens, per constitution §V.

> **Superseded by the plan (2026-11-17).** Three drawings below no longer match what gets built. Follow [research.md](./research.md) and [contracts/ui-contract.md](./contracts/ui-contract.md) where they differ:
> - **Pickers (Open Question 1, research R2).** Existencias' Almacén and the Kardex's Producto, Almacén and Rango live in the **filter sheet**, not inline in the filter row. A facts strip above each table shows the current selection, and with nothing chosen the empty state has a button that opens the sheet.
> - **Product view totals (Open Question 3, research R6).** The totals are a **facts strip above the table**, not a footer row (`DataTableView` has no footer).
> - **"Ver existencias" (Open Question 8, research R9).** It shows whenever the product screen is **read-only** (View, or a user without the products update right), and is **absent while editing** or creating. The screen has no unsaved-changes guard. It sits first in `RecordFormActions`' end-aligned row, through a new `leading` slot.

Three new screens and one change to a shipped screen:
- Existencias, the stock of one warehouse;
- the product view, one product across every warehouse;
- Kardex, one product's movements in one warehouse;
- a "Ver existencias" button on the product catalog's detail screen.

All of it is read-only: no screen here creates, edits or deletes anything.

## Screen: Existencias (`/inventory/stock`)

### State: populated

```
┌ Inventario ▸ Existencias ─────────────────────────────────────────────────────────┐
│ [🔍 Código o nombre        ]  Almacén [ Bodega Norte      ▾ ]  ( ) Mostrar sin existencia │
├────────┬────────────────────────────────┬───────────┬──────────┬────────────┬─────────────┤
│ Código │ Producto                       │ Existencia│ Apartado │ Disponible │ Por recibir │
├────────┼────────────────────────────────┼───────────┼──────────┼────────────┼─────────────┤
│ A-100  │ Tornillo 1/4 caja              │       120 │       20 │        100 │           0 │
│ B-220  │ Taquete 5/16                   │         4 │       10 │         −6 │          50 │
│ C-310  │ Ancla plástica                 │        −2 │        0 │         −2 │           0 │
├────────┴────────────────────────────────┴───────────┴──────────┴────────────┴─────────────┤
│                                           1–50 de 1,240   ‹  1  2 … 25  ›                  │
└───────────────────────────────────────────────────────────────────────────────────────────┘
```

- Nav: a fifth entry in the "Inventario" group, after Conteos físicos, shown with read on 67 (FR-001, FR-013).
- Filter row: `CatalogFilterBar`.
  - Search: `CatalogSearchBar` (FR-004, code or name contains).
  - Filters, inline: a required Almacén `CatalogEntityPicker<Warehouse>` offering every warehouse (FR-002; inline placement is Open Question 1), and a `FilterChip` "Mostrar sin existencia", off by default (FR-004).
  - No actions: nothing here creates anything (FR-014).
- Table: `DataTableView`, sorted by code by the server (FR-003). Four numeric columns through `fmt.display.quantity`, negatives shown as negative (FR-016, spec edge case). A row tap opens the product view. There are no row icons, because the row has nothing to edit and §VI bans a View icon.
- Pagination: `CatalogPagination`, server-paged (page size is Open Question 6). Warehouse, search, switch and page live in the URL (FR-005).

### State: no warehouse chosen / loading / empty / filtered-empty / error

```
┌───────────────────────────────────┐ ┌───────────────────────────────────┐
│ [🔍 …]  Almacén [ Elige…     ▾ ]  │ │ [🔍 tornillo]  Almacén [Bodega ▾] │
│                                   │ │                                   │
│   Elige un almacén para ver sus   │ │  Ningún producto coincide con la  │
│   existencias.                    │ │  búsqueda.                        │
└───────────────────────────────────┘ └───────────────────────────────────┘
  no warehouse (no point of sale)        filtered-empty

┌───────────────────────────────────┐ ┌───────────────────────────────────┐
│ [🔍 …]  Almacén [ Tránsito M ▾ ]  │ │ [🔍 …]  Almacén [ Bodega Sur ▾ ]  │
│ ⛔ Este almacén es de tránsito;    │ │                                   │
│    sus existencias se ven por     │ │   Este almacén no tiene           │
│    producto.            [Reintentar]│ │   existencias.                    │
└───────────────────────────────────┘ └───────────────────────────────────┘
  in-transit warehouse refused           empty (switch off)
```

- `CatalogListStateView` renders loading, empty and error. The error is its `ErrorBanner` with the localized code. The in-transit refusal is a 422 whose exact code is for the plan to confirm (FR-015, spec edge case).
- The no-warehouse prompt is a plain text state, not an error (spec edge case "No warehouse").
- No access: the route gate redirects to home, and the entry is absent (US1 #6).

### Compact tier

```
┌──────────────────────────────┐
│ [🔍 Código o nombre        ] │
│ Almacén [ Bodega Norte   ▾ ] │
│ ( ) Mostrar sin existencia   │
├──────────────────────────────┤
│ A-100 Tornillo 1/4 caja      │
│ Exist. 120 · Disp. 100       │
├──────────────────────────────┤
│ B-220 Taquete 5/16           │
│ Exist. 4 · Disp. −6          │
└──────────────────────────────┘
```

- Apartado and Por recibir are dropped on phones. They're on the product view. No compact-specific work, as in 067–070 (Open Question 9).

---

## Screen: Product view (`/inventory/stock/products/:id`)

### State: populated

```
┌ ← Existencias · A-100 Tornillo 1/4 caja ────────────────────────────────────────────┐
├──────────────────┬────────────┬───────────┬──────────┬────────────┬─────────────┬────┤
│ Almacén          │ Sucursal   │ Existencia│ Apartado │ Disponible │ Por recibir │    │
├──────────────────┼────────────┼───────────┼──────────┼────────────┼─────────────┼────┤
│ Bodega Norte     │ Matriz     │       120 │       20 │        100 │           0 │ 📒 │
│ Piso venta       │ Matriz     │        15 │        5 │         10 │          30 │ 📒 │
│ Bodega Sur       │ Sucursal 2 │         0 │        0 │          0 │          50 │ 📒 │
├──────────────────┴────────────┼───────────┼──────────┼────────────┼─────────────┼────┤
│ Total                         │       135 │       25 │        110 │          80 │    │
├───────────────────────────────┴───────────┴──────────┴────────────┴─────────────┴────┤
│ En tránsito                                                                          │
│   Matriz        30                                                                   │
│   Sucursal 2    50                                                                   │
└──────────────────────────────────────────────────────────────────────────────────────┘
```

- A full screen with its own address (FR-006, FR-013), reached from an Existencias row or from the catalog's "Ver existencias". The title names the product's code and name. There are no AppBar actions (§VI).
- Warehouses: `DataTableView` with the four figures, plus a Sucursal column from the warehouse's facility. Names come from the shared `InventoryWarehouseName` and `InventoryFacilityName` cells. The total row is a footer (Open Question 3).
- 📒: the one allowed direct row action (§VI: a shortcut into a related screen), "Ver kardex", from `buildCatalogRowActions` with `onEdit: null`. It is present only with read on 32 (FR-007). It opens the Kardex with this product and warehouse and the default range.
- En tránsito: a plain list of facility and quantity (FR-006, US2 #2), shown only when non-empty. The server gives each facility's in-transit warehouse; the label shows the facility (Open Question 4).

### State: no stock anywhere / loading / not found

```
┌ ← Existencias · Z-900 Producto nuevo ───────────┐
│                                                  │
│   Este producto no tiene existencias en ningún   │
│   almacén.                                       │
└──────────────────────────────────────────────────┘
```

- US2 #3. Loading and not-found use the shared error view, as other detail screens do.

### Compact tier

- The four figures fold into two text rows per warehouse, the 📒 action stays, and the in-transit list stacks below. No compact-specific work.

---

## Screen: Kardex (`/inventory/kardex?product=&warehouse=&from=&to=`)

### State: populated

```
┌ Inventario ▸ Kardex ─────────────────────────────────────────────────────────────────┐
│ Producto [ A-100 Tornillo 1/4 caja ▾ ]  Almacén [ Bodega Norte ▾ ]  (18 oct – 17 nov ✕) │
├──────────────────────────────────────────────────────────────────────────────────────┤
│ Saldo inicial 80     Entradas +60     Salidas −20     Saldo final 120                 │
├──────────────────┬─────────────────────┬───────────────┬─────────┬─────────┬─────────┤
│ Fecha            │ Origen              │ Documento     │ Entrada │  Salida │   Saldo │
├──────────────────┼─────────────────────┼───────────────┼─────────┼─────────┼─────────┤
│ 2026-10-20 09:14 │ Entrada de almacén  │ 2991 ↗        │      50 │         │     130 │
│ 2026-10-22 16:02 │ Pedido              │ F-1023 ↗      │         │      15 │     115 │
│ 2026-11-01 11:40 │ Conteo físico       │ 12 ↗          │      10 │         │     125 │
│ 2026-11-05 08:00 │ Itinerario de reparto│ #344         │         │       5 │     120 │
├──────────────────┴─────────────────────┴───────────────┴─────────┴─────────┴─────────┤
│                                           1–100 de 412   ‹  1  2  3  4  5  ›          │
└──────────────────────────────────────────────────────────────────────────────────────┘
```

- Nav: a sixth entry in the "Inventario" group, after Existencias, shown with read on 32 (FR-008, FR-013).
- Filter row: `CatalogFilterBar` with no search.
  - Filters, inline: Producto (`CatalogEntityPicker<Product>`, stockable, active and inactive), Almacén (`CatalogEntityPicker<Warehouse>`), and the shared `DateRangeFilterChip`, defaulting to the last 30 days (FR-009).
  - The range chip's clear action returns to the default 30 days, not to "any date". The chip's precedent assumes "Hoy" as the default (Open Question 2).
  - All of it lives in the URL (FR-012).
- Summary: `FactStripRow` with Saldo inicial, Entradas, Salidas and Saldo final (FR-010). Totals come from the server.
- Table: `DataTableView`, in server order.
  - Fecha: date and time through `formattersProvider`.
  - Origen: the source name, localized from the source type, not the server's `source_name` (Open Question 5).
  - Documento: the document's folio, or "Borrador #{id}" when it has none. The ↗ marks a row that opens its document (FR-011).
  - Entrada and Salida: one of them is filled per row.
  - Saldo: the running balance.
- Rows without a screen (itinerary, legacy purchase order, legacy adjustment) or not found show "#{reference}" as plain text, and their row tap does nothing (US3 #4).
- The kardex isn't paged by the server, so rows are paged in memory, 100 per page, with `CatalogPagination` (as spec 070's count lines). See the spec's edge case "Large ranges".

### State: incomplete selection / invalid range / no movements / error

```
┌───────────────────────────────────────┐ ┌───────────────────────────────────────┐
│ Producto [ Elige…  ▾ ] Almacén [ … ▾ ]│ │ Producto [A-100 ▾] Almacén [Norte ▾]  │
│                                       │ │ (01 ene 2025 – 17 nov 2026 ✕)         │
│  Elige un producto y un almacén para  │ │ ⚠ El rango no puede pasar de 366 días.│
│  ver su kardex.                       │ │                                       │
└───────────────────────────────────────┘ └───────────────────────────────────────┘
  incomplete selection                      invalid range (not loaded)

┌───────────────────────────────────────┐
│ Saldo inicial 80  Entradas 0          │
│ Salidas 0         Saldo final 80      │
│                                       │
│  Sin movimientos en este rango.       │
└───────────────────────────────────────┘
  no movements (US3 #6)
```

- The invalid-range text is checked on the client before any request (FR-009). If the server still answers 422, the localized code shows in an `ErrorBanner` (FR-015).
- Loading uses the list's progress state. An error uses `ErrorBanner` with retry.

### Compact tier

```
┌──────────────────────────────┐
│ Producto [ A-100 …       ▾ ] │
│ Almacén  [ Bodega Norte  ▾ ] │
│ (18 oct – 17 nov ✕)          │
├──────────────────────────────┤
│ Inicial 80 · Final 120       │
│ Entradas +60 · Salidas −20   │
├──────────────────────────────┤
│ 20/10 09:14 Entrada 2991 ↗   │
│ +50              Saldo 130   │
└──────────────────────────────┘
```

- Each movement folds into two text rows. No compact-specific work.

---

## Changed screen: Product detail (`/products/:id`)

```
├────────────────────────────────────────────────────────────────────────────────┤
│ … attributes …                                                                 │
├────────────────────────────────────────────────────────────────────────────────┤
│ [📦 Ver existencias]                              [Eliminar]  [Editar]           │
└────────────────────────────────────────────────────────────────────────────────┘
```

- "Ver existencias" is an `OutlinedButton.icon` in the record's action area, beside `RecordFormActions`, shown only with read on 67 (FR-013a). §VI puts a shortcut to a related screen in the record's action area, never in the AppBar.
- The products list row is not changed. It already shows Edit and the pricing shortcut, the two-icon maximum (§VI). A third action would need a kebab menu (Open Question 7).
- It shows in both the read-only View and the edit form for an existing product, and not on a new product (Open Question 8).

---

## Open Questions

1. **Inline required pickers in `CatalogFilterBar`.** Existencias needs a warehouse, and the Kardex a product and a warehouse, before anything loads. No shipped list puts a required `CatalogEntityPicker` inline in the bar: shipped pickers live in the filter drawer. Options: (a) inline pickers in the bar's `filters` slot, as drawn; (b) the filter drawer, with the screen showing the "choose…" prompt until one is set. The wireframe assumed **(a)**, because a required choice hidden in a drawer reads as optional. Whether `CatalogEntityPicker` sits well inline, at a fixed width, is for the plan to check. If it doesn't, that is a widget gap to raise, not to build quietly.
2. **Kardex range chip default.** `DateRangeFilterChip` treats "Hoy" or no range as its default state. The Kardex needs "last 30 days" as the default, with clearing returning to it. Options: (a) pass the 30-day range and handle clear on the screen; (b) extend the chip with a configurable default. The wireframe assumed **(a)**, if the chip's API allows it; otherwise (b) is a small shared-widget change to record in the plan.
3. **Totals row on the product view.** `DataTableView` has no footer row. Options: (a) a total line below the table, drawn as a footer; (b) a facts strip above the table with the four totals. The wireframe drew (a) but either is fine. The plan picks whichever needs no new widget, which is probably (b).
4. **In-transit labels.** The server returns each facility's in-transit warehouse with its stock. The wireframe shows the facility name, since an in-transit warehouse's own name is not meaningful to a clerk. It could link to that facility's En tránsito view (spec 069). The wireframe assumed **plain text**.
5. **Source names.** Each kardex row carries `source` (a type number) and the server's English `source_name`. Per §III the UI shows Spanish text built from the type, not server prose. That needs one label per source type: 1 sales order, 2 refund, 3 issue, 4 receipt, 5 transfer, 6 purchase order, 8 legacy adjustment, 10 delivery itinerary, 12 physical count, 13 delivery pickup, and a fallback for an unknown type. The wireframe assumed **localized labels from the type**.
6. **Existencias page size.** The server allows up to 500 per page. Options: the usual 20 per page, or a larger page (50–100) because supervisors scan long lists. The wireframe assumed **50**, which is an assumption to confirm.
7. **Products list row action.** The spec asks for the record surface only. Adding a stock shortcut to the products list rows too would need a kebab menu holding pricing and stock. The wireframe assumed **record surface only**, as the spec says.
8. **"Ver existencias" while editing.** Leaving the edit form for the stock view could drop unsaved edits; the shared unsaved-changes guard would ask first. The wireframe assumed it is shown in **both modes, guarded**. The alternative is to show it in read-only View only.
9. **Compact tier.** As in 067–070, §VI defers the phone tier. The drawings show how the screens would reflow. The wireframe assumed **no compact-specific work**.
