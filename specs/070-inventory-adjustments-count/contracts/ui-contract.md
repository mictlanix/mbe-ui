# Contract: UI (routes, nav, screens, dialogs)

System object: **PhysicalCountAdjustment (74)**, `SystemObject.physicalCountAdjustment`. InventoryAdjustments (93) is not used (FR-020). The drawings are in [wireframes.md](../wireframes.md); this contract fixes what tests assert.

## Routes and nav

| Route | Screen | Gate |
|---|---|---|
| `/inventory/counts` (shell branch `NavBranch.inventoryCounts = 33`, `ListQuery.fromUri`) | `InventoryCountsListScreen` | `can(74, read)` |
| `/inventory/counts/:id` (top-level) | `InventoryCountDetailScreen` | `can(74, read)` |

- The nav entry is the fourth child of the `inventory` group, after Traspasos. Its label is `navInventoryCounts` "Conteos físicos".
- `_routeGate` gets a `/inventory/counts` prefix clause. Without read, the route redirects to home.

## List screen

- `CatalogFilterBar` with no search. Its actions are, in order, "Nuevo conteo" (`FilledButton.icon`, needs create on 74 and read on warehouses), then the filter button with `Badge.count`.
- `DataTableView` columns: Folio (right-aligned; "Borrador #{id}" when there is no serial), Almacén, Sucursal, Estado (`InventoryCountStatusChip`), Creado por, Fecha. A row tap pushes the detail.
- Filter drawer: Estado chips (Borrador, Confirmado, Cancelado), and Almacén from `inventoryFilterWarehouseOptions` (needs read on warehouses).
- `CatalogPagination`, newest first. `CatalogListStateView` handles loading, empty ("No hay conteos físicos"), filtered-empty and error.

## Detail screen

- **Title**: `InventoryCount.title` (data-model).
- **Header facts**: Estado chip, Folio ("—" on a draft), Almacén, Sucursal, Comentario, Partidas (line count), Creado por/at, Modificado por/at.
- **Quick entry** (draft + update): key `count_quick_entry_code` and `count_quick_entry_quantity` fields, and a Registrar button. Enter moves from code to quantity, then submits. On success: both fields clear, focus returns to code, and the feedback line (key `count_quick_entry_feedback`) shows the entry, with "(reemplazada)" when the product was already counted. On a refusal: the values stay and an inline error shows the localized part message.
- **Warnings band** (key `count_confirm_warnings`): shown when `CountConfirmNotice(id)` holds non-empty warnings. It has two optional sections (contado por debajo de lo apartado; corregido por otro conteo) and an ✕ that clears the notice.
- **Line search**: `CatalogSearchBar` (key `count_lines_search`) over the loaded lines, by code or name.
- **Lines**: `DataTableView` columns Código, Producto, Contado. Esperado and Diferencia are added only when the count is completed. ✎ and 🗑 appear only on a draft with update. The table is paged in memory at 100 rows with `CatalogPagination`.
- **Empty draft text**: "Registra lo que contaste. Las existencias esperadas se muestran al confirmar."
- **Action area**, in order: Cancelar (draft + delete), Editar encabezado (draft + update), Pegar lista (draft + update), Agregar producto (draft + update + read on products), Confirmar (draft + update). Each action is absent when not allowed.
- **Errors**: `ErrorBanner` above the action area keeps the last action's `AppError`. After a `document.not_editable` or `inventory_document.already_cancelled` refusal, the screen re-fetches.

## Dialogs (`ResponsiveDialog`, `FormErrorBanner`)

| Dialog | Fields | Result |
|---|---|---|
| Nuevo conteo | Almacén* (`inventoryWarehouseOptions`, preselected `inventoryStartingWarehouse`), Comentario (≤ 500) | pushes `/inventory/counts/{id}` |
| Editar encabezado | Almacén*, Comentario | updated count |
| Agregar producto | Producto* (stockable picker), Contado* (≥ 0, ≤ 4 decimals). When the product is already a line: note "Ya contado: {qty}. Se reemplazará." Button "Registrar" | updated count |
| Cantidad contada (✎) | Contado* | updated count |
| Quitar partida (🗑) | prompt | updated count |
| Pegar lista | multi-line text; live "N filas leídas · M con problemas" and a problem list. Enviar only when `canSend`. Sending shows progress and can't be dismissed. A refusal shows the rejected rows, how many rows were applied, and the "pegar de nuevo es seguro" note | re-fetch on close |
| Confirmar conteo | text per FR-012, checkbox "Contar en 0 los productos con existencia que no están en este conteo" (off) | `CountConfirmResult`; warnings go to `CountConfirmNotice` |
| Cancelar borrador | prompt; nothing posted | cancelled count |

All quantities, dates and folios go through `formattersProvider`.
