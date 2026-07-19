import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/navigation/nav_destination.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Branch indices for the router's `StatefulShellRoute` — the order here MUST
/// match the branch order in `app_router.dart`.
class NavBranch {
  const NavBranch._();
  static const int home = 0;
  static const int users = 1;
  static const int products = 2;
  static const int priceLists = 3;
  static const int pricing = 4;
  static const int exchangeRates = 5;
  static const int suppliers = 6;
  static const int labels = 7;
  static const int employees = 8;
  static const int customers = 9;
}

/// The full navigation tree for the app, before access filtering. New
/// destinations/groups are added here as features ship (spec 010 assumptions).
const List<NavItem> kNavigationTree = [
  NavDestination(
    id: 'home',
    label: _homeLabel,
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
    route: '/',
    branchIndex: NavBranch.home,
  ),
  NavGroup(
    id: 'catalogs',
    label: _catalogsLabel,
    children: [
      NavDestination(
        id: 'users',
        label: _usersLabel,
        icon: Icons.people_outline,
        selectedIcon: Icons.people,
        route: '/users',
        branchIndex: NavBranch.users,
        gate: (object: SystemObject.users, right: AccessRight.read),
      ),
      NavDestination(
        id: 'products',
        label: _productsLabel,
        icon: Icons.inventory_2_outlined,
        selectedIcon: Icons.inventory_2,
        route: '/products',
        branchIndex: NavBranch.products,
        gate: (object: SystemObject.products, right: AccessRight.read),
      ),
      NavDestination(
        id: 'price-lists',
        label: _priceListsLabel,
        icon: Icons.sell_outlined,
        selectedIcon: Icons.sell,
        route: '/price-lists',
        branchIndex: NavBranch.priceLists,
        gate: (object: SystemObject.priceLists, right: AccessRight.read),
      ),
      NavDestination(
        id: 'exchange-rates',
        label: _exchangeRatesLabel,
        icon: Icons.currency_exchange_outlined,
        selectedIcon: Icons.currency_exchange,
        route: '/exchange-rates',
        branchIndex: NavBranch.exchangeRates,
        gate: (object: SystemObject.exchangeRates, right: AccessRight.read),
      ),
      NavDestination(
        id: 'suppliers',
        label: _suppliersLabel,
        icon: Icons.local_shipping_outlined,
        selectedIcon: Icons.local_shipping,
        route: '/suppliers',
        branchIndex: NavBranch.suppliers,
        gate: (object: SystemObject.suppliers, right: AccessRight.read),
      ),
      NavDestination(
        id: 'labels',
        label: _labelsLabel,
        icon: Icons.label_outline,
        selectedIcon: Icons.label,
        route: '/labels',
        branchIndex: NavBranch.labels,
        gate: (object: SystemObject.labels, right: AccessRight.read),
      ),
      NavDestination(
        id: 'employees',
        label: _employeesLabel,
        icon: Icons.badge_outlined,
        selectedIcon: Icons.badge,
        route: '/employees',
        branchIndex: NavBranch.employees,
        gate: (object: SystemObject.employees, right: AccessRight.read),
      ),
      NavDestination(
        id: 'customers',
        label: _customersLabel,
        icon: Icons.people_alt_outlined,
        selectedIcon: Icons.people_alt,
        route: '/customers',
        branchIndex: NavBranch.customers,
        gate: (object: SystemObject.customers, right: AccessRight.read),
      ),
    ],
  ),
  NavGroup(
    id: 'sales',
    label: _salesLabel,
    children: [
      NavDestination(
        id: 'pricing',
        label: _pricingLabel,
        icon: Icons.price_change_outlined,
        selectedIcon: Icons.price_change,
        route: '/pricing',
        branchIndex: NavBranch.pricing,
        gate: (object: SystemObject.pricing, right: AccessRight.read),
      ),
    ],
  ),
];

// Label resolvers kept as top-level tear-offs so [kNavigationTree] stays const.
String _homeLabel(AppLocalizations l10n) => l10n.homeMenuTitle;
String _catalogsLabel(AppLocalizations l10n) => l10n.catalogsGroupTitle;
String _salesLabel(AppLocalizations l10n) => l10n.salesGroupTitle;
String _usersLabel(AppLocalizations l10n) => l10n.usersMenuTitle;
String _productsLabel(AppLocalizations l10n) => l10n.productsTitle;
String _priceListsLabel(AppLocalizations l10n) => l10n.priceListsMenuTitle;
String _pricingLabel(AppLocalizations l10n) => l10n.pricingMenuTitle;
String _exchangeRatesLabel(AppLocalizations l10n) =>
    l10n.exchangeRatesMenuTitle;
String _suppliersLabel(AppLocalizations l10n) => l10n.suppliersMenuTitle;
String _labelsLabel(AppLocalizations l10n) => l10n.labelsMenuTitle;
String _employeesLabel(AppLocalizations l10n) => l10n.employeesMenuTitle;
String _customersLabel(AppLocalizations l10n) => l10n.customersMenuTitle;

/// The navigation tree filtered by the current user's access (constitution
/// §IV, FR-005/FR-006): destinations the user cannot read are removed, and a
/// group left with no visible children is dropped entirely (no empty header).
final navDestinationsProvider = Provider<List<NavItem>>((ref) {
  final access = ref.watch(accessControlProvider);
  return _filterTree(kNavigationTree, access);
});

List<NavItem> _filterTree(List<NavItem> tree, AccessControlService access) {
  final result = <NavItem>[];
  for (final item in tree) {
    switch (item) {
      case NavDestination():
        if (_isVisible(item, access)) result.add(item);
      case NavGroup():
        final children = item.children
            .where((d) => _isVisible(d, access))
            .toList();
        if (children.isNotEmpty) {
          result.add(
            NavGroup(id: item.id, label: item.label, children: children),
          );
        }
    }
  }
  return result;
}

bool _isVisible(NavDestination d, AccessControlService access) {
  final gate = d.gate;
  return gate == null || access.can(gate.object, gate.right);
}
