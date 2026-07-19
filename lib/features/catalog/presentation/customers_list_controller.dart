import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer_list_item.dart';

part 'customers_list_controller.freezed.dart';
part 'customers_list_controller.g.dart';

const _pageSize = 20;

/// The Customers list screen's search/filter selection (FR-022): a
/// disabled tri-state and price-list/salesperson FK filters, independent of
/// each other and of search.
@freezed
class CustomerFilter with _$CustomerFilter {
  const factory CustomerFilter({
    @Default('') String search,
    bool? disabled,
    int? priceListId,
    String? priceListDisplayText,
    int? salespersonId,
    String? salespersonDisplayText,
  }) = _CustomerFilter;
}

/// Derived facet-filter summary for the Customers list's Filters button
/// badge, mirroring `ProductFilter.activeFilterCount`/`EmployeeFilter`.
extension CustomerFilterBadge on CustomerFilter {
  int get activeFilterCount {
    var count = 0;
    if (disabled != null) count++;
    if (priceListId != null) count++;
    if (salespersonId != null) count++;
    return count;
  }

  bool get hasActiveFilters => activeFilterCount > 0;
}

/// Holds the current search/filter selection for the Customers list
/// (FR-002, FR-022).
@riverpod
class CustomerFilterController extends _$CustomerFilterController {
  @override
  CustomerFilter build() => const CustomerFilter();

  void searchChanged(String value) => state = state.copyWith(search: value);

  /// `null` shows both active and disabled customers; `false` narrows to
  /// active-only, mirroring `ProductFilterController.deactivatedChanged`.
  void disabledChanged(bool? value) => state = state.copyWith(disabled: value);

  void priceListChanged(int? id, String? displayText) => state = state
      .copyWith(priceListId: id, priceListDisplayText: displayText);

  void salespersonChanged(int? id, String? displayText) => state = state
      .copyWith(salespersonId: id, salespersonDisplayText: displayText);

  /// Resets every facet filter while preserving the current search text.
  void reset() => state = CustomerFilter(search: state.search);
}

/// Fetches and holds the Customers list (FR-001, FR-022), re-fetching page 0
/// whenever [CustomerFilterController]'s state changes.
@riverpod
class CustomersListController extends _$CustomersListController {
  @override
  Future<CatalogPage<CustomerListItem>> build() {
    final filter = ref.watch(customerFilterControllerProvider);
    return _fetch(filter, pageIndex: 0);
  }

  Future<CatalogPage<CustomerListItem>> _fetch(
    CustomerFilter filter, {
    required int pageIndex,
  }) async {
    final result = await ref
        .read(customerRepositoryProvider)
        .list(
          search: filter.search.isEmpty ? null : filter.search,
          disabled: filter.disabled,
          priceList: filter.priceListId,
          salesperson: filter.salespersonId,
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
    final filter = ref.read(customerFilterControllerProvider);
    state =
        const AsyncLoading<CatalogPage<CustomerListItem>>().copyWithPrevious(
          state,
        );
    state = await AsyncValue.guard(() => _fetch(filter, pageIndex: pageIndex));
  }
}
