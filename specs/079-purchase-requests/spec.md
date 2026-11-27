# Feature Specification: Purchase Requests with Approval

**Feature Branch**: `079-purchase-requests`

**Created**: 2026-11-26

**Status**: Draft

**Input**: Covers mictlanix/mbe-roadmap#69 ([UI] Purchase requests with approval). Scope 05 §1–2 (mbe-api `docs/specs/05-purchases.md`: §1 Purchase Requests, SystemObject PurchaseRequest 86; §2 Purchase Request Approval, SystemObject PurchaseRequestApproval 96). Weight: 12 legacy actions. The server side is mictlanix/mbe-roadmap#68 (mbe-api spec 031), closed; the generated client already has every purchase-request route.

## Context

This adds the back office's first purchasing screens. A purchase request ("solicitud de compra") is how a store asks for goods before anyone talks to a supplier. Store staff list the products they need, a supervisor approves the request, and purchasing later turns its marked lines into purchase orders (mictlanix/mbe-roadmap#71, a separate spec).

A request is in one of four states:

| State | Meaning | Editable |
|---|---|---|
| Draft | Being prepared. Has no folio until its first submit | Yes |
| Submitted | Waiting for a supervisor | No |
| Approved | A supervisor approved it; purchasing can order its marked lines | No |
| Cancelled | Cancelled from any other state | No |

A rejected request goes back to Draft and keeps the folio it got on its first submit.

## Clarifications

### Session 2026-11-26

- Q: Opening a single request needs read access to purchase requests (86), not to approval (96). What can an approver with only 96 do? → A: They see the queue and can approve the requests they select there. Opening a request to review its lines needs 86 read too, and so do approving from the detail and rejecting, which happen on the detail. No server change is requested.
- Q: The client cannot read a rejection's reason. How is that handled? → A: Ship without showing it, and track the server change in mictlanix/mbe-api#352 (latest rejection reason, who and when, on the request). When it ships, the request detail shows the reason.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Create and submit a request (Priority: P1)

A store employee needs goods. They open "Solicitudes de compra" and choose Nueva solicitud. The warehouse starts as their point-of-sale warehouse, and they may add a note. They add each product they need. A new line's quantity starts at the product's minimum order quantity (or 1), and its destination warehouse starts as the request's. They can change the quantity, the name shown for the product, and the destination warehouse, which may belong to another facility. When the list is complete they submit it. On its first submit the request gets its facility's next folio, and it becomes read-only while it waits for a supervisor.

**Why this priority**: Nothing else in purchasing can happen until stores can ask for goods.

**Independent Test**: Create a request, add two products, change one line's quantity and destination warehouse, and submit it. The request shows a folio and the Submitted state, and no edit actions remain.

**Acceptance Scenarios**:

1. **Given** a user with create access to purchase requests, **When** they choose Nueva solicitud, **Then** a draft opens titled "Solicitud · Borrador #{internal number}", with the warehouse set to their point-of-sale warehouse when they have one, and no lines.
2. **Given** a draft, **When** the user adds a purchasable product, **Then** a line appears with the product's code and name, a quantity equal to the product's minimum order quantity (or 1 when it has none), and the request's warehouse as its destination.
3. **Given** a draft line, **When** the user sets its quantity below the product's minimum order quantity, **Then** the line is saved and a warning names the minimum. The warning never blocks saving or submitting.
4. **Given** a draft line, **When** the user sets a quantity of 0 or less, or with more than 2 decimals, **Then** they cannot save it until it is corrected.
5. **Given** a draft, **When** the user changes a line's product name, quantity or destination warehouse, or deletes a line, **Then** the request shows the change as the server returns it.
6. **Given** a draft with at least one line, **When** the user submits it after accepting a confirmation prompt, **Then** it shows the Submitted state and its folio, and no longer offers edit actions.
7. **Given** a draft with no lines, **When** the user tries to submit, **Then** the server's reason is shown and the request stays a draft.

---

### User Story 2 - Approve or reject requests (Priority: P1)

A supervisor opens "Aprobación de solicitudes" and sees every submitted request of every facility, oldest first, each with its folio, facility, warehouse, requester, date and number of lines. They can narrow the queue to one facility. They open a request to review its lines and approve it, or reject it with a reason, which sends it back to its requester as a draft. When several requests are clearly fine, they select them in the queue and approve them all at once.

**Why this priority**: A request is useless to purchasing until it is approved, and this is the only place approvals happen.

**Independent Test**: As a supervisor, approve one submitted request from its detail and check it leaves the queue and shows the approver and approval time. Reject another with a reason and check it is a draft again with its folio kept. Select three requests, approve them together, and check the result names each one.

**Acceptance Scenarios**:

1. **Given** a user with read access to purchase request approval, **When** they open Aprobación de solicitudes, **Then** they see the submitted requests of every facility, oldest first, one page at a time, each with its number of lines.
2. **Given** the queue, **When** the user filters by facility, **Then** only that facility's requests are shown.
3. **Given** a user with update access to purchase request approval and a submitted request, **When** they approve it after accepting a confirmation prompt, **Then** it shows the Approved state, the approver and the approval time, and it leaves the queue.
4. **Given** a submitted request, **When** the supervisor rejects it with a reason of 1 to 500 characters, **Then** it shows the Draft state with its folio kept, and it leaves the queue.
5. **Given** the queue, **When** the user selects up to 100 requests and approves them together, **Then** a summary shows how many were approved and, for each one refused, its folio and the reason in Spanish.
6. **Given** a request that someone else already approved, rejected or cancelled, **When** the supervisor tries to approve or reject it, **Then** the server's reason is shown and the queue reloads.
7. **Given** the requester holds the approval right, **When** they open their own submitted request, **Then** they may approve it, as the server allows.

---

### User Story 3 - Find a request and follow it (Priority: P2)

A store employee wants to know where their requests stand. The list shows by default the requests they created or last changed, without cancelled ones, newest first. They can switch to every user's requests and filter by state, facility, warehouse, requester and date range, or look one up by folio. Opening a request shows its header, its lines and, on an approved request, who approved it and when. Each line that is already on a purchase order shows that order's number and state.

**Why this priority**: Requesters and purchasing staff check progress daily, but the list is not needed to create or approve.

**Independent Test**: With a non-administrator, open the list and check that only their own non-cancelled requests appear. Switch to everyone's requests, filter by Approved and by a facility, and search a known folio.

**Acceptance Scenarios**:

1. **Given** a user with read access to purchase requests, **When** they open Solicitudes de compra, **Then** they see the requests they created or last changed, without cancelled ones, newest first, one page at a time.
2. **Given** the list, **When** the user switches to everyone's requests, **Then** requests of every user are shown.
3. **Given** the list, **When** the user filters by state, facility, warehouse, requester or date range, or searches a folio, **Then** only matching requests are shown, and the filter button shows how many filters are active.
4. **Given** an approved request, **When** the user opens it, **Then** it shows the approver and the approval time.
5. **Given** a request whose line is on a purchase order, **When** the user opens it, **Then** that line shows the purchase order's number and state.
6. **Given** a user without read access to purchase requests, **When** they look at the navigation, **Then** Solicitudes de compra is not offered, and opening its address directly is redirected to the home page.

---

### User Story 4 - Correct and resubmit a rejected request (Priority: P2)

A supervisor rejected a request. Its requester opens it, now a draft again with its original folio, fixes the lines or the notes, and submits it again. It returns to the approval queue under the same folio.

**Why this priority**: Rejections are part of the normal flow, and a request that can't be corrected must be recreated from scratch.

**Independent Test**: Reject a submitted request, change one of its lines, resubmit it, and check it shows the same folio as before and appears in the approval queue again.

**Acceptance Scenarios**:

1. **Given** a rejected request (a draft with a folio), **When** its requester edits it and submits it again, **Then** it shows the Submitted state with the same folio.
2. **Given** a draft that already has a folio, **When** the user changes its warehouse, **Then** only warehouses of the same facility are accepted, and the server's refusal is shown for any other.
3. **Given** a non-administrator, **When** they open the warehouse picker for a request's header, **Then** only the warehouses of their own facility are offered. Administrators are offered every warehouse.

---

### User Story 5 - Mark lines for purchase (Priority: P3)

Purchasing reviews a submitted or approved request and decides which lines will actually be bought. Every line starts marked. They unmark the lines that won't be ordered, and mark them again if they change their mind. Only marked lines of approved requests reach purchase orders.

**Why this priority**: It refines what purchasing orders, but every line is marked by default, so the flow works without it.

**Independent Test**: On an approved request, unmark one line and check it shows as unmarked after reopening. On a line already on a live purchase order, try to unmark it and check the server's reason is shown.

**Acceptance Scenarios**:

1. **Given** a user with update access to purchase orders and a submitted or approved request, **When** they unmark or mark a line, **Then** the line shows its new mark as the server returns it.
2. **Given** a line already on a purchase order that is not cancelled, **When** the user unmarks it, **Then** the server's reason is shown and the line stays marked.
3. **Given** a draft or cancelled request, or a user without update access to purchase orders, **When** they open it, **Then** the lines' marks are shown but cannot be changed.

---

### User Story 6 - Cancel a request (Priority: P3)

A request is no longer needed. Its requester or a supervisor cancels it from draft, submitted or approved. A cancelled request is read-only.

**Why this priority**: Unneeded requests otherwise sit in the queue or in purchasing's pending lines, but cancelling is infrequent.

**Independent Test**: Cancel a draft and an approved request and check both show Cancelled. Try to cancel a request with a line on a live purchase order and check the server's reason is shown.

**Acceptance Scenarios**:

1. **Given** a user with the delete right on purchase requests and a draft, submitted or approved request, **When** they cancel it after accepting a confirmation prompt, **Then** it shows the Cancelled state and offers no actions.
2. **Given** a request with a line on a purchase order that is not cancelled, **When** the user cancels it, **Then** the server's reason is shown and the request is unchanged.
3. **Given** a user without the delete right, **When** they open any request, **Then** the cancel action is not offered.

---

### Edge Cases

- A non-administrator opens a request whose header warehouse is in another facility. They can read it, but the server refuses editing, submitting and cancelling it, and that refusal is shown. Approving, rejecting and marking lines are not limited by facility.
- Two supervisors act on the same request. The second approval or rejection is refused with the server's reason, and the screen reloads the request in its new state.
- A bulk approval mixes requests that can be approved with ones that were changed meanwhile. Each one is approved or refused on its own; the summary lists the refused ones with their reasons, and the queue reloads.
- A request was rejected. The rejection reason is recorded on the server as an incidence, which the client has no route to read, so the requester sees the request back in Draft without the reason until mictlanix/mbe-api#352 ships. See Assumptions.
- A line's destination warehouse is in transit. The server refuses it, and the refusal is shown.
- The product picker offers a product that is not purchasable. The server refuses it, and the refusal is shown.
- A user can read requests but not update them: every request opens read-only, with no New, edit, submit or line actions.
- The user leaves a draft with unsaved edits in the header or a line: they are warned before losing them, as in other back-office forms.
- A user holds the approval right but not read access to purchase requests. They see the queue and can approve the requests they select there, but the queue offers no way to open a request, so they can neither review its lines nor reject it.

## Requirements *(mandatory)*

### Functional Requirements

**List**

- **FR-001**: The back office MUST offer a Solicitudes de compra list to users with read access to purchase requests (system object 86), newest first and paginated.
- **FR-002**: The list MUST show by default the requests the server returns for the user (those they created or last changed, without cancelled), and MUST let the user switch to everyone's requests. The UI MUST NOT widen or narrow either scope itself.
- **FR-003**: The list MUST filter by state (draft, submitted, approved, cancelled), facility, warehouse, requester and date range, and search by folio, through the shared filter drawer.
- **FR-004**: Each row MUST show the folio, facility, warehouse, state, requester, date and number of lines. A draft that has never been submitted MUST show "Borrador #{internal number}" in the Folio column instead.
- **FR-005**: The detail screen's title MUST be "Solicitud {folio}" for a request with a folio and "Solicitud · Borrador #{internal number}" for one without.

**Header**

- **FR-006**: Users with create access MUST be able to start a request by choosing a warehouse and, optionally, entering notes. The warehouse MUST start as the user's point-of-sale warehouse when they have one and, for a non-administrator, when it belongs to their own facility; otherwise it starts empty.
- **FR-007**: On a draft, users with update access MUST be able to change the warehouse and the notes. Notes MUST be limited to 500 characters.
- **FR-008**: The header's warehouse picker MUST offer a non-administrator only the warehouses of their own facility, and an administrator every warehouse. A draft that already has a folio MUST accept only warehouses of its current facility; the server's refusal of any other MUST be shown.
- **FR-009**: The request MUST show its facility, which follows its warehouse, as read-only information, and on an approved request its approver and approval time.

**Lines**

- **FR-010**: On a draft, users with update access MUST be able to add a product, change a line's product name (up to 250 characters), quantity and destination warehouse, and delete a line.
- **FR-011**: A new line MUST start with the product's name, the product's minimum order quantity (or 1 when it is 0), and the request's warehouse as its destination, as the server returns them.
- **FR-012**: A quantity MUST be greater than 0 with at most 2 decimals; the UI MUST NOT allow saving any other.
- **FR-013**: A line whose quantity is below its product's minimum order quantity MUST show a Spanish warning naming the minimum, computed from the line figures the server returns. It MUST NOT block any action.
- **FR-014**: The line's destination warehouse picker MUST offer every warehouse, since a line may go to another facility. An in-transit warehouse is refused by the server, and that refusal MUST be shown.
- **FR-015**: Each line MUST show the product code and name, the quantity, the destination warehouse, its purchase mark, and, when it is on a purchase order, that order's number and state.

**Actions**

- **FR-016**: Users with update access MUST be able to submit a draft after accepting a confirmation prompt. On success the request MUST show its folio and the Submitted state and become read-only.
- **FR-017**: Users with update access to purchase orders (system object 20) MUST be able to mark and unmark the lines of a submitted or approved request, one line at a time.
- **FR-018**: Users with the delete right on purchase requests MUST be able to cancel a draft, submitted or approved request after accepting a confirmation prompt.

**Approval**

- **FR-019**: The back office MUST offer an Aprobación de solicitudes queue to users with read access to purchase request approval (system object 96), showing submitted requests of every facility, oldest first and paginated, each with its folio, facility, warehouse, requester, date, number of lines and notes, filterable by facility.
- **FR-020**: Users who also have read access to purchase requests (86) MUST be able to open a request from the queue to review its header and lines. For users without it, the queue MUST NOT offer opening a request.
- **FR-021**: Users with update access to purchase request approval MUST be able to approve a submitted request, after accepting a confirmation prompt, from its detail (which needs read access to purchase requests, FR-020) or by selecting it in the queue (FR-023).
- **FR-022**: Users with update access to purchase request approval and read access to purchase requests MUST be able to reject a submitted request from its detail, entering a reason of 1 to 500 characters.
- **FR-023**: Users with update access to purchase request approval MUST be able to select 1 to 100 requests in the queue and approve them together. The result MUST show how many were approved and, for each one refused, its folio and the localized reason for its error code.
- **FR-024**: After an approval, rejection or bulk approval the queue MUST reload, so decided requests leave it.

**Across the feature**

- **FR-025**: Actions the user's rights do not allow MUST be absent, never shown disabled, mirroring the server: read on 86 to see requests, create on 86 to start one, update on 86 to edit a draft and submit it, delete on 86 to cancel; read on 96 to see the queue, plus read on 86 to open a request from it; update on 96 to approve (from the queue, or from the detail with read on 86) and to reject (from the detail, so also read on 86); update on 20 to mark lines. A control that lists other records also needs that record's read right (warehouses to choose or filter a warehouse, products to add a line, facilities to filter by facility, employees to filter by requester).
- **FR-026**: The facility rule (a non-administrator edits, submits and cancels only requests whose header warehouse is in their facility) MUST be enforced by the server, and its refusal MUST be shown.
- **FR-027**: Every server refusal MUST be shown with the localized text for its error code, never a raw server message or a generic failure. This includes submitting without lines, a wrong state for the action, a warehouse of another facility, an in-transit warehouse, a non-purchasable product, a request of another facility, and a line or request held by a live purchase order.
- **FR-028**: After every change the screen MUST show the request as the server returned it.
- **FR-029**: All user-facing text MUST be in Spanish, with quantities, dates and folios formatted by the app's shared formatting.

### Key Entities

- **Purchase request**: Goods a store asks for. It has a warehouse and, through it, a facility, a folio once first submitted, a state, notes, its requester and date, the approver and approval time once approved, its lines and its number of lines.
- **Request line**: A purchasable product with the name shown for it, a quantity, a destination warehouse, a purchase mark, the product's minimum order quantity, and, when it is on a purchase order, that order's number and state.
- **Approval queue**: The submitted requests of every facility, waiting for a supervisor.
- **Rejection**: A supervisor's reason for sending a request back to draft. It is recorded on the server and not shown on the request until mictlanix/mbe-api#352 ships.
- **Purchase order**: Shown only as a reference on the lines it holds. It is what keeps a line from being unmarked or a request from being cancelled.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A store employee can create and submit a request of 10 products in under 3 minutes.
- **SC-002**: A supervisor can clear a queue of 20 requests that need no changes in under 1 minute with bulk approval.
- **SC-003**: A rejected request, once resubmitted, keeps its folio every time.
- **SC-004**: Every server refusal a user can trigger on these screens shows a specific Spanish message. None shows a generic error or raw server text.
- **SC-005**: A user with read-only access cannot reach any action that changes a request.

## Assumptions

- The back office gets a new "Compras" group in its navigation, after Inventario and before Finanzas, holding Solicitudes de compra and Aprobación de solicitudes. Purchase orders, supplier payments and accounts payable (mictlanix/mbe-roadmap#71, #75, #80) will join it. Proveedores stays where it is. The Spanish names follow the legacy system ("Solicitudes de Compra").
- The rejection reason is stored by the server as an incidence (source 4), and the client has no route to read incidences. This spec does not show the reason to the requester. Exposing the latest rejection reason on the request is requested in mictlanix/mbe-api#352; when it ships, the request detail should show it.
- The list and queue rows carry ids for the warehouse, facility and requester, not names. How the screens show names (client-side lookups or a server change, as was done for other documents in mbe-api#324–#330) is decided in planning.
- The server's warnings are English text with no code, so the UI does not show them. The only warning in this scope, a quantity below the minimum order quantity, is computed by the UI in Spanish from the line figures (FR-013).
- The list's default scope and the meaning of "everyone's requests" are decided by the server; the UI only sends the switch and the filters.
- Line fields the legacy system stored but never offered (customer, accepted) are not shown, as the server spec says.
- The warehouse picker uses the existing warehouse list. Warehouse records do not say whether they are in transit, so the picker cannot hide them; the server refuses one and the UI shows the refusal.
- The product picker is the existing one, limited to purchasable products where it supports that filter.
- Purchase requests are not printed. Turning marked lines into purchase orders, and the "to purchase by supplier" view, belong to the purchase orders spec (mictlanix/mbe-roadmap#71).
- Live verification needs, in the dev tenant, a purchasable product with a minimum order quantity, a warehouse with a point-of-sale user, an account holding the approval right, and a non-administrator in a different facility.
