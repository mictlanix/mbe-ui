# Implementation Plan: User Profiles as Permission Templates

**Branch**: `024-user-profiles` | **Date**: 2026-08-14 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/024-user-profiles/spec.md`

## Summary

Surface mbe-api's user profiles — reusable permission templates — in mbe-ui: an
administrator-only catalog at `/user-profiles` where profiles are authored and
maintained, a profile choice when creating a user, an Apply Profile action on an
existing user with a confirmation that states its two consequences, and an origin
column plus filter on the users list.

The technical approach is **reuse, not construction**. Every major piece already
exists: `PrivilegesGrid` renders the permission matrix and needs no change,
`Privilege` already models a mask, `CatalogEntityPicker` is the picker, the
shared catalog widgets are the list, `RecordFormActions` is the action area, and
`AccessControlService.isAdministrator` is the gate. The genuinely new code is one
repository, one controller pair, two screens, and a small widening of the router's
gate type from a `(SystemObject, AccessRight)` record to a two-case sealed type.

Three details carry most of the risk and are pinned in the design artifacts:
a create-with-profile must **not** be followed by the existing privileges `PUT`
(research §7); an apply must **replace** form state from the response, never merge
(data-model §4); and profiles are **sparse** on the wire while the grid is full
(research §4).

## Technical Context

**Language/Version**: Dart 3.10.3+ / Flutter stable

**Primary Dependencies**: `flutter_riverpod` + `riverpod_annotation` (state and
DI), `go_router` (navigation), `freezed` (domain entities and view state), `dio`
via the generated `mbe_api_client` (`lib/generated/openapi/`), `data_table_2`
(tables), `flutter_localizations` + `intl` (l10n)

**Storage**: N/A — server-owned. No local persistence; `flutter_secure_storage`
holds only the existing session token.

**Testing**: `flutter_test` — unit tests for repository and controllers (API
client mocked), widget tests for the two new screens and the three additions to
existing ones, plus the router gate test

**Target Platform**: Web (Chrome) and desktop, per the app's desktop/web-first
posture

**Project Type**: Flutter application, feature-first layered

**Performance Goals**: No new goals. The catalog list paginates server-side at 20
rows like every other list; the permission grid paginates client-side at 10 rows
over the fixed `SystemObject.values`, as it already does on the user form.

**Constraints**: Online-only. Administrator-only server-side, so every entry
point must be hidden rather than shown-and-refused. No new pub dependencies.

**Scale/Scope**: 2 new screens, 1 new repository, 1 new controller file, ~110
`SystemObject` rows per grid, ~35 new localization keys in each of 2 locales

## Constitution Check

*GATE: evaluated before Phase 0 and re-evaluated after Phase 1 design.*

| Principle | Status | Notes |
|---|---|---|
| **I. Feature-First Layered Architecture** | PASS | All new code under `lib/features/auth/{domain,data,presentation}`. `presentation` imports `domain` only; the repository provider lives in `data/` and is read through Riverpod, matching the existing `userRepositoryProvider` convention. No entity is redefined — `Privilege`, `SystemObject` and `EntityStatus` stay in the shared kernel. |
| **II. Riverpod for State Management & DI** | PASS | `UserProfilesController` (`AsyncNotifier` family over the filter) for the list; `UserProfileFormController` (plain `Notifier`) for the form; `userProfileRepositoryProvider` for DI so tests override it with a fake. No new DI mechanism. |
| **III. Contract-Driven API Integration** | PASS | All six profile calls and the three user-endpoint changes exist in the generated client (commit `4382f3a`); no hand-written DTOs. Generated DTOs are mapped to freezed entities in `domain/` before reaching `presentation/`. Errors funnel through the existing `AppError` types. No `multipart/form-data` involved, so the binary-upload caveat does not apply. **No mbe-api change is needed**, so the repo-boundary rule raises nothing to file. |
| **IV. Deny-by-Default RBAC** | **DEVIATION** | Profile routes gate on `isAdministrator`, not on `can(SystemObject, AccessRight)`, because mbe-api exposes no `SystemObject` for profiles. Justified in Complexity Tracking below. All *other* gating is unchanged, and the deviation is strictly narrowing. |
| **V. Material 3, White-Labeled Design System** | PASS | Material 3 components only; no hardcoded brand values; every new string in `app_en.arb` and `app_es.arb` with `es-MX` first-class. |
| **VI. Desktop/Web-First, Compact-Ready Layout** | PASS | The catalog list uses the shared `DataTableView` + `CatalogPage` (pagination implemented once), mandatory filtering via `CatalogFilterBar` + filter sheet, and the codified row-action set: whole-row tap opens read-only, one Edit row action, Delete on the detail screen. Detail screens keep `AppBar.actions` **empty**, with Edit/Save/Delete in `RecordFormActions` — including the new Apply Profile button, which is a body `OutlinedButton`, not an app-bar icon. Forms use `ResponsiveFormGrid`. |
| **VII. Online-Only, Server-Rendered Documents** | PASS | Not applicable — no documents, no offline behaviour. |

**Post-Phase-1 re-evaluation**: unchanged. The design added no new dependency,
no new shared widget, and no second way to do anything the app already does. The
§IV deviation is the only entry in Complexity Tracking, and Phase 1 narrowed it
further: the sealed gate type keeps every existing destination on the identical
`PrivilegeGate` path, so the change is additive rather than a rewrite of the
guard.

## Project Structure

### Documentation (this feature)

```text
specs/024-user-profiles/
├── plan.md              # This file
├── spec.md              # Feature specification
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
│   ├── mbe-api-user-profiles.md
│   ├── routes.md
│   └── user-profile-screens.md
├── checklists/
│   └── requirements.md
└── tasks.md             # Phase 2 output (/speckit-tasks — NOT created here)
```

### Source Code (repository root)

```text
lib/
├── app/router/
│   └── app_router.dart                          # M  branch, 3 routes, sealed gate
├── core/
│   ├── access/
│   │   ├── privilege.dart                       # M  fromProfileResponse, toProfileUpdate
│   │   └── user.dart                            # M  profileId/profileName on User + UserSummary
│   └── navigation/
│       ├── nav_destination.dart                 # M  NavGate → sealed RouteGate
│       └── nav_destinations.dart                # M  NavBranch.userProfiles, destination, _isVisible
├── features/auth/
│   ├── domain/
│   │   ├── entities/user_profile.dart           # +  UserProfile, UserProfileSummary
│   │   └── repositories/
│   │       ├── user_profile_repository.dart     # +  list/get/create/update/delete/apply
│   │       └── user_repository.dart             # M  profileId on create() and list()
│   ├── data/
│   │   ├── user_profile_repository_impl.dart    # +  UserProfilesApi + provider
│   │   └── user_repository_impl.dart            # M  pass profileId through
│   └── presentation/admin/
│       ├── user_profiles_controller.dart        # +  filter, list controller, form controller
│       ├── user_profiles_list_screen.dart       # +
│       ├── user_profile_detail_screen.dart      # +
│       ├── apply_profile_dialog.dart            # +  picker + consequences + confirm
│       ├── users_controller.dart                # M  UserFilter.profileId, applyProfile, form fields
│       ├── users_list_screen.dart               # M  profile column + profile facet
│       ├── user_detail_screen.dart              # M  picker, origin line, apply button
│       └── privileges_grid.dart                 #    UNCHANGED — reused as-is
└── l10n/
    ├── app_en.arb                               # M
    └── app_es.arb                               # M

test/
├── unit/
│   ├── app/router/app_router_test.dart          # M  administrator gate + branch index
│   └── features/auth/
│       ├── user_profile_repository_impl_test.dart   # +
│       ├── user_profiles_controller_test.dart       # +
│       └── users_controller_test.dart               # M  create-with-profile, applyProfile
└── widget/features/auth/
    ├── user_profiles_list_screen_test.dart      # +
    ├── user_profile_detail_screen_test.dart     # +
    ├── users_list_screen_test.dart              # M  column + filter
    └── user_detail_screen_test.dart             # M  picker, origin, apply dialog
```

`+` new · `M` modified. Generated siblings (`*.freezed.dart`, `*.g.dart`) are
produced by `build_runner` and not listed.

**Structure Decision**: the feature lives entirely in `lib/features/auth/`,
beside the user administration it extends, with only the router, navigation,
shared access entities and localizations touched outside it. Rationale in
research §1: a profile is made of `Privilege` values and applied to a `User`, so
placing it in `catalog/` would force `auth`'s presentation layer to import
another feature's domain for its core flow.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|---|---|---|
| **Constitution §IV**: `/user-profiles` gates on `AccessControlService.isAdministrator` rather than `can(SystemObject, AccessRight)`, widening the router's gate type to a two-case sealed type. | mbe-api gates every profile endpoint on the administrator flag and exposes **no `SystemObject`** for profiles, so the constitutional form cannot be expressed. `isAdministrator` already exists on `AccessControlService`; the change is one new gate case plus a two-arm switch in `_redirect` and `_isVisible`. | *Gate on `SystemObject.users` + read*: a non-administrator holding `users:read` would see the navigation entry and the screen, then be refused by every request — the dead end deny-by-default exists to prevent. *Invent a client-side `SystemObject.userProfiles`*: the enum mirrors mbe-api's catalog and `Privilege.fromResponse` drops unknown codes, so the row would appear in every permission grid while granting nothing anywhere. Note the deviation only ever **narrows** access: `can()` already returns `true` for administrators on every object, so nothing previously reachable becomes unreachable. |
