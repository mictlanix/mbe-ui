# Facturas: create and edit CFDI payment receipts (complemento de pago)

## Summary

Spec 066 built the invoice editor, spec 072 stamps and cancels any fiscal document, and spec 073 made credit notes editable. mbe-api spec 028 added payment receipts (type 200, Pagos 2.0). This PR lets billing **issue a payment receipt from a customer payment or by hand, fill it, seal it and stamp it**, in the existing detail screen.

- **Emitir complemento de pago** on a customer payment's detail, next to "Aplicar". The clerk picks one of the customer's RFCs and the app creates a draft with the payment's date, amount, form and reference, plus the PPD invoices the server proposes, and opens it. A payment that already has a live receipt is refused with an **"Abrir complemento"** button, since the server sends only the receipt's id.
- **Nuevo complemento de pago** on the Facturas list, for payments that were never recorded in the new MBE. It creates an empty draft for a customer and RFC. "Nueva factura" keeps the primary slot.
- **The receipt screen** shows the payment (date, amount, form, operation number, ordering bank, source payment), the paid invoices (folio, UUID, installment, previous balance, amount paid, remaining balance) and a summary of the payment amount, what is assigned and what is left. A receipt has no product lines, and its related documents would repeat the paid invoices, so those sections are not drawn. "Por asignar" turns red while a draft is not matched.
- **Agregar factura** opens the spec 072 picker (issued invoices of the receipt's issuer and recipient, without the ones already paid) with an optional amount. Blank takes the server's default. **Editar importe** and **Quitar** work per row.
- **Encabezado** has the payment date, amount, form (never 99), operation number (max 50), ordering bank (max 25) and the issue date and notes. Usage, currency and terms are fixed.
- **Confirmar, Reabrir, Timbrar** are the same actions as an invoice, with the receipt's own refusals worded in Spanish and English.

Spec: `specs/074-cfdi-payment-receipts/` (spec, wireframes, plan, research R1–R15, data model, contracts C34–C44, tasks).

## Roadmap

Closes mictlanix/mbe-roadmap#54

## Worth knowing

- **The Spanish name of the type changes** from "Recibo de pago" to "Complemento de pago" everywhere it shows, including spec 065's series list. English stays "Payment receipt".
- **The create dialog is now shared.** `showNewInvoiceDialog` is a wrapper over `showNewFiscalDocumentDialog(mode)` (invoice, receipt by hand, receipt from a payment). Its keys and the invoice mode are unchanged.
- **`FiscalDocumentCandidatePicker` gained two optional parameters** (`typeCode`, `excludeIds`). Its two existing callers pass neither.
- **The picker cannot tell PPD from PUE.** The list API has no filter for terms or recipient, so a PUE invoice is picked and then refused by the server with "invoice_not_payable". See the follow-ups.
- **Header limits come from the server's columns:** operation number 50, ordering bank 25 (stored in `reference`). The spec only said 50.
- **No client regeneration, new route or navigation change.**

## Rights

| Right | What it gives |
|---|---|
| FiscalDocuments (23) create | Emitir complemento de pago, Nuevo complemento de pago |
| FiscalDocuments (23) update | Editar, Agregar factura, edit and remove an amount, Confirmar, Reabrir, Timbrar |
| CustomerPayments (8) read | "Pago de origen" as a link (plain text without it) |
| FiscalDocuments (23) read | The paid-invoice links |

Every action is absent, never disabled, without its right or outside its state.

## Also in this PR

- **Errors (§III):** ten codes localized in both languages and flipped to `IN` in `code-scope.tsv` (coverage 181 → 191): `invoice_not_payable`, `invoice_already_on_receipt`, `amount_exceeds_balance`, `amounts_exceed_payment`, `amounts_not_equal_payment`, `payment_date_out_of_range`, `payment_already_receipted`, `payment_other_customer`, `receipt_needs_payment_data` and `receipt_pays_no_invoice`. The "already has a receipt" path reads the receipt's id from the error's params, never from its prose.
- **Tests:** unit (entity getters, repository mappings and request bodies for the four new calls and the receipt header fields, actions), widget (the create dialog in its three modes, the payment button matrix, the receipt screen in every state, the paid-invoice dialogs, the header in receipt mode, the list button and the type filter) and a live test.
- **§VI:** the paid-invoice row, its phone-width card and the add dialog's amount and buttons are control bands, with tests that measure real padding and baselines.

## Follow-ups (not filed)

- **mbe-api: filter `GET /fiscal-documents` by payment terms and recipient,** so the picker can list only PPD invoices of the recipient.
- **mbe-api: expose the receipt on the customer payment** (or its id), so the payment screen can show it and skip the refused second try.

## Verification

- `flutter analyze`: clean. Formatting checked on the changed files only.
- `flutter test`: 6285 pass, 85 skipped (live tests without credentials). The 7 failures all fail the same way on the branch without this work: the six goldens in `test/golden/core_widgets_golden_test.dart` (known, mbe-ui#209) and the sales-list pixel diff in `pos_screens_screenshot_test.dart`. `auth_flow_test.dart` scenario 2 also failed in the full run, because mbe-api had lost its database connection; it passes after an mbe-api restart.
- **Live test** (`test/integration/fiscal_documents_live_test.dart`, group "Payment receipt against the simulated PAC"): **13/13 pass** on 2026-11-18, after mictlanix/mbe-api#341 (the `usage` column was too short for `CP01`) was fixed. The run makes and stamps its own PPD invoice (A5252), then creates, fills, seals, reopens, re-seals and stamps a receipt (CPZUMP13). Along the way it checks both amount refusals and that the invoice can't be cancelled while the receipt is live. It then cancels both.
- **Manual checks** (`quickstart.md`) are not done yet.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
