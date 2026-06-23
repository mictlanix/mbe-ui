# Implementation Plan: Product Photo Display & Upload

**Branch**: `004-product-image-upload` | **Date**: 2026-06-23 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/004-product-image-upload/spec.md`

## Summary

Extend the existing `/products` catalog (002-product-catalog) so every product's photo — already a field on `Product`/`ProductResponse` but previously read-only — can be uploaded, replaced, and removed from the product detail/edit screen, and is displayed (with a placeholder fallback) on both the list and detail screens. mbe-api already exposes the underlying endpoints (`POST /products/{id}/image` for upload, and the existing `PUT /products/{id}` for clearing the field), but the project's generated OpenAPI client cannot represent either call correctly (research.md §3: a `format: binary` multipart param gets codegen'd as a plain string, and the generated `ProductUpdate` model can never serialize an explicit `null`). `ProductRepositoryImpl` therefore adds two hand-rolled raw-`dio` calls (`uploadPhoto`, `removePhoto`) alongside its existing generated-client-backed methods. `ProductFormController` gains local, unsaved-photo-selection state so photo changes apply only on save (FR-010), matching how every other product field already behaves. All upload/replace/remove actions are gated by the existing `accessControlProvider.can(SystemObject.products, AccessRight.update)` — no new RBAC plumbing.

## Technical Context

**Language/Version**: Dart `^3.10.3` (per `pubspec.yaml`), Flutter stable channel matching that SDK constraint — same as specs/001-user-authentication and specs/002-product-catalog.

**Primary Dependencies**: `flutter_riverpod` + `riverpod_annotation`/`riverpod_generator`, `go_router`, `dio`, `freezed`/`freezed_annotation` + `json_serializable` — all already present, no change. **New**: `file_picker` (research.md §4) for cross-platform image-file selection (Web/Windows/macOS/Linux); this is the first file-upload feature in the codebase, so no existing picker dependency covers the need.

**Storage**: N/A — no local database/cache (constitution §VII). A picked-but-unsaved photo's bytes live only in `ProductFormController`'s in-memory state until save or navigation-away (research.md §5, data-model.md).

**Testing**: `flutter_test` for unit/widget tests, `mocktail` for `ProductRepository` fakes (including the two new methods), `integration_test` for the pick → save → verify-displayed golden path (quickstart.md), run against a local mbe-api instance.

**Target Platform**: Web, Windows, macOS, Linux — Expanded (desktop/web) layout tier, same as specs/001/002.

**Project Type**: Single Flutter project, feature-first (`lib/features/catalog`) — this feature only extends the existing catalog module, no new feature folder.

**Performance Goals**: A successful upload/replace/remove is reflected in both list and detail views within 30s of save (SC-001); photo loading in the paginated list MUST NOT block the list from rendering — images load incrementally per row via `Image.network`, consistent with how the list already paginates (research.md §5, constitution §VI).

**Constraints**: Client pre-validates JPEG/PNG and a 2 MB size limit (research.md §2) to fail fast, but the backend (`image_service._MAX_BYTES`, PIL format check) remains authoritative — a 422 from either upload call is treated identically to any other field-level validation error already handled by the shared `ValidationError` path. The dedicated upload endpoint is server-side privilege-gated (`require_privilege(PRODUCTS, UPDATE)`) but the plain `PUT` used for removal is not yet (research.md §1) — the same pre-existing gap as 002-product-catalog (mictlanix/mbe-api#70); this feature still gates fully client-side (FR-008) regardless.

**Scale/Scope**: No new screens. Modifies `products_list_screen.dart` (render photo per row), `product_detail_screen.dart` (photo preview + upload/replace/remove controls, gated), `product_form_controller.dart` (pending-photo state + save-time upload/remove calls), `product_repository.dart`/`product_repository_impl.dart` (two new methods), plus one new shared `core/widgets/` placeholder/photo widget reused by both screens (constitution §VI: shared visual components live once).

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|---|---|---|
| I. Feature-First Layered Architecture | ✅ PASS | No new feature folder; extends `lib/features/catalog/{data,domain,presentation}` in place, consistent with `Product` already living there (002's data-model.md). The new shared photo/placeholder widget lives in `core/widgets/`, not duplicated per screen. |
| II. Riverpod for State & DI | ✅ PASS | Pending-photo selection is local UI state on the existing `ProductFormController` (`Notifier`) — no new provider type introduced. `productRepositoryProvider` is extended, not replaced, so test overrides keep working. |
| III. Contract-Driven API Integration | ⚠️ PASS WITH NOTED EXCEPTION | Both new repository methods bypass the generated `ProductsApi` wrapper methods/models for the *call construction* only (research.md §3) because of two distinct codegen limitations (binary multipart params, explicit-null serialization) — not because of hand-written DTOs for a resource lacking a schema. Both calls still go through the shared `dio` instance and its existing interceptors (auth, error mapping), and both target endpoints that already exist in mbe-api's published OpenAPI spec. Recorded in Complexity Tracking below per Governance's compliance rule. |
| IV. Deny-by-Default RBAC | ✅ PASS | Reuses `accessControlProvider.can(SystemObject.products, AccessRight.update)` — no new `SystemObject` or privilege. Upload/replace/remove affordances are hidden, not just disabled, for accounts lacking Update (FR-008, FR-009), mirroring the existing Create/Update/Delete action-gating pattern in `product_detail_screen.dart`. |
| V. Material 3 White-Labeled Design System | ✅ PASS | No new theming; the placeholder widget uses the existing `ColorScheme`, no hardcoded colors. |
| VI. Desktop/Web-First, Compact-Ready Layout | ✅ PASS | Photo column/preview is additive to the existing `DataTableView`-based list and multi-column detail form; the shared placeholder/photo widget is added once to `core/widgets/` and reused by both screens, per constitution §VI's shared-component rule. No horizontal-scroll or truncation concerns (an image thumbnail, not text). |
| VII. Online-Only, Server-Rendered Documents | ✅ PASS | No local persistence of photo bytes beyond the in-memory unsaved-selection state, which is discarded (not cached to disk) if the user navigates away without saving. |

One noted exception under Principle III, justified above and in Complexity Tracking — does not block proceeding to Phase 0.

## Project Structure

### Documentation (this feature)

```text
specs/004-product-image-upload/
├── plan.md                              # This file
├── research.md                          # Phase 0 output
├── data-model.md                        # Phase 1 output
├── quickstart.md                        # Phase 1 output
├── contracts/
│   └── mbe-api-products-photo.md        # Phase 1 output
└── tasks.md                             # Phase 2 output (/speckit-tasks - not created here)
```

### Source Code (repository root)

```text
lib/
├── core/
│   └── widgets/
│       └── product_photo.dart           # NEW: shared photo-or-placeholder widget
│                                         #      (errorBuilder fallback, research.md §5);
│                                         #      used by both screens below
└── features/
    └── catalog/
        ├── data/
        │   └── product_repository_impl.dart   # MODIFIED: + uploadPhoto, + removePhoto
        │                                       # (raw dio calls, contracts/mbe-api-products-photo.md)
        ├── domain/
        │   └── repositories/
        │       └── product_repository.dart    # MODIFIED: + uploadPhoto, + removePhoto signatures
        └── presentation/
            ├── products_list_screen.dart       # MODIFIED: render ProductPhoto per row
            ├── product_detail_screen.dart       # MODIFIED: photo preview + pick/replace/remove
            │                                    #           controls, gated by canUpdate
            └── product_form_controller.dart     # MODIFIED: + pendingPhotoBytes,
                                                   #           pendingPhotoFilename,
                                                   #           photoMarkedForRemoval state +
                                                   #           photoPicked()/photoRemoveRequested()
                                                   #           + save-time upload/remove calls

pubspec.yaml                              # MODIFIED: + file_picker dependency

test/
├── unit/
│   └── features/catalog/                 # + uploadPhoto/removePhoto repository tests (mocktail),
│                                          #   + ProductFormController pending-photo state tests
├── widget/
│   └── features/catalog/                 # + ProductPhoto widget tests (photo / null / load-error),
│                                          #   + detail screen upload/replace/remove gating tests
└── integration/
    └── product_photo_flow_test.dart      # NEW: pick → save → verify in list + detail
```

**Structure Decision**: No new feature folder or route — this is a pure extension of 002-product-catalog's existing `lib/features/catalog/` module and its already-established `/products` routes (contracts/routes.md from 002 is unchanged; no new route, no new `SystemObject`). The only new file outside `features/catalog/` is the shared `core/widgets/product_photo.dart`, placed there per constitution §VI's rule that shared visual components used by more than one screen live once in `core/widgets/`.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|---------------------------------------|
| Two repository methods (`uploadPhoto`, `removePhoto`) bypass the generated `ProductsApi` wrapper/models, using raw `dio.post`/`dio.put` calls instead (Principle III) | The generated client cannot express either operation: a `format: binary` multipart param codegens to a plain string field (research.md §3), and the generated `ProductUpdate` model's serializer only emits a field when non-null, so it can never send an explicit `{"photo": null}` (research.md §3). Both target endpoints already exist and are part of mbe-api's published contract — this is a client codegen gap, not a missing backend contract. | *Hand-edit the generated files* — forbidden outright (constitution III, files are regenerated and overwritten). *Fix the openapi-generator template/config first* — correct long-term fix, but a template/codegen-pipeline change is a separate, cross-cutting concern affecting every feature's generated client, not something this single feature's plan should take on as a prerequisite; tracked as a follow-up. *Skip remove-photo entirely until codegen is fixed* — rejected; User Story 3 (remove) is explicitly in scope per spec.md and the workaround is small, contained, and still goes through the shared `dio` instance/interceptors, satisfying the principle's actual intent (consistent, centralized HTTP handling) even though it doesn't route through the generated wrapper for these two calls. |
