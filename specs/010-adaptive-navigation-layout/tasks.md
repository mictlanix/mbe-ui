---
description: "Task list for Adaptive Navigation Layout"
---

# Tasks: Adaptive Navigation Layout

**Input**: Design documents from `/specs/010-adaptive-navigation-layout/`

**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/](./contracts/)

**Tests**: Included — the constitution's Development Workflow requires widget tests for `core/widgets/` + critical screens and an integration golden path, and each contract defines widget-test acceptance. Each story's tests can be written before or alongside its implementation.

**Organization**: Grouped by user story (spec.md priorities) for independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: US1–US4 map to the spec's user stories
- Every task lists an exact file path

## Path Conventions

Single Flutter app: source under `lib/`, tests under `test/`, per [plan.md](./plan.md) → *Project Structure*.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Bundled assets the feature needs.

- [X] T001 Add default welcome placeholder `assets/branding/default_welcome.png` and register `assets/branding/` under `flutter/assets` in `pubspec.yaml`; run `flutter pub get`.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: The access-gated navigation model that the shell and its navigation widget both consume.

**⚠️ CRITICAL**: Blocks User Story 1 (and therefore the shell every other story renders in).

- [X] T002 [P] Create the navigation model — `NavItem` (sealed) with `NavDestination` and `NavGroup` (one-level grouping) — in `lib/core/navigation/nav_destination.dart`, per [data-model.md](./data-model.md).
- [X] T003 Create the concrete destination tree (Home + `Catalogs → Users, Products`, each with its `(SystemObject, AccessRight.read)` gate and `branchIndex`) and the access-filtered `navDestinationsProvider` (watches `accessControlProvider`, hides forbidden destinations and empty groups) in `lib/core/navigation/nav_destinations.dart`; run `dart run build_runner build --delete-conflicting-outputs`. Depends on T002.

**Checkpoint**: Navigation model resolves the correct filtered tree per RBAC — user story work can begin.

---

## Phase 3: User Story 1 - Persistent, grouped navigation that adapts to screen size (Priority: P1) 🎯 MVP

**Goal**: A shared shell hosting an adaptive primary navigation — persistent rail at ≥ 600 px, `NavigationDrawer` below — with one level of grouping, gated by access, on every authenticated screen.

**Independent Test**: Sign in on a wide window → grouped rail lists permitted destinations and switches sections in one tap; narrow the window → same destinations via a drawer; forbidden destinations/empty groups never appear; no shell on `/auth/*`.

### Implementation for User Story 1

- [X] T004 [US1] Add navigation l10n keys (`homeMenuTitle` "Inicio"/"Home", `catalogsGroupTitle` "Catálogos"/"Catalogs"; reuse existing `usersMenuTitle`, `productsTitle`) in `lib/l10n/app_es.arb` and `lib/l10n/app_en.arb`; regenerate localizations.
- [X] T005 [P] [US1] Implement `AppNavigation` (rail mode ≥ 600 px / `NavigationDrawer` mode < 600 px from the same filtered tree, group section headers, selected-index highlight, `nav_dest_<id>` / `nav_group_<id>` keys) in `lib/core/widgets/app_navigation.dart`, per [contracts/app-navigation.md](./contracts/app-navigation.md). Depends on T003.
- [X] T006 [US1] Implement `AppShell` (Scaffold; app-bar title from active destination; Compact drawer + menu button vs. Medium+ persistent rail via `LayoutBreakpoints`; body = `navigationShell`; `goBranch` on select) in `lib/core/widgets/app_shell.dart`, per [contracts/navigation-shell.md](./contracts/navigation-shell.md). Depends on T005.
- [X] T007 [US1] Refactor the router to a `StatefulShellRoute.indexedStack` with 3 branches (`/`, `/users`, `/products`) built by `AppShell`, keeping detail/form/merge and all `/auth/*` routes as full-screen sibling routes; preserve existing redirect guard and route gates, in `lib/app/router/app_router.dart`. Depends on T006.
- [X] T008 [US1] Convert `HomeScreen`, `UsersListScreen`, `ProductsListScreen` to body-only (remove their own `Scaffold`/`AppBar`; title now supplied by the shell) in `lib/features/home/presentation/home_screen.dart`, `lib/features/auth/presentation/admin/users_list_screen.dart`, `lib/features/catalog/presentation/products_list_screen.dart`. (Catalog app-bar actions are relocated in US4; the temporary body keeps the existing list/table.) Depends on T007.
- [X] T009 [P] [US1] Widget test `AppNavigation` (grouped tree both modes; Products hidden without read; Catalogs header hidden when both children hidden; select fires `onDestinationSelected`; selected-index) in `test/widget/core/widgets/app_navigation_test.dart`.
- [X] T010 [P] [US1] Widget test `AppShell` (rail ≥ 1000 / drawer @ 500; title tracks active destination; `goBranch` on select) in `test/widget/core/widgets/app_shell_test.dart`.
- [X] T011 [US1] Integration test: login → shell shows rail; navigate Home/Users/Products; resize to drawer; `/auth/login` shows no shell, in `test/integration/navigation_shell_flow_test.dart`.

**Checkpoint**: Adaptive grouped navigation works end-to-end — MVP shell is usable.

---

## Phase 4: User Story 2 - Consolidated user menu in the app bar (Priority: P1)

**Goal**: Exactly one trailing app-bar control → a menu with identity, current store/POS/cash-drawer, Change Password, Logout.

**Independent Test**: Open the single trailing control on any destination → shows email + location lines (names when present, else "Store <ID>"/"POS <ID>"/"Drawer <ID>") + working Change Password and Logout; a user with no settings shows no location lines and no error.

### Implementation for User Story 2

- [X] T012 [US2] Add user-menu l10n keys (`userMenuLogout` "Salir"/"Logout"; fallback labels `userMenuStoreFallback` "Store {id}", `userMenuPosFallback` "POS {id}", `userMenuDrawerFallback` "Drawer {id}"; reuse `changePasswordMenuTitle`) in `lib/l10n/app_es.arb` and `lib/l10n/app_en.arb`; regenerate localizations.
- [X] T013 [US2] Implement `UserMenuButton` (single trigger `user_menu_button`; identity = `user.email`; store/POS/cash-drawer lines from `user.settings` with a display helper that prefers name `name (code)` and falls back to the labeled-ID keys — today ids-only, names arrive with mbe-api#79; omit a line whose id is null; Change Password → `/auth/account/password`; Logout → `signOut()`) in `lib/core/widgets/user_menu_button.dart`, per [contracts/user-menu.md](./contracts/user-menu.md). Add a `// TODO(mbe-api#79)` where names slot in.
- [X] T014 [US2] Wire `UserMenuButton` as the sole trailing `AppBar` action in `AppShell` (drawer menu button stays leading on Compact) in `lib/core/widgets/app_shell.dart`. Depends on T013, T006.
- [X] T015 [P] [US2] Widget test `UserMenuButton` (one trigger; names shown when settings carry them; labeled-ID fallback when only ids; `settings == null` omits location lines with no error; Change Password pushes route; Logout calls `signOut()`) in `test/widget/core/widgets/user_menu_button_test.dart`.

**Checkpoint**: App bar shows exactly one trailing control on every destination (SC-003); location shows fallback labels until mbe-api#79 ships.

---

## Phase 5: User Story 3 - Branded Home welcome screen (Priority: P2)

**Goal**: Home shows a per-flavor welcome image/message, with a default placeholder when unbranded.

**Independent Test**: Default build → placeholder + generic message; branded build (`--dart-define`) → configured asset + display name; a broken asset path falls back to the placeholder; no nav list on Home; no overflow at any width.

### Implementation for User Story 3

- [X] T016 [P] [US3] Implement `BrandConfig` (freezed; `displayName`, `welcomeAsset?`, `hasWelcomeAsset`; `BrandConfig.fromEnvironment()` from `--dart-define`) and `brandConfigProvider` (`keepAlive`) in `lib/core/branding/brand_config.dart` and `lib/core/branding/brand_config_provider.dart`; run `dart run build_runner build --delete-conflicting-outputs`, per [contracts/brand-config.md](./contracts/brand-config.md).
- [X] T017 [US3] Add `homeWelcomeMessage` l10n key (generic default welcome text) in `lib/l10n/app_es.arb` and `lib/l10n/app_en.arb`; regenerate localizations.
- [X] T018 [US3] Implement `HomeWelcome` (branded asset + display name/message when `hasWelcomeAsset`, else default `assets/branding/default_welcome.png` + `homeWelcomeMessage`; `Image.errorBuilder` → placeholder; centered/constrained, no overflow; `home_welcome_default` key) in `lib/features/home/presentation/home_welcome.dart`, per [contracts/home-welcome.md](./contracts/home-welcome.md). Depends on T016, T001.
- [X] T019 [US3] Replace the Home body with `HomeWelcome` (remove the old nav `ListTile`s) in `lib/features/home/presentation/home_screen.dart`. Depends on T018, T008.
- [X] T020 [P] [US3] Widget test `HomeWelcome` (branded vs default via overridden `brandConfigProvider`; no `ListTile` nav entries; no overflow at 400 & 1400) in `test/widget/features/home_welcome_test.dart`.

**Checkpoint**: Home is never blank; branded when configured, placeholder otherwise (SC-005).

---

## Phase 6: User Story 4 - Catalog actions relocated beside the search bar (Priority: P2)

**Goal**: Add (primary) and Merge move from the app bar to the right of the search bar, permission-gated, without overflow.

**Independent Test**: Products → Add + Merge beside the search bar (not the app bar), Add primary-styled, both permission-gated and behaving as before; Users → Add beside the search bar; narrow width reflows without horizontal overflow.

### Implementation for User Story 4

- [X] T021 [US4] Add an optional trailing `actions` slot to `CatalogFilterBar` (rendered right of `filters` in both the single-row ≥ 840 px and reflowed `Wrap` layouts; empty = unchanged) in `lib/core/widgets/catalog_filter_bar.dart`, per [contracts/catalog-action-slot.md](./contracts/catalog-action-slot.md).
- [X] T022 [US4] Products list: pass `actions: [if (canMerge) Merge, if (canCreate) Add(primary FilledButton.icon)]` to `CatalogFilterBar` and remove any app-bar actions (keys `merge_products_button`, `new_product_button` preserved) in `lib/features/catalog/presentation/products_list_screen.dart`. Depends on T021, T008.
- [X] T023 [US4] Users list: pass `actions: [if (canCreate) Add(primary)]` to `CatalogFilterBar` (key `new_user_button` preserved) in `lib/features/auth/presentation/admin/users_list_screen.dart`. Depends on T021, T008.
- [X] T024 [P] [US4] Widget test `CatalogFilterBar` actions slot (actions right of filters at wide width; present, no overflow, at narrow width) in `test/widget/core/widgets/catalog_filter_bar_test.dart`.
- [X] T025 [P] [US4] Update products list widget test (Add + Merge found in the filter-bar region not an `AppBar`; Add primary-styled; hidden without create/merge privilege) in `test/widget/features/catalog/products_list_screen_test.dart`.
- [X] T026 [P] [US4] Widget test users list Add relocation (Add beside the search bar; hidden without `users.create`) in `test/widget/features/auth/users_list_screen_test.dart`.

**Checkpoint**: Every catalog shows Add (primary) + Merge beside the search bar, none in the app bar (SC-006).

---

## Phase 7: Polish & Cross-Cutting Concerns

- [X] T027 [P] Run `flutter analyze` (clean) and `dart run build_runner build --delete-conflicting-outputs`.
- [X] T028 Run the full `flutter test` suite; fix regressions caused by the shell/body conversion in pre-existing catalog/list/home tests.
- [X] T029 Run [quickstart.md](./quickstart.md) manual validation (rail↔drawer at 500/1000/1400 px; single trailing user menu; branded vs default Home; catalog actions beside search) and confirm no app-bar title duplication or horizontal overflow.
- [X] T030 Confirm the location fallback behavior against mbe-api#79 (names render once the enriched `/auth/me` ships + client regenerated; until then labeled IDs) — documentation/verification only, no code change now.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: none.
- **Foundational (Phase 2)**: after Setup; blocks US1.
- **US1 (Phase 3)**: after Foundational. Delivers the shell that US2–US4 render in.
- **US2 / US3 / US4 (Phases 4–6)**: after US1. Independent of each other (different widgets/files) and can proceed in parallel.
- **Polish (Phase 7)**: after all desired stories.

### Story-level notes

- **US1 → US4 sequencing**: T008 (US1) strips the catalog screens' app-bar actions; US4 restores Add/Merge in the filter bar. Between US1 and US4 the create/merge actions are temporarily absent from the catalogs — acceptable for incremental delivery; do US4 before demoing catalog create.
- **US2 location names**: implemented as labeled-ID fallback now; upgrades to names with no UI change once **mbe-api#79** lands (regen client + extend `UserSettings` mapping).
- **US3** T019 and **US4** T022 edit files US1 first converted to bodies (`home_screen.dart`, `products_list_screen.dart`) — sequential, not parallel with T008.

### Parallel Opportunities

- T002 is [P] within Foundational.
- Within US1: T005 (widget) is [P]; T009/T010 tests [P]; T005 precedes T006 precedes T007 precedes T008.
- After US1: US2, US3, US4 can run in parallel (distinct files); each story's `[P]` tests run together.
- Polish T027 is [P].

---

## Parallel Example: after US1 completes

```bash
# Three developers pick up the P2/P1-remaining stories in parallel:
Dev A → US2: T012–T015 (user menu)
Dev B → US3: T016–T020 (home welcome)
Dev C → US4: T021–T026 (catalog actions)
```

---

## Implementation Strategy

### MVP First

1. Phase 1 Setup → Phase 2 Foundational → Phase 3 US1.
2. **STOP & VALIDATE**: adaptive grouped navigation works (rail/drawer, RBAC-filtered). Add US2 for a complete P1 app bar.
3. Demo the shell.

### Incremental Delivery

Foundation → US1 (shell, MVP) → US2 (user menu) → US4 (catalog actions) → US3 (branded home). Each adds value without breaking prior stories. (US4 recommended before US3 so catalog create returns promptly after the US1 app-bar strip.)

---

## Notes

- `[P]` = different files, no incomplete-task dependency.
- Run `build_runner` after any freezed/riverpod change (T003, T013 via provider, T016).
- External dependency: **mbe-api#79** (enrich `/auth/me` settings with location names) — non-blocking; menu ships with labeled-ID fallback.
  - **Resolved**: mbe-api#79 shipped (`UserSettingsResponse` gained `store_name`/`store_code`, `point_sale_name`/`point_sale_code`, `cash_drawer_name`/`cash_drawer_code`). Client regenerated; `UserSettings` (`core/access/user_settings.dart`) and `UserMenuButton` (`core/widgets/user_menu_button.dart`) now display resolved names (`name (code)` for POS/cash-drawer), falling back to the labeled-ID text only when a name is still absent.
- Commit after each task or logical group; stop at any checkpoint to validate a story independently.
