# Feature Specification: Nested Facility Management

**Feature Branch**: `018-nested-facility-management`

**Created**: 2026-07-26

**Status**: Draft

**Input**: User description: "Fold Warehouses, Cash Drawers and Points of Sale into an org-chart-style Facilities screen: keep only Facilities in the navigation, replace the Facilities table with an expandable hierarchy that shows each facility's warehouses, points of sale and cash drawers, and wire the existing forms to create/update/delete from that screen."

## Overview

Today an operator maintaining a physical site has to visit four sibling catalogs
that are only related by a foreign key: **Facilities**, **Warehouses**, **Cash
Drawers** and **Points of Sale**. Setting up one new store means four separate
list screens, four searches, and re-selecting the same facility in three
different pickers. Nothing on any screen shows the shape of a site — how many
warehouses it has, whether its points of sale are wired to the right stock, or
whether a site has been left half-configured.

Every one of those three catalogs exists **only** as a child of a facility. This
feature makes the UI say so: one navigation entry, one screen, each facility a
card that expands into its own warehouses, points of sale and cash drawers, with
create/view/edit reachable in place.

The layouts in `artifacts/facilities_improvements/desktop_layout.html` and
`artifacts/facilities_improvements/mobile_layout.html` are the visual reference
for this feature.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - See a facility's full shape at a glance (Priority: P1)

An operations manager opens Facilities and sees one card per site. Without
clicking anything, each card tells them the site's name, code, type, whether it
is active, and how many warehouses, points of sale and cash drawers it holds.
Expanding a card reveals those children grouped into labeled sections, each child
showing its own code and status, and each point of sale showing which warehouse
it draws stock from. A production site shows only its warehouses, with a note
explaining that production sites have no points of sale or cash drawers.

**Why this priority**: This is the whole point of the feature — the structural
view that no current screen provides. It is valuable on its own even before any
record can be edited from it, and it is the foundation every other story builds
on.

**Independent Test**: Load the Facilities screen against a tenant with a mix of
stores and production sites, active and inactive records, and facilities with
zero children. Verify counts on collapsed cards match what expansion reveals,
that production sites show only warehouses, and that empty sections state so
explicitly. No record needs to be created or edited to test this.

**Acceptance Scenarios**:

1. **Given** a store facility with 2 warehouses, 3 points of sale and 1 cash
   drawer, **When** the Facilities screen finishes loading, **Then** that
   facility's collapsed card shows the counts 2, 3 and 1 against warehouse,
   point-of-sale and cash-drawer indicators, without the user expanding it.
2. **Given** that same facility, **When** the user expands its card, **Then**
   three sections appear — Warehouses, Points of Sale, Cash Drawers — each
   headed by its name and count, and each listing its children with name, code
   and status.
3. **Given** a production-site facility, **When** the user expands its card,
   **Then** only the Warehouses section is shown, together with an explanatory
   note that production sites manage warehouses only.
4. **Given** a facility with no cash drawers, **When** the user expands its card,
   **Then** the Cash Drawers section renders an explicit "no cash drawers
   registered" placeholder rather than an empty gap.
5. **Given** a point of sale whose stock warehouse belongs to a different
   facility, **When** its row is displayed, **Then** the row names that warehouse
   and is marked as belonging to another facility.
6. **Given** a facility list longer than one page, **When** the user searches by
   facility name or code, filters by status, or moves between pages, **Then** the
   result set updates and that view state survives a page reload and a shared
   link.
7. **Given** several facilities on screen, **When** the user activates the
   expand-all control, **Then** every facility on the current page expands, and
   the control switches to collapse-all.

---

### User Story 2 - Manage a site's records without leaving the tree (Priority: P2)

The same manager can act on what they see. Clicking a facility or child row opens
that record read-only; the edit affordance opens it for editing; and each section
offers a create action that opens the corresponding blank form with the parent
facility already chosen. After saving or deleting, they land back in the tree
with the affected facility still expanded, on the same page, showing the change.

**Why this priority**: Turns the view into a workspace. It depends on Story 1
existing but is separately demonstrable, and it is what makes removing the three
standalone catalogs safe.

**Independent Test**: From the tree, create one warehouse, one point of sale and
one cash drawer, edit each, and delete one. Verify the parent facility was
pre-selected in every create form and that the tree reflects each change without
losing expansion or page position.

**Acceptance Scenarios**:

1. **Given** an expanded facility, **When** the user activates the create action
   in its Warehouses section, **Then** the blank warehouse form opens with that
   facility already selected as the parent.
2. **Given** the user saves that new warehouse, **When** they return to the
   Facilities screen, **Then** the same facility is still expanded on the same
   page, its warehouse count has increased by one, and the new warehouse appears
   in its section.
3. **Given** a child row, **When** the user clicks anywhere on it other than its
   edit affordance, **Then** that record opens read-only.
4. **Given** a child row, **When** the user activates its edit affordance,
   **Then** that record opens in an editable form.
5. **Given** a record deleted from its own detail screen, **When** the user
   returns to the Facilities screen, **Then** the record is gone from its
   section, the parent's count has decreased, and the card is still expanded.
6. **Given** a user who may read facilities but may not create warehouses,
   **When** they expand a facility, **Then** the Warehouses section is visible
   but offers no create action.
7. **Given** a user with no read privilege on cash drawers, **When** they expand
   a facility, **Then** no Cash Drawers section is rendered at all.

---

### User Story 3 - One navigation entry instead of four (Priority: P3)

The Catalogs menu lists Facilities once. Warehouses, Cash Drawers and Points of
Sale no longer appear as siblings, because they are reached through the facility
that owns them.

**Why this priority**: This is the payoff, but it removes the old path, so it
must land only once Stories 1 and 2 make the new path complete. Sequencing it
last keeps every intermediate state shippable.

**Independent Test**: Inspect the Catalogs menu for a fully-privileged user and
confirm exactly one of the four destinations remains, then confirm that every
facility, warehouse, point of sale and cash drawer is still reachable, viewable
and editable through it.

**Acceptance Scenarios**:

1. **Given** a user with read privileges on all four objects, **When** they open
   the navigation, **Then** Catalogs lists Facilities and does not list
   Warehouses, Cash Drawers or Points of Sale.
2. **Given** the standalone warehouse, cash-drawer and point-of-sale list
   locations, **When** they are requested directly, **Then** they no longer
   resolve to a list screen.
3. **Given** an individual warehouse, cash-drawer or point-of-sale record,
   **When** its own location is requested directly, **Then** the record still
   opens exactly as before, honoring the same read/update privileges.
4. **Given** a user without read privilege on facilities, **When** they open the
   navigation, **Then** Facilities is absent and none of the four catalogs is
   reachable.

---

### User Story 4 - Usable on a phone (Priority: P4)

A supervisor on the floor opens the same screen on a phone and gets the same
hierarchy in a denser form: compact cards, wrapped metadata, status shown as a
dot, touch-sized targets, create actions grouped at the bottom of an expanded
card, and a floating action to add a facility.

**Why this priority**: The compact tier is genuinely useful for this screen but
is not what unblocks the operator's daily work, and it can be added without
reopening anything from Stories 1–3.

**Independent Test**: Render the screen at a compact width and verify no
horizontal scrolling, that all interactive targets are touch-sized, and that
every action available on the wide tier is reachable.

**Acceptance Scenarios**:

1. **Given** a compact viewport, **When** the Facilities screen renders, **Then**
   facility cards, sections and child rows are all legible without horizontal
   scrolling.
2. **Given** a compact viewport, **When** the user expands a facility, **Then**
   the create actions for its child types appear as a group at the end of the
   expanded content.
3. **Given** a compact viewport, **When** the user wants to add a facility,
   **Then** a persistent floating create action is available.

---

### Edge Cases

- **A facility holds more children than one request returns.** The section keeps
  retrieving until the reported total is satisfied, silently — the tree must
  remain the complete path to every child, since the standalone lists are gone.
  Not expected to occur in practice; specified so it degrades to "slightly
  slower" rather than "records invisible".
- **A point of sale references a warehouse not among the parent facility's loaded
  warehouses.** Treated as belonging to another facility and marked accordingly.
  If the reference cannot be resolved at all, the row still renders with a
  fallback label rather than failing.
- **Child data fails to load for one facility while the facility list succeeds.**
  That card indicates its children could not be loaded and offers a retry; the
  rest of the page stays usable.
- **A facility has zero children of every type.** The card is still expandable and
  each applicable section shows its empty placeholder.
- **A production site is expanded.** Only the Warehouses section is built, and no
  point-of-sale or cash-drawer retrieval is issued at all — the type rule is
  applied before requesting, not after.
- **A user's privileges allow reading only some child types.** Only the permitted
  sections render, and the collapsed card's counts cover only those types.
- **The last record on a page is deleted.** The page position is clamped to a page
  that still has content rather than showing an empty page.
- **A shared link is opened cold.** Search, status filter and page are restored;
  expansion state is not, because it belongs to the current view only.

## Requirements *(mandatory)*

### Functional Requirements

#### Navigation and reachability

- **FR-001**: The navigation MUST list Facilities as the single entry point for
  facilities, warehouses, points of sale and cash drawers; Warehouses, Cash
  Drawers and Points of Sale MUST NOT appear as navigation destinations.
- **FR-002**: The standalone Warehouses, Cash Drawers and Points of Sale list
  screens MUST be removed, along with the search, filter and page state they
  maintained.
- **FR-003**: The individual record locations for a warehouse, cash drawer and
  point of sale — both create and existing-record — MUST continue to resolve and
  MUST continue to enforce their own object's read/update privileges.
- **FR-004**: Removing the three list destinations MUST NOT change the privilege
  required to open any surviving location, and every remaining destination MUST
  still open its own screen — no destination may be left pointing at another's.

#### The facility hierarchy view

- **FR-005**: The Facilities screen MUST present each facility as an expandable
  card rather than a table row, and MUST retain pagination over facilities.
- **FR-006**: A collapsed facility card MUST show the facility's name, code,
  type, status, and the number of warehouses, points of sale and cash drawers it
  holds.
- **FR-007**: An expanded facility card MUST group its children into labeled
  sections — Warehouses, Points of Sale, Cash Drawers — each showing its own
  count and visually connected to the parent facility.
- **FR-008**: Each child row MUST show the child's name, code and status, and
  MUST be visually distinguishable by child type.
- **FR-009**: A point-of-sale row MUST additionally name the warehouse it draws
  stock from, and MUST be marked when that warehouse belongs to a facility other
  than the one the row is nested under.
- **FR-010**: A section with no children MUST render an explicit empty-state
  message naming the missing child type.
- **FR-011**: A production-site facility MUST show only its Warehouses section,
  accompanied by an explanation that production sites manage warehouses only.
  Points of Sale and Cash Drawers sections MUST NOT be rendered for a production
  site under any circumstance — the facility type determines which child types
  exist, and only stores have points of sale and cash drawers.
- **FR-012**: The screen MUST offer a control that expands and collapses every
  facility on the current page, whose label reflects which action it will perform.
- **FR-013**: Expansion state MUST be view-local: it MUST NOT be encoded in the
  shareable location, and it MUST survive navigating to a record and back within
  the session.

#### Filtering, search and view state

- **FR-014**: The screen MUST keep a search box that matches facilities by name
  and code, and its placeholder MUST NOT imply that children are searched.
- **FR-015**: The screen MUST keep the facility status filter facet and its
  active-filter indicator.
- **FR-016**: Search, status filter and page position MUST remain encoded in the
  shareable location, and a cold load of that location MUST reproduce the same
  result set.

#### Loading the hierarchy

- **FR-017**: After a page of facilities loads, the children of every facility on
  that page MUST be loaded without the user expanding anything, so that counts and
  badges are correct on first paint and expanding is instantaneous.
- **FR-018**: Child types that cannot exist for a facility's type, or that the
  current user may not read, MUST NOT be requested.
- **FR-019**: A section MUST end up holding every child of its facility. When the
  reported total exceeds what a single retrieval returned, the section MUST
  continue retrieving subsequent pages until the total is satisfied, without the
  user asking for it and without any additional control on screen. The tree is
  the only path to a child record once the standalone lists are gone, so no child
  may be unreachable.
- **FR-020**: A failure loading one facility's children MUST be reported on that
  facility's card with a retry, and MUST NOT prevent the rest of the page from
  rendering.

#### Creating, editing and deleting

- **FR-021**: The screen MUST offer a create action for facilities.
- **FR-022**: Each child section MUST offer a create action that opens that
  child's existing blank form with the parent facility already selected.
- **FR-023**: The pre-selected parent facility MUST be applied on cold load of
  the create form, so that the form behaves identically whether reached from the
  tree or by direct link.
- **FR-024**: Clicking a facility card's header or a child row, outside its edit
  affordance, MUST open that record read-only.
- **FR-025**: Each facility card and child row MUST expose an edit affordance that
  opens that record's editable form, using the shared cross-module edit
  iconography.
- **FR-026**: Delete MUST remain on each record's own detail screen and MUST NOT
  appear on any card or row in the tree.
- **FR-027**: After a create, update or delete, the affected facility's children
  and counts MUST refresh in place, preserving the current page and the card's
  expansion state.

#### Access control

- **FR-028**: Every create and edit affordance MUST be hidden — not disabled —
  when the current user lacks the corresponding privilege on that object.
- **FR-029**: A child section MUST be omitted entirely when the current user
  lacks read privilege on that child's object, and collapsed-card counts MUST
  reflect only the sections the user may see.

#### Presentation and localization

- **FR-030**: The screen MUST derive all color, elevation and typography from the
  application's theme so that it renders correctly under both light and dark
  schemes and any per-deployment brand seed.
- **FR-031**: The screen MUST render correctly on both the wide and compact
  tiers, with the compact tier using denser cards, wrapped metadata, dot status
  indicators, touch-sized targets, create actions grouped within the expanded
  card, and a floating create-facility action.
- **FR-032**: Every string introduced by this feature MUST be localized in both
  supported locales.
- **FR-033**: No content in the tree may be truncated without a way to reveal the
  full text, and status, code and name MUST never be truncated.

### Key Entities

- **Facility**: An operating site, of exactly one of two types. A **store** owns
  warehouses, points of sale and cash drawers. A **production site** owns
  warehouses only — it has no points of sale and no cash drawers, by definition of
  the type rather than by circumstance. The root of each card in the hierarchy.
- **Warehouse**: A stock-holding location belonging to exactly one facility.
- **Point of Sale**: A selling station belonging to exactly one facility and
  drawing stock from exactly one warehouse, which may belong to a *different*
  facility. This cross-link is the only place the hierarchy is not a strict tree.
- **Cash Drawer**: A cash-handling station belonging to exactly one facility.
- **Facility hierarchy**: The composed, per-page view of a facility together with
  the child collections the current user is allowed to see. Presentation-scoped —
  it is assembled for display, not a stored record.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Configuring a new store end to end — the facility plus one
  warehouse, one point of sale and one cash drawer — is completed from a single
  screen, with the parent facility chosen once instead of four times.
- **SC-002**: An operator can determine how many warehouses, points of sale and
  cash drawers a given facility has without opening or expanding anything.
- **SC-003**: Every facility, warehouse, point of sale and cash drawer that was
  reachable before this feature remains reachable, viewable and editable after
  the three standalone catalogs are removed.
- **SC-004**: Expanding a facility reveals its children with no perceptible wait,
  because they are already loaded.
- **SC-005**: Saving or deleting a record returns the user to the same page, with
  the same facility still expanded and the change visible — no re-navigation, no
  lost place.
- **SC-006**: Identifying a half-configured site — a store with no point of sale,
  no cash drawer, or no warehouse — takes one glance at the facility list instead
  of cross-referencing three catalogs.
- **SC-007**: A user restricted to a subset of the four objects sees exactly the
  sections and actions their privileges allow, and no others.
- **SC-008**: The screen is fully usable at a phone width, with no horizontal
  scrolling and every wide-tier action reachable.

## Assumptions

- **The facility type rule is a domain invariant, not a data observation.** A
  store has warehouses, points of sale and cash drawers; a production site has
  warehouses only. The UI treats this as given: for a production site it does not
  render, and does not even request, the other two child types.
- **mbe-api does not enforce that invariant**, so a migrated row could in
  principle contradict it — and such a record would be invisible in this UI and,
  with the standalone lists removed, unreachable. Checked against production data
  on 2026-07-26: no point of sale and no cash drawer is attached to a production
  site. The invariant holds in the real dataset, so no record is stranded by the
  strict reading.
- **Children are filterable by facility already.** Warehouses, points of sale and
  cash drawers can each be retrieved for a given facility today; no backend change
  is required to build the hierarchy. Verified against mbe-api, not assumed.
- **A facility-scoped retrieval is still capped.** Every list endpoint caps a
  single request at 100 records, uniformly across the API. Raising that cap is
  explicitly *not* requested — a facility with more than 100 warehouses, points of
  sale or cash drawers is not a real configuration. FR-019's continue-until-complete
  loop is therefore a correctness safety valve, not an expected path: it costs one
  loop condition, adds nothing to the screen, and guarantees no record can become
  invisible if that assumption is ever wrong.
- **Exact child counts come free with the first retrieval**, because each list
  response reports the true total alongside the records returned. Collapsed-card
  counts are therefore correct even for a section whose children were only
  partially loaded.
- **Child loading is eager, per facilities page.** Chosen over lazy loading so
  that counts and badges are correct on first paint. The cost is three additional
  retrievals per store and one per production site; if that proves too heavy in
  practice, reducing the facilities page size is the intended lever, not switching
  to lazy loading.
- **Cross-facility points of sale are detected by comparing the point of sale's
  warehouse against the parent facility's own warehouses.** A point of sale is
  marked as belonging to another facility when its warehouse is not among them.
- **Facility read privilege becomes a prerequisite for reaching warehouses, cash
  drawers and points of sale.** A user granted read on a child object but not on
  facilities loses their entry point. This is an accepted consequence of
  consolidating navigation; deployments should confirm that anyone holding a
  child-object privilege also holds facility read. No privilege model change is
  made by this feature.
- **The removed list screens' cross-facility views are not replaced.** There will
  no longer be a way to see, search or filter all warehouses (or points of sale,
  or cash drawers) across every facility at once. This is accepted: those catalogs
  are always consumed in the context of their site.
- **The visual reference supplies structure, not palette.** The supplied HTML uses
  its own colors; the implementation takes structure, hierarchy and density from
  it and colors from the application theme.
- **Existing record forms are reused unchanged**, except for accepting a
  pre-selected parent facility when opened for creation from a section.
- **Search remains server-side and facility-only**, matching current behavior.

## Out of Scope

- Any change to the warehouse, point-of-sale, cash-drawer or facility forms
  beyond parent pre-selection.
- Drag-and-drop reparenting of children between facilities.
- Bulk operations across facilities or children.
- Any backend change: no new endpoint, no new response field, no new privilege.
- Cross-facility list views to replace the removed standalone catalogs.
- Searching or filtering by child attributes.
