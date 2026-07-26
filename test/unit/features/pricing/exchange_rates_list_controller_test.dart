import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/pricing/data/exchange_rate_repository_impl.dart';
import 'package:mbe_ui/features/pricing/domain/entities/exchange_rate.dart';
import 'package:mbe_ui/features/pricing/domain/repositories/exchange_rate_repository.dart';
import 'package:mbe_ui/features/pricing/presentation/exchange_rates_list_controller.dart';

class MockExchangeRateRepository extends Mock
    implements ExchangeRateRepository {}

ExchangeRate _rate(int id) => ExchangeRate(
  exchangeRateId: id,
  date: DateTime(2026, 7, id),
  rate: '17.50',
  rawBase: 1,
  rawTarget: 0,
);

void main() {
  late MockExchangeRateRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = MockExchangeRateRepository();
    container = ProviderContainer(
      overrides: [exchangeRateRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
  });

  group(
    'ExchangeRateFilter.fromQuery (017-ui-consistency-filters FR-017)',
    () {
      test('derives every field from a ListQuery', () {
        final filter = ExchangeRateFilter.fromQuery(
          const ListQuery(
            pageIndex: 2,
            facets: {
              'dateFrom': ['2026-01-01'],
              'dateTo': ['2026-12-31'],
              'base': ['1'],
              'target': ['0'],
            },
          ),
        );

        expect(filter.dateFrom, DateTime(2026, 1, 1));
        expect(filter.dateTo, DateTime(2026, 12, 31));
        expect(filter.base, 1);
        expect(filter.target, 0);
        expect(filter.pageIndex, 2);
      });

      test('defaults from an empty ListQuery', () {
        final filter = ExchangeRateFilter.fromQuery(const ListQuery());

        expect(filter.dateFrom, isNull);
        expect(filter.dateTo, isNull);
        expect(filter.base, isNull);
        expect(filter.target, isNull);
        expect(filter.pageIndex, 0);
      });

      test('an unparseable date degrades to null (absent)', () {
        final filter = ExchangeRateFilter.fromQuery(
          const ListQuery(
            facets: {
              'dateFrom': ['not-a-date'],
            },
          ),
        );

        expect(filter.dateFrom, isNull);
      });
    },
  );

  group(
    'ExchangeRatesListController (a family keyed by ExchangeRateFilter)',
    () {
      test(
        'build(filter) maps the filter to repository query params',
        () async {
          when(
            () => repository.list(
              dateFrom: null,
              dateTo: null,
              base: null,
              target: null,
              skip: 0,
              limit: 20,
            ),
          ).thenAnswer(
            (_) async => ExchangeRateResult(items: [_rate(1)], total: 1),
          );

          const filter = ExchangeRateFilter();
          final result = await container.read(
            exchangeRatesListControllerProvider(filter).future,
          );

          expect(result.items, hasLength(1));
          expect(result.total, 1);
        },
      );

      test(
        'a different pageIndex maps to skip = pageIndex * pageSize',
        () async {
          when(
            () => repository.list(
              dateFrom: null,
              dateTo: null,
              base: null,
              target: null,
              skip: 0,
              limit: 20,
            ),
          ).thenAnswer(
            (_) async => ExchangeRateResult(items: [_rate(1)], total: 21),
          );
          when(
            () => repository.list(
              dateFrom: null,
              dateTo: null,
              base: null,
              target: null,
              skip: 20,
              limit: 20,
            ),
          ).thenAnswer(
            (_) async => ExchangeRateResult(items: [_rate(2)], total: 21),
          );

          final page0 = await container.read(
            exchangeRatesListControllerProvider(
              const ExchangeRateFilter(),
            ).future,
          );
          final page1 = await container.read(
            exchangeRatesListControllerProvider(
              const ExchangeRateFilter(pageIndex: 1),
            ).future,
          );

          expect(page0.items.map((r) => r.exchangeRateId), [1]);
          expect(page0.pageIndex, 0);
          expect(page1.items.map((r) => r.exchangeRateId), [2]);
          expect(page1.pageIndex, 1);
        },
      );

      test(
        'invalidating the provider re-fetches the SAME page rather than '
        'resetting to page 0 (017-ui-consistency-filters FR-025, research §3)',
        () async {
          const filter = ExchangeRateFilter(pageIndex: 1);
          when(
            () => repository.list(
              dateFrom: null,
              dateTo: null,
              base: null,
              target: null,
              skip: 20,
              limit: 20,
            ),
          ).thenAnswer(
            (_) async => ExchangeRateResult(items: [_rate(2)], total: 21),
          );

          await container.read(
            exchangeRatesListControllerProvider(filter).future,
          );

          when(
            () => repository.list(
              dateFrom: null,
              dateTo: null,
              base: null,
              target: null,
              skip: 20,
              limit: 20,
            ),
          ).thenAnswer(
            (_) async => ExchangeRateResult(items: [_rate(99)], total: 21),
          );
          container.invalidate(exchangeRatesListControllerProvider(filter));

          final refreshed = await container.read(
            exchangeRatesListControllerProvider(filter).future,
          );
          expect(refreshed.pageIndex, 1);
          expect(refreshed.items.single.exchangeRateId, 99);
        },
      );
    },
  );
}
