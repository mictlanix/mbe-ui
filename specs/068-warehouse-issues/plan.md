# Implementation Plan: Warehouse Issues

**Branch**: `068-warehouse-issues` | **Date**: 2026-11-16 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/068-warehouse-issues/spec.md` (mictlanix/mbe-roadmap#61)

## Summary

This adds "Salidas de almacén", the second screen of the back office's Inventario group. It has an issues list and an issue detail screen where a draft is edited in place: its header (source warehouse, "Motivo / notas"), its lines (stockable products and quantities), and the Confirm and Cancel actions. Confirm can be refused when the warehouse's available stock is short. The refusal names the product and warehouse, and the issue stays a draft.

All 9 routes already exist in the generated client (`InventoryIssuesApi`), and every error code they return is already localized. No codegen, mbe-api change or new error message is needed.

The work happens in two steps:
1. Move the document-agnostic parts of the shipped receipts feature (spec 067) into shared inventory code: the status enum and chip, the name cells, the warehouse scope, options and starting warehouse, and the status+warehouse filter. This is a rename only. The user chose it on 2026-11-16 (research R1). The receipts suite must pass unchanged.
2. Build the issue screens on those shared parts. They are copied from receipts and simplified: no purchase order, no complementary action, no warnings.

## Technical Context

**Language/Version**: Dart 3 / Flutter (the stable channel pinned by the repo)

**Primary Dependencies**: flutter_riverpod + riverpod_generator, go_router, freezed, dio, the generated `mbe_api_client` (built_value), intl / flutter_localizations

**Storage**: N/A (online-only, §VII)

**Testing**:
- `flutter test`: unit tests, and widget tests with mocktail fakes.
- Live API tests in `test/integration/` (`--dart-define-from-file=.env.settings`), with writes gated by `MBE_WRITE=true`.
- A device walkthrough in `integration_test/`.

**Target Platform**: Desktop (macOS) and web, Expanded tier first (§VI)

**Project Type**: Flutter client app (one project)

**Performance Goals**: One round trip each for the list and the detail. Name lookups are cached per id. A mutation shows the server's response, with no extra GET.

**Constraints**: Spanish UI text built from codes (§III), one formatting surface (§V), rights mirrored with `can(16, …)` (§IV), and pagination plus the filter drawer on the list (§VI).

**Scale/Scope**:
- 2 screens and 7 dialogs (new issue, header, add line, line quantity, and the remove, confirm and cancel prompts).
- 1 nav destination and 9 endpoints.
- 0 new error codes.
- 1 refactor step: 12 receipt symbols and 5 shared l10n keys move to shared names, touching about 10 lib files and the receipts tests.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Result | How |
|---|---|---|
| **I. Feature-first layers** | Pass | Inside `lib/features/inventory/`. The domain gets the `InventoryIssue` entities and the repository interface. `data/` gets the repository implementation over `InventoryIssuesApi`. Presentation gets `issues/` and the new `shared/`. The shared status enum lives in `domain/entities/`, and the shared widgets and providers in `presentation/shared/`. Nothing crosses feature boundaries. |
| **II. Riverpod** | Pass | The list and detail are `AsyncNotifier` controllers. A `keepAlive` actions notifier returns `AppError?` and updates the detail and list (067's pattern). The repository is a provider. |
| **III. Contract-driven API** | Pass | Generated `InventoryIssuesApi` only, with no hand-written DTOs. Every reachable code is already localized ([contracts/error-messages.md](contracts/error-messages.md)). The insufficient-stock enrichment is presentation-side, built from params and the issue's own data, never from server text. |
| **IV. Deny-by-default RBAC** | Pass | The route and nav are gated by `can(inventoryIssues, read)`. Actions are absent when not allowed: create (Nueva salida), update (header, lines, Confirmar), delete (Cancelar). The pickers also need read on warehouses (4) and products. |
| **V. Material 3 / formatting** | Pass | Shared components only. Quantities, dates and folios go through `formattersProvider`. Status uses the shared `StatusChip`. **Largest text level** is checked in quickstart step 10. |
| **VI. List and record surface** | Pass (document reading, as 067) | **List**: filter row (no search, since the endpoint has none), table and pagination. **Surface**: a full detail screen, because an issue owns lines. **No row Edit icon and no View toggle.** This is the document reading recorded in specs 056–067: only a draft is editable, and it is edited in place. Draft line rows carry ✎ and 🗑. **The AppBar has no actions**, and there is no Delete action (Cancel is a status action). |
| **VII. Online-only** | Pass | No caching or printing. |

**Post-design re-check (after Phase 1)**: Pass. The design adds no widget to `core/widgets/`. The shared pieces are feature-local (`features/inventory/presentation/shared/`), because only inventory documents use them. The refactor changes names and paths only, and the unchanged receipts suite guards it.

## Project Structure

### Documentation (this feature)

```text
specs/068-warehouse-issues/
├── plan.md              # This file
├── research.md          # Phase 0: R1–R9
├── data-model.md        # Phase 1: entities, states, action availability
├── quickstart.md        # Phase 1: validation walkthrough
├── wireframes.md        # Pre-plan drawings (questions 1–3 settled)
├── contracts/
│   ├── ui-contract.md       # routes, nav, screens, dialogs
│   ├── repository.md        # InventoryIssueRepository ↔ endpoints
│   └── error-messages.md    # reachable codes (all existing) + refusal enrichment
└── tasks.md             # Phase 2 (/speckit-tasks)
```

### Source Code (repository root)

```text
lib/features/inventory/
├── domain/
│   ├── entities/inventory_document_status.dart     # NEW (moved): InventoryDocumentStatus (was ReceiptStatus)
│   ├── entities/inventory_receipt.dart             # EDIT: use InventoryDocumentStatus
│   ├── entities/inventory_issue.dart               # NEW: InventoryIssueSummary, InventoryIssue, InventoryIssueLine, InventoryIssuePage
│   └── repositories/inventory_issue_repository.dart  # NEW
├── data/
│   ├── inventory_receipt_repository_impl.dart      # EDIT: status rename
│   └── inventory_issue_repository_impl.dart        # NEW: inventoryIssueRepositoryProvider, mapping, DioException→AppError
└── presentation/
    ├── shared/                                     # NEW (moved from receipts/, renamed — research R1)
    │   ├── inventory_document_status_chip.dart
    │   ├── inventory_name_cells.dart
    │   ├── inventory_warehouse_options.dart
    │   └── inventory_documents_filter.dart
    ├── receipts/                                   # EDIT: imports and names only; 4 files removed (moved to shared/)
    └── issues/                                     # NEW
        ├── inventory_issues_list_screen.dart       # inventoryIssuesPath = '/inventory/issues'
        ├── inventory_issues_list_controller.dart
        ├── inventory_issue_detail_screen.dart
        ├── inventory_issue_detail_controller.dart
        ├── inventory_issue_actions.dart            # create, updateHeader, addLine, updateLine, removeLine, confirm, cancel
        ├── new_issue_dialog.dart
        ├── issue_header_dialog.dart
        ├── add_issue_line_dialog.dart
        └── issue_dialogs.dart                      # quantity, remove line, confirm, cancel prompts

lib/app/router/app_router.dart                      # branch 31 + detail route + _routeGate clause
lib/core/navigation/nav_destinations.dart           # NavBranch.inventoryIssues = 31; second child of 'inventory'
lib/l10n/app_es.arb, app_en.arb                     # inventoryIssue… keys; inventoryReceiptStatus* → inventoryDocumentStatus*

test/unit/features/inventory/                       # renamed: inventory_documents_filter_test, inventory_warehouse_options_test;
                                                    # new: inventory_issue_fixtures, repository impl, controllers, actions
test/widget/features/inventory/                     # renamed: inventory_document_status_chip_test;
                                                    # new: issues list, detail, dialogs, large text
test/integration/inventory_issues_live_test.dart
integration_test/inventory_issues_quickstart_test.dart
```

**Structure Decision**: Issues go in the existing `lib/features/inventory/` beside receipts, under `/inventory/issues` (route-mirrors-folders). The shared pieces go in `presentation/shared/` and `domain/entities/`, inside the feature, not in `core/`, because only inventory documents use them. Transfers (04 §3) and counts (04 §5) will add to them.

## Implementation order

1. **Refactor (research R1)**: move and rename the 12 symbols and the 3 status l10n keys, and update receipts and their tests. **Check:** the full receipts unit and widget suite passes, and `flutter analyze` is clean.
2. **Domain and data**: issue entities, repository interface and implementation, with unit tests for the mapping and errors.
3. **Presentation**: controllers, actions, list, detail, dialogs, nav and route. Widget tests cover rights, states, the insufficient-stock enrichment and the supplier-return fact.
4. **Live and device**: `inventory_issues_live_test.dart` (stock before and after, the 409 path) and the quickstart device test, plus the receipts live test again.

## External dependencies

None. mictlanix/mbe-api#322 (coded warnings) doesn't affect issues, which have no warnings.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| §VI row rules read as catalog-only (same reading as 067): issue list rows have no Edit icon and no View toggle, and draft line rows carry ✎ and 🗑. | An issue is a document with a status lifecycle, editable only as a draft and edited in place on its detail screen. This is the reading recorded in specs 056–067. | Catalog row icons would lead from confirmed and cancelled issues, most of the list, to a form with nothing to change. |
| The refactor touches shipped 067 code (CLAUDE.md §3, surgical changes). | FR-018 requires the two screens to match. The user chose shared parts over copies (research R1). | Copying would leave about 300 identical lines that can drift apart. A generic document screen would be a far larger change to 067. |
