import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/config/app_settings_provider.dart';
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
  // above, under Operación, versus `facilities`, under Sistema).
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

  // 040-sales-quotes: appended last, same rationale as `cashSessions`
  // above — display order comes from position within `kNavigationTree`
  // (this destination sits right after `sales-orders` there).
  static const int salesQuotes = 21;

  // 054-payments-list-search: appended last, same rationale as `cashSessions`
  // above — display order comes from position within `kNavigationTree` (this
  // destination sits right after `cash-sessions` there).
  static const int salesPayments = 22;

  // 056-credit-notes: appended last, same rationale as `cashSessions` above —
  // display order comes from position within `kNavigationTree` (this
  // destination sits right after `payments` there).
  static const int creditNotes = 23;

  // 057-customer-refunds: appended last, same rationale as `cashSessions`
  // above — display order comes from position within `kNavigationTree` (this
  // destination sits right after `credit-notes` there).
  static const int customerRefunds = 24;

  // 060-payment-verification: appended last, same rationale as `cashSessions`
  // above — display order comes from position within `kNavigationTree` (this
  // destination sits right after `payments` there).
  static const int paymentVerification = 25;

  // 061-delivery-orders: appended last, same rationale as `cashSessions`
  // above — display order comes from position within `kNavigationTree` (this
  // destination is in Operación there).
  static const int deliveryOrders = 26;

  // 062-delivery-order-approval: appended last, same rationale as
  // `cashSessions` above — display order comes from position within
  // `kNavigationTree` (this destination sits right after `deliveryOrders` in
  // Operación there).
  static const int deliveryOrderApproval = 27;

  // 063-for-delivery-queue: appended last, same rationale as `cashSessions`
  // above — display order comes from position within `kNavigationTree` (this
  // destination sits right after `deliveryOrderApproval` in Operación
  // there).
  static const int forDelivery = 28;

  // 066-invoice-list-editor: appended last, same rationale as `cashSessions`
  // above — display order comes from position within `kNavigationTree` (the
  // destination is in Finanzas there).
  static const int fiscalDocuments = 29;

  // 067-warehouse-receipts: appended last, same rationale as `cashSessions`
  // above — display order comes from position within `kNavigationTree` (the
  // destination opens the Inventario group there).
  static const int inventoryReceipts = 30;

  // 068-warehouse-issues: appended last, same rationale as `cashSessions`
  // above — display order comes from position within `kNavigationTree` (the
  // second destination of the Inventario group there).
  static const int inventoryIssues = 31;

  // 069-inventory-transfers: appended last, same rationale as `cashSessions`
  // above — display order comes from position within `kNavigationTree` (the
  // third destination of the Inventario group there).
  static const int inventoryTransfers = 32;

  // 070-inventory-adjustments-count: appended last, same rationale as
  // `cashSessions` above — display order comes from position within
  // `kNavigationTree` (the fourth destination of the Inventario group there).
  static const int inventoryCounts = 33;

  // 071-stock-kardex: appended last, same rationale as `cashSessions` above
  // — display order comes from position within `kNavigationTree` (the fifth
  // destination of the Inventario group there).
  static const int inventoryStock = 34;

  // 071-stock-kardex: appended last, same rationale as `cashSessions` above
  // — display order comes from position within `kNavigationTree` (the sixth
  // destination of the Inventario group there).
  static const int inventoryKardex = 35;

  // 075-delivery-itineraries: appended last, same rationale as `cashSessions`
  // above — display order comes from position within `kNavigationTree` (the
  // destination sits after `forDelivery` in Operación there).
  static const int deliveryItineraries = 36;

  // 078-commissions: appended last, same rationale as `deliveryItineraries`
  // above — the destination sits after Gastos in Finanzas in `kNavigationTree`.
  static const int commissions = 37;
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
  // Operación (spec 077): the day-to-day selling and delivering work.
  NavGroup(
    id: 'operation',
    label: _operationLabel,
    children: [
      NavDestination(
        id: 'pos',
        label: _posLabel,
        icon: Icons.shopping_cart_outlined,
        selectedIcon: Icons.shopping_cart,
        route: '/sales/pos',
        branchIndex: NavBranch.pos,
        gate: PrivilegeGate(SystemObject.pos, AccessRight.read),
      ),
      // 037-sales-order-refinements: moved after Point of Sale — the
      // register is the more frequently used destination. This changes
      // display order only: still gated on `salesOrders`, not `pos`, so a
      // back-office salesperson with no register privilege still reaches it
      // (FR-020, FR-021).
      NavDestination(
        id: 'sales-orders',
        label: _salesOrdersLabel,
        icon: Icons.receipt_long_outlined,
        selectedIcon: Icons.receipt_long,
        route: '/sales/orders',
        branchIndex: NavBranch.salesOrders,
        gate: PrivilegeGate(SystemObject.salesOrders, AccessRight.read),
      ),
      // 040-sales-quotes: placed after Pedidos, before nothing — quotes are
      // the document that precedes an order, so it sits next to it.
      NavDestination(
        id: 'sales-quotes',
        label: _salesQuotesLabel,
        icon: Icons.request_quote_outlined,
        selectedIcon: Icons.request_quote,
        route: '/sales/quotes',
        branchIndex: NavBranch.salesQuotes,
        gate: PrivilegeGate(SystemObject.salesQuotes, AccessRight.read),
      ),
      NavDestination(
        id: 'pricing',
        label: _pricingLabel,
        icon: Icons.price_change_outlined,
        selectedIcon: Icons.price_change,
        route: '/pricing',
        branchIndex: NavBranch.pricing,
        gate: PrivilegeGate(SystemObject.pricing, AccessRight.read),
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
        id: 'cash-sessions',
        label: _cashSessionsLabel,
        icon: Icons.point_of_sale_outlined,
        selectedIcon: Icons.point_of_sale,
        route: '/sales/cash-sessions',
        branchIndex: NavBranch.cashSessions,
        gate: PrivilegeGate(SystemObject.pos, AccessRight.read),
      ),
      // 061-delivery-orders: in Operación, after cash sessions. Gated on SystemObject 71
      // (`deliveryOrders`) read, matching the server's GET /delivery-orders.
      // The route stays under /sales/ (only the nav entry moved).
      NavDestination(
        id: 'delivery-orders',
        label: _deliveryOrdersLabel,
        icon: Icons.delivery_dining_outlined,
        selectedIcon: Icons.delivery_dining,
        route: '/sales/delivery-orders',
        branchIndex: NavBranch.deliveryOrders,
        gate: PrivilegeGate(SystemObject.deliveryOrders, AccessRight.read),
      ),
      // 062-delivery-order-approval: right after Órdenes de entrega. Gated on
      // SystemObject 94 (`deliveryOrderApproval`) read, matching the server's
      // GET /delivery-orders/approval. Approving and rejecting need 94 update,
      // checked on the screen and the detail screen.
      NavDestination(
        id: 'delivery-order-approval',
        label: _deliveryOrderApprovalLabel,
        icon: Icons.fact_check_outlined,
        selectedIcon: Icons.fact_check,
        route: '/sales/delivery-order-approval',
        branchIndex: NavBranch.deliveryOrderApproval,
        gate: PrivilegeGate(
          SystemObject.deliveryOrderApproval,
          AccessRight.read,
        ),
      ),
      // 063-for-delivery-queue: right after Aprobación de entregas. Gated on
      // SystemObject 91 (`forDeliver`) read, matching the server's GET
      // /delivery-itineraries/deliveries. The queue has no actions; opening
      // an order from a row needs 71 read, checked on the screen.
      NavDestination(
        id: 'for-delivery',
        label: _forDeliveryLabel,
        icon: Icons.local_shipping_outlined,
        selectedIcon: Icons.local_shipping,
        route: '/sales/for-delivery',
        branchIndex: NavBranch.forDelivery,
        gate: PrivilegeGate(SystemObject.forDeliver, AccessRight.read),
      ),
      // 075-delivery-itineraries: right after Por entregar. Gated on
      // SystemObject 87 (`deliveryItineraries`) read, matching the server's
      // GET /delivery-itineraries. Creating needs 87 create; every other
      // write needs 87 update, checked on the screens.
      NavDestination(
        id: 'delivery-itineraries',
        label: _deliveryItinerariesLabel,
        icon: Icons.route_outlined,
        selectedIcon: Icons.route,
        route: '/sales/delivery-itineraries',
        branchIndex: NavBranch.deliveryItineraries,
        gate: PrivilegeGate(SystemObject.deliveryItineraries, AccessRight.read),
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
    ],
  ),
  // Inventario: warehouse documents and stock, with the catalogs that describe what is stocked.
  NavGroup(
    id: 'inventory',
    label: _inventoryLabel,
    children: [
      // Gated on SystemObject 15 (`inventoryReceipts`) read, matching the
      // server's GET /inventory-receipts. Creating and editing need 15 create
      // and update, checked on the screens.
      NavDestination(
        id: 'inventory-receipts',
        label: _inventoryReceiptsLabel,
        icon: Icons.move_to_inbox_outlined,
        selectedIcon: Icons.move_to_inbox,
        route: '/inventory/receipts',
        branchIndex: NavBranch.inventoryReceipts,
        gate: PrivilegeGate(SystemObject.inventoryReceipts, AccessRight.read),
      ),
      // Gated on SystemObject 16 (`inventoryIssues`) read, matching the
      // server's GET /inventory-issues. Creating and editing need 16 create
      // and update, checked on the screens.
      NavDestination(
        id: 'inventory-issues',
        label: _inventoryIssuesLabel,
        icon: Icons.outbox_outlined,
        selectedIcon: Icons.outbox,
        route: '/inventory/issues',
        branchIndex: NavBranch.inventoryIssues,
        gate: PrivilegeGate(SystemObject.inventoryIssues, AccessRight.read),
      ),
      // Gated on SystemObject 17 (`inventoryTransfers`) read, matching the
      // server's GET /inventory-transfers. Creating, editing and the other
      // actions need 17 create, update and delete, checked on the screens.
      NavDestination(
        id: 'inventory-transfers',
        label: _inventoryTransfersLabel,
        icon: Icons.swap_horiz_outlined,
        selectedIcon: Icons.swap_horiz,
        route: '/inventory/transfers',
        branchIndex: NavBranch.inventoryTransfers,
        gate: PrivilegeGate(SystemObject.inventoryTransfers, AccessRight.read),
      ),
      // Gated on SystemObject 74 (`physicalCountAdjustment`) read, matching
      // the server's GET /inventory-counts. Creating, editing, confirming and
      // cancelling need 74 create, update and delete, checked on the screens.
      NavDestination(
        id: 'inventory-counts',
        label: _inventoryCountsLabel,
        icon: Icons.fact_check_outlined,
        selectedIcon: Icons.fact_check,
        route: '/inventory/counts',
        branchIndex: NavBranch.inventoryCounts,
        gate: PrivilegeGate(
          SystemObject.physicalCountAdjustment,
          AccessRight.read,
        ),
      ),
      // Existencias (spec 071): gated on WarehouseStockReport (SystemObject
      // 67) read, matching the server's GET /stock.
      NavDestination(
        id: 'inventory-stock',
        label: _inventoryStockLabel,
        icon: Icons.inventory_2_outlined,
        selectedIcon: Icons.inventory_2,
        route: '/inventory/stock',
        branchIndex: NavBranch.inventoryStock,
        gate: PrivilegeGate(
          SystemObject.warehouseStockReport,
          AccessRight.read,
        ),
      ),
      // Kardex (spec 071): gated on Kardex (SystemObject 32) read, matching
      // the server's GET /kardex.
      NavDestination(
        id: 'inventory-kardex',
        label: _inventoryKardexLabel,
        icon: Icons.receipt_long_outlined,
        selectedIcon: Icons.receipt_long,
        route: '/inventory/kardex',
        branchIndex: NavBranch.inventoryKardex,
        gate: PrivilegeGate(SystemObject.kardex, AccessRight.read),
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
    ],
  ),
  // Finanzas: money in and out, and the fiscal documents.
  NavGroup(
    id: 'finance',
    label: _financeLabel,
    children: [
      // 054-payments-list-search: next to the cash sessions it relates to.
      // Gated on `customerPayments`, not `pos` — a payment is permissioned
      // separately server-side, so an accountant without a register still
      // reaches it.
      NavDestination(
        id: 'payments',
        label: _paymentsLabel,
        icon: Icons.payments_outlined,
        selectedIcon: Icons.payments,
        route: '/sales/payments',
        branchIndex: NavBranch.salesPayments,
        gate: PrivilegeGate(SystemObject.customerPayments, AccessRight.read),
      ),
      // 060-payment-verification: gated on `paymentsVerification` (108) read,
      // matching the server's /customer-payments/unverified — not on
      // `customerPayments`, since verification is a separate right and a
      // verifier needs none of the others.
      NavDestination(
        id: 'payment-verification',
        label: _paymentVerificationLabel,
        icon: Icons.fact_check_outlined,
        selectedIcon: Icons.fact_check,
        route: '/sales/payment-verification',
        branchIndex: NavBranch.paymentVerification,
        gate: PrivilegeGate(
          SystemObject.paymentsVerification,
          AccessRight.read,
        ),
      ),
      // Gated on `creditPayments` (83), matching the server's credit-notes
      // read; the payment a note opens is gated separately, on
      // `customerPayments`, when the user taps a row.
      NavDestination(
        id: 'credit-notes',
        label: _creditNotesLabel,
        icon: Icons.receipt_long_outlined,
        selectedIcon: Icons.receipt_long,
        route: '/sales/credit-notes',
        branchIndex: NavBranch.creditNotes,
        gate: PrivilegeGate(SystemObject.creditPayments, AccessRight.read),
      ),
      NavDestination(
        id: 'refunds',
        label: _refundsLabel,
        icon: Icons.assignment_return_outlined,
        selectedIcon: Icons.assignment_return,
        route: '/sales/refunds',
        branchIndex: NavBranch.customerRefunds,
        gate: PrivilegeGate(SystemObject.customerRefunds, AccessRight.read),
      ),
      // Gated on SystemObject 23 (`fiscalDocuments`) read, matching the
      // server's GET /fiscal-documents. Creating and editing need 23 create
      // and update, checked on the screens.
      NavDestination(
        id: 'fiscal-documents',
        label: _fiscalDocumentsLabel,
        icon: Icons.description_outlined,
        selectedIcon: Icons.description,
        route: '/invoicing/fiscal-documents',
        branchIndex: NavBranch.fiscalDocuments,
        gate: PrivilegeGate(SystemObject.fiscalDocuments, AccessRight.read),
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
        id: 'taxpayer-recipients',
        label: _taxpayerRecipientsLabel,
        icon: Icons.receipt_long_outlined,
        selectedIcon: Icons.receipt_long,
        route: '/taxpayer-recipients',
        branchIndex: NavBranch.taxpayerRecipients,
        gate: PrivilegeGate(SystemObject.taxpayerRecipients, AccessRight.read),
      ),
      NavDestination(
        id: 'exchange-rates',
        label: _exchangeRatesLabel,
        icon: Icons.currency_exchange_outlined,
        selectedIcon: Icons.currency_exchange,
        route: '/exchange-rates',
        branchIndex: NavBranch.exchangeRates,
        gate: PrivilegeGate(SystemObject.exchangeRates, AccessRight.read),
        requiresMultiCurrency: true,
      ),
      // spec 015: Payment Method Options is a fiscal catalog, in Finanzas beside
      // its Taxpayer Issuers/Certificates counterparts (contracts/routes.md).
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
      NavDestination(
        id: 'expenses',
        label: _expensesLabel,
        icon: Icons.payments_outlined,
        selectedIcon: Icons.payments,
        route: '/expenses',
        branchIndex: NavBranch.expenses,
        gate: PrivilegeGate(SystemObject.expenses, AccessRight.read),
      ),
      // Gated on SystemObject 112 (`commissionsBySalesPerson`) read, matching
      // the server's GET /commissions/periods.
      NavDestination(
        id: 'commissions',
        label: _commissionsLabel,
        icon: Icons.percent_outlined,
        selectedIcon: Icons.percent,
        route: '/commissions',
        branchIndex: NavBranch.commissions,
        gate: PrivilegeGate(
          SystemObject.commissionsBySalesPerson,
          AccessRight.read,
        ),
      ),
    ],
  ),
  // Sistema: administration of people and places.
  NavGroup(
    id: 'system',
    label: _systemLabel,
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
        id: 'employees',
        label: _employeesLabel,
        icon: Icons.badge_outlined,
        selectedIcon: Icons.badge,
        route: '/employees',
        branchIndex: NavBranch.employees,
        gate: PrivilegeGate(SystemObject.employees, AccessRight.read),
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
    ],
  ),
];

// Label resolvers kept as top-level tear-offs so [kNavigationTree] stays const.
String _homeLabel(AppLocalizations l10n) => l10n.homeMenuTitle;
String _operationLabel(AppLocalizations l10n) => l10n.navOperationGroup;
String _financeLabel(AppLocalizations l10n) => l10n.navFinanceGroup;
String _systemLabel(AppLocalizations l10n) => l10n.navSystemGroup;
String _inventoryLabel(AppLocalizations l10n) => l10n.navInventoryGroup;
String _inventoryReceiptsLabel(AppLocalizations l10n) =>
    l10n.navInventoryReceipts;
String _inventoryIssuesLabel(AppLocalizations l10n) => l10n.navInventoryIssues;
String _inventoryTransfersLabel(AppLocalizations l10n) =>
    l10n.navInventoryTransfers;
String _inventoryCountsLabel(AppLocalizations l10n) => l10n.navInventoryCounts;
String _inventoryStockLabel(AppLocalizations l10n) => l10n.navInventoryStock;
String _inventoryKardexLabel(AppLocalizations l10n) => l10n.navInventoryKardex;
String _fiscalDocumentsLabel(AppLocalizations l10n) => l10n.navFiscalDocuments;
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
String _commissionsLabel(AppLocalizations l10n) => l10n.navCommissions;
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
String _salesQuotesLabel(AppLocalizations l10n) => l10n.salesQuotesMenuTitle;
String _deliveryOrdersLabel(AppLocalizations l10n) => l10n.navDeliveryOrders;
String _deliveryOrderApprovalLabel(AppLocalizations l10n) =>
    l10n.navDeliveryOrderApproval;
String _forDeliveryLabel(AppLocalizations l10n) => l10n.navForDelivery;
String _deliveryItinerariesLabel(AppLocalizations l10n) =>
    l10n.navDeliveryItineraries;
String _paymentsLabel(AppLocalizations l10n) => l10n.paymentsMenuTitle;
String _paymentVerificationLabel(AppLocalizations l10n) =>
    l10n.paymentVerificationMenuTitle;
String _creditNotesLabel(AppLocalizations l10n) => l10n.creditNotesMenuTitle;
String _refundsLabel(AppLocalizations l10n) => l10n.refundsMenuTitle;

/// The navigation tree filtered by the current user's access (constitution
/// §IV, FR-005/FR-006): destinations the user cannot read are removed, and a
/// group left with no visible children is dropped entirely (no empty header).
final navDestinationsProvider = Provider<List<NavItem>>((ref) {
  final access = ref.watch(accessControlProvider);
  final multiCurrency = ref.watch(multiCurrencyEnabledProvider);
  return _filterTree(kNavigationTree, access, multiCurrency);
});

/// Whether [location] belongs to a destination that exists only when the
/// deployment is multi-currency (spec 049 FR-004). Derived from
/// [kNavigationTree] so the menu and the router share one source of truth.
bool routeRequiresMultiCurrency(String location) {
  bool matches(NavDestination d) =>
      d.requiresMultiCurrency &&
      (location == d.route || location.startsWith('${d.route}/'));
  return kNavigationTree.any(
    (item) => switch (item) {
      NavDestination() => matches(item),
      NavGroup() => item.children.any(matches),
    },
  );
}

List<NavItem> _filterTree(
  List<NavItem> tree,
  AccessControlService access,
  bool multiCurrency,
) {
  final result = <NavItem>[];
  for (final item in tree) {
    switch (item) {
      case NavDestination():
        if (_isVisible(item, access, multiCurrency)) result.add(item);
      case NavGroup():
        final children = item.children
            .where((d) => _isVisible(d, access, multiCurrency))
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

bool _isVisible(
  NavDestination d,
  AccessControlService access,
  bool multiCurrency,
) {
  if (d.requiresMultiCurrency && !multiCurrency) return false;
  return switch (d.gate) {
    null => true,
    PrivilegeGate(:final object, :final right) => access.can(object, right),
    AdministratorGate() => access.isAdministrator,
  };
}
