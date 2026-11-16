# Contract: UI — Entradas de almacén

SystemObject: **InventoryReceipts (15)**. Related reads: Warehouses (4) for the warehouse picker and facet, Products for the line picker.

## Routes and navigation

| Route | Screen | Gate |
|---|---|---|
| `/inventory/receipts` | `InventoryReceiptsListScreen(query: ListQuery.fromUri(uri))`, a `StatefulShellBranch` at index 30 | `can(15, read)` via `_routeGate` |
| `/inventory/receipts/:id` | `InventoryReceiptDetailScreen(id)`, top-level `GoRoute` | `can(15, read)` |

- Nav: a new group "Inventario" (`id: 'inventory'`) between Logística and Facturación, with one destination, "Entradas de almacén" (`NavBranch.inventoryReceipts = 30`). The group is dropped when the user can't read 15 (existing empty-group rule).
- Opening the detail URL of a receipt outside the user's scope shows the server's `resource.not_found` or `auth.forbidden` through the shared error view.

## List screen

- **Filter row** (`CatalogFilterBar`): no search control. A filters button with the active count badge opens `showCatalogFilterSheet`. Actions: "Nueva entrada" (`FilledButton.icon`, `Icons.add`) when `can(15, create)` and `can(4, read)`.
- **Filter drawer**: Estado (choice chips Borrador / Confirmada / Cancelada, single select or none). Almacén (warehouse picker, when `can(4, read)`). "Limpiar" and "Aplicar".
- **Table** (`DataTableView`), in column order:

  | Folio | Almacén | Sucursal | Orden de compra | Estado | Creado por | Fecha |
  |---|---|---|---|---|---|---|

  - Folio is the serial (right-aligned), or "Borrador #{id}" for a draft (FR-004).
  - Orden de compra is the PO id, or empty.
  - Estado is `InventoryReceiptStatusChip`.
  - Fecha is the creation date-time.

  The row tap pushes the detail. There are no row icons.
- **States**: `CatalogListStateView` handles loading, empty ("No hay entradas de almacén"), filtered-empty (with "Limpiar filtros") and error.
- **Pagination**: shared `CatalogPagination`, 20 per page, with the page in the URL.

## Detail screen

- **Title** (FR-004a): "Entrada {serial}" for a confirmed or cancelled receipt, or "Entrada · Borrador #{id}" for a draft. The AppBar has no actions.
- **Header facts** (`FactStripRow` / `ResponsiveFormGrid`, read-only):
  - Estado (chip), Folio, Almacén, Sucursal.
  - Orden de compra, when linked.
  - Notas.
  - Creado por and date, Modificado por and date.
- **Warnings band** (`receipt_warnings.dart`): on a draft or confirmed receipt (never a cancelled one, FR-015), when `overReceipts` is non-empty, a warning-toned banner lists one line per entry: "Se recibió de más {code}: {excess} (recibido {received} de {ordered} ordenado)". It is never blocking.
- **Lines table**: Código, Producto, Cantidad recibida (right). When the receipt is linked, it also shows Ordenado and Recibido en otras entradas (right). Hand-added lines show "—" in both.
  - On a draft with update, rows have ✎ (quantity dialog) and 🗑 (remove prompt) via `buildCatalogRowActions`.
  - Empty draft: "Agrega los productos recibidos."
- **Action area** (body, left to right):
  1. Cancelar (`OutlinedButton`, error tone)
  2. Entrada complementaria (`OutlinedButton`)
  3. Editar encabezado (`OutlinedButton`)
  4. Agregar producto (`OutlinedButton`)
  5. Confirmar (`FilledButton`)

  Each is shown per the data-model availability table and absent otherwise.
- After any action: the screen shows the returned receipt. A refusal shows in the `ErrorBanner` above the action area. `document.not_editable`, `already_cancelled` and `lock.busy` also trigger a re-fetch.
- After confirm or cancel, when `hasUnmappedWarnings`: a notice band above the lines shows "Se actualizaron los costos con excepciones." with a close button (FR-015a). It stays until closed or until the user leaves the receipt.
- After complementary: push `/inventory/receipts/{returnedId}`.

## Dialogs

| Dialog | Fields | Submit | Guard |
|---|---|---|---|
| Nueva entrada | Almacén (required; starts with the user's point-of-sale warehouse, else empty, and empty for a non-administrator when that warehouse is in another facility; own-facility warehouses only for non-administrators), Notas (≤ 500, counter) | "Crear"; on success, push detail | `hasUnsavedChanges` (the starting warehouse alone doesn't count as a change) |
| Editar encabezado | Almacén (a picker only with read on Warehouses (4); read-only text when linked or without that right; own-facility warehouses only for non-administrators), Notas (≤ 500) | "Guardar"; send only changed fields (research R8) | `hasUnsavedChanges` |
| Agregar producto | Producto (stockable, active), Cantidad (> 0) | "Agregar"; the dialog stays open on refusal | `hasUnsavedChanges` |
| Cantidad de la partida | Cantidad (> 0), prefilled | "Guardar" | `hasUnsavedChanges` |
| Quitar partida | — | "Quitar" | — |
| Confirmar entrada | Explanation text, plus the over-receipt list when present | "Confirmar" | — |
| Cancelar entrada | Draft or completed wording (research R11) | "Cancelar entrada" | — |

Refusals inside a dialog show in the dialog's `FormErrorBanner`, and the dialog stays open.

## Spanish labels (new `.arb` keys, prefix `inventoryReceipt…`)

- Nav: Inventario, Entradas de almacén.
- Statuses: Borrador, Confirmada, Cancelada.
- Every column, action, dialog title, prompt and empty state named above, plus the cost notice and the over-receipt line.
- English strings are added to `app_en.arb` with the same keys.
