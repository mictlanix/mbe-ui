# Contract: routes, route gates and navigation

**Feature**: `021-cash-sessions` | **Date**: 2026-08-04

Two routes, one nav destination, one route-gate clause. All three edits land in files that
spec 020 also appends to — mechanically resolvable, see research §15.

---

## 1. Routes

| Path | Screen | Placement | Gate |
|---|---|---|---|
| `/sales/cash-sessions` | `CashSessionsScreen` | `StatefulShellBranch`, **appended last** | `pos` / `read` |
| `/sales/cash-sessions/:cashSessionId` | `CashSessionDetailScreen` | Top-level sibling (full-screen, no rail) | `pos` / `read` |

The nested `/sales/...` form follows constitution's route scheme and spec 020's
`/sales/pos`, deliberately diverging from the 15 flat business routes — see research §1.

**No `/new` route.** Every other entity has a `…/new` sibling, because every other entity
is created from a dedicated form screen. A session is opened from the shift panel on the
list screen itself, so there is nothing to route to. This asymmetry is intentional.

### Branch declaration

Appended at the end of `branches: [...]` in `app_router.dart`, making it **index 17**:

```
StatefulShellBranch(
  routes: [
    GoRoute(
      path: '/sales/cash-sessions',
      builder: (context, state) =>
          CashSessionsScreen(query: ListQuery.fromUri(state.uri)),
    ),
  ],
),
```

`query: ListQuery.fromUri(state.uri)` is required — the drawer facet and page index live in
the URL, per the shared list pattern.

### Detail route

Declared among the top-level siblings, following the `/warehouses/:warehouseId` form:

```
GoRoute(
  path: '/sales/cash-sessions/:cashSessionId',
  builder: (context, state) => CashSessionDetailScreen(
    cashSessionId: int.parse(state.pathParameters['cashSessionId']!),
  ),
),
```

`int.parse(...!)` not `tryParse`, matching every other int path param.

**No `forceReadOnly` parameter**, unlike every other detail route. Those pass
`state.uri.queryParameters['view'] == 'true'` to distinguish a read-only view from an
editable form. A cash session has no editable form — the screen is always read-only with
respect to the record's own fields, and its one action (close) is gated by privilege, not by
a query parameter. Adding `?view=` would imply an edit mode that does not exist.

---

## 2. Route gate

One clause added to `_routeGate` in `app_router.dart`:

```
if (location.startsWith('/sales/cash-sessions')) {
  return (object: SystemObject.pos, right: AccessRight.read);
}
```

- `SystemObject.pos` (44) already exists at `system_object.dart:55`. **No new enum value.**
  A `SystemObject` member must correspond to a real mbe-api integer, and there is no
  `cashSessions` object upstream.
- `AccessRight.read` follows the convention: the route gates on read, and the screen
  further restricts actions (open on `pos`/`create`, close on `cashSessionClose`/`update`).
- **Not** gated on `cashSessionClose` (111). That would lock out the cashiers this feature
  exists for — they must reach the screen to open and view a shift even when a supervisor
  is the only one who can close it.

**Prefix-collision check** (the guard matches by `startsWith`, first match wins):
`/sales/cash-sessions` is not a prefix of, nor prefixed by, any existing clause. The
nearest neighbour is `/cash-drawers`, which is distinct. Spec 020 will add `/sales/pos`,
also distinct. Clause order is therefore not load-bearing here, but the clause should still
sit with the other business routes rather than before the exact-match `/products/merge`
special case.

**Guard-coverage warning**: nothing enforces that a new route has a `_routeGate` clause. A
route added without one is silently public. The router test below is the only protection.

---

## 3. Navigation

`lib/core/navigation/nav_destinations.dart`, three edits:

```
class NavBranch {
  ...
  static const int cashSessions = 17;   // appended — must equal the branch's position
}
```

```
// inside the existing NavGroup(id: 'sales')
NavDestination(
  id: 'cash-sessions',
  label: _cashSessionsLabel,
  icon: Icons.point_of_sale_outlined,
  selectedIcon: Icons.point_of_sale,
  route: '/sales/cash-sessions',
  branchIndex: NavBranch.cashSessions,
  gate: (object: SystemObject.pos, right: AccessRight.read),
),
```

```
String _cashSessionsLabel(AppLocalizations l10n) => l10n.cashSessionsMenuTitle;
```

- The **Sales group already exists** (`NavGroup(id: 'sales')`, currently holding Pricing
  and Taxpayer Issuers) and `salesGroupTitle` is already localized in both ARBs. No new
  group.
- `id` is kebab-case matching the route slug, per convention.
- The label must be a top-level tear-off because `kNavigationTree` is `const`.
- Icons are the `_outlined` / filled pair.
- RBAC hiding is automatic: `navDestinationsProvider` filters on `gate`, and drops a group
  left with no visible children (FR-036).

### The branch-index invariant

`NavBranch.cashSessions` must equal the destination's **positional index** among the
router's `branches: [...]`. The two lists are hand-maintained with **zero compile-time
enforcement**, and a mismatch does not crash — it navigates to the wrong screen and shows
the wrong app-bar title.

Appending (index 17) is chosen precisely to avoid renumbering. Inserting the branch
mid-list to keep the router grouped by business area would require renumbering every
`NavBranch` constant after it plus a matching test, for no functional gain — note that
`NavBranch` order is already not display order (`pricing = 4` sits under Sales while
`facilities = 14` sits under Catalogs).

---

## 4. Required test coverage for these edits

In `test/unit/app/router/app_router_test.dart`:

1. **Gate allows** — a user with `pos`/`read` reaches `/sales/cash-sessions`.
2. **Gate denies** — a user without it is redirected to `/`.
3. **Branch index** — after navigating to the route,
   `AppShell.navigationShell.currentIndex == NavBranch.cashSessions`, following the
   spec-018 pattern at `app_router_test.dart:457-490`. This is the only thing standing
   between a renumbering mistake and a silently wrong screen.
4. **Detail route parses its param** and is gated by the same clause.

**Mandatory or the suite breaks**: `pumpAt` in that file must gain an override for the cash
session repository provider. The new branch's screen fetches eagerly, and an unmocked
network call leaves a pending timer that trips `flutter_test`'s leak detector at teardown —
failing tests unrelated to this feature.
