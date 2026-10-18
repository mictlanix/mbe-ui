# Implementation Plan: Login & POS Sales Enhancements

**Branch**: `048-login-pos-enhancements` | **Date**: 2026-10-18 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/048-login-pos-enhancements/spec.md`

## Summary

Five stories. Two ship with no backend change, two ship now and finish themselves when an mbe-api change lands, and one waits on its mbe-api issue.

1. **Confirm password (P1, ships now)**
   - A shared `NewPasswordFields` widget holds the new-password field, a confirmation field, and the rule checklist.
   - When the new password changes, the confirmation is validated again.
   - All three existing forms use it (change, forgot, admin create), and each controller guards submit on a match (R1).
2. **Paid sale read-only detail (P1, ships now)**
   - The POS workspace gains a `detail` mode. It is decided once, when a sale opens, by a pure predicate: paid, zero balance, and fully distributed if it is a delivery sale.
   - The predicate sits next to `resumeTargetFor` and shares one `saleIsDelivery` check with the open-sales selector.
   - A new `PosSaleDetailView` reuses the disabled line rows, the totals bar without its action, and the applied-payments panel. Payments are gated on `customerPayments` read. The view adds the ticket preview (R5–R7).
3. **Other-facility stock (P2, ships now, complete after mbe-api#242)**
   - The stock cache already holds every facility's rows. Only the pop-up hides them.
   - A pure `otherFacilityStock` helper and a read-only section in the pop-up show those rows. Before #242 they appear under "Other warehouses", found by excluding the sale facility's warehouse ids. After regeneration they are grouped by facility with no further logic change (R8).
4. **Password policy (P2, ships now, complete after mbe-api#241)**
   - A `PasswordPolicy` entity with a pure `unmet()`, and a checklist in `NewPasswordFields`.
   - The interim policy is today's server rule (6 characters). It is replaced by `GET /auth/password-policy` after regeneration.
   - Server 422s map to localized rule messages (R2, R3).
5. **Forced change (P3, blocked on mbe-api#240)**
   - Designed (user flag, redirect, a forced mode on `ChangePasswordScreen`, an interceptor hook for `403 password_change_required`) but not built until #240 ships and the client is regenerated (R4).

## Technical Context

**Language/Version**: Dart `^3.10.3`, Flutter stable (unchanged)

**Primary Dependencies**:
- Riverpod (`riverpod_annotation` / generator 4), `freezed` 4, `go_router` `^17.3.0`, `decimal`, the generated `mbe_api_client`.
- No new packages.
- Codegen re-runs only when consuming #242, #241 and #240 (R9).

**Storage**: N/A (online-only, §VII).

**Testing**:
- `flutter_test` + `mocktail`.
- Widget tests use `ProviderScope` overrides (`authRepositoryProvider`, `tokenStorageProvider`) and `pos_test_harness.dart`.
- Router tests use `_FixedAuthNotifier`, and interceptor tests use `_FakeHttpClientAdapter`.
- POS goldens that include the warehouse dialog are regenerated.

**Target Platform**: Web/desktop first (Expanded tier). Compact (390 px) is verified for the detail view and the warehouse dialog.

**Project Type**: Flutter client application, feature-first layered

**Performance Goals**:
- Opening a paid **delivery** sale adds one `listForSale` read. Counter sales add none.
- The detail view adds one payments read, and only with the privilege.
- No extra calls for other-facility stock: the rows are already cached.

**Constraints**:
- The line band's measured height is unchanged (§VI).
- Amounts and dates go through `formattersProvider` (§V guard).
- No new `SystemObject`. This is the first use of `customerPayments` read.
- No app-bar actions in the detail view (§VI).

**Scale/Scope**:

| | Files |
|---|---|
| **New** | `features/auth/domain/entities/password_policy.dart`, `features/auth/presentation/widgets/new_password_fields.dart`, `features/sales/presentation/pos_sale_detail_view.dart`, `features/sales/presentation/capture/other_facility_stock.dart` |
| **Edited, auth** | `account/account_controller.dart`, `account/change_password_screen.dart`, `account/forgot_password_screen.dart`, `admin/users_controller.dart`, `admin/user_detail_screen.dart`, `domain/repositories/auth_repository.dart`, `data/auth_repository_impl.dart` |
| **Edited, POS detail** | `pos_resume_controller.dart`, `pos_step_controller.dart`, `pos_workspace_screen.dart`, `open_sales_selector_controller.dart`, `payment/applied_payments_panel.dart`, `pos_sales_list_screen.dart` (shared `saleTicketRef`) |
| **Edited, stock** | `capture/warehouse_picker_dialog.dart`, `capture/sale_line_editing.dart` |
| **Edited, l10n** | both `.arb` files plus the regenerated `app_localizations*.dart`; about 20 keys |
| **Blocked (#240)** | `core/access/user.dart`, `session/auth_notifier.dart`, `core/network/auth_interceptor.dart`, `app/router/app_router.dart`, `change_password_screen.dart` (forced mode) |
| **Blocked (#242)** | `domain/entities/product_lookup_result.dart` (facility mapping) |

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Verdict | How |
|---|---|---|
| **I. Feature-first layering** | Pass | `PasswordPolicy` lives in `auth/domain`, reached through `AuthRepository` and a provider. The predicate and stock grouping are pure functions beside the presentation code that uses them, the same pattern as `evaluateStock` and `resumeTargetFor`. The existing data-layer import in `account_controller.dart` predates this spec and is left untouched (R10). |
| **II. Riverpod** | Pass | `passwordPolicyProvider` and `saleDestinationsProvider` are generated providers. `PosStepState` gains a field. No other DI is added. |
| **III. Contract-driven API** | Pass, with tracked dependencies | Only existing generated operations are used now. The backend changes are filed as mbe-api#240, #241 and #242, and none is patched from this repo. Each is consumed after regeneration (R9). See Complexity Tracking. |
| **IV. Deny-by-default RBAC** | Pass | The detail view shows payments only with `can(customerPayments, read)`, and the ticket only with `canOpenDocument`. The forced-change route requires a session. No new privileges. |
| **V. Material 3 / l10n / formatting** | Pass | Standard M3 widgets. Every string is in both `.arb` files, and the hard-coded Spanish error in `AppliedPaymentsPanel` and the hard-coded English controller messages on the touched forms are moved to l10n. Amounts and dates go through `formattersProvider`. |
| **VI. Desktop-first, compact-ready** | Pass | The detail view uses a two-pane Expanded layout and one column on Compact. The dialog's single scroll area is capped. Both are verified at 390 px with `expectNoHorizontalScroll`. No app-bar actions. |
| **VII. Online-only** | Pass | Nothing is persisted. The policy is read from the server, or is the interim constant. |
| **Quality gates** | Pass | **Unit tests**: `PasswordPolicy.unmet`, `ruleFromFieldError`, `opensAsReadOnlyDetail`, `saleIsDelivery`, `otherFacilityStock`, and the controllers' submit guards. **Widget tests**: `NewPasswordFields`, the three forms, the workspace detail branch, `PosSaleDetailView` (with and without the privilege), and the warehouse dialog section. **Goldens**: regenerated where the dialog appears. |

**Post-design re-check** (after Phase 1): still passing. The only Complexity Tracking entries are upstream dependencies, not violations.

## Project Structure

### Documentation (this feature)

```text
specs/048-login-pos-enhancements/
├── plan.md              # This file
├── research.md          # Phase 0 (R1–R10)
├── data-model.md        # Phase 1
├── quickstart.md        # Phase 1
├── contracts/
│   └── ui-contracts.md  # Phase 1 (C1–C4)
├── checklists/
│   └── requirements.md
└── tasks.md             # Phase 2 (/speckit-tasks)
```

### Source Code (repository root)

```text
lib/
├── app/router/app_router.dart                         # [#240] /auth/password-required + redirect (C2)
├── core/
│   ├── access/user.dart                               # [#240] + mustChangePassword
│   └── network/auth_interceptor.dart                  # [#240] onPasswordChangeRequired
├── features/auth/
│   ├── domain/
│   │   ├── entities/password_policy.dart              # NEW PasswordPolicy, PasswordRule, ruleFromFieldError
│   │   └── repositories/auth_repository.dart          # + passwordPolicy()
│   ├── data/auth_repository_impl.dart                 # interim → [#241] endpoint
│   └── presentation/
│       ├── widgets/new_password_fields.dart           # NEW (C1)
│       ├── account/account_controller.dart            # confirm + policy guards
│       ├── account/change_password_screen.dart        # C1; [#240] forced mode
│       ├── account/forgot_password_screen.dart        # C1
│       ├── admin/users_controller.dart                # confirm + passwordMismatch + rule mapping
│       ├── admin/user_detail_screen.dart              # C1 in create mode
│       └── session/auth_notifier.dart                 # [#240] reloadCurrentUser, flag wiring
├── features/sales/
│   ├── domain/entities/product_lookup_result.dart     # [#242] WarehouseStock.facilityId/Name
│   └── presentation/
│       ├── pos_resume_controller.dart                 # opensAsReadOnlyDetail, saleIsDelivery
│       ├── pos_step_controller.dart                   # PosStepState.detail
│       ├── pos_workspace_screen.dart                  # _syncStepTo decision + detail branch
│       ├── pos_sale_detail_view.dart                  # NEW (C3)
│       ├── open_sales_selector_controller.dart        # shared saleIsDelivery
│       ├── pos_sales_list_screen.dart                 # shared saleTicketRef
│       ├── payment/applied_payments_panel.dart        # showChangeAndDate, l10n error
│       └── capture/
│           ├── other_facility_stock.dart              # NEW otherFacilityStock (C4)
│           ├── warehouse_picker_dialog.dart           # other-facilities section (C4)
│           └── sale_line_editing.dart                 # pass facilityId
└── l10n/app_en.arb, app_es.arb (+ regenerated app_localizations*.dart)

test/
├── unit/features/auth/{password_policy,users_controller}_test.dart
├── unit/features/sales/{open_sale_resolution,other_facility_stock}_test.dart
├── unit/app/router/app_router_test.dart               # [#240]
├── unit/core/network/auth_interceptor_test.dart       # [#240]
├── widget/features/auth/{new_password_fields,change_password_screen,forgot_password_screen}_test.dart
└── widget/features/sales/{pos_workspace_route,pos_sale_detail_view,warehouse_picker_dialog,
    sale_line_row,pos_047_extra_large_text}_test.dart
```

**Structure Decision**: existing feature-first layout. No new feature module. The password work stays in `features/auth`, and the POS work stays in `features/sales/presentation`.

## Complexity Tracking

These are upstream dependencies, not principle violations. The table records how each requirement is met until its mbe-api change ships.

| Dependency | Requirement affected | Until it ships | After regeneration |
|---|---|---|---|
| mbe-api#242: facility on stock rows | FR-021 (group by facility) | One "Other warehouses" group, found by excluding the sale facility's warehouse ids | Real facility groups; only the entity mapping changes |
| mbe-api#241: published password policy | FR-030, FR-032 | Interim policy (6 characters, as the server does today); the 422 mapper falls back to the raw `msg` | Endpoint-backed policy; the mapper is checked against the real 422 shape |
| mbe-api#240: `must_change_password` | FR-040–FR-044 (Story 5) | Not built (R4) | Build C2 and its tests |
