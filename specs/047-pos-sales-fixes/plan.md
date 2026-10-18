# Implementation Plan: POS Sales Fixes

**Branch**: `047-pos-sales-fixes` | **Date**: 2026-10-17 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/047-pos-sales-fixes/spec.md`

## Summary

This plan covers six fixes to the POS sale flow. All of them are UI-only, and none needs a backend change or codegen.

1. **Session gate (P1)**
   - A session is valid only when `CurrentSession.state == open`.
   - *New sale* re-reads the session. A stale session sends the cashier to `/sales/cash-sessions/<id>` (the close form is already there). A stale session on an existing sale blocks payments behind a banner with a close action.
   - The session is re-read before each payment (R1, R2).
2. **Label filter (P1)**
   - `CurrentListQueryBuilder` read the base route's URI, so Advanced search (reached by `push`) always saw an empty filter.
   - It now resolves the top-most route's URI instead. A regression test opens the screen through `push` (R3).
3. **Stock gate (P2)**
   - The stock cache now stores `ProductStock`, which carries `stockable`, `stockRequired` and the warehouse stock. It is filled for resumed sales through per-product `product-lookup` calls.
   - A pure `evaluateStock` function marks a (product, warehouse) pair short when the summed quantity is greater than `available`, mirroring the backend's confirm rule.
   - It blocks Continue on draft sales only. Unknown stock warns, and nothing can override a block (R4, R5, Q1, Q2).
4. **Warehouse pop-up (P2)**
   - The inline dropdown becomes a tap field inside the same band. The field opens an `AlertDialog` picker modeled on `showCustomerAddressPicker` (R6).
5. **Tap-to-apply (P2)**
   - `PaymentController.tender` replaces selecting a method and then pressing *Apply payment*. Methods that need a reference ask for it in a dialog.
   - The amount is pre-filled with the balance. The `submitting` flag guards against repeated taps (R7).
6. **Cash change (P2)**
   - Only cash may exceed the balance.
   - A dismissible change card keeps the change visible after the payment is applied (R8).

## Technical Context

**Language/Version**: Dart `^3.10.3`, Flutter stable (unchanged)

**Primary Dependencies**:
- Riverpod (`riverpod_annotation` / generator 4), `freezed` 4, `go_router` `^17.3.0`, `decimal`, the generated `mbe_api_client`.
- No new packages and no codegen re-run.

**Storage**: N/A (online-only, §VII). The stock cache is screen-scoped UI state, as it is today, not a persistence layer.

**Testing**:
- `flutter_test` + `mocktail`; widget tests use `ProviderScope` overrides and `pos_test_harness.dart`.
- The harness gains a `/sales/cash-sessions/:cashSessionId` stub route.
- POS capture and payment goldens and screenshots are regenerated.

**Target Platform**: Web/desktop first (Expanded tier). Compact (390 px) is verified for the dialog and the payment pane through the existing `pos_compact_layout_test`.

**Project Type**: Flutter client application, feature-first layered

**Performance Goals**:
- Resuming a sale costs one `product-lookup` per distinct product without cached stock. The calls run concurrently, and POS sales have few distinct products.
- Two network reads are added in total: one session re-read per *New sale*, and one per tender.

**Constraints**:
- The line band's height and baseline are unchanged (§VI measuring tests).
- All amounts go through `formattersProvider` (§V guard).
- RBAC stays as it is: the close form keeps its own `cashSessionClose` gate (R2 limitation).

**Scale/Scope**:

| | Files |
|---|---|
| **New** | `capture/warehouse_picker_dialog.dart`, `capture/stock_gate.dart`, `payment/payment_reference_dialog.dart`, `payment/payment_change_card.dart` |
| **Edited, session** | `pos_sales_list_screen.dart`, `pos_workspace_screen.dart`, `pos_gate_screen.dart`, `domain/entities/current_session.dart` (`isValid`) |
| **Edited, filters** | `core/navigation/list_query.dart` |
| **Edited, stock / warehouse** | `capture/product_stock_cache.dart`, `capture/capture_step.dart`, `capture/sale_line_editing.dart`, `capture/sale_line_row.dart`, `capture/sale_line_card.dart` |
| **Edited, payment** | `payment/payment_controller.dart`, `payment/payment_capture_pane.dart`, `payment/payment_method_grid.dart`, `payment/payment_step.dart` |
| **Edited, l10n** | both `.arb` files, plus the regenerated `app_localizations*.dart`; about 10 keys added |

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Verdict | How |
|---|---|---|
| **I. Feature-first layering** | Pass | Everything stays in `features/sales/{domain,presentation}`. The URI helper stays in `core/navigation`, where the builder already lives. `evaluateStock` is a pure function beside the capture widgets, the same place as the existing `shortfall()`. Presentation reaches repositories only through providers. |
| **II. Riverpod** | Pass | The session re-read uses `ref.refresh(...future)`. The stock cache stays a `Notifier`. `PaymentDraft` gains `lastChange`. No other DI is added. |
| **III. Contract-driven API** | Pass | Uses only the existing generated `productLookup`, `getCurrent`, `createPayment` and `applyPayment`. **No mbe-api change is required to ship.** The batch `product-lookup` parameter was filed as mbe-api#237 (R4) and shipped on 2026-10-18; the client was regenerated and `ensureStockFor` uses the batch call (`productLookupByIds`). |
| **IV. Deny-by-default RBAC** | Pass | *New sale* is still hidden without `pos` create. The close screen keeps its `cashSessionClose` gate, so a cashier without it sees the existing supervisor-required message (documented in R2). No new privilege or `SystemObject` is added. |
| **V. Material 3 / l10n / formatting** | Pass | `AlertDialog`, `ListTile`, `InputDecorator` and a `Card` for the change. Every new string is in both `.arb` files. Amounts go through `formattersProvider`. The formatting guard is unaffected. |
| **VI. Desktop-first, compact-ready** | Pass | The warehouse field keeps the measured band height and baseline (existing `sale_line_*` measuring tests are kept). The dialog is not a record surface. Compact behavior is verified at 390 px with `expectNoHorizontalScroll`. No new list screens. |
| **VII. Online-only** | Pass | Nothing is persisted. The stock cache is per-screen and re-read from the API. |
| **Quality gates** | Pass | Unit tests: `evaluateStock`, `tender`/guard/cap/`lastChange`, the URI helper. Widget tests: session redirect, workspace `/new`, pushed Advanced search, warehouse dialog, Continue gate, tap-to-apply, change card. Goldens are regenerated. |

**Post-design re-check** (after Phase 1): still passing. No Complexity Tracking entries.

## Project Structure

### Documentation (this feature)

```text
specs/047-pos-sales-fixes/
├── plan.md              # This file
├── research.md          # Phase 0 (R1–R9)
├── data-model.md        # Phase 1
├── quickstart.md        # Phase 1
├── contracts/
│   └── ui-contracts.md  # Phase 1 (C1–C8)
├── checklists/
│   └── requirements.md
└── tasks.md             # Phase 2 (/speckit-tasks)
```

### Source Code (repository root)

```text
lib/
├── core/navigation/list_query.dart                     # currentRouteUri (C3)
├── features/sales/
│   ├── domain/entities/current_session.dart            # + isValid
│   └── presentation/
│       ├── pos_sales_list_screen.dart                  # New sale → re-read / redirect (C1)
│       ├── pos_workspace_screen.dart                   # /new under stale → close screen (C2)
│       ├── pos_gate_screen.dart                        # stale banner → blocking banner (C2)
│       ├── capture/
│       │   ├── product_stock_cache.dart                # ProductStock + ensureStockFor (C4)
│       │   ├── stock_gate.dart                         # NEW evaluateStock (C4)
│       │   ├── capture_step.dart                       # Continue gate + reason
│       │   ├── sale_line_editing.dart                  # warehouse field → dialog
│       │   ├── warehouse_picker_dialog.dart            # NEW (C5)
│       │   ├── sale_line_row.dart, sale_line_card.dart # wire field
│       └── payment/
│           ├── payment_controller.dart                 # tender, prefill, cap, lastChange
│           ├── payment_capture_pane.dart               # drop submit + reference field
│           ├── payment_method_grid.dart                # tiles → tender
│           ├── payment_reference_dialog.dart           # NEW (C6)
│           ├── payment_change_card.dart                # NEW (C7)
│           └── payment_step.dart                       # session banner + change card
└── l10n/app_en.arb, app_es.arb (+ regenerated app_localizations*.dart)

test/
├── unit/core/navigation/list_query_test.dart
├── unit/features/sales/{payment_controller,stock_gate}_test.dart
├── widget/features/sales/{pos_sales_list_screen,pos_workspace_route,pos_gate_screen,
│   advanced_search_screen,sale_line_row,warehouse_picker_dialog,capture_step_gate,
│   payment_step_gate,payment_step_layout,payment_capture_pane_reflow,
│   payment_method_grid,pos_compact_layout}_test.dart
├── widget/features/sales/pos_test_harness.dart        # + cash-session detail stub route
└── golden/pos_capture_golden_test.dart (+ screenshots)
```

**Structure Decision**: Existing feature-first layout. All work is inside `features/sales/presentation` plus one helper in `core/navigation`.

## Complexity Tracking

No violations. Nothing to justify.
