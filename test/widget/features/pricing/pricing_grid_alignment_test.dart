import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/app/theme/app_theme.dart';
import 'package:mbe_ui/core/branding/brand_config.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product_missing_price_facet.dart';
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

class MockProductPriceRepository extends Mock
    implements ProductPriceRepository {}

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

const _retail = PriceList(priceListId: 5, name: 'Retail');

ProductListItem _product(int id) => ProductListItem(
  productId: id,
  code: 'SKU-$id',
  name: 'Product $id',
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
    when(
      () => productRepository.productMissingPriceFacets(
        search: any(named: 'search'),
        status: any(named: 'status'),
        stockable: any(named: 'stockable'),
        salable: any(named: 'salable'),
        purchasable: any(named: 'purchasable'),
        supplier: any(named: 'supplier'),
        labels: any(named: 'labels'),
      ),
    ).thenAnswer(
      (_) async => const [
        ProductMissingPriceFacet(priceListId: 5, missingCount: 14),
      ],
    );
    when(() => priceListRepository.list(limit: 100)).thenAnswer(
      (_) async => const PriceListResult(items: [_retail], total: 1),
    );
    when(
      () => productRepository.list(
        search: null,
        status: EntityStatus.active,
        stockable: null,
        salable: null,
        purchasable: null,
        supplier: null,
        labels: const [],
        missingPriceList: null,
        skip: 0,
        limit: 20,
      ),
    ).thenAnswer(
      (_) async => ProductListResult(items: [_product(1)], total: 1),
    );
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
        ),
      ],
    );
    when(
      () => productPriceRepository.update(productPriceId: 100, price: '30'),
    ).thenAnswer(
      (_) async => ProductPrice(
        productPriceId: 100,
        productId: 1,
        priceList: _retail,
        price: '30',
      ),
    );
  });

  Future<void> pumpAt(WidgetTester tester, double width) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();
    tester.view.physicalSize = Size(width, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          productRepositoryProvider.overrideWithValue(productRepository),
          priceListRepositoryProvider.overrideWithValue(priceListRepository),
          productPriceRepositoryProvider.overrideWithValue(
            productPriceRepository,
          ),
          accessControlProvider.overrideWithValue(_accessFor(_fullAccessUser)),
        ],
        child: MaterialApp(
          // The tier-resolved theme carries the `cardPadding` Card margin the
          // alignment depends on; a bare `ThemeData` would not.
          theme: AppTheme.of(const BrandConfig(displayName: 'Test')).light,
          builder: (context, child) => Theme(
            data: DesignTheme.forTier(
              Theme.of(context),
              LayoutBreakpoints.tierOfContext(context),
            ),
            child: child!,
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: PricingGridScreen(query: ListQuery())),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// The card's visible surface — a `Card`'s own box includes its margin.
  Finder tableCard() => find
      .descendant(
        of: find
            .descendant(
              of: find.byKey(const Key('pricing_grid_table')),
              matching: find.byType(Card),
            )
            .first,
        matching: find.byType(Material),
      )
      .first;

  for (final width in [800.0, 1440.0]) {
    testWidgets('search, chips, table and hint share one left edge at '
        '${width.toInt()} px (C6)', (tester) async {
      await pumpAt(tester, width);

      final hint = find.text(
        AppLocalizations.of(
          tester.element(find.byType(PricingGridScreen)),
        )!.pricingGridHint,
      );
      final search = tester.getRect(
        find.byKey(const Key('pricing_grid_search_field')),
      );
      final table = tester.getRect(tableCard());

      expect(
        tester
            .getTopLeft(find.byKey(const Key('pricing_grid_worklist_all')))
            .dx,
        closeTo(search.left, 1),
      );
      expect(table.left, closeTo(search.left, 1));
      expect(tester.getTopLeft(hint).dx, closeTo(search.left, 1));
      // The search row ends at its filter button, or at the search field
      // when the bar wraps and the button drops below it.
      final filterRight = tester
          .getRect(find.byKey(const Key('pricing_grid_filter_button')))
          .right;
      expect(
        table.right,
        closeTo(filterRight > search.right ? filterRight : search.right, 1),
      );
    });
  }

  testWidgets(
    'the change summary bar lines up with the search field too (C6)',
    (tester) async {
      await pumpAt(tester, 1440);
      await tester.tap(find.byKey(const Key('price_cell_1_5')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('price_cell_field_1_5')),
        '30',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      final bar = tester.getRect(
        find.byKey(const Key('pricing_grid_summary_bar')),
      );
      final search = tester.getRect(
        find.byKey(const Key('pricing_grid_search_field')),
      );
      expect(bar.left, closeTo(search.left, 1));
      expect(bar.right, closeTo(tester.getRect(tableCard()).right, 1));
    },
  );
}
