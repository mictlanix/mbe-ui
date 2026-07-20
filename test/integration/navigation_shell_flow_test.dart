import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/app/app.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/core/storage/token_storage.dart';
import 'package:mbe_ui/core/widgets/app_shell.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/auth/domain/repositories/auth_repository.dart';
import 'package:mbe_ui/features/auth/presentation/login/login_screen.dart';
import 'package:mbe_ui/features/catalog/data/label_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/product_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/products_list_screen.dart';

/// UI-level integration of the navigation shell against the *real*
/// `goRouterProvider` (spec 010 US1): the redirect guard, the
/// `StatefulShellRoute`, and the adaptive rail/drawer, with data sources
/// mocked (no live backend needed).
class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockTokenStorage extends Mock implements TokenStorage {}

class _MockProductRepository extends Mock implements ProductRepository {}

const _bothUser = User(
  userId: 'both',
  email: 'both@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [
    Privilege(systemObject: SystemObject.users, rawValue: 2),
    Privilege(systemObject: SystemObject.products, rawValue: 2),
  ],
);

void main() {
  late _MockAuthRepository authRepository;
  late _MockTokenStorage tokenStorage;
  late _MockProductRepository productRepository;

  setUp(() {
    authRepository = _MockAuthRepository();
    tokenStorage = _MockTokenStorage();
    productRepository = _MockProductRepository();
  });

  Future<void> pumpApp(WidgetTester tester) async {
    when(
      () => productRepository.list(
        search: any(named: 'search'),
        status: any(named: 'status'),
        stockable: any(named: 'stockable'),
        salable: any(named: 'salable'),
        purchasable: any(named: 'purchasable'),
        labels: any(named: 'labels'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => const ProductListResult(items: [], total: 0));
    when(
      () => productRepository.productLabelFacets(
        search: any(named: 'search'),
        status: any(named: 'status'),
        stockable: any(named: 'stockable'),
        salable: any(named: 'salable'),
        purchasable: any(named: 'purchasable'),
        labels: any(named: 'labels'),
      ),
    ).thenAnswer((_) async => const []);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepository),
          tokenStorageProvider.overrideWithValue(tokenStorage),
          productRepositoryProvider.overrideWithValue(productRepository),
          allLabelsProvider.overrideWith((_) async => const []),
        ],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('an authenticated user lands in the shell and can navigate '
      'between destinations', (tester) async {
    when(() => tokenStorage.read()).thenAnswer((_) async => 'token');
    when(() => authRepository.me()).thenAnswer((_) async => _bothUser);

    await pumpApp(tester);

    // Shell + persistent rail (default 800px test surface -> Medium tier).
    expect(find.byType(AppShell), findsOneWidget);
    expect(find.byKey(const Key('nav_dest_home')), findsOneWidget);
    expect(find.byKey(const Key('nav_dest_products')), findsOneWidget);

    // Navigate to Products via the rail — the branch swaps in.
    await tester.tap(find.byKey(const Key('nav_dest_products')));
    await tester.pumpAndSettle();
    expect(find.byType(ProductsListScreen), findsOneWidget);
  });

  testWidgets('narrowing the window moves navigation into a drawer', (
    tester,
  ) async {
    when(() => tokenStorage.read()).thenAnswer((_) async => 'token');
    when(() => authRepository.me()).thenAnswer((_) async => _bothUser);
    tester.view.physicalSize = const Size(500, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await pumpApp(tester);

    // Not persistent; reachable via the app-bar menu button.
    expect(find.byKey(const Key('nav_dest_home')), findsNothing);
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('nav_dest_home')), findsOneWidget);
  });

  testWidgets('an unauthenticated user sees the login screen, not the shell', (
    tester,
  ) async {
    when(() => tokenStorage.read()).thenAnswer((_) async => null);

    await pumpApp(tester);

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(AppShell), findsNothing);
  });
}
