import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/catalog/data/vehicle_operator_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/vehicle_operator.dart';

part 'vehicle_operators_list_controller.freezed.dart';
part 'vehicle_operators_list_controller.g.dart';

const _pageSize = 20;

/// The Vehicle Operators list screen's search/filter selection (FR-018): a
/// single driver facet, independent of search.
@freezed
class VehicleOperatorFilter with _$VehicleOperatorFilter {
  const factory VehicleOperatorFilter({
    @Default('') String search,
    int? driverId,
    @Default('') String driverDisplayText,
  }) = _VehicleOperatorFilter;
}

/// Derived facet-filter summary for the Vehicle Operators list's Filters
/// button badge, mirroring `EmployeeFilterBadge.activeFilterCount`. [search]
/// has its own always-visible box and is excluded.
extension VehicleOperatorFilterBadge on VehicleOperatorFilter {
  int get activeFilterCount => driverId != null ? 1 : 0;

  bool get hasActiveFilters => activeFilterCount > 0;
}

/// Holds the current search/filter selection for the Vehicle Operators list
/// (FR-002, FR-018).
@riverpod
class VehicleOperatorFilterController
    extends _$VehicleOperatorFilterController {
  @override
  VehicleOperatorFilter build() => const VehicleOperatorFilter();

  void searchChanged(String value) => state = state.copyWith(search: value);

  void driverSelected(int driverId, String driverName) =>
      state = state.copyWith(driverId: driverId, driverDisplayText: driverName);

  /// Resets the driver facet while preserving the current search text,
  /// mirroring `EmployeeFilterController.reset`.
  void reset() => state = VehicleOperatorFilter(search: state.search);
}

/// Fetches and holds the Vehicle Operators list (FR-001, FR-018), re-fetching
/// page 0 whenever [VehicleOperatorFilterController]'s state changes.
@riverpod
class VehicleOperatorsListController extends _$VehicleOperatorsListController {
  @override
  Future<CatalogPage<VehicleOperator>> build() {
    final filter = ref.watch(vehicleOperatorFilterControllerProvider);
    return _fetch(filter, pageIndex: 0);
  }

  Future<CatalogPage<VehicleOperator>> _fetch(
    VehicleOperatorFilter filter, {
    required int pageIndex,
  }) async {
    final result = await ref
        .read(vehicleOperatorRepositoryProvider)
        .list(
          search: filter.search.isEmpty ? null : filter.search,
          driverId: filter.driverId,
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
    final filter = ref.read(vehicleOperatorFilterControllerProvider);
    state = const AsyncLoading<CatalogPage<VehicleOperator>>().copyWithPrevious(
      state,
    );
    state = await AsyncValue.guard(() => _fetch(filter, pageIndex: pageIndex));
  }
}
