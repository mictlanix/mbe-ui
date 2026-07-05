# Implementation Plan: Catalog UI/Layout Improvements

**Branch**: `006-catalog-ui-improvements` | **Date**: 2026-07-05 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `specs/006-catalog-ui-improvements/spec.md`

## Summary

Two presentation-only refinements to the existing product catalog screens, with **no API, DTO, domain-entity, or repository changes**:

1. **Declutter the products-list filter bar** (US1): replace the inline row of filter chips + label dropdown next to the search box with a single **Filters** button carrying an **active-filter count badge**. Tapping it opens a filter panel holding all facets (show-inactive, stockable, salable, purchasable, label) plus **Clear all** and **Done/Apply**. The panel is a **modal bottom sheet on compact** widths and a **right-anchored side sheet on expanded** widths. Filtering stays live/reactive against the existing `ProductFilterController` — the only controller addition is a derived `activeFilterCount`.

2. **Make the product detail form use horizontal space** (US2/US3): constrain the form to a **max content width** and lay fields out in a **responsive column grid** (1 col compact / 2 col medium-expanded / 3 col large≥1200) via a new shared `core/widgets/` responsive-grid wrapper; extend `core/layout/breakpoints.dart` with a `large` (1200px) tier. Move the photo thumbnail's **Change/Remove/Upload** actions **beside** the thumbnail instead of stacked below.

Both build reusable pieces in `core/` (a filter-sheet launcher + a responsive form grid) so future catalog/form screens inherit the same behavior (constitution §VI).

## Technical Context

**Language/Version**: Dart `^3.10.3`, Flutter stable — same as specs 001–005.

**Primary Dependencies**: `flutter_riverpod` `^2.6.1` + `riverpod_annotation`/`riverpod_generator`, `go_router` `^17.3.0`, `freezed` `^2.5.8`/`freezed_annotation`. **No new pub dependencies** — Flutter's built-in `showModalBottomSheet`, `showGeneralDialog`, `LayoutBuilder`/`MediaQuery`, `Wrap`, and `Badge` cover everything (research.md §1–§4).

**Storage**: N/A — no persistence, no local cache (constitution §VII). No new state is persisted; the filter panel reads/writes the existing in-memory `ProductFilter`.

**Testing**: `flutter_test` widget tests. Existing widget tests for both screens must be updated because facet chips now live inside a sheet that must be opened first (research.md §6, quickstart.md). `mocktail` fakes for `ProductRepository`/`AccessControlService` as today. No new integration tests required (pure layout change), though the quickstart adds manual responsive-resize checks.

**Target Platform**: Web, Windows, macOS, Linux — Expanded (desktop/web) primary tier, with the new `large` tier for wide monitors; Compact behavior preserved.

**Project Type**: Single Flutter project, feature-first. This feature modifies `lib/features/catalog/presentation/` (two screens + one controller) and adds two shared widgets under `lib/core/`.

**Performance Goals**: No new network calls; filtering keeps its existing reactive re-fetch on `ProductFilter` change. Sheet open/close and form reflow must stay at 60 fps. No regression to products-list page-load time.

**Constraints**: Must preserve **every existing widget key, RBAC gate, localized string, error banner, field-error, and read-only behavior** (FR-013). Controller business logic MUST NOT change beyond a derived active-filter count (FR-014). Responsive breakpoints MUST come from the centralized `LayoutBreakpoints` (FR-015). No horizontal scrolling at any tier (SC-005).

**Scale/Scope**: No new screens or routes. Modifies 3 existing files (`products_list_screen.dart`, `product_detail_screen.dart`, `products_list_controller.dart`), extends 1 core file (`breakpoints.dart`), adds 2 shared widgets (`catalog_filter_sheet.dart`, `responsive_form_grid.dart`), adds a handful of l10n strings, and updates 2 widget-test files.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|---|---|---|
| I. Feature-First Layered Architecture | ✅ PASS | All screen changes stay in `lib/features/catalog/presentation/`. The two new reusable widgets live in `lib/core/widgets/` and the breakpoint extension in `lib/core/layout/`. `presentation` still imports only `domain`; no `data` imports added. |
| II. Riverpod for State & DI | ✅ PASS | No new providers needed. Filter state stays on the existing `ProductFilterController` (`Notifier`); the added `activeFilterCount` is a pure derived getter on `ProductFilter`, not new state. Sheet visibility is transient widget/navigator state (a `showModalBottomSheet`/`showGeneralDialog` route), correctly *not* Riverpod. |
| III. Contract-Driven API Integration | ✅ PASS | Zero API surface touched — no new endpoints, DTOs, or `dio` calls. Query-param mapping in `ProductsListController` is unchanged. |
| IV. Deny-by-Default RBAC | ✅ PASS | Filtering remains ungated (read capability). The detail form's per-field `enabled`/read-only gating, `canSave`, `canDeactivate`, and `canEditPhoto` are carried through unchanged into the new grid/photo-row layout. |
| V. Material 3 White-Labeled Design System | ✅ PASS | Uses standard M3 components (`Badge`, `FilterChip`, bottom/side sheet, `FilledButton`/`TextButton`). No hardcoded colors or bespoke theming; sheet and badge inherit `ColorScheme`. |
| VI. Desktop/Web-First, Compact-Ready Layout | ✅ PASS | Breakpoints extended centrally in `core/layout/` (not per-screen). Filter panel and responsive grid implemented once in `core/widgets/` for reuse. Catalog still ships with search + filtering (now behind a discoverable Filters button, still complete). Row CRUD action icons/order on the list are untouched. No horizontal scroll introduced. |
| VII. Online-Only, Server-Rendered Documents | ✅ PASS | No local persistence added; filter selection remains in-memory Riverpod state discarded on disposal. |

**No violations — Complexity Tracking section omitted.**

## Project Structure

### Documentation (this feature)

```text
specs/006-catalog-ui-improvements/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output (UI-state only; no persisted entities)
├── quickstart.md        # Phase 1 output (manual + widget-test validation guide)
├── contracts/
│   └── ui-components.md  # Phase 1 output (shared-widget UI contracts)
└── checklists/
    └── requirements.md   # From /speckit-specify
```

### Source Code (repository root)

```text
lib/
├── core/
│   ├── layout/
│   │   └── breakpoints.dart          # EXTEND: add `large` (1200) tier + LayoutTier.large
│   └── widgets/
│       ├── catalog_filter_sheet.dart # NEW: showCatalogFilterSheet() — bottom sheet
│       │                             #      (compact) / side sheet (expanded) launcher
│       └── responsive_form_grid.dart # NEW: 1/2/3-column responsive form layout wrapper
└── features/catalog/presentation/
    ├── products_list_screen.dart     # MODIFY: Filters button + badge; move facets into sheet
    ├── products_list_controller.dart # MODIFY: add derived ProductFilter.activeFilterCount
    │                                  #         + a reset() for Clear All (composed from copyWith)
    └── product_detail_screen.dart    # MODIFY: max-width + responsive grid; inline photo actions

lib/l10n/
├── app_en.arb                        # ADD: filtersButton, filtersTooltip, clearAllFilters,
└── app_es.arb                        #      applyFilters (+ es translations)

test/widget/features/catalog/
├── products_list_screen_test.dart    # UPDATE: open the sheet before asserting facet chips
└── product_detail_screen_test.dart   # UPDATE: assert responsive layout; keys unchanged
```

**Structure Decision**: Single Flutter project, feature-first (unchanged from 001–005). New cross-cutting UI behavior goes to `lib/core/` per constitution §VI; screen-specific wiring stays in `lib/features/catalog/presentation/`. No new routes, providers, repositories, or entities.

## Complexity Tracking

*No constitution violations — section intentionally empty.*
