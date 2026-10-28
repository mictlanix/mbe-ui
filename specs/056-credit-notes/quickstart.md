# Quickstart: Credit Notes

How to prove the feature works end to end. Behaviour details are in [contracts/ui-contracts.md](contracts/ui-contracts.md); data shapes are in [data-model.md](data-model.md).

## Prerequisites

- mbe-api running at `http://127.0.0.1:8000`, on the dev tenant.
- `.env` with `MBE_POS_*` (admin) and `MBE_QA*` accounts. See `test/integration/TEST_ACCOUNTS.md`.
- **Spendable fixture.** Facility 51 on the dev tenant has spendable notes (10 on 2026-10-27, found with `GET /credit-notes?open_only=true`) and three walk-in notes with a balance. To make a fresh one, create a refund through mbe-api (`POST /customer-refunds`, set the return quantities with `PUT /customer-refunds/{id}/lines/{line_id}`, then `POST /customer-refunds/{id}/confirm` with `{"payout": "credit_note"}` while a cash session is open). Do this once for a named customer and once for the walk-in customer, then note the backing payment ids.

## Automated

```bash
flutter analyze
flutter test test/unit/features/sales test/widget/features/sales test/unit/app/router
flutter test test/integration/credit_notes_live_test.dart -j 1 \
  --dart-define-from-file=.env
```

Expected: all pass. The live test is read-only and redeems nothing (research R11).

The real-app walkthrough of steps 1–4 and 10 is automated:

```bash
flutter test integration_test/credit_notes_quickstart_test.dart -d macos --dart-define-from-file=.env
```

Steps 5–9 are automated too, but **they write to the tenant**: the test opens a cash session if there is none (and leaves it open), raises two POS sales, spends two real notes, then reverses both applications and cancels both sales:

```bash
flutter test integration_test/credit_notes_redemption_quickstart_test.dart -d macos \
  --dart-define-from-file=.env --dart-define=MBE_POS_PRODUCT_PATTERN=clavo
```

## Manual walkthrough (real app, POS user with a cash session)

| # | Step | Expected |
|---|---|---|
| 1 | Open Ventas → Notas de crédito | List newest first, 20 per page. Filter row shows no search box. |
| 2 | Filter by the customer of the newest note | Only that customer's notes in this facility are shown, each with "Devolución #… · Pedido #…". |
| 3 | Turn on "Solo utilizables" with no customer | Only the notes mbe-api's `open_only` returns are shown, and the count matches the rows. |
| 4 | Tap a row | Ver pago opens for the backing payment. Back returns to the list. |
| 5 | POS sale for the named fixture customer, go to Cobro | "Nota de crédito · Saldo X" tile present. |
| 6 | Tap it with a sale balance larger than X | X applied, the balance falls by X, and an applied row reads "Nota de crédito". The tile disappears. |
| 7 | New walk-in sale, Cobro → Canjear nota de crédito, type the walk-in fixture's payment id | "Saldo disponible" shown. Confirm applies it. |
| 8 | Repeat 7 on the same sale | "ya está aplicada a esta venta". |
| 9 | Walk-in sale, enter the named customer's fixture payment id | "es de {name}". Nothing applied. |
| 10 | Log in as a user without CreditPayments read | No nav entry. `/sales/credit-notes` redirects to `/`. No credit tile in Cobro. |
