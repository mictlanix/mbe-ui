import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

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

  group('ExchangeRateFilterController', () {
    test('starts with an empty filter', () {
      final filter = container.read(exchangeRateFilterControllerProvider);
      expect(filter.dateFrom, isNull);
      expect(filter.dateTo, isNull);
      expect(filter.base, isNull);
      expect(filter.target, isNull);
    });

    test('dateRangeChanged and currencyPairChanged update state', () {
      final notifier = container.read(
        exchangeRateFilterControllerProvider.notifier,
      );
      notifier
        ..dateRangeChanged(DateTime(2026, 1, 1), DateTime(2026, 12, 31))
        ..currencyPairChanged(1, 0);

      final filter = container.read(exchangeRateFilterControllerProvider);
      expect(filter.dateFrom, DateTime(2026, 1, 1));
      expect(filter.dateTo, DateTime(2026, 12, 31));
      expect(filter.base, 1);
      expect(filter.target, 0);
    });

    test('reset clears the filter', () {
      final notifier = container.read(
        exchangeRateFilterControllerProvider.notifier,
      );
      notifier
        ..dateRangeChanged(DateTime(2026, 1, 1), DateTime(2026, 12, 31))
        ..currencyPairChanged(1, 0)
        ..reset();

      final filter = container.read(exchangeRateFilterControllerProvider);
      expect(filter.dateFrom, isNull);
      expect(filter.base, isNull);
    });
  });

  group('ExchangeRatesListController', () {
    test(
      'build() maps the current filter to repository query params',
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

        final result = await container.read(
          exchangeRatesListControllerProvider.future,
        );

        expect(result.items, hasLength(1));
        expect(result.total, 1);
      },
    );

    test('goToPage replaces the current page with the requested one', () async {
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
      await container.read(exchangeRatesListControllerProvider.future);

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

      await container
          .read(exchangeRatesListControllerProvider.notifier)
          .goToPage(1);

      final page = container.read(exchangeRatesListControllerProvider).value!;
      expect(page.items.map((r) => r.exchangeRateId), [2]);
      expect(page.pageIndex, 1);
    });
  });
}
