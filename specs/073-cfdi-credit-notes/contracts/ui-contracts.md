# UI Contracts: CFDI Credit Notes

These contracts continue the numbering of spec 066 (C1–C14) and spec 072 (C15–C24).
Each key is the widget `Key` that tests find.

## C25. "Emitir nota de crédito" on an invoice (FR-001, FR-002)

- **Key**: `fiscal_document_issue_credit_note`.
- **Style**: `OutlinedButton`, last in the action row (C18 order: PDF, XML, Cancelar,
  **Emitir nota de crédito**).
- **Present when**: `canIssueCreditNote && can(23, create)`. Absent otherwise.
- **On tap**: `showIssueCreditNoteDialog(context, invoice)` (C26). On success it returns the
  new id, and the screen calls `context.push('$fiscalDocumentsPath/$id')`.

## C26. Create confirmation dialog

- **Key**: `issue_credit_note_dialog`, a `ResponsiveDialog`.
- **Body** (es): "Se creará un borrador de nota de crédito para la factura {folio}
  ({recipient}), relacionada con tipo 01. Tomará el cliente, el receptor, la forma de pago y
  el uso CFDI de la factura."
- **Buttons**: `issue_credit_note_cancel` (shared `cancelButton`) and
  `issue_credit_note_create` ("Crear", filled). Both are disabled while the request runs.
- **On a refusal**: the dialog stays open and shows a `FormErrorBanner`, keyed
  `issue_credit_note_refusal`, with the localized text (`issuer_has_no_series`,
  `invoice_not_creditable`, `cancellation_open`, or the generic fallback).

## C27. Credit-note detail differences (FR-003, FR-007, FR-009, FR-013, FR-015)

Compared with the invoice detail (C5, C18):

| Region | Credit note |
|---|---|
| Title | `fiscalDocumentTitleKind` ("Nota de crédito #id" / "Nota de crédito NC118"): existing |
| Banner | `credit_note_form` when `needsPaymentForm` and the user has Update on 23 (C30); `sealed` uses the reopen variant; `read_only_kind` only for a credit note with no related invoice |
| Header facts | "Editar" when `isEditableDraft` and the user has Update on 23. Terms show PUE |
| Lines toolbar | `fiscal_document_copy_invoice_lines` ("Agregar de la factura", outlined, `Icons.add`) in place of `fiscal_document_add_order`; `fiscal_document_add_product` with 56 create |
| Line rows | edit/remove as for invoices; **no** `fiscal_document_line_order_*` chip |
| Relations | always shown; no `fiscal_document_add_relation`, no `fiscal_document_relation_remove_*` |
| Action row | `fiscal_document_confirm` (draft), `fiscal_document_reopen` + `fiscal_document_stamp` (sealed); 072's rows otherwise; never C25 |

## C28. Relation link (FR-003, all types)

- **Key**: `fiscal_document_relation_link_<relationId>`. A `TextButton` (or the theme's link
  style) whose label is the series+serial, or `#documentId`.
- **On tap**: `context.push('$fiscalDocumentsPath/${r.documentId}')`.
- **Present**: on every relation row, on every document type, for anyone who can see the
  detail.

## C29. Copy invoice lines dialog (FR-004, R1, R10)

- **Entry point**: `showCopyInvoiceLinesDialog(context, creditNote)`. It returns the number of lines
  added, 0 when none (analysis F3).
- **Key**: `copy_invoice_lines_dialog`, a `ResponsiveDialog`, full-screen on compact.
- **Loading the invoice**: through `fiscalDocumentDetailProvider(creditedInvoice.documentId)`.
  - `ListStateViews` shows loading, and an error with retry.
  - An invoice without lines shows `copy_invoice_lines_empty`.
- **Rows**: `copy_invoice_line_<lineId>`. Each row has:
  - a checkbox, `copy_invoice_line_check_<lineId>`;
  - the code, description, invoice quantity, price, discount and tax;
  - a `TextField` for the quantity (not `CompactField`, which is for values that are not typed
    into), `copy_invoice_line_qty_<lineId>`, enabled when the row is checked and defaulting to
    the invoice quantity. A row's validation text is `copy_invoice_line_error_<lineId>`.
  - On compact, each row is a two-line card.
- **Validation**: 0 < q ≤ the invoice quantity. Otherwise an error text appears under the
  field: "Máximo {max} (la cantidad facturada)", or "Debe ser mayor que 0".
- **Submit**: `copy_invoice_lines_submit`, labelled "Agregar ({n})". It is disabled when
  nothing is checked, any checked row is invalid, or a request is running.
- **Sending**: `FiscalDocumentActions.copyInvoiceLines` sends the lines in the invoice's
  line order.
  - All succeed: the dialog closes with the count, and the screen shows the SnackBar "{n}
    partidas agregadas" when it is above 0. Closing after a partial run returns the count
    added so far.
  - A refusal: the dialog stays open. The added rows become unchecked and disabled with a
    "Agregada" label. A `FormErrorBanner`, `copy_invoice_lines_refusal`, says "Partida
    {code}: {localized refusal}".

## C30. Banner `credit_note_form` (FR-010)

- **Key**: `fiscal_document_banner_credit_note_form`, with tertiary colours and
  `Icons.info_outline`.
- **es**: "La forma de pago es 99 (Por definir). Elige la forma de pago real en el encabezado
  antes de confirmar."
- **When**: `needsPaymentForm` and Update on 23. It takes the draft slot, which is empty for
  invoices.

## C31. Header dialog, credit-note mode (FR-009, R9)

Inside `invoice_header_dialog`:
- **Hidden**: `invoice_header_recipient`, `invoice_header_series`, `invoice_header_terms`,
  `invoice_header_form_ppd` and `invoice_header_facility`.
- **Payment form**: `invoice_header_form` never lists 99. Its initial value is null when the
  stored form is 99, and Guardar stays disabled until a form is chosen.
- **The patch**: only `usage`, `paymentForm`, `issued`, `reference` and `comment` are ever
  set.

## C32. Refusals (FR-012, FR-016)

- On a credit note, `credit_exceeds_invoice` renders `fiscalDocumentCreditExceedsInvoice`:
  "La nota de crédito excede lo que queda de la factura {folio}: {remaining}." The folio comes
  from `creditedInvoice`, and `remaining` is formatted as currency. Without a relation it
  falls back to the localizer's text.
- `InvoiceLineDialog` stays open on `credit_quantity_exceeds_line` ("La cantidad excede la de
  la factura: máximo {max}."), as it does today for `quantity_exceeds_invoiceable`.
- All other codes go through `localizeProblem` unchanged (research R11).

## C33. Rights matrix additions (extends C9)

| Action | Needs |
|---|---|
| Emitir nota de crédito | 23 create |
| Agregar de la factura, edit/remove line, Editar header, Confirmar, Reabrir | 23 update |
| Agregar producto | 56 create (plus 23 update for the draft to be editable) |
| Relation link | 23 read (implied by the screen) |
