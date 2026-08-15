import 'package:flutter/widgets.dart';

import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// A single-level navigation tree node: either a leaf [NavDestination] or a
/// one-level [NavGroup] of leaves (data-model.md "NavItem"). Consumed by the
/// shared `AppNavigation` / `AppShell` (spec 010 FR-004).
sealed class NavItem {
  const NavItem();
}

/// The RBAC gate for a destination/route: either the constitution §IV
/// `(SystemObject, AccessRight)` pair, or — for the one family of routes
/// mbe-api itself gates on the administrator flag rather than on a
/// `SystemObject` — a bare administrator check (024-user-profiles
/// research.md §2, contracts/routes.md §2). [AdministratorGate] is strictly
/// narrower than any [PrivilegeGate]: `can()` already returns `true` for an
/// administrator on every object, so nothing reachable via a `PrivilegeGate`
/// becomes unreachable by adding this case.
sealed class NavGate {
  const NavGate();
}

/// The existing constitution §IV gate: visible/reachable only when the
/// signed-in user satisfies `can(object, right)`.
class PrivilegeGate extends NavGate {
  const PrivilegeGate(this.object, this.right);

  final SystemObject object;
  final AccessRight right;
}

/// Visible/reachable only for the signed-in user's `administrator` flag —
/// used where mbe-api exposes no `SystemObject` for the resource (e.g. user
/// profiles).
class AdministratorGate extends NavGate {
  const AdministratorGate();
}

/// A reachable destination in the shell — one branch of the router's
/// `StatefulShellRoute` (data-model.md "NavDestination").
class NavDestination extends NavItem {
  const NavDestination({
    required this.id,
    required this.label,
    required this.icon,
    required this.route,
    required this.branchIndex,
    this.selectedIcon,
    this.gate,
  });

  /// Stable key (e.g. `home`, `users`, `products`) for widget keys/selection.
  final String id;

  /// Localized label resolver — never a hardcoded string.
  final String Function(AppLocalizations l10n) label;

  /// Rail/drawer icon (unselected).
  final IconData icon;

  /// Optional filled variant shown when selected.
  final IconData? selectedIcon;

  /// Target location and matching `StatefulShellBranch` root route.
  final String route;

  /// Index of this destination's branch in the `StatefulShellRoute`.
  final int branchIndex;

  /// RBAC gate; `null` means always visible (e.g. Home).
  final NavGate? gate;
}

/// A one-level grouping of destinations under a section label
/// (data-model.md "NavGroup"). A group MUST NOT contain groups.
class NavGroup extends NavItem {
  const NavGroup({
    required this.id,
    required this.label,
    required this.children,
  });

  /// Stable key (e.g. `catalogs`).
  final String id;

  /// Localized section-header label.
  final String Function(AppLocalizations l10n) label;

  /// The group's leaf destinations (never nested groups).
  final List<NavDestination> children;
}
