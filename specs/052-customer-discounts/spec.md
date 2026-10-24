# Feature Specification: Customer Discounts

**Feature Branch**: `052-customer-discounts`

**Created**: 2026-10-24

**Status**: Draft

**Input**: User description: "Customer discounts sub-panel on the customer detail page (mictlanix/mbe-roadmap#16). Scope: legacy spec 01 §1.3 Customers → Discounts sub-panel (2 legacy actions). mbe-api (commit dbae5f0) exposes per-customer product-specific discount overrides nested under the customer: GET and POST /customers/{id}/discounts, PUT and DELETE /customers/{id}/discounts/{customer_discount_id}. The list is ordered by product code and each row carries product_id, code and name. `discount` is a fraction 0..1 with up to 8 decimal places. One override per product (409 on a repeat), unknown product = 422, product is fixed after create (PUT changes only discount), override of another customer = 404. mbe-api commit ac68749 (closes roadmap#149) makes a new sales order or quote line added without discount_rate start at the customer's override for that product; the UI's capture step already omits discount_rate, so sales pick it up with no UI change. The generated OpenAPI client already has CustomerDiscountCreate/Update/Response and the customers_api methods. Precedent: customers already have a full detail page with linked-record sections (spec 046); supplier agreements (spec 050) are the closest per-row child CRUD pattern (add/edit dialog, delete inside the edit dialog with confirmation, row has only an Edit icon per constitution §VI). Discounts are saved one at a time, not as part of the customer save."

Roadmap: mictlanix/mbe-roadmap#16

## Context & Findings

- **Today.** The customer detail page (spec 046) shows the customer's own fields and three linked-record sections: Addresses, Contacts and Taxpayers. It has no discounts. A customer's negotiated discounts can't be seen or changed anywhere in the new UI.
- **Legacy.** The current system's customer screen (scope 01 §3) has a Discounts sub-panel. It is a table of product code, product name and discount. A dialog adds a product with a percentage. The percentage is edited in place, and a delete icon removes the row.
- **Server (mbe-api dbae5f0).**
  - A discount belongs to exactly one customer and names one product. It is added, changed and removed on its own, one at a time, not as part of the customer save.
  - A customer has at most one discount per product. Once a discount exists, only its rate can change, not its product.
  - The rate is stored as a fraction from 0 to 1 with up to 8 decimal places. For example, 0.15 means 15%.
  - Reading discounts needs Customers *Read*. Adding, changing and removing them needs Customers *Update*.
  - The list comes back ordered by product code.
- **Effect on sales (mbe-api ac68749, roadmap#149).** When a product is added to a sales order or quote for a customer, the new line starts at that customer's discount for the product. The UI already leaves the line's discount blank when adding products, so the server's default applies with no change to the sales screens. The discount is read only at the moment the line is added. Editing a line, changing the order's customer, converting a quote and duplicating an order never read it again, the same as in the current system.
- **Precedent.** Supplier agreements (spec 050) are the closest match. They are child records saved one at a time from their own dialog. The row carries only an Edit action, and removing happens inside the edit dialog after a confirmation. This feature follows that pattern so the two screens behave the same.

## Clarifications

### Session 2026-10-24

- Q: A discount can only be added to a saved customer. After creating a new customer, where does the user land? → A: On the saved customer, reopened for editing, so discounts can be added straight away. This matches suppliers since spec 050. After an update, the user still returns to the list.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - See a customer's product discounts (Priority: P1)

A sales user opens a customer and sees a Discounts section that lists every product the customer has a negotiated discount on, with the product's code, its name and the discount as a percentage. When the customer has none, the section says so.

**Why this priority**: Most use is lookup: "what discount does this customer get on this product?" Seeing the discounts is the smallest useful slice and needs no editing.

**Independent Test**: Open a customer that has discounts on the server. Each one appears, in product-code order, with the right percentage. A customer with none shows the empty state.

**Acceptance Scenarios**:

1. **Given** a customer with discounts on 3 products, **When** the user opens the customer, **Then** the Discounts section lists exactly those 3, ordered by product code, each showing the product code, product name and discount percentage.
2. **Given** a customer with no discounts, **When** the user opens the customer, **Then** the Discounts section shows an empty-state message instead of a blank area.
3. **Given** a stored discount of 0.125, **When** it is shown in the section, **Then** it reads in the application's percentage format (12.50 % by default), and its edit dialog shows the full stored precision (12.5).
4. **Given** a user who can read customers but not update them, **When** they open a customer, **Then** they see the Discounts section with every row but no add or edit controls.

---

### User Story 2 - Add a discount on a product (Priority: P1)

On a saved customer, the user adds a discount by picking a product through a search and entering a percentage. The discount appears in the section at once, and new sales lines for that customer and product start at that discount.

**Why this priority**: Recording a newly negotiated discount is the core reason for the roadmap item. Without it the section is a read-only copy of migrated data.

**Independent Test**: On a saved customer, add a 10% discount on a product. It appears in the section and is still there after reopening. A new sales order for that customer starts that product's line at 10%.

**Acceptance Scenarios**:

1. **Given** a saved customer, **When** the user picks a product, enters 10 and confirms, **Then** the section shows the product with 10 % and keeps it after reopening.
2. **Given** the add dialog, **When** the user searches for a product, **Then** products that already have a discount for this customer are not offered.
3. **Given** the add dialog, **When** the percentage is empty, below 0, above 100, or has more than 6 decimal places, **Then** the user cannot confirm, and the dialog says why.
4. **Given** someone else added a discount on the same product while the dialog was open, **When** the user confirms, **Then** the dialog stays open with the user's input and says the product already has a discount for this customer. The section then refreshes to show the other user's discount.
5. **Given** the user picked a product that is deleted before they confirm, **When** they confirm, **Then** the dialog stays open and says the product no longer exists.
6. **Given** a customer that has not been saved yet, **When** the user looks at the Discounts section, **Then** it explains that discounts can be added once the customer is saved, and shows no add control.
7. **Given** a new customer, **When** the user saves it for the first time, **Then** the screen stays open on the saved customer in edit mode, and the user can add a discount without going back to the list.
8. **Given** a discount was added for a customer and product, **When** a user adds that product to a new sales order or quote for that customer, **Then** the line starts at that discount (behaviour provided by the server, verified end to end).

---

### User Story 3 - Change or remove a discount (Priority: P2)

The user corrects the percentage of an existing discount, or removes it when the agreement with the customer ends. Each change takes effect when the dialog is confirmed.

**Why this priority**: Discounts change less often than they are looked up or added, but a wrong or stale discount silently affects every new sale for that customer, so it must be fixable.

**Independent Test**: Change a discount from 10 % to 12 %, then remove it. Reopen the customer after each step: the section matches.

**Acceptance Scenarios**:

1. **Given** a discount, **When** the user opens its edit dialog, enters a new percentage and confirms, **Then** the section shows the new percentage.
2. **Given** the edit dialog, **When** the user looks at the product, **Then** it is shown but cannot be changed.
3. **Given** a discount, **When** the user opens its edit dialog, chooses to remove it, and confirms the prompt, **Then** it disappears from the section.
4. **Given** a discount that someone else removed, **When** the user saves or removes it, **Then** the user sees that it no longer exists, and the section refreshes.
5. **Given** sales lines already created with a discount, **When** that discount is changed or removed, **Then** those lines keep the rate they started with.

---

### Edge Cases

- **Customer has unsaved edits.** Adding, changing or removing a discount refreshes only the Discounts section. The customer's unsaved field and link edits are left untouched and still need the customer's Save.
- **0 % discount.** A 0 % discount is valid and is listed. It is distinct from having no discount on the product, although both make a new line start at 0.
- **100 % discount.** Valid. The product is free for that customer.
- **Decimal separator.** The percentage field reads input the same way the sales discount field does, with a period as the decimal separator.
- **Many discounts.** A customer with many discounts keeps the section readable, and the page scrolls rather than truncating.
- **Inactive product.** A discount on a product that has since been deactivated is still listed and can be changed or removed.
- **Narrow screens.** The section stays usable in one column, and every action stays reachable.

## Requirements *(mandatory)*

### Functional Requirements

**Discounts section**

- **FR-001**: The customer detail page MUST show a Discounts section below the existing sections, when viewing and when editing a customer.
- **FR-002**: The section MUST list the customer's discounts in product-code order. Each row MUST show the product code, product name and discount as a percentage. When there are none, the section MUST show an empty-state message.
- **FR-003**: The section MUST show percentages in the application's percentage format, the same one every other screen uses (spec 028). The edit dialog MUST show the stored value at full precision, so nothing is lost when the user saves without changing it.

**Adding**

- **FR-004**: On a saved customer, a user with Update on customers MUST be able to add a discount through a dialog that asks for a product and a percentage.
- **FR-005**: The product MUST be chosen by searching active products by code or name. Products that already have a discount for this customer MUST NOT be offered.
- **FR-006**: The percentage MUST be required, from 0 to 100 inclusive, with at most 6 decimal places. The dialog MUST refuse any other value before anything is sent.
- **FR-007**: On a customer that is not yet saved, the section MUST NOT show an add control. It MUST say that discounts can be added once the customer is saved.
- **FR-007a**: After a customer is created, the screen MUST stay open on the saved customer in edit mode, with the Discounts add control available. After a customer is updated, the screen MUST return to the customer list, as today.

**Changing and removing**

- **FR-008**: A discount row MUST offer only an Edit action. The edit dialog MUST show the product without letting it change, and MUST let the user change the percentage under the same rules as FR-006.
- **FR-009**: Removing a discount MUST be done from its edit dialog, and MUST ask for confirmation.

**Saving behaviour**

- **FR-010**: Each add, change or removal MUST take effect when its dialog is confirmed, independently of the customer's Save. After each one, only the Discounts section MUST refresh. The customer's unsaved edits MUST NOT be touched.
- **FR-011**: When a save is refused, the dialog MUST stay open with the user's input and MUST say why: the product already has a discount for this customer, the product no longer exists, or the discount no longer exists. The section MUST then refresh to show the current server state.

**Access**

- **FR-012**: Viewing discounts MUST need *Read* on Customers (2). Adding, changing and removing MUST need *Update* on Customers. Searching products in the add dialog MUST need *Read* on Products (0). Without the needed right, the control MUST be hidden.

**Sales**

- **FR-013**: Adding a product to a sales order or quote MUST keep leaving the line's discount blank, so that the server starts the line at the customer's discount. No change to the sales screens is required beyond keeping this true.

**Language**

- **FR-014**: All new labels, empty states and messages MUST be available in Spanish and English.

### Key Entities

- **Customer**: A buyer. It now also has a list of product discounts.
- **Customer discount**: A negotiated discount that belongs to one customer and names one product, with a rate from 0 % to 100 %. A customer has at most one per product. Its product can't change after it is created.
- **Product**: The catalog item the discount applies to, shown by code and name.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: For every customer spot-checked on the test tenant (at least 10, including the one with the most discounts), the section shows exactly the server's discounts with the exact rates, with nothing missing or extra.
- **SC-002**: A user can add a discount on a product to a saved customer in under 30 seconds.
- **SC-003**: An out-of-range or over-precise percentage is refused before it is sent, 100% of the time.
- **SC-004**: A new sales order line for a customer and product with a discount starts at that discount 100% of the time, with no manual entry.
- **SC-005**: A user without a given right never sees the controls that need it, verified for each right named in FR-012.
- **SC-006**: Every legacy action in the Discounts sub-panel of scope 01 §3 can be done: view, add, change the percentage and remove.

## Assumptions

- **Percentages, not fractions.** Users enter and read discounts as percentages, as in the current system and the sales screens. The screen converts to and from the stored fraction. Six decimal places of a percentage is exactly the server's eight decimal places of a fraction.
- **Dialog editing instead of in-place editing.** The current system edits the percentage in place and removes the row with a delete icon. This feature uses an edit dialog with the remove action inside it, following spec 050's agreements and constitution §VI.
- **Discounts render as a table**, like the current system and the supplier agreements section. On narrow screens the columns stack and the Edit action stays reachable.
- **No search inside the section.** Discounts are listed in full, in product-code order, as in the current system. A search or filter within the section is out of scope until a customer with too many discounts to scan is found.
- **No extra product details on the row.** The current system also shows the product's model and SKU under the name. The server returns only code and name, and both identify the product well enough.
- **Server is ready.** mbe-api dbae5f0 and ac68749 are on the test deployment, and the generated client already has the discount operations.

## Out of Scope

- Applying a customer's discounts again to existing lines when the discount changes, the customer changes, or a quote is converted or duplicated. The server does not do this, and neither did the current system.
- Discounts by label, category or price list. Only product-specific discounts exist.
- Showing on a sales line that its discount came from the customer's discount.
- Bulk import, copy between customers, or editing many discounts at once.
