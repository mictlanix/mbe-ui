# UI Contracts: Payments Editor (spec 059)

Keys are the test contract. Strings live in both `.arb` files.

## C1. Pagos list: "Registrar pago" (FR-010)

- Placement: `CatalogFilterBar.actions` on `/sales/payments`, before the scope switch.
- Widget: `FilledButton.icon`, key `payments_record_button`, icon `Icons.add`, with a short label at compact widths.
- Shown only with Customer Payments (8) create.
- Tapping it opens C2.

## C2. Record payment dialog (FR-011 to FR-015, US2)

- `ResponsiveDialog`, key `record_payment_dialog`. It can't be dismissed while saving.
- Fields, by key:
  - `record_payment_customer`
  - `record_payment_type` (credit payment / advance segments)
  - `record_payment_method`
  - `record_payment_reference`
  - `record_payment_amount`
- Inline errors name the failing field: missing customer, walk-in customer, missing method, reference required, amount ≤ 0, or cash without an open session. Validation runs when the user presses save. The walk-in customer stays searchable and is refused under the field. A cash-session error links to the sessions list.
- There is no "save and apply" action. The payment view's apply button follows.
- `record_payment_save` is disabled while busy and shows a spinner.
- A server refusal shows the localized message in a `FormErrorBanner`. A network or timeout failure shows "result unknown, check Pagos".
- On success the dialog closes, the Pagos list refreshes, and the app pushes `/sales/payments/:id`.

## C3. Payment view actions (FR-001 to FR-009, US1)

- Applications table: a trailing action column. A live row shows an `IconButton` with key `payment_application_reverse_<applicationId>`, only with Customer Payments update. Reversed rows show no action.
- Summary area: an `OutlinedButton.icon` with key `payment_apply_button`, shown when `unapplied > 0.01`, `payment.facilityId == userFacilityId`, and the user has Customer Payments create. Another facility's payment gets no apply button until mbe-api#308.
- After a successful reverse or apply, the detail, the applications and the list refresh, and a snackbar confirms.
- The doc comment that says the view has no actions (payment_detail_screen.dart:35-37) is updated.

## C4. Reverse dialog, shared by POS, Pagos and Pedidos (FR-002, FR-004)

- `showReversalReasonDialog(context, {required String amount, required String orderLabel, bool orderHasRefunds = false, Future<AppError?> Function(String reason)? submit}) → Future<String?>` returns the trimmed reason, or null if cancelled.
- With `submit`: confirm runs it behind a busy flag (spinner, not dismissible). A returned `AppError` shows in a `FormErrorBanner` and the dialog stays open. Null pops the reason. Without `submit`, confirm pops the reason directly (the POS).
- The header line (key `reversal_subject`) names the formatted amount and the order number (`#id`), for example "$1,500.00 aplicados al pedido #1041". It appears everywhere, the POS included.
- Keys: `reversal_reason_dialog`, `reversal_reason_field` (max 500), `reversal_reason_confirm`, which is disabled while the trimmed text is empty.
- Key `reversal_refund_warning` is shown when `orderHasRefunds`.
- All text is localized (replaces the hard-coded "Revertir pago" / "Motivo").

## C5. Apply dialog (FR-005 to FR-009)

- `ResponsiveDialog`, key `apply_payment_dialog`.
- Header: the payment's unapplied amount.
- Title: "Aplicar pago #{customerPaymentId}", matching the payment view's header.
- Search: key `apply_payment_search` (order number or folio; the server matches either).
- Order list: one row per outstanding order in the payment's currency, keyed `apply_payment_order_<orderId>`. Each row shows the order as `#id` (the label the payment view and snackbars use), its folio when it has one, date, total and balance.
- Empty state: key `apply_payment_empty`.
- Amount: key `apply_payment_amount`, prefilled with `min(balance, unapplied)`. Out-of-bounds values show an inline error.
- Confirm: key `apply_payment_confirm`, disabled with no order picked, with an invalid amount, or while busy.
- On a server refusal the dialog shows the localized message, reloads the orders and the payment, and stays open.

## C6. Pedidos "Pagos" (FR-016 to FR-018, US3)

- `TextButton` with key `sales_order_payments_button`, in the `OrderHeaderPanel` trailing group. Shown for a completed or paid order with Customer Payments read. The label has no count; the list loads when the dialog opens.
- It opens a `ResponsiveDialog` with key `sales_order_payments_dialog` that contains `AppliedPaymentsPanel(enabled: canUpdate, showChangeAndDate: true, onReverse:, onOpenPayment:)`.
- The empty state reads "No se han aplicado pagos" ("No payments have been applied").
- Each row carries a link, `applied_payment_open_<customerPaymentId>`, that closes the dialog and pushes `/sales/payments/:id`.
- After a reversal, the panel and the order's status refresh.

## C7. `AppliedPaymentsPanel` additions

- New optional params: `void Function(SalePayment)? onReverse` and `void Function(int customerPaymentId)? onOpenPayment`.
- With both null, the POS behaves exactly as before, except that the dialog is now localized.

## Routes and objects

No new routes. `/sales/payments` and `/sales/payments/:paymentId` remain gated by Customer Payments (8) read. Actions are gated as in research R1.
