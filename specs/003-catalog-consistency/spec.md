# Feature Specification: Catalog Screen Consistency

**Feature Branch**: `003-catalog-consistency`

**Created**: 2026-06-20

**Status**: Draft

**Input**: User description: "Catalog consistency fixes across all list/catalog screens (Users, Products, etc.): 1) Add missing filtering to Users catalog. 2) Add missing pagination to Users catalog. 3) Every catalog must show View, Edit, and Delete row actions as the last columns, per constitution Principle VI. 4) Create, View, Edit, and Delete actions must use one consistent icon and left-to-right order across all modules. 5) Adopt the data_table_2 package for desktop-mode data table rendering. 6) Freeze identity-like columns (e.g. product code, user username) so they stay visible during horizontal scroll. 7) Filter widgets must stay on a single row when the viewport is tablet-landscape or larger. 8) Text filtering must be triggered explicitly via a search button or Enter key press, not on every keystroke."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Search and page through the Users catalog (Priority: P1)

An administrator managing accounts needs to find a specific user among a growing list and move through results a page at a time, the same way they already can on the Products catalog.

**Why this priority**: The Users catalog is the most visible gap today — it has neither search nor pagination — and blocks day-to-day admin work as the user list grows past one screen.

**Independent Test**: Open the Users catalog, type part of a username/email into the search box, submit it, and confirm only matching users are shown; confirm a second page of results can be reached when the list exceeds one page.

**Acceptance Scenarios**:

1. **Given** the Users catalog with more users than fit on one page, **When** the administrator opens the screen, **Then** the catalog shows a bounded first page of results with controls to reach subsequent pages.
2. **Given** the Users catalog, **When** the administrator types a search term and presses Enter (or clicks the search button) without having pressed it yet, **Then** the list is unchanged until the search is submitted, at which point only matching users are shown.
3. **Given** an active search/filter on the Users catalog, **When** the administrator clears it, **Then** the full, paginated user list returns.

---

### User Story 2 - Recognize and use the same row actions on every catalog (Priority: P1)

A user who has learned how to view, edit, or delete a record on one catalog (e.g. Products) expects the same icons, in the same order, in the same place, when working on any other catalog (e.g. Users), without having to relearn the screen.

**Why this priority**: Inconsistent or missing actions force users to hunt for functionality per-module and violate the project's own UI consistency rule; this is the core "inconsistency" the feature is named for.

**Independent Test**: Open the Users catalog and the Products catalog side by side (or in sequence); confirm both expose Create, View, Edit, and Delete using identical icons and the same left-to-right order, and confirm each action only appears for a user who holds the corresponding permission.

**Acceptance Scenarios**:

1. **Given** a catalog row the current user is allowed to view, edit, and delete, **When** the row is rendered, **Then** the row's trailing action column shows View, Edit, and Delete actions in that fixed left-to-right order, using the same icon glyphs used by every other catalog in the app.
2. **Given** the same user lacks delete permission for a given record type, **When** that catalog renders, **Then** the Delete action is omitted (not shown disabled) while View/Edit retain their fixed positions, consistent with the existing RBAC display rule.
3. **Given** a user with create permission, **When** they look at the catalog's toolbar, **Then** the Create action uses the same icon glyph wherever Create appears across catalogs.
4. **Given** the View action is invoked, **When** the corresponding form opens, **Then** it is the same form used for Edit, rendered read-only.

---

### User Story 3 - Keep the record's identity visible while scanning wide rows (Priority: P2)

A user scrolling a wide catalog table horizontally to see additional columns needs to keep track of which record each row belongs to (e.g. the product code or username) without scrolling back to the left edge.

**Why this priority**: Improves usability on data-dense catalogs but is not blocking compared to the missing Users functionality and inconsistent actions in P1.

**Independent Test**: On a catalog with enough columns to require horizontal scrolling, scroll the table right and confirm the identity column (e.g. product code, username) remains visible/pinned at the left edge.

**Acceptance Scenarios**:

1. **Given** a catalog table wide enough to scroll horizontally, **When** the user scrolls right, **Then** the designated identity column stays pinned in place and remains readable.
2. **Given** the Products catalog, **When** scrolled horizontally, **Then** the product code column stays frozen; **given** the Users catalog, **when** scrolled horizontally, **then** the username column stays frozen.

---

### User Story 4 - Filter without the layout fighting back (Priority: P2)

A user on a tablet (landscape) or desktop screen wants to see and use all the filter controls for a catalog without them wrapping into a tall, scrolling block that pushes the data table out of view.

**Why this priority**: A layout quality-of-life improvement that affects all catalogs uniformly but does not block core functionality the way missing search/pagination/actions do.

**Independent Test**: Resize the app window/viewport to a tablet-landscape width or larger and confirm a catalog's filter row (search box plus facet filters) lays out across a single row rather than wrapping to multiple rows.

**Acceptance Scenarios**:

1. **Given** a catalog with a search box and two or more facet filters, **When** viewed at tablet-landscape width or larger, **Then** all filter controls fit on one horizontal row.
2. **Given** the same catalog, **When** viewed at a narrower (phone-portrait-equivalent) width, **Then** filter controls MAY wrap to additional rows rather than being clipped or hidden.

---

### Edge Cases

- What happens when a catalog has zero facet filters (only a search box)? The single-row requirement still holds trivially; no facet wrapping is possible.
- What happens when a search submitted via Enter/button returns zero results? The catalog shows the existing "no records found" empty state, scoped to the active search/filter.
- What happens when a user without Read access for a record type would otherwise see it in a catalog? Out of scope here — covered by existing RBAC route/screen guards (Principle IV); this feature only governs which row-level actions are shown once the row is already visible.
- What happens to the frozen identity column when the screen is too narrow to show it plus any other column? The identity column remains pinned and visible; remaining columns scroll underneath/beside it instead of the identity column being pushed off-screen.
- What happens when a catalog's dataset is small enough to fit on one page? Pagination controls MAY be hidden or disabled rather than removed, consistent with existing pagination behavior elsewhere in the app.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The Users catalog MUST provide a search control that filters the listed users (e.g. by username or email) consistent with the filtering pattern used on other catalogs.
- **FR-002**: The Users catalog MUST present results in bounded pages with controls to navigate between pages, consistent with the pagination pattern used on other catalogs.
- **FR-003**: Every catalog screen MUST expose Create (toolbar), View, Edit, and Delete (row-level, trailing columns) as its supported actions, omitting any action the current action target does not support (e.g. a non-deletable record) or the current user lacks RBAC permission for.
- **FR-004**: View, Edit, and Delete row actions MUST appear in that fixed left-to-right order as the last columns of every catalog table, with no catalog reordering them relative to one another.
- **FR-005**: Each of Create, View, Edit, and Delete MUST use exactly one icon glyph across the entire application; no catalog may substitute a different icon for an action another catalog already represents.
- **FR-006**: The View action MUST open the same form/screen used for Edit, rendered in a read-only mode, rather than a separate view-only screen.
- **FR-007**: Catalog tables rendered in desktop/expanded layout MUST support pinning ("freezing") a designated identity column so it remains visible during horizontal scrolling.
- **FR-008**: The Products catalog MUST designate the product code column as frozen; the Users catalog MUST designate the username column as frozen.
- **FR-009**: Catalog filter controls (search box plus any facet filters) MUST lay out on a single horizontal row whenever the viewport is at least tablet-landscape width, reflowing to multiple rows only below that width.
- **FR-010**: Catalog text search MUST NOT re-query/re-filter on every keystroke; it MUST apply only when the user explicitly submits it via a search button or the Enter key.
- **FR-011**: Existing catalogs whose current behavior conflicts with FR-001 through FR-010 (e.g. Products' per-keystroke search, missing row actions, missing frozen columns) MUST be brought into conformance as part of this feature, not just newly added catalogs.
- **FR-012**: All catalog/row actions MUST continue to honor the existing RBAC display rule (Principle IV): an action the user lacks privilege for is omitted, not shown disabled.

### Key Entities

- **Catalog screen**: Any list/table screen presenting a paginated, filterable collection of records of one entity type (e.g. Users, Products) with Create/View/Edit/Delete actions.
- **Row action**: A View, Edit, or Delete control rendered per row in a catalog's trailing columns, scoped to one record.
- **Identity column**: The column on a given catalog that uniquely identifies a record to the user at a glance (product code for Products, username for Users), eligible to be frozen during horizontal scroll.
- **Filter/search state**: The currently submitted search text and facet filter selections governing which records a catalog displays; distinct from in-progress, not-yet-submitted text typed into the search box.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A user can locate a specific user account in the Users catalog by search in under 10 seconds, regardless of total user count.
- **SC-002**: 100% of catalog screens in the app expose Create/View/Edit/Delete using the same icon and the same left-to-right order for each action, verifiable by visual inspection across modules.
- **SC-003**: On a catalog with enough rows to scroll horizontally, the record's identity remains visible at all horizontal scroll positions for 100% of rows.
- **SC-004**: At tablet-landscape width or larger, 100% of existing catalog screens display their filter controls without wrapping to more than one row.
- **SC-005**: No catalog issues a filtered/search request before the user explicitly submits the search (button click or Enter), eliminating per-keystroke requests.

## Assumptions

- "Catalogs" in scope are the existing Users and Products list screens; any catalog added after this feature ships is expected to inherit the same shared components and therefore conform by construction.
- The View action's read-only form reuses the same screen as Edit (per constitution Principle VI), so no separate view-only screen needs to be designed.
- Soft-delete vs. hard-delete semantics for "Delete" follow whatever each entity's existing domain rules already define; this feature only standardizes the action's icon, position, and visibility, not its underlying deletion behavior.
- "Tablet-landscape width or larger" maps to the project's existing Expanded layout breakpoint tier (Principle VI); no new breakpoint needs to be introduced.
- Replacing the underlying table-rendering widget (e.g. adopting `data_table_2`) is an implementation detail belonging in the planning phase, not a user-facing requirement in this spec.
