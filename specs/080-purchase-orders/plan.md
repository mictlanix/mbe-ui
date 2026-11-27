# Implementation Plan: Purchase Orders with Receipts, PDF and Email

**Branch**: `080-purchase-orders` | **Date**: 2026-11-27 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/080-purchase-orders/spec.md` (mictlanix/mbe-roadmap#71)

## Summary

This adds purchase orders to the Compras group:

- **Por comprar**: the pending marked lines of approved requests, grouped by supplier and facility, each supplier group turned into a draft order in one step.
- **Órdenes de compra**: a list, and an order detail where a draft is edited in place (supplier, date, notes, lines, a request's lines), confirmed (creating draft receipts), or cancelled; a confirmed order shows receiving progress and is printed and emailed.
- **Links**: the request detail (079) and the receipt detail (067) link their order number to the new detail.

All routes are already in the generated client (`PurchaseOrdersApi`), so nothing blocks the work. Three mbe-api issues add to it later without blocking: coded warnings (#353), Por comprar filters and paging (#354), and receipts with state on every order response (#355). The feature extends 079's `lib/features/purchases/`, reuses inventory's name cells and status chip, adds a `DocumentKind` for printing, and copies the quote email dialog's layout with its pure helpers imported.

## Technical Context

**Language/Version**: Dart 3 / Flutter (stable channel pinned by the repo)

**Primary Dependencies**: flutter_riverpod + riverpod_generator, go_router, freezed, dio, the generated `mbe_api_client` (built_value), decimal, intl / flutter_localizations, printing (via `lib/core/documents/`)

**Storage**: N/A (online-only, §VII)

**Testing**: `flutter test` (unit, plus widget tests with mocktail mocks), a live repository test in `test/integration/` (`--dart-define-from-file=.env.settings --dart-define-from-file=.env`, writes gated by `MBE_WRITE=true`), and a macOS device walkthrough in `integration_test/`

**Target Platform**: Desktop (macOS) and web, Expanded tier first (§VI)

**Project Type**: Flutter client app (one project)

**Performance Goals**: Each screen loads in one round trip, plus cached per-id name lookups (employees, warehouses, facilities, request folios). After each mutation the screen shows the server's response with no extra GET.

**Constraints**: Spanish UI text built from codes (§III); the server's uncoded `warnings` and skip reasons are not shown. One formatting surface (§V). Rights mirrored with `can(20|15|86, …)` (§IV). Pagination and the filter drawer on every list (§VI); Por comprar pages its loaded groups on the client until mbe-api#354.

**Scale/Scope**: 3 screens (Por comprar, list, detail), 9 dialogs, 2 nav destinations, 2 changed existing screens, 13 repository methods over 13 endpoints, plus the document route, 9 new error codes, 1 new `DocumentKind`

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Result | How |
|---|---|---|
| **I. Feature-first layers** | Pass (couplings recorded) | `lib/features/purchases/` gains `domain/entities/purchase_order.dart`, `domain/zero_price.dart`, `domain/repositories/purchase_order_repository.dart`, `data/purchase_order_repository_impl.dart`, and `presentation/orders/` + `presentation/to_purchase/`. Reuses 079's existing imports of inventory's shared name cells. New cross-feature imports: `sales/domain/quote_email.dart` pure helpers (R14), and `inventory/.../inventory_receipt_detail_screen.dart` → `purchases/presentation/orders/purchase_order_link.dart` (R16). Recorded in Complexity Tracking. |
| **II. Riverpod** | Pass | List, Por comprar and detail are `@riverpod` controllers; the detail state holds the order plus the receipts from the last confirm. Writes live in a `keepAlive` `purchaseOrderActionsProvider` returning `AppError?` or a result record, putting the response into the detail and invalidating the list and Por comprar (079 pattern). The email dialog has its own controller. Request folios and name lookups are cached `FutureProvider.family`s. |
| **III. Contract-driven API** | Pass | Generated `PurchaseOrdersApi` only, except a raw `dio.put` if the generated serializer cannot send an explicit `null` date (R7, precedent 049). 9 new codes in [contracts/error-messages.md](contracts/error-messages.md) with `es` and `en`. Uncoded `warnings` and `skipped[].reason` are dropped; the price-0 warning is computed client-side (R10). mbe-api#353–#355 recorded as non-blocking dependencies. |
| **IV. Deny-by-default RBAC** | Pass | Routes and nav entries gated by read on 20. Every action absent without its right ([data-model.md](data-model.md#action-availability)); the order link falls back to text without read on 20; "Abrir" receipt needs read on 15; pickers need read on their catalogs. Orders are not facility-scoped (FR-003). |
| **V. Material 3 / formatting** | Pass | Shared components: `CatalogFilterBar`, `CatalogSearchBar`, `DataTableView`, `CatalogPagination`, `InventoryDocumentStatusChip`, `FactStripRow`, `ResponsiveFormGrid`, `ErrorBanner`, `FormErrorBanner`, `CatalogEntityPicker`, `ResponsiveDialog`, `RecordIdText`, `documentActionsProvider`. The warning band is feature-local on theme tokens. Quantities, money and dates through `formattersProvider`. Largest text checked (quickstart step 15). |
| **VI. List and record surface** | Pass (two readings recorded) | **List**: filter row (number search, badged filters button, Nueva orden), table, pagination; every facet, the scope included, in the drawer. **Por comprar**: filter row with no search (the endpoint has none), the facility facet in the drawer, and one "Crear orden" toolbar action that creates the order for the selected group (create stays toolbar-only); the loaded groups paged with `CatalogPagination` on the client until mbe-api#354 pages them on the server. **Control bands**: only the shared `CatalogFilterBar`, already measured by `catalog_filter_bar_test.dart`; no new band needing an alignment test. **Surface**: full detail at `/purchases/orders/:id` (owns lines and receipts). **Rows**: no Edit icon or View toggle (document reading, 056–079); draft line rows carry ✎ 🗑. **AppBar actions**: none. **Delete**: none; Cancel is a status action. |
| **VII. Online-only** | Pass | PDF rendered by mbe-api, previewed through `lib/core/documents/`. No caching. |

**Post-design re-check (after Phase 1)**: Pass. `/speckit-analyze` (2026-11-27) found that the first design put a "Crear orden" button in each Por comprar group (§VI: create is toolbar-only) and shipped Por comprar without pagination (§VI: unbounded lists are paginated). Both were fixed without a constitution change: one toolbar action over a selected group, and client-side paging of the loaded groups (research R5, spec FR-008, FR-031). No new shared widget; no change to `DataTableView`. The shared changes are the nav tree, the router, `DocumentKind` + its source arm, the 9 error messages and the `.arb` strings, which §III, §IV and §VII require, plus the order link in the receipt detail (FR-030).

## Project Structure

### Documentation (this feature)

```text
specs/080-purchase-orders/
├── plan.md              # This file
├── research.md          # Phase 0: decisions R1–R18
├── data-model.md        # Phase 1: entities, filters, states, action availability
├── quickstart.md        # Phase 1: validation walkthrough
├── wireframes.md        # Drawn before the plan; open questions resolved below
├── contracts/
│   ├── ui-contract.md       # routes, nav, screens, dialogs, changed screens
│   ├── repository.md        # PurchaseOrderRepository ↔ endpoints
│   └── error-messages.md    # every reachable error code → es/en text
└── tasks.md             # Phase 2 (/speckit-tasks)
```

### Source Code (repository root)

```text
lib/features/purchases/
├── domain/
│   ├── entities/purchase_order.dart                  # PurchaseOrderSummary, PurchaseOrder, PurchaseOrderLine, OrderReceipt, ToPurchaseGroup, ToPurchaseLine, OrderEmailReceipt, PurchaseOrderPage
│   ├── zero_price.dart                               # zeroPriceLines(lines)  (FR-019)
│   └── repositories/purchase_order_repository.dart
├── data/
│   └── purchase_order_repository_impl.dart          # purchaseOrderRepositoryProvider, mapping, DioException→AppError
└── presentation/
    ├── orders/
    │   ├── purchase_orders_list_screen.dart          # purchaseOrdersPath = '/purchases/orders'
    │   ├── purchase_orders_list_controller.dart
    │   ├── purchase_orders_filter.dart               # facets + scope + number in the URL
    │   ├── purchase_order_detail_screen.dart
    │   ├── purchase_order_detail_controller.dart     # order + receipts from the last confirm
    │   ├── purchase_order_actions.dart               # create, header, lines, request lines, confirm, cancel, createFromGroup
    │   ├── purchase_order_availability.dart          # rights × state (data-model table)
    │   ├── purchase_order_link.dart                  # PurchaseOrderLink (FR-030)
    │   ├── purchase_request_serial.dart              # purchaseRequestSerialProvider (R8)
    │   ├── new_order_dialog.dart
    │   ├── order_header_dialog.dart
    │   ├── add_order_line_dialog.dart
    │   ├── order_line_dialog.dart                    # + tax-rate options (R8)
    │   ├── add_request_lines_dialog.dart
    │   ├── order_dialogs.dart                        # remove line, confirm, cancel prompts
    │   ├── order_warnings_band.dart
    │   ├── order_receipts_section.dart
    │   ├── purchase_order_email_dialog.dart
    │   └── purchase_order_email_controller.dart
    └── to_purchase/
        ├── to_purchase_screen.dart                   # toPurchasePath = '/purchases/to-purchase'
        ├── to_purchase_controller.dart
        └── to_purchase_filter.dart

lib/features/purchases/presentation/requests/purchase_request_detail_screen.dart   # order column → PurchaseOrderLink
lib/features/inventory/presentation/receipts/inventory_receipt_detail_screen.dart  # order fact → PurchaseOrderLink
lib/core/documents/domain/document_kind.dart                                       # DocumentKind.purchaseOrder
lib/core/documents/data/document_source_impl.dart                                  # its print arm
lib/app/router/app_router.dart                         # 2 branches, detail route, 2 _routeGate clauses
lib/core/navigation/nav_destinations.dart              # NavBranch 40, 41 in the 'purchases' group
lib/core/errors/localize_problem.dart                  # 9 new codes
lib/l10n/app_es.arb, app_en.arb                        # screen strings + error messages

test/unit/features/purchases/                          # order repository impl, zero_price, filters, controllers, actions, availability, email controller, tax options (purchase_order_fixtures.dart)
test/widget/features/purchases/                        # list, Por comprar, detail states, dialogs, band, receipts section, link, large text (purchases_harness.dart)
test/unit/core/documents/                              # DocumentKind.purchaseOrder
test/integration/purchase_orders_live_test.dart
integration_test/purchase_orders_quickstart_test.dart
```

**Structure Decision**: Extend `lib/features/purchases/` with `orders/` and `to_purchase/` presentation folders. Routes under `/purchases`. Branch indexes 40 and 41 appended after 079's 39.

## Phase 0 and Phase 1 outputs

- [research.md](research.md): R1–R18 (placement and nav, surface, names, status, Por comprar, creating, header clearing, lines and tax rate, request lines, warnings, confirm and receipts, cancel, print, email, list, links, errors, tests).
- [data-model.md](data-model.md): entities, filters, state transitions, action availability.
- [contracts/](contracts/): UI, repository, error messages.
- [quickstart.md](quickstart.md): commands and the 15-step walkthrough.

Wireframe open questions settled here: 1 (names, R3), 3 (one toolbar Crear orden over a selected group, R5, changed after `/speckit-analyze`), 4 (status labels, R4), 5 (warning band stays feature-local, R10), 6 (decimals, R8), 7 (supplier always set, R6), 9 (columns by state, R8), 10 (tax-rate options, R8), 11 (email dialog, R14). Settled by `/speckit-clarify`: 2, 8, 12, 13. The row ✎ on draft list rows is dropped (R2).

## External dependencies

- **mictlanix/mbe-api#353** (coded warnings and skip reasons): not blocking. When it ships: regenerate, map the codes, show the supplier-mismatch warning and per-line skip reasons; drop `zeroPriceLines` if the server's coded zero-price warning covers it.
- **mictlanix/mbe-api#354** (Por comprar supplier filter, search, paging): not blocking. When it ships: add the search slot and the supplier facet, and move the paging from the client to the server.
- **mictlanix/mbe-api#355** (linked receipts with state on every order response): not blocking. When it ships: regenerate, map `status`, show the Entradas section on every load with the chip.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| §VI row rules read as catalog-only: list rows have no Edit icon or View toggle; draft line rows carry ✎ 🗑. | An order is a document with a lifecycle, editable only in draft, edited in place on its detail. The reading recorded in specs 056–079. | A row Edit icon and View toggle would lead, for every confirmed or cancelled order, to a form with nothing to change. |
| §I: `inventory_receipt_detail_screen.dart` imports `purchases/presentation/orders/purchase_order_link.dart`; `purchases` imports `sales/domain/quote_email.dart`. | The link needs the order route and right in one place (FR-030). The email helpers (address check, chip model, limit) are pure and already correct. | A third private link copy (after refunds and delivery orders) drifts; moving the link to `core/` needs a feature route in core. Generalizing the quote dialog rewrites shipped sales code; promote both when a third document needs email or a third screen needs an order link. |
| Another feature-local warning band (`OrderWarningsBand`), the fourth feature with one. | No shared warning banner exists; this band shows one kind of line. | Promoting the band to `core/widgets/` touches three shipped features (067, 069, 079) for no behaviour change; do it in its own change. |
