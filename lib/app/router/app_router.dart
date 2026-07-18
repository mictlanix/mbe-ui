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
import 'package:mbe_ui/core/widgets/app_shell.dart';
import 'package:mbe_ui/features/catalog/presentation/merge_products_screen.dart';
import 'package:mbe_ui/features/catalog/presentation/product_detail_screen.dart';
import 'package:mbe_ui/features/catalog/presentation/products_list_screen.dart';
import 'package:mbe_ui/features/home/presentation/home_screen.dart';
import 'package:mbe_ui/features/pricing/presentation/exchange_rate_detail_screen.dart';
import 'package:mbe_ui/features/pricing/presentation/exchange_rates_list_screen.dart';
import 'package:mbe_ui/features/pricing/presentation/price_list_detail_screen.dart';
import 'package:mbe_ui/features/pricing/presentation/price_lists_list_screen.dart';
import 'package:mbe_ui/features/pricing/presentation/pricing_screen.dart';

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
                builder: (context, state) => const UsersListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/products',
                builder: (context, state) => const ProductsListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/price-lists',
                builder: (context, state) => const PriceListsListScreen(),
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
                builder: (context, state) => const ExchangeRatesListScreen(),
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
  return null;
}
