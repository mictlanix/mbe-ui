import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/catalog/data/vehicle_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/vehicle.dart';

part 'vehicles_list_controller.g.dart';

const _pageSize = 20;

/// Holds the current search text for the Vehicles catalog screen (FR-001,
/// FR-002).
@riverpod
class VehicleSearchController extends _$VehicleSearchController {
  @override
  String build() => '';

  void searchChanged(String value) => state = value;
}

/// Fetches and holds the Vehicles list (FR-001), re-fetching page 0 whenever
/// the search text changes.
@riverpod
class VehiclesListController extends _$VehiclesListController {
  @override
  Future<CatalogPage<Vehicle>> build() {
    final search = ref.watch(vehicleSearchControllerProvider);
    return _fetch(search, pageIndex: 0);
  }

  Future<CatalogPage<Vehicle>> _fetch(
    String search, {
    required int pageIndex,
  }) async {
    final result = await ref
        .read(vehicleRepositoryProvider)
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
    final search = ref.read(vehicleSearchControllerProvider);
    state = const AsyncLoading<CatalogPage<Vehicle>>().copyWithPrevious(state);
    state = await AsyncValue.guard(() => _fetch(search, pageIndex: pageIndex));
  }
}
