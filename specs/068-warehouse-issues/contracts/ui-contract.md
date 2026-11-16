# Contract: UI — Salidas de almacén

SystemObject: **InventoryIssues (16)**. Related reads: Warehouses (4) for the warehouse picker and facet, and Products for the line picker. Wherever this contract says "as 067", the [receipts UI contract](../../067-warehouse-receipts/contracts/ui-contract.md) applies with "entrada" read as "salida".

## Routes and navigation

| Route | Screen | Gate |
|---|---|---|
| `/inventory/issues` | `InventoryIssuesListScreen(query: ListQuery.fromUri(uri))`, `StatefulShellBranch` index 31 | `can(16, read)` via `_routeGate` |
| `/inventory/issues/:id` | `InventoryIssueDetailScreen(id)`, top-level `GoRoute` | `can(16, read)` |

- Nav: a second destination in the "Inventario" group, after Entradas de almacén: "Salidas de almacén" (`id: 'inventory-issues'`, `NavBranch.inventoryIssues = 31`, `Icons.outbox_outlined` / `Icons.outbox`). The group shows when the user can read either 15 or 16 (existing empty-group rule).

## List screen

- **Filter row**: as 067. There is no search control. The filters button shows the active count. The action is "Nueva salida" (`FilledButton.icon`, `Icons.add`), shown when `can(16, create)` and `can(4, read)`.
- **Filter drawer**: as 067, on the shared `InventoryDocumentsFilter` (Estado chips, and the Almacén picker offering every warehouse).
- **Table** (`DataTableView`), in column order:

  | Folio | Almacén | Sucursal | Estado | Creado por | Fecha |
  |---|---|---|---|---|---|

  - Folio is the serial, right-aligned, or "Borrador #{id}" for a draft.
  - Estado is `InventoryDocumentStatusChip`.
  - Names come from the shared name cells.
  - A row tap pushes the detail. There are no row icons.
- **States**: `CatalogListStateView`. The empty text is "No hay salidas de almacén". Filtered-empty has "Limpiar filtros".
- **Pagination**: `CatalogPagination`, 20 per page.

## Detail screen

- **Title**: "Salida {serial}", or "Salida · Borrador #{id}" for a draft. The AppBar has no actions.
- **Header facts** (`FactStripRow` / `ResponsiveFormGrid`, read-only):
  - Estado (chip), Folio, Almacén, Sucursal.
  - Devolución a proveedor #{id}, only when `supplierReturnId` is set (plain text).
  - Motivo / notas.
  - Creado por with its date, and Modificado por with its date.
- **Lines table**: Código, Producto, Cantidad (right-aligned).
  - On a draft with update, rows have ✎ (quantity dialog) and 🗑 (remove prompt) via `buildCatalogRowActions`.
  - Empty draft: "Agrega los productos que salen del almacén."
- **No warning or notice band.**
- **Action area** (body, left to right):
  1. Cancelar (`OutlinedButton`, error tone)
  2. Editar encabezado (`OutlinedButton`)
  3. Agregar producto (`OutlinedButton`)
  4. Confirmar (`FilledButton`)

  Each action follows the data-model availability table.
- **After an action**: the screen shows the returned issue. A refusal shows in the `ErrorBanner` above the action area. `insufficient_stock` adds the line "Producto: {code} · Almacén: {name}" (error-messages contract). `document.not_editable`, `already_cancelled` and `lock.busy` also re-fetch the issue.

## Dialogs

| Dialog | Fields | Submit | Guard |
|---|---|---|---|
| Nueva salida | Almacén (required; shared starting warehouse and scope, as 067), Motivo / notas (optional, ≤ 500, counter, hint "p. ej. merma, daño, consumo interno") | "Crear", then push the detail | `hasUnsavedChanges` (the starting warehouse alone doesn't count) |
| Editar encabezado | Almacén (a picker with read on 4, otherwise read-only text; shared scope), Motivo / notas (≤ 500, hint) | "Guardar", sending only changed fields; cleared notes send `""` | `hasUnsavedChanges` |
| Agregar producto | Producto (stockable, active), Cantidad (> 0) | "Agregar"; stays open on refusal | `hasUnsavedChanges` |
| Cantidad de la partida | Cantidad (> 0), prefilled | "Guardar" | `hasUnsavedChanges` |
| Quitar partida | — | "Quitar" | — |
| Confirmar salida | "Confirmar asigna un folio y retira las existencias de {almacén}. Después ya no se puede editar." | "Confirmar" | — |
| Cancelar salida | Draft: "Cancelar el borrador". Completed: "Cancelar la salida {folio} regresa a {almacén} las existencias que retiró." | "Cancelar salida" | — |

Refusals inside a dialog show in an `ErrorBanner` inside the dialog, and the dialog stays open.

## Spanish labels (new `.arb` keys, prefix `inventoryIssue…`)

- Nav label: Salidas de almacén.
- Every column, action, dialog title, prompt, hint and empty state above, the supplier-return fact, and the refusal enrichment line.
- The status labels are the shared `inventoryDocumentStatus*` keys (research R1).
- English strings use the same keys in `app_en.arb`.
