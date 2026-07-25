# Feature Specification: Cross-Screen UX Consistency & Filtering Backfill

**Feature Branch**: `017-ui-consistency-filters`

**Created**: 2026-07-25

**Status**: Draft

**Input**: User description: "Let's create a spec to enhance overall project experience and review the created screens up to the current state, and add missing features to the ones that were build earlier, like filtering by query params. Let's also move the edit icon button that is shown in the app bar, to an outlined button similar to the save/delete buttons of the edit mode."

## Context

This is a **remediation feature, not a new business capability**. Fourteen feature
specs (001–015) have shipped **18 list screens** and **18 record detail screens**
across the `catalog`, `pricing`, and `auth` modules. Each spec inherited the shared
patterns that existed *at the time it was written*, so the earliest screens are
missing capabilities the later ones take for granted, and one interaction pattern
(the read-only → edit affordance) needs to change for all of them at once.

A review of the current state found five concrete, verified inconsistencies. This
feature closes all five, so that a user moving between any two screens in the
product encounters the same behavior, and so future features inherit one correct
pattern instead of copying whichever variant they happen to land next to.

**Review findings that motivate this feature** (each verified against the current
`main`):

| # | Finding | Screens affected |
|---|---|---|
| 1 | The read-only → edit affordance is an app-bar icon, visually and spatially divorced from the Save/Delete buttons that replace it in edit mode. | All 18 detail screens |
| 2 | Save and Delete (plus its confirmation dialog) are hand-copied per screen and stretched edge-to-edge on wide displays. | All 18 detail screens |
| 3 | Four catalogs ignore a filter facet their own data source already offers, so records cannot be narrowed by a criterion the list even displays. | Vehicles, Vehicle Operators, Users, Products |
| 4 | No list view is addressable: filters, search text, and page number exist only in memory. A filtered list cannot be linked, bookmarked, or refreshed, and returning from a record resets it to an unfiltered page 1. | All 18 list screens |
| 5 | Not one list screen uses the shared error presentation; every one renders load failures by interpolating the raw underlying failure object into a sentence, and every empty state is a bare line of centered text with no way to recover. | All 18 list screens |

## Clarifications

### Session 2026-07-25

- Q: "Filtering by query params" — does this mean wiring up the filter facets the
  data source already supports but the screens never used, or making the filter
  state addressable in the URL query string? → A: **Both.** They are separate
  deliverables in this feature: backfilling the unused facets (finding 3) restores
  missing *capability*, and making list state URL-addressable (finding 4) makes
  every list shareable, bookmarkable, refresh-safe, and Back-button-correct.
- Q: Beyond moving the edit affordance and the filtering work, what else belongs in
  the "overall experience" scope? → A: Three additions — (a) extract the duplicated
  Save/Delete/Edit action set into one shared record-action component so the
  affordance move is a single change rather than eighteen, (b) make a list survive
  navigating into a record and back, and (c) give every list one consistent
  loading, empty, and error presentation.
- Q: The deferred table polish on the pricing screens (empty vertical space below
  short tables, footer placement, search box layout) — in or out? → A: **Out.** It
  stays deferred and is explicitly listed under Out of Scope. Only the pricing
  screens' loading/empty/error presentation is touched here, as part of (c).
- Q: The governing design rules currently *require* the edit affordance to live in
  the app bar. Is changing them part of this feature? → A: **Yes, explicitly.** The
  project's design principles reserve the record app bar for exactly this toggle.
  Reversing that is a deliberate amendment to the governing rules and the design
  record, and is a first-class deliverable of this feature (FR-005) rather than an
  undocumented drift away from them.

## User Scenarios & Testing *(mandatory)*

<!--
  User stories are PRIORITIZED as user journeys ordered by importance.
  Each is INDEPENDENTLY TESTABLE — implementing just one still yields a viable
  improvement that can be demonstrated on its own.
-->

### User Story 1 - Act on a record from one consistent place (Priority: P1)

A user opens a record in read-only mode — by clicking its row — and decides to
change it. Today the way in is a small unlabeled icon in the top app bar, far from
the form they are reading, while the actions that appear *after* they switch to edit
mode (Save, Delete) sit at the bottom of the form. The user has to learn two
different places for what is one continuous task.

After this change, every record action lives in one place at the end of the form.
In read-only mode that place holds a single **Edit** button, visually a lighter
sibling of the Save and Delete buttons; switching to edit mode swaps it for Save and
Delete in that same place. The buttons no longer stretch the full width of a wide
display. Every one of the 18 record screens presents this identically.

**Why this priority**: It is the change the user explicitly asked for, it affects
every record screen in the product, and it removes the single most visible
inconsistency in the app — an action that moves across the screen depending on which
mode you are in. It also has a hard prerequisite worth doing regardless: the action
set must first become one shared component, since it is currently copy-pasted 18
times.

**Independent Test**: Can be fully tested by opening any record read-only,
confirming there is no edit icon left in the app bar, confirming an Edit button
appears at the end of the form alongside where Save/Delete would be, clicking it,
and confirming the same region now offers Save and Delete — then repeating on a
record from a different module and observing identical placement, order, and
styling. Requires none of the other stories.

**Acceptance Scenarios**:

1. **Given** a user with update privilege viewing a record in read-only mode,
   **When** the screen renders, **Then** the app bar contains no edit action, and an
   Edit control appears in the record's action area at the end of the form.
2. **Given** that read-only record, **When** the user activates Edit, **Then** the
   form becomes editable and the same action area now presents Save and, where the
   user holds the delete privilege, Delete.
3. **Given** a user **without** update privilege viewing a record, **When** the
   screen renders, **Then** no Edit control is offered anywhere — it is absent, not
   shown-but-disabled.
4. **Given** a user without delete privilege editing a record, **When** the screen
   renders, **Then** no Delete control is offered anywhere.
5. **Given** any two record screens from different modules, **When** both are opened
   in the same mode, **Then** their action controls appear in the same position,
   same left-to-right order, and same visual weight.
6. **Given** a record screen on a wide display, **When** the action area renders,
   **Then** its buttons are sized to their content rather than stretched across the
   full width of the form.
7. **Given** a user deleting a record, **When** they activate Delete, **Then** they
   are asked to confirm before anything is deleted, with the same confirmation
   wording pattern on every screen.
8. **Given** a record being created (not yet saved), **When** the screen renders,
   **Then** the action area offers Save only — no Edit and no Delete.

---

### User Story 2 - Filter every catalog by every criterion its data supports (Priority: P1)

A user managing vehicles wants to see only the active ones. The list shows a status
for every vehicle, but offers no way to filter by it — so the user pages through
inactive records by hand. The same gap exists for vehicle operators and for user
accounts, and a purchasing user cannot narrow the product catalog to a single
supplier even though every product records one.

After this change, each of these catalogs offers the missing filter using the same
filter controls the rest of the product already uses, and filtering happens against
the full dataset — not just the page currently on screen.

**Why this priority**: This is missing functionality, not polish: the user cannot
accomplish a reasonable task at all today. It is also low-risk, since the data
source already accepts every one of these criteria and other catalogs already
demonstrate the exact control for each.

**Independent Test**: Can be fully tested by opening the Vehicles catalog, filtering
to Active, and confirming that inactive vehicles disappear and the result count and
paging reflect the filtered total rather than the unfiltered one; then repeating for
Vehicle Operators (status), Users (status), and Products (supplier). Requires none
of the other stories.

**Acceptance Scenarios**:

1. **Given** the Vehicles catalog, **When** the user opens its filter controls,
   **Then** a status filter is available and behaves identically to the status
   filter on catalogs that already have one.
2. **Given** the Vehicle Operators catalog, **When** the user opens its filter
   controls, **Then** a status filter is available alongside the existing operator
   filter, and the two combine.
3. **Given** the Users administration list, **When** the user opens its filter
   controls, **Then** a status filter is available.
4. **Given** the Products catalog, **When** the user opens its filter controls,
   **Then** a supplier filter is available, presented the same way as other
   record-reference filters in the product, and combines with the existing label,
   status, and stockable/salable/purchasable filters.
5. **Given** any filter applied on any of these catalogs, **When** the results
   return, **Then** the total count and the number of pages reflect the filtered
   result set, not the unfiltered one.
6. **Given** a filter is applied, **When** the user clears it, **Then** the
   unfiltered list returns without requiring a page reload.
7. **Given** the review of all list screens, **When** a catalog's data source offers
   a criterion the screen does not expose, **Then** either the screen exposes it or
   the omission is recorded with a reason.

---

### User Story 3 - Share, bookmark, and refresh a filtered list (Priority: P2)

A user narrows the products list to a supplier's active items, lands on page 3, and
wants to send that exact view to a colleague — or simply refresh the page without
starting over. Today the address bar shows only the bare list address; the view
cannot be shared, cannot be bookmarked, and is lost on every refresh.

After this change, the address always describes the view: search text, every applied
filter, and the current page. Opening that address — pasted, bookmarked, or
refreshed — reproduces the same view.

**Why this priority**: High value on the primary (web) target and a prerequisite for
Story 4's most natural implementation, but users can work without it today, unlike
the missing filters in Story 2.

**Independent Test**: Can be fully tested by applying a search term and filters on
any list, paging forward, copying the address, opening it in a fresh session, and
confirming the same search, filters, and page appear — and by refreshing the page in
place and confirming nothing is lost.

**Acceptance Scenarios**:

1. **Given** a user applies a search term on a list, **When** the results render,
   **Then** the address reflects that search term.
2. **Given** a user applies one or more filters, **When** the results render,
   **Then** the address reflects each applied filter.
3. **Given** a user moves to another page, **When** the page renders, **Then** the
   address reflects the current page.
4. **Given** an address describing a filtered, paged view, **When** it is opened in
   a new session by a user with access, **Then** that same search, filters, and page
   are applied and shown in the filter controls, not merely in the address.
5. **Given** such a view, **When** the user refreshes, **Then** the view is
   unchanged.
6. **Given** an address containing an unrecognized or invalid filter value, **When**
   it is opened, **Then** the list loads with that value ignored rather than
   failing, and the user is not shown an error.
7. **Given** all filters and search are cleared and the user is on the first page,
   **When** the view renders, **Then** the address is the clean list address with no
   leftover parameters.
8. **Given** a user changes filters several times, **When** they press the browser's
   Back button, **Then** they return to the previous filter state rather than
   leaving the list entirely.

---

### User Story 4 - Return from a record to exactly the list you left (Priority: P2)

A user searches a large catalog, filters it, pages to the record they want, opens
it, and goes back. Today they land on an unfiltered page 1 and must redo the search,
the filters, and the paging — every single time. For a user working through a batch
of records this is the most repeated friction in the product.

After this change, leaving a record returns the user to the exact list view they
came from: same search text, same filters, same page.

**Why this priority**: It is high-frequency friction, but it is a restoration of
context rather than a missing capability, and Story 3 supplies the most natural
mechanism for it.

**Independent Test**: Can be fully tested by filtering any list, paging to page 3,
opening a record, returning, and confirming the list still shows page 3 with the
same search and filters — repeated for a record opened read-only (row click) and one
opened for edit.

**Acceptance Scenarios**:

1. **Given** a filtered list on page 3, **When** the user opens a record and returns
   without changing it, **Then** the list shows page 3 with the same search and
   filters applied.
2. **Given** the same, **When** the user edits and saves the record and returns,
   **Then** the list shows the same page and filters, refreshed to reflect the
   change.
3. **Given** the same, **When** the user deletes the record and returns, **Then**
   the list shows the same filters with the deleted record gone, and — if that
   record was the only item on the last page — the user is left on a valid page
   rather than an empty one.
4. **Given** the same, **When** the user creates a new record and returns, **Then**
   the list reflects the new record without discarding the user's search, filters,
   or page.

---

### User Story 5 - Understand at a glance why a list is not showing results (Priority: P3)

A list can be loading, empty because the catalog has no records, empty because the
user's filters matched nothing, or failed. Today all four look broadly alike — a
line of centered grey text — and a failure additionally shows the user raw internal
failure detail rather than a comprehensible message. Nothing offers a way out: an
over-filtered list gives no way to clear filters, and a genuinely empty catalog
gives no prompt to create the first record.

After this change all 18 lists present these states identically, distinguish "no
records yet" from "nothing matched your filters", offer the appropriate way forward,
and describe failures in the same comprehensible terms the record screens already
use.

**Why this priority**: It affects comprehension and polish rather than the ability
to complete a task, so it ranks below the functional gaps — but it is the finding
with the widest reach (every list screen) and the one that most directly contradicts
the project's existing error-presentation rule.

**Independent Test**: Can be fully tested by forcing each of the four states on any
list (slow load, empty catalog, filters matching nothing, backend unavailable),
confirming each renders its own distinct and consistent treatment, and confirming
the failure text contains no raw internal detail — then repeating on a list from a
different module and observing identical treatment.

**Acceptance Scenarios**:

1. **Given** a list is loading, **When** it renders, **Then** it shows the same
   loading treatment used by every other list.
2. **Given** a list whose catalog contains no records at all and no filters are
   applied, **When** it renders, **Then** it says so and — for a user with create
   privilege — offers to create the first record.
3. **Given** a list where filters or a search term are applied and nothing matched,
   **When** it renders, **Then** it says the filters matched nothing (distinctly
   from an empty catalog) and offers to clear them.
4. **Given** a list whose load fails, **When** it renders, **Then** it shows a
   comprehensible message drawn from the same failure vocabulary the record screens
   use, with no raw internal failure detail shown to the user, and offers to retry.
5. **Given** a failed list, **When** the user retries, **Then** the list attempts
   the load again with the current search, filters, and page intact.
6. **Given** any two lists from different modules in the same state, **When** both
   render, **Then** the treatment is identical apart from the entity-specific
   wording.

---

### Edge Cases

- **A user opens a shared list address for a catalog they lack read access to** —
  the existing access rules apply unchanged; the address's filter parameters must
  not create any path around them.
- **A shared address names a filter value the user cannot see** (e.g. a supplier
  outside their scope) — the list must load with that filter ignored or empty rather
  than failing.
- **A shared address names a page beyond the end of the filtered result set** — the
  user lands on a valid page rather than an empty one or an error.
- **A user's privileges change between opening a record read-only and acting on it**
  — the server remains authoritative; a rejected action surfaces as a comprehensible
  failure rather than a silent no-op.
- **A record is deleted by someone else while a user has it open read-only** — the
  Edit control leads to a failure that is reported comprehensibly, and the user is
  not stranded.
- **A record screen with no delete capability at all** (e.g. an entity whose data
  source exposes none) — the action area renders correctly with the Delete slot
  simply absent, not blank-but-reserved.
- **Filter and search values containing characters that need encoding in an address**
  (accented characters, `&`, `#`, spaces) — round-trip through the address without
  corruption.
- **A list whose filter set is later extended by a new feature** — the shared
  address mechanism accepts the new filter without each screen re-implementing
  encoding rules.
- **A list reached by a route that carries its own parameters** (a nested or scoped
  list) — list-state parameters coexist with those without collision.

## Requirements *(mandatory)*

### Functional Requirements

**Record action consistency (US1)**

- **FR-001**: Every record detail screen MUST present its Edit, Save, and Delete
  actions in a single, consistent action area within the record form, in one fixed
  left-to-right order, identical across all modules.
- **FR-002**: The read-only → edit affordance MUST be presented as a labeled button
  of lighter visual weight than the Save and Delete buttons, in that same action
  area — not as an app bar icon.
- **FR-003**: After this change, a record screen's app bar MUST NOT carry the edit
  affordance. It MAY retain the record's own delete action only where the form-body
  action area genuinely cannot accommodate it, and that exception MUST be recorded.
- **FR-004**: The record action area MUST NOT stretch its buttons to the full width
  of the form on wide displays.
- **FR-005**: The project's governing design principles and design record MUST be
  amended to reflect the new rule *before or alongside* the screens changing, so
  that no shipped screen contradicts the written rule at any point. The amendment
  MUST follow the project's established amendment process, including a version bump.
- **FR-006**: The record action set — including the delete confirmation prompt —
  MUST be defined once in shared components and reused by every record screen, not
  reimplemented per screen.
- **FR-007**: Each action MUST be shown only to a user holding the corresponding
  privilege, and MUST be absent — not disabled — otherwise, preserving the current
  behavior exactly.
- **FR-008**: While a record is being saved or deleted, its actions MUST prevent a
  duplicate submission and MUST indicate that work is in progress.

**Filter backfill (US2)**

- **FR-009**: The Vehicles catalog MUST offer a status filter.
- **FR-010**: The Vehicle Operators catalog MUST offer a status filter, combinable
  with its existing operator filter.
- **FR-011**: The Users administration list MUST offer a status filter.
- **FR-012**: The Products catalog MUST offer a supplier filter, combinable with its
  existing filters.
- **FR-013**: Every backfilled filter MUST use the same shared filter controls and
  visual treatment as the equivalent filter on catalogs that already have one — a
  module MUST NOT introduce its own filter presentation.
- **FR-014**: All filtering MUST be applied against the complete dataset by the data
  source, never by filtering the page already retrieved.
- **FR-015**: A review MUST be performed across every list screen comparing the
  filter criteria its data source accepts against the criteria the screen exposes.
  Every gap MUST be either closed in this feature or recorded, with a reason, as a
  known omission.
- **FR-016**: Catalogs whose data source genuinely offers only free-text search MUST
  remain search-only. A missing server-side criterion MUST NOT be compensated for
  with client-side filtering.

**Addressable list state (US3)**

- **FR-017**: Every list screen's search text, applied filters, and current page
  MUST be represented in the screen's address.
- **FR-018**: Opening such an address MUST reproduce the described view, with the
  restored values visible in the filter controls, not only applied to the results.
- **FR-019**: The address MUST be the authority for list view state, so that a
  refresh, a pasted link, and a Back navigation all yield the same view.
- **FR-020**: Default values — empty search, no filters, first page — MUST NOT
  appear in the address, so an unfiltered list has a clean address.
- **FR-021**: An unrecognized, malformed, or out-of-range value in the address MUST
  be ignored gracefully; the list MUST still load and MUST NOT surface an error to
  the user.
- **FR-022**: Changing filters, search, or page MUST produce Back-navigable history
  entries so the browser Back button returns to the previous view rather than
  leaving the list.
- **FR-023**: The encoding and decoding of list state MUST be defined once and shared
  by every list screen, and MUST be consistent with the existing read-only-record
  address convention.

**List state preservation (US4)**

- **FR-024**: Navigating from a list into a record and back MUST restore the list's
  search, filters, and page exactly as they were left.
- **FR-025**: Returning after creating, updating, or deleting a record MUST show a
  list refreshed to reflect the change while preserving search, filters, and page.
- **FR-026**: If the page a user returns to no longer exists because the result set
  shrank, the user MUST land on the nearest valid page rather than an empty view.

**Consistent list feedback (US5)**

- **FR-027**: Every list screen MUST present loading, empty, filtered-empty, and
  failed states using one shared set of treatments defined in shared components.
- **FR-028**: A list MUST distinguish "this catalog has no records" from "your
  filters matched nothing", with wording appropriate to each.
- **FR-029**: An empty catalog MUST offer to create the first record to a user
  holding the create privilege, and MUST NOT offer it otherwise.
- **FR-030**: A filtered-empty list MUST offer to clear the applied filters and
  search.
- **FR-031**: A failed list MUST describe the failure using the project's existing
  shared failure vocabulary and presentation, and MUST NOT show the user raw
  internal failure detail.
- **FR-032**: A failed list MUST offer a retry that re-attempts the load with the
  current search, filters, and page unchanged.

**Cross-cutting constraints**

- **FR-033**: No new third-party dependency may be introduced by this feature.
- **FR-034**: No generated API client code may be hand-edited, and no hand-written
  substitute for a generated data contract may be introduced.
- **FR-035**: No change may be made to the backend repository from this work. Any
  backend gap found during the review MUST be recorded as an external dependency and
  filed upstream.
- **FR-036**: Every new or changed user-facing string MUST be added to all supported
  locales.
- **FR-037**: Existing automated tests that assert on the moved or replaced controls
  MUST be updated as part of the change, and the shared components introduced here
  MUST themselves be covered by tests.
- **FR-038**: No screen's existing access-control behavior may be weakened by any
  change in this feature.

### Key Entities

- **Record action set**: the Edit / Save / Delete actions available on a record,
  their visibility (driven by the user's privileges and whether the record is being
  viewed, edited, or created), their fixed order, and the confirmation required
  before a deletion.
- **List view state**: the search text, the set of applied filter criteria, and the
  current page that together describe what a list is showing. Addressable,
  shareable, and restorable; the unit that must survive a refresh, a shared link,
  and a round trip into a record.
- **List presentation state**: which of loading, populated, empty, filtered-empty,
  or failed a list is currently in, and the recovery action appropriate to each.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: All 18 record detail screens present Edit, Save, and Delete in the
  same position, order, and styling; zero record screens retain an edit action in
  the app bar.
- **SC-002**: A user switching a record from viewing to editing finds the control in
  the same region of the screen where the resulting Save button appears — the
  affordance no longer moves between modes on any screen.
- **SC-003**: Every list screen can be filtered by every criterion its data source
  accepts, or the omission is documented; the count of undocumented gaps is zero
  (from four today).
- **SC-004**: A user can reproduce any filtered, searched, paged list view from its
  address alone, in a new session, on 100% of list screens.
- **SC-005**: Returning to a list after opening a record preserves search, filters,
  and page on 100% of list screens (from 0% today).
- **SC-006**: A user working through a filtered list of records no longer re-enters
  search terms or re-applies filters between records — reducing the interactions
  needed to review N records from roughly proportional to N to a fixed setup cost.
- **SC-007**: All 18 list screens render loading, empty, filtered-empty, and failed
  states with the same shared treatment, and each of the four states is visually
  distinguishable from the other three.
- **SC-008**: Zero list screens present raw internal failure detail to the user
  (from 18 today).
- **SC-009**: The governing design principles and design record describe the new
  record-action rule, and no shipped screen contradicts them.
- **SC-010**: The duplicated record-action markup is defined in one shared place;
  changing the action set's appearance requires editing one component, not 18
  screens.
- **SC-011**: No regression in access control: every action hidden from an
  unprivileged user before this feature remains hidden after it.

## Assumptions

- **The review baseline is the shipped state of specs 001–015 on `main`.** Findings
  were verified against the current code; any screen added between this spec and its
  implementation is expected to be brought in line as part of the same work.
- **"All 18 detail screens"** means the record create/view/edit screens for: user,
  cash drawer, customer, employee, expense, facility, label, payment method option,
  point of sale, product, supplier, taxpayer issuer, taxpayer recipient, vehicle,
  vehicle operator, warehouse, exchange rate, and price list. **"All 18 list
  screens"** means the corresponding catalog lists.
- **The product pricing screen and the merge-products screen** are not catalog list
  screens and are out of scope for the filtering and addressable-state stories, but
  are in scope for the loading/empty/failed-state consistency story (US5), since
  they exhibit the same ad-hoc treatments.
- **Every filter backfilled in US2 is already accepted by the existing data source.**
  No backend change is required for US2; this was verified during the review.
- **The addressable-state mechanism reuses the existing navigation layer** and the
  existing read-only-record address convention rather than introducing a parallel
  scheme.
- **The record embedded sub-sections** (a facility's inline address, a taxpayer
  issuer's certificates, a product's prices sub-panel) keep their own local actions
  and are not governed by the shared record action area; only the record's own
  Edit/Save/Delete move.
- **Locale coverage** means the project's existing supported locales; no new locale
  is added.
- **Pagination page size** is unchanged; this feature changes how a page is
  addressed and restored, not how large it is.

## Dependencies

- **Governing design principles amendment (internal, blocking for US1)**: the
  current principles reserve the record app bar for the read-only → edit toggle.
  FR-005 requires amending that rule and the corresponding design record, with a
  version bump, following the established amendment process. This must land with —
  not after — the screen changes.
- **Existing shared components**: the filter drawer, search bar, status filter
  controls, record-reference picker, pagination, data table, responsive form grid,
  and shared failure presentation are all reused. This feature adds shared
  components (record action area, list state encoding, list feedback states) rather
  than replacing existing ones.
- **Existing automated test suites** for the affected screens must be updated
  alongside the changes (FR-037), notably any that locate the edit affordance in the
  app bar.
- **Upstream (tracked, non-blocking)**: the previously filed request to add
  free-text search to the Payment Method Options list remains open and is **not**
  part of this feature. If the review under FR-015 surfaces further server-side
  gaps, they are filed upstream and recorded, not worked around.

## Out of Scope

- **Table layout polish on the pricing screens** — the deferred empty vertical space
  below short tables, footer placement, and search box layout issues on the pricing
  and price-list screens remain deferred. Only those screens' loading/empty/failed
  presentation is touched here.
- **New catalogs, entities, or business capabilities.** This feature adds no new
  record type and no new screen beyond shared components.
- **Column sorting, saved views, bulk selection, or export** on list screens.
- **Compact (phone) tier redesign.** The changes must not break the compact tier,
  but no new compact-specific layout work is undertaken.
- **Any change to the backend.** See FR-035.
- **Reworking the record forms themselves** — field layout, validation, and grouping
  are unchanged except where the action area's relocation requires it.
- **Changes to the read-only-record address convention itself**; list state is added
  alongside it, consistently, without redefining it.
