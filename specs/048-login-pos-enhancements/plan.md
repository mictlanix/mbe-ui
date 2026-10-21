# Implementation Plan: Login & POS Sales Enhancements

**Branch**: `048-login-pos-enhancements` | **Date**: 2026-10-18 (revised the same day after mbe-api#240–#242 shipped) | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/048-login-pos-enhancements/spec.md`

## Summary

Five stories. All of them are buildable now: the three mbe-api changes they need shipped on 2026-10-18, and the client was regenerated (R9).

1. **Confirm password (P1)**
   - A shared `NewPasswordFields` widget holds the new-password field, a confirmation that is re-validated when the new password changes, and (with US4) the rule checklist.
   - It is used by the change, forgot and admin-create forms. Each controller guards submit on a match (R1).
2. **Paid sale read-only detail (P1)**
   - The POS workspace gains a `detail` mode, decided once when a sale opens by a pure predicate: paid, zero balance, and fully distributed if it is a delivery sale.
   - The predicate sits next to `resumeTargetFor` and shares one `saleIsDelivery` check with the open-sales selector.
   - A new `PosSaleDetailView` reuses the disabled line rows, the totals bar without its action, and the applied-payments panel. Payments are gated on `customerPayments` read, and the view adds the ticket preview (R5–R7).
3. **Other-facility warehouses (P2), which also fixes mbe-ui#182**
   - The stock cache already holds every facility's rows, now with their facility. The pop-up gains a grouped "Other facilities" section whose rows can be **selected**: mbe-api accepts cross-facility lines, and legacy uses them for 14% of lines.
   - The line's current warehouse is always listed.
   - A pure `lineWarehouseLabel` makes the closed field show `name · facility` or `#id`, never an empty field. The stock gate already works for any warehouse (R8).
4. **Password policy (P2)**
   - A `PasswordPolicy` entity read from `GET /auth/password-policy` (public), with a pure `unmet()` and a checklist in `NewPasswordFields`.
   - `FieldError` gains `failedRules` from the 422's `ctx.failed`, and each form shows localized per-rule messages (R2, R3).
5. **Forced change (P3)**
   - `User.mustChangePassword`, a `/auth/password-required` route and redirect, and a forced mode on `ChangePasswordScreen` with logout.
   - An interceptor hook turns `403 password_change_required` into the redirect, and `reloadCurrentUser()` runs after the change (R4).

## Technical Context

**Language/Version**: Dart `^3.10.3`, Flutter stable (unchanged)

**Primary Dependencies**:
- Riverpod (`riverpod_annotation` / generator 4), `freezed` 4, `go_router` `^17.3.0`, `decimal`, the generated `mbe_api_client`.
- No new packages. The client is already regenerated (`6f68797`, `401a78a`), so there is no further OpenAPI codegen. `build_runner` re-runs for freezed and riverpod changes.

**Storage**: N/A (online-only, §VII).

**Testing**:
- `flutter_test` + `mocktail`. Widget tests use `ProviderScope` overrides (`authRepositoryProvider`, `tokenStorageProvider`) and `pos_test_harness.dart`.
- Router tests use `_FixedAuthNotifier`, and interceptor tests use `_FakeHttpClientAdapter`.
- POS goldens that include the warehouse dialog or line field are regenerated.

**Target Platform**: Web/desktop first (Expanded tier). Compact (390 px) is verified for the detail view, the warehouse dialog and the forced-change screen.

**Project Type**: Flutter client application, feature-first layered

**Performance Goals**:
- Each password form adds one policy read.
- Opening a paid **delivery** sale adds one `listForSale` read. Counter sales add none.
- The detail view adds one payments read, and only with the privilege.
- Other-facility stock adds no calls: the rows are already cached.

**Constraints**:
- The line band's measured height and baseline are unchanged (§VI), so the label stays one ellipsized line.
- Amounts and dates go through `formattersProvider` (§V guard).
- No new `SystemObject`. This is the first use of `customerPayments` read.
- No app-bar actions in the detail view (§VI).
- The client never reads or logs the 422 `input` field, which echoes the rejected password.

**Scale/Scope**:

| | Files |
|---|---|
| **New** | `features/auth/domain/entities/password_policy.dart`, `features/auth/presentation/widgets/new_password_fields.dart`, `features/sales/presentation/pos_sale_detail_view.dart`, `features/sales/presentation/capture/other_facility_stock.dart` |
| **Edited, core** | `core/errors/app_error.dart` (`FieldError.failedRules`), `core/network/auth_interceptor.dart` (`failedRules` parsing, `onPasswordChangeRequired`), `core/access/user.dart` (`mustChangePassword`) |
| **Edited, auth** | `account/account_controller.dart`, `account/change_password_screen.dart` (also the forced mode), `account/forgot_password_screen.dart`, `admin/users_controller.dart`, `admin/user_detail_screen.dart`, `domain/repositories/auth_repository.dart`, `data/auth_repository_impl.dart`, `session/auth_notifier.dart`, `app/router/app_router.dart` |
| **Edited, POS detail** | `pos_resume_controller.dart`, `pos_step_controller.dart`, `pos_workspace_screen.dart`, `open_sales_selector_controller.dart`, `payment/applied_payments_panel.dart`, `pos_sales_list_screen.dart` (shared `saleTicketRef`) |
| **Edited, warehouses** | `domain/entities/product_lookup_result.dart`, `capture/warehouse_picker_dialog.dart`, `capture/sale_line_editing.dart` |
| **Edited, l10n** | both `.arb` files plus the regenerated `app_localizations*.dart`; about 22 keys |

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Verdict | How |
|---|---|---|
| **I. Feature-first layering** | Pass | `PasswordPolicy` lives in `auth/domain`, reached through `AuthRepository` and a provider. The predicate, stock grouping and line label are pure functions beside the presentation code that uses them, the same pattern as `evaluateStock` and `resumeTargetFor`. The existing data-layer import in `account_controller.dart` predates this spec and is left untouched (R10). |
| **II. Riverpod** | Pass | `passwordPolicyProvider` and `saleDestinationsProvider` are generated providers. `PosStepState` gains a field. No other DI is added. |
| **III. Contract-driven API** | Pass | Uses only generated operations and DTOs. The three backend changes were filed (mbe-api#240–#242), shipped upstream (PRs #244–#246), and consumed through regeneration. Nothing was patched from this repo. |
| **IV. Deny-by-default RBAC** | Pass | `SystemObject` codes: `/auth/password-required` needs only a session. The detail view lives on the existing `/sales/pos/:saleId` route (`pos` read). It shows payments only with `customerPayments` read, and the ticket only with `canOpenDocument` (`salesOrders` read). The forced-change route requires a session. No new privileges. Other-facility warehouses come from the stock rows the capture step can already read, not `GET /warehouses`. |
| **V. Material 3 / l10n / formatting** | Pass | Standard M3 widgets. Every string is in both `.arb` files. The touched forms' hard-coded English messages and the hard-coded Spanish error in `AppliedPaymentsPanel` move to l10n. Amounts and dates go through `formattersProvider`. |
| **VI. Desktop-first, compact-ready** | Pass | The POS workspace isn't one of the catalog record surfaces the read-only/View rules list, but the detail view follows them anyway: its title is "Ver venta" / "View sale", there are no app-bar actions, and no edit toggle is shown because a paid sale can't be edited. The detail view uses a two-pane Expanded layout and one column on Compact. The dialog's single scroll area is capped. The line label keeps the measured band. All are verified at 390 px with `expectNoHorizontalScroll`. No app-bar actions. |
| **VII. Online-only** | Pass | Nothing is persisted. The policy is read from the server each time, with no local fallback. |
| **Quality gates** | Pass | **Unit tests**: `PasswordPolicy.unmet`, `rulesFromFieldError`, `failedRules` parsing, `opensAsReadOnlyDetail`, `saleIsDelivery`, `otherFacilityStock`, `lineWarehouseLabel`, the `WarehouseStock` mapping, the controllers' guards, the router redirect, and the interceptor 403 hook. **Widget tests**: `NewPasswordFields`, the three forms and the forced mode, the workspace detail branch, `PosSaleDetailView`, and the warehouse dialog. **Goldens**: regenerated. |

**Post-design re-check** (after Phase 1): still passing. No Complexity Tracking entries.

## Project Structure

### Documentation (this feature)

```text
specs/048-login-pos-enhancements/
├── plan.md              # This file
├── research.md          # Phase 0 (R1–R10)
├── data-model.md        # Phase 1
├── quickstart.md        # Phase 1
├── contracts/
│   └── ui-contracts.md  # Phase 1 (C1–C5)
├── checklists/
│   └── requirements.md
└── tasks.md             # Phase 2 (/speckit-tasks)
```

### Source Code (repository root)

```text
lib/
├── app/router/app_router.dart                         # /auth/password-required + redirect (C2)
├── core/
│   ├── access/user.dart                               # + mustChangePassword
│   ├── errors/app_error.dart                          # FieldError.failedRules
│   └── network/auth_interceptor.dart                  # failedRules parsing; onPasswordChangeRequired
├── features/auth/
│   ├── domain/
│   │   ├── entities/password_policy.dart              # NEW PasswordPolicy, PasswordRule, rulesFromFieldError
│   │   └── repositories/auth_repository.dart          # + passwordPolicy()
│   ├── data/auth_repository_impl.dart                 # passwordPolicy() via generated AuthApi
│   └── presentation/
│       ├── widgets/new_password_fields.dart           # NEW (C1)
│       ├── account/account_controller.dart            # confirm + policy guards + rule mapping
│       ├── account/change_password_screen.dart        # C1; forced mode (C2)
│       ├── account/forgot_password_screen.dart        # C1
│       ├── admin/users_controller.dart                # confirm + passwordMismatch + rule mapping
│       ├── admin/user_detail_screen.dart              # C1 in create mode
│       └── session/auth_notifier.dart                 # reloadCurrentUser, flag wiring
├── features/sales/
│   ├── domain/entities/product_lookup_result.dart     # WarehouseStock.facilityId/Name
│   └── presentation/
│       ├── pos_resume_controller.dart                 # opensAsReadOnlyDetail, saleIsDelivery, saleDestinationsProvider
│       ├── pos_step_controller.dart                   # PosStepState.detail
│       ├── pos_workspace_screen.dart                  # _syncStepTo decision + detail branch
│       ├── pos_sale_detail_view.dart                  # NEW (C3)
│       ├── open_sales_selector_controller.dart        # shared saleIsDelivery
│       ├── pos_sales_list_screen.dart                 # shared saleTicketRef
│       ├── payment/applied_payments_panel.dart        # showChangeAndDate, l10n error
│       └── capture/
│           ├── other_facility_stock.dart              # NEW otherFacilityStock, lineWarehouseLabel (C4, C5)
│           ├── warehouse_picker_dialog.dart           # selectable other-facilities section (C4)
│           └── sale_line_editing.dart                 # pass facilityId; label fallback (C5)
└── l10n/app_en.arb, app_es.arb (+ regenerated app_localizations*.dart)

test/
├── unit/features/auth/{password_policy,users_controller,auth_notifier,auth_repository_impl}_test.dart
├── unit/features/sales/{open_sale_resolution,other_facility_stock,product_lookup_result}_test.dart
├── unit/app/router/app_router_test.dart
├── unit/core/network/auth_interceptor_test.dart
├── widget/features/auth/{new_password_fields,change_password_screen,forgot_password_screen,user_detail_screen}_test.dart
└── widget/features/sales/{pos_workspace_route,pos_sale_detail_view,warehouse_picker_dialog,
    sale_line_row,pos_047_extra_large_text}_test.dart
```

**Structure Decision**: existing feature-first layout with no new feature module. The password work stays in `features/auth` and `core`, and the POS work stays in `features/sales`.

## Complexity Tracking

No entries. The upstream dependencies recorded in the first version of this plan have all shipped.
