# Contract: routes, gates and navigation

**Feature**: `024-user-profiles` | **Files**:
`lib/app/router/app_router.dart`, `lib/core/navigation/nav_destination.dart`,
`lib/core/navigation/nav_destinations.dart`

## 1. New routes

| Path | Screen | Placement | Gate |
|---|---|---|---|
| `/user-profiles` | `UserProfilesListScreen(query: ListQuery.fromUri(state.uri))` | New `StatefulShellBranch`, appended last | administrator |
| `/user-profiles/new` | `UserProfileDetailScreen()` | Top-level sibling (full screen, no rail) | administrator |
| `/user-profiles/:profileId` | `UserProfileDetailScreen(profileId: …, forceReadOnly: uri.queryParameters['view'] == 'true')` | Top-level sibling | administrator |

`/user-profiles` is pinned by the spec's Verbatim Constraints. The `new` and
`:profileId` shapes and the `?view=true` read-only flag mirror `/users`
exactly.

## 2. Gate type change

`_routeGate` today returns `({SystemObject object, AccessRight right})?`, where
`null` means unguarded. It gains a third possibility — administrator-only — so
the return type becomes a small sealed type:

```
sealed class RouteGate
  PrivilegeGate(SystemObject object, AccessRight right)   // today's pair
  AdministratorGate()                                     // new
```

`_redirect` evaluates it:

| Gate | Test |
|---|---|
| `null` | allowed |
| `PrivilegeGate` | `accessControl.can(object, right)` — unchanged |
| `AdministratorGate` | `accessControl.isAdministrator` |

A failing gate redirects to `/` — unchanged behaviour.

**Ordering**: the `/user-profiles` check must precede the existing
`location.startsWith('/users')` check, because `/user-profiles` does **not**
start with `/users` — but the reverse mistake (a `/users` prefix test written
loosely enough to catch it) is the kind of bug this note exists to prevent.
Both prefixes are tested explicitly.

**Rationale for a new gate kind rather than a synthetic `SystemObject`**: see
research.md §2 and the plan's Complexity Tracking entry. `isAdministrator`
already exists on `AccessControlService`; nothing new is computed.

## 3. `NavGate` change

`NavGate` in `nav_destination.dart` is today the same record type. It becomes
the same sealed `RouteGate`, and `_isVisible` in `nav_destinations.dart`
evaluates it with the identical two-case switch. Every existing destination
keeps a `PrivilegeGate` with unchanged semantics.

## 4. Navigation entry

```
NavGroup(id: 'catalogs')
  ├─ users            /users            gate: PrivilegeGate(users, read)
  ├─ user-profiles    /user-profiles    gate: AdministratorGate()   ← new, second
  ├─ products         …
  └─ …
```

| Property | Value |
|---|---|
| `id` | `user-profiles` |
| `label` | `l10n.userProfilesMenuTitle` |
| `icon` / `selectedIcon` | `Icons.badge_outlined` / `Icons.badge` |
| `route` | `/user-profiles` |
| `branchIndex` | `NavBranch.userProfiles = 19` |

`NavBranch` constants are positional and appended, never renumbered — the file
already documents this for `cashSessions = 17` and `pos = 18`. Display order
comes from position within `kNavigationTree`, which is why index 19 can sit
second in the group.

A group with no visible children is dropped entirely by `_filterTree`, so a
non-administrator with no other catalog access sees no empty header.

## 5. Existing routes touched

| Route | Change |
|---|---|
| `/users` | List screen gains a profile column and a profile filter facet (`?profile=<id>`). Gate unchanged. |
| `/users/new` | Detail screen gains the profile picker. Gate unchanged. |
| `/users/:userId` | Detail screen gains the origin line and the Apply Profile action (edit mode only). Gate unchanged. |

## 6. Redirect guard summary (delta only)

```
/user-profiles*        → AdministratorGate
/users*                → PrivilegeGate(users, read)          [unchanged]
everything else        → unchanged
```
