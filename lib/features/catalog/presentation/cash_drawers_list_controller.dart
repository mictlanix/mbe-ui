import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/catalog/data/cash_drawer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/cash_drawer.dart';

part 'cash_drawers_list_controller.freezed.dart';
part 'cash_drawers_list_controller.g.dart';

const _pageSize = 20;

/// The CashDrawers list screen's addressable view state
/// (017-ui-consistency-filters FR-017), derived from the route's
/// [ListQuery] — the URL, not a mutable notifier, is the source of truth.
@freezed
class CashDrawerFilter with _$CashDrawerFilter {
  const factory CashDrawerFilter({
    @Default('') String search,
    int? facilityId,
    EntityStatus? status,
    @Default(0) int pageIndex,
  }) = _CashDrawerFilter;

  factory CashDrawerFilter.fromQuery(ListQuery query) {
    final facilityRaw = query.facet('facility');
    final statusRaw = query.facet('status');
    return CashDrawerFilter(
      search: query.search,
      facilityId: facilityRaw != null ? int.tryParse(facilityRaw) : null,
      status: statusRaw != null
          ? EntityStatus.values.byNameOrNull(statusRaw)
          : null,
      pageIndex: query.pageIndex,
    );
  }
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

extension _EntityStatusByName on List<EntityStatus> {
  EntityStatus? byNameOrNull(String name) {
    for (final value in this) {
      if (value.name == name) return value;
    }
    return null;
  }
}

/// Fetches and holds the CashDrawers list (FR-001, FR-003) for the given
/// [CashDrawerFilter]. A family keyed by the filter value: a different URL
/// is a different provider instance, and `ref.invalidate` after a mutation
/// re-fetches the *same* page rather than resetting to page 0 (FR-025,
/// research §3).
@riverpod
class CashDrawersListController extends _$CashDrawersListController {
  @override
  Future<CatalogPage<CashDrawer>> build(CashDrawerFilter filter) {
    return fetchClampedPage(
      pageIndex: filter.pageIndex,
      pageSize: _pageSize,
      fetch: (pageIndex) => _fetch(filter.copyWith(pageIndex: pageIndex)),
    );
  }

  Future<CatalogPage<CashDrawer>> _fetch(CashDrawerFilter filter) async {
    final result = await ref
        .read(cashDrawerRepositoryProvider)
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
