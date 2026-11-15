# Feature Specification: Delivery Order Approval

**Feature Branch**: `062-delivery-order-approval`

**Created**: 2026-11-15

**Status**: Draft

**Input**: User description: mictlanix/mbe-roadmap#39 ([UI] Delivery order approval). Scope 06 §6.2 (legacy Delivery Order Approval, mbe-api `docs/specs/06-logistics.md` §2 and `06a-delivery-flow-v2.md`; SystemObject DeliveryOrderApproval 94). Server side done in mbe-api spec 012, User Story 2. Weight: 3 legacy actions. Builds on spec 061 (Órdenes de entrega). Precedent for the queue shape: spec 060 (Verificación de pagos).

Some businesses want a supervisor to review every delivery before the warehouse prepares it. When the server is set to require approval, confirming a delivery order (spec 061) leaves it in Pendiente de aprobación. Nothing in the new app can move it on, so it never reaches the warehouse.

In the current system, a supervisor opens "Aprobación de órdenes de entrega", reviews each order and approves or rejects it. This feature brings that queue to the back office. It lists the orders awaiting approval at the supervisor's facility. The supervisor opens one to review it, then approves it or sends it back to its author with a reason. The same two actions are on the order's detail screen.

## Clarifications

### Session 2026-11-15

- Q: Tapping a row opens the spec 061 detail screen, which needs Delivery Orders read. What about an approver with Delivery Order Approval but without Delivery Orders read? → A: Their rows aren't tappable. Queue rights mirror the server exactly; such an approver decides from the row and its icons. No read-only panel is added, so constitution §VI's single record surface holds.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Approve delivery orders waiting for review (Priority: P1)

A supervisor opens "Aprobación de entregas". The queue lists every order at their facility that's waiting for approval. Each row shows folio, customer, type (Entrega or Recoge en tienda), scheduled date, ship-to, the sales orders it fulfills, and priority. The supervisor opens order 1532, checks the address and the lines, and taps "Aprobar". A delivery moves to En preparación and shows up for the warehouse. A pickup order moves to Aprobada. The order leaves the queue.

**Why this priority**: When approval is required, this is the only way a confirmed order reaches the warehouse. Without it, every delivery stops at Pendiente de aprobación.

**Independent Test**: With approval required on the server, confirm one delivery and one pickup order at the user's facility. Open the queue as a user with Delivery Order Approval read and update. Approve both. Check that the delivery is En preparación, the pickup is Aprobada, both left the queue, and each history shows the move and the approver.

**Acceptance Scenarios**:

1. **Given** a user with Delivery Order Approval read, **When** they open the back-office navigation, **Then** "Aprobación de entregas" is offered in the Logística group. Without that right it isn't.
2. **Given** the queue opens, **When** it loads, **Then** it lists only orders in Pendiente de aprobación at the user's facility, paginated, with the total in the pagination footer. Each row shows folio, customer, type, scheduled date, ship-to, the sales orders it fulfills, and priority.
3. **Given** a user with Delivery Order Approval update, **When** they tap "Aprobar" on a row, **Then** a confirmation names the folio, customer, type and scheduled date, and says where the order goes next (En preparación for a delivery, Aprobada for a pickup).
4. **Given** the user confirms, **When** the server accepts, **Then** the row leaves the queue, the total falls by one, and a message gives the order's new status.
5. **Given** a user with only Delivery Order Approval read, **When** they open the queue, **Then** they see the list but no "Aprobar" or "Rechazar" actions.

---

### User Story 2 - Reject an order back to its author (Priority: P1)

The supervisor opens an order and sees the ship-to is the customer's old warehouse. They tap "Rechazar" and type "Dirección equivocada, el cliente se mudó a la bodega de Tlaquepaque". The order goes back to Borrador and leaves the queue. Its author finds it among the drafts in Órdenes de entrega. Its detail screen shows the rejection reason, and its history shows who rejected it and why. The author fixes the address and confirms it again, and it comes back to the queue.

**Why this priority**: Approval without rejection is a rubber stamp. The server's rule is that a rejected order goes back to draft with a reason and never sits in limbo, so the two ship together.

**Independent Test**: Reject an order from the queue with a reason. Check that it left the queue, that it's Borrador in Órdenes de entrega, that its detail screen shows the reason, and that its history shows Pendiente de aprobación → Borrador with the reason and the rejecting user. Confirm it again and check it's back in the queue.

**Acceptance Scenarios**:

1. **Given** a user with Delivery Order Approval update, **When** they tap "Rechazar" on a row, **Then** a dialog names the folio, customer and scheduled date, asks for a reason, and says the order goes back to its author as a draft.
2. **Given** the reject dialog, **When** the reason is empty or only spaces, **Then** the confirm action is disabled. The reason can't exceed 500 characters.
3. **Given** a reason, **When** the user confirms and the server accepts, **Then** the row leaves the queue, the total falls by one, and a message says the order went back to draft.
4. **Given** a rejected order, **When** anyone with Delivery Orders read opens it, **Then** its detail screen shows the rejection reason (spec 061, FR-007) and its history shows the rejection with the reason and the rejecting user (spec 061, FR-009).

---

### User Story 3 - Review the order before deciding (Priority: P1)

Before approving, the supervisor wants to see what's actually going out. They tap a row and the order's detail screen opens (spec 061): header, lines with quantities, and history. "Aprobar" and "Rechazar" are offered right there. After either one, the screen shows the order's new status and history, and returning to the queue shows the order gone.

**Why this priority**: The legacy screen's "View Detail" action. A supervisor can't judge an order from a row alone, since the row has no lines.

**Independent Test**: Open an order from the queue as a user with Delivery Order Approval update and Delivery Orders read. Check that the detail screen offers both actions, approve from there, check the new status and history, and go back to find the queue without that order.

**Acceptance Scenarios**:

1. **Given** a queue row and a user with Delivery Orders read, **When** the user taps it (outside its icons), **Then** the order's detail screen from spec 061 opens. Without Delivery Orders read, rows don't open; the approver decides from the row and its icons.
2. **Given** an order in Pendiente de aprobación open on the detail screen and a user with Delivery Order Approval update, **When** the screen loads, **Then** it offers "Aprobar" and "Rechazar", using the same dialogs as the queue. This holds however the user got to the screen (from the queue or from Órdenes de entrega).
3. **Given** an order in any other status, or a user without Delivery Order Approval update, **When** the detail screen loads, **Then** neither action is offered.
4. **Given** the user approves or rejects from the detail screen, **When** it succeeds, **Then** the screen shows the new status and history, and the queue and the Órdenes de entrega list reflect the change when the user returns to them.
5. **Given** the detail screen opened from the queue, **Then** the draft-editing and other status actions follow spec 061's rules unchanged. The approver doesn't gain edit rights from this feature.

---

### Edge Cases

- **Approval not required.** When the server is set not to require approval, confirmed orders skip the queue, so it's always empty. The app can't read that setting. The empty queue just says there are no orders waiting for approval.
- **Already decided by someone else.** Two supervisors work the same queue. The second to approve or reject is refused because the order is no longer waiting. The app says the order isn't pending approval anymore and removes the row (or reloads the detail screen).
- **Order cancelled while waiting.** Spec 061 allows cancelling an order in Pendiente de aprobación. It leaves the queue. Acting on a stale row is refused the same way.
- **User without a facility.** The queue shows only the user's facility. A user with no facility assigned sees a notice that the queue needs a facility, as Pedidos does, instead of an empty list.
- **Another facility's orders.** The server offers no facility choice for the queue. An approver sees only their own facility's orders, and must switch facility to review another's.
- **Rejected, then confirmed again.** The order comes back to the queue as a fresh request. Confirming clears the stored rejection reason, so the detail screen's rejection banner is gone by then. The earlier rejection stays in the order's history, with its reason and who rejected it, so the approver can still see why it was sent back before.
- **Names the user can't read.** Customer, ship-to and facility arrive as numbers. When the user lacks the right to read one of those catalogs, the row shows the number instead of the name, as in spec 061.
- **Network failure on approve or reject.** The app says the result is unknown and reloads the row or the detail screen, rather than claiming it failed.
- **Last row on a page.** After the last row on a page is approved or rejected, the queue loads the previous page instead of showing an empty one.

## Requirements *(mandatory)*

### Functional Requirements

**Queue**

- **FR-001**: The back office MUST offer an "Aprobación de entregas" screen in the Logística group only to users with Delivery Order Approval read.
- **FR-002**: The queue MUST list the delivery orders in Pendiente de aprobación at the user's facility, in the order the server returns them, paginated. Each row shows folio, customer name, type, scheduled date, ship-to, the sales orders it fulfills, and priority. Names fall back to numbers as in spec 061 (FR-025).
- **FR-003**: The queue MUST show the total count of waiting orders in the table's pagination footer. It has no filters and no search box, since the server offers none for this list.
- **FR-004**: When the user has no facility assigned, the queue MUST show a notice saying a facility is needed instead of loading.
- **FR-005**: Each row MUST offer two direct icons to users with Delivery Order Approval update: ✓ Aprobar (primary) and ✕ Rechazar.
- **FR-006**: For users with Delivery Orders read, tapping a row (outside its icons) MUST open the order's detail screen from spec 061. For users without it, rows MUST NOT be tappable; the row icons still work.

**Approve**

- **FR-007**: "Aprobar" MUST be offered only to users with Delivery Order Approval update, and only on orders in Pendiente de aprobación.
- **FR-008**: Approving MUST ask for confirmation. The confirmation names the folio, customer, type and scheduled date, and says the next status: En preparación for a delivery, Aprobada for a pickup.
- **FR-009**: After an approval, the order MUST leave the queue, and the app MUST show the status the server returned.

**Reject**

- **FR-010**: "Rechazar" MUST be offered only to users with Delivery Order Approval update, and only on orders in Pendiente de aprobación.
- **FR-011**: Rejecting MUST require a reason that isn't empty or only whitespace, up to 500 characters. The dialog names the folio, customer and scheduled date and says the order goes back to its author as a draft.
- **FR-012**: After a rejection, the order MUST leave the queue, and the app MUST say it went back to draft.

**Detail screen**

- **FR-013**: The spec 061 detail screen MUST offer "Aprobar" and "Rechazar" on an order in Pendiente de aprobación to users with Delivery Order Approval update, using the same dialogs as the queue, whether it was opened from the queue or from Órdenes de entrega.
- **FR-014**: After an approval or rejection on the detail screen, it MUST show the order's new status and history. The queue and the Órdenes de entrega list MUST reflect the change when the user returns to them.

**General**

- **FR-015**: When the server refuses an approval or rejection, the app MUST show the reason in the user's language, from the error code, and reload the affected order. An order that's no longer pending approval is reported as such.
- **FR-016**: Every new label, message and error MUST be available in Spanish and English.

### Key Entities

- **Delivery order**: a destination for some of a customer's purchased goods (spec 061). Has a folio, facility, customer, type (delivery or pickup), scheduled date, ship-to, priority, status, lines, history, and the last rejection reason.
- **Approval**: moves an order out of Pendiente de aprobación in a single recorded step: to En preparación for a delivery, or to Aprobada for a pickup. Recorded in the order's history against the approving employee.
- **Rejection**: moves an order from Pendiente de aprobación back to Borrador. The reason is stored on the order and in its history, against the rejecting employee. The order becomes editable again and must be confirmed again to return to the queue.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A supervisor can open an order from the queue, review it and approve it in under 30 seconds.
- **SC-002**: A supervisor can clear a queue of 20 orders without leaving the screen.
- **SC-003**: In every walkthrough case, an approved delivery ends in En preparación and an approved pickup in Aprobada, and both leave the queue.
- **SC-004**: No rejection can be confirmed without a reason, and every rejected order shows its reason on its detail screen.
- **SC-005**: Users without Delivery Order Approval read don't see the queue. Users without Delivery Order Approval update don't see approve or reject anywhere.

## Assumptions

- The rights follow the server. Listing the queue needs Delivery Order Approval (94) read. Approving and rejecting need Delivery Order Approval update. Opening the detail screen needs Delivery Orders (71) read, as in spec 061.
- This feature amends spec 061's SC-006 and FR-011 for two actions. "Rechazar" and "Aprobar" on the detail screen are status actions that need Delivery Order Approval update, not Delivery Orders update. A user without Delivery Orders update can see them, and spec 061's own actions still need that right.
- The queue is limited to the user's facility because the server lists it that way and offers no facility parameter. A facility filter is out of scope.
- Legacy excluded counter pickups from approval. The new server sends pickups through approval too when it's required (06a, decision D3), so the queue shows them.
- The author learns of a rejection by finding the order among the drafts in Órdenes de entrega and reading its reason on the detail screen. No notification is sent, by server design. A "mis órdenes" filter on Órdenes de entrega is out of scope.
- Approving doesn't re-check the minimum notice for the scheduled date. The server checked it at confirmation.
- Out of scope: approving or rejecting several orders in one action, notifications, editing an order from the queue beyond what spec 061 already allows, printing, and a filter or search on the queue.

## Verbatim Constraints

- Server rules relied on: `GET /delivery-orders/approval` (`skip`, `limit`; scoped to the caller's facility), `POST /delivery-orders/approval/{id}/approve`, `POST /delivery-orders/approval/{id}/reject` (body carries `reason`, not blank; stored up to 500 characters).
- Error codes: `delivery_order.not_pending_approval`, `delivery_order.reason_required`.
