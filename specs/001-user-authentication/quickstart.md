# Quickstart: Validating User Authentication & Access Control

End-to-end validation steps for the acceptance scenarios in
[spec.md](./spec.md). Run against a real mbe-api instance — this feature has
no mocked/offline mode (constitution §VII).

## Prerequisites

1. **mbe-api running locally**, per its `README.md`:
   ```bash
   cd ../mbe-api
   uv run uvicorn app.main:app --reload
   ```
   Confirms at `http://127.0.0.1:8000/openapi.json` and `/docs`.
2. **A seeded administrator account** in mbe-api's database (`disabled =
   false`, `administrator = true`). Creating this account is an mbe-api/DB
   setup step outside this feature's scope — see mbe-api's own docs/migrations
   for the current bootstrap procedure.
3. **A second, non-administrator test account** with a known, limited set of
   `Privilege` rows (e.g., only `SystemObject.Users` with `read`-only, or no
   `Users` row at all) — used to validate FR-005/FR-007/FR-015. Create via the
   admin account once Story 3 is implemented, or directly in mbe-api's DB.

## Setup (mbe-ui)

```bash
flutter pub get

# Regenerate the OpenAPI client (research.md §2) against the running mbe-api:
./tool/generate_api_client.sh http://127.0.0.1:8000/openapi.json

# Generate freezed/riverpod code:
dart run build_runner build --delete-conflicting-outputs
```

## Run

```bash
flutter run -d chrome      # or -d macos / -d windows / -d linux
```

## Validation scenarios

### Story 1 — Sign In and Work Within a Session (P1)

1. **Valid login** (Acceptance Scenario 1, SC-001): on `/auth/login`, enter
   the administrator credentials. Expect: redirected away from
   `/auth/login` within 5s, landing screen reflects full access (FR-006).
2. **Invalid login** (Acceptance Scenario 2, FR-008): enter a wrong password.
   Expect: a single generic error message (does not say "wrong password" vs.
   "unknown user"), still on `/auth/login`.
3. **Permission-gated nav** (Acceptance Scenarios 6-7, FR-005, FR-007,
   SC-002): sign in as the non-administrator test account. Expect: `/users`
   (and any nav entry to it) is hidden/disabled unless that account has a
   `Users` privilege with `read`; sign in as the administrator and expect
   `/users` to be visible and fully usable.
4. **Sign out** (Acceptance Scenario 5, FR-004): use the sign-out action.
   Expect: immediate redirect to `/auth/login`; attempting to navigate back
   does not show authenticated content.
5. **Session invalidation** (Acceptance Scenarios 3-4, FR-003, SC-003):
   - *Expiry*: not practical to wait 8 hours in manual testing — instead,
     simulate by having mbe-api return `401` (e.g., temporarily set
     `JWT_ACCESS_TOKEN_EXPIRE_MINUTES=0` in mbe-api's `.env` and restart, then
     sign in and perform any action).
   - *Revocation*: while signed in as the test account in one browser
     session, use the administrator (in another session/browser profile) to
     edit the test account (any field — bumps `session_version` server-side).
     Expect: the test account's next action redirects it to `/auth/login`
     (FR-014).

### Story 2 — Manage My Own Password (P2)

1. **Change password** (Acceptance Scenarios 1-2, FR-009, SC-004): sign in,
   go to `/auth/account/password`, submit the wrong current password —
   expect rejection with the password unchanged; then submit the correct
   current password + a new password (≥6 chars) — expect success; sign out
   and sign back in with the new password.
2. **Forgot password** (Acceptance Scenarios 3-4, FR-010): from
   `/auth/login`, follow the recovery link to `/auth/recover`. Submitting a
   request informs the user an administrator will help. As the
   administrator, trigger `POST /users/{user_id}/recover-password` from the
   Users admin screen (Story 3) to obtain a `recovery_token`; use it on
   `/auth/recover` to set a new password and confirm sign-in works with it.

### Story 3 — Administer User Accounts and Permissions (P3)

1. **List accounts** (Acceptance Scenario 1, FR-011): as administrator, open
   `/users`. Expect a list of all accounts with status and administrator
   flag.
2. **Create account** (Acceptance Scenario 2, FR-012, SC-006): use `/users/new`
   to create a test account (4-20 char user id, email, password). Expect it
   appears in the list and can sign in.
3. **Edit permissions** (Acceptance Scenario 3, FR-013, SC-005): open the new
   account at `/users/:userId`, grant `read` on one `SystemObject` via the
   permissions grid, save. Sign in as that account and confirm the
   corresponding module/action is now visible — without restarting the app.
4. **Deactivate** (Acceptance Scenario 4, FR-012, FR-014): toggle the test
   account to `disabled`. Expect: the account can no longer sign in, and if
   it was signed in, its next action redirects to `/auth/login`.
5. **Access restriction** (Acceptance Scenario 5, FR-015): sign in as a
   non-administrator without a `Users` privilege. Expect `/users` is
   unreachable (hidden from nav and redirects away if navigated to directly).

## Automated coverage

- `test/unit/features/auth/` — `AuthNotifier` state transitions
  (data-model.md "AuthState"), `AccessControlService.can()` truth table,
  repository error mapping (422/401/404/5xx → domain errors).
- `test/widget/features/auth/` — login form validation/error display, change
  password form, permissions grid rendering.
- `test/integration/auth_flow_test.dart` — Story 1 scenarios 1, 2, 4, 6, 7
  against a real mbe-api instance.
