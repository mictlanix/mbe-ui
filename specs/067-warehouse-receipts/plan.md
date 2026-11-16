# Implementation Plan: Warehouse Receipts

**Branch**: `067-warehouse-receipts` | **Date**: 2026-11-16 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/067-warehouse-receipts/spec.md` (mictlanix/mbe-roadmap#59)

## Summary

This adds the back office's first inventory screens. "Entradas de almacén" consists of a receipts list and a receipt detail screen, where a draft is edited in place: its header (warehouse, notes), its lines (stockable products and quantities), and the Confirm, Cancel and Complementary receipt actions. Every route already exists in the generated client (`InventoryReceiptsApi`), so no codegen or mbe-api change blocks the work.

The feature copies the delivery-orders screens (spec 061) for the document shape: list, detail, actions controller, dialogs and refusal banner. It copies the invoicing screens (spec 066) for the "new draft" button and the product-line picker. Over-receipt warnings are computed client-side in Spanish from the line figures. A generic notice stands in for the server's uncoded cost warnings until mictlanix/mbe-api#322 ships (spec FR-015/FR-015a).

## Technical Context

**Language/Version**: Dart 3 / Flutter (stable channel pinned by the repo)

**Primary Dependencies**: flutter_riverpod + riverpod_generator, go_router, freezed, dio, the generated `mbe_api_client` (built_value), intl / flutter_localizations

**Storage**: N/A (online-only, §VII)

**Testing**: `flutter test` (unit, plus widget tests with mocktail fakes), live API tests in `test/integration/` (`--dart-define-from-file=.env.settings`, writes gated by `MBE_WRITE=true`), and a device walkthrough in `integration_test/`

**Target Platform**: Desktop (macOS) and web, Expanded tier first (§VI)

**Project Type**: Flutter client app (one project)

**Performance Goals**: The list and detail load in one round trip each, with name lookups cached per id (existing `*DisplayNameProvider`s). After each mutation the screen shows the server's response with no extra GET.

**Constraints**: Spanish UI text built from codes (§III). One formatting surface (§V). Rights mirrored with `can(15, …)` (§IV). Pagination and the filter drawer on the list (§VI).

**Scale/Scope**: 2 screens (list and detail), 5 dialogs (new receipt, header, add line, line quantity, confirm/cancel prompts), 1 nav group, 9 endpoints, 15 reachable error codes (9 not yet localized)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Result | How |
|---|---|---|
| **I. Feature-first layers** | Pass | New `lib/features/inventory/` with `domain/` (freezed entities, repository interface, the over-receipt calculator), `data/` (repository impl over `InventoryReceiptsApi`) and `presentation/`. Warehouse, product, employee and facility lookups reuse the catalog's providers, not new entities. |
| **II. Riverpod** | Pass | The list and detail are `AsyncNotifier` controllers. Actions live in a `keepAlive` actions notifier that returns `AppError?` and invalidates the list and detail (the delivery-orders pattern). The repository is a provider, overridden in tests. |
| **III. Contract-driven API** | Pass | Uses the generated `InventoryReceiptsApi`, with no hand-written DTOs. Every code the 9 endpoints can return is listed in [contracts/error-messages.md](contracts/error-messages.md), with `es` and `en` messages. The uncoded `warnings[]` are not shown as text (FR-015a). mbe-api#322 is recorded as an external dependency for coded warnings, but nothing here waits on it. A possible raw PUT to clear the notes (research R8) deserializes with `appSerializers`. |
| **IV. Deny-by-default RBAC** | Pass | The route and nav entry are gated by `can(inventoryReceipts, read)`. Actions are absent, not disabled: create (New receipt, Complementary), update (header, lines, Confirm), delete (Cancel). Pickers also need read on warehouses (4) and products. The routes are documented with SystemObject 15. |
| **V. Material 3 / formatting** | Pass | Shared components only. Quantities, dates and folios go through `formattersProvider`. Status chips use the shared `StatusChip`. **Largest text level:** both tables are checked in the walkthrough (quickstart step 10). |
| **VI. List and record surface** | Pass (reading recorded) | **List:** a filter row, a table and pagination. The endpoint has no free-text search, so the filter row has no search box (§VI allows this) and holds the status and warehouse facets in the drawer plus the "Nueva entrada" action. **Surface:** a full detail screen at `/inventory/receipts/:id`, because a receipt owns a child collection (lines) and the complementary action navigates between receipts. **No row Edit icon, no View toggle:** this follows the document reading recorded in specs 056, 057, 060, 061 and 066. A receipt has a status lifecycle and only a draft is editable, so the row tap opens the detail, and a draft is edited in place. Draft line rows use `buildCatalogRowActions` with ✎ and 🗑, within the two-icon limit. **AppBar actions:** empty; every action is in the body's action area. **Delete:** none; Cancel is a status action. |
| **VII. Online-only** | Pass | No caching or printing. |

No deviation needs Complexity Tracking.

**Post-design re-check (after Phase 1)**: Pass, unchanged. The design adds no shared widget and no new layer. The over-receipt calculator is pure domain code with unit tests. The only new shared change is the error messages in `localize_problem.dart` and the `.arb` files, which §III requires.

## Project Structure

### Documentation (this feature)

```text
specs/067-warehouse-receipts/
├── plan.md              # This file
├── research.md          # Phase 0: decisions R1–R12
├── data-model.md        # Phase 1: domain entities, states, derived values
├── quickstart.md        # Phase 1: validation walkthrough
├── contracts/
│   ├── ui-contract.md       # routes, nav, rights matrix, screen and dialog behaviour
│   ├── repository.md        # InventoryReceiptRepository interface ↔ endpoints
│   └── error-messages.md    # every error code these endpoints return → es/en text
└── tasks.md             # Phase 2 (/speckit-tasks)
```

### Source Code (repository root)

```text
lib/features/inventory/
├── domain/
│   ├── entities/inventory_receipt.dart          # InventoryReceiptSummary, InventoryReceipt, InventoryReceiptLine, InventoryReceiptPage, ReceiptStatus
│   ├── over_receipt.dart                        # OverReceipt + computeOverReceipts(lines)  (FR-015)
│   └── repositories/inventory_receipt_repository.dart
├── data/
│   └── inventory_receipt_repository_impl.dart   # inventoryReceiptRepositoryProvider, DTO→entity mapping, DioException→AppError
└── presentation/receipts/
    ├── inventory_receipts_list_screen.dart      # inventoryReceiptsPath = '/inventory/receipts'
    ├── inventory_receipts_list_controller.dart
    ├── inventory_receipts_filter.dart           # status + warehouse facets in the URL
    ├── inventory_receipt_detail_screen.dart
    ├── inventory_receipt_detail_controller.dart
    ├── inventory_receipt_actions.dart           # create, updateHeader, addLine, updateLine, removeLine, confirm, cancel, complementary
    ├── new_receipt_dialog.dart
    ├── receipt_header_dialog.dart
    ├── add_receipt_line_dialog.dart
    ├── receipt_dialogs.dart                     # quantity, remove line, confirm, cancel prompts
    ├── receipt_warnings.dart                    # over-receipt list + cost notice
    ├── receipt_warehouse_options.dart           # own-facility picker options + starting warehouse (R5)
    └── inventory_receipt_status_chip.dart

lib/app/router/app_router.dart                    # new branch + detail route + _routeGate clause
lib/core/navigation/nav_destinations.dart         # NavBranch.inventoryReceipts = 30, new 'inventory' group
lib/core/errors/localize_problem.dart             # 9 new codes (contracts/error-messages.md)
lib/l10n/app_es.arb, app_en.arb                   # screen strings + error messages

test/unit/features/inventory/                     # over_receipt, filter, warehouse options, controllers, actions, repository impl (inventory_receipt_fixtures.dart)
test/widget/features/inventory/                   # list, detail, dialogs, warnings, status chip (inventory_harness.dart)
test/integration/inventory_receipts_live_test.dart
integration_test/inventory_receipts_quickstart_test.dart
```

**Structure Decision**: `lib/features/inventory/` is the feature folder §I names for inventory. Issues, transfers and counts (04 §2 onward) will join it, and the route prefix `/inventory` follows the Technology Stack's route-mirrors-folders rule. The nav group "Inventario" sits in the tree between Logística and Facturación. Its branch index is appended last (30), as branch indexes are positional.

## Phase 0 and Phase 1 outputs

- [research.md](research.md): R1–R12 (surface, nav, create flow, pickers, warnings, notes clearing, error coverage, live fixtures).
- [data-model.md](data-model.md): entities, state rules, action availability, derived over-receipt.
- [contracts/](contracts/): UI contract, repository contract, error messages.
- [quickstart.md](quickstart.md): the validation walkthrough.

## External dependencies

- **mictlanix/mbe-api#322** (coded `warnings[]`): not blocking. Until it ships, over-receipt warnings are computed client-side and cost warnings show as one generic notice (R6). When it ships: regenerate the client, map the coded warnings, and drop the client-side calculator.
- No other mbe-api change is needed. The generated client already includes all 9 routes, so codegen does not need to re-run.

## Complexity Tracking

No constitution violations need justification.

**Note on §VI (analysis finding I3).** Read literally, §VI asks every list row for an Edit icon and a read-only View mode, and bans per-row Delete icons. This feature doesn't follow that wording for receipts: list rows have no icons, a draft is edited in place on its detail screen, and draft line rows carry ✎ and 🗑. It applies the document reading that specs 056, 057, 060, 061 and 066 recorded: a document with a status lifecycle, editable only in draft, is not a catalog record, so the catalog row rules don't apply to it. The constitution is deliberately left unchanged. This note records that the reading is relied on here too.
