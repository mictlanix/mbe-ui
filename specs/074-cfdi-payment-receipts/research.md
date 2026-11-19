# Research: CFDI Payment Receipts (REP)

Server behaviour was read from mbe-api at `1c81e07` (`app/services/invoice_service.py` §
"Payment receipts", `app/services/fiscal_document_service.py` `get_paid_invoices` /
`get_document`, `app/core/error_codes.py`). The generated client in `lib/generated/openapi`
already has every route and model this spec needs (`createPaymentReceipt…`,
`add/update/removePaidInvoice…`, `PaidInvoiceResponse`, `InvoiceUpdate.paymentDate/
paymentAmount/paymentReference/orderingBank`) and all ten new error codes, so **no client
regeneration**.

R1–R7 settle the wireframes' Open Questions 1–7, in order. R8 onward are design findings.

## R1. When "Emitir complemento de pago" shows on a payment (wireframe OQ1)

- **Decision**: Always, for a user with Create on 23 (FiscalDocuments). The payment's state
  (applied, verified, rejected) does not gate it.
- **Rationale**: The server doesn't gate it either. A payment applied to legacy orders, or
  not applied yet, still yields a draft, and the "none proposed" banner (C38) tells the clerk
  to add invoices by hand. Hiding it would leave those payments without a path.
- **Alternatives**: only when applied (hides the legacy case); only when verified (spec 060's
  verification is a cash-control step, not a fiscal one).

## R2. Facturas list entry (wireframe OQ2)

- **Decision**: A second `OutlinedButton` "Nuevo complemento de pago", keyed
  `fiscal_documents_new_receipt`, before the existing filled "Nueva factura".
- **Rationale**: No new widget. Credit notes don't start from the list, so a type menu would
  have only two entries.
- **Alternatives**: a menu button (`MenuAnchor`), which is more code for two choices.

## R3. Lines and relations on a receipt (wireframe OQ3)

- **Finding**: `get_document` returns `relations` from the same `fiscal_document_relation`
  table the paid invoices live in, so a receipt's `relations` **duplicates** its
  `paid_invoices`. A receipt has no product lines of its own: the SAT "Pago" concept is
  written into the XML by the seal builder.
- **Decision**: On a receipt, hide `_LinesSection` and `_RelationsSection` in every state and
  show `_PaidInvoicesSection` (C37) instead. Legacy receipts, which may carry a stored
  zero-value line, show no lines either.
- **Alternatives**: show both (shows every invoice twice); show lines read-only (a 0.00
  "Pago" line adds nothing).

## R4. Totals on a receipt (wireframe OQ4)

- **Finding**: `total` comes from the XML; a Pagos 2.0 receipt's `Total` is 0.
- **Decision**: Replace `InvoiceTotals` with `ReceiptPaymentSummary` (C39): Monto del pago,
  Asignado (sum of `amount`), Por asignar (difference). The list keeps showing 0.00 as the
  total of a receipt, as it does for legacy receipts today.

## R5. Adding an invoice before the payment amount is set (wireframe OQ5)

- **Finding**: `default_amount(balance, unassigned)` returns the full balance when
  `payment_amount` is null; `_check_amount` skips the over-payment check then.
- **Decision**: Offer "Agregar factura" whenever the draft is editable; leave the amount blank
  by default and show what the server sets. Confirm then refuses with
  `receipt_needs_payment_data` until the header has date and amount.

## R6. Banner for a payment-backed draft with nothing proposed (wireframe OQ6)

- **Decision**: One generic sentence (C38), shown when `customerPaymentId != null`, the draft
  has no paid invoices, and the user has Update on 23. The server proposes only stamped,
  live PPD invoices of the same issuer and recipient, dated on or before the payment, with
  a balance left, and doesn't say which rule dropped each one.

## R7. Ordering bank (wireframe OQ7)

- **Decision**: A plain optional text field with the hint "Solo si el banco ordenante es
  extranjero". It is sent as `orderingBank`; the server stores it in `reference`, so the
  detail reads it from `reference` on receipts.

## R8. The server refuses an over-assigned header

- **Finding**: `_check_receipt_header` runs after every header edit and raises
  `amounts_exceed_payment` when the new amount is below the sum already assigned, and
  `payment_date_out_of_range` when the date falls before an invoice's.
- **Decision**: The unassigned amount is never negative, so the wireframe's "-1,600.00"
  frame is dropped. The header dialog stays open and shows these refusals inline. The spec's
  edge case was corrected to match.

## R9. "This payment already has a receipt" carries an id, not a folio

- **Finding**: `payment_already_receipted` params are `{fiscal_document_id}`; the folio is
  only in `detail`, which the constitution (§III) forbids showing.
- **Decision**: The create dialog shows "Este pago ya tiene un complemento de pago." with a
  `TextButton` "Abrir complemento" that closes the dialog and pushes
  `$fiscalDocumentsPath/{fiscal_document_id}`. FR-004 was reworded from "name the folio" to
  "offer to open it". No extra fetch.

## R10. Payment form defaults

- **Finding**: `create_payment_receipt` sets `payment_method = CASH` (01) on every receipt,
  and from a payment copies the method only when it is 1–31. The header route refuses 99
  on a receipt (`payment_form_required`).
- **Decision**: The header dialog's form list for receipts excludes 99 and government
  funding, like credit notes (spec 073 C31). `needsPaymentForm` widens to receipts, which
  only matters for legacy drafts stored on 99.

## R11. Error codes

Ten codes go from `OUT` to `IN` in `specs/058-localized-api-errors/contracts/code-scope.tsv`,
and `catalog_coverage_test` goes from 181 to 191:

| Code | Params | es text (summary) | Shown in |
|---|---|---|---|
| `invoice_not_payable` | `invoice_id` | La factura no se puede pagar con este complemento (no es PPD, no está timbrada o vigente, o es de otro emisor o receptor). | add dialog, confirm |
| `invoice_already_on_receipt` | `invoice_id` | La factura ya está en este complemento. | add dialog |
| `amount_exceeds_balance` | `balance` | El importe excede el saldo de la factura: {balance}. | add/edit dialogs, confirm |
| `amounts_exceed_payment` | – | La suma de los importes pagados excede el monto del pago. | add/edit/header dialogs |
| `amounts_not_equal_payment` | – | La suma de los importes pagados debe ser igual al monto del pago. | confirm |
| `payment_date_out_of_range` | – | La fecha del pago debe estar entre las fechas de las facturas y hoy. | header, add, confirm |
| `payment_already_receipted` | `fiscal_document_id` | Este pago ya tiene un complemento de pago. (+ Abrir, R9) | create dialog |
| `payment_other_customer` | `customer_payment_id` | El pago es de otro cliente. | create dialog |
| `receipt_needs_payment_data` | – | Captura la fecha y el monto del pago antes de confirmar. | confirm |
| `receipt_pays_no_invoice` | – | Agrega al menos una factura pagada antes de confirmar. | confirm |

Reused, already `IN`: `payment_form_required` (its text is already type-neutral after 073),
`issuer_has_no_series`, `recipient_not_linked`, `field_not_for_type`, `not_draft`,
`issue_date_out_of_range`, `no_valid_certificate`, `series_missing`, `cancellation_open`,
`has_live_documents`, and 072's stamp/cancel codes. `type_not_supported` (409 "Not available
for this document type") stays mapped.

`issuer_has_no_series`'s text is already type-neutral ("El emisor no tiene una serie para
este tipo de documento…"), so it needs no change.

## R12. Domain and data shape

- **Decision**: `FiscalDocument` gains `paymentDate` (date), `paymentAmount` (Decimal?),
  `paymentReference`, `customerPaymentId` and `paidInvoices` (`List<PaidInvoice>`). The
  repository maps them from `FiscalDocumentResponse`. Ordering bank reads `reference`.
- `isPaymentReceipt` = type 200. `isEditableKind` widens to receipts (every receipt, legacy
  included: the routes need nothing a legacy row lacks).
- `InvoiceHeaderPatch` gains `paymentDate`, `paymentAmount`, `paymentReference` and
  `orderingBank`. The repository sends only the fields set, so a receipt never sends
  invoice fields (and vice versa), as `field_not_for_type` requires.
- Four repository methods: `createPaymentReceipt(NewPaymentReceipt)`,
  `addPaidInvoice(id, invoiceId, {amount})`, `updatePaidInvoice(id, relationId, amount)`,
  `removePaidInvoice(id, relationId)`; matching `FiscalDocumentActions` methods that refresh
  the detail from the returned document.

## R13. One create dialog, three modes

- **Decision**: `showNewInvoiceDialog` becomes the shared create dialog with a
  `NewFiscalDocumentMode`: `invoice` (unchanged), `receipt` (by hand), and
  `receiptFromPayment(customerPayment)` (customer fixed and shown read-only, payment summary
  line on top). The customer/RFC loading, `no_taxpayers` state and refusal banner are shared.
  Keys keep their `new_invoice_` prefix so 066's tests keep passing; the receipt-only parts
  use `new_receipt_` keys.
- **Alternatives**: a separate dialog (duplicates the RFC picker and its states).

## R14. Adding an invoice: the picker

- **Decision**: Reuse `FiscalDocumentCandidatePicker` (072 C22) with `issuerRfc` = the
  receipt's issuer, `status` issued, `initialSearch` and `recipientRfc` = the receipt's
  recipient, plus a new optional `typeCode` filter (0) and an `excludeIds` set (invoices
  already on the receipt). The list API has `type`, so `typeCode` is a query parameter, not
  a client filter. PPD cannot be filtered (spec assumption); `invoice_not_payable` covers it.
- `excludeIds` replaces nothing: the existing `excludeId` stays for its two callers.

## R15. Testing

- **Unit**: entity getters (`isPaymentReceipt`, widened `isEditableKind`, `unassigned`,
  `needsNoProposalBanner`); repository mapping of the receipt fields and the four new calls;
  the ten localizer arms (`catalog_coverage_test` 191).
- **Widget**: payment detail button presence by right; create dialog in its three modes
  (including the R9 "Abrir complemento" path); receipt detail states (draft from payment,
  none proposed, by hand, sealed, read-only, legacy); header dialog receipt mode; add and
  edit-amount dialogs with their refusals; compact tier of the receipt detail.
- **Live** (`test/integration/fiscal_documents_live_test.dart`, `MBE_WRITE=true`, simulated
  PAC, dev only, ask first): create a PPD invoice from an order, seal, stamp; record and apply
  a payment to that order; issue a receipt from it; check the proposal; confirm; stamp;
  cancel the receipt; then cancel the invoice. It consumes an invoice and a receipt folio.
