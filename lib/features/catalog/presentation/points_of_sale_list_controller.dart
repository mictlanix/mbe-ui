import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/catalog/data/point_sale_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/point_sale.dart';

part 'points_of_sale_list_controller.freezed.dart';
part 'points_of_sale_list_controller.g.dart';

const _pageSize = 20;

/// The Points of Sale list screen's search/filter selection (FR-003): a
/// facility facet, a warehouse facet, and a status facet, independent of
/// search.
@freezed
class PointSaleFilter with _$PointSaleFilter {
  const factory PointSaleFilter({
    @Default('') String search,
    int? facilityId,
    @Default('') String facilityDisplayText,
    int? warehouseId,
    @Default('') String warehouseDisplayText,
    EntityStatus? status,
  }) = _PointSaleFilter;
}

/// Derived facet-filter summary for the Points of Sale list's Filters button
/// badge. [search] has its own always-visible box and is excluded.
extension PointSaleFilterBadge on PointSaleFilter {
  int get activeFilterCount {
    var count = 0;
    if (facilityId != null) count++;
    if (warehouseId != null) count++;
    if (status != null) count++;
    return count;
  }

  bool get hasActiveFilters => activeFilterCount > 0;
}

/// Holds the current search/filter selection for the Points of Sale list
/// (FR-002, FR-003).
@riverpod
class PointSaleFilterController extends _$PointSaleFilterController {
  @override
  PointSaleFilter build() => const PointSaleFilter();

  void searchChanged(String value) => state = state.copyWith(search: value);

  void facilitySelected(int facilityId, String facilityName) => state = state
      .copyWith(facilityId: facilityId, facilityDisplayText: facilityName);

  void warehouseSelected(int warehouseId, String warehouseName) =>
      state = state.copyWith(
        warehouseId: warehouseId,
        warehouseDisplayText: warehouseName,
      );

  void statusChanged(EntityStatus? value) =>
      state = state.copyWith(status: value);

  /// Resets every facet filter to its default while preserving the current
  /// search text (FR-002; the search box stays outside the filter sheet).
  void reset() => state = PointSaleFilter(search: state.search);
}

/// Fetches and holds the Points of Sale list (FR-001, FR-003), re-fetching
/// page 0 whenever [PointSaleFilterController]'s state changes.
@riverpod
class PointsOfSaleListController extends _$PointsOfSaleListController {
  @override
  Future<CatalogPage<PointSale>> build() {
    final filter = ref.watch(pointSaleFilterControllerProvider);
    return _fetch(filter, pageIndex: 0);
  }

  Future<CatalogPage<PointSale>> _fetch(
    PointSaleFilter filter, {
    required int pageIndex,
  }) async {
    final result = await ref
        .read(pointSaleRepositoryProvider)
        .list(
          search: filter.search.isEmpty ? null : filter.search,
          facilityId: filter.facilityId,
          warehouseId: filter.warehouseId,
          status: filter.status,
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
    final filter = ref.read(pointSaleFilterControllerProvider);
    state = const AsyncLoading<CatalogPage<PointSale>>().copyWithPrevious(
      state,
    );
    state = await AsyncValue.guard(() => _fetch(filter, pageIndex: pageIndex));
  }
}
