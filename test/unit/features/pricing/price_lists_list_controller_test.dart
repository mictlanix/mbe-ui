import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

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

  group('PriceListSearchController', () {
    test('starts empty', () {
      expect(container.read(priceListSearchControllerProvider), '');
    });

    test('updates on searchChanged', () {
      container
          .read(priceListSearchControllerProvider.notifier)
          .searchChanged('Retail');
      expect(container.read(priceListSearchControllerProvider), 'Retail');
    });
  });

  group('PriceListsListController', () {
    test(
      'build() maps the current search to repository query params',
      () async {
        when(
          () => repository.list(search: null, skip: 0, limit: 20),
        ).thenAnswer(
          (_) async => PriceListResult(items: [_priceList(1)], total: 1),
        );

        final result = await container.read(
          priceListsListControllerProvider.future,
        );

        expect(result.items, hasLength(1));
        expect(result.total, 1);
      },
    );

    test('changing the search text re-fetches from skip=0', () async {
      when(() => repository.list(search: null, skip: 0, limit: 20)).thenAnswer(
        (_) async => PriceListResult(items: [_priceList(1)], total: 1),
      );
      await container.read(priceListsListControllerProvider.future);

      when(
        () => repository.list(search: 'Retail', skip: 0, limit: 20),
      ).thenAnswer(
        (_) async => PriceListResult(items: [_priceList(2)], total: 1),
      );
      container
          .read(priceListSearchControllerProvider.notifier)
          .searchChanged('Retail');

      final result = await container.read(
        priceListsListControllerProvider.future,
      );
      expect(result.items.single.priceListId, 2);
    });

    test('goToPage replaces the current page with the requested one', () async {
      when(() => repository.list(search: null, skip: 0, limit: 20)).thenAnswer(
        (_) async => PriceListResult(items: [_priceList(1)], total: 21),
      );
      await container.read(priceListsListControllerProvider.future);

      when(() => repository.list(search: null, skip: 20, limit: 20)).thenAnswer(
        (_) async => PriceListResult(items: [_priceList(2)], total: 21),
      );

      await container
          .read(priceListsListControllerProvider.notifier)
          .goToPage(1);

      final page = container.read(priceListsListControllerProvider).value!;
      expect(page.items.map((p) => p.priceListId), [2]);
      expect(page.pageIndex, 1);
      expect(page.total, 21);
    });
  });
}
