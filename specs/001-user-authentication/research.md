# Phase 0 Research: User Authentication & Access Control

All items below were either fixed by the constitution (no decision needed
here, just confirmation) or required a small amount of investigation. No
`NEEDS CLARIFICATION` markers remain in the Technical Context.

## 1. mbe-api `auth`/`users` contract (confirmed against running dev server)

**Decision**: Build against the OpenAPI spec actually served by mbe-api's
local dev instance (`http://127.0.0.1:8000/openapi.json`, `mbe-api v0.1.0`),
which exposes exactly the paths DESIGN.md §3.2/§3.3 describes:

- `POST /api/v1/auth/login` — `application/x-www-form-urlencoded`
  (`username`, `password`, OAuth2 `password` grant) → `TokenResponse
  {access_token, token_type}`.
- `POST /api/v1/auth/change-password` — `{old_password, new_password
  (min 6)}` → `204`.
- `POST /api/v1/auth/recover` — `{recovery_token, new_password (min 6)}` →
  `204`.
- `GET /api/v1/users` → `UserListResponse {items: UserListItem[], total}`.
- `POST /api/v1/users` — `UserCreate {user_id (4-20 chars), password, email,
  employee_id?, administrator?, disabled?}` → `201 UserResponse`.
- `GET /api/v1/users/{user_id}` → `UserResponse` (incl. `settings`,
  `privileges[]`).
- `PUT /api/v1/users/{user_id}` — `UserUpdate` (all fields optional,
  including `privileges: PrivilegeUpdate[]` and `settings`) → `UserResponse`.
- `DELETE /api/v1/users/{user_id}` → `204`.
- `POST /api/v1/users/{user_id}/recover-password` →
  `RecoverPasswordAdminResponse {recovery_token, expires_at}`.
- `GET /api/v1/auth/me` — **does not exist yet**, tracked as
  `mictlanix/mbe-api#1`. Required for session bootstrap (see
  [contracts/mbe-api-auth-users.md](contracts/mbe-api-auth-users.md)): every
  `/users/*` endpoint requires `require_admin`, so a non-admin user gets
  `403` fetching their own record via `GET /api/v1/users/{user_id}`. This
  feature is blocked on `/auth/me` shipping.

**Rationale**: matches DESIGN.md exactly, except it surfaced a gap DESIGN.md
didn't anticipate — non-admins cannot bootstrap their session via
`/users/{user_id}` (admin-only). `/auth/refresh` remains genuinely out of
scope (client treats `401` as session-invalid); `/auth/me` is now a tracked
blocking dependency (`mictlanix/mbe-api#1`), not an open question.

**Alternatives considered**: hand-writing DTOs from DESIGN.md alone — rejected
per constitution §III (contract-driven, generated DTOs only).

## 2. OpenAPI client generation tooling

**Decision**: `openapi-generator-cli` (Java-based, run via `npx
@openapitools/openapi-generator-cli` to avoid a global Java/brew dependency
beyond a JRE) with the `dart-dio` generator, output committed to
`lib/generated/openapi/`. A small script
`tool/generate_api_client.sh` wraps the invocation (input:
`http://127.0.0.1:8000/openapi.json` or a locally-saved spec file; output:
`lib/generated/openapi`).

**Rationale**: `dart-dio` produces a `dio`-based client + model classes that
match constitution §III's "dio generator" requirement and integrate directly
with the hand-written `dio` interceptor (Decision 4). Committing the output
avoids requiring every contributor to run Java-based codegen just to `flutter
run`; re-running the script after an mbe-api spec change is a deliberate,
reviewable diff.

**Alternatives considered**:
- `dart` generator (no `dio`) — rejected, doesn't match constitution.
- Hand-maintained `retrofit`-style client — rejected, defeats the
  contract-driven goal and would drift from mbe-api.
- Not committing generated output (gitignored, regenerated on build) —
  rejected for now: adds a Java/codegen dependency to every fresh checkout
  and CI run; revisit if generated code volume becomes unwieldy.

## 3. State management codegen (Riverpod)

**Decision**: `flutter_riverpod` + `riverpod_annotation` +
`riverpod_generator` (+ `build_runner`, already needed for `freezed`/
`json_serializable`). `AuthNotifier` is an `@riverpod class AuthNotifier
extends _$AuthNotifier` (`AsyncNotifier<AuthState>`).

**Rationale**: generator-based Riverpod reduces boilerplate for provider
declarations and keeps `ref` typing safe; the build_runner step is already a
hard requirement for `freezed` DTO↔entity mapping, so it adds no new tooling
class.

**Alternatives considered**: hand-written `Provider`/`StateNotifierProvider`
— viable but more boilerplate for no benefit given build_runner is already
in the toolchain.

## 4. go_router auth guard pattern

**Decision**: `GoRouter(redirect: ...)` reads session state synchronously via
`ref.read(authNotifierProvider)` (an `AsyncValue<AuthState>`), and the
router's `refreshListenable` is a `GoRouterRefreshStream` wrapping
`ref.watch(authNotifierProvider.notifier).stream` (or an equivalent
`ChangeNotifier` bridge) so navigation re-evaluates redirects whenever auth
state changes (login, logout, 401-triggered invalidation).

- Unauthenticated + target route outside `/auth/*` → redirect to
  `/auth/login`.
- Authenticated + target route is `/auth/login` → redirect to `/` (or last
  intended route).
- Authenticated but `can(object, Read)` is `false` for the target route's
  `SystemObject` → redirect to a "not authorized" placeholder (or `/`).

**Rationale**: this is the standard documented integration between
`go_router` and Riverpod-held auth state; satisfies constitution §IV's
requirement that route guards use `can(object, Read)`.

**Alternatives considered**: per-screen manual checks in `build()` — rejected,
inconsistent and easy to miss for new routes (violates "deny by default"
intent).

## 5. Token storage on web

**Decision**: use `flutter_secure_storage` uniformly across platforms as
constitution §"Technology Stack" specifies, accepting its documented
limitation that the web implementation stores values in browser storage
without OS-level encryption.

**Rationale**: the 8-hour token lifetime plus server-side `session_version`
revocation (DESIGN.md §3.2) make this an acceptable risk for v1, and using
one API across platforms avoids per-platform branching in `core/storage`.

**Alternatives considered**: in-memory-only token on web (lost on refresh,
forcing re-login every page reload) — rejected as a poor UX for a desktop/web
-first app; revisit only if a security review requires it.

## 6. `SystemObject` enum source

**Decision**: hand-maintain `lib/core/access/system_object.dart` as a Dart
`enum SystemObject` with explicit integer values (`0`–`113`), transcribed
from `mbe/docs/constants.md` §SystemObjects (114 entries, 7 disabled/unused).
This feature populates the full table now (it's static data with no
dependency on mbe-api) so every later feature can reference it immediately;
`Users = 92` is the entry this feature's admin screens gate on.

**Rationale**: mbe-api exposes `system_object` as a raw `integer` in
`PrivilegeResponse`/`PrivilegeUpdate` (not an OpenAPI enum), so there's
nothing to generate — the canonical source is the legacy constants doc per
DESIGN.md §3.7.

**Alternatives considered**: deferring to "whichever feature needs the next
code" — rejected; the table is ~150 lines of static data and having it
complete avoids every subsequent feature touching the same shared file.

## 7. Test doubles

**Decision**: `mocktail` for repository/`dio` fakes in unit and widget tests.

**Rationale**: no code generation step, good null-safety ergonomics, widely
used with Riverpod `ProviderContainer` overrides.

**Alternatives considered**: `mockito` — requires `build_runner` codegen per
mock class; `mocktail` avoids that for a marginal feature like this.
