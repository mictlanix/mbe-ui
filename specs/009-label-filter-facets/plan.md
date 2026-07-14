# Implementation Plan: Faceted Label Filtering

**Branch**: `009-label-filter-facets` | **Date**: 2026-07-12 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/009-label-filter-facets/spec.md`

## Summary

Turn the products-list filter drawer's label selector into a **faceted, dead-end-free** control: after every filter change (label select/deselect, search, or attribute toggle), each label chip is enabled only if at least one product in the *current* filtered result set also carries it; otherwise the chip is disabled/greyed. Selecting an enabled label therefore always narrows to a non-empty result, and users only ever see labels that further narrow what they're already viewing.

Technical approach: the products-list label filter is **already AND** ("contains all") server-side and mbe-ui already sends every selected `label` — so no filtering-semantics work is needed beyond correcting mbe-ui's stale "OR" docstrings. The only genuinely new capability is *cross-page label availability*, which the client cannot compute from a single 20-item page. That comes from a new mbe-api endpoint (`GET /api/v1/products/labels/facets`), filed as **[mictlanix/mbe-api#78](https://github.com/mictlanix/mbe-api/issues/78)** per the repo-boundary rule (constitution §III). Once it ships and the client is regenerated, mbe-ui adds a `productLabelFacets()` repository method, an autodispose `productLabelFacetsProvider` keyed on the current `ProductFilter`, extends the shared `LabelMultiPicker` with an optional "available ids" set, and wires it into `_ProductFiltersPanel`. Availability **fails open**: while the facet lookup is loading or on error, every label stays selectable, so filtering is never blocked.

**Cross-repo dependency (open)**: label availability requires [mictlanix/mbe-api#78](https://github.com/mictlanix/mbe-api/issues/78) — a dedicated `GET /api/v1/products/labels/facets` returning `[{label_id, count}]` for the products matching the same filter params as the list. mbe-ui does not patch mbe-api directly; the UI-side consumption (codegen + entity mapping + provider) lands once #78 ships. This is tracked in Complexity Tracking below.

## Technical Context

**Language/Version**: Dart 3 / Flutter (stable channel)

**Primary Dependencies**: `flutter_riverpod` + `riverpod_annotation` (state/DI), `go_router` (routing), `dio` + generated `mbe_api_client` (OpenAPI dio client), `freezed` (immutable entities), `intl` + `flutter_localizations` (es-MX default / en), Material 3. No new pub dependencies.

**Storage**: N/A — online-only (constitution §VII); no local persistence or caching of facet data.

**Testing**: `flutter_test` widget tests for the extended `LabelMultiPicker` (disabled vs. selected-still-interactive chips) and `_ProductFiltersPanel` (availability wiring, fail-open when the provider is loading/errored); unit tests for `productLabelFacetsProvider` (refetch on filter change, maps response → available-id set) and `ProductRepositoryImpl.productLabelFacets` with the API client mocked; an `integration_test` faceted-narrowing path against a test mbe-api once #78 ships.

**Target Platform**: Web + desktop (Expanded tier first per constitution §VI), compact-ready — the drawer already renders as a side sheet (expanded) or bottom sheet (compact).

**Project Type**: Single Flutter application, feature-first layered (`lib/features/*`, shared `lib/core/*`).

**Performance Goals**: 60 fps interaction; one facets round-trip per discrete filter change, issued **only while the drawer is open** (autodispose provider) and in parallel with the list fetch; facet payload is at most one row per label (≤ ~100 rows), not per product.

**Constraints**: Material 3 only (§V); no new RBAC surface — the drawer stays under the products-list `Read` gate (§IV); generated DTOs only, no hand-written schemas (§III); no hardcoded strings (§V); availability must fail open so a lookup failure never blocks filtering (spec FR-010).

**Scale/Scope**: 1 new repository method + 1 new domain entity + 1 new provider + 1 shared-widget param extension + drawer wiring + docstring corrections + `.arb` key(s). 12 functional requirements, 3 user stories. Blocked on one external mbe-api endpoint (#78).

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Feature-First Layered Architecture | ✅ Pass | `productLabelFacets()` added to the `domain` `ProductRepository` interface, implemented in `data`; the availability provider and drawer wiring live in `presentation`. Presentation depends only on domain (via `productRepositoryProvider`). The shared chip control extension lands in `core/widgets/`. No cross-layer leak. |
| II. Riverpod state/DI | ✅ Pass | New `productLabelFacetsProvider` is an `@riverpod` autodispose provider exposing `AsyncValue<Set<int>>`, derived from `productFilterControllerProvider`; reuses `productRepositoryProvider`. Local UI state only. No new DI mechanism. |
| III. Contract-Driven API | ⚠️ Pass w/ dependency | Uses the generated client **after** #78 ships and codegen re-runs (`tool/generate_api_client.sh`); the new `ProductLabelFacet` DTO is generated, not hand-written, and mapped to a `freezed` domain entity. Errors flow through the shared `mapDioException` → `AppError`. The endpoint is filed as [mictlanix/mbe-api#78](https://github.com/mictlanix/mbe-api/issues/78) (external dependency, Complexity Tracking) rather than patched from this repo. Also corrects stale "OR" docstrings so docs match the already-shipped AND behavior. |
| IV. Deny-by-Default RBAC | ✅ Pass | No new route, screen, or privilege. The drawer and its facet lookup are reached only from the products list, already gated by `can(SystemObject.products, AccessRight.read)`. The facets endpoint is a read alongside the existing list read. |
| V. Material 3, White-Labeled, i18n | ✅ Pass | Disabled state uses `FilterChip`'s native `onSelected: null` (Material 3). Any new copy (e.g. a disabled-chip tooltip) is added to `app_es.arb` (default) + `app_en.arb`; no hardcoded strings. |
| VI. Desktop/Web-First, Compact-Ready Layout | ✅ Pass | Not a list/table change. The drawer keeps its shared responsive side-sheet/bottom-sheet presentation (`core/widgets/catalog_filter_sheet.dart`); the label section keeps its `Wrap` of chips. |
| VII. Online-Only | ✅ Pass | Facet availability is fetched live per filter change; nothing cached or persisted. |

**Gate result**: PASS — no violations. One external dependency (mbe-api#78) is recorded in Complexity Tracking; per §III this is the sanctioned repo-boundary pattern (mirrors specs/008-merge-products' handling of #76), not a deviation. The UI-side work is fully specified and lands once the endpoint ships upstream.

## Project Structure

### Documentation (this feature)

```text
specs/009-label-filter-facets/
├── plan.md              # This file
├── research.md          # Phase 0 — decisions (facet source, availability model, provider shape, fail-open, picker extension)
├── data-model.md        # Phase 1 — ProductLabelFacet, LabelAvailability set, provider, ProductFilter reuse
├── quickstart.md        # Phase 1 — manual validation per user story
├── contracts/
│   ├── product-repository.md    # productLabelFacets() method contract + error mapping
│   ├── ui-contracts.md          # LabelMultiPicker availability extension + drawer wiring behavior
│   └── mbe-api-label-facets.md  # GET /products/labels/facets contract (mirrors mbe-api#78)
├── checklists/
│   └── requirements.md  # From /speckit-specify (present)
└── tasks.md             # /speckit-tasks output — NOT created here
```

### Source Code (repository root)

```text
lib/
├── core/
│   └── widgets/
│       └── label_multi_picker.dart          # extend: optional availableIds set → per-chip disabled state (US2 / FR-003, FR-004)
├── features/
│   └── catalog/
│       ├── domain/
│       │   ├── entities/
│       │   │   └── product_label_facet.dart # NEW — freezed {labelId, count}
│       │   └── repositories/
│       │       └── product_repository.dart   # + productLabelFacets({filter params}); fix stale "OR" docstring on list()
│       ├── data/
│       │   └── product_repository_impl.dart  # implement productLabelFacets via generated client (after #78 regen)
│       └── presentation/
│           ├── products_list_controller.dart # + productLabelFacetsProvider (autodispose, keyed on ProductFilter); fix stale OR comment
│           └── products_list_screen.dart      # wire availability into _ProductFiltersPanel's LabelMultiPicker
├── generated/openapi/                         # regenerated after mbe-api#78 (ProductLabelFacet DTO + facets endpoint)
└── l10n/{app_es.arb, app_en.arb}              # new key(s): disabled-chip tooltip, if used

test/                                          # widget/unit/integration for the above
```

**Structure Decision**: Single Flutter project, feature-first layered per constitution §I. The only new file is the `ProductLabelFacet` entity; everything else is an additive method/param/provider on existing files plus the shared-widget extension in `core/widgets/`. Extending the shared `LabelMultiPicker` (rather than forking a filter-only variant) keeps the product form's picker on the same widget — it simply omits the availability set and stays all-enabled.

## Complexity Tracking

*No constitution violations.* One external dependency is tracked here per §III (repo-boundary rule):

| Dependency | Why Needed | Resolution |
|------------|------------|------------|
| mbe-api endpoint `GET /api/v1/products/labels/facets` ([mictlanix/mbe-api#78](https://github.com/mictlanix/mbe-api/issues/78)) | The client holds only one 20-item page, so it cannot compute which labels co-occur across the entire filtered result set (FR-009). A dedicated, lightweight facets lookup returns `[{label_id, count}]` for the matching products in one grouped query. | Filed as mbe-api#78. mbe-ui does not patch mbe-api directly; UI-side consumption (codegen + `ProductLabelFacet` mapping + `productLabelFacets()` + provider + drawer wiring) lands once #78 ships and `tool/generate_api_client.sh` re-runs. Until then the repository method and provider are built against the contract in `contracts/mbe-api-label-facets.md` and can be unit-tested with the client mocked. |

**Note**: AND ("contains all") label semantics are **already** implemented in mbe-api (`list_products`, commit `bc80335`, 2026-07-05) and mbe-ui already sends every selected label — so FR-001 is a docstring correction, not a code/behavior change, and is *not* an external dependency.

## Phase 0 — Research

See [research.md](./research.md). All Technical Context items are resolved; no `NEEDS CLARIFICATION` remain. Key decisions: source availability from the dedicated `GET /products/labels/facets` endpoint (mbe-api#78); model availability as a `Set<int>` of label ids present in the current filter's matches; expose it via an autodispose `productLabelFacetsProvider` keyed on `ProductFilter` so it fetches only while the drawer is open and refetches on every filter change; **fail open** (all labels enabled) whenever the provider is loading or errored; and extend the shared `LabelMultiPicker` with an optional availability set rather than forking a new widget.

## Phase 1 — Design & Contracts

- [data-model.md](./data-model.md) — `ProductLabelFacet` (`labelId`, `count`), the derived `Set<int>` availability value, `productLabelFacetsProvider`, and reuse of the existing `ProductFilter`.
- [contracts/product-repository.md](./contracts/product-repository.md) — `productLabelFacets()` signature, mapping, and error handling (fails open at the provider layer).
- [contracts/ui-contracts.md](./contracts/ui-contracts.md) — `LabelMultiPicker` availability extension (enabled = selected OR available; selected chips always interactive) and `_ProductFiltersPanel` wiring.
- [contracts/mbe-api-label-facets.md](./contracts/mbe-api-label-facets.md) — the `GET /api/v1/products/labels/facets` request/response contract, mirroring mbe-api#78.
- [quickstart.md](./quickstart.md) — manual validation walkthrough per user story.
- Agent context (`CLAUDE.md`) updated to point at this plan.
