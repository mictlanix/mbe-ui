# Facturas: invoice list, view, PDF/XML and editor

## Summary

mbe-ui had no fiscal-document screens at all. This PR adds the Facturación area: find any fiscal document, read it, get its PDF and XML, and start, edit, seal and reopen an invoice.

- **List** ("Facturas", new Facturación nav group). Newest first, 20 per page. Search by series+folio, UUID, or recipient RFC or name. Filters for status (draft, sealed, issued, cancelled), document type, issuer (with Taxpayers read) and issue-date range. The date facet says drafts have no issue date and drop out when you filter by date.
- **Detail** (full screen, own address). Header facts, lines (table, or cards on compact), related documents, totals and a status banner. Issued and cancelled documents offer **Ver PDF** (shared preview, print, download) and **Descargar XML** (saved through a new cross-platform file saver).
- **Nueva factura.** Pick a customer and one of its RFCs; the server picks store, issuer, series and defaults.
- **Edit a draft.** Add a customer's completed sales order (re-adding duplicates nothing), add a manual product, edit or remove a line, edit the header (recipient, series, CFDI use, PUE/PPD, payment form, issue date, facility, reference, notes), and add or remove related documents (04, 07).
- **Confirmar** seals a valid draft; **Reabrir** returns a sealed invoice to draft and keeps its folio. Each confirm refusal (no lines, missing SAT key, incomplete recipient, date out of range, no valid certificate, quantity above what remains) has its own message.

Spec: `specs/066-invoice-list-editor/` (spec, plan, research R1–R14, data model, contracts C1–C14, tasks).

## Roadmap

Closes mictlanix/mbe-roadmap#48
Closes mictlanix/mbe-roadmap#49

Credit notes, payment receipts, cancellation, stamping and email are separate items (#56, #52, #46) and are not here.

## Worth knowing

- **Stamping is pending (roadmap#46).** An invoice made here stops at **sealed**. The PDF and XML only exist for a stamped document, so today they work for **documents the legacy system issued**. A sealed invoice shows a banner saying so, and offers neither.
- **A draft's total is an estimate.** The API's `total` comes from the stored XML, so it is null on a draft. The client mirrors mbe-api's `cfdi_invoice.line_amounts` (`invoice_amounts.dart`, round half away from zero) and labels it "Total (estimado)". Once sealed, the server's total is shown. The live write run compared them after a confirm and they matched (see Tests).
- **Spec 065 had the document-type names wrong.** The codes were right and the names weren't: 1, 2, 3 are fee receipt, rent receipt and debit note, and 101 and 200 were swapped. `FiscalDocumentKind` is renamed. `TaxpayerBatchRepositoryImpl._wireType` maps by member name, so its 101 and 200 arms are swapped too, with a test keyed by kind, so a payment-receipt series is written as 200. **Visible effect:** the Series section of a taxpayer issuer now reads 101 as "Aplicación de anticipos" and 200 as "Recibo de pago" (it read them the other way round).
- **The order picker lists fully invoiced orders too**, since the API exposes no remaining quantity. Adding one is refused with `no_invoiceable_lines`, shown inline so another order can be picked.
- **A document is read as a document** (§VI): no row Edit icon, a row tap opens it, and a draft is edited in place. Every edit control is absent, never disabled, without its right.
- **An issue date can't be emptied again** once set from the header dialog: the server treats an absent value as unchanged.
- **A legacy draft with no customer** keeps its header editable except the recipient, and can't take sales orders; the screen says so.

## Rights

| Right | What it gives |
|---|---|
| FiscalDocuments (23) read | The nav entry, the route, the detail, Ver PDF and Descargar XML |
| FiscalDocuments (23) create | Nueva factura |
| FiscalDocuments (23) update | Editar encabezado, line edit and remove, relations, Confirmar, Reabrir |
| SalesOrders (7) read | Agregar pedido (the picker lists orders) |
| StandaloneFiscalDocuments (56) create | Agregar producto |
| IssuedLocationId (103) update, or administrator | The facility field of the header |
| Taxpayers (24) read | The issuer facet and the series dropdown |
| Customers read | The recipient dropdown in the header |

## Also in this PR

- **Errors (§III).** 29 `fiscal_document.*` codes and 2 validation types are localized and flipped OUT→IN in `code-scope.tsv` (`catalog_coverage` 114→143), plus the nouns "partida de factura" and "documento relacionado".
- **`core/documents`** gains `DocumentKind.fiscalDocument` and its source arm.
- **`core/files/FileSaver`** (new). `file_picker` 8.3.7 saves bytes on web, Android and iOS, but throws on macOS when given bytes, so desktop asks for a path and writes with `dart:io`.
- **`ResponsiveDialog`** gains an optional `hasUnsavedChanges`: back, Escape, the barrier and the compact close control then ask "discard changes?". Off by default; other dialogs are unchanged. Its compact close control now uses `maybePop`.
- **`SatCatalogRepository.listCfdiUsages`** for the CFDI use picker.
- **`rational`** becomes a direct dependency (it was already transitive) for exact rounding.
- The Facturación group is last in the nav tree, so the existing "Logística follows Ventas" test is unchanged.

## Tests

- `flutter analyze`: no issues.
- `flutter test test/unit test/widget`: 5,034 passed, 1 skipped (the live test below, which needs credentials).
- New tests cover: the amounts mirror (worked out by hand from the formula, including a half-cent case), the repository's wire traps (int type, `sealed_`, decimal strings, percent to fraction, relation type, PPD sending no form, wall-clock issue date, XML bytes and filename), the filter's URL round trip, the list and write controllers (including the unknown-result case), the file saver on every platform branch, the XML name, the kind rename (and the swapped 101/200 arms), all error codes and nouns, the nav entry and the three routes, and the widgets: list, detail (per state and per right), Nueva factura, Agregar pedido, Agregar producto, the line and header dialogs (including discard prompts), confirm and reopen with each refusal, and relations.
- **Live (`test/integration/fiscal_documents_live_test.dart`, local mbe-api), read-only: 8 passed.** On legacy invoice GR4776: the list opens newest first; search by series+folio, UUID and recipient RFC finds it; status, type, issuer and date filters narrow; the detail's total equals the list's; the PDF starts with `%PDF-` (server name `CAG190523ES5-GR004776.pdf`); the XML is byte-identical to `GET /xml` and named `CAG190523ES5-GR004776.xml`, matching the client rule; a draft's PDF is refused with `fiscal_document.not_issued`.
- **Live write run (`MBE_WRITE=true`): 11 passed, 1 skipped.** It creates a draft for customer 1 (RFC XAXX010101000). The issue date round-trips with no time-zone shift. Adding order 344218 twice duplicates nothing. A quantity above what remains is refused, and a 10 % discount plus Exento moves the estimate from 32 to 28.8. It adds a manual product, PPD forces form 99, and an empty draft's confirm is refused with `no_lines`. Confirming seals folio **A5232**, and the **server's total (28.8) equals the client estimate**. Reopening keeps A5232. Skipped: relations, because no cancelled invoice of that issuer and RFC exists.
  - The manual product (Truper nails) has no SAT key, so the server refused the first confirm with `line_missing_sat_key` (line 2). The test drops that line and retries once, and says so. This is tenant data, not the flow under test.
  - Caveat: the sealed invoice had one line at Exento, so the estimate-vs-server comparison exercised discount rounding but not the 16 % path. The unit tests cover 16 %, tax-included and the half-cent case.
  - Left on the dev tenant: drafts #63903 and #63905 (A5232 reopened), empty drafts #63904 and #63906, and folio A5232 consumed.

## Manual checks (quickstart.md)

**Not run yet**:

- Step 1: `qanoaccess` has no entry and the URL is refused.
- Step 3: the kind names in the list and on the issuer's Series section.
- Step 5: a cancelled document's PDF mark; a pre-4.0 document, if the tenant has one.
- Step 12: a user with 23 read but not update.
- Step 13: the compact tier on a phone.
- Step 14: the largest text size.
- Plus timing SC-001 (find a document to PDF in under 30 s) and SC-002 (an invoice from an order to sealed in under 2 minutes).

🤖 Generated with [Claude Code](https://claude.com/claude-code)
