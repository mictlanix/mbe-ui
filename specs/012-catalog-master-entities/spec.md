# Feature Specification: Catalog Master Entities (Customers, Employees, Suppliers, Labels, Taxpayer Recipients)

**Feature Branch**: `012-catalog-master-entities`

**Created**: 2026-07-19

**Status**: Draft

**Input**: User description: "Add full CRUD catalog UIs for Customers, Labels, TaxpayerRecipients, Employees, and Suppliers — five master-data entities mbe-api already exposes with complete Create/Read/Update/Delete endpoints, following the same paginated-list-with-filter-drawer and view/edit/create patterns already established by the Products catalog, plus whichever related catalogs (e.g. an Employee picker for a Customer's salesperson, SAT postal-code/tax-regime pickers for Taxpayer Recipients) are necessary for these five to actually function."

## User Scenarios & Testing *(mandatory)*

<!--
  IMPORTANT: User stories should be PRIORITIZED as user journeys ordered by importance.
  Each user story/journey must be INDEPENDENTLY TESTABLE - meaning if you implement just ONE of them,
  you should still have a viable MVP (Minimum Viable Product) that delivers value.
-->

### User Story 1 - Manage the Suppliers catalog (Priority: P1)

A user with the appropriate privilege needs to see the full list of suppliers, search for one by name or code, view a supplier's full detail, create a new supplier, edit an existing one, and delete a supplier that is no longer used — all from a dedicated Suppliers screen, the same way products are managed today.

**Why this priority**: Suppliers already exist in the system as a read-only picker (used only to assign a product's default supplier), but there is nowhere to actually create, correct, or retire a supplier record. This is a fully self-contained gap with no dependency on any other new catalog, making it the cheapest, highest-confidence first slice.

**Independent Test**: Can be fully tested by opening the Suppliers catalog, searching for an existing supplier by name, creating a new supplier, editing its credit terms, and deleting a supplier — independent of any other catalog in this feature.

**Acceptance Scenarios**:

1. **Given** a user with read privilege on suppliers, **When** they open the Suppliers catalog, **Then** they see a paginated, searchable list of all suppliers with their code, name, and status.
2. **Given** a user with create privilege, **When** they fill in the required supplier fields and save, **Then** a new supplier appears in the list.
3. **Given** a user with update privilege viewing a supplier, **When** they edit any field and save, **Then** the change is reflected on the list and detail screen.
4. **Given** a user with delete privilege viewing a supplier's detail screen, **When** they confirm deletion, **Then** the supplier no longer appears in the catalog.
5. **Given** a user without update privilege, **When** they open a supplier's detail screen, **Then** it renders read-only with no edit or delete affordance.
6. **Given** a supplier is referenced by an existing product, **When** a user attempts to delete that supplier, **Then** the system surfaces whatever rejection the backend returns rather than silently failing or crashing.

---

### User Story 2 - Manage the Labels catalog (Priority: P1)

A user with the appropriate privilege needs to create new labels, rename or update the comment on an existing label, and delete a label that's no longer needed — from a dedicated Labels screen — while the existing label picker used on the product form and the products list's label filter keep working unchanged.

**Why this priority**: Labels currently exist only as a read-only list consumed by the product form and product-list filter; there is no way to actually manage the set of labels a business defines. Equally self-contained and low-risk as Suppliers.

**Independent Test**: Can be fully tested by opening the Labels catalog, creating a new label, editing its name, deleting an unused label, and then confirming the product form's label picker and the products list's label filter still show the current label set.

**Acceptance Scenarios**:

1. **Given** a user with read privilege on labels, **When** they open the Labels catalog, **Then** they see a paginated, searchable list of all labels with their name and comment.
2. **Given** a user with create privilege, **When** they enter a label name and save, **Then** the new label appears in the catalog and immediately becomes selectable in the product form's label picker.
3. **Given** a user with update privilege, **When** they rename a label and save, **Then** the new name is reflected everywhere the label is shown, including on products already tagged with it.
4. **Given** a user with delete privilege, **When** they delete a label that is still assigned to one or more products, **Then** the system surfaces whatever rejection or confirmation the backend requires rather than silently failing.
5. **Given** a user without any privilege on labels, **When** they view a product that has labels assigned, **Then** the labels are still visible read-only on the product (unaffected by this feature).

---

### User Story 3 - Manage the Employees catalog (Priority: P1)

A user with the appropriate privilege needs to see the full list of employees, search and filter by active/sales-person status, view an employee's full detail, create a new employee record, edit an existing one, and delete one that's no longer needed.

**Why this priority**: Employees are entirely unmanaged in the system today (no mbe-ui screen exists at all) despite being referenced elsewhere (a customer's salesperson, and the existing Users admin screen's raw employee-id field). Equal priority to Suppliers/Labels since it's independently useful, and it must exist before Customers (User Story 4) can offer a real salesperson picker instead of a placeholder.

**Independent Test**: Can be fully tested by opening the Employees catalog, filtering to only active sales-person employees, creating a new employee, editing their comment, and deleting one — independent of Customers or any other catalog.

**Acceptance Scenarios**:

1. **Given** a user with read privilege on employees, **When** they open the Employees catalog, **Then** they see a paginated, searchable list of employees with name, active status, and sales-person status.
2. **Given** the list has more than a handful of employees, **When** the user opens the filter controls, **Then** they can narrow the list by active/inactive and by sales-person/not-sales-person, independently of each other.
3. **Given** a user with create privilege, **When** they fill in the required employee fields (first name, last name, nickname, gender, birthday, start date) and save, **Then** a new employee appears in the catalog.
4. **Given** a user with update privilege, **When** they edit an employee's fields and save, **Then** the change is reflected on the list and detail screen.
5. **Given** a user with delete privilege, **When** they delete an employee who is assigned as a customer's salesperson, **Then** the system surfaces whatever rejection the backend returns rather than silently failing.

---

### User Story 4 - Manage the Customers catalog (Priority: P2)

A user with the appropriate privilege needs to see the full list of customers, search and filter (by active/inactive status, price list, and assigned salesperson), view a customer's full detail — including their price list and salesperson shown by name, not raw id — create a new customer, edit an existing one, and delete one that's no longer needed.

**Why this priority**: Customers is the most-referenced and highest-value of the five catalogs, but its salesperson field depends on the Employees catalog (User Story 3) existing first so the picker has real data to search, and its price-list field depends on the price-list catalog already shipped in a prior feature — making it correctly a P2 that builds on P1 foundations rather than a first slice.

**Independent Test**: Can be fully tested by opening the Customers catalog, filtering to only active customers on a specific price list, creating a new customer with a searched-and-selected salesperson, editing their credit terms, and deleting a customer — assuming Employees (User Story 3) has already shipped.

**Acceptance Scenarios**:

1. **Given** a user with read privilege on customers, **When** they open the Customers catalog, **Then** they see a paginated, searchable list of customers with code, name, status, and salesperson name.
2. **Given** the customers list, **When** the user opens the filter controls, **Then** they can narrow by active/inactive status, by a specific price list, and by a specific salesperson, independently of each other.
3. **Given** a user with create or update privilege on the customer form, **When** they open the salesperson field and search by name, **Then** matching employees are shown for selection, and the chosen employee's name (not a raw id) is shown wherever the customer is displayed.
4. **Given** a user with create or update privilege, **When** they open the price-list field and search or select from the existing price lists, **Then** the chosen price list's name is shown on the customer's detail screen and list.
5. **Given** a customer has no salesperson assigned, **When** viewed on the detail screen or list, **Then** the field shows a clear "none assigned" state rather than blank or a raw number.
6. **Given** a user with delete privilege, **When** they attempt to delete a customer with existing history (e.g. sales orders), **Then** the system surfaces whatever rejection the backend returns rather than silently failing.

---

### User Story 5 - Manage the Taxpayer Recipients catalog (Priority: P3)

A user with the appropriate privilege needs to see the full list of taxpayer recipients (the fiscal/invoicing recipient records), search for one by name, view full detail — including postal code and tax regime shown by their human-readable description, not raw codes — create a new one by supplying its tax id, edit its name/email/postal-code/regime, and delete one that's no longer needed.

**Why this priority**: Taxpayer Recipients is the least-referenced of the five catalogs today (nothing else in the current UI consumes it) and its postal-code/tax-regime fields depend on picker support being added to the existing SAT catalog lookup — making it correctly the lowest priority, shippable independently of Customers/Employees/Suppliers/Labels once that picker support exists.

**Independent Test**: Can be fully tested by opening the Taxpayer Recipients catalog, creating a new entry by typing its tax id and searching/selecting a postal code and tax regime, editing its email, and deleting an entry — independent of the other four catalogs.

**Acceptance Scenarios**:

1. **Given** a user with read privilege on taxpayer recipients, **When** they open the catalog, **Then** they see a paginated, searchable list with tax id, name, and email.
2. **Given** a user with create privilege, **When** they type a new tax id and the required name/email and select a postal code and tax regime from a search-as-you-type picker, **Then** a new taxpayer recipient is created using that tax id as its permanent identifier.
3. **Given** a user attempts to create a taxpayer recipient using a tax id that already exists, **When** they submit, **Then** the system shows a clear rejection rather than silently overwriting or crashing.
4. **Given** an existing taxpayer recipient, **When** a user with update privilege opens its edit form, **Then** the tax id itself is shown but not editable (it is the permanent identifier), while name, email, postal code, and tax regime remain editable.
5. **Given** a taxpayer recipient's postal code or tax regime cannot be resolved to a description, **When** its detail screen loads, **Then** a fallback label is shown instead of failing the whole screen.

---

### Edge Cases

- What happens when a user searches any of these five catalogs for a term with no matches? → Show the existing empty-state pattern used elsewhere in the app ("no results"), not an error.
- What happens if a customer, once created, has its assigned salesperson or price list later deleted from their respective catalogs? → The customer's list/detail screens show a clear fallback label (e.g. "Unknown salesperson") rather than crashing or showing a blank/raw value.
- What happens when a user without any privilege on one of these five system objects tries to navigate directly to its route? → Denied per the existing deny-by-default RBAC; consistent with every other catalog in the app.
- What happens when a user filters the Customers or Employees list by more than one facet at once (e.g. active + a specific price list + a specific salesperson)? → All selected filters apply together (narrowing, not widening, the result set).
- What happens when the postal-code or tax-regime picker search returns no matches while creating/editing a Taxpayer Recipient? → Same empty-state pattern as any other picker in the app; the user can retry with a different search term without losing other form input.
- What happens when a user attempts to delete a record from any of these five catalogs that is still referenced elsewhere (a supplier on a product, a label on a product, an employee as a salesperson, etc.)? → The system surfaces whatever rejection the backend returns; the UI never pre-blocks the attempt speculatively, and never silently drops the reference.

## Requirements *(mandatory)*

### Functional Requirements

**Cross-cutting (all five catalogs)**

- **FR-001**: Each of the five catalogs (Suppliers, Labels, Employees, Customers, Taxpayer Recipients) MUST have its own dedicated list screen showing a paginated, searchable table of records, consistent in look, feel, and interaction with the existing Products catalog.
- **FR-002**: Each catalog's list screen MUST provide a search box that filters by the record's identifying text (code/name, or tax id/name as applicable).
- **FR-003**: Creating a record MUST be available as a primary action alongside the search box (not tucked into a menu), visible only to users holding create privilege for that catalog.
- **FR-004**: Each catalog row's sole direct action MUST be Edit, visible only to users holding update privilege; clicking anywhere else on the row MUST open that record's detail screen in read-only ("View") mode.
- **FR-005**: A read-only detail screen MUST offer an explicit control to switch to the editable form when the current user holds update privilege, and MUST NOT offer that control otherwise.
- **FR-006**: Deleting a record MUST be available only from that record's own detail screen (never as a row action on the list), visible only to users holding delete privilege for that catalog, and MUST require an explicit confirmation before the delete is submitted.
- **FR-007**: Every mutable action (create, update, delete) on every one of these five catalogs MUST be gated by the existing per-catalog access-control privilege already defined in the system for Suppliers, Labels, Employees, Customers, and Taxpayer Recipients respectively; a user lacking a privilege MUST NOT see the corresponding control.
- **FR-008**: All five catalogs MUST be reachable from the app's existing catalog navigation area, each only shown to users holding at least read privilege on that catalog.
- **FR-009**: Screen-level actions other than the single read-only-to-edit toggle (and, where a catalog keeps delete on the detail screen's own toolbar) MUST NOT be placed as toolbar icon actions; they MUST appear as visible-label buttons in the screen body, consistent with how Create/Merge already work on the Products catalog.

**Suppliers (User Story 1)**

- **FR-010**: The Suppliers catalog MUST support creating, viewing, editing, and deleting a supplier with fields: code, name, zone, credit limit, credit days, and comment.
- **FR-011**: Code and name MUST be required on create; a supplier's code MUST be validated the same way the Products catalog validates uniqueness/format expectations for equivalent fields (surfaced as a field-level error, not a crash).

**Labels (User Story 2)**

- **FR-012**: The Labels catalog MUST support creating, viewing, editing, and deleting a label with fields: name and comment.
- **FR-013**: Name MUST be required on create.
- **FR-014**: Changes made in the Labels catalog (create, rename, delete) MUST be immediately reflected by the existing label picker on the product form and the existing label filter on the products list, without requiring any change to those two existing features.

**Employees (User Story 3)**

- **FR-015**: The Employees catalog MUST support creating, viewing, editing, and deleting an employee with fields: first name, last name, nickname, gender, birthday, tax id (optional), sales-person flag, active flag, personal id (optional), start date, enrollment number (optional), and comment.
- **FR-016**: First name, last name, nickname, gender, birthday, and start date MUST be required on create.
- **FR-017**: The Employees list MUST provide filter controls for active/inactive status and for sales-person/not-sales-person status, usable independently or together.

**Customers (User Story 4)**

- **FR-018**: The Customers catalog MUST support creating, viewing, editing, and deleting a customer with fields: code, name, zone, credit limit, credit days, price list, shipping flag, shipping-required-document flag, salesperson (optional), active/disabled status, and comment.
- **FR-019**: Code and name MUST be required on create; price list MUST be required on create (every customer belongs to exactly one price list).
- **FR-020**: The customer form MUST provide a searchable picker for the price list field (search/select from existing price lists) and a searchable picker for the salesperson field (search/select from existing employees), each showing the human-readable name rather than requiring a raw id.
- **FR-021**: The Customers list and detail screen MUST display the assigned price list and salesperson by name; a customer with no salesperson assigned MUST show an explicit "none assigned" state.
- **FR-022**: The Customers list MUST provide filter controls for active/inactive status, for a specific price list, and for a specific salesperson, usable independently or together.

**Taxpayer Recipients (User Story 5)**

- **FR-023**: The Taxpayer Recipients catalog MUST support creating, viewing, editing, and deleting a taxpayer recipient with fields: tax id, name, email, postal code, and tax regime.
- **FR-024**: Tax id MUST be supplied by the user at creation time (it is not system-generated) and MUST be required; once created, the tax id MUST NOT be editable.
- **FR-025**: The taxpayer recipient form MUST provide a searchable picker for postal code and a searchable picker for tax regime, each backed by the existing official catalog of valid values, showing a human-readable description for each match.
- **FR-026**: The Taxpayer Recipients list and detail screen MUST display postal code and tax regime by their human-readable description, not by raw code; if a referenced code cannot be resolved, a fallback label MUST be shown instead of failing the whole screen.
- **FR-027**: Attempting to create a taxpayer recipient with a tax id that already exists MUST be rejected with a clear, user-visible message rather than silently overwriting the existing record.

### Key Entities *(include if feature involves data)*

- **Supplier**: A vendor a product can be sourced from. Identified by a system-assigned id, with code, name, zone, credit limit, credit days, and comment. Already referenced read-only by the product catalog (specs/005); this feature adds full management.
- **Label**: A named tag attachable to products. Identified by a system-assigned id, with name and comment. Already referenced read-only by the product form/list (specs/002, specs/009); this feature adds full management.
- **Employee**: A staff member, identified by a system-assigned id, with personal details (name, nickname, gender, birthday), employment details (start date, enrollment number, active status), and a flag marking whether they can be assigned as a customer's salesperson. Not previously manageable in the UI; a customer's salesperson references an employee, and the existing Users admin screen references one by raw id.
- **Customer**: A buyer of goods/services, identified by a system-assigned id, with code, name, zone, credit terms, an assigned price list (required), an optional assigned salesperson (an Employee), shipping preferences, and active/disabled status.
- **Taxpayer Recipient**: A fiscal/invoicing recipient record, identified by a user-supplied, permanent tax id, with name, email, a postal code, and a tax regime — the latter two drawn from official reference catalogs.
- **Price List** *(reused, not newly introduced)*: The existing named pricing channel entity from the pricing feature; this feature only adds a picker over it for the Customer form/filter, with no changes to price-list management itself.
- **SAT Postal Code / SAT Tax Regime** *(reused, not newly introduced)*: Existing official reference catalogs (the same kind of lookup already used for unit-of-measurement and product/service key on the product form); this feature adds picker support over the postal-code and tax-regime catalogs specifically, for the Taxpayer Recipient form.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A privileged user can locate, create, edit, or delete a record in any of the five catalogs in under 30 seconds from landing on that catalog's list screen.
- **SC-002**: 100% of customer records display their salesperson and price list as human-readable names, never as raw ids, across the list and detail screens.
- **SC-003**: 100% of taxpayer recipient records display postal code and tax regime as human-readable descriptions (or an explicit fallback), never as raw codes.
- **SC-004**: Users can narrow the Employees list and the Customers list to their intended subset using the available filters in two interactions or fewer (open filter, select values) and clear them in one interaction.
- **SC-005**: Zero regressions in the existing product form's supplier picker, unit-of-measurement/key pickers, label picker, or the products list's label filter after this feature ships.
- **SC-006**: A user lacking any privilege on one of these five catalogs cannot reach its screens, and a user lacking only update/delete privilege never sees an edit or delete control for it.

## Assumptions

- All five backend endpoints (Customers, Employees, Suppliers, Labels, Taxpayer Recipients) already exist as complete Create/Read/Update/Delete APIs and are already reflected in the generated API client; no backend/API change is required for this feature.
- All five catalogs already have their own access-control privilege defined in the system; no new privilege needs to be introduced.
- This feature promotes the existing read-only Suppliers and Labels lookups (used today as pickers/filters on the product catalog) to full management catalogs; it does not change how the product form or products list consume them.
- A Customer's salesperson picker depends on the Employees catalog existing — Employees is scoped as an earlier, independent slice of this same feature specifically so Customers can rely on it, rather than treating Employees as a separate future feature.
- A Customer's price-list picker reuses the price-list catalog already delivered by a prior feature; managing price lists themselves is out of scope here.
- A Taxpayer Recipient's postal-code and tax-regime pickers reuse the same kind of official reference-catalog lookup already used elsewhere in the product catalog (units of measurement, product/service key); this feature extends that lookup to cover postal codes and tax regimes as well.
- Retrofitting the existing Users admin screen's raw employee-id field into a proper employee picker is a valuable follow-up once the Employees catalog exists, but is explicitly out of scope for this feature.
- Bulk import/export (e.g. CSV) for any of these five catalogs is out of scope; each record is created/edited one at a time, consistent with every existing catalog in the app.
- Money-shaped fields (credit limit on Suppliers and Customers) follow the same display/edit conventions already established for monetary values elsewhere in the app (e.g. price-list amounts) — never manually formatted, always locale-aware.
- "Zone" on Suppliers/Customers remains a free-text field with no master-data catalog behind it, consistent with how "brand"/"model" remain free-text on products.
