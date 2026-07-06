import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
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
  deactivated: false,
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

  group('ProductFilterController', () {
    test('starts with an empty filter', () {
      final filter = container.read(productFilterControllerProvider);
      expect(filter.search, '');
      expect(filter.deactivated, isNull);
      expect(filter.stockable, isNull);
      expect(filter.salable, isNull);
      expect(filter.purchasable, isNull);
    });

    test('updates each field independently', () {
      final notifier = container.read(productFilterControllerProvider.notifier);

      notifier.searchChanged('widget');
      notifier.deactivatedChanged(false);
      notifier.stockableChanged(true);
      notifier.salableChanged(true);
      notifier.purchasableChanged(true);

      final filter = container.read(productFilterControllerProvider);
      expect(filter.search, 'widget');
      expect(filter.deactivated, isFalse);
      expect(filter.stockable, isTrue);
      expect(filter.salable, isTrue);
      expect(filter.purchasable, isTrue);
    });

    test('reset() clears every facet but preserves the search text', () {
      final notifier = container.read(productFilterControllerProvider.notifier);
      notifier
        ..searchChanged('widget')
        ..deactivatedChanged(false)
        ..stockableChanged(true)
        ..salableChanged(false)
        ..purchasableChanged(true)
        ..labelsChanged([7]);

      notifier.reset();

      final filter = container.read(productFilterControllerProvider);
      expect(filter.search, 'widget');
      expect(filter.deactivated, isNull);
      expect(filter.stockable, isNull);
      expect(filter.salable, isNull);
      expect(filter.purchasable, isNull);
      expect(filter.labels, isEmpty);
    });
  });

  group('ProductFilter.activeFilterCount', () {
    test('is zero for the default filter (inactive included, no facets)', () {
      const filter = ProductFilter();
      expect(filter.activeFilterCount, 0);
      expect(filter.hasActiveFilters, isFalse);
    });

    test('ignores search text and the default deactivated == null', () {
      const filter = ProductFilter(search: 'widget');
      expect(filter.activeFilterCount, 0);
      expect(filter.hasActiveFilters, isFalse);
    });

    test('counts narrowing to active-only (deactivated == false)', () {
      const filter = ProductFilter(deactivated: false);
      expect(filter.activeFilterCount, 1);
      expect(filter.hasActiveFilters, isTrue);
    });

    test('counts each set attribute facet and a single selected label', () {
      const filter = ProductFilter(
        deactivated: false,
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

  group('ProductsListController', () {
    test(
      'build() maps the current filter to repository query params',
      () async {
        when(
          () => repository.list(
            search: null,
            deactivated: null,
            stockable: null,
            salable: null,
            purchasable: null,
            labels: const [],
            skip: 0,
            limit: 20,
          ),
        ).thenAnswer(
          (_) async => ProductListResult(items: [_item(1)], total: 1),
        );

        final result = await container.read(
          productsListControllerProvider.future,
        );

        expect(result.items, hasLength(1));
        expect(result.total, 1);
      },
    );

    test(
      'changing the filter re-fetches from skip=0 with the new params',
      () async {
        when(
          () => repository.list(
            search: null,
            deactivated: null,
            stockable: null,
            salable: null,
            purchasable: null,
            labels: const [],
            skip: 0,
            limit: 20,
          ),
        ).thenAnswer(
          (_) async => ProductListResult(items: [_item(1)], total: 1),
        );
        await container.read(productsListControllerProvider.future);

        when(
          () => repository.list(
            search: 'widget',
            deactivated: false,
            stockable: null,
            salable: null,
            purchasable: null,
            labels: const [],
            skip: 0,
            limit: 20,
          ),
        ).thenAnswer(
          (_) async => ProductListResult(items: [_item(2)], total: 1),
        );

        container.read(productFilterControllerProvider.notifier)
          ..searchChanged('widget')
          ..deactivatedChanged(false);

        final result = await container.read(
          productsListControllerProvider.future,
        );
        expect(result.items.single.productId, 2);
      },
    );

    test('goToPage replaces the current page with the requested one', () async {
      when(
        () => repository.list(
          search: null,
          deactivated: null,
          stockable: null,
          salable: null,
          purchasable: null,
          labels: const [],
          skip: 0,
          limit: 20,
        ),
      ).thenAnswer(
        (_) async => ProductListResult(items: [_item(1)], total: 21),
      );
      await container.read(productsListControllerProvider.future);

      when(
        () => repository.list(
          search: null,
          deactivated: null,
          stockable: null,
          salable: null,
          purchasable: null,
          labels: const [],
          skip: 20,
          limit: 20,
        ),
      ).thenAnswer(
        (_) async => ProductListResult(items: [_item(2)], total: 21),
      );

      await container.read(productsListControllerProvider.notifier).goToPage(1);

      final page = container.read(productsListControllerProvider).value!;
      expect(page.items.map((p) => p.productId), [2]);
      expect(page.pageIndex, 1);
      expect(page.total, 21);
    });
  });
}
