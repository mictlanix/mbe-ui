# Implementation Plan: Catalog Screen Consistency

**Branch**: `003-catalog-consistency` | **Date**: 2026-06-20 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/003-catalog-consistency/spec.md`

## Summary

Bring the Users catalog up to parity with Products (search + pagination)
and make both catalogs share one consistent shell: a fixed Create/View/
Edit/Delete icon set in a fixed left-to-right order, a real page-based
pagination control (replacing Products' "load more" button), a single-row
filter bar at tablet-landscape+ widths with explicit submit-on-Enter/button
search, and a frozen identity column (product code / username) when
scrolling horizontally. The shared `core/widgets/data_table_view.dart`
component is rewritten on top of `data_table_2`'s `DataTable2`/
`PaginatedDataTable2`, which natively supports fixed left columns and
horizontal-overflow ellipsis — this keeps the "implement once in
`core/widgets/`" rule (constitution §VI) intact rather than hand-rolling
column-freezing and pagination per screen. `UserRepository.list()` is
extended to pass `search`/`skip`/`limit` through to mbe-api's
already-search/paginate-capable `GET /api/v1/users` (no backend change
needed). New shared widgets — `CatalogActionIcons` (the fixed icon/order
table), `CatalogSearchBar` (submit-on-Enter/button), and
`CatalogFilterBar` (single-row-at-Expanded-tier layout) — live in
`core/widgets/` so future catalogs inherit them by construction.

## Technical Context

**Language/Version**: Dart `^3.10.3`, Flutter stable — unchanged from
specs/001 and specs/002.

**Primary Dependencies**: Adds `data_table_2` (pub.dev) as the new backing
implementation for the shared `DataTableView`/pagination/frozen-column
behavior (constitution §VI's table/pagination requirements have no
first-party Flutter equivalent with column-freezing support). All other
dependencies (`flutter_riverpod`, `go_router`, `dio`, `freezed`, `intl`)
are already present and unchanged.

**Storage**: N/A — no local persistence (constitution §VII).

**Testing**: `flutter_test` for unit/widget tests (the rewritten
`DataTableView`, `CatalogSearchBar`, `CatalogFilterBar`,
`CatalogActionIcons`, and both list screens), `mocktail` for repository
fakes, `integration_test` for a search → paginate → view → edit → delete
golden path on both catalogs.

**Target Platform**: Web, Windows, macOS, Linux — Expanded (desktop/web)
layout tier, same as specs/001 and specs/002. The single-row filter
requirement (FR-009) is exercised at the Medium/Expanded breakpoint
boundary (`LayoutBreakpoints.expanded` = 840px, `core/layout/
breakpoints.dart`).

**Project Type**: Single Flutter project, feature-first; this feature
touches the shared `core/widgets/` layer plus the existing `auth` (Users)
and `catalog` (Products) feature modules — no new feature module.

**Performance Goals**: Search results apply only on explicit submit
(Enter/button), never per-keystroke (FR-010); a user can locate a specific
user account by search in under 10 seconds regardless of total user count
(SC-001).

**Constraints**: Must not change `SystemObject`/RBAC semantics (constitution
§IV) — action visibility per row continues to come from
`AccessControlService.can(...)`, this feature only standardizes *which*
icon/order is shown once an action is already permitted. Must not reorder
or duplicate icons already used elsewhere (FR-005).

**Scale/Scope**: 2 existing screens modified (`UsersListScreen`,
`ProductsListScreen`), 1 shared widget rewritten
(`core/widgets/data_table_view.dart`), 3 new shared widgets added to
`core/widgets/`, `UserRepository`/`UserRepositoryImpl`/`UsersController`
extended for search+pagination, both detail screens (`UserDetailScreen`,
`ProductDetailScreen`) extended to support an explicit read-only "View"
entry point distinct from Edit.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|---|---|---|
| I. Feature-First Layered Architecture | ✅ PASS | Changes stay within existing `auth`/`catalog` feature boundaries plus the shared `core/widgets/` layer; no new feature module, no cross-feature entity leakage. |
| II. Riverpod for State & DI | ✅ PASS | `UsersController` gains filter/pagination state via a new `UserFilterController` `Notifier`, mirroring `ProductFilterController`'s existing pattern 1:1. No new DI mechanism. |
| III. Contract-Driven API Integration | ✅ PASS | `UserRepositoryImpl.list()` only adds pass-through params (`search`, `skip`, `limit`) already present on the generated `UsersApi.listUsersApiV1UsersGet` client — no codegen re-run needed, no hand-written DTOs. |
| IV. Deny-by-Default RBAC | ✅ PASS | Row actions continue to be gated by `AccessControlService.can(object, right)`; this feature only fixes the icon/order/position once an action is already shown — an action a user lacks privilege for is still omitted, not disabled (FR-012). |
| V. Material 3 White-Labeled Design System | ✅ PASS | `data_table_2` is themed via the existing Material 3 `ColorScheme.fromSeed`; no Cupertino branches, no hardcoded brand colors. |
| VI. Desktop/Web-First, Compact-Ready Layout | ✅ PASS (this feature exists to close prior gaps) | Implements the shared table/pagination/filter/action-icon/frozen-column/truncation rules in `core/widgets/` exactly as Principle VI mandates, rather than per-screen. |
| VII. Online-Only, Server-Rendered Documents | ✅ PASS | No document/PDF generation involved. |

No violations — Complexity Tracking table not required. Adding
`data_table_2` is a net-new third-party dependency, but it is adopted in
service of an existing constitution requirement (shared table behavior,
pagination, frozen columns) that no first-party widget satisfies, not as
an unjustified addition.

## Project Structure

### Documentation (this feature)

```text
specs/003-catalog-consistency/
├── plan.md               # This file
├── research.md           # Phase 0 output
├── data-model.md         # Phase 1 output
├── quickstart.md         # Phase 1 output
├── contracts/            # Phase 1 output
│   ├── catalog-action-icons.md
│   └── mbe-api-users-list.md
└── tasks.md               # Phase 2 output (/speckit-tasks - not created here)
```

### Source Code (repository root)

```text
lib/
├── core/
│   └── widgets/
│       ├── data_table_view.dart        # REWRITTEN: backed by data_table_2's
│       │                                 DataTable2, supports fixedLeftColumns
│       │                                 (FR-007/FR-008) and ellipsis overflow
│       │                                 (constitution §VI truncation rule)
│       ├── catalog_pagination.dart     # NEW: page-based pagination control
│       │                                 (FR-002), replacing Products' ad hoc
│       │                                 "load more" button
│       ├── catalog_search_bar.dart     # NEW: search field that only fires on
│       │                                 Enter/submit button (FR-010)
│       ├── catalog_filter_bar.dart     # NEW: lays out search + facet filters
│       │                                 on one row at Expanded/Medium width,
│       │                                 wraps below it (FR-009)
│       └── catalog_action_icons.dart   # NEW: single source of truth for the
│       │                                 Create/View/Edit/Delete icon set and
│       │                                 left-to-right order (FR-004, FR-005)
│       └── data_table_view_test.dart   # (test/widget, see below) updated for
│                                         data_table_2-backed behavior
├── features/
│   ├── auth/
│   │   ├── domain/repositories/user_repository.dart      # MODIFIED: list()
│   │   │                                                    gains search/skip/limit
│   │   ├── data/user_repository_impl.dart                # MODIFIED: passes
│   │   │                                                    search/skip/limit to
│   │   │                                                    UsersApi (already supports them)
│   │   └── presentation/admin/
│   │       ├── users_controller.dart      # MODIFIED: UserFilterController
│   │       │                                (mirrors ProductFilterController) +
│   │       │                                paginated UsersController
│   │       ├── users_list_screen.dart     # MODIFIED: CatalogFilterBar,
│   │       │                                CatalogPagination, frozen username
│   │       │                                column, CatalogActionIcons row actions
│   │       └── user_detail_screen.dart    # MODIFIED: explicit `readOnly` route
│   │                                        param so View and Edit reach the
│   │                                        same screen with different intents
│   └── catalog/
│       └── presentation/
│           ├── products_list_controller.dart  # MODIFIED: replace _skip/loadMore
│           │                                    incremental loading with page-based
│           │                                    state consumed by CatalogPagination
│           ├── products_list_screen.dart       # MODIFIED: CatalogSearchBar (submit-
│           │                                    on-Enter/button) + CatalogFilterBar
│           │                                    single-row layout, frozen code
│           │                                    column, CatalogActionIcons row actions
│           └── product_detail_screen.dart      # MODIFIED: explicit `readOnly` route
│                                                  param (View vs. Edit), same pattern
│                                                  as user_detail_screen.dart
└── app/router/app_router.dart    # MODIFIED: /users/:userId and
                                    /products/:productId routes accept a
                                    `view` query param to enter read-only mode

test/
├── unit/features/{auth,catalog}/    # filter/pagination controller tests
├── widget/
│   ├── core/widgets/                # NEW: catalog_pagination, catalog_search_bar,
│   │                                   catalog_filter_bar, catalog_action_icons,
│   │                                   rewritten data_table_view
│   └── features/{auth,catalog}/     # updated list-screen widget tests
└── integration/
    └── catalog_consistency_flow_test.dart   # search → paginate → view → edit →
                                                delete, run on both catalogs
```

**Structure Decision**: No new feature module. All new shared behavior
lands in `lib/core/widgets/` per constitution §VI ("implemented once...not
re-implemented per screen"); `auth` and `catalog` feature modules are
modified to consume those shared widgets, matching how `ProductFilterController`
already exists as the template `UserFilterController` mirrors. The single
cross-cutting backend-adjacent change is `UserRepositoryImpl.list()` gaining
pass-through parameters already exposed by the generated `UsersApi` client
— no `core/network`, `core/errors`, or `core/access` changes.

## Complexity Tracking

*No constitution violations — this section is intentionally empty.*
