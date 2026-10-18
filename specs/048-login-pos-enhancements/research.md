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

## R2 — Password policy: a domain entity, with an interim source until mbe-api#241 ships (Story 4)

**Decision**:
- **Entity**: a freezed `PasswordPolicy {minLength, requireUpper, requireLower, requireDigit, requireSymbol}` in `features/auth/domain/entities/password_policy.dart`. It has `enum PasswordRule {minLength, upper, lower, digit, symbol}`, a pure `Set<PasswordRule> unmet(String)`, and `List<PasswordRule> get rules`.
- **Interim value**: `PasswordPolicy.interim = (minLength: 6, all others false)`. This matches today's server rule.
- **Source**: `AuthRepository.passwordPolicy()` is exposed as `passwordPolicyProvider`. It returns `interim` with no network call until #241 ships. After the client is regenerated, it calls the generated `GET /auth/password-policy`.
- **No login needed**: the endpoint is public, and `AuthInterceptor` attaches a bearer token only when one is stored (`core/network/auth_interceptor.dart:28-31`). So the pre-login Forgot screen works.
- **Checklist**: `NewPasswordFields` shows one row per rule, met or unmet, and the forms block submission while any rule is unmet. This replaces every hard-coded `< 6` check (widget validators and controllers).
- **Failure to load**: the checklist shows `passwordRulesUnavailable`, the client does not block, and the server stays the source of truth.

**Rationale**: building the checklist now removes three duplicated length checks. The swap after #241 then touches only the repository. Until #241 ships, the checklist shows a single rule ("At least 6 characters"), which is honest. FR-030 is fully met once #241 ships (recorded in plan Complexity Tracking).

**Alternatives rejected**:
- *Hard-coding the 8/upper/lower/digit default in the client now*: this breaks FR-030. It would also reject passwords the server still accepts, and the reverse once a deployment changes its policy.
- *Waiting for #241 before building anything*: this leaves the duplicated `< 6` checks in place and makes the post-#241 work bigger.

---

## R3 — Mapping server policy rejections

**Decision**: a 422 already becomes `ValidationError(List<FieldError{loc, msg, type}>)` (`auth_interceptor.dart:59-60, 109-123`). Add a pure `PasswordRule? ruleFromFieldError(FieldError)` keyed on the rule names #241 proposes (`min_length`, `require_upper`, `require_lower`, `require_digit`, `require_symbol`, read from `ctx.failed` or `type`).
- Each form maps a match to the localized `passwordRule*` string.
- An unknown error falls back to the raw `msg`.
- The admin form currently stores only the first raw `msg` (`users_controller.dart:374-375`). It switches to the same mapper.

**Rationale**: there's no new `AppError` variant, so the exhaustive switches in `app_error.dart` and `error_banner.dart` don't change.

**Alternatives rejected**: a `PasswordPolicyError` subtype, which adds churn for no UX gain.

**Open contract item**: the exact shape of the 422 is agreed in mbe-api#241. The mapper is the only code that depends on it.

---

## R4 — Forced change: designed now, built when mbe-api#240 ships (Story 5)

**Decision**: Story 5's tasks are **blocked on #240**, and nothing for them ships beforehand. The design:
- **User flag**: `User` (`core/access/user.dart`) gains `@Default(false) bool mustChangePassword`, mapped in `User.fromResponse` from the regenerated `UserResponse.must_change_password`.
- **Route**: a new `/auth/password-required` route, added to `requiresSession` (`app_router.dart:513`).
- **Redirect**: in `_redirect`, after the unauthenticated branch and before `/auth/login → /`, a flagged user is sent to `/auth/password-required`, and an unflagged user who lands there goes to `/`. `_AuthRefreshListenable` already re-runs the redirect when the session changes.
- **Screen**: `ChangePasswordScreen(forced: true)`. It has no back button, uses `PopScope(canPop: false)`, shows an explanation, and offers a Logout action (`authProvider.notifier.signOut()`, key `userMenuLogout`).
- **After the change**: success calls a new `AuthNotifier.reloadCurrentUser()` (`me()` → new authenticated state). The flag clears, and the redirect continues to `/` (FR-043; the normal post-login destination is always `/`).
- **Server refusal (FR-044)**: `AuthInterceptor` gains `onPasswordChangeRequired`, mirroring `onUnauthorized`. It fires on a `403` whose detail is `password_change_required`. `AuthNotifier` wires it to set `mustChangePassword: true`.

**Rationale**: with the flag always false, the code would ship inactive. That is speculative code that nothing exercises, against CLAUDE.md §2. Constitution III also says consumption proceeds once the upstream change ships.

**Verified risk**: mbe-api's `change_password` does **not** bump `session_version` (`user_service.py:253-255`), so the follow-up `/auth/me` succeeds rather than returning 401. If #240 also starts bumping it, `reloadCurrentUser` must handle a 401 by sending the user to login. Recorded for the #240 consumption task.

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

## R8 — Other-facility stock in the warehouse pop-up (Story 3)

**Decision**:
- **Data**: the stock cache already holds every non-transit warehouse in every facility. `ensureStockFor` and the capture search never pass `warehouse` (`capture_step.dart:412-416`, `sales_order_repository_impl.dart:255-270`). Only the dialog hides those rows, because it iterates the facility's warehouse list.
- **Entity**: after #242 ships, `WarehouseStock` gains `int? facilityId` and `String? facilityName`, mapped in `fromResponse`.
- **Pure helper**: `otherFacilityStock(ProductStock, {required int saleFacilityId, required Set<int> saleWarehouseIds})` in `capture/other_facility_stock.dart`.
  - It keeps a row only when `available > 0`.
  - A row is "other" when its `facilityId` is set and differs from the sale's facility. A row with a null `facilityId` is "other" when its warehouse id is not one of the sale facility's warehouses.
  - It groups rows by facility, sorts groups by name, and puts the unknown-facility group last.
- **Dialog**: `showWarehousePicker` gains `required int facilityId`. The section shows only when `stock != null && stock.stockable`.
  - It shows for any stock-tracked product, even when the sale doesn't require a stock check (`stockRequired == false`).
  - An uncached product shows nothing, rather than wrongly saying "not available".
  - Rows are `ListTile(enabled: false)` with no `onTap` (FR-022), keyed `warehouse_other_<id>`.
  - Quantities go through `fmt.field.quantity`.
  - Both sections share one scroll area capped at about 420 px, so long lists scroll at 390 px (§VI).

**Before and after #242**: until #242 ships, every facility is null. The helper excludes the sale facility's warehouses by id and shows the rest under one heading, "Other warehouses" (`posWarehousePickerOtherWarehouses`), without grouping. That partly meets FR-021 until #242 ships, which is recorded in Complexity Tracking. Once the client is regenerated, real facility groups appear with **no code change** beyond the entity mapping.

**Rationale**: the feature ships now and finishes itself on regeneration.

**Alternatives rejected**:
- *Hiding the section until #242*: no value until #242 ships.
- *Fetching `GET /warehouses`*: cashiers lack `WAREHOUSES READ`.

**Accepted risks**:
- The cache is seeded once per screen, so the figures can be stale. The section is advisory only.
- Until #242, a facility with more than 100 warehouses (the list's `limit`) could mislabel its own warehouses.

---

## R9 — Consuming the backend changes

**Decision**: each mbe-api change is consumed in its own step:
1. regenerate `lib/generated/openapi`, committed separately because it may touch unrelated DTOs;
2. map the new fields in the domain entity;
3. switch the interim source.

Mapping, by issue:

| Issue | Unblocks | Client change after regeneration |
|---|---|---|
| #242 | Story 3 grouping | `WarehouseStock.facilityId/facilityName` mapping |
| #241 | Story 4 FR-030 | `AuthRepositoryImpl.passwordPolicy()` calls the endpoint. The R3 mapper is checked against the real 422 |
| #240 | Story 5 | All of R4 |

**Rationale**: constitution III requires it: no hand-written DTOs and no edits to sibling repositories.

---

## R10 — Existing layering issue, left as is

`account_controller.dart:5` imports the data layer directly. That breaks constitution §I, but it predates this spec. CLAUDE.md §3 (surgical changes) says to leave it alone. It is noted here, and the controllers are edited only where this spec needs them.
