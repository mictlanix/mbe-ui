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
import 'package:mbe_ui/features/catalog/presentation/products_list_screen.dart';
import 'package:mbe_ui/features/home/presentation/home_screen.dart';

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
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
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
        path: '/users',
        builder: (context, state) => const UsersListScreen(),
      ),
      GoRoute(
        path: '/users/new',
        builder: (context, state) => const UserDetailScreen(),
      ),
      GoRoute(
        path: '/users/:userId',
        builder: (context, state) =>
            UserDetailScreen(userId: state.pathParameters['userId']),
      ),
      GoRoute(
        path: '/products',
        builder: (context, state) => const ProductsListScreen(),
      ),
    ],
  );
});

/// Notifies `GoRouter` to re-run [_redirect] whenever [authNotifierProvider]
/// changes — including the `401`-triggered transition to `unauthenticated`
/// (FR-003, SC-003; research.md §4).
class _AuthRefreshListenable extends ChangeNotifier {
  _AuthRefreshListenable(Ref ref) {
    _subscription = ref.listen(authNotifierProvider, (_, _) => notifyListeners());
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

  final requiredObject = _routeSystemObject(state.matchedLocation);
  if (requiredObject != null &&
      !ref.read(accessControlProvider).can(requiredObject, AccessRight.read)) {
    return '/';
  }
  return null;
}

/// `SystemObject` (Read) gate for a route, per contracts/routes.md. Returns
/// `null` for unguarded routes.
SystemObject? _routeSystemObject(String location) {
  if (location.startsWith('/users')) return SystemObject.users;
  if (location.startsWith('/products')) return SystemObject.products;
  return null;
}
