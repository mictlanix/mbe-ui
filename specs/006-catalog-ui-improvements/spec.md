# Feature Specification: Catalog UI/Layout Improvements

**Feature Branch**: `006-catalog-ui-improvements`

**Created**: 2026-07-05

**Status**: Draft

**Input**: User description: "Catalog UI/layout improvements for the product catalog screens. Two focused, presentation-only enhancements (no API or data-model changes): (1) declutter the products-list filter bar behind a Filters button + sheet with an active-filter count badge; (2) make the product detail screen use horizontal space on wide screens via a responsive multi-column form and a photo thumbnail with its action buttons on the same row."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Decluttered product-list filtering (Priority: P1)

A user opens the Products catalog. Instead of a crowded row of filter chips and a
label dropdown competing with the search box, they see a prominent search box and a
single **Filters** control. When one or more filters are active, that control shows a
**count badge** so the user knows filters are narrowing their results even before
opening it. Tapping the control opens a **filter panel** listing every facet filter
(stockable, salable, purchasable, show-inactive, and label). The user adjusts filters
there, sees the effect, and can **clear all** filters in one action or **apply** and
dismiss the panel.

**Why this priority**: The cluttered filter bar is the most visible usability problem
in the screenshots and affects every visit to the catalog. It is also fully
self-contained on the list screen, making it the highest-value, lowest-risk slice.

**Independent Test**: Load the products list, confirm the filter bar shows only the
search box plus a Filters control; open the panel, toggle each facet, confirm the
result set updates and the badge count reflects the number of active filters; use
Clear All and confirm all facets reset and the badge disappears.

**Acceptance Scenarios**:

1. **Given** the products list with no filters active, **When** the screen renders,
   **Then** the filter area shows a prominent search box and a single Filters control
   with no count badge, and no facet chips/dropdowns are shown inline.
2. **Given** the products list, **When** the user activates two facet filters via the
   panel, **Then** the Filters control shows a badge with the count "2" and the list
   reflects both filters.
3. **Given** the panel is open with active filters, **When** the user chooses Clear
   All, **Then** every facet resets to its default, the list returns to the unfiltered
   result set, and the badge disappears.
4. **Given** a viewport at desktop/web width, **When** the user opens the Filters
   control, **Then** the panel appears anchored to the side of the window; **and given**
   a narrow (compact) viewport, the panel appears from the bottom of the screen.
5. **Given** a user without update/delete privileges, **When** they use filtering,
   **Then** filtering behaves identically — filtering is a read capability and is not
   gated by write privileges.
6. **Given** any active filter and pagination, **When** filters change, **Then** result
   paging and counts stay consistent with the applied filters (no behavior regression
   versus the current inline chips).

---

### User Story 2 - Responsive multi-column product form (Priority: P2)

An operator edits or views a product on a wide (e.g. 4K) monitor. Rather than a single
column of full-width text fields stretched across the whole screen, the form is
constrained to a comfortable reading width and lays its fields out in **multiple
columns** that adapt to the available width: one column on narrow screens, two on
medium/expanded, three on the widest screens. All existing fields, their order,
validation, read-only behavior, and localized labels are preserved.

**Why this priority**: Directly addresses wasted horizontal space and long eye-travel
on large displays, the primary complaint for the detail screen. It depends on nothing
from Story 1 and can ship independently.

**Independent Test**: Open a product in edit mode on a wide viewport and confirm fields
arrange into three columns within a constrained max width; shrink the window and confirm
it reflows to two then one column; confirm every field still edits, validates, and
respects read-only/view mode exactly as before.

**Acceptance Scenarios**:

1. **Given** a viewport at the widest tier, **When** the product form renders, **Then**
   the text fields are laid out in three columns within a constrained maximum content
   width (not stretched edge-to-edge).
2. **Given** a viewport at the medium/expanded tier, **When** the form renders, **Then**
   fields are laid out in two columns.
3. **Given** a viewport at the compact tier, **When** the form renders, **Then** fields
   are laid out in a single column identical in behavior to today.
4. **Given** view (read-only) mode, **When** the form renders at any width, **Then** the
   same responsive column layout applies and all fields remain non-editable.
5. **Given** a field with a validation error, **When** the error displays, **Then** it
   appears with its field in the multi-column layout without truncation or overlap.
6. **Given** the switches, prices, and labels sections, **When** the form renders,
   **Then** they sit within the same constrained max-width container and remain legible
   and aligned rather than stretching full screen width.

---

### User Story 3 - Photo thumbnail with inline actions (Priority: P3)

When editing a product, the photo thumbnail and its **Change photo / Remove photo**
buttons share a single row: the buttons sit beside the image rather than stacked
underneath it, reclaiming the near-empty row visible in the screenshot.

**Why this priority**: A smaller, cosmetic refinement of the detail screen. Valuable but
lowest-impact of the three, and independent of the column layout work.

**Independent Test**: Open a product with a photo in edit mode and confirm the
Change/Remove buttons render to the side of the thumbnail; confirm upload, replace, and
remove still work and that any photo validation error still displays.

**Acceptance Scenarios**:

1. **Given** edit mode with an existing photo, **When** the photo area renders, **Then**
   the Change and Remove actions appear beside the thumbnail on the same row.
2. **Given** edit mode with no photo, **When** the photo area renders, **Then** the
   upload action appears beside the placeholder thumbnail.
3. **Given** view (read-only) mode, **When** the photo area renders, **Then** no
   edit/upload/remove actions appear (unchanged from today).
4. **Given** a narrow (compact) viewport, **When** the photo area renders, **Then** it
   remains usable — actions may stack below the thumbnail if side-by-side would overflow.
5. **Given** a photo validation error, **When** it occurs, **Then** the error message
   still displays near the photo area.

---

### Edge Cases

- **No facet filters available** (e.g. label list empty): the Filters control still
  opens the panel showing whatever facets exist; the label facet is omitted when no
  labels exist, matching current behavior.
- **All filters at default**: the Filters control shows no badge and the panel's Clear
  All is a no-op (or disabled).
- **Opening the panel while the list is loading or errored**: filtering controls remain
  available; applying a filter re-triggers the query as today.
- **Very long field content or long validation messages** in a narrow column: text wraps
  or truncates per the shared truncation rules (constitution §VI) without breaking the
  grid.
- **Odd number of fields** in a 2- or 3-column grid: the trailing row is left-aligned
  with empty trailing cells, not stretched to fill.
- **Photo actions in the narrowest column**: actions reflow below the thumbnail rather
  than overflowing horizontally.

## Requirements *(mandatory)*

### Functional Requirements

**Products list filtering (Story 1)**

- **FR-001**: The products list MUST present its facet filters (show-inactive, stockable,
  salable, purchasable, and label) inside a dedicated filter panel opened from a single
  Filters control, rather than inline beside the search box.
- **FR-002**: The search box MUST remain visible and prominent on the list screen at all
  times, independent of the filter panel.
- **FR-003**: The Filters control MUST display a badge indicating the number of currently
  active (non-default) facet filters, and MUST show no badge when no facet filter is
  active.
- **FR-004**: The filter panel MUST provide a Clear All action that resets every facet
  filter to its default and dismisses/updates the badge accordingly.
- **FR-005**: The filter panel MUST present as a bottom sheet on compact viewports and as
  a side sheet on expanded/desktop viewports, per Material 3 guidance.
- **FR-006**: Changing filters via the panel MUST produce the same result set, pagination,
  and counts as the current inline filters — no change to filtering semantics or the
  underlying filter state.
- **FR-007**: Filtering MUST remain a read capability available regardless of create/
  update/delete privileges.

**Product detail responsive layout (Stories 2 & 3)**

- **FR-008**: The product form MUST be constrained to a maximum content width rather than
  stretching text fields across the full width of large displays.
- **FR-009**: The product form's fields MUST lay out in a responsive column grid: one
  column on compact, two on medium/expanded, and three on the widest tier.
- **FR-010**: The responsive layout MUST apply identically in create, edit, and view
  (read-only) modes, preserving each field's existing order, label, validation, and
  enabled/disabled state.
- **FR-011**: The switches, prices, and labels sections MUST render within the same
  constrained max-width container as the fields.
- **FR-012**: The photo thumbnail and its associated actions (upload / change / remove)
  MUST render on the same row with the actions beside the thumbnail on non-compact
  viewports, reflowing to stacked on compact viewports if needed.
- **FR-013**: All existing widget keys, RBAC gating, localized strings, error banners,
  field-error messages, and the save/deactivate actions MUST be preserved unchanged.

**Cross-cutting constraints**

- **FR-014**: These changes MUST be presentation-only: no changes to API calls, domain
  entities, repositories, or the business logic in the filter and form controllers
  beyond what the new layout requires (e.g. exposing an active-filter count derived from
  existing state).
- **FR-015**: The responsive breakpoints used MUST come from the app's centralized
  breakpoint definitions (constitution §VI), extended if a wider "large" tier is needed
  for the three-column layout, rather than hardcoded per screen.
- **FR-016**: New shared behavior (the filter panel and any responsive form-grid wrapper)
  MUST be implemented as reusable components in the shared widgets layer where it could
  serve other catalog/list or form screens, consistent with the shared-widget rule
  (constitution §VI).

### Key Entities

*No new data entities.* This feature reuses the existing product-filter state (search,
show-inactive, stockable, salable, purchasable, label) and the existing product-form
state; it introduces no new persisted data.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: On the products list, the filter area shows at most two visible controls at
  rest (the search box and the Filters control), down from the current five-plus inline
  controls.
- **SC-002**: A user can tell at a glance whether filters are active without opening the
  panel, via the count badge, in 100% of filtered states.
- **SC-003**: Every facet filter reachable today remains reachable through the new panel,
  with no loss of filtering capability and identical result sets for equivalent selections.
- **SC-004**: On a wide (≥1200px) display, the product form presents fields in three
  columns within a bounded width, eliminating full-width single-column field stretching.
- **SC-005**: The form reflows correctly across compact, medium/expanded, and wide tiers
  with no horizontal scrolling and no overlapping or clipped fields/labels/errors.
- **SC-006**: All existing product create/view/edit/deactivate flows and photo
  upload/replace/remove flows continue to pass their existing tests unchanged (zero
  behavior regressions).

## Assumptions

- **Show-inactive moves into the panel**: To maximize decluttering and keep one
  consistent filter surface, the "Show inactive" filter is placed inside the filter panel
  alongside the other facets rather than kept as an inline quick-toggle. (The user
  explicitly delegated this decision.)
- **Active-filter count definition**: The badge counts each facet set to a non-default
  value; the label filter counts as one when a label is selected. Search text is not
  counted as a filter (it has its own visible box).
- **Responsive tiers**: Column counts map to Material 3 window size classes — compact
  (<600px) → 1 column, medium/expanded (600–1200px) → 2 columns, large/extra-large
  (≥1200px) → 3 columns. The centralized breakpoints (currently compact/medium/expanded)
  will be extended with a "large" threshold (~1200px) to support the three-column tier.
- **Max content width**: The form is capped at a comfortable reading width (a fixed
  max-width container) centered on the page; the exact value is a design detail resolved
  in planning.
- **Side sheet vs bottom sheet threshold** reuses the existing expanded breakpoint (840px)
  as the switch point between bottom sheet (below) and side sheet (at/above).
- **No API or contract changes**: mbe-api endpoints, generated DTOs, and domain entities
  are untouched; this is a pure client-side presentation refactor of two existing screens
  and their shared widgets.
- **Scope is the product catalog screens only**: other catalog/list screens are not
  modified in this feature, though new shared components are built to be reusable by them
  later.
