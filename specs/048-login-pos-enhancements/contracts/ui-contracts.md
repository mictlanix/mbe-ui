# UI Contracts: Login & POS Sales Enhancements

**Spec**: [spec.md](./spec.md) | **Data model**: [data-model.md](../data-model.md)

Widget keys listed here are test contracts. Strings live in both `lib/l10n/app_en.arb` and `app_es.arb`, and each new key's `description` cites spec 048.

---

## C1: `NewPasswordFields` (Story 1 + 4) — `features/auth/presentation/widgets/new_password_fields.dart`

| Parameter | Type | Notes |
|---|---|---|
| `newFieldKey` | `Key` | default `Key('new_password_field')`. The admin form passes `Key('password_field')` |
| `newLabel` | `String` | e.g. `newPasswordLabel`, or `passwordLabel` for admin create |
| `policy` | `AsyncValue<PasswordPolicy>` | drives the checklist |
| `enabled` | `bool` | |
| `onNewChanged`, `onConfirmChanged` | `ValueChanged<String>` | |
| `onSubmitted` | `VoidCallback?` | the confirmation field's submit action |

**Renders**:
1. The new-password field (obscured).
2. The confirmation field, `Key('new_password_confirm_field')`, labeled `confirmNewPasswordLabel`. When non-empty and different, its validator shows `passwordMismatchError`. It is re-validated whenever the new-password field changes (FR-003).
3. The rule checklist, `Key('password_rules')`. It has one row per `policy.rules` entry, keyed `password_rule_<name>`:
   - a met rule shows a check icon in the `primary` color;
   - an unmet rule shows a circle icon in the `onSurfaceVariant` color.

   When `policy` holds an error, the checklist shows `passwordRulesUnavailable` and its rows are hidden. While `policy` is loading, the checklist is hidden.

**Strings**:
- `confirmNewPasswordLabel`
- `passwordMismatchError`
- `passwordRuleMinLength(count)`
- `passwordRuleUpper`, `passwordRuleLower`, `passwordRuleDigit`, `passwordRuleSymbol`
- `passwordRulesUnavailable`

**Used by**:
- `ChangePasswordScreen`
- `ForgotPasswordScreen` (after the token field)
- `UserDetailScreen` (create mode only)
- the forced-change screen (C2)

The old `< 6` validators and `fieldMinLength6` / `userPasswordLengthError` usages on these forms are removed. The keys themselves stay if other screens use them.

---

## C2: Forced password change (Story 5, **blocked on #240**)

- **Route** `/auth/password-required`: requires a session (it is added to the `requiresSession` check).
- **Redirect**:
  - authenticated and `user.mustChangePassword`: any other location goes to `/auth/password-required`;
  - authenticated and not flagged: `/auth/password-required` goes to `/`.
- **Screen** `ChangePasswordScreen(forced: true)`:
  - No back arrow (`automaticallyImplyLeading: false`) and `PopScope(canPop: false)`.
  - Title `passwordRequiredTitle`. The body starts with `passwordRequiredExplanation`.
  - Fields: current password (`current_password_field`), then C1.
  - Logout button `Key('userMenuLogout')` calls `authProvider.notifier.signOut()`.
  - On success, it calls `AuthNotifier.reloadCurrentUser()`. No `_SuccessView` is shown, and the redirect takes the user to `/`.
- **Interceptor**: a `403` whose detail is `password_change_required` invokes `onPasswordChangeRequired`, which sets the flag. The request still fails with its normal error. The redirect then moves the user.

---

## C3: POS read-only sale detail (Story 2): `features/sales/presentation/pos_sale_detail_view.dart`

**When it shows**: `PosStepState.detail == true` (R6 predicate). In that case:
- The workspace body renders `PosSaleDetailView(sale)`, keyed `Key('pos_sale_detail')`.
- The AppBar keeps Back, and its title is `posSaleDetailTitle`.
- These are **not** rendered:
  - `OpenSalesSelector`
  - `_StepIndicator`
  - `PosSessionBlockedBanner`
  - any step host
  - any edit, payment or cancel action

**Content**:
1. **Facts strip**, `Key('pos_sale_detail_facts')`:
   - customer name (`posCustomerNameLabel`);
   - date (`posSaleDetailDateLabel`, `fmt.display.dateTime`);
   - register (`posSaleDetailRegisterLabel`, `UserSettings.pointSaleName`);
   - salesperson (`salesOrderSalespersonLabel`, display name or the id as fallback).
2. **Lines**: `SaleLineRow` on wide screens, `SaleLineCard` on compact ones. Both use `enabled: false` and `stockGate: const StockGate()`.
3. **Totals**: `SaleTotalsBar(showAction: false)`.
4. **Payments**, `Key('pos_sale_detail_payments')`:
   - With `customerPayments` read: `AppliedPaymentsPanel(enabled: false, showChangeAndDate: true)` (method, amount, change, date).
   - Without it, or when the call returns `403`: the text `posSaleDetailPaymentsForbidden`, and the provider is not watched.
5. **Ticket action**: a `FilledButton.tonalIcon`, `Key('pos_sale_detail_ticket')`, labeled with the existing `posSaleViewTicketTooltip`. It opens the `saleTicket` preview (which has Print). It is shown only if `canOpenDocument(access, DocumentKind.saleTicket)`.

**Layout**:
- Expanded: the lines and totals on the left, and a payments rail on the right, matching `PaymentStep`'s proportions.
- Compact (390 px): a single scrolling column with no horizontal scroll.

**New strings**:
- `posSaleDetailTitle`
- `posSaleDetailDateLabel`
- `posSaleDetailRegisterLabel`
- `posSaleDetailPaymentsForbidden`
- `posPaymentDateLabel`

`AppliedPaymentsPanel`'s hard-coded load error is replaced with the existing `posAppliedPaymentsLoadError`.

---

## C4: Warehouse pop-up, other-facilities section (Story 3): `capture/warehouse_picker_dialog.dart`

- **Signature**: `showWarehousePicker(..., required int facilityId)`. The caller, `sale_line_editing.dart`, passes the sale's facility.
- **Visibility**: the section shows only when `stock != null && stock.stockable`.
- **Section**: keyed `Key('warehouse_other_facilities')`, below the sale facility's list and inside the same scroll area (capped at about 420 px).
  - **Header**: `posWarehousePickerOtherFacilities` once facility data is present. Before #242, the single null group's heading is `posWarehousePickerOtherWarehouses`.
  - **Group subheader**: the facility name (`labelMedium`, `onSurfaceVariant`).
  - **Rows**: `ListTile(enabled: false)` with no `onTap`, keyed `warehouse_other_<warehouseId>`. Each has `Icons.store_outlined`, the warehouse name (or `#id`), and trailing `fmt.field.quantity(available)`.
  - **Empty**: when there are no groups, the section shows `posWarehousePickerOtherNone`.
- **Selection**: tapping another facility's row pops nothing and leaves the selection unchanged.

**New strings**:
- `posWarehousePickerOtherFacilities`
- `posWarehousePickerOtherWarehouses`
- `posWarehousePickerOtherNone`
