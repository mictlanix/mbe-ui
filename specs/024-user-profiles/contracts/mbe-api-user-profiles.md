# Contract: mbe-api user profiles, as consumed by mbe-ui

**Feature**: `024-user-profiles` | **Source**: mbe-api `specs/014-user-profiles`,
generated client in `lib/generated/openapi/` (commit `4382f3a`)

This records the endpoints, shapes and refusals this feature depends on. It is a
consumption contract: mbe-ui does not modify mbe-api (constitution §III). Every
call listed here already exists in the generated client — **no upstream change
is needed for this feature**.

## 1. Access

All six endpoints are **administrator-only**. There is no `SystemObject` for
profiles. A non-administrator receives `403`, whatever their privilege rows say.
Unauthenticated requests receive `401`, which the shared auth interceptor already
turns into a redirect to `/auth/login`.

## 2. Endpoints

### `GET /api/v1/user-profiles`

`listUserProfilesApiV1UserProfilesGet({search, status, skip, limit})`

| Parameter | Type | Notes |
|---|---|---|
| `search` | `String?` | Search by profile name. |
| `status` | `EntityStatus?` | Wire enum (`number0`/`number1`/`number2`). |
| `skip` | `int?` | Default `0`. |
| `limit` | `int?` | Default `20`; the app passes its own page size of 20. |

→ `UserProfileListResponse { items: BuiltList<UserProfileListItem>, total: int }`

`UserProfileListItem { user_profile_id: int, name: String, description: String?, status: EntityStatus }`

Note the list item carries **no privileges** — the catalog list cannot show what
a profile grants without a per-row `get`. FR-001 asks only for name, description
and status, so no extra fetch is made.

### `GET /api/v1/user-profiles/{profile_id}`

`getUserProfileApiV1UserProfilesProfileIdGet({profileId})`

→ `UserProfileResponse { user_profile_id, name, description?, status, privileges: BuiltList<ProfilePrivilegeResponse> }`

`ProfilePrivilegeResponse { system_object: int, privileges: int, allow_create: bool, allow_read: bool, allow_update: bool, allow_delete: bool }`

**`privileges` is sparse** — an entry exists only for a system object the
profile grants something on. Every absent object is denied. The four booleans are
a redundant projection of the `privileges` bitmask; the client maps the bitmask
and ignores them (`Privilege` already exposes the same four as getters).

### `POST /api/v1/user-profiles`

`createUserProfileApiV1UserProfilesPost({userProfileCreate})`

`UserProfileCreate { name: String (required), description: String?, status: EntityStatus?, privileges: BuiltList<ProfilePrivilegeUpdate>? }`

`ProfilePrivilegeUpdate { system_object: int, privileges: int }`

→ `UserProfileResponse`

### `PUT /api/v1/user-profiles/{profile_id}`

`updateUserProfileApiV1UserProfilesProfileIdPut({profileId, userProfileUpdate})`

`UserProfileUpdate { name: String?, description: String?, status: EntityStatus?, privileges: BuiltList<ProfilePrivilegeUpdate>? }`

→ `UserProfileResponse`

A supplied `privileges` list **replaces** the profile's set. The client always
sends the complete intended set on save.

### `DELETE /api/v1/user-profiles/{profile_id}`

`deleteUserProfileApiV1UserProfilesProfileIdDelete({profileId})` → `204`

### `POST /api/v1/user-profiles/{profile_id}/apply/{user_id}`

`applyUserProfileApiV1UserProfilesProfileIdApplyUserIdPost({profileId, userId})`

→ **`UserResponse`** — the full updated user, not the profile. The client
replaces its form state from this response rather than re-fetching.

## 3. User endpoints touched

### `POST /api/v1/users`

`UserCreate` gained `profile_id: int?`. When present the server applies that
profile as part of creation; when absent, creation behaves exactly as before.

### `GET /api/v1/users`

`listUsersApiV1UsersGet` gained `profileId: int?` — "Only accounts provisioned
from this profile".

### `UserResponse` / `UserListItem`

Both gained `profile_id: int?` and `profile_name: String?`. Empty on accounts
that were never provisioned from a profile.

## 4. Semantics the client must honour

| Rule | Consequence for mbe-ui |
|---|---|
| An apply **replaces** the user's permissions in full; unnamed objects become denied. | The confirmation must say so (FR-020); the form must replace, never merge, the returned privileges. |
| An apply **invalidates the target's sessions**. | The confirmation must say so; a self-apply ends the administrator's own session (FR-024). |
| An apply is a **one-time copy**. Editing a profile does not propagate. | Nothing may present `profile_name` as a live description of current permissions (FR-030). |
| Profiles are **sparse**; users keep a full matrix. | The grid renders all `SystemObject.values`; the client submits only non-zero masks (FR-010). |
| Profile names are unique **case-insensitively**. | "cashier" conflicting with "Cashier" is a legitimate refusal to surface on the name field (FR-013). |
| An **inactive** profile cannot be applied, but stays readable. | Both pickers query `status: active`; the catalog does not filter by default (FR-003). |
| Per-user privilege editing stays a **partial upsert**. | Never combine a create-with-profile and a follow-up privileges `PUT` in one save (research.md §7). |

## 5. Refusals

| Situation | Status | Client handling |
|---|---|---|
| Duplicate profile name (any case) | `409` (or `422`) | Localized message on the name field; input preserved (FR-013). |
| Delete a profile users reference | `409`, `detail` names how many | Localized heading + the server `detail` verbatim; profile unchanged (FR-014). |
| Apply an inactive profile | `409` | Localized heading + `detail`; form unchanged (FR-023). |
| Apply/read a missing profile or user | `404` | Localized heading + `detail`; form unchanged (FR-023). |
| Non-administrator caller | `403` | Should be unreachable — the UI hides every entry point (FR-031). Surfaced through the standard error path if it ever occurs. |
| Unauthenticated | `401` | Existing interceptor redirects to `/auth/login`. |

All refusals arrive as `DioException` and are funnelled through the repository's
`_toAppError` into the shared `AppError` types, exactly as
`UserRepositoryImpl` does today.
