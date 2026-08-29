import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/product_repository.dart';
import 'package:mbe_ui/features/pricing/data/price_list_repository_impl.dart';
import 'package:mbe_ui/features/pricing/data/product_price_repository_impl.dart';
import 'package:mbe_ui/features/pricing/domain/entities/price_list.dart';
import 'package:mbe_ui/features/pricing/domain/entities/product_price.dart';
import 'package:mbe_ui/features/pricing/domain/repositories/price_list_repository.dart';
import 'package:mbe_ui/features/pricing/domain/repositories/product_price_repository.dart';
import 'package:mbe_ui/features/pricing/presentation/price_cell.dart';
import 'package:mbe_ui/features/pricing/presentation/pricing_grid_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockProductRepository extends Mock implements ProductRepository {}

class MockPriceListRepository extends Mock implements PriceListRepository {}

class MockProductPriceRepository extends Mock implements ProductPriceRepository {}

const _filter = PricingGridFilter();

ProductListItem _product(int id) => ProductListItem(
  productId: id,
  code: 'SKU-$id',
  name: 'Product $id',
  unitOfMeasurementCode: 'PCE',
  unitOfMeasurementName: 'Piece',
  taxRate: '0.16',
  status: EntityStatus.active,
);

PriceList _priceList(int id) =>
    PriceList(priceListId: id, name: 'List $id', highProfitMargin: '0.40', lowProfitMargin: '0.10');

ProductPrice _price({required int productId, required int priceListId, required String price}) =>
    ProductPrice(
      productPriceId: productId * 100 + priceListId,
      productId: productId,
      priceList: _priceList(priceListId),
      price: price,
      lowProfit: '0.10',
      highProfit: '0.40',
    );

void main() {
  late MockProductRepository productRepository;
  late MockPriceListRepository priceListRepository;
  late MockProductPriceRepository productPriceRepository;
  late ProviderContainer container;

  setUp(() async {
    productRepository = MockProductRepository();
    priceListRepository = MockPriceListRepository();
    productPriceRepository = MockProductPriceRepository();
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();
    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        productRepositoryProvider.overrideWithValue(productRepository),
        priceListRepositoryProvider.overrideWithValue(priceListRepository),
        productPriceRepositoryProvider.overrideWithValue(productPriceRepository),
      ],
    );
    addTearDown(container.dispose);

    when(() => priceListRepository.list(limit: 100)).thenAnswer(
      (_) async => PriceListResult(items: [_priceList(5)], total: 1),
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

    await container.read(pricingGridControllerProvider(_filter).future);
  });

  Future<void> pump(
    WidgetTester tester, {
    required ProductPrice? price,
    RejectedEdit? rejected,
    bool isActive = false,
    bool canUpdate = true,
    List<PriceCellMove> moves = const [],
  }) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: PriceCell(
              filter: _filter,
              productId: 1,
              priceListId: 5,
              price: price,
              rejected: rejected,
              inFlight: false,
              isActive: isActive,
              canUpdate: canUpdate,
              onMove: moves.add,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('reading state shows "not set" for a product with no price on '
      'this list (FR-005)', (tester) async {
    await pump(tester, price: null);
    expect(find.text('Not set'), findsOneWidget);
  });

  testWidgets('reading state shows the formatted price when one exists', (
    tester,
  ) async {
    await pump(tester, price: _price(productId: 1, priceListId: 5, price: '25.00'));
    expect(find.textContaining('25.00'), findsOneWidget);
  });

  testWidgets('a canUpdate cell opens for editing on tap', (tester) async {
    await pump(tester, price: null);
    await tester.tap(find.byKey(const Key('price_cell_1_5')));
    await tester.pump();

    final state = container.read(pricingGridControllerProvider(_filter)).requireValue;
    expect(state.active?.productId, 1);
    expect(state.active?.priceListId, 5);
  });

  testWidgets('a !canUpdate cell does not open for editing on tap', (
    tester,
  ) async {
    await pump(tester, price: null, canUpdate: false);
    await tester.tap(find.byKey(const Key('price_cell_1_5')));
    await tester.pump();

    final state = container.read(pricingGridControllerProvider(_filter)).requireValue;
    expect(state.active, isNull);
  });

  testWidgets(
    'editing state renders a TextField seeded with the stored price',
    (tester) async {
      await pump(
        tester,
        price: _price(productId: 1, priceListId: 5, price: '25.00'),
        isActive: true,
      );

      final field = tester.widget<TextField>(
        find.byKey(const Key('price_cell_field_1_5')),
      );
      expect(field.controller!.text, '25.00');
    },
  );

  testWidgets('Enter commits and reports a downward move (contracts §2)', (
    tester,
  ) async {
    when(
      () => productPriceRepository.create(
        productId: 1,
        priceListId: 5,
        price: '30.00',
        lowProfit: '0.10',
        highProfit: '0.40',
      ),
    ).thenAnswer((_) async => _price(productId: 1, priceListId: 5, price: '30.00'));
    final moves = <PriceCellMove>[];
    await pump(tester, price: null, isActive: true, moves: moves);

    await tester.enterText(find.byKey(const Key('price_cell_field_1_5')), '30.00');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(moves, [PriceCellMove.down]);
    verify(
      () => productPriceRepository.create(
        productId: 1,
        priceListId: 5,
        price: '30.00',
        lowProfit: '0.10',
        highProfit: '0.40',
      ),
    ).called(1);
  });

  testWidgets('Tab commits and reports a rightward move', (tester) async {
    when(
      () => productPriceRepository.create(
        productId: any(named: 'productId'),
        priceListId: any(named: 'priceListId'),
        price: any(named: 'price'),
        lowProfit: any(named: 'lowProfit'),
        highProfit: any(named: 'highProfit'),
      ),
    ).thenAnswer((_) async => _price(productId: 1, priceListId: 5, price: '30.00'));
    final moves = <PriceCellMove>[];
    await pump(tester, price: null, isActive: true, moves: moves);

    await tester.enterText(find.byKey(const Key('price_cell_field_1_5')), '30.00');
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();

    expect(moves, [PriceCellMove.right]);
  });

  testWidgets('Escape discards without committing and reports no move', (
    tester,
  ) async {
    final moves = <PriceCellMove>[];
    await pump(tester, price: null, isActive: true, moves: moves);

    await tester.enterText(find.byKey(const Key('price_cell_field_1_5')), 'abc');
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(moves, isEmpty);
    verifyNever(
      () => productPriceRepository.create(
        productId: any(named: 'productId'),
        priceListId: any(named: 'priceListId'),
        price: any(named: 'price'),
        lowProfit: any(named: 'lowProfit'),
        highProfit: any(named: 'highProfit'),
      ),
    );
    final state = container.read(pricingGridControllerProvider(_filter)).requireValue;
    expect(state.active, isNull);
  });

  testWidgets(
    'a rejected cell keeps the typed text visible, flagged, in reading state '
    '(FR-009)',
    (tester) async {
      await container
          .read(pricingGridControllerProvider(_filter).notifier)
          .commitCell(productId: 1, priceListId: 5, typed: 'abc');

      final state = container.read(pricingGridControllerProvider(_filter)).requireValue;
      final rejection = state.rejected.values.single;

      await pump(tester, price: null, rejected: rejection);

      expect(find.text('abc'), findsOneWidget);
    },
  );
}
