# Feature Specification: Delivery Orders

**Feature Branch**: `061-delivery-orders`

**Created**: 2026-11-14

**Status**: Draft

**Input**: User description: mictlanix/mbe-roadmap#38 ([UI] Delivery orders: list, detail, confirm, cancel, requeue, events). Scope 06 §6.1 and 06a (mbe-api `docs/specs/06-logistics.md`, `06a-delivery-flow-v2.md`; SystemObject DeliveryOrders 71). Server side done in mbe-api specs 012 and 013. The POS delivery step only creates destinations (ui spec 026). Weight: 10 legacy actions. Before specify, the user chose:

- edit a DRAFT's header and lines in the back office, but don't create orders there;
- include the two pickup actions (ready for pickup, and picked up with proof of delivery);
- offer cancel wherever the server allows it, and file the cancel-on-itinerary bug upstream (filed as mbe-api#311);
- open the list on active orders. Planning found the server can't list several statuses at once, so the list opens on every status until mbe-api#312 ships (FR-003). **Shipped 2026-11-14** (mbe-api PR #315): the list opens on "Activas"; "Todas" is `status=all` (fix/consume-mbe-api-308-314).

When a customer's purchase has to be delivered, or picked up later, the cashier sets up its destinations in the POS "Entrega" step. Each destination becomes a delivery order. Today these orders stay in draft forever. Nothing in the new app confirms them, so they never get a folio and never reach the warehouse queue. Nobody can see an order's history, cancel one, or put a failed delivery back in the queue.

In the current system, logistics staff use "Órdenes de entrega" to find orders, fix details, confirm them and cancel them. This feature brings that screen to the back office:

- a list of the facility's delivery orders;
- a detail screen where a draft can be corrected and confirmed;
- the status actions the server allows (cancel, requeue a failed delivery, mark a pickup order ready, record its pickup);
- the order's status history.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Find delivery orders and see where each stands (Priority: P1)

A logistics clerk opens "Órdenes de entrega". The list shows every active order at their facility, newest first. Active means drafts waiting for confirmation, orders waiting for approval or preparation, pickup orders, and failed deliveries. Each row shows:

- folio (or "Borrador" for an unconfirmed draft);
- customer;
- type (Entrega or Recoge en tienda);
- scheduled date;
- ship-to;
- the sales orders it fulfills;
- status.

The clerk types folio 1532 and finds the order. They open it and see its header, its lines with ordered, committed, delivered, returned and open quantities, and its history.

**Why this priority**: Everything else starts from finding an order. On its own, this already shows which POS drafts are waiting for confirmation and which deliveries failed.

**Independent Test**: Seed orders in several statuses at the user's facility and one at another facility. Open the list as a user with Delivery Orders read. Check that it opens on every status at the user's facility, newest first, that the filters narrow it, and that opening a row shows its header, lines and history.

**Acceptance Scenarios**:

1. **Given** a user with Delivery Orders read, **When** they open the back-office navigation, **Then** "Órdenes de entrega" is offered. Without that right it isn't.
2. **Given** the list opens, **When** it loads, **Then** it shows orders at the user's facility in every status, newest first, paginated. Once mbe-api#312 ships, it opens on active orders instead: every non-terminal status (Borrador, Pendiente de aprobación, Aprobada, Lista para recoger, En preparación, En tránsito, Fallida). **Shipped 2026-11-14** (mbe-api PR #315): the list opens on "Activas"; "Todas" is `status=all` (fix/consume-mbe-api-308-314).
3. **Given** the list, **When** the user filters by status (any single status or "Todas", plus "Activas" once mbe-api#312 ships), type, scheduled date range, customer, sales order or facility, **Then** only matching orders are shown. Clearing the filters returns to the opening state at the user's facility. **Shipped 2026-11-14** (mbe-api PR #315): the list opens on "Activas"; "Todas" is `status=all` (fix/consume-mbe-api-308-314).
4. **Given** the search box, **When** the user types a number, **Then** the list shows the order with that folio. The box doesn't search sales-order numbers; the sales-order filter does that.
5. **Given** a row, **When** the user clicks it, **Then** the order's detail screen opens. It shows folio, status, type, customer, facility, scheduled date, priority, ship-to, contact, comment, the sales orders it fulfills, its parent order (when it came from a partial delivery), the last rejection reason (when there is one), and its lines.
6. **Given** the detail screen, **Then** each line shows product code, product name, dispatch warehouse, the sales order it comes from, and its ordered, committed, delivered, returned and open quantities.

---

### User Story 2 - Confirm a draft from the POS (Priority: P1)

A cashier set up a delivery in the POS this morning, so a draft is waiting. The logistics clerk opens it and checks the ship-to and date, then taps "Confirmar". The order gets its folio. Its status becomes En preparación (a delivery), Aprobada (a pickup), or Pendiente de aprobación when the business requires approval. The detail screen shows the new folio and status, and the history gains a line.

**Why this priority**: Without confirmation, no delivery order created in the new app ever reaches the warehouse. This is the gap that blocks deliveries going live.

**Independent Test**: Create a draft with one line through the POS. Open it in the back office as a user with Delivery Orders update, confirm it, and check that it now has a folio, a post-confirmation status and a history entry.

**Acceptance Scenarios**:

1. **Given** a draft with at least one line and a user with Delivery Orders update, **When** they open it, **Then** "Confirmar" is offered.
2. **Given** they tap "Confirmar", **When** asked, **Then** a confirmation names the customer, scheduled date and number of lines, and says the order can no longer be edited once confirmed.
3. **Given** the server accepts, **Then** the screen shows the assigned folio and the status the server chose. The app doesn't guess the status in advance.
4. **Given** the scheduled date is too soon for the business's minimum notice, **When** the server refuses, **Then** the app says so and shows the earliest date allowed. The order stays a draft.
5. **Given** a draft with no lines, **Then** "Confirmar" is disabled and the screen explains that the order needs at least one line.

---

### User Story 3 - Correct a draft before confirming (Priority: P2)

The clerk notices the POS draft has the wrong contact and that the customer asked for delivery on Thursday. On the detail screen they edit the header: date, priority, ship-to, contact and comment. They lower one line's quantity from 10 to 6 and remove a line the customer will pick up instead. They add a line from another of the same customer's sales, so both purchases go on one trip. Then they confirm.

**Why this priority**: Legacy did all of this from the same screen. Without it, every mistake in a draft sends the clerk back to the POS. Confirming is still possible without it, so it comes after confirm.

**Independent Test**: Open a draft as a user with Delivery Orders update. Change each header field, change a line's quantity, remove a line, and add a line from another sale of the same customer. Reload and check that every change stuck.

**Acceptance Scenarios**:

1. **Given** a draft and a user with Delivery Orders update, **When** they edit the header, **Then** they can change scheduled date, priority (a whole number, 0 or more), ship-to (from the customer's addresses; a pickup keeps its store's address), contact (from the customer's contacts) and comment.
2. **Given** a draft, **When** the user changes a line's quantity, **Then** it must be greater than 0 and no more than what that sales line still has left to deliver. A larger quantity is refused with how much is left.
3. **Given** a draft, **When** the user removes a line, **Then** it's removed after confirmation, and its quantity becomes available to deliver again.
4. **Given** a draft, **When** the user adds a line, **Then** they choose from lines on the same customer's completed sales that still have quantity left to deliver, and set a quantity within what's left. A line already on the order can't be added twice.
5. **Given** an order that isn't a draft, or a user without Delivery Orders update, **Then** header and lines are read-only.

---

### User Story 4 - Cancel an order (Priority: P2)

A customer calls to cancel a delivery that's waiting in preparation. The clerk opens it, taps "Cancelar" and types "Cliente canceló la entrega por teléfono". The order becomes Cancelada, its history records the reason and who cancelled it, and the sale's quantities can go on a new delivery.

**Why this priority**: Legacy had cancel, and orders that will never ship have to leave the queue. It comes after confirm and edit because a draft can also just be left alone.

**Independent Test**: Cancel an order in En preparación with a reason, as a user with Delivery Orders update. Check that it's Cancelada, that the history shows the reason and the user, and that it leaves the active list.

**Acceptance Scenarios**:

1. **Given** an order in Borrador, Pendiente de aprobación, Aprobada, Lista para recoger, En preparación or Fallida and a user with Delivery Orders update, **Then** "Cancelar" is offered. In any other status it isn't.
2. **Given** the cancel dialog, **When** the reason is empty or only spaces, **Then** the confirm action is disabled.
3. **Given** the server accepts, **Then** the order shows Cancelada, and the history shows the reason, who cancelled it and when.
4. **Given** the order moved on in the meantime (for example, its truck left), **When** the server refuses, **Then** the app says the order can no longer be cancelled from its current status and reloads it.

---

### User Story 5 - See an order's history (Priority: P2)

A supervisor wants to know why an order failed and who put it back in the queue. On the detail screen they open the history. It lists every status change, oldest first, each with date and time, from and to status, who made it, and the reason when one was given (cancellation, approval rejection).

**Why this priority**: Legacy had no history. It's what answers "what happened to this order" without asking around. It's read-only and fits naturally on the detail screen.

**Independent Test**: Take an order through create, confirm, cancel. Check that the history shows three entries in order, with the right statuses, the right employee, and the cancellation reason.

**Acceptance Scenarios**:

1. **Given** an order's detail screen, **Then** its history lists each status change oldest first, with date and time, previous status (none for creation), new status, employee name and reason.
2. **Given** an approval rejection, **Then** it appears as Pendiente de aprobación → Borrador with the rejection reason.
3. **Given** an action on the screen (confirm, cancel, requeue, ready, pickup), **When** it succeeds, **Then** the history shows the new entry without the user reloading.

---

### User Story 6 - Requeue a failed delivery (Priority: P3)

The driver couldn't deliver yesterday: nobody was home. The goods are back in the warehouse and the order is Fallida. The customer reschedules. The clerk opens the order, adjusts nothing, and taps "Reprogramar". The order goes back to En preparación and its quantities are open again, so the dispatcher can put it on a new trip.

**Why this priority**: Failed deliveries are expected to be rare. They can't be retried without this, but the cost of a missing requeue is lower than missing confirm or cancel.

**Independent Test**: Take an order to Fallida through an itinerary stop. Requeue it as a user with Delivery Orders update. Check that it's En preparación, that its returned quantities are back in open quantity, and that the history shows the move.

**Acceptance Scenarios**:

1. **Given** an order in Fallida and a user with Delivery Orders update, **Then** "Reprogramar" is offered. In any other status it isn't.
2. **Given** they confirm, **When** the server accepts, **Then** the order shows En preparación, and its lines show returned quantity back at 0 and open quantity restored.

---

### User Story 7 - Hand over a pickup order (Priority: P3)

A customer bought cement for pickup at the counter. Their pickup order is Aprobada. The warehouse sets the goods aside and the clerk marks the order "Lista para recoger". When the customer arrives, the clerk opens the order and taps "Entregar al cliente". They enter the receiver's name, note the ID they showed ("INE 0123456789"), and attach a photo. The order becomes Recogida.

**Why this priority**: Without it, a confirmed pickup order never leaves Aprobada, because no other screen moves it. It ranks last because pickup orders are a smaller share and the counter can hand goods over before the record catches up.

**Independent Test**: Confirm a pickup order. As a user with Delivery Orders update, mark it ready, then record its pickup with receiver name, the ID shown and a photo. Check that it reaches Recogida and that the detail screen shows the proof of delivery.

**Acceptance Scenarios**:

1. **Given** a pickup order in Aprobada and a user with Delivery Orders update, **Then** "Lista para recoger" is offered. It isn't offered on delivery orders.
2. **Given** a pickup order in Lista para recoger, **Then** "Entregar al cliente" is offered. Its dialog asks for the receiver's name, the identification they showed (free text, such as the ID type and number), and a photo, and can't be confirmed until all three are given.
3. **Given** the server accepts, **Then** the order shows Recogida, and the detail screen shows the proof: receiver name, the identification shown, the photo, and when it was recorded.
4. **Given** an order with proof of delivery (a pickup, or a stop closed on an itinerary), **Then** the detail screen shows the same proof read-only.

---

### Edge Cases

- **Confirm lands in approval.** Whether a confirmed order needs approval is a server setting the app can't read. The app shows whatever status the server returns. Approving and rejecting belong to a separate screen (roadmap #39).
- **Rejected and back to draft.** An approver rejected the order. It's a draft again, editable, with the rejection reason shown on the detail screen until it's confirmed again.
- **Cancelling an order that's on an open trip.** The server allows cancelling an order in En preparación even when it's already a stop on an open itinerary, and today that blocks that trip's departure (mbe-api#311). The app offers cancel wherever the server allows it, and relies on the server fix. **Fixed 2026-11-14** (mbe-api PR #320): the server refuses that cancel with `delivery_order.on_itinerary`, shown as a localized refusal (fix/consume-mbe-api-308-314).
- **Edited or confirmed elsewhere.** Someone else changed the order's status since the screen loaded. The server refuses the stale action. The app says the order changed and reloads it.
- **Fields that can't be cleared.** The server ignores an empty value for ship-to, contact, date or comment, so those can be changed but not cleared. The editor doesn't offer to clear them.
- **Text search.** The server's search matches only a number (folio or order number). Customer and sales order are filters, not search terms. Search text that isn't a number is not accepted.
- **Another facility.** The list shows the user's own facility. Only administrators get the facility filter, and a `facility` typed into the URL by anyone else is ignored, as in Pedidos (spec 029). The server doesn't check it today, so the app is the only guard (mbe-api#314). **Fixed 2026-11-14** (mbe-api PR #321): the server checks the facility on the list and on every read and write by id. The client drop stays as defence in depth (fix/consume-mbe-api-308-314).
- **No facility configured.** A user whose account has no facility gets a notice saying so, and no list request is sent. This applies to administrators too, as in Pedidos.
- **Partial delivery's child order.** When a stop closes partially delivered, the server creates a new order for what's left, in En preparación, linked to its parent. Both orders link to each other on their detail screens.
- **Names the user can't read.** Customer, address, contact, facility, warehouse and employee arrive as numbers. When the user lacks the right to read one of those catalogs, the app shows the number instead of the name.
- **Statuses the screen doesn't set.** En tránsito, Entregada, Entregada parcialmente and Fallida are set by trips (itineraries), never from this screen.
- **Drafts with no folio.** A draft has no folio until it's confirmed. The list shows "Borrador" in the folio column, and search can't find it. The user finds it by status (Borrador), customer or scheduled date.
- **Network failure on an action.** The app says the result is unknown and reloads the order, rather than claiming the action failed.

## Requirements *(mandatory)*

### Functional Requirements

**List**

- **FR-001**: The back office MUST offer an "Órdenes de entrega" screen only to users with Delivery Orders read.
- **FR-002**: The list MUST show delivery orders newest first, paginated. Each row shows folio ("Borrador" when there's none), customer name, type, scheduled date, ship-to, the sales orders it fulfills, and status as a badge.
- **FR-003**: The list MUST open on every status at the user's facility, newest first. When mbe-api#312 lets the server list every non-terminal status in one request, the list MUST open on active orders instead, and offer "Activas" as a status choice. **Shipped 2026-11-14** (mbe-api PR #315): the list opens on "Activas"; "Todas" is `status=all` (fix/consume-mbe-api-308-314).
- **FR-004**: The list MUST filter by status (a single status or "Todas"; "Activas" per FR-003), type (Entrega, Recoge en tienda), scheduled date range, customer, sales order and facility. The customer filter needs Customers read, and the facility filter is offered only to administrators (see Edge Cases). Clearing the filters returns to the opening state.
- **FR-005**: The list MUST offer a search box that finds an order by its folio.
- **FR-006**: Clicking a row MUST open that order's detail screen.

**Detail**

- **FR-007**: The detail screen MUST show the order's header: folio, status, type, customer, facility, scheduled date, priority, ship-to, contact, comment, the sales orders it fulfills, its parent order and child orders (as links), and the last rejection reason when there is one.
- **FR-008**: The detail screen MUST list the order's lines with product code, product name, dispatch warehouse, source sales order, and ordered, committed, delivered, returned and open quantities.
- **FR-009**: The detail screen MUST show the order's history: each status change, oldest first, with date and time, previous and new status, employee name and reason.
- **FR-010**: The detail screen MUST show the proof of delivery read-only when the order has one: receiver name, identification shown, photo, and when it was recorded.
- **FR-011**: The detail screen MUST offer each action only when the order's status and type allow it and the user has Delivery Orders update (see Key Entities for the status rules).

**Edit a draft**

- **FR-012**: For a draft, the detail screen MUST let the user change scheduled date, priority, ship-to, contact and comment. Ship-to comes from the customer's addresses. A pickup order keeps its store's address, which isn't offered for change. Contact comes from the customer's contacts.
- **FR-013**: For a draft, the user MUST be able to change a line's quantity (more than 0, at most what's left to deliver on its sales line) and remove a line, after confirming.
- **FR-014**: For a draft, the user MUST be able to add a line from the same customer's completed sales that still have quantity left to deliver, with a quantity within what's left. Lines already on the order aren't offered.
- **FR-015**: Header and lines MUST be read-only when the order isn't a draft or the user lacks Delivery Orders update.

**Status actions**

- **FR-016**: "Confirmar" MUST be offered on a draft and MUST ask for confirmation, naming the customer, scheduled date and number of lines. It's disabled while the draft has no lines. After success, the screen shows the folio and status the server returned.
- **FR-017**: When confirm is refused because the scheduled date is too soon, the app MUST show the earliest date allowed.
- **FR-018**: "Cancelar" MUST be offered in Borrador, Pendiente de aprobación, Aprobada, Lista para recoger, En preparación and Fallida, and MUST require a reason that isn't empty or only whitespace.
- **FR-019**: "Reprogramar" MUST be offered only in Fallida, and MUST ask for confirmation.
- **FR-020**: "Lista para recoger" MUST be offered only on a pickup order in Aprobada.
- **FR-021**: "Entregar al cliente" MUST be offered only on a pickup order in Lista para recoger. It MUST require receiver name, the identification shown (free text, not blank), and a photo (jpg or png, up to 2 MB, as the server allows).
- **FR-022**: After any action succeeds, the detail screen MUST show the order's new state and history, and the list MUST reflect the change when the user returns to it.

**General**

- **FR-023**: When the server refuses an action, the app MUST show the reason in the user's language, from the error code, and reload the order. This includes an order that changed status, a quantity beyond what's left, a draft with no lines, too little notice, missing proof and an order that isn't failed.
- **FR-024**: Every new label, message, status name and error MUST be available in Spanish and English.
- **FR-025**: Names for customer, address, contact, facility, warehouse and employee MUST fall back to their number when the user can't read that catalog.

### Key Entities

- **Delivery order**: goods from one customer's completed sales, to be delivered to an address or picked up at a facility. It has:
  - a folio (assigned at confirmation), facility, customer and type (delivery or pickup);
  - scheduled date, priority, ship-to, contact, comment and status;
  - an optional parent order, when it holds what was left over from a partial delivery.

  It can carry lines from several sales of the same customer.
- **Delivery order line**: a quantity of one product from one sales line, leaving from one warehouse. It tracks how much is committed to a trip, delivered, returned, and still open. Product name and code are copies taken when the line was added.
- **Status**: one of:
  - Borrador, Pendiente de aprobación, Aprobada, Lista para recoger, En preparación, En tránsito, Fallida, which are active;
  - Recogida, Entregada, Entregada parcialmente, Cancelada, which are terminal.

  This screen moves orders as follows:
  - confirm: Borrador → Pendiente de aprobación, Aprobada or En preparación;
  - cancel: any active status except En tránsito → Cancelada;
  - requeue: Fallida → En preparación;
  - ready: Aprobada → Lista para recoger, pickup only;
  - pickup: Lista para recoger → Recogida, pickup only.
- **Status change (event)**: one entry in an order's history. It has from and to status, employee, date and time, and an optional reason.
- **Proof of delivery**: who received the goods, what identification they showed, a photo, and when.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A clerk can find a draft created in the POS today and confirm it in under 30 seconds.
- **SC-002**: Every delivery order created through the POS can be confirmed from the back office. None is left stuck in draft for lack of a screen.
- **SC-003**: In every walkthrough case, the detail screen offers exactly the actions the order's status, type and the user's rights allow, and no others.
- **SC-004**: No cancellation can be confirmed without a reason, and no pickup can be recorded without receiver name, identification shown and photo.
- **SC-005**: For any order, a supervisor can tell from its history who moved it to each status and when, without asking anyone.
- **SC-006**: Users without Delivery Orders read don't see the screen. Users without Delivery Orders update see no edit or status action anywhere on it.

## Assumptions

- The rights follow the server. Listing, detail, history and proof need Delivery Orders (71) read. Header and line edits, confirm, cancel, requeue, ready-for-pickup and pickup all need Delivery Orders update (cancel needs update, not delete).
- Delivery orders are created only in the POS "Entrega" step (spec 026), from a completed sale. This screen doesn't create them. Legacy "New" stays out of scope, by the user's choice.
- Delivery orders are only a back-office concern here. The POS "Entrega" step keeps working as it does and doesn't gain confirm.
- The list's facility default is the server's (the caller's facility). The server honors any facility id from any reader (mbe-api#314), so the app decodes the facility filter only for administrators, in both the URL filter and the request, as Pedidos does (spec 029). **Fixed 2026-11-14** (mbe-api PR #321): the server checks the facility on the list and on every read and write by id. The client drop stays as defence in depth (fix/consume-mbe-api-308-314).
- Approval (roadmap #39) and printing the delivery ticket and document (#42, #43) have their own issues and aren't part of this feature.
- Trips (itineraries), including stop closure and its proof of delivery (#41), aren't part of this feature. Their effects show up here as statuses, quantities, history and proof.
- Priority is a whole number of 0 or more, as the server takes it. There are no named priority levels, because the server has none.
- Legacy let users rename a line's product; the new server keeps product name and code as copies, so that's dropped.
- Legacy's default list was "orders I created or updated, not cancelled". The user chose active orders at the facility instead, deferred until mbe-api#312 (FR-003). **Shipped 2026-11-14** (mbe-api PR #315): the list opens on "Activas"; "Todas" is `status=all` (fix/consume-mbe-api-308-314).
- The minimum notice and whether approval is required are server settings the app can't read ahead of time. The app reacts to the server's answer.
- The photo for a pickup is picked from a file (the app has no camera capture today).
- "Agregar línea" works one sale at a time. The user picks one of the customer's completed sales, then that sale's lines that still have quantity left. The app computes what's left until mbe-api#313 adds a server query for it. Choosing a sale needs Sales Orders read. **Shipped 2026-11-14** (mbe-api PR #318): step 2 reads `GET /delivery-orders/deliverable-lines`; the client computation is deleted (fix/consume-mbe-api-308-314).
- Out of scope: creating a delivery order in the back office, approval, printing, trips, bulk actions on several orders, editing an order after confirmation, and clearing a header field.

## Verbatim Constraints

- Server rules relied on:
  - `GET /delivery-orders` (filters: `status`, `customer`, `facility`, `fulfillment_type`, `sales_order`, `date_from`, `date_to`, `search`, `skip`, `limit`; `mine` unused);
  - `GET /delivery-orders/{id}`, `PUT /delivery-orders/{id}`;
  - `POST /delivery-orders/{id}/lines`, `PUT` and `DELETE /delivery-orders/{id}/lines/{line_id}`;
  - `POST /delivery-orders/{id}/confirm`, `/cancel` (body `reason`, at least one non-blank character), `/requeue`, `/ready-for-pickup`;
  - `POST /delivery-orders/{id}/pickup` (multipart: `receiver_name`, `receiver_id_shown`, `image`);
  - `GET /delivery-orders/{id}/events`, `/proof`, `/proof/image`.
- Status numbers: 0 DRAFT, 1 PENDING_APPROVAL, 2 APPROVED, 3 READY_FOR_PICKUP, 4 PICKED_UP, 5 IN_PREPARATION, 6 IN_TRANSIT, 7 DELIVERED, 8 PARTIALLY_DELIVERED, 9 FAILED, 10 CANCELLED. Fulfillment type: 0 PICKUP, 1 DELIVERY.
- Error codes:
  - `delivery_order.not_editable`, `delivery_order.no_lines`, `delivery_order.insufficient_notice` (detail `min_hours`, `earliest`);
  - `delivery_order.not_failed`, `delivery_order.quantity_exceeds_remaining`, `delivery_order.line_not_deliverable`, `delivery_order.line_already_present`;
  - `delivery_order.proof_incomplete`, `delivery_order.reason_required`, `state.transition_invalid` (detail `resource`, `from`, `to`);
  - `lock.busy` (confirm), `image.too_large` and `image.unsupported_format` (pickup), `resource.not_found`.
- Known server gap: mbe-api#311. Cancelling an order that's a stop on an open itinerary blocks that itinerary's departure. **Fixed 2026-11-14** (mbe-api PR #320): the server refuses that cancel with `delivery_order.on_itinerary`, shown as a localized refusal (fix/consume-mbe-api-308-314).
- Pending server changes: mbe-api#312 (list several statuses at once, for "Activas"), mbe-api#313 (deliverable sales lines for a customer) and mbe-api#314 (facility checks on every delivery-order read). **All three shipped 2026-11-14** (mbe-api PRs #315, #318, #321; fix/consume-mbe-api-308-314).
