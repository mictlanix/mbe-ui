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
  static const int taxpayerRecipients = 10;
  static const int expenses = 11;
  static const int vehicles = 12;
  static const int vehicleOperators = 13;

  // Branch index continues positionally from spec 013's last branch
  // (vehicleOperators = 13): 018-nested-facility-management removes the
  // warehouses(14)/cashDrawers(15)/pointsOfSale(16) branches spec 014 had
  // appended here — those catalogs no longer have standalone screens — and
  // renumbers facilities/paymentMethodOptions/taxpayerIssuers down to fill
  // the gap (contracts/routes.md §2).
  static const int facilities = 14;
  static const int paymentMethodOptions = 15;
  static const int taxpayerIssuers = 16;

  // 021-cash-sessions: appended last, not renumbered into the sequence —
  // appending avoids renumbering every constant above it for no functional
  // gain (NavBranch order is already not display order; see `pricing`
  // above, under Sales, versus `facilities`, under Catalogs).
  static const int cashSessions = 17;

  // 020-point-of-sale: appended last, same rationale as `cashSessions` above.
  static const int pos = 18;

  // 024-user-profiles: appended last, same rationale as `cashSessions`
  // above — display order comes from position within `kNavigationTree`
  // (this destination sits right after `users` there), not from this index.
  static const int userProfiles = 19;

  // 029-back-office-sales-orders: appended last, same rationale as
  // `cashSessions` above — display order comes from position within
  // `kNavigationTree` (this destination sits right before `pos` there).
  static const int salesOrders = 20;
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
        gate: PrivilegeGate(SystemObject.users, AccessRight.read),
      ),
      NavDestination(
        id: 'user-profiles',
        label: _userProfilesLabel,
        icon: Icons.badge_outlined,
        selectedIcon: Icons.badge,
        route: '/user-profiles',
        branchIndex: NavBranch.userProfiles,
        gate: AdministratorGate(),
      ),
      NavDestination(
        id: 'products',
        label: _productsLabel,
        icon: Icons.inventory_2_outlined,
        selectedIcon: Icons.inventory_2,
        route: '/products',
        branchIndex: NavBranch.products,
        gate: PrivilegeGate(SystemObject.products, AccessRight.read),
      ),
      NavDestination(
        id: 'price-lists',
        label: _priceListsLabel,
        icon: Icons.sell_outlined,
        selectedIcon: Icons.sell,
        route: '/price-lists',
        branchIndex: NavBranch.priceLists,
        gate: PrivilegeGate(SystemObject.priceLists, AccessRight.read),
      ),
      NavDestination(
        id: 'exchange-rates',
        label: _exchangeRatesLabel,
        icon: Icons.currency_exchange_outlined,
        selectedIcon: Icons.currency_exchange,
        route: '/exchange-rates',
        branchIndex: NavBranch.exchangeRates,
        gate: PrivilegeGate(SystemObject.exchangeRates, AccessRight.read),
      ),
      NavDestination(
        id: 'suppliers',
        label: _suppliersLabel,
        icon: Icons.local_shipping_outlined,
        selectedIcon: Icons.local_shipping,
        route: '/suppliers',
        branchIndex: NavBranch.suppliers,
        gate: PrivilegeGate(SystemObject.suppliers, AccessRight.read),
      ),
      NavDestination(
        id: 'labels',
        label: _labelsLabel,
        icon: Icons.label_outline,
        selectedIcon: Icons.label,
        route: '/labels',
        branchIndex: NavBranch.labels,
        gate: PrivilegeGate(SystemObject.labels, AccessRight.read),
      ),
      NavDestination(
        id: 'employees',
        label: _employeesLabel,
        icon: Icons.badge_outlined,
        selectedIcon: Icons.badge,
        route: '/employees',
        branchIndex: NavBranch.employees,
        gate: PrivilegeGate(SystemObject.employees, AccessRight.read),
      ),
      NavDestination(
        id: 'customers',
        label: _customersLabel,
        icon: Icons.people_alt_outlined,
        selectedIcon: Icons.people_alt,
        route: '/customers',
        branchIndex: NavBranch.customers,
        gate: PrivilegeGate(SystemObject.customers, AccessRight.read),
      ),
      NavDestination(
        id: 'taxpayer-recipients',
        label: _taxpayerRecipientsLabel,
        icon: Icons.receipt_long_outlined,
        selectedIcon: Icons.receipt_long,
        route: '/taxpayer-recipients',
        branchIndex: NavBranch.taxpayerRecipients,
        gate: PrivilegeGate(
          SystemObject.taxpayerRecipients,
          AccessRight.read,
        ),
      ),
      NavDestination(
        id: 'expenses',
        label: _expensesLabel,
        icon: Icons.payments_outlined,
        selectedIcon: Icons.payments,
        route: '/expenses',
        branchIndex: NavBranch.expenses,
        gate: PrivilegeGate(SystemObject.expenses, AccessRight.read),
      ),
      NavDestination(
        id: 'vehicles',
        label: _vehiclesLabel,
        icon: Icons.airport_shuttle_outlined,
        selectedIcon: Icons.airport_shuttle,
        route: '/vehicles',
        branchIndex: NavBranch.vehicles,
        gate: PrivilegeGate(SystemObject.vehicle, AccessRight.read),
      ),
      NavDestination(
        id: 'vehicle-operators',
        label: _vehicleOperatorsLabel,
        icon: Icons.assignment_ind_outlined,
        selectedIcon: Icons.assignment_ind,
        route: '/vehicle-operators',
        branchIndex: NavBranch.vehicleOperators,
        gate: PrivilegeGate(SystemObject.vehicleOperators, AccessRight.read),
      ),
      // Warehouses, Cash Drawers and Points of Sale are no longer
      // standalone destinations (018-nested-facility-management): each
      // exists only as a child of a facility, reached by expanding that
      // facility's card on the Facilities screen below. Their l10n keys
      // (warehousesMenuTitle/cashDrawersMenuTitle/pointsOfSaleMenuTitle) are
      // reused as that screen's child-section headers, not orphaned.
      NavDestination(
        id: 'facilities',
        label: _facilitiesLabel,
        icon: Icons.business_outlined,
        selectedIcon: Icons.business,
        route: '/facilities',
        branchIndex: NavBranch.facilities,
        gate: PrivilegeGate(SystemObject.facilities, AccessRight.read),
      ),
      // spec 015: Payment Method Options is a fiscal catalog under Catálogos;
      // its Taxpayer Issuers/Certificates counterparts live under Ventas
      // below (contracts/routes.md).
      NavDestination(
        id: 'payment-method-options',
        label: _paymentMethodOptionsLabel,
        icon: Icons.payment_outlined,
        selectedIcon: Icons.payment,
        route: '/payment-method-options',
        branchIndex: NavBranch.paymentMethodOptions,
        gate: PrivilegeGate(
          SystemObject.paymentMethodOptions,
          AccessRight.read,
        ),
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
        gate: PrivilegeGate(SystemObject.pricing, AccessRight.read),
      ),
      // Taxpayer Certificates has no destination of its own — it is a child
      // section of the Taxpayer Issuer detail screen below, not a standalone
      // catalog (spec 015 research.md §9).
      NavDestination(
        id: 'taxpayer-issuers',
        label: _taxpayerIssuersLabel,
        icon: Icons.corporate_fare_outlined,
        selectedIcon: Icons.corporate_fare,
        route: '/taxpayer-issuers',
        branchIndex: NavBranch.taxpayerIssuers,
        gate: PrivilegeGate(SystemObject.taxpayers, AccessRight.read),
      ),
      NavDestination(
        id: 'cash-sessions',
        label: _cashSessionsLabel,
        icon: Icons.point_of_sale_outlined,
        selectedIcon: Icons.point_of_sale,
        route: '/sales/cash-sessions',
        branchIndex: NavBranch.cashSessions,
        gate: PrivilegeGate(SystemObject.pos, AccessRight.read),
      ),
      // 029-back-office-sales-orders: placed before Point of Sale — the
      // back-office order screen is the more general entry point, and it is
      // gated on `salesOrders`, not `pos`, so a back-office salesperson with
      // no register privilege reaches it (contracts/routes.md §1, FR-002).
      NavDestination(
        id: 'sales-orders',
        label: _salesOrdersLabel,
        icon: Icons.receipt_long_outlined,
        selectedIcon: Icons.receipt_long,
        route: '/sales/orders',
        branchIndex: NavBranch.salesOrders,
        gate: PrivilegeGate(SystemObject.salesOrders, AccessRight.read),
      ),
      NavDestination(
        id: 'pos',
        label: _posLabel,
        icon: Icons.shopping_cart_outlined,
        selectedIcon: Icons.shopping_cart,
        route: '/sales/pos',
        branchIndex: NavBranch.pos,
        gate: PrivilegeGate(SystemObject.pos, AccessRight.read),
      ),
    ],
  ),
];

// Label resolvers kept as top-level tear-offs so [kNavigationTree] stays const.
String _homeLabel(AppLocalizations l10n) => l10n.homeMenuTitle;
String _catalogsLabel(AppLocalizations l10n) => l10n.catalogsGroupTitle;
String _salesLabel(AppLocalizations l10n) => l10n.salesGroupTitle;
String _usersLabel(AppLocalizations l10n) => l10n.usersMenuTitle;
String _userProfilesLabel(AppLocalizations l10n) => l10n.userProfilesMenuTitle;
String _productsLabel(AppLocalizations l10n) => l10n.productsTitle;
String _priceListsLabel(AppLocalizations l10n) => l10n.priceListsMenuTitle;
String _pricingLabel(AppLocalizations l10n) => l10n.pricingMenuTitle;
String _exchangeRatesLabel(AppLocalizations l10n) =>
    l10n.exchangeRatesMenuTitle;
String _suppliersLabel(AppLocalizations l10n) => l10n.suppliersMenuTitle;
String _labelsLabel(AppLocalizations l10n) => l10n.labelsMenuTitle;
String _employeesLabel(AppLocalizations l10n) => l10n.employeesMenuTitle;
String _customersLabel(AppLocalizations l10n) => l10n.customersMenuTitle;
String _taxpayerRecipientsLabel(AppLocalizations l10n) =>
    l10n.taxpayerRecipientsMenuTitle;
String _expensesLabel(AppLocalizations l10n) => l10n.expensesMenuTitle;
String _vehiclesLabel(AppLocalizations l10n) => l10n.vehiclesMenuTitle;
String _vehicleOperatorsLabel(AppLocalizations l10n) =>
    l10n.vehicleOperatorsMenuTitle;
String _facilitiesLabel(AppLocalizations l10n) => l10n.facilitiesMenuTitle;
String _paymentMethodOptionsLabel(AppLocalizations l10n) =>
    l10n.paymentMethodOptionsMenuTitle;
String _taxpayerIssuersLabel(AppLocalizations l10n) =>
    l10n.taxpayerIssuersMenuTitle;
String _cashSessionsLabel(AppLocalizations l10n) => l10n.cashSessionsMenuTitle;
String _posLabel(AppLocalizations l10n) => l10n.posMenuTitle;
String _salesOrdersLabel(AppLocalizations l10n) => l10n.salesOrdersMenuTitle;

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
  return switch (d.gate) {
    null => true,
    PrivilegeGate(:final object, :final right) => access.can(object, right),
    AdministratorGate() => access.isAdministrator,
  };
}
