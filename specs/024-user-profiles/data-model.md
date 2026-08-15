# Phase 1 Data Model: User Profiles as Permission Templates

**Feature**: `024-user-profiles` | **Date**: 2026-08-14

Client-side domain types only. Generated DTOs (`UserProfileResponse`,
`ProfilePrivilegeUpdate`, …) stay in `lib/generated/openapi/` and never reach
`presentation/` — constitution §III requires the mapping boundary, and the
`fromResponse`/`toUpdate` members below are that boundary.

## 1. New domain entities

### `UserProfile` — `lib/features/auth/domain/entities/user_profile.dart`

A permission template, as read from `GET /api/v1/user-profiles/{id}`.

| Field | Type | Notes |
|---|---|---|
| `userProfileId` | `int` | Server-assigned. |
| `name` | `String` | Unique without regard to case; stored as typed. |
| `description` | `String?` | Optional. |
| `status` | `EntityStatus` | Reuses [`EntityStatus`](../../lib/core/domain/entity_status.dart); `inactive` = retired, not applyable. |
| `privileges` | `List<Privilege>` | **Sparse** — only the objects the profile grants on. Absence means denied. |

- `factory UserProfile.fromResponse(UserProfileResponse)` — maps
  `status` via `EntityStatus.fromApi`, and `privileges` via
  `Privilege.fromProfileResponse`, dropping entries whose `system_object` is not
  a known `SystemObject` (same posture as `Privilege.fromResponse`).

**Validation rules** (client-side, before submit):

- `name` MUST be non-empty (FR-006). Trailing/leading whitespace trimmed.
- `privileges` MAY be empty — an empty profile is valid (FR-011).
- No entry with `rawValue == 0` is ever submitted (FR-010).

### `UserProfileSummary` — same file

A row in the catalog list and an option in the two pickers, from
`UserProfileListItem`.

| Field | Type |
|---|---|
| `userProfileId` | `int` |
| `name` | `String` |
| `description` | `String?` |
| `status` | `EntityStatus` |

- `factory UserProfileSummary.fromListItem(UserProfileListItem)`.

## 2. Extended existing entities

### `Privilege` — `lib/core/access/privilege.dart` *(extended)*

No field changes. Two members added so one mask type serves both users and
profiles:

- `static Privilege? fromProfileResponse(ProfilePrivilegeResponse)` — mirrors
  the existing `fromResponse`, returning `null` for an unknown system object.
- `ProfilePrivilegeUpdate toProfileUpdate()` — mirrors the existing
  `toUpdate()`.

### `User` — `lib/core/access/user.dart` *(extended)*

| Added field | Type | Notes |
|---|---|---|
| `profileId` | `int?` | Provenance only. Never consulted by `AccessControlService`. |
| `profileName` | `String?` | Denormalized by the server for display. |

`User.fromResponse` reads both from `UserResponse`.

### `UserSummary` — same file *(extended)*

Same two fields, read from `UserListItem` in `UserSummary.fromListItem`.

**Invariant**: nothing in `lib/core/access/` may branch on `profileId`. It is
display and filter data; `can()` reads `privileges` and `administrator` only.

## 3. View state

### `UserProfileFilter` — `user_profiles_controller.dart`

The catalog list's addressable state, decoded from the route's `ListQuery`
exactly as `UserFilter` is (017-ui-consistency-filters).

| Field | Default | Facet key |
|---|---|---|
| `search` | `''` | `search` (reserved param) |
| `status` | `null` | `status` |
| `pageIndex` | `0` | `page` (reserved param) |

- `factory UserProfileFilter.fromQuery(ListQuery)` — an unparseable `status`
  degrades to `null`.
- `extension UserProfileFilterBadge` → `activeFilterCount` = `status != null ? 1 : 0`.

### `UserFilter` — `users_controller.dart` *(extended)*

| Added field | Default | Facet key |
|---|---|---|
| `profileId` | `null` | `profile` |

- `activeFilterCount` becomes `(status != null ? 1 : 0) + (profileId != null ? 1 : 0)`.
- Canonical facet insertion order: `status`, then `profile`.

### `UserProfileFormState` — `user_profiles_controller.dart`

Local form state for create/edit, mirroring `UserFormState`'s shape.

| Field | Type | Default |
|---|---|---|
| `name` | `String` | `''` |
| `description` | `String` | `''` |
| `status` | `EntityStatus` | `active` |
| `privileges` | `List<Privilege>` | `[]` |
| `loading` / `submitting` / `saved` / `deleted` | `bool` | `false` |
| `error` | `String?` | `null` — a `UserProfileFormErrorCode` or a raw `ValidationError` message |
| `errorDetail` | `String?` | `null` — the server's untranslatable `detail` |

`UserProfileFormErrorCode`: `nameRequired`, `nameConflict`, `loadFailed`,
`saveFailed`, `deleteFailed`, `deleteReferenced`.

### `UserFormState` — `users_controller.dart` *(extended)*

| Added field | Type | Purpose |
|---|---|---|
| `profileId` | `int?` | Create mode: the chosen template. Edit mode: the recorded origin. |
| `profileName` | `String` | Display text for the picker / the provenance line. |

Added `UserFormErrorCode` constants: `applyFailed`, `profileInactive`.

## 4. State transitions

### Profile status

```
active ──(edit: status → inactive)──▶ inactive ──(edit: status → active)──▶ active
```

- `inactive` is readable everywhere but excluded from both pickers (FR-016,
  FR-019), which query `status: EntityStatus.active`.
- `archived` exists in `EntityStatus` but is not offered by this feature's forms;
  a profile arriving as `archived` renders its status and is likewise excluded
  from the pickers.

### Applying a profile to a user

```
                      ┌─ 4xx ─▶ error shown, form state unchanged (FR-023)
confirm ─▶ POST apply ┤
                      └─ 200 ─▶ form state replaced from returned User
                                 (privileges, profileId, profileName)
                                 + invalidate users list
                                 + if target == signed-in user:
                                     next request 401 ─▶ auth interceptor
                                     redirects to /auth/login (FR-024)
```

The transition is **replace, never merge**: the returned `User` supersedes the
form's privileges wholesale. A merge would reintroduce permissions the server
just denied.

### Creating a user with a profile

```
profile chosen ─▶ POST /users {..., profile_id} ─▶ done  (no follow-up PUT)
no profile     ─▶ POST /users {...} ─▶ if grid non-empty: PUT /users/{id} {privileges}
```

The follow-up `PUT` is the existing behaviour and MUST NOT run on the
profile path — see research.md §7.

## 5. Relationships

```
UserProfile 1 ──── * Privilege        (sparse: only granted SystemObjects)
UserProfile 1 ──── * User             (provenance only, via User.profileId)
User        1 ──── * Privilege        (full matrix: an entry per SystemObject)
Privilege   * ──── 1 SystemObject     (existing enum, unchanged)
```

The `UserProfile → User` edge is **not** a foreign key the client dereferences
for permissions. It exists so the users list can filter (FR-028) and so the
detail screen can name where an account came from (FR-029). Deleting a profile
with any such edge is refused by the server (FR-014).
