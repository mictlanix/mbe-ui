# Facturas: create and edit CFDI credit notes

## Summary

Spec 066 built the invoice editor, and spec 072 stamps and cancels any fiscal document. mbe-api spec 028 added credit notes (type 100). This PR lets billing **create a credit note from an issued invoice, fill it, seal it and stamp it**, all in the existing detail screen.

- **Emitir nota de crédito.** An issued invoice offers it as the last button of the action row, after a confirmation. It creates a draft that takes the invoice's customer, receiver, payment form and CFDI use, with PUE and a type-01 relation to the invoice, and opens it.
- **Agregar de la factura.** On a credit-note draft this replaces "Agregar pedido". A dialog lists the invoice's lines: the clerk checks the ones they credit and sets each quantity, which can't pass the invoiced one.
  - The server takes one line per request, so the lines go in the invoice's order and the run stops at the first refusal. Lines already added stay added and show "Agregada"; the refusal names the failed line.
  - "Agregar producto" (with StandaloneFiscalDocuments (56) create), line edit and line remove work as on an invoice.
- **Encabezado.** The header dialog shows only CFDI use, payment form, issue date, reference and notes, with PUE fixed. It never offers form 99 and opens with no form chosen when the draft is on 99, so the clerk has to pick the real one. A banner on the draft says so.
- **Confirmar, Reabrir, Timbrar.** The same actions as an invoice. When a confirm exceeds the invoice, the refusal names the invoice and what is left: "La nota de crédito excede lo que queda de la factura GR12: $1,500.00."
- **Relation link.** Every relation row on every document type links to the related document, so a credit note opens its invoice and Back returns.

Spec: `specs/073-cfdi-credit-notes/` (spec, wireframes, plan, research R1–R13, data model, contracts C25–C33, tasks).

## Roadmap

Closes mictlanix/mbe-roadmap#56

## Worth knowing

- **This also changes spec 066's invoice screen.** The relation link applies to the 04 and 07 relations of an invoice too, and the confirm, reopen, remove-line and empty-lines texts are now worded for any document ("documento"). "Sellado" and "reabierto" messages carry the document type: "Documento sellado: Factura GR12."
- **A credit note with no related invoice stays read-only,** in every state. That is 11 legacy ones on `mbe_dev`. Its lines come from the invoice and the server's confirm needs the relation, so there is nothing to edit it against. It keeps spec 066's read-only banner.
- **No remaining-to-credit figure is shown on the draft.** `FiscalDocumentResponse` has none, and computing it client-side would need every credit note of the invoice. The over-limit refusal on confirm carries it.
- **The quantity field in the copy dialog is a plain `TextField`, not `CompactField`.** The contract said `CompactField`, but that widget is for values that aren't typed into.
- **Quantity rules differ by action, as on the server.** Copying checks the quantity against that invoice line, in the dialog. Editing a line is checked by the server against the largest quantity of that product on the invoice, so the line dialog stays open on `credit_quantity_exceeds_line` and shows the maximum.
- **No client regeneration, new route or navigation change.**

## Rights

| Right | What it gives |
|---|---|
| FiscalDocuments (23) create | Emitir nota de crédito |
| FiscalDocuments (23) update | Agregar de la factura, edit and remove line, Editar header, Confirmar, Reabrir |
| StandaloneFiscalDocuments (56) create | Agregar producto |
| FiscalDocuments (23) read | The relation link, since the target needs it |

Every action is absent, never disabled, without its right or outside its state.

## Also in this PR

- **Errors (§III):** four codes localized in both languages and flipped to `IN` in `code-scope.tsv` (coverage 177 → 181): `invoice_not_creditable`, `credit_exceeds_invoice`, `credit_quantity_exceeds_line` and `payment_form_required`. The folio in the over-limit text comes from the credited relation, chosen by the error's `code`, never by matching the server's prose. Two existing texts (`not_draft`, `no_lines`) are reworded for any document.
- **Tests:** unit (entity getters, repository mappings including a wire relation of type 01, sequential copy with a stop at the first refusal), widget (create dialog and its presence matrix, the copy dialog, header in credit-note mode including a stored 99, confirm/reopen/stamp on a credit note, the relation link) and a live test.
- **§VI:** the copy dialog's row (checkbox, text cells, quantity field) is a control band, and its test asserts equal padding above and below and a shared baseline with real geometry.

## Follow-ups (not filed)

- **mbe-api: the invoice's remaining creditable amount** isn't exposed before confirm. If the manual checks show clerks need it on the draft, ask for a field on the invoice or the credit note.
- **mbe-api: `remove_relation` has no type guard.** Deleting a credit note's 01 relation would break its confirm. The UI never sends that request.
- **mbe-api: a copied line doesn't record its source invoice line,** so the dialog offers every invoice line again after a copy, and there is no "Pedido"-style marker on credit-note lines.

## Verification

- `flutter analyze`: clean. Formatting checked on the changed files only.
- `flutter test`: 6166 pass. The failures are the six goldens in `test/golden/core_widgets_golden_test.dart` (known, mbe-ui#209) and `pos_screens_screenshot_test.dart`, a pixel diff on the sales list that fails the same way on the branch without this work.
- **Live test** (`test/integration/fiscal_documents_live_test.dart`, group "Credit note against the simulated PAC"): 8/8 passed against dev on 2026-11-18. It created credit note #63928 against invoice #63927, refused a copy above the invoiced quantity with `credit_quantity_exceeds_line`, copied one line, set the form, confirmed (DRC3), stamped and cancelled it.
- **Manual checks** (`quickstart.md`) are tracked in #281.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
