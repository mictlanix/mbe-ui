# Implementation Plan: Payments Editor

**Branch**: `059-payments-editor` | **Date**: 2026-11-13 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/059-payments-editor/spec.md`

Roadmap: Closes mictlanix/mbe-roadmap#26 · Upstream: mbe-api#308 (filed 2026-11-13; not blocking). Every endpoint used already exists and is in the generated client. #308 would let apply work on another facility's payment, and until it ships that action is hidden (R5).

## Summary

Staff can reverse a payment application with a reason, apply a payment's unapplied money to another outstanding order of the customer, and record a credit payment or advance from the back office. The actions live on the existing Pagos payment view and list, plus a "Pagos" dialog on the Pedidos order screen.

**Technical approach:**
- **Data:** `CustomerPaymentRepository` gets a `PaymentType` on `createPayment` (POS default unchanged) and a new `listOutstandingOrders` that returns rows, not a sum (R5, R6).
- **Writes:** a back-office `paymentEditorProvider` runs reverse and apply, invalidates the payment, the list, the order's payments and the order, and returns errors as values (R3). The POS `PaymentController` is not reused, because it refreshes POS state.
- **Reverse dialog:** the POS dialog becomes public and localized, with an optional refund warning. `AppliedPaymentsPanel` gets `onReverse` and `onOpenPayment` callbacks so Pedidos can reuse it without touching the POS path (R3, R4, R7).
- **Record:** a `RecordPaymentDialog` launched from the Pagos toolbar. It reuses the facility payment-option source, `PaymentAmountField`, the customer picker, the walk-in check and the cash-session read (R6).
- **Errors:** eight `payment.*` codes get localized messages (R8).

## Technical Context

**Language/Version**: Dart `^3.10.3`, Flutter stable (unchanged)

**Primary Dependencies**:
- Libraries: Riverpod 3 (riverpod_generator), freezed, `go_router`, `data_table_2`, `decimal` (only through `money.dart`), and the generated `mbe_api_client`.
- No new packages, and no client regeneration.

**Storage**: N/A (online-only, §VII)

**Testing**:
- `flutter_test` + `mocktail` with `ProviderScope` overrides.
- Templates: `payment_detail_screen_test.dart`, the refunds list dialog tests, and `order_workspace_cancel_test.dart`.
- One live quickstart test, `integration_test/payments_editor_quickstart_test.dart` (R9).

**Target Platform**: web and desktop first. The dialogs must work at compact widths (§VI).

**Project Type**: Flutter client application, feature-first layered

**Performance Goals**:

| Action | Requests |
|---|---|
| Reverse | 1, plus 1 refund lookup |
| Apply dialog | 1 page of outstanding orders per search |
| Record | 1 to create, plus 1 session re-read for cash |

Each write also refetches the payment and its applications.

**Constraints**:
- Amounts and `unapplied` are always the server's.
- Use `Decimal` only.
- Use `formattersProvider` for display.
- Spacing comes from tokens.
- Every string goes in both `.arb` files.
- Format only the changed files.

**Scale/Scope**:

| | Files |
|---|---|
| **New (≈7 source)** | `domain/entities/outstanding_order.dart`, `presentation/payment/reversal_reason_dialog.dart`, `presentation/payments/{payment_editor_controller, reverse_application_flow, apply_payment_dialog, record_payment_dialog}.dart`, `presentation/orders/order_payments_dialog.dart` |
| **New tests** | unit: `outstanding_order_entity_test`, `payment_editor_controller_test`, `reverse_application_flow_test`; widget: `reversal_reason_dialog_test`, `applied_payments_panel_test`, `apply_payment_dialog_test`, `record_payment_dialog_test`, `order_header_payments_button_test`, `order_payments_dialog_test`; live: `integration_test/payments_editor_quickstart_test.dart` |
| **Edited (≈9 source)** | `domain/repositories/customer_payment_repository.dart`, `data/customer_payment_repository_impl.dart`, `presentation/payment/applied_payments_panel.dart`, `presentation/payments/{payment_detail_screen, payments_list_screen}.dart`, `presentation/orders/order_header_panel.dart`, `core/errors/localize_problem.dart`, both `.arb` files, `tool/seed_payment_fixtures.py` |

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

These verdicts are against **v1.15.0**.

| Principle | Verdict | How |
|---|---|---|
| **I. Feature-first layering** | Pass | Everything is in `features/sales/{domain,data,presentation}`. Presentation reaches data only through `customerPaymentRepositoryProvider` and `customerRefundRepositoryProvider`. |
| **II. Riverpod** | Pass | `paymentEditorProvider` is a notifier holding the mutations. Reads stay in the existing family providers, and the dialogs keep local form state only. |
| **III. Contract-driven API** | Pass | Only generated operations, mapped to freezed entities (`OutstandingOrder`). **API error text:** the endpoints the app now calls from new screens (create, apply, reverse, outstanding-orders, order payments) can return eight `payment.*` codes without messages. They are added in both locales, with params (R8). Already covered: cash-session, not-found, lock and forbidden. |
| **IV. Deny-by-default RBAC** | Pass | Record and apply need Customer Payments (8) create, reverse needs update, and the Pedidos dialog needs read. Each action is hidden without its right, mirroring the server's dependencies (R1). The routes are unchanged and still documented as CustomerPayments (8). |
| **V. Material 3 / one formatting surface** | Pass | `fmt.display.*` only. Shared components: `ResponsiveDialog`, `CatalogEntityPicker`, `PaymentAmountField`, `FormErrorBanner`, `DataTableView`. The reverse dialog's hard-coded Spanish is replaced with l10n. **Largest text level:** the apply dialog's table, the payment view's applications table with its new action column, and the record form are fixed-column-budget surfaces. They are verified at the largest of the four text sizes, at desktop width with real fonts, in the live walkthrough (T020), never assumed to fit. Widget tests can't answer this: their placeholder font is much wider (spec 055). |
| **VI. List and record-surface rules** | Pass | Record is a dialog launched from a toolbar action in the Pagos filter row, and the result opens on its own route. Apply and reverse are dialogs from the payment view. Pedidos uses a header action that opens a dialog (R7). The applications table gains one row action (reverse), within the "one additional action" rule, since it has no Edit. |
| **VII. Online-only** | Pass | Nothing is persisted. The ticket is server-rendered (spec 055). |
| **Quality gates** | Pass | Unit, widget and live tests are listed in R9. `flutter analyze` must be clean. Catalog coverage is enforced by `catalog_coverage_test.dart`. |

**Post-design re-check** (after Phase 1): still passing.
- The only `core/` touch is `localize_problem.dart`, which the catalog rule requires.
- The POS change is limited to the dialog's text and two optional panel callbacks. With them null, the panel behaves exactly as before.

## Project Structure

### Documentation (this feature)

```text
specs/059-payments-editor/
├── spec.md                # /speckit-specify (2026-11-13)
├── plan.md                # This file
├── research.md            # Phase 0 (R1–R9)
├── data-model.md          # Phase 1
├── quickstart.md          # Phase 1
├── contracts/
│   └── ui-contracts.md    # Phase 1 (C1–C7)
├── checklists/
│   └── requirements.md
└── tasks.md               # /speckit-tasks (not yet)
```

### Source Code (repository root)

```text
lib/features/sales/
├── domain/
│   ├── entities/outstanding_order.dart            # new
│   └── repositories/customer_payment_repository.dart   # +type, +listOutstandingOrders
├── data/customer_payment_repository_impl.dart     # same
└── presentation/
    ├── payment/
    │   ├── applied_payments_panel.dart            # +onReverse, +onOpenPayment
    │   └── reversal_reason_dialog.dart            # new (moved, localized, refund warning)
    ├── payments/
    │   ├── payment_editor_controller.dart         # new: reverse/apply + invalidations
    │   ├── reverse_application_flow.dart          # new: refund lookup + dialog + reverse
    │   ├── apply_payment_dialog.dart              # new
    │   ├── record_payment_dialog.dart             # new
    │   ├── payment_detail_screen.dart             # reverse column, apply button
    │   └── payments_list_screen.dart              # "Registrar pago"
    └── orders/
        ├── order_header_panel.dart                # "Pagos" button
        └── order_payments_dialog.dart             # new
lib/core/errors/localize_problem.dart              # 8 codes
lib/l10n/app_{es,en}.arb
tool/seed_payment_fixtures.py                      # spare outstanding order
test/unit/features/sales/…, test/widget/features/sales/…
integration_test/payments_editor_quickstart_test.dart
```

**Structure Decision**: a single Flutter app, with everything in the existing `features/sales` module, beside the spec 054 and 055 payment screens.

## Dependencies and risks

- **Legacy-order guard (R7):** Pedidos' "Pagos" button can't reach older back-office orders that have payments, because `isForeignOrder` declines them. Those orders are still served from Pagos. Changing the guard is out of scope.
- **mbe-api#308** (outstanding orders by facility): apply is hidden on another facility's payment until it ships. Reverse is unaffected.
- **mbe-api#276** (unapplied vs change) is already resolved by mbe-api spec 033: `unapplied` subtracts change. The client shows the server's figure.
- **POS regression risk:** the dialog move touches the register. A widget test pins the POS path (`onReverse == null` → `PaymentController.reverse`).

## Complexity Tracking

No violations.
