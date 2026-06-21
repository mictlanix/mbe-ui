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

## CatalogPage\<T\> (new shared generic state shape, not per-feature)

Defined once in `core/widgets/catalog_pagination.dart` (not a render
widget — see research.md §1/§2) and passed into `DataTableView<T>`'s
`pagination` parameter. Both catalogs' list controllers produce this same
shape rather than each defining their own near-duplicate page-state class.

| Field | Type | Notes |
|---|---|---|
| `items` | `List<T>` | Current page's rows (`UserSummary` for Users, `ProductListItem` for Products). |
| `total` | `int` | Total matching the active filter, from the API's `ListResponse.total`. |
| `pageIndex` | `int` | 0-based; drives `skip = pageIndex * pageSize`. |
| `pageSize` | `int` | Fixed at 20, matching `ProductsListController`'s existing `_pageSize`. |

`UsersController`'s state becomes `AsyncValue<CatalogPage<UserSummary>>`
(replacing today's `AsyncValue<List<UserSummary>>`).
`ProductsListController`'s state becomes `AsyncValue<CatalogPage<ProductListItem>>`,
replacing the existing `ProductListResult` (specs/002) and its
`_skip`/`loadMore()` incremental-fetch pattern with page-based navigation.

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
