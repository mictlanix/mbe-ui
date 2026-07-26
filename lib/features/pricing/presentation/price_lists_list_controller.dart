import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/pricing/data/price_list_repository_impl.dart';
import 'package:mbe_ui/features/pricing/domain/entities/price_list.dart';

part 'price_lists_list_controller.freezed.dart';
part 'price_lists_list_controller.g.dart';

const _pageSize = 20;

/// The price-lists screen's addressable view state
/// (017-ui-consistency-filters FR-005, FR-017): search only. Derived from
/// the route's [ListQuery] — the URL, not a mutable notifier, is the
/// source of truth.
@freezed
class PriceListFilter with _$PriceListFilter {
  const factory PriceListFilter({
    @Default('') String search,
    @Default(0) int pageIndex,
  }) = _PriceListFilter;

  factory PriceListFilter.fromQuery(ListQuery query) {
    return PriceListFilter(search: query.search, pageIndex: query.pageIndex);
  }
}

/// Fetches and holds the price-lists list (FR-001, FR-005) for the given
/// [PriceListFilter]. A family keyed by the filter value: a different URL
/// is a different provider instance, and `ref.invalidate` after a mutation
/// re-fetches the *same* page rather than resetting to page 0 (FR-025,
/// research §3).
@riverpod
class PriceListsListController extends _$PriceListsListController {
  @override
  Future<CatalogPage<PriceList>> build(PriceListFilter filter) {
    return fetchClampedPage(
      pageIndex: filter.pageIndex,
      pageSize: _pageSize,
      fetch: (pageIndex) => _fetch(filter.copyWith(pageIndex: pageIndex)),
    );
  }

  Future<CatalogPage<PriceList>> _fetch(PriceListFilter filter) async {
    final result = await ref
        .read(priceListRepositoryProvider)
        .list(
          search: filter.search.isEmpty ? null : filter.search,
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
