# Research: Login & POS Sales Enhancements

**Spec**: [spec.md](./spec.md) | **Date**: 2026-10-18

Each entry gives the decision, why it was chosen, and what was rejected. File references are as of `main` @ `8b96e23`.

---

## R1 — One shared widget for the new-password fields (Story 1)

**Decision**: Add `lib/features/auth/presentation/widgets/new_password_fields.dart` (`NewPasswordFields`). It renders the new-password field, a confirmation field (`new_password_confirm_field`), and later the policy checklist (R2). All four password-setting forms use it.
- **Re-check on change**: it keeps a `GlobalKey<FormFieldState>` on the confirmation field. When the new password changes and the confirmation is non-empty, it calls `validate()` on the confirmation (FR-003).
- **Existing test keys**: the new-password key is a parameter, because the admin form uses `password_field` and the account forms use `new_password_field`.
- **Two-layer validation stays**: each controller (`ChangePasswordController`, `RecoveryController`, `UserFormController`) gets `confirmPassword`, `confirmPasswordChanged`, and a guard in `submit()`/`save()`. The admin form adds `UserFormErrorCode.passwordMismatch`.

**Rationale**: FR-003 is the part a field-by-field approach gets wrong: today each field validates only itself (`change_password_screen.dart:79-85`). One widget fixes it once for all three existing forms and the forced-change screen (R4).

**Alternatives rejected**:
- *A confirmation field added to each form separately*: this repeats the cross-field re-validation three times.
- *Controller-only validation*: it loses the inline message on the field (FR-002).

---

## R2 — Password policy: a domain entity read from the server (Story 4)

**Decision**:
- **Entity**: a freezed `PasswordPolicy {minLength, requireUpper, requireLower, requireDigit, requireSymbol}` in `features/auth/domain/entities/password_policy.dart`. It has `enum PasswordRule {minLength, upper, lower, digit, symbol}`, a pure `Set<PasswordRule> unmet(String)`, and `List<PasswordRule> get rules`.
- **Source**: `AuthRepository.passwordPolicy()` calls the generated `AuthApi` operation for `GET /auth/password-policy` and maps `PasswordPolicyResponse` (`lib/generated/openapi/lib/src/model/password_policy_response.dart`). It is exposed as `passwordPolicyProvider`.
- **No login needed**: the endpoint is public. The generated op has `'secure': []`, and `AuthInterceptor` attaches a bearer token only when one is stored (`core/network/auth_interceptor.dart:28-31`). So the pre-login Forgot screen works, and so does a flagged user (the endpoint doesn't go through the 403 check).
- **Server default** (mbe-api PR #245): 8 characters, upper, lower and digit; no symbol.
- **Checklist**: `NewPasswordFields` shows one row per rule, met or unmet, and the forms block submission while any rule is unmet. This replaces every hard-coded `< 6` check (widget validators and controllers).
- **Failure to load**: the checklist shows `passwordRulesUnavailable`, the client does not block, and the server stays the source of truth. There is no hard-coded fallback policy.

**Rationale**: the rules come from the deployment (FR-030), and three duplicated length checks go away.

**Alternatives rejected**:
- *Hard-coding the server default in the client*: this breaks FR-030 the first time a deployment changes its policy.
- *A local fallback policy when the call fails*: it could contradict the server. The server enforces regardless.

---

## R3 — Mapping server policy rejections

**Decision**: a 422 already becomes `ValidationError(List<FieldError{loc, msg, type}>)` (`auth_interceptor.dart:59-60, 109-123`). mbe-api PR #245 settled the shape as `{"type": "password_policy", "loc": ["body", "<field>"], "ctx": {"failed": ["min_length", "require_digit"]}}`.
- `FieldError` (`core/errors/app_error.dart:38-44`) keeps only `loc`, `msg` and `type`. `_fieldErrorsFrom` (`auth_interceptor.dart:109-123`) drops `ctx`. So add `@Default(<String>[]) List<String> failedRules` to `FieldError`, filled from `ctx.failed` when that is a list of strings. `input` (the echoed password) is still never read.
- Add a pure `Set<PasswordRule> rulesFromFieldError(FieldError)`. It returns the rules named in `failedRules` when `type == 'password_policy'`, and an empty set otherwise. Unknown rule names are ignored.
- Each form shows the localized `passwordRule*` string for every failed rule.
- An unmatched error falls back to the raw `msg`.
- The admin form currently stores only the first raw `msg` (`users_controller.dart:374-375`). It switches to the same mapper.

**Rationale**: there's no new `AppError` variant, so the exhaustive switches in `app_error.dart` and `error_banner.dart` don't change.

**Alternatives rejected**: a `PasswordPolicyError` subtype, which adds churn for no UX gain.

**Note**: like every FastAPI 422, the response echoes `input`, which here is the rejected password. The client must not log or display `input`.

---

## R4 — Forced change (Story 5)

**Decision**: mbe-api PR #246 shipped the flag as specified. It is set by `POST /users`, and cleared by `POST /auth/change-password` and `POST /auth/recover`. It appears on `UserResponse`, `UserListItem` and `TokenResponse`. While the flag is set, every request answers `403 {"detail": "password_change_required"}`, except `/auth/me` and `/auth/change-password`. The design:
- **User flag**: `User` (`core/access/user.dart`) gains `@Default(false) bool mustChangePassword`, mapped in `User.fromResponse` from `UserResponse.mustChangePassword` (nullable in the generated model, so treat `null` as false). Login already calls `me()` after the token, so the `TokenResponse` copy isn't needed.
- **Route**: a new `/auth/password-required` route, added to `requiresSession` (`app_router.dart:513`).
- **Redirect**: in `_redirect`, after the unauthenticated branch and before `/auth/login → /`, a flagged user is sent to `/auth/password-required`, and an unflagged user who lands there goes to `/`. `_AuthRefreshListenable` already re-runs the redirect when the session changes.
- **Screen**: `ChangePasswordScreen(forced: true)`. It has no back button, uses `PopScope(canPop: false)`, shows an explanation, and offers a Logout button (`authProvider.notifier.signOut()`, key `forced_change_logout`, labeled with the existing `l10n.userMenuLogout`; the user menu's item is keyed `user_menu_logout`).
- **After the change**: success calls a new `AuthNotifier.reloadCurrentUser()` (`me()` → new authenticated state). The flag clears, and the redirect continues to `/` (FR-043; the normal post-login destination is always `/`).
- **Server refusal (FR-044)**: `AuthInterceptor` gains `onPasswordChangeRequired`, mirroring `onUnauthorized`. It fires on a `403` whose detail is `password_change_required`. `AuthNotifier` wires it to set `mustChangePassword: true`.

**Verified**: PR #246 confirms that `change_password` and `complete_recovery` still do **not** bump `session_version`, so the follow-up `/auth/me` succeeds. `reloadCurrentUser` still signs out on a `401` in case that changes later.

---

## R5 — Read-only detail is a mode inside the POS workspace, not a new route or step (Story 2)

**Decision**: `PosStepState` gains `bool detail`, set through `jumpTo(step, mode:, detail:)` and cleared by `reset()`.
- **Decision point**: `_syncStepTo` (`pos_workspace_screen.dart:174-202`) decides it **once per sale id**, when the sale opens. The existing `_syncedSaleId` latch makes a sale paid during the session keep today's post-payment flow (spec edge case).
- **What renders**: when `detail` is set, the workspace renders a new `PosSaleDetailView` instead of the step host. Back stays. `OpenSalesSelector`, `_StepIndicator` and `PosSessionBlockedBanner` are hidden.
- **Parts reused**:
  - `SaleLineRow` and `SaleLineCard` with `enabled: false` and `stockGate: const StockGate()`, so paid lines show no shortage marks;
  - `SaleTotalsBar(showAction: false)`;
  - `AppliedPaymentsPanel(enabled: false)`, extended with a `showChangeAndDate` option (FR-011).
- The wrong comment at `pos_workspace_screen.dart:282-284` is corrected.

**Rationale**: it reuses loading, the unreachable checks and leave/back handling.

**Alternatives rejected**:
- *`CaptureStep(enabled: false)`*: it still shows a disabled product search, the customer bar's controls and the fulfillment selector, and it has no date, register or salesperson. FR-012 and §VI want actions hidden, not shown disabled.
- *A `PosStep.detalle` enum value*: `_StepIndicator` indexes `PosStep.values` against `stepCount` (`:484-519`), so the step track would break.
- *A separate `/sales/pos/:id/detail` route*: it duplicates loading and the unreachable logic, and the list would need the predicate (with a delivery lookup) for each row before navigating.

---

## R6 — The read-only predicate and a shared delivery check

**Decision**: a pure function next to `resumeTargetFor` in `pos_resume_controller.dart`:

```dart
bool opensAsReadOnlyDetail(Sale sale, {required bool isDelivery, List<Destination>? destinations})
// paid && balance == 0 && (!isDelivery || (destinations != null && every line isFullyDistributed))
```

- **Delivery check**: `saleIsDelivery(Sale, {int? facilityAddressId})` is extracted from `resumeTargetFor:38-52` (`fulfillmentIntent` first, `shipTo` as fallback). `resumeTargetFor`, the open-sales selector (`open_sales_selector_controller.dart:143-164`) and the predicate all use it, so they can't disagree.
- **Distribution rule**: "fully distributed" uses `distributionFor(...).every((l) => l.isFullyDistributed)`. This is the rule the selector already uses in `_paidAndUndistributed`, so FR-014 is unchanged.
- **Destinations**: a small `saleDestinationsProvider(saleId)` wraps `deliveryOrderRepository.listForSale`. `_syncStepTo` watches it only for a delivery sale that is paid with a zero balance, and waits on it the same way it waits for the facility address.
- **Unknown distribution**: when destinations are `null` (loading or failed), the predicate is false and the sale falls back to Entrega, as today.

**Rationale**: the predicate is pure and unit-testable, and the selector, the list's Edit icon and the resume step all share one delivery check.

**Accepted edge**: a pre-`fulfillmentIntent` delivery sale whose facility-address lookup fails reads as counter. If it's paid, it now opens read-only instead of on Cobro. That is harmless, because a paid sale has nothing left to collect.

---

## R7 — Header facts and the payments privilege in the detail view

**Decision**:
- **Customer**: `saleCustomerControllerProvider(customerId)`, as `CustomerBar` uses it (`customer_bar.dart:403-408`).
- **Salesperson**: `employeeDisplayNameProvider(id)`, which returns null on failure. The view then shows the id.
- **Register**: `UserSettings.pointSaleName`. A sale from another register is already unreachable (`_unreachableReasonFor`), so the sale's register is always the user's own.
- **Date**: `fmt.display.dateTime(sale.date)`.
- **Payments**: shown only when `can(SystemObject.customerPayments, AccessRight.read)`. Without that privilege the provider is not watched, and the view shows `posSaleDetailPaymentsForbidden` (FR-013). A `403` from the call is shown the same way.
- `AppliedPaymentsPanel`'s hardcoded Spanish error (`applied_payments_panel.dart:118`) is replaced with the existing `posAppliedPaymentsLoadError` key, since this view now relies on that panel.
- **Ticket**: the action calls `documentActionsProvider.preview(...)` with a `saleTicket` `DocumentRef`, gated by `canOpenDocument`. The preview dialog already has Print. The private `_ticketRef` (`pos_sales_list_screen.dart:419`) becomes a shared `saleTicketRef(l10n, {id, serial})`.

**Rationale**: uses only existing providers and endpoints. `customerPayments` (code 8) is defined but checked nowhere today. This is its first gate.

**Accepted limit**: a cashier without `employees` read sees the salesperson's id. The spec's header list is satisfied, though not pleasantly. A name field on the sale is a possible later mbe-api request.

---

## R8 — Other-facility warehouses in the pop-up, selectable (Story 3, mbe-ui#182)

**Decision**:
- **Data**: the stock cache already holds every non-transit warehouse in every facility. `ensureStockFor` and the capture search never pass `warehouse` (`capture_step.dart:412-416`, `sales_order_repository_impl.dart:255-270`). Only the dialog hides those rows, because it iterates the facility's warehouse list.
- **Entity**: `WarehouseStock` gains `int? facilityId` and `String? facilityName`, mapped in `fromResponse` from the regenerated `ProductStockResponse.facility` / `facilityName`. PR #244 makes both nullable: they are null only for an explicitly requested warehouse that doesn't exist, which the capture never asks for.
- **Pure helper**: `otherFacilityStock(ProductStock, {required int saleFacilityId, required Set<int> saleWarehouseIds, int? currentWarehouse})` in `capture/other_facility_stock.dart`.
  - It keeps a row when `available > 0`, or when the row is the line's current warehouse.
  - A row is "other" when its `facilityId` differs from the sale's facility. A row without a facility is skipped: since #242 that happens only for an explicitly requested warehouse that doesn't exist, which the capture never asks for.
  - It groups rows by facility, sorts groups by name, and sorts warehouses by name inside each group.
- **Dialog**: `showWarehousePicker` gains `required int facilityId`.
  - **Section**: shown when `stock != null && stock.stockable`, even when the sale doesn't require a stock check. An uncached product shows no section, rather than wrongly saying "not available".
  - **Rows**: built like the local rows. Same `ListTile`, tap pops the warehouse id (FR-022), same `WarehouseStockFlag` against the line's quantity, and the selected tint when it is the current warehouse. They are keyed `warehouse_other_<id>`.
  - **Current warehouse elsewhere**: when the line's current warehouse is in neither the local list nor the stock rows (an uncached or non-stockable product), it gets a selected row of its own at the top of the section, named by `#id` (FR-026).
  - **Scroll**: both sections share one scroll area capped at about 420 px, so long lists scroll at 390 px (§VI).
- **Line field (FR-025, #182)**: today `warehousePicker` (`sale_line_editing.dart:358-361`) looks the name up only in the facility list and otherwise shows an empty string. A new pure `lineWarehouseLabel(warehouseId, {facilityWarehouses, stock})` resolves the name in this order:
  1. the facility list;
  2. the cached stock row, as `"<warehouseName> · <facilityName>"`;
  3. `#<id>`.

  The band keeps its height: a single ellipsized `Text` line (§VI measuring tests).
- **Stock gate**: no change is needed. `evaluateLines` (`stock_gate.dart:41-65`) looks up `stock.warehouses` by warehouse id, so it already works for any warehouse.

**Rationale**: legacy sells across facilities (14% of 2026 lines, mbe-api PR #236), and mbe-api accepts it. Making the rows selectable matches that. It also fixes #182 with the same data, with no extra request and no new privilege.

**Alternatives rejected**:
- *Read-only rows (the original spec)*: its reason (#234 forbidding cross-facility lines) didn't hold. mbe-api accepted those lines instead.
- *Fetching `GET /warehouses` for every facility*: cashiers lack `WAREHOUSES READ`.
- *Listing other facilities' warehouses with zero stock too*: on a multi-facility tenant this makes a long list of warehouses nobody would sell from.

**Accepted limits**:
- Products that aren't stock-tracked return no stock rows, so they can only be booked to the sale facility's warehouses (or keep the one they have).
- The cache is seeded once per screen, so the figures can be stale. Confirmation still checks stock on the server.

---

## R9 — Consuming the backend changes

**Status**: all three shipped on 2026-10-18, and the client was regenerated (commits `6f68797`, `401a78a`).

| Issue | PR | Generated surface | Consumed in |
|---|---|---|---|
| #242 | #244 | `ProductStockResponse.facility`, `.facilityName` (both nullable) | R8 |
| #241 | #245 | `PasswordPolicyResponse`, `AuthApi` password-policy op, 422 `password_policy` | R2, R3 |
| #240 | #246 | `mustChangePassword` on `UserResponse`, `UserListItem`, `TokenResponse`, `UserUpdate`; `403 password_change_required` | R4 |

Not consumed: `UserUpdate.mustChangePassword`, the admin's manual override. Out of scope (spec Clarifications).

**Rationale**: constitution III requires it: no hand-written DTOs and no edits to sibling repositories.

---

## R10 — Existing layering issue, left as is

`account_controller.dart:5` imports the data layer directly. That breaks constitution §I, but it predates this spec. CLAUDE.md §3 (surgical changes) says to leave it alone. It is noted here, and the controllers are edited only where this spec needs them.
