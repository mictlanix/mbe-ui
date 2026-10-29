# UI Contracts: Customer Refunds

## C1. Routes and navigation

| Route | Screen | Gate | SystemObject |
|---|---|---|---|
| `/sales/refunds` | `RefundsListScreen(query: ListQuery.fromUri(state.uri))` | `PrivilegeGate(SystemObject.customerRefunds, AccessRight.read)` | CustomerRefunds (22) |
| `/sales/refunds/:refundId` | `RefundDetailScreen(refundId)`, a top-level full-screen route. A bad id gives the not-found state | same | CustomerRefunds (22). Confirm is CustomerRefundConfirm (110) |

- Append the shell branch at index 24 and add `NavBranch.customerRefunds = 24`.
- The nav entry goes in the `sales` group right after Notas de crédito, with `id: 'refunds'`, label `refundsMenuTitle` ("Devoluciones") and icon `Icons.assignment_return_outlined`.
- Add a `_routeGate` clause for the `/sales/refunds` prefix.

## C2. Repository (`domain/repositories/customer_refund_repository.dart`)

```dart
abstract interface class CustomerRefundRepository {
  Future<RefundListResult> list({RefundStatus? status, int? customerId, int? salesOrderId, required int skip, required int limit});
  Future<CustomerRefund> getById(int id);
  Future<CustomerRefund> open(int salesOrderId);
  Future<CustomerRefund> updateLine(int refundId, int lineId, {String? quantity, int? warehouseId});
  Future<CustomerRefund> confirm(int refundId, RefundPayout payout);
  Future<CustomerRefund> cancel(int refundId);
}
```

Errors map through `mapDioException` to the shared `AppError`. `CreditNoteRepository` gains `findByRefund({required int customerId, required int refundId, required DateTime refundDate})`, which returns `Future<CreditNote?>` (R6).

## C3. Open or resume (`openOrResume`)

- **Shared:** "Devolver" and the list's "Nueva devolución" dialog both call it. It returns either `RefundOpened(refundId, resumed: bool)` or `RefundRefused(RefundRefusal, serverDetail?)` (R2, R3).
- **On success:** navigate with `context.push('/sales/refunds/$id')`.
- **On a refusal:**
  - "Devolver" shows a SnackBar.
  - The dialog shows the reason inline and stays open.

| Refusal | Copy (es) |
|---|---|
| `orderNotFound` | "No existe el pedido {n}." |
| `notCompleted` | "El pedido {n} no está confirmado." |
| `notPaid` | "El pedido {n} no está pagado. Cancélalo en lugar de hacer una devolución." |
| `nothingToReturn` | "El pedido {n} no tiene nada por devolver." followed by the server's detail |

**"Devolver" buttons** (key `order_refund_button`):

| Where | Placement |
|---|---|
| Pedidos | `OrderHeaderPanel`, in the trailing `Wrap` next to "Ver pedido" |
| POS | `PosSaleDetailView._Facts`, next to the ticket button |

They are shown only when `sale.isPaid`, `can(customerRefunds, create)` and `can(customerRefunds, read)` all hold. Otherwise they are not built.

## C4. Refunds list (FR-013, FR-014)

- **Columns:** Folio (`serial`, or "—" for a draft) · Fecha · Cliente (`PaymentCustomerName`) · Pedido (`#n`, linked through `orderLinkTargetProvider`) · Estado (chip) · Total (right-aligned, never truncated). Only the customer name truncates.
- **Filter sheet:**
  - Estado: Todas / Abiertas / Confirmadas / Canceladas
  - Cliente picker
  - Pedido number
  - Each change resets the page to 0.
- **Header:** the "Nueva devolución" button (key `refunds_new_button`, gated by create) opens a dialog with an order number field (key `refund_new_order_input`) and runs C3.
- **Row tap:** pushes `/sales/refunds/{id}`. There is no row Edit icon.
- **States:** empty, filtered empty, a 403 shown as forbidden with no retry, and retry otherwise. These follow Notas de crédito.

## C5. Refund detail (FR-005 to FR-012, FR-015, FR-017)

**Header facts:**
- Folio or "Borrador"
- Fecha
- Cliente
- Pedido #n (a link)
- Estado

**Lines** (`DataTableView`): Producto (code · name), Precio, Desc., IVA, Por devolver (`refundableQuantity`), Devolver, Almacén, Total.

**Draft, with update right:**
- Devolver is a `QuantityStepper` (key `refund_line_qty_<lineId>`) with `min: 0` and `max: refundableQuantity`.
- Almacén is a tap-field (key `refund_line_warehouse_<lineId>`) that opens `showWarehousePicker`.
- A refused write shows the server detail under its line.

**Otherwise:** both columns are plain text.

**Totals:** subtotal, tax and total, straight from the server.

**Actions (body, not the app bar):**

| Action | Key | Shown when |
|---|---|---|
| Confirmar devolución | `refund_confirm_button` | draft, `can(customerRefundConfirm, update)`, `hasReturn` |
| Cancelar devolución | `refund_cancel_button` | draft, `can(customerRefunds, update)`. Asks for confirmation first |
| Imprimir | `refund_print_button` | completed. Built only after mbe-api#287 (R10) |

**Failures:** a failed confirm or cancel shows an `ErrorBanner` above the actions with the server's detail, and leaves the refund as it was. This covers the server's 409s for units on a live invoice and for no returnable lines (R3).

**Session pre-check:** if the cash session check fails, show an inline banner (key `refund_session_banner`) that reads "Abre una sesión de caja para confirmar la devolución." It has a button to `/sales/cash-sessions`, or to `/sales/cash-sessions/{id}` for a stale session. The dialog does not open.

**Confirm dialog** (key `refund_confirm_dialog`):
- It shows "Se devolverán {total} al cliente."
- It has two `RadioListTile`s, none selected: `refund_payout_cash` "Efectivo de la caja" and `refund_payout_credit_note` "Nota de crédito".
- Its confirm button is disabled until a choice is made.

**Completed:**
- A payout line (key `refund_payout_line`) shows the `RefundOutcome` copy. The credit-note variant links to its backing payment, `/sales/payments/{customerPaymentId}`, which is the credit note's record surface in spec 056. The link is shown only when the user has `can(customerPayments, read)`.
- If quantities were adjusted, an info banner (key `refund_adjusted_banner`) reads "Algunas cantidades se ajustaron porque otra devolución se confirmó antes."

**Cancelled:** a read-only view with an "Cancelada" chip.

## C6. Credit-notes origin link (FR-016)

In `_OriginCell`, the refund segment becomes a link (key `credit_note_refund_link_<refundId>`) to `/sales/refunds/{id}` when `can(customerRefunds, read)`. Otherwise it stays plain text. The order link is unchanged.

## C7. Localization

New keys go in both `app_es.arb` and `app_en.arb`, prefixed `refunds…` for the list and `refund…` for the detail, dialogs and refusals. The Spanish copy is above. The English copy reads the same: "Refunds", "New refund", "Refund", "Confirm refund", "Cancel refund", "Cash from the drawer", "Credit note", and so on (FR-021).

## C8. Answers from the wireframes

These are from [wireframes.md](../wireframes.md), Open Questions 1–6, as assumed there. Change them here if any is overruled.

- **Compact detail lines:** below the compact breakpoint each line renders as a stacked block, local to `refund_detail_screen.dart`:
  - product;
  - price · Por devolver;
  - stepper · warehouse · total.
  It is built from `CompactField`s, not a new shared widget. Wider screens keep `DataTableView`.
- **A draft's folio and date:** the header reads "Borrador" and the list shows "—", because a draft has neither.
- **A completed refund's columns:** it shows only the lines the server returns, drops "Por devolver", and renames Devolver to "Devuelto".
- **Edit without confirm:** a one-line hint reads "Otra persona con permiso de confirmar debe terminar esta devolución." (key `refund_needs_confirmer_hint`).
- **The adjustment notice:** it is shown only right after the confirm call that caused it, and nothing about it is stored.
- **The compact list:** columns are Folio · Pedido (with a status dot) · Total, and "Nueva devolución" is labelled "Nueva".
- **The "Nueva devolución" button** sits in `CatalogFilterBar`'s trailing slot.
