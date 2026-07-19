# Feature Specification: Catalog Logistics Entities (Expenses, Vehicles, Vehicle Operators)

**Feature Branch**: `013-catalog-logistics-payment-entities`

**Created**: 2026-07-19

**Status**: Draft

**Input**: User description: "Add full CRUD catalog UIs for four more master-data entities mbe-api already exposes with complete Create/Read/Update/Delete endpoints — Expenses, PaymentMethodOptions, Vehicles, and VehicleOperators — following the same paginated-list + view/edit/create patterns established by the Products catalog and by spec 012 (Customers/Employees/Suppliers/Labels/TaxpayerRecipients)."

## Clarifications

### Session 2026-07-19

- Q: Given the four list endpoints expose no free-text `search`, how should users browse/find records while the constitution (§VI) forbids search-less catalog screens? → A: File mbe-api issues requesting a server-side `search` parameter on all in-scope endpoints and build the UI as if it exists (search box present on every screen, wired to that expected parameter).
- Q: Should the Payment Method Options catalog (originally User Story 4) be part of this feature? → A: No — deferred / out of scope. The store and warehouse APIs it depends on may be replaced by a broader "facilities" API upstream, so building store/warehouse pickers now risks near-term rework. This feature is reduced to three entities: Expenses, Vehicles, and Vehicle Operators. Payment Method Options is deferred to a later feature once the facilities API direction is settled.

## User Scenarios & Testing *(mandatory)*

<!--
  IMPORTANT: User stories are PRIORITIZED as user journeys ordered by importance.
  Each is INDEPENDENTLY TESTABLE — implementing just one still yields a viable MVP slice.
-->

### User Story 1 - Manage the Expenses catalog (Priority: P1)

A user with the appropriate privilege needs to see the full list of expense concepts, view an expense's detail, create a new expense concept, edit its name or comment, and delete one that is no longer used — all from a dedicated Expenses screen, the same way products and the spec-012 catalogs are managed today.

**Why this priority**: Expenses is the simplest of the three (just a name and an optional comment, structurally identical to Labels), has no dependency on any other new catalog or picker, and is entirely unmanaged in the UI today. It is the cheapest, highest-confidence first slice that proves the whole pattern end-to-end.

**Independent Test**: Can be fully tested by opening the Expenses catalog, creating a new expense concept, editing its comment, viewing it read-only, and deleting one — independent of any other catalog in this feature.

**Acceptance Scenarios**:

1. **Given** a user with read privilege on expenses, **When** they open the Expenses catalog, **Then** they see a paginated list of all expense concepts with their name and comment.
2. **Given** a user with create privilege, **When** they enter an expense name and save, **Then** the new expense appears in the list.
3. **Given** a user with update privilege viewing an expense, **When** they edit its name or comment and save, **Then** the change is reflected on the list and detail screen.
4. **Given** a user with delete privilege viewing an expense's detail screen, **When** they confirm deletion, **Then** the expense no longer appears in the catalog.
5. **Given** a user without update privilege, **When** they open an expense's detail screen, **Then** it renders read-only with no edit or delete affordance.

---

### User Story 2 - Manage the Vehicles catalog (Priority: P1)

A user with the appropriate privilege needs to see the full list of vehicles, view a vehicle's detail, create a new vehicle, edit its details, mark it active or inactive, and delete one that is no longer part of the fleet — from a dedicated Vehicles screen.

**Why this priority**: Vehicles is a simple, self-contained record (license plate, name, nickname, tonnage capacity, active flag) with no dependency on any other new catalog or picker. Equal priority to Expenses as an independent, low-risk slice, and it is the conceptual companion of Vehicle Operators (User Story 3) in the logistics area.

**Independent Test**: Can be fully tested by opening the Vehicles catalog, creating a new vehicle with its license plate and capacity, editing its nickname, toggling its active flag, and deleting one — independent of any other catalog in this feature.

**Acceptance Scenarios**:

1. **Given** a user with read privilege on vehicles, **When** they open the Vehicles catalog, **Then** they see a paginated list of all vehicles with license plate, name, nickname, and active status.
2. **Given** a user with create privilege, **When** they fill in the required vehicle fields (license plate, name, nickname, tonnage capacity) and save, **Then** the new vehicle appears in the list.
3. **Given** a user with update privilege viewing a vehicle, **When** they edit any field and save, **Then** the change is reflected on the list and detail screen.
4. **Given** a user with delete privilege viewing a vehicle's detail screen, **When** they confirm deletion, **Then** the vehicle no longer appears in the catalog.
5. **Given** a user without update privilege, **When** they open a vehicle's detail screen, **Then** it renders read-only with no edit or delete affordance.

---

### User Story 3 - Manage the Vehicle Operators catalog (Priority: P2)

A user with the appropriate privilege needs to see the full list of vehicle operators (drivers and their driving-license details), filter the list to a specific driver, view an operator's full detail — including the driver shown by name, not raw id — create a new operator record by picking an employee as the driver, edit the license details, mark it active or inactive, and delete one that is no longer needed.

**Why this priority**: A vehicle operator links an existing employee (the driver) to their driving-license credentials (type, number, issue/expiration dates, issuing location). It depends on the employee picker shipped by spec 012 so the driver field has real data to search — making it correctly a P2 that builds on a P1 foundation from the prior feature. It is independently useful once that picker exists.

**Independent Test**: Can be fully tested by opening the Vehicle Operators catalog, filtering to a specific driver, creating a new operator by searching and selecting an employee, entering the license details and dates, editing the issuing location, and deleting one — assuming the employee catalog (spec 012) has already shipped.

**Acceptance Scenarios**:

1. **Given** a user with read privilege on vehicle operators, **When** they open the catalog, **Then** they see a paginated list of operators with driver name, license type, license number, expiration date, and active status.
2. **Given** the operators list, **When** the user opens the filter controls, **Then** they can narrow the list to a specific driver (employee).
3. **Given** a user with create or update privilege on the operator form, **When** they open the driver field and search by name, **Then** matching employees are shown for selection, and the chosen employee's name (not a raw id) is shown wherever the operator is displayed.
4. **Given** a user with create privilege, **When** they select a driver and fill in the required license fields (license type, license number, issue date, expiration date, issuing location) and save, **Then** a new operator appears in the catalog.
5. **Given** an operator whose driving license is near or past its expiration date, **When** it is viewed on the list or detail screen, **Then** the remaining time until expiry is shown as a human-readable value derived from the expiration date.
6. **Given** an operator's driver employee cannot be resolved, **When** its detail screen loads, **Then** a fallback label is shown instead of failing the whole screen.

---

### Edge Cases

- What happens when one of these three catalogs has no records yet, or a filter yields no matches? → Show the existing empty-state pattern used elsewhere in the app ("no results"), not an error.
- How does a user find a specific record when the underlying list endpoints provide no free-text search today (only pagination, plus a driver filter for Vehicle Operators)? → Every screen ships a search box wired to a server-side `search` parameter requested from mbe-api (FR-002); until that parameter lands and the client is regenerated, the search box is present (satisfying §VI) but returns results only once the backend supports it. The app MUST NOT ship a search-less catalog screen.
- What happens if a vehicle operator's driver employee is later deleted from its source catalog? → The referencing screen shows a clear fallback label (e.g. "Unknown driver") rather than crashing or showing a blank/raw value.
- What happens when the driver picker search returns no matches while creating/editing an operator? → Same empty-state pattern as any other picker in the app; the user can retry with a different search term without losing other form input.
- What happens when a user without any privilege on one of these three system objects tries to navigate directly to its route? → Denied per the existing deny-by-default RBAC, consistent with every other catalog in the app.
- What happens when a user attempts to delete a record from any of these three catalogs that is still referenced elsewhere (a vehicle operator referenced by a service order, etc.)? → The system surfaces whatever rejection the backend returns; the UI never pre-blocks the attempt speculatively, and never silently drops the reference.

## Requirements *(mandatory)*

### Functional Requirements

**Cross-cutting (all three catalogs)**

- **FR-001**: Each of the three catalogs (Expenses, Vehicles, Vehicle Operators) MUST have its own dedicated list screen showing a paginated table of records, consistent in look, feel, and interaction with the existing Products catalog and the spec-012 catalogs.
- **FR-002**: Each catalog's list screen MUST ship a free-text search box using the shared filter/search pattern, and MUST NOT ship search-less (constitution §VI). The search box filters by the record's identifying text (expense name; vehicle license plate/name/nickname; operator driver name/license number). Because none of the three list endpoints currently expose a free-text `search` parameter, mbe-api issues MUST be filed requesting one on all three endpoints, and the UI is built against that expected parameter (see Assumptions / Dependencies) — the search box is wired to server-side search, consistent with the spec-012 catalogs, and becomes fully functional once mbe-api ships the parameter and the client is regenerated.
- **FR-002a**: In addition to search, each list screen MUST expose the backend-supported facet filters where they exist — a driver filter on Vehicle Operators (FR-018) — using the shared filter controls, independently combinable with search.
- **FR-003**: Creating a record MUST be available as a primary action alongside the list's filter/search bar (not tucked into a menu), visible only to users holding create privilege for that catalog.
- **FR-004**: Each catalog row's sole direct action MUST be Edit, visible only to users holding update privilege; clicking anywhere else on the row MUST open that record's detail screen in read-only ("View") mode.
- **FR-005**: A read-only detail screen MUST offer an explicit control to switch to the editable form when the current user holds update privilege, and MUST NOT offer that control otherwise.
- **FR-006**: Deleting a record MUST be available only from that record's own detail screen (never as a row action on the list), visible only to users holding delete privilege for that catalog, and MUST require an explicit confirmation before the delete is submitted.
- **FR-007**: Every mutable action (create, update, delete) on every one of these three catalogs MUST be gated by the existing per-catalog access-control privilege already defined in the system for Expenses, Vehicles, and Vehicle Operators respectively; a user lacking a privilege MUST NOT see the corresponding control.
- **FR-008**: All three catalogs MUST be reachable from the app's existing catalog navigation area, each only shown to users holding at least read privilege on that catalog.
- **FR-009**: Screen-level actions other than the single read-only-to-edit toggle MUST NOT be placed as toolbar icon actions; they MUST appear as visible-label buttons in the screen body, consistent with how Create already works on the Products and spec-012 catalogs.

**Expenses (User Story 1)**

- **FR-010**: The Expenses catalog MUST support creating, viewing, editing, and deleting an expense concept with fields: name and comment.
- **FR-011**: Name MUST be required on create.

**Vehicles (User Story 2)**

- **FR-012**: The Vehicles catalog MUST support creating, viewing, editing, and deleting a vehicle with fields: license plate, name, nickname, tonnage capacity, and active flag.
- **FR-013**: License plate, name, nickname, and tonnage capacity MUST be required on create.
- **FR-014**: The Vehicles list and detail screen MUST display the vehicle's active/inactive status clearly.

**Vehicle Operators (User Story 3)**

- **FR-015**: The Vehicle Operators catalog MUST support creating, viewing, editing, and deleting a vehicle operator with fields: driver (an employee), license type, driver license number, issue date, expiration date, issuing location, and active flag.
- **FR-016**: Driver, license type, driver license number, issue date, expiration date, and issuing location MUST be required on create.
- **FR-017**: The operator form MUST provide a searchable picker for the driver field (search/select from existing employees), showing the human-readable employee name rather than requiring a raw id; the Vehicle Operators list and detail screen MUST display the driver by name, and a driver that cannot be resolved MUST show a fallback label.
- **FR-018**: The Vehicle Operators list MUST provide a filter control to narrow the list to a specific driver (employee).
- **FR-019**: The Vehicle Operators list and detail screen MUST display the remaining time until the driving license expires, derived from the expiration date, so a user can spot expired or soon-to-expire licenses.

### Key Entities *(include if feature involves data)*

- **Expense**: A named expense concept used to classify outgoing costs, identified by a system-assigned id, with a name and an optional comment. Not previously manageable in the UI. Structurally the simplest of the three (parallels Label from spec 012).
- **Vehicle**: A fleet vehicle, identified by a system-assigned id, with a license plate, name, nickname, tonnage capacity, and an active flag. Not previously manageable in the UI.
- **Vehicle Operator**: A driver's credential record linking an existing employee (the driver) to their driving-license details — license type, license number, issue date, expiration date, issuing location — plus an active flag and a derived "time until expiry" indicator. References an Employee; not previously manageable in the UI.
- **Employee** *(reused, not newly introduced)*: The employee entity delivered by spec 012; this feature only adds a driver picker over it for the Vehicle Operator form/filter, with no changes to employee management itself.
- **Payment Method Option** *(deferred — out of scope)*: A per-store payment configuration. Originally User Story 4, now deferred to a later feature because its required store/warehouse pickers may be invalidated by an upcoming broader "facilities" API upstream (see Clarifications and Assumptions).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A privileged user can locate, create, edit, or delete a record in any of the three catalogs in under 30 seconds from landing on that catalog's list screen.
- **SC-002**: 100% of vehicle operator records display their driver as a human-readable employee name (or an explicit fallback), never as a raw id, across the list and detail screens.
- **SC-003**: 100% of vehicle operator records show a human-readable "time until license expiry" indicator derived from the expiration date.
- **SC-004**: Zero regressions in the existing employee picker (spec 012) or any other existing catalog after this feature ships.
- **SC-005**: A user lacking any privilege on one of these three catalogs cannot reach its screens, and a user lacking only update/delete privilege never sees an edit or delete control for it.

## Assumptions

- All three backend endpoints (Expenses, Vehicles, Vehicle Operators) already exist as complete Create/Read/Update/Delete APIs and are already reflected in the generated API client; no backend/API change is required for the CRUD surface of this feature.
- All three catalogs already have their own access-control privilege defined in the system (Expenses, Vehicle, Vehicle Operators); no new privilege needs to be introduced.
- A Vehicle Operator's driver picker reuses the employee catalog already delivered by spec 012; managing employees themselves is out of scope here.
- Date fields (a vehicle operator's license issue and expiration dates) follow the same date entry/display conventions already established elsewhere in the app (e.g. employee birthday/start date from spec 012).
- A Vehicle Operator does **not** reference a Vehicle in its record — it associates a driver (employee) with license credentials only; pairing operators to specific vehicles (if needed) is a separate concern and out of scope for this feature.
- Bulk import/export (e.g. CSV) for any of these three catalogs is out of scope; each record is created/edited one at a time, consistent with every existing catalog in the app.
- **Payment Method Options is out of scope** *(decision 2026-07-19, see Clarifications)*: originally User Story 4, it is deferred to a later feature. Its form depends on brand-new store and warehouse pickers, and the store/warehouse APIs may be superseded upstream by a broader "facilities" API; building those pickers now risks near-term rework. Expenses, Vehicles, and Vehicle Operators are unaffected and proceed. When Payment Method Options is picked up later, the payment-method SAT enum, money-shaped commission, and store/warehouse (or facilities) pickers will be specified then.
- **Search & Browse dependency** *(resolved decision, 2026-07-19)*: unlike the spec-012 catalogs, none of these three list endpoints currently expose a free-text `search` parameter — they provide pagination only, plus a driver/`employee` filter (Vehicle Operators). The chosen approach is to **file mbe-api issues requesting a server-side `search` parameter on all three endpoints and build the UI as if it exists** (search box present on every screen, wired to that expected parameter). This keeps the three screens constitution-compliant (§VI) and consistent with the spec-012 catalogs. Until mbe-api ships the parameter and the generated client is regenerated to include it, the search box renders but its results depend on backend support. This is a real cross-repository dependency, not a permanent client-side workaround.
- **Dependency on mbe-api change**: this feature assumes the three requested `search` parameters will be delivered on the mbe-api side; the search box is designed to that contract. Tracking the filed issues and regenerating the OpenAPI client once merged is a follow-up captured in the plan.
