---
description: "Task list for 059-payments-editor"
---

# Tasks: Payments Editor

**Input**: Design documents from `specs/059-payments-editor/`

**Prerequisites**: plan.md, spec.md, research.md (R1–R9), data-model.md, contracts/ui-contracts.md (C1–C7), quickstart.md, wireframes.md (its Open Questions are answered in spec.md Clarifications)

**Tests**: The spec doesn't ask for a test suite as such, but the constitution's quality gates and research R9 require tests. Test tasks sit inside each story, after the code they cover.

**Organization**: Grouped by user story (US1–US3, spec.md). US1 is the MVP: reverse and apply on the payment view. US2 adds recording a payment. US3 adds the Pedidos order screen. Phase 2 holds what two or more stories share.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: parallelizable (different files, no dependency on an incomplete task)
- **[Story]**: US1 move a misapplied payment to the right order · US2 record a credit payment or an advance · US3 see and reverse an order's payments from Pedidos

## Cross-story notes

- **Shared files.** Do these sequentially, not in parallel:
  - `lib/features/sales/presentation/payment/applied_payments_panel.dart`: T007 only.
  - `lib/features/sales/presentation/payments/payment_detail_screen.dart`: T011 (US1) only.
  - `lib/features/sales/presentation/payments/payments_list_screen.dart`: T015 (US2) only.
  - `lib/features/sales/domain/repositories/customer_payment_repository.dart` and `lib/features/sales/data/customer_payment_repository_impl.dart`: T005 only.
  - `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb`: every key is added once, in T002. If a later task needs another, add it there and run `flutter gen-l10n`. Never hand-edit `lib/l10n/app_localizations*.dart`.
- **Generated code.** After editing a freezed or `@riverpod` file, run `dart run build_runner build --delete-conflicting-outputs` at the repo root. Never run two build_runner processes at once: tasks that both need it are not marked [P] against each other. No client regeneration is needed: `CustomerPaymentsApi`, `ApplicationCreate`, `ReversalRequest`, `OutstandingOrderResponse` and `CustomerPaymentCreate.paymentType` already exist in `lib/generated/openapi`.
- **Formatting.** Format only the files you changed (`dart format <files>`). Never `dart format .`, and never format `lib/generated/`.
- **Amounts and dates** go through `formattersProvider` (constitution §V). No `NumberFormat`, no `toStringAsFixed`. Amount arithmetic goes only through `features/sales/domain/money.dart` (`compareAmounts`, `subtractAmounts`, `tryParseAmount`, `isZeroAmount`). Never use `double`.
- **Spacing tokens, not literals** (`Theme.of(context).spacing`). No automated guard catches a literal, so check it in review.
- **`unapplied` is always the server's** (spec 033, mbe-api#276 closed). Never recompute it from the applications list.
- **Never match server prose** (§III). Show refusals through `AppError.localizedMessage` / `FormErrorBanner`, which build the text from the error's `code`. Recognition keys on the code.
- **Simplifications.** Any shortcut carries a comment `// simplified: <ceiling>, <what to do when it binds>`. R5 already names one: the client-side currency filter on outstanding orders.
- **Mirror, don't copy blindly.** Closest precedents:
  - Create dialog with a busy flag: `_NewRefundDialogState` in `refunds/refunds_list_screen.dart` (lines ~443-510).
  - Toolbar create button: `refunds_list_screen.dart` lines ~65-102, and `payments_list_screen.dart` `actions:` (lines ~117-140).
  - Customer picker: `payments_list_screen.dart` lines ~386-401.
  - Payment options for a facility: `payment/facility_payment_options_controller.dart`, and the fallback to `PaymentMethod` tenders in `payment/payment_method_grid.dart`.
  - Cash-session read before a write: `PaymentController._sessionIsValid`, and `PosSessionBlockedBanner` in `pos_gate_screen.dart`.
  - Read-only embed of the applied-payments panel with the 403 text: `_PaymentsSection` in `pos_sale_detail_view.dart` (lines ~219-273).
  - Widget harness: `payment_detail_screen_test.dart`, `payments_list_screen_test.dart`, `order_header_refund_button_test.dart`, `order_workspace_cancel_test.dart`.

---

## Phase 1: Setup

**Purpose**: a known-good baseline, so later failures are attributable.

- [ ] T001 Run `flutter analyze` and the existing tests this feature touches: `test/widget/features/sales/payment_detail_screen_test.dart`, `payments_list_screen_test.dart`, `payments_layout_test.dart`, `order_header_refund_button_test.dart`, `order_workspace_foreign_order_test.dart`, `test/unit/features/sales/customer_payment_repository_impl_test.dart`, `payment_controller_test.dart`, `payment_detail_controller_test.dart`, `test/unit/core/errors/catalog_coverage_test.dart`, plus any existing test for `AppliedPaymentsPanel` or `pos_sale_detail_view` (find them with `grep -rl AppliedPaymentsPanel test`). Note any pre-existing failures so they aren't blamed on this feature. The six failures in `test/golden/core_widgets_golden_test.dart` are already known.

---

## Phase 2: Foundational (blocks all user stories)

**Purpose**: the pieces two or more stories use: strings and error codes, the repository gaps, the shared reverse dialog, the back-office write controller and the reverse flow.

- [ ] T002 Add every new string to `lib/l10n/app_es.arb` and `lib/l10n/app_en.arb`, then run `flutter gen-l10n`. Group the keys by prefix so the later tasks can find them:
  - **Error codes (R8)** with descriptions "mbe-api error code `<code>` (spec 059)", and the placeholders in the research table: `apiErrorPaymentExceedsOrderBalance` (`amount`, `balance`), `apiErrorPaymentExceedsUnapplied` (`amount`, `unapplied`), `apiErrorPaymentOrderSettled`, `apiErrorPaymentOrderCancelled`, `apiErrorPaymentOrderNotCompleted`, `apiErrorPaymentCurrencyMismatch` (`paymentCurrency`, `orderCurrency`), `apiErrorPaymentCustomerMismatch`, `apiErrorPaymentApplicationReversed`. Use the wording in research R8.
  - **Reverse dialog:** title "Revertir aplicación", the subject line "{amount} aplicados al pedido #{order}", the reason label "Motivo", the refund warning "Este pedido tiene devoluciones. Revertir el pago no deshace la devolución.", confirm "Revertir", the snackbar "Aplicación revertida".
  - **Apply dialog:** title "Aplicar pago {folio}", "Sin aplicar: {amount}", the folio search hint, column headers, "Monto a aplicar", "Máximo {amount}", the "No puede ser más de {amount}" error, the empty state "Este cliente no tiene pedidos por pagar en {currency}.", confirm "Aplicar", the snackbar "Pago aplicado a #{order}", and the "Aplicar a pedido" button label.
  - **Record dialog:** title "Registrar pago", the button and its short form "Pago", field labels (customer, type, method, reference, amount, currency), type labels "Abono a crédito" and "Anticipo", confirm "Registrar", the busy label "Registrando…", every validation message in wireframes.md (walk-in customer, missing customer, missing method, reference required, amount above zero, cash needs an open session today, with the "Ir a cajas" link label), and the unknown-result message "No sabemos si el pago se registró: se perdió la conexión. Búscalo en Pagos antes de reintentar."
  - **Pedidos:** the "Pagos" button, the dialog title "Pagos del pedido {order}", "No se han aplicado pagos a este pedido.", and the tooltip for the payment link.
  English text follows the Spanish meaning. Keep es and en in step, and keep the wording consistent with the existing `payments*`, `refunds*` and `posApplied*` keys.

- [ ] T003 Localize the eight `payment.*` codes (research R8, §III). Depends on T002.
  - In `lib/core/errors/localize_problem.dart`, add the eight codes to `localizedErrorCodes` and to the `localizeProblem` switch:
    - `paymentPeriodExceedsOrderBalance` and `paymentPeriodExceedsUnapplied` through `_ap2` with `_money(problem, 'amount', fmt)` and `_money(problem, 'balance' | 'unapplied', fmt)`.
    - `paymentPeriodCurrencyMismatch` through `_ap2` with `problem.stringParam('payment_currency')` and `stringParam('order_currency')`.
    - The other five are fixed sentences.
  - In `test/unit/core/errors/problem_fixtures.dart`, add a fixture for each. The two money codes get a decimal `amount` and `balance` / `unapplied`; currency mismatch gets `payment_currency: 'MXN'`, `order_currency: 'USD'`; customer mismatch gets `payment_customer_id: 1, order_customer_id: 2` and has a fixed message.
  - In `test/unit/core/errors/catalog_coverage_test.dart`, add `payment.exceeds_order_balance`, `payment.exceeds_unapplied` and `payment.currency_mismatch` to `needParams`, and change `expect(checked, 96)` to 104.
  - In `specs/058-localized-api-errors/contracts/code-scope.tsv`, flip the eight rows from `OUT` to `IN`, with the routes that now call them (`POST /customer-payments/{}/applications`, `POST /customer-payments/{}/applications/{}/reverse`) and a note "reachable from … UI route(s)". Leave `payment.already_verified` as `OUT` (it belongs to verify, roadmap#27).
  - Verify: `flutter test test/unit/core/errors`.

- [ ] T004 [P] Create `lib/features/sales/domain/entities/outstanding_order.dart` (freezed): `OutstandingOrder { id, serial?, date, dueDate, currency, total, balance }` with `fromResponse(api.OutstandingOrderResponse)` (amounts kept as the API's strings, as `CustomerPayment` does) and `OutstandingOrderPage { items, total }`, per data-model.md. Run build_runner. Add `test/unit/features/sales/outstanding_order_entity_test.dart` for the mapping, including a null `serial` and the `dueDate`.

- [ ] T005 `CustomerPaymentRepository` gaps (R5, R6). Depends on T004.
  - In `lib/features/sales/domain/repositories/customer_payment_repository.dart` and `lib/features/sales/data/customer_payment_repository_impl.dart`:
    - Add `PaymentType type = PaymentType.immediate` to `createPayment`, sent as `paymentType` on `CustomerPaymentCreate`. Use `lib/features/sales/domain/payment_type.dart`, and map to the generated `api.PaymentType` the way `_methodToApi` does for methods.
    - Add `listOutstandingOrders({required int customerId, String? search, int skip = 0, int limit = 20})` returning `OutstandingOrderPage`, over `listOutstandingOrdersApiV1CustomerPaymentsOutstandingOrdersGet`, with `_toAppError` on `DioException`. Leave `outstandingBalanceFor` as it is.
  - In `test/unit/features/sales/customer_payment_repository_impl_test.dart`: `createPayment` sends `payment_type` for credit payment and advance, and the POS default sends IMMEDIATE (1); `listOutstandingOrders` passes `customer`, `search`, `skip` and `limit` and maps rows and total.
  - Verify the existing `payment_controller_test.dart` still passes unchanged.

- [ ] T006 [P] Create `lib/features/sales/presentation/payment/reversal_reason_dialog.dart` (C4): `showReversalReasonDialog(BuildContext, {required String amount, required String orderLabel, bool orderHasRefunds = false, Future<AppError?> Function(String reason)? submit}) → Future<String?>`. Depends on T002.
  - It is a `ResponsiveDialog` keyed `reversal_reason_dialog`, with the subject line (`reversal_subject`), `reversal_reason_field` (max 500) and `reversal_reason_confirm`, disabled while the trimmed text is empty (FR-002).
  - It shows `reversal_refund_warning` when `orderHasRefunds` (FR-004).
  - Without `submit`: confirm pops the trimmed reason, as the POS dialog does today.
  - With `submit`: confirm runs it with a local busy flag (spinner, not dismissible), shows a non-null `AppError` in a `FormErrorBanner` and stays open, and pops the reason when it returns null. This is what keeps the dialog open on a refusal, as the wireframes draw it.
  - Update `specs/059-payments-editor/contracts/ui-contracts.md` C4 with the `submit` parameter (the wireframes' refused state needs it).
  - Add `test/widget/features/sales/reversal_reason_dialog_test.dart`: confirm disabled for empty and whitespace-only text; the subject names amount and order; the warning shows only when asked; `submit` error shows the banner and keeps the dialog open; `submit` success pops the reason; a double tap on confirm calls `submit` once.

- [ ] T007 `AppliedPaymentsPanel` (C7, R3). Depends on T006.
  - In `lib/features/sales/presentation/payment/applied_payments_panel.dart`, add `void Function(SalePayment payment)? onReverse` and `void Function(int customerPaymentId)? onOpenPayment`.
  - Remove the private `_ReversalReasonDialog`.
  - With `onReverse == null` (the POS), the reverse tap opens the shared dialog with the payment's formatted amount and `#<saleId>` as the order label, then calls `paymentControllerProvider.notifier.reverse` exactly as today. Don't change its error handling.
  - With `onReverse` set, the tap calls it and does nothing else.
  - With `onOpenPayment` set, each row shows a link keyed `applied_payment_open_<customerPaymentId>` that calls it.
  - Add `test/widget/features/sales/applied_payments_panel_test.dart`. Pin the POS path: with `onReverse` null, confirming the dialog calls `PaymentController.reverse` with the same arguments as before. Also cover: `onReverse` is called and `PaymentController` is not touched; the link appears only with `onOpenPayment`; no reverse icon on a cancelled row or with `enabled: false`.

- [ ] T008 Create `lib/features/sales/presentation/payments/payment_editor_controller.dart` (R3): a `@riverpod` notifier `paymentEditor` with two mutations that call `customerPaymentRepositoryProvider` and return `AppError?` (null on success) instead of throwing. Depends on T005. Run build_runner.
  - `reverse({required int paymentId, required int applicationId, required int saleId, required String reason})`
  - `apply({required int paymentId, required int saleId, required String amount})`, sending no change.
  - After either call, success or failure, invalidate: `paymentDetailProvider(paymentId)`, `paymentApplicationsProvider(paymentId)`, `orderPaymentsControllerProvider(saleId)`, `orderEditorControllerProvider(saleId)`, and the `paymentsListControllerProvider` family. A refusal leaves state unchanged, so the invalidation is what reloads what the refusal concerned (FR-009).
  - Do not touch `posSaleControllerProvider` or `posWritesScope`.
  - Add `test/unit/features/sales/payment_editor_controller_test.dart` with a mocked repository: success returns null and invalidates each provider; a refusal returns the `AppError` and still invalidates; the repository receives the right ids and a reason that is passed through trimmed by the caller, not here.

- [ ] T009 Create `lib/features/sales/presentation/payments/reverse_application_flow.dart` (FR-004, FR-017). Depends on T006, T008.
  - `orderHasRefundsProvider` is a `FutureProvider.family<bool, int>` keyed by the sale id. It returns false without Customer Refunds read; otherwise it calls `customerRefundRepositoryProvider.list(salesOrderId: id, status: RefundStatus.completed, skip: 0, limit: 1)` and returns `total > 0`. Any error returns false (R4).
  - `reverseApplicationFlow(BuildContext, WidgetRef, {required int paymentId, required int applicationId, required int saleId, required String amount})` reads that provider, opens `showReversalReasonDialog` with `submit: (reason) => ref.read(paymentEditorProvider.notifier).reverse(...)`, and on a reason result shows the "Aplicación revertida" snackbar.
  - Add `test/unit/features/sales/reverse_application_flow_test.dart` for the provider: no right → false without calling the repository; total 0 → false; total > 0 → true; a failing lookup → false.

**Checkpoint**: strings, error codes, repository, shared dialog, panel callbacks, controller and flow are in place. Run `flutter analyze` and `flutter test test/unit/features/sales test/unit/core/errors`.

---

## Phase 3: User Story 1 — Move a misapplied payment to the right order (Priority: P1) 🎯 MVP

**Goal**: on the payment view, reverse an application with a reason, then apply the freed money to another outstanding order of the same customer.

**Independent test**: with the seeded payment applied to one order, reverse that application, then apply the freed amount to the spare order. Both orders' balances and paid status, and the payment's unapplied amount, are right (quickstart steps 1–4).

- [ ] T010 [US1] Create `lib/features/sales/presentation/payments/apply_payment_dialog.dart` (C5, FR-005 to FR-009): `showApplyPaymentDialog(BuildContext, CustomerPayment payment)`.
  - A `ResponsiveDialog` keyed `apply_payment_dialog`. The header shows `Sin aplicar` from `payment.unapplied`.
  - The folio search (`apply_payment_search`) calls `listOutstandingOrders(customerId: payment.customerId, search:)`, 20 per page. Keep only rows whose currency equals the payment's (`// simplified: a customer with more than one page of foreign-currency orders can get a thin page; add a server filter if it happens`).
  - Rows are single-choice, keyed `apply_payment_order_<orderId>`, and show folio, date, total and balance. States: loading and load error through `CatalogListStateView`, and the empty state `apply_payment_empty`.
  - The amount field (`apply_payment_amount`, `PaymentAmountField`) is prefilled with the smaller of the order's balance and `payment.unapplied` (`compareAmounts`). Show "Máximo {amount}", and an inline error for an amount that is not above zero or is above the bound. Put the bound rule in a top-level pure function (`applyAmountError` or similar) so it can be unit-tested.
  - Confirm (`apply_payment_confirm`) is disabled with no order, an invalid amount, or while busy. It calls `paymentEditorProvider.notifier.apply(...)`. On an `AppError`, show it in a `FormErrorBanner`, clear the selection, reload the orders, and stay open. On success, close and show the "Pago aplicado a #{order}" snackbar.
  - The dialog is not dismissible while busy.
  - Add `test/widget/features/sales/apply_payment_dialog_test.dart`: only same-currency orders are listed; the amount defaults to the smaller of balance and unapplied; out-of-bounds and zero amounts disable confirm and show the error; the empty state; a refusal shows the localized text, reloads and stays open; a double tap applies once. Add a unit test for the pure bound function in the same file or `test/unit/features/sales/apply_amount_test.dart`.

- [ ] T011 [US1] Edit `lib/features/sales/presentation/payments/payment_detail_screen.dart` (C3, FR-001, FR-003, FR-005, FR-019). Depends on T009, T010.
  - In `_ApplicationsSection`, add a trailing action column when the user has Customer Payments update. A live row shows an `IconButton` keyed `payment_application_reverse_<applicationId>` that calls `reverseApplicationFlow(...)` with `payment.customerPaymentId`, the application's id and sale id, and its formatted amount. Reversed rows show nothing. With no update right, drop the column rather than leaving it empty. Size the column the way spec 055 sizes the row-actions column.
  - In the summary area, add an `OutlinedButton.icon` keyed `payment_apply_button`, labelled "Aplicar a pedido". Show it only when `payment.unapplied > 0.01`, `payment.facilityId == ref.watch(userFacilityIdProvider)` and the user has Customer Payments create (another facility's payment gets none, until mbe-api#308). It opens `showApplyPaymentDialog`.
  - Update the doc comment at lines ~35-37, which says the view deliberately has no actions.
  - Do not change the ticket button or the facility guard.

- [ ] T012 [P] [US1] Extend `test/widget/features/sales/payment_detail_screen_test.dart`:
  - reverse icon only on live rows and only with update;
  - the column is absent without update;
  - apply button hidden when unapplied is 0 or 0.01, when the payment is of another facility, and without create;
  - the apply button shown otherwise;
  - confirming a reversal calls `paymentEditor.reverse` with the application's ids and the typed reason;
  - the existing ticket-button tests still pass.

**Checkpoint**: US1 works on its own. Run `flutter test test/widget/features/sales/payment_detail_screen_test.dart test/widget/features/sales/apply_payment_dialog_test.dart`.

---

## Phase 4: User Story 2 — Record a credit payment or an advance (Priority: P2)

**Goal**: from Pagos, record a credit payment or advance, then land on its view to apply and print it.

**Independent test**: record a credit payment for the seeded customer. It appears in Pagos with its folio and the full amount unapplied; apply it to an order; print its ticket (quickstart steps 5–7).

- [ ] T013 [US2] Create `lib/features/sales/presentation/payments/record_payment_dialog.dart` (C2, R6, FR-011 to FR-015): `showRecordPaymentDialog(BuildContext)`. Depends on T002, T005.
  - A `ResponsiveDialog` keyed `record_payment_dialog`, with fields keyed `record_payment_customer`, `record_payment_type`, `record_payment_method`, `record_payment_reference`, `record_payment_amount`, laid out with `ResponsiveFormGrid`.
  - **Customer:** `CatalogEntityPicker<CustomerListItem>`, as in `payments_list_screen.dart`, shown as "code — name".
  - **Type:** a `SegmentedButton` with credit payment and advance only. It defaults to credit payment.
  - **Method:** a dropdown built from `facilityPaymentOptionsControllerProvider(userFacilityId)`. It falls back to the `PaymentMethod` tenders when the facility has none, as `payment_method_grid.dart` does. Picking an option carries the method code, `paymentMethodOptionId` (sent as `paymentCharge`) and `requiresReference`.
  - **Reference:** max 50. Required when the option says so.
  - **Amount:** `PaymentAmountField`.
  - **Currency:** read-only text of the tenant default. A dropdown only when `multiCurrencyEnabledProvider` is on.
  - **Validation on press** (errors under the field): no customer; the walk-in customer (`ref.read(appSettingsProvider).isGenericCustomer(id)`); no method; reference required and empty; amount not above zero (`tryParseAmount`, `isZeroAmount`); method is cash and `await ref.refresh(currentSessionControllerProvider.future)` is not `isValid` (a failed read counts as invalid; link "Ir a cajas" to the sessions list).
  - **Save:** call `createPayment(customer:, amount:, method:, currency:, paymentCharge:, reference:, type:)` behind a local `_busy` flag, with a spinner on the action, and `dismissible: !_busy`. On success, close, invalidate `paymentsListControllerProvider`, and `context.push('/sales/payments/$id')`.
  - **Errors:** an `AppError` shows in a `FormErrorBanner` with the form kept as it was. For `NetworkError` (the network/timeout variant in `lib/core/errors/app_error.dart`), show the "unknown result" message instead, and no retry.
  - Add `test/widget/features/sales/record_payment_dialog_test.dart`: each validation message; cash without a session is refused while transfer is saved without one; the walk-in customer is refused; the request carries the chosen type, method, `paymentCharge` and reference; a double tap creates one payment; a server refusal shows the localized banner; a network failure shows the unknown-result message; success navigates to the new payment.

- [ ] T014 [US2] Edit `lib/features/sales/presentation/payments/payments_list_screen.dart` (C1, FR-010): add a `FilledButton.icon` keyed `payments_record_button` (icon `Icons.add`, short label "Pago" when `LayoutBreakpoints.isCompact(context)`) at the start of `CatalogFilterBar.actions`, shown only when `access.can(SystemObject.customerPayments, AccessRight.create)`. It opens `showRecordPaymentDialog`. Don't touch the scope switch or the list's behavior.

- [ ] T015 [P] [US2] Extend `test/widget/features/sales/payments_list_screen_test.dart`: the button is present with create and absent without it; the compact label is "Pago"; it opens the record dialog; the scope switch still shows only for Payments Editor readers.

**Checkpoint**: US1 and US2 both work. Run `flutter test test/widget/features/sales/record_payment_dialog_test.dart test/widget/features/sales/payments_list_screen_test.dart`.

---

## Phase 5: User Story 3 — See and reverse an order's payments from Pedidos (Priority: P3)

**Goal**: from a back-office order in Pedidos, see the payments applied to it, reverse one, and open its payment.

**Independent test**: open a back-office order with an applied payment, open "Pagos", reverse an application. The list, the order's status and its balance refresh, and the payment link opens the Pagos view (quickstart step 8).

- [ ] T016 [US3] Create `lib/features/sales/presentation/orders/order_payments_dialog.dart` (C6, R7, FR-016 to FR-018): `showOrderPaymentsDialog(BuildContext, {required int orderId})`.
  - A `ResponsiveDialog` keyed `sales_order_payments_dialog` that contains `AppliedPaymentsPanel(saleId: orderId, enabled: canUpdate, showChangeAndDate: true, onReverse: …, onOpenPayment: …)`.
  - `canUpdate` is `access.can(customerPayments, update)`.
  - `onReverse` calls `reverseApplicationFlow(...)` with `payment.customerPayment`, `payment.id`, `orderId` and the payment's formatted amount.
  - `onOpenPayment` closes the dialog and `context.push('/sales/payments/$id')`.
  - Without Customer Payments read, or on a 403 from `orderPaymentsControllerProvider`, show `posSaleDetailPaymentsForbidden`, as `_PaymentsSection` does. With no applications, show the empty text "No se han aplicado pagos a este pedido." (check how the panel renders an empty list today and reuse it if it already does).

- [ ] T017 [US3] Edit `lib/features/sales/presentation/orders/order_header_panel.dart`: add a `TextButton` keyed `sales_order_payments_button`, labelled "Pagos", to the trailing group beside "Ver pedido" and `RefundOrderButton` (lines ~518-539). Show it only for an order whose status is completed or paid and only with Customer Payments read. No count in the label. It opens `showOrderPaymentsDialog(orderId: sale.id)`. Don't change the foreign-order guard (R7).

- [ ] T018 [P] [US3] Tests (depends on T016, T017):
  - Add `test/widget/features/sales/order_header_payments_button_test.dart`, modelled on `order_header_refund_button_test.dart`: the button is shown for completed and paid orders with read; hidden for a draft, a cancelled order and without read.
  - Add `test/widget/features/sales/order_payments_dialog_test.dart`: lists live and reversed applications; the reverse icon needs update; reversing calls the controller and invalidates the order editor provider so the status refreshes; the payment link pops the dialog and pushes `/sales/payments/<id>`; empty text; the forbidden text on a 403.
  - Check `test/widget/features/sales/order_workspace_foreign_order_test.dart` still passes: an origin-null order with a payment still shows the foreign notice.

**Checkpoint**: all three stories work. Run `flutter test test/widget/features/sales`.

---

## Phase 6: Polish and cross-cutting

- [ ] T019 [P] Extend `tool/seed_payment_fixtures.py` so the seeded customer also has a spare outstanding back-office order (completed, unpaid, MXN, same facility) next to the one `QA055-SEED` is applied to. It prints the payment, the applied order and the spare order, and creates nothing when run again. Keep it runnable after `seed_test_accounts.py` on a reset database.

- [ ] T020 Add `integration_test/payments_editor_quickstart_test.dart` against the dev tenant, modelled on `integration_test/payments_quickstart_test.dart` (macOS traps: see the frame-stall watchdog and finder notes there). It follows quickstart steps 1, 2, 5, 6, 8, 9 and 10, discovering fixtures at runtime from the seed output. It ends with `==== RESULTS ====` and every step `PASS`. Steps 3 (a concurrent refusal) and 4 (refund warning) stay manual, because the tenant has no order with a completed refund that this seed controls. Depends on T011, T013, T017, T019.

- [ ] T021 Final checks.
  - `flutter analyze` is clean.
  - `flutter test test/unit test/widget` passes, apart from the six known golden failures.
  - Format only the changed files (`dart format <files>`).
  - Run the live test when the dev backend is up.
  - Walk quickstart.md. Record any step you couldn't run.
  - Confirm mbe-api#308 is still open and referenced from the plan and T011.

- [ ] T022 Write `specs/059-payments-editor/pr-description.md` with a "Roadmap" section: `Closes mictlanix/mbe-roadmap#26`. List the follow-ups: mbe-api#308 (apply on another facility's payment), and the Pedidos limit for older orders with no origin (research R7). End it with the attribution line from the session's instructions.

---

## Dependencies and execution order

```text
T001 ─▶ T002 ─┬─▶ T003
              ├─▶ T006 ─▶ T007
              └─▶ T013 (also needs T005)
        T004 ─▶ T005 ─▶ T008 ─▶ T009 (also needs T006)
                      └──────────────▶ T013

T009 + T010 ─▶ T011 ─▶ T012            (US1)
T013 ─▶ T014 ─▶ T015                   (US2)
T009 + T007 ─▶ T016 ─▶ T017 ─▶ T018    (US3)
T011 + T013 + T017 + T019 ─▶ T020 ─▶ T021 ─▶ T022
```

- **US1** needs T002 to T010. **US2** needs only T002, T005 and its own tasks, so it can start before US1 finishes. **US3** needs T007 and T009.
- **Parallel**:
  - In Phase 2: T004 and T006 can run beside T002/T003.
  - In the stories: T012, T015 and T018 run beside the next story's code.
  - T019 can run any time.

## Implementation strategy

- **MVP**: Phases 1–3 (T001–T012). That delivers the core correction, reverse then apply, on the payment view.
- **Then**: US2 (recording), then US3 (Pedidos). Each is demoable alone, and neither changes US1.
- **Order of risk**: T007 touches the register, so run the POS panel tests and the POS payment tests right after it.

## Task count

22 tasks:

| Phase | Tasks |
|---|---|
| Setup | 1 |
| Foundational | 8 |
| US1 | 3 |
| US2 | 3 |
| US3 | 3 |
| Polish | 4 |
