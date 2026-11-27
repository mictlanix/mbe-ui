# Contract: UI

Screens are drawn in [wireframes.md](../wireframes.md); rights per action are in [data-model.md](../data-model.md#action-availability).

## Routes and navigation

| Route | Screen | Gate (`_routeGate` prefix) | Branch |
|---|---|---|---|
| `/purchases/requests` | `PurchaseRequestsListScreen(query: ListQuery.fromUri)` | read 86 | `NavBranch.purchaseRequests = 38` |
| `/purchases/requests/:requestId` | `PurchaseRequestDetailScreen(requestId: int.tryParse)` (top-level `GoRoute`, outside the shell) | read 86 (same prefix) | — |
| `/purchases/request-approval` | `PurchaseRequestApprovalScreen(query: ListQuery.fromUri)` | read 96 | `NavBranch.purchaseRequestApproval = 39` |

Navigation: `NavGroup(id: 'purchases', label: l10n.navPurchasesGroup /* Compras */)` between `inventory` and `finance`, with `purchaseRequests` (Solicitudes de compra) then `purchaseRequestApproval` (Aprobación de solicitudes). A group with no visible children is dropped.

The detail is pushed (`context.push`) from the list, from the queue and after create, so back returns to where the user came from.

## Solicitudes de compra list

- Filter row: `CatalogFilterBar` with a numeric folio search, the filters button with `Badge.count`, and "Nueva solicitud". Nothing else sits in the row (§VI).
- Filter sheet: Mostrar ("Mis solicitudes" default, "Todas" counted in the badge), state chips, facility, warehouse and requester pickers, date range. Each picker only with read on its catalog.
- Table: Folio, Sucursal, Almacén, Estado, Solicitó, Fecha, Partidas. Row tap pushes the detail. No row icons.
- `CatalogListStateView` for loading, empty (text depends on scope), filtered-empty and error. `CatalogPagination`, 20 per page.

## Solicitud detail

- Header facts (`FactStripRow` in `ResponsiveFormGrid`): Estado, Folio, Almacén, Sucursal, Notas, Solicitó + date, and Aprobó + time when approved.
- Minimum-quantity band (research R7) under the header for draft, submitted and approved.
- Lines (`DataTableView`): Código, Producto, Cantidad, Destino, Comprar (checkbox), Orden c. (number + `InventoryDocumentStatusChip`, only when any line has one); ✎ 🗑 on draft rows for users who can edit.
- Action area (end-aligned `Wrap`): Cancelar · Editar encabezado · Agregar producto · Enviar (draft); Cancelar · Rechazar · Aprobar (submitted); Cancelar (approved). Each present only per the availability table.
- `ErrorBanner` above the action area for refusals; stale codes re-fetch (research R13).
- Loading spinner; not found / forbidden → the shared error view.
- Unsaved-changes guard on the header and line dialogs.

## Aprobación de solicitudes

- Filter row: no search; the badged filters button (its sheet holds the Sucursal picker, with read on facilities; left out without it) and "Aprobar seleccionadas (n)".
- Table: checkbox column (with update on 96), Folio, Sucursal, Almacén, Solicitó, Fecha, Partidas, Notas, row ✓ (with update on 96). Row tap pushes the detail only with read on 86.
- Empty: "No hay solicitudes pendientes de aprobación." (with "Limpiar filtros" when a facility is chosen).
- After a single approve: SnackBar "Solicitud {folio} aprobada." After bulk: SnackBar when all succeed, result dialog when any is refused. The queue reloads; selection clears; an emptied page steps back one page.

## Dialogs (all `showResponsiveDialog`)

| Dialog | Fields / text | Submit |
|---|---|---|
| Nueva solicitud | Almacén* (scoped picker, starts at the POS warehouse), Notas (≤ 500) | Crear → push detail |
| Editar encabezado | Almacén (scoped; helper "solo almacenes de {sucursal}" once numbered), Notas | Guardar |
| Agregar producto | Producto* (active, purchasable) | Agregar |
| Editar partida | Nombre* (≤ 250), Cantidad* (> 0, ≤ 2 decimals, helper "mínimo {n}"), Destino* (unscoped picker) | Guardar |
| Quitar partida | "Quitar {código} de la solicitud." | Quitar |
| Enviar solicitud | first submit vs. "Volverá a aprobación con el folio {serial}"; minimum warnings listed | Enviar |
| ¿Aprobar solicitud {folio}? | sucursal · almacén · partidas | Aprobar |
| Rechazar solicitud {folio} | Motivo* (1–500, trimmed); note: returns to draft, keeps folio | Rechazar |
| Cancelar solicitud | "Cancelar la solicitud {folio}" / "Cancelar el borrador" | Cancelar solicitud |
| Resultado de la aprobación | "Se aprobaron {a} de {n} solicitudes." + refused folio · sucursal: reason | Cerrar |

Every dialog disables its buttons while submitting; refusals show in `FormErrorBanner`.

## Formatting

Folios, quantities and dates through `formattersProvider` (§V). All text in `app_es.arb` with `app_en.arb` twins.
