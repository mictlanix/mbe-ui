# Research: Invoice List, View, PDF and Editor (spec 066)

Every endpoint used already exists in the generated client (`FiscalDocumentsApi`), so no regeneration and no upstream change is needed. Server facts come from mbe-api `app/api/v1/endpoints/fiscal_documents.py`, `app/services/{fiscal_document_service,invoice_service,cfdi_invoice}.py` and `app/core/error_codes.py` as of mbe-api `239dfb7` (2026-11-14).

## R1. Feature placement and routes

- **Decision**: a new feature folder, `lib/features/invoicing/{domain,data,presentation}`. The list is at `/invoicing/fiscal-documents` and the detail at `/invoicing/fiscal-documents/:fiscalDocumentId`. The side nav gets a new "Facturación" group holding one destination, "Facturas", as `NavBranch.fiscalDocuments = 29`.
- **Rationale**: the constitution names `invoicing` as one of the four business features (§I) and `/invoicing` as its route root (Technology Stack). Credit notes (#56), cancellation (#52) and payment receipts will land in the same group.
- **Alternatives**: putting it under `features/sales` beside Pedidos was rejected because fiscal documents are their own right (23) and their own module in legacy.

## R2. Domain entities and the document-type enum

- **Decision**: new freezed entities `FiscalDocumentSummary`, `FiscalDocument`, `InvoiceLine` and `InvoiceRelation`, a `FiscalDocumentStatus` enum (draft, sealed, issued, cancelled) and a `PaymentTerms` enum (pue, ppd). See [data-model.md](./data-model.md). The document type reuses `FiscalDocumentKind` from `features/catalog/domain` (shared kernel, §I), and an unknown code renders as "Tipo desconocido (n)".
- **Bug found and fixed here.** Spec 065's `FiscalDocumentKind` has the right codes but the wrong names. mbe-api's `FiscalDocumentType` and legacy `constants.md` define them as follows:

  | Code | API / legacy | 065 enum value | 065 label (es) | Correct label (es) |
  |---|---|---|---|---|
  | 0 | INVOICE | invoice | Factura | Factura |
  | 1 | FEE_RECEIPT | expense | Egreso | Recibo de honorarios |
  | 2 | RENT_RECEIPT | payment | Pago | Recibo de arrendamiento |
  | 3 | DEBIT_NOTE | transfer | Traslado | Nota de cargo |
  | 100 | CREDIT_NOTE | creditNote | Nota de crédito | Nota de crédito |
  | 101 | ADVANCE_PAYMENTS_APPLIED | paymentReceipt | Recibo de pago | Aplicación de anticipos |
  | 200 | PAYMENT_RECEIPT | advancePaymentsApplied | Aplicación de anticipos | Recibo de pago |

  The wire mapping in `taxpayer_batch_repository_impl.dart` (`_wireType`, lines 105–113) goes by **member name** to the generated `FiscalDocumentType.numberN`, and each arm currently agrees with its member's code, so stored data is right. After the rename the two arms for 101 and 200 must swap (`advancePaymentsApplied => number101`, `paymentReceipt => number200`). Left as they are, they would still compile and write a payment-receipt series as 101, so the rename is tested on the write path too. Only the names shown in the Series section and its type dropdown are wrong, which makes a payment-receipt series read as "Aplicación de anticipos". Facturas would show the same wrong names in its type column and filter. The values are renamed to `invoice, feeReceipt, rentReceipt, debitNote, creditNote, advancePaymentsApplied, paymentReceipt` with matching l10n keys, and the 065 tests are updated. The declaration order (which sorts the Series list) is unchanged.
- **Alternatives**: a second enum for fiscal documents was rejected because it would leave the 065 bug in place and give two names to one concept.

## R3. Repository

- **Decision**: `FiscalDocumentRepository` (domain) and `FiscalDocumentRepositoryImpl(Dio)` (data), over `api.FiscalDocumentsApi(dio, appSerializers)`. `list`, `get`, `downloadXml` and every write return domain entities. Each write returns the whole updated `FiscalDocument`, because the server returns it. `DioException` maps to `AppError` through the shared `_toAppError` pattern of `delivery_order_admin_repository_impl.dart`.
- **Wire traps**, each covered by a repository unit test:
  - `type`, `payment_terms`, `payment_method` and `currency` arrive as **int** in responses. Writes use the `PaymentTerms` enum for terms.
  - The status enum is generated separately for the summary and the response, and `sealed` is the Dart const `sealed_`. Both map to the one domain enum.
  - Every decimal (`quantity`, `price`, `discount`, `tax_rate`, `total`) arrives as a String and maps to `Decimal`.
  - `discount` is a fraction 0–1 on the wire and a percentage in the UI (data-model §3).
  - `tax_rate` is exactly `0.16`, `0` or `-1` (exempt). It maps to `InvoiceTaxRate {iva16, zero, exempt}`.
  - Line writes take anyOf wrappers (`Quantity4`, `Price`, `Discount1`, `TaxRate`), built from `Decimal` strings.
  - A relation's type is `'04'`/`'07'` in requests and `'01'|'04'|'07'|null` in responses.
  - `issued` is Mexico City wall-clock time with no offset. Reads go through `appSerializers` (spec 043). Writes send it the same way the payment editor (spec 059) sends its dates, and the live quickstart checks the round trip (step 6).

## R4. List, filters and search

- **Decision**: copy the delivery-orders list (spec 061). It uses a freezed `FiscalDocumentsFilter` with `fromQuery`/`toQuery` on `ListQuery`, an `AsyncNotifier` family controller using `fetchClampedPage`, `CatalogFilterBar` + `CatalogSearchBar`, and the filter drawer. The drawer facets are:
  - **Estado**: dropdown with Todos, Borrador, Sellado, Timbrado, Cancelado.
  - **Tipo**: dropdown over `FiscalDocumentKind`.
  - **Emisor**: `CatalogEntityPicker<TaxpayerIssuerListItem>` over `taxpayerIssuerRepositoryProvider.list`, shown only to users with Taxpayers (24) read. Without that right the facet is hidden; a URL value still applies and shows as its RFC.
  - **Fecha de emisión**: `DateRangeFilterChip`, with both ends or neither, as in payments.
- The search box passes text straight to `search`. The server takes a series and folio (`GR4776`), a bare folio, a UUID, or recipient RFC or name text.
- **Server behaviours the UI states rather than works around**:
  - The list is newest first. Drafts have no `issued`, so a date filter drops them. The drawer's date facet carries a helper line saying so.
  - `total` is null for drafts (it is read from the XML), so the total column shows the shared placeholder.
  - The list is not facility-scoped. It needs only 23 read, as in legacy, so no scoping guard is needed.
- **Columns**: Folio (series+folio, or "Borrador #id" without a serial), Tipo, Emisor (RFC, name on hover), Receptor (name, RFC as subtitle), Fecha de emisión, Estado (status chip), Total (right-aligned). Row tap opens the detail. There are no row icons (R7).

## R5. Detail screen and the record-surface reading

- **Decision**: a full detail screen. The document owns child collections (lines, relations), has more than 15 own fields and needs a per-record URL, so it meets every §VI full-screen criterion. The layout follows `delivery_order_detail_screen.dart`:
  - status banner
  - header facts (`FactStripRow` + `CompactField`)
  - recipient band
  - lines section
  - related-documents section
  - totals
  - body action area
- `AppBar.actions` is empty.
- **Editing in place, no View toggle**: §VI's document reading (specs 056, 057, 060, 061). A document with a lifecycle that can only be edited as a draft opens editable when it is a draft and the user holds 23 update. It is read-only otherwise. Section controls are passed as nullable callbacks, and a null callback means the control is absent.
- Non-invoice types (credit notes, receipts, legacy fee/rent/debit) render the same header, lines and relations read-only. Receipt-only data (`paid_invoices`, payment fields) is out of scope, and the screen shows a note that the type is read-only in this version.

## R6. Writes: actions notifier

- **Decision**: a keep-alive `FiscalDocumentActions` notifier, the same shape as `DeliveryOrderActions`. Each method returns `Future<AppError?>` and never throws. Every outcome invalidates the detail. The list is invalidated on success or `NetworkError`. Methods: `create`, `updateHeader`, `addSalesOrder`, `addProduct`, `updateLine`, `removeLine`, `addRelation`, `removeRelation`, `confirm`, `reopen`.
- **Why refetch instead of using the write's response**: it matches the 061 shape, and the extra GET is cheap. One write at a time is enforced by each dialog's busy state.

## R7. Dialogs and row actions

| Action | Surface | Right |
|---|---|---|
| Nueva factura | Toolbar `FilledButton.icon` in the list's filter row. `ResponsiveDialog`: customer picker, then that customer's RFC dropdown (from `Customer.taxpayers` via `customerRepositoryProvider.get`). It creates the invoice and navigates to the new detail | 23 create |
| Editar encabezado | Section `OutlinedButton` that opens the header dialog (R8) | 23 update |
| Agregar pedido | Lines-section `OutlinedButton`. Sale picker: `salesOrderRepositoryProvider.listOrders(customer:, status: completed, search:)`, paged and debounced, the step-1 list of 061's `add_line_dialog.dart`. One pick adds the order | 23 update **and** SalesOrders read (the picker lists orders) |
| Agregar producto | Lines-section `OutlinedButton`. `CatalogEntityPicker<ProductListItem>`; the server adds the product at quantity 1 and the customer's price-list price | 56 create |
| Edit line | Row ✎ via `buildCatalogRowActions` opens the line dialog: cantidad, precio unitario, descuento %, IVA (16 % / 0 % / Exento), clave interna, descripción, comentario | 23 update |
| Remove line | Row 🗑 (second icon, within §VI's two-icon limit) opens a confirmation | 23 update |
| Agregar relación | Relations-section `OutlinedButton`. Dialog with the type (04 Sustitución / 07 Aplicación de anticipo; locked to the existing type once one relation exists) and a document picker over the list endpoint. The picker uses `status=cancelled` for 04 and `status=issued` for 07, with search prefilled with the recipient's RFC | 23 update |
| Remove relation | Row 🗑 opens a confirmation | 23 update |
| Confirmar (sellar) | Action area `FilledButton` opens a confirmation dialog that says a folio will be used | 23 update |
| Reabrir | Action area `OutlinedButton` (sealed only) opens a confirmation that says the folio is kept and the sealed XML discarded | 23 update |
| Ver PDF | Action area `OutlinedButton` (issued only) opens the shared document preview (R9) | 23 read |
| Descargar XML | Action area `OutlinedButton` (issued only), saved via R10 | 23 read |

- **Refusals**: a dialog keeps itself open and shows the refusal inline for codes the user can fix in place, such as `quantity_exceeds_invoiceable`, `issue_date_out_of_range` and `product_unpriced`. Any other refusal closes it and is shown above the action area, as in 061.
- **Remaining quantity**: the API exposes no remaining-to-invoice figure. The server refuses an excess with `fiscal_document.quantity_exceeds_invoiceable`, whose `remaining` param the message prints. The order picker lists fully invoiced orders too, and adding one is refused with `no_invoiceable_lines`. This is accepted; an "invoiceable" filter on the sales-order list would be an upstream nice-to-have, not a need.

## R8. Header dialog fields

| Field | Control | Notes |
|---|---|---|
| Receptor (RFC) | Dropdown of the customer's taxpayers | `recipient`; the server copies name, regime and postal code |
| Serie | Dropdown of the issuer's invoice series (`TaxpayerBatchRepository`, spec 065) | Locked (read-only) when the invoice has a serial |
| Uso CFDI | `CatalogEntityPicker<SatCatalogItem>` | `SatCatalogRepository` gains `listCfdiUsages` over the existing generated `SatCatalogsApi.listCfdiUsagesApiV1SatCfdiUsagesGet` |
| Método de pago | Segmented PUE / PPD | PPD sets the form to 99 and disables the form dropdown |
| Forma de pago | Dropdown over the existing `PaymentMethod` enum, minus the non-SAT 1001 | |
| Fecha de emisión | Date-time picker, empty means "al confirmar" | The help text states the 72-hour window. The client checks the window too; the server re-checks |
| Sucursal | Facility picker | Only with 103 update (or administrator), absent otherwise |
| Referencia | Text, ≤ 25 | `reference` |
| Notas | Multi-line, ≤ 1000 | `comment` |

Only changed fields are sent, which matches the server's partial update.

## R9. PDF

- **Decision**: add `DocumentKind.fiscalDocument` (gate: FiscalDocuments 23 read). `DocumentSourceImpl` gets an arm calling `printFiscalDocumentApiV1FiscalDocumentsFiscalDocumentIdPdfGet`, and `fallbackFilename` is `factura-{id}.pdf`. The server's `Content-Disposition` name (`{RFC}-{series}{folio:000000}.pdf`) wins when present. The screen calls `documentActionsProvider.preview(context, DocumentRef(kind: fiscalDocument, recordId: id, title: …))`, which gives preview, print and Descargar for free (spec 044).

## R10. XML download (new core helper)

- **Decision**: a small `core/files/save_bytes.dart` with a `FileSaver` interface and a `fileSaverProvider`. Its implementation calls `FilePicker.platform.saveFile(fileName:, bytes:)` on web, Android and iOS, where file_picker 8.3.7 writes the bytes. On macOS, Windows and Linux it calls `saveFile(fileName:)` to get a path, because the macOS implementation throws `UnsupportedError` when given bytes, and then writes the file with `dart:io`. The macOS app is not sandboxed (`Release.entitlements`), so no entitlement change is needed.
- **Filename**: the server's `Content-Disposition`, falling back to `{issuer RFC}-{series}{serial padded to 6}.xml`, built by a pure function with a unit test.
- **Alternatives**: `Printing.sharePdf` with an XML payload was rejected because it is PDF-typed on web. A new package (`file_saver`) was rejected because `file_picker` is already a dependency.

## R11. Draft totals (client mirror of the server's arithmetic)

- **Finding**: `FiscalDocumentResponse.total` is read from the stored XML, so it is **null for a draft**. The response has no subtotal, discount or tax fields at all.
- **Decision**: a pure domain function `invoiceAmounts(lines)` mirrors `cfdi_invoice.line_amounts` exactly. With MXN only and q, p, d, t as quantity, price, discount fraction and tax rate (exempt counts as 0 here):

  ```text
  divided  = tax_included && t > 0
  subtotal = round2(divided ? q·p/(1+t) : q·p)
  discount = round2(divided ? q·p·d/(1+t) : q·p·d)
  gross    = d > 0 ? round2(q·p·d) : 0
  total    = (tax_included || t <= 0) ? round2(q·p − gross) : round2((q·p − gross)·(1+t))
  taxes    = total − subtotal + discount
  ```

  Here round2 is half away from zero, applied only when the value has more than 2 places. Document SubTotal, Descuento and Total are the sums of the line figures, and IVA is the sum of taxes. Each line row shows its amount (`subtotal − discount`, pre-tax, as legacy shows it). The totals block shows Subtotal, Descuento (when > 0), IVA and Total.
- **Sealed and issued documents**: Total is the server's `total`. If the client figure differs from it, the server's figure is shown and the difference is logged to the console. The live quickstart asserts they are equal on the invoice it seals (step 9). This makes the mirror's correctness testable.
- **Alternatives**:
  - Showing no totals on a draft was rejected: clerks check the total against the order before sealing, and legacy shows it.
  - Filing an mbe-api change to return draft totals was rejected as unnecessary. The formula is six lines, already documented upstream as legacy's, and fixed by SAT compatibility.

## R12. Rights summary (§IV)

| SystemObject | Right | Gates |
|---|---|---|
| FiscalDocuments (23) | read | Nav entry, routes, list, detail, PDF, XML |
| FiscalDocuments (23) | create | Nueva factura |
| FiscalDocuments (23) | update | Every draft edit, add order, relations, confirm, reopen |
| StandaloneFiscalDocuments (56) | create | Agregar producto (the server checks only 56 here) |
| IssuedLocationId (103) | update | Sucursal field in the header dialog |
| SalesOrders | read | Agregar pedido (its picker lists orders) |
| Customers | read | Customer picker in Nueva factura and the customer-name cell (falls back to `#id`) |
| Taxpayers (24) | read | Emisor facet, Serie dropdown (without it the series stays the server's choice) |

None of 23, 56 and 103 is referenced in `lib/` yet. The route, nav entry and each button document the codes they check.

## R13. Error codes (§III coverage)

The newly called endpoints can return these codes. Already localized: `auth.forbidden`, `resource.not_found`, `user.no_facility`, `taxpayer_issuer.unknown`.

**Added (29 codes), flipped OUT → IN in `specs/058-localized-api-errors/contracts/code-scope.tsv`:**

| Group | Codes (`fiscal_document.` prefix) |
|---|---|
| PDF / XML | `not_issued`, `version_not_printable` (version), `not_stamped`, `xml_unavailable` |
| Create / header | `issuer_has_no_series` (type), `series_not_of_type` (batch, type), `recipient_not_linked` (recipient), `field_not_for_type` (fields, type), `unknown_facility`, `series_locked`, `unknown_usage` (usage), `issue_date_out_of_range` |
| State | `not_draft`, `not_sealed`, `type_not_supported` (type) |
| Lines | `order_not_invoiceable` (sales_order_id), `no_invoiceable_lines`, `product_unpriced` (product_id), `quantity_exceeds_invoiceable` (remaining, line?) |
| Relations | `relation_not_allowed` (relation_type), `already_related`, `relation_types_mixed` |
| Confirm | `no_lines`, `line_missing_sat_key` (line), `line_quantity_not_positive` (line), `recipient_incomplete`, `no_valid_certificate`, `series_missing` (batch), `certificate_cannot_sign` |

- **Validation types added (2)**: `fiscal_document_tax_rate_invalid` and `fiscal_document_payment_form_unknown`. The client never sends such values, but they are in scope for the endpoint.
- **Left OUT**: receipt and credit-note codes (`payment_form_required`, `amount_exceeds_balance`, …, 13 in total), `not_emailable` and `fiscal_document_payment_date_in_future`. Their endpoints aren't called, or the fields are never sent on an invoice.
- **Resource nouns added**: `fiscal_document_line` ("partida de factura", f.) and `fiscal_document_relation` ("documento relacionado", m.), in `resourceNoun` and `resourceGender`.
- **Test effects**:
  - `catalog_coverage_test` goes from `checked == 114` to `143`.
  - The `problem_fixtures` and `needParams` entries are added for the parameterized codes.
  - `resource_noun_test` gets the two new nouns.

## R14. Testing

- **Unit**:
  - `fiscal_document_repository_impl_test`: the wire traps in R3, list params, writes, XML bytes and filename.
  - `fiscal_documents_filter_test`
  - `fiscal_documents_list_controller_test`
  - `fiscal_document_actions_test`: invalidations, `AppError` returns.
  - `invoice_amounts_test`: table cases including tax-included, exempt, 0 %, discounts, and a half-cent rounding case.
  - `xml_filename_test`
  - `file_saver_test`: platform branch via an injectable `TargetPlatform`/`kIsWeb` seam.
  - `fiscal_document_kind_test`: codes ↔ names after the R2 rename.
  - The updated `catalog_coverage_test` and `resource_noun_test`.
- **Widget**:
  - `fiscal_documents_list_screen_test`: columns, facets, no-access, the date-drops-drafts helper.
  - `fiscal_document_detail_screen_test`: per state, rights matrix, non-invoice read-only.
  - `new_invoice_dialog_test`
  - `invoice_header_dialog_test`: PPD lock, series lock, 103 gate, 72 h.
  - `invoice_line_dialog_test`: ranges, exempt, % ↔ fraction.
  - `add_sales_order_dialog_test`
  - `add_product_dialog_test`
  - `add_relation_dialog_test`: type lock.
  - `fiscal_document_status_chip_test`
  - The 065 Series widget tests updated for the renamed labels.
- **Live**: `integration_test/fiscal_documents_quickstart_test.dart` (see [quickstart.md](./quickstart.md)). Writes are gated on `MBE_WRITE`, as in earlier specs.
