# Implementation Plan: Delivery Order Print

**Branch**: `064-delivery-order-print` | **Date**: 2026-11-15 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/064-delivery-order-print/spec.md` (mictlanix/mbe-roadmap#43)

## Summary

Offer the two delivery order documents that mbe-api spec 026 already renders: the 72 mm ticket and the Letter format.

- **Where.** On the spec 061 detail screen and, for the ticket only, as a row action on the Órdenes de entrega list.
- **Through spec 044.** Both go through the shared document module. Two new `DocumentKind`s and an optional `warehouseId` on `DocumentRef` let `DocumentSourceImpl` call the generated `DeliveryOrdersApi` methods. The preview, print, download, filename and error banner are reused unchanged.
- **Warehouse choice.** When an order's lines come from two or more warehouses, a small chooser asks for "Todos los almacenes" or one warehouse first. The detail screen knows the lines. The list looks the order up on tap, because the summary has no lines.
- **Error codes.** Three server error codes get Spanish and English messages, as constitution §III requires.

## Technical Context

**Language/Version**: Dart `^3.10.3`, Flutter stable (unchanged)

**Primary Dependencies**:
- Riverpod 3 (riverpod_generator), `go_router`, `printing` (via spec 044's module), freezed, and the generated `mbe_api_client`.
- No new packages and no client regeneration: both methods are already generated with `ResponseType.bytes`.

**Storage**: N/A (online-only, documents never cached, §VII and spec 044 FR-022)

**Testing**:
- `flutter_test` + `mocktail` with `ProviderScope` overrides.
- Spec 044 fakes (`test/unit/core/documents/document_fakes.dart`: `FakeDocumentSource`, `FakeDocumentOutput`, `documentContainer`).
- Spec 061's `delivery_order_detail_screen_test.dart` and `delivery_orders_list_screen_test.dart`.
- Live template: `integration_test/document_printing_quickstart_test.dart`.

**Target Platform**: web and desktop first, with a compact tier required (§VI)

**Project Type**: Flutter client application, feature-first layered

**Performance Goals**:

| Action | Requests |
|---|---|
| Print from the detail screen | 1 (the PDF) |
| Print from a list row | 2 (order lookup for its warehouses, then the PDF) |
| Choose a warehouse | 0 extra (names from the cached facility warehouses) |

**Constraints**:
- Spacing comes from tokens.
- Every string goes in both `.arb` files.
- Actions are absent, never disabled, without the right.
- Format only the changed files.

**Scale/Scope**:

| | Files |
|---|---|
| **New source (≈2)** | `presentation/delivery_orders/delivery_order_print.dart` (`canPrintDeliveryOrder`, `distinctWarehouses`, `openDeliveryTicket`, `openDeliveryLetter`) and `presentation/delivery_orders/delivery_ticket_scope_dialog.dart` (`DeliveryTicketScope`, `showDeliveryTicketScopeDialog`) |
| **Edited source (≈8)** | `core/documents/domain/document_kind.dart`, `core/documents/domain/document_ref.dart`, `core/documents/data/document_source_impl.dart`, `core/errors/localize_problem.dart`, `delivery_order_detail_screen.dart`, `delivery_orders_list_screen.dart`, both `.arb` files |
| **New tests (≈3)** | unit `delivery_order_print_test`; widget `delivery_ticket_scope_dialog_test`; live `integration_test/delivery_order_print_quickstart_test.dart` |
| **Edited tests (≈8)** | `document_source_impl_test`, `generated_client_bytes_test`, a `DocumentRef` equality test, `catalog_coverage_test` (110→113), `problem_fixtures.dart`, the `localize_problem` group test, `delivery_order_detail_screen_test` (incl. the cancelled-order assertion at l.1114), `delivery_orders_list_screen_test` |
| **Edited docs (1)** | `specs/058-localized-api-errors/contracts/code-scope.tsv` (three rows OUT→IN) |

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Check | Result |
|---|---|---|
| **I. Feature-first layers** | Document plumbing stays in `core/documents`. The print flow and chooser are presentation code in the delivery-orders feature. The list lookup goes through the domain `DeliveryOrderAdminRepository`, never the generated API | PASS |
| **II. Riverpod** | Fetching goes through `documentSourceProvider` / `documentActionsProvider` and the repository provider, so tests override them with fakes. No new state notifier: the in-flight guard is a set the flow function owns | PASS |
| **III. Contract-driven API** | Generated methods only, with no hand DTOs. Errors are mapped to `AppError` by the existing `_toAppError`. **API error text:** all five codes the endpoints return are covered; three are added in es and en (research R9, contracts/consumed-endpoints.md). No mbe-api change is needed, and no issue is filed (R12) | PASS |
| **IV. Deny-by-default RBAC** | `canPrintDeliveryOrder` uses `canOpenDocument(access, DocumentKind.deliveryTicket)`, which is DeliveryOrders (71) read. The preview controller re-checks before fetching (`requireDocumentAccess`). Routes are already gated by `PrivilegeGate(deliveryOrders, read)`. SystemObject: DeliveryOrders 71 | PASS |
| **V. Material 3** | `OutlinedButton.icon`, `TextButton.icon`, `RadioListTile` and `ResponsiveDialog`, with no custom widgets | PASS |
| **VI. Layout and actions** | Detail actions are body buttons in the existing action area, with empty `AppBar.actions`. The row gets one extra icon via `buildCatalogRowActions` (≤ 2 icons). The chooser goes fullscreen on compact. The row tap still opens the detail screen | PASS |
| **VII. Server-rendered documents** | mbe-ui only previews, prints and downloads mbe-api's bytes, and caches nothing | PASS |
| **Workflow gates** | Endpoints the app starts calling are listed with their error codes and messages (contracts/consumed-endpoints.md). Codegen re-run: not needed, already generated (R10 adds a bytes guard) | PASS |

**Post-design re-check (after Phase 1):** still PASS.

- **Deviation recorded.** The spec edge case on busy feedback during the list lookup is narrowed: repeated taps are ignored and failures show a SnackBar, with no busy icon (research R5). The spec is amended to match. It isn't a constitution matter.
- **Shared-component change.** `DocumentRef` gains an optional field. It is additive, and existing callers and tests are unaffected apart from equality now including it.

## Project Structure

### Documentation (this feature)

```text
specs/064-delivery-order-print/
├── plan.md              # This file
├── research.md          # Phase 0 (R1–R12)
├── data-model.md        # Phase 1
├── quickstart.md        # Phase 1
├── contracts/
│   ├── consumed-endpoints.md
│   └── ui-actions.md
├── checklists/requirements.md
└── tasks.md             # Phase 2 (/speckit-tasks)
```

### Source Code (repository root)

```text
lib/
├── core/
│   ├── documents/
│   │   ├── domain/document_kind.dart         # + deliveryTicket, deliveryOrderDocument
│   │   ├── domain/document_ref.dart          # + int? warehouseId
│   │   └── data/document_source_impl.dart    # + DeliveryOrdersApi arms
│   └── errors/localize_problem.dart          # + 3 delivery_order codes
├── features/sales/presentation/delivery_orders/
│   ├── delivery_order_print.dart             # NEW: canPrint, distinctWarehouses, open flows
│   ├── delivery_ticket_scope_dialog.dart     # NEW: chooser
│   ├── delivery_order_detail_screen.dart     # + two body buttons
│   └── delivery_orders_list_screen.dart      # + rowActionsBuilder
└── l10n/app_{es,en}.arb                      # + 10 keys

test/
├── unit/core/documents/                      # source, ref, bytes guard
├── unit/core/errors/                         # coverage 113, fixtures, messages
├── unit/features/sales/delivery_order_print_test.dart
└── widget/features/sales/                    # detail, list, scope dialog

integration_test/delivery_order_print_quickstart_test.dart
```

**Structure Decision**: Flutter feature-first layout (constitution §I). Document plumbing extends `lib/core/documents`. Everything delivery-specific lives under `lib/features/sales/presentation/delivery_orders/`, next to spec 061's screens.

## Complexity Tracking

No constitution violations to justify.
