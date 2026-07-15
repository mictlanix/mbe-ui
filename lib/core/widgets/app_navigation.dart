import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/navigation/nav_destination.dart';
import 'package:mbe_ui/core/navigation/nav_destinations.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// How [AppNavigation] renders the destination tree.
enum AppNavigationMode {
  /// Persistent rail-style side navigation (Medium tier and wider).
  rail,

  /// Material 3 `NavigationDrawer` (Compact tier).
  drawer,
}

/// The shared primary navigation, driven by the access-filtered
/// [navDestinationsProvider] tree. Renders a persistent rail (≥ 600 px) or a
/// `NavigationDrawer` (< 600 px) from one model, with one level of grouping
/// (spec 010 FR-002/003/004; contracts/app-navigation.md). Visibility is
/// already resolved by the provider — this widget never calls `can(...)`.
class AppNavigation extends ConsumerWidget {
  const AppNavigation({
    super.key,
    required this.mode,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  /// Rail vs. drawer presentation.
  final AppNavigationMode mode;

  /// The active branch index (selection highlight).
  final int currentIndex;

  /// Invoked with the selected destination's `branchIndex`.
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tree = ref.watch(navDestinationsProvider);
    final l10n = AppLocalizations.of(context)!;
    return switch (mode) {
      AppNavigationMode.rail => _buildRail(context, tree, l10n),
      AppNavigationMode.drawer => _buildDrawer(context, tree, l10n),
    };
  }

  // --- Rail --------------------------------------------------------------

  Widget _buildRail(
    BuildContext context,
    List<NavItem> tree,
    AppLocalizations l10n,
  ) {
    final children = <Widget>[const SizedBox(height: 8)];
    for (final item in tree) {
      switch (item) {
        case NavDestination():
          children.add(_railTile(context, item, l10n));
        case NavGroup():
          children.add(_groupHeader(context, item, l10n));
          for (final child in item.children) {
            children.add(_railTile(context, child, l10n));
          }
      }
    }
    return SizedBox(
      width: 240,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }

  Widget _railTile(
    BuildContext context,
    NavDestination d,
    AppLocalizations l10n,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final selected = d.branchIndex == currentIndex;
    final fg = selected ? scheme.onSecondaryContainer : scheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: selected ? scheme.secondaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          key: Key('nav_dest_${d.id}'),
          borderRadius: BorderRadius.circular(28),
          onTap: () => onDestinationSelected(d.branchIndex),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(selected ? (d.selectedIcon ?? d.icon) : d.icon, color: fg),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    d.label(l10n),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: fg,
                      fontWeight: selected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _groupHeader(BuildContext context, NavGroup g, AppLocalizations l10n) {
    return Padding(
      key: Key('nav_group_${g.id}'),
      padding: const EdgeInsets.fromLTRB(24, 16, 16, 8),
      child: Text(
        g.label(l10n),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  // --- Drawer ------------------------------------------------------------

  Widget _buildDrawer(
    BuildContext context,
    List<NavItem> tree,
    AppLocalizations l10n,
  ) {
    // Destinations flattened in render order — `NavigationDrawer` reports the
    // selected index counting only its `NavigationDrawerDestination` children,
    // so this list maps that index back to a `branchIndex`.
    final flat = <NavDestination>[];
    final children = <Widget>[const SizedBox(height: 12)];

    void addDestination(NavDestination d) {
      flat.add(d);
      children.add(
        NavigationDrawerDestination(
          key: Key('nav_dest_${d.id}'),
          icon: Icon(d.icon),
          selectedIcon: d.selectedIcon != null ? Icon(d.selectedIcon) : null,
          label: Text(d.label(l10n)),
        ),
      );
    }

    for (final item in tree) {
      switch (item) {
        case NavDestination():
          addDestination(item);
        case NavGroup():
          children.add(_groupHeader(context, item, l10n));
          item.children.forEach(addDestination);
      }
    }

    final selectedIndex = flat.indexWhere((d) => d.branchIndex == currentIndex);
    return NavigationDrawer(
      selectedIndex: selectedIndex >= 0 ? selectedIndex : null,
      onDestinationSelected: (i) => onDestinationSelected(flat[i].branchIndex),
      children: children,
    );
  }
}
