import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/open_sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/presentation/register_controller.dart';

part 'sales_orders_list_controller.freezed.dart';
part 'sales_orders_list_controller.g.dart';

const _pageSize = 20;

/// `yyyy-MM-dd` — a fixed, locale-independent pattern for the `date-from`/
/// `date-to` facet values (spec 023's own convention, `pos_sales_list_
/// controller.dart`).
final _dateFacetFormat = DateFormat('yyyy-MM-dd');

/// The Sales Orders list's addressable view state (spec 029 data-model.md
/// §4): a date range (defaulting to the current calendar month — a
/// back-office order is often captured days before it is confirmed, so
/// "today" would hide the very work this screen exists to manage,
/// research §R5), an optional status facet, free-text search, the current
/// page, and — for an administrator only — a salesperson and a facility.
///
/// [salesperson]/[facility] are decoded from the URL **only when
/// [isAdministrator]** (FR-006, FR-011): a non-administrator's filter
/// carries neither, whatever the address says. This is where the
/// hand-edited-address edge case is closed — in the decoder, not the
/// drawer.
@freezed
class SalesOrdersFilter with _$SalesOrdersFilter {
  const factory SalesOrdersFilter({
    required DateTime from,
    required DateTime to,
    SaleStatus? status,
    int? salesperson,
    int? facility,
    @Default('') String search,
    @Default(0) int pageIndex,
  }) = _SalesOrdersFilter;

  /// [today] is a parameter, truncated to a calendar date before use — never
  /// `DateTime.now()` read inside. A raw `DateTime.now()` here would make
  /// every rebuild construct a filter unequal to the last (down to the
  /// microsecond), so the `@riverpod` family keyed on this value would never
  /// reuse an instance: each watch starts a fetch whose completion triggers
  /// the rebuild that starts the next one — an infinite loop, confirmed and
  /// documented as the reason `PosSalesFilter.fromQuery` takes the same
  /// parameter (spec 023 research, `pos_sales_list_controller.dart:41-52`).
  factory SalesOrdersFilter.fromQuery(
    ListQuery query, {
    required DateTime today,
    required bool isAdministrator,
  }) {
    final todayDate = DateTime(today.year, today.month, today.day);
    final defaultFrom = DateTime(todayDate.year, todayDate.month);
    final defaultTo = DateTime(todayDate.year, todayDate.month + 1, 0);
    final from = _parseDateFacet(query.facet('date-from')) ?? defaultFrom;
    final to = _parseDateFacet(query.facet('date-to')) ?? defaultTo;
    final statusRaw = query.facet('status');
    return SalesOrdersFilter(
      from: from,
      to: to,
      status: statusRaw != null ? _statusByName(statusRaw) : null,
      salesperson: isAdministrator ? _parseIntFacet(query.facet('salesperson')) : null,
      facility: isAdministrator ? _parseIntFacet(query.facet('facility')) : null,
      search: query.search,
      pageIndex: query.pageIndex,
    );
  }
}

DateTime? _parseDateFacet(String? value) {
  if (value == null) return null;
  try {
    return _dateFacetFormat.parseStrict(value);
  } on FormatException {
    return null;
  }
}

int? _parseIntFacet(String? value) => value == null ? null : int.tryParse(value);

SaleStatus? _statusByName(String name) {
  for (final status in SaleStatus.values) {
    if (status.name == name) return status;
  }
  return null;
}

/// `yyyy-MM-dd` encoding for a `date-from`/`date-to` facet value.
String encodeSalesOrdersDateFacet(DateTime date) => _dateFacetFormat.format(date);

extension SalesOrdersFilterBadge on SalesOrdersFilter {
  String get fromFacetValue => encodeSalesOrdersDateFacet(from);
  String get toFacetValue => encodeSalesOrdersDateFacet(to);

  /// The default range: the calendar month containing [today]. Clearing the
  /// date chip returns to this — **never** to unbounded (FR-009; an
  /// unfiltered `GET /sales-orders` measured 19,277 rows for one register,
  /// spec 023 research R6).
  bool isDefaultRange(DateTime today) {
    final todayDate = DateTime(today.year, today.month, today.day);
    final defaultFrom = DateTime(todayDate.year, todayDate.month);
    final defaultTo = DateTime(todayDate.year, todayDate.month + 1, 0);
    return _isSameDate(from, defaultFrom) && _isSameDate(to, defaultTo);
  }

  /// Facets shown in the filter drawer's badge count (search excluded — it
  /// has its own visible control, matching every other catalog's
  /// convention).
  int activeFilterCount(DateTime today) =>
      (isDefaultRange(today) ? 0 : 1) +
      (status != null ? 1 : 0) +
      (salesperson != null ? 1 : 0) +
      (facility != null ? 1 : 0);

  bool hasActiveFilters(DateTime today) => activeFilterCount(today) > 0;
}

bool _isSameDate(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Fetches and holds the list's page (spec 029 FR-006–FR-011).
///
/// [mine] is built from `access.isAdministrator`, never decoded from the
/// URL — an ordinary user's request always carries `mine: true` regardless
/// of what the address says (FR-006). [isAdministrator] additionally decides
/// whether [SalesOrdersFilter.facility]/`.salesperson` reach the request at
/// all — both are already `null` for a non-administrator per
/// [SalesOrdersFilter.fromQuery]'s own decode rule, but the drop is
/// re-asserted here too so this controller enforces the rule on its own
/// terms rather than trusting the filter alone (data-model.md §5.1).
@riverpod
class SalesOrdersListController extends _$SalesOrdersListController {
  @override
  Future<CatalogPage<OpenSale>> build(SalesOrdersFilter filter, bool isAdministrator) {
    return fetchClampedPage(
      pageIndex: filter.pageIndex,
      pageSize: _pageSize,
      fetch: (pageIndex) =>
          _fetch(filter.copyWith(pageIndex: pageIndex), isAdministrator),
    );
  }

  Future<CatalogPage<OpenSale>> _fetch(
    SalesOrdersFilter filter,
    bool isAdministrator,
  ) async {
    final result = await ref
        .read(salesOrderRepositoryProvider)
        .listOrders(
          mine: !isAdministrator,
          // US5 scenario 1/2: an administrator who hasn't narrowed the
          // facility facet still sees their **own** facility's orders, not
          // every facility unscoped — the default lives here, at fetch
          // time, rather than baked into `SalesOrdersFilter.facility`
          // itself, so the badge/URL stay silent about a facet nobody
          // touched (`activeFilterCount` only counts an explicit choice).
          facility: isAdministrator
              ? (filter.facility ?? ref.read(userFacilityIdProvider))
              : null,
          salesperson: isAdministrator ? filter.salesperson : null,
          status: filter.status,
          dateFrom: filter.from,
          dateTo: filter.to,
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
