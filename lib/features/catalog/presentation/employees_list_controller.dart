import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/catalog/data/employee_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/employee_list_item.dart';

part 'employees_list_controller.freezed.dart';
part 'employees_list_controller.g.dart';

const _pageSize = 20;

bool? _parseTriState(String? raw) {
  if (raw == 'true') return true;
  if (raw == 'false') return false;
  return null;
}

extension _EntityStatusByName on List<EntityStatus> {
  EntityStatus? byNameOrNull(String name) {
    for (final value in this) {
      if (value.name == name) return value;
    }
    return null;
  }
}

/// The Employees list screen's addressable view state
/// (017-ui-consistency-filters FR-017): status and sales-person tri-state
/// facets, independent of each other and of search. Derived from the
/// route's [ListQuery] — the URL, not a mutable notifier, is the source of
/// truth.
@freezed
class EmployeeFilter with _$EmployeeFilter {
  const factory EmployeeFilter({
    @Default('') String search,
    EntityStatus? status,
    bool? salesPerson,
    @Default(0) int pageIndex,
  }) = _EmployeeFilter;

  factory EmployeeFilter.fromQuery(ListQuery query) {
    final statusRaw = query.facet('status');
    return EmployeeFilter(
      search: query.search,
      status: statusRaw != null
          ? EntityStatus.values.byNameOrNull(statusRaw)
          : null,
      salesPerson: _parseTriState(query.facet('salesPerson')),
      pageIndex: query.pageIndex,
    );
  }
}

/// Derived facet-filter summary for the Employees list's Filters button
/// badge, mirroring `ProductFilter.activeFilterCount`. [search] has its own
/// always-visible box and is excluded.
extension EmployeeFilterBadge on EmployeeFilter {
  int get activeFilterCount {
    var count = 0;
    if (status != null) count++;
    if (salesPerson != null) count++;
    return count;
  }

  bool get hasActiveFilters => activeFilterCount > 0;
}

/// Fetches and holds the Employees list (FR-001, FR-017) for the given
/// [EmployeeFilter]. A family keyed by the filter value: a different URL is
/// a different provider instance, and `ref.invalidate` after a mutation
/// re-fetches the *same* page rather than resetting to page 0 (FR-025,
/// research §3).
@riverpod
class EmployeesListController extends _$EmployeesListController {
  @override
  Future<CatalogPage<EmployeeListItem>> build(EmployeeFilter filter) {
    return fetchClampedPage(
      pageIndex: filter.pageIndex,
      pageSize: _pageSize,
      fetch: (pageIndex) => _fetch(filter.copyWith(pageIndex: pageIndex)),
    );
  }

  Future<CatalogPage<EmployeeListItem>> _fetch(EmployeeFilter filter) async {
    final result = await ref
        .read(employeeRepositoryProvider)
        .list(
          search: filter.search.isEmpty ? null : filter.search,
          status: filter.status,
          salesPerson: filter.salesPerson,
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
