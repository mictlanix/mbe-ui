---
description: "Task list for 065-taxpayer-batches"
---

# Tasks: Taxpayer Batches (Folio Series)

**Input**: Design documents from `specs/065-taxpayer-batches/`

**Prerequisites**: plan.md, spec.md, research.md (R1–R13), data-model.md, contracts/consumed-endpoints.md, contracts/ui-contract.md, quickstart.md, wireframes.md

**Tests**: The spec doesn't ask for a test suite as such, but the constitution's quality gates and research R13 require tests. Test tasks sit inside each story, after the code they cover.

**Organization**: Grouped by user story (US1–US4, spec.md). US1 (see an issuer's series, P1) is the MVP: it adds the section, the host wiring and the read-only dialog. US2 (add a series, P1) adds the dialog controller, the editable form, the bank-account editor and "Nuevo". US3 (edit, with the in-use lock, P2) adds the edit mode, the lock, the Editar toggle and the row Edit icon. US4 (delete, P3) adds Eliminar. Phase 2 holds everything the stories share: the domain types, the repository, the strings, the error messages and the list provider.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: parallelizable (different files, no dependency on an incomplete task)
- **[Story]**: US1 see the series · US2 add · US3 edit and lock · US4 delete

## Cross-story notes

- **Shared files.** Do these sequentially, not in parallel:
  - `lib/features/catalog/presentation/taxpayer_batch_dialog.dart`: T017 (US1) creates it with view mode only. T025 (US2) adds the create form and the account editor, T031 (US3) adds edit mode, the lock and the Editar toggle, and T037 (US4) adds Eliminar.
  - `lib/features/catalog/presentation/taxpayer_batch_dialog_controller.dart`: T023 (US2) creates it with create and validation, T030 (US3) adds edit, the lock and the in-use race, and T036 (US4) adds delete.
  - `lib/features/catalog/presentation/taxpayer_batches_section.dart`: T015 (US1) creates it, T026 (US2) adds "Nuevo", and T032 (US3) adds the row Edit icon.
  - `test/widget/features/catalog/taxpayer_batch_dialog_test.dart`: T020 (US1) creates it, then T029 (US2), T035 (US3) and T039 (US4) extend it.
  - `test/widget/features/catalog/taxpayer_batches_section_test.dart`: T019 (US1) creates it, then T028 (US2) and T034 (US3) extend it.
  - `test/unit/features/catalog/taxpayer_batch_dialog_controller_test.dart`: T027 (US2) creates it, then T033 (US3) and T038 (US4) extend it.
  - `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb`: every key is added once, in T006. If a later task needs another, add it there and run `flutter gen-l10n`. Never hand-edit `lib/l10n/app_localizations*.dart`.
- **Generated code.** T010 runs `build_runner` once, after the freezed and `@riverpod` declarations of Phase 2 exist. Run it again in T024 (new `@riverpod` and `@freezed`). No client regeneration is needed: all four batch methods already exist on `TaxpayerIssuersApi`:
  - `listTaxpayerBatchesApiV1TaxpayerIssuersRfcBatchesGet({rfc})` returns `Response<BuiltList<TaxpayerBatchResponse>>`.
  - `createTaxpayerBatchApiV1TaxpayerIssuersRfcBatchesPost({rfc, taxpayerBatchCreate})`.
  - `updateTaxpayerBatchApiV1TaxpayerIssuersRfcBatchesTaxpayerBatchIdPut({rfc, taxpayerBatchId, taxpayerBatchUpdate})`.
  - `deleteTaxpayerBatchApiV1TaxpayerIssuersRfcBatchesTaxpayerBatchIdDelete({rfc, taxpayerBatchId})`.
- **The response type is an int, the request type is an enum.** `TaxpayerBatchResponse.type` is `int`, while `TaxpayerBatchCreate/Update.type` is the generated `FiscalDocumentType` (`number0` … `number200`). The conversion lives only in the repository (research R4). Presentation never imports the generated enum.
- **Existing tests will break until T018.** `TaxpayerIssuerDetailScreen` in edit mode now reads the batch list provider, which calls the real repository. `taxpayer_issuer_detail_screen_test.dart` and `record_app_bar_actions_test.dart` render that screen, so they need a batch repository override. T018 does this.
- **Formatting.** Format only the files you changed (`dart format <files>`). Never `dart format .`, and never format `lib/generated/`.
- **Spacing tokens, not literals** (`Theme.of(context).spacing`). No automated guard catches a literal, so check it in review.
- **Never match server prose** (§III). Recognise refusals by `error.problem?.code`, and read params with `problem.stringParam('resource')`. Never compare `message` text.
- **Stale families.** A family provider keyed by `(rfc, existing)` holds a draft per series: keep the key stable (the series' `taxpayerBatchId` and RFC drive equality through freezed), and pump `SizedBox()` before a second `ProviderScope` in a widget test (memory: spec 052 traps).
- **Assumptions taken from wireframes.md.** The three open questions marked **→ spec** were not answered, so the tasks follow the wireframe assumptions:
  - "+ Nuevo" follows the screen-wide editable rule (the parent's `readOnly`, which includes `!canUpdate`), as Certificados does.
  - Height fields carry an "mm" suffix.
  - No "missing types" line.

  T041 amends spec.md to match. If any of these is decided differently, change T017, T025, T026 and T041 before implementing.
- **Mirror, don't copy blindly.** Closest precedents:
  - Section and list provider: `taxpayer_certificates_section.dart` and `taxpayer_certificates_controller.dart`.
  - Add, edit and delete dialog with a family controller: `customer_discount_dialog.dart` and `customer_discount_dialog_controller.dart` (field errors, 409, 404 and generic branches in `_fail`).
  - Row tap read-only, Editar toggle, delete confirmation: `RecordFormActions` and `RecordFormMode` in `lib/core/widgets/record_form_actions.dart`.
  - Error message wiring: `taxpayer_certificate.holder_mismatch` in `localize_problem.dart`, `problem_fixtures.dart` and `catalog_coverage_test.dart`.
  - Widget test: `test/widget/features/catalog/taxpayer_certificates_section_test.dart` (user fixtures with `Privilege(systemObject: SystemObject.taxpayers, rawValue: …)`).
  - Live test: `integration_test/customer_discounts_quickstart_test.dart`.

---

## Phase 1: Setup

- [X] T001 Record the baseline before touching anything. Run `flutter analyze`, then `flutter test test/unit/core/errors test/unit/features/catalog test/widget/features/catalog test/widget/features/record_app_bar_actions_test.dart`, and note any failure that already exists, so later runs can tell new breakage from old. No file changes.

---

## Phase 2: Foundational (blocks every story)

**Purpose**: the domain types, the repository, the strings, the error messages and the list provider that all four stories use.

- [X] T002 [P] Create `lib/features/catalog/domain/entities/fiscal_document_kind.dart`. It holds the enum `FiscalDocumentKind` with `invoice(0)`, `expense(1)`, `payment(2)`, `transfer(3)`, `creditNote(100)`, `paymentReceipt(101)` and `advancePaymentsApplied(200)`, in that order (declaration order is the sort order, research R5). Give it `final int code` and `static FiscalDocumentKind? fromCode(int code)`, which returns null for an unknown code (data-model.md).
- [X] T003 [P] Create `lib/features/catalog/domain/entities/taxpayer_batch.dart` with three freezed classes. Follow `taxpayer_certificate.dart` (`@freezed abstract class`, `fromResponse` factories):
  - `TaxpayerBatchAccount` has `bank`, `account`, `clabe` and `currency` (all `String`, null mapped to `''`) and a getter `isBlank` (all four empty after trim).
  - `TaxpayerBatchTemplate` has `name`, `logo` (`String?`), `headerHeight` (null mapped to 0), `footerHeight` (null mapped to 15) and `accounts` (`extraInfo ?? []`, in order). It maps from the generated `BatchTemplate`.
  - `TaxpayerBatch` has `taxpayerBatchId`, `taxpayer`, `series` (from `batch`), `typeCode` (the raw int), `kind` (`FiscalDocumentKind.fromCode(type)`), `template` and `inUse`. It maps from `TaxpayerBatchResponse`.
  - Also add a `TaxpayerBatchDraft` input class (`series`, `kind`, `template`), the input the repository takes for create and update.
- [X] T004 Create `lib/features/catalog/domain/repositories/taxpayer_batch_repository.dart`. The interface has `listForIssuer(String rfc)`, `create(String rfc, TaxpayerBatchDraft draft)`, `update(String rfc, int taxpayerBatchId, TaxpayerBatchDraft draft)` and `delete(String rfc, int taxpayerBatchId)`. Document that it is consumed only through the issuer detail's Series section, as `taxpayer_certificate_repository.dart` does.
- [X] T005 Create `lib/features/catalog/data/taxpayer_batch_repository_impl.dart`, with `taxpayerBatchRepositoryProvider` and a `TaxpayerBatchRepositoryImpl` that wraps `TaxpayerIssuersApi(_dio, appSerializers)`. Mirror `taxpayer_certificate_repository_impl.dart`, including its `_toAppError`.
  - `listForIssuer` calls the generated list and maps `response.data` (a `BuiltList`); a null body throws `AppError.server()`.
  - `create` and `update` build `TaxpayerBatchCreate/Update` with the nested `BatchTemplate` and `BatchAccount` builders. They map `FiscalDocumentKind.code` to `FiscalDocumentType` by wire number in one private helper, and send a blank logo as null.
  - `delete` returns void.
  - Pass the draft's accounts through unchanged: dropping blank accounts is the controller's job (T022), not the repository's.
- [X] T006 Add every string to both `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb`, then run `flutter gen-l10n` (never hand-edit `lib/l10n/app_localizations*.dart`). Each key needs an `@key` description. Add:
  - the section: title, title with a count, "Nuevo", the empty note, "En uso" tooltip and column labels (Serie, Tipo, Plantilla);
  - the dialog: titles (create, view, edit), field labels (Serie, Tipo de documento, Nombre de plantilla, Logo, Alto de encabezado (mm), Alto de pie (mm)), the lock note, "Cuentas bancarias", account field labels (Banco, Cuenta, CLABE, Moneda), "Agregar cuenta", the move up, move down and remove tooltips, "Sin cuentas bancarias", Cerrar, Cancelar, Guardar, Editar and Eliminar;
  - the delete confirmation: title, message with `{series}` and `{type}`, and confirm label;
  - client field errors: series required and too long, type required, template name required and too long, height invalid;
  - the seven kind labels `fiscalDocumentKindInvoice` … `fiscalDocumentKindAdvancePaymentsApplied` (Spanish: Factura, Egreso, Pago, Traslado, Nota de crédito, Recibo de pago, Aplicación de anticipos) and `fiscalDocumentKindUnknown({code})`;
  - the API messages: `apiErrorTaxpayerBatchInUseUpdate` ("La serie ya se usa en documentos emitidos; solo puede cambiar su plantilla."), `apiErrorTaxpayerBatchInUseDelete` ("La serie ya se usa en documentos emitidos y no se puede eliminar."), `apiValidationTaxpayerBatchSeriesBlank` ("La serie no puede quedar en blanco."), `apiResourceTaxpayerBatch` (plural form: serie/series, series) and `apiResourceGenderTaxpayerBatch` (`feminine` in es, `masculine` in en, as the existing keys do).
- [X] T007 Wire the error messages in `lib/core/errors/localize_problem.dart`. Follow `taxpayer_certificate.holder_mismatch`, `taxpayer_issuer.unknown` and `contact_name_blank`:
  - add `api.ErrorCode.taxpayerBatchPeriodInUse` to `localizedErrorCodes`, with an arm that reads `problem.stringParam('action')` and picks the update or delete message (an unknown or missing action falls back to the update text, never throws);
  - add `taxpayer_batch_series_blank` to `localizedValidationTypes` and an arm in `localizeValidationType`;
  - add `'taxpayer_batch'` to `resourceNoun` and `resourceGender`.
- [X] T008 Update the error-coverage bookkeeping (§III):
  - In `specs/058-localized-api-errors/contracts/code-scope.tsv`, flip `code taxpayer_batch.in_use` and `validation_type taxpayer_batch_series_blank` from OUT to IN (example routes `PUT /taxpayer-issuers/{}/batches/{}; DELETE /taxpayer-issuers/{}/batches/{}`), and add the resource rows `taxpayer_batch resource.already_exists IN` and `taxpayer_batch resource.not_found IN`.
  - In `test/unit/core/errors/catalog_coverage_test.dart`, change `expect(checked, 113)` to 114 and add `'taxpayer_batch.in_use'` to `needParams`.
  - In `test/unit/core/errors/problem_fixtures.dart`, add a fixture for `api.ErrorCode.taxpayerBatchPeriodInUse` with `{'action': 'update'}`.
- [X] T009 Create `lib/features/catalog/presentation/taxpayer_batches_controller.dart`, a `@riverpod` class `TaxpayerBatchesController` with `build(String rfc)`, modelled on `taxpayer_certificates_controller.dart`. It reads `taxpayerBatchRepositoryProvider`, then sorts client-side by `kind` position in the enum (unknown kinds last), then by series (research R5).
- [X] T010 Run `dart run build_runner build --delete-conflicting-outputs` for the new freezed and `@riverpod` files (T003, T009). Then run `flutter analyze` and fix what the new code introduced.
- [X] T011 [P] Write `test/unit/features/catalog/fiscal_document_kind_test.dart`. Check that all seven codes round-trip, that an unknown code (7, -1, 999) returns null, and that the enum order is the one data-model.md lists.
- [X] T012 [P] Write `test/unit/features/catalog/taxpayer_batch_test.dart`. Check the mapping from `TaxpayerBatchResponse`: a null header or footer height becomes 0 or 15, a null `extraInfo` becomes an empty list, accounts keep their order, an unknown type code gives `kind == null` with `typeCode` kept, `inUse` carries through, and `TaxpayerBatchAccount.isBlank` is true only when all four fields are blank.
- [X] T013 Write `test/unit/features/catalog/taxpayer_batch_repository_impl_test.dart` against a stubbed dio, following `taxpayer_certificate_repository_impl_test.dart`. Check the list mapping, the create and update request bodies (type as the wire number, blank logo as null, accounts in order), delete, and that a 409 `taxpayer_batch.in_use`, a 409 `resource.already_exists` and a 404 each surface as the right `AppError` with its `problem.code` intact.
- [X] T014 Extend the error tests for the new messages. In `test/unit/core/errors/resource_noun_test.dart`, check the noun and gender for `taxpayer_batch`. In `localize_validation_type_test.dart`, check `taxpayer_batch_series_blank`. In the matching `localize_problem_group_*` test, check that `taxpayer_batch.in_use` renders the update text for `action: update`, the delete text for `action: delete`, and a real message when the param is missing, in both languages. Then run `flutter test test/unit/core/errors` and confirm the coverage test passes at 114.

**Checkpoint**: the repository, the strings, the error messages and the sorted list provider exist and are tested. No UI yet.

---

## Phase 3: User Story 1 — See an issuer's series (P1) — MVP

**Goal**: the issuer detail screen lists the issuer's series, with every state, and a row opens read-only.

**Independent test**: open an issuer with series, and one without, in the dev tenant. Check rows, type labels, the lock, the empty note, the error with retry, and that a new, unsaved issuer shows no section (quickstart steps 1 and 9).

- [X] T015 [US1] Create `lib/features/catalog/presentation/taxpayer_batches_section.dart`: `TaxpayerBatchesSection({rfc, readOnly})`, following `taxpayer_certificates_section.dart` and `contracts/ui-contract.md`.
  - The header shows the title, with a count once loaded and non-empty. There is no "Nuevo" button yet.
  - Loading shows a centered spinner. An error shows `ListFailedView` with retry, which invalidates `taxpayerBatchesControllerProvider(rfc)`. Empty shows the muted note (key `taxpayer_batches_empty`).
  - Populated shows `DataTableView<TaxpayerBatch>` (key `taxpayer_batches_table`, `shrinkWrap`, `margin: EdgeInsets.zero`) with columns Serie, Tipo (the localized kind label, or `fiscalDocumentKindUnknown(typeCode)`), Plantilla (truncating, dropped on the compact tier via `LayoutBreakpoints.isCompact`) and En uso (a lock icon with a tooltip, empty otherwise). Put the label helper in this file.
  - A row tap opens `showTaxpayerBatchDialog` in view mode (T017). Don't add the row Edit icon yet.
- [X] T016 [US1] Host the section in `lib/features/catalog/presentation/taxpayer_issuer_detail_screen.dart`. Inside the existing `if (_isEdit)` block, after `TaxpayerCertificatesSection`, add a `Divider`, a `SizedBox(height: 16)` and `TaxpayerBatchesSection(rfc: widget.rfc!, readOnly: readOnly)`, inside the same width-capped column. Update the comment above the block, which today talks only about Certificates.
- [X] T017 [US1] Create `lib/features/catalog/presentation/taxpayer_batch_dialog.dart` with `showTaxpayerBatchDialog(context, {required String rfc, TaxpayerBatch? existing, bool startInEdit = false, required bool parentReadOnly})`, which opens a `ResponsiveDialog` (fullscreen on compact). In this task it renders view mode only:
  - The title is "Ver serie".
  - A `ResponsiveFormGrid` (at most 2 columns) shows the series, the localized type, the template name, the logo, and the header and footer heights with an "mm" suffix, all non-editable.
  - A "Cuentas bancarias" group lists each account on one line, or "Sin cuentas bancarias".
  - The primary action is "Cerrar".
  - Leave the structure ready for the editable modes (a private widget per mode is fine), and keep the lock note out until T031.
- [X] T018 [US1] Fix the existing tests that render the issuer detail screen in edit mode. In `test/widget/features/catalog/taxpayer_issuer_detail_screen_test.dart` and `test/widget/features/record_app_bar_actions_test.dart`, add a `MockTaxpayerBatchRepository` stubbed to return an empty list, and override `taxpayerBatchRepositoryProvider`, the way `taxpayerCertificateRepositoryProvider` is overridden there. Then run both files and confirm they pass unchanged otherwise.
- [X] T019 [P] [US1] Write `test/widget/features/catalog/taxpayer_batches_section_test.dart`, following `taxpayer_certificates_section_test.dart` (a `MockTaxpayerBatchRepository` and user fixtures with `Privilege(systemObject: SystemObject.taxpayers, rawValue: …)`). Cover:
  - loading, empty (note shown), and error with a working retry;
  - populated rows in type-then-series order with Spanish type labels, the lock only on in-use rows, and an unknown code rendering "Tipo desconocido (n)" last;
  - the count in the title;
  - the Plantilla column absent on a compact-width surface;
  - a row tap opening "Ver serie";
  - a reader (`rawValue: 2`) seeing the rows and no mutating control.
- [X] T020 [P] [US1] Write `test/widget/features/catalog/taxpayer_batch_dialog_test.dart` for view mode. Check that every field renders non-editable with the series' values, that accounts are listed in order, that a series with no accounts shows "Sin cuentas bancarias", and that Cerrar pops.
- [X] T021 [P] [US1] Write `test/unit/features/catalog/taxpayer_batches_controller_test.dart`. Check the sort (kind order, then series, unknown kinds last, series in the same kind alphabetical), that the repository is called once per RFC, that a second RFC gets its own state, and that a repository error surfaces as an `AsyncError`.
- [X] T022 [US1] Add one case to `taxpayer_issuer_detail_screen_test.dart` confirming the Series section renders for a saved issuer and is absent on the create form (FR-005). Run it together with T018's change.

**Checkpoint**: US1 is demonstrable. The issuer's series are visible, with every state, and a row opens read-only.

---

## Phase 4: User Story 2 — Add a series (P1)

**Goal**: a user with the right can add a series, with a bank-account list, and see it appear.

**Independent test**: on an issuer with no Invoice series, add "A" of type Factura with a template name and one account. It appears in the list and survives a reload. A duplicate series is refused with the values kept (quickstart steps 2 and 3).

- [X] T023 [US2] Create `lib/features/catalog/presentation/taxpayer_batch_dialog_controller.dart`, a `@riverpod` family `TaxpayerBatchDialogController` keyed by `(String rfc, TaxpayerBatch? existing)` with a freezed `TaxpayerBatchDialogState`, following `customer_discount_dialog_controller.dart` and data-model.md ("Draft"). In this task cover create only:
  - State holds the typed text, `kind`, the account rows, `fieldErrors`, `submitting`, `errorCause` (keep the `AppError`, never its text), `done` and `issuerGone`. Defaults are header 0 and footer 15.
  - Client validation before sending (keys `batch`, `type`, `name`, `header_height`, `footer_height`; codes `required`, `tooLong`, `invalid`). Trim the series first, so a series of only spaces fails as `required`.
  - Account editing: add, remove, move up, move down, and change a field.
  - `submit()` drops all-blank accounts, trims every account field, calls `create`, invalidates `taxpayerBatchesControllerProvider(rfc)` and sets `done`.
  - Failures are recognised by `problem?.code`: `resource.already_exists` with `resource: taxpayer_batch` becomes `fieldErrors['batch']`; `resource.not_found` with `resource: taxpayer_issuer` sets `issuerGone`; anything else keeps `errorCause` for the banner. The user's input is always kept.
- [X] T024 [US2] Run `dart run build_runner build --delete-conflicting-outputs` for T023's generated files, then `flutter analyze`.
- [X] T025 [US2] Extend `lib/features/catalog/presentation/taxpayer_batch_dialog.dart` with create mode. The title is "Nueva serie". Editable fields use the keys in `contracts/ui-contract.md` (`taxpayer_batch_series_field`, `taxpayer_batch_type_field` as a dropdown of the seven localized kinds with nothing preselected, `taxpayer_batch_template_name_field`, `taxpayer_batch_logo_field`, the two height fields with an "mm" suffix, keyboard type number). Client errors appear under their fields. Add the bank-account editor: per account four fields and icon buttons `move_account_up_{i}`, `move_account_down_{i}` and `remove_account_{i}` (up absent on the first, down on the last), plus `add_taxpayer_batch_account_button`. Each account stacks into one column on the compact tier. Actions are the dialog's own: Guardar (key `taxpayer_batch_save_button`) and Cancelar (`taxpayer_batch_cancel_button`); `RecordFormActions` is not used, because it would repeat them. Show the refusal in `FormErrorBanner`, and the duplicate error under the series field. When `issuerGone` is set, pop and `context.go('/taxpayer-issuers')`. When `done`, pop.
- [X] T026 [US2] Add the "Nuevo" button to `taxpayer_batches_section.dart`: a `TextButton.icon` with key `add_taxpayer_batch_button` and `CatalogAction.create.icon`, shown only when `!readOnly && access.can(SystemObject.taxpayers, AccessRight.create)` and the list has loaded. It opens the dialog in create mode.
- [X] T027 [P] [US2] Write `test/unit/features/catalog/taxpayer_batch_dialog_controller_test.dart` (create paths). Check: each validation code (blank and spaces-only series, an 11-character series, no type, blank and 51-character template name, a negative or non-numeric height); defaults 0 and 15; that a successful save trims the series, drops an all-blank account, keeps the others in order, sends the right draft, invalidates the list provider and sets `done`; add, remove and the move-up and move-down edges; a 409 `resource.already_exists` landing on `fieldErrors['batch']` with the input kept; a 404 for `taxpayer_issuer` setting `issuerGone`; and any other error landing in `errorCause`.
- [X] T028 [P] [US2] Extend `taxpayer_batches_section_test.dart` for "Nuevo": present for create-privileged and admin users on an editable render, absent for a reader, absent when `readOnly` is true even for admin, and absent until the list has loaded.
- [X] T029 [P] [US2] Extend `taxpayer_batch_dialog_test.dart` for create mode: the title, defaults 0 and 15, validation messages under the fields, adding two accounts and removing one, move up and down, the duplicate error under the series field with the typed values kept, the banner on another refusal, and Cancelar closing without a call.

**Checkpoint**: US1 and US2 work. An administrator can add a series and see it appear.

---

## Phase 5: User Story 3 — Edit a series, respecting the in-use lock (P2)

**Goal**: an unused series is fully editable. An in-use series shows its lock up front, and only the template changes.

**Independent test**: edit an unused series and change its prefix. Open an in-use series, confirm prefix and type are read-only with the lock note, and that a template change saves (quickstart steps 4, 5 and 6).

- [X] T030 [US3] Extend `taxpayer_batch_dialog_controller.dart` with edit. Seed the draft from `existing`, set `locked = existing?.inUse ?? false`, and start in `view`, `edit` or `create` as the launcher says.
  - Add `switchToEdit()`.
  - When `locked`, skip series and type validation and send the saved series and type unchanged.
  - `submit()` calls `update(rfc, existing.taxpayerBatchId, draft)`.
  - On a 409 `taxpayer_batch.in_use`: set `locked`, reset series and type to the saved values, keep the user's template edits, invalidate the list, and keep `errorCause` for the banner (research R6).
  - On a 404 `resource.not_found` for `taxpayer_batch`: invalidate the list and keep the error for the banner (research R8).
  - An existing series with an unknown `kind` starts with `kind == null`, so saving requires the user to pick one.
- [X] T031 [US3] Extend `taxpayer_batch_dialog.dart` with view-to-edit and the lock. The title is "Editar serie" in edit mode. When `locked`, show `taxpayer_batch_in_use_note` above the fields and render series and type read-only, while the template fields stay editable. In view mode the dialog's primary action is Editar (key `taxpayer_batch_edit_button`, with Cerrar as the secondary; a user who can't edit gets Cerrar alone) (only when `!parentReadOnly && access.can(taxpayers, update)`), which calls `switchToEdit()` in place. Edit mode shows Guardar. Keep Eliminar out until T037.
- [X] T032 [US3] Add the row Edit icon to `taxpayer_batches_section.dart` through `buildCatalogRowActions` (`editKey: Key('edit_taxpayer_batch_{id}')`), only when `!readOnly && access.can(taxpayers, update)`. It opens the dialog with `startInEdit: true`. The row tap still opens view mode, and there is no row delete.
- [X] T033 [P] [US3] Extend `taxpayer_batch_dialog_controller_test.dart` for edit. Check: an unused series edits everything and sends it; a locked series sends its saved series and type with the changed template; a 409 `taxpayer_batch_in_use` sets `locked`, resets series and type, keeps the template edits, and invalidates the list; a 404 for `taxpayer_batch` invalidates and keeps the error; a duplicate series on rename lands on `fieldErrors['batch']`; an unknown `kind` forces a pick; `switchToEdit` changes the mode.
- [X] T034 [P] [US3] Extend `taxpayer_batches_section_test.dart` for the Edit icon: shown for update-privileged and admin users, absent for a create-only user, a reader, and `readOnly` true; it opens an editable dialog, while a row tap opens "Ver serie".
- [X] T035 [P] [US3] Extend `taxpayer_batch_dialog_test.dart` for edit and the lock: an unused series has every field editable; an in-use series shows the lock note with series and type read-only and the template fields editable; view mode shows Editar for an update-privileged user and not for a reader or when `parentReadOnly`; Editar switches in place without closing; and after a stubbed in-use 409 the lock note appears with the banner and the user's template edits still in the fields.

**Checkpoint**: US1–US3 work. A series can be added, viewed and edited, and the lock shows before any save.

---

## Phase 6: User Story 4 — Delete an unused series (P3)

**Goal**: an unused series can be deleted after a confirmation. An in-use series offers no delete.

**Independent test**: delete an unused series after confirming, and cancel once first. Confirm an in-use series has no Eliminar (quickstart steps 7 and 8).

- [X] T036 [US4] Extend `taxpayer_batch_dialog_controller.dart` with `delete()`: it does nothing without an existing series or while submitting, calls `delete(rfc, id)`, invalidates the list and sets `done`. On a 409 `taxpayer_batch.in_use` it takes the same path as the update race (lock, reset, invalidate, banner). On a 404 for `taxpayer_batch` it invalidates and keeps the error.
- [X] T037 [US4] Extend `taxpayer_batch_dialog.dart` with Eliminar. Eliminar is a body `OutlinedButton` (key `taxpayer_batch_delete_button`) shown in edit mode only when `access.can(taxpayers, delete) && !locked` and the dialog isn't submitting. Pass a `RecordDeleteConfirmation` whose message names the series and the type label (`confirmKey: Key('confirm_delete_taxpayer_batch_button')`). View and create modes never show it. Run `flutter gen-l10n` only if a key was missing, adding it in T006's files.
- [X] T038 [P] [US4] Extend `taxpayer_batch_dialog_controller_test.dart` for delete: success invalidates and sets `done`; a 409 locks and resets, with the banner; a 404 invalidates; a second call while submitting is ignored.
- [X] T039 [P] [US4] Extend `taxpayer_batch_dialog_test.dart` for delete: Eliminar is present for an unused series with the delete right and absent without it, absent for an in-use series, absent in view and create modes; the confirmation names the series and type and cancelling makes no call; confirming deletes and pops.

**Checkpoint**: all four stories work.

---

## Phase 7: Polish and cross-cutting

- [X] T040 Write `integration_test/taxpayer_batches_quickstart_test.dart` following `integration_test/customer_discounts_quickstart_test.dart` and `specs/065-taxpayer-batches/quickstart.md` steps 1–9. Discover an issuer at runtime (don't hard-code one), create the test series with a unique suffix (≤ 10 characters in total), and delete everything it created even when a step fails. Skip the in-use step when no issuer has a series in use. Use the macOS traps in memory (frame-stall watchdog, `hitTestable` login, picker and back-button finders). Run with `flutter test integration_test/taxpayer_batches_quickstart_test.dart -d macos --dart-define-from-file=.env.settings --dart-define-from-file=.env` and record the result.
- [X] T041 Amend `specs/065-taxpayer-batches/spec.md` so it matches what was built: FR-006 names the "mm" unit on both heights, and FR-015 says create, edit and delete are available "on an editable render of the issuer", matching the Certificados rule. Then tick the matching questions in `wireframes.md` as resolved.
- [X] T042 Run `dart format` on only the files this feature changed (never the repo, never `lib/generated/`), then `flutter analyze` and the full `flutter test`. Compare any failures against T001's baseline and report only new ones.
- [ ] T043 Walk the compact-width checks in quickstart.md by hand (fullscreen dialog, stacked account fields, Plantilla column hidden), the in-use race, and the issuer-deleted-while-open case, and record what could not be automated. File them as one follow-up issue in `mictlanix/mbe-ui`, the way specs 061–064 did. Filed as mictlanix/mbe-ui#253; stays open until those checks are ticked.
- [X] T044 Check the spacing rule by reading the diff for literal paddings, sizes and colors in the new presentation files. Replace any with `Theme.of(context).spacing` tokens and theme colors.

---

## Dependencies and execution order

- **Phase 1** (T001) first, with no dependencies.
- **Phase 2** blocks all stories:
  - T002 and T003 are parallel. T004 needs both. T005 needs T004.
  - T006 is independent of T002–T005. T007 needs T006. T008 needs T007.
  - T009 needs T005. T010 needs T003 and T009.
  - T011–T014 follow T010. T011 and T012 are parallel, and T013 needs T005. T014 needs T008.
- **US1** (T015–T022) needs Phase 2. T015 and T017 are in different files, but T015 calls T017's function, so build T017's signature first or stub it. T016 needs T015. T018 needs T016. Tests T019–T022 follow the code, and T019–T021 are parallel.
- **US2** (T023–T029) needs US1, because the dialog and section files exist. T024 follows T023. T025 and T026 follow T024. Tests T027–T029 follow, and run in parallel.
- **US3** (T030–T035) needs US2, since it extends the same controller, dialog and section.
- **US4** (T036–T039) needs US3, since the lock-and-reset path is shared.
- **Polish** (T040–T044) after the stories. T041 can happen any time, but not before the three open questions are settled.

## Parallel examples

- **Phase 2:** T002 ∥ T003, then T011 ∥ T012.
- **US1:** T019 ∥ T020 ∥ T021 once the code tasks are done.
- **Each later story:** its controller test, section test and dialog test touch three different files, so they run in parallel.

## Implementation strategy

- **MVP:** Phase 1, Phase 2 and US1. An administrator can see which document types an issuer has series for. That diagnoses "the issuer has no invoice series" without any editing.
- **Then:** US2 unblocks invoicing for a new RFC. US3 and US4 are maintenance and can follow separately.
- **Stop points:** each checkpoint above leaves the app releasable, and no checkpoint leaves a control that does nothing.
