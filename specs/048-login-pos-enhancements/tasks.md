---

description: "Task list for Login & POS Sales Enhancements"
---

# Tasks: Login & POS Sales Enhancements

**Input**: Design documents from `/specs/048-login-pos-enhancements/`

**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/ui-contracts.md](./contracts/ui-contracts.md), [quickstart.md](./quickstart.md)

**Tests**: Included. The plan's quality gates and the constitution call for unit and widget tests, and §VI requires a 390 px check for any new surface.

**Organization**: Tasks are grouped by user story. Paths are relative to the repository root. `R#` and `C#` refer to [research.md](./research.md) and [contracts/ui-contracts.md](./contracts/ui-contracts.md).

**Scope of this run**: Phases 1–7 are buildable now. Phase 8 holds the work **blocked on mbe-api#240, #241 and #242**. Do not start Phase 8 until the matching issue has shipped and the API client has been regenerated (constitution III; R9).

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependency on an unfinished task)
- **[Story]**: The user story the task belongs to (US1–US5, matching the spec)

## Path Conventions

Flutter, feature-first. Auth code is under `lib/features/auth/` (shortened to `auth/` below). POS code is under `lib/features/sales/presentation/` (shortened to `sales/presentation/`). Tests are under `test/unit/` and `test/widget/features/`.

---

## Phase 1: Setup

**Purpose**: Establish a clean baseline before changing anything.

- [ ] T001 Run `flutter analyze` and `flutter test test/unit/features/auth test/widget/features/auth test/unit/features/sales test/widget/features/sales` on the branch, and record any pre-existing failures in a comment on this task so they are not mistaken for regressions (047's research R9 notes stale failure images in `test/golden/failures`)

---

## Phase 2: Foundational (blocking prerequisites)

**Purpose**: Strings that more than one story needs. Both `.arb` files are shared, so they are edited once, here, to keep the stories independent.

- [ ] T002 Add the new strings for stories 1–4 to both `lib/l10n/app_es.arb` and `lib/l10n/app_en.arb`, following the existing `pos*` and `password*` key naming. Each key's `description` cites spec 048. Then regenerate `lib/l10n/app_localizations*.dart` with `flutter gen-l10n` (do not hand-edit them). Keys:
  - US1: `confirmPasswordLabel`, `confirmNewPasswordLabel`, `passwordMismatchError` ("Las contraseñas no coinciden" / "Passwords don't match")
  - US2: `posSaleDetailTitle`, `posSaleDetailDateLabel`, `posSaleDetailRegisterLabel`, `posSaleDetailPaymentsForbidden` ("No tienes permiso para ver los pagos de esta venta"), `posPaymentDateLabel`
  - US3: `posWarehousePickerOtherFacilities` ("Otras sucursales"), `posWarehousePickerOtherWarehouses` ("Otros almacenes"), `posWarehousePickerOtherNone` ("No hay existencia en otras sucursales.")
  - US4: `passwordRuleMinLength(count)`, `passwordRuleUpper`, `passwordRuleLower`, `passwordRuleDigit`, `passwordRuleSymbol`, `passwordRulesUnavailable`

**Checkpoint**: Strings are in place. Every story below can now start.

---

## Phase 3: User Story 1 - Confirm the new password (Priority: P1) 🎯 MVP

**Goal**: Every password-setting form asks for the new password twice and blocks submit until the two match (FR-001–FR-003).

**Independent Test**: Open each form (change, forgot, admin create), type two different values, and confirm submission is blocked with the mismatch message. Then edit the first field and confirm the confirmation re-validates. Quickstart scenarios 1–3.

### Tests for User Story 1

- [ ] T003 [P] [US1] Write `test/widget/features/auth/new_password_fields_test.dart`: the confirmation shows `passwordMismatchError` when it differs and clears when they match; editing the new-password field after typing a confirmation re-validates the confirmation (FR-003); the new-password key is the one passed in (C1)

### Implementation for User Story 1

- [ ] T004 [US1] Create `auth/presentation/widgets/new_password_fields.dart` (`NewPasswordFields`, C1). It renders the obscured new-password field (key from `newFieldKey`, default `new_password_field`, validator from a `newValidator` parameter so each form keeps its current rule until US4), then the confirmation field `new_password_confirm_field` labeled with a `confirmLabel` parameter. It keeps a `GlobalKey<FormFieldState>` on the confirmation and calls `validate()` on it when the new password changes and the confirmation is non-empty. Parameters: `newFieldKey`, `newLabel`, `confirmLabel`, `newValidator`, `enabled`, `onNewChanged`, `onConfirmChanged`, `onSubmitted`
- [ ] T005 [P] [US1] In `auth/presentation/account/account_controller.dart`, give `ChangePasswordController` a `confirmPassword` field, a `confirmPasswordChanged` method, and a guard in `submit()` that refuses to call the repository when `newPassword != confirmPassword`. Surface the failure as a mismatch error code, not an English string, and convert the existing hard-coded English strings (:36-45) on this controller to codes too (data-model §2; plan Constitution Check, principle V)
- [ ] T006 [US1] In the same file, `auth/presentation/account/account_controller.dart`, apply T005's change to `RecoveryController` (:79-118): `confirmPassword`, `confirmPasswordChanged`, the mismatch guard, and error codes in place of its hard-coded English strings. Do this after T005, since both edit one file, and keep the two controllers' shapes identical
- [ ] T007 [P] [US1] In `auth/presentation/admin/users_controller.dart`, give `UserFormController` a `confirmPassword` field and `passwordConfirmChanged`, and add `UserFormErrorCode.passwordMismatch`. `save()` (:299-384) refuses create-mode saves when the password and confirmation differ. Regenerate the freezed output
- [ ] T008 [US1] Wire `NewPasswordFields` into `auth/presentation/account/change_password_screen.dart` (current password field stays as is; new key `new_password_field`; confirmation `new_password_confirm_field`) and localize the controller's mismatch code with `passwordMismatchError`. Depends on T004, T005
- [ ] T009 [US1] Wire `NewPasswordFields` into `auth/presentation/account/forgot_password_screen.dart` after the token field, and localize the mismatch code. Depends on T004, T006
- [ ] T010 [US1] Wire `NewPasswordFields` into create mode of `auth/presentation/admin/user_detail_screen.dart` (:158-168; pass `newFieldKey: Key('password_field')` and `newLabel: l10n.passwordLabel`, `confirmLabel: l10n.confirmPasswordLabel`) and add `passwordMismatch` to `_localizeFormError` (:434-457). Depends on T004, T007
- [ ] T011 [P] [US1] Update `test/unit/features/auth/users_controller_test.dart`: the create-user test at :467-491 must also call `passwordConfirmChanged('secret1')`; add a case where a differing confirmation yields `UserFormErrorCode.passwordMismatch` and no repository call
- [ ] T012 [P] [US1] Update `test/widget/features/auth/change_password_screen_test.dart` and `test/widget/features/auth/forgot_password_screen_test.dart`: fill the confirmation in the existing success cases, and add a mismatch case to each (submission blocked, repository not called). Add a create-mode mismatch case to `test/widget/features/auth/user_detail_screen_test.dart`

**Checkpoint**: All three forms ask for a confirmation. Story 1 is complete and demonstrable on its own.

---

## Phase 4: User Story 2 - Paid sales open read-only (Priority: P1)

**Goal**: A fully paid POS sale opens in a read-only detail view instead of the payment step (FR-010–FR-014).

**Independent Test**: Open a paid counter sale from the POS sales list and confirm the detail view shows facts, lines, totals and payments, with no edit or pay actions and a working ticket preview. Then check the unchanged cases: completed with balance → Cobro, paid delivery with pending distribution → Entrega. Quickstart scenarios 5–9.

### Tests for User Story 2

- [ ] T013 [P] [US2] In `test/unit/features/sales/open_sale_resolution_test.dart`, add predicate cases for `opensAsReadOnlyDetail` following the data-model §4 table (paid counter at zero balance → true; completed with balance → false; paid delivery with a line pending → false; paid delivery fully distributed → true; destinations `null` → false), plus `saleIsDelivery` cases (`fulfillmentIntent` first, `shipTo` as fallback). Leave the existing assertion at :56-64 alone: `resumeTargetFor` still returns Cobro for a paid counter sale, and the workspace now overrides it through the predicate
- [ ] T014 [P] [US2] Write `test/widget/features/sales/pos_sale_detail_view_test.dart`: facts strip (customer, date, register, salesperson with the id fallback); lines are disabled; no selector, step track or action buttons; payments show method, amount, change and date; without `customerPayments` read the forbidden text shows and the payments provider is never read; a `403` from the payments call shows the same text; the ticket button shows only with `canOpenDocument`; no horizontal scroll at 390 px (C3)

### Implementation for User Story 2

- [ ] T015 [US2] In `sales/presentation/pos_resume_controller.dart`, extract `saleIsDelivery(Sale, {int? facilityAddressId})` from `resumeTargetFor` (:38-52) and make `resumeTargetFor` call it. In `sales/presentation/open_sales_selector_controller.dart` (:143-164), replace the selector's own delivery test with `saleIsDelivery`. No behavior changes: T013's `saleIsDelivery` cases and the existing selector tests must pass (R6)
- [ ] T016 [US2] In `sales/presentation/pos_resume_controller.dart`, add the pure `opensAsReadOnlyDetail(Sale, {required bool isDelivery, List<Destination>? destinations})` using `isZeroAmount(sale.balanceOrZero)` and `distributionFor(sale:, destinations:).every((l) => l.isFullyDistributed)` (R6). Add a generated `saleDestinationsProvider(saleId)` over `deliveryOrderRepository.listForSale`, and regenerate. Fix the doc comment on `resumeTargetFor`. Depends on T015
- [ ] T017 [P] [US2] In `sales/presentation/pos_step_controller.dart`, add `bool detail` (default false) to `PosStepState`, extend `jumpTo(step, mode:, detail:)`, and have `reset()` clear it. Regenerate the freezed output (R5)
- [ ] T018 [P] [US2] Extract the private `_ticketRef` (`sales/presentation/pos_sales_list_screen.dart:419`) into a shared `saleTicketRef(l10n, {id, serial})` that the list and the new view both use, with no change to the list's behavior
- [ ] T019 [P] [US2] In `sales/presentation/payment/applied_payments_panel.dart`, add a `showChangeAndDate` option that shows each payment's change given and date (FR-011), and replace the hard-coded Spanish error at :118 with the existing `posAppliedPaymentsLoadError` key. `enabled: false` already hides the reverse action
- [ ] T020 [US2] Create `sales/presentation/pos_sale_detail_view.dart` (`PosSaleDetailView`, C3): the facts strip (`saleCustomerControllerProvider`, `fmt.display.dateTime`, `UserSettings.pointSaleName`, `employeeDisplayNameProvider` with the id as fallback); the disabled `SaleLineRow` / `SaleLineCard` with `stockGate: const StockGate()`; `SaleTotalsBar(showAction: false)`; the payments section gated on `can(SystemObject.customerPayments, AccessRight.read)` (without it, show `posSaleDetailPaymentsForbidden` and do not watch the provider; treat a `403` the same); and the ticket button gated by `canOpenDocument`. Expanded: a payments rail beside the lines. Compact: one scrolling column. Depends on T017, T018, T019
- [ ] T021 [US2] In `sales/presentation/pos_workspace_screen.dart`, decide the mode once per sale id in `_syncStepTo` (:174-202): for a paid, zero-balance sale, read `saleDestinationsProvider` only when `saleIsDelivery` is true and wait for it like the facility address (`hasValue || hasError`); then call `opensAsReadOnlyDetail` and `jumpTo(..., detail: true)`. In `build()`, when `step.detail` is set, render `PosSaleDetailView` instead of the step host (:670-685) and hide `OpenSalesSelector`, `_StepIndicator` and `PosSessionBlockedBanner`. Correct the comment at :282-284. Depends on T016, T017, T020
- [ ] T022 [US2] Extend `test/widget/features/sales/pos_workspace_route_test.dart`: a paid counter sale shows `pos_sale_detail` and none of the step track, selector or edit actions; a completed sale with a balance still opens on Cobro; a paid delivery sale with a pending line opens on Entrega; a fully distributed one shows the detail; a sale that becomes paid during the session keeps today's post-payment flow (the decision is latched). Then run `test/unit/features/sales/pos_sale_workability_test.dart` and `test/integration/pos_resume_flow_test.dart` and update any assertion that a paid sale lands on Cobro. Depends on T021

**Checkpoint**: Paid sales open read-only. Stories 1 and 2 are the P1 scope.

---

## Phase 5: User Story 3 - Stock in other facilities (Priority: P2)

**Goal**: The line's warehouse pop-up shows a read-only "other facilities" section with available stock (FR-020–FR-024), using the interim "Other warehouses" heading until mbe-api#242 ships (R8).

**Independent Test**: For a product stocked in another facility, open the line's warehouse pop-up and confirm a greyed section lists those warehouses with quantities, that tapping one changes nothing, and that non-stockable products show no section. Quickstart scenarios 10–13.

### Tests for User Story 3

- [ ] T023 [P] [US3] Write `test/unit/features/sales/other_facility_stock_test.dart` for `otherFacilityStock`, in the style of `stock_gate_test.dart`: rows with `available <= 0` are dropped; a null-`facilityId` row is "other" only when its warehouse id is not in the sale's warehouse ids; a row with a `facilityId` is "other" when it differs from the sale facility; groups sort by name with the null-facility group last; warehouses sort by name; a product with no other stock returns an empty list
- [ ] T024 [P] [US3] Extend `test/widget/features/sales/warehouse_picker_dialog_test.dart` (use its `openPicker` helper and `const ProductStock(...)` fixtures): the section renders below the local list for a stockable product; tapping an other row leaves the result unset and the dialog open; the empty message shows when nothing is available elsewhere; a non-stockable product and an uncached product (`stock == null`) show no section; a stockable product with `stockRequired == false` still shows it; a long list scrolls at 390 px with `phoneSurface`, `expectNoHorizontalScroll` and no `takeException`

### Implementation for User Story 3

- [ ] T025 [US3] Create `sales/presentation/capture/other_facility_stock.dart` with `OtherFacilityGroup {facilityId?, facilityName?, warehouses}` and the pure `otherFacilityStock(ProductStock, {required int saleFacilityId, required Set<int> saleWarehouseIds})` exactly as in data-model §6 and R8 (it must already treat `facilityId` when present, so the post-#242 step needs no logic change)
- [ ] T026 [US3] In `sales/presentation/capture/warehouse_picker_dialog.dart`, add `required int facilityId` to `showWarehousePicker` (:17-35), derive the sale warehouse ids from the `warehouses` it already receives, and render the C4 section when `stock != null && stock.stockable`: header (`posWarehousePickerOtherWarehouses` while every group has a null facility, `posWarehousePickerOtherFacilities` once facility data is present), a subheader per named facility, rows as `ListTile(enabled: false)` with no `onTap` keyed `warehouse_other_<id>` (`Icons.store_outlined`, name or `#id`, trailing `fmt.field.quantity(available)`), and the empty message. Put both sections in one scroll area capped at about 420 px. Depends on T025
- [ ] T027 [US3] In `sales/presentation/capture/sale_line_editing.dart` (:378-382), pass `facilityId: facilityId` to `showWarehousePicker`. Update the other callers and tests of the picker: `test/widget/features/sales/sale_line_row_test.dart` and `test/widget/features/sales/pos_047_extra_large_text_test.dart`. Depends on T026
- [ ] T028 [US3] Regenerate any POS goldens that include the warehouse dialog (see 047's `test/golden/pos_capture_golden_test.dart`) and review the diffs. Depends on T027

**Checkpoint**: Other-facility stock shows in the pop-up under the interim heading.

---

## Phase 6: User Story 4 - Strong passwords (Priority: P2)

**Goal**: Password forms validate against a `PasswordPolicy` and show a live rule checklist (FR-030–FR-033). The policy source is the interim value (6 characters, today's server rule) until mbe-api#241 ships (R2).

**Independent Test**: With the interim policy, type 5 characters and confirm the single rule shows unmet and submit is blocked, then type 6 and confirm it shows met and the form submits. Quickstart scenario 4.

### Tests for User Story 4

- [ ] T029 [P] [US4] Write `test/unit/features/auth/password_policy_test.dart`: `unmet` for each rule (min length, upper, lower, digit, symbol including whitespace); `rules` lists only enabled rules in order; `PasswordPolicy.interim` is 6 characters with nothing else required; `ruleFromFieldError` maps `min_length`, `require_upper`, `require_lower`, `require_digit`, `require_symbol` and returns null for anything else (R3)
- [ ] T030 [P] [US4] Extend `test/widget/features/auth/new_password_fields_test.dart`: the checklist shows one `password_rule_<name>` row per rule with met/unmet state that updates as the user types; a policy load error shows `passwordRulesUnavailable` and no rows; while loading, the checklist is hidden

### Implementation for User Story 4

- [ ] T031 [US4] Create `auth/domain/entities/password_policy.dart` per data-model §1: a freezed `PasswordPolicy`, `enum PasswordRule`, `rules`, the pure `unmet(String)`, `PasswordPolicy.interim`, and `ruleFromFieldError(FieldError)`. Regenerate the freezed output
- [ ] T032 [US4] Add `Future<PasswordPolicy> passwordPolicy()` to `auth/domain/repositories/auth_repository.dart`, implement it in `auth/data/auth_repository_impl.dart` to return `PasswordPolicy.interim` with no network call, and expose `passwordPolicyProvider` (a `FutureProvider`) next to `authRepositoryProvider` (`auth_repository_impl.dart:12`). Depends on T031
- [ ] T033 [US4] Extend `NewPasswordFields` (`auth/presentation/widgets/new_password_fields.dart`) with a `policy` parameter and the `password_rules` checklist (C1): one row per rule keyed `password_rule_<name>`, a check icon in `primary` when met and a circle icon in `onSurfaceVariant` when unmet, `passwordRulesUnavailable` on error, hidden while loading. Depends on T031
- [ ] T034 [US4] Replace the duplicated length checks with the policy. In `change_password_screen.dart`, `forgot_password_screen.dart` and `admin/user_detail_screen.dart` pass `policy: ref.watch(passwordPolicyProvider)` and drop the `< 6` widget validators. In `account_controller.dart` (both controllers) and `users_controller.dart`, replace the `< 6` / `UserFormErrorCode.passwordLength` guards with `policy.unmet(newPassword).isEmpty` when the policy loaded (when it didn't, do not block). Keep `fieldMinLength6`, `passwordLengthError` and `userPasswordLengthError` in the `.arb` files if any other screen still uses them. Depends on T032, T033
- [ ] T035 [US4] Map server rejections (R3): in the two account controllers and in `users_controller.dart:374-375`, turn a `ValidationError` whose `FieldError` matches `ruleFromFieldError` into the localized `passwordRule*` message, and fall back to the first raw `msg` otherwise. Depends on T031
- [ ] T036 [P] [US4] Update the existing tests that assert the old length messages: `test/widget/features/auth/change_password_screen_test.dart` (:74 checks "Must be at least 6 characters"), `forgot_password_screen_test.dart`, and `test/unit/features/auth/users_controller_test.dart` (the `passwordLength` case). Add a case per form where a 422 carrying a rule `type` shows the localized rule message. Depends on T034, T035

**Checkpoint**: Forms use the policy and checklist. The only thing left for FR-030 is the real endpoint (Phase 8).

---

## Phase 7: Polish & Cross-Cutting

**Purpose**: Final verification across the stories that shipped.

- [ ] T037 [P] Run `flutter analyze` and fix anything this feature introduced (the Dart MCP `analyze_files` tool is fine). Then run `dart format` on the touched files only
- [ ] T038 Run the full suite, `flutter test`, and compare with the baseline recorded in T001
- [ ] T039 Walk quickstart scenarios 1–13 in `flutter run -d chrome` against the dev backend (use the `MBE_POS_*` admin account, plus a cashier without `customerPayments` read for scenario 9). Check 390 px for scenarios 5, 10 and 13. Note that scenarios 4 and 10 show the interim behavior
- [ ] T040 Update `specs/048-login-pos-enhancements/spec.md` **Status** to reflect partial delivery, and record in the Notes of `checklists/requirements.md` which Phase 8 items remain blocked and on which mbe-api issue

---

## Phase 8: Deferred — blocked on mbe-api (do not start early)

**Purpose**: The parts that need a backend change. Each block starts with the matching client regeneration, committed on its own because it may touch unrelated DTOs (R9). Check the issue first: `gh issue view <n> -R mictlanix/mbe-api`.

### Blocked on mbe-api#242 (facility on stock rows) — completes US3

- [ ] T041 [US3] Regenerate `lib/generated/openapi` against the updated `/openapi.json` and commit it separately; confirm `ProductStockResponse` has `facility` and `facility_name`
- [ ] T042 [US3] Add `int? facilityId` and `String? facilityName` to `WarehouseStock` in `lib/features/sales/domain/entities/product_lookup_result.dart` and map them in `fromResponse` (:60-75); regenerate freezed. Add a mapping test in `test/unit/` (none exists today). Re-run T023/T024; `otherFacilityStock` already handles real facility ids, so grouping should now appear with no logic change
- [ ] T043 [US3] Re-run quickstart scenario 10 and confirm groups are headed "Otras sucursales" with facility names

### Blocked on mbe-api#241 (published password policy) — completes US4

- [ ] T044 [US4] Regenerate the client and commit it separately; confirm `GET /auth/password-policy` is in the generated `AuthApi` and check the real 422 shape for a policy rejection
- [ ] T045 [US4] Switch `AuthRepositoryImpl.passwordPolicy()` (`auth/data/auth_repository_impl.dart`) from the interim constant to the generated call, mapping `min_length`, `require_upper`, `require_lower`, `require_digit` and `require_symbol`; keep `PasswordPolicy.interim` as the fallback only if the call fails. Extend `test/unit/features/auth/auth_repository_impl_test.dart`
- [ ] T046 [US4] Check `ruleFromFieldError` against the real 422 and adjust it if the issue settled on a different shape than R3 assumed. Re-run quickstart scenario 4 with a changed deployment policy (e.g. require a symbol)

### Blocked on mbe-api#240 (must_change_password) — builds US5

**Goal**: A flagged user is sent to a forced-change screen after login, cannot leave except by logging out, and continues normally after changing the password (FR-040–FR-044; R4, C2).

**Independent Test**: Create a user as admin, log in as that user, confirm every route redirects to the forced-change screen, change the password, and confirm the app opens at `/` and the screen does not return. Quickstart, "After each upstream issue ships".

- [ ] T047 [US5] Regenerate the client and commit it separately; confirm `UserResponse.must_change_password` exists, and note the exact field name and the `403` detail string from the issue
- [ ] T048 [P] [US5] Add `@Default(false) bool mustChangePassword` to `User` in `lib/core/access/user.dart` and map it in `User.fromResponse` (:33-51); regenerate freezed
- [ ] T049 [P] [US5] Add `void Function()? onPasswordChangeRequired` to `AuthInterceptor` in `lib/core/network/auth_interceptor.dart`, mirroring `onUnauthorized`; fire it on a `403` whose `_detailFrom(body)` is `password_change_required` (the request still fails with its normal error). Add a case to `test/unit/core/network/auth_interceptor_test.dart` using `_FakeHttpClientAdapter` (a `403` case already exists at :46)
- [ ] T050 [US5] In `auth/presentation/session/auth_notifier.dart`, add `reloadCurrentUser()` (`repository.me()` then a new authenticated state; on a `401`, sign the user out) and wire `onPasswordChangeRequired` to set `mustChangePassword: true` (next to the existing `onUnauthorized` wiring at :23). Extend `test/unit/features/auth/auth_notifier_test.dart`. Depends on T048, T049
- [ ] T051 [US5] Add a `forced` mode to `ChangePasswordScreen` (`auth/presentation/account/change_password_screen.dart`, C2): no back arrow, `PopScope(canPop: false)`, title `passwordRequiredTitle`, a `passwordRequiredExplanation` body, a Logout button keyed `userMenuLogout` calling `authProvider.notifier.signOut()`, and on success `reloadCurrentUser()` instead of `_SuccessView`. Add `passwordRequiredTitle` and `passwordRequiredExplanation` to both `.arb` files (EN and ES) and regenerate l10n. Depends on T050
- [ ] T052 [US5] In `lib/app/router/app_router.dart`, add `GoRoute('/auth/password-required')` beside the other `/auth/*` routes (:319-334), add it to the `requiresSession` check (:513), and in `_redirect` (:504-533) send a flagged user to it from any other location and an unflagged user who lands on it to `/`. Add router cases to `test/unit/app/router/app_router_test.dart` using `_FixedAuthNotifier` with a `mustChangePassword` user (redirect in, redirect out, typed URL redirects back). Depends on T048, T051
- [ ] T053 [US5] Add a widget test for the forced screen in `test/widget/features/auth/change_password_screen_test.dart` (no back button, logout works, a successful change reloads the user and leaves the screen), then walk the US5 quickstart scenario against the dev backend

---

## Dependencies & Execution Order

### Phase dependencies

- **Phase 1 (T001)**: no dependencies.
- **Phase 2 (T002)**: after Phase 1. It blocks every story, because all of them need strings.
- **Phases 3–6 (US1–US4)**: after Phase 2. They touch different files, with two exceptions that create a real order: **US4 depends on US1** (T033 extends the widget T004 creates, and T034/T035 edit the same controllers and screens US1 edits). US2 and US3 are independent of everything except T002.
- **Phase 7**: after the stories you ship.
- **Phase 8**: each block waits for its mbe-api issue, then for the regeneration task that opens it.

### Within each story

- Tests first where listed, and they should fail before the implementation.
- US1: T004 → T008/T009/T010 (each also needs its controller task).
- US2: T015 → T016 → T021; T017, T018, T019 → T020 → T021 → T022.
- US3: T025 → T026 → T027 → T028.
- US4: T031 → T032 → T034; T031 → T033 → T034; T031 → T035; T034 + T035 → T036.

### Parallel opportunities

- After T002, US1, US2 and US3 can run in parallel by different people.
- US1: T003, T005 and T007 (T006 follows T005 because they share a file), then T011 and T012.
- US2: T013, T014, T017, T018, T019 are independent files.
- US3: T023 and T024.
- US4: T029 and T030.
- Phase 8: T048 and T049 in parallel.

---

## Implementation Strategy

### MVP first (the P1 scope)

1. Phase 1, then Phase 2.
2. **US1** (confirm password) and **US2** (paid-sale read-only) are both P1 and need no backend change. Do US1 first: it is small and finishes in one pass. US2 is the larger piece.
3. Stop and validate with quickstart scenarios 1–3 and 5–9.

### Incremental delivery

1. US3 (other-facility stock) next. It ships with the interim heading and gains facility groups when #242 lands.
2. US4 (password policy) after US1, because it extends the widget and controllers US1 touches. It ships with the 6-character interim rule and switches to the server's policy when #241 lands.
3. Phase 7 to verify, then commit.
4. Phase 8 as each mbe-api issue ships. US5 is built only then.

### Notes

- The `[P]` markers assume no two tasks edit one file at once. T005 and T006 share a file, so T006 is not marked `[P]`.
- Commit after each task or logical group. Regenerated client code (Phase 8) goes in its own commit.
- Do not hand-edit generated files (`*.g.dart`, `*.freezed.dart`, `lib/generated/openapi`, `app_localizations*.dart`).
