import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/auth/presentation/account/change_password_screen.dart';
import 'package:mbe_ui/features/auth/presentation/account/forgot_password_screen.dart';
import 'package:mbe_ui/features/auth/presentation/admin/user_detail_screen.dart';
import 'package:mbe_ui/features/auth/presentation/admin/users_list_screen.dart';
import 'package:mbe_ui/features/auth/presentation/login/login_screen.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/widgets/app_shell.dart';
import 'package:mbe_ui/features/catalog/presentation/customer_detail_screen.dart';
import 'package:mbe_ui/features/catalog/presentation/customers_list_screen.dart';
import 'package:mbe_ui/features/catalog/presentation/employee_detail_screen.dart';
import 'package:mbe_ui/features/catalog/presentation/employees_list_screen.dart';
import 'package:mbe_ui/features/catalog/presentation/expense_detail_screen.dart';
import 'package:mbe_ui/features/catalog/presentation/expenses_list_screen.dart';
import 'package:mbe_ui/features/catalog/presentation/label_detail_screen.dart';
import 'package:mbe_ui/features/catalog/presentation/labels_list_screen.dart';
import 'package:mbe_ui/features/catalog/presentation/merge_products_screen.dart';
import 'package:mbe_ui/features/catalog/presentation/product_detail_screen.dart';
import 'package:mbe_ui/features/catalog/presentation/products_list_screen.dart';
import 'package:mbe_ui/features/catalog/presentation/supplier_detail_screen.dart';
import 'package:mbe_ui/features/catalog/presentation/suppliers_list_screen.dart';
import 'package:mbe_ui/features/catalog/presentation/taxpayer_recipient_detail_screen.dart';
import 'package:mbe_ui/features/catalog/presentation/taxpayer_recipients_list_screen.dart';
import 'package:mbe_ui/features/catalog/presentation/vehicle_detail_screen.dart';
import 'package:mbe_ui/features/catalog/presentation/vehicle_operator_detail_screen.dart';
import 'package:mbe_ui/features/catalog/presentation/vehicle_operators_list_screen.dart';
import 'package:mbe_ui/features/catalog/presentation/cash_drawer_detail_screen.dart';
import 'package:mbe_ui/features/catalog/presentation/facilities_list_screen.dart';
import 'package:mbe_ui/features/catalog/presentation/facility_detail_screen.dart';
import 'package:mbe_ui/features/catalog/presentation/payment_method_option_detail_screen.dart';
import 'package:mbe_ui/features/catalog/presentation/payment_method_options_list_screen.dart';
import 'package:mbe_ui/features/catalog/presentation/point_sale_detail_screen.dart';
import 'package:mbe_ui/features/catalog/presentation/taxpayer_issuer_detail_screen.dart';
import 'package:mbe_ui/features/catalog/presentation/taxpayer_issuers_list_screen.dart';
import 'package:mbe_ui/features/catalog/presentation/vehicles_list_screen.dart';
import 'package:mbe_ui/features/catalog/presentation/warehouse_detail_screen.dart';
import 'package:mbe_ui/features/home/presentation/home_screen.dart';
import 'package:mbe_ui/features/pricing/presentation/exchange_rate_detail_screen.dart';
import 'package:mbe_ui/features/pricing/presentation/exchange_rates_list_screen.dart';
import 'package:mbe_ui/features/pricing/presentation/price_list_detail_screen.dart';
import 'package:mbe_ui/features/pricing/presentation/price_lists_list_screen.dart';
import 'package:mbe_ui/features/pricing/presentation/pricing_screen.dart';
import 'package:mbe_ui/features/sales/presentation/cash_session_detail_screen.dart';
import 'package:mbe_ui/features/sales/presentation/cash_sessions_screen.dart';
import 'package:mbe_ui/features/sales/presentation/pos_sales_list_screen.dart';
import 'package:mbe_ui/features/sales/presentation/pos_workspace_screen.dart';

/// Redirect guard skeleton (contracts/routes.md "Redirect guard summary").
/// Routes are registered by later phases; this provider gives them a
/// shared `GoRouter` instance to register against.
final goRouterProvider = Provider<GoRouter>((ref) {
  final refreshListenable = _AuthRefreshListenable(ref);
  ref.onDispose(refreshListenable.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refreshListenable,
    redirect: (context, state) => _redirect(ref, state),
    routes: [
      // Authenticated destinations live inside the shell: one branch per
      // top-level destination, so each keeps its own navigation state
      // (spec 010 US1; research.md §1). Detail/form/merge and /auth/* routes
      // are top-level siblings below — they render full-screen (no rail).
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/users',
                builder: (context, state) =>
                    UsersListScreen(query: ListQuery.fromUri(state.uri)),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/products',
                builder: (context, state) =>
                    ProductsListScreen(query: ListQuery.fromUri(state.uri)),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/price-lists',
                builder: (context, state) =>
                    PriceListsListScreen(query: ListQuery.fromUri(state.uri)),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/pricing',
                builder: (context, state) => const PricingScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/exchange-rates',
                builder: (context, state) => ExchangeRatesListScreen(
                  query: ListQuery.fromUri(state.uri),
                ),
              ),
            ],
          ),
          // Branch index is positional (contracts/routes.md §1, spec 012):
          // each new branch below is appended at the next available index,
          // in build order (Suppliers→Labels→Employees→Customers→
          // TaxpayerRecipients), not a pre-reserved slot.
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/suppliers',
                builder: (context, state) =>
                    SuppliersListScreen(query: ListQuery.fromUri(state.uri)),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/labels',
                builder: (context, state) =>
                    LabelsListScreen(query: ListQuery.fromUri(state.uri)),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/employees',
                builder: (context, state) =>
                    EmployeesListScreen(query: ListQuery.fromUri(state.uri)),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/customers',
                builder: (context, state) =>
                    CustomersListScreen(query: ListQuery.fromUri(state.uri)),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/taxpayer-recipients',
                builder: (context, state) => TaxpayerRecipientsListScreen(
                  query: ListQuery.fromUri(state.uri),
                ),
              ),
            ],
          ),
          // Branch index continues positionally from spec 012's last branch
          // (taxpayerRecipients = 10): spec 013 appends Expenses(11)→
          // Vehicles(12)→VehicleOperators(13) in build order
          // (contracts/routes.md §1).
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/expenses',
                builder: (context, state) =>
                    ExpensesListScreen(query: ListQuery.fromUri(state.uri)),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/vehicles',
                builder: (context, state) =>
                    VehiclesListScreen(query: ListQuery.fromUri(state.uri)),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/vehicle-operators',
                builder: (context, state) => VehicleOperatorsListScreen(
                  query: ListQuery.fromUri(state.uri),
                ),
              ),
            ],
          ),
          // Branch index continues positionally from spec 013's last branch
          // (vehicleOperators = 13): 018-nested-facility-management removed
          // the standalone Warehouses/CashDrawers/PointsOfSale branches spec
          // 014 had appended here — those catalogs no longer have their own
          // list screens, only their record detail routes survive (below) —
          // so Facilities is now this branch, followed by
          // PaymentMethodOptions and TaxpayerIssuers from spec 015
          // (contracts/routes.md §2). There is NO taxpayerCertificates
          // branch — Taxpayer Certificates is a child section of the
          // Taxpayer Issuer detail, not a standalone catalog (spec 015
          // research.md §9).
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/facilities',
                builder: (context, state) =>
                    FacilitiesListScreen(query: ListQuery.fromUri(state.uri)),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/payment-method-options',
                builder: (context, state) => PaymentMethodOptionsListScreen(
                  query: ListQuery.fromUri(state.uri),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/taxpayer-issuers',
                builder: (context, state) => TaxpayerIssuersListScreen(
                  query: ListQuery.fromUri(state.uri),
                ),
              ),
            ],
          ),
          // 021-cash-sessions: appended last (index 17) — the nested
          // /sales/... form deliberately diverges from the 15 flat business
          // routes above (research.md §1).
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/sales/cash-sessions',
                builder: (context, state) =>
                    CashSessionsScreen(query: ListQuery.fromUri(state.uri)),
              ),
            ],
          ),
          // 020-point-of-sale: appended after cash-sessions (index 18) — same
          // append-don't-renumber rationale (nav_destinations.dart NavBranch).
          //
          // 023-pos-ux-improvements: this branch now renders the register's
          // sales list (`PosSalesListScreen`) rather than the sale capture
          // surface itself — the sale moved to the top-level
          // `/sales/pos/new` / `/sales/pos/:saleId` routes below, alongside
          // every other record's detail route, so it can render full-screen
          // with no rail (spec 023 research R1, contracts/pos-workspace.md).
          // The branch index and the `pos` gate are unchanged.
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/sales/pos',
                builder: (context, state) =>
                    PosSalesListScreen(query: ListQuery.fromUri(state.uri)),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/account/password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/auth/recover',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/users/new',
        builder: (context, state) => const UserDetailScreen(),
      ),
      GoRoute(
        path: '/users/:userId',
        builder: (context, state) => UserDetailScreen(
          userId: state.pathParameters['userId'],
          forceReadOnly: state.uri.queryParameters['view'] == 'true',
        ),
      ),
      GoRoute(
        path: '/products/new',
        builder: (context, state) => const ProductDetailScreen(),
      ),
      GoRoute(
        path: '/products/merge',
        builder: (context, state) => const MergeProductsScreen(),
      ),
      GoRoute(
        path: '/products/:productId',
        builder: (context, state) => ProductDetailScreen(
          productId: int.parse(state.pathParameters['productId']!),
          forceReadOnly: state.uri.queryParameters['view'] == 'true',
        ),
      ),
      GoRoute(
        path: '/products/:productId/pricing',
        builder: (context, state) => PricingScreen(
          initialProductId: int.parse(state.pathParameters['productId']!),
          initialProductDisplayText:
              state.uri.queryParameters['productDisplayText'],
          standalone: true,
        ),
      ),
      GoRoute(
        path: '/price-lists/new',
        builder: (context, state) => const PriceListDetailScreen(),
      ),
      GoRoute(
        path: '/price-lists/:priceListId',
        builder: (context, state) => PriceListDetailScreen(
          priceListId: int.parse(state.pathParameters['priceListId']!),
          forceReadOnly: state.uri.queryParameters['view'] == 'true',
        ),
      ),
      GoRoute(
        path: '/exchange-rates/new',
        builder: (context, state) => const ExchangeRateDetailScreen(),
      ),
      GoRoute(
        path: '/exchange-rates/:exchangeRateId',
        builder: (context, state) => ExchangeRateDetailScreen(
          exchangeRateId: int.parse(state.pathParameters['exchangeRateId']!),
          forceReadOnly: state.uri.queryParameters['view'] == 'true',
        ),
      ),
      GoRoute(
        path: '/suppliers/new',
        builder: (context, state) => const SupplierDetailScreen(),
      ),
      GoRoute(
        path: '/suppliers/:supplierId',
        builder: (context, state) => SupplierDetailScreen(
          supplierId: int.parse(state.pathParameters['supplierId']!),
          forceReadOnly: state.uri.queryParameters['view'] == 'true',
        ),
      ),
      GoRoute(
        path: '/labels/new',
        builder: (context, state) => const LabelDetailScreen(),
      ),
      GoRoute(
        path: '/labels/:labelId',
        builder: (context, state) => LabelDetailScreen(
          labelId: int.parse(state.pathParameters['labelId']!),
          forceReadOnly: state.uri.queryParameters['view'] == 'true',
        ),
      ),
      GoRoute(
        path: '/employees/new',
        builder: (context, state) => const EmployeeDetailScreen(),
      ),
      GoRoute(
        path: '/employees/:employeeId',
        builder: (context, state) => EmployeeDetailScreen(
          employeeId: int.parse(state.pathParameters['employeeId']!),
          forceReadOnly: state.uri.queryParameters['view'] == 'true',
        ),
      ),
      GoRoute(
        path: '/customers/new',
        builder: (context, state) => const CustomerDetailScreen(),
      ),
      GoRoute(
        path: '/customers/:customerId',
        builder: (context, state) => CustomerDetailScreen(
          customerId: int.parse(state.pathParameters['customerId']!),
          forceReadOnly: state.uri.queryParameters['view'] == 'true',
        ),
      ),
      GoRoute(
        path: '/taxpayer-recipients/new',
        builder: (context, state) => const TaxpayerRecipientDetailScreen(),
      ),
      GoRoute(
        // String path param — taxpayerRecipientId is a client-supplied RFC,
        // not a server-assigned int (research.md §9); no int.parse here.
        path: '/taxpayer-recipients/:taxpayerRecipientId',
        builder: (context, state) => TaxpayerRecipientDetailScreen(
          taxpayerRecipientId: state.pathParameters['taxpayerRecipientId'],
          forceReadOnly: state.uri.queryParameters['view'] == 'true',
        ),
      ),
      GoRoute(
        path: '/expenses/new',
        builder: (context, state) => const ExpenseDetailScreen(),
      ),
      GoRoute(
        path: '/expenses/:expenseId',
        builder: (context, state) => ExpenseDetailScreen(
          expenseId: int.parse(state.pathParameters['expenseId']!),
          forceReadOnly: state.uri.queryParameters['view'] == 'true',
        ),
      ),
      GoRoute(
        path: '/vehicles/new',
        builder: (context, state) => const VehicleDetailScreen(),
      ),
      GoRoute(
        path: '/vehicles/:vehicleId',
        builder: (context, state) => VehicleDetailScreen(
          vehicleId: int.parse(state.pathParameters['vehicleId']!),
          forceReadOnly: state.uri.queryParameters['view'] == 'true',
        ),
      ),
      GoRoute(
        path: '/vehicle-operators/new',
        builder: (context, state) => const VehicleOperatorDetailScreen(),
      ),
      GoRoute(
        path: '/vehicle-operators/:vehicleOperatorId',
        builder: (context, state) => VehicleOperatorDetailScreen(
          vehicleOperatorId: int.parse(
            state.pathParameters['vehicleOperatorId']!,
          ),
          forceReadOnly: state.uri.queryParameters['view'] == 'true',
        ),
      ),
      GoRoute(
        path: '/warehouses/new',
        // `?facility=<id>` pre-selects the parent facility when reached from
        // a facility card's "+ Almacén" (018-nested-facility-management
        // FR-022/FR-023, contracts/routes.md §4). Absent/unparseable is
        // `null` — the form opens with an empty picker, unchanged.
        builder: (context, state) => WarehouseDetailScreen(
          facilityId: int.tryParse(state.uri.queryParameters['facility'] ?? ''),
        ),
      ),
      GoRoute(
        path: '/warehouses/:warehouseId',
        builder: (context, state) => WarehouseDetailScreen(
          warehouseId: int.parse(state.pathParameters['warehouseId']!),
          forceReadOnly: state.uri.queryParameters['view'] == 'true',
        ),
      ),
      GoRoute(
        path: '/cash-drawers/new',
        builder: (context, state) => CashDrawerDetailScreen(
          facilityId: int.tryParse(state.uri.queryParameters['facility'] ?? ''),
        ),
      ),
      GoRoute(
        path: '/cash-drawers/:cashDrawerId',
        builder: (context, state) => CashDrawerDetailScreen(
          cashDrawerId: int.parse(state.pathParameters['cashDrawerId']!),
          forceReadOnly: state.uri.queryParameters['view'] == 'true',
        ),
      ),
      GoRoute(
        path: '/points-of-sale/new',
        builder: (context, state) => PointSaleDetailScreen(
          facilityId: int.tryParse(state.uri.queryParameters['facility'] ?? ''),
        ),
      ),
      GoRoute(
        path: '/points-of-sale/:pointSaleId',
        builder: (context, state) => PointSaleDetailScreen(
          pointSaleId: int.parse(state.pathParameters['pointSaleId']!),
          forceReadOnly: state.uri.queryParameters['view'] == 'true',
        ),
      ),
      GoRoute(
        path: '/facilities/new',
        builder: (context, state) => const FacilityDetailScreen(),
      ),
      GoRoute(
        path: '/facilities/:facilityId',
        builder: (context, state) => FacilityDetailScreen(
          facilityId: int.parse(state.pathParameters['facilityId']!),
          forceReadOnly: state.uri.queryParameters['view'] == 'true',
        ),
      ),
      GoRoute(
        path: '/payment-method-options/new',
        builder: (context, state) => const PaymentMethodOptionDetailScreen(),
      ),
      GoRoute(
        path: '/payment-method-options/:paymentMethodOptionId',
        builder: (context, state) => PaymentMethodOptionDetailScreen(
          paymentMethodOptionId: int.parse(
            state.pathParameters['paymentMethodOptionId']!,
          ),
          forceReadOnly: state.uri.queryParameters['view'] == 'true',
        ),
      ),
      GoRoute(
        path: '/taxpayer-issuers/new',
        builder: (context, state) => const TaxpayerIssuerDetailScreen(),
      ),
      GoRoute(
        // String path param — rfc is a client-supplied identity, not a
        // server-assigned int (spec 015 contracts/routes.md); no int.parse.
        path: '/taxpayer-issuers/:rfc',
        builder: (context, state) => TaxpayerIssuerDetailScreen(
          rfc: state.pathParameters['rfc'],
          forceReadOnly: state.uri.queryParameters['view'] == 'true',
        ),
      ),
      // 021-cash-sessions: no `/new` sibling — a session is opened from the
      // shift panel on the list screen itself, not a dedicated create form.
      // No `forceReadOnly` param — a session has no editable form to toggle
      // (contracts/routes.md §1).
      GoRoute(
        path: '/sales/cash-sessions/:cashSessionId',
        builder: (context, state) => CashSessionDetailScreen(
          cashSessionId: int.parse(state.pathParameters['cashSessionId']!),
        ),
      ),
      // 023-pos-ux-improvements: top-level siblings, not shell branches — the
      // sale workspace renders full-screen with no rail (contracts/
      // pos-workspace.md §1). `/new` opens with no sale until the first real
      // action; `:saleId` loads an existing one. Both share the `pos` read
      // gate the `/sales/pos` prefix already covers (see `_routeGate` below).
      GoRoute(
        path: '/sales/pos/new',
        builder: (context, state) => const PosWorkspaceScreen(),
      ),
      GoRoute(
        path: '/sales/pos/:saleId',
        builder: (context, state) => PosWorkspaceScreen(
          saleId: int.parse(state.pathParameters['saleId']!),
        ),
      ),
    ],
  );
});

/// Notifies `GoRouter` to re-run [_redirect] whenever [authNotifierProvider]
/// changes — including the `401`-triggered transition to `unauthenticated`
/// (FR-003, SC-003; research.md §4).
class _AuthRefreshListenable extends ChangeNotifier {
  _AuthRefreshListenable(Ref ref) {
    _subscription = ref.listen(
      authNotifierProvider,
      (_, _) => notifyListeners(),
    );
  }

  late final ProviderSubscription<AsyncValue<AuthState>> _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}

String? _redirect(Ref ref, GoRouterState state) {
  final authState = ref.read(authNotifierProvider).valueOrNull;
  // Still loading/erroring: let it settle, refreshListenable will re-run
  // this once `authNotifierProvider` resolves.
  if (authState == null || authState is AuthAuthenticating) return null;

  final isAuthRoute = state.matchedLocation.startsWith('/auth/');
  // Unlike the rest of /auth/*, this screen requires an active session
  // (FR-009 "a signed-in user"); /auth/recover is for users who can't sign in.
  final requiresSession = state.matchedLocation == '/auth/account/password';

  if (authState is AuthUnauthenticated) {
    if (requiresSession) return '/auth/login';
    return isAuthRoute ? null : '/auth/login';
  }

  if (state.matchedLocation == '/auth/login') return '/';

  final gate = _routeGate(state.matchedLocation);
  if (gate != null &&
      !ref.read(accessControlProvider).can(gate.object, gate.right)) {
    return '/';
  }
  return null;
}

/// The `(SystemObject, AccessRight)` gate for a route, per
/// contracts/routes.md. Returns `null` for unguarded routes. Most routes
/// gate on `AccessRight.read` (the convention — a route's own screen then
/// further restricts create/update/delete actions); `/products/merge` is a
/// deliberate exception, since its only purpose is the create-gated merge
/// action mbe-api itself enforces (specs/008-merge-products research.md §5,
/// plan.md §IV design note) — gating it on Read would expose a screen a
/// Read-only user could never successfully use.
({SystemObject object, AccessRight right})? _routeGate(String location) {
  if (location == '/products/merge') {
    return (object: SystemObject.productsMerge, right: AccessRight.create);
  }
  if (location.startsWith('/users')) {
    return (object: SystemObject.users, right: AccessRight.read);
  }
  // Checked before the generic '/products' gate below: this nested route
  // is the product detail screen's "view pricing" shortcut and must gate on
  // pricing read access, not products read access (the button that links
  // here is itself hidden without it — product_detail_screen.dart).
  if (location.startsWith('/products/') && location.endsWith('/pricing')) {
    return (object: SystemObject.pricing, right: AccessRight.read);
  }
  if (location.startsWith('/products')) {
    return (object: SystemObject.products, right: AccessRight.read);
  }
  if (location.startsWith('/price-lists')) {
    return (object: SystemObject.priceLists, right: AccessRight.read);
  }
  if (location.startsWith('/pricing')) {
    return (object: SystemObject.pricing, right: AccessRight.read);
  }
  if (location.startsWith('/exchange-rates')) {
    return (object: SystemObject.exchangeRates, right: AccessRight.read);
  }
  if (location.startsWith('/suppliers')) {
    return (object: SystemObject.suppliers, right: AccessRight.read);
  }
  if (location.startsWith('/labels')) {
    return (object: SystemObject.labels, right: AccessRight.read);
  }
  if (location.startsWith('/employees')) {
    return (object: SystemObject.employees, right: AccessRight.read);
  }
  if (location.startsWith('/customers')) {
    return (object: SystemObject.customers, right: AccessRight.read);
  }
  if (location.startsWith('/taxpayer-recipients')) {
    return (object: SystemObject.taxpayerRecipients, right: AccessRight.read);
  }
  if (location.startsWith('/expenses')) {
    return (object: SystemObject.expenses, right: AccessRight.read);
  }
  if (location.startsWith('/vehicles')) {
    return (object: SystemObject.vehicle, right: AccessRight.read);
  }
  if (location.startsWith('/vehicle-operators')) {
    return (object: SystemObject.vehicleOperators, right: AccessRight.read);
  }
  if (location.startsWith('/warehouses')) {
    return (object: SystemObject.warehouses, right: AccessRight.read);
  }
  if (location.startsWith('/cash-drawers')) {
    return (object: SystemObject.cashDrawers, right: AccessRight.read);
  }
  if (location.startsWith('/points-of-sale')) {
    return (object: SystemObject.pointsOfSale, right: AccessRight.read);
  }
  if (location.startsWith('/facilities')) {
    return (object: SystemObject.facilities, right: AccessRight.read);
  }
  if (location.startsWith('/payment-method-options')) {
    return (object: SystemObject.paymentMethodOptions, right: AccessRight.read);
  }
  if (location.startsWith('/taxpayer-issuers')) {
    return (object: SystemObject.taxpayers, right: AccessRight.read);
  }
  // 021-cash-sessions: gated on `pos` (44), not `cashSessionClose` (111) —
  // the latter would lock out the cashiers the screen exists for. Close
  // itself is gated separately, inside the screen (contracts/routes.md §2).
  if (location.startsWith('/sales/cash-sessions')) {
    return (object: SystemObject.pos, right: AccessRight.read);
  }
  // 020-point-of-sale: same `pos` privilege — line-level mutations are
  // additionally gated on `salesOrders` inside the screen itself
  // (contracts/pos-screen.md §2), not at the route level.
  if (location.startsWith('/sales/pos')) {
    return (object: SystemObject.pos, right: AccessRight.read);
  }
  return null;
}
