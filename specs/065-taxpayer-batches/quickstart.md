# Quickstart: Taxpayer Batches

How to prove the feature works. See [contracts/ui-contract.md](contracts/ui-contract.md) for keys and [contracts/consumed-endpoints.md](contracts/consumed-endpoints.md) for refusals.

## Prerequisites

- mbe-api running locally with the dev tenant, including the batch endpoints from mbe-roadmap#44.
- `.env` and `.env.settings` present. The `MBE_POS_*` account is an admin (see memory).
- At least one taxpayer issuer in the dev tenant. The live test discovers one at runtime and skips the in-use steps if no issuer has a series in use.

## Automated checks

```bash
flutter analyze
flutter test test/unit/features/catalog/taxpayer_batch_repository_impl_test.dart \
  test/unit/features/catalog/taxpayer_batch_dialog_controller_test.dart \
  test/unit/features/catalog/fiscal_document_kind_test.dart \
  test/widget/features/catalog/taxpayer_batches_section_test.dart \
  test/widget/features/catalog/taxpayer_batch_dialog_test.dart \
  test/unit/core/errors/
flutter test   # full suite; compare against the pre-existing failures noted in memory
flutter test integration_test/taxpayer_batches_quickstart_test.dart -d macos \
  --dart-define-from-file=.env.settings --dart-define-from-file=.env
```

## Live walkthrough (what the integration test automates)

| # | Step | Expected |
|---|---|---|
| 1 | Sign in as admin, open Emisores, open an issuer | The "Series" section sits below Certificados and lists the issuer's series by type, then series, with type labels in Spanish |
| 2 | Tap "Nuevo", enter series `QA<timestamp-suffix>` (≤10 chars), type Factura, template "QA plantilla", add two accounts, remove the first, save | The dialog closes, and the new row appears with type "Factura" and no lock. Reopening it shows one account |
| 3 | Tap "Nuevo" and enter the same series with type Nota de crédito | The error under the series field says it already exists, and the typed values stay |
| 4 | Tap the new row | "Ver serie": the fields are read-only, and Editar is offered |
| 5 | Editar, change the series to `QB…`, move an added account up, save | The row shows the new series. Reopening shows the new account order |
| 6 | Open an in-use series (if one exists) with the Edit icon | Series and type are read-only with the lock note, and there is no Eliminar. Changing the header height saves |
| 7 | Edit the test series, Eliminar, cancel the confirmation | Nothing changes |
| 8 | Eliminar, confirm | The row disappears and stays gone after a reload |
| 9 | Switch the language to English | Section, dialog and type labels are in English |


No seeded dev account holds Taxpayers read without update (`qareadonly` has only Products and Users read). The reader-only matrix (rows open in view mode, with no "Nuevo", no Edit icon and no Editar toggle) is therefore covered by widget tests with an overridden access control, not live.

## Manual-only checks

- Compact width (phone): the dialog is fullscreen, the account rows stack, and the "Plantilla" column is hidden.
- The in-use race (step 6 variant): open an unused series in one window, stamp an invoice with it from another, then try to change the series. Expect the in-use banner and the lock to appear. Hard to automate, because it needs a stamped document.
- Issuer deleted elsewhere while the dialog is open: on save, the dialog returns to the issuer list.
