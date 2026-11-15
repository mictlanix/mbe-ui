# Research: Delivery Order Approval

**Feature**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md) | **Date**: 2026-11-15

Spec 062 has no open clarification, so this file records the design decisions the plan rests on. It also resolves the five wireframe open questions.

## R1. Server surface and rights

**Decision.** Three generated operations are used, all already in `DeliveryOrdersApi`. No client regeneration is needed.

| Operation | Generated method | Right |
|---|---|---|
| `GET /delivery-orders/approval?skip&limit` | `listApprovalQueueApiV1DeliveryOrdersApprovalGet` | DeliveryOrderApproval (94) read |
| `POST /delivery-orders/approval/{id}/approve` | `approveDeliveryOrderApiV1DeliveryOrdersApprovalDeliveryOrderIdApprovePost` | 94 update |
| `POST /delivery-orders/approval/{id}/reject` body `{reason}` | `rejectDeliveryOrderApiV1DeliveryOrdersApprovalDeliveryOrderIdRejectPost` | 94 update |

`SystemObject.deliveryOrderApproval(94)` already exists in `lib/core/access/system_object.dart`.

- **The queue** returns `ListResponse[DeliveryOrderSummary]`, the same shape as `GET /delivery-orders`, so `DeliveryOrderSummary.fromResponse` maps it unchanged.
- **Approve and reject** return a `DeliveryOrderResponse`.

**Rationale.** The server filters the queue on `PENDING_APPROVAL` and on `current.facility_id` (`delivery_order_service.list_orders`, with no `facility` argument from the approval route). The facility scope is server-side, so the client needs no guard of its own. This is unlike `GET /delivery-orders` (spec 061 R3, mbe-api#314).

**Alternatives.**
- **`GET /delivery-orders?status=1`** (spec 061's list) would also give the pending orders. It's gated on 71, not 94, and it takes `facility` from the caller. Rejected: the approval route is the server's own definition of the queue (spec FR-021 in mbe-api 012).

## R2. Repository: extend `DeliveryOrderAdminRepository`

**Decision.** Add three methods to `DeliveryOrderAdminRepository` and its implementation:

- `approvalQueue({skip, limit}) → DeliveryOrderPage`
- `approve(id) → DeliveryOrder`
- `reject({id, reason}) → DeliveryOrder`

**Rationale.** These are the same generated API, the same entities and the same error mapping (`toAppError`) as the spec 061 methods. A second repository would duplicate the API provider wiring for three calls.

**Alternatives.**
- **A new `DeliveryOrderApprovalRepository`** keyed to the separate right. Rejected: rights are checked in presentation and on the server, not by repository boundaries (§IV), and spec 060 likewise added `listUnverified`/`verify`/`reject` to the existing `CustomerPaymentRepository`.

## R3. Queue controller and screen

**Decision.**
- **Controller.** A new `DeliveryOrderApprovalQueueController`, an `AsyncNotifier` family keyed by `pageIndex`. It is built on `fetchClampedPage`, as spec 060's `VerificationQueueController` is, so a page emptied by the last approval steps back one page (spec edge case "Last row on a page").
- **Page in the URL.** The page index lives in the URL (`?page=`) through `ListQuery`, like every list. There's no filter object, because the queue has no filters (FR-003).
- **No-facility guard.** When `userFacilityIdProvider` is null, the screen shows the no-facility notice and doesn't watch the controller (FR-004). This is the same branch `DeliveryOrdersListScreen` has (`delivery_orders_list_screen.dart:59`). Without it, the server would query `facility == NULL` and answer an empty page that looks like "nothing waiting".
- **403 handling.** A 403 shows the queue's "not allowed" state with no retry, copied from spec 060's `_isForbidden`.

**Rationale.** This is the smallest list that follows §VI: table and pagination, with no filter row, because nothing can be searched or filtered (wireframe Open Question 4).

## R4. Row tap pushes the detail screen, gated on 71 read

**Decision.**
- **With Delivery Orders (71) read,** `onRowTap` does `context.push('/sales/delivery-orders/$id')`.
- **Without it,** `onRowTap` is `null`, so `DataTableView` renders no tap affordance (FR-006, Clarification Q1).
- **Back.** Push, not go, so back returns to the queue (wireframe Open Question 2).

**Rationale.**
- The detail route is top-level and already gated by `_routeGate` on 71 read. Opening it without that right would redirect.
- Both actions return to the queue when they finish. The queue controller is invalidated by the write (R6), so the row is gone when the user comes back.

## R5. Approve and reject dialogs: shared, refusal shown inside

**Decision.** There are two new dialogs, `showApproveDeliveryOrderDialog` and `showRejectDeliveryOrderDialog`, in a new `approval_dialogs.dart`. Both take a small `ApprovalTarget` value (id, serial, customerId, type, date). The queue builds it from a `DeliveryOrderSummary` and the detail screen from a `DeliveryOrder` (data-model §1).

Each dialog runs its write and handles the outcome itself:

| Outcome | What the dialog does |
|---|---|
| Accepted | Closes and returns the new status: the approved order's status, or `draft` for a rejection. |
| Refused | Stays open with the refusal in `DeliveryOrderRefusal` (the spec 061 widget: `ErrorBanner` from `localizeProblem`, or the unknown-result `FormErrorBanner` for a `NetworkError`). The primary button becomes "Cerrar". |
| Backed out | Returns `null`. |

**Rationale.**
- **Why the refusal stays in the dialog.** The queue has no action area to show a refusal in, and the wireframe draws it inside the dialog. Spec 060's verify and reject dialogs do the same. On the detail screen this differs from spec 061's cancel, which closes and shows the refusal above the actions. One shared dialog keeps both callers identical, and the reload behind it (R6) updates whichever screen opened it.
- **Why the status comes back.** FR-009 asks for the status the server returned, not the predicted one.

**Alternatives.**
- **Close and return the error**, as in spec 061. Rejected: the queue would need a SnackBar for refusals, which the wireframe doesn't draw, and two error surfaces for one dialog.
- **Taking a `DeliveryOrderSummary`** only. Rejected: the detail screen holds a `DeliveryOrder`, which isn't a subtype.

## R6. Writes go through `DeliveryOrderActions`, which also invalidates the queue

**Decision.** Add `approve(id)` and `reject(id, reason:)` to the existing keep-alive `DeliveryOrderActions`.

- **Return value.** Both return `({AppError? error, DeliveryOrderStatus? status})`. The status comes from the write's response, and is used only for the success message.
- **Invalidation.** `_run` invalidates `deliveryOrderApprovalQueueControllerProvider` alongside the order and the list, with the same rule: always the order, and the lists unless the server refused. Spec 061's existing actions also invalidate the queue. Cancelling a pending order in spec 061 removes it from the queue too (spec edge case "Order cancelled while waiting").
- **Existing callers.** `_run` keeps its `AppError?` return for them. The two new methods wrap it to also carry the status.

**Rationale.** A single write path means a single invalidation rule. The detail screen still refetches from the server and never takes the order from the write response (spec 061 R6).

## R7. Detail screen action area

**Decision.** In `_actionButtons`, when the order is `pendingApproval` and `can(deliveryOrderApproval, update)`, add outlined "Rechazar" after "Cancelar orden" and filled "Aprobar" last.

- **Order.** The order is Cancelar · Rechazar · Aprobar (wireframe Open Question 3: show both, rely on dialog notes).
- **Rights.** Today the method returns `[]` without 71 update. That early return becomes per-button, so an approver without 71 update still sees Rechazar and Aprobar.
- **Success message.** A SnackBar names the new status.

**Rationale.** FR-013 and the wireframe. Hiding "Cancelar orden" while pending would remove a spec 061 action (FR-018 there).

## R8. Navigation and route

**Decision.**
- **Route** `/sales/delivery-order-approval` (wireframe Open Question 1). It's a new `StatefulShellBranch` appended last, at `NavBranch.deliveryOrderApproval = 27`.
- **Nav entry.** A `NavDestination` in the Logística group after Órdenes de entrega, with the `Icons.fact_check_outlined`/`fact_check` pair.
- **Route gate.** A `_routeGate` clause on 94 read.

**Rationale.**
- `'/sales/delivery-order-approval'.startsWith('/sales/delivery-orders')` is false, so the existing 71 clause doesn't capture it. The new clause is still placed before the 71 clause and commented, as spec 060 did for `/sales/payments`, so correctness never depends on how the prefixes compare.
- `/sales/delivery-orders/approval` would sit under the `:deliveryOrderId` route and the 71 gate. Rejected.

## R9. Errors

**Decision.**
- **`delivery_order.not_pending_approval` (409)** gets a message in both `.arb` files ("Esta orden ya no está pendiente de aprobación." / "This order is no longer pending approval."). It joins `localize_problem.dart`'s catalog set, and its `code-scope.tsv` row flips to `IN` with both endpoints.
- **`delivery_order.reason_required`** is already `IN`. Its row gains the reject endpoint.
- **`state.transition_invalid`** is already `IN`. It is reachable from approve and reject only on a race, because the service checks `PENDING_APPROVAL` before calling the transition helper. Its row's endpoint list gains both approval endpoints.
- **Every code the two writes can return:**
  - `delivery_order.not_pending_approval` (new);
  - `delivery_order.reason_required` (existing; the client prevents it);
  - `state.transition_invalid` (existing; race only);
  - `resource.not_found` (404, generic, existing), which covers both an unknown id and another facility's order the user may not see (R12);
  - `auth.forbidden` (403) and `auth.not_authenticated` (401), generic and existing.
- **Queue read:** only the generic `auth.forbidden` and `auth.not_authenticated`.

**Rationale.** §III v1.15.0, API error text from codes. `catalog_coverage_test.dart` enforces the TSV.

## R10. Strings

**Decision.** All new strings use a `deliveryOrderApproval…` key prefix in both `.arb` files:

- the nav label;
- the screen title;
- the empty state and no-facility text (reusing the spec 061 no-facility strings if their wording fits; otherwise new);
- the row tooltips;
- both dialogs (title, facts, type-dependent next-status note, reason label, note);
- the three SnackBars;
- the error message.

Status names come from the existing `DeliveryOrderStatus` l10n mapping, never from `enum.name`.

## R11. Testing

**Decision.**

- **Unit.**
  - `delivery_order_admin_repository_impl_test`: the 3 new methods, the query parameters sent, and the reason body.
  - `delivery_order_approval_queue_controller_test`: paging and clamping.
  - `delivery_order_actions_test`: approve/reject return status and error, and the invalidation set includes the queue.
  - `catalog_coverage_test` and `problem_fixtures`: the new code.
- **Widget.**
  - `delivery_order_approval_screen_test`: populated, read-only (no action column), no 71 read (rows not tappable), empty, no facility, 403, and a row tap pushing the detail.
  - `approval_dialogs_test`: confirm text per type, blank reason disabled, 500 cap, refusal stays in the dialog, network unknown.
  - `delivery_order_detail_screen_test`: Rechazar/Aprobar matrix by status × 94 update × 71 update.
- **Live.** `integration_test/delivery_order_approval_quickstart_test.dart`.
  - **Read-only part:** queue loads at the user's facility.
  - **`MBE_WRITE` part:** confirm two drafts (needs approval-required config, else skip with a message), approve one, reject one, check statuses.
  - Uses the dev tenant. If the tenant doesn't require approval, the write part skips. See quickstart prerequisites.

## R12. Facility checks on approve and reject

mbe-api#314 is closed (PR #321, 169803a). Approve and reject now load the order through `_visible_order_or_404`. Another facility's order answers 404 unless the user may see every facility (SearchCreditsFromAllStores 101 or DeliveryItineraries 87).

The queue itself is still scoped to `current.facility_id`, so the UI never offers another facility's order from the queue. From the detail screen, an approver who can see every facility can act on any facility's pending order. That is the server's rule, and the UI mirrors it by offering the actions on whatever detail screen the server let the user open. A 404 on a write shows the generic not-found message, and the order reloads. No upstream issue is needed.
