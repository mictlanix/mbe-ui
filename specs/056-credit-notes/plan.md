# Implementation Plan: Credit Notes

**Branch**: `056-credit-notes` | **Date**: 2026-10-27 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/056-credit-notes/spec.md`

Roadmap: Closes mictlanix/mbe-roadmap#28 · Upstream: mbe-api#277, #278, plus one unfiled request (research R4)

## Summary

Cashiers spend credit notes in the POS Cobro step, and staff get a read-only **Notas de crédito** list.

**In the Cobro step:**
- A named customer's spendable credit appears as one tile in the payment-method grid. Tapping it applies their notes oldest first, up to the sale's balance.
- On a walk-in sale, the same tile becomes "Canjear nota de crédito". It redeems one ticket by the number under its barcode.

**Technical approach:**
- **Redemption:** the existing `applyPayment` on each note's backing payment. No payment is created (R1). The new `PaymentController.tenderCreditNotes` keeps `tender`'s lock and refresh wiring.
- **Data:** one new repository over the generated `CreditNotesApi`. It never sends `open_only`, so mbe-api#278 can't hide notes (R2, R8).
- **Figures:** shown exactly as the server reports them (FR-015).

**Not working until mbe-api#277 ships:** legacy notes read 0.00 and can't be spent. This is accepted and tracked upstream, not patched on the client.

## Technical Context

**Language/Version**: Dart `^3.10.3`, Flutter 3.47.7 stable (unchanged)

**Primary Dependencies**: Riverpod 3 (riverpod_generator 4), freezed 4, `go_router`, `data_table_2`, `decimal` (only through `money.dart`), and the generated `mbe_api_client`. No new packages and no codegen: `CreditNotesApi` and `OrderApplicationResponse.paymentType` already exist.

**Storage**: N/A (online-only, §VII)

**Testing**: `flutter_test` + `mocktail` with `ProviderScope` overrides. The templates are `payment_controller_test.dart`, `pos_test_harness.dart` and the Pagos list tests. There is one live test with runtime fixture discovery (R11).

**Target Platform**: Web/desktop first. The new grid tile must pass the existing extra-large-text POS tests (`pos_047_extra_large_text_test.dart`).

**Project Type**: Flutter client application, feature-first layered

**Performance Goals**:
- The customer's credit is one request per Cobro visit in practice: at most 13 notes per named customer on the dev tenant.
- A ticket lookup is one payment read, plus walk-in pages newest first until a match: usually 1 page (R4).
- The list is one request per page with the toggle off. With the toggle on and no customer, every page is read once (R8).

**Constraints**:
- The app never computes a remaining balance (FR-015).
- The app never sends `open_only` (#278).
- Applications run one at a time (R3).
- Amounts go through `formattersProvider`. Spacing comes from tokens. All strings live in `.arb` files.
- Format only the changed files.

**Scale/Scope**:

| | Files |
|---|---|
| **New (≈8 source files)** | `domain/entities/credit_note.dart`, `domain/repositories/credit_note_repository.dart`, `data/credit_note_repository_impl.dart`, `presentation/payment/customer_credit_controller.dart`, `presentation/payment/credit_note_ticket_dialog.dart`, `presentation/credit_notes/{credit_notes_filter, credit_notes_list_controller, credit_notes_list_screen}.dart` |
| **Edited (≈9 source files)** | `payment_controller.dart`, `payment_method_grid.dart`, `payment_step.dart` (issue messages), `applied_payments_panel.dart`, `entities/sale_payment.dart`, `customer_payment_repository.dart` (doc comment), `app_router.dart`, `nav_destinations.dart`, both `.arb` files (C6) |

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

These verdicts are against **v1.14.0**.

| Principle | Verdict | How |
|---|---|---|
| **I. Feature-first layering** | Pass | Everything is in `features/sales/{domain,data,presentation}`. Presentation reaches the new repository only through `creditNoteRepositoryProvider`. |
| **II. Riverpod** | Pass | `customerCreditProvider` and the list controller are providers. The URL is the list's state. Ticket-dialog state is local to the dialog. |
| **III. Contract-driven API** | Pass | Only generated operations, mapped to a freezed `CreditNote`. Server defects are filed (mbe-api#277, #278), not patched. The `customer_payment` filter request is drafted in R4; filing it is pending the user's approval. The client works without it, through a marked interim scan. |
| **IV. Deny-by-default RBAC** | Pass | The route and nav are gated by `creditPayments` (83) read. The Cobro tiles need `creditPayments` read and `customerPayments` (8) create, plus read for the ticket lookup. The row tap needs `customerPayments` read. Anything a user can't use is hidden (R7). The route documents its object (C1). |
| **V. Material 3 / one formatting surface** | Pass | `fmt.display.*` only. Shared components only: `CatalogFilterBar`, `showCatalogFilterSheet`, `CatalogEntityPicker`, `CatalogListStateView`, `DataTableView`, `ErrorBanner`. |
| **VI. List screen rules** | Pass | Filter row, list, pagination. The search slot is omitted because the endpoint has none, and the facets are in the drawer. Amounts and origin are never truncated; only the customer name is. **No row Edit icon:** a credit note is never edited, following the Pagos and cash-sessions precedent. **Record surface:** the backing payment's existing full detail screen. No new surface is needed. |
| **VII. Online-only** | Pass | Nothing is persisted locally. |
| **Quality gates** | Pass | Unit, widget and live tests are listed in R11. `flutter analyze` must be clean. |

**Post-design re-check** (after Phase 1): still passing. There is no change to `core/widgets/` or `core/formatting/`, no new `AppError` variant, and no codegen.

## Project Structure

### Documentation (this feature)

```text
specs/056-credit-notes/
├── spec.md                # /speckit-specify (2026-10-27)
├── plan.md                # This file
├── research.md            # Phase 0 (R1–R11)
├── data-model.md          # Phase 1
├── quickstart.md          # Phase 1
├── contracts/
│   └── ui-contracts.md    # Phase 1 (C1–C6)
├── checklists/
│   └── requirements.md
└── tasks.md               # Phase 2 (/speckit-tasks)
```

### Source Code (repository root)

```text
lib/
├── app/router/app_router.dart                     # + shell branch 23, _routeGate clause (C1)
├── core/navigation/nav_destinations.dart          # + NavBranch.creditNotes, nav entry after Pagos
├── features/sales/
│   ├── domain/
│   │   ├── entities/credit_note.dart              # NEW
│   │   ├── entities/sale_payment.dart             # + type (R6)
│   │   └── repositories/
│   │       ├── credit_note_repository.dart        # NEW
│   │       └── customer_payment_repository.dart   # doc comment only
│   ├── data/credit_note_repository_impl.dart      # NEW
│   └── presentation/
│       ├── payment/
│       │   ├── payment_controller.dart            # + tenderCreditNotes, ticket lookup, new issues
│       │   ├── customer_credit_controller.dart    # NEW
│       │   ├── credit_note_ticket_dialog.dart     # NEW
│       │   ├── payment_method_grid.dart           # + credit tile, subtitle override
│       │   ├── payment_step.dart                  # + issue messages
│       │   └── applied_payments_panel.dart        # + credit-note label
│       └── credit_notes/                          # NEW
│           ├── credit_notes_filter.dart
│           ├── credit_notes_list_controller.dart
│           └── credit_notes_list_screen.dart
└── l10n/app_en.arb, app_es.arb                    # + keys (C6)

test/
├── unit/features/sales/      # credit_note_repository_impl, payment_controller (extended),
│                             # customer_credit_controller, credit_notes_filter, credit_notes_list_controller
├── widget/features/sales/    # payment_method_grid (extended), credit_note_ticket_dialog,
│                             # applied_payments_panel, credit_notes_list_screen
├── unit/app/router/app_router_test.dart           # + gate
└── integration/credit_notes_live_test.dart        # NEW
```

**Structure Decision**: a single Flutter project with feature-first layering. Credit notes live in `features/sales`, next to the payments they are a view over.

## Complexity Tracking

There are no violations to justify.

**Upstream dependencies** (constitution §III):

| Issue | Effect on this feature | Client stance |
|---|---|---|
| mbe-api#277 (+ addendum) | Legacy notes report 0 remaining, and the cashed-out note 158 reports 1,025.00 | Show the server's figures. Live redemption is tested only with notes issued through mbe-api. |
| mbe-api#278 | `open_only` gives short or empty pages and a wrong total | Never send it. Filter locally (R2, R8), with a `// simplified` marker to remove when it ships. |
| `customer_payment` filter (**unfiled**, R4) | A ticket lookup scans walk-in pages | Scan newest first and stop at the first match, with a `// simplified` marker. |
