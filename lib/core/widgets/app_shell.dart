import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/layout/breakpoints.dart';
import 'package:mbe_ui/core/navigation/nav_destination.dart';
import 'package:mbe_ui/core/navigation/nav_destinations.dart';
import 'package:mbe_ui/core/widgets/app_navigation.dart';
import 'package:mbe_ui/core/widgets/brand_nav_header.dart';
import 'package:mbe_ui/core/widgets/user_menu_button.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The single owner of the authenticated `Scaffold`, app bar, and adaptive
/// navigation (contracts/navigation-shell.md). Wraps the router's
/// `StatefulShellRoute` branch content: a persistent rail beside the content
/// at ≥ 600 px, a `NavigationDrawer` (opened from the app-bar menu button)
/// below that. The app bar carries exactly one trailing control — the
/// [UserMenuButton] (spec 010 FR-001/002/003/009).
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void _goBranch(int branchIndex) {
    widget.navigationShell.goBranch(
      branchIndex,
      // Re-tapping the active destination resets it to its branch root.
      initialLocation: branchIndex == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tree = ref.watch(navDestinationsProvider);
    final l10n = AppLocalizations.of(context)!;
    final currentIndex = widget.navigationShell.currentIndex;
    final isCompact = LayoutBreakpoints.isCompact(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: isCompact
          ? AppBar(
              title: Text(_titleFor(tree, currentIndex, l10n)),
              // Exactly one trailing control — the user menu (FR-009).
              actions: const [UserMenuButton(), SizedBox(width: 4)],
            )
          : AppBar(
              // A fixed brand header, exactly as wide as the persistent rail
              // below it, so the logo reads as anchored top-left rather than
              // scrolling away inside the rail (spec 019 follow-up).
              leading: const BrandNavHeader(),
              leadingWidth: AppNavigation.railWidth,
              toolbarHeight: 64,
              title: Text(_titleFor(tree, currentIndex, l10n)),
              actions: const [UserMenuButton(), SizedBox(width: 4)],
            ),
      drawer: isCompact
          ? AppNavigation(
              mode: AppNavigationMode.drawer,
              currentIndex: currentIndex,
              onDestinationSelected: (branchIndex) {
                _scaffoldKey.currentState?.closeDrawer();
                _goBranch(branchIndex);
              },
            )
          : null,
      body: isCompact
          ? widget.navigationShell
          : Row(
              // Stretch so the rail fills the height and its entries sit at
              // the top rather than floating vertically centered.
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppNavigation(
                  mode: AppNavigationMode.rail,
                  currentIndex: currentIndex,
                  onDestinationSelected: _goBranch,
                ),
                const VerticalDivider(width: 1),
                Expanded(child: widget.navigationShell),
              ],
            ),
    );
  }

  /// The active destination's localized label, for the app-bar title. Falls
  /// back to the app title when no destination matches (e.g. an empty tree).
  String _titleFor(List<NavItem> tree, int branchIndex, AppLocalizations l10n) {
    for (final item in tree) {
      switch (item) {
        case NavDestination():
          if (item.branchIndex == branchIndex) return item.label(l10n);
        case NavGroup():
          for (final child in item.children) {
            if (child.branchIndex == branchIndex) return child.label(l10n);
          }
      }
    }
    return l10n.appTitle;
  }
}
