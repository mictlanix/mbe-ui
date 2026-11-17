# Implementation Plan: Physical Inventory Counts

**Branch**: `070-inventory-adjustments-count` | **Date**: 2026-11-17 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/070-inventory-adjustments-count/spec.md` (mictlanix/mbe-roadmap#65)

## Summary

This adds "Conteos físicos", the fourth screen of the back office's Inventario group. It has a counts list and a count detail screen where a draft is edited in place:
- its header (warehouse, comment);
- its blind lines, entered three ways: the product picker, a quick-entry row for scanners, and pasting a code/quantity list that is sent in batches of up to 2,000;
- Confirm, with an option to count uncounted stock as 0, and the non-blocking warnings it returns;
- Cancel, for drafts only.

Mbe-api §4 (manual adjustments) is not built server-side, so there is no adjustment screen (FR-020).

All 9 routes already exist in the generated client (`InventoryCountsApi`). No codegen and no mbe-api change is needed. Six new error codes and one resource noun get Spanish and English messages (research R10).

The work builds on the shared inventory parts extracted in 068 (research R1). It adds no change to shipped receipts, issues or transfers code.

## Technical Context

**Language/Version**: Dart 3 / Flutter (the stable channel pinned by the repo)

**Primary Dependencies**: flutter_riverpod + riverpod_generator, go_router, freezed, dio, the generated `mbe_api_client` (built_value), intl / flutter_localizations

**Storage**: N/A (online-only, §VII)

**Testing**:
- `flutter test`: unit tests (including the pure paste parser), and widget tests with mocktail fakes.
- Live API tests in `test/integration/`, with writes gated by `MBE_WRITE=true`.
- A macOS device walkthrough in `integration_test/`.

**Target Platform**: Desktop (macOS) and web, Expanded tier first (§VI)

**Project Type**: Flutter client app (one project)

**Performance Goals**:
- One round trip each for the list and the detail.
- Each line write renders the server's response, with no extra GET.
- Lines are paged in memory (100 per page) so 15,000-line counts stay responsive (research R5).
- One quick entry on a 15,000-line count is measured in quickstart step 9 (research R4).

**Constraints**: Spanish UI text built from codes (§III), one formatting surface (§V), rights mirrored with `can(74, …)` (§IV), and pagination plus the filter drawer on the list (§VI). A paste batch has at most 2,000 rows.

**Scale/Scope**:
- 2 screens and 8 dialogs (new count, header, add line, line quantity, remove line, paste list, confirm, cancel), plus the quick-entry row and the warnings band.
- 1 nav destination and 9 endpoints.
- 6 new error codes and 1 resource noun.
- 1 pure parser.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Result | How |
|---|---|---|
| **I. Feature-first layers** | Pass | All in `lib/features/inventory/`. The domain gets the count entities, `CountPaste` with `parseCountPaste`, and the repository interface. `data/` gets the implementation over `InventoryCountsApi`. Presentation gets `counts/`. The shared inventory parts are reused unchanged, and nothing is imported from another feature. |
| **II. Riverpod** | Pass | The list and detail are `AsyncNotifier` controllers. A `keepAlive` actions notifier returns `AppError?` and updates the detail and list (068's pattern). `CountConfirmNotice` is an auto-dispose family (067's `ReceiptCostNotice`). `CountPasteSender` is an auto-dispose notifier scoped to the dialog. |
| **III. Contract-driven API** | Pass | Generated `InventoryCountsApi` only, with no hand-written DTOs. Coverage: the 6 new codes and the `inventory_count` noun are added in es/en ([contracts/error-messages.md](contracts/error-messages.md)). Rejected paste rows are recognized by part `code` and `extra['index']`, never by prose. |
| **IV. Deny-by-default RBAC** | Pass | The route and nav are gated by `can(physicalCountAdjustment, read)`. Actions are absent when not allowed: create (Nuevo conteo), update (header, lines, quick entry, paste, Confirmar), delete (Cancelar, draft only). The pickers also need read on warehouses and products. |
| **V. Material 3 / formatting** | Pass | Shared components only: `CatalogFilterBar`, `DataTableView`, `CatalogPagination`, `CatalogSearchBar`, `StatusChip`, `FactStripRow`, `ResponsiveDialog`, `ErrorBanner`/`FormErrorBanner`. Quantities, dates and folios go through `formattersProvider`. The paste parser reads decimals itself, because it parses user input, not display text. The largest text level is checked in quickstart step 13. |
| **VI. List and record surface** | Pass (the document reading, as 067–069) | **List**: filter row (no search; the endpoint has none), table and pagination. **Surface**: a full detail screen, because a count owns lines. No row Edit icon and no View toggle on the list. Draft line rows carry ✎ and 🗑. The AppBar has no actions. Cancel is a status action. |
| **VII. Online-only** | Pass | No caching, offline queue or printing. |

**Post-design re-check (after Phase 1)**: Pass.
- The design adds no widget to `core/widgets/`.
- The quick-entry row, warnings band and paste dialog are feature-local compositions of `TextField`, `ResponsiveDialog` and the banner widgets.
- In-memory line paging reuses `CatalogPage` the way `privileges_grid.dart` does.
- The masculine status labels need a count-specific chip, which reuses the shared colours (research R2), so shared code stays untouched.

## Project Structure

### Documentation (this feature)

```text
specs/070-inventory-adjustments-count/
├── plan.md              # This file
├── research.md          # Phase 0: R1–R13
├── data-model.md        # Phase 1: entities, paste state, transitions, action availability
├── quickstart.md        # Phase 1: validation walkthrough
├── wireframes.md        # Pre-plan drawings (questions settled in research)
├── contracts/
│   ├── ui-contract.md       # routes, nav, screens, dialogs, test keys
│   ├── repository.md        # InventoryCountRepository ↔ endpoints
│   └── error-messages.md    # 6 new codes + inventory_count noun
└── tasks.md             # Phase 2 (/speckit-tasks)
```

### Source Code (repository root)

```text
lib/features/inventory/
├── domain/
│   ├── entities/inventory_count.dart                 # NEW: InventoryCountSummary, InventoryCount, InventoryCountLine,
│   │                                                 #      CountWarnings, CountConfirmResult, CountLineInput, InventoryCountPage
│   ├── count_paste.dart                              # NEW: parseCountPaste → CountPaste (pure; research R7)
│   └── repositories/inventory_count_repository.dart  # NEW
├── data/
│   └── inventory_count_repository_impl.dart          # NEW: inventoryCountRepositoryProvider, mapping, DioException→AppError
└── presentation/
    └── counts/                                       # NEW
        ├── inventory_counts_list_screen.dart         # inventoryCountsPath = '/inventory/counts'
        ├── inventory_counts_list_controller.dart
        ├── inventory_count_detail_screen.dart        # header facts, quick entry, warnings band, line search + paged table, actions
        ├── inventory_count_detail_controller.dart
        ├── inventory_count_actions.dart              # create, updateHeader, setLines, updateLine, removeLine, confirm, cancel
        ├── inventory_count_status_chip.dart          # masculine labels, shared colours (research R2)
        ├── count_confirm_notice.dart                 # CountConfirmNotice + warnings band (research R9)
        ├── count_quick_entry.dart                    # quick-entry row (research R6)
        ├── count_paste_dialog.dart                   # + CountPasteSender (research R8)
        ├── new_count_dialog.dart
        ├── count_header_dialog.dart
        ├── add_count_line_dialog.dart
        └── count_dialogs.dart                        # quantity, remove line, confirm (with uncounted checkbox), cancel

lib/app/router/app_router.dart                        # branch 33 + detail route + _routeGate clause
lib/core/navigation/nav_destinations.dart             # NavBranch.inventoryCounts = 33; fourth child of 'inventory'
lib/core/errors/localize_problem.dart                 # 6 codes + inventory_count noun/gender
lib/l10n/app_es.arb, app_en.arb                       # navInventoryCounts, inventoryCount… keys, apiError… and apiResource… keys

test/unit/features/inventory/                         # count_paste_test, inventory_count_fixtures, repository impl,
                                                      # controllers, actions, paste sender
test/widget/features/inventory/                       # counts list, detail (blind/completed/rights/warnings/paging),
                                                      # quick entry, paste dialog, dialogs, large text
test/integration/inventory_counts_live_test.dart
integration_test/inventory_counts_quickstart_test.dart
```

**Structure Decision**: Counts go in the existing `lib/features/inventory/` beside receipts, issues and transfers, under `/inventory/counts` (route-mirrors-folders), with their own `counts/` presentation folder and the 068 shared parts reused.

## Implementation order

1. **Domain and data**: entities, `parseCountPaste` (TDD against research R7's rules), repository interface and implementation. **Check:** unit tests for the parser, mapping (including null `quantityOnHand`/`difference` on drafts and the warnings) and error mapping.
2. **Error coverage**: the 6 codes, the noun and gender, in es and en. **Check:** `catalog_coverage_test` passes.
3. **List and nav**: list controller and screen, status chip, nav entry, routes and gate. **Check:** widget tests for rights, filters and labels, and the router test.
4. **Detail core**: detail controller, actions, header facts, blind and completed line tables with in-memory paging and search, dialogs (new, header, add, quantity, remove, confirm, cancel), confirm notice band. **Check:** widget tests for blind vs completed columns, replace note, no cancel on completed, warnings band.
5. **Fast entry**: quick-entry row and the paste dialog with `CountPasteSender`. **Check:** widget tests for focus flow, replace feedback, batch progress, a refused second batch with row mapping.
6. **Live and device**: `inventory_counts_live_test.dart` (blind draft, replace, batch refusal by index, confirm sets stock, uncounted, warnings, cancel rules) and the quickstart device test.

## External dependencies

None. Possible follow-up: if quickstart step 9 shows slow line writes on very large counts, file an mbe-api issue for a lighter line-write response (research R4). It is not needed to ship.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| §VI row rules read as catalog-only (same reading as 067–069): count list rows have no Edit icon and no View toggle, and draft line rows carry ✎ and 🗑. | A count is a document with a status lifecycle, editable only as a draft and edited in place on its detail screen. | Catalog row icons would lead from completed and cancelled counts to a form with nothing to change. |
| In-memory paging and search of a document's lines, which no other document screen has. | An opening count holds up to ~15,000 lines, and the server returns them all. `DataTableView` with `shrinkWrap` builds every row. | One unpaged table would freeze the screen. A lazily scrolled table would break the shared table look and need a scroll-aware `DataTableView`. |
