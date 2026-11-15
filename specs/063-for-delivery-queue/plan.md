# Implementation Plan: For Delivery Queue

**Branch**: `063-for-delivery-queue` | **Date**: 2026-11-15 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/063-for-delivery-queue/spec.md`

Roadmap: Closes mictlanix/mbe-roadmap#40.

**Upstream.** Nothing blocks this feature. The endpoint is already in the generated client (research R1), and it needs no server setting.

## Summary

The back office gets "Por entregar" in the Logística group: every delivery line in En preparación still waiting to be loaded, across all active facilities, highest priority first. A single-select "Periodo" filter in the shared filter panel picks one of the server's six date buckets, defaulting to Hoy, with each period's count in the panel. Rows open the spec 061 order detail. The screen is read-only.

**Technical approach.**
- **Data.** A new `DeliveryItineraryRepository` with one method over the generated pending-deliveries endpoint. It's the home roadmap#41 will extend (R2).
- **State.** A `PendingDeliveriesFilter` (period + page) in the URL (R3), and an `AsyncNotifier` family keyed by `(period, page)` that keeps every bucket's total and date from the same response for the panel (R4).
- **Panel.** The existing dropdown facet pattern, without an "all" item (R5).
- **Reload.** On return from the order detail, the controller is invalidated (R6). No refresh button.
- **Names.** Spec 061's customer cell, a ship-to address cell extracted from `DeliveryOrderShipTo`, and a warehouse cell over the catalog's `warehouseDisplayNameProvider` (R7).

## Technical Context

**Language/Version**: Dart `^3.10.3`, Flutter stable (unchanged)

**Primary Dependencies**:
- Riverpod 3 (riverpod_generator), `go_router`, `data_table_2`, freezed, and the generated `mbe_api_client`.
- No new packages, and no client regeneration.

**Storage**: N/A (online-only, §VII)

**Testing**:
- `flutter_test` + `mocktail` with `ProviderScope` overrides.
- Templates: spec 062's `delivery_order_approval_queue_controller_test.dart`, `delivery_order_approval_screen_test.dart`, `delivery_order_approval_quickstart_test.dart`; spec 061's `delivery_orders_filter_test.dart`.

**Target Platform**: web and desktop first, with a compact tier required (§VI)

**Project Type**: Flutter client application, feature-first layered

**Performance Goals**:

| Action | Requests |
|---|---|
| Open, change period or page, return from detail | 1, plus the cached customer and warehouse name lookups |
| Open the filter panel | 0 (counts come from the loaded state) |

**Constraints**:
- Spacing comes from tokens.
- Every string goes in both `.arb` files.
- Dates and quantities go through `formattersProvider`.
- Format only the changed files.

**Scale/Scope**:

| | Files |
|---|---|
| **New source (≈8)** | `domain/entities/pending_delivery.dart` (period enum, line, result), `domain/repositories/delivery_itinerary_repository.dart`, `data/delivery_itinerary_repository_impl.dart`, `presentation/for_delivery/{pending_deliveries_screen, pending_deliveries_controller, pending_deliveries_filter}.dart`, plus generated parts |
| **New tests (≈5)** | unit: `pending_deliveries_filter_test`, `pending_deliveries_controller_test`, `delivery_itinerary_repository_impl_test`; widget: `pending_deliveries_screen_test`; live: `integration_test/for_delivery_quickstart_test.dart` |
| **Edited source (≈5)** | `presentation/delivery_orders/delivery_order_name_cells.dart` (C8), `core/navigation/nav_destinations.dart`, `app/router/app_router.dart`, both `.arb` files |
| **Edited tests (≈3)** | `nav_destinations_test`, `app_router_test`, a name-cell test for the extracted address cell |

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

These verdicts are against **v1.15.0**.

| Principle | Verdict | How |
|---|---|---|
| **I. Feature-first layering** | Pass | Everything is in `features/sales/{domain,data,presentation}`, beside specs 061 and 062. The screen gets its own `presentation/for_delivery/` folder. Presentation reaches data only through the repository provider. |
| **II. Riverpod** | Pass | The list is an `AsyncNotifier` family keyed by period and page; both are URL state. No writes, so no actions notifier. |
| **III. Contract-driven API** | Pass | Only the generated operation is used. **API error text:** the endpoint returns only generic codes (`auth.forbidden`, `auth.not_authenticated`), already localized (R11). No new codes, no TSV change. **Upstream:** no gap. |
| **IV. Deny-by-default RBAC** | Pass | Nav entry and route gate on ForDeliver (91) read; the route and nav entry document 91 in code. Row tap needs DeliveryOrders (71) read, because it opens a 71-gated route. No mutating actions. **Facility scoping:** the endpoint is cross-facility by design (as the legacy screen) and takes no facility parameter, so there is nothing a client could widen. The controller documents that, as spec 062's does (R4). |
| **V. Material 3 / design system** | Pass | Shared components only: `CatalogFilterBar`, `showCatalogFilterSheet`, `DataTableView`, `CatalogPagination`, `CatalogListStateView`, spec 061's name cells. The dropdown facet is the pattern the existing panels use (R5). **Largest text level:** quickstart step 11. |
| **VI. List and record-surface rules** | Pass | **List:** filter row, list, pagination. **Filtering:** the period facet lives in the shared drawer, not inline; the search box is omitted because the endpoint has no search. **Row actions:** none — the queue is read-only, the same reading specs 060/062 used for their queues' missing Edit. **Record surface:** the row opens the order's one existing surface, the spec 061 detail screen. |
| **VII. Online-only** | Pass | Nothing is persisted. |
| **Quality gates** | Pass | Unit, widget and live tests in R12. `flutter analyze` must be clean. |

**Post-design re-check** (after Phase 1): unchanged.
- No `core/` widget changes; `core/navigation` gains one destination.
- One refactor of spec 061 code: `DeliveryOrderShipTo`'s delivery branch moves into `DeliveryOrderCustomerAddress` (C8). No visible change; spec 061/062 screen tests are the guard.
- No deviation needs Complexity Tracking.

## Project Structure

### Documentation (this feature)

```text
specs/063-for-delivery-queue/
├── spec.md                # /speckit-specify (2026-11-15)
├── wireframes.md          # /speckit-wireframes-draft (Open Questions resolved in research R5, R9, R10)
├── plan.md                # This file
├── research.md            # Phase 0 (R1–R12)
├── data-model.md          # Phase 1
├── quickstart.md          # Phase 1
├── contracts/
│   └── ui-contracts.md    # Phase 1 (C1–C9)
├── checklists/
│   └── requirements.md
└── tasks.md               # /speckit-tasks (not yet)
```

### Source Code (repository root)

```text
lib/features/sales/
├── domain/
│   ├── entities/pending_delivery.dart                       # period enum, line, result (data-model §1–3)
│   └── repositories/delivery_itinerary_repository.dart      # C6
├── data/delivery_itinerary_repository_impl.dart             # C6
└── presentation/
    ├── for_delivery/                                        # new
    │   ├── pending_deliveries_screen.dart                   # C2–C5
    │   ├── pending_deliveries_controller.dart               # C7
    │   └── pending_deliveries_filter.dart                   # data-model §4
    └── delivery_orders/delivery_order_name_cells.dart       # + DeliveryOrderCustomerAddress (C8)
lib/core/navigation/nav_destinations.dart                    # NavBranch 28 + Logística entry (C1)
lib/app/router/app_router.dart                               # branch + _routeGate clause (C1)
lib/l10n/app_{es,en}.arb                                     # C9
test/unit/features/sales/…, test/widget/features/sales/…, integration_test/for_delivery_quickstart_test.dart
```

**Structure Decision**: a single Flutter app. The queue is a sibling presentation folder of `delivery_orders/` and `delivery_order_approval/`, reusing their name cells. The new repository is the start of the itineraries data layer that roadmap#41 extends.

## Dependencies and risks

- **Cross-facility list.** Staff see lines from every active facility. This matches legacy and the server, and rows show the warehouse. If the business wants it scoped, that's an mbe-api change (a facility parameter) and a follow-up here; not filed.
- **Server-side "today".** Buckets follow the server's date. If the server and the user are in different time zones, the edges shift; the bucket dates shown in the panel make that visible. Not addressed here.
- **Shared paging across buckets.** Each request carries a page of all six buckets and discards five. At limit 20 the waste is small; if it ever matters, a `bucket` parameter upstream would fix it.
- **Itinerary commits change the queue.** Until roadmap#41 ships there is no UI that commits lines, so in practice the queue changes only through spec 061/062 actions and other users.

## Complexity Tracking

No constitution violations need justification.
