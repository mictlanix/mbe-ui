import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product_list_item.dart';

part 'products_list_controller.freezed.dart';
part 'products_list_controller.g.dart';

const _pageSize = 20;

/// The products list screen's search/filter selection (data-model.md
/// "ProductFilter"), translated 1:1 into `GET /products` query params
/// (research.md §6). Local UI state, not persisted (constitution §II).
@freezed
class ProductFilter with _$ProductFilter {
  const factory ProductFilter({
    @Default('') String search,
    bool? deactivated,
    bool? stockable,
    bool? salable,
    bool? purchasable,
    @Default(<int>[]) List<int> labels,
  }) = _ProductFilter;
}

/// Derived facet-filter summary used by the products list's Filters button
/// badge (FR-003, data-model.md). [search] is deliberately excluded — it has
/// its own always-visible box — and `deactivated == null` (the default, which
/// includes inactive products) does not count; only narrowing to active-only
/// (`deactivated == false`) does, so a freshly-loaded list shows no badge.
/// Each selected label counts individually (FR-009), so selecting N labels
/// contributes N to the total.
extension ProductFilterBadge on ProductFilter {
  int get activeFilterCount {
    var count = 0;
    if (deactivated == false) count++;
    if (stockable != null) count++;
    if (salable != null) count++;
    if (purchasable != null) count++;
    count += labels.length;
    return count;
  }

  bool get hasActiveFilters => activeFilterCount > 0;
}

/// Holds the current search/filter selection for the products list
/// (FR-001, FR-002).
@riverpod
class ProductFilterController extends _$ProductFilterController {
  @override
  ProductFilter build() => const ProductFilter();

  void searchChanged(String value) => state = state.copyWith(search: value);

  /// `null` shows both active and disabled products (FR-011's "include
  /// disabled" filter); `false` shows only active ones (FR-002's
  /// "active only" filter).
  void deactivatedChanged(bool? value) =>
      state = state.copyWith(deactivated: value);

  void stockableChanged(bool? value) =>
      state = state.copyWith(stockable: value);

  void salableChanged(bool? value) => state = state.copyWith(salable: value);

  void purchasableChanged(bool? value) =>
      state = state.copyWith(purchasable: value);

  void labelsChanged(List<int> value) => state = state.copyWith(labels: value);

  /// Resets every facet filter to its default while preserving the current
  /// [ProductFilter.search] text (FR-004; the search box stays outside the
  /// filter panel). Wired to the panel's "Clear all" action.
  void reset() => state = ProductFilter(search: state.search);
}

/// Fetches and holds the products list (FR-001, FR-002), re-fetching page
/// 0 whenever [ProductFilterController]'s state changes. Supports
/// page-based navigation via [goToPage], consumed by `DataTableView`'s
/// `pagination` parameter (data-model.md "CatalogPage`<T>`", research.md
/// §2 — replaces the prior `_skip`/`loadMore()` incremental-fetch
/// pattern).
@riverpod
class ProductsListController extends _$ProductsListController {
  @override
  Future<CatalogPage<ProductListItem>> build() {
    final filter = ref.watch(productFilterControllerProvider);
    return _fetch(filter, pageIndex: 0);
  }

  Future<CatalogPage<ProductListItem>> _fetch(
    ProductFilter filter, {
    required int pageIndex,
  }) async {
    final result = await ref
        .read(productRepositoryProvider)
        .list(
          search: filter.search.isEmpty ? null : filter.search,
          deactivated: filter.deactivated,
          stockable: filter.stockable,
          salable: filter.salable,
          purchasable: filter.purchasable,
          labels: filter.labels,
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
    final filter = ref.read(productFilterControllerProvider);
    state = const AsyncLoading<CatalogPage<ProductListItem>>().copyWithPrevious(
      state,
    );
    state = await AsyncValue.guard(() => _fetch(filter, pageIndex: pageIndex));
  }
}
