# Contract: AppShell — `core/widgets/app_shell.dart`

The single owner of the authenticated `Scaffold`, app bar, and adaptive navigation. Wraps the `StatefulShellRoute` branch content.

## Signature

```dart
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;
}
```

## Behavior

- Renders a `Scaffold` with:
  - `appBar`: an `AppBar` whose **title** is the active destination's localized label (from `navDestinationsProvider` / `navigationShell.currentIndex`), whose **leading** is an automatic drawer menu button **only on Compact** (< 600 px), and whose **actions** contain **exactly one** `UserMenuButton` (FR-009, SC-003).
  - `drawer`: on Compact only, the `AppNavigation` in drawer mode (`NavigationDrawer`). Null on Medium+ (no drawer, rail is persistent).
  - `body`: on Medium+ a `Row(children: [AppNavigation(rail), VerticalDivider, Expanded(navigationShell)])`; on Compact just `navigationShell` (nav reached via drawer).
- Uses `LayoutBreakpoints.tierOfContext` (rail when `width >= 600`, drawer when `< 600`). Reflows live on resize (LayoutBuilder/MediaQuery).
- Selecting a destination calls `navigationShell.goBranch(index, initialLocation: index == currentIndex)` (tap-again resets the branch to its root — standard indexed-stack idiom).
- Never rendered for `/auth/*` (those routes are outside the shell) — satisfies FR-008.

## Acceptance (widget test `app_shell_test.dart`)

1. At width 1000, a persistent side navigation is present and no drawer menu button is shown.
2. At width 500, no persistent side nav; an app-bar menu button opens a `NavigationDrawer`.
3. Exactly one trailing action widget of type `UserMenuButton` exists on every branch (Home, Users, Products).
4. The app-bar title equals the active destination's localized label and updates when the branch changes.
5. Tapping a destination invokes `goBranch` with the destination's `branchIndex`.
