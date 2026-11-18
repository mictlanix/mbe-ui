# Implementation Plan: CFDI Credit Notes

**Branch**: `073-cfdi-credit-notes` | **Date**: 2026-11-18 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `specs/073-cfdi-credit-notes/spec.md`. The wireframes
are in [wireframes.md](./wireframes.md), and research.md R1–R7 settle their open questions.

## Summary

This spec extends `lib/features/invoicing` (specs 066 and 072) so that billing can create and
edit CFDI credit notes (type 100). It covers mictlanix/mbe-roadmap#56. The server side is
mbe-api spec 028. The work, in order:

1. **Domain.** `FiscalDocument` gains `isCreditNote`, `canIssueCreditNote`,
   `creditedInvoice` and `needsPaymentForm`. `isEditableDraft` and `canReopen` widen to
   credit notes that relate an invoice (R8).
2. **Data.** Two repository methods, `createCreditNote` and `copyInvoiceLine`, and two
   actions. The second action sends a multi-line copy one request at a time (R1, R12).
3. **Invoice detail.** "Emitir nota de crédito" and its confirmation dialog (C25, C26).
4. **Credit-note detail.** The existing editor with credit-note gates:
   - "Agregar de la factura" replaces "Agregar pedido";
   - no relation editing, and no "Pedido" chip;
   - a form-99 banner;
   - the header dialog in credit-note mode (C27, C30, C31).
5. **The copy dialog** (C29).
6. **Relation link**: on every relation row, for every type (C28, R4).
7. **Error codes and wording.** Four codes are localized, two error texts and the invoice-worded
   confirm/reopen/remove/empty-lines texts are made type-neutral, and one
   screen branch names the invoice in the exceeds-invoice refusal (R11, C32).

No new route, no navigation change, no new package and no client regeneration: the client at
f4271b49 already has spec 028's credit-note routes.

## Technical Context

**Language/Version**: Dart `^3.10.3`, Flutter 3.47.7 stable (unchanged)

**Primary Dependencies**:
- Riverpod 3 (riverpod_generator), freezed, `go_router` and `decimal`.
- The generated `mbe_api_client`: `FiscalDocumentsApi.createCreditNote…` and
  `copyInvoiceLine…`.
- No new packages.

**Storage**: N/A (online-only, §VII)

**Testing**:
- `flutter_test` + `mocktail` with `ProviderScope` overrides and the existing
  `invoicing_harness.dart`.
- The live test `test/integration/fiscal_documents_live_test.dart` gains a credit-note group.
  It runs behind `MBE_WRITE=true` with the simulated PAC, on dev only, and the user is asked
  first (R13).

**Target Platform**: web and desktop first, with a compact tier required (§VI)

**Project Type**: Flutter client application, feature-first layered

**Performance Goals**:

| Action | Requests |
|---|---|
| Create | 1 write, then the new detail (1) |
| Copy dialog | 1 read of the invoice (cached family), then n writes, then 1 detail refetch |
| Header, line, confirm, reopen | as in 066 |

**Constraints**:
- Use `formattersProvider` for amounts and quantities, and tokens for spacing and colours.
- Every string goes in both `.arb` files.
- Format only the changed files.
- Never compute the remaining-to-credit amount client-side (R6).

**Scale/Scope**:

| | Files |
|---|---|
| **New source (1)** | `features/invoicing/presentation/copy_invoice_lines_dialog.dart` |
| **Edited source (11)** | `domain/entities/fiscal_document.dart`; `domain/repositories/fiscal_document_repository.dart`; `data/fiscal_document_repository_impl.dart`; `presentation/{fiscal_document_actions, fiscal_document_detail_screen, invoice_action_dialogs, invoice_header_dialog, invoice_line_dialog}.dart`; `core/errors/localize_problem.dart`; both `.arb` files; `specs/058-localized-api-errors/contracts/code-scope.tsv` (4 rows go from `OUT` to `IN`) |
| **New tests (2)** | `test/widget/features/invoicing/copy_invoice_lines_dialog_test.dart`, `test/unit/features/invoicing/fiscal_document_credit_note_test.dart` |
| **Edited tests (≈9)** | `fiscal_document_repository_impl_test`, `fiscal_document_actions_test`, `fiscal_document_fixtures`, `fiscal_document_detail_screen_test`, `invoice_action_dialogs_test`, `invoice_header_dialog_test`, `invoice_line_dialog_test`, `catalog_coverage_test` (177 → 181), `problem_fixtures`; the live test is extended |

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

These verdicts are against **v1.15.0**.

| Principle | Verdict | How |
|---|---|---|
| **I. Feature-first layering** | Pass | Everything stays in `features/invoicing`. Presentation reaches data only through `FiscalDocumentActions` and the repository. The copy dialog reads the invoice through the existing detail provider family. |
| **II. Riverpod** | Pass | The writes go through the keep-alive `FiscalDocumentActions`. The sequential copy lives in the notifier and invalidates the detail once (R1). The dialogs hold local form state only. |
| **III. Contract-driven API** | Pass | Only generated operations are used. **Error text**: the four new reachable codes are localized and flipped to `IN`, and two reused texts are made type-neutral (R11). The exceeds-invoice folio is chosen by branching on `code` and reading `params.remaining`, never `detail`. **Upstream**: nothing blocks this spec. R6 (no remaining-to-credit amount) and R8 (`remove_relation` has no type guard) are recorded as follow-up candidates. |
| **IV. Deny-by-default RBAC** | Pass | Create needs 23 create; edits need 23 update; a manual product needs 56 create, as the server checks (C33). Each action is absent without its right. The banner's advice shows only with 23 update. |
| **V. Material 3 / design system** | Pass | Only shared components are used: `ResponsiveDialog`, `DataTableView`, `CompactField`, `ListStateViews`, `FormErrorBanner`, and the existing `FiscalDocumentRefusal` and `InvoiceTotals`. The banner colours come from `ColorScheme`. **Largest text level**: quickstart step 17. |
| **VI. List and record-surface rules** | Pass | **List**: unchanged. **Surface**: the existing full detail screen. `AppBar.actions` stays empty and every action is in the body's action row. **Delete**: none. Drafts are not deletable, as in 066. **Control band**: the copy dialog's row (checkbox, text, quantity field) is asserted for symmetric padding and a shared baseline (R10b). |
| **VII. Online-only, server-rendered documents** | Pass | The PDF and XML are still the server's. Every write re-reads the document. |
| **Quality gates** | Pass | Unit, widget and live tests are listed in R13. `flutter analyze` must be clean. Coverage is enforced by `catalog_coverage_test`. |

**Post-design re-check** (after Phase 1): unchanged.
- **Shared touches**: only `core/errors/localize_problem.dart` (4 arms) and the spec 058
  code-scope TSV.
- The relation link (R4) changes 066's relation rows for every type. That is intended and
  is tested.
- No deviation needs Complexity Tracking.

## Project Structure

### Documentation (this feature)

```text
specs/073-cfdi-credit-notes/
├── spec.md
├── wireframes.md        # drawn before planning; its open questions are settled in research.md R1–R7
├── plan.md              # this file
├── research.md          # R1–R13
├── data-model.md
├── quickstart.md
├── contracts/
│   └── ui-contracts.md  # C25–C33 (continuing 066's C1–C14 and 072's C15–C24)
├── checklists/
│   └── requirements.md
└── tasks.md             # /speckit-tasks
```

### Source Code (repository root)

```text
lib/features/invoicing/
├── domain/
│   ├── entities/fiscal_document.dart                 # isCreditNote, canIssueCreditNote, creditedInvoice, needsPaymentForm; widened gates
│   └── repositories/fiscal_document_repository.dart  # + createCreditNote, copyInvoiceLine
├── data/fiscal_document_repository_impl.dart          # the two generated operations
└── presentation/
    ├── fiscal_document_actions.dart        # + createCreditNote, copyInvoiceLines (sequential)
    ├── fiscal_document_detail_screen.dart  # C25, C27, C28, C30, C32
    ├── invoice_action_dialogs.dart         # + showIssueCreditNoteDialog (C26)
    ├── copy_invoice_lines_dialog.dart      # new (C29)
    ├── invoice_header_dialog.dart          # credit-note mode (C31)
    └── invoice_line_dialog.dart            # stays open on credit_quantity_exceeds_line

lib/core/errors/localize_problem.dart          # 4 arms
lib/l10n/app_{es,en}.arb
specs/058-localized-api-errors/contracts/code-scope.tsv

test/unit/features/invoicing/…   test/widget/features/invoicing/…
test/unit/core/errors/…          test/integration/fiscal_documents_live_test.dart
```

**Structure Decision**: Extend `features/invoicing` in place. This adds no new feature
module, route or navigation entry.

## Complexity Tracking

No constitution violations to justify.
