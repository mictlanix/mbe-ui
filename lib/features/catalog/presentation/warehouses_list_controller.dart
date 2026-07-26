import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';

part 'warehouses_list_controller.freezed.dart';
part 'warehouses_list_controller.g.dart';

const _pageSize = 20;

/// The Warehouses list screen's addressable view state
/// (017-ui-consistency-filters FR-017), derived from the route's
/// [ListQuery] — the URL, not a mutable notifier, is the source of truth
/// (data-model.md §2). Display text for the facility facet is resolved
/// separately (presentation-only, data-model.md §4), not carried here.
@freezed
class WarehouseFilter with _$WarehouseFilter {
  const factory WarehouseFilter({
    @Default('') String search,
    int? facilityId,
    EntityStatus? status,
    @Default(0) int pageIndex,
  }) = _WarehouseFilter;

  factory WarehouseFilter.fromQuery(ListQuery query) {
    final facilityRaw = query.facet('facility');
    final statusRaw = query.facet('status');
    return WarehouseFilter(
      search: query.search,
      facilityId: facilityRaw != null ? int.tryParse(facilityRaw) : null,
      status: statusRaw != null
          ? EntityStatus.values.byNameOrNull(statusRaw)
          : null,
      pageIndex: query.pageIndex,
    );
  }
}

/// Derived facet-filter summary for the Warehouses list's Filters button
/// badge (mirrors `ProductFilterBadge`/`VehicleOperatorFilterBadge`).
/// [search] has its own always-visible box and is excluded.
extension WarehouseFilterBadge on WarehouseFilter {
  int get activeFilterCount {
    var count = 0;
    if (facilityId != null) count++;
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

/// Fetches and holds the Warehouses list (FR-001, FR-003) for the given
/// [WarehouseFilter]. A family keyed by the filter value: a different URL is
/// a different provider instance, and `ref.invalidate` after a mutation
/// re-fetches the *same* page rather than resetting to page 0 (FR-025,
/// research §3).
@riverpod
class WarehousesListController extends _$WarehousesListController {
  @override
  Future<CatalogPage<Warehouse>> build(WarehouseFilter filter) {
    return fetchClampedPage(
      pageIndex: filter.pageIndex,
      pageSize: _pageSize,
      fetch: (pageIndex) => _fetch(filter.copyWith(pageIndex: pageIndex)),
    );
  }

  Future<CatalogPage<Warehouse>> _fetch(WarehouseFilter filter) async {
    final result = await ref
        .read(warehouseRepositoryProvider)
        .list(
          search: filter.search.isEmpty ? null : filter.search,
          facilityId: filter.facilityId,
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
