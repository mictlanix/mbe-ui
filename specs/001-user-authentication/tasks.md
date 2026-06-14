---

description: "Task list for User Authentication & Access Control"

---

# Tasks: User Authentication & Access Control

**Input**: Design documents from `/specs/001-user-authentication/`

**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/](./contracts/), [quickstart.md](./quickstart.md)

**Tests**: Included per constitution §"Development Workflow & Quality Gates"
(unit/widget/integration tests are a quality gate, not optional, for this
project). Write each story's tests first; confirm they fail before
implementing.

**Organization**: Tasks are grouped by user story (spec.md priorities P1/P2/P3)
to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no unmet dependencies)
- **[Story]**: Maps the task to US1 (Sign In & Session), US2 (Manage My Own
  Password), or US3 (Administer Users & Permissions)
- File paths are relative to the repository root

## Path Conventions

Single Flutter project per plan.md "Project Structure": `lib/`, `test/`,
`tool/` at repository root.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Toolchain and codegen prerequisites every later task depends on.

- [ ] T001 Update `pubspec.yaml` with the dependencies listed in plan.md
  "Technical Context": `flutter_riverpod`, `riverpod_annotation`,
  `riverpod_generator`, `go_router`, `dio`, `freezed`, `freezed_annotation`,
  `json_annotation`, `json_serializable`, `build_runner`,
  `flutter_secure_storage`, `shared_preferences`, `flutter_localizations`,
  `intl`, and `mocktail` (dev dependency); run `flutter pub get`.
- [ ] T002 [P] Create `tool/generate_api_client.sh`, wrapping `npx
  @openapitools/openapi-generator-cli generate` with the `dart-dio` generator
  (research.md §2), taking an OpenAPI spec URL/path as `$1` (default
  `http://127.0.0.1:8000/openapi.json`) and writing output to
  `lib/generated/openapi/`.
- [ ] T003 Run `tool/generate_api_client.sh http://127.0.0.1:8000/openapi.json`
  to generate the `dart-dio` client + models for the `auth` and `users`
  paths (incl. `GET /api/v1/auth/me`) into `lib/generated/openapi/`, and
  commit the generated output (research.md §2).
- [ ] T004 [P] Verify/extend `analysis_options.yaml` at the repo root per
  constitution "Development Workflow & Quality Gates" (lint rules for
  `freezed`/`riverpod_generator` generated files, etc.).

**Checkpoint**: `flutter pub get` succeeds and `lib/generated/openapi/`
contains a `dart-dio` client covering `auth`/`users`.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Shared kernel (`core/`), domain entities, session state, access
control, network/storage, shared widgets, and app shell that ALL three user
stories depend on. No user-story screen can be meaningfully implemented
before this phase.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [ ] T005 [P] Create `AccessRight` flags enum (`none=0, create=1, read=2,
  update=4, delete=8`) in `lib/core/access/access_right.dart`
  (data-model.md "AccessRight").
- [ ] T006 [P] Create `SystemObject` enum with explicit `int` values `0`-`113`
  (114 entries, transcribed from `mbe/docs/constants.md`) in
  `lib/core/access/system_object.dart` (research.md §6, data-model.md
  "SystemObject"); include `Users = 92`.
- [ ] T007 [P] Create `UserSettings` freezed entity (`storeId`, `pointSaleId`,
  `cashDrawerId`) mapping `UserSettingsResponse`/`UserSettingsUpdate` in
  `lib/core/access/user_settings.dart` (data-model.md "UserSettings").
- [ ] T008 [P] Create `Privilege` freezed entity (`systemObject`, `rawValue`,
  `allowCreate/Read/Update/Delete`, `0..15` validation) mapping
  `PrivilegeResponse`/`PrivilegeUpdate` in `lib/core/access/privilege.dart`
  (data-model.md "Privilege") — shared kernel per constitution §I, consumed
  by `AccessControlService` (T017).
- [ ] T009 [P] Create the `AppError` domain error hierarchy
  (`ValidationError`, `AuthError`, `NotFoundError`, `ServerError`,
  `NetworkError`) in `lib/core/errors/app_error.dart` (data-model.md "Domain
  error types"; contracts/mbe-api-auth-users.md "Error shape").
- [ ] T010 [P] Create `TokenStorage` (`flutter_secure_storage` wrapper:
  `read`/`write`/`clear` for the access token) in
  `lib/core/storage/token_storage.dart` (research.md §5).
- [ ] T011 [P] Create `User`/`UserSummary` freezed entities mapping
  `UserResponse`/`UserListItem` in `lib/core/access/user.dart` (data-model.md
  "User" / "UserSummary") — shared kernel per constitution §I, consumed by
  `AccessControlService` (T017) and `AuthState` (T012); depends on T007, T008
  for field types.
- [ ] T012 [P] Create the `AuthState` sealed/freezed union
  (`unauthenticated(reason)`, `authenticating`, `authenticated(token, user)`)
  and `SignOutReason` in `lib/features/auth/domain/entities/auth_session.dart`
  (data-model.md "AuthSession / AuthState"); depends on T011.
- [ ] T013 Create `dio_client.dart` (base `Dio` instance/provider, pointed at
  mbe-api base URL) and `auth_interceptor.dart` (attaches `Authorization:
  Bearer <token>` from `TokenStorage`, maps non-2xx responses to `AppError`
  subtypes) in `lib/core/network/` (depends on T009, T010).
- [ ] T014 [P] Define the `AuthRepository` interface (`login`, `me`) in
  `lib/features/auth/domain/repositories/auth_repository.dart`
  (contracts/mbe-api-auth-users.md "POST /api/v1/auth/login",
  "GET /api/v1/auth/me").
- [ ] T015 Implement `AuthRepositoryImpl.login`/`.me` in
  `lib/features/auth/data/auth_repository_impl.dart` using the generated
  `lib/generated/openapi/` client, mapping `TokenResponse`/`UserResponse` to
  `User`/`AuthState` and errors via `AppError` (depends on T003, T012, T013,
  T014).
- [ ] T016 Implement `AuthNotifier` (`AsyncNotifier<AuthState>`) in
  `lib/features/auth/presentation/session/auth_notifier.dart`: `signIn`,
  `signOut`, and app-start restore (read `TokenStorage` → `AuthRepository.me`
  → `authenticated` or `unauthenticated`) (depends on T012, T015, T010).
- [ ] T017 Create `AccessControlService` and `accessControlProvider` in
  `lib/core/access/access_control.dart`: `can(SystemObject, AccessRight)`,
  `isAuthenticated`, `isAdministrator`, derived from `authNotifierProvider`
  (contracts/access_control.md; depends on T005, T006, T016).
- [ ] T018 [P] Create centralized `LayoutBreakpoints` (compact/expanded
  thresholds) in `lib/core/layout/breakpoints.dart` (constitution §VI).
- [ ] T019 [P] Create shared `ErrorBanner` widget (renders `AppError` /
  `ValidationError` field messages) in `lib/core/widgets/error_banner.dart`.
- [ ] T020 [P] Create a shared `DataTableView` widget (sortable columns,
  optional row actions, used by any feature's list screens) in
  `lib/core/widgets/data_table_view.dart` (constitution §VI — shared data
  tables MUST live in `core/widgets/`, not be reimplemented per module).
- [ ] T021 [P] Create `AppTheme` (`ColorScheme.fromSeed`, light/dark theme
  data, `ThemeMode` provider persisted via `shared_preferences`) in
  `lib/app/theme/app_theme.dart` (constitution §V).
- [ ] T022 Create the `GoRouter` instance and `redirect` guard skeleton
  (unauthenticated → `/auth/login`, authenticated-on-`/auth/login` →
  `/`, `refreshListenable` wired to `authNotifierProvider`) in
  `lib/app/router/app_router.dart` (contracts/routes.md "Redirect guard
  summary"; depends on T016, T017).
- [ ] T023 Create `lib/app/app.dart` (`MaterialApp.router` wiring
  `app_router.dart`, `AppTheme`, `flutter_localizations`/`intl` for `es-MX`)
  and update `lib/main.dart` to bootstrap `ProviderScope` + run the app
  (depends on T021, T022).

**Checkpoint**: App builds and launches to a redirect-only shell (no screens
yet); `AuthNotifier`/`AccessControlService`/router guard are wired and ready
for screens to register against.

---

## Phase 3: User Story 1 - Sign In and Work Within a Session (Priority: P1) 🎯 MVP

**Goal**: A user signs in with username/password, lands on a screen
reflecting only their permitted modules, stays signed in for the session,
and is returned to `/auth/login` on sign-out, expiry, or revocation
(FR-001..FR-008, FR-014).

**Independent Test**: quickstart.md "Story 1" — valid/invalid login,
permission-gated nav for admin vs. non-admin, sign-out, session
expiry/revocation via `401`.

### Tests for User Story 1

- [ ] T024 [P] [US1] `AuthNotifier` state-transition tests (sign in success/
  failure, sign out, 401 → `unauthenticated(sessionInvalid)`, app-start
  restore) in `test/unit/features/auth/auth_notifier_test.dart` (mocktail
  `AuthRepository`/`TokenStorage` fakes).
- [ ] T025 [P] [US1] `AccessControlService.can()` truth table tests
  (administrator override, missing privilege, partial bitmask, unauthenticated
  → `false`) in `test/unit/features/auth/access_control_test.dart`.
- [ ] T026 [P] [US1] `AuthRepositoryImpl.login`/`.me` tests covering `200`,
  `401`, `422`, `5xx`, network-error → `AppError` mapping in
  `test/unit/features/auth/auth_repository_impl_test.dart`.
- [ ] T027 [P] [US1] Widget test for `LoginScreen` (empty-field validation,
  generic error display on `401`/`422`, no field-specific messaging per
  FR-008) in `test/widget/features/auth/login_screen_test.dart`.
- [ ] T028 [P] [US1] Integration test: sign in (valid/invalid), permission-
  gated nav visibility for admin vs. non-admin, sign out, in
  `test/integration/auth_flow_test.dart` (quickstart Story 1 scenarios 1, 2,
  4, 6, 7 — run against local mbe-api). Scenario 3 (session expiry) requires
  a separate mbe-api restart with `JWT_ACCESS_TOKEN_EXPIRE_MINUTES=0` and is
  validated manually per quickstart.md, not in this automated suite.

### Implementation for User Story 1

- [ ] T029 [P] [US1] Create `LoginController` (plain `Notifier`:
  `username`, `password`, `submitting`, `error`) in
  `lib/features/auth/presentation/login/login_controller.dart`
  (data-model.md "Login form state").
- [ ] T030 [US1] Create `LoginScreen` (form, generic error banner via
  `ErrorBanner`, calls `AuthNotifier.signIn`) in
  `lib/features/auth/presentation/login/login_screen.dart` (depends on
  T029).
- [ ] T031 [US1] Create a minimal home screen with a navigation list gated by
  `accessControlProvider.can(object, AccessRight.read)` per visible
  `SystemObject` (FR-005/FR-006/FR-007), plus a sign-out action (FR-004), in
  `lib/features/home/presentation/home_screen.dart` (depends on T017).
- [ ] T032 [US1] Register the `/auth/login` and `/` routes in
  `lib/app/router/app_router.dart`, completing the redirect guard's
  authenticated/unauthenticated branches from contracts/routes.md (depends
  on T022, T030, T031).
- [ ] T033 [US1] Wire app-start session restore: call `AuthNotifier`'s
  restore path from `lib/app/app.dart`/`main.dart` so a persisted token in
  `TokenStorage` resolves to `authenticated` (via `/auth/me`) or
  `unauthenticated` before the first route resolves (depends on T016, T023).
- [ ] T034 [US1] Verify/wire the `401` path end-to-end: `auth_interceptor.dart`
  signals `AuthNotifier` → `unauthenticated(sessionInvalid)` →
  `refreshListenable` triggers `redirect` to `/auth/login` (FR-003, SC-003;
  depends on T013, T016, T022).

**Checkpoint**: User Story 1 is fully functional and independently testable —
sign in, permission-gated landing screen, sign out, and session
invalidation all work end-to-end.

---

## Phase 4: User Story 2 - Manage My Own Password (Priority: P2)

**Goal**: A signed-in user changes their own password (current + new), and a
user who forgot their password can be guided through admin-mediated recovery
(FR-009, FR-010).

**Independent Test**: quickstart.md "Story 2" — change password with wrong
then correct current password, sign out/in with the new password; recovery
request → admin-issued token → `/auth/recover` confirm.

### Tests for User Story 2

- [ ] T035 [P] [US2] `AuthRepositoryImpl.changePassword`/`.recoverConfirm`
  tests covering `204`, `422` (wrong current password / short new password /
  invalid recovery token) in
  `test/unit/features/auth/auth_repository_impl_test.dart` (extends T026's
  file).
- [ ] T036 [P] [US2] Widget test for `ChangePasswordScreen` (validation,
  rejection on wrong current password, success path) in
  `test/widget/features/auth/change_password_screen_test.dart`.
- [ ] T037 [P] [US2] Widget test for `ForgotPasswordScreen` (recovery request
  informational message; recovery-token confirm form validation/success) in
  `test/widget/features/auth/forgot_password_screen_test.dart`.

### Implementation for User Story 2

- [ ] T038 [US2] Add `changePassword(oldPassword, newPassword)` and
  `recoverConfirm(recoveryToken, newPassword)` to `AuthRepository`
  (`lib/features/auth/domain/repositories/auth_repository.dart`) and
  `AuthRepositoryImpl` (`lib/features/auth/data/auth_repository_impl.dart`)
  per contracts/mbe-api-auth-users.md `POST /api/v1/auth/change-password` and
  `POST /api/v1/auth/recover` (depends on T015).
- [ ] T039 [P] [US2] Create `AccountController` (plain `Notifier` for
  change-password and recovery-confirm form state, `newPassword minLength
  6`) in `lib/features/auth/presentation/account/account_controller.dart`
  (data-model.md "Password-change / recovery form state"; depends on T038).
- [ ] T040 [US2] Create `ChangePasswordScreen` in
  `lib/features/auth/presentation/account/change_password_screen.dart`
  (depends on T039).
- [ ] T041 [US2] Create `ForgotPasswordScreen` (request-help message +
  recovery-token confirm form) in
  `lib/features/auth/presentation/account/forgot_password_screen.dart`
  (depends on T039).
- [ ] T042 [US2] Register `/auth/account/password` (any authenticated user)
  and `/auth/recover` (unauthenticated + recovery-token holders) routes in
  `lib/app/router/app_router.dart` per contracts/routes.md (depends on T040,
  T041).

**Checkpoint**: User Stories 1 AND 2 both work independently — password
self-service is fully usable on top of the Story 1 session/auth foundation.

---

## Phase 5: User Story 3 - Administer User Accounts and Permissions (Priority: P3)

**Goal**: Administrators list, create, and edit user accounts (incl.
activate/deactivate) and manage each user's per-`SystemObject` CRUD
permissions via a permissions grid, with changes taking effect immediately
(FR-011..FR-015).

**Independent Test**: quickstart.md "Story 3" — list accounts, create a test
account, edit its permissions and confirm they take effect without restart,
deactivate it, and confirm `/users` is unreachable for a non-administrator.

### Tests for User Story 3

- [ ] T043 [P] [US3] `UserRepositoryImpl` tests for `list`/`get`/`create`/
  `update`/`recoverPassword` covering `200`/`201`/`204`/`404`/`422` →
  `AppError` mapping in
  `test/unit/features/auth/user_repository_impl_test.dart`. (`DELETE
  /api/v1/users/{user_id}` is out of scope for this feature per
  contracts/mbe-api-auth-users.md — not included here.)
- [ ] T044 [P] [US3] `UsersController` tests: form state → `UserCreate`/
  `UserUpdate` mapping (incl. `privileges: PrivilegeUpdate[]` from the grid)
  in `test/unit/features/auth/users_controller_test.dart`.
- [ ] T045 [P] [US3] Widget test for `PrivilegesGrid` (renders one row per
  `SystemObject`, four C/R/U/D checkboxes, edits update `0..15` bitmask) in
  `test/widget/features/auth/privileges_grid_test.dart`.
- [ ] T046 [P] [US3] Widget test for `UsersListScreen` (renders accounts with
  status/administrator flag; route hidden/redirected for a user without
  `Users` `read`) in `test/widget/features/auth/users_list_screen_test.dart`.

### Implementation for User Story 3

- [ ] T047 [P] [US3] Define the `UserRepository` interface (`list`, `get`,
  `create`, `update`, `recoverPassword`) in
  `lib/features/auth/domain/repositories/user_repository.dart` per
  contracts/mbe-api-auth-users.md "Users" section. (`delete` is intentionally
  omitted — `DELETE /api/v1/users/{user_id}` is out of scope for this
  feature; deactivation via `update(disabled: true)` is the FR-012/FR-014
  path.)
- [ ] T048 [US3] Implement `UserRepositoryImpl` in
  `lib/features/auth/data/user_repository_impl.dart` using the generated
  `lib/generated/openapi/` client, mapping `UserListResponse`/`UserResponse`
  to `UserSummary`/`User` and `UserCreate`/`UserUpdate`/`PrivilegeUpdate` from
  domain entities (depends on T003, T011, T008, T047).
- [ ] T049 [US3] Create `UsersController` (admin user-form state per
  data-model.md "Admin user-form state": list/selection state, create/edit
  form fields, privileges-grid state, save/recover-password actions) in
  `lib/features/auth/presentation/admin/users_controller.dart`. On a
  successful `update` for the signed-in administrator's own `user_id`,
  refresh `AuthNotifier`'s in-memory `AuthState.authenticated.user` per
  contracts/mbe-api-auth-users.md "PUT /api/v1/users/{user_id}" self-refresh
  note (FR-014) (depends on T048, T016).
- [ ] T050 [US3] Create `PrivilegesGrid` widget (one row per `SystemObject`
  from T006, four C/R/U/D checkboxes bound to `Privilege.rawValue`) in
  `lib/features/auth/presentation/admin/privileges_grid.dart` (depends on
  T005, T006, T008).
- [ ] T051 [US3] Create `UsersListScreen` (FR-011: list with status +
  administrator flag using the shared `DataTableView` from T020, "New"
  action gated by `can(Users, create)`) in
  `lib/features/auth/presentation/admin/users_list_screen.dart` (depends on
  T020, T049).
- [ ] T052 [US3] Create `UserDetailScreen` (create + edit modes: account
  fields, activate/deactivate toggle, embedded `PrivilegesGrid`, "Recover
  password" action surfacing `recovery_token`/`expires_at`) in
  `lib/features/auth/presentation/admin/user_detail_screen.dart` (depends on
  T049, T050).
- [ ] T053 [US3] Register `/users`, `/users/new`, and `/users/:userId` routes
  in `lib/app/router/app_router.dart`, gated by `can(SystemObject.Users,
  AccessRight.read|create|update)` per contracts/routes.md (depends on T051,
  T052, T017).

**Checkpoint**: All three user stories are independently functional —
administrators can fully manage accounts/permissions, and permission changes
are reflected for affected users on their next action (FR-014).

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final consistency pass across all three stories.

- [ ] T054 [P] Run `dart run build_runner build --delete-conflicting-outputs`
  and resolve any `freezed`/`json_serializable`/`riverpod_generator` codegen
  errors across `lib/`.
- [ ] T055 [P] Add `es-MX` localized strings (`.arb` files under `lib/l10n/`,
  e.g. `app_es.arb`) for all auth/admin screens introduced in Phases 3-5
  (constitution §"Technology Stack" / §V — `flutter_localizations` + `intl`).
- [ ] T056 Run `flutter analyze` across `lib/core/`, `lib/app/`,
  `lib/features/auth/`, `lib/features/home/` and resolve all warnings/errors.
- [ ] T057 Execute [quickstart.md](./quickstart.md) end-to-end against a local
  mbe-api instance (Stories 1-3 validation scenarios) and fix any
  discrepancies found.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately.
- **Foundational (Phase 2)**: Depends on Phase 1 (T003's generated client is
  consumed by T015). BLOCKS all user stories.
- **User Story 1 (Phase 3)**: Depends on Phase 2 completion. No dependency on
  US2/US3.
- **User Story 2 (Phase 4)**: Depends on Phase 2 completion (`AuthRepository`/
  `AuthNotifier` from T015/T016). Independent of US1/US3 at the code level,
  but T042 adds routes alongside T032's router edits — coordinate to avoid
  merge conflicts in `app_router.dart`.
- **User Story 3 (Phase 5)**: Depends on Phase 2 completion (`User`/
  `Privilege`/`SystemObject`/`AccessRight` from T006/T008/T011, the shared
  `DataTableView` from T020, and `accessControlProvider` from T017).
  Independent of US1/US2 at the code level; T053 also edits
  `app_router.dart`.
- **Polish (Phase 6)**: Depends on whichever of Phases 3-5 are complete.

### Within Each User Story

- Tests (T024-T028, T035-T037, T043-T046) MUST be written and FAIL before
  their corresponding implementation tasks.
- Entities/repositories before controllers; controllers before screens;
  screens before router registration.

### Parallel Opportunities

- Phase 1: T002 and T004 in parallel; T001 first, T003 after T002.
- Phase 2: T005-T012 (entities/enums/errors/storage) can all run in parallel;
  T013-T023 follow the dependency chain noted in each task.
- Once Phase 2 is complete, Phases 3, 4, and 5 can proceed in parallel by
  different contributors (see router-edit coordination note above).
- All `[P]` test tasks within a story can run in parallel.

---

## Parallel Example: User Story 1

```bash
# Tests (after Phase 2 checkpoint):
Task: "AuthNotifier state-transition tests in test/unit/features/auth/auth_notifier_test.dart"
Task: "AccessControlService.can() truth table tests in test/unit/features/auth/access_control_test.dart"
Task: "AuthRepositoryImpl login/me tests in test/unit/features/auth/auth_repository_impl_test.dart"
Task: "LoginScreen widget test in test/widget/features/auth/login_screen_test.dart"
Task: "auth_flow_test.dart integration test"

# Implementation:
Task: "LoginController in lib/features/auth/presentation/login/login_controller.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup.
2. Complete Phase 2: Foundational (CRITICAL — blocks all stories).
3. Complete Phase 3: User Story 1.
4. **STOP and VALIDATE**: run quickstart.md Story 1 against local mbe-api.
5. Demo: sign in, permission-gated landing screen, sign out, session
   invalidation.

### Incremental Delivery

1. Setup + Foundational → app shell with working session/RBAC plumbing, no
   screens.
2. Add User Story 1 → validate independently → MVP demo.
3. Add User Story 2 → validate independently → demo.
4. Add User Story 3 → validate independently → demo.
5. Phase 6 polish across all three.

---

## Notes

- `[P]` tasks touch different files with no unmet dependencies.
- `[Story]` labels (US1/US2/US3) map to spec.md priorities P1/P2/P3.
- `app_router.dart` is edited by T022 (Foundational) and again by T032
  (US1), T042 (US2), T053 (US3) — these three are NOT parallel with each
  other; sequence or coordinate them even though they belong to different
  stories.
- `auth_repository_impl.dart` / `auth_repository.dart` are edited by T015
  (Foundational, `login`/`me`) and T038 (US2, `changePassword`/
  `recoverConfirm`) — sequence these two.
- Commit after each task or logical group; stop at any checkpoint to validate
  a story independently.
