# Contract: UI actions

The print actions, the warehouse chooser and the flow between them. Requirement numbers refer to [spec.md](../spec.md).

## U1. Detail screen buttons

`lib/features/sales/presentation/delivery_orders/delivery_order_detail_screen.dart`, inside `_actionButtons`.

| Key | Widget | Label es / en | Shown when |
|---|---|---|---|
| `delivery_order_view_ticket` | `OutlinedButton.icon(Icons.receipt_long_outlined)` | Ver ticket / View ticket | `canPrintDeliveryOrder(access, order.status)` |
| `delivery_order_view_letter` | `TextButton.icon(Icons.description_outlined)` | Ver formato carta / View letter format | same |

- **Order.** Both lead the `Wrap`, so they sit left of the status actions and the filled action stays rightmost.
- **When hidden.** They are absent, never disabled, when the user lacks the right or the status is Borrador or Pendiente de aprobación (constitution §VI).
- **Cancelled orders.** These now show the action area with only these two buttons.

## U2. List row action

`delivery_orders_list_screen.dart`, through `DataTableView.rowActionsBuilder`.

| Key | Icon | Tooltip es / en | Shown when |
|---|---|---|---|
| `delivery_order_view_ticket_<id>` | `Icons.receipt_long_outlined` | Ver ticket / View ticket | `canPrintDeliveryOrder(access, summary.status)` |

- **Building it.** It is built with `buildCatalogRowActions(editTooltip: …, extraActions: [ticket])`, with no Edit, as on the payments list.
- **Unprintable rows.** They return no actions.
- **Row tap.** It still opens the detail screen.
- **Letter format.** No letter-format action on the row (FR-002).

## U3. Ticket flow: `openDeliveryTicket`

One function serves both entry points:

```text
openDeliveryTicket(context, ref, {
  required int orderId, required String folio, required int facilityId,
  List<int>? warehouseIds,   // known on the detail screen; null from the list
})
```

1. If `orderId` is already in the flow's in-flight set, return. Otherwise add it, and remove it when the flow ends.
2. If `warehouseIds` is null, call `deliveryOrderAdminRepository.getById(orderId)` and take `distinctWarehouses(lines)`.
   - On `AppError`, show a SnackBar with the error's localized message and stop.
3. If there are fewer than 2 warehouses, preview `DocumentRef(kind: deliveryTicket, recordId: orderId, title: documentDeliveryTicketTitle(folio))`.
4. Otherwise `showDeliveryTicketScopeDialog(...)`:
   - `null` (dismissed): stop, with nothing fetched;
   - `all`: as step 3;
   - `warehouse(id, name)`: preview with `warehouseId: id` and `title: documentDeliveryTicketWarehouseTitle(folio, name)`.

The preview itself is `ref.read(documentActionsProvider).preview(context, documentRef)`. Its own guard prevents a second dialog for the same ref.

## U4. Letter flow

`preview(DocumentRef(kind: deliveryOrderDocument, recordId: orderId, title: documentDeliveryOrderLetterTitle(folio)))`, with no chooser (FR-014).

## U5. Warehouse chooser: `showDeliveryTicketScopeDialog`

```text
Future<DeliveryTicketScope?> showDeliveryTicketScopeDialog(
  BuildContext context, {required int facilityId, required List<int> warehouseIds})
```

- **Container.** `ResponsiveDialog`: fullscreen on compact screens, max width 560 otherwise.
- **Title.** "¿Qué líneas imprimir?" / "Which lines to print?".
- **Options.** A `RadioGroup` with the key `delivery_ticket_scope_all` first and selected ("Todos los almacenes" / "All warehouses"). Then one `RadioListTile` per id, with the key `delivery_ticket_scope_<warehouseId>` and the label `DeliveryOrderWarehouseName(facilityId:, warehouseId:)`, which falls back to `#id`.
- **Primary action.** "Ver ticket" / "View ticket", with the key `delivery_ticket_scope_confirm`. It pops the chosen scope. For a single warehouse, the name passed back is the resolved name, or `#id` if unresolved.
- **Secondary action.** "Cancelar". It and a barrier dismiss pop `null`.

## U6. Strings added (es / en)

| Key | es | en |
|---|---|---|
| `deliveryOrderViewTicket` | Ver ticket | View ticket |
| `deliveryOrderViewLetter` | Ver formato carta | View letter format |
| `deliveryTicketScopeTitle` | ¿Qué líneas imprimir? | Which lines to print? |
| `deliveryTicketScopeAll` | Todos los almacenes | All warehouses |
| `documentDeliveryTicketTitle` | Ticket de entrega · {folio} | Delivery ticket · {folio} |
| `documentDeliveryTicketWarehouseTitle` | Ticket de entrega · {folio} · {warehouse} | Delivery ticket · {folio} · {warehouse} |
| `documentDeliveryOrderLetterTitle` | Orden de entrega · {folio} (carta) | Delivery order · {folio} (letter) |
| `apiErrorDeliveryOrderNotApproved` | La orden de entrega aún no está aprobada; no se puede imprimir. | The delivery order isn't approved yet, so it can't be printed. |
| `apiErrorDeliveryOrderUnknownWarehouse` | El almacén elegido no existe. | The chosen warehouse doesn't exist. |
| `apiErrorDeliveryOrderNoLinesFromWarehouse` | Ninguna línea de esta orden sale del almacén elegido. | No line of this order leaves from the chosen warehouse. |

The confirm and cancel buttons reuse the existing generic "Cancelar" key and `deliveryOrderViewTicket`.
