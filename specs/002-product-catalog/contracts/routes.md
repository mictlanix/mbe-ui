# Contract: routes introduced by this feature

Route structure mirrors the feature folder (`lib/features/catalog/`) per
constitution §"Technology Stack", even though the module is named `catalog`
rather than `products` (research.md §4). `SystemObject` column is the gate
checked via `AccessControlService.can` (specs/001-user-authentication/contracts/access_control.md,
already established by the auth feature — this feature is a consumer, not a
re-definition).

| Path | Screen | `SystemObject` (Read to view) | Audience | Spec refs |
|---|---|---|---|---|
| `/products` | `products_list_screen.dart` | `products` (0), Read | Any user with `products` Read | FR-001, FR-002, FR-013 |
| `/products/new` | `product_detail_screen.dart` (create mode) | `products` (0), Create | Users with `products` Create | FR-003–FR-007, FR-012, FR-015 |
| `/products/:productId` | `product_detail_screen.dart` (view/edit mode) | `products` (0), Read to view; Update for edits; Delete for the Deactivate action | Users with `products` Read (view-only) / Update (edit) / Delete (deactivate) | FR-008–FR-011, FR-012, FR-013, FR-014 |

## Redirect guard

Reuses the existing `app_router.dart` redirect callback established by the
auth feature (specs/001-user-authentication/contracts/routes.md) — this
feature only adds entries to the route→`SystemObject` lookup
(`routeSystemObject`), it does not change the guard logic itself:

```text
"/products"           -> SystemObject.products  (AccessRight.read)
"/products/new"       -> SystemObject.products  (AccessRight.create)
"/products/:productId"-> SystemObject.products  (AccessRight.read)
```

Action-level gating (Create button, Save on edit, Deactivate button) is
enforced inside the screens via `can(SystemObject.products, AccessRight.X)`,
not via separate routes, per constitution §IV ("Shared list/detail screens
MUST use `can(object, Create|Update|Delete)` to show/hide action buttons").

## Not introduced by this feature

- Any route for Price Lists or Labels administration (`PriceLists` (5),
  `Labels` (1) system objects) — out of scope (spec.md Assumptions).
- A `/products/merge` route — gated by the separate `ProductsMerge` (73)
  system object, out of scope.
