# Data Model: Delivery Order Approval

**Feature**: [spec.md](./spec.md) | **Research**: [research.md](./research.md)

No new server data and no new persisted client state. The feature reuses spec 061's entities (`lib/features/sales/domain/entities/delivery_order.dart`) and adds one small value type for the dialogs.

## 1. `ApprovalTarget` (new, presentation)

What the approve and reject dialogs need to name an order. The queue and the detail screen build it from different entities (research R5).

| Field | Type | From `DeliveryOrderSummary` | From `DeliveryOrder` |
|---|---|---|---|
| `id` | `int` | `id` | `id` |
| `serial` | `int?` | `serial` | `serial` |
| `customerId` | `int` | `customerId` | `customerId` |
| `type` | `FulfillmentType` | `type` | `type` |
| `date` | `DateTime?` | `date` | `date` |

The type is a plain Dart record, or a small immutable class with two named constructors, `ApprovalTarget.fromSummary` and `ApprovalTarget.fromOrder`. It needs no freezed and no serialization. A pending order always has a serial, because it was confirmed. `serial` stays nullable only because the source types are.

## 2. Reused entities (spec 061)

- **`DeliveryOrderSummary`.** A queue row. Its fields are id, facilityId, serial, customerId, salesOrderIds, shipToId, date, priority, status, type and parentId. The queue shows folio, customer, type, date, ship-to, sales orders and priority (FR-002).
- **`DeliveryOrderPage`** holds `{items, total}`. `approvalQueue` returns it.
- **`DeliveryOrder`.** The detail screen's order. Its `rejectionReason` is already shown by the spec 061 rejection banner.
- **`DeliveryOrderEvent`** is a history line. A rejection appears as `pendingApproval → draft` with the reason and the rejecting employee, which spec 061 already renders.

## 3. Status transitions this feature drives

Both transitions are server-side. The client never computes them, and it shows the status the server returns (FR-009).

| From | Action | Type | To | Recorded |
|---|---|---|---|---|
| `pendingApproval` (1) | approve | delivery | `inPreparation` (5) | one event, approving employee |
| `pendingApproval` (1) | approve | counter pickup | `approved` (2) | one event, approving employee |
| `pendingApproval` (1) | reject + reason | either | `draft` (0) | one event with reason, rejecting employee; `rejection_reason` set on the order |

Any other starting status is refused with `delivery_order.not_pending_approval` (409).

## 4. Action matrix on the detail screen (adds to spec 061 data-model §3)

Rows are the user's rights. Columns are what the action area shows on an order in `pendingApproval`.

| 71 update | 94 update | Cancelar orden | Rechazar | Aprobar |
|---|---|---|---|---|
| ✓ | ✓ | ✓ | ✓ | ✓ |
| ✓ | ✗ | ✓ | — | — |
| ✗ | ✓ | — | ✓ | ✓ |
| ✗ | ✗ | — | — | — |

In every other status, Rechazar and Aprobar are absent. Spec 061's actions are unchanged.

## 5. Validation

- **Reject reason.** Trimmed, it must not be empty, and it can be at most 500 characters. The 500 limit is the server's `rejection_reason` column (`String(500)`), and the server strips the reason before storing it. The client sends the trimmed text.
- **Queue page.** `skip = pageIndex × 20`, `limit = 20`. A page emptied by an action clamps back (`fetchClampedPage`).

## 6. Queue URL state

`/sales/delivery-order-approval?page=N`. Only the page index, parsed through `ListQuery`. There is no filter object, so nothing else is encoded.
