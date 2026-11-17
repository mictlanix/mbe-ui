# Feature Specification: Physical Inventory Counts

**Feature Branch**: `070-inventory-adjustments-count`

**Created**: 2026-11-17

**Status**: Draft

**Input**: Covers mictlanix/mbe-roadmap#65 ([UI] Inventory adjustments and physical count). Scope 04 §4–5 (mbe-api `docs/specs/04-inventory.md`: §4 Inventory Adjustments, SystemObject InventoryAdjustments 93; §5 Physical Count, SystemObject PhysicalCountAdjustment 74). Weight: 3 legacy actions. User description: "Inventory adjustments and physical count — mictlanix/mbe-roadmap#65. Scope: mbe-api docs/specs 04 §4–5 (3 legacy actions)."

## Context

This adds the fourth screen of the back office's "Inventario" group, after Entradas de almacén (spec 067), Salidas de almacén (spec 068) and Traspasos (spec 069). A physical count ("conteo físico") corrects a warehouse's stock after the clerks have counted it. They enter what they counted per product. Confirming the count posts, for each product, the difference between what was counted and what the stock records held at that moment.

The roadmap item names two legacy features. The server builds only one:

- **Inventory adjustments (§4)** are not built. The legacy manual adjustment form is dropped. A stock correction is made with a physical count, which posts only the difference. This spec therefore has no adjustment screen, and system object 93 is not used.
- **Physical count (§5)** is built by the server (`/inventory-counts`), and the generated client has every route this spec needs.

A count is in one of three states:

| State | Meaning | Editable |
|---|---|---|
| Draft | Being counted; no folio; expected stock hidden | Yes |
| Completed | Confirmed; folio assigned, differences posted to stock | No, and it can never be cancelled |
| Cancelled | A draft that was dropped; nothing was posted | No |

A count differs from receipts and issues in four ways:

- **It is blind.** While the count is a draft, neither the screen nor the server shows how much stock the records expect. The clerk enters only what they see. Expected stock and the difference appear on each line after confirming.
- **A line's quantity replaces, never adds.** There is one line per product. Entering a product that is already on the count overwrites its quantity. A quantity of 0 is valid (the product was looked for and not found).
- **A confirmed count cannot be cancelled.** A mistake is corrected with a new count.
- **Confirming returns warnings that never block**: products whose counted quantity is below what is reserved for orders, and products that another confirmed count of the same warehouse corrected since this count was started.

### Decisions carried over from specs 067–069

These were settled for the other Inventario documents and apply to counts the same way:

- In Nuevo conteo and Editar encabezado, a non-administrator is offered only the warehouses of their own facility. Administrators are offered every warehouse. The list's warehouse filter offers every warehouse to everyone.
- A draft is identified as "Borrador #{internal number}": the title is "Conteo · Borrador #{id}", and the list's Folio column shows "Borrador #{id}" until the count is confirmed.
- Nuevo conteo starts with the user's point-of-sale warehouse when they have one (and, for a non-administrator, when it is in their own facility), and empty otherwise. The user can always change it.

## Clarifications

### Session 2026-11-17

- Q: How should the editor let clerks enter count lines, given opening counts of about 15,000 lines? → A: All three: the product picker (as on receipts and issues), a quick-entry row (type or scan a code, a quantity, Enter), and pasting a list of code and quantity pairs that is sent in batches of up to 2,000, with bad rows listed.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Find a count (Priority: P1)

A warehouse supervisor opens "Conteos físicos" and sees the counts that concern them: those of their own point-of-sale warehouse and those they created, newest first. They narrow the list by state and by warehouse. Each row shows the folio (once confirmed), warehouse, facility, state, creator and creation date. Administrators, and users with the delete right on counts, see every count and can filter by any warehouse.

**Why this priority**: Every other story starts from this list, and supervisors use it to find a count still in progress or to check when a warehouse was last counted.

**Independent Test**: With a non-administrator account that has read access to counts, open the list and check that only counts of the user's warehouse or created by the user appear. Filter by state. Repeat with an administrator and check that every count appears.

**Acceptance Scenarios**:

1. **Given** a user with read access to counts, **When** they open Conteos físicos, **Then** they see counts newest first, one page at a time, limited to the scope the server grants them.
2. **Given** the list, **When** the user filters by state (draft, completed, cancelled) or warehouse, **Then** only matching counts are shown, and the filter button shows how many filters are active.
3. **Given** an administrator or a user with the delete right on counts, **When** they open the list, **Then** they see every count and can filter by any warehouse.
4. **Given** a user without read access to counts, **When** they look at the navigation, **Then** Conteos físicos is not offered, and opening its address directly is redirected to the home page (the app's route gate).

---

### User Story 2 - Count a warehouse and confirm (Priority: P1)

The supervisor creates a count for a warehouse, with an optional comment (for example "Conteo mensual pasillo 3"). As the clerks count, the supervisor enters each product with the quantity found. Entering a product that is already on the count replaces its quantity. When counting is done, they confirm. They choose whether products that were not counted, but that the records say are in the warehouse, should be counted as 0. The server gives the count the next folio of the facility, compares each line with the stock records at that moment, and posts the differences. The count becomes read-only and now shows, per line, the expected quantity and the difference.

**Why this priority**: This is the only way in the new system to correct stock that does not match reality. Without it, wrong stock can only be fixed with receipts and issues that misstate what happened.

**Independent Test**: Note a product's stock in a warehouse. Create a count for that warehouse, enter that product with a quantity 3 higher than its stock and a second product with 0, enter the first product again with a different quantity and check that its line was replaced, then confirm. The count shows a folio and the Completed state, each line shows the expected quantity and the difference, and the warehouse's stock of each product now equals the counted quantity.

**Acceptance Scenarios**:

1. **Given** a user with create access to counts, **When** they choose Nuevo conteo and a warehouse, **Then** a draft opens titled "Conteo · Borrador #{internal number}", with no folio and no lines.
2. **Given** a draft, **When** the user enters a stockable product with a quantity of 0 or more, **Then** a line appears showing the product's code and name and the counted quantity, and no expected quantity or difference.
3. **Given** a draft that already has a line for a product, **When** the user enters the same product with a new quantity, **Then** that line's quantity becomes the new amount (it is not added), and no second line appears.
4. **Given** a draft, **When** the user edits a line's quantity or deletes a line, **Then** the count shows the change as the server returns it.
5. **Given** a draft, **When** the user enters a product that is not stockable, an unknown product code, or a negative quantity, **Then** it is refused with a clear message and the draft is unchanged.
6. **Given** a draft with at least one line, **When** the user chooses Confirmar, **Then** a prompt says the stock of the warehouse will be set to the counted quantities and that a confirmed count cannot be cancelled, and offers an option, off by default, to count as 0 every product with stock in the warehouse that is not on the count.
7. **Given** that prompt, **When** the user accepts it, **Then** the count shows the Completed state and its folio, each line shows its expected quantity and its difference (counted minus expected), and no edit or cancel action is offered.
8. **Given** a count confirmed with the uncounted option on, **When** the user opens it, **Then** it also has a line with a counted quantity of 0 for each product that had stock and was not counted.
9. **Given** a draft with no lines and the uncounted option off, **When** the user confirms, **Then** the server's reason is shown and the count stays a draft.
10. **Given** a non-administrator and a draft of another facility, **When** they try to confirm it, **Then** the server's refusal (document of another facility) is shown.

---

### User Story 3 - Load a large count fast (Priority: P2)

Clerks count with a handheld scanner, or on paper that someone types into a spreadsheet. On a draft, the supervisor uses the quick-entry row to scan or type a code, type the quantity and press Enter, product after product, without opening the picker. For an opening count of thousands of products, they copy the code and quantity columns from the spreadsheet and paste them into the count. The screen first checks every row and lists the ones it cannot read. When the list is clean, it sends the rows in batches and shows progress. If the server refuses a batch because of an unknown or non-stockable code, sending stops, the bad codes are listed, and the supervisor fixes the spreadsheet and pastes again.

**Why this priority**: The picker alone makes an opening count of 15,000 products impractical, and day-to-day counts are made with a scanner. The count still works without this story, so it follows the core flow.

**Independent Test**: On a draft, enter three products with the quick-entry row using only the keyboard. Then paste 2,500 rows of code and quantity, with one row whose quantity is "abc": the screen lists that row and does not send. Fix it and paste again: the rows are sent in two batches and the count shows 2,500 lines. Paste a list with one unknown code in its second batch: the first batch is applied, sending stops, the unknown code is listed, and the screen says how many rows were applied.

**Acceptance Scenarios**:

1. **Given** a draft, **When** the user types or scans a code, types a quantity and presses Enter, **Then** the line is set (replacing any previous quantity for that product) and the focus returns to the code field.
2. **Given** a draft, **When** the user enters an unknown code in the quick-entry row, **Then** the server's reason is shown, nothing changes, and the entered values stay so the user can correct them.
3. **Given** a draft, **When** the user pastes a list in which some rows have no code, a non-numeric or negative quantity, or more than 4 decimals, or a code appears twice, **Then** every such row is listed with its row number and nothing is sent.
4. **Given** a pasted list with no bad rows, **When** the user sends it, **Then** it is sent in batches of at most 2,000 rows with progress shown, and the count then shows every pasted product with its quantity.
5. **Given** a pasted list whose second batch contains a non-stockable or unknown code, **When** it is sent, **Then** the first batch is applied, sending stops, every bad code of the refused batch is listed, and the screen says how many rows were applied and that pasting the corrected list again is safe.

---

### User Story 4 - Review the warnings of a confirmed count (Priority: P2)

Right after confirming, the supervisor is told about two kinds of situations that did not stop the count but need attention: products whose counted quantity is below what is reserved for open orders, so the warehouse now owes more than it holds; and products that another count of the same warehouse, confirmed after this one was started, had already corrected, so this count may have overwritten a newer correction.

**Why this priority**: The warnings never block and the count is already posted, but missing them leaves orders that cannot be filled or a double correction that nobody checks.

**Independent Test**: Reserve some stock of a product with an open order, count that product below the reserved quantity and confirm. The result names the product with its counted, reserved and available quantities. Start two counts of one warehouse with the same product, confirm the second, then confirm the first: the first's result names the product and the other count's folio.

**Acceptance Scenarios**:

1. **Given** a confirm that returns products counted below their reservations, **When** the count is confirmed, **Then** the screen lists each such product by code with its counted, reserved and available quantities.
2. **Given** a confirm that returns products corrected by other counts, **When** the count is confirmed, **Then** the screen lists each such product by code with the folio of the other count.
3. **Given** a confirm that returns no warnings, **When** the count is confirmed, **Then** no warning is shown.

---

### User Story 5 - Correct a draft's header or drop it (Priority: P3)

Before confirming, the supervisor notices that the wrong warehouse was chosen, or wants to change the comment. On a draft they change the warehouse or the comment. If the count is abandoned, they cancel the draft, and nothing is posted.

**Why this priority**: Less frequent than counting, but a count in the wrong warehouse would set the stock of the wrong place, and it cannot be undone once confirmed.

**Independent Test**: As an administrator, change a draft's warehouse to one of another facility and edit the comment. After reopening, both changes are kept and the count shows the new facility. Cancel another draft and check it shows Cancelled. Open a completed count and check that it offers no cancel.

**Acceptance Scenarios**:

1. **Given** a draft, **When** the user changes its warehouse, **Then** the count shows the new warehouse and the facility it belongs to.
2. **Given** a non-administrator, **When** they open the warehouse picker to create a count or edit a draft, **Then** only the warehouses of their own facility are offered.
3. **Given** a draft, **When** the user chooses an in-transit warehouse, **Then** the server's refusal is shown and the warehouse is unchanged.
4. **Given** a user with the delete right and a draft, **When** they cancel it after accepting a confirmation prompt, **Then** it shows the Cancelled state.
5. **Given** a completed or cancelled count, **When** the user opens it, **Then** the header cannot be edited and no cancel action is offered.

---

### Edge Cases

- **Blind counting**: the editor never shows expected stock on a draft, and neither does any value the server returns for a draft. A user who also has read access to stock reports can look stock up elsewhere; this screen does not link to it while the count is a draft.
- **Large counts**: an opening count may have thousands of lines. The editor stays usable with that many lines: the user can find a line by product code or name instead of scrolling.
- **Large confirm**: confirming a count of many lines holds the warehouse, and other stock movements of that warehouse wait. The confirm prompt does not warn about this; the server answers "the warehouse is busy, retry" if it cannot get the warehouse, and that refusal is shown with the count unchanged.
- **Paste interrupted**: the user leaves the screen or loses the connection while a pasted list is being sent. Batches already applied stay on the draft. Pasting the same list again sets the same quantities, so it is safe to repeat.
- **Pasted header row**: a first row whose quantity is not a number (such as "Código / Cantidad") is reported as an unreadable row like any other; the user removes it before sending.
- **Zero differences** post nothing. A completed count whose lines all match shows every difference as 0.
- Two people edit the same draft. The server applies each change as it arrives. A line's quantity is the last one entered. After a save or a refusal, the screen shows the count as the server returned it.
- Another user confirms or cancels a draft while it is open. The next action is refused with the server's reason, and the screen reloads the count in its new state.
- A user tries to cancel a completed count through a stale screen. The server refuses (a confirmed count cannot be cancelled) and that reason is shown.
- A user can read counts but not update them: every count opens read-only, with no New, edit, confirm or line actions.
- The user leaves a draft with unsaved edits in the header or a line, or closes Pegar lista with pasted text not yet sent: they are warned before losing them, as in other back-office forms.
- Stock records include entries made by legacy adjustments. They remain in the stock history as they were; this spec does not show or change them.

## Requirements *(mandatory)*

### Functional Requirements

**List**

- **FR-001**: The back office MUST offer a Conteos físicos list to users with read access to counts (system object 74), newest first and paginated, in the Inventario navigation group after Traspasos.
- **FR-002**: The list MUST show the counts the server returns for the user's scope. The UI MUST NOT widen or narrow that scope itself.
- **FR-003**: The list MUST filter by state (draft, completed, cancelled) and by warehouse, through the shared filter drawer.
- **FR-004**: Each row MUST show the folio, warehouse, facility, state, creator and creation date. A draft, which has no folio, MUST show "Borrador #{internal number}" in the Folio column instead.
- **FR-004a**: The detail screen's title MUST be "Conteo {folio}" for a completed count, "Conteo · Borrador #{internal number}" for a draft, and "Conteo · Borrador #{internal number}" with the Cancelled state for a cancelled one (a cancelled count was never confirmed, so it never has a folio).

**Header**

- **FR-005**: Users with create access MUST be able to start a count by choosing a warehouse and, optionally, entering a comment. The warehouse MUST start as the user's point-of-sale warehouse when they have one, and empty otherwise. For a non-administrator, the point-of-sale warehouse is used only when it belongs to their own facility (FR-015); otherwise the field starts empty.
- **FR-006**: On a draft, users with update access MUST be able to change the warehouse and the comment. The comment MUST stay optional, with the server's length limit.
- **FR-007**: The count MUST show its facility, which follows its warehouse, as read-only information, and the number of lines it holds ("Partidas").

**Lines**

- **FR-008**: On a draft, users with update access MUST be able to enter a product with a counted quantity of 0 or more (up to 4 decimals), change a line's quantity, and delete a line.
- **FR-009**: Entering a product already on the count MUST replace that line's quantity with the new one, never add to it. The screen MUST make clear, at the moment of entry, that the existing quantity will be replaced.
- **FR-010**: Each line MUST show the product code and name and the counted quantity. On a completed count, each line MUST also show the expected quantity and the difference; on a draft or a cancelled count, neither is shown.
- **FR-011**: The product picker for count lines SHOULD offer only stockable products. Any refusal of a non-stockable or unknown product MUST be shown.
- **FR-011a**: The user MUST be able to find a line on the count by product code or name.
- **FR-011b**: Besides the product picker, a draft MUST offer a quick-entry row: the user types or scans a product code, types a quantity and presses Enter, and the line is set. The code is matched exactly (ignoring case), with no search by name; the product picker covers searching. After each entry the focus returns to the code field, ready for the next product.
- **FR-011c**: On a draft, users with update access MUST be able to paste a list of product code and quantity pairs, one per row, in the column layout a spreadsheet copy produces: code and quantity separated by a tab, a semicolon or a comma. With a tab or semicolon separator, a decimal comma ("4,5") is accepted; a row whose separator is a comma and that also uses a decimal comma is reported as unreadable, not guessed. Before anything is sent, the screen MUST show how many rows were read and list every row it cannot read (missing code, quantity not a number, negative, or more than 4 decimals) and every code repeated in the paste. The user can send only when no row is unreadable or repeated.
- **FR-011d**: A pasted list MUST be sent in batches of at most 2,000 rows, with progress shown. Once sending starts it cannot be stopped midway; it runs until every batch is applied or one is refused. When the server refuses a batch, sending MUST stop and every bad row it names (unknown or non-stockable product) MUST be listed with its code. The screen MUST say how many rows were already applied. Because a line's quantity replaces the previous one, pasting the corrected list again is safe and the screen MUST say so.

**Actions**

- **FR-012**: Users with update access MUST be able to confirm a draft after accepting a confirmation prompt that says the warehouse's stock will be set to the counted quantities and that a confirmed count cannot be cancelled. The prompt MUST offer an option, off by default, to count as 0 every product with stock in the warehouse that is not on the count. On success the count MUST show its folio, the Completed state and each line's expected quantity and difference, and become read-only.
- **FR-013**: After a confirm, the screen MUST show the warnings the server returned: each product counted below its reservations, with its counted, reserved and available quantities, and each product corrected by another count, with that count's folio. The warnings MUST NOT be presented as errors, since the count is already confirmed. They are shown in a band the user can dismiss, and they are not shown again after the user leaves the count.
- **FR-014**: Users with the delete right MUST be able to cancel a draft after accepting a confirmation prompt. A completed count MUST NOT offer a cancel action.

**Across the feature**

- **FR-015**: Actions the user's rights do not allow MUST be absent, never shown disabled, mirroring the server: read on 74 to see, create on 74 to start a count, update on 74 to edit the header and lines and to confirm, delete on 74 to cancel a draft. A control that lists other records also needs that record's read right (warehouses to choose or filter a warehouse, products to add a line). The facility rule (a non-administrator acts only on counts of their own facility) is enforced by the server, and its refusal MUST be shown. The warehouse picker in Nuevo conteo and Editar encabezado MUST offer a non-administrator only the warehouses of their own facility, and administrators every warehouse. The list's warehouse filter MUST offer every warehouse to everyone.
- **FR-016**: Every server refusal MUST be shown with the localized text for its error code, never a raw server message or a generic failure. This includes the in-transit warehouse, a non-stockable product, an unknown product, a product repeated in one batch, a count of another facility, a confirm with no lines, a completed count that cannot be cancelled, an edit of a count that is no longer a draft, and a busy warehouse.
- **FR-017**: After every change the screen MUST show the count as the server returned it.
- **FR-018**: All user-facing text MUST be in Spanish, with quantities, dates and folios formatted by the app's shared formatting.
- **FR-019**: Conteos físicos MUST look and behave like the other Inventario screens wherever the documents work the same way (list columns and filters, header, draft naming, confirm and cancel prompts), and differ only where counts differ (replace instead of add, blind lines, warnings, no cancel once completed).
- **FR-020**: The back office MUST NOT offer a separate manual inventory adjustment screen. The legacy adjustment feature (system object 93) is covered by physical counts.

### Key Entities

- **Physical count**: A count of one warehouse. It has a facility (from its warehouse), a folio once confirmed, a state, an optional comment, its creator and creation date, and its lines. Once confirmed it can never be cancelled.
- **Count line**: A stockable product and the quantity counted (0 or more), one per product. After confirm, it also holds the quantity the stock records expected at that moment and the difference (counted minus expected).
- **Count warnings**: Returned once, when the count is confirmed. Products counted below their reservations (counted, reserved, available), and products corrected by another confirmed count of the same warehouse since this count was started (that count's folio).
- **Warehouse**: Where the count is made. It belongs to a facility. An in-transit warehouse cannot be counted.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A supervisor can enter and confirm a count of 20 products in under 4 minutes.
- **SC-002**: After a count is confirmed, the warehouse's stock of every product on it equals the counted quantity, every time.
- **SC-003**: No screen shows the expected stock of a product on a count that is still a draft.
- **SC-004**: Entering the same product twice never leaves the count with a quantity other than the last one entered.
- **SC-005**: Every server refusal a user can trigger on these screens shows a specific Spanish message. None shows a generic error or raw server text.
- **SC-006**: A user with read-only access cannot reach any action that changes a count.
- **SC-007**: A list of 15,000 code and quantity pairs can be pasted into a draft and fully applied without entering any product by hand.
- **SC-008**: With the quick-entry row, a clerk can enter 20 products using only the keyboard or a scanner, without touching the mouse.

## Assumptions

- Conteos físicos joins the Inventario navigation group after Traspasos (spec 069). The editor is reached from the list (Nuevo conteo, or opening a count).
- The list's default scope (the user's point-of-sale warehouse or their own counts) and the wider view (administrators and the delete right) are decided by the server. The UI sends only the state and warehouse filters.
- The warehouse picker uses the existing warehouse list. Warehouse records do not say whether they are in transit, so the picker cannot hide them. The server refuses an in-transit warehouse, and the UI shows that refusal.
- Manual inventory adjustments (mbe-api §4) are not built by the server and are not built here; the roadmap item is covered by physical counts. System object 93 gates nothing in this spec.
- The confirm warnings are shown only in the response to the confirm. Reopening a completed count later does not show them again, because the server does not store them.
- Lots, serials and expiry are out of scope, as in the server.
- Counts are not printed in this spec. A printable count sheet, if wanted, is a separate roadmap item.
- Live verification needs, in the dev tenant, a warehouse with a point-of-sale user, stockable products with stock in it, and a product with an open order reserving stock, to trigger the reservation warning.
