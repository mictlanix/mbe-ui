import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product_label_facet.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/product_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/products_list_controller.dart';

class MockProductRepository extends Mock implements ProductRepository {}

ProductListItem _item(int id) => ProductListItem(
  productId: id,
  code: 'SKU-$id',
  name: 'Product $id',
  unitOfMeasurementCode: 'PCE',
  unitOfMeasurementName: 'Piece',
  taxRate: '0.16',
  status: EntityStatus.active,
);

void main() {
  late MockProductRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = MockProductRepository();
    container = ProviderContainer(
      overrides: [productRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
  });

  group('ProductFilter.fromQuery (017-ui-consistency-filters FR-017)', () {
    test('derives every field from a ListQuery', () {
      final filter = ProductFilter.fromQuery(
        const ListQuery(
          search: 'widget',
          pageIndex: 2,
          facets: {
            'status': ['active'],
            'stockable': ['true'],
            'salable': ['true'],
            'purchasable': ['true'],
            'label': ['3', '7'],
          },
        ),
      );

      expect(filter.search, 'widget');
      expect(filter.pageIndex, 2);
      expect(filter.status, EntityStatus.active);
      expect(filter.stockable, isTrue);
      expect(filter.salable, isTrue);
      expect(filter.purchasable, isTrue);
      expect(filter.labels, [3, 7]);
    });

    test('defaults from an empty ListQuery', () {
      final filter = ProductFilter.fromQuery(const ListQuery());

      expect(filter.search, '');
      expect(filter.pageIndex, 0);
      // spec 035 FR-001/FR-002: an absent status facet now defaults to
      // Active, not "no filter" — the "All" choice is the explicit
      // `status=all` case, covered separately below.
      expect(filter.status, EntityStatus.active);
      expect(filter.stockable, isNull);
      expect(filter.salable, isNull);
      expect(filter.purchasable, isNull);
      expect(filter.labels, isEmpty);
    });

    test('an explicit "all" status clears the default (FR-004)', () {
      final filter = ProductFilter.fromQuery(
        const ListQuery(
          facets: {
            'status': ['all'],
          },
        ),
      );

      expect(filter.status, isNull);
    });

    test('an unparseable tri-state value degrades to null (absent)', () {
      final filter = ProductFilter.fromQuery(
        const ListQuery(
          facets: {
            'stockable': ['not-a-bool'],
          },
        ),
      );

      expect(filter.stockable, isNull);
    });
  });

  group('ProductFilter.activeFilterCount', () {
    test('is zero for the default filter (inactive included, no facets)', () {
      const filter = ProductFilter();
      expect(filter.activeFilterCount, 0);
      expect(filter.hasActiveFilters, isFalse);
    });

    test('ignores search text and the default status == null', () {
      const filter = ProductFilter(search: 'widget');
      expect(filter.activeFilterCount, 0);
      expect(filter.hasActiveFilters, isFalse);
    });

    test('counts narrowing to active-only (status == active)', () {
      const filter = ProductFilter(status: EntityStatus.active);
      expect(filter.activeFilterCount, 1);
      expect(filter.hasActiveFilters, isTrue);
    });

    test('counts each set attribute facet and a single selected label', () {
      const filter = ProductFilter(
        status: EntityStatus.active,
        stockable: true,
        salable: false,
        purchasable: true,
        labels: [3],
      );
      expect(filter.activeFilterCount, 5);
    });

    test('counts each selected label individually (FR-009)', () {
      const filter = ProductFilter(labels: [1, 2, 3]);
      expect(filter.activeFilterCount, 3);
      expect(filter.hasActiveFilters, isTrue);
    });
  });

  group('ProductsListController (a family keyed by ProductFilter)', () {
    test('build(filter) maps the filter to repository query params', () async {
      when(
        () => repository.list(
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
      ).thenAnswer((_) async => ProductListResult(items: [_item(1)], total: 1));

      const filter = ProductFilter();
      final result = await container.read(
        productsListControllerProvider(filter).future,
      );

      expect(result.items, hasLength(1));
      expect(result.total, 1);
    });

    test(
      'a different filter maps to a different provider instance and query',
      () async {
        when(
          () => repository.list(
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
          (_) async => ProductListResult(items: [_item(1)], total: 1),
        );
        when(
          () => repository.list(
            search: 'widget',
            status: EntityStatus.active,
            stockable: null,
            salable: null,
            purchasable: null,
            supplier: null,
            labels: const [],
            skip: 0,
            limit: 20,
          ),
        ).thenAnswer(
          (_) async => ProductListResult(items: [_item(2)], total: 1),
        );

        final first = await container.read(
          productsListControllerProvider(const ProductFilter()).future,
        );
        final second = await container.read(
          productsListControllerProvider(
            const ProductFilter(search: 'widget', status: EntityStatus.active),
          ).future,
        );

        expect(first.items.single.productId, 1);
        expect(second.items.single.productId, 2);
      },
    );

    test('a different pageIndex maps to skip = pageIndex * pageSize', () async {
      when(
        () => repository.list(
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
        (_) async => ProductListResult(items: [_item(1)], total: 21),
      );
      when(
        () => repository.list(
          search: null,
          status: null,
          stockable: null,
          salable: null,
          purchasable: null,
          supplier: null,
          labels: const [],
          skip: 20,
          limit: 20,
        ),
      ).thenAnswer(
        (_) async => ProductListResult(items: [_item(2)], total: 21),
      );

      final page0 = await container.read(
        productsListControllerProvider(const ProductFilter()).future,
      );
      final page1 = await container.read(
        productsListControllerProvider(
          const ProductFilter(pageIndex: 1),
        ).future,
      );

      expect(page0.items.map((p) => p.productId), [1]);
      expect(page0.pageIndex, 0);
      expect(page1.items.map((p) => p.productId), [2]);
      expect(page1.pageIndex, 1);
      expect(page1.total, 21);
    });

    test(
      'invalidating the provider re-fetches the SAME page rather than '
      'resetting to page 0 (017-ui-consistency-filters FR-025, research §3)',
      () async {
        const filter = ProductFilter(pageIndex: 1);
        when(
          () => repository.list(
            search: null,
            status: null,
            stockable: null,
            salable: null,
            purchasable: null,
            supplier: null,
            labels: const [],
            skip: 20,
            limit: 20,
          ),
        ).thenAnswer(
          (_) async => ProductListResult(items: [_item(2)], total: 21),
        );

        await container.read(productsListControllerProvider(filter).future);

        when(
          () => repository.list(
            search: null,
            status: null,
            stockable: null,
            salable: null,
            purchasable: null,
            supplier: null,
            labels: const [],
            skip: 20,
            limit: 20,
          ),
        ).thenAnswer(
          (_) async => ProductListResult(items: [_item(99)], total: 21),
        );
        container.invalidate(productsListControllerProvider(filter));

        final refreshed = await container.read(
          productsListControllerProvider(filter).future,
        );
        expect(refreshed.pageIndex, 1);
        expect(refreshed.items.single.productId, 99);
      },
    );
  });

  group(
    'productLabelFacetsProvider (spec 009, a family keyed by ProductFilter)',
    () {
      test('maps the repository response to a label-id -> count map', () async {
        when(
          () => repository.productLabelFacets(
            search: any(named: 'search'),
            status: any(named: 'status'),
            stockable: any(named: 'stockable'),
            salable: any(named: 'salable'),
            purchasable: any(named: 'purchasable'),
            labels: any(named: 'labels'),
          ),
        ).thenAnswer(
          (_) async => const [
            ProductLabelFacet(labelId: 3, count: 42),
            ProductLabelFacet(labelId: 7, count: 12),
          ],
        );

        const filter = ProductFilter();
        final result = await container.read(
          productLabelFacetsProvider(filter).future,
        );

        expect(result, {3: 42, 7: 12});
      });

      test('refetches when the ProductFilter changes (FR-003)', () async {
        when(
          () => repository.productLabelFacets(
            search: null,
            status: null,
            stockable: null,
            salable: null,
            purchasable: null,
            labels: const [],
          ),
        ).thenAnswer(
          (_) async => const [ProductLabelFacet(labelId: 1, count: 5)],
        );
        final first = await container.read(
          productLabelFacetsProvider(const ProductFilter()).future,
        );
        expect(first, {1: 5});

        when(
          () => repository.productLabelFacets(
            search: null,
            status: null,
            stockable: null,
            salable: null,
            purchasable: null,
            labels: const [1],
          ),
        ).thenAnswer(
          (_) async => const [
            ProductLabelFacet(labelId: 1, count: 5),
            ProductLabelFacet(labelId: 2, count: 3),
          ],
        );

        final second = await container.read(
          productLabelFacetsProvider(const ProductFilter(labels: [1])).future,
        );

        expect(second, {1: 5, 2: 3});
      });

      test(
        'an empty facet response yields an empty map (nothing available)',
        () async {
          when(
            () => repository.productLabelFacets(
              search: any(named: 'search'),
              status: any(named: 'status'),
              stockable: any(named: 'stockable'),
              salable: any(named: 'salable'),
              purchasable: any(named: 'purchasable'),
              labels: any(named: 'labels'),
            ),
          ).thenAnswer((_) async => const []);

          final result = await container.read(
            productLabelFacetsProvider(const ProductFilter()).future,
          );

          expect(result, isEmpty);
        },
      );
    },
  );
}
