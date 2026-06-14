# Contract: routes introduced by this feature

Route structure mirrors feature folders per constitution §"Technology Stack".
`SystemObject` column is the gate checked via
[`AccessControlService.can`](./access_control.md); `—` means no gate (open to
the stated audience).

| Path | Screen | `SystemObject` (Read to view) | Audience | Spec refs |
|---|---|---|---|---|
| `/auth/login` | `login_screen.dart` | — | Unauthenticated only (authenticated users are redirected away) | FR-001, FR-008 |
| `/auth/account/password` | `change_password_screen.dart` | — | Any authenticated user | FR-009 |
| `/auth/recover` | `forgot_password_screen.dart` | — | Unauthenticated (request) + holders of a recovery token (confirm) | FR-010 |
| `/users` | `users_list_screen.dart` | `Users` (92) | Administrators (any user with `Users` Read) | FR-011, FR-015 |
| `/users/new` | `user_detail_screen.dart` (create mode) | `Users` (92), Create | Administrators with `Users` Create | FR-012 |
| `/users/:userId` | `user_detail_screen.dart` (edit mode, incl. `privileges_grid.dart`) | `Users` (92), Update for edits | Administrators with `Users` Read/Update | FR-012, FR-013, FR-014 |

## Redirect guard summary (`app_router.dart`)

```text
redirect(context, state):
  authState = ref.read(authNotifierProvider)
  if authState is authenticating: return null  # let it settle

  isAuthRoute = state.matchedLocation starts with "/auth/"

  if authState is unauthenticated:
    return isAuthRoute ? null : "/auth/login"

  if authState is authenticated:
    if state.matchedLocation == "/auth/login": return "/"  # or last intended route
    requiredObject = routeSystemObject(state.matchedLocation)  # null for unguarded routes
    if requiredObject != null and !can(requiredObject, AccessRight.read):
      return "/"  # or a dedicated "not authorized" route
    return null
```

`refreshListenable` must be wired to `authNotifierProvider` (research.md §4)
so that a `401`-triggered transition to `unauthenticated` immediately
re-runs `redirect` and bounces the user to `/auth/login` (FR-003, SC-003) —
without this, a stale screen would remain visible until the next manual
navigation.

## Not introduced by this feature

- `/` (landing/home) — referenced above as the post-login destination, but
  its content is out of scope here. For this feature, `/` MAY be a minimal
  placeholder (e.g., a welcome screen with a sign-out button) sufficient to
  demonstrate FR-001 acceptance scenario 1 and SC-001.
