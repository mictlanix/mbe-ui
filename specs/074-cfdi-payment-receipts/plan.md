# Implementation Plan: CFDI Payment Receipts (REP)

**Branch**: `074-cfdi-payment-receipts` | **Date**: 2026-11-18 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `specs/074-cfdi-payment-receipts/spec.md`. The
wireframes are in [wireframes.md](./wireframes.md), and research.md R1–R7 settle their open
questions.

## Summary

This spec extends `lib/features/invoicing` (specs 066, 072, 073) so that billing can create
and edit CFDI payment receipts (type 200, Pagos 2.0) for PPD invoices. It covers
mictlanix/mbe-roadmap#54. The server side is mbe-api spec 028 (#53). The work, in order:

1. **Domain.** `FiscalDocument` gains the receipt fields (payment date, amount, reference,
   source payment, paid invoices) and getters (`isPaymentReceipt`, `assignedAmount`,
   `unassignedAmount`, `showsNoProposalBanner`). `isEditableKind` and `needsPaymentForm`
   widen to receipts. New `PaidInvoice` and `NewPaymentReceipt`; `InvoiceHeaderPatch` gains
   four fields (R12).
2. **Data.** Four repository methods (`createPaymentReceipt`, `addPaidInvoice`,
   `updatePaidInvoice`, `removePaidInvoice`), the receipt fields in the header PUT, and the
   mapping of the new response fields. Matching `FiscalDocumentActions` methods.
3. **Create.** The new-invoice dialog becomes a shared create dialog with three modes
   (C35, R13). It is reached from the customer payment detail (C34) and from a second button
   on the Facturas list (C36).
4. **Receipt detail.** Payment section, paid-invoices section, payment summary in place of
   lines, relations and totals; no-proposal banner (C37–C39).
5. **Dialogs.** The header dialog in receipt mode (C40), add paid invoice with the 072 picker
   (C41, R14), and edit/remove amount (C42).
6. **Error codes.** Ten codes are localized and flipped to `IN` (R11).
7. **Naming.** The type's Spanish label `fiscalDocumentKindPaymentReceipt` changes from "Recibo de pago" to "Complemento de pago" (English stays "Payment receipt").

No new route, no navigation change, no new package and no client regeneration: the client
already has spec 028's receipt routes, models and codes.

## Technical Context

**Language/Version**: Dart `^3.10.3`, Flutter 3.47.7 stable (unchanged)

**Primary Dependencies**:
- Riverpod 3 (riverpod_generator), freezed, `go_router` and `decimal`.
- The generated `mbe_api_client`: `FiscalDocumentsApi.createPaymentReceipt…`,
  `addPaidInvoice…`, `updatePaidInvoice…`, `removePaidInvoice…`, and `InvoiceUpdate`'s
  receipt fields.
- No new packages.

**Storage**: N/A (online-only, §VII)

**Testing**:
- `flutter_test` + `mocktail` with `ProviderScope` overrides and the existing
  `invoicing_harness.dart`.
- The live test `test/integration/fiscal_documents_live_test.dart` gains a receipt group.
  It runs behind `MBE_WRITE=true` with the simulated PAC, on dev only, and the user is asked
  first (R15).

**Target Platform**: web and desktop first, with a compact tier required (§VI)

**Project Type**: Flutter client application, feature-first layered

**Performance Goals**:

| Action | Requests |
|---|---|
| Create | 1 read of the customer (taxpayers), 1 write, then the new detail (1) |
| Add paid invoice | picker pages (20 per page), 1 write (returns the document) |
| Edit / remove amount, header, confirm, reopen | 1 write each, returning the document |

**Constraints**:
- Use `formattersProvider` for amounts and dates, and tokens for spacing and colours.
- Every string goes in both `.arb` files.
- Format only the changed files.
- Never compute installments or balances client-side; only the unassigned difference, from
  server values (R4).

**Scale/Scope**:

| | Files |
|---|---|
| **New source (2)** | `features/invoicing/presentation/{paid_invoice_dialogs, receipt_sections}.dart` |
| **Edited source (≈12)** | `domain/entities/fiscal_document.dart`; `domain/repositories/fiscal_document_repository.dart`; `data/fiscal_document_repository_impl.dart`; `presentation/{fiscal_document_actions, fiscal_document_detail_screen, new_invoice_dialog, invoice_header_dialog, fiscal_document_candidate_picker, fiscal_documents_list_screen}.dart`; `features/sales/presentation/payments/payment_detail_screen.dart`; `core/errors/localize_problem.dart`; both `.arb` files; `specs/058-localized-api-errors/contracts/code-scope.tsv` (10 rows `OUT` → `IN`) |
| **New tests (3)** | `test/widget/features/invoicing/paid_invoice_dialogs_test.dart`, `test/widget/features/invoicing/receipt_detail_test.dart`, `test/unit/features/invoicing/fiscal_document_receipt_test.dart` |
| **Edited tests (≈10)** | `fiscal_document_repository_impl_test`, `fiscal_document_actions_test`, `fiscal_document_fixtures`, `new_invoice_dialog_test`, `invoice_header_dialog_test`, `fiscal_document_candidate_picker_test`, `fiscal_documents_list_screen_test`, `payment_detail_screen_test`, `fiscal_document_kind_test` (label rename), `catalog_coverage_test` (181 → 191), `problem_fixtures`; the live test is extended |

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

These verdicts are against **v1.15.0**.

| Principle | Verdict | How |
|---|---|---|
| **I. Feature-first layering** | Pass | Everything stays in `features/invoicing`. The payment detail (sales) only calls the invoicing create dialog, as other cross-feature entry points do, and reaches no invoicing data layer. |
| **II. Riverpod** | Pass | Writes go through the keep-alive `FiscalDocumentActions` and refresh the detail from the returned document. The dialogs hold local form state only. |
| **III. Contract-driven API** | Pass | Only generated operations are used. **Error text**: the ten new reachable codes are localized and flipped to `IN` (R11). The "already has a receipt" path reads `params.fiscal_document_id`, never `detail` (R9). **Upstream**: nothing blocks this spec. The list's missing PPD/recipient filter (spec assumption) is a follow-up candidate, not filed. |
| **IV. Deny-by-default RBAC** | Pass | Create needs 23 create; edits need 23 update; the source-payment link needs 8 read (C44). Each action is absent without its right. Banners with advice show only with 23 update. |
| **V. Material 3 / design system** | Pass | Only shared components: `ResponsiveDialog`, `DataTableView`, `FactStripRow`, `ListStateViews`, `FormErrorBanner`, the existing `FiscalDocumentCandidatePicker` and `FiscalDocumentRefusal`. Colours from `ColorScheme`. **Largest text level**: quickstart step 12. |
| **VI. List and record-surface rules** | Pass | **List**: one extra header button, no row changes. **Surface**: the existing full detail screen; `AppBar.actions` stays empty and every action is in the body's action row. **Delete**: none; drafts are not deletable, as in 066. Paid-invoice remove is a row action with a confirm dialog. **Control band**: the paid-invoice row and compact card (folio link, amounts, edit and remove icons) and the add dialog's amount row are asserted for symmetric padding and a shared baseline (T011, T020), as 073 did for its copy row. Edit and remove use the shared icons from `core/widgets/catalog_action_icons.dart`. |
| **VII. Online-only, server-rendered documents** | Pass | PDF and XML stay the server's. Every write re-reads the document. |
| **Quality gates** | Pass | Unit, widget and live tests are listed in R15. `flutter analyze` must be clean. Coverage is enforced by `catalog_coverage_test`. |

**Post-design re-check** (after Phase 1): unchanged.
- **Shared touches**: `core/errors/localize_problem.dart` (10 arms), the 058 code-scope TSV,
  and `FiscalDocumentCandidatePicker` (two optional parameters; existing callers unchanged).
- The create dialog refactor keeps the old entry point and keys, so 066's tests stay valid.
- No deviation needs Complexity Tracking.

## Project Structure

### Documentation (this feature)

```text
specs/074-cfdi-payment-receipts/
├── spec.md
├── wireframes.md        # drawn before planning; its open questions are settled in research.md R1–R7
├── plan.md              # this file
├── research.md          # R1–R15
├── data-model.md
├── quickstart.md
├── contracts/
│   └── ui-contracts.md  # C34–C44 (continuing 066's C1–C14, 072's C15–C24, 073's C25–C33)
├── checklists/
│   └── requirements.md
└── tasks.md             # /speckit-tasks
```

### Source Code (repository root)

```text
lib/features/invoicing/
├── domain/
│   ├── entities/fiscal_document.dart                 # receipt fields + getters, PaidInvoice, NewPaymentReceipt, patch fields
│   └── repositories/fiscal_document_repository.dart  # + createPaymentReceipt, add/update/removePaidInvoice
├── data/fiscal_document_repository_impl.dart          # the four operations, receipt header fields, response mapping
└── presentation/
    ├── fiscal_document_actions.dart          # + the four actions
    ├── fiscal_document_detail_screen.dart    # C37–C39, C43; receipt gates
    ├── receipt_sections.dart                 # new: payment section, paid invoices, summary
    ├── paid_invoice_dialogs.dart             # new: add (C41), edit amount and remove (C42)
    ├── new_invoice_dialog.dart               # shared create dialog, three modes (C35)
    ├── invoice_header_dialog.dart            # receipt mode (C40)
    ├── fiscal_document_candidate_picker.dart # + typeCode, excludeIds
    └── fiscal_documents_list_screen.dart     # + "Nuevo complemento de pago" (C36)

lib/features/sales/presentation/payments/payment_detail_screen.dart   # C34
lib/core/errors/localize_problem.dart          # 10 arms
lib/l10n/app_{es,en}.arb
specs/058-localized-api-errors/contracts/code-scope.tsv

test/unit/features/invoicing/…   test/widget/features/invoicing/…
test/widget/features/sales/payment_detail_screen_test.dart
test/unit/core/errors/…          test/integration/fiscal_documents_live_test.dart
```

**Structure Decision**: Extend `features/invoicing` in place; one entry point in
`features/sales`. No new feature module, route or navigation entry.

## Complexity Tracking

No constitution violations to justify.
