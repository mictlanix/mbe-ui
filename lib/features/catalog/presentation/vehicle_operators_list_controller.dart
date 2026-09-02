import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/core/widgets/entity_status_controls.dart';
import 'package:mbe_ui/features/catalog/data/vehicle_operator_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/vehicle_operator.dart';

part 'vehicle_operators_list_controller.freezed.dart';
part 'vehicle_operators_list_controller.g.dart';

const _pageSize = 20;

/// The Vehicle Operators list screen's addressable view state
/// (017-ui-consistency-filters FR-010, FR-017, FR-018): a driver facet and
/// a status facet, combinable, independent of search. Derived from the
/// route's [ListQuery] — the URL, not a mutable notifier, is the source of
/// truth.
@freezed
class VehicleOperatorFilter with _$VehicleOperatorFilter {
  const factory VehicleOperatorFilter({
    @Default('') String search,
    int? driverId,
    EntityStatus? status,
    @Default(0) int pageIndex,
  }) = _VehicleOperatorFilter;

  factory VehicleOperatorFilter.fromQuery(ListQuery query) {
    final driverRaw = query.facet('driver');
    return VehicleOperatorFilter(
      search: query.search,
      driverId: driverRaw != null ? int.tryParse(driverRaw) : null,
      status: decodeStatusFacet(query),
      pageIndex: query.pageIndex,
    );
  }
}

/// Derived facet-filter summary for the Vehicle Operators list's Filters
/// button badge, mirroring `EmployeeFilterBadge.activeFilterCount`. [search]
/// has its own always-visible box and is excluded.
extension VehicleOperatorFilterBadge on VehicleOperatorFilter {
  int get activeFilterCount {
    var count = 0;
    if (driverId != null) count++;
    if (status != null) count++;
    return count;
  }

  bool get hasActiveFilters => activeFilterCount > 0;
}

/// Fetches and holds the Vehicle Operators list (FR-001, FR-018) for the
/// given [VehicleOperatorFilter]. A family keyed by the filter value: a
/// different URL is a different provider instance, and `ref.invalidate`
/// after a mutation re-fetches the *same* page rather than resetting to
/// page 0 (FR-025, research §3).
@riverpod
class VehicleOperatorsListController extends _$VehicleOperatorsListController {
  @override
  Future<CatalogPage<VehicleOperator>> build(VehicleOperatorFilter filter) {
    return fetchClampedPage(
      pageIndex: filter.pageIndex,
      pageSize: _pageSize,
      fetch: (pageIndex) => _fetch(filter.copyWith(pageIndex: pageIndex)),
    );
  }

  Future<CatalogPage<VehicleOperator>> _fetch(
    VehicleOperatorFilter filter,
  ) async {
    final result = await ref
        .read(vehicleOperatorRepositoryProvider)
        .list(
          search: filter.search.isEmpty ? null : filter.search,
          driverId: filter.driverId,
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
