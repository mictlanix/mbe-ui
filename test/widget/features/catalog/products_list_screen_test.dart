import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/core/storage/token_storage.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/auth/domain/repositories/auth_repository.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/product_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/products_list_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockTokenStorage extends Mock implements TokenStorage {}

class MockProductRepository extends Mock implements ProductRepository {}

const _readOnlyUser = User(
  userId: 'reader',
  email: 'reader@example.com',
  administrator: false,
  disabled: false,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.products, rawValue: 2)],
);

const _fullAccessUser = User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: false,
  disabled: false,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.products, rawValue: 15)],
);

const _testProducts = [
  ProductListItem(
    productId: 1,
    code: 'SKU-001',
    name: 'Widget',
    unitOfMeasurement: 'PCE',
    taxRate: '0.16',
    deactivated: false,
  ),
  ProductListItem(
    productId: 2,
    code: 'SKU-002',
    name: 'Gadget',
    unitOfMeasurement: 'PCE',
    taxRate: '0.16',
    deactivated: true,
  ),
];

void main() {
  late MockAuthRepository authRepository;
  late MockTokenStorage tokenStorage;
  late MockProductRepository productRepository;

  setUp(() {
    authRepository = MockAuthRepository();
    tokenStorage = MockTokenStorage();
    productRepository = MockProductRepository();
    when(() => tokenStorage.read()).thenAnswer((_) async => 'test-token');
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    required User signedInAs,
    List<ProductListItem> products = _testProducts,
  }) async {
    when(() => authRepository.me()).thenAnswer((_) async => signedInAs);
    when(() => productRepository.list(
          search: any(named: 'search'),
          deactivated: any(named: 'deactivated'),
          stockable: any(named: 'stockable'),
          salable: any(named: 'salable'),
          purchasable: any(named: 'purchasable'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        )).thenAnswer(
      (_) async => ProductListResult(items: products, total: products.length),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepository),
          tokenStorageProvider.overrideWithValue(tokenStorage),
          productRepositoryProvider.overrideWithValue(productRepository),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ProductsListScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows products with their status (FR-001, FR-002)',
      (tester) async {
    await pumpScreen(tester, signedInAs: _readOnlyUser);

    expect(find.text('SKU-001'), findsOneWidget);
    expect(find.text('Widget'), findsOneWidget);
    expect(find.text('SKU-002'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Disabled'), findsOneWidget);
  });

  testWidgets('shows the search field and filter chips (FR-001, FR-002)',
      (tester) async {
    await pumpScreen(tester, signedInAs: _readOnlyUser);

    expect(find.byKey(const Key('products_search_field')), findsOneWidget);
    expect(find.byKey(const Key('products_filter_show_inactive')), findsOneWidget);
    expect(find.byKey(const Key('products_filter_stockable')), findsOneWidget);
    expect(find.byKey(const Key('products_filter_salable')), findsOneWidget);
    expect(find.byKey(const Key('products_filter_purchasable')), findsOneWidget);
  });

  testWidgets(
      'cycles the stockable filter through null -> true -> false -> null',
      (tester) async {
    await pumpScreen(tester, signedInAs: _readOnlyUser);
    final chipFinder = find.byKey(const Key('products_filter_stockable'));

    await tester.tap(chipFinder);
    await tester.pumpAndSettle();
    expect(
      tester.widget<FilterChip>(chipFinder).avatar,
      isA<Icon>().having((i) => i.icon, 'icon', Icons.check),
    );

    await tester.tap(chipFinder);
    await tester.pumpAndSettle();
    expect(
      tester.widget<FilterChip>(chipFinder).avatar,
      isA<Icon>().having((i) => i.icon, 'icon', Icons.close),
    );

    await tester.tap(chipFinder);
    await tester.pumpAndSettle();
    expect(tester.widget<FilterChip>(chipFinder).avatar, isNull);
  });

  testWidgets('shows an empty state when there are no matches', (tester) async {
    await pumpScreen(tester, signedInAs: _readOnlyUser, products: const []);

    expect(find.text('No products found.'), findsOneWidget);
  });

  testWidgets('shows the New product action for a user with create right',
      (tester) async {
    await pumpScreen(tester, signedInAs: _fullAccessUser);

    expect(find.byKey(const Key('new_product_button')), findsOneWidget);
  });

  testWidgets(
      'hides the New product action for a user without products.create',
      (tester) async {
    await pumpScreen(tester, signedInAs: _readOnlyUser);

    expect(find.byKey(const Key('new_product_button')), findsNothing);
  });
}
