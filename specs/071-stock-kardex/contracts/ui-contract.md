# Contract: UI (routes, nav, screens)

System objects: **WarehouseStockReport (67)** for Existencias and the product view, and **Kardex (32)** for the Kardex. Drawings: [wireframes.md](../wireframes.md). Research R2 overrides wireframe question 1: the required pickers live in the filter sheet, and a facts strip shows the current selection.

## Routes and nav

| Route | Screen | Gate |
|---|---|---|
| `/inventory/stock` (shell branch `NavBranch.inventoryStock = 34`, `ListQuery.fromUri`: `warehouse`, `q`, `include_zero`, `page`) | `StockListScreen` | `can(67, read)` |
| `/inventory/stock/products/:id` (top-level) | `ProductStockScreen` | `can(67, read)` |
| `/inventory/kardex` (shell branch `NavBranch.inventoryKardex = 35`; query `product`, `warehouse`, `from`, `to` as `yyyy-MM-dd`) | `KardexScreen` | `can(32, read)` |
| `/inventory/kardex/view` (top-level, same query; pushed from the product view) | `KardexScreen(pushed: true)` | `can(32, read)` (the `/inventory/kardex` prefix clause) |

- Nav: the fifth and sixth children of the `inventory` group, after Conteos físicos. Labels: `navInventoryStock` "Existencias" and `navInventoryKardex` "Kardex".
- `_routeGate` gets a clause for `/inventory/stock` (which also covers `/inventory/stock/products/:id`) and one for `/inventory/kardex`.

## Existencias

- `CatalogFilterBar`:
  - `search`: `CatalogSearchBar` (key `stock_search`, code or name).
  - `filters`: the badged filters button (key `stock_filter_button`), opening `showCatalogFilterSheet` with Almacén (`CatalogEntityPicker<Warehouse>` from `inventoryFilterWarehouseOptions`, key `stock_warehouse_filter`, needs read on 4) and the switch "Mostrar sin existencia" (key `stock_include_zero`).
  - No `actions`.
- Facts strip (key `stock_selection`): "Almacén {name}", shown when a warehouse is chosen.
- `DataTableView` (key `stock_table`): Código, Producto, Existencia, Apartado, Disponible, Por recibir. The four numbers go through `fmt.display.quantity`, keeping negatives. A row tap pushes `/inventory/stock/products/{productId}`. There are no row icons.
- `CatalogPagination`, 50 per page, server-paged.
- States, via `CatalogListStateView`:
  - no warehouse: "Elige un almacén para ver sus existencias." with the button "Elegir almacén", which opens the sheet;
  - loading;
  - empty: "Este almacén no tiene existencias.";
  - filtered-empty: "Ningún producto coincide con la búsqueda.";
  - error, including `warehouse.in_transit_location`.

## Product view

- Title: "Existencias · {code} {name}". No AppBar actions.
- Totals facts strip (key `product_stock_totals`): Existencia, Apartado, Disponible and Por recibir, summed.
- `DataTableView` (key `product_stock_table`): Almacén, Sucursal, Existencia, Apartado, Disponible, Por recibir. The row action is "Ver kardex" (key `product_stock_kardex_{warehouseId}`, icon `Icons.receipt_long_outlined`), shown only with `can(32, read)`. It pushes the Kardex **page** `/inventory/kardex/view?product={id}&warehouse={w}`, never the Kardex tab: pushing a shell-branch route on top of a pushed top-level route puts a second shell page on the root navigator and breaks navigation (found by the device test, 2026-11-17).
- En tránsito (key `product_stock_in_transit`): facility name and quantity, shown only when non-empty.
- Empty: "Este producto no tiene existencias en ningún almacén." Loading, not-found and forbidden use the shared error view.

## Kardex

- `CatalogFilterBar`:
  - no `search`, no `actions`;
  - `filters`: the badged filters button (key `kardex_filter_button`), opening the sheet. The sheet holds Producto (`CatalogEntityPicker<Product>`, key `kardex_product_filter`, needs read on Products), Almacén (key `kardex_warehouse_filter`, needs read on 4) and Rango (`DateRangeFilterChip` with `isToday: false`, `firstDate: DateTime(2000)`, clear restoring the last 30 days).
- Selection facts strip (key `kardex_selection`): Producto, Almacén, Rango.
- Summary facts strip (key `kardex_summary`): Saldo inicial, Entradas, Salidas, Saldo final.
- `DataTableView` (key `kardex_table`), in server order: Fecha (date and time), Origen (`kardexSourceLabel`), Documento (the folio, or "#{id}"/"#{reference}"/"—"), Entrada, Salida, Saldo.
  - A linked row has an `onRowTap` that pushes its route (data-model "Source mapping"). Unlinked rows do nothing on tap.
  - The Documento cell of a linked row reads as a link: key `kardex_doc_{movementId}`, styled with the theme's link tone.
- In-memory pages of 100 with `CatalogPagination`.
- **Pushed mode** (`/inventory/kardex/view`): the same screen inside a `Scaffold` with an `AppBar` (title "Kardex", default back arrow, no actions). Selection changes `replace` the URL in place, so back still returns to the product view. The tab mode keeps `go`.
- States:
  - `incomplete`: "Elige un producto y un almacén para ver su kardex." with the button "Elegir", which opens the sheet;
  - `reversed`: "La fecha final no puede ser anterior a la inicial.";
  - `tooLong`: "El rango no puede pasar de 366 días.";
  - loading;
  - no movements: the summary strip plus "Sin movimientos en este rango.";
  - error (coded).

## Product detail (shipped screen, changed)

- `RecordFormActions` gains an optional `leading: List<Widget>?`, rendered first in its `Wrap`. Nothing changes when it is null.
- `product_detail_screen.dart` passes `OutlinedButton.icon(key: Key('view_stock_button'), icon: Icons.inventory_2_outlined, label: "Ver existencias")`. It shows whenever the screen's mode is `RecordFormMode.view` (from `?view=true`, or because the user lacks products update), for an existing product, with `can(67, read)`, and pushes `/inventory/stock/products/{id}`. It is absent in edit and create mode.
