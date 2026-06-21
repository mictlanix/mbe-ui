# Data Model: Catalog Screen Consistency

This feature does not introduce new persisted domain entities — it adds
local UI/filter state and a shared widget-level vocabulary on top of the
existing `User`/`UserSummary` and `Product`/`ProductListItem` entities
already defined in specs/001 and specs/002.

## UserFilter (new local UI state)

Mirrors `ProductFilter` (specs/002/data-model.md) for the Users catalog.
Not persisted (constitution §II — local UI state uses plain `Notifier`).

| Field | Type | Default | Notes |
|---|---|---|---|
| `search` | `String` | `''` | Submitted (not in-progress) search text; only updated when `CatalogSearchBar.onSubmitted` fires (FR-010). |

No facet filters are defined for Users in this feature — `UserListItem`
exposes `administrator`/`disabled` today, but the spec's User Story 1 only
calls for search + pagination; adding facet filters for those fields is
out of scope (see spec.md Assumptions — only existing catalogs' current
gaps are in scope).

## UserListPage (new local UI state, replaces ad hoc list-only state)

| Field | Type | Notes |
|---|---|---|
| `items` | `List<UserSummary>` | Current page's rows. |
| `total` | `int` | Total matching the active `UserFilter`, from `UserListResponse.total`. |
| `pageIndex` | `int` | 0-based; drives `skip = pageIndex * pageSize`. |
| `pageSize` | `int` | Fixed at 20, matching `ProductsListController`'s `_pageSize`. |

## ProductListPage (modification of existing `ProductListResult`)

`ProductListResult` (specs/002) already holds `items`/`total`; this
feature adds `pageIndex`/`pageSize` tracking to `ProductsListController` so
its state can drive `CatalogPagination` the same way `UserListPage` does,
replacing the `_skip`/`loadMore()` incremental-fetch pattern.

## CatalogAction (new shared vocabulary, not persisted)

| Value | Icon | Position | Notes |
|---|---|---|---|
| `create` | `Icons.add` | Toolbar (not a row action) | Shown only when `can(object, AccessRight.create)`. |
| `view` | `Icons.visibility_outlined` | Row, 1st of trailing actions | Opens the same form as `edit`, forced read-only. Shown whenever `can(object, AccessRight.read)` (already implied by the row being visible). |
| `edit` | `Icons.edit_outlined` | Row, 2nd of trailing actions | Shown only when `can(object, AccessRight.update)`. |
| `delete` | `Icons.delete_outline` | Row, 3rd (last) of trailing actions | Shown only when `can(object, AccessRight.delete)` AND the record supports deletion (e.g. Products' soft-delete-only rule from specs/002 still applies — "delete" there means deactivate). |

This is a widget-layer enum (`core/widgets/catalog_action_icons.dart`), not
a domain entity — included here because FR-003/FR-004/FR-005 are
data-shape requirements on *every* catalog's row, not just visual styling.

## Identity column designation (per catalog)

| Catalog | Identity column | Source field |
|---|---|---|
| Products | Product code | `ProductListItem.code` |
| Users | Username | `UserSummary.userId` |

Declared as a `bool` (or column-index) parameter passed into the rewritten
`DataTableView`/`DataTableColumn` (`frozen: true` on exactly one column per
table) rather than inferred — avoids ambiguity if a catalog's first column
isn't its identity column.
