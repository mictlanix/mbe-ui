import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/pricing/data/exchange_rate_repository_impl.dart';
import 'package:mbe_ui/features/pricing/domain/entities/exchange_rate.dart';

part 'exchange_rates_list_controller.freezed.dart';
part 'exchange_rates_list_controller.g.dart';

const _pageSize = 20;

/// The exchange-rates screen's filter selection (FR-015): a date range and
/// a base/target currency pair.
@freezed
class ExchangeRateFilter with _$ExchangeRateFilter {
  const factory ExchangeRateFilter({
    DateTime? dateFrom,
    DateTime? dateTo,
    int? base,
    int? target,
  }) = _ExchangeRateFilter;
}

/// Holds the current filter selection for the exchange-rates screen.
@riverpod
class ExchangeRateFilterController extends _$ExchangeRateFilterController {
  @override
  ExchangeRateFilter build() => const ExchangeRateFilter();

  void dateRangeChanged(DateTime? from, DateTime? to) =>
      state = state.copyWith(dateFrom: from, dateTo: to);

  void currencyPairChanged(int? base, int? target) =>
      state = state.copyWith(base: base, target: target);

  void reset() => state = const ExchangeRateFilter();
}

/// Fetches and holds the exchange-rates list (FR-014, FR-015), re-fetching
/// page 0 whenever the filter changes.
@riverpod
class ExchangeRatesListController extends _$ExchangeRatesListController {
  @override
  Future<CatalogPage<ExchangeRate>> build() {
    final filter = ref.watch(exchangeRateFilterControllerProvider);
    return _fetch(filter, pageIndex: 0);
  }

  Future<CatalogPage<ExchangeRate>> _fetch(
    ExchangeRateFilter filter, {
    required int pageIndex,
  }) async {
    final result = await ref
        .read(exchangeRateRepositoryProvider)
        .list(
          dateFrom: filter.dateFrom,
          dateTo: filter.dateTo,
          base: filter.base,
          target: filter.target,
          skip: pageIndex * _pageSize,
          limit: _pageSize,
        );
    return CatalogPage(
      items: result.items,
      total: result.total,
      pageIndex: pageIndex,
      pageSize: _pageSize,
    );
  }

  Future<void> goToPage(int pageIndex) async {
    final filter = ref.read(exchangeRateFilterControllerProvider);
    state = const AsyncLoading<CatalogPage<ExchangeRate>>().copyWithPrevious(
      state,
    );
    state = await AsyncValue.guard(() => _fetch(filter, pageIndex: pageIndex));
  }
}
