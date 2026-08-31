import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/core/widgets/entity_status_controls.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product_list_item.dart';

part 'products_list_controller.freezed.dart';
part 'products_list_controller.g.dart';

const _pageSize = 20;

bool? _parseTriState(String? raw) {
  if (raw == 'true') return true;
  if (raw == 'false') return false;
  return null;
}

/// The products list screen's addressable view state
/// (017-ui-consistency-filters FR-017, data-model.md "ProductFilter"),
/// translated 1:1 into `GET /products` query params (research.md §6).
/// Derived from the route's [ListQuery] — the URL, not a mutable notifier,
/// is the source of truth.
@freezed
class ProductFilter with _$ProductFilter {
  const factory ProductFilter({
    @Default('') String search,
    EntityStatus? status,
    bool? stockable,
    bool? salable,
    bool? purchasable,
    int? supplier,
    @Default(<int>[]) List<int> labels,
    @Default(0) int pageIndex,
  }) = _ProductFilter;

  factory ProductFilter.fromQuery(ListQuery query) {
    final supplierRaw = query.facet('supplier');
    return ProductFilter(
      search: query.search,
      status: decodeStatusFacet(query),
      stockable: _parseTriState(query.facet('stockable')),
      salable: _parseTriState(query.facet('salable')),
      purchasable: _parseTriState(query.facet('purchasable')),
      supplier: supplierRaw != null ? int.tryParse(supplierRaw) : null,
      labels: query
          .facetValues('label')
          .map(int.tryParse)
          .whereType<int>()
          .toList(),
      pageIndex: query.pageIndex,
    );
  }
}

/// Derived facet-filter summary used by the products list's Filters button
/// badge (FR-003, data-model.md). [search] is deliberately excluded — it has
/// its own always-visible box — and `status == null` (the default "All",
/// which includes every lifecycle state) does not count; narrowing to any one
/// status does, so a freshly-loaded list shows no badge.
/// Each selected label counts individually (FR-009), so selecting N labels
/// contributes N to the total.
extension ProductFilterBadge on ProductFilter {
  int get activeFilterCount {
    var count = 0;
    if (status != null) count++;
    if (stockable != null) count++;
    if (salable != null) count++;
    if (purchasable != null) count++;
    if (supplier != null) count++;
    count += labels.length;
    return count;
  }

  bool get hasActiveFilters => activeFilterCount > 0;
}

/// Fetches and holds the products list (FR-001, FR-002) for the given
/// [ProductFilter]. A family keyed by the filter value: a different URL is
/// a different provider instance, and `ref.invalidate` after a mutation
/// re-fetches the *same* page rather than resetting to page 0 (FR-025,
/// research §3).
@riverpod
class ProductsListController extends _$ProductsListController {
  @override
  Future<CatalogPage<ProductListItem>> build(ProductFilter filter) {
    return fetchClampedPage(
      pageIndex: filter.pageIndex,
      pageSize: _pageSize,
      fetch: (pageIndex) => _fetch(filter.copyWith(pageIndex: pageIndex)),
    );
  }

  Future<CatalogPage<ProductListItem>> _fetch(ProductFilter filter) async {
    final result = await ref
        .read(productRepositoryProvider)
        .list(
          search: filter.search.isEmpty ? null : filter.search,
          status: filter.status,
          stockable: filter.stockable,
          salable: filter.salable,
          purchasable: filter.purchasable,
          supplier: filter.supplier,
          labels: filter.labels,
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

/// Label id → matching-product count, for every label that appears on at
/// least one product matching the current [ProductFilter] — i.e. labels that
/// would *further* narrow the present results under the list's AND semantics
/// (spec 009 FR-003, FR-009). Drives the filter drawer's per-chip enabled
/// state and count display via `LabelMultiPicker`. A family keyed by
/// [ProductFilter] — the filter drawer passes the same filter it's showing.
///
/// `autoDispose`, so the facet lookup fires only while the filter drawer
/// (`_ProductFiltersPanel`) is watching it, and re-runs on every filter change
/// (label/attribute toggle or submitted search). Consumers read `.valueOrNull`
/// and treat `null` (loading/error) as "availability unknown" → all chips
/// enabled, so a facet failure never blocks filtering (FR-010).
@riverpod
Future<Map<int, int>> productLabelFacets(Ref ref, ProductFilter filter) async {
  final facets = await ref
      .read(productRepositoryProvider)
      .productLabelFacets(
        search: filter.search.isEmpty ? null : filter.search,
        status: filter.status,
        stockable: filter.stockable,
        salable: filter.salable,
        purchasable: filter.purchasable,
        labels: filter.labels,
      );
  return {for (final f in facets) f.labelId: f.count};
}
