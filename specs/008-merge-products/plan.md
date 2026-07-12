# Implementation Plan: Merge Products

**Branch**: `008-merge-products` | **Date**: 2026-07-12 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/008-merge-products/spec.md`

## Summary

Surface mbe-api's already-implemented product-merge capability as a dedicated Flutter screen. An authorized user opens a **Merge Products** screen, picks a canonical **Product** (kept) and a **Duplicate** (folded in and permanently deleted) via two search-as-you-type pickers, confirms an explicit permanence warning, and submits. The backend remaps the duplicate's transactional references and labels onto the canonical product, deletes the duplicate's price/label rows, and hard-deletes the duplicate. On success the user is confirmed and returned to the products list; on failure the error is surfaced and both selections are preserved.

Technical approach: everything lands in the existing `features/catalog` layer plus one shared-widget extension and the router. The generated `mbe_api_client` already exposes `ProductsApi.mergeProductsApiV1ProductsMergePost` and the `ProductMergeRequest` DTO, so **no OpenAPI regeneration is required for the merge action itself** (constitution §III / Development Workflow). The product search that backs both pickers reuses the existing `ProductRepository.list(search:, …)` path — mbe-api's list search already matches `code|name|model|sku|brand` via `ilike`, and passing `deactivated: null` searches products in any state, matching the legacy merge-suggestion behavior. New surface: a `mergeProducts()` method on `ProductRepository`/impl, a `MergeProductsScreen` + `MergeProductsController` (Riverpod `Notifier`), a `/products/merge` route with an RBAC gate on `SystemObject.productsMerge`, an entry point on the products list, an optional photo-in-suggestion extension to the shared `CatalogEntityPicker`, and new `.arb` keys.

**Cross-repo dependency**: FR-003 requires SKU in suggestion rows, but `ProductListItem` (the products-list projection both pickers reuse) doesn't carry `sku`. Per this project's repo boundary — mbe-ui does not modify mbe-api directly — this was filed as [mictlanix/mbe-api#76](https://github.com/mictlanix/mbe-api/issues/76) rather than patched here. This feature ships its MVP (US1–US4) with suggestion rows showing photo/name/code/model; SKU display is a follow-up once #76 lands and mbe-ui regenerates its client (research §3).

## Technical Context

**Language/Version**: Dart 3 / Flutter (stable channel)

**Primary Dependencies**: `flutter_riverpod` (state/DI), `go_router` (routing), `dio` + generated `mbe_api_client` (OpenAPI dio client), `freezed` (immutable entities), `intl` + `flutter_localizations` (es-MX default / en), Material 3. No new pub dependencies.

**Storage**: N/A — online-only (constitution §VII); no local persistence.

**Testing**: `flutter_test` widget tests for `MergeProductsScreen` (picker selection, self-merge/empty guards, confirm dialog, success→pop, error→banner+preserved selections) and the extended `CatalogEntityPicker`; unit tests for `MergeProductsController` and `ProductRepositoryImpl.mergeProducts` with the API client mocked; an `integration_test` golden-path merge against a test mbe-api.

**Target Platform**: Web + desktop (Expanded tier first per constitution §VI), compact-ready.

**Project Type**: Single Flutter application, feature-first layered (`lib/features/*`, shared `lib/core/*`).

**Performance Goals**: 60 fps interaction; picker searches debounced (300 ms, reusing `CatalogEntityPicker`'s existing debounce) with a min query length; one merge round-trip per confirmed action.

**Constraints**: Material 3 only (§V); deny-by-default RBAC on the screen, its entry point, and the submit action (§IV); generated DTOs only, no hand-written schemas (§III); no hardcoded strings (§V); no edge-to-edge single fields on wide displays (§VI).

**Scale/Scope**: 1 new screen + 1 controller + 1 repository method + 1 shared-widget extension + 1 route + 1 list entry point + `.arb` keys. 14 functional requirements, 4 user stories.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Feature-First Layered Architecture | ✅ Pass | `mergeProducts()` added to the `domain` `ProductRepository` interface, implemented in `data`; screen/controller live in `presentation`. Presentation depends only on domain (via `productRepositoryProvider`). No cross-layer leak. |
| II. Riverpod state/DI | ✅ Pass | New `MergeProductsController` is a plain `Notifier<MergeProductsState>` (local UI state: two selections + a submit `AsyncValue`), exposed via a provider; reuses `productRepositoryProvider` and `accessControlProvider`. No new DI mechanism. |
| III. Contract-Driven API | ✅ Pass (1 external dependency) | Uses the already-generated `mergeProductsApiV1ProductsMergePost` + `ProductMergeRequest`; product search reuses the generated `listProductsApiV1ProductsGet`. No regeneration needed for the merge action itself; no hand-written DTOs (SKU-in-suggestion is deferred to a tracked upstream issue rather than hand-patching generated code — [mictlanix/mbe-api#76](https://github.com/mictlanix/mbe-api/issues/76)). Errors mapped through the shared `mapDioException` → `AppError` and surfaced via the shared `error_banner`. |
| IV. Deny-by-Default RBAC | ✅ Pass | The `/products/merge` route, the products-list entry point, and the submit action are all gated on `can(SystemObject.productsMerge, AccessRight.create)` — the operative privilege the mbe-api endpoint itself enforces. Denied by default (hidden entry point, redirect refuses direct navigation). See §Design note below on using Create (not Read) for this single-purpose route. |
| V. Material 3, White-Labeled, i18n | ✅ Pass | Material 3 screen; destructive confirm uses `colorScheme.error` styling like the product-delete dialog; all copy added to `app_es.arb` (default) + `app_en.arb`; no hardcoded strings. |
| VI. Desktop/Web-First, Compact-Ready Layout | ✅ Pass | Not a list/table screen, so the row-action/table clauses don't apply. The two pickers are laid out using the shared `core/widgets/responsive_form_grid.dart` component (single column, width-capped) so single fields never stretch edge-to-edge on wide displays, per §VI's mandated shared form-grid. Breakpoints come from `core/`. |
| VII. Online-Only | ✅ Pass | Merge and search go straight to mbe-api; no caching/offline. |

**Gate result**: PASS — no violations. One intentional, stricter-than-default choice (route gated on Create rather than the conventional Read) is documented below and in `contracts/routes.md`; it tightens access rather than loosening it, so it is not a deviation requiring Complexity Tracking.

**Design note — route right (§IV).** The constitution's convention is `can(object, Read)` to gate route access. The merge screen has no read-only purpose: its sole function is the Create-gated merge action, and mbe-api enforces `require_privilege(PRODUCTS_MERGE, CREATE)`. Gating the route (and entry point and submit) on `AccessRight.create` keeps the client check aligned with the server and avoids exposing a screen a user could never successfully use. This is applied only to `/products/merge`.

## Project Structure

### Documentation (this feature)

```text
specs/008-merge-products/
├── plan.md              # This file
├── research.md          # Phase 0 — decisions (search source, picker photo, route right, SKU-in-suggestion)
├── data-model.md        # Phase 1 — MergeProductsState, ProductSuggestion, request mapping
├── quickstart.md        # Phase 1 — manual validation walkthrough per user story
├── contracts/
│   ├── product-repository.md   # mergeProducts() method contract + error mapping
│   ├── ui-contracts.md         # MergeProductsScreen + CatalogEntityPicker extension behavior
│   └── routes.md               # /products/merge route + RBAC gate
├── checklists/
│   └── requirements.md  # From /speckit-specify (present)
└── tasks.md             # /speckit-tasks output — NOT created here
```

### Source Code (repository root)

```text
lib/
├── core/
│   └── widgets/
│       └── catalog_entity_picker.dart      # extend: optional photo/subtitle option rendering (US2 / FR-003)
├── features/
│   └── catalog/
│       ├── domain/
│       │   └── repositories/product_repository.dart   # + mergeProducts({productId, duplicateId})
│       ├── data/
│       │   └── product_repository_impl.dart           # implement mergeProducts via generated client
│       └── presentation/
│           ├── merge_products_screen.dart             # NEW — two pickers, confirm, submit, back
│           ├── merge_products_controller.dart         # NEW — Notifier<MergeProductsState> + provider
│           └── products_list_screen.dart              # + Merge entry point gated by productsMerge/create
├── app/router/app_router.dart              # + /products/merge route; gate before generic /products
└── l10n/{app_es.arb, app_en.arb}           # new keys: title, labels, merge/confirm/back, errors

test/                                       # widget/unit/integration for the above
```

**Structure Decision**: Single Flutter project, feature-first layered per constitution §I. The only genuinely new files are the screen, its controller, and their tests; everything else is an additive method/param on existing files. Shared behavior (the photo-in-suggestion picker) is added once in `core/widgets/` so future pickers inherit it, per §VI.

## Complexity Tracking

| Item | Why Needed | Simpler Alternative Rejected Because |
|------|------------|---------------------------------------|
| **SKU-in-suggestion-row deferred** (FR-003 partial) — suggestion rows ship with photo/name/code/model; SKU display waits on [mictlanix/mbe-api#76](https://github.com/mictlanix/mbe-api/issues/76). | `ProductListItem` (the reused products-list projection) has no `sku` field; adding it requires an mbe-api schema change mbe-ui cannot make itself (repo boundary — mbe-ui does not edit sibling repos). | Hand-patching the generated Dart model to add `sku` was rejected: constitution §III forbids hand-edited generated files, and the field would be silently missing again on the next real regen. Filing the upstream issue and treating SKU-in-row as a tracked follow-up is the honest path — it doesn't block MVP delivery (US1–US4 all work with photo/name/code/model) and doesn't fake a field the API doesn't return. |

The route-gated-on-Create choice (§IV design note) is a separate, non-violating tightening and remains recorded only in the Constitution Check and `contracts/routes.md`.

## Phase 0 — Research

See [research.md](./research.md). All Technical Context items are resolved; no `NEEDS CLARIFICATION` remain. Key decisions: reuse `ProductRepository.list` (with `deactivated: null`) as the picker search source; extend `CatalogEntityPicker` with optional photo/subtitle option rendering rather than forking a new widget; gate the merge route on Create; and ship suggestion rows with name/code/model (SKU deferred to [mictlanix/mbe-api#76](https://github.com/mictlanix/mbe-api/issues/76) — the list projection has no `sku` field yet, though SKU remains searchable server-side today).

## Phase 1 — Design & Contracts

- [data-model.md](./data-model.md) — `MergeProductsState` (canonical/duplicate selections + submit `AsyncValue`), the `ProductSuggestion` view used by the pickers (reusing `ProductListItem`), and the `ProductMergeRequest` mapping.
- [contracts/product-repository.md](./contracts/product-repository.md) — `mergeProducts()` signature, success/no-content handling, and error mapping (400 self-merge, 404 not found, other).
- [contracts/ui-contracts.md](./contracts/ui-contracts.md) — `MergeProductsScreen` behavior (guards, confirm, in-flight lock, success/error) and the `CatalogEntityPicker` photo-suggestion extension.
- [contracts/routes.md](./contracts/routes.md) — `/products/merge` route registration and the `productsMerge`/Create gate.
- [quickstart.md](./quickstart.md) — manual validation walkthrough per user story.
- Agent context (`CLAUDE.md`) updated to point at this plan.
