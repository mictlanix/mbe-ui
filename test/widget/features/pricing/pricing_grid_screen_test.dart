import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/product_repository.dart';
import 'package:mbe_ui/features/pricing/data/price_list_repository_impl.dart';
import 'package:mbe_ui/features/pricing/data/product_price_repository_impl.dart';
import 'package:mbe_ui/features/pricing/domain/entities/price_list.dart';
import 'package:mbe_ui/features/pricing/domain/entities/product_price.dart';
import 'package:mbe_ui/features/pricing/domain/repositories/price_list_repository.dart';
import 'package:mbe_ui/features/pricing/domain/repositories/product_price_repository.dart';
import 'package:mbe_ui/features/pricing/presentation/pricing_grid_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockProductRepository extends Mock implements ProductRepository {}

class MockPriceListRepository extends Mock implements PriceListRepository {}

class MockProductPriceRepository extends Mock implements ProductPriceRepository {}

const _readOnlyUser = User(
  userId: 'reader',
  email: 'reader@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.pricing, rawValue: 2)],
);

const _fullAccessUser = User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.pricing, rawValue: 6)],
);

AccessControlService _accessFor(User user) =>
    AccessControlService(AuthState.authenticated(token: 't', user: user));

const _retail = PriceList(
  priceListId: 5,
  name: 'Retail',
  highProfitMargin: '0.40',
  lowProfitMargin: '0.10',
);

ProductListItem _product(int id, {String code = 'SKU', String name = 'Product'}) =>
    ProductListItem(
      productId: id,
      code: '$code-$id',
      name: '$name $id',
      unitOfMeasurementCode: 'PCE',
      unitOfMeasurementName: 'Piece',
      taxRate: '0.16',
      status: EntityStatus.active,
    );

void main() {
  late MockProductRepository productRepository;
  late MockPriceListRepository priceListRepository;
  late MockProductPriceRepository productPriceRepository;

  setUp(() {
    productRepository = MockProductRepository();
    priceListRepository = MockPriceListRepository();
    productPriceRepository = MockProductPriceRepository();
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    required User signedInAs,
    ListQuery query = const ListQuery(),
  }) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          productRepositoryProvider.overrideWithValue(productRepository),
          priceListRepositoryProvider.overrideWithValue(priceListRepository),
          productPriceRepositoryProvider.overrideWithValue(productPriceRepository),
          accessControlProvider.overrideWithValue(_accessFor(signedInAs)),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: PricingGridScreen(query: query)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'renders a populated grid with no product selection required (FR-001), '
    'one column per price list',
    (tester) async {
      when(() => priceListRepository.list(limit: 100)).thenAnswer(
        (_) async => const PriceListResult(items: [_retail], total: 1),
      );
      when(
        () => productRepository.list(
          search: null,
          status: null,
          stockable: null,
          salable: null,
          purchasable: null,
          supplier: null,
          labels: const [],
          skip: 0,
          limit: 20,
        ),
      ).thenAnswer(
        (_) async => ProductListResult(items: [_product(1), _product(2)], total: 2),
      );
      when(
        () => productPriceRepository.listForProducts(
          productIds: [1, 2],
          priceListIds: [5],
        ),
      ).thenAnswer(
        (_) async => [
          ProductPrice(
            productPriceId: 100,
            productId: 1,
            priceList: _retail,
            price: '25.00',
            lowProfit: '0.10',
            highProfit: '0.40',
          ),
        ],
      );

      await pumpScreen(tester, signedInAs: _fullAccessUser);

      expect(find.byKey(const Key('pricing_grid_table')), findsOneWidget);
      expect(find.text('Retail'), findsOneWidget);
      expect(find.text('SKU-1'), findsOneWidget);
      expect(find.text('SKU-2'), findsOneWidget);
    },
  );

  testWidgets(
    'a product with no price on a list shows "not set", distinct from a '
    'stored price of zero (FR-005)',
    (tester) async {
      when(() => priceListRepository.list(limit: 100)).thenAnswer(
        (_) async => const PriceListResult(items: [_retail], total: 1),
      );
      when(
        () => productRepository.list(
          search: null,
          status: null,
          stockable: null,
          salable: null,
          purchasable: null,
          supplier: null,
          labels: const [],
          skip: 0,
          limit: 20,
        ),
      ).thenAnswer((_) async => ProductListResult(items: [_product(1)], total: 1));
      when(
        () => productPriceRepository.listForProducts(
          productIds: [1],
          priceListIds: [5],
        ),
      ).thenAnswer((_) async => const []);

      await pumpScreen(tester, signedInAs: _fullAccessUser);

      expect(find.text('Not set'), findsOneWidget);
    },
  );

  testWidgets(
    'no price lists exist shows the shared "create one first" empty state '
    'rather than an empty grid frame',
    (tester) async {
      when(
        () => priceListRepository.list(limit: 100),
      ).thenAnswer((_) async => const PriceListResult(items: [], total: 0));

      await pumpScreen(tester, signedInAs: _fullAccessUser);

      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      expect(find.text(l10n.pricingNoPriceListsEmptyState), findsOneWidget);
      expect(find.byKey(const Key('pricing_grid_table')), findsNothing);
    },
  );

  testWidgets(
    'no column ⋮ menu is offered on any price-list header — US3 is not '
    'shipped until mbe-api#183 lands',
    (tester) async {
      when(() => priceListRepository.list(limit: 100)).thenAnswer(
        (_) async => const PriceListResult(items: [_retail], total: 1),
      );
      when(
        () => productRepository.list(
          search: null,
          status: null,
          stockable: null,
          salable: null,
          purchasable: null,
          supplier: null,
          labels: const [],
          skip: 0,
          limit: 20,
        ),
      ).thenAnswer((_) async => ProductListResult(items: [_product(1)], total: 1));
      when(
        () => productPriceRepository.listForProducts(
          productIds: [1],
          priceListIds: [5],
        ),
      ).thenAnswer((_) async => const []);

      await pumpScreen(tester, signedInAs: _fullAccessUser);

      expect(find.byIcon(Icons.more_vert), findsNothing);
    },
  );

  testWidgets(
    'no worklist chips appear above the grid — US2 is not shipped until '
    'mbe-api#184 lands (FR-019)',
    (tester) async {
      when(() => priceListRepository.list(limit: 100)).thenAnswer(
        (_) async => const PriceListResult(items: [_retail], total: 1),
      );
      when(
        () => productRepository.list(
          search: null,
          status: null,
          stockable: null,
          salable: null,
          purchasable: null,
          supplier: null,
          labels: const [],
          skip: 0,
          limit: 20,
        ),
      ).thenAnswer((_) async => ProductListResult(items: [_product(1)], total: 1));
      when(
        () => productPriceRepository.listForProducts(
          productIds: [1],
          priceListIds: [5],
        ),
      ).thenAnswer((_) async => const []);

      await pumpScreen(tester, signedInAs: _fullAccessUser);

      expect(find.byKey(const Key('pricing_grid_worklist_all')), findsNothing);
    },
  );

  testWidgets(
    'read-only user reaches no editing affordance and sees the read-only '
    'hint (FR-026, US5)',
    (tester) async {
      when(() => priceListRepository.list(limit: 100)).thenAnswer(
        (_) async => const PriceListResult(items: [_retail], total: 1),
      );
      when(
        () => productRepository.list(
          search: null,
          status: null,
          stockable: null,
          salable: null,
          purchasable: null,
          supplier: null,
          labels: const [],
          skip: 0,
          limit: 20,
        ),
      ).thenAnswer((_) async => ProductListResult(items: [_product(1)], total: 1));
      when(
        () => productPriceRepository.listForProducts(
          productIds: [1],
          priceListIds: [5],
        ),
      ).thenAnswer(
        (_) async => [
          ProductPrice(
            productPriceId: 100,
            productId: 1,
            priceList: _retail,
            price: '25.00',
            lowProfit: '0.10',
            highProfit: '0.40',
          ),
        ],
      );

      await pumpScreen(tester, signedInAs: _readOnlyUser);

      await tester.tap(find.byKey(const Key('price_cell_1_5')));
      await tester.pump();

      expect(find.byKey(const Key('price_cell_field_1_5')), findsNothing);
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      expect(find.text(l10n.pricingGridReadOnlyHint), findsOneWidget);
    },
  );
}
