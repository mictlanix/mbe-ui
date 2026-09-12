# Implementation Plan: Advanced Product Search

**Branch**: `038-advanced-product-search` | **Date**: 2026-09-09 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/038-advanced-product-search/spec.md`

## Summary

`ProductSearchField` gains an **Advanced search** button that pushes a new
top-level route, `/sales/product-search`: the catalog's paged products table
with its search box and badged filters button, minus the status column and the
row action icons, plus a leading checkbox column. The operator ticks one or
several products (per a new deployment setting) and confirms; the field prices
each one through the existing sales-order lookup and hands it to the host's own
`_addLine`, one at a time.

No backend change, no codegen, no new dependency, no change to `DataTableView`.
The work is shaped by five findings in [research.md](./research.md), three of
which contradict the obvious implementation:

1. **`context.go` inside the pushed screen would silently destroy the sale**
   (research R1). `go` re-resolves the whole match list, so navigating to
   `/sales/product-search?...` from `/sales/pos/123` unmounts the register page;
   `posSaleControllerProvider` is autoDispose and kept alive only by that page's
   `ref.watch`, so the in-progress sale would be disposed and cancel would have
   nothing to return to. Every in-screen navigation uses `GoRouter.replace`,
   which this repo already relies on for the same reason
   (`pos_workspace_screen.dart:123-130`). Consequence: `submitCatalogSearch` and
   the products screen's filter panel hardcode `context.go` and cannot be reused
   verbatim — the screen owns a three-line `_replaceWith(ListQuery)` helper.

2. **The result cannot come back through the `push` future** (research R2). This
   repo documents that a `replace` leaves an awaited push future "permanently
   uncompleted" (`pos_workspace_screen.dart:196-206`), and R1 makes `replace`
   the screen's normal mode. Worse, the screen *cannot* add the lines itself:
   `OrderScreen` overrides `saleEditorProvider` inside a nested `ProviderScope`,
   so a root-navigator route would resolve it to the register's controller and a
   back-office selection would land on the wrong sale. The selection therefore
   travels through two plain `StateProvider`s and the field consumes it with
   `ref.listen`; the host keeps doing the adding, inside its own scope.

3. **The callback must become awaitable** (research R3). `ensureOpen()` is not
   concurrency-safe — two simultaneous first adds create two draft sales — and
   both hosts currently wire `_addLine` into a `ValueChanged` that discards the
   future, which is also why a rejected add today produces an unhandled async
   error and no feedback. Changing `onProductSelected` to
   `Future<void> Function(ProductLookupResult)` is one word at each call site and
   is what makes sequencing, line ordering (FR-019) and per-product failure
   reporting (FR-021) possible at all.

Two smaller consequences the spec did not anticipate:

- **The forced facets must live inside `ProductFilter`**, not at the call site
  (research R5), or the label chips count over the whole catalog. And because
  `activeFilterCount` counts `status` and `salable`, the screen computes its own
  badge — otherwise a virgin screen shows a badge of 2.
- **The two open questions are closed** (research R7, R8): no dev-tenant account
  can prove whether cashiers hold `products` read (`MBE_POS_*` is an
  administrator), so the design is safe either way and the negative is asserted
  in a widget test; and direct entry with no sale beneath is handled by gating
  confirm on `Navigator.canPop()`.

## Technical Context

**Language/Version**: Dart 3.x / Flutter (goldens baselined on 3.44.2)

**Primary Dependencies**: `go_router`, `flutter_riverpod` + `riverpod_annotation`,
`freezed`, `data_table_2`, `dio` (existing generated client), `intl` +
`flutter_localizations`

**Storage**: none — server-side via mbe-api; no local persistence in this feature

**Testing**: `flutter_test` (unit + widget) with `mocktail`; existing
`pos_test_harness.dart` / `golden_harness.dart`; live flows under
`test/integration/`

**Target Platform**: Flutter web (Chrome) first, desktop/expanded tier; compact
tier must not break (constitution §VI)

**Project Type**: single Flutter application (feature-first layering)

**Performance Goals**: SC-005 — a 10-product selection added or reported within
5 s, with visible progress. One lookup + one `POST /lines` per product,
sequential by necessity (research R3).

**Constraints**: no mbe-api change (§III); no modification to `DataTableView`;
`GET /sales-orders/product-lookup` has no paging and no facets, which is why the
table is backed by `GET /products`; page size fixed at the catalog's 20.

**Scale/Scope**: one new screen, one new route, one new app setting, two new
providers, one changed widget contract, two host call-site touch-ups, 8 new
l10n keys ×2 locales. ~14 files.

## Constitution Check

*GATE: evaluated before Phase 0 and re-evaluated after Phase 1 design. Both
passes below reflect the post-design state.*

| Principle | Verdict | Notes |
|---|---|---|
| **I. Feature-first layered architecture** | Pass, with one recorded deviation | The screen lands in `lib/features/sales/presentation/capture/`. It reuses catalog's `ProductListItem` (domain) and `productsListControllerProvider` / `productLabelFacetsProvider` (presentation). Its filter panel needs `supplierRepositoryProvider` and `allLabelsProvider`, which are declared in `catalog/data/` — see Complexity Tracking. |
| **II. Riverpod state & DI** | Pass | Two plain `StateProvider`s for view-local selection state (§II explicitly allows `StateProvider` for local UI state and selections); everything else is existing `AsyncNotifier` families reused unchanged. No new DI. |
| **III. Contract-driven API integration** | Pass | Zero endpoint, schema or codegen change. No mbe-api issue needed. All errors already map to `AppError` in the repositories being reused. |
| **IV. Deny-by-default RBAC** | Pass | New `_routeGate` clause gating `/sales/product-search` on `PrivilegeGate(SystemObject.products, AccessRight.read)` — without it the route would be ungated, since `_routeGate` matches only `/sales/cash-sessions`, `/sales/pos` and `/sales/orders`. The affordance is hidden on the same `can()` check. Documented in `contracts/advanced-search-screen.md` §1. |
| **V. Material 3, white-labeled design system** | Pass | Material 3 only; both `.arb` files, `es` first; the new option is build-time, listed in `.env.template` with a documented default and a malformed-value fallback, and unreachable from the UI. The screen displays no dates, currency or quantities, so the formatting surface is not engaged. The largest text-size level is asserted for the new screen (tasks). |
| **VI. Desktop/web-first, compact-ready** | Pass, with one recorded deviation | Shared `CatalogFilterBar` + badged filters button + shared filter drawer + shared paged `DataTableView`; no inline facet chips; compact behaviour specified (FR-014). The row-action and row-click rules are deliberately not applied — see Complexity Tracking. |
| **VII. Online-only, server-rendered documents** | Pass | No caching, no offline state. The two selection providers hold view state for the duration of one visit, not fetched data. |
| **Workflow & quality gates** | Pass | Unit tests for the new setting; widget tests for the screen, the affordance, the access gate, the compact layout and the partial-failure path; the existing live flows keep covering the scan path. No mbe-api endpoint change, so no codegen/`SystemObject` update is required. |

## Project Structure

### Documentation (this feature)

```text
specs/038-advanced-product-search/
├── plan.md                              # This file
├── spec.md
├── research.md                          # R1–R10
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── advanced-search-screen.md        # route, layout, keys, field contract
│   └── app-settings-additions.md        # PRODUCT_SEARCH_MULTI_SELECT
├── checklists/
│   └── requirements.md
└── tasks.md                             # /speckit-tasks output — NOT created here
```

### Source code (repository root)

```text
lib/
├── app/router/
│   └── app_router.dart                  # +1 GoRoute, +1 _routeGate clause
├── core/config/
│   ├── app_settings.dart                # +productSearchMultiSelect, +parser
│   └── app_settings_provider.dart       # +productSearchMultiSelectProvider
├── features/sales/presentation/
│   ├── capture/
│   │   ├── product_search_field.dart    # +affordance, awaitable callback, bulk add
│   │   ├── advanced_search_screen.dart  # NEW — the picker screen
│   │   ├── advanced_search_state.dart   # NEW — selection + result providers
│   │   └── product_lookup_controller.dart  # +dependencies:[saleEditor] (research.md R11 —
│   │                                        # pre-existing scoping bug found by T024, fixed
│   │                                        # with user approval; regenerates .g.dart)
│   ├── capture/capture_step.dart        # call site unchanged in shape (await)
│   └── orders/order_screen.dart         # same
└── l10n/
    ├── app_es.arb                       # +8 keys (first)
    └── app_en.arb                       # +8 keys

test/
├── unit/core/config/app_settings_test.dart          # setting default + parser rule
└── widget/features/sales/
    ├── advanced_search_screen_test.dart             # NEW — table, filters, selection, compact
    ├── product_search_field_test.dart               # affordance, gating, bulk add, partial failure
    └── pos_test_harness.dart                        # +advancedSearchPath route (T020's harness)

.env.template                                        # +PRODUCT_SEARCH_MULTI_SELECT
.env.settings                                        # optional local override
```

**Structure Decision**: feature-first, matching the existing layout. The screen
lives beside the widget that opens it (`features/sales/presentation/capture/`)
rather than in `features/catalog/`, because it is a sales capture surface that
happens to read the product catalog — and deliberately **not** in
`lib/core/widgets/`, which would drag in the golden suite's file-scan guard for
a single-use screen.

## Complexity Tracking

| Violation | Why needed | Simpler alternative rejected because |
|---|---|---|
| §VI: rows expose no Edit action, and a row click selects instead of opening the record | This is a picker, not a catalog list screen: its rows are choices to add to a sale, and the spec pins "without the last columns (status and icon buttons)" and "first column has a checkbox" as Verbatim Constraints. An Edit icon here would navigate away from an in-progress sale mid-selection. | Following the rule literally would contradict the user's pinned requirements and put a catalog-management action inside a sales flow. The rule's intent — consistent row affordances across *catalog* screens — is unaffected: `/products` keeps its Edit and row-click behaviour unchanged. |
| §I: the new presentation-layer screen imports `catalog/data/` for `supplierRepositoryProvider` and `allLabelsProvider` | Those repository providers are declared in the `data/` implementation files; there is no domain-layer alias for them anywhere in the repo. | `products_list_screen.dart:22-23` already imports exactly these two for exactly this filter panel. Introducing a domain-layer provider alias for one screen would leave two ways to reach the same repository and make this screen inconsistent with the one it mirrors. Worth a separate cleanup spec, not a detour here. |
| Two non-autoDispose `StateProvider`s used as a cross-route channel | `GoRouter.replace` can rebuild the screen's page, and the field must read the confirmed selection after the screen is gone; widget state cannot span either boundary (research R1, R2). | An awaited `push` future is documented in this repo to never complete after a `replace`. `context.pop(value)` has no precedent here for go_router routes and would break the moment a filter is touched. The providers are reset on open and cleared on consume, so nothing outlives one visit. |
