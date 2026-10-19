---

description: "Task list for Login & POS Sales Enhancements"
---

# Tasks: Login & POS Sales Enhancements

**Input**: Design documents from `/specs/048-login-pos-enhancements/`

**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/ui-contracts.md](./contracts/ui-contracts.md), [quickstart.md](./quickstart.md)

**Tests**: Included. The plan's quality gates and the constitution call for unit and widget tests, and §VI requires a 390 px check for any new surface.

**Organization**: Tasks are grouped by user story. Paths are relative to the repository root. `R#` and `C#` refer to [research.md](./research.md) and [contracts/ui-contracts.md](./contracts/ui-contracts.md).

**Backend status**: mbe-api#240, #241 and #242 shipped on 2026-10-18, and the client is already regenerated (`6f68797`, `401a78a`). Do not re-run OpenAPI codegen. Revised the same day: Story 3's other-facility rows are **selectable**, and the story also fixes mbe-ui#182 (spec Clarifications).

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependency on an unfinished task)
- **[Story]**: The user story the task belongs to (US1–US5, matching the spec)

## Path Conventions

Flutter, feature-first. Auth code is under `lib/features/auth/` (shortened to `auth/` below). POS code is under `lib/features/sales/presentation/` (shortened to `sales/presentation/`). Tests are under `test/unit/` and `test/widget/features/`.

---

## Phase 1: Setup

**Purpose**: Establish a clean baseline before changing anything.

- [X] T001 Run `flutter analyze` and `flutter test test/unit test/widget/features/auth test/widget/features/sales` on the branch, which now includes the regenerated client, and record any pre-existing failures in a comment on this task so they are not mistaken for regressions. Check that the regenerated models (`ProductStockResponse.facility`, `PasswordPolicyResponse`, `UserResponse.mustChangePassword`) compile and that nothing in `lib/` broke on the regeneration
  - **Baseline result**: `flutter analyze` clean. 2,261 tests ran with **1 pre-existing failure**: `test/unit/features/repository_list_params_audit_test.dart` (Products). The regenerated client added `perishable`, `seriable` and `invoiceable` list filters, and the audit asks whether to wire them into the repository. That is unrelated to this spec and was left alone

---

## Phase 2: Foundational (blocking prerequisites)

**Purpose**: Strings every story needs. Both `.arb` files are shared, so they are edited once, here, to keep the stories independent.

- [X] T002 Add the new strings for all five stories to both `lib/l10n/app_es.arb` and `lib/l10n/app_en.arb`, following the existing `pos*` and `password*` key naming. Each key's `description` cites spec 048. Then regenerate `lib/l10n/app_localizations*.dart` with `flutter gen-l10n` (do not hand-edit them). Keys:
  - US1: `confirmPasswordLabel`, `confirmNewPasswordLabel`, `passwordMismatchError` ("Las contraseñas no coinciden" / "Passwords don't match")
  - US2: `posSaleDetailTitle` ("Ver venta" / "View sale"; constitution VI labels a read-only surface as a View), `posSaleDetailDateLabel`, `posSaleDetailRegisterLabel`, `posSaleDetailPaymentsForbidden` ("No tienes permiso para ver los pagos de esta venta"), `posPaymentDateLabel`
  - US3: `posWarehousePickerOtherFacilities` ("Otras sucursales"), `posWarehousePickerOtherNone` ("No hay existencia en otras sucursales.")
  - US4: `passwordRuleMinLength(count)`, `passwordRuleUpper`, `passwordRuleLower`, `passwordRuleDigit`, `passwordRuleSymbol`, `passwordRulesUnavailable`
  - US5: `passwordRequiredTitle`, `passwordRequiredExplanation`

**Checkpoint**: Strings are in place. Every story below can now start.

---

## Phase 3: User Story 1 - Confirm the new password (Priority: P1) 🎯 MVP

**Goal**: Every password-setting form asks for the new password twice and blocks submit until the two match (FR-001–FR-003).

**Independent Test**: Open each form (change, forgot, admin create), type two different values, and confirm submission is blocked with the mismatch message. Then edit the first field and confirm the confirmation re-validates. Quickstart scenarios 1–3.

### Tests for User Story 1

- [X] T003 [P] [US1] Write `test/widget/features/auth/new_password_fields_test.dart`: the confirmation shows `passwordMismatchError` when it differs and clears when they match; editing the new-password field after typing a confirmation re-validates the confirmation (FR-003); the new-password key is the one passed in (C1)

### Implementation for User Story 1

- [X] T004 [US1] Create `auth/presentation/widgets/new_password_fields.dart` (`NewPasswordFields`, C1). It renders:
  - the obscured new-password field: key from `newFieldKey` (default `new_password_field`), validator from a `newValidator` parameter, so each form keeps its current rule until US4;
  - the confirmation field `new_password_confirm_field`, labeled with a `confirmLabel` parameter.

  It keeps a `GlobalKey<FormFieldState>` on the confirmation, and calls `validate()` on it when the new password changes and the confirmation is non-empty. Parameters: `newFieldKey`, `newLabel`, `confirmLabel`, `newValidator`, `enabled`, `onNewChanged`, `onConfirmChanged`, `onSubmitted`
- [X] T005 [P] [US1] In `auth/presentation/account/account_controller.dart`, give `ChangePasswordController` a `confirmPassword` field, a `confirmPasswordChanged` method, and a guard in `submit()` that refuses to call the repository when `newPassword != confirmPassword`. Surface the failure as a mismatch error code, not an English string, and convert this controller's existing hard-coded English strings (:36-45) to codes too. The codes localize to existing keys: an empty field to `fieldRequired`, and the mismatch to `passwordMismatchError`. Repository failures stay `AppError`s surfaced through the shared `ErrorBanner` (`errorServerGeneric`, `errorNetworkGeneric`, etc.), not a new per-form string (data-model §3; plan Constitution Check, principles III and V)
- [X] T006 [US1] In the same file, `auth/presentation/account/account_controller.dart`, apply T005's change to `RecoveryController` (:79-118): `confirmPassword`, `confirmPasswordChanged`, the mismatch guard, and error codes in place of its hard-coded English strings, localized the same way as T005. Run after T005 (same file), and keep the two controllers' shapes identical
- [X] T007 [P] [US1] In `auth/presentation/admin/users_controller.dart`, give `UserFormController` a `confirmPassword` field and `passwordConfirmChanged`, and add `UserFormErrorCode.passwordMismatch`. `save()` (:299-384) refuses a create-mode save when the password and confirmation differ. Regenerate the freezed output
- [X] T008 [US1] Wire `NewPasswordFields` into `auth/presentation/account/change_password_screen.dart`:
  - the current-password field stays as is;
  - new key `new_password_field`, confirmation key `new_password_confirm_field`;
  - localize the controller's codes, the mismatch with `passwordMismatchError`.

  Depends on T004, T005
- [X] T009 [US1] Wire `NewPasswordFields` into `auth/presentation/account/forgot_password_screen.dart` after the token field, and localize the controller's codes. Depends on T004, T006
- [X] T010 [US1] Wire `NewPasswordFields` into create mode of `auth/presentation/admin/user_detail_screen.dart` (:158-168), passing `newFieldKey: Key('password_field')`, `newLabel: l10n.passwordLabel` and `confirmLabel: l10n.confirmPasswordLabel`. Add `passwordMismatch` to `_localizeFormError` (:434-457). Depends on T004, T007
- [X] T011 [P] [US1] Update `test/unit/features/auth/users_controller_test.dart`: the create-user test at :467-491 must also call `passwordConfirmChanged('secret1')`. Add a case where a differing confirmation yields `UserFormErrorCode.passwordMismatch` and no repository call
- [X] T012 [P] [US1] Update `test/widget/features/auth/change_password_screen_test.dart` and `test/widget/features/auth/forgot_password_screen_test.dart`: fill the confirmation in the existing success cases, and add a mismatch case to each (submission blocked, repository not called). Add a create-mode mismatch case to `test/widget/features/auth/user_detail_screen_test.dart`

**Checkpoint**: All three forms ask for a confirmation. Story 1 is complete and demonstrable on its own.

---

## Phase 4: User Story 2 - Paid sales open read-only (Priority: P1)

**Goal**: A fully paid POS sale opens in a read-only detail view instead of the payment step (FR-010–FR-014).

**Independent Test**: Open a paid counter sale from the POS sales list and confirm the detail view shows facts, lines, totals and payments, with no edit or pay actions and a working ticket preview. Then check the unchanged cases: completed with balance → Cobro, paid delivery with pending distribution → Entrega. Quickstart scenarios 6–9.

### Tests for User Story 2

- [X] T013 [P] [US2] In `test/unit/features/sales/open_sale_resolution_test.dart`, add cases:
  - `opensAsReadOnlyDetail`, following the data-model §5 table:
    - paid counter at zero balance → true;
    - completed with a balance → false;
    - paid delivery with a line pending → false;
    - paid delivery fully distributed → true;
    - destinations `null` → false.
  - `saleIsDelivery`: `fulfillmentIntent` first, `shipTo` as fallback.

  Leave the existing assertion at :56-64 alone: `resumeTargetFor` still returns Cobro for a paid counter sale, and the workspace now overrides it through the predicate
- [X] T014 [P] [US2] Write `test/widget/features/sales/pos_sale_detail_view_test.dart` (C3):
  - the facts strip: customer, date, register, and salesperson with the id fallback;
  - lines are disabled;
  - no selector, step track or action buttons;
  - payments show method, amount, change and date;
  - without `customerPayments` read, the forbidden text shows and the payments provider is never read;
  - a `403` from the payments call shows the same text;
  - the ticket button shows only with `canOpenDocument`;
  - no horizontal scroll at 390 px

### Implementation for User Story 2

- [X] T015 [US2] In `sales/presentation/pos_resume_controller.dart`, extract `saleIsDelivery(Sale, {int? facilityAddressId})` from `resumeTargetFor` (:38-52), and make `resumeTargetFor` call it. In `sales/presentation/open_sales_selector_controller.dart` (:143-164), replace the selector's own delivery test with `saleIsDelivery`. Behavior must not change: T013's `saleIsDelivery` cases and the existing selector tests must pass (R6)
- [X] T016 [US2] In `sales/presentation/pos_resume_controller.dart`, add the pure `opensAsReadOnlyDetail(Sale, {required bool isDelivery, List<Destination>? destinations})`. It uses `isZeroAmount(sale.balanceOrZero)` and `distributionFor(sale:, destinations:).every((l) => l.isFullyDistributed)` (R6). Add a generated `saleDestinationsProvider(saleId)` over `deliveryOrderRepository.listForSale`, then regenerate. Fix the doc comment on `resumeTargetFor`. Depends on T015
- [X] T017 [P] [US2] In `sales/presentation/pos_step_controller.dart`, add `bool detail` (default false) to `PosStepState`, extend `jumpTo(step, mode:, detail:)`, and have `reset()` clear it. Regenerate the freezed output (R5)
- [X] T018 [P] [US2] Extract the private `_ticketRef` (`sales/presentation/pos_sales_list_screen.dart:419`) into a shared `saleTicketRef(l10n, {id, serial})` that both the list and the new view use. The list's behavior must not change
- [X] T019 [P] [US2] In `sales/presentation/payment/applied_payments_panel.dart`, add a `showChangeAndDate` option that shows each payment's change given and date (FR-011). Replace the hard-coded Spanish error at :118 with the existing `posAppliedPaymentsLoadError` key. `enabled: false` already hides the reverse action
- [X] T020 [US2] Create `sales/presentation/pos_sale_detail_view.dart` (`PosSaleDetailView`, C3) with:
  - the facts strip: `saleCustomerControllerProvider`, `fmt.display.dateTime`, `UserSettings.pointSaleName`, and `employeeDisplayNameProvider` with the id as fallback;
  - the disabled `SaleLineRow` / `SaleLineCard`, with `stockGate: const StockGate()`;
  - `SaleTotalsBar(showAction: false)`;
  - the payments section, gated on `can(SystemObject.customerPayments, AccessRight.read)`. Without it, show `posSaleDetailPaymentsForbidden` and don't watch the provider. Treat a `403` the same way;
  - the ticket button, gated by `canOpenDocument`.

  Expanded: a payments rail beside the lines. Compact: one scrolling column. Depends on T017, T018, T019
- [X] T021 [US2] In `sales/presentation/pos_workspace_screen.dart`:
  - In `_syncStepTo` (:174-202), decide the mode once per sale id. For a paid, zero-balance sale, read `saleDestinationsProvider` only when `saleIsDelivery` is true, and wait for it like the facility address (`hasValue || hasError`), showing the same loading state the workspace already shows during that wait. Then call `opensAsReadOnlyDetail` and `jumpTo(..., detail: true)`.
  - In `build()`, when `step.detail` is set, render `PosSaleDetailView` instead of the step host (:670-685), and hide `OpenSalesSelector`, `_StepIndicator` and `PosSessionBlockedBanner`.
  - Correct the comment at :282-284.

  Depends on T016, T017, T020
- [X] T022 [US2] Extend `test/widget/features/sales/pos_workspace_route_test.dart`:
  - a paid counter sale shows `pos_sale_detail`, with no step track, selector or edit actions;
  - a completed sale with a balance still opens on Cobro;
  - a paid delivery sale with a pending line opens on Entrega;
  - a fully distributed one shows the detail;
  - a sale that becomes paid during the session keeps today's post-payment flow (the decision is latched).

  Then run `test/unit/features/sales/pos_sale_workability_test.dart` and `test/integration/pos_resume_flow_test.dart`, and update any assertion that a paid sale lands on Cobro. Depends on T021

**Checkpoint**: Paid sales open read-only. Stories 1 and 2 are the P1 scope.

---

## Phase 5: User Story 3 - Other facilities' warehouses, selectable (Priority: P2), fixes mbe-ui#182

**Goal**: The line's warehouse pop-up lists other facilities' warehouses that have stock, grouped by facility. Any of them can be picked. The line always names its warehouse (FR-020–FR-026; R8, C4, C5).

**Independent Test**: For a product stocked in another facility, open the line's warehouse pop-up, pick that facility's warehouse, and confirm the line shows "<warehouse> · <facility>" and the stock gate checks that warehouse. Reopen a sale with such a line and confirm the name shows. Quickstart scenarios 10–14.

### Tests for User Story 3

- [X] T023 [P] [US3] Write `test/unit/features/sales/other_facility_stock_test.dart` in the style of `stock_gate_test.dart`. Cover `otherFacilityStock`:
  - rows with `available <= 0` are dropped, except the `currentWarehouse` row;
  - a row whose `facilityId` differs from the sale facility is "other";
  - a row without a `facilityId` is skipped;
  - groups sort by facility name, and warehouses sort by name;
  - no other stock gives an empty list.

  Cover `lineWarehouseLabel`:
  - the facility list name wins;
  - then the stock row's `"<name> · <facility>"`;
  - then `#<id>`;
  - never empty.
- [X] T024 [P] [US3] Write `test/unit/features/sales/product_lookup_result_test.dart`: `WarehouseStock.fromResponse` maps `facility` and `facilityName`
- [X] T025 [P] [US3] Extend `test/widget/features/sales/warehouse_picker_dialog_test.dart`, using its `openPicker` helper and `const ProductStock(...)` fixtures:
  - the section renders below the local list, with a facility subheader per group;
  - tapping an other-facility row **pops its warehouse id**;
  - a line whose current warehouse is another facility's shows that row as selected;
  - a current warehouse in neither list shows as a selected `#id` row;
  - **the #182 case**: a non-stockable product, and an uncached one (`stock == null`), whose line is booked to another facility's warehouse still list that warehouse, selected, as a `#id` row;
  - the empty message shows when nothing is available elsewhere;
  - a non-stockable product shows no other rows;
  - a stockable product with `stockRequired == false` still shows them;
  - a long list scrolls at 390 px (`phoneSurface`, `expectNoHorizontalScroll`, no `takeException`).

### Implementation for User Story 3

- [X] T026 [US3] Add `int? facilityId` and `String? facilityName` to `WarehouseStock` in `lib/features/sales/domain/entities/product_lookup_result.dart`, map them in `fromResponse` (:60-75) from `ProductStockResponse.facility` / `.facilityName`, and regenerate the freezed output
- [X] T027 [US3] Create `sales/presentation/capture/other_facility_stock.dart` with `OtherFacilityGroup {facilityId, facilityName, warehouses}`. Rows without a facility are skipped. Add two pure functions, exactly as in data-model §7 and R8:
  - `otherFacilityStock(ProductStock, {required int saleFacilityId, required Set<int> saleWarehouseIds, int? currentWarehouse})`;
  - `lineWarehouseLabel(int warehouseId, {required List<Warehouse> facilityWarehouses, ProductStock? stock})`.

  Depends on T026
- [X] T028 [US3] In `sales/presentation/capture/warehouse_picker_dialog.dart`, add `required int facilityId` to `showWarehousePicker` (:17-35), and derive the sale's warehouse ids from the `warehouses` it already receives. Render the C4 section:
  - header `posWarehousePickerOtherFacilities`;
  - a subheader per group (the facility name);
  - rows built exactly like the local ones: `ListTile`, `minTileHeight: 56`, the same `WarehouseStockFlag` against the line's quantity, the selected tint and check on the current warehouse, and **tap pops the id**. Key them `warehouse_other_<id>`;
  - the `#id` row for a current warehouse found in neither list;
  - the empty message.

  Put both sections in one scroll area capped at about 420 px. Refactor the local row builder so both sections share it. Depends on T027
- [X] T029 [US3] In `sales/presentation/capture/sale_line_editing.dart`, update `warehousePicker` (:346-395):
  - pass `facilityId: facilityId` to `showWarehousePicker`;
  - replace the name lookup at :358-361 (which falls back to `''`) with `lineWarehouseLabel(line.warehouse, facilityWarehouses: list, stock: ref.watch(productStockCacheProvider)[line.product])` (C5). Keep it a single ellipsized `Text`, so the band's height is unchanged.

  Update the picker's other callers and tests, `test/widget/features/sales/sale_line_row_test.dart` and `test/widget/features/sales/pos_047_extra_large_text_test.dart`. Add a `sale_line_row_test` case for #182: a line booked to another facility's warehouse shows `"<name> · <facility>"`, and `#id` when it isn't cached. The existing band-height and `sale_line_symmetry_test` measurements must still pass. Depends on T028
- [X] T030 [US3] Regenerate any POS goldens that include the warehouse dialog or the line's warehouse field (see `test/golden/pos_capture_golden_test.dart`) and review the diffs. Depends on T029

**Checkpoint**: Cashiers can see and sell from other facilities' warehouses, and #182 is fixed.

---

## Phase 6: User Story 4 - Strong passwords (Priority: P2)

**Goal**: Password forms validate against the server's published `PasswordPolicy`, show a live rule checklist, and show localized per-rule messages for server rejections (FR-030–FR-033; R2, R3).

**Independent Test**: With the default policy, type `abc12345` and confirm the uppercase rule shows unmet and submit is blocked. Type `Abc12345` and confirm all four rules are met. Change the deployment policy and confirm the checklist follows it. Quickstart scenarios 4–5.

**Depends on US1**: it extends `NewPasswordFields` and edits the same controllers and screens.

### Tests for User Story 4

- [X] T031 [P] [US4] Write `test/unit/features/auth/password_policy_test.dart`:
  - `unmet` for each rule: minimum length, upper, lower, digit, and symbol (whitespace does **not** count, matching the server);
  - `rules` lists only the enabled rules, in order;
  - `rulesFromFieldError` returns the rules named in `failedRules` for `type == 'password_policy'`, ignores unknown names, and returns empty for any other type (R3).
- [X] T032 [P] [US4] Add cases to `test/unit/core/network/auth_interceptor_test.dart` with `_FakeHttpClientAdapter`. A 422 with `{"type": "password_policy", "loc": [...], "ctx": {"failed": ["min_length", "require_digit"]}, "input": "..."}` yields a `FieldError` with those `failedRules`, and `input` is not stored anywhere. A 422 without `ctx` yields empty `failedRules`
- [X] T033 [P] [US4] Extend `test/widget/features/auth/new_password_fields_test.dart`:
  - the checklist shows one `password_rule_<name>` row per rule;
  - each row's met/unmet state updates as the user types;
  - a policy load error shows `passwordRulesUnavailable` and no rows;
  - the checklist is hidden while the policy is loading.

### Implementation for User Story 4

- [X] T034 [US4] Add `@Default(<String>[]) List<String> failedRules` to `FieldError` in `lib/core/errors/app_error.dart`, and fill it in `_fieldErrorsFrom` (`lib/core/network/auth_interceptor.dart:109-123`) from `entry['ctx']['failed']` when that is a list. Never read `entry['input']`. Regenerate the freezed output
- [X] T035 [US4] Create `auth/domain/entities/password_policy.dart` per data-model §1: a freezed `PasswordPolicy`, `enum PasswordRule` with each rule's server name, `rules`, the pure `unmet(String)`, and `rulesFromFieldError(FieldError)`. Regenerate the freezed output. Depends on T034
- [X] T036 [US4] Add `Future<PasswordPolicy> passwordPolicy()` to `auth/domain/repositories/auth_repository.dart`. In `auth/data/auth_repository_impl.dart`, implement it with the generated `AuthApi` password-policy operation, mapping `PasswordPolicyResponse`. Expose `passwordPolicyProvider` (a `FutureProvider`) next to `authRepositoryProvider` (`auth_repository_impl.dart:12`). Extend `test/unit/features/auth/auth_repository_impl_test.dart` with the mapping. Depends on T035
- [X] T037 [US4] Extend `NewPasswordFields` (`auth/presentation/widgets/new_password_fields.dart`) with a `policy` parameter and the `password_rules` checklist (C1):
  - one row per rule, keyed `password_rule_<name>`;
  - a check icon in `primary` when met, a circle icon in `onSurfaceVariant` when unmet;
  - `passwordRulesUnavailable` on error;
  - hidden while loading.

  Keep the `newValidator` parameter for now; T038 removes it together with its call sites, so the build never breaks in between. Depends on T035
- [X] T038 [US4] Replace the duplicated length checks with the policy:
  - In `change_password_screen.dart`, `forgot_password_screen.dart` and `admin/user_detail_screen.dart`, pass `policy: ref.watch(passwordPolicyProvider)` and stop passing `newValidator`. Then remove the `newValidator` parameter from `NewPasswordFields`, since the policy replaces it.
  - In `account_controller.dart` (both controllers) and `users_controller.dart`, replace the `< 6` / `UserFormErrorCode.passwordLength` guards with `policy.unmet(newPassword).isEmpty` when the policy loaded. When it didn't load, don't block.
  - Remove the `fieldMinLength6`, `passwordLengthError` and `userPasswordLengthError` usages on these forms. Delete a key from both `.arb` files only if nothing else uses it.

  Depends on T036, T037
- [X] T039 [US4] Map server rejections (R3). In the two account controllers and in `users_controller.dart:374-375`, turn a `ValidationError` whose `FieldError` has non-empty `rulesFromFieldError` into one localized `passwordRule*` message per failed rule. Otherwise fall back to the first raw `msg`. Depends on T035
- [X] T040 [P] [US4] Update the existing tests that assert the old length messages:
  - `test/widget/features/auth/change_password_screen_test.dart` (:74 checks "Must be at least 6 characters");
  - `forgot_password_screen_test.dart`;
  - `test/unit/features/auth/users_controller_test.dart` (the `passwordLength` case).

  Override `passwordPolicyProvider` with the server default (8, upper, lower, digit). Add a case per form where a `422 password_policy` shows the localized rule messages. Depends on T038, T039

**Checkpoint**: Forms follow the deployment's policy.

---

## Phase 7: User Story 5 - Change password on first login (Priority: P3)

**Goal**: A user flagged by the server is sent to a forced-change screen after login, can't leave it except by logging out, and continues normally after changing the password (FR-040–FR-044; R4, C2).

**Independent Test**: Create a user as admin, log in as that user, confirm every route redirects to the forced-change screen, change the password, and confirm the app opens at `/` and the screen doesn't return. Quickstart scenarios 15–17.

**Depends on US1 and US4**: the forced screen reuses `ChangePasswordScreen` with `NewPasswordFields` and the policy.

### Tests for User Story 5

- [X] T041 [P] [US5] Add cases to `test/unit/core/network/auth_interceptor_test.dart`. A `403 {"detail": "password_change_required"}` invokes `onPasswordChangeRequired` and still fails the request. Any other `403` does not invoke it (there is a `403` case at :46)
- [X] T042 [P] [US5] Add router cases to `test/unit/app/router/app_router_test.dart` using `_FixedAuthNotifier` with a `mustChangePassword` user:
  - `/` and a typed URL redirect to `/auth/password-required`;
  - an unflagged user on `/auth/password-required` goes to `/`;
  - an unauthenticated user on it goes to `/auth/login`.

### Implementation for User Story 5

- [X] T043 [P] [US5] Add `@Default(false) bool mustChangePassword` to `User` in `lib/core/access/user.dart`, and map it in `User.fromResponse` (:33-51) from `UserResponse.mustChangePassword ?? false`. Regenerate the freezed output
- [X] T044 [P] [US5] Add `void Function()? onPasswordChangeRequired` to `AuthInterceptor` in `lib/core/network/auth_interceptor.dart`, mirroring `onUnauthorized` (:21, :38-40). Fire it on a `403` whose `_detailFrom(body)` is `password_change_required`. Run after T034 if both are in flight (same file)
- [X] T045 [US5] In `auth/presentation/session/auth_notifier.dart`:
  - add `reloadCurrentUser()`: `repository.me()`, then a new authenticated state; on a `401`, sign out;
  - wire `onPasswordChangeRequired` to set `mustChangePassword: true` on the current user, next to the existing `onUnauthorized` wiring (:23).

  Extend `test/unit/features/auth/auth_notifier_test.dart`. Depends on T043, T044
- [X] T046 [US5] Add a `forced` mode to `ChangePasswordScreen` (`auth/presentation/account/change_password_screen.dart`, C2):
  - no back arrow (`automaticallyImplyLeading: false`), and `PopScope(canPop: false)`;
  - title `passwordRequiredTitle`, then a `passwordRequiredExplanation` body;
  - a Logout button keyed `forced_change_logout`, labeled with the existing `l10n.userMenuLogout`, that calls `authProvider.notifier.signOut()`;
  - on success, `reloadCurrentUser()` instead of `_SuccessView`.

  Depends on T045
- [X] T047 [US5] In `lib/app/router/app_router.dart`:
  - add `GoRoute('/auth/password-required')` building `ChangePasswordScreen(forced: true)`, next to the other `/auth/*` routes (:319-334);
  - add it to the `requiresSession` check (:513);
  - in `_redirect` (:504-533), after the unauthenticated branch and before `/auth/login → /`, send a flagged user to it from any other location, and send an unflagged user who lands on it to `/`.

  Make T042 pass. Depends on T043, T046
- [X] T048 [US5] Add widget tests for the forced mode in `test/widget/features/auth/change_password_screen_test.dart`:
  - no back button;
  - `forced_change_logout` signs out;
  - a successful change calls `reloadCurrentUser` and leaves the screen;
  - a `422 password_policy` shows the rule messages;
  - no horizontal scroll at 390 px.

  Depends on T046

**Checkpoint**: All five stories are done.

---

## Phase 8: Polish & Cross-Cutting

**Purpose**: Final verification.

- [X] T049 [P] Run `flutter analyze` and fix anything this feature introduced (the Dart MCP `analyze_files` tool is fine). Then run `dart format` on the touched files only
- [X] T050 Run the full suite (`flutter test`) and compare against the baseline recorded in T001
  - **Result**: 3,105 passed, 62 skipped, 9 failed. All 9 predate this feature or are environmental: the 7 `test/golden/core_widgets_golden_test.dart` goldens (they also fail on a clean checkout of HEAD), the Products `repository_list_params_audit_test` (T001's baseline), and `test/integration/auth_flow_test.dart` scenario 2, which got HTTP 500 from the live dev backend on a wrong-password login (probably mbe-api migration `021` not applied there)
- [ ] T051 Walk quickstart scenarios 1–18 in `flutter run -d chrome` against a dev backend with migration `021` applied, using the `MBE_POS_*` admin account plus a cashier without `customerPayments` read for scenarios 9 and 10. Scenario 10 run as the cashier verifies FR-024, and scenario 18 verifies FR-033. Check 390 px for scenarios 6, 10, 13 and 15
  - **Not run by the agent**: it needs a person driving the app against a dev backend that has migration `021` applied. The live dev backend currently fails user reads (see T050), so scenarios 15–17 can't be walked until that is fixed
- [ ] T052 Set the **Status** of `specs/048-login-pos-enhancements/spec.md` to Implemented, then run `/speckit-companion-mark-complete` to record `completed`, as spec 047 did. Note in the PR description that it fixes mictlanix/mbe-ui#182, so merging closes it

---

## Dependencies & Execution Order

### Phase dependencies

- **Phase 1 (T001)**: no dependencies.
- **Phase 2 (T002)**: after Phase 1. Blocks every story, since they all need strings.
- **US1 (Phase 3), US2 (Phase 4), US3 (Phase 5)**: after Phase 2. Independent of each other.
- **US4 (Phase 6)**: after US1, because it extends the widget and edits the same controllers and screens.
- **US5 (Phase 7)**: after US1 and US4, because the forced screen reuses both. T043, T044, T041 and T042 can start earlier.
- **Phase 8**: after all stories.

### Within each story

- Tests come first where listed, and should fail before implementation.
- US1: T004 → T008/T009/T010, each also needing its controller task (T005 → T006 share a file).
- US2: T015 → T016 → T021; T017, T018, T019 → T020 → T021 → T022.
- US3: T026 → T027 → T028 → T029 → T030.
- US4: T034 → T035 → T036 → T038; T035 → T037 → T038; T035 → T039; T038 + T039 → T040.
- US5: T043 + T044 → T045 → T046 → T047; T046 → T048.

### Shared files to watch

- `lib/core/network/auth_interceptor.dart`: T034 (US4) and T044 (US5).
- `test/unit/core/network/auth_interceptor_test.dart`: T032 and T041.
- `auth/presentation/account/account_controller.dart`: T005, T006, T038, T039.
- `change_password_screen.dart`: T008, T038, T046.

### Parallel opportunities

- After T002, US1, US2 and US3 can run in parallel.
- US1: T003, T005, T007, then T011 and T012.
- US2: T013, T014, T017, T018, T019.
- US3: T023, T024, T025.
- US4: T031, T032, T033.
- US5: T041, T042, T043, T044.

---

## Implementation Strategy

### MVP first (the P1 scope)

1. Phase 1, then Phase 2.
2. **US1** (confirm password), then **US2** (paid-sale read-only). Both are P1.
3. Stop and validate with quickstart scenarios 1–3 and 6–9.

### Incremental delivery

1. **US3** (other-facility warehouses + #182): independent, can go any time after T002.
2. **US4** (policy) after US1.
3. **US5** (forced change) after US4.
4. Phase 8, then the PR.

### Notes

- Commit after each task or logical group.
- Do not hand-edit generated files (`*.g.dart`, `*.freezed.dart`, `lib/generated/openapi`, `app_localizations*.dart`).
- Never log or display the 422 `input` field: it echoes the rejected password.
