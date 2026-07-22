import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/facility_list_item.dart';

part 'facilities_list_controller.freezed.dart';
part 'facilities_list_controller.g.dart';

const _pageSize = 20;

/// The Facilities list screen's search/filter selection (FR-003): a status
/// facet only — the facilities endpoint exposes no `facility` facet on
/// itself, unlike the three operational catalogs that reference it.
@freezed
class FacilityFilter with _$FacilityFilter {
  const factory FacilityFilter({
    @Default('') String search,
    EntityStatus? status,
  }) = _FacilityFilter;
}

/// Derived facet-filter summary for the Facilities list's Filters button
/// badge. [search] has its own always-visible box and is excluded.
extension FacilityFilterBadge on FacilityFilter {
  int get activeFilterCount => status != null ? 1 : 0;

  bool get hasActiveFilters => activeFilterCount > 0;
}

/// Holds the current search/filter selection for the Facilities list
/// (FR-002, FR-003).
@riverpod
class FacilityFilterController extends _$FacilityFilterController {
  @override
  FacilityFilter build() => const FacilityFilter();

  void searchChanged(String value) => state = state.copyWith(search: value);

  void statusChanged(EntityStatus? value) =>
      state = state.copyWith(status: value);

  /// Resets every facet filter to its default while preserving the current
  /// search text (FR-002; the search box stays outside the filter sheet).
  void reset() => state = FacilityFilter(search: state.search);
}

/// Fetches and holds the Facilities list (FR-001, FR-028), re-fetching
/// page 0 whenever [FacilityFilterController]'s state changes.
@riverpod
class FacilitiesListController extends _$FacilitiesListController {
  @override
  Future<CatalogPage<FacilityListItem>> build() {
    final filter = ref.watch(facilityFilterControllerProvider);
    return _fetch(filter, pageIndex: 0);
  }

  Future<CatalogPage<FacilityListItem>> _fetch(
    FacilityFilter filter, {
    required int pageIndex,
  }) async {
    final result = await ref
        .read(facilityRepositoryProvider)
        .list(
          search: filter.search.isEmpty ? null : filter.search,
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
    final filter = ref.read(facilityFilterControllerProvider);
    state = const AsyncLoading<CatalogPage<FacilityListItem>>()
        .copyWithPrevious(state);
    state = await AsyncValue.guard(() => _fetch(filter, pageIndex: pageIndex));
  }
}
