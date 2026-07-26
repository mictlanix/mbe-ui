import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/pricing/data/exchange_rate_repository_impl.dart';
import 'package:mbe_ui/features/pricing/domain/entities/exchange_rate.dart';

part 'exchange_rates_list_controller.freezed.dart';
part 'exchange_rates_list_controller.g.dart';

const _pageSize = 20;

/// Parses an ISO `yyyy-MM-dd` facet value, degrading to `null` (absent) on
/// any unparseable input (contracts/list-query.md §5) rather than throwing.
DateTime? _parseIsoDate(String? raw) =>
    raw != null ? DateTime.tryParse(raw) : null;

/// Encodes [date] as the `yyyy-MM-dd` facet value [ExchangeRateFilter.fromQuery]
/// expects — used by the screen when writing `dateFrom`/`dateTo` into the URL.
String toIsoDateFacet(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

/// The exchange-rates screen's addressable view state
/// (017-ui-consistency-filters FR-015, FR-017): a date range and a
/// base/target currency pair, encoded as ISO `yyyy-MM-dd` date facets and
/// integer currency-code facets. Derived from the route's [ListQuery] — the
/// URL, not a mutable notifier, is the source of truth.
@freezed
class ExchangeRateFilter with _$ExchangeRateFilter {
  const factory ExchangeRateFilter({
    DateTime? dateFrom,
    DateTime? dateTo,
    int? base,
    int? target,
    @Default(0) int pageIndex,
  }) = _ExchangeRateFilter;

  factory ExchangeRateFilter.fromQuery(ListQuery query) {
    final baseRaw = query.facet('base');
    final targetRaw = query.facet('target');
    return ExchangeRateFilter(
      dateFrom: _parseIsoDate(query.facet('dateFrom')),
      dateTo: _parseIsoDate(query.facet('dateTo')),
      base: baseRaw != null ? int.tryParse(baseRaw) : null,
      target: targetRaw != null ? int.tryParse(targetRaw) : null,
      pageIndex: query.pageIndex,
    );
  }
}

/// Fetches and holds the exchange-rates list (FR-014, FR-015) for the given
/// [ExchangeRateFilter]. A family keyed by the filter value: a different
/// URL is a different provider instance, and `ref.invalidate` after a
/// mutation re-fetches the *same* page rather than resetting to page 0
/// (FR-025, research §3).
@riverpod
class ExchangeRatesListController extends _$ExchangeRatesListController {
  @override
  Future<CatalogPage<ExchangeRate>> build(ExchangeRateFilter filter) {
    return fetchClampedPage(
      pageIndex: filter.pageIndex,
      pageSize: _pageSize,
      fetch: (pageIndex) => _fetch(filter.copyWith(pageIndex: pageIndex)),
    );
  }

  Future<CatalogPage<ExchangeRate>> _fetch(ExchangeRateFilter filter) async {
    final result = await ref
        .read(exchangeRateRepositoryProvider)
        .list(
          dateFrom: filter.dateFrom,
          dateTo: filter.dateTo,
          base: filter.base,
          target: filter.target,
          skip: filter.pageIndex * _pageSize,
          limit: _pageSize,
        );
    return CatalogPage(
      items: result.items,
      total: result.total,
      pageIndex: filter.pageIndex,
      pageSize: _pageSize,
    );
  }
}
