import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/app/router/app_router.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/features/auth/data/user_repository_impl.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/auth/domain/repositories/user_repository.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/features/catalog/data/label_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/product_repository.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockProductRepository extends Mock implements ProductRepository {}

class MockUserRepository extends Mock implements UserRepository {}

/// Bypasses `AuthNotifier.build()`'s real `TokenStorage`/`AuthRepository`
/// round-trip, resolving directly to a fixed [AuthState] — this test only
/// exercises `_redirect`'s access-control branch, not session restoration.
class _FixedAuthNotifier extends AuthNotifier {
  _FixedAuthNotifier(this._state);

  final AuthState _state;

  @override
  Future<AuthState> build() async => _state;
}

const _mergeUser = User(
  userId: 'merger',
  email: 'merger@example.com',
  administrator: false,
  disabled: false,
  sessionVersion: 1,
  privileges: [
    Privilege(systemObject: SystemObject.productsMerge, rawValue: 1), // create
  ],
);

const _noMergeUser = User(
  userId: 'no-merger',
  email: 'no-merger@example.com',
  administrator: false,
  disabled: false,
  sessionVersion: 1,
  // Holds products/users read but not productsMerge.
  privileges: [
    Privilege(systemObject: SystemObject.products, rawValue: 2),
    Privilege(systemObject: SystemObject.users, rawValue: 2),
  ],
);

const _readOnlyUser = User(
  userId: 'reader',
  email: 'reader@example.com',
  administrator: false,
  disabled: false,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.products, rawValue: 2)],
);

const _noAccessUser = User(
  userId: 'no-access',
  email: 'no-access@example.com',
  administrator: false,
  disabled: false,
  sessionVersion: 1,
  privileges: [],
);

void main() {
  /// Pumps the real `goRouterProvider` (auth fixed via [_FixedAuthNotifier])
  /// and navigates to [location]. Deliberately uses bounded `pump()` calls
  /// rather than `pumpAndSettle()`: `_redirect` itself is synchronous once
  /// the auth state has resolved (the one `pumpAndSettle` below), so the
  /// redirect decision is available without waiting for a destination
  /// screen's own (unrelated, real-repository-backed) data to load —
  /// avoiding a dependency on mocking every screen's repositories just to
  /// check where the router landed.
  Future<GoRouterTestHandle> pumpAt(
    WidgetTester tester,
    User user,
    String location,
  ) async {
    final productRepository = MockProductRepository();
    when(
      () => productRepository.list(
        search: any(named: 'search'),
        deactivated: any(named: 'deactivated'),
        stockable: any(named: 'stockable'),
        salable: any(named: 'salable'),
        purchasable: any(named: 'purchasable'),
        labels: any(named: 'labels'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => const ProductListResult(items: [], total: 0));

    final userRepository = MockUserRepository();
    when(
      () => userRepository.list(
        search: any(named: 'search'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => const UserListResult(items: [], total: 0));

    final container = ProviderContainer(
      overrides: [
        authNotifierProvider.overrideWith(
          () => _FixedAuthNotifier(
            AuthState.authenticated(token: 't', user: user),
          ),
        ),
        // Destination screens for the "allowed" cases (/products, /users,
        // /products/merge) fetch real data eagerly — without these
        // overrides they'd spawn a real, unmocked network call whose
        // pending timer trips flutter_test's leak detector at teardown.
        productRepositoryProvider.overrideWithValue(productRepository),
        allLabelsProvider.overrideWith((_) async => const []),
        userRepositoryProvider.overrideWithValue(userRepository),
      ],
    );
    addTearDown(container.dispose);
    final router = container.read(goRouterProvider);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();

    router.go(location);
    await tester.pump();
    await tester.pump();

    return GoRouterTestHandle(router);
  }

  group('/products/merge — productsMerge/create gate (specs/008-merge-products)', () {
    testWidgets(
      'a user with productsMerge/create reaches /products/merge',
      (tester) async {
        final handle = await pumpAt(tester, _mergeUser, '/products/merge');
        expect(handle.router.state.uri.path, '/products/merge');
      },
    );

    testWidgets(
      'a user without productsMerge/create is redirected to / (FR-012, '
      'deny-by-default)',
      (tester) async {
        final handle = await pumpAt(tester, _noMergeUser, '/products/merge');
        expect(handle.router.state.uri.path, '/');
      },
    );

    testWidgets(
      'a user with no privileges at all is redirected to /',
      (tester) async {
        final handle = await pumpAt(tester, _noAccessUser, '/products/merge');
        expect(handle.router.state.uri.path, '/');
      },
    );
  });

  group('regression: existing routes still gate on Read (post-T023 refactor)', () {
    testWidgets('a read-only user still reaches /products', (tester) async {
      final handle = await pumpAt(tester, _readOnlyUser, '/products');
      expect(handle.router.state.uri.path, '/products');
    });

    testWidgets(
      'a user without products/read is redirected away from /products',
      (tester) async {
        final handle = await pumpAt(tester, _noAccessUser, '/products');
        expect(handle.router.state.uri.path, '/');
      },
    );

    testWidgets(
      'a user with users/read still reaches /users',
      (tester) async {
        final handle = await pumpAt(tester, _noMergeUser, '/users');
        expect(handle.router.state.uri.path, '/users');
      },
    );

    testWidgets(
      'a user without users/read is redirected away from /users',
      (tester) async {
        final handle = await pumpAt(tester, _noAccessUser, '/users');
        expect(handle.router.state.uri.path, '/');
      },
    );
  });
}

/// Thin wrapper so `pumpAt`'s return type stays self-describing at call
/// sites (`handle.router.state.uri.path`).
class GoRouterTestHandle {
  GoRouterTestHandle(this.router);

  final GoRouter router;
}
