# Contract: `AccessControlService` (consumed by every future feature)

This is the internal contract this feature establishes for the rest of
mbe-ui (constitution §IV). Other features depend on this, not on
`AuthState`/`User` directly.

## Provider surface (`lib/core/access/access_control.dart`)

```text
accessControlProvider: Provider<AccessControlService>
```

`AccessControlService`:

| Member | Signature | Behavior |
|---|---|---|
| `can` | `bool can(SystemObject object, AccessRight right)` | Returns `true` if the current user is `administrator`, OR has a `Privilege` for `object` whose bitmask includes `right`. Returns `false` if unauthenticated, if `object` has no `Privilege` entry, or if the bit is unset. |
| `isAuthenticated` | `bool get isAuthenticated` | `true` only when `AuthState` is `authenticated`. |
| `isAdministrator` | `bool get isAdministrator` | `true` when the current user's `administrator == true`. |

`AccessControlService` is derived (read-only) from
`authNotifierProvider`'s current `AuthState` — it does not hold independent
state and recomputes whenever `AuthState` changes.

## Consumption patterns

- **Routing** (`app/router/app_router.dart`): `redirect` callback calls
  `can(routeSystemObject, AccessRight.read)` for the target route; `false` ⇒
  redirect away (to `/` or a "not authorized" screen). Routes with no
  associated `SystemObject` (e.g. `/auth/login`, a future landing `/`) skip
  this check.
- **Shared widgets** (`core/widgets/`): list/detail screens accept a
  `SystemObject` and use `can(object, AccessRight.create|update|delete)` to
  show/hide "New"/"Edit"/"Delete" actions (constitution §IV).
- **This feature's own screens**:
  - Admin Users routes/actions check `can(SystemObject.Users, ...)`.
  - The login screen and password-change/recovery screens require no
    `SystemObject` check (available to any authenticated — or, for
    login/recovery, unauthenticated — user).

## Failure mode

If `AuthState` is `unauthenticated`, `can()` always returns `false` and
`isAuthenticated`/`isAdministrator` are `false` — callers do not need a
separate "not logged in" branch before calling `can()`.
