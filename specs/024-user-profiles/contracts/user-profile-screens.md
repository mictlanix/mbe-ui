# Contract: user profile screens and the user-screen additions

**Feature**: `024-user-profiles`

Widget-level contracts for the two new screens and the three additions to
existing ones. Keys are named because widget tests assert on them.

## 1. `UserProfilesListScreen` — `/user-profiles`

Body-only (the shell owns the `Scaffold`/app bar), mirroring
`UsersListScreen` structurally.

| Element | Key | Behaviour |
|---|---|---|
| Search box | `user_profiles_search_field` | `onSubmitted` → `query.copyWith(search:, pageIndex: 0)` |
| New button | `new_user_profile_button` | `context.push('/user-profiles/new')` |
| Filters button | `user_profiles_filter_button` | Opens the filter sheet; `Badge.count` from `activeFilterCount` |
| Status chips (in sheet) | `user_profiles_filter_status` | `EntityStatusFilterChips` → `query.withFacet('status', …)` |
| Table | `user_profiles_table` | `DataTableView<UserProfileSummary>` |

Columns: **Name** (`ColumnSize.M`) · **Description** (`ColumnSize.L`) ·
**Status** (`ColumnSize.S`, `EntityStatusCell`).

Row interactions, per constitution §VI: whole-row tap →
`/user-profiles/:id?view=true` (read-only); one row action, Edit →
`/user-profiles/:id`. Delete lives on the detail screen, never on the row.

Empty and error states come from `CatalogListStateView`, distinguishing an empty
catalog from an over-filtered one via `query.isFiltered` — this is what makes
FR-001's empty state read as "none yet" rather than "no matches".

## 2. `UserProfileDetailScreen` — `/user-profiles/new`, `/user-profiles/:id`

Owns its own `Scaffold` (full screen, no rail), as `UserDetailScreen` does.
`AppBar.actions` is **empty** (constitution §VI v1.10.0).

Fields, laid out in a `ResponsiveFormGrid`:

| Field | Key | Rules |
|---|---|---|
| Name | `user_profile_name_field` | Required (FR-006); trimmed |
| Description | `user_profile_description_field` | Optional, multiline |
| Status | `user_profile_status_field` | `EntityStatus` control; `active` default |
| Permissions | `privileges_table` | **`PrivilegesGrid`, unmodified** |

`PrivilegesGrid` is reused as-is: it already renders one row per
`SystemObject.values` and defaults a missing entry to `0`, so a sparse profile
renders correctly with no change (research.md §4). Read-only mode passes
`onChanged: null`, which the widget already supports.

Actions come from `RecordFormActions` with the standard three modes:

| Mode | Shown |
|---|---|
| `create` (`/new`) | Save |
| `view` (`?view=true`) | Edit |
| `edit` | Delete, Save |

Delete uses `RecordDeleteConfirmation` with profile-specific wording and
`confirmKey: Key('confirm_delete_user_profile')`.

Errors render through `ErrorBanner` using the `error` (localized code) +
`errorDetail` (raw server text) pair, exactly as `UserDetailScreen` does.

## 3. `UserDetailScreen` additions

### 3a. Profile picker — create mode only

| Element | Key | Behaviour |
|---|---|---|
| Picker | `user_profile_picker` | `CatalogEntityPicker<UserProfileSummary>` querying `status: active` |

- Rendered only when `!_isEdit` and `accessControl.isAdministrator`.
- Selecting a profile **hides the permissions grid** — the profile is the
  account's permission set, and a grid shown beside it would imply the two
  combine (research.md §7). Clearing the selection restores the grid.
- Empty catalog: the picker shows a "no profiles yet" message rather than an
  empty dropdown (FR-014 of US2's scenarios).

### 3b. Origin line — edit and view modes

A read-only field showing `profileName`, labelled as *provisioned from* — never
as the account's current permissions (FR-029, FR-030). Absent entirely when
`profileName == null`. No link, no "in sync" indicator, no comparison.

### 3c. Apply Profile action — edit mode only

An `OutlinedButton` in the form body (**not** `AppBar.actions`), key
`apply_profile_button`, rendered only when `_isEdit && !readOnly &&
accessControl.isAdministrator`.

Opens a dialog, key `apply_profile_dialog`:

| Element | Key | Notes |
|---|---|---|
| Picker | `apply_profile_picker` | `CatalogEntityPicker<UserProfileSummary>`, `status: active` |
| Consequence — replacement | `apply_profile_replace_warning` | "every permission this account holds will be replaced" |
| Consequence — sessions | `apply_profile_session_warning` | "the account's active sessions will end" |
| Self-apply warning | `apply_profile_self_warning` | Shown **only** when the target is the signed-in user |
| Cancel | `apply_profile_cancel` | Sends nothing (FR-021) |
| Confirm | `apply_profile_confirm` | Disabled until a profile is picked |

The three warnings are separate localization keys, so a widget test can assert
each of FR-020's two mandated statements independently.

**On confirm** → `UserFormController.applyProfile(profileId:, userId:)`:

1. Success: form state is **replaced** from the returned `User` — privileges,
   `profileId`, `profileName`, status, administrator flag — then
   `ref.invalidate(usersControllerProvider)`. A success `SnackBar` confirms
   (FR-022). No re-fetch of the user is issued.
2. Failure: `error` + `errorDetail` set, everything else untouched (FR-023).
3. Self-apply: no re-fetch and no error handling for the subsequent `401` — the
   existing auth interceptor redirects to `/auth/login` on the next request
   (FR-024).

## 4. `UsersListScreen` additions

| Addition | Key | Notes |
|---|---|---|
| Profile column | — | Between Admin and Status; `ColumnSize.M`; renders `profileName ?? ''` (FR-027) |
| Profile filter | `users_filter_profile` | `CatalogEntityPicker<UserProfileSummary>` in the filter sheet, below the status chips |

The filter writes `query.withFacet('profile', '$id')` and clears with
`withFacet('profile', null)`. A shared URL carries only the id, so the picker's
`initialDisplayText` resolves through `userProfileNameProvider(id)`, falling
back to the raw id while it loads — the pattern `cash_sessions_screen.dart`
already uses for its cashier facet.

Both the column and the filter render for every user who can reach `/users`.
The filter's picker calls an administrator-only endpoint, so for a
non-administrator it is omitted rather than shown-and-failing (FR-034).

## 5. Localization keys

All new copy lands in both `app_en.arb` and `app_es.arb` (FR-035). Groups:

- Catalog: menu title, screen titles (new/edit/view), column headers, search
  label, empty-state message, new-profile button, delete confirmation.
- Form: field labels, `nameRequired`, `nameConflict`, `loadFailed`,
  `saveFailed`, `deleteFailed`, `deleteReferenced`.
- Apply: button label, dialog title, the three warning strings, cancel/confirm
  labels, success message, `applyFailed`, `profileInactive`.
- Users screens: profile column header, profile filter label, "provisioned
  from" label, profile picker label, "no profiles yet" message.
