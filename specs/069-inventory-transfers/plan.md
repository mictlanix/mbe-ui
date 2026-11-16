# Implementation Plan: Inventory Transfers

**Branch**: `069-inventory-transfers` | **Date**: 2026-11-16 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/069-inventory-transfers/spec.md` (mictlanix/mbe-roadmap#63)

## Summary

This adds "Traspasos", the third screen of the back office's Inventario group, plus an "En tránsito" view.
- The list shows transfers with their origin and destination.
- On the detail screen a draft is edited in place (origin, destination, notes, lines, fill from a sales order) and then dispatched.
- A dispatched transfer is received, in full or in part, through a receive dialog. Its outstanding remainder can be closed, and it can be cancelled.
- The in-transit view lists a facility's outstanding lines and per-product totals.

All 13 routes already exist in the generated client (`InventoryTransfersApi`). No codegen or mbe-api change is needed. Five error codes and one validation type get Spanish and English messages (research R11).

The code copies 068's issue structure into `presentation/transfers/`. It reuses the shared warehouse options and name cells, and adds its own four-state status enum, chip and filter (research R1, R3). Receipts and issues are not touched.

## Technical Context

**Language/Version**: Dart 3 / Flutter (the stable channel pinned by the repo)

**Primary Dependencies**: flutter_riverpod + riverpod_generator, go_router, freezed, dio, the generated `mbe_api_client` (built_value), decimal, intl / flutter_localizations

**Storage**: N/A (online-only, §VII)

**Testing**:
- `flutter test`: unit tests, and widget tests with mocktail fakes.
- Live API tests in `test/integration/`, with writes gated by `MBE_WRITE=true`.
- A device walkthrough in `integration_test/` (run under `caffeinate -dimsu`).

**Target Platform**: Desktop (macOS) and web, Expanded tier first (§VI)

**Project Type**: Flutter client app (one project)

**Performance Goals**: One round trip each for the list, the detail and the in-transit view. Name lookups are cached per id. A mutation shows the server's response, with no extra GET.

**Constraints**:
- Spanish UI text built from codes (§III).
- One formatting surface (§V).
- Rights mirrored with `can(17, …)`, actions absent when not allowed (§IV).
- Pagination and the filter drawer on the list (§VI).
- No AppBar actions (§VI).

**Scale/Scope**:
- 3 screens (list, detail, in transit) and 10 dialogs: new transfer, header, add line, line quantity, remove line, add from sales order, receive, and the dispatch, close and cancel prompts.
- 1 nav destination and 13 endpoints.
- 5 new error codes and 1 validation type.
- About 70 new l10n keys.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Result | How |
|---|---|---|
| **I. Feature-first layers** | Pass | Inside `lib/features/inventory/`. `domain/` gets the `InventoryTransfer` entities, `InventoryTransferStatus`, the in-transit view entities and the repository interface. `data/` gets the implementation over `InventoryTransfersApi`. Presentation gets `transfers/`. Cross-feature reads: `facilityRepositoryProvider` and `warehouseDisplayNameProvider` (catalog), which inventory already uses for warehouses. US8 adds the first imports from sales: `salesOrderRepositoryProvider` (sales `data/`) and `SaleStatus` and the order summary entity (sales `domain/`), as invoicing's add-sales-order dialog (066) does. The user's facility is read from the auth session settings, as `inventory_warehouse_options.dart` does, not from the sales POS `userFacilityIdProvider`, so inventory takes no dependency on a sales screen controller. |
| **II. Riverpod** | Pass | The list, detail and in-transit view are `AsyncNotifier` controllers. A `keepAlive` actions notifier returns `AppError?` and updates the detail, the list and the in-transit view (068's pattern). The repository is a provider. |
| **III. Contract-driven API** | Pass | Generated `InventoryTransfersApi` only, with no hand-written DTOs. Every reachable code gets a message ([contracts/error-messages.md](contracts/error-messages.md)), with `code-scope.tsv` flipped to `IN` and the coverage count raised. The insufficient-stock enrichment uses params only, never server text. |
| **IV. Deny-by-default RBAC** | Pass | The route, nav and in-transit route are gated by `can(17, read)`. Create (Nuevo traspaso). Update (header, lines, Agregar desde pedido, Despachar, Recibir). Delete (Cerrar pendiente, Cancelar). The pickers also need read on warehouses, products, sales orders, and facilities for the admin switch. Facility rules stay server-side, and their refusals are shown (research R5). |
| **V. Material 3 / formatting** | Pass | Shared components only: `StatusChip`, `DataTableView`, `CatalogFilterBar`, `CatalogEntityPicker`, `CompactField`, `ResponsiveDialog`, `FactStripRow`. Quantities, dates and folios go through `formattersProvider`. **Largest text level** is checked in quickstart step 12. |
| **VI. List and record surface** | Pass (document reading, as 067/068) | **List**: filter row (no search, since the endpoint has none), table and pagination. **Surface**: a full detail screen, because a transfer owns lines. **No row Edit icon and no View toggle.** **The AppBar has no actions.** "En tránsito" is a filter-row action. The in-transit tables are unpaginated because the set is bounded by transfers in flight (research R9). |
| **VII. Online-only** | Pass | No caching or printing. |

**Post-design re-check (after Phase 1)**: Pass. Nothing is added to `core/widgets/`. The receive dialog composes `ResponsiveDialog`, `DataTableView` and `CompactField`. The transfer status chip is a feature-local `StatusChip<InventoryTransferStatus>`. 067 and 068 code is untouched (research R1).

## Project Structure

### Documentation (this feature)

```text
specs/069-inventory-transfers/
├── plan.md              # This file
├── research.md          # Phase 0: R1–R12
├── data-model.md        # Phase 1: entities, states, action availability
├── quickstart.md        # Phase 1: validation walkthrough
├── wireframes.md        # Pre-plan drawings (open questions answered in research)
├── contracts/
│   ├── ui-contract.md       # routes, nav, screens, dialogs
│   ├── repository.md        # InventoryTransferRepository ↔ endpoints, actions, controllers
│   └── error-messages.md    # 5 new codes + 1 validation type, reused codes, enrichment
└── tasks.md             # Phase 2 (/speckit-tasks)
```

### Source Code (repository root)

```text
lib/features/inventory/
├── domain/
│   ├── entities/inventory_transfer.dart              # NEW: InventoryTransferStatus, InventoryTransferSummary,
│   │                                                 #      InventoryTransfer, InventoryTransferLine, InventoryTransferPage,
│   │                                                 #      InTransitView, InTransitProductTotal, InTransitLineItem
│   └── repositories/inventory_transfer_repository.dart  # NEW
├── data/
│   └── inventory_transfer_repository_impl.dart       # NEW: inventoryTransferRepositoryProvider, mapping, DioException→AppError
└── presentation/
    └── transfers/                                    # NEW
        ├── inventory_transfers_list_screen.dart      # inventoryTransfersPath = '/inventory/transfers'
        ├── inventory_transfers_list_controller.dart
        ├── inventory_transfers_filter.dart           # InventoryTransfersFilter (status, warehouseId)
        ├── inventory_transfer_status_chip.dart
        ├── inventory_transfer_detail_screen.dart
        ├── inventory_transfer_detail_controller.dart
        ├── inventory_transfer_actions.dart           # create, updateHeader, add/update/removeLine, addSalesOrderItems,
        │                                             # dispatch, receive, close, cancel
        ├── new_transfer_dialog.dart
        ├── transfer_header_dialog.dart
        ├── add_transfer_line_dialog.dart
        ├── add_from_sales_order_dialog.dart
        ├── receive_transfer_dialog.dart
        ├── transfer_dialogs.dart                     # quantity, remove line, dispatch, close, cancel prompts
        ├── in_transit_screen.dart                    # inTransitPath = '/inventory/transfers/in-transit'
        └── in_transit_controller.dart

lib/app/router/app_router.dart                        # branch 32 + in-transit + detail routes + _routeGate clause
lib/core/navigation/nav_destinations.dart             # NavBranch.inventoryTransfers = 32; third child of 'inventory'
lib/core/errors/localize_problem.dart                 # 5 codes + 1 validation type
lib/l10n/app_es.arb, app_en.arb                       # inventoryTransfer… keys, navInventoryTransfers, apiError… keys
specs/058-localized-api-errors/contracts/code-scope.tsv   # 6 rows OUT → IN

test/unit/core/errors/problem_fixtures.dart, catalog_coverage_test.dart   # fixtures; 152 → 157; needParams
test/unit/core/errors/localize_validation_type_test.dart   # hasLength 11 → 12
test/unit/features/inventory/                         # inventory_transfer_fixtures, repository impl, filter,
                                                      # list/detail/in-transit controllers, actions
test/widget/features/inventory/                       # status chip, list, detail (per state), receive dialog,
                                                      # add-from-order dialog, header/new dialogs, in-transit, large text
test/unit/core/navigation/nav_destinations_test.dart, test/unit/app/router/app_router_test.dart
test/integration/inventory_transfers_live_test.dart
integration_test/inventory_transfers_quickstart_test.dart
```

**Structure Decision**: Transfers go in the existing `lib/features/inventory/` beside receipts and issues, under `/inventory/transfers` (route-mirrors-folders). The in-transit view is a top-level route under the `/inventory/transfers` path, like the detail route, declared before `/:id`. The transfer status, chip and filter are local to `presentation/transfers/`, because the shared ones serve the three-state documents (research R1).

## Implementation order

1. **Errors**: the 5 codes and the validation type, their arb text, fixtures, `code-scope.tsv`, and the coverage count. **Check:** `catalog_coverage_test` passes.
2. **Domain and data**: entities, status mapping, repository interface and implementation, including `receive` with and without a body, and `inTransit`. Unit tests cover the mapping, the wire status, the receive body and the errors.
3. **List**: filter, status chip, controller, screen, nav and route. **Check:** the nav and router tests pass with branch 32.
4. **Detail and draft editing**: detail controller, actions, header, new, add-line and quantity dialogs, and Despachar with the insufficient-stock enrichment. Widget tests cover rights × states.
5. **Receive, close, cancel**: the receive dialog (prefill, validation, body vs. no body), the close and cancel prompts with their conditional text.
6. **Fill from sales order** (US8) and **in-transit view** (US7): both P3, each independently testable.
7. **Live and device**: `inventory_transfers_live_test.dart` (stock at both ends after each step, and the refusals) and the quickstart device test.

## External dependencies

None. mbe-api#322 (coded warnings) doesn't apply: transfers return no warnings.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| §VI row rules read as catalog-only (same reading as 067/068): transfer list rows have no Edit icon and no View toggle, and draft line rows carry ✎ and 🗑. | A transfer is a document with a status lifecycle, editable only as a draft and edited in place on its detail screen. | Catalog row icons would lead from dispatched, received and cancelled transfers, most of the list, to a form with nothing to change. |
| The in-transit tables are not paginated (§VI asks for pagination on unbounded lists). | The endpoint returns the full set for one facility and takes no paging parameters. The set is bounded by the transfers currently in flight. | Paging on the client would add controls to a short, bounded list. |
| A second status chip and filter beside the shared inventory ones. | Transfers have four masculine states, and receipts and issues have three feminine ones. | Making the shared pieces generic would change two just-shipped screens and their tests for one caller (research R1). |
