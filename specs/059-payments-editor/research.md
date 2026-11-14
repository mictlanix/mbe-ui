# Research: Payments Editor (spec 059)

All decisions were checked against the code on `main` (9552a477) and mbe-api `main` on 2026-11-13. No open questions remain.

## R1. Which rights gate each action

**Decision**:

| Action | Right |
|---|---|
| Record | Customer Payments (8) create |
| Apply | Customer Payments (8) create |
| Reverse | Customer Payments (8) update |

Another facility's payment is visible only with Payments Editor (100) read, and the existing `paymentDetailProvider` guard already enforces that.

**Rationale**: these are mbe-api's own dependencies. `create_customer_payment` and `apply_customer_payment` use `_CREATE`, `reverse_customer_payment_application` uses `_UPDATE`, and `_visible_payment_or_404` widens access through `can_see_every_facility(PAYMENTS_EDITOR)`. §IV wants client checks to mirror the server.

**Alternatives**:
- Gate everything on PaymentsEditor (100), as the legacy screen did. Rejected: cashiers who can reverse at the POS today would lose that power in the back office, and the server would still accept their calls.

## R2. Where the legacy Payments Editor lives

**Decision**: there is no new screen. Its actions go on the existing Pagos payment view (`payment_detail_screen.dart`) and the Pagos list (`payments_list_screen.dart`). The Pedidos order screen gets a payments dialog (R7).

**Rationale**: spec 054 built the payment view as the place to add these actions later. Its doc comment (payment_detail_screen.dart:35-37) gets updated.

## R3. Reversal: one shared dialog, one shared reverse path

**Decision**:
- **Shared dialog**: move `_ReversalReasonDialog` out of `applied_payments_panel.dart` into a public, localized `showReversalReasonDialog(context, {bool orderHasRefunds = false})` in `presentation/payment/reversal_reason_dialog.dart`. It keeps the 500-character limit and the trimmed non-empty rule. It shows the refund warning (FR-004) when asked.
- **Back-office reverse path**: a new `paymentEditorProvider` notifier (`presentation/payments/payment_editor_controller.dart`) provides `reverse(...)` and `apply(...)`. It calls the repository, then invalidates `paymentDetailProvider(paymentId)`, `paymentApplicationsProvider(paymentId)`, `orderPaymentsControllerProvider(saleId)`, `orderEditorControllerProvider(saleId)` and the `paymentsListControllerProvider` family. It returns the `AppError` instead of throwing, so the dialog can show it.
- **Panel change**: `AppliedPaymentsPanel` gets two optional callbacks.
  - `onReverse(SalePayment)`: when it is null, the panel keeps calling `paymentControllerProvider.reverse`, so the POS is unchanged.
  - `onOpenPayment(int customerPaymentId)`: links each row to its payment.

**Rationale**: `PaymentController.reverse` is POS state. It refreshes `posSaleControllerProvider`, tracks under `posWritesScope`, and handles no errors, so it can't serve Pedidos or Pagos. The dialog's hard-coded Spanish ("Revertir pago", "Motivo") violates §V/i18n once it is shared. Localizing it changes the POS only in that its text now follows the language setting.

**Alternatives**:
- A second, back-office-only dialog. Rejected: it would duplicate the dialog, and the two would drift on the reason rules.
- Give the POS controller a scope parameter. Rejected: it reaches POS-only providers.

## R4. Refund warning before reversing (FR-004)

**Decision**: when the reverse dialog opens, call `customerRefundRepository.list(salesOrderId: saleId, status: RefundStatus.completed, skip: 0, limit: 1)`. If `total > 0`, show the warning. If the lookup fails, show no warning and still allow the reversal; the server doesn't block it.

**Rationale**: `SalesOrderResponse` carries no refund information, and the refund list already filters by order (customer_refund_repository.dart:8-16). Only users with Customer Refunds read can run that query. Without that right the warning is skipped, which is acceptable because the server allows the reversal either way.

## R5. Apply dialog data

**Decision**: add `Future<OutstandingOrderPage> listOutstandingOrders({required int customerId, String? search, int skip = 0, int limit = 20})` to `CustomerPaymentRepository`. It maps `OutstandingOrderResponse` to a new freezed `OutstandingOrder` (id, serial, date, dueDate, currency, total, balance). The dialog filters to the payment's currency on the client. The server has no currency filter, and spec FR-006 wants mismatched orders hidden, not refused.

**Rationale**: today `outstandingBalanceFor` only sums the balances (customer_payment_repository_impl.dart:225-251). The picker needs the rows.

**Amount rule**: default `min(order.balance, payment.unapplied)`. Accept `0 < amount ≤ that min`. `amountChange` is never sent (FR-008). Amounts use `Decimal` through `money.dart`, never `double`.

**Alternatives**:
- A server-side currency filter. Rejected: the client filter covers it, and one customer's open orders in one facility is a small set. Simplified: if a customer has more than one page of foreign-currency orders, a page can come back thin. Revisit if that happens.

## R6. Recording a payment

**Decision**:
- **Repository**: `CustomerPaymentRepository.createPayment` gains `PaymentType type = PaymentType.immediate`. The impl sets `b.paymentType`. The server default is already IMMEDIATE (mbe-api `CustomerPaymentCreate.payment_type`), so POS callers are unchanged.
- **Form**: `RecordPaymentDialog` (`presentation/payments/record_payment_dialog.dart`), a `ResponsiveDialog` launched from a `FilledButton.icon` in the Pagos `CatalogFilterBar.actions`, following the "Nueva devolución" pattern (refunds_list_screen.dart:91-102, 443-510).
- **Fields**:
  - Customer: `CatalogEntityPicker<CustomerListItem>`, as payments_list_screen.dart:386-401.
  - Type: a `SegmentedButton` with credit payment and advance.
  - Method/option: a dropdown built from `facilityPaymentOptionsControllerProvider(facilityId)`, falling back to the `PaymentMethod` enum when the facility has no options. This is the same source as `PaymentMethodGrid`.
  - Reference: a text field, max 50, required when the option says `requiresReference`.
  - Amount: `PaymentAmountField`.
  - Currency: the tenant default, shown read-only. It is selectable only when `multiCurrencyEnabledProvider` is on.
- **Validation**:
  - The walk-in customer is refused through `appSettingsProvider.isGenericCustomer(id)`.
  - Cash requires `currentSessionControllerProvider` with `isValid`. It is re-read with `ref.refresh(...future)` just before saving, as `PaymentController._sessionIsValid` does. A stale session counts as none.
- **Double submit**: a local `_busy` flag disables save, and the dialog is not dismissible while saving.
- **After saving**: close the dialog, invalidate the list family, and `context.push('/sales/payments/$id')`. The existing ticket button (spec 055 FR-001) covers printing.

**Rationale**: everything except the dropdown already exists. A dialog suits §VI: it is a short form launched from the list's toolbar, and the result gets its own route, the payment view.

**Unknown outcome**: when the save fails with a network or timeout `AppError`, the dialog shows a message that the result is unknown and points to Pagos. It does not offer a blind retry.

## R7. Pedidos order screen: a payments dialog, not a new panel

**Decision**:
- **Button**: add a "Pagos" `TextButton` to the `OrderHeaderPanel` trailing group, next to "Ver pedido" and `RefundOrderButton` (order_header_panel.dart:518-539). It shows only for a completed order (`completed` or `paid` status) and only with Customer Payments read.
- **Dialog**: it opens `ResponsiveDialog` → `AppliedPaymentsPanel(saleId, enabled: canUpdate, showChangeAndDate: true, onReverse: …, onOpenPayment: …)`.
  - Reversal runs through `paymentEditorProvider` (R3), which refreshes `orderEditorControllerProvider(saleId)`, so status updates.
  - Opening a payment closes the dialog and pushes `/sales/payments/:id`.
- **Errors**: the 403 handling is copied from `_PaymentsSection` (pos_sale_detail_view.dart:228-239).

**Rationale**: the workspace has no rail of its own. Entrega is an `Expanded(DeliveryStep)`, and adding a rail means restructuring `_StepHost`. A header button reuses the slot spec 057 used for "Devolver", and the dialog is the §VI "dialog launched from a toolbar action" form.

**Known limit**: `isForeignOrder` treats an order with `origin == null` and any payment applied as a register sale, and replaces the whole workspace with `_ForeignOrderNotice` (foreign_order_guard.dart:41-53). So the Pagos button reaches only orders with `origin == backOffice`. Older back-office orders with payments open as foreign, and their payments are reachable from Pagos. This spec doesn't change the guard; that would change spec 041's behavior.

## R8. Error codes (§III, API error text)

The app calls apply and reverse today (POS) but never localized their codes. This feature adds every code the five endpoints can return that isn't in `localizedErrorCodes` yet:

| Code | Endpoint | Params | es | en |
|---|---|---|---|---|
| `payment.exceeds_order_balance` | apply | amount, balance | El monto {amount} supera el saldo del pedido, {balance}. | The amount {amount} is more than the order's balance of {balance}. |
| `payment.exceeds_unapplied` | apply | amount, unapplied | El monto {amount} supera lo que queda por aplicar del pago, {unapplied}. | The amount {amount} is more than the {unapplied} left on the payment. |
| `payment.order_settled` | apply | none | El pedido ya está pagado. | The order is already paid. |
| `payment.order_cancelled` | apply | none | El pedido está cancelado y no se le puede aplicar un pago. | The order is cancelled and can't take a payment. |
| `payment.order_not_completed` | apply | none | El pedido no está confirmado; confírmalo antes de aplicarle un pago. | The order isn't confirmed. Confirm it before applying a payment. |
| `payment.currency_mismatch` | apply | payment_currency, order_currency | El pago es en {payment_currency} y el pedido en {order_currency}. | The payment is in {payment_currency} and the order in {order_currency}. |
| `payment.customer_mismatch` | apply | ids only | El pago es de otro cliente. | The payment belongs to another customer. |
| `payment.application_reversed` | reverse | none | Esta aplicación ya estaba revertida. | This application was already reversed. |

Already localized and reused:
- `cash_session.closed` (create)
- `resource.not_found` (customer, order, payment, application)
- `lock.busy` / `resource.conflict` ("busy, retry")
- `auth.forbidden`
- validation

`payment.already_verified` belongs to verify (#27) and is not added. The final wording is set in implement; the table fixes the codes and params.

## R9. Tests

- **Unit**:
  - `paymentEditorProvider`: invalidations, returned errors.
  - Apply amount rule: default, bounds.
  - Record form validation: walk-in, cash without a session, reference required.
  - `createPayment` sends `payment_type`.
  - `listOutstandingOrders` mapping.
  - Catalog coverage for the eight codes, through the existing `catalog_coverage_test.dart`.
- **Widget**:
  - Payment view: reverse/apply visibility per right and per unapplied amount.
  - Reverse dialog: reason rule, refund warning.
  - Apply dialog: currency filter, amount bounds, refusal shows the localized text and reloads.
  - Record dialog: fields, busy state.
  - Pedidos "Pagos" button visibility and reversal refresh.
  - POS `AppliedPaymentsPanel` still reverses through its controller when `onReverse` is null.
- **Live** (`integration_test/payments_editor_quickstart_test.dart`): the quickstart flows against the dev tenant. Fixtures come from `tool/seed_payment_fixtures.py`, extended with a second outstanding order for the seeded customer.
