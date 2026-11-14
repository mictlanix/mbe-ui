# Quickstart: Payment Verification

**Spec**: [spec.md](./spec.md) | **Contracts**: [contracts/ui-contracts.md](./contracts/ui-contracts.md)

## Prerequisites

- mbe-api running locally with the dev tenant. `.env` holds `MBE_ADMIN_*` (see `test/integration/TEST_ACCOUNTS.md`).
- After a DB reset, run `python3 tool/seed_test_accounts.py`. The non-admin checks need an account without Payments Verification, and `qa054payments` serves (Customer Payments read only).
- At least one unverified transfer exists. If not, record one from Pagos ("Registrar pago", Transferencia, 1.00).

## Automated

```bash
flutter test test/unit test/widget                    # unit + widget
# Live, against a running mbe-api: the admin account is MBE_POS_* in .env
flutter test integration_test/payment_verification_quickstart_test.dart -d macos \
  --dart-define-from-file=.env.settings \
  --dart-define=MBE_POS_USERNAME=... --dart-define=MBE_POS_PASSWORD=...
# ...and add this to also verify + reject (irreversible, leaves payments behind)
  --dart-define=MBE_WRITE=true
```

Each write run leaves three verified 1.00 transfers and one rejected, still-unverified 1.00 transfer on the tenant.

## Manual walkthrough

1. **Opening (US1-1, US1-2).** Log in as admin. Ventas shows "Verificación de pagos" after Pagos.
   - Open it. Every row is a transfer, newest first, from more than one facility.
   - The pagination footer shows the total ("1–20 de N"), and the filter badge reads ①.
2. **Access (SC-005).** Log in as `qa054payments`. The menu entry is missing, and typing `/sales/payment-verification` is refused.
3. **Filters (US1-3, FR-003).**
   - Set Método to "Todos". Cash payments appear and the badge clears.
   - Set a facility and a date range. The rows narrow.
   - "Limpiar todo" returns to transfers from every facility, with the badge at ①.
4. **Row panel (FR-005a).** Tap a row from a facility other than yours.
   - The read-only panel opens at once with folio, store, date, customer, type, method, reference, amount, unapplied amount and cash session.
   - It has no buttons except close.
5. **Verify (US1-4, US1-5).**
   - Tap ✓ on a row. The dialog names folio, customer, amount and reference, and says verification can't be undone.
   - Confirm. The row is gone, the footer's total drops by one, and a SnackBar confirms.
   - Open that payment in Pagos. It shows "Verificado" with your name.
6. **Already verified (edge).** Open the queue in two windows and verify the same row in both. The second window says it was already verified, and the row disappears.
7. **Reject (US2).**
   - Tap ✕. "Rechazar" is disabled until a reason is typed, and the counter stops at 500.
   - Confirm. The SnackBar says the payment stays unverified and in the queue, and the row is still there.
8. **Payment view (US3).**
   - Open an unverified payment in Pagos. "Verificar" and "Rechazar" are in the header. Verify it, and the buttons go away.
   - Open a verified payment. Neither button shows.
9. **Compact tier.** Narrow the window to phone width. The rows stack, with ✓ and ✕ on the first line.
10. **Largest text size (§V).** At desktop width, set the largest text size. No column in the queue clips its folio, date or amount.
