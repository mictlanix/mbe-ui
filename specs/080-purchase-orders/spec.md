# Feature Specification: Purchase Orders with Receipts, PDF and Email

**Feature Branch**: `080-purchase-orders`

**Created**: 2026-11-27

**Status**: Draft

**Input**: Covers mictlanix/mbe-roadmap#71 ([UI] Purchase orders with receipts, PDF and email). Scope 05 §3–4 (mbe-api `docs/specs/05-purchases.md`: §3 Purchase Orders, SystemObject PurchasesOrders 20; §4 Purchase Order Approval, not built). No purchase order approval step: off since Mar 2025 (decided 26 Oct 2026). Weight: 17 legacy actions. The server side is mictlanix/mbe-roadmap#70 (mbe-api spec 031), closed; the generated client already has every purchase-order route.

## Context

A purchase order ("orden de compra") is the formal order sent to a supplier. It follows the purchase requests built in spec 079: purchasing takes the approved requests' marked lines and orders them, grouped by supplier, or writes an order by hand. Confirming an order creates the draft warehouse receipts the stores will fill in when the goods arrive (spec 067 receipts). The confirmed order can be printed and emailed to the supplier.

An order is in one of three states:

| State | Meaning | Editable |
|---|---|---|
| Draft | Being prepared | Yes |
| Confirmed | Sent to the supplier; its receipts exist | No |
| Cancelled | Cancelled while a draft; its lines stay as history | No |

There is no approval step. The legacy approval (PurchaseOrderApproval, 95) was used only from 2024-11 to 2025-03, left confirmed orders without receipts, and is not built (§4). Orders are numbered by their id and are not limited to a facility.

## Clarifications

### Session 2026-11-27

- Q: Should the request detail (079) and receipt detail (067), which show an order number as plain text, link to the new order detail? → A: Both link it, for users with read access to purchase orders; others keep seeing plain text.
- Q: Order lines don't carry the product's supplier and the batch product lookup doesn't return it. How does the UI warn about a supplier mismatch? → A: Ask mbe-api for coded warnings (filed as mictlanix/mbe-api#353). The UI shows the mismatch warning once that ships and shows none until then.
- Q: Por comprar's endpoint returns every group at once with only a facility filter; how does the screen meet §VI's search, filter and pagination rule? → A: Ask mbe-api for a supplier filter, product search and pagination (filed as mictlanix/mbe-api#354). Until it ships, Por comprar offers only the facility filter the server already has, with no search or pagination, as a recorded temporary exception.
- Q: The order response doesn't give each receipt's state, and `GET /purchase-orders/{id}` returns no receipts at all (only the confirm response does). How does a confirmed order show its receipts? → A: Ask mbe-api to list every linked receipt with its state on every order response (filed as mictlanix/mbe-api#355). Until it ships, the receipts appear only right after confirming, and a reloaded order relies on per-line received and pending quantities.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Order the pending request lines by supplier (Priority: P1)

A buyer opens "Por comprar", which groups every marked line of approved requests not yet on an order by supplier and destination facility. Each group shows its supplier, facility, number of lines and estimated total at cost. The buyer picks a group and creates a draft order from it in one step, then lands on that order.

**Why this priority**: This is how approved requests become orders; without it, the request flow from spec 079 has no outlet.

**Independent Test**: With one approved request whose lines are marked, open Por comprar, create the order for its group, and check that the draft holds those lines priced at cost and that the group is gone from Por comprar.

**Acceptance Scenarios**:

1. **Given** approved requests with marked lines for two suppliers, **When** the buyer opens Por comprar, **Then** they see one group per supplier and destination facility, each with its line count and estimated total, and can expand a group to see its lines (request folio, product, quantity, warehouse, cost).
2. **Given** a group with a supplier, **When** the buyer creates the order, **Then** a draft order for that supplier opens holding every pending line of the group, each priced at the product's cost.
3. **Given** a group's product has no cost, **When** the order is created, **Then** that line is priced at 0 and the order shows a Spanish warning on it.
4. **Given** lines whose product has no supplier, **When** the buyer views Por comprar, **Then** those lines form a "Sin proveedor" group per facility that cannot be turned into an order in one step; the screen says they must be added by hand.
5. **Given** another user ordered some of the group's lines in the meantime, **When** the buyer creates the order, **Then** the order holds only the remaining lines and the screen says how many lines were left out because they were already ordered.

---

### User Story 2 - Write and confirm an order (Priority: P1)

A buyer creates an order by hand: chooses the supplier, an optional estimated receipt date and notes, adds products with destination warehouse, quantity, unit price and tax rate, or pulls in all pending lines of one approved request. They review the totals and confirm. Confirming locks the order and creates one draft receipt per destination warehouse; the order then lists those receipts.

**Why this priority**: Confirming is what makes the order real and creates the receipts the stores need to receive goods.

**Independent Test**: Create an order by hand with lines for two warehouses, confirm it, and check that it shows as confirmed with two linked draft receipts, each holding its warehouse's stockable lines.

**Acceptance Scenarios**:

1. **Given** a user with create access, **When** they start a new order and choose a supplier, **Then** a draft order is created and opens for editing.
2. **Given** a draft, **When** the user adds a product, **Then** the line starts with the user's point-of-sale warehouse, the product's cost as unit price (0 when none) and the product's tax rate, as the server returns them, and the user can change the warehouse, quantity, unit price and tax rate.
3. **Given** a draft, **When** the user adds the lines of an approved request, **Then** the request's pending lines are added priced at cost, and lines already on another order are reported as left out. (Flagging a line whose product's supplier differs from the order's waits on mictlanix/mbe-api#353.)
4. **Given** a draft with a supplier and lines with quantities above 0, **When** the user confirms, **Then** the order becomes confirmed, read-only, and shows the receipts it created, each with its warehouse, facility and line count, and each can be opened. (Once mictlanix/mbe-api#355 ships, a reopened order also lists them, with their state.)
5. **Given** a draft with lines priced at 0, **When** the user confirms, **Then** the UI asks for confirmation naming those lines and, if they go ahead, the order is confirmed.
6. **Given** a draft without a supplier or without lines, **When** the user tries to confirm, **Then** the action is unavailable or refused with a Spanish explanation.

---

### User Story 3 - Find an order and follow its receiving (Priority: P2)

A buyer opens Órdenes de compra, sees their own orders newest first, and can switch to everyone's. They filter by state, supplier, creator, date range and search by number. Opening a confirmed order shows, per line, how much has been received and how much is still pending.

**Why this priority**: Buyers need to chase suppliers for what has not arrived; the list is also the entry point to every other action.

**Independent Test**: With two confirmed orders, one partly received, filter the list by supplier, open the partly received one and check the received and pending quantities against its confirmed receipts.

**Acceptance Scenarios**:

1. **Given** a user with read access, **When** they open the list, **Then** they see by default the orders the server returns for them (those they created or last changed, without cancelled), newest first and paginated, and can switch to everyone's.
2. **Given** the list, **When** the user filters by state, supplier, creator or date range, or searches an order number, **Then** only matching orders are listed.
3. **Given** a confirmed order with some receipts confirmed, **When** the user opens it, **Then** each stockable line shows its quantity received and pending, and a non-stockable line shows neither.
4. **Given** each row, **When** the list shows it, **Then** it shows the number, supplier, state, estimated receipt date, creator, date, number of lines and total.

---

### User Story 4 - Print and email a confirmed order (Priority: P2)

A buyer prints a confirmed order as a PDF, or emails it to the supplier: the email dialog suggests the supplier's contact addresses, lets the buyer edit up to 10 addresses and add a message, and sends.

**Why this priority**: Sending the order to the supplier is the order's purpose; it is the "PDF and email" of the issue.

**Independent Test**: Print a confirmed order and check the PDF opens; email it to one address and check the success message; try a draft and check neither action is offered.

**Acceptance Scenarios**:

1. **Given** a confirmed order, **When** the user prints it, **Then** the order's PDF is shown or downloaded the way other back-office documents are.
2. **Given** a confirmed order and a supplier with contact email addresses, **When** the user opens the email dialog, **Then** those addresses are suggested, the user can edit them (1 to 10 valid addresses) and add a message of up to 1,000 characters, and sending shows a success message.
3. **Given** the mail server refuses the send or mail is not configured, **When** the user sends, **Then** a Spanish message says which happened and the dialog keeps what they typed.
4. **Given** a draft or cancelled order, **When** the user views it, **Then** print and email are not offered.

---

### User Story 5 - Correct or cancel a draft (Priority: P3)

A buyer edits a draft's header and lines, removes lines, or cancels the draft. Cancelling keeps the lines on the order as history and puts their request lines back in Por comprar.

**Why this priority**: Corrections and cancellations are needed but less frequent than creating and confirming.

**Independent Test**: Create an order from Por comprar, cancel it, and check that its lines reappear in Por comprar and that the cancelled order still shows its lines read-only.

**Acceptance Scenarios**:

1. **Given** a draft, **When** a user with update access changes the supplier, estimated receipt date, notes, or a line's warehouse, quantity, price or tax rate, or deletes a line, **Then** the change is saved and the totals update.
2. **Given** a draft, **When** a user with delete access cancels it and confirms, **Then** the order becomes cancelled and read-only, keeps its lines, and its request lines are pending again.
3. **Given** a confirmed order, **When** the user views it, **Then** cancel is not offered.

---

### Edge Cases

- An estimated receipt date in the past is not selectable; the server's refusal is shown if it happens anyway.
- A line's warehouse that is in transit is refused by the server; the refusal is shown in Spanish.
- Two users confirm the same draft at once: the second sees the server's refusal and the order reloads as confirmed.
- Pulling a request's lines when it has none pending, or whose request is no longer approved, shows the matching Spanish message.
- Por comprar is empty: the screen says there is nothing pending to order.
- A Por comprar group's estimated total counts lines without cost as 0.
- A user without update access opens a draft: it is read-only and no edit, confirm or email action is shown.
- A receipt created by confirming belongs to a facility the user cannot see: the order still lists it, and opening it follows the receipts screen's own access rules.
- An order whose lines were added by hand has no request reference on those lines; lines from requests show their request folio.

## Requirements *(mandatory)*

### Functional Requirements

**Navigation and access**

- **FR-001**: The back office MUST add "Órdenes de compra" and "Por comprar" to the Compras navigation group, offered to users with read access to purchase orders (system object 20).
- **FR-002**: Every action MUST mirror the server's rights on object 20: read to list, view, print and see Por comprar; create to create an order by hand or from a Por comprar group; update to edit, add request lines, confirm and email; delete to cancel. Actions the user lacks the right for MUST NOT be shown.
- **FR-003**: Orders MUST NOT be limited to the user's facility in any screen; the UI MUST NOT filter them by facility.

**List**

- **FR-004**: The list MUST show by default the orders the server returns for the user, and MUST let the user switch to everyone's. The UI MUST NOT widen or narrow either scope itself.
- **FR-005**: The list MUST filter by state (draft, confirmed, cancelled), supplier, creator and date range, and search by order number, through the shared filter drawer.
- **FR-006**: Each row MUST show the number, supplier, state, estimated receipt date, creator, date, number of lines and total.

**Por comprar**

- **FR-007**: Por comprar MUST show one group per supplier and destination facility, each with its supplier name (or "Sin proveedor"), facility, line count and estimated total, and MUST let the user see each group's lines with their request folio, product code and name, quantity, warehouse and cost.
- **FR-008**: Users with create access MUST be able to create a draft order from a group that has a supplier, and MUST land on the new order. A "Sin proveedor" group MUST NOT offer this.
- **FR-009**: After creating an order from a group, Por comprar MUST reflect that the group's lines are no longer pending.
- **FR-031**: Por comprar MUST offer a facility filter in the shared filter drawer. Supplier filter, product search and pagination MUST be added through the server once mictlanix/mbe-api#354 ships; until then Por comprar is a recorded exception to §VI's search and pagination rule, and the UI MUST NOT filter, search or page the groups itself.

**Header**

- **FR-010**: Users with create access MUST be able to start an order by hand by choosing a supplier and, optionally, an estimated receipt date and notes.
- **FR-011**: On a draft, users with update access MUST be able to change the supplier, the estimated receipt date (not in the past) and the notes (up to 500 characters).
- **FR-012**: The order MUST show its number, state, creator, creation date and, once confirmed, its subtotal, tax and total.

**Lines**

- **FR-013**: On a draft, users with update access MUST be able to add a purchasable product, change a line's destination warehouse, quantity, unit price and tax rate, and delete a line.
- **FR-014**: A new line MUST start with the defaults the server returns: the user's point-of-sale warehouse, the product's cost as unit price (0 when none) and the product's tax rate.
- **FR-015**: A quantity MUST be greater than 0 with at most 4 decimals, and a unit price at least 0 with at most 7 decimals; the UI MUST NOT allow saving any other.
- **FR-016**: Each line MUST show its product code and name, warehouse, quantity, unit price, tax rate and amount, and the request folio when it came from a request.
- **FR-017**: On a draft, users with update access MUST be able to add the pending lines of one approved request, chosen by its folio.
- **FR-018**: When adding lines (from a group or a request) leaves some out because another order already holds them, the UI MUST say in Spanish how many lines were left out.
- **FR-019**: The UI MUST show a Spanish warning, computed from the order's own figures, for a line priced at 0. It MUST NOT show the server's English warning text. A warning for a line whose product's supplier differs from the order's MUST NOT be built client-side; it is added from the server's coded warning once mictlanix/mbe-api#353 ships.
- **FR-020**: Discount, currency, exchange rate and tax-included MUST NOT be shown or editable.

**Confirm and receipts**

- **FR-021**: Users with update access MUST be able to confirm a draft that has a supplier and at least one line, all with quantity above 0. When any line is priced at 0, the UI MUST ask for confirmation naming those lines before confirming.
- **FR-022**: A confirmed order MUST list the receipts the server returns for it, each with its number, warehouse, facility and line count, and each MUST open the existing receipt screen. Right after confirming, these are the receipts the confirm created. Once mictlanix/mbe-api#355 ships, every load of the order MUST list all its linked receipts with a state chip; until then a reloaded order shows no receipt list and the UI MUST NOT look receipts up by other means.
- **FR-023**: A confirmed order's stockable lines MUST show the quantity received (on confirmed receipts) and pending; non-stockable lines MUST show neither.

**Cancel**

- **FR-024**: Users with delete access MUST be able to cancel a draft after confirming the action. A confirmed or cancelled order MUST NOT offer cancel.
- **FR-025**: A cancelled order MUST remain viewable, read-only, with its lines.

**Print and email**

- **FR-026**: Users with read access MUST be able to print a confirmed order's PDF; draft and cancelled orders MUST NOT offer print.
- **FR-027**: Users with update access MUST be able to email a confirmed order's PDF to 1 to 10 addresses with an optional message of up to 1,000 characters. The addresses MUST start as the supplier's contacts' email addresses, editable.
- **FR-028**: A successful send MUST show a confirmation. A refused send and mail not being configured MUST each show their own Spanish message and keep the dialog's input.

**Errors**

- **FR-029**: Every server refusal MUST be shown in Spanish from its error code, following the localized API errors rule (constitution §III), including no supplier, no lines, line without quantity, already cancelled, confirmed cannot cancel, not confirmed, nothing pending, nothing to add and request not approved.

**Links from existing screens**

- **FR-030**: The purchase request detail (spec 079) and the warehouse receipt detail (spec 067) MUST show the order number they already display as a link to the order detail for users with read access to purchase orders (object 20), and as plain text for everyone else.

### Key Entities

- **Purchase order**: number, state, supplier, estimated receipt date, notes, creator and last updater, dates, line count, subtotal, tax, total.
- **Purchase order line**: product (code and name as ordered), destination warehouse, quantity, unit price before tax, tax rate, amount, originating request line and request, quantity received and pending.
- **Order receipt**: a warehouse receipt linked to the order, created on confirm (one per destination warehouse) or later as a complementary receipt; number, warehouse, facility, line count, and state once mictlanix/mbe-api#355 ships.
- **Por comprar group**: supplier (or none), destination facility, line count, estimated total, and its pending request lines.
- **Order email**: recipients (1–10) and optional message.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A buyer turns a Por comprar group into a confirmed order in under 1 minute, with no retyping of products or quantities.
- **SC-002**: A buyer writes, confirms, prints and emails a 5-line order by hand in under 4 minutes.
- **SC-003**: Right after confirming, the order shows every receipt it created and each opens from the order in 100% of cases; once mictlanix/mbe-api#355 ships, the same holds on every reopen.
- **SC-004**: For any confirmed order, the received and pending quantities shown match its confirmed receipts in 100% of checked cases.
- **SC-005**: No server message reaches the user in English: every refusal and warning in these screens appears in Spanish.
- **SC-006**: The 17 legacy purchase-order actions are covered or deliberately dropped (approval, §4), with each one accounted for in the plan.

## Assumptions

- Purchase orders join the "Compras" navigation group added in spec 079, after Solicitudes de compra and Aprobación de solicitudes. The Spanish names follow the legacy system ("Órdenes de Compra").
- There is no purchase order approval. The server stores the approved flag and approver as unused; the UI does not show them, nor the unused invoice number.
- The server's warnings and the reasons for left-out lines are English text with no code, so the UI does not show them. The price-0 warning is computed by the UI in Spanish, and left-out lines are reported by count (FR-018, FR-019). The supplier-mismatch warning cannot be computed client-side (lines don't carry the product's supplier); coded warnings and skip reasons are requested in mictlanix/mbe-api#353, following mbe-api#322.
- List rows and lines carry ids for warehouse, creator and facility, not always names; how names are shown follows the pattern already used for receipts and requests and is decided in planning.
- Receipts created on confirm are the spec 067 receipts; receiving goods, complementary receipts and over-receipt warnings stay in that screen. Confirming a receipt updates average cost on the server; nothing in this spec triggers or shows that beyond the receipt itself.
- The cost-change history (GET /cost-changes) is out of scope: the issue's title names receipts, PDF and email but not cost averaging, which the server applies by itself.
- Por comprar ships without search or pagination until mictlanix/mbe-api#354 adds them (FR-031). The list empties as lines are ordered, which keeps it small in practice, but that is not a guarantee, hence the server request.
- Supplier payments applied to an order (GET /{id}/payments) belong to mictlanix/mbe-roadmap#75 and are out of scope.
- Printing uses the same PDF viewing or download behavior as the other back-office documents (spec 044).
- Live verification needs, in the dev tenant, an approved purchase request with marked lines, a purchasable product with a supplier and a cost, one without cost, a supplier with an email contact, and mail configured on the server.
