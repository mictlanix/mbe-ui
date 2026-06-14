# Implementation Plan: User Authentication & Access Control

**Branch**: `main` (no feature branch in use) | **Date**: 2026-06-14 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/001-user-authentication/spec.md`

## Summary

Build the sign-in flow, session lifecycle, and role-based access control (RBAC)
that every other mbe-ui module will depend on, plus self-service password
management and an admin Users screen (account CRUD + per-module permissions
grid). The API client and DTOs for `auth`/`users` are generated from
mbe-api's published OpenAPI spec (`dart-dio` generator) and mapped to
`freezed` domain entities. A session-scoped Riverpod `AuthNotifier` holds the
current user/token; a derived `AccessControlService` exposes
`can(SystemObject, AccessRight)`, used by `go_router` redirects/guards and by
shared widgets to show/hide actions. A `dio` interceptor attaches the bearer
token and treats any `401` as "session invalid" (no refresh endpoint exists —
re-login is the recovery path). This feature also stands up the cross-cutting
`core/` scaffolding (network client, error mapping, secure token storage,
theme/locale bootstrap, responsive breakpoints) that later features build on.

## Technical Context

**Language/Version**: Dart `^3.10.3` (per `pubspec.yaml`), Flutter stable
channel matching that SDK constraint.

**Primary Dependencies**: `flutter_riverpod` + `riverpod_annotation` /
`riverpod_generator` (state & DI), `go_router` (navigation/guards), `dio`
(HTTP), `freezed` / `freezed_annotation` + `json_serializable` (immutable
domain entities), `flutter_secure_storage` (access-token storage),
`shared_preferences` (theme-mode persistence), `flutter_localizations` +
`intl` (es-MX). `openapi-generator-cli` (`dart-dio` generator) is a dev-time
codegen tool, not a pub dependency — its output is committed under
`lib/generated/openapi/`.

**Storage**: N/A — no local database/cache (constitution §VII, online-only).
`flutter_secure_storage` holds only the access token.

**Testing**: `flutter_test` for unit/widget tests, `mocktail` for
repository/dio fakes, `integration_test` for the login → RBAC-gated nav →
logout golden path (run against a local mbe-api instance).

**Target Platform**: Web, Windows, macOS, Linux — the Expanded (desktop/web)
layout tier per constitution §VI. Android/iOS remain scaffold-only.

**Project Type**: Single Flutter project, feature-first
(`lib/app`, `lib/core`, `lib/features/auth`).

**Performance Goals**: SC-001 — sign-in to a screen reflecting permitted
modules within 5s under normal network conditions.

**Constraints**: 8-hour JWT (`JWT_ACCESS_TOKEN_EXPIRE_MINUTES=480` on
mbe-api), no refresh endpoint — any `401` ends the session client-side;
`session_version` is mbe-api's server-side revocation mechanism; deny-by-default
RBAC (no privilege row ⇒ no access); fully online, no offline reads/writes.

**Scale/Scope**: ~6 screens (login, change password, forgot/recover password,
admin Users list, user detail/edit incl. permissions grid, create user) plus
the shared session/RBAC/network/error/theme/locale infrastructure every later
feature (sales, inventory, invoicing, accounting) will reuse.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|---|---|---|
| I. Feature-First Layered Architecture | ✅ PASS | `lib/features/auth/{data,domain,presentation}`. `User`/`Privilege`/`SystemObject`/`AccessRight` are placed in `core/` (not `features/auth/domain`) because every feature consumes them — consistent with the "shared kernel" carve-out in DESIGN.md §5 and Principle I. |
| II. Riverpod for State & DI | ✅ PASS | `AuthNotifier` (`AsyncNotifier<AuthState>`) for session; derived `accessControlProvider` for `can()`; plain `Notifier`s for login/password/user-form state. |
| III. Contract-Driven API Integration | ✅ PASS | `dart-dio` client generated from mbe-api's `/openapi.json` (`auth`, `users` paths — confirmed live, see research.md). `dio` interceptor for bearer token + 401 handling. Errors mapped to `ValidationError`/`NotFoundError`/`AuthError`/`ServerError`/`NetworkError`. |
| IV. Deny-by-Default RBAC | ✅ PASS | This feature introduces the `SystemObject`/`AccessRight` enums and `can()` provider that Principle IV requires; `Users = 92` gates the admin screens this feature adds. |
| V. Material 3 White-Labeled Design System | ✅ PASS (scoped) | Establishes `ColorScheme.fromSeed` theme + Light/Dark/System toggle with a single default seed. Per-deployment flavor wiring (multiple seeds/brand assets) is out of scope for this feature — tracked as future work, not a violation (only one deployment exists today). |
| VI. Desktop/Web-First, Compact-Ready Layout | ✅ PASS | Login is a centered single-column form (works at any width); admin Users list+detail uses the Expanded two-pane layout; `core/layout` breakpoints introduced here for reuse. |
| VII. Online-Only, Server-Rendered Documents | ✅ PASS | No local persistence beyond the secure token and theme-mode preference. No PDF generation in this feature. |

No violations — Complexity Tracking table not required.

## Project Structure

### Documentation (this feature)

```text
specs/001-user-authentication/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md         # Phase 1 output
├── quickstart.md         # Phase 1 output
├── contracts/            # Phase 1 output
│   ├── mbe-api-auth-users.md
│   ├── access_control.md
│   └── routes.md
└── tasks.md              # Phase 2 output (/speckit-tasks - not created here)
```

### Source Code (repository root)

```text
lib/
├── main.dart
├── app/
│   ├── app.dart                 # MaterialApp.router, theme, locale wiring
│   ├── router/
│   │   └── app_router.dart      # go_router config, auth redirect guard
│   └── theme/
│       └── app_theme.dart       # ColorScheme.fromSeed (light/dark), ThemeMode provider
├── core/
│   ├── network/
│   │   ├── dio_client.dart      # dio instance + provider
│   │   └── auth_interceptor.dart# attaches bearer token, handles 401
│   ├── errors/
│   │   └── app_error.dart       # ValidationError/NotFoundError/AuthError/ServerError/NetworkError
│   ├── access/
│   │   ├── system_object.dart   # SystemObject enum (mirrors mbe-api/legacy codes)
│   │   ├── access_right.dart    # AccessRight flags (Create/Read/Update/Delete)
│   │   └── access_control.dart  # can(SystemObject, AccessRight) provider
│   ├── storage/
│   │   └── token_storage.dart   # flutter_secure_storage wrapper
│   ├── layout/
│   │   └── breakpoints.dart     # centralized LayoutBuilder breakpoints
│   └── widgets/
│       └── error_banner.dart    # shared error-display widget
├── generated/
│   └── openapi/                 # openapi-generator (dart-dio) output — auth + users APIs/models
└── features/
    └── auth/
        ├── data/
        │   ├── auth_repository_impl.dart
        │   └── user_repository_impl.dart
        ├── domain/
        │   ├── entities/
        │   │   ├── auth_session.dart   # freezed: AuthState (unauthenticated/authenticating/authenticated/error)
        │   │   ├── user.dart            # freezed: User, UserSummary, UserSettings
        │   │   └── privilege.dart       # freezed: Privilege
        │   └── repositories/
        │       ├── auth_repository.dart # interface
        │       └── user_repository.dart # interface
        └── presentation/
            ├── session/
            │   └── auth_notifier.dart   # AsyncNotifier<AuthState>
            ├── login/
            │   ├── login_screen.dart
            │   └── login_controller.dart
            ├── account/
            │   ├── change_password_screen.dart
            │   ├── forgot_password_screen.dart
            │   └── account_controller.dart
            └── admin/
                ├── users_list_screen.dart
                ├── user_detail_screen.dart
                ├── privileges_grid.dart
                └── users_controller.dart

test/
├── unit/
│   └── features/auth/           # domain + repository + notifier tests (mocktail)
├── widget/
│   ├── core/                    # error_banner, breakpoints
│   └── features/auth/           # login, change password, users admin screens
└── integration/
    └── auth_flow_test.dart       # login → RBAC-gated nav → logout
```

**Structure Decision**: Single Flutter project, feature-first layout per
constitution §I. This feature creates the `app/` and `core/` scaffolding
(network, errors, access control, storage, layout, widgets) alongside its own
`lib/features/auth/`, since these are the cross-cutting foundations every
later feature (`sales`, `inventory`, `invoicing`, `accounting`) will depend
on. No web/backend split or mobile-specific structure is needed — Android/iOS
scaffolds remain untouched per DESIGN.md §1.

## Complexity Tracking

*No constitution violations — this section is intentionally empty.*
