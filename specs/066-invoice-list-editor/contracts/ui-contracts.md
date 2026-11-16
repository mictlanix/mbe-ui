# UI Contracts: Invoice List, View, PDF and Editor (spec 066)

Each contract states what a widget test asserts. Spanish labels are the `es` ARB values; `en` gets equivalents.

## C1. Navigation and routes

- The side nav has a new group, **Facturación**, with destination **Facturas** (`NavBranch.fiscalDocuments = 29`, route `/invoicing/fiscal-documents`), gated `PrivilegeGate(SystemObject.fiscalDocuments, AccessRight.read)`.
- The detail is a top-level `GoRoute` at `/invoicing/fiscal-documents/:fiscalDocumentId`. A non-numeric id shows not-found.
- `_routeGate` adds `/invoicing/fiscal-documents` → 23 read. Without the right, the nav entry is hidden and the URL shows the no-access screen.

## C2. List screen

- The filter row holds `CatalogSearchBar` (hint "Folio, UUID, RFC o nombre del receptor"), the badged filters button, and **Nueva factura** (`FilledButton.icon`, only with 23 create).
- Columns are listed in research R4. Total is right-aligned, a draft's total shows the placeholder, and the status column uses `FiscalDocumentStatusChip`.
- Rows have no row icons. Tapping a row pushes the detail.
- Pagination uses the shared component, 20 per page.
- The empty and filtered-empty states use `CatalogListStateView`.

## C3. Filter drawer

- The facets are Estado, Tipo, Emisor (only with Taxpayers 24 read) and Fecha de emisión.
- Under the date facet sits the helper "Los borradores no tienen fecha de emisión y no aparecen al filtrar por fecha."
- Every change resets to page 0. "Limpiar" keeps the search.

## C4. Status chip

| Status | Label | Tone |
|---|---|---|
| draft | Borrador | neutral |
| sealed | Sellado | info |
| issued | Timbrado | success |
| cancelled | Cancelado | error |

## C5. Detail screen

- **AppBar**: the title is "Factura {folio}" (or "Borrador #{id}"; for other kinds, the kind's name), with no actions.
- **Banner** (one at most):
  - sealed: "Sellada, pendiente de timbrar. El timbrado aún no está disponible en este sistema."
  - non-invoice: "Este tipo de documento solo se puede consultar."
  - cancelled: "Cancelada el {fecha}."
- **No-customer note**: on a legacy draft with no customer, the header shows "Este borrador no tiene cliente: no se puede cambiar el receptor ni agregar pedidos.", and Receptor and Agregar pedido are absent.
- **Header facts**: emisor (RFC, name, regime), receptor (RFC, name, regime, CP), cliente (name via `customerDisplayNameProvider`, falls back to `#id`), sucursal, serie y folio, fecha de emisión ("al confirmar" when empty on a draft), método/forma de pago, uso CFDI, moneda, referencia, notas, UUID and fecha de timbrado (when stamped).
- **Lines section**: a `DataTableView` on wide screens and cards on compact.
  - Columns: cantidad, unidad, clave SAT, descripción (+ clave interna, comentario), precio unitario, descuento %, IVA, importe.
  - A line from a sales order shows a "Pedido" marker. (The order id is not exposed per line, so only the marker shows.)
- **Related documents section**: shown when there are relations, or on an editable draft. Rows show tipo, folio and UUID.
- **Totals**: Subtotal, Descuento (> 0 only), IVA, Total. On a draft, the label reads "Total (estimado)".
- **Action area**: secondary actions first, then the primary.

| State (invoice) | Actions shown (subject to rights, C9) |
|---|---|
| draft | Editar encabezado (header section), Agregar pedido, Agregar producto (lines section), Agregar relación (relations section), **Confirmar** |
| sealed | Reabrir |
| issued | Ver PDF, Descargar XML |
| cancelled | Ver PDF, Descargar XML (the PDF carries the cancellation mark) |
| any non-invoice issued/cancelled | Ver PDF, Descargar XML |

On any non-draft document, no edit controls exist in the tree.

## C6. Nueva factura dialog

- Fields: Cliente (picker) and RFC del receptor (dropdown, enabled after the customer loads).
- With no taxpayers, the dropdown is replaced by "Este cliente no tiene RFC registrado." and Crear is disabled.
- Crear calls `create`. On success the dialog closes and the app navigates to the new detail. Refusals such as `issuer_has_no_series`, `recipient_not_linked` and `user.no_facility` stay inline.

## C7. Header dialog

- The fields are those in research R8, filled from the document. Only changed fields are sent.
- PPD selected: Forma de pago shows "99 — Por definir" and is disabled.
- `serial != null`: Serie is read-only, with the helper "La serie no cambia una vez asignado el folio."
- Without 103 update (and not an administrator), Sucursal is absent.
- A date outside the 72-hour window shows an inline field error and disables Guardar.

## C8. Line dialog and line removal

- Fields: Cantidad (> 0), Precio unitario (≥ 0), Descuento % (0–100), IVA (16 % / 0 % / Exento), Clave interna (≤ 35), Descripción (blank = "se restablece al nombre del producto"), Comentario.
- `quantity_exceeds_invoiceable` keeps the dialog open with "Solo quedan {remaining} por facturar de esta partida del pedido."
- Removing a line asks "¿Quitar esta partida de la factura?" with Quitar as the confirm button.

## C9. Rights matrix

| Control | Required |
|---|---|
| Facturas nav/route, detail, Ver PDF, Descargar XML | 23 read |
| Nueva factura | 23 create |
| Editar encabezado, line ✎/🗑, Agregar relación, relation 🗑, Confirmar, Reabrir | 23 update |
| Agregar pedido | 23 update + SalesOrders (7) read |
| Agregar producto | 56 create (a draft is open for editing only with 23 update, so both are needed in practice) |
| Sucursal field | 103 update or administrator |
| Emisor facet, Serie dropdown | Taxpayers (24) read |

A missing right means the control is absent, never shown disabled.

## C10. Add sales order dialog

- The paged list shows the customer's completed orders (folio, fecha, total), with a search box.
- Picking one calls `addSalesOrder`. On success it closes with a snackbar "Se agregaron las partidas del pedido {folio}."
- `no_invoiceable_lines` and `order_not_invoiceable` stay inline, so the user can pick another order.

## C11. Add product dialog

- `CatalogEntityPicker<ProductListItem>`; picking one calls `addProduct`.
- `product_unpriced` stays inline: "El producto no está en la lista de precios del cliente."

## C12. Add relation dialog

- Tipo: 04 Sustitución de CFDI cancelado / 07 Aplicación de anticipo. It is locked to the draft's existing type when one exists.
- Documento: a paged picker over the list endpoint (`status=cancelled` for 04, `issued` for 07), with search prefilled with the recipient RFC. Rows show folio, fecha, UUID and total.
- `relation_not_allowed`, `already_related` and `relation_types_mixed` stay inline.
- Removing a relation asks for confirmation.

## C13. Confirm and reopen dialogs

- **Confirmar**: "Se asignará el siguiente folio de la serie {serie} y se sellará la factura. Después solo podrá reabrirse mientras no esté timbrada." On success: snackbar "Factura {folio} sellada."
- **Reabrir**: "La factura vuelve a borrador y conserva el folio {folio}. El sello se descarta."
- Refusals close the dialog and show above the action area via `ErrorBanner`. The confirm-validation codes in research R13 each have their own message.

## C14. PDF and XML

- **Ver PDF** calls `documentActionsProvider.preview` with `DocumentKind.fiscalDocument`. The dialog provides Imprimir and Descargar.
- **Descargar XML** fetches the bytes and calls `fileSaverProvider.save(bytes, filename)`. On success: snackbar "XML guardado." Cancelling the save dialog shows nothing. Refusals (`not_issued`, `xml_unavailable`) show as a snackbar with the localized message.
