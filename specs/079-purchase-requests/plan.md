# Implementation Plan: Purchase Requests with Approval

**Branch**: `079-purchase-requests` | **Date**: 2026-11-26 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/079-purchase-requests/spec.md` (mictlanix/mbe-roadmap#69)

## Summary

This adds the back office's first purchasing screens, in a new "Compras" navigation group:

- **Solicitudes de compra**: a list and a request detail where a draft is edited in place (warehouse, notes, lines), submitted, cancelled, and, once submitted or approved, has its lines marked for purchase.
- **Aprobación de solicitudes**: a queue of submitted requests from every facility, with single and bulk approval, and rejection with a reason from the detail.

All 14 routes are already in the generated client (`PurchaseRequestsApi`), so no codegen or mbe-api change blocks the work. The feature copies the warehouse-receipts screens (spec 067) for the document shape and reuses inventory's shared name cells and warehouse options. The queue's checkbox column copies advanced product search (spec 038). The minimum-quantity warning is computed client-side in Spanish, because the server's warnings are uncoded. The rejection reason is not shown until mictlanix/mbe-api#352 ships.

## Technical Context

**Language/Version**: Dart 3 / Flutter (stable channel pinned by the repo)

**Primary Dependencies**: flutter_riverpod + riverpod_generator, go_router, freezed, dio, the generated `mbe_api_client` (built_value), decimal, intl / flutter_localizations

**Storage**: N/A (online-only, §VII)

**Testing**: `flutter test` (unit, plus widget tests with mocktail mocks), a live repository test in `test/integration/` (`--dart-define-from-file=.env.settings --dart-define-from-file=.env`, writes gated by `MBE_WRITE=true`), and a macOS device walkthrough in `integration_test/`

**Target Platform**: Desktop (macOS) and web, Expanded tier first (§VI)

**Project Type**: Flutter client app (one project)

**Performance Goals**: Each screen loads in one round trip, plus cached per-id name lookups. After each mutation the screen shows the server's response with no extra GET. A bulk approval is one call.

**Constraints**: Spanish UI text built from codes (§III). One formatting surface (§V). Rights mirrored with `can(86|96|20, …)` (§IV). Pagination and the filter drawer on the list (§VI).

**Scale/Scope**: 3 screens (list, detail, queue), 10 dialogs, 1 nav group with 2 destinations, 14 endpoints, 20 reachable error codes (11 not yet localized)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Result | How |
|---|---|---|
| **I. Feature-first layers** | Pass (one coupling recorded) | New `lib/features/purchases/` with `domain/` (freezed entities, repository interface, `belowMinimum`), `data/` (repository impl over `PurchaseRequestsApi`) and `presentation/`. Warehouse, facility, employee and product data come through the catalog's providers. The presentation imports inventory's shared name cells and warehouse options (research R5), and the sales payments filter's date-facet helpers, as invoicing already does; recorded in Complexity Tracking. |
| **II. Riverpod** | Pass | List, detail and queue are `@riverpod` controllers (`fetchClampedPage` for pages). Writes live in a `keepAlive` actions notifier that returns `AppError?` or a result record, puts the response into the detail and invalidates the list and queue (the 067 pattern). The queue selection is a screen-scoped notifier. The repository is a provider, overridden in tests. |
| **III. Contract-driven API** | Pass | Generated `PurchaseRequestsApi` only. Every reachable code is in [contracts/error-messages.md](contracts/error-messages.md) with `es` and `en`. The uncoded `warnings` are dropped (research R7). Bulk refusals are localized from their `code` + `params`. mbe-api#352 is recorded as a non-blocking dependency. |
| **IV. Deny-by-default RBAC** | Pass | Routes and nav entries gated by read on 86 and 96. Every action absent without its right ([data-model.md](data-model.md#action-availability)), including the facility comparison for non-administrators (research R12). Pickers need read on their catalogs. |
| **V. Material 3 / formatting** | Pass | Shared components only: `CatalogFilterBar`, `DataTableView`, `CatalogPagination`, `StatusChip`, `FactStripRow`, `ResponsiveFormGrid`, `ErrorBanner`, `CatalogEntityPicker`, `ResponsiveDialog`. The warning band is feature-local on theme tokens, like 067's. Folios, quantities and dates through `formattersProvider`. Largest text level checked (quickstart step 14). |
| **VI. List and record surface** | Pass (document reading recorded) | **List**: a filter row (folio search, the badged filters button, New), a table and pagination. Every facet, the "Mis solicitudes / Todas" scope included, is in the filter drawer; the queue's facility facet too (no search there, since its endpoint has none). No facet control sits inline in a filter row. **Control bands**: both screens use the shared `CatalogFilterBar`, whose insets and baselines `catalog_filter_bar_test.dart` already asserts, and add no custom band, so no new alignment test is needed. **Surface**: a full detail at `/purchases/requests/:id`, because a request owns lines. **No row Edit icon or View toggle**: the document reading of specs 056–067. Draft line rows carry ✎ 🗑; queue rows carry one ✓ plus a checkbox column, within the two-icon limit. **AppBar actions**: none. **Delete**: none; Cancel is a status action. |
| **VII. Online-only** | Pass | No caching, no printing. |

**Post-design re-check (after Phase 1)**: Pass, unchanged. `/speckit-analyze` (2026-11-26) found that the first draft placed the scope switch and the queue's facility picker inline in the filter row, against §VI; both moved into the filter drawer (research R9, R10). No new shared widget and no change to `DataTableView` (the checkbox column uses the existing `DataTableColumn.header`). The shared changes are the nav tree, the router, the 11 error messages and the `.arb` strings, which §III and §IV require.

## Project Structure

### Documentation (this feature)

```text
specs/079-purchase-requests/
├── plan.md              # This file
├── research.md          # Phase 0: decisions R1–R14
├── data-model.md        # Phase 1: entities, states, action availability
├── quickstart.md        # Phase 1: validation walkthrough
├── wireframes.md        # Drawn before the plan; open questions resolved by research
├── contracts/
│   ├── ui-contract.md       # routes, nav, screens, dialogs
│   ├── repository.md        # PurchaseRequestRepository ↔ endpoints
│   └── error-messages.md    # every reachable error code → es/en text
└── tasks.md             # Phase 2 (/speckit-tasks)
```

### Source Code (repository root)

```text
lib/features/purchases/
├── domain/
│   ├── entities/purchase_request.dart                # PurchaseRequestStatus, PurchaseRequestSummary, PurchaseRequest, PurchaseRequestLine, PurchaseRequestPage, BulkApproveOutcome
│   ├── below_minimum.dart                            # BelowMinimum + belowMinimum(lines)  (FR-013)
│   └── repositories/purchase_request_repository.dart
├── data/
│   └── purchase_request_repository_impl.dart        # purchaseRequestRepositoryProvider, mapping, DioException→AppError
└── presentation/
    ├── requests/
    │   ├── purchase_requests_list_screen.dart        # purchaseRequestsPath = '/purchases/requests'
    │   ├── purchase_requests_list_controller.dart
    │   ├── purchase_requests_filter.dart             # facets + scope + folio in the URL
    │   ├── purchase_request_detail_screen.dart
    │   ├── purchase_request_detail_controller.dart
    │   ├── purchase_request_actions.dart             # create, header, lines, submit, cancel, mark, approve, approveMany, reject
    │   ├── purchase_request_availability.dart        # rights × state × facility (data-model table)
    │   ├── new_request_dialog.dart
    │   ├── request_header_dialog.dart
    │   ├── add_request_line_dialog.dart
    │   ├── request_line_dialog.dart
    │   ├── request_dialogs.dart                      # remove line, submit, approve, reject, cancel prompts
    │   ├── request_minimum_band.dart
    │   └── purchase_request_status_chip.dart
    └── approval/
        ├── purchase_request_approval_screen.dart     # purchaseRequestApprovalPath = '/purchases/request-approval'
        ├── approval_queue_controller.dart
        ├── approval_selection.dart                   # per-page Set<int>
        └── bulk_approve_result_dialog.dart

lib/app/router/app_router.dart                         # 2 branches, detail route, 2 _routeGate clauses
lib/core/navigation/nav_destinations.dart              # NavBranch 38, 39; 'purchases' group
lib/core/errors/localize_problem.dart                  # 11 new codes
lib/l10n/app_es.arb, app_en.arb                        # screen strings + error messages

test/unit/features/purchases/                          # repository impl, below_minimum, filter, controllers, actions, availability, selection (purchase_request_fixtures.dart)
test/widget/features/purchases/                        # list, detail, queue, dialogs, band, chip, large text (purchases_harness.dart)
test/integration/purchase_requests_live_test.dart
integration_test/purchase_requests_quickstart_test.dart
```

**Structure Decision**: `lib/features/purchases/` for the purchasing area; purchase orders, supplier payments and accounts payable will join it. Routes under `/purchases`. Branch indexes 38 and 39 are appended after commissions (37).

## Phase 0 and Phase 1 outputs

- [research.md](research.md): R1–R14 (placement, nav, surface, names, reuse, pickers, warning, notes, list, queue and bulk, actions, foreign facility, errors, tests).
- [data-model.md](data-model.md): entities, filters, state transitions, action availability.
- [contracts/](contracts/): UI, repository, error messages.
- [quickstart.md](quickstart.md): commands and the 14-step walkthrough.

Wireframe open questions settled here: 1 (names, R4), 2 (selection, R10), 3 (scope switch, R9), 4 (mark checkbox, R11), 5 (foreign facility, R12, with FR-026 updated in the spec), 9 (add product, R6), 10 (repeated folios, R9). 6 (warning band) and 7 (PO reference as text) stand as drawn; 8 (compact) stays deferred per §VI.

## External dependencies

- **mictlanix/mbe-api#352** (latest rejection reason on the request): not blocking. When it ships: regenerate the client and show the reason on the detail of a rejected draft.
- **mictlanix/mbe-roadmap#71** (purchase orders): not blocking. The PO reference on lines becomes a link then, and the "line on a live order" refusals become reachable in live tests.
- No other mbe-api change is needed.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| §VI row rules read as catalog-only: list rows have no Edit icon or View toggle; draft line rows carry ✎ 🗑. | A request is a document with a lifecycle, editable only in draft, edited in place on its detail. The reading recorded in specs 056–067. | A row Edit icon and View toggle would lead, for every non-draft request, to a form with nothing to change. |
| §I: `purchases/presentation` imports `inventory/presentation/shared/` (name cells, warehouse options) and `sales/presentation/payments/payments_filter.dart` (date-facet helpers). | Both do exactly what is needed. Cross-feature presentation imports already exist (invoicing uses the same date helpers), so this follows precedent rather than opening a new path. | Copying duplicates ~200 lines that would drift. Moving them to `catalog` touches 23 files of shipped code for no behaviour change; do it when a third feature needs them. |
