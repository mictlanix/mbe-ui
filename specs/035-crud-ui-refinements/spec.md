# Feature Specification: CRUD UI Refinements

**Feature Branch**: `035-crud-ui-refinements`
**Created**: 2026-08-30
**Status**: Draft
**Input**: Seven cross-cutting UI observations collected from the CRUD screens now in daily use, with the durable styling rules to be enforced in the design system so future screens inherit them.

## Overview

The catalog and list screens shipped across specs 005–034 are individually correct but
have drifted from each other in four visible ways and behave surprisingly in two
functional ways. This feature closes all six gaps at the shared-component level rather
than screen by screen, and converts fourteen simple records from a full-screen route to
the app's existing responsive panel so that editing a supplier or a label no longer costs
the user their place in the list.

Nothing here changes what data the system stores or what the server is asked for, beyond
the default status filter and the refresh behaviour of the search control.

## User Scenarios & Testing

### User Story 1 - Lists open showing only what is in use (Priority: P1)

A purchasing clerk opens Suppliers to pick a supplier for a new expense. Today the list
opens showing every supplier ever created, including the ones retired years ago, and the
clerk has to open the filter panel and choose Active before the list is usable. They want
the list to open already showing only active records, while still being able to see the
retired ones in one action when they genuinely need to.

**Why this priority**: It is the single most repeated piece of friction in the product —
it costs two interactions on every visit to every catalog, and the retired-record noise
grows monotonically as the business ages. It is also independent of every other item here.

**Independent Test**: Open each catalog list with a clean URL and confirm only active
records are listed, the status facet visibly shows the applied default, and one interaction
reveals the full set. (The transactional lists are excluded and unchanged — see Out of Scope.)

**Acceptance Scenarios**:

1. **Given** a catalog containing both active and inactive records, **When** the user opens
   that catalog's list with no status in the address, **Then** only active records are
   listed and the total count reflects only active records.
2. **Given** that same list, **When** the user opens the filter panel, **Then** the status
   facet visibly shows Active as the selected value — not an empty or "All" state that
   contradicts what the table is showing.
3. **Given** the default is applied, **When** the user selects "All" in the status facet,
   **Then** inactive and archived records appear, and that choice survives paging, sorting
   and a browser reload.
4. **Given** a link someone shared that explicitly names a status, **When** the recipient
   opens it, **Then** they see exactly the status the sender saw, and the default does not
   override it.
5. **Given** the default is applied and nothing else is filtered, **When** the user looks at
   the filters button, **Then** it indicates that a filter is in effect, so an empty-looking
   list is never mistaken for an empty catalog.

---

### User Story 2 - The search button always refreshes the list (Priority: P1)

An administrator edits a customer, returns to the list, and presses the search button to
confirm the change landed. Nothing happens — the term did not change, so the screen has no
reason to re-ask the server, and the stale row stays on screen. They cannot tell whether
their edit failed or the screen simply did not refresh.

**Why this priority**: This is a correctness-of-perception defect, not a preference. It
teaches users to distrust the list, and the fix is small and self-contained.

**Independent Test**: On any list, submit the search control twice with the same term while
the underlying data changes between submissions, and confirm the second submission produces
fresh rows.

**Acceptance Scenarios**:

1. **Given** a list already showing results for a term, **When** the user submits the same
   term again, **Then** the list re-requests the current page and renders whatever the
   server now returns.
2. **Given** a record was changed elsewhere since the list loaded, **When** the user submits
   the search control without editing the term, **Then** the changed record's new values are
   shown.
3. **Given** the user edits the term and submits, **When** the request completes, **Then**
   exactly one request was issued for that submission, not two.
4. **Given** the user is on page 3 with a status facet and a sort applied, **When** they
   submit the search control unchanged, **Then** the page, facet and sort are all preserved.
5. **Given** the user types into the search field, **When** they have not yet submitted,
   **Then** no request is issued — typing alone never queries the server.

---

### User Story 3 - The list surface reads as one object (Priority: P2)

Anyone using any list sees a search row that hangs past both edges of the table beneath it,
a table whose bottom corners are rounded but whose top corners are square, and a table that
floats on the page with no outline to say where it begins. The screen looks unfinished, and
the inconsistency repeats on every catalog because each screen inherits it from the same
shared components.

**Why this priority**: Purely visual, but it is on every screen in the product and the fix
is confined to shared components, so it is cheap and broad. It ranks below the two
functional stories.

**Independent Test**: Render any list screen at each breakpoint in both light and dark
themes and confirm the filter row and table share the same left and right content edges,
the table has four rounded corners, and a hairline outline bounds it.

**Acceptance Scenarios**:

1. **Given** any list screen at any supported width, **When** it renders, **Then** the left
   edge of the search control and the right edge of the last filter-row control align with
   the left and right edges of the list surface beneath them.
2. **Given** any list screen, **When** it renders, **Then** all four corners of the list
   surface carry the same radius, and the column-header band does not paint square corners
   over the top two.
3. **Given** any list screen in either theme, **When** it renders, **Then** the list surface
   is bounded by a hairline outline that is visible against the page background.
4. **Given** a list whose current filters match no records, **When** it renders, **Then** the
   outline and corners are still drawn, so the empty state reads as an empty table rather
   than a missing one.
5. **Given** a developer adds a new list screen after this feature, **When** they use the
   shared components without writing any styling of their own, **Then** the alignment,
   corners and outline are already correct.

---

### User Story 4 - Facility cards and their child rows match the tables (Priority: P2)

On the Facilities screen, each facility card and each warehouse, point-of-sale and cash
drawer row beneath it is distinguished only by a slightly different fill. Against a dark
background the boundaries are hard to read, and the rows do not match the outlined surfaces
used everywhere else.

**Why this priority**: Same class of fix as User Story 3 and shares its outline decision,
but it is confined to one screen, so it delivers less breadth.

**Independent Test**: Render the Facilities screen with a facility that has all three child
types and confirm each card and row carries the shared outline and a tokenised radius.

**Acceptance Scenarios**:

1. **Given** the Facilities screen, **When** it renders, **Then** each facility card and each
   warehouse, point-of-sale and cash drawer row carries the same hairline outline used by
   the list surface.
2. **Given** those same surfaces, **When** they render, **Then** their corner radii come from
   the shared shape scale rather than per-widget values.
3. **Given** a card or row that supports hover or selection, **When** the user hovers or
   selects it, **Then** that state remains clearly distinguishable now that an outline is
   present.

---

### User Story 5 - Simple records open beside the list, not instead of it (Priority: P3)

A user scanning a long, filtered list of vehicles clicks one to check its plate. Today the
whole screen is replaced by that vehicle's page; going back costs a navigation and, on some
screens, their scroll position and page. For records this simple, they want the record to
open in a panel over the list, view it, optionally edit it, and close it with the list still
exactly where they left it.

**Why this priority**: The largest and riskiest slice — fourteen entities, the removal of
their routes, and a governance change — so it ships last, after the cheap cross-cutting wins
are already in users' hands.

**Independent Test**: For each of the fourteen entities, create, view, edit and delete a
record entirely from its list screen, and confirm the list's page, filters and scroll
position are unchanged afterward.

**Acceptance Scenarios**:

1. **Given** any of the fourteen entity lists, **When** the user clicks a row, **Then** that
   record opens read-only in a panel over the list and the list is not navigated away from.
2. **Given** the record is open read-only and the user may update it, **When** they use the
   panel's edit control, **Then** the same form becomes editable in place.
3. **Given** the record is open read-only and the user may not update it, **When** they look
   at the panel, **Then** no edit control is offered.
4. **Given** the user has the delete privilege, **When** they open a persisted record for
   editing, **Then** delete is available inside the panel with the same confirmation step
   used today; a user without that privilege is not shown it.
5. **Given** the user creates or edits a record and saves, **When** the panel closes, **Then**
   the list reflects the change while keeping its current page and filters.
6. **Given** the user has typed changes and dismisses the panel by clicking outside it,
   pressing Escape, or using its close control, **When** the dismissal is attempted, **Then**
   they are warned before their edits are discarded.
7. **Given** a wide display, **When** a record panel opens, **Then** the form still uses more
   than one column where the form has enough fields to warrant it.
8. **Given** an old bookmark to a removed per-record address, **When** it is opened, **Then**
   the user lands on that entity's list rather than an error.
9. **Given** a facility's warehouse, point of sale or cash drawer, **When** the user opens it
   from the facility card, **Then** it opens in a panel without leaving the Facilities screen.
10. **Given** any of the 14 entities' converted forms, **When** the user opens it, **Then** every
    field it already offers — including the entity pickers Customers uses for taxpayer recipient,
    employee and price list (autocomplete, not inline creation) — renders and behaves exactly as
    it does today.

---

### Edge Cases

- A catalog in which every record is inactive opens looking empty under the new default. The
  filters indicator must make the applied default discoverable so this is not read as data loss.
- A shared or bookmarked list address that predates this feature carries no status. It will
  now resolve to Active-only, which is a deliberate change in what an old link shows.
- The search control is submitted while a previous request for the same list is still in
  flight.
- The search control is submitted on a page that no longer exists because the result set
  shrank since the page was loaded.
- A record is deleted or archived by someone else while its panel is open, and the user then
  saves.
- A form long enough to exceed the panel's height, on a compact width where the panel is a
  bottom sheet and the on-screen keyboard is open.
- An entity-picker autocomplete (e.g. Customers' taxpayer recipient/employee/price list pickers)
  opened from within a panel that is itself already a panel.
- The largest supported text-scaling level, where the new outline and radius must not collide
  with grown row heights.
- A list surface rendered with zero rows.

## Requirements

### Functional Requirements

#### Default status filtering

- **FR-001**: Every list screen whose status facet is the shared entity lifecycle MUST apply a
  default value when the user arrives without an explicit status, rather than listing every
  record. This covers the catalogs — products, customers, employees, users, user profiles,
  vehicles, vehicle operators, facilities and payment method options — and excludes the
  transactional lists governed by FR-007.
- **FR-002**: For lists whose status is the shared entity lifecycle, the applied default MUST
  be Active.
- **FR-003**: The applied default MUST be shown in the filter UI as the selected value, so the
  filter panel never contradicts the table.
- **FR-004**: The user MUST be able to reach the unfiltered set in a single interaction, and
  that choice MUST persist across paging, sorting and reload exactly as a user-chosen filter does.
- **FR-005**: An explicit status carried in a shared link MUST take precedence over the default,
  including an explicit "all", so a link always reproduces what its sender saw.
- **FR-006**: The filters-applied indicator MUST count the default-applied status as an active
  filter, consistent with how the POS sales list already indicates its default date range.
- **FR-007**: The transactional lists — point-of-sale sales, sales orders and cash sessions —
  are explicitly OUT of scope for default status filtering and MUST be left exactly as they
  behave today, showing every state. This feature MUST NOT alter their filtering (see Out of
  Scope: transactional list filtering).

#### Search refresh

- **FR-008**: Submitting the search control MUST re-request the current page from the server
  even when neither the search term nor any other filter changed.
- **FR-009**: A submission that does change the term MUST result in exactly one request, not a
  filter-change request plus a refresh request.
- **FR-010**: Typing in the search field MUST NOT issue any request; submission remains the only
  trigger, and the shared search control MUST continue to offer no per-keystroke callback.
- **FR-011**: A refresh triggered this way MUST preserve the current page index, sort order and
  every active facet.
- **FR-012**: While a refresh is in flight the list MUST use the existing loading affordance and
  MUST NOT blank out the rows already displayed.

#### Filter row alignment

- **FR-013**: The filter row's left and right content edges MUST align with the content edges of
  the list surface beneath it at every supported width.
- **FR-014**: The filter row's internal spacing MUST be symmetric — the gap between the last
  trailing control and the row's right edge MUST equal the gap at the left edge.
- **FR-015**: All spacing introduced by this change MUST come from the shared spacing tokens; no
  literal values.
- **FR-016**: The alignment MUST be asserted by tests measuring real insets, not by visual
  inspection, per the existing rule for control bands.

#### List surface shape and outline

- **FR-017**: All four corners of the shared list surface MUST carry the same radius, taken from
  the shared shape scale.
- **FR-018**: The column-header band MUST NOT paint over the surface's top corners.
- **FR-019**: The shared list surface MUST carry a hairline outline of one logical pixel in the
  scheme's variant outline colour.
- **FR-020**: FR-017 through FR-019 MUST hold for both the paginated and the non-paginated list
  surface, so a screen's pagination choice never changes how its table looks.
- **FR-021**: These rules MUST be expressed once, in the shared design system or the shared list
  component, and no screen may pass its own values for them.
- **FR-022**: They MUST hold in both light and dark themes and at every supported text-scaling level.

#### Facility cards and child rows

- **FR-023**: The facility card and the warehouse, point-of-sale and cash drawer child rows MUST
  carry the same hairline outline defined in FR-019.
- **FR-024**: Those surfaces' corner radii MUST come from the shared shape scale, replacing their
  current per-widget values.
- **FR-025**: Hover and selected states on those surfaces MUST remain clearly distinguishable once
  the outline is present.

#### Records in a panel

- **FR-026**: For the fourteen entities named under Verbatim Constraints, both the create action
  and a row click MUST open the record in the app's shared responsive panel, without navigating
  away from the list.
- **FR-027**: A row click MUST open the record read-only; the create action MUST open it editable.
- **FR-028**: A read-only panel MUST offer an explicit control to make the form editable, shown
  only to a user holding the update privilege.
- **FR-029**: Delete or soft-delete MUST be available inside the panel for a persisted record,
  with the same confirmation step used today, and MUST NOT be shown to a user lacking the delete
  privilege.
- **FR-030**: The per-record addresses and full-screen record screens for those fourteen entities
  MUST be removed, and an address that previously resolved to one MUST land the user on that
  entity's list rather than an error.
- **FR-031**: Saving or deleting from the panel MUST close it and update the list without losing
  the list's current page, filters or sort.
- **FR-032**: Dismissing a panel with unsaved changes — by barrier click, Escape, or its close
  control — MUST warn before discarding them.
- **FR-033**: The panel MUST be wide enough on expanded and larger displays for the shared
  multi-column form layout to still produce more than one column where a form warrants it.
- **FR-034**: A facility's warehouse, point of sale and cash drawer MUST open in a panel from the
  facility card without leaving the Facilities screen.
- **FR-035**: Every field a converted form already offers — including an entity-picker
  autocomplete (e.g. Customers' taxpayer recipient, employee and price list pickers) — MUST
  continue to work unchanged from within the panel.
- **FR-036**: Entities not named in Verbatim Constraints — including products, facilities,
  taxpayer issuers, users and user profiles — MUST keep their existing full-screen record
  presentation; this feature MUST NOT convert them.

#### Enforcement for future work

- **FR-037**: The project's governing design rules MUST be amended so that the row-click,
  read-only, edit-control and delete placement rules are expressed in terms of a record's own
  surface — full screen or panel — rather than assuming a route, and so that they state which
  kinds of entity use which surface.
- **FR-038**: The styling rules in FR-013 through FR-024 MUST be enforced from the shared design
  system and shared components such that a new list screen written after this feature inherits
  them with no styling code of its own.

## Key Entities

- **Status-filtered list**: any list screen exposing a status facet. Carries a default value for
  that facet, an indication of whether filters are applied, and a filter state that round-trips
  through the address so links and history reproduce it.
- **List surface**: the shared visual container holding column headers, rows and pagination.
  Carries one radius, one outline and one set of content edges shared by every screen.
- **Record surface**: the presentation of a single record — either a full screen or the shared
  responsive panel. Carries a read-only and an editable mode, an edit control gated on the update
  privilege, and a delete action gated on the delete privilege.
- **Shape and spacing scale**: the shared token sets that own every radius and inset introduced
  here, and the single place a future screen inherits them from.

## Success Criteria

### Measurable Outcomes

- **SC-001**: 100% of catalog lists exposing an entity-lifecycle status facet open showing only
  active records, with zero user interactions.
- **SC-002**: A user can go from the default-filtered list to the unfiltered list in exactly one
  interaction, on every such list, and the transactional lists' behaviour is unchanged by this
  feature.
- **SC-003**: Submitting the search control with an unchanged term produces a fresh server
  response 100% of the time; submitting it with a changed term produces exactly one request.
- **SC-004**: On every supported width, the filter row's left and right content edges match the
  list surface's content edges to within zero logical pixels.
- **SC-005**: Every list surface renders four equally rounded corners and a visible hairline
  outline in both light and dark themes.
- **SC-006**: All 14 named entities can be created, viewed, edited and deleted without leaving
  their list screen, and zero per-record addresses remain for them.
- **SC-007**: Zero hard-coded radius or inset values remain in the components touched by this
  feature; all come from the shared scales.
- **SC-008**: A list screen added after this feature, written with the shared components and no
  styling code of its own, satisfies SC-004 and SC-005 without modification.
- **SC-009**: The full automated test suite and the static analyser pass with no new failures or
  warnings.

## Out of Scope: transactional list filtering

**The point-of-sale sales, sales orders and cash sessions lists keep their current filtering
behaviour, unchanged.** Default status filtering was considered for them and deliberately
dropped, because the server cannot express the defaults that were wanted:

- The intended defaults are *every state except cancelled* for point-of-sale sales and sales
  orders, and *open together with stale* for cash sessions. Both are multi-state selections.
- Both list endpoints accept a **single** optional status value, and for cash sessions the
  three values are mutually exclusive server-side conditions — `open` and `stale` partition
  the not-yet-closed sessions between them, so no single existing value means "either".
- Filtering the fetched page in the client is not an alternative: both lists are paginated by
  the server, so discarding rows from a page would corrupt both the page size and the reported
  total.

Delivering it would therefore require a server change — accepting multiple status values, or
an exclusion parameter. The requester decided not to pursue that and not to raise it with the
API: these three lists are to be left as they are. No follow-up work is scheduled, and this
feature carries no external dependency.

Recorded for whoever revisits this: if it is ever picked up, the intended approach was to keep
the status facets single-select and express the multi-state default implicitly behind the
existing "All" choice, rather than converting them to multi-select controls. That trades away
the guarantee FR-003 makes for the catalogs — that the filter UI always literally describes what
the table is showing — so it would need to say how a user learns which states are being hidden.

## Assumptions

- "Active by default" describes the initial state of a visible, user-editable filter, not a
  hidden restriction on what the server may return. Users retain full access to inactive and
  archived records.
- Old links to a list carrying no status will now show Active-only rather than everything. This
  is accepted as the intended behaviour change rather than treated as a regression.
- Losing per-record addresses for the fourteen converted entities is accepted, as decided with
  the requester. No per-record deep link is preserved for them; an old one resolves to the list.
- The shared panel's current fixed width was chosen for a filter form and is assumed to be too
  narrow for record forms; widening it, or making it width-tiered, is in scope for FR-033.
- The existing shared record-action component already provides save, delete and delete
  confirmation independently of the surface hosting it, and is assumed reusable inside the panel
  without behavioural change.
- The outline colour and thickness in FR-019 are assumed identical for the list surface, facility
  cards and child rows, so all three are defined from one place.
- Facility children are reached from the Facilities screen rather than from a top-level list of
  their own; their panels open over that screen.
- Taxpayer issuers are excluded from the conversion because of the certificate management they
  own, even though their record screen is comparable in size to the converted ones.
- "Every list with a status filter" was the requester's original scope for default filtering; it
  was narrowed to the entity-lifecycle catalogs once the server constraint above was found. The
  transactional lists are left untouched rather than approximated, and no server change is being
  requested for them.

## Verbatim Constraints

The fourteen entities to be converted to a panel, exactly as specified by the requester:

- `PriceLists`
- `Suppliers`
- `Labels`
- `Employees`
- `Customers`
- `Taxpayer recipients`
- `Expenses`
- `Vehicles`
- `Operators`
- `Warehouse`
- `Point of Sale`
- `Cash Drawer`
- `Exchange Rates`
- `Payment Method Options`

The default status value for entity-lifecycle lists: `Active`.
