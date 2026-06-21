# Research: Catalog Screen Consistency

## 1. Table/pagination/frozen-column widget choice

**Decision**: Adopt `data_table_2` (pub.dev) to back the rewritten
`core/widgets/data_table_view.dart` as **one widget with one frozen-column
code path**: `DataTableView<T>` takes an optional `pagination: CatalogPage<T>?`
parameter (see research §2). When `pagination` is `null`, it renders
`DataTable2` (kept for any future small/bounded catalog). When
`pagination` is supplied — the case for both Users and Products, the only
two catalogs in scope — it renders `PaginatedDataTable2` internally,
driven by that same state. `fixedLeftColumns` (frozen-column support,
FR-007/FR-008) is wired once, in `DataTableView`, and applies identically
in both branches — there is no second, competing table-rendering widget a
caller could end up using instead.

**Rationale**: Flutter's first-party `DataTable`/`PaginatedDataTable` (the
current basis for `DataTableView`) has no column-pinning support, so
freezing the identity column (FR-007/FR-008) would require hand-rolling a
synchronized dual-scroll-view layout per screen — exactly the
per-screen-reimplementation constitution §VI forbids. `data_table_2`
exposes `fixedLeftColumns` directly on `DataTable2`/`PaginatedDataTable2`
and ships ellipsis/overflow handling for fixed-width columns, covering both
FR-007 and the existing horizontal-scroll/ellipsis rule in one widget.
Branching *inside* `DataTableView` (rather than having pagination be a
separate wrapper widget around it) guarantees the frozen-column behavior
this feature is also delivering can never be implemented against one
branch and silently skipped for the other, since both catalogs that exist
today always supply `pagination`.

**Alternatives considered**:
- *Hand-rolled pinned-column layout* (two `ListView`s scrolled in sync):
  rejected — duplicates logic `data_table_2` already provides, more
  surface area to keep "identical visual behavior" (constitution §VI)
  across catalogs.
- *`SfDataGrid` (Syncfusion)*: rejected — commercial license required for
  some use cases; `data_table_2` is BSD-licensed and purpose-built as a
  drop-in `DataTable`/`PaginatedDataTable` replacement, minimizing the
  diff against the existing `DataTableView` API surface.
- *A separate `CatalogPagination` widget that itself renders
  `PaginatedDataTable2`, used instead of `DataTableView` for paginated
  catalogs*: rejected during `/speckit-analyze` — this would have created
  two table-rendering code paths (`DataTableView` for `DataTable2`,
  `CatalogPagination` for `PaginatedDataTable2`) with frozen-column support
  only guaranteed to exist on one of them, contradicting constitution
  §VI's "implemented once" rule for the exact feature this spec is
  delivering. `CatalogPagination` is instead just the `CatalogPage<T>` data
  shape (research §2), not a render widget.

## 2. Pagination model: page-based vs. "load more"

**Decision**: Replace Products' incremental `loadMore()` with page-based
pagination (`skip = pageIndex * pageSize`). The shared state shape is a
single generic `CatalogPage<T>` (`items`, `total`, `pageIndex`, `pageSize`)
defined in `core/widgets/catalog_pagination.dart` — not a render widget,
just the data contract `DataTableView` accepts via its `pagination`
parameter (research §1) and that `UsersController`'s and
`ProductsListController`'s list state are both instances of.
`DataTableView` itself renders the page-navigation UI
via `data_table_2`'s built-in `PaginatedDataTable2` footer when given a
`CatalogPage<T>`.

**Rationale**: The constitution's pagination rule (§VI) calls for "the
shared pagination component from `core/widgets/`" — a single component
both catalogs use identically. "Load more" is a valid pagination strategy
in principle, but `PaginatedDataTable2` (already adopted per research §1)
ships page-based pagination out of the box; reusing it directly satisfies
"implemented once" with less code than building a custom "load more"
footer on top of it. mbe-api's `GET /api/v1/users` and
`GET /api/v1/products` both already accept `skip`/`limit`, so no backend
change is needed either way.

**Alternatives considered**:
- *Keep "load more" for Products, add it to Users*: rejected — would
  fight `data_table_2`'s native page-based footer instead of using it,
  reintroducing a bespoke widget the constitution says to avoid.

## 3. Explicit-submit search (no per-keystroke filtering)

**Decision**: New shared `CatalogSearchBar` widget exposes an
`onSubmitted` callback wired to a `TextField`'s `onSubmitted` (Enter key)
and a trailing search `IconButton`; it does not expose `onChanged` to
callers, so a catalog screen has no way to accidentally wire per-keystroke
filtering.

**Rationale**: FR-010 requires search to apply only on explicit submission.
Products' current `TextField.onChanged: filterController.searchChanged`
re-fetches on every keystroke today — this is one of the "existing
catalogs whose current behavior conflicts" call-outs in FR-011. Making the
shared widget's API surface physically unable to express per-keystroke
filtering (no exposed `onChanged`) prevents the regression from
recurring in a third future catalog.

**Alternatives considered**:
- *Debounce the existing `onChanged` (e.g. 400ms)*: rejected — still
  issues a request without explicit user intent, and FR-010 explicitly
  asks for the button/Enter trigger, not "less frequent but still
  automatic" filtering.

## 4. Single-row filter layout

**Decision**: New shared `CatalogFilterBar` widget uses a `LayoutBuilder`
keyed to the existing `LayoutBreakpoints.expanded` (840px) constant from
`core/layout/breakpoints.dart`: at or above that width, search box and
facet filter chips render in one `Row`; below it, they render in the
existing `Wrap` (current Products behavior), allowing reflow.

**Rationale**: FR-009 maps directly onto the project's existing Medium/
Expanded breakpoint boundary (constitution §VI already requires
breakpoints be centralized in `core/`) — no new breakpoint constant is
needed, just a layout that branches on the existing one.

**Alternatives considered**: A bespoke "tablet-landscape" breakpoint
distinct from `LayoutBreakpoints.expanded`: rejected as an unnecessary
second source of truth for screen-size tiers.

## 5. View vs. Edit as distinct entry points

**Decision**: `UserDetailScreen`/`ProductDetailScreen` accept an explicit
`readOnly` flag (surfaced as a `?view=true` query parameter on the
existing `/users/:userId` and `/products/:productId` routes) that forces
read-only rendering regardless of the user's edit permission; the existing
permission-derived `readOnly = _isEdit && !canUpdate` check
(`product_detail_screen.dart:65`) becomes `readOnly = (_isEdit &&
!canUpdate) || forcedReadOnly`.

**Rationale**: FR-006 requires View to open "the same form/screen used for
Edit, rendered read-only" as a *user-chosen* action, not just the
already-existing fallback for users who lack edit rights. A query param
keeps both intents on one route/screen (no new screen file, no
duplicated form-building code) and composes with the existing permission
check rather than replacing it.

**Alternatives considered**:
- *Separate `/users/:userId/view` route to a new view-only widget*:
  rejected — duplicates the form layout that already exists, against the
  "no separate view-only screen needs to be designed" assumption in
  spec.md and the project's general anti-duplication stance.

## 6. Fixed action icon set and order

**Decision**: New `core/widgets/catalog_action_icons.dart` exports a
single `CatalogAction` enum (`create`, `view`, `edit`, `delete`) each
mapping to one fixed `IconData` and a helper that renders the row's
trailing actions in `[view, edit, delete]` order (toolbar `create` is
separate, as today). Both `UsersListScreen` and `ProductsListScreen`
import this instead of building `IconButton`s ad hoc.

**Rationale**: FR-004/FR-005 require one fixed icon and one fixed order
app-wide; a shared enum/builder is the only way to make "every future
catalog inherits this by construction" (spec.md Assumptions) actually
true, versus a convention developers could drift from.

**Icon choices** (chosen to avoid clashing with any icon already used for
a different action elsewhere in the app — confirmed via repo-wide grep for
existing `Icons.` usage in `presentation/` directories):
- Create: `Icons.add` (toolbar)
- View: `Icons.visibility_outlined`
- Edit: `Icons.edit_outlined`
- Delete: `Icons.delete_outline`

**Alternatives considered**: Reusing Products' existing toolbar
`Icons.add_box` / Users' `Icons.person_add` for Create: rejected — FR-005
requires *one* icon for Create across all catalogs, and a generic
`Icons.add` generalizes better to entities with no obvious
"add a person/box" metaphor than either entity-specific icon does.
