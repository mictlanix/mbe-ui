# Quickstart: Credit Notes

How to prove the feature works end to end. Behaviour details are in [contracts/ui-contracts.md](contracts/ui-contracts.md); data shapes are in [data-model.md](data-model.md).

## Prerequisites

- mbe-api running at `http://127.0.0.1:8000`, on the dev tenant.
- `.env` with `MBE_POS_*` (admin) and `MBE_QA*` accounts. See `test/integration/TEST_ACCOUNTS.md`.
- **Spendable fixture.** Until mbe-api#277 ships, no legacy note reports a real spendable balance. Note 158 reports 1,025.00 but was paid out in cash. To get a valid fixture, create a refund through mbe-api (`POST /customer-refunds`, set the return quantities with `PUT /customer-refunds/{id}/lines/{line_id}`, then `POST /customer-refunds/{id}/confirm` with `{"payout": "credit_note"}` while a cash session is open). Do this once for a named customer and once for the walk-in customer, then note the backing payment ids.

## Automated

```bash
flutter analyze
flutter test test/unit/features/sales test/widget/features/sales test/unit/app/router
flutter test test/integration/credit_notes_live_test.dart -j 1 \
  --dart-define-from-file=.env
```

Expected: all pass. The live test skips its redemption case when no spendable note exists (research R11).

## Manual walkthrough (real app, POS user with a cash session)

| # | Step | Expected |
|---|---|---|
| 1 | Open Ventas → Notas de crédito | List newest first, 20 per page. Filter row shows no search box. |
| 2 | Filter by customer 10653 | Notes 990 and others shown. Origin reads "Devolución #9605 · Pedido #343533". |
| 3 | Turn on "Solo con saldo" with no customer | The full set is read once. Only notes with remaining > 0 are shown, and the count matches the rows (no empty pages). |
| 4 | Tap a row | Ver pago opens for the backing payment. Back returns to the list. |
| 5 | POS sale for the named fixture customer, go to Cobro | "Nota de crédito · Saldo X" tile present. |
| 6 | Tap it with a sale balance larger than X | X applied, the balance falls by X, and an applied row reads "Nota de crédito". The tile disappears. |
| 7 | New walk-in sale, Cobro → Canjear nota de crédito, type the walk-in fixture's payment id | "Saldo disponible" shown. Confirm applies it. |
| 8 | Repeat 7 on the same sale | "ya está aplicada a esta venta". |
| 9 | Walk-in sale, enter the named customer's fixture payment id | "es de {name}". Nothing applied. |
| 10 | Log in as a user without CreditPayments read | No nav entry. `/sales/credit-notes` redirects to `/`. No credit tile in Cobro. |
