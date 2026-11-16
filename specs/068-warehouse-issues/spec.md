# Feature Specification: Warehouse Issues

**Feature Branch**: `068-warehouse-issues`

**Created**: 2026-11-16

**Status**: Draft

**Input**: Covers mictlanix/mbe-roadmap#61 ([UI] Warehouse issues). Scope 04 §2 Inventory Issues (mbe-api `docs/specs/04-inventory.md`; SystemObject InventoryIssues 16). Weight: 7 legacy actions. User description: "Warehouse issues ('Salidas de almacén') back-office list and editor, for goods leaving a warehouse other than by sale (write-offs, waste, damage, internal consumption); the reason goes in the notes. Mirrors spec 067 (warehouse receipts) without the complementary receipt, the purchase-order link and quantities ordered, and without warnings. States draft → completed → cancelled. List scope, filters and wider view as receipts. Header: source warehouse (not in transit; facility follows it), folio on confirm, notes up to 500 characters, linked supplier return read-only if stored. Lines: stockable product and quantity greater than 0, editable only on drafts. Confirm refuses when available stock is short, naming the product and warehouse. Cancelling a confirmed issue returns the stock. Rights: Read, Create, Update (edit and confirm), Delete (cancel), plus the facility rule. Lots, serials and FIFO are out of scope."

## Context

This adds the second screen of the back office's "Inventario" group, next to Entradas de almacén (spec 067). A warehouse issue ("salida de almacén") records goods that leave a warehouse for a reason other than a sale: a write-off, waste, damage or internal consumption. There is no reason field. The clerk writes the reason in the notes. The server work is done (mbe-api spec 029), and the generated client has every route this spec needs.

An issue is in one of three states:

| State | Meaning | Editable |
|---|---|---|
| Draft | Being prepared; no folio | Yes |
| Completed | Confirmed; folio assigned, stock taken out of the warehouse | No (can only be cancelled) |
| Cancelled | Cancelled; a completed one had its stock put back | No |

An issue works like a receipt in reverse. Three things are different. An issue has no purchase order and no complementary action. The server returns no warnings for issues. Confirming can be refused when the warehouse does not have enough stock, while a receipt's confirm cannot.

Supplier returns are not built in the new MBE. An issue may still carry a link to a legacy supplier return. It is shown but never set or changed here.

### Decisions carried over from spec 067

These were settled for receipts on 2026-11-16 and apply to issues the same way, so the two screens behave alike:

- In Nueva salida and Editar encabezado, a non-administrator is offered only the warehouses of their own facility. Administrators are offered every warehouse. The list's warehouse filter offers every warehouse to everyone.
- A draft is identified as "Borrador #{internal number}": the title is "Salida · Borrador #{id}", and the list's Folio column shows "Borrador #{id}" until the issue is confirmed.
- Nueva salida starts with the user's point-of-sale warehouse when they have one (and, for a non-administrator, when it is in their own facility), and empty otherwise. The user can always change it.

## Clarifications

### Session 2026-11-16

- Q: The reason for an issue goes in the notes, which the server allows empty. Should the screen require it, and how is the field labelled? → A: Notes stay optional. The field is labelled "Motivo / notas", with a hint listing typical reasons (merma, daño, consumo).
- Q: Only legacy issues carry a supplier-return link. Where is it shown? → A: As a read-only "Devolución a proveedor #{id}" fact on the detail screen, only when stored. The list has no column for it.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Find an issue (Priority: P1)

A warehouse clerk opens "Salidas de almacén" and sees the issues that concern them: those for their own point-of-sale warehouse and those they created, newest first. They narrow the list by state and by warehouse. Each row shows the folio (once confirmed), warehouse, facility, state, creator and creation date. Administrators, and users with the delete right on issues, see every issue and can filter by any warehouse.

**Why this priority**: Every other story starts from this list, and clerks use it to check whether a write-off was already recorded.

**Independent Test**: With a non-administrator account that has read access to issues, open the list and check that only issues for the user's warehouse or created by the user appear. Filter by state. Repeat with an administrator and check that every issue appears.

**Acceptance Scenarios**:

1. **Given** a user with read access to issues, **When** they open Salidas de almacén, **Then** they see issues newest first, one page at a time, limited to the scope the server grants them.
2. **Given** the list, **When** the user filters by state (draft, completed, cancelled) or warehouse, **Then** only matching issues are shown, and the filter button shows how many filters are active.
3. **Given** an administrator or a user with the delete right on issues, **When** they open the list, **Then** they see every issue and can filter by any warehouse.
4. **Given** a user without read access to issues, **When** they look at the navigation, **Then** Salidas de almacén is not offered, and opening its address directly is redirected to the home page (the app's route gate).

---

### User Story 2 - Record and confirm an issue (Priority: P1)

Goods were damaged, expired or used up inside the business. The clerk creates an issue, chooses the warehouse the goods leave from, and writes the reason in the notes. They add each product with its quantity. Adding a product that is already on the issue adds to its quantity instead of creating a second line. When the list matches what left, they confirm the issue. The server checks that the warehouse has enough available stock, gives the issue the next folio of the facility and takes the stock out, and the issue becomes read-only.

**Why this priority**: This is the core job. Stock that has physically left but is still on record gets sold or transferred when it does not exist.

**Independent Test**: Create an issue for a warehouse with stock, add two stockable products, add one of them again and check that its quantity grows, then confirm. The issue shows a folio and the Completed state, and the warehouse's stock of each product has dropped by the quantity issued.

**Acceptance Scenarios**:

1. **Given** a user with create access to issues, **When** they choose Nueva salida and a source warehouse, **Then** a draft opens titled "Salida · Borrador #{internal number}", with no folio and no lines.
2. **Given** a draft, **When** the user adds a stockable product with a quantity greater than 0, **Then** a line is added showing the product's code and name as they were when the line was added.
3. **Given** a draft that already has a line for a product, **When** the user adds the same product again, **Then** that line's quantity grows by the new amount and no second line appears.
4. **Given** a draft, **When** the user edits a line's quantity or deletes a line, **Then** the issue shows the change as the server returns it.
5. **Given** a draft, **When** the user tries to add a product that is not stockable, or a quantity of 0 or less, **Then** it is refused with a clear message and the draft is unchanged.
6. **Given** a draft with at least one line and enough available stock, **When** the user confirms it after accepting a confirmation prompt that says the stock will be taken out of the warehouse, **Then** it shows the Completed state and its folio, and no longer offers any edit action.
7. **Given** a draft whose lines of one product together exceed that product's available stock in the warehouse, **When** the user confirms, **Then** the server's reason (not enough stock of the product in the warehouse) is shown, the issue stays a draft, and no folio is used.
8. **Given** a draft with no lines, **When** the user tries to confirm, **Then** the server's reason is shown and the issue stays a draft.
9. **Given** a non-administrator and a draft of another facility, **When** they try to confirm it, **Then** the server's refusal (document of another facility) is shown.

---

### User Story 3 - Correct a draft's header (Priority: P2)

Before confirming, the clerk notices the wrong warehouse was chosen, or wants to make the reason clearer. On a draft they change the source warehouse or the notes. Changing the warehouse moves the draft to that warehouse's facility.

**Why this priority**: A wrong source warehouse takes stock out of the wrong place. It is cheap to fix before confirming and needs a cancel and a new issue after.

**Independent Test**: As an administrator, change a draft's warehouse to one of another facility and edit the notes. After reopening the draft, both changes are kept, and the issue shows the new facility. As a non-administrator, check that the picker offers only their own facility's warehouses.

**Acceptance Scenarios**:

1. **Given** a draft, **When** the user changes its warehouse, **Then** the issue shows the new warehouse and the facility it belongs to.
2. **Given** a draft, **When** the user enters notes longer than 500 characters, **Then** they cannot save until the notes are shortened.
3. **Given** a non-administrator, **When** they open the warehouse picker to create an issue or edit a draft, **Then** only the warehouses of their own facility are offered.
4. **Given** a draft, **When** the user chooses an in-transit warehouse, **Then** the server's refusal is shown and the warehouse is unchanged.
5. **Given** a completed or cancelled issue, **When** the user opens it, **Then** the header cannot be edited.

---

### User Story 4 - Cancel an issue (Priority: P2)

An issue was recorded by mistake, or the goods turned out to be fine. The clerk cancels it. A draft is simply cancelled. A completed issue is cancelled by putting its stock back into the warehouse.

**Why this priority**: Mistakes in stock must be correctable, but cancellation is less frequent than recording.

**Independent Test**: Cancel a draft and check it shows Cancelled. Confirm another issue, cancel it, and check that the warehouse's stock of each product is back to what it was before the issue was confirmed.

**Acceptance Scenarios**:

1. **Given** a user with the delete right and a draft, **When** they cancel it after accepting a confirmation prompt, **Then** it shows the Cancelled state.
2. **Given** a user with the delete right and a completed issue, **When** they cancel it after accepting a confirmation prompt that says the stock will be put back into the warehouse, **Then** it shows the Cancelled state and the warehouse's stock goes back up by the quantities issued.
3. **Given** a cancelled issue, **When** the user opens it, **Then** no cancel action is offered.
4. **Given** a user without the delete right, **When** they open any issue, **Then** the cancel action is not offered.

---

### Edge Cases

- Two lines of the same product cannot exist (adding the product again grows its line), but the server still checks available stock summed per product, so a legacy issue with two lines of one product is checked as one total.
- Available stock is on-hand stock minus reservations. A warehouse can show stock on hand and still refuse the confirm because part of it is reserved for orders. The refusal says the stock is not enough. The screen does not explain reservations.
- Two clerks edit the same draft. The server applies each change as it arrives. After a save or a refusal, the screen shows the issue as the server returned it.
- Another clerk confirms or cancels a draft while it is open. The next action is refused with the server's reason, and the screen reloads the issue in its new state.
- The warehouse is busy (another stock movement holds it). The server refuses with a "retry" reason, which is shown, and the issue is unchanged.
- A user can read issues but not update them: every issue opens read-only, with no New, edit, confirm or line actions.
- The user leaves a draft with unsaved edits in the header or a line: they are warned before losing them, as in other back-office forms.
- A legacy issue linked to a supplier return shows the return's number as read-only information. Nothing about it can be changed, and there is no supplier-return screen to open.

## Requirements *(mandatory)*

### Functional Requirements

**List**

- **FR-001**: The back office MUST offer a Salidas de almacén list to users with read access to issues (system object 16), newest first and paginated, in the Inventario navigation group after Entradas de almacén.
- **FR-002**: The list MUST show the issues the server returns for the user's scope. The UI MUST NOT widen or narrow that scope itself.
- **FR-003**: The list MUST filter by state (draft, completed, cancelled) and by warehouse, through the shared filter drawer.
- **FR-004**: Each row MUST show the folio, warehouse, facility, state, creator and creation date. A draft, which has no folio, MUST show "Borrador #{internal number}" in the Folio column instead.
- **FR-004a**: The detail screen's title MUST be "Salida {folio}" for a confirmed or cancelled issue, and "Salida · Borrador #{internal number}" for a draft.

**Header**

- **FR-005**: Users with create access MUST be able to start an issue by choosing a source warehouse and, optionally, entering notes. The warehouse MUST start as the user's point-of-sale warehouse when they have one, and empty otherwise. For a non-administrator, the point-of-sale warehouse is used only when it belongs to their own facility (FR-014); otherwise the field starts empty.
- **FR-006**: On a draft, users with update access MUST be able to change the warehouse and the notes. Notes MUST be limited to 500 characters and stay optional, as on the server. The field MUST be labelled "Motivo / notas", in the dialogs and on the detail screen, and its input MUST carry a hint listing typical reasons (merma, daño, consumo).
- **FR-007**: The issue MUST show its facility, which follows its warehouse, as read-only information. When a supplier return is stored, the detail screen MUST also show it as a read-only "Devolución a proveedor #{id}" fact, as plain text with nothing to open. The list MUST NOT have a column for it.

**Lines**

- **FR-008**: On a draft, users with update access MUST be able to add a product with a quantity greater than 0, change a line's quantity, and delete a line.
- **FR-009**: Adding a product already on the issue MUST result in one line with the combined quantity, as the server returns it.
- **FR-010**: Each line MUST show the product code and name stored on the line, and its quantity.
- **FR-011**: The product picker for issue lines SHOULD offer only stockable products. Any refusal of a non-stockable product MUST be shown.

**Actions**

- **FR-012**: Users with update access MUST be able to confirm a draft after accepting a confirmation prompt that says the stock will be taken out of the warehouse. On success the issue MUST show its folio and the Completed state and become read-only. When the server refuses for lack of available stock, the issue MUST stay a draft and the refusal MUST name the product and warehouse.
- **FR-013**: Users with the delete right MUST be able to cancel a draft or a completed issue after accepting a confirmation prompt that, for a completed issue, says its stock will be put back into the warehouse.

**Across the feature**

- **FR-014**: Actions the user's rights do not allow MUST be absent, never shown disabled, mirroring the server: read on 16 to see, create on 16 to start an issue, update on 16 to edit the header and lines and to confirm, delete on 16 to cancel. A control that lists other records also needs that record's read right (warehouses to choose or filter a warehouse, products to add a line). The facility rule (a non-administrator acts only on issues of their own facility) is enforced by the server, and its refusal MUST be shown. The warehouse picker in Nueva salida and Editar encabezado MUST offer a non-administrator only the warehouses of their own facility, and administrators every warehouse. The list's warehouse filter MUST offer every warehouse to everyone.
- **FR-015**: Every server refusal MUST be shown with the localized text for its error code, never a raw server message or a generic failure. This includes insufficient stock on confirm, the in-transit warehouse, a non-stockable product, an issue of another facility, an issue already cancelled, a confirm with no lines, and a busy warehouse.
- **FR-016**: After every change the screen MUST show the issue as the server returned it.
- **FR-017**: All user-facing text MUST be in Spanish, with quantities, dates and folios formatted by the app's shared formatting.
- **FR-018**: Salidas de almacén MUST look and behave like Entradas de almacén wherever the two documents work the same way (list columns and filters, header, lines, confirm and cancel prompts, draft naming), so a clerk who knows one knows the other.

### Key Entities

- **Warehouse issue**: Goods taken out of one warehouse other than by sale. It has a facility (from its warehouse), a folio once confirmed, a state, notes holding the reason, an optional legacy supplier-return link, its creator and creation date, and its lines.
- **Issue line**: A stockable product and the quantity taken out, with the product's code and name as they were when the line was added.
- **Warehouse**: The source of the issue. It belongs to a facility. An in-transit warehouse cannot issue.
- **Available stock**: The warehouse's on-hand stock of a product minus what is reserved. The server checks it on confirm. It is not shown on these screens.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A clerk can record and confirm a write-off of 10 products in under 3 minutes.
- **SC-002**: After an issue is confirmed or cancelled, the warehouse's stock of every product on it matches the issue, every time.
- **SC-003**: An issue that asks for more than the warehouse has available is never confirmed, and the clerk is told which product is short.
- **SC-004**: Every server refusal a clerk can trigger on these screens shows a specific Spanish message. None shows a generic error or raw server text.
- **SC-005**: A user with read-only access cannot reach any action that changes an issue.

## Assumptions

- Salidas de almacén joins the Inventario navigation group that spec 067 opened, right after Entradas de almacén. The editor is reached from the list (Nueva salida, or opening an issue).
- The list's default scope (the user's point-of-sale warehouse or their own issues) and the wider view (administrators and the delete right) are decided by the server. The UI sends only the state and warehouse filters.
- The warehouse picker uses the existing warehouse list. Warehouse records do not say whether they are in transit, so the picker cannot hide them. The server refuses an in-transit warehouse, and the UI shows that refusal.
- The editor does not show each product's available stock while the clerk adds lines. The server's check on confirm is the guard, and its refusal names the short product. Showing stock while editing can be a later improvement.
- Lots, serials, expiry and FIFO consumption are out of scope, as in the server.
- Supplier returns are not built. Creating an issue from a supplier return is not in this spec.
- Issues are not printed in this spec. If a printable issue is wanted, it is a separate roadmap item.
- Live verification needs, in the dev tenant, a stockable product with stock in a warehouse that has a point-of-sale user, and a product with less available stock than an issue asks for, to trigger the insufficient-stock refusal.
