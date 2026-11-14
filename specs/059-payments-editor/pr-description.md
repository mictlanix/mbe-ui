## Summary

Staff can now fix a misapplied payment, take a credit payment or an advance outside the register, and see an order's payments from Pedidos. Spec: `specs/059-payments-editor/`.

- **Move a misapplied payment (P1).** The Pagos payment view gains two actions, each where the data it changes is shown.
  - **Reverse:** every live application gets a reverse icon. A dialog names the amount and the order, and requires a reason. It warns when the order has refunds, since reversing doesn't undo them. A refusal from the server shows inside the dialog, which stays open.
  - **"Aplicar a pedido":** shown while money is left unapplied. It lists the customer's outstanding orders in the payment's currency, searchable by order number or folio. The amount defaults to the smaller of the order's balance and what the payment has left, and can't go above either. A refusal reloads the list and the payment.
- **Record a payment (P2).** "Registrar pago" in the Pagos toolbar records a credit payment or an advance. The form asks for customer, type, method or payment option, reference and amount.
  - **Refused on save:** the walk-in customer; cash without a cash session opened today; a missing reference when the option needs one. Each error shows under its field.
  - **Double taps and lost connections:** repeated taps record one payment. A lost connection says the result is unknown instead of offering a blind retry.
  - **After saving:** the new payment's view opens, with "Aplicar a pedido" and its ticket.
- **Pedidos (P3).** A confirmed order's header gets "Pagos". It opens the order's applications, live and reversed, with the same reverse flow. Each row links to its payment. A reversal refreshes the order's status.

**Gates mirror the server.** Recording and applying need Customer Payments (8) create; reversing needs update; the Pedidos list needs read. Payments Editor (100) read only widens which facility's payments a user can open. Anything a user can't use is absent, not disabled.

**Where this changes existing behaviour.**
- **The register's reverse dialog:** it is now the shared one. It is translated (it was hard-coded Spanish) and names the amount and order. Its path is otherwise unchanged, pinned by a new test.
- **The payment view:** it no longer blanks to a spinner when a write reloads it.
- **`createPayment` takes a payment type:** the register's default is unchanged.
- **Eight `payment.*` error codes get messages in both languages.** The register already called apply and reverse without them. Spec 058's `code-scope.tsv` marks them `IN`, and the coverage test's count goes from 96 to 104.

**Known limits.**
- **Another facility's payment can't be applied from here:** mbe-api lists only the user's own facility's outstanding orders. "Aplicar a pedido" is hidden on such a payment until mbe-api#308 adds a facility parameter. Reversing still works.
- **A payment reversed off an order can't be applied to that order again.** The legacy table keeps one application per payment and order (`UNIQUE (sales_order, customer_payment)`), and a reversed application stays on record as evidence. The server answers a generic `resource.conflict`. This blocks "reverse the wrong amount, apply the right one to the same order". Filed as mbe-api#309.
- **Older back-office orders with payments:** one with no recorded origin opens as a register sale in Pedidos, so its "Pagos" button isn't reachable. Its payments are still reached from Pagos.
- **Found, not caused here:** the Pagos list clips dates and amounts at the largest text size, which constitution §V forbids. It predates this spec.

## Roadmap

Closes mictlanix/mbe-roadmap#26

Upstream: mbe-api#308 (filed 2026-11-13) and mbe-api#309 (filed 2026-11-14), neither blocking.

## Test plan

- [x] `flutter analyze`: no issues.
- [x] `flutter test test/unit test/widget`: 4196 passed, none failed. New: 9 test files (unit: outstanding order, payment editor controller, refund lookup, apply amount; widget: reverse dialog, applied-payments panel, apply dialog, record dialog, Pedidos button and dialog), plus new cases in the payment view, Pagos list and repository tests.
- [x] Live walkthrough `integration_test/payments_editor_quickstart_test.dart` on macOS against the dev API, with `--dart-define=MBE_WRITE=true`: all 11 steps pass.
  - Read-only: "Registrar pago" and its validation; the reverse icon on the seeded payment; Pedidos "Pagos" listing the application and opening its payment; the refund warning when reversing on a refunded order (cancelled, nothing written); the payment view, record, Pedidos and apply dialogs at the largest text size at 1680 px with real fonts.
  - Writes: recording a 1.00 credit payment through the UI (its view shows apply and ticket); a concurrent refusal (with the apply dialog open, the test spends the payment on another order through the API, and the UI's confirm shows the Spanish refusal and reloads); applying the payment to an outstanding order (balance falls by 1.00); reversing it (reason required, balance restored).
- [ ] Goldens and screenshots (`test/golden`, `test/screenshots`): run, and 7 golden groups plus the POS screenshots fail. Not caused here: this branch touches no shared widget, design token, app shell or baseline. The golden diffs are sub-pixel text and corner anti-aliasing (baselines from Flutter 3.44.2, this machine runs 3.47.7). The sales-list screenshot differs in column positions because its baseline (2026-10-17) predates the DataTableView column changes on main (latest 2026-10-27, spec 055). Refreshing the baselines belongs with mbe-ui#209 (goldens via CI).
- Dev tenant: every order ends as it started. Each write run leaves its recorded 1.00 payment (300912, 300914, 300915, 300916 so far), because mbe-api has no way to cancel a payment. Seed payment 300834 sits unapplied after an early run hit the mbe-api#309 limit; `tool/seed_payment_fixtures.py` seeded 300913 in its place.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
