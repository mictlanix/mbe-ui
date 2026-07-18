import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/pricing/data/price_list_repository_impl.dart';
import 'package:mbe_ui/features/pricing/domain/entities/price_list.dart';

part 'price_lists_list_controller.g.dart';

const _pageSize = 20;

/// Holds the current search text for the price-lists screen (FR-005).
@riverpod
class PriceListSearchController extends _$PriceListSearchController {
  @override
  String build() => '';

  void searchChanged(String value) => state = value;
}

/// Fetches and holds the price-lists list (FR-001, FR-005), re-fetching
/// page 0 whenever the search text changes. Mirrors
/// `ProductsListController`'s `CatalogPage<T>` pagination pattern.
@riverpod
class PriceListsListController extends _$PriceListsListController {
  @override
  Future<CatalogPage<PriceList>> build() {
    final search = ref.watch(priceListSearchControllerProvider);
    return _fetch(search, pageIndex: 0);
  }

  Future<CatalogPage<PriceList>> _fetch(
    String search, {
    required int pageIndex,
  }) async {
    final result = await ref
        .read(priceListRepositoryProvider)
        .list(
          search: search.isEmpty ? null : search,
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

  /// Fetches [pageIndex] and replaces the current page with it.
  Future<void> goToPage(int pageIndex) async {
    final search = ref.read(priceListSearchControllerProvider);
    state = const AsyncLoading<CatalogPage<PriceList>>().copyWithPrevious(
      state,
    );
    state = await AsyncValue.guard(() => _fetch(search, pageIndex: pageIndex));
  }
}
