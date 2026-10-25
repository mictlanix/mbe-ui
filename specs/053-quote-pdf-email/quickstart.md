# Quickstart: Quotation PDF and Email

**Feature**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md)

How to prove the feature works. Contracts are in [contracts/](./contracts/), types in
[data-model.md](./data-model.md), screens in [wireframes.md](./wireframes.md).

## Prerequisites

- On branch `053-quote-pdf-email`, after `flutter pub get` and
  `dart run build_runner build --delete-conflicting-outputs`. The new controller and
  entities are generated. Format only the files you changed, never the whole repo.
- **For live checks**: an mbe-api at or after spec 024 (PR #254), and `.env` with `MBE_POS_*`
  (the admin account).
- **For the live email check only**: mail configured on that mbe-api (`MAIL_FROM` and the
  SMTP settings), plus an inbox you control, passed as `--dart-define=MBE_QUOTE_EMAIL_TO=<address>`.
  Without it the email step skips.

## 1. Automated tests

```bash
# Document kind, source route, fallback name, gate
flutter test test/unit/core/documents/

# Repository email call, controller rules, address check
flutter test test/unit/features/sales/sales_quote_repository_email_test.dart \
  test/unit/features/sales/quote_email_controller_test.dart \
  test/unit/features/sales/quote_email_test.dart

# Shared dialog + quote screen + email dialog
flutter test test/widget/core/widgets/responsive_dialog_test.dart \
  test/widget/features/sales/quote_screen_documents_test.dart \
  test/widget/features/sales/quote_email_dialog_test.dart

# Goldens (the new ResponsiveDialog must be in the covered set)
flutter test test/golden

# Quality gate
flutter analyze && flutter test test/unit test/widget test/golden

# Live: fetch a quote PDF; send email only if MBE_QUOTE_EMAIL_TO is set
flutter test test/integration/quote_pdf_email_flow_test.dart \
  --dart-define-from-file=.env --dart-define=MBE_QUOTE_EMAIL_TO=<your inbox>
```

**Expected**: all pass. The integration test skips, rather than fails, when it finds no
confirmed quote or `MBE_QUOTE_EMAIL_TO` is unset, so a silent skip means a missing fixture,
not a pass.

## 2. Manual checks in Chrome (`flutter run -d chrome --dart-define-from-file=.env`)

| # | Steps | Expected | Covers |
|---|---|---|---|
| M1 | Open a confirmed quote, then press **Ver cotización**. | The preview opens with "Cotización · 000000NN". Print opens the browser dialog; download saves `cotizacion-000000NN.pdf`. | US1, FR-001–004, SC-001 |
| M2 | Open a draft, type into the comment without confirming, then press **Ver cotización**. | On a touch device the keep/discard prompt appears first. On desktop, the click that presses the button takes the field's focus, which discards the typed text before the button fires (the app's "blur is a discard" rule), so no prompt is needed. Either way the PDF shows what is on screen and nothing is saved. While a line edit is saving, the button is disabled. | FR-005 |
| M3 | Open a cancelled quote. | **Ver cotización** is present. **Enviar por correo** is absent. | FR-001, FR-006 |
| M4 | Confirmed quote, then **Enviar por correo**. | The dialog lists the customer's contact and fiscal emails as chips, none selected; **Enviar** is disabled. | FR-007–009 |
| M5 | Tap two chips, type a new address, press Enter, then deselect it. | The selected chips show checks. The typed address becomes a selected chip, then stays unselected. The counter tracks the selection. | FR-008, FR-009a |
| M6 | Type `pedro@`, then press **Agregar**. | Field error "No es un correo válido."; no chip is added. | FR-010 |
| M7 | Select 10, then try an 11th (chip or typed). | It is refused, with the limit message. | FR-010 |
| M8 | Send to your own inbox. | The button shows progress and the dialog cannot be closed. Then the dialog closes and a snackbar lists the address. The mail arrives with subject "{facility} Cotización {id}" and the PDF attached. **Time it from opening the dialog to the snackbar: under 30 s.** | US2, FR-011–012, SC-002 |
| M9 | Against an mbe-api without mail configured, send. | The banner says email is unavailable and suggests downloading. The selection is kept. | FR-013, SC-003 |
| M10 | Open the dialog, cancel the quote in another tab, then send. | The banner says the quote can no longer be sent. On close, the screen shows "Cancelada" and the email action disappears. | FR-013–014 |
| M11 | Resize to under 600 px wide. | The header shows **Más detalles** plus ⋮. The menu holds both actions (only Ver cotización on a draft). The email dialog is full screen, with ✕ and **Enviar** in its top bar. | FR-015a, FR-015b |
| M12 | Log in as a user without sales-quotes Read. | The quote screen is unreachable, so neither action is seen. | FR-016 |

### Automated run (real app, macOS desktop)

`integration_test/quote_pdf_email_quickstart_test.dart` drives M1–M7, M9 and M11, plus a check that the wide header's three controls share one line. It is read-only: it never confirms an edit or changes a quote, and it only attempts a send after probing that the deployment answers 503.

```bash
caffeinate -dimsu flutter test integration_test/quote_pdf_email_quickstart_test.dart \
  -d macos --dart-define-from-file=.env.settings --dart-define-from-file=.env
```

**2026-10-25, local mbe-api (mail not configured): 10/10 passed.** The preview loaded in about 2.3 s (M1, under the 3 s target). M2 took the desktop discard-on-blur path.

Not automated:
- **M8** needs configured mail and an inbox.
- **M10** changes data (it cancels a quote). Also, on a deployment without mail, mbe-api answers 503 before it checks the quote's state, so the 409 path can't be seen there.
- **M12** needs an account without sales-quotes read; none of the `.env` accounts lacks it.
- **Print and download** open native dialogs. The driver checks that the preview loads with both buttons enabled, and checks the file name through the client.

## 3. Done when

- Every automated test above passes, and `flutter analyze` is clean.
- M1–M12 are checked off. M8 and M9 need mail configured and unconfigured respectively.
  Record which deployment was used.
- The PR body says `Closes mictlanix/mbe-roadmap#31`.
