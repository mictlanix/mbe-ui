import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/core/storage/token_storage.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/auth/domain/repositories/auth_repository.dart';
import 'package:mbe_ui/features/catalog/data/label_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/sat_catalog_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/supplier_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/product_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/sat_catalog_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/supplier_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/product_detail_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockTokenStorage extends Mock implements TokenStorage {}

class MockProductRepository extends Mock implements ProductRepository {}

class MockSatCatalogRepository extends Mock implements SatCatalogRepository {}

class MockSupplierRepository extends Mock implements SupplierRepository {}

/// [products] is the raw Products (2) right, [stock] the raw
/// WarehouseStockReport (67) right.
User _user({required int products, int stock = 0}) => User(
  userId: 'u',
  email: 'u@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [
    Privilege(systemObject: SystemObject.products, rawValue: products),
    if (stock != 0)
      Privilege(
        systemObject: SystemObject.warehouseStockReport,
        rawValue: stock,
      ),
  ],
);

Product _product() => const Product(
  productId: 1,
  code: 'SKU-001',
  name: 'Widget',
  unitOfMeasurementCode: 'PCE',
  unitOfMeasurementName: 'Piece',
  taxRate: '0.16',
  taxIncluded: false,
  priceType: 0,
  currency: 0,
  minOrderQty: 1,
  stockable: true,
  perishable: false,
  seriable: false,
  purchasable: false,
  salable: false,
  invoiceable: false,
  stockRequired: false,
  status: EntityStatus.active,
);

/// Spec 071 FR-013a, research R9 (T015): "Ver existencias" on the product
/// detail screen.
void main() {
  late MockAuthRepository authRepository;
  late MockTokenStorage tokenStorage;
  late MockProductRepository productRepository;
  late MockSatCatalogRepository satCatalogRepository;
  late MockSupplierRepository supplierRepository;

  setUp(() {
    authRepository = MockAuthRepository();
    tokenStorage = MockTokenStorage();
    productRepository = MockProductRepository();
    satCatalogRepository = MockSatCatalogRepository();
    supplierRepository = MockSupplierRepository();
    when(() => tokenStorage.read()).thenAnswer((_) async => 'test-token');
    when(
      () => productRepository.get(productId: 1),
    ).thenAnswer((_) async => _product());
    when(
      () => satCatalogRepository.listUnitsOfMeasurement(
        search: any(named: 'search'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => const SatCatalogListResult(items: [], total: 0));
    when(
      () => satCatalogRepository.listProductServices(
        search: any(named: 'search'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => const SatCatalogListResult(items: [], total: 0));
    when(
      () => supplierRepository.list(
        search: any(named: 'search'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => const SupplierListResult(items: [], total: 0));
  });

  /// Pumps the product screen at [location], as the app router builds it.
  Future<GoRouter> pumpAt(
    WidgetTester tester, {
    required User signedInAs,
    required String location,
  }) async {
    tester.view.physicalSize = const Size(1400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    when(() => authRepository.me()).thenAnswer((_) async => signedInAs);
    final router = GoRouter(
      initialLocation: location,
      routes: [
        GoRoute(
          path: '/products/new',
          builder: (_, _) => const ProductDetailScreen(),
        ),
        GoRoute(
          path: '/products/:productId',
          builder: (_, state) => ProductDetailScreen(
            productId: int.parse(state.pathParameters['productId']!),
            forceReadOnly: state.uri.queryParameters['view'] == 'true',
          ),
        ),
        GoRoute(
          path: '/inventory/stock/products/:id',
          builder: (_, state) => Scaffold(
            body: Text(
              'stock ${state.pathParameters['id']}',
              key: const Key('product_stock_route'),
            ),
          ),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepository),
          tokenStorageProvider.overrideWithValue(tokenStorage),
          productRepositoryProvider.overrideWithValue(productRepository),
          satCatalogRepositoryProvider.overrideWithValue(satCatalogRepository),
          supplierRepositoryProvider.overrideWithValue(supplierRepository),
          allLabelsProvider.overrideWith((_) async => []),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
    return router;
  }

  final button = find.byKey(const Key('view_stock_button'));

  testWidgets('shows on a View (?view=true) with stock read', (tester) async {
    await pumpAt(
      tester,
      signedInAs: _user(products: 6, stock: 2),
      location: '/products/1?view=true',
    );

    expect(button, findsOneWidget);
    expect(
      find.descendant(
        of: button,
        matching: find.byIcon(Icons.inventory_2_outlined),
      ),
      findsOneWidget,
    );
  });

  testWidgets('shows for a user without products update, opened without '
      '?view=true', (tester) async {
    await pumpAt(
      tester,
      signedInAs: _user(products: 2, stock: 2),
      location: '/products/1',
    );

    expect(button, findsOneWidget);
  });

  testWidgets('is absent without stock read', (tester) async {
    await pumpAt(
      tester,
      signedInAs: _user(products: 2),
      location: '/products/1?view=true',
    );

    expect(button, findsNothing);
  });

  testWidgets('is absent in edit mode', (tester) async {
    await pumpAt(
      tester,
      signedInAs: _user(products: 6, stock: 2),
      location: '/products/1',
    );

    expect(find.byKey(const Key('save_button')), findsOneWidget);
    expect(button, findsNothing);
  });

  testWidgets('is absent on a new product', (tester) async {
    await pumpAt(
      tester,
      signedInAs: _user(products: 3, stock: 2),
      location: '/products/new',
    );

    expect(find.byKey(const Key('save_button')), findsOneWidget);
    expect(button, findsNothing);
  });

  testWidgets('pushes the product stock view', (tester) async {
    final router = await pumpAt(
      tester,
      signedInAs: _user(products: 2, stock: 2),
      location: '/products/1?view=true',
    );

    await tester.tap(button);
    await tester.pumpAndSettle();

    expect(router.state.uri.path, '/inventory/stock/products/1');
    expect(find.byKey(const Key('product_stock_route')), findsOneWidget);
  });
}
