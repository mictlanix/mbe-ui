# Implementation Plan: Stock and Kardex

**Branch**: `071-stock-kardex` | **Date**: 2026-11-17 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/071-stock-kardex/spec.md` (mictlanix/mbe-roadmap#67)

## Summary

This adds two read-only screens to the back office's Inventario group, plus a product view and a catalog shortcut:
- **Existencias** shows one warehouse's stock per product: on hand, reserved, available and incoming. It has a search and a "show zero stock" switch, and keeps its state in the URL.
- **The product view** shows one product in every warehouse, with totals and its in-transit stock per facility. Each warehouse row has a "Ver kardex" action.
- **Kardex** shows one product's movements in one warehouse over a date range of at most 366 days: opening balance, each movement with its running balance, the totals and the closing balance. A movement opens its source document when the app has a screen for it and the user can read it.
- **"Ver existencias"** is a button on the product catalog's detail screen, in View mode.

All three routes are already in the generated client (`StockApi`, `KardexApi`). No codegen and no mbe-api change is needed. Two new error codes get Spanish and English messages.

One shared widget changes. `RecordFormActions` gains an optional `leading` slot for the catalog shortcut (research R9), and it renders exactly as today when the slot is empty.

## Technical Context

**Language/Version**: Dart 3 / Flutter (the stable channel pinned by the repo)

**Primary Dependencies**: flutter_riverpod + riverpod_generator, go_router, freezed, dio, the generated `mbe_api_client` (built_value), intl / flutter_localizations

**Storage**: N/A (online-only, §VII)

**Testing**:
- `flutter test`: unit tests (repositories, the range check, the source mapping), and widget tests with mocktail fakes.
- A read-only live API test in `test/integration/`.
- A macOS device walkthrough in `integration_test/`.

**Target Platform**: Desktop (macOS) and web, Expanded tier first (§VI)

**Project Type**: Flutter client app (one project)

**Performance Goals**:
- One request per view: a stock page, a product's stock, or a kardex.
- Existencias pages on the server (50 per page). The kardex pages in memory (100 per page), since the server returns the whole range.

**Constraints**:
- Spanish text built from codes and source types, never from the server's `sourceName` (§III).
- One formatting surface (§V).
- Rights mirrored with `can(67|32, read)` (§IV).
- Filter row, sheet and pagination on the lists (§VI).
- The kardex range is at most 366 days.

**Scale/Scope**:
- 3 screens and 1 shared-widget extension.
- 2 nav destinations and 3 endpoints.
- 2 new error codes, and 11 source labels (10 types plus a fallback).

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Result | How |
|---|---|---|
| **I. Feature-first layers** | Pass | All in `lib/features/inventory/`: domain entities and two repository interfaces, `data/` implementations over the generated APIs, and presentation in `stock/` and `kardex/`. The kardex links push other features' routes by path and import no other feature's presentation. The catalog change uses only a `core/widgets` slot and a route path. |
| **II. Riverpod** | Pass | Existencias and the product view are `AsyncNotifier` families keyed by their query. The kardex is a family keyed by `KardexSelection`, and it never fetches when the selection isn't `ready`. Repositories are providers. |
| **III. Contract-driven API** | Pass | Generated `StockApi` and `KardexApi` only, built with `appSerializers`. Coverage: the 2 kardex codes are added in es and en, and their rows in code-scope.tsv become `IN` ([contracts/error-messages.md](contracts/error-messages.md)). Source labels are keyed on the source type, never on `sourceName`. |
| **IV. Deny-by-default RBAC** | Pass | The routes and nav entries are gated by `can(67, read)` and `can(32, read)`. "Ver kardex" needs 32, "Ver existencias" needs 67, and each kardex link needs its document type's read right. There is no create, update or delete anywhere. |
| **V. Material 3 / formatting** | Pass | Shared components only: `CatalogFilterBar`, `CatalogSearchBar`, the filter sheet, `CatalogEntityPicker`, `DateRangeFilterChip`, `FactStripRow`, `DataTableView`, `CatalogPagination`, `CatalogListStateView` and `buildCatalogRowActions`. Quantities, dates and times go through `formattersProvider`. The largest text level is checked in quickstart step 12. |
| **VI. List and record surface** | Pass | Each list has a filter row (search where the endpoint has one), a sheet, a table and pagination. Existencias rows have no icons, and a row tap opens the product view (read-only, so there is no Edit and no View icon). The product view rows carry one direct action, "Ver kardex", the one allowed shortcut. The catalog shortcut is an `OutlinedButton` in the record's shared action area, never an AppBar icon. |
| **VII. Online-only** | Pass | No caching, export or printing. |

**Post-design re-check (after Phase 1)**: Pass. The one shared-widget change (`RecordFormActions.leading`) is additive and optional, and follows §VI's rule that every screen-level action sits in the record's shared action area. Every other piece is a composition of existing widgets. The required pickers follow the shipped filter-sheet pattern (research R2), so no inline-picker width token is needed.

## Project Structure

### Documentation (this feature)

```text
specs/071-stock-kardex/
├── plan.md              # This file
├── research.md          # Phase 0: R1–R13
├── data-model.md        # Phase 1: entities, selection states, source mapping, rights
├── quickstart.md        # Phase 1: validation walkthrough
├── wireframes.md        # Pre-plan drawings (questions settled in research; R2 overrides Q1)
├── contracts/
│   ├── ui-contract.md       # routes, nav, screens, keys
│   ├── repository.md        # Stock and Kardex repositories ↔ endpoints
│   └── error-messages.md    # 2 new kardex codes
└── tasks.md             # Phase 2 (/speckit-tasks)
```

### Source Code (repository root)

```text
lib/features/inventory/
├── domain/
│   ├── entities/stock.dart                         # NEW: StockRow, StockPage, ProductStock, InTransitStock
│   ├── entities/kardex.dart                        # NEW: Kardex, KardexMovement, KardexDocumentRef
│   ├── repositories/stock_repository.dart          # NEW
│   └── repositories/kardex_repository.dart         # NEW
├── data/
│   ├── stock_repository_impl.dart                  # NEW: stockRepositoryProvider
│   └── kardex_repository_impl.dart                 # NEW: kardexRepositoryProvider
└── presentation/
    ├── stock/                                      # NEW
    │   ├── stock_list_screen.dart                  # stockPath = '/inventory/stock'
    │   ├── stock_list_controller.dart
    │   ├── product_stock_screen.dart               # '/inventory/stock/products/:id'
    │   └── product_stock_controller.dart
    └── kardex/                                     # NEW
        ├── kardex_screen.dart                      # kardexPath = '/inventory/kardex'
        ├── kardex_controller.dart
        ├── kardex_selection.dart                   # URL state + range check (research R4)
        └── kardex_sources.dart                     # source labels + document routes (research R5)

lib/core/widgets/record_form_actions.dart           # EDIT: optional `leading` (research R9)
lib/features/catalog/presentation/product_detail_screen.dart  # EDIT: "Ver existencias" in View mode
lib/app/router/app_router.dart                      # branches 34, 35 + product view route + _routeGate clauses
lib/core/navigation/nav_destinations.dart           # NavBranch.inventoryStock = 34, inventoryKardex = 35
lib/core/errors/localize_problem.dart               # 2 kardex codes
lib/l10n/app_es.arb, app_en.arb                     # nav, screens, source labels, error keys
specs/058-localized-api-errors/contracts/code-scope.tsv  # 2 rows IN (163 → 165)

test/unit/features/inventory/                       # stock/kardex fixtures, repository impls, controllers,
                                                    # kardex_selection_test, kardex_sources_test
test/widget/features/inventory/                     # stock list, product view, kardex, large text
test/widget/core/widgets/record_form_actions_test.dart  # + leading slot
test/widget/features/catalog/                       # product detail "Ver existencias"
test/integration/stock_kardex_live_test.dart        # read-only
integration_test/stock_kardex_quickstart_test.dart
```

**Structure Decision**: Stock and kardex go in the existing `lib/features/inventory/`, under `/inventory/stock` and `/inventory/kardex` (route-mirrors-folders). They reuse the shared inventory name cells and warehouse options from specs 067–070.

## Implementation order

1. **Domain and data**: entities, both repositories, and the pure `KardexSelection` range check and source mapping. **Check:** unit tests for mapping (null lists, decimals, the document ref), the range edges (365, 366 and 367 days; a reversed range), and every source type's label and route with and without the read right.
2. **Error coverage**: the 2 codes in es and en, and the code-scope.tsv rows. **Check:** `catalog_coverage_test` at 165.
3. **Existencias and the product view**: the list controller and screen, the sheet, the product view, nav and routes. **Check:** widget tests for the starting warehouse, URL state, negative figures, the prompt, the in-transit refusal, totals, "Ver kardex" gating and the empty product.
4. **Kardex**: controller, screen, sheet, summary, in-memory paging and links. **Check:** widget tests for the incomplete, reversed, tooLong, no-movements and populated states, a link pushing its route, an unlinked row, and the default 30 days.
5. **Catalog shortcut**: `RecordFormActions.leading` and the product detail button. **Check:** the `RecordFormActions` tests pass unchanged plus a `leading` case; the button shows only in View mode with 67.
6. **Live and device**: the read-only live test (stock figures, the product view, a kardex whose closing balance matches stock, both range refusals, the in-transit refusal, and an inactive product in the picker, research R12), and the device walkthrough.

## External dependencies

None.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| A shared widget (`core/widgets/record_form_actions.dart`) changes for one feature. | §VI requires the catalog's "Ver existencias" in the record's shared action area, and `RecordFormActions` has no place for it. | A local `Row` beside it would let the action area's alignment drift from every other record screen. The change is additive and optional, so every existing caller renders exactly as before; the existing `RecordFormActions` tests and the `core_widgets` golden must stay unchanged. |
| The kardex pages its rows in memory. | The server returns the whole range (up to 366 days) in one response. | One unpaged table builds every row and freezes on a busy product. The same pattern as spec 070's count lines. |
