# Feature Specification: Facility-Scoped Operational Catalogs (Warehouses, Points of Sale, Cash Drawers)

**Feature Branch**: `014-facility-scoped-catalogs`

**Created**: 2026-07-19

**Status**: Draft

**Input**: User description: "Let's create a spec to build the UI for the following catalogs: Warehouses, PointsOfSale, CashDrawers, Facilities."

## Clarifications

### Session 2026-07-19

- Q: Facilities create/edit needs an address reference the app cannot resolve (no address management exists anywhere in the product) and a required logo value with no way to upload one. How should Facilities be scoped? → A: **Out of scope as a screen.** Facilities gets no list or detail screen in this feature. Facility is still consumed **read-only** by all three in-scope catalogs — as a required picker on every form and as a list filter — because every one of them is facility-scoped. Upstream requests are filed for the missing address management (mictlanix/mbe-api#90), the logo upload path (#91), the unnamed facility-type values (#92), and the facility access-control object (#93); a later feature adds Facility management once they land.
- Q: Facilities appears to be a new concept — how does it relate to what exists today? → A: **Facilities is the merged successor of the legacy Store and Production Site concepts.** A facility carries a type distinguishing the two. **Confirmed 2026-07-19** against the mbe-api source: the type is an integer enum where `0` is Store and `1` is Production Site (mictlanix/mbe-api#92, closed). The published contract still omits the member names, so this feature names them once in a small hand-written domain enum, exactly as the existing shared status and gender enums already do.
- Q: Do the two facility types carry different fields, or is type just a label? → A: **Just a label and a filter.** A facility has one flat shape with no type-conditional fields, so nothing in this feature varies by facility type.
- Q: None of the three in-scope list endpoints expose a free-text search capability, yet the constitution (§VI) forbids search-less catalog screens. How should this be handled? → A: Same resolution as spec 013 (§III): file upstream requests for server-side search on all in-scope list endpoints (filed as mictlanix/mbe-api#86 warehouses, #87 points of sale, #88 cash drawers, plus #89 for the facilities list the pickers read) and build the UI as if it exists — the search box is present on every screen and wired to that expected capability, activating the moment the backend ships it. This is a tracked external dependency, **not** a constitution deviation and **not** a client-side filtering workaround.

## User Scenarios & Testing *(mandatory)*

<!--
  IMPORTANT: User stories are PRIORITIZED as user journeys ordered by importance.
  Each is INDEPENDENTLY TESTABLE — implementing just one still yields a viable MVP slice.
-->

### User Story 1 - Manage the Warehouses catalog (Priority: P1)

A user with the appropriate privilege needs to see the full list of warehouses across the organization, narrow that list to a single facility or to active records only, open a warehouse to view its detail, create a new warehouse under a chosen facility, edit its code, name or comment, change its status, and delete one that is no longer in use — all from a dedicated Warehouses screen, the same way products and the spec-012/013 catalogs are managed today.

**Why this priority**: Warehouses is the foundational slice of the three. It establishes the facility picker and the facility/status filter pattern that both other catalogs reuse, and a warehouse is itself a prerequisite of a point of sale (User Story 3). It is also the entity users most directly recognize, and it is entirely unmanaged in the UI today.

**Independent Test**: Can be fully tested by opening the Warehouses catalog, filtering to a single facility, creating a new warehouse by picking a facility and entering a code and name, editing its comment, changing its status, viewing it read-only, and deleting one — independent of the other two catalogs in this feature.

**Acceptance Scenarios**:

1. **Given** a user with read privilege on warehouses, **When** they open the Warehouses catalog, **Then** they see a paginated list of all warehouses showing each one's facility, code, name, and status.
2. **Given** the warehouses list, **When** the user opens the filter controls, **Then** they can narrow the list to a specific facility and/or to a specific status, and the two filters combine.
3. **Given** a user with create or update privilege on the warehouse form, **When** they open the facility field and search by name, **Then** matching facilities are shown for selection, and the chosen facility's name (not a raw id) is shown wherever the warehouse is displayed.
4. **Given** a user with create privilege, **When** they select a facility and enter a code and a name and save, **Then** the new warehouse appears in the list.
5. **Given** a user with update privilege viewing a warehouse, **When** they edit any field and save, **Then** the change is reflected on the list and detail screen.
6. **Given** a user with delete privilege viewing a warehouse's detail screen, **When** they confirm deletion, **Then** the warehouse no longer appears in the catalog.
7. **Given** a user without update privilege, **When** they open a warehouse's detail screen, **Then** it renders read-only with no edit or delete affordance.
8. **Given** a user creating a warehouse with a code another warehouse already uses, **When** they save and the system rejects it, **Then** the rejection is shown clearly on the form and the user's other input is preserved.

---

### User Story 2 - Manage the Cash Drawers catalog (Priority: P1)

A user with the appropriate privilege needs to see the full list of cash drawers, narrow that list to a single facility or status, open a cash drawer to view its detail, create a new one under a chosen facility, edit its code, name or comment, change its status, and delete one that is no longer in use — from a dedicated Cash Drawers screen.

**Why this priority**: A cash drawer has exactly the same shape as a warehouse (facility, code, name, comment, status) and depends on nothing beyond the facility picker that User Story 1 establishes. Equal priority as an independent, low-risk slice that no other story blocks on.

**Independent Test**: Can be fully tested by opening the Cash Drawers catalog, filtering to a single facility, creating a new cash drawer, editing its name, changing its status, and deleting one — independent of the other two catalogs in this feature.

**Acceptance Scenarios**:

1. **Given** a user with read privilege on cash drawers, **When** they open the Cash Drawers catalog, **Then** they see a paginated list of all cash drawers showing each one's facility, code, name, and status.
2. **Given** the cash drawers list, **When** the user opens the filter controls, **Then** they can narrow the list to a specific facility and/or to a specific status, and the two filters combine.
3. **Given** a user with create privilege, **When** they select a facility and enter a code and a name and save, **Then** the new cash drawer appears in the list.
4. **Given** a user with update privilege viewing a cash drawer, **When** they edit any field and save, **Then** the change is reflected on the list and detail screen.
5. **Given** a user with delete privilege viewing a cash drawer's detail screen, **When** they confirm deletion, **Then** the cash drawer no longer appears in the catalog.
6. **Given** a user without update privilege, **When** they open a cash drawer's detail screen, **Then** it renders read-only with no edit or delete affordance.

---

### User Story 3 - Manage the Points of Sale catalog (Priority: P2)

A user with the appropriate privilege needs to see the full list of points of sale, narrow that list by facility, by the warehouse that fulfils it, or by status, open one to view its detail — with both its facility and its warehouse shown by name, not raw ids — create a new point of sale by picking a facility and the warehouse it draws stock from, edit its details, change its status, and delete one that is retired.

**Why this priority**: A point of sale references **both** a facility and a warehouse, so it depends on the warehouse catalog and picker delivered by User Story 1. That dependency makes it correctly a P2 that builds on a P1 foundation, and it carries the one genuine design question in this feature (how tightly the warehouse choice is coupled to the chosen facility).

**Independent Test**: Can be fully tested by opening the Points of Sale catalog, filtering by facility and by warehouse, creating a new point of sale by selecting a facility and a warehouse, editing its comment, changing its status, and deleting one — assuming User Story 1's warehouse data exists.

**Acceptance Scenarios**:

1. **Given** a user with read privilege on points of sale, **When** they open the catalog, **Then** they see a paginated list showing each record's facility, code, name, warehouse, and status.
2. **Given** the points of sale list, **When** the user opens the filter controls, **Then** they can narrow the list to a specific facility, a specific warehouse, and/or a specific status, and the filters combine.
3. **Given** a user with create or update privilege on the point-of-sale form, **When** they open the warehouse field and search, **Then** matching warehouses are shown for selection, and the chosen warehouse's name (not a raw id) is shown wherever the point of sale is displayed.
4. **Given** a user with create privilege who has selected a facility, **When** they open the warehouse picker, **Then** the warehouses offered are those belonging to the selected facility, so an inconsistent pairing cannot be built by accident.
5. **Given** a user with create privilege, **When** they select a facility and a warehouse and enter a code and a name and save, **Then** the new point of sale appears in the list.
6. **Given** a user with update privilege viewing a point of sale, **When** they edit any field and save, **Then** the change is reflected on the list and detail screen.
7. **Given** a user with delete privilege viewing a point of sale's detail screen, **When** they confirm deletion, **Then** the record no longer appears in the catalog.
8. **Given** a point of sale whose facility or warehouse cannot be resolved, **When** its detail screen loads, **Then** a fallback label is shown instead of failing the whole screen.

---

### Edge Cases

- What happens when one of these three catalogs has no records yet, or a filter combination yields no matches? → Show the existing empty-state pattern used elsewhere in the app ("no results"), not an error.
- How does a user find a specific record in these catalogs? → Every screen ships a search box (FR-002) alongside its facet filters. The app MUST NOT ship a search-less catalog screen (§VI). Until the backend ships server-side search, the box is present and wired to the expected capability (see Assumptions).
- What happens when the facility picker's search returns no matches, or no facilities exist at all? → The same empty-state pattern as any other picker in the app. Because a facility is required on all three entities, a user who cannot select one cannot create a record; the form makes the unmet requirement explicit rather than failing silently on save.
- What happens if a facility or warehouse referenced by a record is later deleted or otherwise cannot be resolved? → The referencing screen shows a clear fallback label rather than crashing or showing a blank/raw value.
- What happens when a user changes the facility on an existing point of sale whose warehouse belongs to the previous facility? → The form surfaces the now-inconsistent pairing and requires the user to reselect a warehouse before saving, rather than submitting a mismatched pair.
- What happens when a user enters a code that another record in the same catalog already uses? → The system surfaces whatever rejection the backend returns on save; the UI never pre-validates uniqueness speculatively and never silently rewrites the user's code.
- What happens when a user attempts to delete a record that is still referenced elsewhere (a warehouse holding stock, a warehouse a point of sale draws from, a cash drawer with session history)? → The system surfaces whatever rejection the backend returns; the UI never pre-blocks the attempt speculatively, and never silently drops the reference.
- What happens when a user without any privilege on one of these three catalogs tries to navigate directly to its route? → Denied per the existing deny-by-default access control, consistent with every other catalog in the app.
- What happens when a user has privilege on a catalog but cannot read facilities? → The list still renders, and the facility filter and picker degrade to their empty state rather than breaking the screen (see FR-021).

## Requirements *(mandatory)*

### Functional Requirements

**Cross-cutting (all three catalogs)**

- **FR-001**: Each of the three catalogs (Warehouses, Points of Sale, Cash Drawers) MUST have its own dedicated list screen showing a paginated table of records, consistent in look, feel, and interaction with the existing Products catalog and the spec-012/013 catalogs.
- **FR-002**: Each catalog's list screen MUST ship a free-text search box using the shared filter/search pattern, and MUST NOT ship search-less (constitution §VI). The search box filters by the record's identifying text (code and name), wired to the server-side search capability requested upstream for all three list endpoints (mictlanix/mbe-api#86, #87, #88); it activates without UI rework once that capability ships.
- **FR-003**: In addition to search, each list screen MUST expose the backend-supported facet filters using the shared filter controls, independently combinable with each other and with search — facility and status on all three catalogs, plus warehouse on Points of Sale.
- **FR-004**: Creating a record MUST be available as a primary action alongside the list's filter/search bar (not tucked into a menu), visible only to users holding create privilege for that catalog.
- **FR-005**: Each catalog row's sole direct action MUST be Edit, visible only to users holding update privilege; clicking anywhere else on the row MUST open that record's detail screen in read-only ("View") mode.
- **FR-006**: A read-only detail screen MUST offer an explicit control to switch to the editable form when the current user holds update privilege, and MUST NOT offer that control otherwise.
- **FR-007**: Deleting a record MUST be available only from that record's own detail screen (never as a row action on the list), visible only to users holding delete privilege for that catalog, and MUST require an explicit confirmation before the delete is submitted.
- **FR-008**: Every mutable action (create, update, delete) on every one of these three catalogs MUST be gated by the existing per-catalog access-control privilege already defined in the system for Warehouses, Points of Sale, and Cash Drawers respectively; a user lacking a privilege MUST NOT see the corresponding control.
- **FR-009**: All three catalogs MUST be reachable from the app's existing catalog navigation area, each shown only to users holding at least read privilege on that catalog.
- **FR-010**: Screen-level actions other than the single read-only-to-edit toggle MUST NOT be placed as toolbar icon actions; they MUST appear as visible-label buttons in the screen body, consistent with how Create already works on the Products and spec-012/013 catalogs.
- **FR-011**: All three catalogs MUST display a record's status using the shared status-badge pattern already used elsewhere in the catalog module, and MUST reuse the product's existing shared status concept rather than introducing a new one.
- **FR-012**: A rejection returned by the backend on save or delete (duplicate code, referential constraint, validation) MUST be surfaced to the user in place, using the app's existing error-banner pattern, without discarding the user's unsaved input.

**Warehouses (User Story 1)**

- **FR-013**: The Warehouses catalog MUST support creating, viewing, editing, and deleting a warehouse with fields: facility, code, name, comment, and status.
- **FR-014**: Facility, code, and name MUST be required on create.
- **FR-015**: The warehouse form MUST provide a searchable picker for the facility field, showing the human-readable facility name rather than requiring a raw id; the warehouses list and detail screen MUST display the facility by name, and a facility that cannot be resolved MUST show a fallback label.

**Cash Drawers (User Story 2)**

- **FR-016**: The Cash Drawers catalog MUST support creating, viewing, editing, and deleting a cash drawer with fields: facility, code, name, comment, and status.
- **FR-017**: Facility, code, and name MUST be required on create.
- **FR-018**: The cash drawer form MUST provide the same searchable facility picker described in FR-015, with the same by-name display and fallback behavior on its list and detail screens.

**Points of Sale (User Story 3)**

- **FR-019**: The Points of Sale catalog MUST support creating, viewing, editing, and deleting a point of sale with fields: facility, code, name, warehouse, comment, and status.
- **FR-020**: Facility, code, name, and warehouse MUST be required on create.
- **FR-021**: The point-of-sale form MUST provide searchable pickers for both the facility and the warehouse fields, showing human-readable names rather than raw ids; the list and detail screens MUST display both by name, and either one that cannot be resolved MUST show a fallback label.
- **FR-022**: The warehouse picker on the point-of-sale form MUST offer only warehouses belonging to the currently selected facility, and MUST require the user to reselect a warehouse when the facility is changed to one the current warehouse does not belong to. [NEEDS CLARIFICATION: does the backend itself enforce that a point of sale's warehouse belongs to its facility, or is this a UI-only guard? If the backend permits a cross-facility pairing deliberately, this constraint must be relaxed to a warning rather than a hard requirement.]

**Facility consumption (all three catalogs; Facilities itself is out of scope)**

- **FR-023**: The facility picker and facility filter MUST read facilities from the existing facility source without providing any means to create, edit, or delete a facility in this feature.
- **FR-024**: Where a facility is displayed on any of the three catalogs, its type (Store or Production Site) MAY be shown as a plain label to disambiguate similarly named facilities, but MUST NOT change the behavior, fields, or layout of any screen in this feature.
- **FR-025**: Reading facilities for the picker and filter MUST degrade gracefully — if the current user cannot read facilities, the affected list screen still renders and the facility controls show their empty state rather than failing the screen. [NEEDS CLARIFICATION: which access-control object governs reading facilities? Facilities merged the legacy Store and Production Site concepts, and an access-control object exists for each of those, but none exists for facilities itself. Pending upstream confirmation — mictlanix/mbe-api#93.]
- **FR-026**: The facility type MUST be named in exactly one place in the app — a small domain enum mapping the backend's integer values (Store `0`, Production Site `1`) to readable terms — so no screen reads or compares raw type numbers, consistent with how the shared status and gender concepts are already handled.

### Key Entities *(include if feature involves data)*

- **Warehouse**: A stock-holding location belonging to exactly one facility, identified by a system-assigned id, with a code, a name, an optional comment, and a status. Referenced by points of sale. Not previously manageable in the UI.
- **Point of Sale**: A selling station belonging to exactly one facility and drawing stock from exactly one warehouse, identified by a system-assigned id, with a code, a name, an optional comment, and a status. References both a Facility and a Warehouse. Not previously manageable in the UI.
- **Cash Drawer**: A cash-handling station belonging to exactly one facility, identified by a system-assigned id, with a code, a name, an optional comment, and a status. Structurally identical to Warehouse. Not previously manageable in the UI.
- **Facility** *(consumed read-only; management out of scope)*: An operating site — the merged successor of the legacy Store and Production Site concepts, carrying a type that distinguishes the two. Every entity in this feature belongs to exactly one facility. This feature only reads facilities to power a picker and a filter; creating, editing, and deleting facilities is deferred to a later feature (see Assumptions).
- **Status** *(reused, not newly introduced)*: The shared record-status concept already defined in the product and already displayed via the existing status badge; this feature introduces no new status concept.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A privileged user can locate, create, edit, or delete a record in any of the three catalogs in under 30 seconds from landing on that catalog's list screen.
- **SC-002**: 100% of records across the three catalogs display their facility — and, for points of sale, their warehouse — as a human-readable name (or an explicit fallback label), never as a raw id, on both the list and detail screens.
- **SC-003**: A user can reduce any of the three lists to the records of a single facility in at most two interactions from the list screen.
- **SC-004**: Zero point-of-sale records can be created through the UI whose warehouse belongs to a facility other than the record's own (subject to FR-022's clarification).
- **SC-005**: A user lacking any privilege on one of these three catalogs cannot reach its screens, and a user lacking only update/delete privilege never sees an edit or delete control for it.
- **SC-006**: Zero regressions in any existing catalog screen or shared picker after this feature ships.
- **SC-007**: Every backend rejection on save or delete (duplicate code, referential constraint) is surfaced to the user without loss of unsaved form input — no silent failures.

## Assumptions

- All three in-scope backend endpoints (Warehouses, Points of Sale, Cash Drawers) already exist as complete Create/Read/Update/Delete APIs and are already reflected in the generated API client; no backend change is required for the CRUD surface of this feature.
- All three in-scope catalogs already have their own access-control privilege defined in the system (Warehouses, Points of Sale, Cash Drawers); no new privilege needs to be introduced for them. The facility access-control object is the one open question (FR-025).
- The shared record-status concept and its badge already exist in the product and are reused unchanged; this feature adds no new status concept.
- Facility, warehouse, code, and name are required on the entities that carry them; comment is always optional; status defaults to whatever the backend applies when the form leaves it unset.
- The facility and warehouse pickers reuse the same searchable-picker pattern already delivered for the salesperson picker (spec 012) and the driver picker (spec 013); no new picker concept is introduced.
- **Facilities management is out of scope** *(decision 2026-07-19, see Clarifications)*: creating, editing, and deleting facilities is deferred to a later feature. Three upstream gaps block it today — a facility references an address the app has no way to browse, search, or create, since no address management exists anywhere in the product (mictlanix/mbe-api#90); a facility requires a logo value with no upload path or format contract (#91); and the facility type values carry no names in the published contract (#92 — **closed 2026-07-19**, the Store `0` / Production Site `1` mapping is confirmed and no longer blocks anything). The two remaining gaps are filed, plus a third asking which access-control object governs facilities (#93, see FR-025). Warehouses, Points of Sale, and Cash Drawers are unaffected and proceed; they only read facilities.
- **Search & Browse** *(open cross-repository dependency)*: none of the in-scope list endpoints currently exposes a free-text search capability. Following the spec-013 precedent, upstream requests are filed for server-side search on all three — mictlanix/mbe-api#86 (warehouses), #87 (points of sale), #88 (cash drawers), plus #89 for the facilities list the pickers read — matching the semantics of the search already available on customers, employees, and suppliers. The UI ships the search box wired to that expected capability so it activates without rework the moment it lands. Client-side filtering of a single fetched page is explicitly **not** an acceptable substitute. The facet filters (facility, status, and warehouse on points of sale) are available today and carry findability in the interim.
- Bulk import/export (e.g. CSV) for any of these catalogs is out of scope; each record is created/edited one at a time, consistent with every existing catalog in the app.
- Cash drawer *sessions* (opening, closing, reconciling a drawer) are a separate operational concern and are out of scope; this feature manages the cash drawer master record only.
- Warehouse *stock* (quantities, lots, serial numbers, movements) is out of scope; this feature manages the warehouse master record only.

## Verbatim Constraints

Identifiers pinned by the request that the implementation MUST match exactly:

- Access-control objects for the three in-scope catalogs: `warehouses(4)`, `pointsOfSale(9)`, `cashDrawers(10)`.
- Legacy access-control objects relevant to the facility question (FR-025): `stores(29)`, `productionSites(107)`.
- The shared status enum to reuse, not redefine: `lib/core/domain/entity_status.dart`.
- List-endpoint query parameters available today: `facility`, `status`, `skip`, `limit` on all three; plus `warehouse` on points of sale.
- The list-endpoint query parameter requested upstream and wired for in advance: `search`.

## Upstream Dependencies

Filed against `mictlanix/mbe-api` on 2026-07-19 on behalf of this spec:

| Issue | Subject | Blocking? |
|---|---|---|
| [#86](https://github.com/mictlanix/mbe-api/issues/86) | `search` param on `GET /api/v1/warehouses` | No — box ships wired, activates on landing |
| [#87](https://github.com/mictlanix/mbe-api/issues/87) | `search` param on `GET /api/v1/points-of-sale` | No — same |
| [#88](https://github.com/mictlanix/mbe-api/issues/88) | `search` param on `GET /api/v1/cash-drawers` | No — same |
| [#89](https://github.com/mictlanix/mbe-api/issues/89) | `search` param on `GET /api/v1/facilities` | No — affects picker search quality only |
| [#90](https://github.com/mictlanix/mbe-api/issues/90) | `Facility.address` references a nonexistent addresses resource | Yes — for deferred Facilities management only |
| [#91](https://github.com/mictlanix/mbe-api/issues/91) | `FacilityCreate.logo` required with no upload path | Yes — for deferred Facilities management only |
| ~~[#92](https://github.com/mictlanix/mbe-api/issues/92)~~ | ~~`FacilityType` has no member names; Store/ProductionSite mapping unpublished~~ | **Closed 2026-07-19** — mapping confirmed as Store `0` / Production Site `1`; named UI-side per FR-026 |
| [#93](https://github.com/mictlanix/mbe-api/issues/93) | No `SystemObject` governs `/api/v1/facilities` | No — resolves FR-025's marker |

None of these block the three in-scope catalogs.
