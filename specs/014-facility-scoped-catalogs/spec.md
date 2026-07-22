# Feature Specification: Facilities and their Facility-Scoped Operational Catalogs (Facilities, Warehouses, Points of Sale, Cash Drawers)

**Feature Branch**: `014-facility-scoped-catalogs`

**Created**: 2026-07-19

**Status**: Draft

**Input**: User description: "Let's create a spec to build the UI for the following catalogs: Warehouses, PointsOfSale, CashDrawers, Facilities."

## Clarifications

### Session 2026-07-19

- Q: Facilities create/edit needs an address reference the app cannot resolve (no address management exists anywhere in the product) and a required logo value with no way to upload one. How should Facilities be scoped? → A: **Out of scope as a screen.** Facilities gets no list or detail screen in this feature. Facility is still consumed **read-only** by all three in-scope catalogs — as a required picker on every form and as a list filter — because every one of them is facility-scoped. Upstream requests are filed for the missing address management (mictlanix/mbe-api#90), the logo upload path (#91), the unnamed facility-type values (#92), and the facility access-control object (#93); a later feature adds Facility management once they land. **Update 2026-07-20: all four RESOLVED upstream and regenerated into the client** — addresses are now a full CRUD catalog with search, `logo` is optional, the facility-type mapping is confirmed, and `FACILITIES = 29` exists. The blockers that motivated the deferral are gone. **Superseded later the same day: Facilities is back in scope as a fully managed catalog** — see the two questions below and User Story 4. This entry is kept for the record; it no longer describes the feature.
- Q: Facilities appears to be a new concept — how does it relate to what exists today? → A: **Facilities is the merged successor of the legacy Store and Production Site concepts.** A facility carries a type distinguishing the two. **Confirmed 2026-07-19** against the mbe-api source: the type is an integer enum where `0` is Store and `1` is Production Site (mictlanix/mbe-api#92, closed). The published contract still omits the member names, so this feature names them once in a small hand-written domain enum, exactly as the existing shared status and gender enums already do.
- Q: Do the two facility types carry different fields, or is type just a label? → A: **Just a label and a filter.** A facility has one flat shape with no type-conditional fields, so nothing in this feature varies by facility type.
- Q: None of the three in-scope list endpoints expose a free-text search capability, yet the constitution (§VI) forbids search-less catalog screens. How should this be handled? → A: Same resolution as spec 013 (§III): file upstream requests for server-side search on all in-scope list endpoints (filed as mictlanix/mbe-api#86 warehouses, #87 points of sale, #88 cash drawers, plus #89 for the facilities list the pickers read) and build the UI as if it exists — the search box is present on every screen and wired to that expected capability, activating the moment the backend ships it. This is a tracked external dependency, **not** a constitution deviation and **not** a client-side filtering workaround. **Update 2026-07-20: RESOLVED — mbe-api shipped `search` on all four list endpoints (#86/#87/#88/#89) and the generated client was regenerated to include it.** Every `list…` method now accepts `String? search` ahead of its facet params. The dependency is closed; the search box is fully functional and no longer pending.

### Session 2026-07-20

- Q: Does the backend enforce that a point of sale's warehouse belongs to its facility (FR-022's open marker)? → A: **No.** `create_point_sale` and `update_point_sale` assign `facility` and `warehouse` independently with no cross-check, so the backend accepts a cross-facility pairing. The facility-scoped warehouse picker is therefore a **UI-only guard** — still required (it is the only thing preventing an inconsistent pairing through this app), but it cannot be described as enforcing a backend invariant. FR-022 and SC-004 are reworded accordingly, and the missing server-side validation is recorded as a follow-up rather than treated as a UI defect.
- Q: Which access-control object governs facilities (FR-025's open marker)? → A: **`facilities(29)`** — mbe-api **reused the legacy stores slot** rather than adding a new object. `STORES` and `PRODUCTION_SITES` no longer exist in its `SystemObject` enum at all. mbe-ui's own mirror is therefore stale on both counts and must be corrected (FR-027).
- Q: With #90/#91/#92 resolved, should Facilities come back into scope as a managed catalog? → A: **Yes — full CRUD.** Facilities is promoted from a read-only picker source to the feature's fourth managed catalog (User Story 4). This reverses the 2026-07-19 deferral.
- Q: A facility's `taxpayer` is a required foreign key to a taxpayer-issuer record, but that table has **no endpoint** — it cannot be listed, searched, or resolved. How should the form handle it? → A: *(Superseded 2026-07-21 — the endpoint shipped; the taxpayer field is now an autocomplete, see the 2026-07-21 session below. Original interim answer, kept for the record:)* **Free-text RFC entry** as a validated 13-character field, letting the server reject an unregistered key, with the taxpayer-issuer endpoint requested upstream (mictlanix/mbe-api#100) so the field could later become an autocomplete.
- Q: A facility's `address` is a required foreign key, and addresses now have a full API but no UI anywhere — so a picker alone could only reach addresses that already exist. How should it work? → A: **Picker plus inline create.** The address field is a searchable picker over existing addresses, with a path to create a new address from inside the facility form. This keeps the facility form self-sufficient without promoting Addresses to a fourth managed catalog with its own screens.

### Session 2026-07-21

- Q: The three follow-up requests filed 2026-07-20 (#100 taxpayer issuers, #101 address expansion, #102 point-of-sale validation) all shipped upstream and regenerated into the client overnight. What changes? → A: Three interim shapes are retired, each in favor of the proper design the follow-up was requested to enable:
  - **Taxpayer becomes an autocomplete (#100).** The taxpayer-issuers list/get API shipped, gated on `taxpayers(24)` (already in the app's object mirror). The taxpayer field is now a searchable autocomplete over registered issuers, not a typed RFC — FR-034 rewritten, FR-034a/FR-034b added. The interim "typed field designed for a later swap" is gone; the swap is done. Issuer *creation* is deliberately **not** offered inline (it drags in tax regime + certification provider + signing certificates), so a Taxpayer Issuers catalog is noted as a follow-up rather than built here.
  - **Facility address is now pre-expanded (#101).** `FacilityResponse.address` arrives as the full address object, so FR-035's bulk client-side resolve is deleted — the screen renders the expanded address directly with zero extra requests. SC-009 tightened from "at most one additional request" to "zero".
  - **Point-of-sale pairing is now backend-enforced (#102).** `create`/`update` validate that the warehouse belongs to the facility, on both paths, using the effective pairing when only one side changes. FR-022's picker guard drops from "the only protection" to a UX convenience over a real invariant; SC-004 restated as a backend guarantee the UI also upholds.
- Q: The taxpayer-issuers work also brought a `TaxpayerCertificatesApi` and a `FiscalCertificationProvider` enum into the client. Are they in scope? → A: **No.** Those cover fiscal signing certificates (CSD), a separate administrative concern. This feature reads taxpayer issuers only to populate the facility autocomplete; it neither manages certificates nor sets a certification provider. They are noted so a reader knows the omission is deliberate.

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

### User Story 4 - Manage the Facilities catalog (Priority: P2)

A user with the appropriate privilege needs to see the full list of facilities — the stores and production sites the business operates — narrow it by status, open one to view its detail, create a new facility with its code, name, type, fiscal location, street address and taxpayer, edit any of that, change its status, and delete one that is closed. Because no address management exists anywhere else in the app, the facility form must also let the user create a new address inline rather than only pick an existing one.

**Why this priority**: Facilities is the parent of all three other catalogs, and today there is no way to manage one from the app at all — a facility has to be created by other means before a warehouse can point at it. That makes it genuinely valuable. It is P2 rather than P1 because the other three catalogs can ship and be tested against facility data that already exists, and because this story carries by far the largest form — the inline address sub-form and the taxpayer autocomplete included — so it should not gate the simpler slices.

**Independent Test**: Can be fully tested by opening the Facilities catalog, creating a facility with a new inline address and a taxpayer picked from the autocomplete, editing its receipt message, changing its status, and deleting one — independent of the other three catalogs, though they consume its output.

**Acceptance Scenarios**:

1. **Given** a user with read privilege on facilities, **When** they open the Facilities catalog, **Then** they see a paginated list showing each facility's code, name, type, and status.
2. **Given** the facilities list, **When** the user opens the filter controls, **Then** they can narrow the list by status, and search by code or name.
3. **Given** a user with create privilege, **When** they enter a code, name, type, fiscal location, address and taxpayer and save, **Then** the new facility appears in the list and is immediately selectable in the other three catalogs' facility pickers.
4. **Given** a user filling in the facility form, **When** they open the address field, **Then** they can search existing addresses **and** create a new one inline without leaving the form or losing their other input.
5. **Given** a user creating an address inline, **When** they save it, **Then** it becomes the facility's selected address and is shown by its readable description rather than a raw id.
6. **Given** a user on the taxpayer field, **When** they type part of an RFC or issuer name, **Then** matching registered issuers are offered, and selecting one stores that issuer's RFC and displays its name; a facility cannot be saved with an issuer that was never selected.
7. **Given** a user with update privilege viewing a facility, **When** they edit any field and save, **Then** the change is reflected on the list and detail screen.
8. **Given** a user with delete privilege viewing a facility's detail screen, **When** they confirm deletion, **Then** the facility no longer appears in the catalog.
9. **Given** a facility still referenced by a warehouse, point of sale, or cash drawer, **When** the user attempts to delete it and the server rejects it, **Then** the rejection is surfaced and the facility is left intact.
10. **Given** a user without update privilege, **When** they open a facility's detail screen, **Then** it renders read-only with no edit or delete affordance.

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
- What happens when a user has privilege on a catalog but cannot read facilities? → The list still renders, and the facility filter and picker degrade to their empty state rather than breaking the screen (see FR-025).
- What happens when a user can create facilities but not addresses? → The address picker still works over existing addresses; the inline-create path is hidden rather than shown and failing (FR-032). If no address exists at all, the user cannot complete the facility and the form says so plainly.
- What happens when the inline address save succeeds but the facility save then fails? → The address has already been created and is not rolled back; the user is returned to the facility form with the new address still selected so they can correct the failure and retry without re-entering it.
- What happens when a user types a taxpayer key that is not a registered issuer? → The form accepts it locally (only its shape is checked) and the server's rejection is surfaced against the taxpayer field. There is no way to browse valid issuers — a documented compromise, see Clarifications.
- What happens when a facility's address key resolves to nothing (deleted or inaccessible)? → The facility still loads and shows a fallback in place of the address text, consistent with every other unresolvable reference in this feature.

## Requirements *(mandatory)*

### Functional Requirements

**Cross-cutting (all four catalogs)**

*(FR-001–FR-012 apply to all four managed catalogs — Warehouses, Cash Drawers, Points of Sale, and Facilities. Where a requirement lists "Warehouses, Points of Sale, Cash Drawers" it predates Facilities' promotion to a managed catalog on 2026-07-20; FR-028 binds Facilities to this same cross-cutting set.)*

- **FR-001**: Each of the catalogs (Warehouses, Points of Sale, Cash Drawers, Facilities) MUST have its own dedicated list screen showing a paginated table of records, consistent in look, feel, and interaction with the existing Products catalog and the spec-012/013 catalogs.
- **FR-002**: Each catalog's list screen MUST ship a free-text search box using the shared filter/search pattern, and MUST NOT ship search-less (constitution §VI). The search box filters by the record's identifying text (code and name), wired to the server-side search capability now available on all three list endpoints (mictlanix/mbe-api#86, #87, #88 — shipped and regenerated into the client 2026-07-20).
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
- **FR-022**: The warehouse picker on the point-of-sale form MUST offer only warehouses belonging to the currently selected facility, and MUST require the user to reselect a warehouse when the facility is changed to one the current warehouse does not belong to. *(Updated 2026-07-21: the backend now validates this pairing on both create and update — mictlanix/mbe-api#102 — so the picker guard is a UX convenience that spares the user a round-trip, layered over a real backend invariant, not the only line of defense. A backend rejection of a mismatched pairing MUST still be surfaced per FR-012. A legacy record that already pairs across facilities MUST still load and display rather than being rejected on open.)*

**Facility consumption by the operational catalogs (Facilities is separately managed — User Story 4)**

- **FR-023**: The facility picker and facility filter on the three operational catalogs MUST read from the same facility source the Facilities catalog manages (User Story 4), so a facility created there is immediately selectable without a reload.
- **FR-024**: Where a facility is displayed on any of the three catalogs, its type (Store or Production Site) MAY be shown as a plain label to disambiguate similarly named facilities, but MUST NOT change the behavior, fields, or layout of any screen in this feature.
- **FR-025**: Reading facilities for the picker and filter MUST be gated on the facility access-control object and MUST degrade gracefully — if the current user cannot read facilities, the affected list screen still renders and the facility controls show their empty state rather than failing the screen. *(Resolved 2026-07-20: the governing object is `facilities(29)` — mictlanix/mbe-api#93.)*
- **FR-026**: The facility type MUST be named in exactly one place in the app — a small domain enum mapping the backend's integer values (Store `0`, Production Site `1`) to readable terms — so no screen reads or compares raw type numbers, consistent with how the shared status and gender concepts are already handled.
- **FR-027**: The app's access-control object mirror MUST be corrected to match the backend: the entry currently named `stores(29)` MUST be renamed to `facilities(29)`, and `productionSites(107)` MUST be removed. Neither `STORES` nor `PRODUCTION_SITES` exists in the backend's object enum any more — facilities reused slot `29` — so leaving the stale names in place would gate facility access on an object that no longer means what its name says.

**Facilities (User Story 4)**

- **FR-028**: The Facilities catalog MUST support creating, viewing, editing, and deleting a facility with fields: code, name, type, fiscal location, address, taxpayer, logo, receipt message, default batch, and status. It MUST ship its own list screen meeting FR-001 through FR-012 exactly as the other three do, gated on the facility access-control object (FR-025).
- **FR-029**: Code, name, fiscal location, address, and taxpayer MUST be required on create; type MUST default to Store; logo, receipt message, and default batch MUST be optional.
- **FR-030**: The facility form MUST provide a searchable picker for the fiscal location, which is a postal-code entry from the tax authority's published catalog, displayed by its readable description rather than a bare code.
- **FR-031**: The facility form MUST provide a searchable picker for the address **and** a path to create a new address from within the form, because no other screen in the app can create one. Creating an address inline MUST select it on the facility being edited and MUST NOT discard any other input already entered on the facility form.
- **FR-032**: The inline address form MUST capture the address fields the backend requires — street, exterior number, postal code, neighborhood, borough, state, and country — plus the optional interior number, locality, city, nickname, type, and comment, and MUST be gated on the address access-control object: a user without create privilege on addresses MUST see the picker without the inline-create path rather than a failing control.
- **FR-033**: The address type MUST be named in one place in the app — Other, Home, Work, Business, Fiscal — following FR-026's rule that no screen reads or compares raw enum numbers.
- **FR-034**: The taxpayer field MUST be a searchable autocomplete over registered taxpayer issuers, matching by registration key (RFC) and name, displaying the issuer's name where it has one and its RFC otherwise. The value stored on the facility is the issuer's registration key (RFC). The autocomplete reads the taxpayer-issuers list endpoint (mictlanix/mbe-api#100, shipped 2026-07-21) and is gated on the taxpayer access-control object `taxpayers(24)`; if the current user cannot read taxpayers, the field degrades to a shape-validated typed RFC entry rather than a failing control. *(This supersedes the interim typed-field compromise: the endpoint that was requested to enable an autocomplete has landed, so the autocomplete is now the requirement, not a future upgrade.)*
- **FR-034a**: The taxpayer field MUST NOT offer an inline create-issuer path. A taxpayer issuer carries fiscal setup a facility form has no business capturing (tax regime, certification provider, and associated signing certificates), so issuers are picked, never created here. When a needed issuer does not exist, the user is directed to create it in its own place; a dedicated Taxpayer Issuers catalog is a natural follow-up now that the full API exists, but is out of scope for this feature.
- **FR-034b**: Where a facility's taxpayer is shown on the list or detail screen, it MUST render as the issuer's name (falling back to its RFC, then to a fallback label if the issuer cannot be resolved), never as a blank. Because the facility response carries only the RFC and does not expand the issuer, any name resolution MUST NOT issue one request per row on the list screen; showing the RFC alone on the list is acceptable if bulk name-resolution is impractical, since the RFC is itself human-meaningful.
- **FR-035**: Where a facility's address is displayed, the app MUST show readable address text rather than a raw id. The facility response now carries the address **pre-expanded** (mictlanix/mbe-api#101, shipped 2026-07-21), so this is a direct render with **no** per-row or bulk address fetch; an address that is nonetheless absent or unresolvable MUST show a fallback label rather than a blank or a raw id.

### Key Entities *(include if feature involves data)*

- **Warehouse**: A stock-holding location belonging to exactly one facility, identified by a system-assigned id, with a code, a name, an optional comment, and a status. Referenced by points of sale. Not previously manageable in the UI.
- **Point of Sale**: A selling station belonging to exactly one facility and drawing stock from exactly one warehouse, identified by a system-assigned id, with a code, a name, an optional comment, and a status. References both a Facility and a Warehouse. Not previously manageable in the UI.
- **Cash Drawer**: A cash-handling station belonging to exactly one facility, identified by a system-assigned id, with a code, a name, an optional comment, and a status. Structurally identical to Warehouse. Not previously manageable in the UI.
- **Facility** *(managed — User Story 4)*: An operating site — the merged successor of the legacy Store and Production Site concepts, carrying a type that distinguishes the two. Every other entity in this feature belongs to exactly one facility. Beyond code, name, type and status it carries a fiscal location (a tax-authority postal-code entry), a street address, a taxpayer registration key, and optional logo, receipt message, and default batch.
- **Address** *(created and selected from the facility form; no screens of its own)*: A street address — street, exterior and interior number, postal code, neighborhood, locality, borough, city, state, country — plus an optional nickname, a type (Other, Home, Work, Business, Fiscal), a comment, and a status. A facility references exactly one. This feature creates and picks addresses from within the facility form only; a dedicated Addresses catalog is out of scope.
- **Taxpayer issuer** *(referenced and browsed, not managed here)*: The registered taxpayer a facility invoices as, identified by its registration key (RFC) and carrying a name, tax regime, and certification provider. As of 2026-07-21 a full API exposes these (mictlanix/mbe-api#100), gated on `taxpayers(24)`; this feature reads them to drive the facility's taxpayer autocomplete and stores the selected issuer's RFC on the facility. Managing issuers — and their signing certificates — is out of scope; a dedicated Taxpayer Issuers catalog is a natural follow-up.
- **Status** *(reused, not newly introduced)*: The shared record-status concept already defined in the product and already displayed via the existing status badge; this feature introduces no new status concept.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A privileged user can locate, create, edit, or delete a record in any of the four catalogs in under 30 seconds from landing on that catalog's list screen.
- **SC-002**: 100% of records across the operational catalogs display their facility — and, for points of sale, their warehouse — as a human-readable name (or an explicit fallback label), never as a raw id, on both the list and detail screens.
- **SC-003**: A user can reduce any list to the records of a single facility using the shared filter sheet's facility facet — the same open→select→apply flow every catalog/list screen in the app already uses — with no screen requiring a different or extra step.
- **SC-004**: Zero point-of-sale records can be saved whose warehouse belongs to a facility other than the record's own — the backend rejects such a pairing (mictlanix/mbe-api#102) and the form's picker prevents the user from attempting it. A legacy record that already exhibits one MUST still display without error (FR-022).
- **SC-005**: A user lacking any privilege on one of these catalogs cannot reach its screens, and a user lacking only update/delete privilege never sees an edit or delete control for it.
- **SC-006**: Zero regressions in any existing catalog screen or shared picker after this feature ships, verified by the full existing test suite passing.
- **SC-007**: Every backend rejection on save or delete (duplicate code, referential constraint) is surfaced to the user without loss of unsaved form input — no silent failures.
- **SC-008**: A user can create a facility end to end — including an address that did not previously exist — without leaving the facility form and without any other screen in the app.
- **SC-009**: 100% of displayed facility addresses render as readable address text or an explicit fallback, never as a raw id, with zero additional requests — the address arrives pre-expanded on the facility response (mictlanix/mbe-api#101).
- **SC-010**: A facility created in the Facilities catalog is selectable in the warehouse, point-of-sale, and cash-drawer facility pickers without the user reloading the app.
- **SC-011**: The taxpayer field resolves a user's search to a selectable issuer and stores that issuer's RFC; a facility cannot be saved with a taxpayer the server does not recognize, and the taxpayer shown on the detail screen is the issuer's name (falling back to its RFC), never blank.

## Assumptions

- All three in-scope backend endpoints (Warehouses, Points of Sale, Cash Drawers) already exist as complete Create/Read/Update/Delete APIs and are already reflected in the generated API client; no backend change is required for the CRUD surface of this feature.
- All three in-scope catalogs already have their own access-control privilege defined in the system (Warehouses, Points of Sale, Cash Drawers); no new privilege needs to be introduced for them. The facility object is `facilities(29)`, resolved 2026-07-20 — but the app's own mirror of the object list is stale and must be corrected as part of this feature (FR-027).
- The shared record-status concept and its badge already exist in the product and are reused unchanged; this feature adds no new status concept.
- Facility, warehouse, code, and name are required on the entities that carry them; comment is always optional; status defaults to whatever the backend applies when the form leaves it unset.
- The facility and warehouse pickers reuse the same searchable-picker pattern already delivered for the salesperson picker (spec 012) and the driver picker (spec 013); no new picker concept is introduced.
- **Facilities management is IN scope** *(decision reversed 2026-07-20, see Clarifications)*: the three gaps that blocked it are resolved upstream — addresses are now a full CRUD catalog with search and their own `addresses(11)` object (mictlanix/mbe-api#90), `logo` is optional (#91), and the Store `0` / Production Site `1` mapping is confirmed (#92) — so Facilities is promoted to this feature's fourth managed catalog (User Story 4). Addresses are created inline from the facility form rather than getting a catalog of their own (FR-031). The taxpayer field is a searchable autocomplete over registered issuers (FR-034), reading the taxpayer-issuers API that shipped 2026-07-21 (mictlanix/mbe-api#100); issuer *creation* is deliberately not offered inline (FR-034a) because an issuer carries fiscal setup beyond a facility form's remit.
- **A dedicated Addresses catalog is out of scope**: addresses are reachable only through the facility form's picker and inline-create path. Addresses have a full API and their own access-control object, so a standalone Addresses catalog is a straightforward follow-up if one is ever wanted — but nothing in this feature needs it.
- **Search & Browse** *(dependency resolved 2026-07-20)*: originally none of the in-scope list endpoints exposed a free-text search capability, so upstream requests were filed per the spec-013 precedent — mictlanix/mbe-api#86 (warehouses), #87 (points of sale), #88 (cash drawers), plus #89 for the facilities list the pickers read. **All four shipped and were regenerated into the client**, so the search box on every screen is fully functional against server-side search — no longer a pending cross-repository dependency. Client-side filtering of a single fetched page was explicitly ruled out as a substitute and is not used.
- Bulk import/export (e.g. CSV) for any of these catalogs is out of scope; each record is created/edited one at a time, consistent with every existing catalog in the app.
- Cash drawer *sessions* (opening, closing, reconciling a drawer) are a separate operational concern and are out of scope; this feature manages the cash drawer master record only.
- Warehouse *stock* (quantities, lots, serial numbers, movements) is out of scope; this feature manages the warehouse master record only.

## Verbatim Constraints

Identifiers pinned by the request that the implementation MUST match exactly:

- Access-control objects for the three in-scope catalogs: `warehouses(4)`, `pointsOfSale(9)`, `cashDrawers(10)`.
- The facility access-control object, confirmed 2026-07-20: `facilities(29)` — it **reuses** the slot the app currently calls `stores(29)`. The stale `stores(29)` and `productionSites(107)` entries MUST be corrected per FR-027.
- The access-control object gating the inline address create path: `addresses(11)` (already present and correct in the app's mirror).
- The access-control object gating the taxpayer autocomplete's read: `taxpayers(24)` (already present and correct in the app's mirror).
- The shared status enum to reuse, not redefine: `lib/core/domain/entity_status.dart`.
- Enum values that MUST be named in one place, never compared as raw numbers (FR-026, FR-033): `FacilityType` — Store `0`, Production Site `1`; `AddressType` — Other `0`, Home `1`, Work `2`, Business `3`, Fiscal `4`.
- The taxpayer registration key's maximum length: 13 characters. The taxpayer field stores this key (the issuer's RFC), whether entered via the autocomplete or the read-denied fallback.
- List-endpoint query parameters, all available in the regenerated client: `search`, `facility`, `status`, `skip`, `limit` on the three operational catalogs (plus `warehouse` on points of sale); `search`, `status`, `skip`, `limit` on facilities; `search`, `skip`, `limit` on taxpayer issuers. `search` is the first positional-optional param on every `list…` method.
- The facility response as of 2026-07-21 expands `address` to the full address object and `location` to the SAT postal-code object, but carries `taxpayer` as the bare RFC string (not expanded).

## Upstream Dependencies

Filed against `mictlanix/mbe-api` on 2026-07-19 on behalf of this spec. **All eight are now closed and regenerated into the client (verified 2026-07-20); this feature has no open upstream dependency.**

| Issue | Subject | Resolution |
|---|---|---|
| [#86](https://github.com/mictlanix/mbe-api/issues/86) | `search` param on `GET /api/v1/warehouses` | Shipped — `String? search` |
| [#87](https://github.com/mictlanix/mbe-api/issues/87) | `search` param on `GET /api/v1/points-of-sale` | Shipped — `String? search` |
| [#88](https://github.com/mictlanix/mbe-api/issues/88) | `search` param on `GET /api/v1/cash-drawers` | Shipped — `String? search` |
| [#89](https://github.com/mictlanix/mbe-api/issues/89) | `search` param on `GET /api/v1/facilities` | Shipped — `String? search` |
| [#90](https://github.com/mictlanix/mbe-api/issues/90) | `Facility.address` references a nonexistent addresses resource | Shipped — full addresses CRUD + `search`; `addresses(11)` already present in the app's object mirror. **Residual**: `FacilityResponse.address` is still a bare `int`, not expanded the way `facility`/`warehouse` are (see Follow-ups) |
| [#91](https://github.com/mictlanix/mbe-api/issues/91) | `FacilityCreate.logo` required with no upload path | Shipped — `logo` is now optional (`String?`) on create, update, and response |
| [#92](https://github.com/mictlanix/mbe-api/issues/92) | `FacilityType` has no member names | Closed — mapping confirmed Store `0` / Production Site `1`; named UI-side per FR-026 |
| [#93](https://github.com/mictlanix/mbe-api/issues/93) | No `SystemObject` governs `/api/v1/facilities` | Resolved — `FACILITIES = 29`, reusing the legacy stores slot; `STORES`/`PRODUCTION_SITES` removed upstream. Drives FR-027 |

### Follow-ups — filed 2026-07-20, **all resolved 2026-07-21**

| Issue | Subject | Resolution |
|---|---|---|
| [#100](https://github.com/mictlanix/mbe-api/issues/100) | `taxpayer_issuer` has no endpoint | Shipped — full taxpayer-issuers API (list + `search`, get by RFC, create/update/delete), gated on `taxpayers(24)`. Drives the taxpayer autocomplete (FR-034); the interim typed-field shape is retired |
| [#101](https://github.com/mictlanix/mbe-api/issues/101) | `FacilityResponse.address` not expanded | Shipped — `address` now arrives as the full address object. FR-035's bulk-resolve workaround deleted; render is direct with zero extra requests |
| [#102](https://github.com/mictlanix/mbe-api/issues/102) | Point of sale accepts a cross-facility warehouse | Shipped — `create`/`update` validate the pairing on both paths. FR-022's guard is now a UX layer over a backend invariant; SC-004 is a backend guarantee |

**No open upstream dependency remains for this feature.** Two out-of-scope arrivals rode along with #100 and are deliberately not consumed: the `TaxpayerCertificatesApi` and the `FiscalCertificationProvider` enum (both fiscal-signing/CSD concerns).

- **`AddressType` is a new unnamed enum** (`number0`–`number4`), the same shape as `FacilityType` and `EntityStatus`. Handled UI-side by FR-033, so no upstream issue was filed. `FiscalCertificationProvider` (`number0`–`number4`) has the same shape but is not consumed by this feature, so it needs no treatment here.

### Follow-ups opened by this round

- **A dedicated Taxpayer Issuers catalog.** The full issuer API now exists and is gated on `taxpayers(24)`, but this feature only reads issuers for the facility autocomplete and never creates one (FR-034a). Managing issuers — including their signing certificates via the new `TaxpayerCertificatesApi` — is a clean, self-contained follow-up feature.
