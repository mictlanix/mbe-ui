import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/catalog/data/cash_drawer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/cash_drawer.dart';

part 'cash_drawers_list_controller.freezed.dart';
part 'cash_drawers_list_controller.g.dart';

const _pageSize = 20;

/// The CashDrawers list screen's search/filter selection (FR-003): a facility
/// facet and a status facet, independent of search.
@freezed
class CashDrawerFilter with _$CashDrawerFilter {
  const factory CashDrawerFilter({
    @Default('') String search,
    int? facilityId,
    @Default('') String facilityDisplayText,
    EntityStatus? status,
  }) = _CashDrawerFilter;
}

/// Derived facet-filter summary for the CashDrawers list's Filters button
/// badge (mirrors `ProductFilterBadge`/`VehicleOperatorFilterBadge`).
/// [search] has its own always-visible box and is excluded.
extension CashDrawerFilterBadge on CashDrawerFilter {
  int get activeFilterCount {
    var count = 0;
    if (facilityId != null) count++;
    if (status != null) count++;
    return count;
  }

  bool get hasActiveFilters => activeFilterCount > 0;
}

/// Holds the current search/filter selection for the CashDrawers list
/// (FR-002, FR-003).
@riverpod
class CashDrawerFilterController extends _$CashDrawerFilterController {
  @override
  CashDrawerFilter build() => const CashDrawerFilter();

  void searchChanged(String value) => state = state.copyWith(search: value);

  void facilitySelected(int facilityId, String facilityName) => state = state
      .copyWith(facilityId: facilityId, facilityDisplayText: facilityName);

  void statusChanged(EntityStatus? value) =>
      state = state.copyWith(status: value);

  /// Resets every facet filter to its default while preserving the current
  /// search text (FR-002; the search box stays outside the filter sheet).
  void reset() => state = CashDrawerFilter(search: state.search);
}

/// Fetches and holds the CashDrawers list (FR-001, FR-003), re-fetching page 0
/// whenever [CashDrawerFilterController]'s state changes.
@riverpod
class CashDrawersListController extends _$CashDrawersListController {
  @override
  Future<CatalogPage<CashDrawer>> build() {
    final filter = ref.watch(cashDrawerFilterControllerProvider);
    return _fetch(filter, pageIndex: 0);
  }

  Future<CatalogPage<CashDrawer>> _fetch(
    CashDrawerFilter filter, {
    required int pageIndex,
  }) async {
    final result = await ref
        .read(cashDrawerRepositoryProvider)
        .list(
          search: filter.search.isEmpty ? null : filter.search,
          facilityId: filter.facilityId,
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
    final filter = ref.read(cashDrawerFilterControllerProvider);
    state = const AsyncLoading<CatalogPage<CashDrawer>>().copyWithPrevious(
      state,
    );
    state = await AsyncValue.guard(() => _fetch(filter, pageIndex: pageIndex));
  }
}
