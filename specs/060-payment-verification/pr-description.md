## Summary

Supervisors can now verify customer payments, usually bank transfers, against the bank statement, or reject one that isn't there. Spec: `specs/060-payment-verification/`.

- **Verification queue (P1).** A new "Verificación de pagos" screen in Ventas, right after Pagos. It lists unverified payments from **every facility**, newest first, and opens on transfers (the legacy `PaymentMethodsVerificationRequired = EFT`).
  - **Filters:** facility, date range and method. "Todos" shows every method; "Limpiar filtros" goes back to transfers. There is no search box, because the server's list has no search.
  - **Rows:** folio, facility, date, customer, method, reference and amount. The total is the table footer's.
  - **✓ Verificar:** a confirmation names the folio, customer, amount and reference and says verification can't be undone. The row leaves the queue.
  - **Row tap:** a read-only panel built from the row's own data, so it opens for any facility's payment.
- **Reject (P2).** ✕ Rechazar on each row asks for a reason (required, up to 500 characters). The server records it with who and when. The payment stays unverified and stays in the queue, and the app says so.
- **Payment view (P3).** An unverified payment in Pagos gets "Verificar" and "Rechazar" beside its verified chip, with the same dialogs.

**Gates mirror the server.** The queue needs Payments Verification (108) read; verify and reject need 108 update, in the queue and on the payment view. No Customer Payments right is needed or checked. Anything a user can't use is absent, not disabled.

**Where this changes existing code.**
- **`buildCatalogRowActions` gains an optional `primaryAction`.** It fills the slot Edit usually holds, on rows that have no Edit because the record isn't editable there. It is asserted exclusive with `onEdit`, keeps the two-icon limit, and every existing caller is unchanged.
- **`payment.already_verified` gets a message in both languages.** Spec 058's `code-scope.tsv` marks it `IN`, and the coverage test's count goes from 104 to 105.
- **`parsePaymentsDateFacet`** in `payments_filter.dart` is now public, so the queue reuses Pagos' date parser instead of copying it.

**Constitution §VI deviation (recorded in `plan.md`, Complexity Tracking).** The row panel is a second surface for customer payments, beside the Pagos screen. A row tap can't open Pagos: it refuses another facility's payment to a verifier without Payments Editor read, and the queue spans every facility. §VI isn't amended; this is a one-off.

**Known limits.**
- **Rejected payments look unchecked.** The server only writes the rejection to its incidence log; nothing reads it back, so a rejected payment looks like one nobody has checked. Filed as mbe-api#310 (FR-016).
- **Without Facilities read** (29), a verifier sees the facility's number instead of its name and gets no facility filter. The queue still lists every facility.
- **No undo:** the server has no way to unverify a payment, so the confirmation says so.

## Roadmap

Closes mictlanix/mbe-roadmap#27

Upstream: mbe-api#310 (rejection visibility, filed 2026-11-14), not blocking.

## Test plan

- [x] `flutter analyze`: no issues.
- [x] `flutter test test/unit test/widget`: 4295 passed, none failed (4196 before). New: 3 unit files (filter, queue controller, write controller) and 4 widget files (queue screen, verify dialog, reject dialog, row panel), plus new cases in the payment view, row-actions helper, repository, router, navigation and error-catalog tests.
- [x] Live walkthrough `integration_test/payment_verification_quickstart_test.dart` on macOS against the dev API, with `--dart-define=MBE_WRITE=true`: all 8 steps pass.
  - Read-only: the queue opens on transfers with the API's own total; "Todos" lists every method; a row tap opens the panel; the queue and the panel at the largest text size at 1680 px with real fonts.
  - Writes, each on a fresh 1.00 transfer: verify from the queue (the row leaves, the server agrees); reject from the queue (reason required, the row stays, the server shows it unverified); verify from the payment view (the buttons go, "Verificado" shows); verify a payment the API verified underneath a stale row (the Spanish "already verified" message, and the row goes).
- [x] Found and fixed by the live run: the amount column clipped "$150,000.00 MXN" by up to 10 px at the largest text size. It is now wider, and the method column narrower.
- [x] Manual checks (T019, quickstart steps 2, 6, 9 and the SC-001/SC-002 timing): done by hand. In step 6 the stale row in a second window showed "Otra persona ya verificó este pago." with only "Cerrar" left.
- [ ] Goldens (`test/golden`): the same 6 known failures as `main` (Flutter 3.44.2 baselines on 3.47.7). None comes from this branch: the new `primaryAction` only renders when a caller passes one, and the goldens don't. Baselines belong with mbe-ui#209.
- Dev tenant: verification can't be undone and payments can't be deleted, so each write run leaves its payments.
  - **Verified:** 300919, 300920, 300921, 300923, 300924.
  - **Rejected, still unverified:** 300922.
  - **Left by a first run** whose queue steps failed before the refresh fix in the test: 300917 (still unverified) and 300918 (verified later during the manual two-window check).

🤖 Generated with [Claude Code](https://claude.com/claude-code)
