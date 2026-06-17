import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/product_repository.dart';

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
  }) = _ProductFilter;
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
}

/// Fetches and holds the products list (FR-001, FR-002), re-fetching from
/// the first page whenever [ProductFilterController]'s state changes.
/// Supports incremental loading via [loadMore] (research.md §5).
@riverpod
class ProductsListController extends _$ProductsListController {
  int _skip = 0;

  @override
  Future<ProductListResult> build() {
    _skip = 0;
    final filter = ref.watch(productFilterControllerProvider);
    return _fetch(filter, skip: 0);
  }

  Future<ProductListResult> _fetch(ProductFilter filter, {required int skip}) {
    return ref.read(productRepositoryProvider).list(
          search: filter.search.isEmpty ? null : filter.search,
          deactivated: filter.deactivated,
          stockable: filter.stockable,
          salable: filter.salable,
          purchasable: filter.purchasable,
          skip: skip,
          limit: _pageSize,
        );
  }

  /// Fetches the next page and appends it to the current results. No-ops if
  /// already loading or if every matching product has been loaded.
  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || current.items.length >= current.total) return;

    _skip += _pageSize;
    final filter = ref.read(productFilterControllerProvider);
    final next = await _fetch(filter, skip: _skip);
    state = AsyncData(
      ProductListResult(
        items: [...current.items, ...next.items],
        total: next.total,
      ),
    );
  }
}
