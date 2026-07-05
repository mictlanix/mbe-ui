# Implementation Plan: Catalog UI Improvements Round 2

**Branch**: `007-catalog-ui-improvements-2` | **Date**: 2026-07-05 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/007-catalog-ui-improvements-2/spec.md`

## Summary

A follow-up refinement of the catalog CRUD surface after usage feedback. It (1) simplifies the shared list widgets — drop frozen columns, reduce row actions to **Edit-only**, and make a whole-row click open the detail screen **read-only** with a "View <Entity>" title and an explicit "Edit" switch button; (2) upgrades the products filter's label facet to **multi-select**; (3) completes the product form — surface the already-modelled **SKU**, keep the working **supplier** picker, drop the read-only **price-list** section and relocate the **labels** control into its place; (4) converts the product's destructive action from an app-bar soft-deactivate into a warning-styled **hard Delete** button beneath Save (per the clarified decision), wired to mbe-api's real `DELETE /products/{id}`; (5) enlarges the product **photo** 75% with a non-cropping fit; (6) reorders the products list so the **photo is the first, header-less column** and adds a **copy-code** affordance; and (7) renames the `LEGACY_PHOTOS_BASE_URL` setting to `PHOTOS_BASE_URL`.

Technical approach: almost all changes land in existing files — the shared `core/widgets/` components (`data_table_view`, `catalog_action_icons`, `product_photo`), the catalog feature's `products_list_screen` / `product_detail_screen` / `product_form_controller` / `product_repository`, the `auth` users list/detail (which inherit the shared row-action + read-only-view changes), the router, `core/network/photo_url.dart`, and the `.arb` localization files. No codegen change is required: the hard-delete endpoint and the `sku` field already exist in the generated client.

## Technical Context

**Language/Version**: Dart 3 / Flutter (stable channel)

**Primary Dependencies**: `flutter_riverpod` (state/DI), `go_router` (routing), `freezed` (immutable entities), `dio` + generated `mbe_api_client` (OpenAPI dio client), `data_table_2` (shared table), `intl` + `flutter_localizations` (es-MX/en), `file_picker` (photo pick), Material 3

**Storage**: N/A — online-only (constitution §VII); no local persistence touched

**Testing**: `flutter_test` widget tests for the shared widgets and the two screens; unit tests for `ProductFormController` / `ProductRepositoryImpl` with the API client mocked; `integration_test` golden-path flows against a test mbe-api

**Target Platform**: Web + desktop (Expanded tier first per constitution §VI), compact-ready

**Project Type**: Single Flutter application, feature-first layered (`lib/features/*`, shared `lib/core/*`)

**Performance Goals**: 60 fps interaction; no added network round-trips beyond the one `DELETE` call replacing the prior `PUT`

**Constraints**: No horizontal scroll on data tables (§VI); Material 3 only (§V); deny-by-default RBAC on every mutating action (§IV); generated DTOs only, no hand-written schemas (§III)

**Scale/Scope**: 2 primary screens (products list + product detail) + 4 shared/core files + 2 inherited auth screens (users list/detail) + router + l10n. 11 spec items → ~21 functional requirements.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Feature-First Layered Architecture | ✅ Pass | Changes stay within `features/catalog`, `features/auth` (users), and `core/widgets`+`core/network`; presentation→domain→data boundaries preserved (hard-delete added to `ProductRepository` domain interface, implemented in `data/`). |
| II. Riverpod state/DI | ✅ Pass | Reuses `productFormControllerProvider`, `productFilterControllerProvider`, `productRepositoryProvider`; multi-label filter stays a plain `Notifier`. No new DI mechanism. |
| III. Contract-Driven API | ✅ Pass (1 dependency) | Hard delete uses the already-generated `deleteProductApiV1ProductsProductIdDelete`; `sku` already exists on generated `ProductCreate`/`ProductUpdate`. **Dependency:** supplier-*clear* is not expressible against current mbe-api (see Complexity Tracking / research §5). No hand-written DTOs. |
| IV. Deny-by-Default RBAC | ✅ Pass | Delete button gated by `can(products, delete)`; Edit row action + edit-switch button gated by `can(products, update)`; read-only view is the safe default. |
| V. Material 3, White-Labeled, i18n | ✅ Pass | Warning Delete button uses `colorScheme.error`; all new copy added to `app_es.arb` (default) + `app_en.arb`; no hardcoded strings. |
| VI. Desktop/Web-First, Compact-Ready Layout | ⚠️ Deviation | FR-002/FR-003 **redefine** the §VI-mandated row-action set (Create/View/Edit/Delete, fixed order) to **Edit-only + whole-row-click→read-only View**, and relocate catalog Delete into the detail form. This is a material change to §VI (lines 155–163) → **constitution amendment required**. Removing frozen columns *aligns* with §VI's anti-horizontal-scroll rule (no conflict). Photo/label/divider changes conform. See Complexity Tracking. |
| VII. Online-Only | ✅ Pass | Hard delete goes straight to mbe-api; no caching/offline. |

**Gate result**: PASS with one recorded deviation (VI). The deviation is intrinsic to the feature's intent (the user explicitly asked to reduce the action set), so it is justified and must be ratified via `/speckit-constitution` (§VI action-set clause) rather than worked around. No unjustified violations.

## Project Structure

### Documentation (this feature)

```text
specs/007-catalog-ui-improvements-2/
├── plan.md              # This file
├── research.md          # Phase 0 — decisions & the supplier/constitution findings
├── data-model.md        # Phase 1 — entity/state/filter deltas
├── quickstart.md        # Phase 1 — manual validation walkthrough
├── contracts/
│   ├── ui-contracts.md          # Shared-widget + screen behavior contracts
│   └── product-repository.md     # Repository method deltas (delete, sku, supplier)
├── checklists/
│   └── requirements.md  # From /speckit-specify (already present)
└── tasks.md             # /speckit-tasks output — NOT created here
```

### Source Code (repository root)

```text
lib/
├── core/
│   ├── widgets/
│   │   ├── data_table_view.dart        # FR-001: remove frozen/fixedLeftColumns
│   │   ├── catalog_action_icons.dart   # FR-002: buildCatalogRowActions → Edit-only
│   │   └── product_photo.dart          # FR-017/018: +75% size, BoxFit.contain
│   └── network/
│       └── photo_url.dart              # FR-021: LEGACY_PHOTOS_BASE_URL → PHOTOS_BASE_URL
├── features/
│   ├── catalog/
│   │   ├── domain/
│   │   │   ├── entities/product.dart           # prices display drop (mapping kept)
│   │   │   └── repositories/product_repository.dart  # + delete(); + sku on create/update
│   │   ├── data/
│   │   │   └── product_repository_impl.dart    # delete(), sku wiring, supplier assign/change
│   │   └── presentation/
│   │       ├── products_list_screen.dart       # FR-003/007/019/020: view-on-tap, multi-label, photo-first, copy-code
│   │       ├── products_list_controller.dart   # FR-007/008: label int? → List<int>
│   │       └── product_detail_screen.dart       # FR-005/006/010/012/013/014/015/016: title, edit btn, sku, drop prices, labels reposition, Delete button
│   │       └── product_form_controller.dart     # FR-010/016a: sku field, deactivate()→delete()
│   └── auth/presentation/admin/
│       ├── users_list_screen.dart      # inherits FR-002/003 (Edit-only, view-on-tap); keeps app-bar delete
│       └── user_detail_screen.dart     # FR-005 consistency: "View User" title in read-only
├── app/router/app_router.dart          # (unchanged — ?view=true already wired)
└── l10n/{app_es.arb, app_en.arb}       # new keys: view titles, edit-switch, sku, delete, copy-code

test/                                   # widget/unit/integration updates mirroring the above
```

**Structure Decision**: Single Flutter project, feature-first layered per constitution §I. The bulk of the work edits existing files in place; the only genuinely new surface is a `delete()` method on `ProductRepository`/impl and a handful of `.arb` keys. Shared behavior (frozen removal, Edit-only rows, row-click→read-only) is changed once in `core/widgets/` so both the catalog and auth consumers inherit it, per §VI.

## Complexity Tracking

| Violation / Deviation | Why Needed | Simpler Alternative Rejected Because |
|-----------------------|------------|--------------------------------------|
| **§VI row-action set redefinition** (Edit-only + row-click→read-only View; catalog Delete relocated to detail form) contradicts constitution §VI lines 155–163 (Create/View/Edit/Delete, fixed order). | The user explicitly requested reducing the three row buttons to Edit-only and making row-click open a read-only view — the whole point of this feature item. | Keeping the mandated 3-icon set would directly refuse the user's request. The honest path is to amend §VI (via `/speckit-constitution`) to define the new set, then implement — not to silently diverge or to leave the constitution stale. |
| **Hard delete replaces soft delete** for products; `ProductRepository.delete()` added despite its doc comment saying delete is "intentionally never added." | Clarified decision (spec Clarifications 2026-07-05): the destructive action must call mbe-api's real `DELETE` endpoint (a genuine hard delete). | Renaming the button to "Delete" while keeping soft-delete behavior would mislabel the action; keeping "Deactivate" refuses the user's rename request. |
| **Supplier-clear not delivered** (FR-011 partial): assign/change ships; clearing to "no supplier" does not. | mbe-api's update treats `supplier = None` as "leave unchanged" (`if data.supplier is not None`), so the client cannot express a clear. | A client-only workaround is impossible without a backend sentinel/PATCH-semantics change. Deferring *clear* (documented dependency) beats shipping a control that silently no-ops or lies about success. |

## Phase 0 — Research

See [research.md](./research.md). All Technical Context items are resolved; no `NEEDS CLARIFICATION` remain. Key decisions: hard-delete wiring & UX; multi-label OR-filter data shape; frozen-column removal strategy; photo sizing math + fit; copy-code affordance; the supplier-clear backend dependency; and the required §VI constitution amendment.

## Phase 1 — Design & Contracts

- [data-model.md](./data-model.md) — deltas to `Product` (display), `ProductFormState` (add `sku`, drop prices display, `deleted` flag), and `ProductFilter` (`label: int?` → `labels: List<int>`).
- [contracts/ui-contracts.md](./contracts/ui-contracts.md) — shared-widget and screen behavior contracts (row actions, read-only view, table columns, photo, copy-code).
- [contracts/product-repository.md](./contracts/product-repository.md) — `delete()`, `sku` on create/update, supplier assign/change.
- [quickstart.md](./quickstart.md) — manual validation walkthrough per user story.
- Agent context (`CLAUDE.md`) updated to point at this plan.
