# Implementation Plan: Product Catalog (Products CRUD)

**Branch**: `main` (no feature branch in use) | **Date**: 2026-06-16 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/002-product-catalog/spec.md`

## Summary

Build a `/products` catalog screen (search/filter list + create/edit/
deactivate detail form) consuming mbe-api's already-published `products`
endpoints. `ProductRepository` wraps the generated `products_api.dart`
client, mapping `ProductCreate`/`ProductUpdate`/`ProductResponse`/
`ProductListItem` DTOs to `freezed` domain entities under
`lib/features/catalog/domain/`. A `ProductsListController` (`Notifier`)
holds search/filter state and drives paginated (`skip`/`limit`) fetches; a
`ProductFormController` (`Notifier`) holds create/edit form state with
client-side validation mirroring mbe-api's Pydantic constraints (code,
name, barcode). All routes and mutating actions are gated through the
existing `accessControlProvider.can(SystemObject.products, ...)`
established by the auth feature — this feature is a consumer of that
contract, not a new RBAC integration point. "Delete" is implemented purely
as a soft-delete (`PUT .../{id}` with `deactivated: true`); the API's hard
`DELETE` endpoint is intentionally not wired to any UI action.

## Technical Context

**Language/Version**: Dart `^3.10.3` (per `pubspec.yaml`), Flutter stable
channel matching that SDK constraint — same as specs/001-user-authentication.

**Primary Dependencies**: `flutter_riverpod` + `riverpod_annotation` /
`riverpod_generator`, `go_router`, `dio`, `freezed` / `freezed_annotation` +
`json_serializable`, `intl` (currency/decimal formatting for `taxRate`/
prices). No new dependency is introduced by this feature — all required
packages are already in `pubspec.yaml` from the auth feature.

**Storage**: N/A — no local database/cache (constitution §VII). Nothing in
this feature is persisted beyond the in-memory list/filter state.

**Testing**: `flutter_test` for unit/widget tests, `mocktail` for
`ProductRepository` fakes, `integration_test` for the
search → create → edit → deactivate golden path (run against a local
mbe-api instance per quickstart.md).

**Target Platform**: Web, Windows, macOS, Linux — Expanded (desktop/web)
layout tier, same as specs/001-user-authentication.

**Project Type**: Single Flutter project, feature-first
(`lib/features/catalog`), per constitution §I's "shared `master_data`/
`catalog` module for entities used across features" (research.md §4).

**Performance Goals**: Search results for a known code/partial name appear
within 10s of typing (SC-001); list pagination (`skip`/`limit`, max 100
per page) keeps any single fetch bounded regardless of catalog size
(research.md §5).

**Constraints**: Deny-by-default RBAC via `SystemObject.products` (already
defined, value `0`) — enforced client-side only today since mbe-api's core
`products` CRUD endpoints are not yet server-side privilege-gated
(research.md §1 gap; tracked as an mbe-api follow-up, not blocking this
plan). Soft delete only — no hard-delete UI action (research.md §2).

**Scale/Scope**: 3 screens (products list, product create form, product
detail/edit form) reusing the shared `DataTableView` widget
(`lib/core/widgets/data_table_view.dart`) and the shared error-display
widget from `lib/core/widgets/`, plus a `ProductRepository` + two
controllers (`ProductsListController`, `ProductFormController`).

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|---|---|---|
| I. Feature-First Layered Architecture | ✅ PASS | `lib/features/catalog/{data,domain,presentation}`. `Product`/`ProductPrice`/`ProductListItem` live in `features/catalog/domain/` (not `core/`) — research.md §4 explains why `catalog`, not a `core` shared kernel placement like `User`: nothing in `core/` needs `Product` directly, only `SystemObject.products` (already present) is consumed by `core/access`. |
| II. Riverpod for State & DI | ✅ PASS | `ProductsListController`/`ProductFormController` as plain `Notifier`s for local list/filter and form state; `productRepositoryProvider` exposes the repository for test overrides. |
| III. Contract-Driven API Integration | ✅ PASS | Consumes the already-generated `products_api.dart` (`dart-dio`, codegen'd from mbe-api's live `/openapi.json` — contracts/mbe-api-products.md). No hand-written DTOs. Errors mapped to the existing shared `ValidationError`/`NotFoundError`/`ServerError`/`NetworkError` types from the auth feature's `core/errors/app_error.dart`. |
| IV. Deny-by-Default RBAC | ✅ PASS | Reuses `accessControlProvider.can(SystemObject.products, ...)` (no new RBAC plumbing); routes and Create/Update/Delete actions all gated per contracts/routes.md. |
| V. Material 3 White-Labeled Design System | ✅ PASS | No new theming; reuses the existing `ColorScheme.fromSeed` theme and Light/Dark/System toggle. |
| VI. Desktop/Web-First, Compact-Ready Layout | ✅ PASS | Products list uses the existing `DataTableView` (constitution §VI, already shared); product detail is a multi-column form consistent with the Expanded tier established by the auth feature's Users admin screens. |
| VII. Online-Only, Server-Rendered Documents | ✅ PASS | No local persistence; no PDF/document generation in this feature. |

No violations — Complexity Tracking table not required.

## Project Structure

### Documentation (this feature)

```text
specs/002-product-catalog/
├── plan.md               # This file
├── research.md           # Phase 0 output
├── data-model.md          # Phase 1 output
├── quickstart.md          # Phase 1 output
├── contracts/             # Phase 1 output
│   ├── mbe-api-products.md
│   └── routes.md
└── tasks.md               # Phase 2 output (/speckit-tasks - not created here)
```

### Source Code (repository root)

```text
lib/
├── app/
│   └── router/
│       └── app_router.dart      # MODIFIED: add /products routes + routeSystemObject entries (contracts/routes.md)
├── core/
│   └── access/
│       └── system_object.dart   # UNCHANGED: products(0) already present
└── features/
    └── catalog/
        ├── data/
        │   └── product_repository_impl.dart  # wraps generated ProductsApi
        ├── domain/
        │   ├── entities/
        │   │   ├── product.dart              # freezed: Product (data-model.md)
        │   │   ├── product_price.dart        # freezed: ProductPrice (read-only)
        │   │   └── product_list_item.dart    # freezed: ProductListItem
        │   └── repositories/
        │       └── product_repository.dart   # interface
        └── presentation/
            ├── products_list_screen.dart
            ├── products_list_controller.dart  # Notifier: search/filter/pagination state
            ├── product_detail_screen.dart     # create + view/edit modes
            └── product_form_controller.dart   # Notifier: form state + client-side validation

generated/
└── openapi/                     # UNCHANGED (re-confirm currency per research.md §3); ProductsApi/ProductResponse/etc. already present

test/
├── unit/
│   └── features/catalog/        # domain mapping + repository tests (mocktail)
├── widget/
│   └── features/catalog/        # products list, create/edit form screens
└── integration/
    └── product_catalog_flow_test.dart  # search → create → edit → deactivate
```

**Structure Decision**: Single Flutter project, feature-first layout per
constitution §I, placed under `lib/features/catalog/` rather than
`lib/features/products/` (research.md §4 — `catalog` is the constitution's
named home for cross-feature master data). This feature only adds to
`app_router.dart`'s route table; it does not touch `core/network`,
`core/errors`, `core/storage`, or `core/access`, all of which it reuses
unmodified from the auth feature. No new third-party dependency, no
backend or mobile-specific structure change.

## Complexity Tracking

*No constitution violations — this section is intentionally empty.*
