---

description: "Task list for spec 058: localized API messages from error codes"
---

# Tasks: Localized API Messages from Error Codes

**Input**: Design documents from `specs/058-localized-api-errors/`

**Baseline (T001, 2026-11-09)**: 4016 passing, 76 skipped, 7 failing, all of them existing golden or screenshot comparisons that fail without this feature: `core_widgets_golden_test.dart` (DataTableView, EntityStatusCell, LabelMultiPicker, DateRangeFilterChip ×2, StatusChip) and `pos_screens_screenshot_test.dart` (sales list US1). The error-banner goldens pass. Getting there needed one unrelated fix: the regenerated analytics client did not compile (`Comparison? comparison = previous_period`), so I added an `isEnumRef` guard to `tool/openapi-templates/dart-dio/api.mustache` and regenerated through `tool/generate_api_client.sh`. Only `analytics_api.dart` changed.

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md), [data-model.md](data-model.md), [contracts/](contracts/), [quickstart.md](quickstart.md)

**Tests**: Included. The plan lists them (unit, widget, golden), and SC-001/SC-003/SC-004 are verified by tests. Existing tests must keep passing (SC-006).

**Organization**: Tasks are grouped by user story. US1 and US2 are both P1 and ship together (clarification 2026-11-09: forms are where users meet refusals), but each is testable on its own.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: can run in parallel (different files, no dependency on an unfinished task)
- **[Story]**: US1, US2, US3, from spec.md
- Paths are relative to the repository root.

## Repository rules that apply to every task

- Regenerate with `dart run build_runner build` after changing a freezed class or provider. `*.g.dart` is gitignored, but **`*.freezed.dart` is tracked** (the README says otherwise), so a regenerated or new one is part of the change.
- `lib/l10n/app_localizations*.dart` **are tracked**. After any ARB edit run `flutter gen-l10n` and include the regenerated files.
- Every new string goes in **both** `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb` (parity test).
- Format only the files you changed (`dart format <files>`). Never run `dart format` repo-wide.
- Do not touch `lib/generated/`. Do not edit mbe-api.
- Only `flutter test` against the existing suite may be used to judge "unchanged behaviour".

---

## Phase 1: Setup

- [X] T001 Baseline on branch `058-localized-api-errors`: run `flutter pub get`, `dart run build_runner build --delete-conflicting-outputs`, `flutter analyze lib test` and `flutter test`. Write the total passing count at the top of this file under a "Baseline" line (SC-006 compares against it).

---

## Phase 2: Foundational (blocks every story)

**Purpose**: read the coded error, carry it on `AppError`, and provide the localizer entry points. Until a code is added in US1 every localizer returns `null`, so app behaviour is unchanged after this phase.

- [X] T002 [P] Create `lib/core/errors/api_problem.dart` per [data-model.md](data-model.md) `ApiProblem` and `ApiProblemPart`: `codeName`, `code` (`ErrorCode?`), `params`, `parts`, `detail`, `detailItems`, and typed accessors `intParam`, `stringParam`, `decimalParam`, `dateParam`, `listParam`, `mapListParam` that return `null` on a missing key or wrong type. Add `static ApiProblem? fromBody(Object? body)`: returns `null` unless the body is a `Map` with a `String` `code`; resolves `code` with `appSerializers.deserializeWith(ErrorCode.serializer, codeName)` inside `try` (unknown name → `null`, never throws, research R2); reads `detail` as a string or `detail.message`; fills `detailItems` from `detail.lines` / `detail.missing`; reads `errors[]` into parts (`extra` = the item's other keys). Import the generated client the way `lib/core/network/api_serializers.dart` does.
- [X] T003 Test `ApiProblem` in `test/unit/core/errors/api_problem_test.dart`: coded body parses; unknown code string keeps `codeName` with `code == null`; body without `code` → `null`; non-map body → `null`; every accessor returns `null` for missing and mistyped values (`"four"` for an int); `"12"` parses as int 12; `errors[]` parts with `extra` (inventory-count shape); `detailItems` from today's `{message, lines}` and `{message, missing}` dicts. Depends on T002.
- [X] T004 Add `ApiProblem? problem` as an optional **last** parameter to `validation`, `auth`, `notFound`, `server` and `creditHold` in `lib/core/errors/app_error.dart` (data-model.md). Leave `network` and `FieldError` unchanged. Run build_runner. Depends on T002.
- [X] T005 In `mapDioException` (`lib/core/network/auth_interceptor.dart`), build `ApiProblem.fromBody(body)` and pass it to every variant it creates, using the variant rules in [contracts/error-mapping.md](contracts/error-mapping.md) §1–§2. In this task do **not** add the credit-code selection (T058) or the password-change code check (T057). Keep `_jsonBodyOf` so bytes bodies are covered. Depends on T004.
- [X] T006 Extend `test/unit/core/network/auth_interceptor_test.dart` with new groups: coded JSON body and bytes body each yield `problem`; a body without `code` maps exactly as before; unknown code keeps the variant by status. Existing groups stay untouched and green. Depends on T005.
- [X] T007 Create `lib/core/errors/localize_problem.dart` skeleton per [contracts/display.md](contracts/display.md) §1 and §6:
  - `String? localizeProblem(ApiProblem, AppLocalizations, AppFormatters)`, returning `null` for now;
  - `String? localizeValidationType(String type, AppLocalizations l10n)`, returning `null` for now;
  - `const Set<String> localizedValidationTypes = {}` and `String serverFieldValue(FieldError e)` (returns `e.type` when the set contains it, else `e.msg`);
  - `const Set<ErrorCode> localizedErrorCodes = {}`;
  - `String resourceNoun(String? resource, AppLocalizations l10n)` returning a placeholder until T011;
  - `extension AppErrorText on AppError` with `localizedMessage` and `userMessage` as specified in display.md §1.
  Depends on T004.
- [X] T008 Test the extension in `test/unit/core/errors/user_message_test.dart`: with the skeleton, `userMessage` equals `serverMessage` for server/notFound/creditHold; for a field-level `ValidationError` it joins each entry's `msg`; `network` gives `null`-safe output. Depends on T007.

**Checkpoint**: `flutter analyze lib test` clean; the whole suite matches the T001 baseline.

---

## Phase 3: User Story 1 — Server refusals read in the user's language (P1) 🎯 MVP

**Goal**: for the 96 in-scope codes the error panel shows one message in the user's language, with formatted values and no English; every other case looks as it does today.

**Independent test**: [quickstart.md](quickstart.md) §2 checks 1, 3 and 6 in `es-MX` and `en`, plus the unknown-code case in §3.

### Panel and message plumbing

- [X] T009 [US1] Make `ErrorBanner` a `ConsumerWidget` in `lib/core/widgets/error_banner.dart`, reading `formattersProvider` once per build, with the line rules in display.md §2: localized text replaces headline + English; otherwise today's output. Keep the constructor unchanged.
- [X] T010 [US1] Add `ProviderScope` to every existing test that pumps `ErrorBanner` without one. Find them with `grep -rln "ErrorBanner" test`; at least `test/widget/core/widgets/error_banner_test.dart`, `list_state_views_test.dart`, `test/widget/features/list_error_rendering_test.dart`, `payment_step_gate_test.dart`, `customer_bar_test.dart`, `pos_sale_completed_dialog_test.dart`, the three `*_inline_create_test.dart` files, `test/widget/core/documents/document_preview_dialog_test.dart`, and the `ErrorBanner` case in `test/golden/core_widgets_golden_test.dart` (check `test/golden/golden_harness.dart` for a shared wrapper). Behaviour assertions stay unchanged. Depends on T009.

### Nouns and generic codes

- [X] T011 [US1] Record nouns. Add the 42 `apiResource<Name>(int count)` plural keys, the `apiResourceGender<Name>` keys and `apiResourceGeneric`, from [contracts/message-catalog.md](contracts/message-catalog.md) §4, to both ARBs. Implement `resourceNoun` (the generic noun for any other name) and a gender accessor in `lib/core/errors/localize_problem.dart`. Create `test/unit/core/errors/problem_fixtures.dart`: a map from each in-scope `ErrorCode` to sample params; start it empty and let each later task add its codes. Run `flutter gen-l10n`.
- [X] T012 [US1] Generic codes (catalog §1, 16 codes). Add `apiError*` keys to both ARBs and the cases to `localizeProblem`, with fixtures:
  - add the codes to `localizedErrorCodes`;
  - `resource.not_found` and `resource.already_exists` use `resourceNoun` and the Spanish gender `select`;
  - `resource.still_referenced` builds `{list}` from `references` with `apiReferenceCount`/`apiReferenceMore`, and falls back to `apiErrorResourceStillReferencedGeneric` for an empty list;
  - `auth.forbidden` is generic and never lists `required`.
  Add tests in `test/unit/core/errors/localize_problem_generic_test.dart`: each code in `en` and `es`; a missing or mistyped param returns `null`; an unknown `resource` uses the generic noun.

### Area codes (sequential: they share `localize_problem.dart` and the ARB files)

- [X] T013 [US1] Group A (catalog §2): `cash_session.*` (6), `csd.*` (6), `customer.*` (6), `customer_discount.product_not_found`. Money params (`outstanding`, `limit`) go through `fmt.display.currency`; `overdue_count` uses an ICU plural. ARB en+es, cases, `localizedErrorCodes`, fixtures, and tests in `test/unit/core/errors/localize_problem_group_a_test.dart`, including `"18450.00"` → `$18,450.00` and the plural `one`/`other` forms.
- [X] T014 [US1] Group B: `delivery_order.*` (10), `document.not_editable`, `email.*` (2), `facility.*` (3), `image.*` (2), `incidence.reason_required`, `lock.busy`, `payment.no_ticket`, `point_of_sale.warehouse_facility_mismatch`. Quantities use `fmt.display.quantity`. `image.too_large` renders `max_bytes` as MB, or KB below 1 MB, through `fmt.display.quantity` with a unit key: no `toStringAsFixed` and no `intl` import (see `test/unit/core/formatting_guard_test.dart`). `facility.other_facility` uses the noun and gender `select`. ARB, cases, set, fixtures, tests in `localize_problem_group_b_test.dart`.
- [X] T015 [US1] Group C: `price_list.*` (4), `product.*` (3), `product_price.*` (2), `quote.*` (4), `refund.*` (8). `refund.line_invoiced` is two keys (with and without the folio, `invoice?`). `product_price.references_not_found` uses the plural noun. ARB, cases, set, fixtures, tests in `localize_problem_group_c_test.dart`.
- [X] T016 [US1] Group D: `sales_order.*` (8), `supplier_agreement.end_before_start`, `taxpayer_certificate.holder_mismatch`, `taxpayer_issuer.unknown`, `user.*` (3), `user_profile.not_active`, `warehouse.*` (3). `sales_order.insufficient_stock`, `.zero_priced_lines` and `.missing_delivery_details` render the headline followed by one line per item, as in [contracts/error-mapping.md](contracts/error-mapping.md) §5: a part with a known code is localized, a part with an unknown code shows `params.product_code` or is left out, and a `detailItems` entry is shown as sent. `supplier_agreement.end_before_start` renders its `start` and `end` params through `fmt.display.date`. ARB, cases, set, fixtures, tests in `localize_problem_group_d_test.dart`, including both shapes giving the same lines in the same order.
- [X] T017 [US1] Coverage test `test/unit/core/errors/catalog_coverage_test.dart` (SC-001, SC-003): every member of `localizedErrorCodes` renders a non-empty message in `en` and `es` from `problem_fixtures.dart`; every code with a `verdict` of `IN` in `specs/058-localized-api-errors/contracts/code-scope.tsv` is in the set; for every code with params, a missing and a mistyped param each return `null`; an unknown code string and a `null` code return `null`. Depends on T012–T016.

### Logging and other displays

- [X] T018 [US1] Logging (FR-020, [contracts/error-mapping.md](contracts/error-mapping.md) §4). In `mapDioException`, when a problem is built, write one `debugPrint('api-error $status $codeName params=<json> detail=<detail>')`. Never log the request, headers, or validation `input`. Test in `auth_interceptor_test.dart` by capturing `debugPrint`: one line per failed request, with the fields present. Depends on T005.
- [X] T019 [P] [US1] `lib/features/sales/presentation/delivery/destination_card.dart` (~line 188): replace `e.serverMessage ?? l10n.errorServerGeneric` with `e.userMessage(l10n, fmt) ?? l10n.errorServerGeneric`, reading `formattersProvider` from the widget's `ref`. Extend `test/widget/features/sales/destination_card_test.dart` for a coded refusal.
- [X] T020 [P] [US1] `lib/features/sales/presentation/refunds/refund_detail_screen.dart` (lines ~206, ~233) and `refund_open_or_resume.dart` (the snackbar at ~113): use `userMessage`. Only the snackbar changes here; the nothing-to-return branch is T060. Extend the existing refund tests for a coded refusal.

### Banner tests and golden

- [X] T021 [US1] Extend `test/widget/core/widgets/error_banner_test.dart` for Story 1 scenarios 1–6: known code in `es` shows only the localized text and no English; in `en` the same; money and date params follow the formatting settings; unknown code, no code, and a known code with a broken param show the headline plus the English detail; none throws. Depends on T009, T012–T016.
- [X] T022 [US1] Golden: add an `error_banner_localized` case to `test/golden/core_widgets_golden_test.dart` (a coded server refusal). Do the font check from `test/golden/README.md` first, then run `flutter test test/golden --update-goldens` and confirm that only the new PNGs were added and the existing `error_banner_*.png` files are unchanged. Depends on T009.

**Checkpoint (US1)**: Story 1 works end to end for panels. Forms still show their old English line until Phase 4.

---

## Phase 4: User Story 2 — Forms explain refusals in the user's language (P1)

**Goal**: forms keep the `AppError` and render it at display time, so the reason is localized and follows a language change. Depends on the US1 messages (T011–T016).

**Independent test**: [quickstart.md](quickstart.md) §2 check 5, then switch language with the error on screen.

### Shared pieces

- [X] T023 [US2] Create `lib/core/widgets/form_error_banner.dart`: `FormErrorBanner({required String headline, AppError? cause})` per display.md §3, built on `ErrorBanner`; the reason line is `cause.userMessage(l10n, fmt)` when non-empty. Test in `test/widget/core/widgets/form_error_banner_test.dart`: no cause → headline only; localized cause → headline plus localized reason and no English; unknown code → headline plus English; the reason follows a locale change.
- [X] T024 [US2] Validation types. Add the 8 `apiValidation*` keys of catalog §3 to both ARBs, implement `localizeValidationType` (returns `null` for `password_policy` and unknown types), fill `localizedValidationTypes`, and make `ErrorBanner`'s per-entry lines use `localizeValidationType(e.type) ?? e.msg`. Tests in `test/unit/core/errors/localize_validation_type_test.dart` and the banner test. Depends on T007, T009.

### Convert each form (all [P]: each task touches only its own pair of files)

For each pair: in the controller state replace `String? errorDetail` with `AppError? errorCause`, every `errorDetail: e.serverMessage` with `errorCause: e`, and every `errorDetail: null` with `errorCause: null`. In the screen replace the hand-built `ErrorBanner(error: AppError.validation([FieldError(msg: _localizeFormError(...)), FieldError(msg: errorDetail)]))` with `FormErrorBanner(headline: _localizeFormError(l10n, state.error!), cause: state.errorCause)`. Leave `_localizeFormError` and `_localizeFieldError` for client-side codes as they are. The codebase will not compile until T054; do not run tests between T025 and T054.

- [X] T025 [P] [US2] `lib/features/catalog/presentation/vehicle_operator_form_controller.dart` + `vehicle_operator_form.dart`
- [X] T026 [P] [US2] `lib/features/catalog/presentation/supplier_form_controller.dart` + `supplier_form.dart`
- [X] T027 [P] [US2] `lib/features/catalog/presentation/employee_form_controller.dart` + `employee_form.dart`
- [X] T028 [P] [US2] `lib/features/catalog/presentation/product_form_controller.dart` + `product_detail_screen.dart`, plus FR-011: at `product_form_controller.dart:~607` store `serverFieldValue(fieldError)`, and let the screen's field-error text switch default to `localizeValidationType(code, l10n) ?? code` (display.md §6)
- [X] T029 [P] [US2] `lib/features/catalog/presentation/customer_form_controller.dart` + `customer_form.dart`
- [X] T030 [P] [US2] `lib/features/catalog/presentation/vehicle_form_controller.dart` + `vehicle_form.dart`
- [X] T031 [P] [US2] `lib/features/catalog/presentation/point_sale_form_controller.dart` + `point_sale_form.dart`
- [X] T032 [P] [US2] `lib/features/catalog/presentation/warehouse_form_controller.dart` + `warehouse_form.dart`
- [X] T033 [P] [US2] `lib/features/catalog/presentation/cash_drawer_form_controller.dart` + `cash_drawer_form.dart`
- [X] T034 [P] [US2] `lib/features/catalog/presentation/taxpayer_recipient_form_controller.dart` + `taxpayer_recipient_form.dart`
- [X] T035 [P] [US2] `lib/features/catalog/presentation/taxpayer_issuer_form_controller.dart` + `taxpayer_issuer_detail_screen.dart`
- [X] T036 [P] [US2] `lib/features/catalog/presentation/payment_method_option_form_controller.dart` + `payment_method_option_form.dart`
- [X] T037 [P] [US2] `lib/features/catalog/presentation/label_form_controller.dart` + `label_form.dart`
- [X] T038 [P] [US2] `lib/features/catalog/presentation/expense_form_controller.dart` + `expense_form.dart`
- [X] T039 [P] [US2] `lib/features/catalog/presentation/facility_form_controller.dart` + `facility_detail_screen.dart`
- [X] T040 [P] [US2] `lib/features/catalog/presentation/taxpayer_certificate_upload_controller.dart` + `taxpayer_certificate_upload_dialog.dart`
- [X] T041 [P] [US2] `lib/features/catalog/presentation/contact_inline_create_controller.dart` + `contact_inline_create.dart`, plus FR-011 at `contact_inline_create_controller.dart:~106` (`serverFieldValue`; the field text switch defaults to `localizeValidationType`)
- [X] T042 [P] [US2] `lib/features/catalog/presentation/bank_account_inline_create_controller.dart` + `bank_account_inline_create.dart`
- [X] T043 [P] [US2] `lib/features/catalog/presentation/address_inline_create_controller.dart` + `address_inline_create.dart`
- [X] T044 [P] [US2] `lib/features/catalog/presentation/supplier_agreement_dialog_controller.dart` + `supplier_agreement_dialog.dart`, plus FR-011 at `supplier_agreement_dialog_controller.dart:~128`
- [X] T045 [P] [US2] `lib/features/catalog/presentation/customer_discount_dialog_controller.dart` + `customer_discount_dialog.dart`
- [X] T046 [P] [US2] `lib/features/pricing/presentation/exchange_rate_form_controller.dart` + `exchange_rate_form.dart`
- [X] T047 [P] [US2] `lib/features/pricing/presentation/price_list_form_controller.dart` + `price_list_form.dart` + `price_list_delete_dialog.dart` (3 `errorDetail` references there)
- [X] T048 [P] [US2] `lib/features/sales/presentation/open_session_form_controller.dart` + `cash_sessions_screen.dart` (only the `errorDetail` conversion; busy codes are T059)
- [X] T049 [P] [US2] `lib/features/sales/presentation/close_session_form_controller.dart` + `cash_session_detail_screen.dart`
- [X] T050 [P] [US2] `lib/features/auth/presentation/admin/users_controller.dart` + `user_detail_screen.dart`, plus FR-011: line 416 becomes `errorCause: e`; lines ~420 and ~467 (`error: e.errors.first.msg`) store `serverFieldValue(e.errors.first)`; the screen's error text switch defaults to `localizeValidationType(code, l10n) ?? code`
- [X] T051 [P] [US2] `lib/features/auth/presentation/admin/user_profiles_controller.dart` + `user_profile_detail_screen.dart`, plus FR-011 for the two `error: e.errors.first.msg` stores (~234, ~255)
- [X] T052 [P] [US2] `lib/features/sales/presentation/customer_inline_create.dart`: consume `errorCause` from the customer form state converted in T029. Depends on T029.
- [X] T053 [P] [US2] Pricing tooltip (display.md §5): add `AppError? cause` to `RejectedEdit` in `lib/features/pricing/presentation/pricing_grid_controller.dart`; on `AppError` at ~line 936 set `reason = saveFailed` and `cause = e` (drop the `errors.first.msg` reason). In `price_cell.dart` (~line 269) the `saveFailed` tooltip is `cause?.userMessage(l10n, fmt) ?? l10n.pricingSaveFailedError`. Update the existing pricing grid tests that assert a server-message reason.

### Verification

- [X] T054 [US2] Run `dart run build_runner build --delete-conflicting-outputs`, then `flutter analyze lib test`, and fix leftovers until clean. Confirm `grep -rn "errorDetail" lib --include='*.dart' | grep -v "\.freezed\.dart"` finds nothing. Depends on T025–T053.
- [X] T055 [US2] Update the existing tests that reference `errorDetail` (`grep -rln errorDetail test`, 13 files / 23 references) to assert `errorCause`, or the rendered text, instead. Behaviour they check stays the same. Depends on T054.
- [X] T056 [US2] Widget tests for Story 2 in `test/widget/features/catalog/form_server_error_localization_test.dart`, using the vehicle operator form: a known code (`resource.already_exists`) shows the headline plus the localized reason and no English (scenario 1); changing the locale with the error on screen re-renders it (scenario 2); an unknown code shows today's headline plus English (scenario 3); a client-side error is unchanged (scenario 4). Add a product-form case for `product_barcode_invalid` (scenario 5). Depends on T054.

**Checkpoint (US2)**: the whole suite is green again and matches the T001 baseline, apart from tests that deliberately changed in T055.

---

## Phase 5: User Story 3 — Special handling relies on codes (P2)

**Goal**: each special path recognizes the code first and keeps the old check as a fallback; the stock, zero-price and missing-detail refusals read both today's shape and the announced phase-3 shape.

**Independent test**: for each path, a response with only the code, then one with only the old signal, give the same behaviour (spec Story 3).

- [X] T057 [US3] Password change by code, in `AuthInterceptor.onError` (`lib/core/network/auth_interceptor.dart`): call `onPasswordChangeRequired` when `problem?.code == ErrorCode.authPeriodPasswordChangeRequired` (check the exact generated member name), keeping the 403 + `'password_change_required'` match as the fallback. Tests in `auth_interceptor_test.dart`: code only, old signal only, and a 403 with neither.
- [X] T058 [US3] Credit by code. In `mapDioException`, select `AppError.creditHold(detail, problem)` when `problem?.code` is one of the five customer credit codes (error-mapping.md §2), whatever the status. In `lib/features/sales/data/sales_order_repository_impl.dart` (`_toSalesOrderError`) and `sales_quote_repository_impl.dart` (`_toQuoteError`) keep the "422 + string detail" check only when the mapped error has no problem and is not already a `creditHold`. Tests in `auth_interceptor_test.dart` (each of the five codes) and `test/unit/features/sales/sales_quote_repository_impl_test.dart` plus the order repository tests: the fallback still works with no code. Depends on T005.
- [X] T059 [US3] Busy drawer / busy cashier by code in `lib/features/sales/presentation/open_session_form_controller.dart` (~line 174): `problem.code == cashSession.drawerBusy` → `drawerBusy`; `.userBusy` → `cashierBusy`, taking the other session id from `params.cash_session_id` without a second request. Keep today's re-fetch only for a 409 with no problem. Extend `test/unit/features/sales/open_session_form_controller_test.dart`: both codes make no extra repository call; a 409 without a code still re-fetches. Depends on T048.
- [X] T060 [US3] Nothing-to-refund by code in `lib/features/sales/presentation/refunds/refund_open_or_resume.dart` (~line 73): `refund.nothingRefundable` and `refund.noReturnableLines` → `RefundRefusal.nothingToReturn` with no English appended (error-mapping.md §7); `refund.orderNotPaid`/`orderNotCompleted` → the existing `notPaid`/`notCompleted` refusals; a 409 without a code keeps today's behaviour. Extend `test/unit/features/sales/refund_open_or_resume_test.dart`. Depends on T020.
- [X] T061 [US3] Confirm refusals, both shapes (FR-019, error-mapping.md §5). In `_toConfirmError` (`sales_order_repository_impl.dart`, ~line 435) take the mapped error from `_toAppError`; for a dict `detail`, keep `ServerError.message` as `[message, ...detailItems].join('\n')` (today's fallback, now also including `missing`) and keep its `problem`. A string `detail` with `errors[]` parts needs no special case: `problem.parts` carries them. A credit refusal still falls through to `_toSalesOrderError`. Tests in `test/unit/features/sales/sales_order_confirm_error_test.dart`: zero-priced and stock refusals as today's dict and as the phase-3 shape give the same lines in the same order through `userMessage`; missing delivery details; a part with an unknown code shows `product_code` or is dropped; a dict without a `code` gives today's joined message. Depends on T016.

**Checkpoint (US3)**: every path behaves identically with code-only and old-signal-only responses.

---

## Phase 6: Polish & cross-cutting

- [X] T062 Guard test `test/unit/core/server_text_guard_test.dart` (SC-004), modelled on `test/unit/core/formatting_guard_test.dart`: no file under `lib/` outside `lib/core/errors/`, `lib/generated/` and generated `*.freezed.dart`/`*.g.dart` may read `serverMessage`, `.message` of an `AppError`, or `errorDetail`. Fix any hit by routing it through `userMessage`. Depends on T054, T019, T020.
- [X] T063 Run `flutter gen-l10n`, `flutter analyze lib test`, `dart format` on the files this feature changed (never repo-wide), and `flutter test`. The result must match the T001 baseline plus the new tests (SC-006); `l10n_parity_test.dart` and `layering_test.dart` pass.
- [ ] T064 Live checks against mbe_dev, per [quickstart.md](quickstart.md) §2 (SC-005): credit hold in `es-MX` and `en`, password change landing on the change-password screen, zero-priced confirm listing lines, busy drawer without a follow-up request, duplicate record on a catalog form, delete with references, and one log line per refusal. Find fixtures at runtime; do not hard-code ids.
  - **Partial, 2026-11-09.** A throwaway live test against `http://127.0.0.1:8000` covered the non-mutating refusals: `auth.not_authenticated`, `resource.not_found` for a customer, an order and a refund, `request.route_not_found`, and `auth.forbidden` for the read-only account on a write route. Each carried its code and params and rendered in both languages. **Not run**, because each changes data on the shared dev server: credit hold on an order, password change landing on its screen, zero-priced confirm, busy drawer, a duplicate record on a catalog form, and delete with references (quickstart §2 checks 1–6).
- [ ] T065 mbe-api issue for phase-3 part codes (research R9): **ask the user for a go-ahead first**, then file the drafted issue against `mictlanix/mbe-api` with `gh issue create`. mbe-ui must not edit mbe-api (constitution §III).
- [ ] T066 Open the PR with "Roadmap" section lines `Closes mictlanix/mbe-roadmap#148` and `Closes #232`, listing the 96 / 9 / 42 scope and noting the two measured limits of the scope check (research R1).

---

## Dependencies & execution order

- **Phase 1 → Phase 2 → everything else.** Phase 2 changes no visible behaviour.
- **US1** needs Phase 2. T011–T016 are strictly sequential: they share `localize_problem.dart`, `problem_fixtures.dart` and the two ARB files. T019 and T020 are independent of them.
- **US2** needs Phase 2 and the US1 messages (T011–T016), so a localized reason exists to show. T025–T053 are independent of each other. T054 → T055 → T056.
- **US3** needs Phase 2 and T016 (for T061), T048 (for T059) and T020 (for T060). T057, T058, T059, T060 and T061 touch different files and can run in parallel once their dependencies are done.
- **Polish** needs all stories. T065 can happen any time after the plan is approved.

### Parallel examples

```text
# Phase 2: T002 first, then these together
T004 AppError.problem            (lib/core/errors/app_error.dart)
T007 localizer skeleton          (lib/core/errors/localize_problem.dart)   # both only need T002/T004's types

# Phase 4: after T024, all of these at once
T025 vehicle operator  T026 supplier  T027 employee  ...  T053 pricing tooltip

# Phase 5: once T016, T020 and T048 are done
T057 password change   T058 credit   T059 open session   T060 refund   T061 confirm
```

## Implementation strategy

1. **MVP = Phase 1 + 2 + US1.** Panels localize in the default locale and nothing else changes. Stop here to demo.
2. **Ship US1 and US2 together.** Forms are where most refusals appear, so US1 alone leaves the most-used screens in English (clarification 2026-11-09).
3. **US3 last.** Those paths already work; the value is robustness and being ready for mbe-api's phase 3.
4. **Follow-ups** (out of scope here): messages for the 155 codes whose routes the app does not call yet. The spec that builds each area's screens adds its codes, ARB keys and `localizedErrorCodes` members together, and re-measures with `contracts/code-scope.tsv`.

## Notes

- Mapping `ErrorCode` members: the generated names insert `Period` for the dot (research R2), e.g. `customerPeriodCreditHold`. Prefer reading a member by its wire name in comments.
