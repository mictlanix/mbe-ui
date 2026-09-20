# Implementation Plan: Fix List Origin Filtering and Cash Session List Refresh

**Branch**: `041-fix-list-origin-refresh` | **Date**: 2026-09-20 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/041-fix-list-origin-refresh/spec.md`

## Summary

Three fixes that share no code but share a shape: each is a place where data the
app already holds never reaches the screen that needs it.

1. **The two sales lists gain an origin facet.** Spec 039 recorded an order's
   originating workflow but deliberately left both list screens blind to it
   (OS-2), pending a backfill policy. That policy question dissolves once the
   filter is expressed as *exclusion* rather than *inclusion*: mbe-api's
   `exclude_origin` parameter — which shipped with the origin field itself, and
   whose doc comment names the register's own list as the caller it exists for —
   keeps orders with no recorded origin visible under every filter state. No
   backfill is needed, and no order predating spec 039 ever disappears.
2. **Both lists gain a per-row origin indicator.** The list endpoint's response
   projection (`SalesOrderSummary`) already carries `origin`; the domain entity
   the lists render (`OpenSale`) simply never mapped it.
3. **The cash sessions history list refreshes after an open or a close.** This
   is not a new mechanism: "the form controller invalidates the list family
   after a successful write" is already the house pattern across eight other
   form controllers. The two cash-session form controllers are the outliers —
   they invalidate only `currentSessionControllerProvider`.

The dependency that blocked spec 039 is gone: **mbe-api#209 has shipped**, the
client is already regenerated, and `origin`/`exclude_origin` are present on the
generated list method today. This feature therefore has **no external
dependencies** and requires **no codegen re-run** beyond `freezed` for one new
entity field.

The only genuine design question is where the per-row indicator goes without
pushing either six-column table into horizontal scroll — resolved in research
R5, and pinned by an overflow test rather than by eye.

## Technical Context

**Language/Version**: Dart 3.x / Flutter (stable channel)

**Primary Dependencies**: `flutter_riverpod` 2.6.1 + `riverpod_generator` 2.6.4
(codegen), `go_router`, `freezed`, `dio` via the generated `mbe_api_client`
(`lib/generated/openapi`), `flutter_localizations` + `intl`, `mocktail` (tests)

**Storage**: None client-side (constitution VII — online only). Filter state
lives in the URL query, not in local storage.

**Testing**: `flutter_test` (unit + widget), `integration_test` against a live
mbe-api. The established widget-test fake pattern is `mocktail` +
`ProviderContainer(overrides:)` pumped through `UncontrolledProviderScope` —
which matters here, because holding the container is what lets a test assert a
*re-fetch count* (the only honest way to test fix 3).

**Target Platform**: Web and desktop first, compact tier supported —
constitution VI

**Project Type**: Single Flutter application; feature-first layering under
`lib/features/sales/`

**Performance Goals**: No new budget. The origin facet adds one query parameter
to a call the screens already make — no extra round trip. The cash-session fix
adds exactly one re-fetch per successful open/close, and none on cancel.

**Constraints**:

- An order with no recorded origin MUST remain visible in both lists under
  every filter state (FR-005, SC-003). This is the constraint that dictates
  `exclude_origin` over `origin`, and it is the whole reason this feature can
  ship without a backfill.
- Both lists' default (unfiltered) behaviour must be observably unchanged
  (FR-012, SC-005).
- Point-of-sale and back-office *capture* behaviour is untouched; this feature
  is read-side only, plus two one-line invalidations.

**Scale/Scope**: ~13 files. One domain entity gains a nullable field, two filter
classes gain a facet, two repository methods gain a parameter (interface +
impl), two list controllers forward it, two screens gain a drawer chip and a
column, one new shared-pattern chip widget, two `.arb` files, and two cash
session form controllers gain one line each. Roughly 8 test files affected or
added.

**External dependencies**: **None.**
[mbe-api#209](https://github.com/mictlanix/mbe-api/issues/209) — recorded as an
open blocker in spec 039's plan — has since shipped and is already reflected in
the generated client (`origin` and `exclude_origin` on
`listSalesOrdersApiV1SalesOrdersGet`; `origin` on `SalesOrderSummary`). Verified
against the checked-in generated sources, not assumed. No mbe-api issue needs
filing for this feature.

## Constitution Check

*GATE: evaluated before Phase 0 and re-evaluated after Phase 1.*

| Principle | Verdict | Notes |
|---|---|---|
| **I. Feature-first layered architecture** | PASS | Everything lands under `lib/features/sales/`. `presentation` continues to depend only on `domain`. `OpenSale` gains a field; no entity is redefined or relocated. |
| **II. Riverpod for state & DI** | PASS | Fix 3 *is* a Riverpod fix, and it adopts the repo's existing majority pattern (family invalidation from the form controller) rather than inventing a navigation-result seam. Filter state stays in the URL-derived family key, as both lists already do. |
| **III. Contract-driven API integration** | PASS | No hand-written DTO. No codegen re-run required — the client already carries both parameters and the response field. `freezed` regeneration only, for `OpenSale`'s new field. No sibling-repo edit; no backend gap to file. |
| **IV. Deny-by-default RBAC** | PASS | Read-side only. No new mutable action, so no new `can()` gate. The existing route gates (`SystemObject.pos`, `SystemObject.salesOrders`) are unchanged, and the origin facet does not widen what any user can see — `exclude_origin` only ever narrows a result set the caller was already entitled to. |
| **V. Material 3, white-labeled design system** | PASS | The new origin chip wraps the shared `StatusChip<T>` rather than styling a `Chip` directly. All new strings go to both `.arb` files. No new formatting path — dates/currency on these rows already go through `formattersProvider`. The new column must be verified at the **largest** of the four text-size levels (see R5). |
| **VI. Desktop/web-first, compact-ready** | PASS with a verified risk | The origin facet goes *behind the shared filter drawer* (v1.11.0 rule (a)) — both screens already use `showCatalogFilterSheet`, so this is the compliant path, not an exception. The risk is the anti-horizontal-scroll rule: both tables already render 6 columns plus a 150 px action column. R5 sizes the addition and T-numbered tasks pin it with an overflow test at desktop width and at the largest text scale. |
| **VII. Online-only, server-rendered documents** | PASS | No caching layer is added. The cash-session fix is a re-fetch from mbe-api, not a local cache update. |
| **Quality gates** (unit / widget / integration) | PASS | All three layers apply: unit for filter decode/badge counts and repository parameter forwarding, widget for the drawer chip, the column, and the re-fetch-after-write regression, integration for the live round trip on both lists and the cash-session open→close cycle. |

**No violations. Complexity Tracking is therefore omitted.**

**Post-design re-check (after Phase 1)**: verdicts unchanged. Phase 1 added no
component that was not already anticipated — one chip widget wrapping a shared
one, one entity field, one repository parameter, two invalidation lines. Two
obligations hardened into testable form rather than staying advisory: the
column-budget risk under VI/V is now pinned by a named overflow assertion at the
largest text-size level (contracts/origin-filter.md §5), and fix 3's correctness
is pinned by a re-fetch-count assertion rather than a rendered-row one
(contracts/list-refresh.md §6). One item of scope was explicitly *declined*
during design: promoting the thrice-duplicated private `_TriStateFilterChip` to
`core/widgets/` — real cleanup, unrelated to this feature, recorded in research
R3 rather than absorbed (CLAUDE.md §3, surgical changes).

One point deserves explicit note rather than a silent pass. Fix 3's smallest
possible change would be to hang an `await` on the shift sheet and invalidate on
dismiss. That is rejected on constitution II grounds *and* on evidence:
`showAppSideSheet`'s own doc comment says it returns nothing and that callers
needing to react should read provider state instead; no caller in `lib/` awaits
it; and, decisively, the **close** path does not even go through that sheet (see
R6). Invalidating from the two form controllers fixes both paths at their
source, matches eight existing precedents, and leaves the cancel case correct
for free.

## Project Structure

### Documentation (this feature)

```text
specs/041-fix-list-origin-refresh/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
│   ├── origin-filter.md     # The facet, its URL form, and its server mapping
│   └── list-refresh.md      # Who invalidates which list family, and when
├── checklists/
│   └── requirements.md  # Written by /speckit-specify
└── tasks.md             # Phase 2 output (/speckit-tasks — NOT created here)
```

### Source Code (repository root)

```text
lib/
├── features/sales/
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── open_sale.dart              # + SaleOrigin? origin, + mapping
│   │   │   └── sale_origin.dart            # unchanged (enum + fromApi/toApi)
│   │   └── repositories/
│   │       └── sales_order_repository.dart # + excludeOrigin on 2 declarations
│   ├── data/
│   │   └── sales_order_repository_impl.dart# + excludeOrigin on 2 impls
│   └── presentation/
│       ├── pos_sales_list_controller.dart      # + facet on PosSalesFilter
│       ├── pos_sales_list_screen.dart          # + drawer chip, + column
│       ├── orders/
│       │   ├── sales_orders_list_controller.dart # + facet on SalesOrdersFilter
│       │   └── sales_orders_list_screen.dart     # + drawer chip, + column
│       ├── widgets/
│       │   ├── pos_sale_status_chip.dart       # existing precedent to mirror
│       │   └── sale_origin_chip.dart           # NEW — wraps shared StatusChip
│       ├── open_session_form_controller.dart   # + 1 invalidate line
│       └── close_session_form_controller.dart  # + 1 invalidate line
├── core/widgets/
│   ├── status_chip.dart          # reused as-is
│   ├── data_table_view.dart      # reused as-is
│   └── catalog_filter_sheet.dart # reused as-is
└── l10n/
    ├── app_en.arb                # + origin strings (with "@key" stubs)
    └── app_es.arb                # + origin strings

test/
├── unit/features/sales/
│   ├── pos_sales_filter_test.dart          # + origin decode/badge cases
│   ├── sales_orders_filter_test.dart       # + origin decode/badge cases
│   └── sales_order_repository_impl_test.dart # + excludeOrigin forwarding
├── widget/features/sales/
│   ├── pos_sales_list_screen_test.dart     # + facet, column, overflow
│   ├── sales_orders_filters_test.dart      # + facet
│   ├── sales_orders_list_screen_test.dart  # + column
│   └── cash_sessions_screen_test.dart      # + re-fetch-after-open/close
└── integration/
    ├── pos_sales_list_flow_test.dart       # + live exclude_origin round trip
    └── cash_session_flow_test.dart         # existing open→close cycle
```

**Structure Decision**: No new module, layer or shared component beyond one chip
widget, which lands beside its existing sibling in
`lib/features/sales/presentation/widgets/`. The chip is a thin wrapper over the
shared `core/widgets/status_chip.dart` exactly as `PosSaleStatusChip` is, so the
"implement shared visual behaviour once" rule (constitution VI) is satisfied by
reuse rather than by a fourth parallel implementation.

## Complexity Tracking

Not applicable — the Constitution Check records no violations.
