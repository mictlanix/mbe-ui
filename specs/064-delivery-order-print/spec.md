# Feature Specification: Delivery Order Print

**Feature Branch**: `064-delivery-order-print`

**Created**: 2026-11-15

**Status**: Implemented

**Input**: User description: mictlanix/mbe-roadmap#43 ([UI] Delivery order print). Scope 06 §6.1 (mbe-api `docs/specs/06-logistics.md` §1 "Print / Ticket"; SystemObject DeliveryOrders 71). Server side done in mbe-api spec 026 (mictlanix/mbe-roadmap#42, closed). Weight: 1 legacy action. Builds on spec 061 (Órdenes de entrega) and spec 044 (document preview).

A delivery leaves the warehouse with a ticket. The driver hands it to the receiver, who signs it. A counter pickup gets its own ticket with a barcode. In the current system staff print these from the delivery orders list: 8,026 tickets in 2026. The new back office lists and manages delivery orders (spec 061) but can't print them, so every delivery still needs the old system.

mbe-api already renders both documents as PDFs:

- **The ticket** (72 mm). The server picks the pickup ticket for a counter pickup and the delivery ticket otherwise. It can be limited to the lines from one warehouse.
- **The Letter format.** A full-page delivery order with a conformity legend and signature lines.

This feature offers them in the back office through the shared document preview from spec 044.

## Clarifications

### Session 2026-11-15

- Q: Where are the print actions offered? → A: On the spec 061 detail screen and as a row action on the Órdenes de entrega list, where the current system offered Print. The Por entregar queue (spec 063) and the approval queue (spec 062) don't get one.
- Q: The current system could limit the ticket to the warehouse of the user's point of sale (379 prints in 2026). Back-office users have a facility, not a point of sale. How is the warehouse limit offered? → A: Only when the order's lines come from two or more warehouses, about 5% of orders. Then the ticket action asks for "Todos los almacenes" or one of the order's warehouses. Otherwise the ticket opens directly with every line.
- Q: The Letter format logged no prints in 2026 (35 since August 2024). Is it offered? → A: Yes, as a secondary action next to the ticket. The server already renders it.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Print a delivery order's ticket from its detail screen (Priority: P1)

A warehouse clerk opens an approved delivery order, taps "Ver ticket" and sees the ticket in the preview. They print it and send it with the goods. For a counter pickup the same action shows the pickup ticket, which the server chooses.

**Why this priority**: The ticket is the delivery's paperwork. Without it, every delivery still goes through the current system.

**Independent Test**: As a user with Delivery Orders read, open an approved delivery order and an approved pickup order. Tap "Ver ticket" on each. The preview shows the server's delivery ticket and pickup ticket, and "Imprimir" and "Descargar" work.

**Acceptance Scenarios**:

1. **Given** an order in Aprobada or any later status, **When** the user opens its detail screen, **Then** "Ver ticket" is offered as a body action.
2. **Given** the detail screen of such an order whose lines all come from one warehouse, **When** the user taps "Ver ticket", **Then** the preview opens with the ticket for every line.
3. **Given** an order in Borrador or Pendiente de aprobación, **When** the user opens its detail screen, **Then** no print action is offered.
4. **Given** a cancelled order, **When** the user taps "Ver ticket", **Then** the preview shows the ticket as the server renders it, marked "CANCELADA".
5. **Given** the preview is open, **When** the user taps "Imprimir" or "Descargar", **Then** the device's print dialog opens, or the PDF is saved under the server's file name (`entrega-00012345.pdf`).

---

### User Story 2 - Print a ticket straight from the list (Priority: P1)

The clerk prints the morning's tickets from the Órdenes de entrega list without opening each order. Each printable row offers "Ver ticket".

**Why this priority**: The current system's Print lived on the list row, and that's where most tickets are printed. Opening every order first would slow the warehouse down.

**Independent Test**: Open the list with orders in several statuses. Approved and later rows offer "Ver ticket", and it opens the same preview as the detail screen. Draft and pending-approval rows don't offer it.

**Acceptance Scenarios**:

1. **Given** the list, **When** a row's order is in Aprobada or a later status, **Then** the row offers "Ver ticket", and it opens the preview without leaving the list.
2. **Given** a row in Borrador or Pendiente de aprobación, **Then** it offers no print action.
3. **Given** the preview opened from a row, **When** the user closes it, **Then** the list keeps its filters, page and scroll position.

---

### User Story 3 - Print only one warehouse's lines (Priority: P2)

An order draws cement from the main warehouse and block from the yard. Each warehouse loads its own part, so each prints a ticket with only its lines. When the clerk taps "Ver ticket", the app asks which lines to print: all of them, or one warehouse's.

**Why this priority**: Only about 5% of orders use two or more warehouses, and printing every line still works for them. It saves paper and confusion at the loading dock.

**Independent Test**: Open an approved order whose lines come from two warehouses. Tap "Ver ticket". Choose one warehouse: the ticket shows only that warehouse's lines. Choose "Todos los almacenes": it shows every line.

**Acceptance Scenarios**:

1. **Given** an order whose lines come from two or more warehouses, **When** the user taps "Ver ticket" on the detail screen or the list row, **Then** the app asks for "Todos los almacenes" or one of those warehouses, by name, before opening the preview.
2. **Given** that choice, **When** the user picks a warehouse, **Then** the preview shows the ticket with only that warehouse's lines, and its title names the warehouse.
3. **Given** that choice, **When** the user dismisses it, **Then** no preview opens and nothing is fetched.
4. **Given** an order whose lines all come from one warehouse, **When** the user taps "Ver ticket", **Then** the app doesn't ask and the preview opens with every line.

---

### User Story 4 - Print the Letter format (Priority: P3)

A branch that delivers concrete prints the order on Letter paper. The receiver signs that they checked the concrete before unloading. On the detail screen the clerk taps "Ver formato carta".

**Why this priority**: The format logged no prints in 2026. It's offered because the server renders it and one branch is configured for it.

**Independent Test**: Open an approved order's detail screen and tap "Ver formato carta". The preview shows a Letter-size document and downloads it as `orden-entrega-00012345.pdf`.

**Acceptance Scenarios**:

1. **Given** the detail screen of an order in Aprobada or later, **Then** "Ver formato carta" is offered next to "Ver ticket", less prominent than it.
2. **Given** the user taps it, **Then** the preview opens with the Letter document, which has every line whatever the warehouses. No warehouse choice is asked.
3. **Given** a list row, **Then** "Ver formato carta" is not offered there.

---

### Edge Cases

- **No Delivery Orders read.** The user can't reach the list or the detail screen, so nothing is offered. If the right is revoked mid-session, the preview's own access check (spec 044) refuses before fetching and shows the shared generic message. That refusal carries no server code, so it isn't translated per case. A refusal from the server (`auth.forbidden`) shows its localized message.
- **Status changed since the screen loaded.** Another user cancels or approves the order in the meantime. The app offers the action from the status it shows. Whatever the server decides when the document is requested wins: a cancelled order prints marked "CANCELADA", and a refusal shows the server's message in the preview.
- **A warehouse emptied since the screen loaded.** The user picks a warehouse whose lines were removed meanwhile. The server refuses ("no line of this order comes from that warehouse") and the preview shows that message with a retry.
- **Warehouse names the user can't read.** The warehouse choice shows the warehouse number instead of its name, as spec 061 does elsewhere.
- **Warehouses can't be determined from the list.** A list row doesn't carry the order's lines, so the app looks the order up when "Ver ticket" is tapped. Pressing again during the lookup does nothing. If the lookup fails, its message shows briefly and no preview opens. *(Amended at plan time, research R5: the row icon shows no busy state, since the shared row action has none and the lookup is a single quick read.)*
- **Repeated taps.** Pressing "Ver ticket" or "Ver formato carta" again while a document or the warehouse lookup is loading starts nothing new.
- **Unsaved edits on a draft.** Drafts offer no print, so a print never races an edit in progress.
- **Phone-sized screens.** The preview fills the screen (spec 044). The warehouse choice fits a phone screen.

## Requirements *(mandatory)*

### Functional Requirements

**Where the documents are offered**

- **FR-001**: The delivery order detail screen (spec 061) MUST offer "Ver ticket" and "Ver formato carta" as body actions, never in the app bar. "Ver formato carta" MUST be visually secondary to "Ver ticket".
- **FR-002**: Each printable row of the Órdenes de entrega list MUST offer "Ver ticket" as a row action. It MUST follow the list's existing row-action limit before folding into an overflow menu. The list MUST NOT offer "Ver formato carta".
- **FR-003**: The print actions MUST be offered only for orders in Aprobada or a later status, cancelled orders included. They MUST NOT be offered for Borrador or Pendiente de aprobación. This matches what the server accepts.
- **FR-004**: The print actions MUST be offered only to users with the read privilege on delivery orders, which the server requires. Each action MUST re-check the privilege immediately before fetching.

**Warehouse choice**

- **FR-010**: When an order's lines come from two or more distinct warehouses, "Ver ticket" MUST first ask the user to choose "Todos los almacenes" or one of those warehouses. The choice MUST list only the warehouses the order's lines come from, by name (number when the name can't be read), with "Todos los almacenes" first and preselected.
- **FR-011**: When the order's lines all come from one warehouse, "Ver ticket" MUST NOT ask, and MUST open the ticket with every line.
- **FR-012**: Choosing a warehouse MUST open the ticket limited to that warehouse's lines. "Todos los almacenes" MUST open the ticket unlimited. Dismissing the choice MUST open nothing.
- **FR-013**: A ticket limited to one warehouse MUST say which warehouse in the preview's title.
- **FR-014**: "Ver formato carta" MUST always open the full document, with no warehouse choice.

**Preview and content**

- **FR-020**: Both documents MUST open in the shared document preview from spec 044, with its zoom, page indicator, "Imprimir" and "Descargar", loading state, error with retry, and repeated-press protection.
- **FR-021**: The preview title MUST identify the document and the order's folio, for example "Ticket de entrega · 12345" or "Orden de entrega · 12345 (carta)".
- **FR-022**: The document shown, printed and downloaded MUST be exactly the one mbe-api produced. mbe-ui MUST NOT choose between the delivery and pickup tickets, alter content, or add the "CANCELADA" mark itself. A download MUST use the server's file name.
- **FR-023**: Each open MUST fetch the current document. Nothing is cached.

**Errors**

- **FR-030**: When the server refuses a document, the preview MUST show its explanation in the user's language, from the server's error code where it gives one (constitution §III): order not approved yet, unknown warehouse, no line from that warehouse, order not found, insufficient privileges. Any other refusal falls back to the server's text or a generic message.

**After the preview**

- **FR-040**: Closing the preview MUST return the user to the screen they came from in the same state: the detail screen as it was, or the list with its filters, page and scroll position.
- **FR-041**: Printing MUST NOT change the order or record anything. The list and the detail screen MUST NOT reload because of a print.

**Language**

- **FR-050**: All new labels and messages MUST be available in Spanish (es-MX, the default) and English.

### Key Entities

- **Delivery order** (spec 061): has a folio, a status, a type (delivery or counter pickup) and lines. Its status decides whether it can print. Its type decides which ticket the server renders.
- **Delivery order line**: leaves from one warehouse. The set of distinct warehouses across an order's lines decides whether the warehouse choice is asked.
- **Delivery ticket**: the 72 mm document from the server: the delivery ticket for a delivery, the pickup ticket for a counter pickup. Optionally limited to one warehouse's lines.
- **Letter format**: the Letter-size delivery order document from the server, always with every line.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A clerk can print an approved order's ticket from the list in at most 3 interactions (row action, Imprimir, confirm the print dialog) when the order uses one warehouse, and 4 when it uses several.
- **SC-002**: In every walkthrough case, an order offers the print actions exactly when its status is Aprobada or later and the user has Delivery Orders read, and never otherwise.
- **SC-003**: The ticket for a counter pickup is the pickup ticket and the ticket for a delivery is the delivery ticket, in 100% of the walkthrough cases, with no choice by the user.
- **SC-004**: A ticket limited to one warehouse contains only that warehouse's lines, and an unlimited one contains all of them, in every walkthrough case with a multi-warehouse order.
- **SC-005**: Every server refusal of a print (order not approved, unknown warehouse, warehouse with no lines, missing privilege) shows a message the user can act on, in Spanish and in English. A refusal by the app's own access check before any request shows the shared generic message (spec 044).
- **SC-006**: Staff can print every delivery order ticket from the new back office, with no trip to the current system.

## Assumptions

- **Server.** mbe-api spec 026 is deployed and the generated client already has both document requests (ticket, with an optional warehouse, and the Letter document). No server change is needed.
- **Server rules the client mirrors.** Both documents need Read on Delivery Orders (71). Borrador and Pendiente de aprobación are refused as a conflict. A cancelled order renders stamped "CANCELADA". A warehouse no line comes from, or one that doesn't exist, is refused as invalid input. Its error codes are `delivery_order.not_approved`, `delivery_order.unknown_warehouse` and `delivery_order.no_lines_from_warehouse`.
- **Statuses.** "Aprobada or later" means Aprobada, Lista para recoger, En preparación, En tránsito, Entregada, Entregada parcialmente, Recogida, Fallida and Cancelada: every status except Borrador and Pendiente de aprobación.
- **Preview.** Spec 044's shared preview is reused unchanged, including its web limits: a cancelled browser print dialog can't be detected.
- **Warehouse limit differs from the current system.** The current system limited the ticket to the warehouse of the user's point of sale and offered it on the list row only when a line came from there. Back-office users have no point of sale, so the user chooses among the order's own warehouses instead. This was chosen during clarification.
- **Itinerary documents are out of scope.** The itinerary ticket and the delivery notes (mbe-api spec 026, User Story 2) ship with itineraries (mictlanix/mbe-roadmap#41).
- **Other screens.** The Por entregar queue (spec 063) and the approval queue (spec 062) get no print action in this feature.
- **No direct-to-printer.** Every print goes through the preview. A send-straight-to-printer path is for later, as spec 044 left room for.
- **Manual checks.** The checks automation can't cover, including the two-warehouse walkthrough the live test skipped (the dev tenant has no such order), are tracked in mictlanix/mbe-ui#251.
