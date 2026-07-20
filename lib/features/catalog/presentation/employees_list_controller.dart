import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/catalog/data/employee_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/employee_list_item.dart';

part 'employees_list_controller.freezed.dart';
part 'employees_list_controller.g.dart';

const _pageSize = 20;

/// The Employees list screen's search/filter selection (FR-017): status and
/// sales-person tri-state facets, independent of each other and of search.
@freezed
class EmployeeFilter with _$EmployeeFilter {
  const factory EmployeeFilter({
    @Default('') String search,
    EntityStatus? status,
    bool? salesPerson,
  }) = _EmployeeFilter;
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

/// Holds the current search/filter selection for the Employees list
/// (FR-002, FR-017).
@riverpod
class EmployeeFilterController extends _$EmployeeFilterController {
  @override
  EmployeeFilter build() => const EmployeeFilter();

  void searchChanged(String value) => state = state.copyWith(search: value);

  void statusChanged(EntityStatus? value) =>
      state = state.copyWith(status: value);

  void salesPersonChanged(bool? value) =>
      state = state.copyWith(salesPerson: value);

  /// Resets every facet filter while preserving the current search text,
  /// mirroring `ProductFilterController.reset`.
  void reset() => state = EmployeeFilter(search: state.search);
}

/// Fetches and holds the Employees list (FR-001, FR-017), re-fetching page 0
/// whenever [EmployeeFilterController]'s state changes.
@riverpod
class EmployeesListController extends _$EmployeesListController {
  @override
  Future<CatalogPage<EmployeeListItem>> build() {
    final filter = ref.watch(employeeFilterControllerProvider);
    return _fetch(filter, pageIndex: 0);
  }

  Future<CatalogPage<EmployeeListItem>> _fetch(
    EmployeeFilter filter, {
    required int pageIndex,
  }) async {
    final result = await ref
        .read(employeeRepositoryProvider)
        .list(
          search: filter.search.isEmpty ? null : filter.search,
          status: filter.status,
          salesPerson: filter.salesPerson,
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
    final filter = ref.read(employeeFilterControllerProvider);
    state = const AsyncLoading<CatalogPage<EmployeeListItem>>()
        .copyWithPrevious(state);
    state = await AsyncValue.guard(() => _fetch(filter, pageIndex: pageIndex));
  }
}
