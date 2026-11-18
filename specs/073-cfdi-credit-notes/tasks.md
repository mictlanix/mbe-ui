---
description: "Task list for 073-cfdi-credit-notes"
---

# Tasks: CFDI Credit Notes

**Input**: Design documents from `specs/073-cfdi-credit-notes/`

**Prerequisites**: plan.md, spec.md, research.md (R1–R13), data-model.md, contracts/ui-contracts.md (C25–C33), wireframes.md, quickstart.md

**Tests**: The spec doesn't ask for a test suite as such, but the constitution's quality gates and research R13 require tests. Test tasks sit inside each story, after the code they cover.

**Organization**: Grouped by user story (US1–US4, spec.md). US1, US2 and US3 are P1 and together are the MVP: start a credit note, fill it, seal and stamp it. US4 (relation link) is P2. Phase 2 holds what two or more stories share.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: parallelizable (different files, no dependency on an incomplete task)
- **[Story]**: US1 start from an invoice · US2 fill with lines · US3 header, seal, stamp · US4 navigate to the invoice

## Cross-story notes

- **Specs 066 and 072 are the base.** Everything is in `lib/features/invoicing` (paths are relative to the repo root). Mirror what 072 did for stamp: `showStampFiscalDocumentDialog` in `presentation/invoice_action_dialogs.dart`, `stamp` in `presentation/fiscal_document_actions.dart`, `_stamp` in `presentation/fiscal_document_detail_screen.dart`.
- **Generated client.** The operations are `createCreditNoteApiV1FiscalDocumentsCreditNotesPost` (body `CreditNoteCreate {invoice}`) and `copyInvoiceLineApiV1FiscalDocumentsFiscalDocumentIdInvoiceLinesPost` (body `InvoiceLineCopy {line, quantity}`), both in `lib/generated/openapi/lib/src/api/fiscal_documents_api.dart`. Do not confuse the second with `addInvoiceLine…LinesPost`, which is the manual product. No client regeneration is needed.
- **Type codes.** `typeCode == 100` is a credit note; `0` is an invoice. Relation type 01 is `InvoiceRelationType.creditNoteOf`.
- **Shared files.** Do these sequentially, not in parallel:
  - `lib/features/invoicing/presentation/fiscal_document_detail_screen.dart`: T009 (US1), T013 (US2), T018, T019 (US3), T023 (US4) each add to it. Every control is a nullable callback or a condition, so an absent right or state means the control is not in the tree.
  - `lib/features/invoicing/presentation/invoice_action_dialogs.dart`: T008 (US1) only.
  - `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb`: T002 adds every key once. If a later task needs another, add it there and run `flutter gen-l10n`. Never hand-edit `lib/l10n/app_localizations*.dart`.
- **Generated code.** After editing a freezed or `riverpod` file, run `dart run build_runner build --delete-conflicting-outputs` at the repo root, then revert `delivery_orders_filter.freezed.dart` if it changed (stale committed file). Never run two build_runner processes at once.
- **Formatting.** Format only the files you changed (`dart format <files>`). Never `dart format .`, and never format `lib/generated/`.
- **Dates and amounts** go through `formattersProvider` (§V). Spacing comes from `Theme.of(context).spacing`, colours from `ColorScheme`. No hex values.
- **Never match server prose** (§III). Refusals are shown through `FiscalDocumentRefusal` / `AppError.localizedMessage`, built from the error's `code` and `params`. Recognition keys on the code.
- **Never compute the remaining-to-credit amount** client-side (research R6). It comes only from the `credit_exceeds_invoice` refusal.
- **Rights.** Create needs 23 create; edits need 23 update; a manual product needs 56 create. A missing right means the control is absent, never disabled.
- **Simplifications.** Any shortcut carries a comment `// simplified: <ceiling>, <what to do when it binds>`.
- **Companion hooks are not used** for this spec (plain speckit).

---

## Phase 1: Setup

**Purpose**: a known-good baseline, so later failures are attributable.

- [X] T001 Run `flutter analyze` and the tests this feature touches: `test/unit/features/invoicing`, `test/widget/features/invoicing`, `test/unit/core/errors`. Note any failure that exists before this work. The failures in `test/golden/core_widgets_golden_test.dart` are already known (mbe-ui#209).

---

## Phase 2: Foundational (blocks all user stories)

**Purpose**: strings, entity gates, repository, actions and error codes, which every story uses.

- [X] T002 Add every new string to **both** `lib/l10n/app_es.arb` and `lib/l10n/app_en.arb` (with `description` entries like the neighbours, `"spec 073: <key>"`), then run `flutter gen-l10n`. Keys, by group:
  - **Create**: `fiscalDocumentIssueCreditNoteAction` ("Emitir nota de crédito" / "Issue credit note"), `fiscalDocumentIssueCreditNoteTitle`, `fiscalDocumentIssueCreditNoteBody` (with `{folio}` and `{recipient}`, C26), `fiscalDocumentIssueCreditNoteCreate` ("Crear" / "Create").
  - **Copy dialog**: `fiscalDocumentCopyInvoiceLinesAction` ("Agregar de la factura"), `fiscalDocumentCopyInvoiceLinesTitle` (with `{folio}`), intro text, `fiscalDocumentCopyInvoiceLinesSubmit` ("Agregar ({count})"), `fiscalDocumentCopyInvoiceLinesEmpty`, `fiscalDocumentCopyInvoiceLineMax` ("Máximo {max} (la cantidad facturada)"), `fiscalDocumentCopyInvoiceLineQtyPositive` ("Debe ser mayor que 0"), `fiscalDocumentCopyInvoiceLineAdded` ("Agregada"), `fiscalDocumentCopyInvoiceLineFailed` ("Partida {code}: {message}"), `fiscalDocumentCopyInvoiceLinesDone` (plural, "{count} partidas agregadas"), `fiscalDocumentInvoiceQuantity` ("Cant. factura").
  - **Banner** (C30): `fiscalDocumentBannerCreditNoteForm`.
  - **Header dialog**: `fiscalDocumentHeaderTermsFixedPue` ("PUE (fijo en notas de crédito)").
  - **Refusal** (C32): `fiscalDocumentCreditExceedsInvoice` (with `{folio}` and `{remaining}`).
  - **Errors**: `apiErrorFiscalDocumentInvoiceNotCreditable`, `apiErrorFiscalDocumentCreditExceedsInvoice` (with `{remaining}`), `apiErrorFiscalDocumentCreditQuantityExceedsLine` (with `{max}`), `apiErrorFiscalDocumentPaymentFormRequired`, with the texts in research R11. Reword `apiErrorFiscalDocumentNotDraft` and `apiErrorFiscalDocumentNoLines` to "este documento" / "El documento" (research R11), in both languages.
  - **Invoice-worded texts that credit notes also show** (research R11, U1): reword to neutral "documento" wording in both languages `fiscalDocumentLinesEmpty` ("El documento no tiene partidas."), `fiscalDocumentRemoveLineBody` ("¿Quitar esta partida del documento?"), `fiscalDocumentConfirmTitle` ("Confirmar documento"), `fiscalDocumentConfirmBody` ("…y se sellará el documento…"), `fiscalDocumentConfirmed` ("{kind} {folio} sellada." → add a `{kind}` placeholder, passing `fiscalDocumentKindLabel`), `fiscalDocumentReopenTitle` ("Reabrir documento"), `fiscalDocumentReopenBody` ("El documento vuelve a borrador…"), `fiscalDocumentReopened` (with `{kind}`, as `Confirmed`). Update their call sites in `invoice_action_dialogs.dart` and `fiscal_document_detail_screen.dart` for the new placeholders, and any existing invoicing test that asserts the old Spanish text (`grep -rn "Confirmar factura\|Reabrir factura\|sellada\.\|reabierta\." test/`).
  - Every English text is its own translation, not a copy.
- [X] T003 [P] Edit `lib/features/invoicing/domain/entities/fiscal_document.dart` (data-model.md). Add getters to `FiscalDocument`: `isCreditNote` (`summary.typeCode == 100`), `canIssueCreditNote` (`isInvoice && status == issued`), `creditedInvoice` (the first relation whose `type == InvoiceRelationType.creditNoteOf`, only when `isCreditNote`, else null) and `needsPaymentForm` (`isCreditNote && status == draft && paymentForm == 99`; use `PaymentMethod.toBeDefined.code` rather than a literal). Widen `isEditableDraft` and `canReopen` from `isInvoice` to `(isInvoice || (isCreditNote && creditedInvoice != null))`: a credit note with no related invoice (legacy) stays read-only in every state (research R8, spec FR-015). No build_runner is needed (getters only).
- [X] T004 Edit `lib/features/invoicing/domain/repositories/fiscal_document_repository.dart` and `lib/features/invoicing/data/fiscal_document_repository_impl.dart` (depends on T003). Add `Future<FiscalDocument> createCreditNote(int invoiceId)` and `Future<FiscalDocument> copyInvoiceLine(int id, int invoiceLineId, {required Decimal quantity})` to the interface and implementation, each through `_document(...)` like `confirm`. Build `CreditNoteCreate` (`invoice`) and `InvoiceLineCopy` (`line`, `quantity` as the decimal string). Check how the existing `updateLine` sends a decimal quantity and do the same.
- [X] T005 Edit `lib/features/invoicing/presentation/fiscal_document_actions.dart` (depends on T004). Add `Future<({AppError? error, int? id})> createCreditNote(int invoiceId)`, modelled on `create`, and `Future<({int added, AppError? error, int? failedLineId})> copyInvoiceLines(int id, List<({int lineId, Decimal quantity})> lines)` (research R1, R12). It sends the lines one at a time in the given order, stops at the first refusal and returns how many were added and which line failed, and invalidates the detail **once** at the end (and the list only on success, as `create` does). Run build_runner.
- [X] T006 [P] Localize the four new error codes (research R11). In `lib/core/errors/localize_problem.dart` add `fiscalDocumentPeriodInvoiceNotCreditable`, `fiscalDocumentPeriodCreditExceedsInvoice` (param `remaining`, via the same decimal-param helper the neighbours use), `fiscalDocumentPeriodCreditQuantityExceedsLine` (param `max`) and `fiscalDocumentPeriodPaymentFormRequired` to both `localizedErrorCodes` and the `switch`, using the T002 keys. In `specs/058-localized-api-errors/contracts/code-scope.tsv` flip those four rows from `OUT` to `IN`, with the routes `POST /fiscal-documents/credit-notes; POST /fiscal-documents/{}/invoice-lines; PUT /fiscal-documents/{}/lines/{}; POST /fiscal-documents/{}/confirm; PUT /fiscal-documents/{}` as the route column, matching the neighbouring rows' style and the reachable-from note "reachable from the Facturas screens (spec 073)". Add the new routes to the route column of `issuer_has_no_series`, `cancellation_open` and `field_not_for_type`. In `test/unit/core/errors/catalog_coverage_test.dart` change `checked` from 177 to 181, and add fixtures for the four codes (with their params) in `test/unit/core/errors/problem_fixtures.dart`.
- [X] T007 [P] Tests for the foundation. In `test/unit/features/invoicing/fiscal_document_fixtures.dart` add builders for a credit note (type 100, with one type-01 relation) and a form-99 credit-note draft. Add tests: (a) entity getters, a table over invoice and credit note by state and form (`isEditableDraft`, `canReopen`, `canIssueCreditNote`, `creditedInvoice`, `needsPaymentForm`), in a new `test/unit/features/invoicing/fiscal_document_credit_note_test.dart`, including a credit-note draft **with no relation**, which is not editable and not reopenable when sealed; (b) `fiscal_document_repository_impl_test.dart`: `createCreditNote` and `copyInvoiceLine` call the right operations with the right bodies, and a wire `FiscalDocumentResponse` of type 100 with a relation of type `01` maps to `InvoiceRelationType.creditNoteOf`, so `creditedInvoice` returns it (the mapping at `fiscal_document_repository_impl.dart` `_relation` derives the code from the enum name); (c) `fiscal_document_actions_test.dart`: `copyInvoiceLines` sends all lines in order and invalidates the detail once; the second of three failing stops the run, reports `added == 1` and the failed line, and sends no third request; `createCreditNote` returns the id.

**Checkpoint**: `flutter analyze` is clean and the foundation tests pass. Nothing is visible yet.

---

## Phase 3: User Story 1 - Start a credit note from an invoice (Priority: P1) 🎯 MVP

**Goal**: an issued invoice offers "Emitir nota de crédito", which creates a draft and opens it.

**Independent Test**: quickstart steps 1–2b. Open an issued invoice, issue a credit note, and a draft credit note opens with the invoice's parties, PUE, and a 01 relation.

- [X] T008 [US1] Add `showIssueCreditNoteDialog(BuildContext, FiscalDocument invoice)` to `lib/features/invoicing/presentation/invoice_action_dialogs.dart`, per C26, modelled on `showStampFiscalDocumentDialog`. It returns the new document id, or null when dismissed. Keys: `issue_credit_note_dialog`, `issue_credit_note_cancel`, `issue_credit_note_create`, `issue_credit_note_refusal`. Body text uses the invoice's folio and recipient. While the request runs both buttons are disabled (FR-018). A refusal stays in the dialog as a `FormErrorBanner`, built from `AppError.localizedMessage`. Success pops the id.
- [X] T009 [US1] Edit `lib/features/invoicing/presentation/fiscal_document_detail_screen.dart` (depends on T008). Compute `canIssueCreditNote = document.canIssueCreditNote && access.can(SystemObject.fiscalDocuments, AccessRight.create)`. Add the `OutlinedButton` keyed `fiscal_document_issue_credit_note` as the **last** entry of the action row (C25), and include `canIssueCreditNote` in the condition that decides whether the row exists. Its handler calls `showIssueCreditNoteDialog` and, when it returns an id, `context.push('$fiscalDocumentsPath/$id')`. While `_refreshing` it is disabled, like the neighbours.
- [X] T010 [P] [US1] Widget test `test/widget/features/invoicing/invoice_action_dialogs_test.dart` (extend): the dialog shows the folio, Crear calls the repository and pops the new id; a `issuer_has_no_series` refusal stays open with the localized text; both buttons are disabled while the request runs; cancel pops null and sends nothing.
- [X] T011 [US1] Widget test `test/widget/features/invoicing/fiscal_document_detail_screen_test.dart` (extend; depends on T009): the action is present only for an issued **invoice** with 23 create, and absent for draft, sealed, stamping, cancellation pending and cancelled invoices, for a credit note, for 23 update without create, and for a read-only user (spec US1 scenarios 2, 3, 5; FR-017). Tapping it and confirming navigates to the new document's path. While a refresh is running the button is disabled (FR-018).

**Checkpoint**: an issued invoice can start a credit note, and the draft opens (the draft's editor is US2 and US3).

---

## Phase 4: User Story 2 - Fill a credit note with lines (Priority: P1) 🎯 MVP

**Goal**: on the draft, copy invoice lines (several at once, each at its quantity or less), add a product by hand, edit and remove lines.

**Independent Test**: quickstart steps 4–6. Copy two lines (one above its quantity is refused client-side), add a "Descuento" product, edit a quantity above the invoice's, and the lines and totals update after each step.

- [X] T012 [US2] Create `lib/features/invoicing/presentation/copy_invoice_lines_dialog.dart` with `Future<int> showCopyInvoiceLinesDialog(BuildContext, FiscalDocument creditNote)` per C29 (it returns how many lines were added; 0 when nothing was), modelled on `add_sales_order_dialog.dart`. It loads the invoice with `fiscalDocumentDetailProvider(creditNote.creditedInvoice!.documentId)` and shows `ListStateViews` for loading and error-with-retry, and `copy_invoice_lines_empty` when the invoice has no lines. Each row (`copy_invoice_line_<lineId>`) has a checkbox (`copy_invoice_line_check_<lineId>`), the code, description, invoice quantity, price, discount and tax (formatted through `formattersProvider`), and a `CompactField` (`copy_invoice_line_qty_<lineId>`), enabled only when checked and defaulting to the invoice quantity. Validation: 0 < q ≤ the invoice quantity, with the T002 texts under the field; invalid fields block submit. Submit (`copy_invoice_lines_submit`, "Agregar (n)") calls `copyInvoiceLines` with the checked lines in the invoice's line order. All succeed → pop the count. Closing after a partial run pops the count added so far. A refusal → stay open, mark the lines already added as unchecked, disabled and "Agregada", and show a `FormErrorBanner` (`copy_invoice_lines_refusal`) "Partida {code}: {message}" (research R1). Compact: full-screen `ResponsiveDialog`, rows as two-line cards with the quantity field only on checked rows (wireframes.md). A row's `Key` ids use the invoice line's `id`.
- [X] T013 [US2] Edit `lib/features/invoicing/presentation/fiscal_document_detail_screen.dart` (depends on T012). For a credit note (C27):
  - `canAddOrder` is false; the lines toolbar shows `fiscal_document_copy_invoice_lines` ("Agregar de la factura", outlined, `Icons.add`, calls the dialog; when the dialog returns a count above 0 it shows the SnackBar `fiscalDocumentCopyInvoiceLinesDone` with that count) when `canEdit`. The button is only shown when `document.creditedInvoice != null`, which `isEditableDraft` already guarantees (T003). `canAddProduct` keeps its 56-create rule.
  - `_LinesSection` gets `onCopyInvoiceLines`; `orderMarker` is not shown when `document.isCreditNote` (research R3), in both the compact and the table layout.
  - `_RelationsSection` is shown whenever `hasRelations`; for a credit note its `onAdd` and `onRemove` are null (FR-007).
- [X] T014 [US2] Edit `lib/features/invoicing/presentation/invoice_line_dialog.dart` so that a `credit_quantity_exceeds_line` refusal keeps the dialog open and shows the localized text with its `max`, exactly as `quantity_exceeds_invoiceable` does today (research R10, C32). Do not add a client-side check for this rule.
- [X] T015 [P] [US2] Widget test `test/widget/features/invoicing/copy_invoice_lines_dialog_test.dart` (new): rows render from the invoice; checking a row enables its field at the invoice quantity; a quantity above the invoice's or ≤ 0 shows the inline text and disables submit; submit with two checked lines sends two requests in order and pops; a refusal on the second keeps the dialog open with the first marked "Agregada" and the refusal naming the failed line; invoice load error shows retry; an invoice with no lines shows the empty text; the compact layout renders cards. **Alignment (constitution §VI)**: the row's checkbox, its text cells and the quantity field form a control band, so assert with real geometry (`tester.getRect` / `getTopLeft`, as other §VI tests in the repo do) that the vertical padding above and below the band is equal and that the checkbox label text and the quantity field's text share a baseline, at the regular tier.
- [X] T016 [US2] Widget test `test/widget/features/invoicing/fiscal_document_edit_controls_test.dart` (extend; depends on T013, T014): for a draft credit note with 23 update, "Agregar de la factura" is present and "Agregar pedido" is not; "Agregar producto" only with 56 create; no relation add or remove controls; no "Pedido" chip on a line that has an order line; edit and remove line controls are present; a read-only user sees none of them; an invoice draft is unchanged (still has "Agregar pedido", the chip and relation editing). In `invoice_line_dialog_test.dart` (extend): a `credit_quantity_exceeds_line` refusal keeps the dialog open with the maximum.

**Checkpoint**: a credit-note draft can be filled and its lines edited; totals follow.

---

## Phase 5: User Story 3 - Header, seal and stamp (Priority: P1) 🎯 MVP

**Goal**: the header edits only the credit-note fields, confirm and reopen work, a form of 99 is flagged, an over-limit total names the invoice, and stamping works as in 072.

**Independent Test**: quickstart steps 3 and 7–10. A form-99 draft shows the banner and the header dialog offers no 99; confirming an over-limit total is refused naming the invoice; a valid one seals; reopen keeps the folio; stamp issues it.

- [X] T017 [US3] Edit `lib/features/invoicing/presentation/invoice_header_dialog.dart` for credit-note mode (research R9, C31), branching on `_doc.isCreditNote`. Hide recipient, series, terms (and the PPD form box) and facility. Keep usage, payment form, issue date, reference and notes. Show a read-only line `fiscalDocumentHeaderTermsFixedPue`. The payment-form list excludes 99, and its initial value is null when the stored form is 99 (a `DropdownButtonFormField` asserts otherwise). Guardar stays disabled until a form is chosen. The patch sets only `usage`, `paymentForm`, `issued`, `reference` and `comment`. Terms are never sent for a credit note, so `_formNeeded` must not depend on `_terms` here: for a credit note the form is always needed.
- [X] T018 [US3] Edit `lib/features/invoicing/presentation/fiscal_document_detail_screen.dart` (depends on T003, T017). In `_StatusBanner`: (a) for a credit-note draft with `needsPaymentForm` and 23 update, show the `credit_note_form` banner (key `fiscal_document_banner_credit_note_form`, tertiary colours, `Icons.info_outline`, C30), placed before the `read_only_kind` branch; (b) the `read_only_kind` branch must not apply to an editable kind (`document.isEditableKind`: an invoice, or a credit note that relates its invoice); a legacy credit note with no relation keeps the banner, as in 066; (c) a sealed credit note uses the "stamp or reopen" text, since it can be reopened (research R7). In the header facts, show terms as PUE for a credit note (it already comes from `paymentTerms`; check that and only change it if it doesn't read PUE).
- [X] T019 [US3] Edit `lib/features/invoicing/presentation/fiscal_document_detail_screen.dart` (depends on T018). Per C32, when the refused action is on a credit note and the error's `code` is `fiscal_document.credit_exceeds_invoice`, render `fiscalDocumentCreditExceedsInvoice(folio, remaining)` in `FiscalDocumentRefusal`, taking the folio from `document.creditedInvoice` (series + serial, else `#documentId`) and `remaining` from the problem's params formatted through `formattersProvider` as currency. Without a relation or without `remaining`, fall back to `error.localizedMessage`. Extend `FiscalDocumentRefusal` with an optional `message` override rather than reworking it, and keep the branch in the screen, keyed on the code (§III).
- [X] T020 [P] [US3] Widget test `test/widget/features/invoicing/invoice_header_dialog_test.dart` (extend): in credit-note mode only the five fields show and PUE is read-only; the form list has no 99; a stored form of 99 opens with nothing selected (no assertion) and Guardar is disabled until one is chosen; saving sends a patch with only the changed credit-note fields; the invoice dialog is unchanged.
- [X] T021 [US3] Widget test `test/widget/features/invoicing/fiscal_document_detail_screen_test.dart` (extend; depends on T018, T019): the form-99 banner shows for a credit-note draft with 23 update and not for a read-only user or for a draft with a real form; a draft credit note never shows the `read_only_kind` banner; a sealed credit note shows Reabrir and Timbrar and the "stamp or reopen" banner; a draft shows Confirmar; confirm refused with `credit_exceeds_invoice` shows the invoice's folio and the remaining amount (FR-012); confirm refused with `payment_form_required`, `no_lines` and `issue_date_out_of_range` shows each localized text; reopen returns to draft; stamping a credit note reaches issued with the simulated badge (072's flow, no credit-note-specific behaviour, FR-014); a read-only user sees no action; on a credit note the confirm and reopen dialogs and the empty-lines text use the neutral "documento" wording (U1).
- [X] T022 [P] [US3] Extend `test/integration/fiscal_documents_live_test.dart` per research R13: a credit-note group behind `MBE_WRITE=true` and `PAC_PROVIDER=simulated`, dev tenant only, **asking the user before it runs** (it consumes a credit-note folio and stamps a document). Steps: find an issued, live invoice; create a credit note; copy one line at quantity 1; set a real payment form when the stored one is 99; confirm; stamp and check issued; cancel with reason 02. Skip with a reason when the issuer has no credit-note series. Write it and run `flutter analyze` on it; run it only with the user's go-ahead.

**Checkpoint**: a credit note goes from an invoice to stamped (the MVP).

---

## Phase 6: User Story 4 - Navigate between a credit note and its invoice (Priority: P2)

**Goal**: every relation row links to its document, so a credit note opens its invoice (and 066's 04/07 relations gain the same link).

**Independent Test**: quickstart steps 11 and 14. From a credit note, open its invoice and Back returns; the list's type filter finds credit notes.

- [X] T023 [US4] Edit `_RelationsSection` in `lib/features/invoicing/presentation/fiscal_document_detail_screen.dart` (C28, research R4). Replace the plain folio `Text` with a link-styled `TextButton` keyed `fiscal_document_relation_link_<relationId>` (label as today: series + serial, or `#documentId`) whose handler is `context.push('$fiscalDocumentsPath/${r.documentId}')`. Use the theme's link styling and `VisualDensity.compact`; no raw colours. It applies to every document type.
- [X] T024 [US4] Widget test `test/widget/features/invoicing/fiscal_document_detail_screen_test.dart` (extend; depends on T023): the link is on every relation row of a credit note and of an invoice with a 04 relation; tapping it pushes the related document's path; a legacy credit note with no relation shows no relations section and, when not a draft, is read-only (US4 scenario 3, FR-015). In `test/widget/features/invoicing/fiscal_documents_list_screen_test.dart` (extend if it lacks one): the list's type facet already filters by type 100 and shows the credit-note label (no code change expected; add the test only if none covers it).

**Checkpoint**: the invoice and its credit notes are one tap apart.

---

## Phase 7: Polish & Cross-Cutting Concerns

- [X] T025 Run the full gate: `flutter analyze` (clean), `dart format` on the changed files only, and `flutter test` for the whole suite. Compare against the T001 baseline: nothing new may fail.
- [ ] T026 (open: the manual walk is tracked in mbe-ui#281; the live test passed 8/8 on 2026-11-18) Walk `quickstart.md` steps 1–17 against dev (simulated PAC), including compact width (step 16) and the largest text scale (step 17), and English. Record any step that cannot be run. Anything left becomes a manual-checks issue like 072's (mbe-ui#278), which you create only after asking the user.
- [X] T027 Write `specs/073-cfdi-credit-notes/pr-description.md`. The Roadmap section reads `Closes mictlanix/mbe-roadmap#56`. Do not add `Part of` lines for #54 (payment receipts). Under "Follow-ups" list the two mbe-api candidates from research R6 and R8 (the invoice's remaining creditable amount, and the missing type guard in `remove_relation`) and say they are not filed. Note that the relation link also changes spec 066's invoice screen. Do not open the PR: the user does that.

---

## Dependencies & Execution Order

```text
Phase 1 (T001)
   └─▶ Phase 2:  T002 ─┐
                 T003 ─┼─▶ T004 ─▶ T005
                 T002 ─▶ T006
                 T005 ─▶ T007
Phase 2 ─▶ US1 (T008–T011) ─▶ US2 (T012–T016) ─▶ US3 (T017–T022)   ← MVP
        ─▶ US4 (T023–T024)  needs only Phase 2
Polish (T025–T027) after the stories you ship
```

- **US1** needs only Phase 2.
- **US2** needs US1 for a real draft to open (it can be built and unit-tested against fixtures before then).
- **US3** needs US2's detail edits (same file), but its header dialog (T017) and live test (T022) are independent of them.
- **US4** is independent apart from sharing the detail screen file, so do its edit after the other detail-screen tasks.

### Parallel opportunities

- T002 and T003 run in parallel (different files). T006 runs beside T004–T005. T007 runs once T005 is done.
- T010 beside T008–T009's screen work (different test files). T015 beside T013.
- T017 and T020 (the header dialog) can be done by one person while another does US2.
- T022 can be written at any time after T005.

## Implementation Strategy

1. **MVP = Phase 2 + US1 + US2 + US3.** After T022 a clerk can take an issued invoice to a stamped credit note against the simulator, and every refusal on the way reads in Spanish.
2. **US4 next.** It is small and also benefits 066's 04/07 relations. It can land before US3 if the rest slips.
3. **Live test last**, with the user's go-ahead. It writes to the dev tenant.
