import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/catalog/data/vehicle_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/vehicle.dart';

part 'vehicles_list_controller.freezed.dart';
part 'vehicles_list_controller.g.dart';

const _pageSize = 20;

extension _EntityStatusByName on List<EntityStatus> {
  EntityStatus? byNameOrNull(String name) {
    for (final value in this) {
      if (value.name == name) return value;
    }
    return null;
  }
}

/// The Vehicles list screen's addressable view state (017-ui-consistency-filters
/// FR-009, FR-017), derived from the route's [ListQuery] — the URL, not a
/// mutable notifier, is the source of truth (data-model.md §2).
@freezed
class VehicleFilter with _$VehicleFilter {
  const factory VehicleFilter({
    @Default('') String search,
    EntityStatus? status,
    @Default(0) int pageIndex,
  }) = _VehicleFilter;

  factory VehicleFilter.fromQuery(ListQuery query) {
    final statusRaw = query.facet('status');
    return VehicleFilter(
      search: query.search,
      status: statusRaw != null
          ? EntityStatus.values.byNameOrNull(statusRaw)
          : null,
      pageIndex: query.pageIndex,
    );
  }
}

/// Derived facet-filter summary for the Vehicles list's Filters button
/// badge, mirroring `EmployeeFilterBadge.activeFilterCount`. [search] has
/// its own always-visible box and is excluded.
extension VehicleFilterBadge on VehicleFilter {
  int get activeFilterCount => status != null ? 1 : 0;

  bool get hasActiveFilters => activeFilterCount > 0;
}

/// Fetches and holds the Vehicles list (FR-001, FR-009) for the given
/// [VehicleFilter]. A family keyed by the filter value: a different URL is
/// a different provider instance, and `ref.invalidate` after a mutation
/// re-fetches the *same* page rather than resetting to page 0 (FR-025,
/// research §3).
@riverpod
class VehiclesListController extends _$VehiclesListController {
  @override
  Future<CatalogPage<Vehicle>> build(VehicleFilter filter) {
    return fetchClampedPage(
      pageIndex: filter.pageIndex,
      pageSize: _pageSize,
      fetch: (pageIndex) => _fetch(filter.copyWith(pageIndex: pageIndex)),
    );
  }

  Future<CatalogPage<Vehicle>> _fetch(VehicleFilter filter) async {
    final result = await ref
        .read(vehicleRepositoryProvider)
        .list(
          search: filter.search.isEmpty ? null : filter.search,
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
