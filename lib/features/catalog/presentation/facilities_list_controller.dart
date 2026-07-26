import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/facility_list_item.dart';

part 'facilities_list_controller.freezed.dart';
part 'facilities_list_controller.g.dart';

const _pageSize = 20;

/// The Facilities list screen's addressable view state
/// (017-ui-consistency-filters FR-017): a status facet only — the
/// facilities endpoint exposes no `facility` facet on itself, unlike the
/// three operational catalogs that reference it. Derived from the route's
/// [ListQuery] — the URL, not a mutable notifier, is the source of truth.
@freezed
class FacilityFilter with _$FacilityFilter {
  const factory FacilityFilter({
    @Default('') String search,
    EntityStatus? status,
    @Default(0) int pageIndex,
  }) = _FacilityFilter;

  factory FacilityFilter.fromQuery(ListQuery query) {
    final statusRaw = query.facet('status');
    return FacilityFilter(
      search: query.search,
      status: statusRaw != null
          ? EntityStatus.values.byNameOrNull(statusRaw)
          : null,
      pageIndex: query.pageIndex,
    );
  }
}

/// Derived facet-filter summary for the Facilities list's Filters button
/// badge. [search] has its own always-visible box and is excluded.
extension FacilityFilterBadge on FacilityFilter {
  int get activeFilterCount => status != null ? 1 : 0;

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

/// Fetches and holds the Facilities list (FR-001, FR-028) for the given
/// [FacilityFilter]. A family keyed by the filter value: a different URL is
/// a different provider instance, and `ref.invalidate` after a mutation
/// re-fetches the *same* page rather than resetting to page 0 (FR-025,
/// research §3).
@riverpod
class FacilitiesListController extends _$FacilitiesListController {
  @override
  Future<CatalogPage<FacilityListItem>> build(FacilityFilter filter) {
    return fetchClampedPage(
      pageIndex: filter.pageIndex,
      pageSize: _pageSize,
      fetch: (pageIndex) => _fetch(filter.copyWith(pageIndex: pageIndex)),
    );
  }

  Future<CatalogPage<FacilityListItem>> _fetch(FacilityFilter filter) async {
    final result = await ref
        .read(facilityRepositoryProvider)
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
