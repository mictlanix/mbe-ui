import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';

part 'payments_filter.freezed.dart';

/// Which payments the list covers (spec 054 research R5): the user's own
/// facility, or — for a Payments Editor reader only — every facility.
enum PaymentsScope { facility, allFacilities }

/// The Pagos list's addressable view state (spec 054 data-model.md §4). Every
/// field lives in the URL, so Back from a payment returns to the same page
/// and filters.
///
/// Unlike Pedidos there is **no default date range** (research R6): with no
/// facet the list is the facility's whole history, newest first, and clearing
/// the filters returns to exactly that (Story 1, scenario 8).
@freezed
abstract class PaymentsFilter with _$PaymentsFilter {
  const PaymentsFilter._();

  const factory PaymentsFilter({
    @Default(PaymentsScope.facility) PaymentsScope scope,
    int? customerId,

    /// Both ends or neither: a half-open range is dropped by [fromQuery], so
    /// the date chip never has to show one.
    DateTime? dateFrom,
    DateTime? dateTo,
    int? methodCode,

    /// Tri-state (FR-007): `null` lists any, `true` only verified, `false`
    /// only unverified.
    bool? verified,
    int? cashSessionId,

    /// A fragment of the payment's reference — all-facilities mode only,
    /// where it is the search box. Carried in `ListQuery.search`.
    String? reference,

    /// A fragment of the customer's name — facility mode only, where it is the
    /// search box (spec 055 R3). Carried in `ListQuery.search`, like
    /// [reference]: each scope reads the one the other ignores.
    String? customerSearch,
    @Default(0) int pageIndex,
  }) = _PaymentsFilter;

  /// [canSearchAllFacilities] is the user's Payments Editor read right. A
  /// `scope=all` the user can't use is read as the facility scope, so a
  /// hand-typed address can never widen what they see (FR-002, SC-004); and
  /// in the all-facilities scope the facility-only facets are ignored, since
  /// that endpoint has no such filters (FR-012). The one `search` box means a
  /// customer name in the facility scope and a reference in the other.
  factory PaymentsFilter.fromQuery(
    ListQuery query, {
    bool canSearchAllFacilities = false,
  }) {
    final allFacilities =
        canSearchAllFacilities && query.facet('scope') == 'all';
    var from = _parseDateFacet(query.facet('date-from'));
    var to = _parseDateFacet(query.facet('date-to'));
    // An end before the start can't be a range; the picker prevents it, so
    // only a hand-edited address gets here. Dropping both is the one reading
    // that cannot show an empty list for a filter the user can't see.
    if (from == null || to == null || to.isBefore(from)) {
      from = null;
      to = null;
    }
    final reference = query.search.trim();
    return PaymentsFilter(
      scope: allFacilities
          ? PaymentsScope.allFacilities
          : PaymentsScope.facility,
      customerId: _parseIntFacet(query.facet('customer')),
      dateFrom: from,
      dateTo: to,
      methodCode: allFacilities ? null : _parseIntFacet(query.facet('method')),
      verified: allFacilities
          ? null
          : switch (query.facet('verified')) {
              'true' => true,
              'false' => false,
              _ => null,
            },
      cashSessionId: allFacilities
          ? null
          : _parseIntFacet(query.facet('cash-session')),
      reference: allFacilities && reference.isNotEmpty ? reference : null,
      customerSearch: !allFacilities && reference.isNotEmpty ? reference : null,
      pageIndex: query.pageIndex,
    );
  }

  /// How many facets the drawer badge counts. A date range is one facet, and
  /// the reference and the customer-name search are not — each is the visible
  /// search box.
  int get activeFilterCount =>
      (customerId != null ? 1 : 0) +
      (dateFrom != null ? 1 : 0) +
      (methodCode != null ? 1 : 0) +
      (verified != null ? 1 : 0) +
      (cashSessionId != null ? 1 : 0);

  bool get hasActiveFilters => activeFilterCount > 0;

  /// Whether anything narrows the list at all, the search box included — what
  /// decides between the empty state and the "nothing matches" one.
  bool get isNarrowed =>
      hasActiveFilters || reference != null || customerSearch != null;
}

/// [query] re-pointed at [scope] (FR-012): keeps the customer and date range,
/// which both modes support, and drops everything else — the facility-only
/// facets, the search text (a customer name in one scope, a reference in the
/// other) and the page — so a hidden filter never keeps narrowing a list that
/// no longer shows it.
ListQuery paymentsQueryForScope(ListQuery query, PaymentsScope scope) =>
    const ListQuery()
        .withFacet('scope', scope == PaymentsScope.allFacilities ? 'all' : null)
        .withFacet('customer', query.facet('customer'))
        .withFacet('date-from', query.facet('date-from'))
        .withFacet('date-to', query.facet('date-to'));

/// A `date-from`/`date-to` facet value, `yyyy-MM-dd` — fixed and
/// locale-independent, the same shape the POS and Sales Orders lists use.
///
/// Parsed by hand rather than with `DateFormat`: this is a URL encoding, not a
/// display path, and the formatting guard (spec 028 FR-018) keeps `intl` out
/// of everything but the formatting surface. A date that does not exist
/// (`2026-02-31`) is rejected, not rolled over to March.
DateTime? _parseDateFacet(String? value) {
  if (value == null) return null;
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);
  if (match == null) return null;
  final year = int.parse(match.group(1)!);
  final month = int.parse(match.group(2)!);
  final day = int.parse(match.group(3)!);
  final date = DateTime(year, month, day);
  return date.year == year && date.month == month && date.day == day
      ? date
      : null;
}

int? _parseIntFacet(String? value) =>
    value == null ? null : int.tryParse(value);

/// `yyyy-MM-dd` encoding for a `date-from`/`date-to` facet value.
String encodePaymentsDateFacet(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';
