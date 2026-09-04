import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/product_repository.dart';
import 'package:mbe_ui/features/pricing/data/price_list_repository_impl.dart';
import 'package:mbe_ui/features/pricing/data/product_price_repository_impl.dart';
import 'package:mbe_ui/features/pricing/domain/entities/price_cell_key.dart';
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

PriceList _priceList(int id) => PriceList(priceListId: id, name: 'List $id');

ProductPrice _price({
  required int productId,
  required int priceListId,
  required String price,
}) => ProductPrice(
  productPriceId: productId * 100 + priceListId,
  productId: productId,
  priceList: _priceList(priceListId),
  price: price,
);

void main() {
  // spec 036 R10: `commitCell`/`adjustByPercent` now route through
  // `formattersProvider`, which constructs a `DateFormat` — needs locale
  // data initialized, unlike a widget test where the test binding does
  // this implicitly.
  setUpAll(() async {
    await initializeDateFormatting();
  });

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
      // spec 035 FR-001/FR-002: an absent status facet now defaults to
      // Active, not "no filter" — the "All" choice is the explicit
      // `status=all` case, covered separately below.
      expect(filter.status, EntityStatus.active);
      expect(filter.stockable, isNull);
      expect(filter.salable, isNull);
      expect(filter.purchasable, isNull);
      expect(filter.supplier, isNull);
      expect(filter.labels, isEmpty);
      expect(filter.missingPriceList, isNull);
    });

    test('an explicit "all" status clears the default (FR-004)', () {
      final filter = PricingGridFilter.fromQuery(
        const ListQuery(
          facets: {
            'status': ['all'],
          },
        ),
      );

      expect(filter.status, isNull);
    });

    test('reads the worklist selection from the `missing` facet (US2, '
        'mbe-api#184)', () {
      final filter = PricingGridFilter.fromQuery(
        const ListQuery(
          facets: {
            'missing': ['5'],
          },
        ),
      );

      expect(filter.missingPriceList, 5);
    });

    test(
      'a `missing` of 0 parses to 0, not null — `Costo` sits at price list id '
      '0, so a falsy-check here would silently ignore its chip (FR-019a)',
      () {
        final filter = PricingGridFilter.fromQuery(
          const ListQuery(
            facets: {
              'missing': ['0'],
            },
          ),
        );

        expect(filter.missingPriceList, 0);
        expect(filter.missingPriceList, isNotNull);
      },
    );

    test('an unparseable `missing` degrades to null rather than throwing', () {
      final filter = PricingGridFilter.fromQuery(
        const ListQuery(
          facets: {
            'missing': ['not-a-list-id'],
          },
        ),
      );

      expect(filter.missingPriceList, isNull);
    });
  });

  group('PricingGridController.commitCell (spec 033 US1)', () {
    late MockProductRepository productRepository;
    late MockPriceListRepository priceListRepository;
    late MockProductPriceRepository productPriceRepository;
    late ProviderContainer container;

    setUp(() async {
      productRepository = MockProductRepository();
      priceListRepository = MockPriceListRepository();
      productPriceRepository = MockProductPriceRepository();
      // `commitCell` now routes through `formattersProvider` (spec 036 US8,
      // contracts/app-settings-additions.md C3), which chains through
      // `resolvedLocaleProvider`/`UserDisplayPreferencesController` down to
      // `sharedPreferencesProvider` — needs a value here too, or resolving
      // it throws.
      SharedPreferences.setMockInitialValues({});
      final sharedPreferences = await SharedPreferences.getInstance();
      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
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
      'arrowing through an unpriced cell without typing is a no-op, not a '
      'rejection — a "Missing «list»" worklist is unpriced cells by '
      'definition, and traversing one used to flag every cell passed over',
      () async {
        await primeWith(
          priceLists: [_priceList(5)],
          products: [_product(1)],
          prices: const [],
        );

        await container
            .read(pricingGridControllerProvider(filter).notifier)
            .commitCell(productId: 1, priceListId: 5, typed: '');

        final state = container
            .read(pricingGridControllerProvider(filter))
            .requireValue;
        expect(state.rejected, isEmpty);
        expect(state.hasChanges, isFalse);
        verifyNever(
          () => productPriceRepository.create(
            productId: any(named: 'productId'),
            priceListId: any(named: 'priceListId'),
            price: any(named: 'price'),
          ),
        );
      },
    );

    test(
      'whitespace alone is the same no-op — the field can be spaced without '
      'becoming an error',
      () async {
        await primeWith(
          priceLists: [_priceList(5)],
          products: [_product(1)],
          prices: const [],
        );

        await container
            .read(pricingGridControllerProvider(filter).notifier)
            .commitCell(productId: 1, priceListId: 5, typed: '   ');

        expect(
          container.read(pricingGridControllerProvider(filter)).requireValue
              .rejected,
          isEmpty,
        );
      },
    );

    test(
      'emptying a cell that DOES have a price is still refused — the grid '
      'has no delete path, so silently doing nothing would look like it '
      'worked (FR-011 remains unimplemented)',
      () async {
        await primeWith(
          priceLists: [_priceList(5)],
          products: [_product(1)],
          prices: [_price(productId: 1, priceListId: 5, price: '10.0000')],
        );

        await container
            .read(pricingGridControllerProvider(filter).notifier)
            .commitCell(productId: 1, priceListId: 5, typed: '');

        final state = container
            .read(pricingGridControllerProvider(filter))
            .requireValue;
        expect(state.rejectedCount, 1);
        expect(
          state.valueOf(const PriceCellKey(productId: 1, priceListId: 5)),
          '10.0000',
        );
      },
    );

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
          ),
        );
      },
    );

    test(
      'dismissRejected clears every refusal and touches nothing else — a '
      'rejection never reached the server, so discarding it must not cost '
      'the accepted edits beside it (FR-023a)',
      () async {
        await primeWith(
          priceLists: [_priceList(5)],
          products: [_product(1), _product(2)],
          prices: [
            _price(productId: 1, priceListId: 5, price: '10.0000'),
            _price(productId: 2, priceListId: 5, price: '20.0000'),
          ],
        );
        when(
          () => productPriceRepository.update(productPriceId: 105, price: '11'),
        ).thenAnswer(
          (_) async => _price(productId: 1, priceListId: 5, price: '11.0000'),
        );
        final notifier = container.read(
          pricingGridControllerProvider(filter).notifier,
        );

        await notifier.commitCell(productId: 1, priceListId: 5, typed: '11');
        await notifier.commitCell(productId: 2, priceListId: 5, typed: 'abc');
        expect(
          container.read(pricingGridControllerProvider(filter)).requireValue
              .rejectedCount,
          1,
        );

        notifier.dismissRejected();

        final state = container
            .read(pricingGridControllerProvider(filter))
            .requireValue;
        expect(state.rejected, isEmpty);
        // The accepted edit survives, history and all.
        expect(state.changedCount, 1);
        expect(state.history, hasLength(1));
        expect(
          state.valueOf(const PriceCellKey(productId: 1, priceListId: 5)),
          '11.0000',
        );
      },
    );

    test(
      'Escape on a rejected cell drops that cell\'s refusal, and only that '
      'one — cancelling an edit cancels its warning too',
      () async {
        await primeWith(
          priceLists: [_priceList(5)],
          products: [_product(1), _product(2)],
          prices: [
            _price(productId: 1, priceListId: 5, price: '10.0000'),
            _price(productId: 2, priceListId: 5, price: '20.0000'),
          ],
        );
        final notifier = container.read(
          pricingGridControllerProvider(filter).notifier,
        );
        await notifier.commitCell(productId: 1, priceListId: 5, typed: 'abc');
        await notifier.commitCell(productId: 2, priceListId: 5, typed: 'xyz');

        // Reopen the first and Escape out of it.
        notifier.openCell(const PriceCellKey(productId: 1, priceListId: 5));
        notifier.closeCell();

        final state = container
            .read(pricingGridControllerProvider(filter))
            .requireValue;
        expect(state.active, isNull);
        expect(state.rejected.keys.single.productId, 2);
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
      'submitting the same amount at a different scale issues no write — '
      'mbe-api returns `Numeric(18,4)`, so a stored `120.0000` and a typed '
      '`120.00` are one price (FR-010; found by the live integration test)',
      () async {
        await primeWith(
          priceLists: [_priceList(5)],
          products: [_product(1)],
          prices: [_price(productId: 1, priceListId: 5, price: '120.0000')],
        );

        await container
            .read(pricingGridControllerProvider(filter).notifier)
            .commitCell(productId: 1, priceListId: 5, typed: '120.00');

        verifyNever(
          () => productPriceRepository.update(
            productPriceId: any(named: 'productPriceId'),
            price: any(named: 'price'),
          ),
        );
      },
    );

    test(
      'a cell whose stored value only differs in scale is not counted as '
      'changed, so the summary bar cannot invent work (FR-023)',
      () async {
        await primeWith(
          priceLists: [_priceList(5)],
          products: [_product(1)],
          prices: [_price(productId: 1, priceListId: 5, price: '120.0000')],
        );

        final state = container
            .read(pricingGridControllerProvider(filter))
            .requireValue;
        expect(state.changedCount, 0);
        expect(state.hasChanges, isFalse);
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
          priceLists: [_priceList(5)],
          products: [_product(1)],
          prices: const [],
        );
        // spec 036 R10: the commit routes through `AppFormatters.field
        // .parsePrice`, which round-trips via `Decimal` and so sends the
        // canonical value — trailing zeros stripped — not the raw typed
        // string.
        when(
          () => productPriceRepository.create(
            productId: 1,
            priceListId: 5,
            price: '25',
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
            price: '25',
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
            ),
          ],
        );
        // spec 036 R10: sent as the canonical, trailing-zero-stripped value.
        when(
          () => productPriceRepository.update(
            productPriceId: 105,
            price: '12',
          ),
        ).thenAnswer(
          (_) async => _price(
            productId: 1,
            priceListId: 5,
            price: '12.00',
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
            price: '12',
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
          price: '25',
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

  group('PricingGridController column actions (spec 033 US3, mbe-api#183)', () {
    late MockProductRepository productRepository;
    late MockPriceListRepository priceListRepository;
    late MockProductPriceRepository productPriceRepository;
    late ProviderContainer container;

    setUp(() async {
      productRepository = MockProductRepository();
      priceListRepository = MockPriceListRepository();
      productPriceRepository = MockProductPriceRepository();
      // `commitCell` now routes through `formattersProvider` (spec 036 US8,
      // contracts/app-settings-additions.md C3), which chains through
      // `resolvedLocaleProvider`/`UserDisplayPreferencesController` down to
      // `sharedPreferencesProvider` — needs a value here too, or resolving
      // it throws.
      SharedPreferences.setMockInitialValues({});
      final sharedPreferences = await SharedPreferences.getInstance();
      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
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

    // `Costo` at id 0 — the deployment's own cost list, and a falsy id.
    final costList = _priceList(0);
    final saleList = _priceList(5);

    Future<void> primeWith(List<ProductPrice> prices, {int products = 3}) async {
      when(() => priceListRepository.list(limit: 100)).thenAnswer(
        (_) async => PriceListResult(items: [costList, saleList], total: 2),
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
          missingPriceList: null,
          skip: 0,
          limit: 20,
        ),
      ).thenAnswer(
        (_) async => ProductListResult(
          items: [for (var i = 1; i <= products; i++) _product(i)],
          total: products,
        ),
      );
      when(
        () => productPriceRepository.listForProducts(
          productIds: [for (var i = 1; i <= products; i++) i],
          priceListIds: [0, 5],
        ),
      ).thenAnswer((_) async => prices);
      await container.read(pricingGridControllerProvider(filter).future);
    }

    void stubBulk() {
      when(() => productPriceRepository.applyPriceChanges(any())).thenAnswer((
        invocation,
      ) async {
        final writes =
            invocation.positionalArguments.first as List<PriceCellWrite>;
        return [
          for (final w in writes)
            _price(
              productId: w.productId,
              priceListId: w.priceListId,
              price: w.price,
            ),
        ];
      });
    }

    List<PriceCellWrite> capturedWrites() =>
        verify(() => productPriceRepository.applyPriceChanges(captureAny()))
                .captured
                .single
            as List<PriceCellWrite>;

    test(
      'fillDown copies the first shown row down every other shown row, as '
      'ONE undoable change regardless of row count (FR-016, SC-004)',
      () async {
        await primeWith([
          _price(productId: 1, priceListId: 5, price: '10.00'),
          _price(productId: 2, priceListId: 5, price: '20.00'),
        ]);
        stubBulk();

        final changed = await container
            .read(pricingGridControllerProvider(filter).notifier)
            .fillDown(priceListId: 5);

        expect(changed, 2);
        final state = container
            .read(pricingGridControllerProvider(filter))
            .requireValue;
        expect(state.history, hasLength(1));
        expect(state.history.single.kind, PriceChangeKind.fillDown);
        expect(state.history.single.writes, hasLength(2));
        expect(
          state.history.single.writes.map((w) => w.next),
          everyElement('10.00'),
        );
        // The source row is not rewritten with its own value.
        expect(
          state.history.single.writes.map((w) => w.cell.productId),
          isNot(contains(1)),
        );
      },
    );

    test('fillDown is a no-op when the first shown row has no price on that '
        'column — nothing to copy', () async {
      await primeWith([_price(productId: 2, priceListId: 5, price: '20.00')]);

      final changed = await container
          .read(pricingGridControllerProvider(filter).notifier)
          .fillDown(priceListId: 5);

      expect(changed, 0);
      verifyNever(() => productPriceRepository.applyPriceChanges(any()));
    });

    test(
      'copyFromCostList skips rows with no cost price rather than creating '
      'them at zero, and reads the cost list at id 0 (FR-019a)',
      () async {
        await primeWith([
          _price(productId: 1, priceListId: 0, price: '7.00'),
          _price(productId: 3, priceListId: 0, price: '9.00'),
        ]);
        stubBulk();

        final changed = await container
            .read(pricingGridControllerProvider(filter).notifier)
            .copyFromCostList(priceListId: 5);

        expect(changed, 2);
        final writes = capturedWrites();
        expect(writes.map((w) => w.productId), unorderedEquals([1, 3]));
        expect(writes.map((w) => w.price), unorderedEquals(['7.00', '9.00']));
      },
    );

    test('adjustByPercent moves only rows that already have a price on that '
        'column — an unpriced cell is never created at 0', () async {
      await primeWith([
        _price(productId: 1, priceListId: 5, price: '100.00'),
        _price(productId: 2, priceListId: 5, price: '50.00'),
      ]);
      stubBulk();

      final changed = await container
          .read(pricingGridControllerProvider(filter).notifier)
          .adjustByPercent(priceListId: 5, percent: Decimal.fromInt(5));

      expect(changed, 2);
      final writes = capturedWrites();
      expect(writes.map((w) => w.productId), unorderedEquals([1, 2]));
      // Canonical decimal strings, not fixed-precision display strings —
      // the wire stores the value, the UI formats it on the way out.
      expect(writes.firstWhere((w) => w.productId == 1).price, '105');
      expect(writes.firstWhere((w) => w.productId == 2).price, '52.5');
    });

    test('adjustByPercent accepts a negative percentage', () async {
      await primeWith([_price(productId: 1, priceListId: 5, price: '100.00')]);
      stubBulk();

      await container
          .read(pricingGridControllerProvider(filter).notifier)
          .adjustByPercent(priceListId: 5, percent: Decimal.fromInt(-10));

      expect(capturedWrites().single.price, '90');
    });

    test(
      'a column action sends every cell exactly once — a repeated '
      '(product, price_list) is a 400 from mbe-api, deliberately',
      () async {
        await primeWith([
          _price(productId: 1, priceListId: 5, price: '10.00'),
          _price(productId: 2, priceListId: 5, price: '20.00'),
        ]);
        stubBulk();

        await container
            .read(pricingGridControllerProvider(filter).notifier)
            .adjustByPercent(priceListId: 5, percent: Decimal.fromInt(10));

        final writes = capturedWrites();
        final keys = writes.map((w) => '${w.productId}:${w.priceListId}');
        expect(keys.toSet(), hasLength(writes.length));
      },
    );

    test(
      'a failed column action leaves no row changed and no history entry — '
      'the write is all-or-nothing server-side, so there is nothing to roll '
      'back locally (FR-015)',
      () async {
        await primeWith([
          _price(productId: 1, priceListId: 5, price: '10.00'),
          _price(productId: 2, priceListId: 5, price: '20.00'),
        ]);
        when(
          () => productPriceRepository.applyPriceChanges(any()),
        ).thenThrow(const AppError.server());

        await expectLater(
          () => container
              .read(pricingGridControllerProvider(filter).notifier)
              .adjustByPercent(priceListId: 5, percent: Decimal.fromInt(5)),
          throwsA(isA<AppError>()),
        );

        final state = container
            .read(pricingGridControllerProvider(filter))
            .requireValue;
        expect(state.history, isEmpty);
        expect(state.inFlight, isEmpty);
        expect(state.valueOf(
          const PriceCellKey(productId: 1, priceListId: 5),
        ), '10.00');
      },
    );

    test('costListOf finds the deployment cost list at id 0, which a '
        'truthiness check would miss (FR-019a)', () async {
      await primeWith(const []);

      final state = container
          .read(pricingGridControllerProvider(filter))
          .requireValue;
      final notifier = container.read(
        pricingGridControllerProvider(filter).notifier,
      );

      expect(notifier.costListOf(state)?.priceListId, 0);
    });
  });

  group('PricingGridController undo & revert (spec 033 US4)', () {
    late MockProductRepository productRepository;
    late MockPriceListRepository priceListRepository;
    late MockProductPriceRepository productPriceRepository;
    late ProviderContainer container;

    setUp(() async {
      productRepository = MockProductRepository();
      priceListRepository = MockPriceListRepository();
      productPriceRepository = MockProductPriceRepository();
      // `commitCell` now routes through `formattersProvider` (spec 036 US8,
      // contracts/app-settings-additions.md C3), which chains through
      // `resolvedLocaleProvider`/`UserDisplayPreferencesController` down to
      // `sharedPreferencesProvider` — needs a value here too, or resolving
      // it throws.
      SharedPreferences.setMockInitialValues({});
      final sharedPreferences = await SharedPreferences.getInstance();
      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
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
    final saleList = _priceList(5);

    Future<void> primeWith(List<ProductPrice> prices, {int products = 3}) async {
      when(() => priceListRepository.list(limit: 100)).thenAnswer(
        (_) async => PriceListResult(items: [saleList], total: 1),
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
          missingPriceList: null,
          skip: 0,
          limit: 20,
        ),
      ).thenAnswer(
        (_) async => ProductListResult(
          items: [for (var i = 1; i <= products; i++) _product(i)],
          total: products,
        ),
      );
      when(
        () => productPriceRepository.listForProducts(
          productIds: [for (var i = 1; i <= products; i++) i],
          priceListIds: [5],
        ),
      ).thenAnswer((_) async => prices);
      await container.read(pricingGridControllerProvider(filter).future);
    }

    void stubBulk() {
      when(() => productPriceRepository.applyPriceChanges(any())).thenAnswer((
        invocation,
      ) async {
        final writes =
            invocation.positionalArguments.first as List<PriceCellWrite>;
        return [
          for (final w in writes)
            _price(
              productId: w.productId,
              priceListId: w.priceListId,
              price: w.price,
            ),
        ];
      });
    }

    List<PriceCellWrite> lastWrites() =>
        verify(() => productPriceRepository.applyPriceChanges(captureAny()))
                .captured
                .last
            as List<PriceCellWrite>;

    test(
      'a multi-write column action reverses in ONE undo, restoring every '
      'cell it touched (SC-004, FR-016)',
      () async {
        await primeWith([
          _price(productId: 1, priceListId: 5, price: '10.00'),
          _price(productId: 2, priceListId: 5, price: '20.00'),
          _price(productId: 3, priceListId: 5, price: '30.00'),
        ]);
        stubBulk();
        final notifier = container.read(
          pricingGridControllerProvider(filter).notifier,
        );

        await notifier.adjustByPercent(
          priceListId: 5,
          percent: Decimal.fromInt(10),
        );
        expect(
          container.read(pricingGridControllerProvider(filter)).requireValue.history,
          hasLength(1),
        );

        final undone = await notifier.undoLast();

        expect(undone, 3);
        final state = container
            .read(pricingGridControllerProvider(filter))
            .requireValue;
        expect(state.history, isEmpty);
        expect(
          lastWrites().map((w) => w.price),
          unorderedEquals(['10.00', '20.00', '30.00']),
        );
      },
    );

    test('undoLast on an empty history is a no-op', () async {
      await primeWith(const []);

      final undone = await container
          .read(pricingGridControllerProvider(filter).notifier)
          .undoLast();

      expect(undone, 0);
      verifyNever(() => productPriceRepository.applyPriceChanges(any()));
    });

    test(
      'undoing a change that CREATED a price skips that cell — there is no '
      'delete in the bulk write, and the count says so rather than pretending',
      () async {
        await primeWith(const []);
        // spec 036 R10: sent as the canonical, trailing-zero-stripped value.
        when(
          () => productPriceRepository.create(
            productId: 1,
            priceListId: 5,
            price: '25',
          ),
        ).thenAnswer(
          (_) async => _price(productId: 1, priceListId: 5, price: '25.00'),
        );
        final notifier = container.read(
          pricingGridControllerProvider(filter).notifier,
        );
        await notifier.commitCell(productId: 1, priceListId: 5, typed: '25.00');

        final undone = await notifier.undoLast();

        expect(undone, 0);
        verifyNever(() => productPriceRepository.applyPriceChanges(any()));
        // The entry still leaves the history — there is nothing left to undo.
        expect(
          container.read(pricingGridControllerProvider(filter)).requireValue.history,
          isEmpty,
        );
      },
    );

    test('revertAll restores every changed cell to its load-time baseline and '
        'clears the history (FR-024)', () async {
      await primeWith([
        _price(productId: 1, priceListId: 5, price: '10.00'),
        _price(productId: 2, priceListId: 5, price: '20.00'),
      ]);
      stubBulk();
      final notifier = container.read(
        pricingGridControllerProvider(filter).notifier,
      );

      await notifier.adjustByPercent(
        priceListId: 5,
        percent: Decimal.fromInt(50),
      );
      final reverted = await notifier.revertAll();

      expect(reverted, 2);
      expect(
        lastWrites().map((w) => w.price),
        unorderedEquals(['10.00', '20.00']),
      );
      final state = container
          .read(pricingGridControllerProvider(filter))
          .requireValue;
      expect(state.history, isEmpty);
      expect(state.hasChanges, isFalse);
    });

    test('revertAll clears rejected cells even when no price needs restoring '
        '(FR-024)', () async {
      await primeWith([_price(productId: 1, priceListId: 5, price: '10.00')]);
      final notifier = container.read(
        pricingGridControllerProvider(filter).notifier,
      );
      await notifier.commitCell(productId: 1, priceListId: 5, typed: 'abc');
      expect(
        container.read(pricingGridControllerProvider(filter)).requireValue.rejectedCount,
        1,
      );

      await notifier.revertAll();

      final state = container
          .read(pricingGridControllerProvider(filter))
          .requireValue;
      expect(state.rejected, isEmpty);
      expect(state.hasChanges, isFalse);
      verifyNever(() => productPriceRepository.applyPriceChanges(any()));
    });

    test('changedCount and rejectedCount drive the summary bar off the rows '
        'themselves, so they cannot drift (FR-023)', () async {
      await primeWith([
        _price(productId: 1, priceListId: 5, price: '10.00'),
        _price(productId: 2, priceListId: 5, price: '20.00'),
      ]);
      // spec 036 R10: sent as the canonical, trailing-zero-stripped value.
      when(
        () => productPriceRepository.update(productPriceId: 105, price: '11'),
      ).thenAnswer(
        (_) async => _price(productId: 1, priceListId: 5, price: '11.00'),
      );
      final notifier = container.read(
        pricingGridControllerProvider(filter).notifier,
      );

      await notifier.commitCell(productId: 1, priceListId: 5, typed: '11.00');
      await notifier.commitCell(productId: 2, priceListId: 5, typed: 'abc');

      final state = container
          .read(pricingGridControllerProvider(filter))
          .requireValue;
      expect(state.changedCount, 1);
      expect(state.rejectedCount, 1);
      expect(state.hasChanges, isTrue);
    });
  });
}
