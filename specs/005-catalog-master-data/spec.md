# Feature Specification: Product Catalog Master-Data Integration

**Feature Branch**: `005-catalog-master-data`

**Created**: 2026-06-28

**Status**: Refined

**Input**: User description: "Complement the Product Catalog feature (002-product-catalog) by wiring it to the master-data reference entities that mbe-api now exposes (Suppliers, Price Lists, Labels, SAT Catalogs). Replace the raw numeric supplier field with a searchable supplier picker showing the supplier's name; replace the free-text unit-of-measurement and SAT product/service key fields with pickers backed by the read-only SAT catalogs, validated before submit; resolve each product price's price-list id to its name on the detail screen; add a label filter to the products list (filtering only — assigning labels to a product is not yet supported by the backend and stays deferred). Reuses existing Products RBAC; no new privileges."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Choose a supplier by name instead of by ID (Priority: P1)

A user with create/edit privilege on products is filling out the product form and needs to set the product's default supplier. Today they can only enter a raw supplier ID with no way to confirm which supplier that is; instead they search for the supplier by name or code and pick it from a list, and the chosen supplier's name is shown on the form, the detail screen, and the products list.

**Why this priority**: The current numeric supplier field is effectively unusable for anyone who doesn't already know supplier IDs by heart, and produces silent mismatches (wrong supplier picked by typo). This is the most user-visible gap in the existing catalog feature.

**Independent Test**: Can be fully tested by opening a product's edit form, searching for a supplier by partial name, selecting it, saving, and confirming the supplier's name (not its ID) appears on the detail screen and in the products list filter.

**Acceptance Scenarios**:

1. **Given** a user with edit privilege viewing a product's form, **When** they open the supplier field and type part of a supplier's name, **Then** matching suppliers are shown by name (and code) for selection.
2. **Given** a user selects a supplier from the picker and saves, **Then** the product is updated with that supplier and the supplier's name is displayed wherever the product is shown (detail screen, list filter chip).
3. **Given** a product already has a supplier assigned, **When** the user opens the edit form, **Then** the picker is pre-filled with that supplier's name, not its raw ID.
4. **Given** a product has no supplier assigned, **When** viewed on the detail screen, **Then** the supplier field shows a clear "no supplier" state rather than blank or "0".
5. **Given** a user without edit privilege views a product, **When** they look at the supplier field, **Then** the supplier's name is shown read-only.

---

### User Story 2 - Pick valid SAT unit-of-measurement and product/service key codes (Priority: P1)

A user creating or editing a product needs to set the unit of measurement and the SAT product/service "key" — both of which must match an official SAT catalog code or the product cannot be invoiced correctly. Today these are free-text fields with no validation until the server rejects the save; instead the user searches the official catalog by code or human-readable description and picks a valid entry.

**Why this priority**: An invalid SAT code on a product silently breaks fiscal-document generation later; catching this at data-entry time, with the same priority as the supplier picker, prevents downstream invoicing failures and is equally foundational to a correct catalog.

**Independent Test**: Can be fully tested by opening the product form, searching the unit-of-measurement field by a partial description (e.g. "kilogram"), selecting a result, repeating for the product/service key field, saving, and confirming both display their human-readable description alongside the raw code on the detail screen.

**Acceptance Scenarios**:

1. **Given** a user editing a product, **When** they open the unit-of-measurement field and type a search term, **Then** matching SAT units of measurement are shown with their code, name, and description.
2. **Given** a user editing a product, **When** they open the SAT product/service key field and type a search term, **Then** matching SAT product/service entries are shown with their code and description.
3. **Given** a user selects a valid SAT code for either field and saves, **Then** the product is saved successfully and the detail screen shows the code together with its human-readable description.
4. **Given** a user attempts to save the form without selecting a value for unit of measurement, **Then** the system blocks submission since this field is required.
5. **Given** the SAT catalog lookup is temporarily unavailable, **When** the user opens either picker, **Then** they see a clear error state and can retry, without losing other form input.

---

### User Story 3 - See price-list names instead of raw numbers on the product detail screen (Priority: P2)

A user viewing a product's detail screen sees a list of prices, one per price list, but each row currently only shows the price list as a bare number. The user needs the price list's name (e.g. "Retail", "Wholesale") so they can tell which price applies to which channel.

**Why this priority**: This is a readability fix on an already-functional screen (prices are visible, just unlabeled) — valuable but lower risk/impact than the two data-entry corrections above.

**Independent Test**: Can be fully tested by opening any product's detail screen and confirming each listed price shows its price list's name rather than a numeric id.

**Acceptance Scenarios**:

1. **Given** a product with prices on multiple price lists, **When** the user opens its detail screen, **Then** each price row shows the price list's name.
2. **Given** a price references a price list that no longer exists, **When** the detail screen loads, **Then** that row shows a clear fallback label (e.g. "Unknown price list") instead of failing to load the whole screen.

---

### User Story 4 - Filter the product list by label (Priority: P3)

A user browsing the product catalog wants to narrow results to products tagged with a specific label (e.g. "Clearance", "Featured"). Today this filter does not exist in the UI even though the underlying list endpoint already supports it.

**Why this priority**: A convenience filter on top of an already-working search/filter experience; valuable for catalogs with many labeled products but not blocking core workflows, and lowest priority since it's additive only.

**Independent Test**: Can be fully tested by selecting a label from a filter control on the products list and confirming only products carrying that label are shown, and that clearing the filter restores the full list.

**Acceptance Scenarios**:

1. **Given** labels exist in the system, **When** the user opens the products list, **Then** a label filter control is available showing label names.
2. **Given** the user selects a label, **When** the list refreshes, **Then** only products carrying that label are shown.
3. **Given** the user clears the label filter, **When** the list refreshes, **Then** previously hidden products reappear.
4. **Given** no products carry the selected label, **When** the filter is applied, **Then** the list shows the existing empty-state message.

---

### User Story 5 - Assign and remove labels on a product (Priority: P3)

A user with edit privilege on products can tag a product with one or more labels and remove labels that no longer apply, keeping the catalog organized for filtering and reporting. The product's current labels are visible on the detail screen regardless of privilege level.

**Why this priority**: Pairs with label filtering (User Story 4) — filtering is only useful once labels are actually assigned to products. Backend now supports label assignment via `ProductCreate`/`ProductUpdate`, so this is no longer deferred.

**Independent Test**: Can be fully tested by opening a product's edit form, selecting two labels from the label picker, saving, confirming both labels appear on the product's detail screen, then removing one and confirming it disappears.

**Acceptance Scenarios**:

1. **Given** a user with edit privilege on the product form, **When** they open the labels field, **Then** all available labels are shown and the product's currently assigned labels are pre-selected.
2. **Given** a user selects or deselects labels and saves, **Then** the product's label set is updated and the detail screen reflects the new set.
3. **Given** a user with read-only privilege views a product's detail screen, **When** labels are assigned to that product, **Then** the labels are displayed but no edit affordance is shown.
4. **Given** no labels exist in the system, **When** the user opens the label field on the form, **Then** the field is empty and the user can still save the product without any labels.

---

### Edge Cases

- What happens when a user types a search term in the supplier, unit-of-measurement, or product/service-key picker that matches nothing? → Show the existing empty-state pattern used elsewhere in the catalog ("no results"), not an error.
- What happens if a product's stored supplier id no longer matches any supplier (orphaned reference)? → Detail/list screens show a clear fallback label (e.g. "Unknown supplier") rather than crashing or showing a blank field; the edit form lets the user pick a new, valid supplier.
- What happens if a product's stored unit-of-measurement or key code no longer matches any SAT catalog entry? → Detail screen shows the raw code with a fallback indicator that it could not be resolved; the edit form requires the user to pick a valid replacement before saving other changes (existing required-field behavior).
- What happens when the label filter list is empty (no labels defined yet)? → The label filter control is hidden or disabled and the label field on the product form is empty but not an error; the rest of the list and form behave as before this feature.
- What happens when a user without any catalog access tries to use these pickers? → Denied per the existing deny-by-default RBAC on the Products system object; this feature does not change those rules.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The product create/edit form MUST provide a searchable supplier picker (search by name or code) in place of the current raw numeric supplier input.
- **FR-002**: The product detail screen and products list MUST display a product's supplier by name, not by raw id; products with no supplier MUST show an explicit "no supplier" state.
- **FR-003**: The product create/edit form MUST provide a searchable picker for unit of measurement, backed by the SAT units-of-measurement catalog, showing code, name, and description for each match.
- **FR-004**: The product create/edit form MUST provide a searchable picker for the SAT product/service key, backed by the SAT product/service catalog, showing code and description for each match.
- **FR-005**: The system MUST prevent submitting the product form with a unit-of-measurement value that was not selected from the SAT catalog picker (unit of measurement remains a required field, per the existing 002-product-catalog rules).
- **FR-006**: The product detail screen MUST display the unit of measurement with its name and description, and the SAT product/service key with its description, not just the raw codes.
- **FR-007**: The product detail screen MUST display each listed price with its price list's name; if the referenced price list cannot be resolved, the row MUST show a fallback label instead of failing the whole screen.
- **FR-008**: The products list screen MUST provide a filter control that narrows results to products carrying a selected label, using the existing label-based filtering already supported by the product list query.
- **FR-009**: Clearing the label filter MUST restore the unfiltered (or otherwise-filtered) product list.
- **FR-010**: The product detail screen MUST display the product's currently assigned labels; users without edit privilege see them read-only.
- **FR-011**: The product create/edit form MUST provide a label multi-picker showing all available labels, with the product's currently assigned labels pre-selected; saving MUST persist the chosen label set.
- **FR-012**: All new pickers and filters MUST respect the existing Products system-object RBAC: users without at least read access to products continue to be denied access to the catalog entirely, and users without edit/create privilege see read-only resolved values (supplier name, SAT descriptions, label list) with no editable pickers.
- **FR-013**: Creating, editing, or deleting suppliers, price lists, labels, or SAT catalog entries is OUT of scope for this feature; all of these are read-only lookups from the product catalog's perspective.

### Key Entities *(include if feature involves data)*

- **Supplier**: A vendor a product can be sourced from; identified by id, with a code and name used for search/display. Referenced by a product's `supplier` field (optional, one supplier per product).
- **SAT Unit of Measurement**: An official catalog entry (code, name, description, symbol) that a product's `unit_of_measurement` field must match; required on every product.
- **SAT Product/Service Key**: An official catalog entry (code + description) that a product's `key` field must match when set; optional on a product.
- **Price List**: A named pricing channel (e.g. "Retail"); a product can have one price entry per price list, currently shown by the price list's numeric id and, after this feature, by its name.
- **Label**: A named tag that can be attached to products (many-to-many); displayed on the product detail screen, assignable/removable via the product form, and used to filter the products list.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can locate and assign the correct supplier to a product by name in under 10 seconds, without needing to know or look up a numeric id beforehand.
- **SC-002**: Zero products can be saved with a unit-of-measurement or SAT product/service key value that does not correspond to a valid SAT catalog entry.
- **SC-003**: 100% of price rows on the product detail screen display a human-readable price-list name (or an explicit fallback) instead of a raw number.
- **SC-004**: Users can assign or remove labels on a product without leaving the product form, and can narrow the product list to a single label's products in one interaction (select label filter) and clear it in one interaction.
- **SC-005**: Existing product catalog workflows (search, create, edit, delete, photo upload) continue to work exactly as before for users who do not interact with the new pickers/filter — no regressions.

## Assumptions

- The mbe-api endpoints for Suppliers, Price Lists, Labels, and the SAT catalogs (units-of-measurement, product-services) are stable list/get endpoints with server-side search and pagination, as implemented in `002-master-data-endpoints` on mbe-api and reflected in mbe-ui's generated API client.
- All FK fields in `ProductResponse` and `ProductListItem` are **pre-expanded server-side**: `supplier` returns a full `SupplierResponse`, `unit_of_measurement` returns a `SatUnitOfMeasurementResponse` (with name, description, symbol), `key` returns a `SatCatalogResponse` (with description), and each `ProductPriceResponse.price_list` returns a `PriceListResponse` with its name. No separate per-ID lookup calls are needed on the detail or list screens.
- `ProductCreate` and `ProductUpdate` request bodies accept plain IDs for FK fields (supplier id, SAT code strings) and a `labels: list[int]` field for label assignment; the expansion is response-only.
- "Brand" and "model" on the product remain free-text fields; they are not backed by a master-data catalog and are out of scope for this feature.
- Production sites, taxpayer recipients, and other master-data entities are not referenced by the `Product` model and are out of scope for this feature.
- This feature reuses the existing Products system-object RBAC from `001-user-authentication`/`002-product-catalog` as-is; no new privileges or system objects are introduced.
- Pickers for supplier, unit of measurement, product/service key, and labels follow the same search-as-you-type and empty-state UX patterns already established by the products list search in `002-product-catalog`, for consistency.
