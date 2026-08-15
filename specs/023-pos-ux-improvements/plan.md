# Implementation Plan: POS Sales List, Full-Width Workspace and Capture Polish

**Branch**: `023-pos-ux-improvements` | **Date**: 2026-08-10 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `specs/023-pos-ux-improvements/spec.md`

---

## Summary

Spec 020 shipped the counter screen; using it surfaced three problems this
feature fixes and nothing else. The register's sales have no screen — only a
dropdown of unfinished ones, reachable from inside the sale. The sale screen
renders beside the navigation rail with form-style paddings and a two-band
footer, so a 1440-px display shows one sale line and ~400 px of nothing. And the
capture surface drifted from its own mock in four specific ways (customer band,
product field, line row, footer).

The approach, in one paragraph: `/sales/pos` becomes an ordinary catalog list
screen scoped to the cashier's register, and the sale moves to two top-level
full-screen routes (`/sales/pos/new`, `/sales/pos/:saleId`) with a Back button
and no shell chrome — the same list→record split every other catalog already
uses, which is also what frees the rail's width. Inside the workspace, the header
band is deleted into the app bar's title, the primary action moves into the
totals bar so the footer is one band, and the lines `Expanded` finally reaches
it. The four capture widgets are then reworked against frame `2a` of the mock:
the customer band becomes a facts-with-actions surface that swaps to the picker
in place, the product field gains debounced search-as-you-type without losing the
scanner's submit-and-add path, the line row gets a measured single-row budget that
holds down to a tablet in landscape, and the footer gets labelled stat groups with
a dominant total. No selling rule, step order, or money calculation changes.

Two decisions came out of research and are worth reading before implementing:
row workability is decided from the summary plus the register's existing
open-sales set, so the list costs **zero** extra requests per row
([research R4](./research.md)); and the single-row line layout is a measured
944-px budget with a 950-px threshold, chosen so a 1024-px tablet fits with slack
([research R10](./research.md)).

## Technical Context

**Language/Version**: Dart 3.10.3+ / Flutter stable

**Primary Dependencies**: `flutter_riverpod` + `riverpod_generator`, `go_router`,
`freezed`, `dio` via the generated `mbe_api_client`, `data_table_2`, `decimal`,
`intl`, `flutter_localizations`

**Storage**: none — online-only (constitution §VII). No new persisted state; the
list's whole view state lives in the URL.

**Testing**: `flutter_test` + `mocktail`; existing `pos_test_harness.dart`;
golden harness from spec 022; live-backend integration tests gated on `.env`
credentials

**Target Platform**: Flutter web/desktop first (expanded tier), with
tablet-landscape and phone tiers explicitly in scope this time (FR-021, FR-037a)

**Project Type**: single Flutter application (feature-first layers)

**Performance Goals**: no added per-row round trips on the list (research R4);
candidates offered within 500 ms of the last keystroke (SC-006); ≥ 8 sale lines
visible at 1440×900 (SC-003)

**Constraints**: no mbe-api change (constitution §III repo boundary) — the line
thumbnail therefore ships as a reserved slot; the endpoint's non-exclusive
`status` filter and its local-wall-clock `date_from` handling must both be
respected rather than rediscovered; every style value must resolve through the
spec 022 tokens (FR-048)

**Scale/Scope**: 1 new list screen, 1 new workspace screen, 1 new shared core
widget, 2 new routes, 4 reworked capture widgets, 1 deleted widget, ~26 files,
~42 tasks (classified **oversized**)

## Constitution Check

*GATE: evaluated before Phase 0, re-evaluated after Phase 1 design (below).*

| Principle | Verdict | How this feature complies |
|---|---|---|
| **I. Feature-first layers** | PASS | Everything lands under `lib/features/sales/{domain,data,presentation}`; the one shared widget goes to `lib/core/widgets/`. `presentation` imports `domain` only — the new predicate lives in `domain/sale_workability.dart`, not in the screen. |
| **II. Riverpod** | PASS | New state is one `@riverpod` list controller family plus a freezed filter; no new DI. Local UI state (band mode) stays plain `State`. |
| **III. Contract-driven API** | PASS | No hand-written DTO: the new repository call uses the generated `listSalesOrdersApiV1SalesOrdersGet` and maps to the existing `OpenSale` freezed entity. The one backend gap (product `photo`) is **not** patched from here — it is recorded as an external dependency and filed as an mbe-api issue, per the repo-boundary rule. |
| **IV. Deny-by-default RBAC** | PASS | Routes keep the existing `(pos, read)` gate via `startsWith('/sales/pos')`. Edit is absent without `salesOrders` update; "Nueva venta" is absent without `pos` create; the customer-create action keeps its `customers` create gate. |
| **V. Material 3, white-labeled** | PASS | Material 3 only; every value from the theme and the spec 022 tokens (FR-048); the mock's dark palette is explicitly not adopted. New copy added to both `.arb` files, `es-MX` first. |
| **VI. Desktop-first, compact-ready layout** | PASS **with two recorded deviations** | The list uses the shared `CatalogFilterBar`/`DataTableView`/pagination/filtering, one Edit row action from `catalog_action_icons.dart`, right-aligned money, no truncation of critical columns, and the click-to-view rule (see below). The two deviations are in Complexity Tracking. |
| **VII. Online-only** | PASS | No caching layer; provider memoization only. No client-side photo fetching (which would also have been a de-facto cache). |

### The one gate that initially failed, and how it was resolved

§VI requires that clicking a row outside the Edit icon opens that record
**read-only** — "a stray click MUST NOT risk an unintended edit". The approved
spec had put read-only sale viewing out of scope, which would have left the new
list with no row click at all.

Resolved without a new screen: a row click opens `/sales/pos/:saleId`, and the
workspace already renders read-only for any sale past draft (`Sale.isEditable`,
`posSaleReadOnlyBanner`, `enabled: false` throughout — spec 020 FR-041). The spec
was amended during planning (FR-006a, FR-019, US1 scenario 6a, and the Assumptions
entry) rather than the rule being bent. See [research R4](./research.md).

## Project Structure

### Documentation (this feature)

```text
specs/023-pos-ux-improvements/
├── plan.md              # This file
├── spec.md              # Amended during planning (FR-006a, FR-019)
├── research.md          # Phase 0 — R1..R15, U1..U3
├── data-model.md        # Phase 1 — view state, the workability predicate, keys
├── quickstart.md        # Phase 1 — run/validate guide, 22 manual checks
├── contracts/
│   ├── pos-sales-list.md   # the list screen
│   ├── pos-workspace.md    # routes, chrome, space rules, gate, leaving
│   └── capture-surface.md  # customer band, product field, line row, footer
├── checklists/
│   └── requirements.md
└── tasks.md             # Phase 2 — NOT created by /speckit-plan
```

### Source code

```text
lib/
├── app/router/app_router.dart                 # MODIFIED: /sales/pos → list;
│                                              #   + /sales/pos/new, /:saleId
├── core/widgets/
│   └── date_range_filter_chip.dart            # NEW (shared; needs a golden)
└── features/sales/
    ├── domain/
    │   ├── entities/open_sale.dart             # reused as the list row (§1 data-model)
    │   ├── repositories/sales_order_repository.dart  # MODIFIED: + listSales()
    │   └── sale_workability.dart               # NEW: saleIsWorkable()
    ├── data/
    │   └── sales_order_repository_impl.dart    # MODIFIED: + listSales(), wireDate()
    └── presentation/
        ├── pos_sales_list_screen.dart          # NEW
        ├── pos_sales_list_controller.dart      # NEW (+ PosSalesFilter)
        ├── pos_workspace_screen.dart           # NEW (absorbs PosScreen's body)
        ├── pos_screen.dart                     # DELETED (split into the two above)
        ├── pos_header_band.dart                # DELETED (into the app bar title)
        ├── open_sales_selector.dart            # MODIFIED: renders in the app bar
        └── capture/
            ├── capture_step.dart               # MODIFIED: insets, one footer band
            ├── customer_bar.dart               # MODIFIED: two faces, terms dropdown
            ├── fulfillment_mode_selector.dart  # MODIFIED: placement only
            ├── product_search_field.dart       # MODIFIED: search-as-you-type
            ├── sale_line_row.dart              # MODIFIED: one-row layout
            ├── sale_line_card.dart             # MODIFIED: thumbnail slot only
            ├── sale_line_layout.dart           # NEW: thresholds in one place
            └── sale_totals_bar.dart            # MODIFIED: footer band + action

test/
├── golden/
│   ├── core_widgets_golden_test.dart           # MODIFIED: + the new chip (scan!)
│   └── pos_capture_golden_test.dart            # NEW
├── unit/features/sales/pos_sale_workability_test.dart      # NEW
├── unit/app/router/app_router_test.dart        # MODIFIED
├── widget/features/sales/
│   ├── pos_test_harness.dart                   # MODIFIED: routed pump + listSales
│   ├── pos_sales_list_screen_test.dart         # NEW
│   ├── pos_workspace_route_test.dart           # NEW
│   ├── product_search_field_test.dart          # NEW
│   ├── sale_totals_bar_test.dart               # NEW
│   ├── customer_bar_test.dart                  # MODIFIED
│   ├── sale_line_row_test.dart                 # MODIFIED
│   └── pos_compact_*.dart                      # MODIFIED: routed workspace
└── integration/pos_sales_list_flow_test.dart   # NEW (live backend)

lib/l10n/app_es.arb, app_en.arb                 # MODIFIED: ~30 new keys
```

**Structure Decision**: the existing feature-first layout is kept exactly. The
only structural change is the split of `pos_screen.dart` into a list screen (in
the shell branch) and a workspace screen (a top-level route) — which mirrors how
every other entity in this codebase is already arranged, and is what makes the
full width available.

## Phase sequencing

Ordered so each phase leaves the app working, and so the two P1 stories land
before the polish:

1. **Data & domain** — `listSales`, `wireDate` extraction, `saleIsWorkable`,
   `PosSalesFilter`, `PosSalesListController`. Verify: unit tests green.
2. **US1, the list** — `PosSalesListScreen`, the `DateRangeFilterChip` (+ its
   golden and scan entry), l10n. Verify: list widget test green; the screen
   renders at `/sales/pos`.
3. **US2, the routes and workspace** — split `pos_screen.dart`, delete
   `pos_header_band.dart`, wire the two routes, the gate, the URL rewrite, the
   unreachable panel, the space rules. Verify: route/layout widget tests, router
   test, and the existing POS flow tests still green.
4. **US3, the customer band** — two faces, resolved name, terms dropdown, mode
   selector placement, insets. Verify: `customer_bar_test.dart`.
5. **US4, the product field** — debounce + submit paths + request numbering.
   Verify: `product_search_field_test.dart`, and the counter-sale flow test
   (which scans) still green.
6. **US5/US6, line and footer** — `sale_line_layout.dart`, the single row, the
   thumbnail slot, the footer band. Verify: line/footer widget tests, the 1024-px
   case, goldens reviewed.
7. **Close-out** — the live integration test, the mbe-api issue for `photo`,
   golden review, `flutter analyze` clean.

## Complexity Tracking

> Two deliberate divergences from constitution §VI, both recorded rather than
> waved through.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|---|---|---|
| The workspace opts out of centring and of `spacing.contentMaxWidth`, which §VI's responsive-form rule and the token scale otherwise imply for wide tiers | The feature exists because the capture surface is starved of width; a bounded, centred column at the `large` tier would reproduce the exact complaint (one line visible, dead space) on the widest displays | Keeping the bound and merely trimming paddings — measured against the mock's frame `2a`, the fixed line columns alone need ~944 px, so a bounded column defeats the single-row layout and FR-037a with it. §VI's rule addresses **forms**; this is a working table, and it is the one screen in the product where edge-to-edge is the requirement |
| The workspace's app bar title carries an interactive control (the open-sales selector), where §VI (v1.10.0) keeps screen-level actions in the body and `AppBar.actions` empty | Switching between two open sales at a busy counter must not require leaving the sale; spec 020 FR-004 shipped this control and the mock places it exactly there. `actions` **is** kept empty — the selector, identity chip and step indicator are title-area content, and Back is `leading` | A body-placed switcher costs a band of vertical space, which is the resource this feature is reclaiming — it would undo FR-016. Deleting the switcher outright was considered: the list replaces it for *finding* a sale but not for hopping between two, so removal is a regression the list does not cover |

Neither deviation touches the rules the constitution added after real incidents
(row actions, truncation, pagination, filtering, RBAC absence-not-disabled) — the
list screen follows all of those literally.

## Post-Design Constitution Re-Check

Re-evaluated after Phase 1. All seven principles still **PASS**, with the two
deviations above tracked. Three things were tightened by the design work:

- **§VI click-to-view** — resolved without a new screen (see the gate note
  above); the spec was amended, not the rule.
- **§VI shared components** — the date-range filter turned out to be the first in
  the product, so it becomes a `core/widgets/` component with a golden rather
  than a screen-local widget. Spec 022's directory-scan test enforces this
  mechanically, which is why it is called out as a task and not left implicit.
- **§III repo boundary** — the thumbnail's missing `photo` field is recorded as an
  external mbe-api dependency with an issue to file; the reserved-slot approach
  means nothing in this feature waits on it.

No unresolved `[NEEDS CLARIFICATION]` remains in the spec. Three research
questions are open and none blocks implementation: what `search` matches, whether
`date_to` is day-inclusive (both settled by the live integration test), and
whether mbe-api will expose `photo` (the placeholder ships regardless).
