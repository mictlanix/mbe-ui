# Implementation Plan: Bulk Pricing Grid

**Branch**: `033-bulk-pricing-grid` | **Date**: 2026-08-29 | **Spec**: [spec.md](./spec.md)
**Revised**: 2026-08-29, after mbe-api#182–#185 landed (`98d3254`)

**Input**: Feature specification from `/specs/033-bulk-pricing-grid/spec.md`

## Summary

Replace the product-picker pricing tool at `/pricing` with a grid — products down,
price lists across, prices edited in the cell — retire every low/high profit field
from the UI, and correct two things in the products filter drawer.

The shape of the work is set by six findings ([research.md](./research.md)), two of
which contradict a straight reading of the spec:

1. ~~**Two of the three headline capabilities cannot be built yet.**~~
   **Superseded — all four API gaps landed** (#182–#185, `98d3254`). Column
   actions (US3) now have the atomic bulk upsert FR-015 needs, and the worklist
   chips (US2) have both the filter and a facet endpoint. The original
   reasoning stands as *why those endpoints have the shape they do* (R7, R8),
   and the refusal to fake atomicity client-side is why US3 waited rather than
   shipping something that half-moves a column.
2. **The screen being replaced serves two routes, and only one of them goes.**
   `PricingScreen` is `/pricing` *and* `/products/:productId/pricing` (R1). The
   grid is a new screen; the old widget survives as the standalone per-product
   view CL-002 keeps, minus its picker branch.
3. ~~**The write path has a landmine**~~ — **defused by #185** (R6). The
   sales-order margin validation that made a wrong profit band dangerous is
   retired outright, and a created row now takes its band from the price
   list's margins *server-side*. The grid sends `price` and nothing else on
   both create and update; the client-side `_bandFor` helper and its `[0, 1]`
   fallback are deleted. This was the finding that most shaped the API's
   final shape, and it is the one with least left to do.
4. **The focus problem is solved by keeping draft text local — not by reusing
   specs 030/031's field controller, as first planned.** A `TextField` inside a
   `DataTableSource` row loses focus on every state-driven rebuild, so draft
   text stays in the cell's own `State`, never in Riverpod. But
   `ConfirmableFieldController` turned out to be the wrong vehicle for FR-009:
   it *discards* an invalid or refused value back to the last accepted one,
   the opposite of "keep it on screen, flagged, with a reason" (R3, corrected
   during implementation). Rejection is real state on the controller instead.
5. **Retiring the profit fields is presentation-only** (R11). The entities keep
   the fields, because the create/update path in finding 3 reads them; only 2 form
   fields, 4 table columns, 1 dialog, 6 l10n keys and one validator go. That is
   also why 94 test references do not all break — most are fixture builders.
6. **The shared table needs one addition, not a fork** (R2). `DataTableView`
   already takes columns as data, so a column per price list is free; it just
   never passes `DataTable2.minWidth`, which is exactly FR-006's "the grid scrolls,
   the page does not".

Net: one new screen with its controller and cell widget, one new repository method
(one request, since #182 landed), one `minWidth` parameter on a shared widget,
deletions across five presentation files, two `.arb` files, and two edits to one
filter panel.

## Technical Context

**Language/Version**: Dart 3.x / Flutter (stable)

**Primary Dependencies**: `flutter_riverpod` + `riverpod_generator`, `go_router`,
`freezed`, `dio` via the generated `mbe_api_client`, `data_table_2`,
`flutter_localizations`/`intl`. **No new dependency, no codegen.**

**Storage**: N/A — online-only (§VII). The shown-columns choice is session state in
a provider, not persisted (R9).

**Testing**: `flutter_test` (unit + widget), `integration_test` against a live
mbe-api

**Target Platform**: Web (Chrome) primary, macOS/desktop; compact tier < 600 px

**Project Type**: Single Flutter application, feature-first layering

**Performance Goals**: 3 requests per grid page (products, prices, price
lists) — achieved, since #182 landed and `listForProducts` collapsed to one
call (R5). One write per edited cell; one write per column action, via #183's
bulk upsert.

**Constraints**: a batched price fetch returns products × lists rows against
mbe-api's `BULK_LIMIT` of 500, shared by the read's `limit` and the bulk
write's body cap (R5); `0` is a real price list id, so every price-list filter
tests null rather than truthiness (R8); no mbe-api edit may be made from this
repo (§III).

**Scale/Scope**: 1 new screen replacing 1 existing screen mode, 1 new controller,
1 new cell widget, 1 new repository method, 1 shared-widget parameter, 5
presentation files losing fields, 12 test files touched.

## Constitution Check

*GATE: evaluated before Phase 0 and re-evaluated after Phase 1 design. Both passes
reach the same verdict.*

| Principle | Assessment |
|---|---|
| **I. Feature-First Layered Architecture** | PASS. Everything lands in `lib/features/pricing/`: the grid screen, its controller and cell widget in `presentation/`, the batched read declared in `domain/repositories/` and implemented in `data/`. The only file outside the feature is `core/widgets/data_table_view.dart` (one optional parameter) and the products list's own filter panel. |
| **II. Riverpod for State & DI** | PASS. The grid is a `@riverpod` family keyed by the freezed filter, mirroring `productsListController`. Shown columns are a session-scoped provider (R9). **Draft cell text is deliberately not in Riverpod** — it is per-widget input state with a disposal contract, which §II names as local UI state, and holding it in a provider is what breaks focus (R3). |
| **III. Contract-Driven API Integration** | PASS. No codegen, no hand-written DTO, no mbe-api edit from this repo. Four backend gaps are filed as mbe-api issues (#182–#185) and recorded in the spec's *External Dependencies*; two of them gate stories that are deliberately not built (R7, R8). No multipart is involved. |
| **IV. Deny-by-Default RBAC** | PASS. `/pricing` keeps its existing `PrivilegeGate(pricing, read)`; every editing affordance is hidden — not disabled — behind `can(pricing, update)`, and the read-only state says why (FR-026). The grid never renders a column menu it would refuse to run. |
| **V. Material 3, White-Labeled** | PASS. Colour, elevation and typography from `Theme.of(context)`; spacing from the spec 022 tokens; money through the spec 028 formatting surface (R10); every new string in both `.arb` files with `es-MX` authored first; six retired keys removed from both. |
| **VI. Desktop/Web-First, Compact-Ready** | **PASS with one recorded tension** — see Complexity Tracking. The grid is `CatalogFilterBar` + `DataTableView` + pagination with all facets behind the badged drawer, and long product names ellipsize with a tooltip. The tension is horizontal scrolling: §VI says avoid it on data tables, and a column per price list can exceed any width. FR-006 confines the scroll to the grid's own region, and FR-020's column chooser is the primary mitigation. |
| **VII. Online-Only** | PASS. No caching beyond provider lifetime, no offline queue. Undo is session state in the controller and reverts by issuing writes — it is not a local shadow copy of the catalogue (spec Assumptions). |

## Project Structure

### Documentation (this feature)

```text
specs/033-bulk-pricing-grid/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
│   ├── mbe-api-pricing.md
│   ├── pricing-grid-screen.md
│   └── routes.md
├── checklists/
│   └── requirements.md
└── tasks.md             # /speckit-tasks output — not created here
```

### Source Code (repository root)

```text
lib/
├── core/
│   ├── widgets/
│   │   └── data_table_view.dart              # + optional minWidth (R2)
│   └── navigation/nav_destinations.dart      # unchanged — /pricing keeps its slot
├── features/
│   ├── pricing/
│   │   ├── domain/repositories/
│   │   │   └── product_price_repository.dart # + listForProducts (R5)
│   │   ├── data/
│   │   │   └── product_price_repository_impl.dart
│   │   └── presentation/
│   │       ├── pricing_grid_screen.dart      # NEW — /pricing
│   │       ├── pricing_grid_controller.dart  # NEW — rows, changes, undo
│   │       ├── pricing_grid_columns.dart     # NEW — shown-columns provider
│   │       ├── price_cell.dart               # NEW — the editable cell
│   │       ├── pricing_screen.dart           # picker branch deleted (R1)
│   │       ├── price_list_detail_screen.dart # two fields removed
│   │       ├── price_lists_list_screen.dart  # two columns removed
│   │       └── price_list_form_controller.dart # margin state + validator removed
│   └── catalog/presentation/
│       └── products_list_screen.dart         # drawer heading + reorder (R12)
├── l10n/
│   ├── app_es.arb                            # new keys first, six keys removed
│   └── app_en.arb
test/
├── unit/features/pricing/
│   ├── pricing_grid_controller_test.dart     # NEW
│   └── …_test.dart                           # margin assertions removed
├── widget/features/pricing/
│   ├── pricing_grid_screen_test.dart         # NEW
│   └── …_test.dart
├── widget/features/catalog/
│   └── products_list_screen_test.dart        # drawer order + heading
└── integration/
    └── pricing_flow_test.dart                # rewritten against the grid
```

**Structure Decision**: feature-first, as every other module. The grid is new
files beside the screen it replaces rather than a rewrite of it, because
`pricing_screen.dart` survives as the standalone per-product view (R1).

## Delivery Order

Four slices, in dependency order. Each is independently shippable and testable;
only the first two can be built today.

**Every API dependency is now satisfied** (#182–#185, `98d3254`), so the
ordering below is about what depends on what in *this* repo, not about waiting
on anything.

| Slice | Stories | Status | Notes |
|---|---|---|---|
| **A1. Drawer corrections** | US6 | in progress | Two lines of layout plus a localized heading (R12). No dependency on anything. |
| **A2. Retire the profit fields** | US7 | unblocked (was gated on #185) | #185 retired the validation and deprecated all four fields, so T049's gate resolves to outcome (a) and the price-list form/list half may proceed (R11). |
| **B. The grid** | US1, US4, US5 | US1 done | `listForProducts` is one request. Single-cell editing, badges, undo, read-only mode. Replaces `/pricing`. US4/US5 still to build. |
| **C. Column actions** | US3 | unblocked (was gated on #183) | The bulk upsert exists; FR-015 is reachable. Mind the 400 on a repeated `(product, price_list)` and the 500-item body cap (R7). |
| **D. Worklist chips** | US2 | unblocked (was gated on #184) | Filter + facet endpoint both exist; `missingPriceList` is already wired through `ProductRepository.list`. FR-019's no-chips behaviour is what ships until the UI is built (R8). |

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|---|---|---|
| §VI "avoid horizontal scrolling on data tables" — the grid's region may scroll (FR-006) | The column count is the deployment's price-list count; there is no width at which "one column per list" always fits, and prices are exactly the "never truncate" category §VI protects | **Ellipsizing prices** — forbidden by §VI's own critical-info rule. **Capping columns silently** — hides data with no way to reach it. **Transposing to one list at a time** — that is the screen being replaced. The chosen mitigation is the FR-020 chooser plus keeping row identity legible while the price columns scroll. |
| Draft cell text held outside Riverpod | A provider write per keystroke rebuilds the `DataTableSource` row and steals focus mid-typing (R3) | Keeping it in the controller and re-seeding focus after each rebuild — fights the framework, and `ConfirmableFieldController` already exists for exactly this, with spec 030/031's tests behind it. §II names per-widget input state as local UI state, so this is inside the rule, not an exception to it. |
