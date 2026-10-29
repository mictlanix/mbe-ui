# Quickstart: Customer Refunds

How to prove the feature works end to end against the dev tenant. Keys and copy are in [contracts/ui-contracts.md](./contracts/ui-contracts.md).

## Prerequisites

- mbe-api running, with `.env` holding `MBE_POS_USERNAME/PASSWORD` (admin) and `MBE_TEST_USERNAME/PASSWORD` (`qanoaccess`).
- A paid order with returnable lines at the admin's facility. The live test finds one at runtime.
- For steps 5 to 7, an open cash session for the admin.

## Automated

```bash
flutter test integration_test/customer_refunds_quickstart_test.dart -d macos --dart-define-from-file=.env
# Steps 5–7 write stock and cash; opt in:
flutter test integration_test/customer_refunds_quickstart_test.dart -d macos --dart-define-from-file=.env --dart-define=MBE_REFUND_CONFIRM=1
```

## Steps

1. **Devolver opens a refund.** Open the paid order in Pedidos and tap "Devolver". The refund opens as a draft. Its lines are the order's returnable lines, each at 0.
2. **Devolver resumes.** Go back to the order and tap "Devolver" again. The same refund opens. No second draft appears in Devoluciones with that order filter.
3. **Quantity cap.** Try to step a line above "Por devolver". The stepper stops at the max. Set it to 1, and the totals update from the server.
4. **Refusal reasons.** In Devoluciones, use "Nueva devolución" with an unpaid order: you get the "no está pagado" message. Use a draft order: you get "no está confirmado".
5. **Session gate.** With no open session, tap "Confirmar devolución". The session banner shows, and nothing is sent.
6. **Confirm as cash.** With a session open, confirm and choose "Efectivo de la caja". The refund shows a folio and is read-only, with the payout line "Pagada en efectivo". The cash session's detail shows its expected cash lower by the refund's total (SC-003).
7. **Confirm as credit note.** Use another order and choose "Nota de crédito". The payout line shows the note number. In Notas de crédito, the note's origin links back to the refund.
8. **Cancel.** Open a new draft refund and cancel it. It shows as cancelled, and no actions remain.
9. **List filters.** Filter Devoluciones by Abiertas, by the customer, and by the order number. Only matching rows remain.
10. **Access.** Sign in as `qanoaccess`. Devoluciones is not in the nav, `/sales/refunds` redirects, and no "Devolver" shows on orders.

Without the opt-in, the live test runs steps 1 to 4 and 8 to 10, then cancels the draft it opened, so the tenant is left as it was.

## Not covered yet

Printing (User Story 3) waits for mbe-api#287.
