import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/pricing/data/price_list_repository_impl.dart';
import 'package:mbe_ui/features/pricing/domain/entities/price_list.dart';
import 'package:mbe_ui/features/pricing/domain/repositories/price_list_repository.dart';
import 'package:mbe_ui/features/pricing/presentation/price_lists_list_controller.dart';

class MockPriceListRepository extends Mock implements PriceListRepository {}

PriceList _priceList(int id) => PriceList(
  priceListId: id,
  name: 'List $id',
  highProfitMargin: '0.40',
  lowProfitMargin: '0.10',
);

void main() {
  late MockPriceListRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = MockPriceListRepository();
    container = ProviderContainer(
      overrides: [priceListRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
  });

  group('PriceListFilter.fromQuery (017-ui-consistency-filters FR-017)', () {
    test('derives every field from a ListQuery', () {
      final filter = PriceListFilter.fromQuery(
        const ListQuery(search: 'Retail', pageIndex: 2),
      );

      expect(filter.search, 'Retail');
      expect(filter.pageIndex, 2);
    });

    test('defaults from an empty ListQuery', () {
      final filter = PriceListFilter.fromQuery(const ListQuery());

      expect(filter.search, '');
      expect(filter.pageIndex, 0);
    });
  });

  group('PriceListsListController (a family keyed by PriceListFilter)', () {
    test('build(filter) maps the filter to repository query params', () async {
      when(() => repository.list(search: null, skip: 0, limit: 20)).thenAnswer(
        (_) async => PriceListResult(items: [_priceList(1)], total: 1),
      );

      const filter = PriceListFilter();
      final result = await container.read(
        priceListsListControllerProvider(filter).future,
      );

      expect(result.items, hasLength(1));
      expect(result.total, 1);
    });

    test(
      'a different search maps to a different provider instance and query',
      () async {
        when(
          () => repository.list(search: null, skip: 0, limit: 20),
        ).thenAnswer(
          (_) async => PriceListResult(items: [_priceList(1)], total: 1),
        );
        when(
          () => repository.list(search: 'Retail', skip: 0, limit: 20),
        ).thenAnswer(
          (_) async => PriceListResult(items: [_priceList(2)], total: 1),
        );

        final first = await container.read(
          priceListsListControllerProvider(const PriceListFilter()).future,
        );
        final second = await container.read(
          priceListsListControllerProvider(
            const PriceListFilter(search: 'Retail'),
          ).future,
        );

        expect(first.items.single.priceListId, 1);
        expect(second.items.single.priceListId, 2);
      },
    );

    test('a different pageIndex maps to skip = pageIndex * pageSize', () async {
      when(() => repository.list(search: null, skip: 0, limit: 20)).thenAnswer(
        (_) async => PriceListResult(items: [_priceList(1)], total: 21),
      );
      when(() => repository.list(search: null, skip: 20, limit: 20)).thenAnswer(
        (_) async => PriceListResult(items: [_priceList(2)], total: 21),
      );

      final page0 = await container.read(
        priceListsListControllerProvider(const PriceListFilter()).future,
      );
      final page1 = await container.read(
        priceListsListControllerProvider(
          const PriceListFilter(pageIndex: 1),
        ).future,
      );

      expect(page0.items.map((p) => p.priceListId), [1]);
      expect(page0.pageIndex, 0);
      expect(page1.items.map((p) => p.priceListId), [2]);
      expect(page1.pageIndex, 1);
      expect(page1.total, 21);
    });

    test(
      'invalidating the provider re-fetches the SAME page rather than '
      'resetting to page 0 (017-ui-consistency-filters FR-025, research §3)',
      () async {
        const filter = PriceListFilter(pageIndex: 1);
        when(
          () => repository.list(search: null, skip: 20, limit: 20),
        ).thenAnswer(
          (_) async => PriceListResult(items: [_priceList(2)], total: 21),
        );

        await container.read(priceListsListControllerProvider(filter).future);

        when(
          () => repository.list(search: null, skip: 20, limit: 20),
        ).thenAnswer(
          (_) async => PriceListResult(items: [_priceList(99)], total: 21),
        );
        container.invalidate(priceListsListControllerProvider(filter));

        final refreshed = await container.read(
          priceListsListControllerProvider(filter).future,
        );
        expect(refreshed.pageIndex, 1);
        expect(refreshed.items.single.priceListId, 99);
      },
    );
  });
}
