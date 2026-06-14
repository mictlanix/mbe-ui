# Contract: mbe-api `auth` / `users` endpoints consumed by this feature

Source of truth: mbe-api's `GET /openapi.json` (confirmed live at
`http://127.0.0.1:8000/openapi.json`, `mbe-api v0.1.0`). This document records
the subset this feature depends on at design time; `lib/generated/openapi/`
is regenerated from the live spec (research.md §2) and is the actual
compile-time contract — if the two disagree, the generated client wins and
this file should be updated.

## Authentication

### `POST /api/v1/auth/login`

- Request: `application/x-www-form-urlencoded`,
  `Body_login_api_v1_auth_login_post { username, password, grant_type?: "password", scope?, client_id?, client_secret? }`.
  mbe-ui sends only `username`/`password` (OAuth2 "password" grant shape, per
  DESIGN.md §3.2).
- Response `200`: `TokenResponse { access_token: string, token_type: "bearer" }`.
- Response `422`: `HTTPValidationError`.
- mbe-ui behavior: on `200`, call `GET /api/v1/auth/me` to obtain
  `UserResponse` → `AuthState.authenticated`. On `422`/`401`, surface FR-008's
  generic error and stay `unauthenticated`.

### `GET /api/v1/auth/me`

- Resolves `mictlanix/mbe-api#1` — now live (`mbe-api v0.1.0` openapi.json,
  confirmed `http://127.0.0.1:8000/openapi.json`).
- Request: no body; `Authorization: Bearer <access_token>` (gated by
  `get_current_user` only — works for non-administrators, unlike
  `/users/{user_id}`).
- Response `200`: `UserResponse { user_id, email, employee_id?,
  administrator, disabled, session_version, settings?, privileges:
  PrivilegeResponse[] }`.
- Response `401`: invalid/expired token ⇒
  `AuthState.unauthenticated(reason: sessionInvalid)`.
- mbe-ui behavior: the session-bootstrap call after login (see above) and on
  app start when restoring a persisted token (`TokenStorage`). Supersedes the
  previously-assumed "decode JWT `sub` → `GET /users/{user_id}`" pattern,
  which only worked for administrators.

### `POST /api/v1/auth/change-password`

- Request: `ChangePasswordRequest { old_password: string, new_password: string (minLength 6) }`.
- Response `204`: success, no body.
- Response `422`: `HTTPValidationError` (e.g., wrong `old_password`, or
  `new_password` too short) → FR-009.

### `POST /api/v1/auth/recover`

- Request: `ConfirmRecoveryRequest { recovery_token: string, new_password: string (minLength 6) }`.
- Response `204`: success — user can now sign in with `new_password`.
- Response `422`: invalid/expired `recovery_token` → FR-010.

## Users

### `GET /api/v1/users`

- Response `200`: `UserListResponse { items: UserListItem[], total: int }`.
- `UserListItem { user_id, email, employee_id?, administrator, disabled }`.
- mbe-ui behavior: backs the admin Users list (FR-011). Access gated by
  `can(SystemObject.Users, AccessRight.read)`.

### `POST /api/v1/users`

- Request: `UserCreate { user_id (4-20 chars), password (minLength 1), email, employee_id?, administrator? = false, disabled? = false }`.
- Response `201`: `UserResponse`.
- Response `422`: `HTTPValidationError` (e.g., duplicate `user_id`).
- mbe-ui behavior: admin "create user" form (FR-012), gated by
  `can(SystemObject.Users, AccessRight.create)`.

### `GET /api/v1/users/{user_id}`

- Response `200`: `UserResponse { user_id, email, employee_id?, administrator, disabled, session_version, settings?, privileges: PrivilegeResponse[] }`.
- mbe-ui behavior: called by the admin Users detail screen for any user,
  gated by `can(SystemObject.Users, AccessRight.read)`. Session bootstrap
  uses `GET /api/v1/auth/me` instead (see Authentication section above).

### `PUT /api/v1/users/{user_id}`

- Request: `UserUpdate` — all fields optional: `email?, employee_id?, administrator?, disabled?, privileges?: PrivilegeUpdate[], settings?: UserSettingsUpdate`.
- `PrivilegeUpdate { system_object: int, privileges: int (0-15) }`.
- Response `200`: `UserResponse`.
- mbe-ui behavior: admin edit form, including the permissions grid
  (FR-013) and activate/deactivate (FR-012), gated by
  `can(SystemObject.Users, AccessRight.update)`. mbe-ui MUST treat a `200`
  response for the *current* user's own account as a signal to refresh the
  in-memory `User`/`privileges` (in case an admin edited their own session in
  another tab — best-effort; the authoritative invalidation is the next 401
  per `session_version`, FR-014).

### `DELETE /api/v1/users/{user_id}`

- Response `204`: success.
- mbe-ui behavior: not directly required by spec.md (which describes
  "deactivate" via `disabled`, FR-012); expose via the admin screen only if a
  hard-delete action is added later. Not wired in this feature's initial
  scope — `disabled: true` via `PUT` is the deactivation path for FR-012/FR-014.

### `POST /api/v1/users/{user_id}/recover-password`

- Response `200`: `RecoverPasswordAdminResponse { recovery_token: string, expires_at: string }`.
- mbe-ui behavior: admin-triggered recovery (FR-010). The admin screen
  displays `recovery_token`/`expires_at` for the admin to relay to the user
  (DESIGN.md §3.2 — no automated delivery). Gated by
  `can(SystemObject.Users, AccessRight.update)`.

## Error shape

All `422` responses use `HTTPValidationError { detail: ValidationError[] }`
where `ValidationError { loc, msg, type }` — mapped to `ValidationError`
(domain error type, data-model.md) preserving `loc`/`msg` for field-level
display.

## Out of scope for this feature

- `/auth/refresh` does not exist and the generated client MUST NOT assume
  one. `401` ⇒ `AuthState.unauthenticated(reason: sessionInvalid)`.
