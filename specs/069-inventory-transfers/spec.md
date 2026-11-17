# Feature Specification: Inventory Transfers

**Feature Branch**: `069-inventory-transfers`

**Created**: 2026-11-16

**Status**: Draft

**Input**: Covers mictlanix/mbe-roadmap#63 ([UI] Inventory transfers). Scope 04 §3 Inventory Transfers (mbe-api `docs/specs/04-inventory.md`; SystemObject InventoryTransfers 17). Weight: 8 legacy actions. User description: "Inventory transfers (back-office UI)."

## Context

This adds the third screen of the back office's "Inventario" group, after Entradas de almacén (spec 067) and Salidas de almacén (spec 068). A transfer ("traspaso") moves stock from one warehouse to another, in the same facility or in a different one. The server work is done (mbe-api spec 029, migration 026), and the generated client has every route this spec needs.

A transfer moves in two steps. **Dispatch** takes the goods out of the origin and puts them in the origin facility's in-transit warehouse. **Receive** moves them from in transit into the destination. The destination does not count the goods until it receives them. A receipt can be partial, and a transfer can be received in several goes.

A transfer is in one of four states:

| State | Meaning | Editable |
|---|---|---|
| Draft (Borrador) | Being prepared; no folio | Yes |
| In transit (En tránsito) | Dispatched; folio assigned; some quantity not yet received | No (receive, close the remainder or cancel only) |
| Received (Recibido) | Nothing outstanding: everything received, or the remainder closed | No (cancel only) |
| Cancelled (Cancelado) | Cancelled; whatever had moved went back to the origin | No |

Transfers confirmed by the legacy system had a single step. They read as Received in full.

Three things set transfers apart from receipts and issues:

- A transfer has two warehouses, origin and destination. Its facility, and its folio, belong to the origin.
- Different steps happen at different ends. A non-administrator dispatches and cancels from the origin facility, receives at the destination facility, and closes the remainder from either.
- Goods dispatched but not received are "in transit". The server gives a per-facility view of them.

### Decisions carried over from specs 067 and 068

These were settled for receipts and issues on 2026-11-16 and apply to transfers the same way, so the three screens behave alike:

- A draft is identified as "Borrador #{internal number}": the title is "Traspaso · Borrador #{id}", and the list's Folio column shows "Borrador #{id}" until the transfer is dispatched.
- In Nuevo traspaso and Editar encabezado, the **origin** picker offers a non-administrator only the warehouses of their own facility, and administrators every warehouse. The origin starts as the user's point-of-sale warehouse when they have one (and, for a non-administrator, when it is in their own facility), and empty otherwise.
- The list's warehouse filter offers every warehouse to everyone.
- Adding a product already on the draft grows its line (server line merge), as on receipts and issues.

### Decisions made for this spec

- The **destination** picker offers every warehouse to everyone, because a transfer may go to another facility. The server refuses the same warehouse as the origin and any in-transit warehouse, and the UI shows those refusals.
- The in-transit view opens on the user's own facility. Only administrators can switch it to another facility. The server would answer any facility to any reader. The UI does not offer that to non-administrators, as with the app's other facility-wide reads, where the client is the only guard.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Find a transfer (Priority: P1)

A warehouse clerk opens "Traspasos" and sees the transfers that concern them: those whose origin or destination is their point-of-sale warehouse, and those they created, newest first. A transfer in transit therefore shows at both ends. They narrow the list by state and by warehouse. Each row shows the folio (once dispatched), origin, destination, facility, state, creator and creation date. Administrators, and users with the delete right on transfers, see every transfer and can filter by any warehouse.

**Why this priority**: Every other story starts from this list. The receiving end uses it to find what is on its way.

**Independent Test**: With a non-administrator account that has read access to transfers, open the list and check that only transfers to or from the user's warehouse, or created by the user, appear. Filter by In transit. Repeat with an administrator and check that every transfer appears.

**Acceptance Scenarios**:

1. **Given** a user with read access to transfers, **When** they open Traspasos, **Then** they see transfers newest first, one page at a time, limited to the scope the server grants them.
2. **Given** the list, **When** the user filters by state (draft, in transit, received, cancelled) or by warehouse, **Then** only matching transfers are shown, a warehouse matching either the origin or the destination, and the filter button shows how many filters are active.
3. **Given** an administrator or a user with the delete right on transfers, **When** they open the list, **Then** they see every transfer and can filter by any warehouse.
4. **Given** a user without read access to transfers, **When** they look at the navigation, **Then** Traspasos is not offered, and opening its address directly is redirected to the home page (the app's route gate).

---

### User Story 2 - Prepare and dispatch a transfer (Priority: P1)

A branch needs stock from the main warehouse. The clerk at the origin creates a transfer, chooses the origin and destination warehouses, and adds each product with its quantity. Adding a product already on the transfer adds to its quantity. When the goods are loaded they dispatch the transfer. The server checks that the origin has enough available stock, gives the transfer the origin facility's next folio, takes the stock out of the origin and puts it in transit.

**Why this priority**: Dispatch is the step that moves stock. Without it nothing reaches the destination.

**Independent Test**: Create a transfer between two warehouses, add two stockable products, add one again and check its quantity grows, then dispatch. The transfer shows a folio and the In transit state, the origin's stock of each product has dropped by the quantity sent, and the destination's stock has not changed yet.

**Acceptance Scenarios**:

1. **Given** a user with create access to transfers, **When** they choose Nuevo traspaso, an origin and a destination, **Then** a draft opens titled "Traspaso · Borrador #{internal number}", with no folio and no lines.
2. **Given** the new-transfer or header form, **When** the user chooses the same warehouse as origin and destination, **Then** the server's refusal is shown and nothing is saved.
3. **Given** a draft, **When** the user adds a stockable product with a quantity greater than 0, **Then** a line is added showing the product's code and name as they were when the line was added.
4. **Given** a draft that already has a line for a product, **When** the user adds the same product again, **Then** that line's quantity grows by the new amount and no second line appears.
5. **Given** a draft, **When** the user edits a line's quantity or deletes a line, **Then** the transfer shows the change as the server returns it.
6. **Given** a draft, **When** the user tries to add a product that is not stockable, or a quantity of 0 or less, **Then** it is refused with a clear message and the draft is unchanged.
7. **Given** a draft with at least one line and enough available stock at the origin, **When** the user dispatches it after accepting a prompt that says the stock will leave the origin and stay in transit until the destination receives it, **Then** it shows the In transit state and its folio, and no longer offers any edit action.
8. **Given** a draft whose lines of one product together exceed that product's available stock at the origin, **When** the user dispatches, **Then** the refusal names the product and warehouse, the transfer stays a draft, and no folio is used.
9. **Given** a draft whose origin facility has no in-transit warehouse, **When** the user dispatches, **Then** the refusal names the facility and the transfer stays a draft.
10. **Given** a non-administrator and a draft whose origin is in another facility, **When** they try to dispatch it, **Then** the server's refusal (document of another facility) is shown.

---

### User Story 3 - Receive a transfer (Priority: P1)

The goods arrive at the destination. The clerk there opens the transfer, which shows each line's quantity sent, received so far and outstanding. They choose Recibir. The receive form lists each line with something outstanding, filled in with the outstanding quantity. If everything arrived they accept it as it is. If some units are missing they lower those quantities, or set them to 0, and receive the rest. The transfer stays In transit while anything is outstanding, and can be received again later.

**Why this priority**: Until it is received the destination cannot sell or move the goods. Partial receipt is the normal case when something arrives short or damaged.

**Independent Test**: Dispatch a transfer of 10 units of one product and 5 of another. At the destination receive 8 and 5. The transfer stays In transit with 2 outstanding on the first line, and the destination's stock has grown by 8 and 5. Receive the remaining 2: the transfer becomes Received.

**Acceptance Scenarios**:

1. **Given** a transfer in transit, **When** the user opens it, **Then** each line shows the quantity sent, received and outstanding.
2. **Given** a user with update access and a transfer in transit, **When** they choose Recibir, **Then** a form lists every line with something outstanding, each filled in with its outstanding quantity.
3. **Given** the receive form, **When** the user receives without changing anything, **Then** everything outstanding is received and the transfer becomes Received.
4. **Given** the receive form, **When** the user lowers some quantities and receives, **Then** each line receives the quantity left in its field (lowered or not), the transfer stays In transit, and those lines show what is still outstanding.
5. **Given** the receive form, **When** the user sets a line to 0, **Then** that line is left out of the receipt. When every line is 0, receiving is not offered.
6. **Given** the receive form, **When** the user enters more than a line's outstanding quantity, **Then** they cannot receive until it is corrected.
7. **Given** a non-administrator outside the destination's facility, **When** they try to receive, **Then** the server's refusal (document of another facility) is shown.
8. **Given** a transfer that is not in transit (draft, received or cancelled), **When** the user opens it, **Then** Recibir is not offered.

---

### User Story 4 - Close the remainder (Priority: P2)

Part of a shipment never arrives and will not. Someone with the delete right closes the remainder. The outstanding quantities go back from in transit to the origin, the transfer becomes Received, and each line keeps what it actually received (for example 8 of 10). If the goods are really lost, the origin then writes them off with a warehouse issue.

**Why this priority**: Without it a short shipment stays In transit forever and its units are never accounted for. It happens less often than a normal receipt.

**Independent Test**: Dispatch 10 units, receive 8, then close the remainder. The transfer shows Received with 8 of 10 received on that line, and the origin's stock has grown back by 2.

**Acceptance Scenarios**:

1. **Given** a user with the delete right and a transfer in transit, **When** they choose Cerrar pendiente and accept a prompt that says the outstanding quantities will go back to the origin, **Then** the transfer shows Received and each line keeps the quantity it received.
2. **Given** a user without the delete right, **When** they open a transfer in transit, **Then** Cerrar pendiente is not offered.
3. **Given** a non-administrator outside both the origin's and the destination's facility, **When** they try to close the remainder, **Then** the server's refusal is shown.

---

### User Story 5 - Correct a draft's header (Priority: P2)

Before dispatching, the clerk notices the wrong origin or destination was chosen, or wants to add notes. On a draft they change the origin, the destination or the notes. Changing the origin moves the draft to the origin's facility.

**Why this priority**: A wrong warehouse is cheap to fix on a draft. After dispatch it needs a cancel and a new transfer.

**Independent Test**: As an administrator, change a draft's origin to a warehouse of another facility and change its destination. After reopening the draft, both are kept and the transfer shows the new facility.

**Acceptance Scenarios**:

1. **Given** a draft, **When** the user changes the origin, **Then** the transfer shows the new origin and its facility.
2. **Given** a draft, **When** the user changes the destination, including to a warehouse of another facility, **Then** the transfer shows the new destination and its facility stays that of the origin.
3. **Given** a draft, **When** the user enters notes longer than 500 characters, **Then** they cannot save until the notes are shortened.
4. **Given** a draft, **When** the user chooses an in-transit warehouse as origin or destination, **Then** the server's refusal is shown and the header is unchanged.
5. **Given** a transfer that is not a draft, **When** the user opens it, **Then** the header cannot be edited.

---

### User Story 6 - Cancel a transfer (Priority: P2)

A transfer was made by mistake. Someone with the delete right cancels it. A draft is simply cancelled. A dispatched transfer is cancelled by sending everything back to the origin: units still in transit go back, and units already received leave the destination and go back.

**Why this priority**: Mistakes must be correctable, but cancellation is rarer than dispatching or receiving.

**Independent Test**: Cancel a draft and check it shows Cancelled. Dispatch another transfer, receive part of it, then cancel it, and check that the origin and destination stocks are back to what they were before the dispatch.

**Acceptance Scenarios**:

1. **Given** a user with the delete right and a draft, **When** they cancel it after accepting a prompt, **Then** it shows Cancelled.
2. **Given** a user with the delete right and a transfer in transit or received, **When** they cancel it after accepting a prompt that says the units in transit and the units received will go back to the origin, **Then** it shows Cancelled, and each line keeps the quantity it had received.
3. **Given** a received transfer whose goods the destination has since sold or moved, **When** the user cancels it, **Then** the refusal names the product and warehouse that would go short, and the transfer is unchanged.
4. **Given** a non-administrator outside the origin's facility, **When** they try to cancel a transfer, **Then** the server's refusal is shown.
5. **Given** a cancelled transfer, or a user without the delete right, **When** the transfer is opened, **Then** no cancel action is offered.

---

### User Story 7 - See what is in transit (Priority: P3)

A manager wants to know what stock is on the road for their facility. They open the in-transit view. It lists, for the facility, every transfer line still outstanding, whether the facility is sending or receiving it: product, transfer folio, origin, destination and outstanding quantity. It also gives the total outstanding per product. Opening a line takes them to its transfer.

**Why this priority**: Useful for follow-up, but the list's In transit filter already covers the day-to-day need.

**Independent Test**: With two transfers in transit for a facility, one sending and one receiving, open the in-transit view and check both appear with the right outstanding quantities and per-product totals.

**Acceptance Scenarios**:

1. **Given** a user with read access to transfers, **When** they open the in-transit view, **Then** it shows their own facility's outstanding lines and per-product totals.
2. **Given** an administrator, **When** they open the in-transit view, **Then** they can switch to any facility.
3. **Given** a non-administrator, **When** they open the in-transit view, **Then** they see only their own facility and no facility switch.
4. **Given** a user without a facility, **When** they open the in-transit view, **Then** they are told a facility is needed, and an administrator can choose one.
5. **Given** an outstanding line, **When** the user opens it, **Then** its transfer opens.

---

### User Story 8 - Fill a draft from a sales order (Priority: P3)

A branch sold goods it does not have, and the order will be served from another warehouse. The clerk adds the order's items to a draft transfer instead of typing each product. They search for and choose a completed sales order. Its stockable lines are added at the ordered quantities, one line per product. Products already on the transfer are left as they are.

**Why this priority**: A shortcut. The same result can be reached by adding lines by hand.

**Independent Test**: On a draft holding one of the order's products, add a completed order with three stockable products. The two missing products are added at the ordered quantities, and the existing line is unchanged. Repeat it: nothing changes.

**Acceptance Scenarios**:

1. **Given** a draft and a user with update access, **When** they choose Agregar desde pedido and a completed sales order, **Then** the order's stockable products not already on the transfer are added at the ordered quantities, a product on several order lines added once with the sum.
2. **Given** a product already on the transfer, **When** the same order is added, **Then** its line is unchanged and the user is told that products already present were skipped.
3. **Given** an order that is not completed, or is cancelled, **When** the user adds it, **Then** the server's refusal is shown and the draft is unchanged.

---

### Edge Cases

- Available stock is on-hand minus reservations. The origin can show stock on hand and still refuse the dispatch because part of it is reserved. The refusal says the stock is not enough. The screen does not explain reservations.
- The transfer shows at both ends. Who can act depends on the step: dispatch and cancel from the origin facility, receive at the destination facility, close from either. A non-administrator sees the actions their rights allow, and the server's facility refusal is shown when they act from the wrong end.
- A legacy transfer (single-step) shows Received, and every line shows its full quantity as received.
- Two clerks receive the same transfer at once. The second receipt is refused if it asks for more than is now outstanding, and the screen reloads the transfer.
- Another user dispatches, receives, closes or cancels a transfer while it is open. The next action is refused with the server's reason, and the screen reloads the transfer in its new state.
- The warehouse is busy (another stock movement holds it). The server refuses with a "retry" reason, which is shown, and the transfer is unchanged.
- A user can read transfers but not update them: every transfer opens read-only, with no New, edit, line, dispatch or receive actions.
- The user leaves a draft with unsaved edits in the header or a line: they are warned before losing them, as in other back-office forms.
- Within one facility a transfer still goes through that facility's in-transit warehouse. It is dispatched and received the same way.
- The in-transit warehouse also holds stock dispatched for deliveries. The in-transit view reads transfers only, so those units are not in it.

## Requirements *(mandatory)*

### Functional Requirements

**List**

- **FR-001**: The back office MUST offer a Traspasos list to users with read access to transfers (system object 17), newest first and paginated, in the Inventario navigation group after Salidas de almacén.
- **FR-002**: The list MUST show the transfers the server returns for the user's scope. The UI MUST NOT widen or narrow that scope itself.
- **FR-003**: The list MUST filter by state (draft, in transit, received, cancelled) and by warehouse, through the shared filter drawer.
- **FR-004**: Each row MUST show the folio, origin, destination, facility, state, creator and creation date. A draft, which has no folio, MUST show "Borrador #{internal number}" in the Folio column.
- **FR-004a**: The detail screen's title MUST be "Traspaso {folio}" when the transfer has a folio, and "Traspaso · Borrador #{internal number}" when it does not (a draft, or a draft that was cancelled).

**Header**

- **FR-005**: Users with create access MUST be able to start a transfer by choosing an origin and a destination and, optionally, entering notes. The origin MUST start as described in "Decisions carried over"; the destination starts empty.
- **FR-006**: On a draft, users with update access MUST be able to change the origin, the destination and the notes. Notes MUST be optional and limited to 500 characters.
- **FR-007**: The transfer MUST show its facility, which follows the origin, as read-only information.

**Lines**

- **FR-008**: On a draft, users with update access MUST be able to add a product with a quantity greater than 0, change a line's quantity, and delete a line.
- **FR-009**: Adding a product already on the transfer MUST result in one line with the combined quantity, as the server returns it.
- **FR-010**: Each line MUST show the product code and name stored on the line and the quantity sent. Once dispatched, it MUST also show the quantity received and the quantity outstanding.
- **FR-011**: The product picker for transfer lines SHOULD offer only stockable products. Any refusal of a non-stockable product MUST be shown.
- **FR-012**: On a draft, users with update access MUST be able to add a completed sales order's stockable items (US8). The UI MUST say how many products were added and that products already on the transfer were left unchanged. The server does not report which products it skipped.

**Actions**

- **FR-013**: Users with update access MUST be able to dispatch a draft after accepting a prompt that says the stock will leave the origin and stay in transit until received. On success the transfer MUST show its folio and the In transit state and become read-only except for receive, close and cancel.
- **FR-014**: Users with update access MUST be able to receive a transfer in transit through a form listing each line with something outstanding, filled in with its outstanding quantity. Each quantity MUST be between 0 and the line's outstanding quantity. Lines at 0 MUST be left out. When the user leaves every quantity as filled in, the whole outstanding amount is received.
- **FR-015**: Users with the delete right MUST be able to close the remainder of a transfer in transit after accepting a prompt that says the outstanding quantities go back to the origin.
- **FR-016**: Users with the delete right MUST be able to cancel a transfer that is not already cancelled, after accepting a prompt that, for a dispatched transfer, says units in transit and units received go back to the origin.
- **FR-017**: Each action MUST be offered only in the states where it applies: header, line and sales-order edits and dispatch on drafts; receive and close the remainder in transit; cancel in every state but cancelled.

**In-transit view**

- **FR-018**: Users with read access to transfers MUST be able to open an in-transit view for a facility, showing the outstanding lines (product, transfer folio, origin, destination, outstanding quantity) and the total outstanding per product. A line MUST open its transfer.
- **FR-019**: The in-transit view MUST open on the user's own facility. Only administrators MUST be offered a facility switch.

**Across the feature**

- **FR-020**: Actions the user's rights do not allow MUST be absent, never shown disabled, mirroring the server: read on 17 to see, create on 17 to start a transfer, update on 17 to edit drafts, add sales-order items, dispatch and receive, delete on 17 to close the remainder and to cancel. A control that lists other records also needs that record's read right (warehouses to choose or filter, products to add a line, sales orders to fill from an order, facilities to switch the in-transit view). The facility rule is enforced by the server and its refusal MUST be shown.
- **FR-021**: The origin picker MUST offer a non-administrator only their own facility's warehouses, and administrators every warehouse. The destination picker and the list's warehouse filter MUST offer every warehouse to everyone.
- **FR-022**: Every server refusal MUST be shown with the localized text for its error code, never a raw server message or a generic failure. This includes insufficient stock on dispatch and on cancel, the same warehouse as origin and destination, an in-transit warehouse, a facility without an in-transit warehouse, a non-stockable product, receiving more than is outstanding, a repeated receive line, a transfer not in transit, a sales order not completed, a transfer of another facility, a transfer already cancelled, a dispatch with no lines, and a busy warehouse.
- **FR-023**: After every change the screen MUST show the transfer as the server returned it.
- **FR-024**: All user-facing text MUST be in Spanish, with quantities, dates and folios formatted by the app's shared formatting.
- **FR-025**: Traspasos MUST look and behave like Entradas and Salidas de almacén wherever the documents work the same way (list, header, lines, prompts, draft naming), so a clerk who knows one knows the others.

### Key Entities

- **Transfer**: Stock moved from an origin warehouse to a destination warehouse. It has a facility and a folio (both from the origin, the folio once dispatched), a state, notes, its creator and creation date, and its lines.
- **Transfer line**: A stockable product, the quantity sent, the quantity received so far and the quantity outstanding, with the product's code and name as they were when the line was added.
- **Warehouse**: The origin or destination. It belongs to a facility. An in-transit warehouse is neither.
- **In-transit warehouse**: Each facility's holding warehouse for goods on the road. Dispatch puts stock there and receive takes it out. It is not chosen by the user.
- **In-transit line**: An outstanding transfer line seen from a facility, sending or receiving.
- **Available stock**: On-hand stock minus reservations, checked by the server on dispatch and on cancel. It is not shown on these screens.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A clerk can prepare and dispatch a transfer of 10 products in under 3 minutes.
- **SC-002**: A clerk at the destination can receive a full shipment in under 30 seconds, and a shipment with two short lines in under 1 minute.
- **SC-003**: After each dispatch, receipt, close or cancel, the origin's and destination's stock of every product on the transfer matches the quantities sent and received, every time.
- **SC-004**: A transfer that asks for more than the origin has available is never dispatched, and the clerk is told which product is short.
- **SC-005**: Every server refusal a user can trigger on these screens shows a specific Spanish message. None shows a generic error or raw server text.
- **SC-006**: A user with read-only access cannot reach any action that changes a transfer.

## Assumptions

- Traspasos joins the Inventario navigation group after Salidas de almacén. The in-transit view is reached from the Traspasos list. Whether it is a separate navigation entry is decided at plan time.
- The list's default scope and the wider view are decided by the server. The UI sends only the state and warehouse filters.
- Warehouse records do not say whether they are in transit, so the pickers cannot hide in-transit warehouses. The server refuses them, and the UI shows that refusal.
- The editor does not show available stock while lines are added. The server's check on dispatch is the guard.
- The sales-order picker reuses the order search already built for delivery orders, limited to completed, non-cancelled orders where the server allows that filter. The transfer does not keep a link to the order.
- Lots, serials, expiry and FIFO are out of scope, as in the server.
- Transfers are not printed in this spec. A printable transfer (packing slip) would be a separate roadmap item.
- The generated client already has all transfer routes. The four `inventory_transfer.*` error codes and `sales_order.not_confirmed` have no Spanish text yet and must get it. The in-transit warehouse codes (`facility.no_in_transit_location`, `warehouse.in_transit_location`) already have it.
- Live verification needs, in the dev tenant, two warehouses in one facility and one in another, a facility with an in-transit warehouse, a stockable product with stock at the origin, and a completed sales order with stockable lines.
