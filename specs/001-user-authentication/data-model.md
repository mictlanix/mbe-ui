# Phase 1 Data Model: User Authentication & Access Control

Domain entities live in `lib/core/access/` (shared kernel: `AccessRight`,
`SystemObject`, `Privilege`, `UserSettings`, `User`/`UserSummary`,
`AccessControlService` — consumed by every feature) and
`lib/features/auth/domain/entities/` (feature-specific: `AuthState`/
`AuthSession`, this feature's session-lifecycle wrapper around `User`), as
immutable `freezed` classes mapped from the generated OpenAPI DTOs in
`lib/generated/openapi/` (see [contracts/mbe-api-auth-users.md](contracts/mbe-api-auth-users.md)).
No entity here is persisted locally (constitution §VII) beyond the access
token (`AuthSession.token`) and the user's theme preference, which is outside
this feature's scope.

## AccessRight (`lib/core/access/access_right.dart`)

Flags bitmask, mirrors mbe-api/legacy `AccessRight` (DESIGN.md §3.7).

| Name | Value |
|---|---|
| `none` | `0` |
| `create` | `1` |
| `read` | `2` |
| `update` | `4` |
| `delete` | `8` |

Combine with bitwise OR; `create | read | update | delete == 15` = full
access. Maps 1:1 to `PrivilegeResponse.allow_*` booleans returned by mbe-api,
and to the raw `privileges` integer (`0`-`15`) sent in `PrivilegeUpdate`.

## SystemObject (`lib/core/access/system_object.dart`)

`enum SystemObject` with explicit `int` values `0`–`113` (114 entries, 7
historically disabled — see research.md §6), transcribed from
`mbe/docs/constants.md` §SystemObjects. Each user has zero or one
`Privilege` per `SystemObject`.

Entries directly exercised by this feature:

| Value | Name | Used for |
|---|---|---|
| `92` | `Users` | Gates the admin Users list/detail/permissions-grid routes and actions (FR-015). |

All other entries are populated for use by future features (sales,
inventory, invoicing, accounting, reports, etc.) per research.md §6.

## Privilege (`lib/core/access/privilege.dart`)

Maps from `PrivilegeResponse` / `PrivilegeUpdate`.

| Field | Type | Notes |
|---|---|---|
| `systemObject` | `SystemObject` | mapped from `system_object` int |
| `rawValue` | `int` | `0`–`15` bitmask, mapped from `privileges` |
| `allowCreate` | `bool` | from `allow_create` (response) or derived from `rawValue & 1` (when building an update) |
| `allowRead` | `bool` | from `allow_read` / `rawValue & 2` |
| `allowUpdate` | `bool` | from `allow_update` / `rawValue & 4` |
| `allowDelete` | `bool` | from `allow_delete` / `rawValue & 8` |

**Validation**: `rawValue` MUST be in `0..15` (matches `PrivilegeUpdate.privileges`
`minimum: 0, maximum: 15`).

## UserSettings (`lib/core/access/user_settings.dart`)

Maps `UserSettingsResponse` / `UserSettingsUpdate`.

| Field | Type | Notes |
|---|---|---|
| `storeId` | `int?` | default store |
| `pointSaleId` | `int?` | default POS |
| `cashDrawerId` | `int?` | default cash drawer |

Read-only display for this feature (FR-011); editing is part of the admin
user-edit form (FR-012) but the values themselves are master-data references
not yet modeled by other features — treated as opaque IDs here.

## User (`lib/core/access/user.dart`)

Maps `UserResponse` (full) and `UserListItem` (summary, for the admin list —
modeled as a separate `UserSummary` to avoid optional/partial fields).

**User** (from `UserResponse`):

| Field | Type | Notes |
|---|---|---|
| `userId` | `String` | mbe-api's `user_id` — the login username, 4-20 chars (FR-001, `UserCreate.user_id`) |
| `email` | `String` | |
| `employeeId` | `int?` | optional link to an employee record (out of scope) |
| `administrator` | `bool` | drives FR-006 |
| `disabled` | `bool` | inverse of "active" in FR-011/FR-012 |
| `sessionVersion` | `int` | opaque to the UI; used only to detect that mbe-api has invalidated the session (FR-003) |
| `settings` | `UserSettings?` | |
| `privileges` | `List<Privilege>` | drives FR-005/FR-007/FR-013 |

**UserSummary** (from `UserListItem`, for FR-011's account list):

| Field | Type |
|---|---|
| `userId` | `String` |
| `email` | `String` |
| `employeeId` | `int?` |
| `administrator` | `bool` |
| `disabled` | `bool` |

## AuthSession / AuthState (`lib/features/auth/domain/entities/auth_session.dart`)

Sealed/`freezed` union representing the client-side session lifecycle
(FR-002, FR-003, FR-004).

| Variant | Fields | Meaning |
|---|---|---|
| `unauthenticated` | `reason: SignOutReason?` | No valid session. `reason` distinguishes "never signed in" from "expired" / "revoked" / "signed out" for UI messaging (edge cases in spec.md). |
| `authenticating` | — | Login request in flight (FR-001 acceptance scenario 1). |
| `authenticated` | `token: String, user: User` | Valid session; `user.privileges` feeds `AccessControlService`. |

**State transitions**:

```text
unauthenticated --(submit credentials)--> authenticating
authenticating --(200 + user fetched)--> authenticated
authenticating --(401/422)--> unauthenticated(reason: invalidCredentials)
authenticated --(sign out)--> unauthenticated(reason: signedOut)
authenticated --(any request returns 401)--> unauthenticated(reason: sessionInvalid)
```

`token` is never persisted in this entity beyond the in-memory provider; the
secure-storage copy (`TokenStorage`, `core/storage/token_storage.dart`) is
read once at app start to attempt to restore `authenticated` without
re-prompting, and is cleared on every transition back to `unauthenticated`.

## Login form state (`lib/features/auth/presentation/login/login_controller.dart`)

Local UI state, not persisted (constitution §II — plain `Notifier`).

| Field | Type | Validation |
|---|---|---|
| `username` | `String` | non-empty |
| `password` | `String` | non-empty |
| `submitting` | `bool` | |
| `error` | `String?` | generic message only (FR-008) |

## Password-change / recovery form state

`ChangePasswordRequest` / `ConfirmRecoveryRequest` (FR-009, FR-010):

| Field | Type | Validation |
|---|---|---|
| `oldPassword` / `recoveryToken` | `String` | non-empty |
| `newPassword` | `String` | `minLength: 6` (matches mbe-api `ChangePasswordRequest`/`ConfirmRecoveryRequest`) |

## Admin user-form state (`lib/features/auth/presentation/admin/users_controller.dart`)

Maps to `UserCreate` (create) / `UserUpdate` (edit), FR-012/FR-013:

| Field | Type | Validation |
|---|---|---|
| `userId` | `String` | create only; `4-20` chars (`UserCreate.user_id`) |
| `password` | `String?` | required on create (`minLength: 1` per schema; client enforces `>= 6` to match the password-change rule, documented as a UI-side stricter default — see Assumptions) |
| `email` | `String` | required |
| `employeeId` | `int?` | optional |
| `administrator` | `bool` | |
| `disabled` | `bool` | |
| `privileges` | `List<Privilege>` | rendered as the permissions grid (one row per `SystemObject`, four checkboxes for C/R/U/D) |
| `settings` | `UserSettings?` | read/edit store/POS/cash-drawer IDs as plain integer fields (no master-data picker yet — out of scope) |

## Domain error types (`lib/core/errors/app_error.dart`)

Per constitution §III, all repository methods return/throw one of:

| Type | mbe-api source |
|---|---|
| `ValidationError` | `422` (`HTTPValidationError` / `ValidationError` schema) — field-level messages |
| `AuthError` | `401` from any endpoint, or `400` from `/auth/login` |
| `NotFoundError` | `404` (e.g., unknown `user_id`) |
| `ServerError` | `5xx` |
| `NetworkError` | connection/timeout failures before a response is received |
