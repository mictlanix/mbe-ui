import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/product_repository.dart';
import 'package:mbe_ui/features/pricing/data/price_list_repository_impl.dart';
import 'package:mbe_ui/features/pricing/data/product_price_repository_impl.dart';
import 'package:mbe_ui/features/pricing/domain/entities/price_list.dart';
import 'package:mbe_ui/features/pricing/domain/entities/product_price.dart';
import 'package:mbe_ui/features/pricing/domain/repositories/price_list_repository.dart';
import 'package:mbe_ui/features/pricing/domain/repositories/product_price_repository.dart';
import 'package:mbe_ui/features/pricing/presentation/pricing_grid_controller.dart';

class MockProductRepository extends Mock implements ProductRepository {}

class MockPriceListRepository extends Mock implements PriceListRepository {}

class MockProductPriceRepository extends Mock implements ProductPriceRepository {}

ProductListItem _product(int id) => ProductListItem(
  productId: id,
  code: 'SKU-$id',
  name: 'Product $id',
  unitOfMeasurementCode: 'PCE',
  unitOfMeasurementName: 'Piece',
  taxRate: '0.16',
  status: EntityStatus.active,
);

PriceList _priceList(
  int id, {
  String lowProfitMargin = '0',
  String highProfitMargin = '0',
}) => PriceList(
  priceListId: id,
  name: 'List $id',
  highProfitMargin: highProfitMargin,
  lowProfitMargin: lowProfitMargin,
);

ProductPrice _price({
  required int productId,
  required int priceListId,
  required String price,
  String lowProfit = '0.10',
  String highProfit = '0.40',
}) => ProductPrice(
  productPriceId: productId * 100 + priceListId,
  productId: productId,
  priceList: _priceList(priceListId),
  price: price,
  lowProfit: lowProfit,
  highProfit: highProfit,
);

void main() {
  group('PricingGridFilter.fromQuery (spec 033 data-model.md §7)', () {
    test(
      'derives every product-list facet from a ListQuery, mirroring '
      'ProductFilter.fromQuery',
      () {
        final filter = PricingGridFilter.fromQuery(
          const ListQuery(
            search: 'clavo',
            pageIndex: 2,
            facets: {
              'status': ['active'],
              'stockable': ['true'],
              'salable': ['true'],
              'purchasable': ['false'],
              'supplier': ['12'],
              'label': ['3', '7'],
            },
          ),
        );

        expect(filter.search, 'clavo');
        expect(filter.pageIndex, 2);
        expect(filter.status, EntityStatus.active);
        expect(filter.stockable, isTrue);
        expect(filter.salable, isTrue);
        expect(filter.purchasable, isFalse);
        expect(filter.supplier, 12);
        expect(filter.labels, [3, 7]);
      },
    );

    test('an empty query yields every default, including a null worklist', () {
      final filter = PricingGridFilter.fromQuery(const ListQuery());

      expect(filter.search, '');
      expect(filter.pageIndex, 0);
      expect(filter.status, isNull);
      expect(filter.stockable, isNull);
      expect(filter.salable, isNull);
      expect(filter.purchasable, isNull);
      expect(filter.supplier, isNull);
      expect(filter.labels, isEmpty);
      expect(filter.missingPriceList, isNull);
    });

    test(
      'missingPriceList stays null even when the query carries an unrelated '
      'facet map — no facet key for it exists until mbe-api#184 lands '
      '(FR-019, research.md §R8)',
      () {
        final filter = PricingGridFilter.fromQuery(
          const ListQuery(
            facets: {
              'missing': ['5'],
            },
          ),
        );

        expect(filter.missingPriceList, isNull);
      },
    );
  });

  group('PricingGridController.commitCell (spec 033 US1)', () {
    late MockProductRepository productRepository;
    late MockPriceListRepository priceListRepository;
    late MockProductPriceRepository productPriceRepository;
    late ProviderContainer container;

    setUp(() {
      productRepository = MockProductRepository();
      priceListRepository = MockPriceListRepository();
      productPriceRepository = MockProductPriceRepository();
      container = ProviderContainer(
        overrides: [
          productRepositoryProvider.overrideWithValue(productRepository),
          priceListRepositoryProvider.overrideWithValue(priceListRepository),
          productPriceRepositoryProvider.overrideWithValue(
            productPriceRepository,
          ),
        ],
      );
      addTearDown(container.dispose);
    });

    const filter = PricingGridFilter();

    Future<void> primeWith({
      required List<PriceList> priceLists,
      required List<ProductListItem> products,
      required List<ProductPrice> prices,
    }) async {
      when(
        () => priceListRepository.list(limit: 100),
      ).thenAnswer((_) async => PriceListResult(items: priceLists, total: priceLists.length));
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
      ).thenAnswer((_) async => ProductListResult(items: products, total: products.length));
      when(
        () => productPriceRepository.listForProducts(
          productIds: products.map((p) => p.productId).toList(),
          priceListIds: priceLists.map((l) => l.priceListId).toList(),
        ),
      ).thenAnswer((_) async => prices);
      await container.read(pricingGridControllerProvider(filter).future);
    }

    test(
      'rejects a non-numeric value without issuing any write (FR-009)',
      () async {
        await primeWith(
          priceLists: [_priceList(5)],
          products: [_product(1)],
          prices: const [],
        );

        await container
            .read(pricingGridControllerProvider(filter).notifier)
            .commitCell(productId: 1, priceListId: 5, typed: 'abc');

        final state = container
            .read(pricingGridControllerProvider(filter))
            .requireValue;
        final key = state.rejected.keys.single;
        expect(key.productId, 1);
        expect(key.priceListId, 5);
        expect(state.rejected[key]!.typed, 'abc');
        expect(state.rejected[key]!.reason, PricingGridErrorCode.invalidAmount);
        verifyNever(
          () => productPriceRepository.create(
            productId: any(named: 'productId'),
            priceListId: any(named: 'priceListId'),
            price: any(named: 'price'),
            lowProfit: any(named: 'lowProfit'),
            highProfit: any(named: 'highProfit'),
          ),
        );
      },
    );

    test(
      'rejects a negative value the same way as unparseable text (FR-009)',
      () async {
        await primeWith(
          priceLists: [_priceList(5)],
          products: [_product(1)],
          prices: const [],
        );

        await container
            .read(pricingGridControllerProvider(filter).notifier)
            .commitCell(productId: 1, priceListId: 5, typed: '-5');

        final state = container
            .read(pricingGridControllerProvider(filter))
            .requireValue;
        expect(state.rejected.values.single.reason, PricingGridErrorCode.invalidAmount);
      },
    );

    test(
      'submitting the stored value unchanged issues no write (FR-010)',
      () async {
        await primeWith(
          priceLists: [_priceList(5)],
          products: [_product(1)],
          prices: [_price(productId: 1, priceListId: 5, price: '10.00')],
        );

        await container
            .read(pricingGridControllerProvider(filter).notifier)
            .commitCell(productId: 1, priceListId: 5, typed: '10.00');

        verifyNever(
          () => productPriceRepository.update(
            productPriceId: any(named: 'productPriceId'),
            price: any(named: 'price'),
            lowProfit: any(named: 'lowProfit'),
            highProfit: any(named: 'highProfit'),
          ),
        );
      },
    );

    test(
      'creating a price sends the price and nothing else — since mbe-api#185 '
      'the server fills the created row\'s band from the price list\'s own '
      'margins, and nothing reads it afterwards (FR-012)',
      () async {
        await primeWith(
          priceLists: [_priceList(5, lowProfitMargin: '0.10', highProfitMargin: '0.40')],
          products: [_product(1)],
          prices: const [],
        );
        when(
          () => productPriceRepository.create(
            productId: 1,
            priceListId: 5,
            price: '25.00',
          ),
        ).thenAnswer(
          (_) async => _price(productId: 1, priceListId: 5, price: '25.00'),
        );

        await container
            .read(pricingGridControllerProvider(filter).notifier)
            .commitCell(productId: 1, priceListId: 5, typed: '25.00');

        // Named arguments omitted entirely, not passed as null: the grid
        // edits one number and has no business naming a profit band.
        verify(
          () => productPriceRepository.create(
            productId: 1,
            priceListId: 5,
            price: '25.00',
          ),
        ).called(1);
      },
    );

    test(
      'updating an existing price sends only the price, leaving the stored '
      'profit band untouched — this cell edits price and nothing else '
      '(FR-034)',
      () async {
        await primeWith(
          priceLists: [_priceList(5)],
          products: [_product(1)],
          prices: [
            _price(
              productId: 1,
              priceListId: 5,
              price: '10.00',
              lowProfit: '0.15',
              highProfit: '0.45',
            ),
          ],
        );
        when(
          () => productPriceRepository.update(
            productPriceId: 105,
            price: '12.00',
          ),
        ).thenAnswer(
          (_) async => _price(
            productId: 1,
            priceListId: 5,
            price: '12.00',
            lowProfit: '0.15',
            highProfit: '0.45',
          ),
        );

        await container
            .read(pricingGridControllerProvider(filter).notifier)
            .commitCell(productId: 1, priceListId: 5, typed: '12.00');

        // The band is omitted, which mbe-api#185 defines as "leave the
        // stored one alone" — the grid never overwrites what it did not edit.
        verify(
          () => productPriceRepository.update(
            productPriceId: 105,
            price: '12.00',
          ),
        ).called(1);
        final state = container
            .read(pricingGridControllerProvider(filter))
            .requireValue;
        expect(state.history.single.writes.single.previous, '10.00');
        expect(state.history.single.writes.single.next, '12.00');
      },
    );

    test('a server 422 rejects the cell with the server\'s own message', () async {
      await primeWith(
        priceLists: [_priceList(5)],
        products: [_product(1)],
        prices: const [],
      );
      when(
        () => productPriceRepository.create(
          productId: 1,
          priceListId: 5,
          price: '25.00',
        ),
      ).thenThrow(
        const AppError.validation([
          FieldError(loc: ['body', 'price'], msg: 'Out of range', type: 'value_error'),
        ]),
      );

      await container
          .read(pricingGridControllerProvider(filter).notifier)
          .commitCell(productId: 1, priceListId: 5, typed: '25.00');

      final state = container
          .read(pricingGridControllerProvider(filter))
          .requireValue;
      final rejection = state.rejected.values.single;
      expect(rejection.typed, '25.00');
      expect(rejection.reason, 'Out of range');
    });
  });
}
