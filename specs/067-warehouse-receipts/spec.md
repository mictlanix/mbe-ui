# Feature Specification: Warehouse Receipts

**Feature Branch**: `067-warehouse-receipts`

**Created**: 2026-11-16

**Status**: Draft

**Input**: Covers mictlanix/mbe-roadmap#59 ([UI] Warehouse receipts). Scope 04 §1 Inventory Receipts (mbe-api `docs/specs/04-inventory.md`; SystemObject InventoryReceipts 15). Weight: 9 legacy actions. User description: "Warehouse receipts ('Entradas de almacén') back-office UI. The generated client already exposes the inventory-receipts routes (list, create, get, update header, add/update/delete lines, confirm, cancel, complementary). Cover: the list view (default scope, wider view for administrators and AllowDelete, status and warehouse filters, newest first); create a draft; edit the draft header; line items; non-blocking over-receipt warnings; Confirm; Cancel; the complementary-receipt action. Rights mirror the server: Read/Create/Update/Delete on InventoryReceipts, plus the facility rule."

## Context

This adds the back office's first inventory screen. A warehouse receipt ("entrada de almacén") records goods that arrive at a warehouse. It usually follows a purchase order but can stand alone. The server work is done (mbe-api spec 029, with cost updates from spec 031), and the generated client has every route this spec needs.

A receipt is in one of three states:

| State | Meaning | Editable |
|---|---|---|
| Draft | Being prepared; no folio | Yes |
| Completed | Confirmed; folio assigned, stock added to the warehouse | No (can only be cancelled) |
| Cancelled | Cancelled; a completed one had its stock taken back out | No |

There is no purchase-order screen in the new MBE yet. A receipt is linked to a purchase order only by the server: by the complementary action, by the future Purchasing work, or because it is a legacy receipt.

## Clarifications

### Session 2026-11-16

- Q: The server applies the facility rule only on confirm and cancel, so a non-administrator could create a draft in another facility's warehouse that they can never confirm. Which warehouses can a non-administrator pick? → A: In Nueva entrada and Editar encabezado, a non-administrator is offered only the warehouses of their own facility. The list's warehouse filter still offers every warehouse. Administrators are offered every warehouse everywhere.
- Q: A draft has no folio until it is confirmed. How is a draft identified? → A: By its internal number with a "Borrador" prefix. The title is "Entrada · Borrador #{id}", and the list's Folio column shows "Borrador #{id}" until the receipt is confirmed.
- Q: Cost warnings come back only in the confirm or cancel response. Does their notice disappear on its own or stay until read? → A: It stays. It is a band on the detail screen with a close button, shown until the clerk dismisses it or leaves the receipt.
- Q: Which warehouse does Nueva entrada start with? → A: The user's point-of-sale warehouse when they have one, and empty otherwise. The user can always change it.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Find a receipt (Priority: P1)

A warehouse clerk opens "Entradas de almacén" and sees the receipts that concern them: those for their own point-of-sale warehouse and those they created, newest first. They narrow the list by state and by warehouse. Each row shows the folio (once confirmed), warehouse, linked purchase order if any, state, creator and creation date. Administrators, and users with the delete right on receipts, see every receipt and can filter by any warehouse.

**Why this priority**: Every other story starts from this list, and clerks use it to check whether a delivery was already recorded.

**Independent Test**: With a non-administrator account that has read access to receipts, open the list and check that only receipts for the user's warehouse or created by the user appear. Filter by state. Repeat with an administrator and check that every receipt appears.

**Acceptance Scenarios**:

1. **Given** a user with read access to receipts, **When** they open Entradas de almacén, **Then** they see receipts newest first, one page at a time, limited to the scope the server grants them.
2. **Given** the list, **When** the user filters by state (draft, completed, cancelled) or warehouse, **Then** only matching receipts are shown, and the filter button shows how many filters are active.
3. **Given** an administrator or a user with the delete right on receipts, **When** they open the list, **Then** they see every receipt and can filter by any warehouse.
4. **Given** a user without read access to receipts, **When** they look at the navigation, **Then** Entradas de almacén is not offered, and opening its address directly shows the no-access screen.

---

### User Story 2 - Record and confirm a receipt (Priority: P1)

Goods arrive. The clerk creates a receipt, chooses the destination warehouse and optionally adds a note. They add each product received with its quantity. Adding a product that is already on the receipt adds to its quantity instead of creating a second line. When the count matches the delivery, they confirm the receipt. The server gives it the next folio of the facility and adds the stock to the warehouse, and the receipt becomes read-only.

**Why this priority**: This is the core job. Stock that the system does not know about cannot be sold or transferred.

**Independent Test**: Create a receipt for a warehouse, add two stockable products, add one of them again and check that its quantity grows, then confirm. The receipt shows a folio and the Completed state, and the warehouse's stock of each product has grown by the quantity received.

**Acceptance Scenarios**:

1. **Given** a user with create access to receipts, **When** they choose New receipt and a destination warehouse, **Then** a draft opens titled "Entrada · Borrador #{internal number}", with no folio and no lines.
2. **Given** a draft, **When** the user adds a stockable product with a quantity greater than 0, **Then** a line is added showing the product's code and name as they were when the line was added.
3. **Given** a draft that already has a line for a product, **When** the user adds the same product again, **Then** that line's quantity grows by the new amount and no second line appears.
4. **Given** a draft, **When** the user edits a line's quantity or deletes a line, **Then** the receipt shows the change as the server returns it.
5. **Given** a draft, **When** the user tries to add a product that is not stockable, or a quantity of 0 or less, **Then** it is refused with a clear message and the draft is unchanged.
6. **Given** a draft with at least one line, **When** the user confirms it after accepting a confirmation prompt, **Then** it shows the Completed state and its folio, and no longer offers any edit action.
7. **Given** a draft with no lines, **When** the user tries to confirm, **Then** the server's reason is shown and the receipt stays a draft.
8. **Given** a non-administrator and a draft of another facility, **When** they try to confirm it, **Then** the server's refusal (document of another facility) is shown.

---

### User Story 3 - Correct a draft's header (Priority: P2)

Before confirming, the clerk notices the wrong warehouse was chosen, or wants to add a note. On a draft they change the destination warehouse or the notes. Changing the warehouse moves the draft to that warehouse's facility.

**Why this priority**: Mistakes in the destination are common and cheap to fix before confirming, but impossible to fix after.

**Independent Test**: As an administrator, change a draft's warehouse to one of another facility and edit the notes. After reopening the draft, both changes are kept, and the receipt shows the new facility. As a non-administrator, check that the picker offers only their own facility's warehouses.

**Acceptance Scenarios**:

1. **Given** a draft, **When** the user changes its warehouse, **Then** the receipt shows the new warehouse and the facility it belongs to.
2. **Given** a draft, **When** the user enters notes longer than 500 characters, **Then** they cannot save until the notes are shortened.
3. **Given** a non-administrator, **When** they open the warehouse picker to create a receipt or edit a draft, **Then** only the warehouses of their own facility are offered.
4. **Given** a draft, **When** the user chooses an in-transit warehouse, **Then** the server's refusal is shown and the warehouse is unchanged.
5. **Given** a draft linked to a purchase order, **When** the user looks at its warehouse, **Then** it cannot be changed, because the server keeps a linked receipt's warehouse fixed.
6. **Given** a completed or cancelled receipt, **When** the user opens it, **Then** the header cannot be edited.

---

### User Story 4 - Cancel a receipt (Priority: P2)

A receipt was recorded by mistake, or for goods that were sent back. The clerk cancels it. A draft is simply cancelled. A completed receipt is cancelled by taking its stock back out of the warehouse, and the server refuses this if the goods have already left (the warehouse would go negative).

**Why this priority**: Mistakes in stock must be correctable, but cancellation is less frequent than recording.

**Independent Test**: Cancel a draft and check it shows Cancelled. Confirm another receipt, cancel it, and check that the stock it added is gone. Confirm a third, sell or transfer part of its goods, try to cancel it, and check that the server's insufficient-stock reason is shown.

**Acceptance Scenarios**:

1. **Given** a user with the delete right and a draft, **When** they cancel it after accepting a confirmation prompt, **Then** it shows the Cancelled state.
2. **Given** a user with the delete right and a completed receipt whose goods are all still in the warehouse, **When** they cancel it, **Then** it shows the Cancelled state and the warehouse's stock goes back to what it was.
3. **Given** a completed receipt whose goods have partly left the warehouse, **When** the user cancels it, **Then** the server's reason (not enough stock of a product, with what is available) is shown and the receipt stays completed.
4. **Given** a user without the delete right, **When** they open any receipt, **Then** the cancel action is not offered.

---

### User Story 5 - See what a purchase order still owes (Priority: P3)

A receipt linked to a purchase order shows, for each linked line, the quantity ordered and the quantity already received on other confirmed receipts. When the receipt takes a line above what was ordered, a warning names the product and the excess. The warning never blocks saving or confirming.

When a supplier delivers a purchase order in parts, the clerk opens a receipt of that order and chooses Complementary receipt. The system opens the draft that completes the order's delivery to that warehouse: the existing open draft if there is one, otherwise a new draft with one line per under-received order line at the remaining quantity.

**Why this priority**: It matters only for receipts linked to purchase orders, which the new MBE does not create yet. Legacy receipts and future Purchasing work depend on it.

**Independent Test**: Open a confirmed legacy receipt of a completed purchase order that was under-received, choose Complementary receipt, and check that a draft opens with the remaining quantities. Choose it again from the original receipt and check that the same draft opens. Raise a line above its remaining quantity and check that a warning appears and the draft can still be confirmed.

**Acceptance Scenarios**:

1. **Given** a receipt linked to a purchase order, **When** the user opens it, **Then** each linked line shows the quantity ordered and the quantity received elsewhere. Lines added by hand show neither.
2. **Given** a linked receipt whose lines exceed what was ordered, **When** it is opened, a line is saved, or it is confirmed, **Then** a warning names each product and its excess, and the action still succeeds.
3. **Given** a user with create access and a receipt linked to a completed purchase order with under-received lines for its warehouse, **When** they choose Complementary receipt, **Then** a draft opens with one line per under-received order line at the remaining quantity.
4. **Given** an open complementary draft already exists for that order and warehouse, **When** the user chooses Complementary receipt again, **Then** that draft opens and no new one is created.
5. **Given** a receipt with no purchase order, an order that is not completed or is cancelled, or nothing left to receive, **When** the user chooses Complementary receipt, **Then** the server's reason is shown and nothing is created.
6. **Given** a receipt with no linked purchase order, or a cancelled one, **When** the user opens it, **Then** the Complementary receipt action is not offered.

---

### Edge Cases

- A legacy receipt stored the remaining quantity, not the true ordered quantity, in its lines. The screen shows the ordered quantity as the server returns it, which the server reads from the order line.
- A legacy receipt links two of its lines to the same order line. The server sums them for the warning. The screen shows both lines as they are.
- Two clerks edit the same draft. The server applies each change as it arrives. After a save or a refusal, the screen shows the receipt as the server returned it.
- Another clerk confirms or cancels a draft while it is open. The next action is refused with the server's reason, and the screen reloads the receipt in its new state.
- A user can read receipts but not update them: every receipt opens read-only, with no New, edit, confirm or line actions.
- The user leaves a draft with unsaved edits in the header or a line: they are warned before losing them, as in other back-office forms.
- Confirming a receipt linked to a purchase order also updates product costs on the server and may return cost warnings (a product priced at 0, or a cost not restored on cancel). Until mbe-api#322 gives them codes, they are shown as one generic Spanish notice band that stays until the clerk dismisses it or leaves the receipt, and they never block.
- A cancelled receipt opens read-only and offers no actions. The server refuses a complementary receipt started from a cancelled receipt, so the action is not offered there.

## Requirements *(mandatory)*

### Functional Requirements

**List**

- **FR-001**: The back office MUST offer an Entradas de almacén list to users with read access to receipts (system object 15), newest first and paginated.
- **FR-002**: The list MUST show the receipts the server returns for the user's scope. The UI MUST NOT widen or narrow that scope itself.
- **FR-003**: The list MUST filter by state (draft, completed, cancelled) and by warehouse, through the shared filter drawer.
- **FR-004**: Each row MUST show the folio, warehouse, facility, linked purchase order when present, state, creator and creation date. A draft, which has no folio, MUST show "Borrador #{internal number}" in the Folio column instead.
- **FR-004a**: The detail screen's title MUST be "Entrada {folio}" for a confirmed or cancelled receipt, and "Entrada · Borrador #{internal number}" for a draft, so two open drafts can always be told apart.

**Header**

- **FR-005**: Users with create access MUST be able to start a receipt by choosing a destination warehouse and, optionally, entering notes. The warehouse MUST start as the user's point-of-sale warehouse when they have one, and empty otherwise. The user can always change it.
- **FR-006**: On a draft, users with update access MUST be able to change the notes and, when the receipt is not linked to a purchase order, the warehouse. Notes MUST be limited to 500 characters.
- **FR-007**: The receipt MUST show its facility, which follows its warehouse, and its linked purchase order as read-only information.

**Lines**

- **FR-008**: On a draft, users with update access MUST be able to add a product with a quantity greater than 0, change a line's quantity, and delete a line.
- **FR-009**: Adding a product already on the receipt MUST result in one line with the combined quantity, as the server returns it.
- **FR-010**: Each line MUST show the product code and name stored on the line, and its quantity received. A line linked to a purchase-order line MUST also show the quantity ordered and the quantity received elsewhere.
- **FR-011**: The product picker for receipt lines SHOULD offer only stockable products. Any refusal of a non-stockable product MUST be shown.

**Actions**

- **FR-012**: Users with update access MUST be able to confirm a draft after accepting a confirmation prompt. On success the receipt MUST show its folio and the Completed state and become read-only.
- **FR-013**: Users with the delete right MUST be able to cancel a draft or a completed receipt after accepting a confirmation prompt that, for a completed receipt, says its stock will be taken back out of the warehouse.
- **FR-014**: Users with create access MUST be able to request the complementary receipt of a receipt linked to a purchase order. The draft the server returns, existing or new, MUST open.
- **FR-015**: Over-receipt warnings MUST be shown on a linked receipt after opening it, saving a line and confirming, one per order line taken above its ordered quantity, naming the product code, the excess, the total received and the quantity ordered. They MUST be computed from the line figures the server returns (this receipt's quantities summed per order line, plus quantity received elsewhere, against quantity ordered), in Spanish. They MUST NOT block any action.
- **FR-015a**: The server's warning texts are English with no code, so the UI MUST NOT show them. When a confirm or cancel returns more warnings than the over-receipt ones the UI computed (the cost warnings), the UI MUST show one generic Spanish notice that product costs were updated with exceptions. The notice MUST stay on the detail screen as a band with a close button until the clerk dismisses it or leaves the receipt, because reopening the receipt does not bring it back. Coded warnings are requested in mictlanix/mbe-api#322. When they ship, the UI should switch to them.

**Across the feature**

- **FR-016**: Actions the user's rights do not allow MUST be absent, never shown disabled, mirroring the server: read on 15 to see, create on 15 to start a receipt or a complementary receipt, update on 15 to edit the header and lines and to confirm, delete on 15 to cancel. A control that lists other records also needs that record's read right (warehouses to choose or filter a warehouse, products to add a line).
- **FR-017**: The facility rule (a non-administrator acts only on receipts of their own facility) MUST be enforced by the server, and its refusal MUST be shown. To keep a non-administrator from creating a draft they can't confirm, the warehouse picker in Nueva entrada and Editar encabezado MUST offer a non-administrator only the warehouses of their own facility. Administrators MUST be offered every warehouse. The list's warehouse filter MUST offer every warehouse to everyone, since reading is not limited by facility.
- **FR-018**: Every server refusal MUST be shown with the localized text for its error code, never a raw server message or a generic failure. This includes insufficient stock on cancel, the in-transit warehouse, a fixed warehouse, a non-stockable product, a receipt of another facility, a receipt already cancelled, and a complementary receipt that is unavailable.
- **FR-021**: The Complementary receipt action MUST be offered only on a receipt that is linked to a purchase order and not cancelled.
- **FR-019**: After every change the screen MUST show the receipt as the server returned it.
- **FR-020**: All user-facing text MUST be in Spanish, with quantities, dates and folios formatted by the app's shared formatting.

### Key Entities

- **Warehouse receipt**: Goods received into one warehouse. It has a facility (from its warehouse), a folio once confirmed, a state, notes, an optional linked purchase order, its creator and creation date, its lines, and any warnings.
- **Receipt line**: A stockable product and the quantity received, with the product's code and name as they were when the line was added. A line may be linked to a purchase-order line, and then it also carries the quantity ordered and the quantity received on other confirmed receipts.
- **Warehouse**: The destination of the receipt. It belongs to a facility. An in-transit warehouse cannot receive.
- **Purchase order**: Shown only as a reference. It decides whether a complementary receipt is possible and what remains to receive.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A clerk can record and confirm a delivery of 10 products in under 3 minutes.
- **SC-002**: After a receipt is confirmed or cancelled, the warehouse's stock of every product on it matches the receipt, every time.
- **SC-003**: Every server refusal a clerk can trigger on these screens shows a specific Spanish message. None shows a generic error or raw server text.
- **SC-004**: A user with read-only access cannot reach any action that changes a receipt.
- **SC-005**: For an under-received purchase order, the complementary draft's lines and quantities match what the order still owes for that warehouse, every time.

## Assumptions

- Entradas de almacén is the first entry of a new "Inventario" group in the back office's navigation, placed after Logística and before Facturación. Issues, transfers and counts (04 §2 onward) will join it. The editor is reached from the list (New receipt, or opening a receipt).
- Creating a receipt from a purchase order is not in this spec. The Purchasing work (05) will link receipts to orders. Here the purchase order appears only as a read-only reference and as the source of the complementary action.
- The list's default scope (the user's point-of-sale warehouse or their own receipts) and the wider view (administrators and the delete right) are decided by the server. The UI sends only the state and warehouse filters. The legacy numeric search that ignored scope is not carried over, as the server spec says.
- The warehouse picker uses the existing warehouse list. Warehouse records do not say whether they are in transit, so the picker cannot hide them. The server refuses an in-transit warehouse, and the UI shows that refusal.
- The product picker is the existing one, limited to stockable products where it supports that filter.
- Receipts are not printed in this spec. If a printable receipt is wanted, it is a separate roadmap item.
- Live verification needs, in the dev tenant, a stockable product, a warehouse with a point-of-sale user, and a legacy under-received purchase order with a confirmed receipt, for the complementary action.
