---

description: "Task list for User Profiles as Permission Templates"
---

# Tasks: User Profiles as Permission Templates

**Input**: Design documents from `/specs/024-user-profiles/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/mbe-api-user-profiles.md, contracts/routes.md, contracts/user-profile-screens.md, quickstart.md

**Tests**: Included — the constitution's "Development Workflow & Quality Gates" mandates unit tests for repositories (API client mocked) and widget tests for critical screens; quickstart.md names the five highest-risk tests explicitly.

**Organization**: Tasks are grouped by user story, following the spec's priorities: US1 Author/maintain the catalog (P1), US2 Provision an account from a profile (P1), US3 Find and re-provision (P2). US2's apply half needs an existing profile, so it depends on US1's create path existing (not the full catalog UI) — the plan's Foundational phase provides the repository both stories need, so this is a data dependency, not a UI one. US3 depends on US2 having produced provisioned accounts to filter by, and reuses US1's `CatalogEntityPicker<UserProfileSummary>` pattern already built for US2. Everything else across stories is independent.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: US1–US3, mapping to the spec's user stories
- Every task includes an exact file path

## Path Conventions

Single Flutter project, feature-first. All new code lives in the existing
`lib/features/auth/` module (plan.md Structure Decision — a profile is made of
`Privilege` values and applied to a `User`, so it belongs beside user
administration, not in `catalog/`). Shared files touched: `lib/core/access/`
(`privilege.dart`, `user.dart`), `lib/core/navigation/` (`nav_destination.dart`,
`nav_destinations.dart`), `lib/app/router/app_router.dart`, both `.arb` files.
`lib/features/auth/presentation/admin/privileges_grid.dart` is reused
**unmodified** — no task touches it. Tests live under
`test/unit/features/auth/`, `test/widget/features/auth/`, and the existing
`test/unit/app/router/app_router_test.dart`.

---

## Phase 1: Setup

**Purpose**: Confirm the generated client actually carries what this feature needs. No backend change, no codegen — the client was regenerated just before this spec was written.

- [X] T001 Confirm `lib/generated/openapi/lib/src/api/user_profiles_api.dart` exposes all 6 operations (`listUserProfilesApiV1UserProfilesGet`, `getUserProfileApiV1UserProfilesProfileIdGet`, `createUserProfileApiV1UserProfilesPost`, `updateUserProfileApiV1UserProfilesProfileIdPut`, `deleteUserProfileApiV1UserProfilesProfileIdDelete`, `applyUserProfileApiV1UserProfilesProfileIdApplyUserIdPost`) and that `lib/generated/openapi/lib/src/api/users_api.dart` carries a `profileId` parameter on `listUsersApiV1UsersGet`, and that `UserCreate`/`UserResponse`/`UserListItem` carry `profileId`/`profileName` fields (contracts/mbe-api-user-profiles.md §2–3). Do NOT regenerate — if anything is missing, stop and re-open research.md §5. Verified: all 6 operations present, `profileId` param present, all 3 models carry the fields
- [X] T002 [P] Create empty directories where new files will land: none needed beyond existing `lib/features/auth/domain/entities/`, `lib/features/auth/domain/repositories/`, `lib/features/auth/data/`, `lib/features/auth/presentation/admin/` — confirm all four already exist (they do; this is a no-op verification, not a scaffold). Verified: all four exist

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: The shared entities, repository, gate type, and routing every user story depends on.

**⚠️ CRITICAL**: T009 (router) and T010 (nav) touch the two files every other feature also appends to — sequence them last in this phase, after the screens they reference have at least a placeholder body, so the router never references a class that doesn't exist yet (021-cash-sessions T016 precedent).

### Domain layer (data-model.md §1–2)

- [X] T003 [P] Add `Privilege.fromProfileResponse(ProfilePrivilegeResponse)` and `Privilege.toProfileUpdate() → ProfilePrivilegeUpdate` to `lib/core/access/privilege.dart`, mirroring the existing `fromResponse`/`toUpdate` exactly — same unknown-system-object-drops-to-null posture (data-model.md §2)
- [X] T004 [P] Add `profileId: int?` and `profileName: String?` to `User` and `UserSummary` in `lib/core/access/user.dart`, read from `UserResponse.profileId`/`profileName` and `UserListItem.profileId`/`profileName` in their respective `fromResponse`/`fromListItem` factories (data-model.md §2). Do NOT let `AccessControlService` read either field
- [X] T005 [P] Create `lib/features/auth/domain/entities/user_profile.dart` — `UserProfile` (`userProfileId`, `name`, `description?`, `status: EntityStatus`, `privileges: List<Privilege>`) with `factory UserProfile.fromResponse(UserProfileResponse)`, and `UserProfileSummary` (`userProfileId`, `name`, `description?`, `status`) with `factory UserProfileSummary.fromListItem(UserProfileListItem)`. Both map `status` via `EntityStatus.fromApi`; `UserProfile.fromResponse` maps `privileges` via `Privilege.fromProfileResponse`, dropping nulls (data-model.md §1). Depends on T003

### Repository (data-model.md §5; contracts/mbe-api-user-profiles.md)

- [X] T006 Define `UserProfileRepository` in `lib/features/auth/domain/repositories/user_profile_repository.dart` — `list({String? search, EntityStatus? status, int skip = 0, int limit = 20})` → `UserProfileListResult { items: List<UserProfileSummary>, total: int }`, `get({required int profileId})` → `UserProfile`, `create({required String name, String? description, EntityStatus status = EntityStatus.active, List<Privilege> privileges = const []})` → `UserProfile`, `update({required int profileId, String? name, String? description, EntityStatus? status, List<Privilege>? privileges})` → `UserProfile`, `delete({required int profileId})`, `apply({required int profileId, required String userId})` → `User` (research.md §5). Depends on T005
- [X] T007 Implement `lib/features/auth/data/user_profile_repository_impl.dart` wrapping `UserProfilesApi`, matching `UserRepositoryImpl`'s shape exactly: same `_toAppError` catch-and-rethrow funnel, same constructor pattern (`UserProfileRepositoryImpl(Dio dio) : _api = UserProfilesApi(dio, standardSerializers)`), a top-level `userProfileRepositoryProvider`. `create`/`update` build `ProfilePrivilegeUpdate` lists via `Privilege.toProfileUpdate()`, sending **only non-zero masks** — never send an entry whose mask is `0` (research.md §4, FR-010). `apply` calls `applyUserProfileApiV1UserProfilesProfileIdApplyUserIdPost` and maps the returned `UserResponse` through `User.fromResponse`. Depends on T006
- [X] T008 [P] Add `int? profileId` to `UserRepository.create()` and `int? profileId` to `UserRepository.list()` in `lib/features/auth/domain/repositories/user_repository.dart`; thread both through `UserRepositoryImpl` in `lib/features/auth/data/user_repository_impl.dart` — `create` passes `profileId` onto `UserCreate.profileId`, `list` passes `profileId` onto `listUsersApiV1UsersGet`'s `profileId` param. Depends on T005 (needs no new type, but keeps this file's edit sequenced with the rest of Foundational)

### Routing gate (contracts/routes.md §2–3)

- [X] T009 Widen the router's gate type: replace `({SystemObject object, AccessRight right})?` with a sealed `RouteGate` (`PrivilegeGate(SystemObject object, AccessRight right)`, `AdministratorGate()`) in `lib/core/navigation/nav_destination.dart` (the `NavGate` typedef becomes this sealed type) and use it in `lib/app/router/app_router.dart`'s `_routeGate`/`_redirect` — every existing route's gate becomes `PrivilegeGate(object, right)` (mechanical, no semantic change), and `_redirect` gains an `AdministratorGate` arm checking `accessControlProvider.isAdministrator`. Add the `/user-profiles` clause to `_routeGate` **before** the existing `/users` clause (contracts/routes.md §2 ordering note — `/user-profiles` doesn't start with `/users`, but the two prefix checks must stay unambiguous). Depends on T007 (screens referenced by the new routes need to exist as at least placeholders — see T010)
- [X] T010 Add the `/user-profiles` `StatefulShellRoute` branch (appended last) plus the `/user-profiles/new` and `/user-profiles/:profileId` top-level sibling routes to `lib/app/router/app_router.dart`, wired against minimal placeholder `UserProfilesListScreen`/`UserProfileDetailScreen` stubs (correct constructor signatures, `Placeholder()` bodies) created ahead of T017/T018 — the router can't reference screens that don't exist yet (021-cash-sessions T016 precedent: this file is edited once, not twice). Depends on T009
- [X] T011 Add `static const int userProfiles = 19;` to `NavBranch` and a `NavDestination` (`id: 'user-profiles'`, icon `Icons.badge_outlined`/`Icons.badge`, gate `AdministratorGate()`) immediately after `users` inside the existing `NavGroup(id: 'catalogs')` in `lib/core/navigation/nav_destinations.dart`; update `_isVisible` to switch on the sealed `RouteGate` (contracts/routes.md §3–4). **Verify immediately** (don't defer to Polish): add gate allow/deny tests plus the branch-index (19) assertion to `test/unit/app/router/app_router_test.dart` now, alongside a `userProfileRepositoryProvider` override in the test's `pumpAt` helper — every screen from here on needs it wired in. Depends on T010

**Checkpoint**: Entities, repository, gate type, routing and nav all exist. Placeholder screens only. Every user story can now start.

---

## Phase 3: User Story 1 - Author and maintain the profile catalog (Priority: P1) 🎯 MVP

**Goal**: An administrator can list, search, filter, create, view, edit and delete user profiles, with the same permission grid the user form already uses.

**Independent Test**: Sign in as an administrator, create several profiles with known permission sets, list/search/filter them, open one and confirm its permissions read back exactly as entered, edit and delete one — all without touching any user account.

### Tests for User Story 1 ⚠️

- [X] T012 [P] [US1] Unit test `test/unit/features/auth/user_profile_repository_impl_test.dart` — DTO↔entity mapping both directions for `list`/`get`/`create`/`update`/`delete`, the sparse-write rule (a `rawValue == 0` privilege is never submitted; a response entry naming an unknown `SystemObject` is dropped), and the `DioException → AppError` funnel, mocking `UserProfilesApi` the way `user_repository_impl_test.dart` mocks `UsersApi` (quickstart.md's top-risk test #1)
- [X] T013 [P] [US1] Unit test `test/unit/features/auth/user_profiles_controller_test.dart` — `UserProfileFilter.fromQuery` decoding (search/status/page, an unparseable status degrading to `null`), `UserProfilesController` paging via a fake `UserProfileRepository`, and `UserProfileFormController` create/update/delete state transitions including `nameRequired`, a `ValidationError` surfacing as a raw name-conflict message, and `deleteReferenced` preserving the profile on a `409`

### Implementation for User Story 1

- [X] T014 [US1] Create `lib/features/auth/presentation/admin/user_profiles_controller.dart` — `UserProfileFilter` (freezed: `search`, `status`, `pageIndex`, `factory .fromQuery(ListQuery)`, `activeFilterCount` extension) mirroring `UserFilter`; `UserProfileFormState` (freezed: `name`, `description`, `status`, `privileges`, `loading`/`submitting`/`saved`/`deleted`, `error`, `errorDetail`) mirroring `UserFormState`; `UserProfileFormErrorCode` constants (`nameRequired`, `nameConflict`, `loadFailed`, `saveFailed`, `deleteFailed`, `deleteReferenced`); `@riverpod class UserProfilesController` (`AsyncNotifier` family over `UserProfileFilter`, `_pageSize = 20`, same `fetchClampedPage` shape as `UsersController`); `@riverpod class UserProfileFormController` (plain `Notifier`) with `loadProfile(int profileId)`, field setters, `privilegeChanged(SystemObject, int rawValue)` (drops the entry when `rawValue == 0`, verbatim reuse of `UserFormController.privilegeChanged`'s logic), `save({int? existingProfileId})`, `deleteProfile(int profileId)`. Depends on T007, T013
- [X] T015 [P] [US1] Add the "Profile catalog" localization keys to `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb` (contracts/user-profile-screens.md §5): `userProfilesMenuTitle`, `newUserProfileTooltip`, `userProfilesSearchLabel`, `noUserProfilesFound`, `columnProfileName`, `columnProfileDescription`, `newUserProfileTitle`/`editUserProfileTitle`/`viewUserProfileTitle`, `userProfileNameFieldLabel`, `userProfileDescriptionFieldLabel`, field-level errors (`userProfileNameRequiredError`, `userProfileNameConflictError`, `userProfileLoadFailedError`, `userProfileSaveFailedError`, `userProfileDeleteFailedError`), delete confirmation (`deleteUserProfileConfirmTitle`/`Message`/`ConfirmLabel`/`CancelLabel`). Run `flutter gen-l10n` after editing
- [X] T016 [P] [US1] Add the "no profiles yet" empty-state message and profile-picker label keys to both `.arb` files: `noUserProfilesYetMessage` (used by both this story's list and US2's pickers), `userProfilePickerLabel`. Run `flutter gen-l10n` after editing
- [X] T017 [US1] Replace the T010 placeholder with the real `UserProfilesListScreen` in `lib/features/auth/presentation/admin/user_profiles_list_screen.dart` — structurally mirrors `UsersListScreen`: `CatalogFilterBar` with `CatalogSearchBar` (key `user_profiles_search_field`), New button (key `new_user_profile_button`) visible only to administrators, Filters button (key `user_profiles_filter_button`) with a status-chip panel (key `user_profiles_filter_status`), `DataTableView<UserProfileSummary>` (key `user_profiles_table`) with Name/Description/Status columns, whole-row tap → `/user-profiles/:id?view=true`, one Edit row action → `/user-profiles/:id` (contracts/user-profile-screens.md §1). Depends on T014, T015
- [X] T018 [US1] Replace the T010 placeholder with the real `UserProfileDetailScreen` in `lib/features/auth/presentation/admin/user_profile_detail_screen.dart` — `Scaffold` with empty `AppBar.actions` (constitution §VI); `ResponsiveFormGrid` with Name (key `user_profile_name_field`), Description (key `user_profile_description_field`), Status fields, and **the existing `PrivilegesGrid` reused unmodified** (key `privileges_table`) driven by `UserProfileFormState.privileges`; `RecordFormActions` in the standard three modes with `RecordDeleteConfirmation` (key `confirm_delete_user_profile`); errors via `ErrorBanner` using the `error`/`errorDetail` pair (contracts/user-profile-screens.md §2). Depends on T014, T015, T016
- [X] T019 [US1] Wire the router: point the `/user-profiles`, `/user-profiles/new`, `/user-profiles/:profileId` routes in `lib/app/router/app_router.dart` at the real screens from T017/T018, replacing the T010 placeholders (contracts/routes.md §1). Depends on T017, T018
- [X] T020 [P] [US1] Widget test `test/widget/features/auth/user_profiles_list_screen_test.dart` — search/status filter round-trip through `ListQuery`, empty state reads "none yet" (not an error) when unfiltered vs. "no matches" when filtered, row tap navigates read-only, Edit row action navigates editable, New button hidden for a non-administrator. Depends on T017
- [X] T021 [P] [US1] Widget test `test/widget/features/auth/user_profile_detail_screen_test.dart` — create with required-name validation; a sparse profile (2 of ~110 objects granted) renders those two ticked and every other row unticked across all grid pages; edit persists a name + one permission change; delete confirmation blocks an accidental delete and a `409` referenced-conflict leaves the profile in place with the server's `detail` shown. Depends on T018

**Checkpoint**: The profile catalog is fully functional and independently testable — profiles can be authored and maintained with no user-side integration yet.

---

## Phase 4: User Story 2 - Provision an account from a profile (Priority: P1)

**Goal**: An administrator can choose a profile when creating a user, and apply a profile to an existing user via a confirmation that states the full-replace and session-invalidation consequences.

**Independent Test**: With a profile already in the catalog (US1), create a user naming it and confirm the new account's grid matches; then apply the same profile to an account with different permissions and confirm the same, including the confirmation and its consequences.

### Tests for User Story 2 ⚠️

- [X] T022 [P] [US2] Extend `test/unit/features/auth/users_controller_test.dart` — a create with `profileId` set issues **exactly one** `repo.create` call and **no** follow-up `repo.update` for privileges, even when the form's permission grid is non-empty (research.md §7 — quickstart.md's top-risk test #3, the single most damaging slip in this feature); a create with no profile behaves exactly as today (unchanged existing test must still pass)
- [X] T023 [P] [US2] Unit test (new file) `test/unit/features/auth/user_form_apply_profile_test.dart` — `UserFormController.applyProfile` **replaces** form privileges/status/administrator/profileId/profileName wholesale from the returned `User` rather than merging with prior state, on success invalidates `usersControllerProvider`, and on failure (404 missing profile, 409 inactive profile) leaves prior state untouched (quickstart.md's top-risk test #2)

### Implementation for User Story 2

- [X] T024 [US2] Add `profileId: int?` and `profileName: String` fields to `UserFormState`, and `UserFormErrorCode.applyFailed`/`profileInactive` constants, in `lib/features/auth/presentation/admin/users_controller.dart`. Add `profileSelected(int? id, String displayText)` (mirrors `employeeSelected`, clearing `profileId`/`profileName` when `id` is `null`) and `Future<void> applyProfile({required String userId, required int profileId})` — on success, **replace** `state` from the returned `User` (privileges, status, administrator, profileId, profileName) and `ref.invalidate(usersControllerProvider)`; on failure, set `error`/`errorDetail` only (research.md §6, data-model.md §4). Depends on T007 (Foundational)
- [X] T025 [US2] In `UserFormController.save()` (same file), pass `state.profileId` onto `repo.create(...)` in create mode, and **skip the existing follow-up privileges `PUT`** entirely whenever `state.profileId != null` (research.md §7). The follow-up `PUT` still runs exactly as today when no profile was chosen. Depends on T024, T022 (test must exist and fail first)
- [X] T026 [P] [US2] Add the "Provisioning" localization keys to both `.arb` files (contracts/user-profile-screens.md §5): `userProfilePickerFieldLabel`, apply-button/dialog keys (`applyProfileButtonLabel`, `applyProfileDialogTitle`, `applyProfileReplaceWarning`, `applyProfileSessionWarning`, `applyProfileSelfWarning`, `applyProfileCancelLabel`, `applyProfileConfirmLabel`, `applyProfileSuccessMessage`), `userFormApplyFailedError`, `userFormProfileInactiveError`. Run `flutter gen-l10n` after editing
- [X] T027 [US2] In `lib/features/auth/presentation/admin/user_detail_screen.dart`, add the profile picker (key `user_profile_picker`, `CatalogEntityPicker<UserProfileSummary>` querying `status: EntityStatus.active` via `userProfileRepositoryProvider`) visible only in create mode (`!_isEdit`) to administrators; selecting a profile hides the `PrivilegesGrid` for the remainder of this create session, clearing the selection restores it (contracts/user-profile-screens.md §3a). An empty profile catalog renders the "no profiles yet" message (T016) rather than an empty dropdown. Depends on T024, T026
- [X] T028 [US2] Create `lib/features/auth/presentation/admin/apply_profile_dialog.dart` — a dialog (key `apply_profile_dialog`) with a `CatalogEntityPicker<UserProfileSummary>` (key `apply_profile_picker`, `status: active`), the two mandatory consequence strings as separate widgets (keys `apply_profile_replace_warning`, `apply_profile_session_warning`), a conditional self-apply warning (key `apply_profile_self_warning`, shown only when the target `userId` equals the signed-in user's `userId`), Cancel (key `apply_profile_cancel`, dismisses with no side effect) and Confirm (key `apply_profile_confirm`, disabled until a profile is picked, calls `UserFormController.applyProfile`) (contracts/user-profile-screens.md §3c). Depends on T024, T026
- [X] T029 [US2] In `user_detail_screen.dart`, add the Apply Profile button (key `apply_profile_button`, `OutlinedButton` in the form body alongside `RecordFormActions`, never in `AppBar.actions` — constitution §VI) visible only when `_isEdit && !readOnly && accessControl.isAdministrator`, opening the T028 dialog; add the read-only origin line (labelled as "provisioned from", never as current permissions) rendered whenever `profileName` is non-null, in both edit and view modes. On the dialog's successful confirm, show a success `SnackBar` (`applyProfileSuccessMessage`) and do **not** issue any additional user re-fetch — the self-apply case relies on the existing auth interceptor's `401` → `/auth/login` redirect on the *next* request, not on this screen detecting anything (research.md §6, FR-024). Depends on T027, T028
- [X] T030 [P] [US2] Extend `test/widget/features/auth/user_detail_screen_test.dart` — the profile picker appears only in create mode and hides the grid when a profile is selected; the apply button appears only in edit mode for an administrator and is absent in view mode; the apply dialog renders both consequence strings and, only when applying to the signed-in user's own account, the self-apply warning; confirming updates the displayed permissions and origin without a manual reload; cancelling sends nothing (quickstart.md's top-risk test #5). Depends on T027, T028, T029

**Checkpoint**: Users can be provisioned from a profile at creation, and provisioned/re-provisioned via apply on an existing account — the two P1 stories together are the feature's whole MVP.

---

## Phase 5: User Story 3 - Find and re-provision the accounts a profile produced (Priority: P2)

**Goal**: The users list shows each account's origin profile and can be filtered to exactly the accounts a given profile produced.

**Independent Test**: Provision two accounts from the same profile (US2), confirm both rows show it, filter the list by it and confirm exactly those two are listed, edit the profile and confirm neither account changes until re-applied.

### Tests for User Story 3 ⚠️

- [X] T031 [P] [US3] Extend `test/unit/features/auth/users_controller_test.dart` — `UserFilter.fromQuery` decodes the `profile` facet into `profileId`; `activeFilterCount` counts both `status` and `profileId` when set; `UsersController._fetch` passes `filter.profileId` onto `repo.list(profileId: ...)`

### Implementation for User Story 3

- [X] T032 [US3] Add `profileId: int?` to `UserFilter` in `lib/features/auth/presentation/admin/users_controller.dart`, decoded from the `profile` facet key (`UserFilter.fromQuery`); update `UserFilterBadge.activeFilterCount` to `(status != null ? 1 : 0) + (profileId != null ? 1 : 0)`; pass `filter.profileId` through to `repo.list(...)` in `UsersController._fetch` (data-model.md §3, research.md §8). Depends on T008 (Foundational), T031
- [X] T033 [P] [US3] Create `userProfileNameProvider(int profileId)` — a small `FutureProvider.family` resolving a profile id to its display name via `userProfileRepositoryProvider.get`, falling back to the raw id while loading, mirroring `employeeDisplayNameProvider`'s existing pattern (research.md §8). Place it alongside `UsersController` in `users_controller.dart`
- [X] T034 [US3] Add a Profile column to `UsersListScreen`'s `DataTableView` in `lib/features/auth/presentation/admin/users_list_screen.dart`, between Admin and Status, rendering `u.profileName ?? ''` (FR-027); add a profile filter to the `_UserFiltersPanel` (key `users_filter_profile`, `CatalogEntityPicker<UserProfileSummary>` querying the full catalog, `initialDisplayText` resolved via T033), writing `query.withFacet('profile', '$id')` and clearing via `withFacet('profile', null)` — insert this facet **after** the existing `status` facet in canonical order (contracts/user-profile-screens.md §4, research.md §8). Both the column and the filter render for every user who can reach `/users`; the filter's picker is simply omitted for a non-administrator target audience note: the picker itself calls an administrator-only endpoint, so gate its visibility on `accessControl.isAdministrator` alongside the existing filter panel, never shown-and-failing. Depends on T032, T033
- [X] T035 [P] [US3] Add the origin-provenance framing to the T029 origin line if not already covered: confirm the wording never implies live sync (FR-030) — this is a copy check against T029's existing string, not new code; adjust `lib/l10n/app_en.arb`/`app_es.arb` only if the review finds drift
- [X] T036 [P] [US3] Extend `test/widget/features/auth/users_list_screen_test.dart` — the profile column renders `profileName` and renders blank for an account with none; the profile filter narrows the list and round-trips through the URL (`?profile=<id>`) surviving a simulated reload; clearing filters removes it alongside status

**Checkpoint**: All three user stories are independently functional. A profile's provenance is now fully traceable from the users list.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final gate-visibility proof, localization parity, and the quickstart walkthrough.

- [X] T037 [P] Extend `test/unit/app/router/app_router_test.dart` (if not already fully covered by T011) — a non-administrator holding `SystemObject.users` + `AccessRight.read` is redirected away from `/user-profiles`, `/user-profiles/new` and `/user-profiles/:id`; an administrator is allowed; `AppShell.navigationShell.currentIndex == NavBranch.userProfiles` after navigating there
- [X] T038 [P] Extend `test/unit/features/auth/access_control_test.dart` if it asserts on route-adjacent gating today — otherwise confirm `AccessControlService.isAdministrator` already has coverage and this task is a no-op verification
- [X] T039 Run `flutter test test/unit/core/l10n_parity_test.dart` and fix any key present in one `.arb` file but not the other, across every key added in T015/T016/T026
- [ ] T040 Run the full quickstart.md manual walkthrough (sections A–E) against a live mbe-api instance, in order, ending with the self-apply case (E) last as the guide specifies — confirms SC-001 through SC-009 end to end. **Not run in this implementation session** — requires a live mbe-api instance (migration 014_user_profiles.sql applied) plus interactive `flutter run` clicking, which this session has no access to. Left for the user to run per quickstart.md.
- [X] T041 `flutter analyze` clean and `flutter test` green for the whole suite (not just this feature's new files) — confirms SC-008, that nothing changed for accounts never touched by a profile

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately
- **Foundational (Phase 2)**: Depends on Setup — BLOCKS all user stories
- **User Story 1 (Phase 3)**: Depends on Foundational only
- **User Story 2 (Phase 4)**: Depends on Foundational; its apply half needs at least one profile to exist, which is a **runtime data dependency** (create one via US1's screens or directly via the repository in a test), not a code dependency — T022–T030 do not import anything from Phase 3's screen files
- **User Story 3 (Phase 5)**: Depends on Foundational for the repository; its manual walkthrough needs US2's apply to have run at least once to have something to filter, but its code (T032–T036) has no import dependency on Phase 4's files either
- **Polish (Phase 6)**: Depends on all three stories being complete

### User Story Dependencies

- **US1 (P1)**: No dependencies on US2/US3 — a complete, shippable slice on its own (an administrator can author and maintain profiles with nothing yet consuming them)
- **US2 (P1)**: Independently testable given Foundational + at least one profile row (creatable via direct repository call in a test, without US1's UI)
- **US3 (P2)**: Independently testable given Foundational + at least one provisioned account (creatable via US2, or via a fake repository in tests)

### Within Each User Story

- Tests written and expected to fail before implementation
- Controllers/state before screens
- Screens before router wiring
- Story complete before moving to the next priority

### Parallel Opportunities

- T003–T005 (domain entities) run in parallel — different files
- T012–T013 (US1 tests) run in parallel
- T015–T016 (l10n) run in parallel with each other and with T014
- T020–T021 (US1 widget tests) run in parallel once their screens exist
- T022–T023 (US2 tests) run in parallel
- T026 (l10n) runs in parallel with T024–T025
- T031 (US3 test) can start as soon as Foundational is done, in parallel with all of US1/US2
- T037–T038 (Polish tests) run in parallel

---

## Parallel Example: User Story 1

```bash
# Launch both US1 test files together:
Task: "Unit test user_profile_repository_impl_test.dart"
Task: "Unit test user_profiles_controller_test.dart"

# Launch both l10n edits together, in parallel with the controller:
Task: "Add profile catalog l10n keys to app_en.arb/app_es.arb"
Task: "Add empty-state/picker l10n keys to app_en.arb/app_es.arb"
```

---

## Implementation Strategy

### MVP First (User Stories 1 + 2)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL — blocks everything)
3. Complete Phase 3: User Story 1 — the catalog exists
4. Complete Phase 4: User Story 2 — provisioning works
5. **STOP and VALIDATE**: run quickstart.md sections A–B independently
6. Deploy/demo if ready — this is the feature's actual MVP per the spec (a catalog with nothing to apply it to is inert; both P1s together are the minimum shippable whole)

### Incremental Delivery

1. Setup + Foundational → foundation ready
2. Add US1 → validate independently (author profiles, nothing consumes them yet)
3. Add US2 → validate independently (provisioning, including the confirmation and self-apply) → this is the MVP
4. Add US3 → validate independently (origin visibility and filtering)
5. Polish → full quickstart walkthrough, l10n parity, analyze/test clean

### Parallel Team Strategy

With multiple developers, once Foundational (Phase 2) is done:

- Developer A: User Story 1 (catalog screens)
- Developer B: User Story 2 (apply flow) — needs only a profile row seeded via the repository directly, not US1's finished UI
- Developer C: User Story 3 (list column + filter) — needs only a provisioned account, seedable the same way

---

## Notes

- [P] tasks touch different files with no unfinished dependency between them
- [Story] labels trace every task back to its user story
- `PrivilegesGrid` is never edited — every task that needs the permission grid reuses it as-is
- The two riskiest single lines in this feature are T025's "skip the follow-up PUT when a profile was chosen" and T024's "replace, never merge" — both have a dedicated failing-first test (T022, T023) before the implementation task that fixes them
- Commit after each task or logical group
- Stop at either Phase 3 or Phase 4's checkpoint to validate independently before continuing
