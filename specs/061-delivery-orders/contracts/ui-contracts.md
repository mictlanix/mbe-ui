# UI Contracts: Delivery Orders

**Spec**: [spec.md](../spec.md) | **Wireframes**: [wireframes.md](../wireframes.md) | **Data model**: [data-model.md](../data-model.md)

Each contract states what a test can assert. Keys are given where a widget test finds the element.

## C1. Navigation and routes

- **Nav entry.** `NavDestination(id: 'delivery-orders')` is in Ventas, immediately after `sales-orders`. Its label is `navDeliveryOrders` ("Órdenes de entrega" / "Delivery orders"), with `NavBranch.deliveryOrders = 26`. Its gate is `PrivilegeGate(SystemObject.deliveryOrders, AccessRight.read)`.
- **List route.** `/sales/delivery-orders` (shell branch). Query keys are listed in data-model §2.
- **Detail route.** `/sales/delivery-orders/:deliveryOrderId` (top-level). A non-integer id renders the not-found state.
- **Gate.** `_routeGate`: any location starting with `/sales/delivery-orders` requires 71 read. Without it, the user is redirected like every other gated route (FR-001, SC-006).
- **Documented object.** The route documents SystemObject 71 (§IV).

## C2. List screen (`DeliveryOrdersListScreen`)

- **Filter row.**
  - It is a `CatalogFilterBar` with a `CatalogSearchBar` (key `delivery_orders_search`). The search accepts digits only: a `FilteringTextInputFormatter.digitsOnly`, hinted "Folio o número de orden".
  - The filters button opens `showCatalogFilterSheet`, and its badge equals `activeFilterCount`. On first load the badge is 0, because the interim opening state is every status (FR-003).
  - There is no create action.
- **Table.** `DataTableView<DeliveryOrderSummary>` with columns Folio, Cliente, Tipo, Programada, Destino, Pedidos, Estado.
  - **Folio** shows "Borrador" (`deliveryOrderDraftFolio`) when `serial == null`.
  - **Cliente** and **Destino** are truncated, with a tooltip.
  - **Pedidos** joins the sales-order ids with ", ".
  - **Estado** is a `DeliveryOrderStatusChip`, never truncated.
- **Row behaviour.** A row has no icons. Tapping a row pushes `/sales/delivery-orders/{id}` (FR-006). This is a recorded §VI reading: delivery orders are documents, not catalog records (plan, Constitution Check).
- **Pagination.** `CatalogPagination`, 20 rows per page, newest first (server order: id descending).
- **States.**
  - Loading and error use `CatalogListStateView`, with error text from `localizeProblem`.
  - Empty shows `deliveryOrdersEmpty`. "Quitar filtros" appears only when `isNarrowed`.
- **Compact tier.** Rows stack, and Pedidos is dropped (wireframes).

## C3. Filter sheet

- **Fields, in order:**
  - **Estado:** "Todas", then the 11 statuses.
  - **Tipo:** "Todos", Entrega or Recoge en tienda.
  - **Fecha programada:** `DateRangeFilterChip`.
  - **Cliente:** `CatalogEntityPicker`, only with Customers read.
  - **Pedido:** a numeric field.
  - **Sucursal:** a dropdown of facilities, only with Facilities read. Its first item is "Mi sucursal" (absent).
- **Buttons.** "Limpiar todo" nulls every facet. "Aplicar" writes the URL.
- **"Activas".** Not offered until mbe-api#312 ships.

## C4. Detail screen (`DeliveryOrderDetailScreen`)

- **App bar.**
  - The title is `deliveryOrderTitleDraft` ("Orden de entrega · Borrador") or `deliveryOrderTitle(serial)`.
  - `AppBar.actions` is empty (§VI).
- **Body, top to bottom:**
  1. **Rejection banner** (key `delivery_order_rejection_banner`), shown when `rejectionReason != null`.
  2. **Facts strip.** A `FactStripRow` with Folio, Estado (chip), Tipo, Cliente, Sucursal, Programada and Prioridad.
  3. **Detail band.** A `ResponsiveFormGrid` of read-only `CompactField`s:
     - Destino and Contacto;
     - Pedidos, as links to `/sales/orders/{id}`;
     - Comentario;
     - "De la orden" (the parent link) when `parentId != null`;
     - "Orden derivada" (child links) when status is `partiallyDelivered` and children exist (R5).

     It ends with the "Editar encabezado" outlined button (key `delivery_order_edit_header`), per data-model §3.
  4. **Lines.** `DataTableView<DeliveryOrderLine>` with columns Código, Producto, Almacén, Pedido, Ordenada, Comprometida, Entregada, Devuelta and Abierta.
     - Quantities are right-aligned, via `formattersProvider` quantity format.
     - On an editable draft, each row has ✎ (`delivery_order_line_edit_{id}`) and 🗑 (`delivery_order_line_remove_{id}`), built with `buildCatalogRowActions`.
     - The "Agregar línea" button (`delivery_order_add_line`) is in the section header.
  5. **Comprobante de entrega.** Shown when `hasProof`: receiver name, identification shown, the photo thumbnail (tap to enlarge, in a `ResponsiveDialog`), the capture time, and who captured it.
  6. **Historial.** One row per event, oldest first: date and time, `from → to`, employee name, and the reason (truncated, with a tooltip).
  7. **Actions.**
     - An end-aligned `Wrap`.
     - "Cancelar orden" is an `OutlinedButton` (`delivery_order_cancel`).
     - The primary is a `FilledButton`: `delivery_order_confirm`, `delivery_order_requeue`, `delivery_order_ready` or `delivery_order_pickup`, per data-model §3.
     - An action the user can't take is absent, not disabled. The one exception is Confirmar with no lines, which is disabled and has the hint `deliveryOrderConfirmNeedsLines` (FR-016).
- **Load states.**
  - Not found shows a message and "Volver a órdenes de entrega".
  - A load error adds retry.
  - Proof load failure shows "No se pudo cargar el comprobante" inside its section only.
- **After any action.** The screen shows the reloaded order and events (FR-022), plus a SnackBar naming the action ("Orden 1532 confirmada", and so on).

## C5. Confirm, Requeue and Ready dialogs

- **Confirmar.** A `ResponsiveDialog` naming the customer, scheduled date and line count, with the line `deliveryOrderConfirmIrreversible`.
  - On `delivery_order.insufficient_notice`, it stays open with a `FormErrorBanner` carrying the localized message, which includes `earliest` (FR-017).
  - Other errors close the dialog, show the localized error and reload.
- **Reprogramar and Lista para recoger.** Name the folio and customer. There is no field.

## C6. Cancel dialog

- **Reason.** A multiline text field (`delivery_order_cancel_reason`). The confirm button is disabled while `reason.trim().isEmpty` (FR-018).
- **`state.transition_invalid`.** The dialog closes, the generic localized transition message shows, and the order reloads, so its new status explains why.

## C7. Add-line dialog (two steps)

- **Step 1, the sale.** A list of the customer's completed sales at the order's facility, each showing folio, date and total.
  - Source: `listOrders(customer:, status: completed, facility:)`, paginated 20 at a time with "Cargar más".
  - Digits typed into its search field narrow it by sale folio.
- **Step 2, the lines.**
  - A table of `DeliverableLine`s (Código, Producto, Pendiente, Cantidad) for the chosen sale. Lines already on the order and lines with nothing left are left out.
  - Each Cantidad field validates `0 < q ≤ remaining`. A blank field means "skip".
  - "Agregar" is enabled when at least one field is valid and none is invalid.
- **Save.** One `addLine` per filled row, run in sequence.
  - On the first error the run stops, the dialog shows the localized error, and every row before it is already added.
  - On close, the detail reloads.
- **Empty states.** "Este cliente no tiene ventas con pendiente por entregar en esta sucursal." (step 1) and "Esta venta ya no tiene pendiente por entregar." (step 2).
- **Gate.** Offered only with `deliveryOrders` update and `salesOrders` read.

## C8. Line quantity and remove

- **✎ Cantidad.** A dialog with one decimal field, prefilled with the current quantity.
  - Above the field: "Ordenada en la venta: N".
  - The client checks only that the quantity is greater than 0. Remaining for this line is `remaining + current`, which the client doesn't have without the sale.
  - So the server's `delivery_order.quantity_exceeds_remaining {requested, remaining}` is the bound, shown inline in the dialog.
- **🗑 Quitar.** A confirmation naming the product, which says its quantity becomes available again.

## C9. Pickup dialog ("Entregar al cliente")

- **Fields.**
  - "Nombre de quien recibe" (`delivery_order_pickup_name`);
  - "Identificación mostrada" (`delivery_order_pickup_id`, free text);
  - "Foto": a "Elegir archivo" button that uses `file_picker` with jpg, jpeg or png. The chosen file's name is shown with ✕ to clear it.
- **Confirm button.** Enabled only when both texts aren't blank and a file is chosen (FR-021, SC-004).
- **Errors.** `delivery_order.proof_incomplete` and others show inside the dialog. The dialog stays open, so the photo isn't lost.

## C10. Header dialog

- **Fields.** Fecha programada (date and time), Prioridad (integer ≥ 0), Destino (`CustomerAddressPicker`, deliveries only), Contacto (`CustomerContactPicker`) and Comentario.
- **Pickup.** Destino is shown read-only as the store.
- **Save.** Only changed fields are sent. There is no clear affordance. "Guardar" is disabled until something changes.

## C11. Status chip and labels

- `DeliveryOrderStatusChip` is a `StatusChip<DeliveryOrderStatus>`, with keys `delivery_order_status_chip_{name}`.

  | Group | Statuses |
  |---|---|
  | Neutral | draft |
  | Warning | pendingApproval, failed |
  | Info | approved, readyForPickup, inPreparation, inTransit |
  | Success | pickedUp, delivered, partiallyDelivered |
  | Muted | cancelled |

- The 11 status labels and 2 type labels are new keys in both ARB files. Spanish labels: Borrador, Pendiente de aprobación, Aprobada, Lista para recoger, Recogida, En preparación, En tránsito, Entregada, Entregada parcialmente, Fallida, Cancelada. Types: Entrega, Recoge en tienda.

## C12. POS fix (R9)

- `DeliveryOrderRepositoryImpl.listForSale` returns no destination whose status is `cancelled`.
