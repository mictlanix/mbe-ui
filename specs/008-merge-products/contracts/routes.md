# Contract: `/products/merge` route & RBAC gate

`lib/app/router/app_router.dart`.

## Route registration

Register the merge route. It must be declared so it matches distinctly from
`/products/:productId` (go_router matches literal `/products/merge` before the
`:productId` param, but keep it above to be explicit):

```dart
GoRoute(
  path: '/products/merge',
  builder: (context, state) => const MergeProductsScreen(),
),
```

## RBAC gate — gate on `productsMerge` / **Create**

The redirect guard (`_redirect` → `_routeSystemObject`) currently maps any
`/products*` prefix to `SystemObject.products` and checks `AccessRight.read`.
Two changes:

1. **Match `/products/merge` before the generic `/products` rule** so it is not
   gated as ordinary product Read.
2. **Gate it on `productsMerge` with `AccessRight.create`** (not Read) — the
   operative privilege the mbe-api endpoint enforces and the only right that
   makes the screen usable (research §5, plan §IV design note).

Because the shared `_redirect` hardcodes `AccessRight.read`, carry a per-route
right. Recommended minimal change — have `_routeSystemObject` return the
required `(SystemObject, AccessRight)` pair (defaulting to Read for existing
routes):

```dart
({SystemObject object, AccessRight right})? _routeGate(String location) {
  if (location == '/products/merge') {
    return (object: SystemObject.productsMerge, right: AccessRight.create);
  }
  if (location.startsWith('/users'))    return (object: SystemObject.users,    right: AccessRight.read);
  if (location.startsWith('/products')) return (object: SystemObject.products, right: AccessRight.read);
  return null;
}
```

and in `_redirect`:

```dart
final gate = _routeGate(state.matchedLocation);
if (gate != null &&
    !ref.read(accessControlProvider).can(gate.object, gate.right)) {
  return '/';
}
```

(A dedicated `if (matchedLocation == '/products/merge')` branch in `_redirect`
is an equally acceptable alternative; the pair-returning refactor keeps the
per-route right in one place.)

## Behavior

| User | Entry point on list | Direct nav to `/products/merge` |
|------|--------------------|--------------------------------|
| Has `productsMerge`/Create (or administrator) | visible | screen renders |
| Lacks it | hidden (FR-012) | redirected to `/` (deny-by-default) |

Documented `SystemObject` correspondence (constitution §IV): the Merge Products
screen corresponds to `SystemObject.productsMerge` (value 73), Create right.
