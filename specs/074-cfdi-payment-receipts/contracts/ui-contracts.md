# UI Contracts: CFDI Payment Receipts (REP)

These contracts continue the numbering of spec 066 (C1–C14), spec 072 (C15–C24) and spec
073 (C25–C33). Each key is the widget `Key` that tests find.

## C34. "Emitir complemento de pago" on a customer payment (FR-001, R1)

- **Key**: `payment_issue_receipt_button`, an `OutlinedButton.icon` (`Icons.receipt_long`)
  in the summary `Wrap`, after `payment_apply_button` when that one shows.
- **Present when**: `can(23, create)`. Payment state does not matter. Absent otherwise.
- **On tap**: `showNewFiscalDocumentDialog(context, NewFiscalDocumentMode.receiptFromPayment(payment))`
  (C35). On success it returns the new id, and the screen calls
  `context.push('$fiscalDocumentsPath/$id')`.

## C35. Shared create dialog (FR-001, FR-002, FR-004, R9, R13)

`showNewInvoiceDialog` becomes `showNewFiscalDocumentDialog(context, mode)`; the old name
stays as a one-line wrapper for `NewFiscalDocumentMode.invoice` so existing callers are
untouched.

| Mode | Title | Customer | Extra |
|---|---|---|---|
| `invoice` | Nueva factura | picker (unchanged) | – |
| `receipt` | Nuevo complemento de pago | picker | hint `new_receipt_hint` |
| `receiptFromPayment(p)` | Emitir complemento de pago | fixed, read-only (`new_receipt_customer_fixed`) | summary `new_receipt_payment_summary`: "Pago #{id} · {customer} · {amount} · {date}" and hint |

- Shared keys: `new_invoice_dialog`, `new_invoice_customer`, `new_invoice_recipient`,
  `new_invoice_no_taxpayers`, `new_invoice_submit`. With a single RFC it is preselected.
- **Refusal**: `FormErrorBanner`, `new_invoice_refusal`, with the localized text.
- **Already receipted** (R9): the banner adds a `TextButton`
  `new_receipt_open_existing` ("Abrir complemento"). Tapping it closes the dialog and pushes
  the receipt from `params.fiscal_document_id`.
- Both buttons disabled while the request runs (FR-018).

## C36. "Nuevo complemento de pago" on the Facturas list (FR-002, R2)

- **Key**: `fiscal_documents_new_receipt`, an `OutlinedButton`, before the existing "Nueva
  factura". Both need `can(23, create)`.
- **On tap**: C35 in `receipt` mode, then push the new id.

## C37. Receipt detail differences (FR-005, FR-009, FR-011, FR-014, FR-015, R3)

Compared with the invoice detail (C5, C18):

| Region | Receipt |
|---|---|
| Title | `fiscalDocumentTitleKind` ("Complemento de pago #id" / "Complemento de pago CP413"), existing |
| Banner | `receipt_no_proposal` (C38) or `credit_note_form` when `needsPaymentForm`; `sealed` uses the reopen variant; **never** `read_only_kind` |
| Header facts | "Editar" when `isEditableDraft` and Update on 23. Uso and Moneda read-only. No terms, no series picker |
| Payment section | `fiscal_document_receipt_payment`, a `FactStripRow`: Fecha, Monto, Forma, No. operación, Banco ordenante, and **Pago de origen** (`fiscal_document_receipt_source_payment`) when `customerPaymentId != null`: a link to `$paymentsPath/{id}` with Read on 8, plain text "Pago #id" otherwise |
| Lines | **not rendered** |
| Relations | **not rendered** |
| Paid invoices | `_PaidInvoicesSection`, `fiscal_document_paid_invoices`: `DataTableView`, rows `fiscal_document_paid_invoice_<relationId>`; columns Folio (link `fiscal_document_paid_invoice_link_<relationId>`), UUID, Parcialidad, Saldo anterior, Importe pagado, Saldo insoluto; row actions `…_edit_<relationId>`, `…_remove_<relationId>` when editable; empty `fiscal_document_paid_invoices_empty` ("Sin facturas."); toolbar `fiscal_document_add_paid_invoice` ("Agregar factura") when editable. Compact: two-line cards without the UUID |
| Totals | `ReceiptPaymentSummary` (C39) instead of `InvoiceTotals` |
| Action row | `fiscal_document_confirm` (draft), `fiscal_document_reopen` + `fiscal_document_stamp` (sealed); 072's rows otherwise |

## C38. Banner `receipt_no_proposal` (FR-003, R6)

- **Key**: `fiscal_document_banner_receipt_no_proposal`, primary colours, `Icons.info_outline`.
- **es**: "No se encontraron facturas PPD timbradas de los pedidos de este pago para este
  receptor. Agrégalas con «Agregar factura»."
- **When**: `showsNoProposalBanner` and Update on 23 (FR-003 applies to users who can edit the draft).

## C39. ReceiptPaymentSummary (FR-010)

- **Key**: `fiscal_document_receipt_summary`, laid out like `InvoiceTotals` (end-aligned).
- Three values: `…_payment_amount`, `…_assigned`, `…_unassigned`. Null amounts show
  `emptyValuePlaceholder`.
- On a draft, when `unassignedAmount` is not zero (or `paymentAmount` is null), "Por asignar"
  uses `colorScheme.error`. Sealed and later: plain.

## C40. Header dialog, receipt mode (FR-005, FR-006, R7, R10)

Inside `invoice_header_dialog`:
- **Shown**: `invoice_header_payment_date` (date picker, no time), `invoice_header_payment_amount`
  (> 0), `invoice_header_form` (no 99, no government funding; null initial value when the
  stored form is 99, Guardar disabled until chosen), `invoice_header_payment_reference`
  (max 50, counter), `invoice_header_ordering_bank` (helper "Solo si el banco ordenante es
  extranjero"), `invoice_header_issued`, `invoice_header_comment`.
- **Hidden**: recipient, series, terms, PPD toggle, facility, usage, reference.
- **Patch**: only the changed receipt fields.
- **Refusals** stay inline: `amounts_exceed_payment`, `payment_date_out_of_range`,
  `payment_form_required`, `field_not_for_type`, `issue_date_out_of_range`.

## C41. Add paid invoice dialog (FR-007, R5, R14)

- **Entry point**: `showAddPaidInvoiceDialog(context, receipt)`; returns true when added.
- **Key**: `add_paid_invoice_dialog`, a `ResponsiveDialog`, full-screen on compact.
- Hosts `FiscalDocumentCandidatePicker` with `keyPrefix: 'add_paid_invoice'`, the receipt's
  issuer, status issued, `typeCode: 0`, `initialSearch`/`recipientRfc` = the receipt's
  recipient, `excludeIds` = the invoices already on it. Empty text: "No hay facturas
  timbradas de este receptor."
- Optional amount `add_paid_invoice_amount` (blank = the server's default: the balance, up to
  what is left of the payment), helper text says so.
- Submit `add_paid_invoice_submit` ("Agregar"), disabled until an invoice is picked, while
  a request runs, or when the amount is not > 0.
- Refusal `add_paid_invoice_refusal` (`FormErrorBanner`): `invoice_not_payable`,
  `invoice_already_on_receipt`, `amount_exceeds_balance` (with balance),
  `amounts_exceed_payment`, `payment_date_out_of_range`. An invoice with an open cancellation
  is refused as `invoice_not_payable`. The dialog stays open.

## C42. Edit paid invoice amount dialog (FR-008)

- **Key**: `edit_paid_invoice_dialog`; field `edit_paid_invoice_amount`, prefilled; shows the
  previous balance; client check 0 < amount ≤ previous balance ("Máximo {balance} (el saldo
  anterior)"); `edit_paid_invoice_submit`. Server refusals inline:
  `amount_exceeds_balance`, `amounts_exceed_payment`.
- **Remove**: `showRemovePaidInvoiceDialog` — a confirm dialog naming the folio, then
  `removePaidInvoice`.

## C43. Refusals on the receipt detail (FR-016)

- Confirm refusals render in the existing `FiscalDocumentRefusal` slot through
  `localizeProblem`: `receipt_pays_no_invoice`, `receipt_needs_payment_data`,
  `payment_form_required`, `payment_date_out_of_range`, `invoice_not_payable`,
  `amount_exceeds_balance`, `amounts_not_equal_payment`, and 066/072's codes.
- No screen-side branching is needed: none of these needs a folio the params lack.

## C44. Rights matrix additions (extends C9, C33)

| Action | Needs |
|---|---|
| Emitir complemento de pago (payment), Nuevo complemento de pago (list) | 23 create |
| Editar header, Agregar factura, edit/remove amount, Confirmar, Reabrir | 23 update |
| Pago de origen as a link | 8 read (CustomerPayments); text otherwise |
| Paid invoice link | 23 read (implied by the screen) |
