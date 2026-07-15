# Contract: AppNavigation — `core/widgets/app_navigation.dart`

Renders the access-filtered destination tree as either a persistent rail-style side navigation (Medium+) or a `NavigationDrawer` (Compact), from one model.

## Signature

```dart
enum AppNavigationMode { rail, drawer }

class AppNavigation extends ConsumerWidget {
  const AppNavigation({
    super.key,
    required this.mode,
    required this.currentIndex,
    required this.onDestinationSelected, // (int branchIndex) -> void
  });
}
```

## Behavior

- Reads the **already-filtered** tree from `navDestinationsProvider` (hidden destinations and empty groups are absent — FR-005/FR-006). The widget does not itself call `can(...)`.
- **Grouping (FR-004)**: a `NavGroup` renders as a non-interactive section header (localized `labelKey`) followed by its visible child destinations. No nested groups.
- **Rail mode**: fixed-width persistent side nav (M3 styling: selected indicator via `secondaryContainer`, unselected `onSurfaceVariant`); vertically scrollable when destinations exceed height.
- **Drawer mode**: Material 3 `NavigationDrawer` with `NavigationDrawerDestination` leaves and header widgets for groups; selecting a destination closes the drawer, then calls `onDestinationSelected`.
- **Selection**: a destination is highlighted when `currentIndex == destination.branchIndex`.
- Each destination exposes a stable `Key('nav_dest_<id>')`; each group header `Key('nav_group_<id>')`.

## Acceptance (widget test `app_navigation_test.dart`)

1. Given a user with Users+Products read, the tree shows Home, a "Catalogs" group header, and Users + Products under it (both modes).
2. Given a user lacking Products read, Products is absent; given a user lacking both Users and Products read, the "Catalogs" group header is absent (FR-006).
3. Selecting Products calls `onDestinationSelected(2)`.
4. The item whose `branchIndex == currentIndex` is rendered selected; others are not.
5. No group renders as a nested group (single level only).
