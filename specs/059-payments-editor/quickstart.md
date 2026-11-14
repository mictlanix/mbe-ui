# Quickstart: Payments Editor

How to check this feature end to end against the dev tenant. Contract details are in [contracts/ui-contracts.md](./contracts/ui-contracts.md), and the rules behind them are in [research.md](./research.md).

## Prerequisites

- mbe-api running locally at `main`, serving `http://127.0.0.1:8000`. No upstream change is needed, and the generated client already has every endpoint used.
- `.env` with `MBE_POS_*` (admin) and a non-admin account without Customer Payments create/update (`MBE_QA054_*`). After a database reset, run `python3 tool/seed_test_accounts.py`.
- Seed fixtures: `python3 tool/seed_payment_fixtures.py`. This spec extends it so the seeded customer also has a second outstanding back-office order. It prints the payment, the order it's applied to, and the spare order. Running it again creates nothing.
- For the cash case: the admin has a cash session open today, plus a way to test without one (close it, or use an account with no session).

## Automated

```
flutter analyze
flutter test test/unit/features/sales test/unit/core/errors test/widget/features/sales
caffeinate -dimsu flutter test integration_test/payments_editor_quickstart_test.dart -d macos \
  --dart-define-from-file=.env.settings \
  --dart-define=MBE_POS_USERNAME=... --dart-define=MBE_POS_PASSWORD=... \
  --dart-define=MBE_QA054_USERNAME=... --dart-define=MBE_QA054_PASSWORD=...
```

The walkthrough must end with `==== RESULTS ====` showing every step `PASS`.

## Manual walkthrough

1. **Reverse (US1, SC-004):** Open the seeded payment in Pagos. On its live application, press reverse. Confirm stays disabled with an empty or blank reason. Enter a reason and confirm. The row now shows reversed, "Sin aplicar" rises by the applied amount plus change, and the order link shows the order as no longer paid.
2. **Apply (US1, SC-001, SC-003):** Press "Aplicar a pedido". The dialog lists only the customer's outstanding orders in the payment's currency. Pick the spare order. The amount is prefilled with the smaller of its balance and "Sin aplicar". Raising it above either shows an error. Confirm. "Sin aplicar" falls by that amount, and the order's balance in Pedidos falls by the same amount.
3. **Refusal (FR-009):** In a second window, settle the spare order, or apply the payment's remainder elsewhere. Then confirm an application in the first window. The dialog shows the Spanish message for the refusal and reloads.
4. **Refund warning (FR-004):** Reverse an application on an order that has a completed refund. The dialog warns that the refund isn't undone.
5. **Record (US2, SC-002, SC-006):** In Pagos, press "Registrar pago". Pick the seeded customer, choose "Abono a crédito", pick transfer, enter a reference and 100.00, then double-click save. Exactly one payment is created, and its view opens with 100.00 unapplied. "Ver ticket" previews its ticket. Apply it to an order as in step 2.
6. **Cash needs a session (FR-015):** With no cash session open today, try to record a cash advance. Saving is refused with the session message. Switch the method to transfer, and it saves.
7. **Walk-in refused (FR-012):** Pick the general-public customer. Saving is refused.
8. **Pedidos (US3):** Open the seeded back-office order. "Pagos" opens the list of applications, live and reversed. Reverse one: the list and the order's status update. Its payment link opens the Pagos payment view.
9. **Rights (SC-005):** Log in as the QA054 account. Pagos shows no "Registrar pago", the payment view shows no reverse or apply, and Pedidos' "Pagos" dialog has no reverse icon.
10. **Largest text size (constitution §V):** In user settings, pick the largest text size. At desktop width, open the apply dialog with orders listed, the payment view with its reverse column, the record dialog, and the Pedidos payments dialog. Nothing clips, overflows, or wraps a money cell. Set the size back.
11. **POS unchanged:** At the register, reverse a payment on an open sale. It still works, and the dialog's text follows the app language.

## Known limit

A back-office order created before mbe-api#209 (no origin) with any payment applied opens as a register sale in Pedidos, so its "Pagos" button isn't reachable. Its payments can still be reversed from Pagos (research R7).
