---
description: "Task list for 066-invoice-list-editor"
---

# Tasks: Invoice List, View, PDF and Editor

**Input**: Design documents from `specs/066-invoice-list-editor/`

**Prerequisites**: plan.md, spec.md, research.md (R1–R14), data-model.md, contracts/ui-contracts.md (C1–C14), quickstart.md

**Tests**: The spec doesn't ask for a test suite as such, but the constitution's quality gates and research R14 require tests. Test tasks sit inside each story, after the code they cover.

**Organization**: Grouped by user story (US1–US6, spec.md). US1, US2 and US3 are P1 and together are the MVP: find documents, read one with its PDF and XML, and start an invoice from a sales order. US4 (edit a draft) and US5 (confirm and reopen) are P2. US6 (relations) is P3. Phase 2 holds what two or more stories share.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: parallelizable (different files, no dependency on an incomplete task)
- **[Story]**: US1 find documents · US2 view, PDF and XML · US3 invoice sales orders · US4 edit a draft · US5 confirm and reopen · US6 relations

## Cross-story notes

- **Shared files.** Do these sequentially, not in parallel:
  - `lib/features/invoicing/presentation/fiscal_document_detail_screen.dart`: T019 (US2) creates it as a read-only screen, then T024 (US3), T032 (US4), T037 (US5) and T040 (US6) each add their controls. Controls are nullable callbacks, so an absent right means the control is not in the tree.
  - `lib/features/invoicing/presentation/invoice_action_dialogs.dart`: T029 (US4) creates it with the remove-line confirmation, T036 (US5) adds confirm and reopen, and T039 (US6) adds the remove-relation confirmation.
  - `lib/features/invoicing/presentation/fiscal_documents_list_screen.dart`: T012 (US1) creates it, and T022 (US3) adds the Nueva factura button.
  - `lib/app/router/app_router.dart` and `lib/core/navigation/nav_destinations.dart`: T013 (US1) adds the list branch, nav entry and gate, and T020 (US2) adds the detail route.
  - `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb`: T002 renames the kind keys and T003 adds every other key once. If a later task needs another, add it there and run `flutter gen-l10n`. Never hand-edit `lib/l10n/app_localizations*.dart`.
- **Generated code.** After editing a freezed or `@riverpod` file, run `dart run build_runner build --delete-conflicting-outputs` at the repo root. Never run two build_runner processes at once: tasks that both need it are not marked [P] against each other. No client regeneration is needed: `FiscalDocumentsApi` already has every operation this spec calls (list, get, xml, pdf, create, update, sales-orders, lines, relations, confirm, reopen).
- **Formatting.** Format only the files you changed (`dart format <files>`). Never `dart format .`, and never format `lib/generated/`.
- **Amounts, quantities and dates** go through `formattersProvider` (constitution §V). No `NumberFormat`, no `toStringAsFixed`. Quantities, prices and rates are `Decimal`, never `double`. A discount is a percentage in the UI and a 0–1 fraction on the wire.
- **Spacing tokens, not literals** (`Theme.of(context).spacing`). No automated guard catches a literal, so check it in review.
- **Never match server prose** (§III). Show refusals through `AppError.localizedMessage` / `ErrorBanner`, which build the text from the error's `code`. Recognition keys on the code.
- **Status and type names come from l10n**, never from `enum.name`.
- **Rights.** Every control follows C9 in `contracts/ui-contracts.md`. A missing right means the control is absent, never disabled. Document the system-object codes in a comment where a route, nav entry or control is gated.
- **Simplifications.** Any shortcut carries a comment `// simplified: <ceiling>, <what to do when it binds>`.
- **Mirror, don't copy blindly.** Closest precedents:
  - List screen, filter and controller: `sales/presentation/delivery_orders/{delivery_orders_list_screen, delivery_orders_filter, delivery_orders_list_controller}.dart`, and `payments/payments_filter.dart` for the date range.
  - Document detail screen (facts strip, lines table and cards, action area, `_NotFound`, `_LoadFailed`): `delivery_orders/delivery_order_detail_screen.dart`.
  - Write controller returning `AppError?`: `delivery_orders/delivery_order_actions.dart`.
  - Dialog with a busy flag and an inline refusal: `delivery_orders/delivery_order_dialogs.dart` and `add_line_dialog.dart` (the sale picker is its step 1).
  - Line row icons: `buildCatalogRowActions` as in `delivery_order_detail_screen.dart`.
  - Repository with a `_toAppError` and the wire mapping: `sales/data/delivery_order_admin_repository_impl.dart`; its test: `test/unit/features/sales/delivery_order_admin_repository_impl_test.dart`.
  - Document preview: `delivery_orders/delivery_order_print.dart` and `lib/core/documents/`.
  - Widget harness: `test/widget/features/sales/delivery_orders_list_screen_test.dart` and `delivery_order_detail_screen_test.dart`; unit harness: `delivery_orders_filter_test.dart` and `delivery_order_actions_test.dart`.

---

## Phase 1: Setup

**Purpose**: a known-good baseline, so later failures are attributable.

- [X] T001 Run `flutter analyze` and the existing tests this feature touches: `test/unit/core/errors/catalog_coverage_test.dart`, `test/unit/core/errors/resource_noun_test.dart`, the spec 065 taxpayer batch tests (find them with `grep -rl TaxpayerBatch test`), `test/unit/core/documents/`, the sat catalog repository test (`grep -rl SatCatalogRepositoryImpl test`), and any navigation or router test (`grep -rl nav_destinations test`). Note any pre-existing failures so they aren't blamed on this feature. The failures in `test/golden/core_widgets_golden_test.dart` are already known (mbe-ui#209).

---

## Phase 2: Foundational (blocks all user stories)

**Purpose**: the pieces two or more stories use: the corrected document kind, strings, error codes, entities, the repository, the filter, the controllers and the status chip.

- [X] T002 Fix spec 065's document-kind names (research R2). The codes were right and the names wrong.
  - In `lib/features/catalog/domain/entities/fiscal_document_kind.dart`, rename the values to `invoice(0), feeReceipt(1), rentReceipt(2), debitNote(3), creditNote(100), advancePaymentsApplied(101), paymentReceipt(200)`. Keep the declaration order, which sorts the Series list.
  - In `lib/features/catalog/presentation/fiscal_document_kind_label.dart`, update the switch and the l10n keys: `fiscalDocumentKindFeeReceipt` ("Recibo de honorarios" / "Fee receipt"), `…RentReceipt` ("Recibo de arrendamiento" / "Rent receipt"), `…DebitNote` ("Nota de cargo" / "Debit note"), `…PaymentReceipt` ("Recibo de pago" / "Payment receipt"), `…AdvancePaymentsApplied` ("Aplicación de anticipos" / "Advance payments applied"). Remove `…Expense`, `…Payment` and `…Transfer` from both `.arb` files, and run `flutter gen-l10n`. Keep `…Invoice`, `…CreditNote` and `…Unknown`.
  - Fix every other reference (`grep -rn "FiscalDocumentKind\.\(expense\|payment\|transfer\|paymentReceipt\|advancePaymentsApplied\)" lib test`), including `lib/features/catalog/data/taxpayer_batch_repository_impl.dart`. **Its `_wireType` switch maps by member name, not by code, so the arms for 101 and 200 must swap**: `advancePaymentsApplied => FiscalDocumentType.number101` and `paymentReceipt => FiscalDocumentType.number200`. A mechanical rename leaves them compiling but writing a payment-receipt series as 101 (research R2). Check the read path (code → kind) the same way.
  - Add `test/unit/features/catalog/fiscal_document_kind_test.dart`: each code maps to the right member and Spanish label, and an unknown code returns null. Extend the taxpayer batch repository test (`grep -rl TaxpayerBatchRepositoryImpl test`): create and update send `number200` for `paymentReceipt` and `number101` for `advancePaymentsApplied`, and a response with type 200 reads back as `paymentReceipt`. Update the spec 065 Series widget and batch tests for the new labels.
  - Run the spec 065 tests: they must pass.

- [X] T003 Add every new string to `lib/l10n/app_es.arb` and `lib/l10n/app_en.arb`, then run `flutter gen-l10n`. Each key gets an `@key` description starting "spec 066". Check `app_es.arb` first and reuse existing keys (`filtersTooltip`, `filtersButton`, `clearAllFilters`, `applyFilters`, `clearFiltersButton`, `retryButton`, `cancelButton`, `apiResourceFiscalDocument`, the `paymentMethod*` set). Copy comes from `contracts/ui-contracts.md` and `research.md` R7/R8. Keys:
  - **Navigation and titles:** `navInvoicingGroup` ("Facturación"), `navFiscalDocuments` ("Facturas"), `fiscalDocumentTitle` (placeholder `folio`: "Factura {folio}"), `fiscalDocumentTitleKind` (placeholders `kind`, `folio`), `fiscalDocumentTitleDraft` (placeholder `id`: "Borrador #{id}"), `fiscalDocumentDraftFolio` ("Borrador"), `fiscalDocumentsEmpty`, `fiscalDocumentsSearchHint` ("Folio, UUID, RFC o nombre del receptor"), `fiscalDocumentBackToList`.
  - **Status labels (4):** `fiscalDocumentStatusDraft` ("Borrador"), `…Sealed` ("Sellado"), `…Issued` ("Timbrado"), `…Cancelled` ("Cancelado").
  - **List columns and facets:** Folio, Tipo, Emisor, Receptor, Fecha de emisión, Estado, Total; the facets Estado, Tipo, Emisor, Fecha de emisión, "Todos"; the date helper "Los borradores no tienen fecha de emisión y no aparecen al filtrar por fecha."
  - **Detail:** the banners (sealed, non-invoice, cancelled) and every header fact label (emisor, receptor, cliente, sucursal, serie y folio, fecha de emisión and "al confirmar", método de pago PUE/PPD, forma de pago, uso CFDI, moneda, referencia, notas, UUID, fecha de timbrado), the lines columns (Cantidad, Unidad, Clave SAT, Descripción, Precio unitario, Descuento, IVA, Importe), the "Pedido" marker, the tax labels ("16 %", "0 %", "Exento"), the section titles (Partidas, Documentos relacionados), the totals (Subtotal, Descuento, IVA, Total, "Total (estimado)"), and the relation-type labels (04 Sustitución, 07 Aplicación de anticipo, 01 Nota de crédito).
  - **Actions and dialogs:** `fiscalDocumentNewAction` ("Nueva factura"), `…EditHeader`, `…AddOrder`, `…AddProduct`, `…AddRelation`, `…ConfirmAction` ("Confirmar"), `…ReopenAction` ("Reabrir"), `…ViewPdf` ("Ver PDF"), `…DownloadXml` ("Descargar XML"), and the dialog titles, field labels, helper texts and bodies of C6–C13, including the line-quantity message with a `remaining` placeholder, the no-customer note ("Este borrador no tiene cliente: no se puede cambiar el receptor ni agregar pedidos."), the no-taxpayers message and the header helpers (series lock, PPD lock, 72-hour window).
  - **Feedback:** one snackbar key per action that names the folio (placeholder `folio`), "XML guardado", and an unknown-result message ("No sabemos si se completó: se perdió la conexión. El documento se actualizó.").
  - **API errors:** one `apiErrorFiscalDocument*` key per code in T004, with the placeholders in research R13.

- [X] T004 [P] Localize the fiscal codes (research R13, depends on T003).
  - In `lib/core/errors/localize_problem.dart`, add the 29 generated `api.ErrorCode` members to `localizedErrorCodes`, mapped to their `l10n.apiErrorFiscalDocument*` keys in the switch. Research R13 lists every code with its params. Find the member names in `lib/generated/openapi/lib/src/model/error_code.g.dart` (pattern `fiscalDocumentPeriod<Name>`). Use the existing `_ap1/_ap2`, `_quantity` and `_count` helpers for `remaining`, `line`, `version`, `type` and the like. A missing or mistyped param returns null (the generic display), never an exception.
  - Add the two validation types (`fiscal_document_tax_rate_invalid`, `fiscal_document_payment_form_unknown`) to `localizedValidationTypes` and `localizeValidationType`.
  - Add `fiscal_document_line` ("partida de factura", feminine) and `fiscal_document_relation` ("documento relacionado", masculine) to `resourceNoun` and `resourceGender`, with `apiResource*` ICU plurals in both `.arb` files.
  - In `test/unit/core/errors/problem_fixtures.dart`, add fixtures for every new code, and add the parameterized ones to `needParams` in `catalog_coverage_test.dart`. Extend `test/unit/core/errors/resource_noun_test.dart` with the two nouns.
  - In `specs/058-localized-api-errors/contracts/code-scope.tsv`, flip the 29 `fiscal_document.*` code rows and the two validation-type rows from `OUT` to `IN`, setting `example_routes` to the endpoint and the note to "reachable from the Facturas screens (spec 066)". Leave the receipt and credit-note rows, `not_emailable` and `fiscal_document_payment_date_in_future` as `OUT`.
  - Raise the `checked` count in `catalog_coverage_test.dart` (114 → 143; confirm the current value first).
  - Run `flutter test test/unit/core/errors/`.

- [X] T005 [P] Create the entities and the amounts mirror (data-model §1, §2, §4, research R11).
  - In `lib/features/invoicing/domain/entities/fiscal_document.dart` (freezed): `FiscalDocumentSummary`, `FiscalDocument`, `InvoiceLine`, `InvoiceRelation`, and the enums `FiscalDocumentStatus`, `PaymentTerms`, `InvoiceTaxRate`, `InvoiceRelationType`, with the getters in data-model §2 (`folioLabel`, `isInvoice`, `isEditableDraft`, `canReopen`, `hasDocuments`, `relationType`). Reuse `FiscalDocumentKind` from catalog. Also declare the write inputs of data-model §3 (`NewInvoice`, `InvoiceHeaderPatch`, `InvoiceLinePatch`).
  - In `lib/features/invoicing/domain/entities/invoice_amounts.dart`: pure `lineAmounts` and `invoiceAmounts` that reproduce mbe-api `app/services/cfdi_invoice.py` `line_amounts` exactly (half away from zero to 2 places, applied only when the value has more than 2; exempt counts as t = 0). The formula is in research R11.
  - Add `test/unit/features/invoicing/invoice_amounts_test.dart`: tax-excluded and tax-included lines, 0 % and exempt, a discount, a half-cent rounding case, several lines summed, and a line row amount of `subtotal − discount`. Work the expected numbers out by hand from the formula, not from the implementation.
  - Run build_runner.

- [X] T006 Create the repository (research R3, depends on T005).
  - In `lib/features/invoicing/domain/repositories/fiscal_document_repository.dart` declare `list`, `getById`, `downloadXml` and the writes (`create`, `updateHeader`, `addSalesOrder`, `addProduct`, `updateLine`, `removeLine`, `addRelation`, `removeRelation`, `confirm`, `reopen`), each with a doc comment naming its endpoint. Every write returns the updated `FiscalDocument`.
  - In `lib/features/invoicing/data/fiscal_document_repository_impl.dart`, implement them over the generated `FiscalDocumentsApi(dio, appSerializers)`, with `fiscalDocumentRepositoryProvider`. Map every wire trap in research R3: int `type`, `payment_terms`, `payment_method` and `currency`; the `sealed_` status const and the two separate status enums; decimal strings to `Decimal`; the anyOf `Quantity4`, `Price`, `Discount1` and `TaxRate` wrappers on writes; the relation type `'01'|'04'|'07'|null`; and an unknown status or tax rate degrading rather than throwing. `list` takes `search`, `issuer`, `type`, `status`, `dateFrom`, `dateTo`, `skip` and `limit`. `downloadXml` returns the bytes and the server's `Content-Disposition` filename when present.
  - Create `test/unit/features/invoicing/fiscal_document_repository_impl_test.dart` (follow `delivery_order_admin_repository_impl_test.dart`): the mapping cases above, the list params, a null `total`, the percent-to-fraction conversion in `updateLine`, only changed header fields sent, PPD sending no payment form, the relation type on the wire, and the XML bytes with and without a filename header.

- [X] T007 [P] Create the filter (data-model §6, research R4, depends on T005): `lib/features/invoicing/presentation/fiscal_documents_filter.dart` (freezed), with `fromQuery(ListQuery)`, `toQuery`, `activeFilterCount`, `isNarrowed` and `cleared()`. Keys: `q`, `status`, `type`, `issuer`, `from`, `to`, `page`. The date range needs both ends or neither, parsed with `parsePaymentsDateFacet` / `encodePaymentsDateFacet`. An unknown status or non-numeric type is ignored. `cleared()` keeps the search. Create `test/unit/features/invoicing/fiscal_documents_filter_test.dart` (follow `delivery_orders_filter_test.dart`): round-trip, unknown values ignored, a one-ended date range dropped, counts (the date range counts once), and clearing. Run build_runner.

- [X] T008 Create the list controller (depends on T006, T007): `lib/features/invoicing/presentation/fiscal_documents_list_controller.dart`, an `AsyncNotifier` family keyed by the filter, 20 per page, page clamped with `fetchClampedPage`. The server does not scope this list by facility (research R4), so no facility handling is needed. Create `test/unit/features/invoicing/fiscal_documents_list_controller_test.dart` (follow `delivery_orders_list_controller_test.dart`): the filter reaches the repository with `limit 20`, the page is clamped when the last row goes, and an error surfaces. Run build_runner.

- [X] T009 Create the detail controller (research R5, depends on T006): `lib/features/invoicing/presentation/fiscal_document_detail_controller.dart`, a `@riverpod` family keyed by the document id that loads the document. Create `test/unit/features/invoicing/fiscal_document_detail_controller_test.dart`: it loads, and a not-found error surfaces as such. Run build_runner.

- [X] T010 Create the write controller (research R6, depends on T006): `lib/features/invoicing/presentation/fiscal_document_actions.dart`, a keep-alive notifier with `create`, `updateHeader`, `addSalesOrder`, `addProduct`, `updateLine`, `removeLine`, `addRelation`, `removeRelation`, `confirm` and `reopen`. Each returns `AppError?` and never throws. Every outcome invalidates the detail provider. The list is invalidated on success or on a connection error. A connection error, or a timeout with no response, returns an "unknown result" error. Create `test/unit/features/invoicing/fiscal_document_actions_test.dart` (follow `delivery_order_actions_test.dart`): each action calls the right repository method, the invalidations on success and on failure, the server's error code passes through, and the unknown-result case. Run build_runner.

- [X] T011 [P] Create the status chip and labels (contracts C4, depends on T003, T005): `lib/features/invoicing/presentation/fiscal_document_status_chip.dart` with `FiscalDocumentStatusChip` on `StatusChip<FiscalDocumentStatus>` (key `fiscal_document_status_chip_{name}`; tones draft neutral, sealed info, issued success, cancelled error), and `lib/features/invoicing/presentation/fiscal_document_labels.dart` with the label helpers for payment terms, tax rate and relation type. Create `test/widget/features/invoicing/fiscal_document_status_chip_test.dart`: the four statuses render their Spanish label and don't clip at a narrow width.

---

## Phase 3: User Story 1 — Find a fiscal document (Priority: P1) 🎯 MVP

**Goal**: a clerk opens Facturas, searches and narrows the list, and sees each document's folio, type, issuer, recipient, date, state and total.

**Independent Test**: open the list as a user with 23 read, search a known legacy invoice by folio and by recipient RFC, and apply each filter. The expected rows show, newest first. As `qanoaccess`, the entry is missing and the URL is refused.

- [X] T012 [US1] Create the list screen (C2, C3, research R4, depends on T008, T011): `lib/features/invoicing/presentation/fiscal_documents_list_screen.dart`. Declare `const fiscalDocumentsPath = '/invoicing/fiscal-documents';` at the top of this file; T013 and T020 use it.
  - Filter row: `CatalogSearchBar` (hint from T003), the badged filters `IconButton.outlined(Icons.tune)` that opens `showCatalogFilterSheet` with `CurrentListQueryBuilder`. Submit search with `submitCatalogSearch`.
  - Drawer facets: Estado (dropdown, sentinel "Todos", wrapped in `KeyedSubtree(key: ValueKey(...))`), Tipo (dropdown over `FiscalDocumentKind`, labelled with `fiscalDocumentKindLabel`; an unknown code in the URL still applies and shows "Tipo desconocido (n)"), Emisor (`CatalogEntityPicker<TaxpayerIssuerListItem>` over `taxpayerIssuerRepositoryProvider.list`, shown only with Taxpayers (24) read; a URL value without the right still applies and shows as its RFC), and Fecha de emisión (`DateRangeFilterChip`) with the helper text under it. Every change calls `goTo(query.withFacet(...).copyWith(pageIndex: 0))`.
  - Table: `DataTableView<FiscalDocumentSummary>` with the columns in research R4. Folio is `folioLabel` or "Borrador #id"; Receptor shows the name with the RFC as a subtitle; Total is right-aligned with the shared placeholder when null; Estado uses the status chip. No row icons. Row tap pushes `'$fiscalDocumentsPath/${s.id}'`. Pagination, `CatalogListStateView` and the compact-tier rows follow the delivery-orders list.
  - Amounts and dates through `formattersProvider`. No Nueva factura button yet (T022).

- [X] T013 [US1] Add the navigation and the list route (C1, depends on T012).
  - In `lib/core/navigation/nav_destinations.dart`, add `NavBranch.fiscalDocuments = 29` (appended last; its position must match the shell branch order) and a new `NavGroup` "Facturación" with one destination "Facturas" (route `/invoicing/fiscal-documents`, gate `PrivilegeGate(SystemObject.fiscalDocuments, AccessRight.read)`), placed after the sales group. Add a comment that it corresponds to FiscalDocuments (23).
  - In `lib/app/router/app_router.dart`, append the matching `StatefulShellBranch` with `builder: (_, state) => FiscalDocumentsListScreen(query: ListQuery.fromUri(state.uri))`, and add the `_routeGate` clause `/invoicing/fiscal-documents` → 23 read, mind the prefix-ordering comments there. The detail route comes in T020.

- [X] T014 [P] [US1] Create `test/widget/features/invoicing/fiscal_documents_list_screen_test.dart` (follow `delivery_orders_list_screen_test.dart`): rows render with folio, type, issuer, recipient, date, chip and total; a draft shows "Borrador #id" and the placeholder total; search submits `q`; each facet updates the query and resets the page; the filter button's badge counts the active facets; the Emisor facet is absent without Taxpayers read; the date helper text is present; row tap pushes the detail path; empty, filtered-empty and error states; and the compact tier stacks the rows.

- [X] T015 [P] [US1] Add router and navigation tests (find the existing ones with `grep -rl nav_destinations test`): the "Facturación" group and "Facturas" entry show for a user with 23 read and not for a user without it; `/invoicing/fiscal-documents` redirects to the no-access screen without the right; `NavBranch.fiscalDocuments` equals the branch's position. Run these tests right after T013, since it changes the router.

**Checkpoint**: the list works and filters. A row tap points at a detail route that T020 adds.

---

## Phase 4: User Story 2 — View a document and get its PDF and XML (Priority: P1) 🎯 MVP

**Goal**: from the list, open any document and read its header, state, lines, relations and totals. For an issued document, preview, print or save the PDF and save the XML.

**Independent Test**: open an issued legacy invoice, check the header, lines and total against the list, preview the PDF, and save the XML as `{RFC}-{series}{folio:000000}.xml`. A draft or sealed document offers neither, and says why.

- [X] T016 [P] [US2] Add the PDF kind to the document module (research R9): in `lib/core/documents/domain/document_kind.dart` add `fiscalDocument` (gate `SystemObject.fiscalDocuments`, right read; `fallbackFilename(id)` is `factura-{id}.pdf`), and in `lib/core/documents/data/document_source_impl.dart` add the switch arm calling `printFiscalDocumentApiV1FiscalDocumentsFiscalDocumentIdPdfGet(fiscalDocumentId:)`. Add the l10n title key if the module needs one. Extend `test/unit/core/documents/` with a case that the arm calls the right method, checks the `%PDF-` signature and uses the server's filename, and that a 409 problem (`fiscal_document.not_stamped`, `fiscal_document.version_not_printable`) reaches the caller as an `AppError` that keeps its code, so the preview can localize it; extend `generated_client_bytes_test.dart` if it lists the methods it guards. Run `test/unit/core/documents/` right after.

- [X] T017 [P] [US2] Create the file saver (research R10): `lib/core/files/file_saver.dart` (interface `FileSaver.save({required Uint8List bytes, required String filename})` returning whether a file was saved, plus `fileSaverProvider`) and `lib/core/files/file_saver_impl.dart`. On web, Android and iOS call `FilePicker.platform.saveFile(fileName:, bytes:)`. On macOS, Windows and Linux call `saveFile(fileName:)` for a path (file_picker 8.3.7 throws `UnsupportedError` when given bytes on macOS) and write the bytes with `dart:io`; a null path means the user cancelled, so return false. Take the platform from an injectable seam (`TargetPlatform` and `kIsWeb`) so it is testable. Create `test/unit/core/files/file_saver_test.dart`: each platform branch, a cancelled dialog returns false, and bytes reach the file on desktop.

- [X] T018 [P] [US2] Create `lib/features/invoicing/domain/xml_filename.dart`: a pure `invoiceXmlFilename({required String issuerRfc, String? series, required int serial})` returning `{RFC}-{series}{serial padded to 6}.xml` (series empty when null), and `test/unit/features/invoicing/xml_filename_test.dart` with a series, no series, a 7-digit serial (not truncated) and a short serial.

- [X] T019 [US2] Create the read-only detail screen (C5, research R5, depends on T009, T011, T016, T017, T018): `lib/features/invoicing/presentation/fiscal_document_detail_screen.dart`.
  - Full-screen `Scaffold`, `AppBar` with the title and empty `actions`. `_NotFound` and `_LoadFailed` states as in the delivery-order detail, and a null id shows not-found.
  - At most one banner (sealed, non-invoice, cancelled).
  - Header facts (`FactStripRow` + `CompactField`), including the customer name through `customerDisplayNameProvider` (falls back to `#id`) and the recipient band.
  - Partidas as `DataTableView<InvoiceLine>` (`shrinkWrap: true`) on wide tiers and cards on compact, with the "Pedido" marker when `orderLineId` is set, and the tax-rate and discount labels. Documentos relacionados when present. Totals in their own widget, `lib/features/invoicing/presentation/invoice_totals.dart`, from `invoiceAmounts(lines)` labelled "Total (estimado)" on a draft; on a sealed or issued document, the server's `total`.
  - Action area per C5: Ver PDF (`documentActionsProvider.preview` with `DocumentKind.fiscalDocument`, shown when `status == issued` or `cancelled`, with 23 read) and Descargar XML (`downloadXml`, then `fileSaverProvider.save` with the server's filename or `invoiceXmlFilename`; success snackbar; a cancelled save shows nothing; a refusal shows a snackbar through `userMessage`). Both need 23 read; a sealed document shows neither and the sealed banner says stamping isn't available.
  - No edit controls at all in this task.

- [X] T020 [US2] Add the detail route (depends on T019): in `lib/app/router/app_router.dart` add a top-level `GoRoute(path: '$fiscalDocumentsPath/:fiscalDocumentId', builder: …)` parsing the id with `int.tryParse` (null shows not-found), and make sure the `_routeGate` clause covers the detail path. Run the router tests from T015.

- [X] T021 [P] [US2] Create `test/widget/features/invoicing/fiscal_document_detail_screen_test.dart` (follow `delivery_order_detail_screen_test.dart`): an issued invoice shows header, lines, totals (the server's total, not "estimado") and both document buttons; Ver PDF calls the preview with the right ref, and a PDF refusal (`version_not_printable`) shows its localized text in the preview dialog; Descargar XML saves the bytes under the right name, and a cancelled save is silent; a refusal shows its localized message; a draft shows the estimated total and neither document button; a sealed invoice shows the sealed banner and no document buttons; a credit note shows the non-invoice banner and no edit controls; a cancelled document shows its date; a missing id and a load failure show their states; a user without 23 read can't reach the buttons; and the compact tier renders lines as cards.

**Checkpoint**: US1 and US2 together give a working Facturas viewer, which already covers everything the legacy documents need.

---

## Phase 5: User Story 3 — Invoice sales orders (Priority: P1) 🎯 MVP

**Goal**: start an invoice for a customer's RFC, then add completed sales orders at their remaining quantity.

**Independent Test**: create an invoice for a customer with a completed order, add the order, and check the lines. Add it again and nothing duplicates. A customer without an RFC can't start one.

- [X] T022 [US3] Create the Nueva factura flow (C6, depends on T010, T012): `lib/features/invoicing/presentation/new_invoice_dialog.dart` (a `ResponsiveDialog` with a busy flag).
  - Cliente: `CatalogEntityPicker<CustomerListItem>` over `customerRepositoryProvider.list(search:, limit: 10)`, shown as `'${code} — ${name}'`. After a pick, load the customer with `customerRepositoryProvider.get` and show its taxpayers in an RFC dropdown; with none, show the no-taxpayers message and disable Crear.
  - Crear calls `create`; on success pop and `context.push` the new detail. `issuer_has_no_series`, `recipient_not_linked` and `user.no_facility` stay inline through `ErrorBanner`.
  - In `fiscal_documents_list_screen.dart`, add the **Nueva factura** `FilledButton.icon` in the filter row, only with 23 create.

- [X] T023 [US3] Create the sales-order picker (C10, depends on T010): `lib/features/invoicing/presentation/add_sales_order_dialog.dart`, a `ResponsiveDialog` that pages the customer's orders with `salesOrderRepositoryProvider.listOrders(customer:, status: SaleStatus.completed, search:, skip:, limit:)` (debounced search, as step 1 of `delivery_orders/add_line_dialog.dart`), each row showing folio, date and total. Picking an order calls `addSalesOrder` and pops with the folio. `no_invoiceable_lines` and `order_not_invoiceable` stay inline so the user can pick another. The dialog takes the document's `customerId` and is only opened when it is non-null.

- [X] T024 [US3] Wire Agregar pedido into the detail screen (depends on T019, T023): in `fiscal_document_detail_screen.dart`, add the controls of an editable draft. `canEdit = document.isEditableDraft && can(fiscalDocuments, update)`. The lines section header gets an **Agregar pedido** `OutlinedButton.icon` when `canEdit` and the user has SalesOrders (7) read; success shows the snackbar from C10. When `customerId` is null (a legacy draft), Agregar pedido is absent and the header shows the no-customer note (T003). Pass the controls as nullable callbacks.

- [X] T025 [P] [US3] Create `test/widget/features/invoicing/new_invoice_dialog_test.dart`: the RFC dropdown fills after a customer is picked; a customer with no taxpayers shows the message and disables Crear; Crear calls `create` with the customer and RFC and navigates to the new detail; the three refusals stay inline; and the list's Nueva factura button is present only with 23 create.

- [X] T026 [P] [US3] Create `test/widget/features/invoicing/add_sales_order_dialog_test.dart` (follow `add_line_dialog_test.dart`): the picker lists the customer's completed orders and pages; search filters; picking calls `addSalesOrder` and pops with the folio; both refusals stay inline and the dialog stays usable; and the button is absent without 23 update and without SalesOrders read.

**Checkpoint**: invoices can be started and filled from orders. This is the MVP: US1–US3.

---

## Phase 6: User Story 4 — Edit an invoice draft (Priority: P2)

**Goal**: adjust and remove lines, add products by hand, and edit the header, all on a draft.

**Independent Test**: on a draft, change a line's quantity and discount, delete a line, add a manual product line, switch the terms to PPD and set an issue date. Each change persists after reloading.

- [X] T027 [P] [US4] Add CFDI usages to the SAT catalog (research R8): `listCfdiUsages({search, skip, limit})` in `lib/features/catalog/domain/repositories/sat_catalog_repository.dart` and its implementation in `lib/features/catalog/data/sat_catalog_repository_impl.dart` over the generated `SatCatalogsApi.listCfdiUsagesApiV1SatCfdiUsagesGet`, mapped to `SatCatalogItem` like the existing methods. Extend the sat catalog repository test (`grep -rl SatCatalogRepositoryImpl test`) with a mapping and search case.

- [X] T028 [US4] Create the line dialog (C8, depends on T010): `lib/features/invoicing/presentation/invoice_line_dialog.dart`, `showInvoiceLineDialog(context, document, line)`.
  - Fields: Cantidad (> 0, 4 decimals), Precio unitario (≥ 0), Descuento % (0–100, sent as `percent / 100`), IVA (16 % / 0 % / Exento), Clave interna (≤ 35), Descripción (blank resets to the product's name; show that helper), Comentario. Editable fields use the editable-field formatting that round-trips, with no currency symbol.
  - Closing with an edited field asks first, with `confirmDiscardChanges` (`lib/core/widgets/app_side_sheet.dart`), as T030 does.
  - Send only changed fields. `quantity_exceeds_invoiceable` stays inline with the `remaining` message; any other refusal closes the dialog and shows above the action area.

- [X] T029 [US4] Create `lib/features/invoicing/presentation/invoice_action_dialogs.dart` with the remove-line confirmation (C8: "¿Quitar esta partida de la factura?", Quitar as the confirm button, busy flag, refusal handling as in `delivery_order_dialogs.dart`). T036 and T039 add to this file.

- [X] T030 [US4] Create the header dialog (C7, research R8, depends on T010, T027): `lib/features/invoicing/presentation/invoice_header_dialog.dart`, `showInvoiceHeaderDialog(context, document)` returning whether it saved.
  - Receptor: dropdown of the customer's taxpayers; absent when `customerId` is null (a legacy draft). Serie: dropdown of the issuer's invoice series from `TaxpayerBatchRepository` (needs Taxpayers read; without it the field is absent), read-only with its helper once `serial != null`. Uso CFDI: `CatalogEntityPicker<SatCatalogItem>` over `listCfdiUsages`. Método de pago: segmented PUE / PPD. Forma de pago: dropdown over `PaymentMethod` without `governmentFunding`, disabled and showing 99 while PPD is selected. Fecha de emisión: date-time picker, empty meaning "al confirmar", with the 72-hour helper and an inline error plus a disabled Guardar outside the window or in the future. Sucursal: facility picker, only with 103 update or an administrator. Referencia (≤ 25) and Notas (≤ 1000).
  - Send only changed fields as `InvoiceHeaderPatch`. Use the shared form grid. Closing with an edited field asks first, with `confirmDiscardChanges` (`lib/core/widgets/app_side_sheet.dart`).

- [X] T031 [US4] Create the add-product dialog (C11, depends on T010): `lib/features/invoicing/presentation/add_product_dialog.dart` with a `CatalogEntityPicker<ProductListItem>` (as in `customer_discount_dialog.dart`); picking calls `addProduct`. `product_unpriced` stays inline with its message.

- [X] T032 [US4] Wire the edit controls into the detail screen (depends on T024, T028, T029, T030, T031): in `fiscal_document_detail_screen.dart`, when `canEdit`: line rows get ✎ (opens the line dialog) and 🗑 (opens the remove confirmation) via `buildCatalogRowActions`; the header section gets **Editar encabezado**; the lines section gets **Agregar producto** when the user also holds StandaloneFiscalDocuments (56) create. A document that isn't an editable draft has none of these in the tree.

- [X] T033 [P] [US4] Create `test/widget/features/invoicing/invoice_line_dialog_test.dart`: the fields fill from the line; quantity ≤ 0 and negative price are refused inline; a discount of 10 sends `0.1`; Exento sends `-1`; a blank description is sent blank; only changed fields are sent; closing after an edit asks before discarding, and closing untouched doesn't; and `quantity_exceeds_invoiceable` stays open with the remaining quantity in the message.

- [X] T034 [P] [US4] Create `test/widget/features/invoicing/invoice_header_dialog_test.dart`: choosing PPD disables the form and shows 99; the series is read-only when a serial exists; Sucursal is absent without 103 update and present for an administrator; a date in the future or older than 72 hours disables Guardar; only changed fields are sent; closing after an edit asks before discarding; and a refusal shows through `ErrorBanner`.

- [X] T035 [P] [US4] Extend `fiscal_document_detail_screen_test.dart` and add `test/widget/features/invoicing/add_product_dialog_test.dart`: the edit controls show only for an editable draft with 23 update; Agregar producto is absent without 56 create; the remove-line confirmation calls `removeLine`; the picker adds a product and `product_unpriced` stays inline; and an issued document, a sealed one and a credit note have no edit controls.

**Checkpoint**: a draft can be fully corrected.

---

## Phase 7: User Story 5 — Confirm (seal) and reopen (Priority: P2)

**Goal**: seal a valid draft, and reopen a sealed one without losing its folio.

**Independent Test**: confirm a valid draft and check the folio, the Sealed state and no edit controls; reopen it and check it is a draft with the same folio; confirm a draft with no lines and check the reason.

- [X] T036 [US5] Add the confirm and reopen dialogs (C13, depends on T029): in `invoice_action_dialogs.dart`, `showConfirmInvoiceDialog` (body names the series, says a folio will be used and that the invoice can only be reopened while not stamped) and `showReopenInvoiceDialog` (body names the folio and says the seal is discarded), each with a busy flag. Refusals close the dialog and are shown above the action area; the dialogs return the `AppError?` as `delivery_order_dialogs.dart` does.

- [X] T037 [US5] Wire confirm and reopen into the detail screen (depends on T032, T036): in `fiscal_document_detail_screen.dart`, an editable draft with 23 update gets **Confirmar** (`FilledButton`, after any secondary actions), and a sealed invoice (`canReopen`) with 23 update gets **Reabrir** (`OutlinedButton`). Success shows the C13 snackbars. The sealed banner stays. Keep `AppError? _actionError` above the action area, and clear it when the next action starts.

- [X] T038 [P] [US5] Create `test/widget/features/invoicing/invoice_action_dialogs_test.dart` and extend the detail screen test: Confirmar shows only on an editable draft with 23 update; its dialog names the series and calls `confirm`; each confirm-validation refusal (`no_lines`, `line_missing_sat_key`, `recipient_incomplete`, `issue_date_out_of_range`, `no_valid_certificate`, `quantity_exceeds_invoiceable`) shows its own localized message and the document stays a draft; Reabrir shows only on a sealed invoice; its dialog names the folio and calls `reopen`; a user with 23 read but not update sees neither; and the busy flag blocks a double press.

**Checkpoint**: the whole draft-to-sealed flow works.

---

## Phase 8: User Story 6 — Relate an invoice to earlier CFDIs (Priority: P3)

**Goal**: add and remove related documents of one relation type (04 or 07) on a draft.

**Independent Test**: on a draft, add a cancelled stamped invoice of the same issuer and recipient as a 04 relation, then check a 07 can't be added while the 04 exists. Remove the relation.

- [X] T039 [US6] Add the relation dialogs (C12, depends on T029): `lib/features/invoicing/presentation/add_relation_dialog.dart` with Tipo (04 Sustitución / 07 Aplicación de anticipo, locked to `document.relationType` when one exists) and a paged document picker over `fiscalDocumentRepositoryProvider.list` (`status: cancelled` for 04, `issued` for 07, search prefilled with the recipient's RFC, rows showing folio, date, UUID and total). `relation_not_allowed`, `already_related` and `relation_types_mixed` stay inline. Add the remove-relation confirmation to `invoice_action_dialogs.dart`.

- [X] T040 [US6] Wire relations into the detail screen (depends on T037, T039): in `fiscal_document_detail_screen.dart`, the Documentos relacionados section shows on an editable draft even when empty, with **Agregar relación**, and each relation row gets 🗑 (the remove confirmation), only with 23 update. On any other document the section is read-only and shows only when there are relations.

- [X] T041 [P] [US6] Create `test/widget/features/invoicing/add_relation_dialog_test.dart`: the type locks to the existing one; the picker queries `cancelled` for 04 and `issued` for 07 with the recipient RFC prefilled; picking calls `addRelation` with the right type; the three refusals stay inline; the remove confirmation calls `removeRelation`; and the section is read-only without 23 update and on a non-draft.

**Checkpoint**: all six stories work.

---

## Phase 9: Polish & Cross-Cutting

- [X] T042 Create the live test `test/integration/fiscal_documents_live_test.dart` (written at repository level with a real Dio, like the other `*_live_test.dart` files, so it needs no device; this replaces the planned `integration_test/…quickstart_test.dart` that would drive the macOS app; see quickstart.md). **Read-only run passed 2026-11-16 (8/8, legacy invoice GR4776). Write run passed 2026-11-16 (11 passed, relations skipped: no candidate; sealed A5232, server total = estimate).**
  - Read-only by default: the list opens; search by a legacy folio, then UUID, then recipient RFC; each filter narrows; an issued document's detail loads, its Total equals the list's, the PDF starts with `%PDF-`, and the XML bytes equal `GET /xml`.
  - With `MBE_WRITE=true`: discover a customer with taxpayers and a completed order; create an invoice; set the issue date to an hour ago and read it back (the round trip); add the order, add it again (no duplicate); edit a line (quantity above remaining is refused, a discount and Exento change the estimate); add a manual product; switch to PPD; confirm an empty draft (refused); confirm the real draft and **assert the server's total equals the client's estimate** (research R11); reopen and check the folio is kept; add and remove a relation if a candidate exists. Skip sealing with a printed reason on `no_valid_certificate`. If no issued document exists, fail the read-only PDF and XML checks with a message saying so; never skip them silently.
  - Discover its fixtures at run time (see the memory note on live-backend tests). Writes consume a folio, so run them only on the dev tenant.

- [ ] T043 Run the manual checks in `quickstart.md` that automation can't prove: step 1 (`qanoaccess` has no entry and the URL is refused), step 3 (kind names in the list and on the issuer's Series section), step 5 (a cancelled document's PDF mark; a pre-4.0 document, if the tenant has one), step 12 (a read-only user; give a test account right 23 read without update first), step 13 (the compact tier) and step 14 (the largest text size). File one tracking issue for the checks left open, as earlier specs did, and record the results in the PR description, saying plainly which checks were not run. **Not run; tracked in mbe-ui#256.**

- [X] T044 Final checks: `flutter analyze` is clean; `dart format` on only the files changed in this feature; the full `flutter test test/unit test/widget` passes apart from the known golden failures (mbe-ui#209); `catalog_coverage_test` passes at its new count. Check by search that no new `NumberFormat`, `toStringAsFixed`, `double` amount or quantity, `enum.name` label or hard-coded spacing literal slipped in, and that no file under `lib/generated/` was edited.

- [X] T045 Write `specs/066-invoice-list-editor/pr-description.md` with a Roadmap section ("Closes mictlanix/mbe-roadmap#48" and "Closes mictlanix/mbe-roadmap#49"). Call out: stamping is pending (roadmap#46), so invoices made here stop at sealed and PDF and XML only work for legacy-issued documents; the draft total is a client estimate that the live test compares with the server; the spec 065 kind-name correction and its visible effect on the Series section; the order picker listing fully invoiced orders; and the §VI document reading. End it with the attribution line the session's reminder gives.

---

## Dependencies and execution order

```text
T001 ─▶ T002 ─▶ T003 ─▶ T004
T005 ─┬─▶ T006 ─┬─▶ T008 (also T007)
      │         ├─▶ T009
      │         └─▶ T010
      ├─▶ T007
      └─▶ T011 (also T003)

T008 + T011 ─▶ T012 ─▶ T013 ─▶ T014, T015                      (US1)
T016, T017, T018 ─▶ T019 (also T009, T011) ─▶ T020 ─▶ T021     (US2)
T010 + T012 ─▶ T022 ─▶ T025                                     (US3)
T010 ─▶ T023 ─▶ T026;  T019 + T023 ─▶ T024
T027 ─▶ T030;  T010 ─▶ T028, T031;  T029
T024 + T028 + T029 + T030 + T031 ─▶ T032 ─▶ T033, T034, T035    (US4)
T029 ─▶ T036 ─▶ T037 (also T032) ─▶ T038                        (US5)
T029 ─▶ T039 ─▶ T040 (also T037) ─▶ T041                        (US6)
all stories ─▶ T042 ─▶ T043 ─▶ T044 ─▶ T045
```

- **US1** needs T002 to T011. **US2** needs the US1 list (T012) only for the row tap, and otherwise T009, T011 and T016 to T018. **US3 to US6** each need the US2 detail screen (T019) and edit it one story at a time.
- **Parallel:**
  - In Phase 2: T004, T005, T007 and T011 touch separate files and can run beside each other once their inputs exist. T006 follows T005.
  - In US2: T016, T017 and T018 are independent of each other and of T019's early work.
  - In US3: T025 and T026 run beside each other after their dialogs exist.
  - In US4: T027, T028 and T031 are independent; T033, T034 and T035 run beside each other after T032.
  - Test tasks marked [P] can start as soon as their code compiles.

## Implementation strategy

- **MVP**: Phases 1–5 (T001–T026). That delivers the viewer for every legacy invoice, with its PDF and XML, plus starting an invoice from a sales order.
- **Then**, in priority order: US4 (edit a draft), US5 (confirm and reopen), and US6 (relations). Each is demoable alone, and none changes US1 to US3.
- **Order of risk:**
  - T002 renames an enum used by spec 065's Series section, so run the spec 065 tests right after it.
  - T013 and T020 change the router and navigation, so run those tests right after each.
  - T016 touches `core/documents`, which every printing screen uses, so run `test/unit/core/documents/` right after it.
  - T004 changes the error catalog, so run `test/unit/core/errors/` right after it.
  - T005's amounts mirror is the one place the client does arithmetic on money. Fix its expected values by hand before the implementation exists, and keep the live comparison in T042.

## Task count

45 tasks:

| Phase | Tasks |
|---|---|
| Setup | 1 |
| Foundational | 10 (T002–T011) |
| US1 | 4 (T012–T015) |
| US2 | 6 (T016–T021) |
| US3 | 5 (T022–T026) |
| US4 | 9 (T027–T035) |
| US5 | 3 (T036–T038) |
| US6 | 3 (T039–T041) |
| Polish | 4 (T042–T045) |
