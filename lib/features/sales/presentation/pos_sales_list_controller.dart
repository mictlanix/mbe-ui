import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/open_sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';

part 'pos_sales_list_controller.freezed.dart';
part 'pos_sales_list_controller.g.dart';

const _pageSize = 20;

/// `yyyy-MM-dd` — a fixed, locale-independent pattern for the `date-from`/
/// `date-to` facet values, since these are machine-readable URL state, not
/// display text (spec 023 data-model §2.1).
final _dateFacetFormat = DateFormat('yyyy-MM-dd');

/// The POS sales list's addressable view state (spec 023 data-model §2):
/// a date range (defaulting to the trading day), an optional status facet,
/// free-text search and the current page. The register is deliberately
/// **not** a field — it is not something the cashier may vary (FR-003) and
/// is read from [registerPointSaleProvider] instead.
@freezed
class PosSalesFilter with _$PosSalesFilter {
  const factory PosSalesFilter({
    required DateTime from,
    required DateTime to,
    SaleStatus? status,
    @Default('') String search,
    @Default(0) int pageIndex,
  }) = _PosSalesFilter;

  /// Decodes [query]'s `date-from`/`date-to`/`status` facets, defaulting an
  /// absent or unparseable value to [today] (for the dates) or to "every
  /// status" (for the facet) — total, like every other `fromQuery`, never
  /// throwing on a malformed URL.
  ///
  /// [today] is truncated to its calendar date before use, **not** used at
  /// whatever second/millisecond `DateTime.now()` happened to return. This
  /// controller is watched by a `@riverpod` family keyed on the whole
  /// [PosSalesFilter] value — passing a raw `DateTime.now()` through would
  /// make every rebuild construct a filter equal to no prior one (down to
  /// the microsecond), so the family never reuses a provider instance: each
  /// watch starts a fresh fetch, whose completion triggers the very rebuild
  /// that starts the next one — an infinite loop that keeps the list
  /// permanently in its loading state. Confirmed live: a widget test pumping
  /// this screen never settled until this normalization was added.
  factory PosSalesFilter.fromQuery(ListQuery query, {required DateTime today}) {
    final todayDate = DateTime(today.year, today.month, today.day);
    final from = _parseDateFacet(query.facet('date-from')) ?? todayDate;
    final to = _parseDateFacet(query.facet('date-to')) ?? todayDate;
    final statusRaw = query.facet('status');
    return PosSalesFilter(
      from: from,
      to: to,
      status: statusRaw != null ? _statusByName(statusRaw) : null,
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

SaleStatus? _statusByName(String name) {
  for (final status in SaleStatus.values) {
    if (status.name == name) return status;
  }
  return null;
}

/// Facet-value encoding and derived state, following this codebase's
/// convention of keeping custom members on a freezed value as an extension
/// (see `ListQueryX`, `CashSessionFilterBadge`).
/// `yyyy-MM-dd` encoding for a `date-from`/`date-to` facet value — exposed
/// standalone (not only via [PosSalesFilterBadge]) so a caller building a
/// *new* range from a date picker's result doesn't need to construct a whole
/// [PosSalesFilter] just to format one date.
String encodePosSalesDateFacet(DateTime date) => _dateFacetFormat.format(date);

extension PosSalesFilterBadge on PosSalesFilter {
  /// `date-from`/`date-to` in [_dateFacetFormat] — what a screen passes to
  /// `ListQuery.withFacet` when the cashier changes the range.
  String get fromFacetValue => encodePosSalesDateFacet(from);
  String get toFacetValue => encodePosSalesDateFacet(to);

  /// Whether this is the default range: `from == to ==` [today]. A filter
  /// cleared back to it encodes to no `date-from`/`date-to` facet at all
  /// (`ListQuery.isDefault` convention) — clearing the chip returns to today,
  /// never to unbounded (research R6: an unfiltered `GET /sales-orders`
  /// measured 19,277 rows for one register).
  ///
  /// [today] is a parameter rather than a `DateTime.now()` read inside, for the
  /// same reason [PosSalesFilter.fromQuery] takes one: the caller decides what
  /// "today" is, and both must agree on it. Reading the clock here instead
  /// meant a filter built for an injected date was judged against the real one
  /// — untestable except on the one calendar day the fixture named, and, in the
  /// screen, two `DateTime.now()` reads that a midnight tick between them could
  /// separate.
  bool isToday(DateTime today) =>
      _isSameDate(from, today) && _isSameDate(to, today);

  int activeFilterCount(DateTime today) =>
      (isToday(today) ? 0 : 1) +
      (status != null ? 1 : 0) +
      (search.isNotEmpty ? 1 : 0);

  bool hasActiveFilters(DateTime today) => activeFilterCount(today) > 0;
}

bool _isSameDate(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Fetches and holds the register's sales page (spec 023 FR-001–FR-005) for
/// the given [pointSale] and [PosSalesFilter].
///
/// [pointSale] is a family parameter, not read internally from
/// [registerPointSaleProvider] — "no register configured" (FR-003, Edge
/// Cases) is a screen-level state the caller checks *before* watching this
/// provider at all, not a nullable variant of [CatalogPage] threaded through
/// every consumer; [CatalogListStateView]'s `AsyncValue<CatalogPage<T>>`
/// contract expects exactly that non-nullable shape.
///
/// Narrows each page to [PosSalesFilter.status] client-side: mbe-api's
/// `status` filter is **not** exclusive — `completed` answers with `paid`
/// rows too (spec 020's own live-verified finding on `listOpen`) — so a
/// caller asking for one status must not trust the raw page.
@riverpod
class PosSalesListController extends _$PosSalesListController {
  @override
  Future<CatalogPage<OpenSale>> build(int pointSale, PosSalesFilter filter) {
    return fetchClampedPage(
      pageIndex: filter.pageIndex,
      pageSize: _pageSize,
      fetch: (pageIndex) => _fetch(pointSale, filter.copyWith(pageIndex: pageIndex)),
    );
  }

  Future<CatalogPage<OpenSale>> _fetch(int pointSale, PosSalesFilter filter) async {
    final result = await ref
        .read(salesOrderRepositoryProvider)
        .listSales(
          pointSale: pointSale,
          status: filter.status,
          dateFrom: filter.from,
          dateTo: filter.to,
          search: filter.search.isEmpty ? null : filter.search,
          skip: filter.pageIndex * _pageSize,
          limit: _pageSize,
        );
    final items = filter.status == null
        ? result.items
        : result.items.where((sale) => sale.status == filter.status).toList();
    return CatalogPage(
      items: items,
      total: result.total,
      pageIndex: filter.pageIndex,
      pageSize: _pageSize,
    );
  }
}
