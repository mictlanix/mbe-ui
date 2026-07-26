import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/catalog/data/point_sale_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/point_sale.dart';

part 'points_of_sale_list_controller.freezed.dart';
part 'points_of_sale_list_controller.g.dart';

const _pageSize = 20;

/// The Points of Sale list screen's addressable view state
/// (017-ui-consistency-filters FR-017), derived from the route's
/// [ListQuery] — the URL, not a mutable notifier, is the source of truth.
@freezed
class PointSaleFilter with _$PointSaleFilter {
  const factory PointSaleFilter({
    @Default('') String search,
    int? facilityId,
    int? warehouseId,
    EntityStatus? status,
    @Default(0) int pageIndex,
  }) = _PointSaleFilter;

  factory PointSaleFilter.fromQuery(ListQuery query) {
    final facilityRaw = query.facet('facility');
    final warehouseRaw = query.facet('warehouse');
    final statusRaw = query.facet('status');
    return PointSaleFilter(
      search: query.search,
      facilityId: facilityRaw != null ? int.tryParse(facilityRaw) : null,
      warehouseId: warehouseRaw != null ? int.tryParse(warehouseRaw) : null,
      status: statusRaw != null
          ? EntityStatus.values.byNameOrNull(statusRaw)
          : null,
      pageIndex: query.pageIndex,
    );
  }
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

extension _EntityStatusByName on List<EntityStatus> {
  EntityStatus? byNameOrNull(String name) {
    for (final value in this) {
      if (value.name == name) return value;
    }
    return null;
  }
}

/// Fetches and holds the Points of Sale list (FR-001, FR-003) for the given
/// [PointSaleFilter]. A family keyed by the filter value: a different URL is
/// a different provider instance, and `ref.invalidate` after a mutation
/// re-fetches the *same* page rather than resetting to page 0 (FR-025,
/// research §3).
@riverpod
class PointsOfSaleListController extends _$PointsOfSaleListController {
  @override
  Future<CatalogPage<PointSale>> build(PointSaleFilter filter) {
    return fetchClampedPage(
      pageIndex: filter.pageIndex,
      pageSize: _pageSize,
      fetch: (pageIndex) => _fetch(filter.copyWith(pageIndex: pageIndex)),
    );
  }

  Future<CatalogPage<PointSale>> _fetch(PointSaleFilter filter) async {
    final result = await ref
        .read(pointSaleRepositoryProvider)
        .list(
          search: filter.search.isEmpty ? null : filter.search,
          facilityId: filter.facilityId,
          warehouseId: filter.warehouseId,
          status: filter.status,
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
