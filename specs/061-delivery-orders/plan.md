# Implementation Plan: Delivery Orders

**Branch**: `061-delivery-orders` | **Date**: 2026-11-14 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/061-delivery-orders/spec.md`

Roadmap: Closes mictlanix/mbe-roadmap#38.

Upstream: none of these block the feature. Every endpoint used already exists in the generated client.

| Issue | Filed | What it changes here |
|---|---|---|
| mbe-api#311 | during specify | Cancelling an order on an open itinerary blocks departure. The risk is accepted. **Fixed 2026-11-14** (mbe-api PR #320): the server refuses that cancel with `delivery_order.on_itinerary`, shown as a localized refusal (fix/consume-mbe-api-308-314). |
| mbe-api#312 | during plan | Multi-status list filter. Until it ships, the list opens on every status rather than "Activas" (R3). **Shipped 2026-11-14** (mbe-api PR #315): the list opens on "Activas"; "Todas" is `status=all` (fix/consume-mbe-api-308-314). |
| mbe-api#313 | during plan | Deliverable-lines query. Until it ships, add-line computes what's left on the client (R8). **Shipped 2026-11-14** (mbe-api PR #318): step 2 reads `GET /delivery-orders/deliverable-lines`; the client computation is deleted (fix/consume-mbe-api-308-314). |
| mbe-api#314 | during analysis | Delivery-order reads aren't facility-checked. Until it ships, the app decodes the facility facet only for administrators, twice (R3). **Fixed 2026-11-14** (mbe-api PR #321): the server checks the facility on the list and on every read and write by id. The client drop stays as defence in depth (fix/consume-mbe-api-308-314). |

## Summary

The back office gets "Órdenes de entrega", a list of the facility's delivery orders and a full detail screen per order.
- **Drafts** coming from the POS can have their header and lines corrected, and then be confirmed. Confirming assigns the folio and sends the order to approval, preparation or pickup.
- **Status actions:** cancel (with a reason), requeue a failed delivery, and hand over a pickup order (ready, then picked up with receiver, identification and photo).
- **The detail screen** also shows the order's status history and its proof of delivery.

**Technical approach:**
- **Data:** a new `DeliveryOrderAdminRepository` over the existing generated `DeliveryOrdersApi`, with new freezed back-office entities. The POS `Destination` is left as it is, and the two enums are reused (R2).
- **List:** a URL-backed `DeliveryOrdersFilter`. "Every status" is the interim opening state (R3). Names come from the existing per-id providers, falling back to `#id` (R4).
- **Detail:** order and events load in parallel. The proof loads only when present, with its image as checked PNG bytes (R5).
- **Writes:** a keep-alive `DeliveryOrderActions` notifier. Each action returns `AppError?` and invalidates the order, its events and the list (R6). Pickup uploads through `file_picker` and `MultipartFile.fromBytes`, as spec 051 does.
- **Add line:** a two-step dialog, sale first and then its remaining lines. `SalesOrderRepository.listOrders` gains `customer` (R8).
- **Errors:** four new localized codes and a `_dateTime` placeholder helper (R10).
- **POS fix:** `listForSale` drops cancelled destinations, so a back-office cancel frees the sale's quantities in the POS too (R9).

## Technical Context

**Language/Version**: Dart `^3.10.3`, Flutter stable (unchanged)

**Primary Dependencies**:
- Riverpod 3 (riverpod_generator), freezed, `go_router`, `data_table_2`, `file_picker` (already a dependency), `decimal`, and the generated `mbe_api_client`.
- No new packages, and no client regeneration.

**Storage**: N/A (online-only, §VII)

**Testing**:
- `flutter_test` + `mocktail` with `ProviderScope` overrides.
- Templates: `refunds_list_screen_test.dart`, `refund_detail_screen_test.dart`, `refunds_filter_test.dart`, `delivery_order_repository_impl_test.dart`, `vehicle_operator_repository_impl_test.dart` (multipart, PNG).
- One live test, `integration_test/delivery_orders_quickstart_test.dart` (R12).

**Target Platform**: web and desktop first, with a compact tier required (§VI)

**Project Type**: Flutter client application, feature-first layered

**Performance Goals**:

| Action | Requests |
|---|---|
| List page | 1, plus cached per-customer and per-facility name lookups |
| Detail | 2 in parallel (order, events) |
| Detail, more | +2 if there's a proof (metadata, image); +k sales for the Pedido column when the order covers k > 1 sales; +1 list for a partially delivered order's children |
| Add line | step 1: 1 per page; step 2: 1 sale + 1 list + 1 per delivery order of that sale |
| Action | 1 write, then the order and events refetch |

**Constraints**:
- Use `Decimal` and `formattersProvider` only.
- Spacing comes from tokens.
- Every string goes in both `.arb` files.
- Format only the changed files.
- Status names come from l10n, never from `enum.name`.

**Scale/Scope**:

| | Files |
|---|---|
| **New source (≈15)** | `domain/entities/delivery_order.dart`, `presentation/delivery_orders/delivery_order_name_cells.dart` (shared name fallbacks, R4), `domain/entities/deliverable_lines.dart`, `domain/repositories/delivery_order_admin_repository.dart`, `data/delivery_order_admin_repository_impl.dart`; `presentation/delivery_orders/{delivery_orders_list_screen, delivery_orders_filter, delivery_orders_list_controller, delivery_order_detail_screen, delivery_order_detail_controller, delivery_order_actions, delivery_order_status_chip, delivery_order_dialogs, add_line_dialog, pickup_dialog, header_dialog}.dart`; plus generated parts |
| **New tests (≈15)** | unit: `delivery_orders_filter_test`, `delivery_orders_scoping_test`, `delivery_orders_list_controller_test`, `delivery_order_detail_controller_test`, `delivery_order_admin_repository_impl_test`, `delivery_order_actions_test`, `deliverable_lines_test`; widget: `delivery_order_status_chip_test`, `delivery_orders_list_screen_test`, `delivery_order_detail_screen_test`, `add_line_dialog_test`, `pickup_dialog_test`, `header_dialog_test`, `delivery_order_dialogs_test`; live: `integration_test/delivery_orders_quickstart_test.dart` |
| **Edited source (≈9)** | `data/delivery_order_repository_impl.dart` (R9, shared quantity helper), `domain/repositories/sales_order_repository.dart` + `data/sales_order_repository_impl.dart` (`customer` on `listOrders`), `core/navigation/nav_destinations.dart`, `app/router/app_router.dart`, `core/errors/localize_problem.dart`, both `.arb` files, `specs/058-…/contracts/code-scope.tsv` (4 rows to `IN`) |
| **Edited tests (≈4)** | `delivery_order_repository_impl_test`, `sales_order_repository_impl_test`, `catalog_coverage_test`, `problem_fixtures` |

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

These verdicts are against **v1.15.0**.

| Principle | Verdict | How |
|---|---|---|
| **I. Feature-first layering** | Pass | Everything is in `features/sales/{domain,data,presentation}`. Presentation reaches data only through repository providers. The remaining-quantity computation is a pure domain function (`deliverable_lines.dart`). |
| **II. Riverpod** | Pass | The list is an `AsyncNotifier` family keyed by filter. The detail is a family keyed by id. Writes go through one keep-alive notifier, and the filter is URL state. |
| **III. Contract-driven API** | Pass | Only generated operations are used. **API error text:** of the codes the newly called endpoints can return, four lack messages: `insufficient_notice`, `no_lines`, `not_failed`, `proof_incomplete`. They're added in both locales and flipped to `IN`. R10 lists every code each new endpoint can return, new or already localized, as the workflow gate requires. **Upstream:** the three server gaps are mbe-api issues (#311–#313), not local patches. The client's remaining computation (R8) is a temporary, documented mirror of `_covered_quantities`, and the server still bounds every add. |
| **IV. Deny-by-default RBAC** | Pass | The route and nav are gated on DeliveryOrders (71) read. Every edit and status action needs 71 update and is absent without it. Add-line also needs SalesOrders read, for the sale picker (R1, R8). The route and nav entry document 71 in code. **Facility scoping:** the server doesn't check `facility` on reads (mbe-api#314), so the list decodes the facility facet only for administrators, in the filter and again in the fetch, with a scoping test, as Pedidos does (R3). |
| **V. Material 3 / design system** | Pass | Shared components only: `CatalogFilterBar`, `CatalogSearchBar`, `showCatalogFilterSheet`, `DataTableView`, `CatalogPagination`, `CatalogListStateView`, `StatusChip`, `FactStripRow`, `CompactField`, `ResponsiveFormGrid`, `ResponsiveDialog`, `FormErrorBanner`, `CatalogEntityPicker`, `DateRangeFilterChip`, `buildCatalogRowActions`, plus the POS address and contact pickers. **Largest text level:** both tables are checked at the largest size in the walkthrough (quickstart step 12). |
| **VI. List and record-surface rules** | Pass (reading recorded) | **List:** a filter row, a table and pagination. The search takes digits, the facets are in the drawer, and the filter row holds no count. **Surface:** a full detail screen, because the order owns a child collection (lines) and linked sections (history, proof) and needs a URL for parent and child links. **AppBar actions:** empty; every action is in the body's action area. **No row Edit icon, no View toggle:** §VI's Edit-on-row and read-only-then-Edit rules are written for catalog records. A delivery order is a document with a status lifecycle, where only the draft status can be edited. This follows the established document screens. Reembolsos (spec 057) opens a detail on row tap and edits a draft in place. Notas de crédito (spec 056) and Reembolsos both show list rows with no row icons. Draft line rows use `buildCatalogRowActions`, ✎ and 🗑 within the two-icon limit. **Delete:** there's none. Cancel is a status action with a reason, not a delete. |
| **VII. Online-only** | Pass | Nothing is persisted. The proof image is held in memory only. |
| **Quality gates** | Pass | Unit, widget and live tests are listed in R12. `flutter analyze` must be clean, and catalog coverage is enforced by `catalog_coverage_test.dart`. |

**Post-design re-check** (after Phase 1): unchanged.
- Two `core/` touches: `localize_problem.dart`, which the catalog rule requires, and a small private `_dateTime` helper inside it.
- Two shared repository touches: an optional `customer` parameter on `listOrders`, with every existing caller unchanged, and the R9 filter in `listForSale`.
- No deviation needs Complexity Tracking.

## Project Structure

### Documentation (this feature)

```text
specs/061-delivery-orders/
├── spec.md                # /speckit-specify (2026-11-14), amended in plan (R3, R7, R8)
├── wireframes.md          # /speckit-wireframes-draft
├── plan.md                # This file
├── research.md            # Phase 0 (R1–R12)
├── data-model.md          # Phase 1
├── quickstart.md          # Phase 1
├── contracts/
│   └── ui-contracts.md    # Phase 1 (C1–C12)
├── checklists/
│   └── requirements.md
└── tasks.md               # /speckit-tasks (not yet)
```

### Source Code (repository root)

```text
lib/features/sales/
├── domain/
│   ├── entities/delivery_order.dart                  # new: summary, order, line, event, proof
│   ├── entities/deliverable_lines.dart               # new: DeliverableLine + pure computation (R8)
│   └── repositories/
│       ├── delivery_order_admin_repository.dart      # new (R2)
│       └── sales_order_repository.dart               # listOrders +customer
├── data/
│   ├── delivery_order_admin_repository_impl.dart     # new
│   ├── delivery_order_repository_impl.dart           # listForSale drops cancelled (R9); shared quantity helper
│   └── sales_order_repository_impl.dart              # listOrders +customer
└── presentation/delivery_orders/                     # new
    ├── delivery_orders_list_screen.dart              # C2
    ├── delivery_orders_filter.dart                   # data-model §2, C3
    ├── delivery_orders_list_controller.dart
    ├── delivery_order_detail_screen.dart             # C4
    ├── delivery_order_detail_controller.dart         # order + events + proof + sale map (R5)
    ├── delivery_order_actions.dart                   # writes + invalidations (R6)
    ├── delivery_order_status_chip.dart               # C11
    ├── delivery_order_name_cells.dart                # shared name fallbacks (R4)
    ├── delivery_order_dialogs.dart                   # confirm, cancel, requeue, ready, line qty/remove (C5, C6, C8)
    ├── add_line_dialog.dart                          # C7
    ├── pickup_dialog.dart                            # C9
    └── header_dialog.dart                            # C10
lib/core/navigation/nav_destinations.dart             # destination + NavBranch 26 (C1)
lib/app/router/app_router.dart                        # branch, detail route, gate clause (C1)
lib/core/errors/localize_problem.dart                 # 4 codes + _dateTime (R10)
lib/l10n/app_{es,en}.arb
specs/058-localized-api-errors/contracts/code-scope.tsv
test/unit/features/sales/…, test/widget/features/sales/…, integration_test/delivery_orders_quickstart_test.dart
```

**Structure Decision**: a single Flutter app. Delivery orders get their own presentation folder in `features/sales`, beside `delivery/` (the POS step), because they're a separate screen with a separate right. Domain and data sit next to the POS delivery files and share the generated API and the two enums.

## Dependencies and risks

- **Cancel on an open itinerary (mbe-api#311):** cancel is offered in En preparación, and that can block a trip's departure until the server fix ships. The user accepted this risk. **Fixed 2026-11-14** (mbe-api PR #320): the server refuses that cancel with `delivery_order.on_itinerary`, shown as a localized refusal (fix/consume-mbe-api-308-314).
- **Interim list default (mbe-api#312):** the list opens on every status, so finished orders mix with active ones. Single-status filters and newest-first ordering cover the daily need. Adding "Activas" later is a filter value plus a default. **Shipped 2026-11-14** (mbe-api PR #315): the list opens on "Activas"; "Todas" is `status=all` (fix/consume-mbe-api-308-314).
- **Client-side remaining (R8, mbe-api#313):** it mirrors `_covered_quantities` one sale at a time. One edge, a consolidated order at another facility, can overstate what's left, and the server refuses the add with a localized message. The mirror is deleted when #313 ships. **Shipped 2026-11-14** (mbe-api PR #318): step 2 reads `GET /delivery-orders/deliverable-lines`; the client computation is deleted (fix/consume-mbe-api-308-314).
- **Facility exposure (mbe-api#314):** the client drop keeps a non-administrator to their own facility's list, but nothing client-side can stop a hand-typed `/sales/delivery-orders/{id}` for another facility's order. That needs the server fix. **Fixed 2026-11-14** (mbe-api PR #321): the server checks the facility on the list and on every read and write by id. The client drop stays as defence in depth (fix/consume-mbe-api-308-314).
- **Names need other rights (R4):** customers, facilities, warehouses and employees fall back to `#id` without their read right. Ship-to and contact need Customers read.
- **Live writes leave data:** each `MBE_WRITE` run leaves a cancelled order, a picked-up order with its proof, and two 1-unit sales. Requeue can't be automated without driving an itinerary, so it's checked manually.
- **Approval setting unknown to the client:** confirm may land in Pendiente de aprobación. The screen shows whatever the server returns, and approval itself belongs to roadmap #39.
- **Wireframe drift:** the plan changed three wireframe assumptions: the opening filter (no ① badge, no "Activas"), add-line becoming two steps, and the generic transition message on a refused cancel. The wireframes are updated in the same change.

## Complexity Tracking

No constitution violations need justification. §VI's document reading is now relied on by specs 056, 057, 060 and 061. Amending §VI to state the criterion (a document with a status lifecycle, editable only in draft, has no row Edit icon and no View toggle) would replace these per-spec readings; that is a separate `/speckit-constitution` change, not part of this feature (analysis D3). §VI's document reading is recorded in the Constitution Check above, following the precedent of specs 056 and 057.
