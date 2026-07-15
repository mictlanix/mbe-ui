# Implementation Plan: Adaptive Navigation Layout

**Branch**: `010-adaptive-navigation-layout` | **Date**: 2026-07-14 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/010-adaptive-navigation-layout/spec.md`

## Summary

Wrap all authenticated destinations in a shared **navigation shell** that owns a single app bar and adaptive primary navigation: a persistent rail-style side navigation at the Medium tier and wider (≥ 600 px), and a `NavigationDrawer` on the Compact tier (< 600 px). Navigation is built from a declarative, access-gated destination/group model supporting one level of grouping (e.g. **Catalogs → Users, Products**). The app bar's trailing area is reduced to a single user-menu control (identity, current store/POS/cash-drawer context resolved to names, Change Password, Logout). Home becomes a branded welcome screen sourced from a build-time **brand/flavor config** with a bundled default placeholder. Catalog list screens drop their app-bar action icons; Add (emphasised as primary) and Merge move beside the search bar via a shared action slot on `CatalogFilterBar`.

The current location (store/POS/cash drawer) is read from the caller's own `/auth/me` session data — not the catalog APIs — so every user sees their location regardless of catalog RBAC; showing **names** (vs. ids) depends on an mbe-api enrichment of `/auth/me`, filed as an external dependency, with a labeled-ID fallback until it ships.

Technical approach: a `go_router` `StatefulShellRoute.indexedStack` with one branch per top-level destination hosts the shell and preserves per-branch list state; detail/form routes remain full-screen sibling routes. All new structural widgets (`AppShell`, `AppNavigation`, `UserMenuButton`, `HomeWelcome`) live in `core/widgets/` per the shared-widget constitution rule; the destination model and brand config live in `core/`.

## Technical Context

**Language/Version**: Dart 3.10.x / Flutter (stable, Material 3)

**Primary Dependencies**: `flutter_riverpod` + `riverpod_annotation` (state/DI), `go_router` ^17.3 (routing/shell), `freezed` (immutable models), `flutter_localizations` + `intl` (`es-MX`). No new package dependencies required.

**Storage**: N/A (no persistence added, and **no new network calls** — location context comes from the existing `/auth/me` session data already loaded at login). Brand config is build-time via `--dart-define`; existing `shared_preferences` theme mode unchanged.

**Testing**: `flutter_test` (widget tests for shell/navigation/user-menu/home/action-bar), `mocktail` for provider overrides, existing `integration_test` harness for the login → navigate golden path.

**Target Platform**: Desktop/web-first (Expanded tier), Compact tier now exercised for the drawer branch.

**Project Type**: Single Flutter application (`lib/features/*` + shared `lib/core`, `lib/app`).

**Performance Goals**: 60 fps navigation transitions; no extra network calls introduced by the shell (navigation/user-menu render from already-loaded session state).

**Constraints**: Material 3 only (no Cupertino); no horizontal overflow of the app bar / search-bar action row at any supported width; forbidden destinations/actions hidden (not disabled); no offline/caching layers.

**Scale/Scope**: 3 top-level destinations today (Home, Users, Products) with one group; model must accommodate the full legacy menu tree (13+ groups) as features ship. ~5 new shared widgets, 1 router refactor, edits to 3 existing screens (home, products list, users list). One external mbe-api dependency (enrich `/auth/me` settings with location names) — the menu ships with labeled-ID fallback until it lands.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **I. Feature-First Layered Architecture** — PASS. Structural/shared UI (shell, navigation, user menu, home welcome, brand config) is cross-feature and lives in `core/` (`core/widgets`, `core/layout`, `core/branding`), not inside a single feature. Home welcome content rendering stays under `features/home`. No `presentation → data` imports introduced.
- **II. Riverpod for State/DI** — PASS. Navigation destinations, brand config, and the router are exposed as providers; navigation visibility derives from the existing `accessControlProvider`; user identity/settings read from `authNotifierProvider`. No new DI framework.
- **III. Contract-Driven API Integration** — PASS, **with one external mbe-api dependency** (recorded below and in research §3). The user menu sources the current location's names from the caller's **own** profile via `GET /api/v1/auth/me` (`AuthApi.getMeApiV1AuthMeGet` → `UserResponse.settings`) — own-data, so no per-catalog RBAC and no extra network calls. Today `UserSettingsResponse` carries only `store_id` / `point_sale_id` / `cash_drawer_id`; showing **names** requires enriching that response with the store/POS/cash-drawer `name` (+`code`). Per the §III repo-boundary rule this is **filed as an mbe-api issue, not patched here**; until it ships the menu renders the labeled-ID fallback from the ids already present. When it ships: re-run codegen, extend the `UserSettings` domain entity mapping, and the menu's display helper prefers the name. No client-side catalog fetch is introduced (the earlier `master_data` resolution slice is dropped). Employee display name on the identity line remains a separate deferred enhancement (email is used now).
- **IV. Deny-by-Default RBAC** — PASS. Every navigation destination carries a `(SystemObject, AccessRight.read)` gate and is hidden via `can(...)`; groups with no visible children are hidden; relocated Add/Merge keep their existing `can(create)` gating. Router redirect guards are unchanged. Location names come from own-profile `/auth/me` data, so **no catalog-object RBAC is involved** — every signed-in user sees their own location regardless of `stores`/`pointsOfSale`/`cashDrawers` privileges (which is why `/auth/me` is preferred over the catalog APIs).
- **V. Material 3, White-Labeled Design System** — PASS, and directly advances it: introduces the first build-time **brand/flavor config** (`--dart-define`) for the welcome asset + display name, with light/dark unaffected and `es-MX` labels via `.arb`. No brand tokens hardcoded in `app/theme/`.
- **VI. Desktop/Web-First, Compact-Ready Layout** — PASS, and advances it: persistent side navigation is exactly this principle's mandate; breakpoints reuse `core/layout/breakpoints.dart`; new shared widgets live in `core/widgets/`. Catalog row actions (Edit-only) and whole-row read-only click are untouched; Create stays a toolbar action, merely relocated from the app bar to the filter/search action row (still not a row action).
- **VII. Online-Only** — PASS. No offline/caching/local-sync added.

**Result**: No violations. Complexity Tracking not required.

## Project Structure

### Documentation (this feature)

```text
specs/010-adaptive-navigation-layout/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output (UI/widget + config contracts)
│   ├── navigation-shell.md
│   ├── app-navigation.md
│   ├── user-menu.md
│   ├── home-welcome.md
│   ├── catalog-action-slot.md
│   └── brand-config.md
└── tasks.md             # Phase 2 output (/speckit-tasks — NOT created here)
```

### Source Code (repository root)

```text
lib/
├── app/
│   ├── app.dart                      # unchanged (MaterialApp.router)
│   └── router/
│       └── app_router.dart           # EDIT: wrap destinations in StatefulShellRoute
├── core/
│   ├── access/
│   │   └── user_settings.dart        # (later) gains name/code when /auth/me is enriched (blocked on mbe-api)
│   ├── layout/
│   │   └── breakpoints.dart          # reuse (rail ≥ compact 600; drawer < 600)
│   ├── branding/                     # NEW
│   │   ├── brand_config.dart         # BrandConfig (freezed) + build-time source
│   │   └── brand_config_provider.dart# Riverpod provider exposing active BrandConfig
│   ├── navigation/                   # NEW
│   │   ├── nav_destination.dart      # NavDestination / NavGroup / NavItem model
│   │   └── nav_destinations.dart     # provider: access-filtered destination tree
│   └── widgets/
│       ├── app_shell.dart            # NEW: Scaffold + app bar + adaptive nav + body
│       ├── app_navigation.dart       # NEW: rail-style side nav (≥600) / NavigationDrawer (<600)
│       ├── user_menu_button.dart     # NEW: single trailing user menu
│       └── catalog_filter_bar.dart   # EDIT: add trailing `actions` slot (primary Add)
├── features/
│   ├── home/presentation/
│   │   ├── home_screen.dart          # EDIT: becomes body-only branded welcome
│   │   └── home_welcome.dart         # NEW: welcome image/message + placeholder fallback
│   ├── auth/presentation/admin/
│   │   └── users_list_screen.dart    # EDIT: drop Scaffold/AppBar+actions; Add → filter bar
│   └── catalog/presentation/
│       └── products_list_screen.dart # EDIT: drop Scaffold/AppBar+actions; Add/Merge → filter bar
├── l10n/
│   ├── app_es.arb                    # EDIT: nav group/labels, user-menu, welcome strings
│   └── app_en.arb                    # EDIT: same keys
assets/
└── branding/
    └── default_welcome.png           # NEW: bundled default placeholder (pubspec assets entry)
test/
├── widget/core/widgets/
│   ├── app_shell_test.dart           # NEW
│   ├── app_navigation_test.dart      # NEW
│   ├── user_menu_button_test.dart    # NEW
│   └── catalog_filter_bar_test.dart  # EDIT: actions slot
├── widget/features/
│   ├── home_welcome_test.dart        # NEW
│   ├── catalog/products_list_screen_test.dart  # EDIT: actions moved
│   └── auth/users_list_screen_test.dart        # NEW/EDIT: Add moved
└── integration/
    └── navigation_shell_flow_test.dart # NEW: login → rail/drawer navigate
```

**Structure Decision**: Single Flutter app. All structural navigation UI is shared and therefore lives under `lib/core/` (widgets, plus new `core/navigation` and `core/branding` modules), consistent with Principle VI's "shared widgets live in `core/widgets/`" and Principle I's shared-kernel rule. The router in `lib/app/router` is the only `app/`-level edit; feature screens shrink to bodies.

## Complexity Tracking

> No constitution violations — table intentionally empty.

## External Dependencies

| Dependency | Why needed | Handling (Principle III) |
|---|---|---|
| **mbe-api: enrich `/auth/me` settings with location names** — add `name` (+`code`) for store / point of sale / cash drawer to `UserSettingsResponse` (e.g. nested `{ id, code, name }` objects, or `*_name`/`*_code` fields) — tracked as **[mictlanix/mbe-api#79](https://github.com/mictlanix/mbe-api/issues/79)** | The user menu must show human-readable store/POS/cash-drawer for **every** signed-in user, including those without catalog RBAC. `/auth/me` is own-data (no catalog permission needed); it currently returns only the ids. | **Filed** as mbe-api#79 (not patched from this session). Ship the menu now with the labeled-ID fallback from the existing ids. When the change lands: re-run OpenAPI codegen, extend the `UserSettings` domain mapping, and the menu's display helper (already written to prefer name, fall back to id) shows names with no further UI change. |

**mbe-api dependency:** [mictlanix/mbe-api#79](https://github.com/mictlanix/mbe-api/issues/79) — *"Include store / point-of-sale / cash-drawer display names in `GET /api/v1/auth/me`"*: add resolved `name` and `code` for the caller's `store_id` / `point_sale_id` / `cash_drawer_id` to `UserSettingsResponse`, so clients can display the current location without requiring `stores`/`points_of_sale`/`cash_drawers` read privileges.
