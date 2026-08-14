# Phase 0 Research: User Profiles as Permission Templates

**Feature**: `024-user-profiles` | **Date**: 2026-08-14 | **Spec**: [spec.md](./spec.md)

Every decision below was taken against code read in this repository and against
mbe-api's `specs/014-user-profiles/spec.md`. Nothing here is speculative: where a
pattern already exists, the decision is to reuse it, and the section names the
file it is reused from.

## §1 Feature module placement

**Decision**: User profiles live in `lib/features/auth/`, alongside the existing
user administration code — `domain/entities/user_profile.dart`,
`domain/repositories/user_profile_repository.dart`,
`data/user_profile_repository_impl.dart`,
`presentation/admin/user_profiles_controller.dart`,
`presentation/admin/user_profiles_list_screen.dart`,
`presentation/admin/user_profile_detail_screen.dart`.

**Rationale**: constitution §I organizes by business feature, and a profile is a
user-management concept: it is authored by the same administrator, made of the
same `Privilege` values, and applied to the same `User`. The apply action and the
profile picker both live on screens already in `presentation/admin/`, so putting
the catalog anywhere else would make `auth`'s presentation layer import another
feature's domain for its core flow.

**Alternatives considered**: `lib/features/catalog/`, where the other
list/detail catalogs live. Rejected — `catalog` is master data for products and
partners; profiles carry `SystemObject`/`AccessRight`, which live in
`lib/core/access/` and are consumed almost exclusively by `auth`.

## §2 Administrator-only route gating

**Decision**: extend `_routeGate` in
[app_router.dart](../../lib/app/router/app_router.dart#L578) from returning
`({SystemObject object, AccessRight right})?` to returning a small sealed
gate type with two cases — a privilege gate (today's pair) and an
administrator-only gate — and have `_redirect` evaluate the latter via
`AccessControlService.isAdministrator`. `NavGate` in
[nav_destination.dart](../../lib/core/navigation/nav_destination.dart#L16) gets
the same treatment, and `_isVisible` in
[nav_destinations.dart](../../lib/core/navigation/nav_destinations.dart#L310)
evaluates it.

**Rationale**: `AccessControlService.isAdministrator` already exists
([access_control.dart](../../lib/core/access/access_control.dart#L21)) and is
exactly what mbe-api enforces for every profile endpoint. Constitution §IV
requires routes be gated by `can(SystemObject, AccessRight)`; profiles have no
`SystemObject`, so the rule cannot be satisfied literally. Since `can()` already
short-circuits to `true` for administrators, an administrator-only gate is
strictly narrower than any privilege gate — it opens nothing that was closed.
This is recorded as the plan's single Constitution deviation (Complexity
Tracking).

**Alternatives considered**:

- *Gate on `SystemObject.users` + read*, as `/users` does. Rejected: a
  non-administrator holding `users:read` would see the navigation entry and the
  screen, then have every request refused by the server — a dead end the user
  cannot act on, and the exact failure mode deny-by-default exists to prevent.
- *Add a synthetic `SystemObject.userProfiles` client-side.* Rejected: the
  `SystemObject` enum mirrors mbe-api's catalog
  ([privilege.dart](../../lib/core/access/privilege.dart#L23) drops unknown
  codes on the way in). Inventing a code the server does not have would put a
  row in the permission grid that grants nothing anywhere.

## §3 Navigation placement

**Decision**: a new `StatefulShellBranch` for `/user-profiles`, appended last in
`app_router.dart`, with `NavBranch.userProfiles = 19` appended to
[nav_destinations.dart](../../lib/core/navigation/nav_destinations.dart#L11).
The `NavDestination` is inserted into the existing `catalogs` group immediately
after `users`, carrying the administrator-only gate from §2.

**Rationale**: branch indices are positional and appended, never renumbered —
the file states this twice, for `cashSessions` (17) and `pos` (18), with the
explicit note that `NavBranch` order is not display order. Display order is the
order within `kNavigationTree`, so "beside Users" is achieved by list position,
not by index.

**Alternatives considered**: renumbering to place `userProfiles = 2` next to
`users = 1`. Rejected — it would shift eighteen constants and every branch in
the router for a purely cosmetic gain the tree ordering already delivers.

## §4 Domain entities and the sparse-to-full mapping

**Decision**: three freezed entities in `lib/features/auth/domain/entities/`:

- `UserProfile` — `userProfileId`, `name`, `description?`, `status`,
  `privileges: List<Privilege>`, mapped from `UserProfileResponse`.
- `UserProfileSummary` — the list row, mapped from `UserProfileListItem`.
- No new privilege type: the existing
  [`Privilege`](../../lib/core/access/privilege.dart) already carries
  `SystemObject` + `rawValue` and already has `toUpdate()`. A profile's
  `ProfilePrivilegeResponse` exposes the identical `system_object` +
  `privileges` pair, so `Privilege.fromProfileResponse` is a second named
  constructor beside the existing `fromResponse`, and a
  `toProfileUpdate()` emits `ProfilePrivilegeUpdate`.

The sparse-versus-full asymmetry is handled entirely in the widget layer:
`PrivilegesGrid` already renders one row per `SystemObject.values` and looks
each up in a map built from the list it is given
([privileges_grid.dart](../../lib/features/auth/presentation/admin/privileges_grid.dart#L73)),
defaulting a missing entry to `0`. A sparse profile therefore renders correctly
with no change to the widget. On the way out, `UserFormController.privilegeChanged`
already drops an entry whose mask reaches `0`
([users_controller.dart](../../lib/features/auth/presentation/admin/users_controller.dart#L224)),
which is precisely the sparse-write rule FR-010 asks for; the profile form
controller reuses that logic verbatim.

**Rationale**: reusing `Privilege` keeps one representation of a permission mask
in the app, satisfies FR-009 ("recognises it as the same thing") structurally
rather than by convention, and means `PrivilegesGrid` needs no modification at
all — the single largest piece of UI in this feature is already built and
already tested (`test/widget/features/auth/privileges_grid_test.dart`).

**Alternatives considered**: a distinct `ProfilePrivilege` entity mirroring
`ProfilePrivilegeResponse`'s extra `allowCreate`/`allowRead`/`allowUpdate`/
`allowDelete` booleans. Rejected — those booleans are a redundant projection of
the same bitmask, and `Privilege` already exposes them as getters.

## §5 Repository surface

**Decision**: one new repository, `UserProfileRepository`, with `list`, `get`,
`create`, `update`, `delete`, `apply`. The `apply` method returns the updated
`User` (the endpoint returns a full `UserResponse`). `UserRepository.create`
gains an optional `int? profileId` parameter, and `UserRepository.list` gains an
optional `int? profileId` filter.

Generated methods this maps onto, verified in
[user_profiles_api.dart](../../lib/generated/openapi/lib/src/api/user_profiles_api.dart):

| Repository method | Generated call |
|---|---|
| `list` | `listUserProfilesApiV1UserProfilesGet(search, status, skip, limit)` |
| `get` | `getUserProfileApiV1UserProfilesProfileIdGet(profileId)` |
| `create` | `createUserProfileApiV1UserProfilesPost(userProfileCreate)` |
| `update` | `updateUserProfileApiV1UserProfilesProfileIdPut(profileId, userProfileUpdate)` |
| `delete` | `deleteUserProfileApiV1UserProfilesProfileIdDelete(profileId)` |
| `apply` | `applyUserProfileApiV1UserProfilesProfileIdApplyUserIdPost(profileId, userId)` |

**Rationale**: mirrors `UserRepositoryImpl`
([user_repository_impl.dart](../../lib/features/auth/data/user_repository_impl.dart))
one-for-one, including its `DioException → AppError` funnel via the file-local
`_toAppError`. Constitution §III forbids hand-written DTOs; all six calls exist
in the generated client already, so no bypass is needed. No `multipart/form-data`
is involved, so the §III upload caveat does not apply.

**External dependency check**: none. Every field the spec needs is already on
the wire — `UserCreate.profileId`, `UserResponse.profileId`/`profileName`,
`UserListItem.profileId`/`profileName`, and the users list `profileId` query
parameter (verified in
[users_api.dart](../../lib/generated/openapi/lib/src/api/users_api.dart#L283)).
No mbe-api issue needs filing for this feature (constitution §III repo-boundary
rule).

## §6 The apply flow

**Decision**: the apply lives on `user_detail_screen.dart` in
`RecordFormMode.edit` only, as an `OutlinedButton` in the form body — not in
`AppBar.actions`, which constitution §VI (v1.10.0) requires be empty on a record
detail screen. Sequence:

1. The button opens a dialog holding a `CatalogEntityPicker<UserProfileSummary>`
   restricted to `status: active`, plus the consequence text (FR-020) and, when
   the target is the signed-in user, the additional self-apply warning (FR-024).
2. Confirming calls `UserFormController.applyProfile(profileId, userId)`.
3. On success the controller replaces the form state wholesale from the returned
   `User` — privileges, status, administrator flag, and the new `profileId`/
   `profileName` — so FR-022's "no manual reload" is structural, not a refresh
   call. It also `ref.invalidate(usersControllerProvider)` so the list's profile
   column is current, mirroring `deleteUser`'s existing invalidation.
4. On failure it sets an error code and leaves prior state untouched (FR-023).

**Self-apply (FR-024)**: applying to one's own account bumps the server's
session version, so the very next request returns `401`. The shared auth
interceptor already treats any `401` as session-invalid and redirects to
`/auth/login`
([constitution §III](../../.specify/memory/constitution.md#L146)), so the
sign-out needs no new machinery — the requirement is satisfied by *not*
surfacing that `401` as a form error. The detail is that the apply response
itself succeeds (it is the request that carries the still-valid token), so the
controller must not immediately re-fetch the user afterwards on the self-apply
path; the redirect happens on the user's next action.

**Rationale**: `UserFormController` already owns load/save/delete/recover for
this screen and already invalidates the list after mutations; adding a sixth
action keeps one owner of the form's state. The dialog-with-picker shape is the
same one `cash_sessions_screen.dart` uses for a picker inside a transient
surface.

**Alternatives considered**:

- *Apply as a row action on the users list.* Rejected in the spec's Assumptions:
  the confirmation must show what the account currently holds, which only the
  detail screen displays. Constitution §VI also caps row actions at Edit plus at
  most one more, and that slot is better left free.
- *A dedicated `/users/:id/apply-profile` route.* Rejected — a modal decision
  with two outcomes does not warrant an addressable screen, and every other
  confirm in the app is a dialog (`RecordDeleteConfirmation`).

## §7 Profile choice on user creation

**Decision**: `UserFormState` gains `profileId`, `profileName` (display text for
the picker) and, for edit mode, `originProfileName` (read-only provenance).
`UserFormController.save` passes `profileId` to `repo.create` in create mode
only.

One subtlety in the existing code: `save()` in create mode calls `create` and
then, if `state.privileges.isNotEmpty`, a follow-up `update` to set privileges
([users_controller.dart](../../lib/features/auth/presentation/admin/users_controller.dart#L297)),
because `POST /users` historically could not carry privileges. That second call
must be **skipped when a profile was chosen** — a partial-upsert `update`
running after the server already copied the profile would layer hand-edits on
top of a just-applied template and silently contradict FR-017. The create form
therefore hides the permission grid while a profile is selected, and shows it
otherwise.

**Rationale**: the two paths write permissions with different semantics (full
replace versus partial upsert — mbe-api FR-026 keeps this asymmetry
deliberately). Letting both run in one save is the one place this feature could
produce an account matching neither its profile nor the grid.

**Alternatives considered**: allowing both — pick a profile *and* tweak the grid
before saving. Rejected as a scope increase the spec does not ask for; the
account can be hand-edited immediately after creation, which is FR-026's
explicit guarantee.

## §8 Users list: origin column and profile filter

**Decision**:

- `UserSummary` gains `profileId` and `profileName`; a new column renders
  `profileName ?? ''` (FR-027).
- `UserFilter` gains `profileId`, decoded from the `profile` facet key, and
  `activeFilterCount` becomes `(status != null ? 1 : 0) + (profileId != null ? 1 : 0)`.
- The filter panel gains a `CatalogEntityPicker<UserProfileSummary>` beside the
  existing status chips, writing `query.withFacet('profile', '$id')`.
- A shared URL carries only the id, so the picker's `initialDisplayText` resolves
  through a new `userProfileNameProvider(int id)` family, falling back to the raw
  id while it loads — exactly the pattern `cash_sessions_screen.dart` uses with
  `employeeDisplayNameProvider`
  ([cash_sessions_screen.dart](../../lib/features/sales/presentation/cash_sessions_screen.dart#L398)).

**Facet key naming**: the URL facet is `profile`, while the wire parameter is
`profile_id`. `ListQuery` facet keys are the app's own vocabulary (`cash-drawer`
maps to `cash_drawer_id`, `cashier` to `cashier_id`), so `profile` is the
consistent choice. The pinned `profile_id` from the spec's Verbatim Constraints
is the *API* parameter, and is used verbatim there.

**Canonical facet order**: `status` then `profile`, since `status` already
exists and `ListQuery.toUri` preserves insertion order for stable URLs
([list_query.dart](../../lib/core/navigation/list_query.dart#L84)).

## §9 Error mapping

**Decision**: two server refusals need specific treatment, both surfaced through
the existing `AppError` funnel and the screen's `ErrorBanner`:

| Case | Server | Presentation |
|---|---|---|
| Duplicate name (case-insensitive) | `409` | Localized message against the name field; form state preserved (FR-013) |
| Delete while referenced | `409` with a count in `detail` | Localized heading plus the server's `detail` verbatim as supplementary text (FR-014) |
| Apply an inactive/missing profile | `404`/`409` | Localized heading plus server `detail`; form unchanged (FR-023) |

**Rationale**: `UserFormState` already carries the
`error` (localizable code) + `errorDetail` (raw server text) pair for exactly
this — a server message that cannot be localized client-side is shown as
supplementary detail under a localized heading
([user_detail_screen.dart](../../lib/features/auth/presentation/admin/user_detail_screen.dart#L104)).
The profile form controller reuses the same two-field shape and its own
`UserProfileFormErrorCode` constants.

**Open point deferred to implementation**: whether mbe-api returns `409` or a
`422` validation body for the duplicate name. Both are already handled — a
`ValidationError` with a non-empty `errors` list is stored raw in `error`
(existing branch in `save()`), anything else falls to the code + detail pair —
so no decision is blocked on confirming it.

## §10 Testing strategy

**Decision**, following the repository's existing split:

- `test/unit/features/auth/user_profile_repository_impl_test.dart` — DTO↔entity
  mapping in both directions, sparse-write (a zero mask emits no entry), and the
  `DioException → AppError` funnel, with the API mocked as
  `user_repository_impl_test.dart` does.
- `test/unit/features/auth/user_profiles_controller_test.dart` — list paging and
  filter decoding; profile form save/delete; and the apply action's success and
  failure state transitions with a fake repository.
- `test/widget/features/auth/user_profiles_list_screen_test.dart` and
  `user_profile_detail_screen_test.dart` — search, status filter, empty state,
  the grid rendering a sparse profile as ticked-here/unticked-elsewhere, and the
  delete confirmation.
- Extensions to `test/widget/features/auth/user_detail_screen_test.dart` and
  `users_list_screen_test.dart` — the apply dialog's consequence text, the
  self-apply warning, the profile column, and the profile filter.
- `test/unit/features/auth/access_control_test.dart` and the router's tests —
  administrator-only gate visible to an administrator, hidden and redirected
  otherwise.

**Rationale**: constitution §"Development Workflow & Quality Gates" requires
unit tests for repositories with the API client mocked, and widget tests for
critical per-module screens. No golden tests: this feature introduces no new
shared visual component (it reuses `PrivilegesGrid`, `DataTableView` and
`RecordFormActions` unchanged).

## §11 Localization

**Decision**: all new strings added to both `lib/l10n/app_en.arb` and
`lib/l10n/app_es.arb`, with `es` as the default locale. The consequence text in
the apply confirmation is written as two separate keys (replacement, session
end) plus a third for the self-apply warning, rather than one interpolated
paragraph, so a translator can reorder them.

**Rationale**: constitution §V makes `es-MX` first-class; FR-035 requires both
locales. Splitting the confirmation copy keeps FR-020's two mandated statements
independently assertable in a widget test.
