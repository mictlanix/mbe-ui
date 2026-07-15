# Phase 0 Research: Adaptive Navigation Layout

All spec assumptions were resolvable with codebase-grounded defaults; no open `NEEDS CLARIFICATION` remain. Decisions below feed `plan.md`, `data-model.md`, and the contracts.

## §1. Persistent shell via `StatefulShellRoute.indexedStack`

- **Decision**: Refactor `app_router.dart` so Home, Users-list, and Products-list become the three branches of a single `StatefulShellRoute.indexedStack`. The shell's `builder` returns `AppShell(navigationShell)`. Detail/form/merge routes (`/users/new`, `/users/:id`, `/products/new`, `/products/:id`, `/products/merge`) and all `/auth/*` routes stay **outside** the shell as top-level sibling routes, so they render full-screen (no rail) with their own `Scaffold`/`AppBar`/back button.
- **Rationale**: `indexedStack` preserves each branch's navigator state (list scroll position, filters, pagination) when switching destinations — a desktop expectation. Keeping focused create/edit forms full-screen matches the legacy app and avoids the fiddly "show a back button inside the shell app bar when the branch can pop" logic. `/auth/*` staying outside the shell satisfies FR-008 (no shell on unauthenticated screens) for free.
- **Alternatives considered**:
  - *Plain `ShellRoute`* — simpler, but loses per-branch state across destination switches; rejected for the list-state UX regression.
  - *Nesting detail routes inside branches (rail stays visible on forms)* — faithful to "menus on all screens," but requires contextual back-button handling in the shared app bar and complicates deep-link/redirect behavior; deferred as a possible later enhancement, not needed for the spec's acceptance scenarios.
  - *`flutter_adaptive_scaffold` package* — provides adaptive rail/drawer out of the box, but doesn't model one-level grouping, adds a dependency for behavior we can build on the existing centralized breakpoints, and would fight our `go_router` shell. Rejected (Principle VI wants breakpoints centralized in `core/`, which we already have).

## §2. Adaptive rail vs. drawer + one-level grouping

- **Decision**: One shared `AppNavigation` widget, driven by a single access-filtered destination model, renders:
  - **Compact (< 600 px)** → Material 3 `NavigationDrawer` opened from the app bar's leading menu button. Group labels render as the standard non-interactive drawer section headers (`Padding`+`Text`); leaves render as `NavigationDrawerDestination`.
  - **Medium and wider (≥ 600 px)** → a persistent **rail-style side navigation**: a fixed-width (`~72` collapsed / `~240` extended) scrollable `Column` of Material 3 nav items with group section headers, styled to M3 (selected indicator, `onSurfaceVariant`/`secondaryContainer`). It is always visible beside the branch content.
- **Rationale**: Flutter's stock `NavigationRail` is a **flat** destination strip with no support for section headers/grouping and a ~3–7 destination guideline. FR-004 mandates one level of grouping now, and the destination set will grow to the full legacy menu tree (Catálogos, Ventas, Producción, …) — well beyond a stock rail. A model-driven side-nav list scales to that and renders both group headers and leaves uniformly. `NavigationDrawer` already supports mixed headers + destinations, so the compact branch uses it directly.
- **Alternatives considered**:
  - *Stock `NavigationRail`* — matches the user's wording literally but cannot show groups and doesn't scale; rejected. (User-facing docs/labels still call it a "navigation rail.")
  - *Expandable/collapsible groups (accordion) on the rail* — nice for a deep tree, but with a single group today it adds state and testing surface for no immediate benefit; the model leaves room to add expansion later without changing callers.
- **Breakpoint**: rail at **Medium tier and wider** (`width ≥ LayoutBreakpoints.compact` = 600), drawer at **Compact** (`< 600`), per the spec assumption. Reuses `core/layout/breakpoints.dart` — no new breakpoint constant. ("Tablet or larger" ⇒ ≥ 600.)

## §3. Single user-menu control in the app bar

- **Decision**: `UserMenuButton` — a single trailing app-bar control (avatar/person icon + optional email) using a Material 3 `MenuAnchor`/`PopupMenuButton`. Menu contents, top-to-bottom: **identity header** (email now; employee display name is a deferred enhancement), **location context** (store / point of sale / cash drawer), a divider, **Change Password** (`context.push('/auth/account/password')`), **Logout** (`authNotifierProvider.notifier.signOut()`). Identity + settings come from `authNotifierProvider`'s `AuthAuthenticated.user`.
- **Rationale**: Consolidating every user-scoped action behind one control is exactly the reference behavior and frees the trailing area so catalog Add/Merge can move to the search bar (US4). All data is already in session state — no fetch, no `AsyncValue` juggling in the app bar.
- **Location display — names from own-profile `/auth/me` (with an mbe-api dependency)**: `UserSettings` carries only `storeId` / `pointSaleId` / `cashDrawerId` (opaque ints); the legacy screenshot shows resolved names ("CASA MAESTRA ZUMPANGO", "PV ZUMPANGO (01)"). Two ways to get names were weighed:
  - *Client-side catalog GET-by-id* (`StoresApi`/`PointsOfSaleApi`/`CashDrawersApi`) — works with today's schema, **but** each call is RBAC-gated on `stores`/`pointsOfSale`/`cashDrawers` read, so a user without those catalog privileges (e.g. a cashier) would get `403` → labeled-ID fallback for exactly the users who most need their POS shown. **Rejected.**
  - *Own-profile via `GET /api/v1/auth/me`* (`AuthApi.getMeApiV1AuthMeGet` → `UserResponse.settings`) — **chosen.** It returns the caller's *own* profile/settings/privileges, so no catalog RBAC is involved and **no extra network call** is needed (the session already loads `/auth/me` at login). The names simply live on the settings object.
- **Decision**: Source store/POS/cash-drawer names from `/auth/me` settings, formatted per the legacy reference (store → `name`, POS/cash drawer → `name (code)`). The user menu's display helper prefers the name and falls back to a labeled ID ("Store {id}" / "POS {id}" / "Drawer {id}") when the name is absent (FR-011). **No `master_data` fetch slice, no `LocationRepository`, no per-catalog calls** — dropped versus the prior revision.
- **Dependency (Principle III)**: `UserSettingsResponse` today has only `store_id` / `point_sale_id` / `cash_drawer_id` — **no names**. Enriching it (add `name`+`code` per location) is an **mbe-api change**, so it is **filed as an mbe-api issue, not patched from this session** (repo-boundary rule). Delivery: ship the menu now with the labeled-ID fallback from the existing ids; when the enriched schema lands, re-run codegen, extend the `UserSettings` domain-entity mapping, and names appear with no further UI change. See plan.md → *External Dependencies*.
  - **Employee identity name** (legacy "Administrador del Sistema") stays a **separate deferred enhancement** — `User` exposes only `email` today; a display name would come from the same `/auth/me` enrichment or `employees` and is not required for FR-010.
- **Alternatives considered**: keeping Logout as its own app-bar icon — rejected (FR-009 requires exactly one trailing control). A full account/profile route instead of a popup — heavier than the reference and unnecessary.

## §4. Branded Home welcome via build-time flavor config

- **Decision**: Introduce `BrandConfig` (freezed) in `core/branding`, populated at build time from `--dart-define` values (e.g. `BRAND_DISPLAY_NAME`, `BRAND_WELCOME_ASSET`) with safe defaults, exposed via a `keepAlive` Riverpod provider. `HomeWelcome` renders the configured welcome asset + display name/message when present, else a bundled **default placeholder** (`assets/branding/default_welcome.png` + a generic localized welcome message). A configured-but-unloadable image falls back to the placeholder via `Image`'s `errorBuilder`.
- **Rationale**: Principle V mandates per-deployment brand tokens via build-time flavors, never hardcoded in `app/theme/`. This is the first brand consumer; a small `BrandConfig` seam lets Casa Maestra (and future customers) supply a logo/name at build time without a code fork, while the default keeps Home non-blank for un-branded builds (FR-015/016).
- **Scope boundary**: This feature wires **the welcome asset + display name** and the default placeholder only. Defining full customer flavor entry points / per-flavor seed colors is out of scope (the seed color stays the current default; `app_theme.dart` already notes flavor wiring as future work). Bundling any specific customer's proprietary art (e.g. the Casa Maestra logo) is a per-deployment concern, not part of this repo's default assets.
- **Alternatives considered**: reading brand assets from mbe-api at runtime — violates the build-time-flavor mandate and Principle VII (online-only doesn't mean fetching static brand art); rejected. A full theming/flavor framework — over-scoped for one welcome screen; deferred.

## §5. Relocating catalog actions to the search-bar row

- **Decision**: Extend `CatalogFilterBar` with an optional trailing `actions` slot rendered to the right of the existing `filters` (Filters button). Product list passes `[Merge?, Add(primary)]`; Users list passes `[Add(primary)]`. "Primary" = a filled/`FilledButton.icon`-style Add vs. the outlined/icon styling of secondary actions and the Filters button. The list screens delete their `AppBar` `actions:` and, since the shell now owns the `Scaffold`/`AppBar`, return body content only (title supplied by the shell from the active destination).
- **Rationale**: Reuses the one shared filter-bar layout (single row ≥ 840 px, `Wrap` below) so relocation is consistent across every catalog and inherits the anti-overflow reflow (FR-021). Keeps Create a toolbar/non-row action (Principle VI) — it moves from the app bar to the filter row, never onto a table row. Access gating (`can(create)` / `can(productsMerge, create)`) is unchanged.
- **Alternatives considered**: a floating action button for Add — inconsistent with the desktop-first toolbar model and the reference; rejected. Leaving Merge in the app bar — violates FR-018's "not in the app bar's trailing area" and the single-trailing-control rule.

## §6. Destination title ownership

- **Decision**: The shell derives the app-bar title from the active branch's `NavDestination.titleKey`. Feature list screens no longer set an `AppBar` title. Detail/form routes (outside the shell) keep setting their own titles as today.
- **Rationale**: With one shell-owned app bar, a single source of truth for the title avoids per-screen duplication and keeps the "exactly one trailing control" invariant (SC-003) trivially true on every destination.

## Resolved spec assumptions (recap)

| Spec assumption | Resolution |
|---|---|
| Rail/drawer cutoff | Rail ≥ 600 (Medium+), drawer < 600 (Compact) — reuse existing breakpoints |
| Destination set | Home + Catalogs(Users, Products) only; model scales to full legacy tree |
| Location = display-only | Confirmed; **names sourced from own-profile `/auth/me`** (not catalog APIs) — needs an mbe-api settings enrichment (external dep); labeled-ID fallback until then; switching still out of scope |
| Change Password moves to user menu | Confirmed; underlying `/auth/account/password` flow unchanged |
| Brand via flavors | `BrandConfig` from `--dart-define` + bundled default placeholder |

## External dependencies

**One**: mbe-api must enrich `GET /api/v1/auth/me` (`UserSettingsResponse`) with the store / point-of-sale / cash-drawer **`name`** (+`code`) for the caller's location ids — filed as **[mictlanix/mbe-api#79](https://github.com/mictlanix/mbe-api/issues/79)** per Principle III (not patched here). The feature ships with a labeled-ID fallback until it lands, then regenerates the client and maps the new fields. No other endpoint or schema change is required, and no client-side catalog fetch is introduced.
