# Phase 1 Data Model: Adaptive Navigation Layout

This feature is UI-structural; its "entities" are in-memory view models and a build-time config, not API DTOs. All are immutable (`freezed` where a class is warranted) and live in `core/`.

## NavItem (sealed) — `core/navigation/nav_destination.dart`

A single-level navigation tree: the root is an ordered list of `NavItem`s, each either a leaf destination or a one-level group of leaf destinations.

```text
NavItem
 ├─ NavDestination   (leaf)
 └─ NavGroup         (one level of NavDestination children)
```

### NavDestination

| Field | Type | Notes |
|---|---|---|
| `id` | `String` | Stable key (e.g. `home`, `users`, `products`); used for widget keys & selection. |
| `labelKey` | `String Function(AppLocalizations)` | Localized label resolver (no hardcoded text). |
| `icon` | `IconData` | Rail/drawer icon. |
| `selectedIcon` | `IconData?` | Optional filled variant for the selected state. |
| `route` | `String` | Target location (e.g. `/`, `/users`, `/products`). |
| `branchIndex` | `int` | Index of this destination's `StatefulShellBranch`. |
| `gate` | `({SystemObject object, AccessRight right})?` | RBAC gate; `null` = always visible (Home). |

**Validation / rules**
- Visible ⇔ `gate == null` OR `accessControl.can(gate.object, gate.right)`.
- `route` must match the branch's root route registered in the router.
- Selected when the current location equals or is under `route` (see `AppNavigation` contract).

### NavGroup

| Field | Type | Notes |
|---|---|---|
| `id` | `String` | Stable key (e.g. `catalogs`). |
| `labelKey` | `String Function(AppLocalizations)` | Section-header label. |
| `children` | `List<NavDestination>` | One level only — a group MUST NOT contain groups. |

**Validation / rules**
- A `NavGroup` is visible ⇔ at least one child is visible; otherwise it (and its header) is omitted entirely (FR-006).
- No nesting: children are always `NavDestination`, never `NavGroup`.

### Concrete tree (current features)

```text
[ NavDestination(home,     gate:null,                       route:/,         branch:0),
  NavGroup(catalogs, children:[
      NavDestination(users,    gate:(users,    read), route:/users,    branch:1),
      NavDestination(products, gate:(products, read), route:/products, branch:2),
  ]) ]
```

Exposed via `navDestinationsProvider` (watches `accessControlProvider`), returning the **filtered** tree (hidden destinations/empty groups already removed) so widgets render what they receive without re-checking access.

## UserSettings — `core/access/user_settings.dart` (existing; extended later)

Maps `UserSettingsResponse` from `/auth/me`. **Today** it carries only ids:

| Field | Type | Notes |
|---|---|---|
| `storeId` | `int?` | |
| `pointSaleId` | `int?` | |
| `cashDrawerId` | `int?` | |
| `storeName` / `storeCode` | `String?` | **Not present yet** — added once mbe-api enriches `/auth/me` (see plan → External Dependencies). |
| `pointSaleName` / `pointSaleCode` | `String?` | Same — blocked on the mbe-api change. |
| `cashDrawerName` / `cashDrawerCode` | `String?` | Same. |

Location context is thus **derived directly from session settings** (already loaded at login) — no separate entity, provider, repository, or network call. When the enriched fields arrive they slot onto this existing entity.

**Display rule** (matches legacy reference), applied by a helper in `UserMenuButton`:
- Store → `storeName` (e.g. "CASA MAESTRA ZUMPANGO"), else fallback `"Store {storeId}"`.
- Point of sale / cash drawer → `name (code)` when both present (e.g. "PV ZUMPANGO (01)"), else `name`, else fallback `"POS {id}"` / `"Drawer {id}"`.

## UserMenuViewModel — derived in `UserMenuButton`

Not a stored class; assembled from `AuthAuthenticated.user` (+ its `settings`):

| Field | Source | Notes |
|---|---|---|
| `identityLine` | `user.email` | Employee display name is a deferred enhancement (research §3). |
| `storeLabel` | `settings.storeName` ?? `"Store {settings.storeId}"` | Omitted entirely if `storeId == null` (FR-014); labeled-ID fallback while `storeName` is absent (pre-dependency) (FR-011). |
| `pointSaleLabel` | `settings.pointSaleName (code)` ?? `"POS {settings.pointSaleId}"` | As above. |
| `cashDrawerLabel` | `settings.cashDrawerName (code)` ?? `"Drawer {settings.cashDrawerId}"` | As above. |
| actions | static | Change Password, Logout. |

**Rules**: when `user.settings == null` or a given id is null, that location line is **omitted** (FR-014). When the id is present but no name is available (before the mbe-api enrichment ships, or the field is null), the line shows the **labeled-ID fallback**, never an error (FR-011). No loading state — the data is synchronous session state.

**Fallback labels** are localized `.arb` entries taking the id as a parameter, with these default values:
- `userMenuStoreFallback` → `"Store {id}"`
- `userMenuPosFallback` → `"POS {id}"`
- `userMenuDrawerFallback` → `"Drawer {id}"`

(es-MX is the first-class locale; these are the default label values — supply Spanish equivalents in `app_es.arb` if a translated form is preferred.)

## BrandConfig — `core/branding/brand_config.dart`

Immutable build-time brand descriptor (freezed), sourced from `--dart-define` with defaults.

| Field | Type | Build source (`--dart-define`) | Default |
|---|---|---|---|
| `displayName` | `String` | `BRAND_DISPLAY_NAME` | app display name ("Mictlanix Business Essentials") |
| `welcomeAsset` | `String?` | `BRAND_WELCOME_ASSET` (asset path) | `null` |
| `hasWelcomeAsset` | `bool` (derived) | — | `welcomeAsset != null` |

**Rules**
- `welcomeAsset == null` ⇒ `HomeWelcome` shows the bundled default placeholder `assets/branding/default_welcome.png` + generic localized welcome message (FR-016).
- A non-null `welcomeAsset` that fails to load falls back to the placeholder via `Image.errorBuilder` (edge case: missing/broken brand asset).
- Exposed via `brandConfigProvider` (`keepAlive`).

## Router shape (view of the change) — `app/router/app_router.dart`

```text
GoRouter
├─ StatefulShellRoute.indexedStack  → builder: AppShell(navigationShell)
│   ├─ branch 0: GoRoute('/')          → HomeScreen (body)
│   ├─ branch 1: GoRoute('/users')     → UsersListScreen (body)
│   └─ branch 2: GoRoute('/products')  → ProductsListScreen (body)
└─ (siblings, full-screen, own Scaffold/AppBar)
    /auth/login, /auth/recover, /auth/account/password,
    /users/new, /users/:userId,
    /products/new, /products/:productId, /products/merge
```

Redirect guard (`_redirect`) and route gates (`_routeGate`) are unchanged; branch root routes keep the same gates they have today.

## Relationships

- `navDestinationsProvider` depends on `accessControlProvider` (visibility) and maps each destination to a `branchIndex` used by `AppNavigation`/`AppShell` to drive `StatefulNavigationShell.goBranch`.
- `AppShell` reads the active branch index from the injected `StatefulNavigationShell` to select the app-bar title (`NavDestination.labelKey`) and the highlighted nav item.
- `UserMenuButton` depends on `authNotifierProvider` (identity + settings, incl. location names once enriched); `HomeWelcome` depends on `brandConfigProvider`. **Neither adds network I/O** — location comes from the already-loaded `/auth/me` session data.
