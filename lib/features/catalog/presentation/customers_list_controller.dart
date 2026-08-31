import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/core/widgets/entity_status_controls.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer_list_item.dart';

part 'customers_list_controller.freezed.dart';
part 'customers_list_controller.g.dart';

const _pageSize = 20;

/// The Customers list screen's addressable view state
/// (017-ui-consistency-filters FR-017, FR-022): a status filter and
/// price-list/salesperson FK filters, independent of each other and of
/// search. Derived from the route's [ListQuery] — the URL, not a mutable
/// notifier, is the source of truth.
@freezed
class CustomerFilter with _$CustomerFilter {
  const factory CustomerFilter({
    @Default('') String search,
    EntityStatus? status,
    int? priceListId,
    int? salespersonId,
    @Default(0) int pageIndex,
  }) = _CustomerFilter;

  factory CustomerFilter.fromQuery(ListQuery query) {
    final priceListRaw = query.facet('priceList');
    final salespersonRaw = query.facet('salesperson');
    return CustomerFilter(
      search: query.search,
      status: decodeStatusFacet(query),
      priceListId: priceListRaw != null ? int.tryParse(priceListRaw) : null,
      salespersonId: salespersonRaw != null
          ? int.tryParse(salespersonRaw)
          : null,
      pageIndex: query.pageIndex,
    );
  }
}

/// Derived facet-filter summary for the Customers list's Filters button
/// badge, mirroring `ProductFilter.activeFilterCount`/`EmployeeFilter`.
extension CustomerFilterBadge on CustomerFilter {
  int get activeFilterCount {
    var count = 0;
    if (status != null) count++;
    if (priceListId != null) count++;
    if (salespersonId != null) count++;
    return count;
  }

  bool get hasActiveFilters => activeFilterCount > 0;
}

/// Fetches and holds the Customers list (FR-001, FR-022) for the given
/// [CustomerFilter]. A family keyed by the filter value: a different URL is
/// a different provider instance, and `ref.invalidate` after a mutation
/// re-fetches the *same* page rather than resetting to page 0 (FR-025,
/// research §3).
@riverpod
class CustomersListController extends _$CustomersListController {
  @override
  Future<CatalogPage<CustomerListItem>> build(CustomerFilter filter) {
    return fetchClampedPage(
      pageIndex: filter.pageIndex,
      pageSize: _pageSize,
      fetch: (pageIndex) => _fetch(filter.copyWith(pageIndex: pageIndex)),
    );
  }

  Future<CatalogPage<CustomerListItem>> _fetch(CustomerFilter filter) async {
    final result = await ref
        .read(customerRepositoryProvider)
        .list(
          search: filter.search.isEmpty ? null : filter.search,
          status: filter.status,
          priceList: filter.priceListId,
          salesperson: filter.salespersonId,
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
