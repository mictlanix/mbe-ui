# Research: CFDI Credit Notes

Sources read on 2026-11-18:
- mbe-api `main` at 1c81e07: `app/services/invoice_service.py`, `docs/specs/10-fiscal-documents.md` and spec 028's `contracts/fiscal-receipts-credit-notes.md`.
- mbe-ui `main` at 05203fec: `lib/features/invoicing`, `lib/core/errors/localize_problem.dart`, and the generated client at f4271b49.

R1–R7 settle the open questions from [wireframes.md](./wireframes.md).

## R1. Copying several invoice lines (wireframe OQ1)

**Decision**: The dialog allows several picks. The actions notifier sends one
`POST /fiscal-documents/{id}/invoice-lines` per checked line, in the invoice's line order.
It stops at the first refusal and invalidates the detail once at the end.

When a copy is refused, the dialog stays open. The lines already added are unchecked and
marked "Agregada". The refusal names the line that failed. The clerk can fix it or close
the dialog.

**Rationale**:
- Returns usually span several lines.
- The server has no batch route, and each call is cheap.
- Stopping at the first refusal never hides a second one.
- Keeping what was added matches how the server already committed it.

**Alternatives**:
- One line per dialog: the clerk reopens the dialog once per line.
- Try all and report every failure: more state for a case that is rare, since the client
  already checks quantities first.
- Ask mbe-api for a batch route: not worth it for ≤ a few dozen lines.

## R2. Draft title (wireframe OQ2)

**Decision**: No change. `_title()` already renders non-invoice types as
"{kind} {folio | #id}", so a draft credit note is "Nota de crédito #63930", and a sealed
one is "Nota de crédito NC118". The wireframe's "· Borrador" is dropped; the state chip
already says Borrador.

**Rationale**: The existing behaviour already shows the type, so changing the title
adds nothing.

## R3. "Pedido" chip on copied lines (wireframe OQ3)

**Decision**: The chip is not shown on credit notes (`document.isCreditNote`).

**Rationale**: The server copies `order_detail` for remaining-quantity bookkeeping (spec
028), but `FiscalDocumentLine` has no link to the source invoice line. A "Pedido" chip would
point the clerk at an order the credit note was never built from.

## R4. Relation rows link to their document (wireframe OQ4)

**Decision**: In `_RelationsSection`, every relation's folio (or `#id`) becomes a link that
pushes `$fiscalDocumentsPath/${r.documentId}`. This applies to every document type, so
066's 04/07 relations gain it too.

**Rationale**:
- It is the same widget, with one condition fewer than a credit-note-only link.
- Any user who sees the detail already has Read on 23, which the target needs.
- 066's relation rows benefit for the same reason, so this is not scope creep in practice.
- `context.push` keeps Back returning to the credit note.

**Alternative**: Link only the type-01 row on credit notes. Rejected: it adds a special
case for no saving.

## R5. Payment form 99 (wireframe OQ5)

**Decision**:
- A credit-note draft whose `paymentForm == 99` shows a banner,
  `fiscal_document_banner_credit_note_form`, and only to users with Update on 23. Its
  colours are tertiary, like the waiting banners in 072.
- The header dialog in credit-note mode:
  - never offers 99;
  - opens with no form selected when the stored one is 99;
  - disables Guardar until a form is chosen.

**Rationale**:
- The create route takes only `{invoice}`, so asking during create would need a second
  request.
- The server refuses 99 only at confirm (`payment_form_required`). The header route accepts
  it on credit notes.
- The trap: `DropdownButtonFormField` asserts when `initialValue` is not among its items.
  So for a 99 document the initial value must be null.

## R6. No remaining-to-credit figure (wireframe OQ6)

**Decision**: Nothing on the draft. The confirm refusal carries `remaining`. No mbe-api issue
is filed now; it is listed as a follow-up candidate in the PR text, to be filed if the
manual checks show clerks need it.

**Rationale**:
- `FiscalDocumentResponse` has no such field.
- Computing it client-side would need every credit note related to the invoice. The list
  has no relation filter, and the constitution forbids client-computed server balances in
  spirit (FR-015 of spec 056).

## R7. Draft banner

**Decision**: A credit-note draft with a real payment form gets **no** banner, as an
invoice draft gets none today. The wireframe's "Borrador. Agrega las partidas…" banner
is dropped.

The `read_only_kind` branch now excludes credit notes in every state. A credit note's
sealed banner uses `fiscalDocumentBannerSealedStampOrReopen`, because it can be reopened.

**Rationale**: This matches invoices and adds no strings that carry no information.

## R8. What becomes editable

`FiscalDocument` gains `isCreditNote => summary.typeCode == 100`, and these getters change:

| Getter | Before | After |
|---|---|---|
| `isEditableDraft` | invoice ∧ draft | (invoice ∨ (credit note ∧ related invoice)) ∧ draft |
| `canReopen` | invoice ∧ sealed | (invoice ∨ (credit note ∧ related invoice)) ∧ sealed |
| `canIssueCreditNote` (new) | — | invoice ∧ issued |
| `creditedInvoice` (new) | — | the first relation of type `creditNoteOf`, on a credit note |

The detail screen narrows several things for credit notes:
- `canAddOrder` is false.
- The relations section gets no `onAdd` and no `onRemove`.
- The header dialog runs in credit-note mode (R9).

**A credit note with no relation** (legacy: 11 on mbe_dev) is not editable or reopenable: the credit-note half of both gates also needs `creditedInvoice != null`. Without that, "Agregar de la factura" has no invoice to load, and the server's confirm (`scalar_one` on the relation) fails. Spec FR-015 was narrowed to match (2026-11-18, analysis F1).

`canIssueCreditNote` also needs Create on 23. The server refuses an invoice with an open
cancellation too, but that state is `cancellationPending`, not `issued`, so the getter
already excludes it.

**Server note**: `remove_relation` does not check the document type. A client that deleted a
credit note's 01 relation would break its confirm, because the server's `scalar_one` would
find no row. The UI never sends that request. This is worth an mbe-api issue for hardening,
but it does not block this spec.

## R9. Header dialog, credit-note mode

`InvoiceHeaderDialog` branches on `document.isCreditNote`:

| Field | Invoice (066) | Credit note |
|---|---|---|
| Receptor | shown | hidden |
| Serie | shown | hidden |
| Uso CFDI | shown | shown |
| Método (PUE/PPD) | segmented | hidden; header facts show PUE read-only |
| Forma de pago | dropdown | dropdown without 99 (R5) |
| Fecha de emisión | shown | shown |
| Sucursal | with 103 | hidden |
| Referencia, Notas | shown | shown |

This keeps the patch to `usage`, `paymentForm`, `issued`, `reference` and `comment`, which
is the server's `_HEADER_FIELDS[CREDIT_NOTE]`. `field_not_for_type` is still mapped.

**Alternative**: A separate dialog. Rejected: it would duplicate the date rule, the usage
picker and the save/refusal plumbing.

## R10. Quantity checks

**Copy dialog**: the client checks 0 < q ≤ the invoice line's quantity, which is exactly
the server's `add_invoice_line` rule.

**Line edit**: the server checks the new quantity against the largest quantity of that
product on the invoice (`_check_credited_quantity`), not against the source line.
- The client does not repeat that check.
- `InvoiceLineDialog` stays open on `credit_quantity_exceeds_line` with the `max`, as it
  does today for `quantity_exceeds_invoiceable`.

## R10b. Copy dialog alignment (constitution §VI)

The copy dialog's row puts a checkbox, text cells and a quantity field in one band. That counts as a non-trivial control band, so its widget test asserts symmetric vertical padding and a shared baseline with real geometry (analysis G1).

## R11. Error codes

Four codes go from `OUT` to `IN` in `specs/058-localized-api-errors/contracts/code-scope.tsv`,
so `catalog_coverage_test` goes from 177 to 181:

| Code | Params | es text |
|---|---|---|
| `fiscal_document.invoice_not_creditable` | invoice_id | "Esta factura ya no admite notas de crédito: debe estar timbrada, vigente y sin cancelación en proceso." |
| `fiscal_document.credit_exceeds_invoice` | invoice_id, remaining | "La nota de crédito excede lo que queda por acreditar de la factura: {remaining}." |
| `fiscal_document.credit_quantity_exceeds_line` | max | "La cantidad excede la de la factura: máximo {max}." |
| `fiscal_document.payment_form_required` | type | "Elige la forma de pago real; 99 (Por definir) no se admite en este documento." |

Notes on the codes:
- `credit_exceeds_invoice` sends `invoice_id`, not the folio. FR-012 wants the series and
  folio, so when the refused document is a credit note the detail screen branches on that
  code and renders `fiscalDocumentCreditExceedsInvoice(folio, remaining)`, taking the folio
  from `creditedInvoice`. This is the same kind of code branch as 072's issue-date hint,
  which the constitution allows. The localizer's text is the fallback when there is no
  relation.
- Already `IN` and reused: `issuer_has_no_series` (already generic), `cancellation_open`
  (create on a pending invoice, which is a race), `not_draft`, `no_lines`,
  `line_missing_sat_key`, `recipient_incomplete`, `issue_date_out_of_range`,
  `no_valid_certificate`, `field_not_for_type` and `type_not_supported`. The TSV rows for
  these gain the new routes in their route column.
- **Rewording**: `apiErrorFiscalDocumentNotDraft` ("Esta factura ya no es borrador…") and
  `apiErrorFiscalDocumentNoLines` ("La factura no tiene partidas.") are reworded to
  "este documento" / "El documento". Their English texts change the same way.
- **UI texts that say "factura"** and are also shown on credit notes are reworded to neutral wording too: `fiscalDocumentLinesEmpty`, `fiscalDocumentRemoveLineBody`, `fiscalDocumentConfirmTitle`/`Body`, `fiscalDocumentReopenTitle`/`Body`, and `fiscalDocumentConfirmed`/`Reopened`, which gain a `{kind}` placeholder (analysis U1).

## R12. Repository and actions additions

| Layer | Addition |
|---|---|
| `FiscalDocumentRepository` | `createCreditNote(int invoiceId) → FiscalDocument`; `copyInvoiceLine(int id, int invoiceLineId, {Decimal? quantity}) → FiscalDocument` |
| `FiscalDocumentActions` | `createCreditNote(int invoiceId) → ({AppError? error, int? id})`; `copyInvoiceLines(int id, List<({int lineId, Decimal quantity})>) → ({int added, AppError? error, int? failedLineId})` |

Both repository methods map the generated `createCreditNote…` and `copyInvoiceLine…`
operations (`CreditNoteCreate`, `InvoiceLineCopy`). The client needs no regeneration.

## R13. Tests and live verification

- **Unit tests**:
  - the repository impl, for the two new mappings;
  - the actions, covering the sequential copy: all succeed; the 2nd fails and stops; the
    detail is invalidated once;
  - entity getters (R8).
- **Widget tests**:
  - the detail: the create action's presence matrix; the credit-note draft's controls;
    no Pedido chip; the relation link; the form-99 banner; the exceeds-invoice refusal
    with the folio;
  - the new `copy_invoice_lines_dialog_test`;
  - `invoice_header_dialog_test` in credit-note mode, including a stored 99 that must not
    assert;
  - `invoice_action_dialogs_test`, for the create confirmation;
  - `invoice_line_dialog_test`, for the new code.
- **Catalog**: `catalog_coverage_test` goes to 181, plus `problem_fixtures` entries.
- **Live**: `test/integration/fiscal_documents_live_test.dart` gains a credit-note group,
  behind `MBE_WRITE=true` and `PAC_PROVIDER=simulated`, on dev only, and the user is asked
  before it runs. The group:
  1. finds an issued, live invoice;
  2. creates a credit note;
  3. copies one line at quantity 1;
  4. sets a form when the stored one is 99;
  5. confirms, stamps, and checks issued;
  6. cancels it with reason 02, so the invoice stays cancellable.

  It skips, with a reason, when the issuer has no credit-note series. It consumes one
  credit-note folio per run.
