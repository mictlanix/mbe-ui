import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/sales/data/sales_quote_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sales_quote_summary.dart';

part 'sales_quotes_list_controller.freezed.dart';
part 'sales_quotes_list_controller.g.dart';

const _pageSize = 20;

/// The Sales Quotes list's addressable view state (spec 040 data-model.md
/// §4): a status facet, a customer facet, free-text search, and the current
/// page — **deliberately no date facet and no `today` parameter**, unlike
/// `SalesOrdersFilter`. `GET /sales-quotes` has no date-range parameter at
/// all (research.md R5), so there is nothing to decode a range against; this
/// also removes the `DateTime.now()`-inside-a-family-key hazard
/// `SalesOrdersFilter.fromQuery`'s own doc comment warns about, rather than
/// merely avoiding it by discipline.
@freezed
class SalesQuotesFilter with _$SalesQuotesFilter {
  const factory SalesQuotesFilter({
    SaleStatus? status,
    int? customer,
    int? salesperson,
    @Default('') String search,
    @Default(0) int pageIndex,
  }) = _SalesQuotesFilter;

  factory SalesQuotesFilter.fromQuery(ListQuery query) {
    final statusRaw = query.facet('status');
    final customerRaw = query.facet('customer');
    final salespersonRaw = query.facet('salesperson');
    return SalesQuotesFilter(
      status: statusRaw != null ? _statusByName(statusRaw) : null,
      customer: customerRaw != null ? int.tryParse(customerRaw) : null,
      salesperson: salespersonRaw != null ? int.tryParse(salespersonRaw) : null,
      search: query.search,
      pageIndex: query.pageIndex,
    );
  }
}

SaleStatus? _statusByName(String name) {
  for (final status in SaleStatus.values) {
    if (status.name == name) return status;
  }
  return null;
}

/// Derived facet-filter summary for the quotes list's Filters button badge
/// — search is excluded from the count, per house convention (`sales_orders_
/// list_controller.dart`'s own `SalesOrdersFilterBadge`).
extension SalesQuotesFilterBadge on SalesQuotesFilter {
  int get activeFilterCount {
    var count = 0;
    if (status != null) count++;
    if (customer != null) count++;
    if (salesperson != null) count++;
    return count;
  }

  bool get hasActiveFilters => activeFilterCount > 0;
}

/// Fetches and holds the Sales Quotes list (FR-034–FR-038) for the given
/// [SalesQuotesFilter]. A family keyed by the filter value: a different URL
/// is a different provider instance, and `ref.invalidate` after a mutation
/// (confirm, cancel, duplicate) re-fetches the *same* page rather than
/// resetting to page 0.
@riverpod
class SalesQuotesListController extends _$SalesQuotesListController {
  @override
  Future<CatalogPage<SalesQuoteSummary>> build(SalesQuotesFilter filter) {
    return fetchClampedPage(
      pageIndex: filter.pageIndex,
      pageSize: _pageSize,
      fetch: (pageIndex) => _fetch(filter.copyWith(pageIndex: pageIndex)),
    );
  }

  Future<CatalogPage<SalesQuoteSummary>> _fetch(SalesQuotesFilter filter) async {
    final result = await ref
        .read(salesQuoteRepositoryProvider)
        .listQuotes(
          // FR-034: the facility's quotes, not filtered to the current user
          // by default — always `false`, never a filter the URL can toggle.
          mine: false,
          customer: filter.customer,
          salesperson: filter.salesperson,
          status: filter.status,
          search: filter.search.isEmpty ? null : filter.search,
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
