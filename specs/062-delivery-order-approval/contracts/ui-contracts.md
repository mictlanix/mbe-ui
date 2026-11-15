# UI Contracts: Delivery Order Approval

**Feature**: [spec.md](../spec.md) | **Wireframes**: [wireframes.md](../wireframes.md) | **Research**: [research.md](../research.md)

Each contract is what a test can check. The keys named here are the ones tests find widgets by.

## C1. Navigation and route

- `NavBranch.deliveryOrderApproval = 27`. It is a new `StatefulShellBranch` appended last, at path `/sales/delivery-order-approval` (const `deliveryOrderApprovalPath`).
- `NavDestination(id: 'delivery-order-approval')` sits in the Logística group right after `delivery-orders`. Its gate is `PrivilegeGate(SystemObject.deliveryOrderApproval, AccessRight.read)` (FR-001).
- `_routeGate` gets a clause for `deliveryOrderApprovalPath` on 94 read. It goes before the `deliveryOrdersPath` clause, with a comment (R8).
- Without 94 read, the entry is hidden and the route redirects.

## C2. Queue screen: `DeliveryOrderApprovalScreen`

| Situation | Renders |
|---|---|
| `userFacilityIdProvider == null` | The no-facility notice (`delivery_order_approval_no_facility`). The controller isn't watched, so no request is made (FR-004). |
| Loading | A `CatalogListStateView` spinner. |
| Load error, not 403 | The `CatalogListStateView` error with retry, text from `localizeProblem`. |
| 403 | The not-allowed state, with no retry. |
| Empty page | `delivery_order_approval_empty`: "No hay órdenes de entrega pendientes de aprobación." There is no action button. |
| Rows | A `DataTableView<DeliveryOrderSummary>` with Folio, Cliente, Tipo, Programada, Destino, Pedidos and Prio. columns, and a `CatalogPagination` footer with the server total (FR-002, FR-003). |

- **No filter row.** There is no `CatalogFilterBar`, no search box and no filters button (FR-003).
- **Names.** Customer and ship-to names come from the spec 061 name cells (`delivery_order_name_cells.dart`), with the `#id` fallback.
- **Row actions,** only with `can(deliveryOrderApproval, update)`, through `buildCatalogRowActions`:
  - `primaryAction`: ✓, key `approve_delivery_order_<id>`, tooltip "Aprobar";
  - `extraActions`: ✕, key `reject_delivery_order_<id>`, tooltip "Rechazar".

  Without the right, the action column is absent (FR-005).
- **Row tap.**
  - With `can(deliveryOrders, read)`, a tap does `context.push('/sales/delivery-orders/<id>')`.
  - Otherwise `onRowTap` is null (FR-006).
- **Paging.** A page change does `context.go('/sales/delivery-order-approval?page=N')`.

## C3. Approve dialog: `showApproveDeliveryOrderDialog(context, ApprovalTarget)`

It returns `Future<DeliveryOrderStatus?>`: the new status on success, `null` when the user backs out or closes after a refusal.

- **Key** `delivery_order_approve_dialog`. The title is "¿Aprobar orden de entrega {folio}?".
- **Body.** Cliente (name with the `#id` fallback), Tipo, and Programada (`formattersProvider` date).
- **Next-status note**, depending on the type (FR-008):
  - delivery: "Pasará a En preparación y aparecerá para el almacén.";
  - pickup: "Pasará a Aprobada; después se marca lista para recoger.".
- **Buttons.** "Volver", and the filled "Aprobar" (key `delivery_order_approve_submit`).
- **Busy.** Both buttons are disabled and the dialog can't be dismissed.
- **Refusal.** The dialog stays open with `DeliveryOrderRefusal`:
  - `delivery_order.not_pending_approval` shows its own message (FR-015);
  - a `NetworkError` shows the unknown-result banner.

  The primary button becomes "Cerrar", which pops `null`.

## C4. Reject dialog: `showRejectDeliveryOrderDialog(context, ApprovalTarget)`

It returns `Future<DeliveryOrderStatus?>`, which is `draft` on success.

- **Key** `delivery_order_reject_dialog`. The title is "Rechazar orden de entrega {folio}". The summary line reads "{cliente} · Programada {fecha}".
- **Reason.** `delivery_order_reject_reason` is a multi-line `TextField` with `maxLength: 500` and a counter, and autofocus.
- **Note.** "La orden regresa a borrador para que su autor la corrija y la vuelva a confirmar. El motivo queda en la orden." (FR-011).
- **Submit.** `delivery_order_reject_submit` is disabled while `reason.trim().isEmpty` or while busy. The trimmed reason is sent.
- **Busy and refusal.** Same as C3. `delivery_order.reason_required` has its message, though the client prevents it.

## C5. Writes: `DeliveryOrderActions`

```text
approve(int id)                    → Future<({AppError? error, DeliveryOrderStatus? status})>
reject(int id, {required String reason}) → same
```

- **Accepted.** `status` is the response's status and `error` is null.
- **Refused or network failure.** `error` is set and `status` is null.
- **Invalidation,** for every write including spec 061's:
  - the order's detail controller, always;
  - `deliveryOrdersListControllerProvider` and `deliveryOrderApprovalQueueControllerProvider`, unless the server refused (a `NetworkError` still invalidates them) (R6).

## C6. Repository: `DeliveryOrderAdminRepository`

```text
approvalQueue({int skip = 0, int limit = 20}) → Future<DeliveryOrderPage>   // GET /delivery-orders/approval
approve(int id)                               → Future<DeliveryOrder>        // POST …/approval/{id}/approve
reject({required int id, required String reason}) → Future<DeliveryOrder>    // POST …/approval/{id}/reject {reason}
```

- **Facility.** `approvalQueue` sends no facility; the server scopes the queue (R1).
- **Errors.** They map through `toAppError` like every other method.

## C7. Detail screen: `DeliveryOrderDetailScreen` action area

The action area adds to spec 061 C4. For an order in `pendingApproval`:

- **Rechazar.** `delivery_order_reject`, outlined, needs 94 update.
- **Aprobar.** `delivery_order_approve`, filled, needs 94 update.
- **Order.** `[Cancelar orden] [Rechazar] [Aprobar]` (data-model §4).
- **Rights.** The 71-update check moves from the whole list to each spec 061 button, so a user with 94 update but without 71 update sees only Rechazar and Aprobar.
- **Success.** A SnackBar:
  - after approve, "Orden {folio} aprobada: {estado}", with the status name from l10n;
  - after reject, "Orden {folio} rechazada. Regresó a borrador con el motivo.".

  The order reloads through the invalidation in C5.
- **Other statuses.** Rechazar and Aprobar are never shown.

## C8. Queue feedback

- **Approve.** After a successful approve from a row, the same SnackBar as C7 is shown.
- **Reject.** After a successful reject, the SnackBar is "Orden {folio} rechazada. Regresó a borrador con el motivo.".
- **Reload.** The queue reloads through invalidation. A page left empty steps back one page.

## C9. Error catalog

- `delivery_order.not_pending_approval`: an `.arb` message in es and en, in the `localize_problem.dart` catalog set, and its `code-scope.tsv` row set to `IN` with both endpoints.
- `delivery_order.reason_required`: its row's endpoint list gains `POST /delivery-orders/approval/{}/reject`.
