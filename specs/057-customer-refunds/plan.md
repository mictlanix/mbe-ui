# Implementation Plan: Customer Refunds

**Branch**: `057-customer-refunds` | **Date**: 2026-10-28 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/057-customer-refunds/spec.md`

Roadmap: Closes mictlanix/mbe-roadmap#29 · Upstream: mbe-api#284, #285, #286, #287 (filed 2026-10-28, open)

## Summary

Clerks refund returned goods from a paid order. A refund can be started from "Devolver" on the order (Pedidos or POS) or from the new **Devoluciones** list.

**The flow:**
- The clerk opens a draft refund, or resumes the order's existing draft.
- They set return quantities and warehouses. Each change is saved to the server, and totals come back from it.
- They confirm, choosing cash or a credit note.

Confirmed refunds show how the money went back. The credit-notes list links each note to its refund. Printing waits for mbe-api#287.

**Technical approach:**
- **Data:** a new `CustomerRefundRepository` over the generated `CustomerRefundsApi`, mapped to freezed entities.
- **Starting a refund:** a shared `openOrResume` lists the order's drafts, then checks the order, then opens one (R2). Refusals are classified from the order's own status, not from server prose (R3).
- **Editing:** the detail screen reuses the stepper, warehouse picker, and `tracked()` write patterns from the sale editor (R4).
- **Confirming:** a cash-session pre-check, then a dialog with no default payout (R5).
- **Interim workarounds**, each marked `// simplified`: per-row customer names (R7, #284), and a credit-note lookup by refund (R6, #286).

## Technical Context

**Language/Version**: Dart `^3.10.3`, Flutter stable (unchanged)

**Primary Dependencies**: Riverpod 3 (riverpod_generator), freezed, `go_router`, `data_table_2`, `decimal` (only through `money.dart`), and the generated `mbe_api_client`. No new packages and no codegen: `CustomerRefundsApi`, `RefundPayout` and `CustomerRefundConfirm` already exist.

**Storage**: N/A (online-only, §VII)

**Testing**: `flutter_test` + `mocktail` with `ProviderScope` overrides. The templates are `pos_test_harness.dart`, `order_workspace_cancel_test.dart`, `payment_detail_screen_test.dart` and the credit-notes list tests. There is one live quickstart test with runtime fixture discovery and an opt-in write step (R12).

**Target Platform**: web and desktop first. The detail lines table must also work at compact widths (§VI).

**Project Type**: Flutter client application, feature-first layered

**Performance Goals**:
- The list costs one request per page, plus one cached customer-name lookup per distinct customer (R7).
- "Devolver" costs one list request, plus an order read and a POST when no draft exists.
- The payout lookup is usually one request (R6).

**Constraints**:
- Totals and refundable quantities are always the server's.
- Writes are serialized per refund.
- Amounts go through `formattersProvider`. Spacing comes from tokens. Every string lives in `.arb`.
- Format only the changed files.

**Scale/Scope**:

| | Files |
|---|---|
| **New (≈11 source)** | `domain/entities/customer_refund.dart`, `domain/repositories/customer_refund_repository.dart`, `data/customer_refund_repository_impl.dart`, `presentation/refunds/{refunds_filter, refunds_list_controller, refunds_list_screen, refund_detail_screen, refund_editor_controller, refund_confirm_dialog, refund_open_or_resume, refund_outcome_provider}.dart` |
| **Edited (≈10 source)** | `data/wire_value_setters.dart` (Quantity3), `domain/repositories/credit_note_repository.dart` + `data/credit_note_repository_impl.dart` (`findByRefund`), `credit_notes/credit_notes_list_screen.dart` (refund link), `orders/order_header_panel.dart`, `pos_sale_detail_view.dart`, `app/router/app_router.dart`, `core/navigation/nav_destinations.dart`, both `.arb` files |

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

These verdicts are against **v1.14.0**.

| Principle | Verdict | How |
|---|---|---|
| **I. Feature-first layering** | Pass | Everything is in `features/sales/{domain,data,presentation}`. Presentation reaches data only through `customerRefundRepositoryProvider` and `creditNoteRepositoryProvider`. |
| **II. Riverpod** | Pass | The list controller is a family keyed by `RefundsFilter`, and the URL is its state. `RefundEditor` is an `AsyncNotifier` with the mutations. `refundOutcomeProvider` is a read-only `FutureProvider.family`, the deviation spec 054 recorded for providers with no mutation method. |
| **III. Contract-driven API** | Pass | Only generated operations, mapped to freezed entities. Each server gap is filed upstream (mbe-api#284 to #287), not patched. The two interim workarounds carry `// simplified` markers. Printing is not hand-written against a missing endpoint (R10). |
| **IV. Deny-by-default RBAC** | Pass | Routes and nav are gated by CustomerRefunds (22) read. Devolver and Nueva devolución need create and read. Line edits and cancel need update. Confirm needs CustomerRefundConfirm (110) update. Anything a user can't use is hidden. Routes document their objects (C1). |
| **V. Material 3 / one formatting surface** | Pass | `fmt.display.*` only. Shared components only: `CatalogFilterBar`, `CatalogListStateView`, `DataTableView`, `QuantityStepper`, `showWarehousePicker`, `ResponsiveDialog`, `ErrorBanner`. |
| **VI. List and record-surface rules** | Pass | The list has a filter row, the table and pagination. The search slot is omitted because the endpoint has none until #285. **Record surface:** a full screen with a per-record URL, because the refund has child lines and is linked from other screens (R1). Actions sit in the body, not the app bar. |
| **VII. Online-only** | Pass | Nothing is persisted locally. A receipt, once available, is rendered by the server. |
| **Quality gates** | Pass | Unit, widget, router and live tests are listed in R12. `flutter analyze` must be clean. |

**Post-design re-check** (after Phase 1): still passing. There is no change to `core/widgets/`, `core/formatting/` or `AppError`, and no codegen. The only `core/` touches are the nav entry and the route gate.

## Project Structure

### Documentation (this feature)

```text
specs/057-customer-refunds/
├── spec.md                # /speckit-specify + /speckit-clarify (2026-10-28)
├── plan.md                # This file
├── research.md            # Phase 0 (R1–R12)
├── data-model.md          # Phase 1
├── quickstart.md          # Phase 1
├── contracts/
│   └── ui-contracts.md    # Phase 1 (C1–C7)
├── checklists/
│   └── requirements.md
└── tasks.md               # Phase 2 (/speckit-tasks)
```

### Source Code (repository root)

```text
lib/
├── app/router/app_router.dart                     # + branch 24, detail route, _routeGate clause (C1)
├── core/navigation/nav_destinations.dart          # + NavBranch.customerRefunds, entry after Notas de crédito
├── features/sales/
│   ├── domain/
│   │   ├── entities/customer_refund.dart          # NEW: CustomerRefund, RefundLine, summary, RefundStatus, RefundPayout
│   │   └── repositories/
│   │       ├── customer_refund_repository.dart    # NEW (C2)
│   │       └── credit_note_repository.dart        # + findByRefund (R6)
│   ├── data/
│   │   ├── customer_refund_repository_impl.dart   # NEW
│   │   ├── credit_note_repository_impl.dart       # + findByRefund (interim, #286)
│   │   └── wire_value_setters.dart                # + Quantity3 setter
│   └── presentation/
│       ├── refunds/                               # NEW
│       │   ├── refunds_filter.dart
│       │   ├── refunds_list_controller.dart
│       │   ├── refunds_list_screen.dart
│       │   ├── refund_open_or_resume.dart         # openOrResume + RefundRefusal (C3)
│       │   ├── refund_editor_controller.dart      # writes, confirm, cancel, adjustment notice
│       │   ├── refund_detail_screen.dart
│       │   ├── refund_confirm_dialog.dart
│       │   └── refund_outcome_provider.dart       # RefundOutcome (interim, #286)
│       ├── orders/order_header_panel.dart         # + Devolver
│       ├── pos_sale_detail_view.dart              # + Devolver
│       └── credit_notes/credit_notes_list_screen.dart  # refund link (C6)
└── l10n/app_en.arb, app_es.arb                    # + keys (C7)

test/
├── unit/features/sales/      # customer_refund_repository_impl, customer_refund entity, refunds_filter,
│                             # refunds_list_controller, refund_editor_controller, refund_open_or_resume,
│                             # credit_note_repository_impl (findByRefund)
├── widget/features/sales/    # refunds_list_screen, refund_detail_screen, refund_confirm_dialog,
│                             # order_header_refund_button, pos_sale_detail_view (extended),
│                             # credit_notes_list_screen (refund link)
├── unit/app/router/app_router_test.dart + unit/core/navigation/nav_destinations_test.dart
└── integration_test/customer_refunds_quickstart_test.dart   # NEW (live)
```

**Structure Decision**: a single Flutter project with feature-first layering. Refunds live in `features/sales`, next to the orders they unwind and the credit notes they issue.

## Complexity Tracking

There are no violations to justify.

**Upstream dependencies** (constitution §III):

| Issue | Effect on this feature | Client stance until it ships |
|---|---|---|
| mbe-api#284 (customer names) | The list resolves each customer per row | `PaymentCustomerName` with no name. Map `customer_display_name` when it ships (R7) |
| mbe-api#285 (search, own filter, ordering) | No search box. No "my refunds". Newest first, not open first | Status, customer and order facets only (R8) |
| mbe-api#286 (payout on the refund) | The payout is inferred by scanning the customer's credit notes | `findByRefund`, marked `// simplified`. Remove it when the fields ship (R6) |
| mbe-api#287 (refund receipt) | User Story 3 can't be built | Print tasks gated on it. No hand-written call (R10) |

**Known gap, not filed**: the server doesn't stop a second draft refund being opened for an order. The client resumes an existing draft (R2), so only a true race leaves a duplicate.
