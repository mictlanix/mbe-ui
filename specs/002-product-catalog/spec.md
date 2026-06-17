# Feature Specification: Product Catalog (Products CRUD)

**Feature Branch**: `002-product-catalog`

**Created**: 2026-06-16

**Status**: Draft

**Input**: User description: "Add a Products CRUD feature: admin/staff can create, view, edit, and delete product records (e.g. SKU/code, name, description, price, unit, category, active/inactive status). List view supports search/filter; product detail/edit form validates required fields and price formatting. Access is gated by the existing RBAC system (Products system object) introduced in the auth feature — deny-by-default, only users with the appropriate privilege can create/edit/delete, others may have read-only or no access."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Browse and find products (Priority: P1)

A staff member with at least read access opens the product catalog and finds a specific item by searching its code, name, brand, model, or by filtering on status (active/disabled) or attributes (stockable, salable, purchasable). Filtering by label is deferred (see Assumptions).

**Why this priority**: Every other interaction with the catalog (selling, purchasing, stock-taking, editing) starts with locating a product. Without reliable search/filter, the catalog is unusable at any real scale.

**Independent Test**: Can be fully tested by signing in as a read-only user, opening the catalog, and finding a known product by code and by partial name, and delivers immediate value as a lookup tool even before create/edit is built.

**Acceptance Scenarios**:

1. **Given** a catalog with multiple products, **When** the user types a product's exact code into the search box, **Then** that product appears in the results.
2. **Given** a catalog with multiple products, **When** the user types a partial name, brand, or model, **Then** all matching products appear, in whatever order the search returns them (result ranking is a server concern and is not specified by this client feature).
3. **Given** the user applies the "active only" filter, **When** the list refreshes, **Then** disabled products are excluded.
4. **Given** the user has no privilege on the Products system object, **When** they attempt to navigate to the catalog, **Then** they are denied access (deny-by-default).

---

### User Story 2 - Create a new product (Priority: P1)

A user with create privilege adds a new product to the catalog, entering its identifying and commercial details, so it becomes available for inventory, sales, and purchasing workflows.

**Why this priority**: Without the ability to create products, the catalog can never grow; this is the second half of the MVP alongside browsing.

**Independent Test**: Can be fully tested by signing in as a user with create privilege, submitting a valid new-product form, and confirming the product appears in the list immediately afterward.

**Acceptance Scenarios**:

1. **Given** a user with create privilege, **When** they submit a form with a unique code, a valid name, and required defaults, **Then** the product is created and appears in the catalog as active.
2. **Given** a user submits a code that already exists (including on a disabled product), **When** they try to save, **Then** the system rejects the submission with a clear "code already in use" message and no product is created.
3. **Given** a user leaves a required field empty or enters a name shorter than the minimum length, **When** they try to save, **Then** the system blocks submission and highlights the invalid field(s).
4. **Given** a user enters a barcode that is not exactly 13 digits, **When** they try to save, **Then** the system rejects the barcode field with a clear message (empty barcode is allowed).
5. **Given** a user without create privilege, **When** they view the catalog, **Then** no "create product" action is available to them.

---

### User Story 3 - Edit an existing product (Priority: P2)

A user with edit privilege updates a product's details — pricing, classification, or behavioral flags (stockable, salable, purchasable, etc.) — to keep the catalog accurate as business needs change.

**Why this priority**: Catalog data drifts from reality over time (price changes, re-branding, discontinued suppliers); editing is essential but secondary to getting basic browse/create working first.

**Independent Test**: Can be fully tested by opening an existing product, changing its name and price, saving, and confirming the change is reflected in the list and detail view.

**Acceptance Scenarios**:

1. **Given** a user with edit privilege viewing a product, **When** they change its name, price, or other editable field and save, **Then** the updated values are persisted and reflected wherever the product is displayed.
2. **Given** a user attempts to change a product's code to one already used by another product, **When** they save, **Then** the system rejects the change with a clear message.
3. **Given** a user with only read privilege opens a product, **When** they view the detail screen, **Then** all fields are displayed but none are editable and no save action is available.

---

### User Story 4 - Deactivate (soft-delete) a product (Priority: P2)

A user with delete privilege removes a product from active use without erasing its history, because the product is discontinued but historical transactions referencing it must remain intact.

**Why this priority**: Deletion completes the CRUD set and is necessary for catalog hygiene, but is lower-frequency than browsing, creating, and editing.

**Independent Test**: Can be fully tested by deactivating an existing product and confirming it disappears from default (active-only) list views and is blocked from selection in new transactions, while remaining visible in an "include disabled" view and unaffected in historical records.

**Acceptance Scenarios**:

1. **Given** a user with delete privilege, **When** they deactivate a product, **Then** the product is marked inactive and excluded from default catalog views and from selection in new sales/purchase/inventory transactions.
2. **Given** a deactivated product, **When** the user searches with the "include disabled" filter enabled, **Then** the product still appears, clearly marked as inactive.
3. **Given** a deactivated product that has historical transactions, **When** those historical records are viewed, **Then** the product's details still display correctly (deactivation does not erase or corrupt history).
4. **Given** a user without delete privilege, **When** they view a product, **Then** no deactivate action is available to them.

---

### Edge Cases

- What happens when two users try to create a product with the same code at nearly the same time? The system must enforce uniqueness server-side and reject the second submission, regardless of client-side timing.
- How does the system handle a search with no matches? Show an explicit "no products found" state rather than an empty/ambiguous list.
- What happens if a user's privilege changes (e.g., create access revoked) while they have a create form open? The save action must be re-validated against current privileges at submit time, not just at page load.
- How does the system handle a barcode field left empty vs. one with the wrong digit count? Empty is valid (optional field); wrong digit count is rejected.
- What happens when a user attempts to deactivate a product that is already inactive? The action should be a no-op or disabled in the UI, not an error.
- How does the list view behave with a very large catalog? Results must be paginated or otherwise incrementally loaded rather than fetching the entire catalog at once.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST display a searchable, filterable list of products, searchable by code, name, brand, and model.
- **FR-002**: System MUST allow filtering the product list by active/disabled status and by attributes: stockable, salable, purchasable.
- **FR-003**: System MUST allow a privileged user to create a new product by entering at minimum: code, name, unit of measurement, and optional descriptive/commercial fields (brand, model, barcode, bin location, tax rate, notes). Per-price-list pricing is not entered at creation time (see Key Entities and Assumptions).
- **FR-004**: System MUST enforce that a product's code is unique across all products, including disabled ones, both on create and on edit.
- **FR-005**: System MUST validate that a product's code contains no whitespace and is between 1 and 25 characters.
- **FR-006**: System MUST validate that a product's name is between 4 and 250 characters.
- **FR-007**: System MUST validate that a product's barcode, if provided, is exactly 13 digits; an empty barcode is valid.
- **FR-008**: System MUST allow a privileged user to view full product details, including pricing and behavioral flags (stockable, perishable, seriable, purchasable, salable, invoiceable).
- **FR-009**: System MUST allow a privileged user to edit an existing product's fields, subject to the same validation rules as creation.
- **FR-010**: System MUST allow a privileged user to deactivate ("soft delete") a product, removing it from active use without deleting its historical transaction references.
- **FR-011**: System MUST exclude deactivated products from default list views and from selection in new transactions, while still allowing them to be found via an explicit "include disabled" filter.
- **FR-012**: System MUST gate all create, edit, and deactivate actions behind the existing RBAC system using the `Products` system object, deny-by-default — users without the corresponding privilege cannot perform the action and the corresponding UI affordance MUST NOT be shown.
- **FR-013**: System MUST allow a user with read-only privilege on `Products` to browse and view product details without exposing create/edit/deactivate actions.
- **FR-014**: System MUST present clear, field-level validation feedback when a create or edit submission is rejected (e.g., duplicate code, invalid name length, invalid barcode).
- **FR-015**: System MUST default new products to active (not disabled) status upon creation.

### Key Entities

- **Product**: The central catalog record. Key attributes: unique code, name, optional brand/model/SKU/barcode/bin location, unit of measurement, tax rate, active/disabled status, and behavioral flags (stockable, perishable, seriable, purchasable, salable, invoiceable). A product also has a price per price list (see below), which this feature displays read-only rather than treating as a single direct attribute. Referenced by inventory, sales, and purchasing records elsewhere in the system (out of scope here).
- **Product Price**: A read-only, per-price-list price entry shown on the product detail screen (FR-008). Managing price lists themselves, or editing a product's price within a list, is out of scope for this feature (see Assumptions).
- **Unit of Measurement**: A reference value a product is measured/sold in (e.g., piece, kilogram, box). Selected from an existing catalog; managing this catalog is out of scope for this feature.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A user can locate a known product by code or partial name in under 10 seconds.
- **SC-002**: A user with create privilege can add a new, valid product in under 2 minutes from opening the create form.
- **SC-003**: 100% of attempts to create or edit a product with a duplicate code, invalid name length, or invalid barcode are rejected with a clear, actionable message — none silently succeed or fail.
- **SC-004**: 0% of users lacking the relevant `Products` privilege can successfully create, edit, or deactivate a product, whether through the UI or by directly invoking the underlying action.
- **SC-005**: Deactivating a product removes it from default catalog views and new-transaction selection on the very next list refresh, with no stale active entries shown.

## Assumptions

- This feature covers the core Product entity CRUD only. Related legacy sub-features — Price Lists administration, Label administration, and product-merge (duplicate cleanup) — are existing or future system objects (`PriceLists`, `Labels`, `ProductsMerge`) with their own RBAC gates and are out of scope for this spec; product price-per-list values and label tag assignment may be displayed/edited as sub-sections of the product detail screen, but managing the underlying price list or label catalogs is not.
- "Category" in the original feature request maps to the existing **Label** concept (many-to-many classification tags) rather than a new single-valued category field; label assignment is treated as part of the product detail screen, consistent with the legacy data model.
- Photo/image upload for products, SAT product-key/tax-catalog integration, and default-supplier assignment are part of the legacy data model but are not required for the MVP CRUD flows in this spec; they may be added as optional fields without blocking initial delivery.
- "Delete" is implemented as a soft delete (deactivation) to preserve referential integrity with historical transactions, consistent with the legacy system's behavior — there is no hard-delete action in this feature.
- Server-side enforcement of code uniqueness and field validation already exists or will be provided by the backend API; this spec describes the client-facing behavior and assumes the API contract supports these constraints.
- Pagination/incremental loading strategy for large catalogs follows whatever pattern the existing Users admin list (from the auth feature) already establishes, for consistency.
- Filtering the product list by label (User Story 1) is deferred — no label picker/management UI exists yet (Labels administration is out of scope per the bullet above), so the label filter is not implemented in this feature's first delivery.
- SC-004 ("0% of users lacking the relevant `Products` privilege can succeed... whether through the UI or by directly invoking the underlying action") depends on mbe-api enforcing `require_privilege(SystemObject.PRODUCTS, ...)` on the core CRUD endpoints, which it does not yet do — tracked as [mictlanix/mbe-api#70](https://github.com/mictlanix/mbe-api/issues/70). This feature implements full deny-by-default gating client-side regardless; SC-004's "direct invocation" clause is fully met only once that backend issue is resolved.
