import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_request.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payments_filter.dart';

part 'purchase_requests_filter.freezed.dart';

/// The "Solicitudes de compra" list's addressable view state (spec 079
/// research R9). Every field lives in the URL, so Back from a request returns
/// to the same page and filters. URL keys: `search` (the folio box), `all`,
/// `status`, `facility`, `warehouse`, `creator`, `from`, `to`, `page`.
@freezed
abstract class PurchaseRequestsFilter with _$PurchaseRequestsFilter {
  const PurchaseRequestsFilter._();

  const factory PurchaseRequestsFilter({
    /// "Todas" instead of "Mis solicitudes".
    @Default(false) bool all,
    PurchaseRequestStatus? status,
    int? facilityId,
    int? warehouseId,
    int? creatorId,

    /// Both ends or neither: a half-open or reversed range is dropped.
    DateTime? from,
    DateTime? to,

    /// The folio search box; numeric only.
    int? serial,
    @Default(0) int pageIndex,
  }) = _PurchaseRequestsFilter;

  /// An unknown `status` or a non-numeric `facility`, `warehouse`, `creator`
  /// or folio is ignored.
  factory PurchaseRequestsFilter.fromQuery(ListQuery query) {
    var from = parsePaymentsDateFacet(query.facet('from'));
    var to = parsePaymentsDateFacet(query.facet('to'));
    if (from == null || to == null || to.isBefore(from)) {
      from = null;
      to = null;
    }
    final status = query.facet('status');
    return PurchaseRequestsFilter(
      all: query.facet('all') == 'true',
      status: PurchaseRequestStatus.values
          .where((s) => s.name == status)
          .firstOrNull,
      facilityId: int.tryParse(query.facet('facility') ?? ''),
      warehouseId: int.tryParse(query.facet('warehouse') ?? ''),
      creatorId: int.tryParse(query.facet('creator') ?? ''),
      from: from,
      to: to,
      serial: int.tryParse(query.search.trim()),
      pageIndex: query.pageIndex,
    );
  }

  /// This filter as a URL query, facets in their canonical order. The
  /// `status` value is the wire value.
  ListQuery toQuery() =>
      ListQuery(search: serial?.toString() ?? '', pageIndex: pageIndex)
          .withFacet('all', all ? 'true' : null)
          .withFacet('status', status?.name)
          .withFacet('facility', facilityId?.toString())
          .withFacet('warehouse', warehouseId?.toString())
          .withFacet('creator', creatorId?.toString())
          .withFacet(
            'from',
            from == null ? null : encodePaymentsDateFacet(from!),
          )
          .withFacet('to', to == null ? null : encodePaymentsDateFacet(to!));

  /// What the drawer badge counts: one per facet in use, `all` when true and
  /// the date range as one. Not the folio search box, nor the page.
  int get activeFilterCount =>
      (all ? 1 : 0) +
      (status != null ? 1 : 0) +
      (facilityId != null ? 1 : 0) +
      (warehouseId != null ? 1 : 0) +
      (creatorId != null ? 1 : 0) +
      (from != null ? 1 : 0);

  /// Anything narrows the list, the folio box included: it tells an empty
  /// list from an over-filtered one.
  bool get isNarrowed => activeFilterCount > 0 || serial != null;

  /// "Limpiar todo": everything emptied, back to page 1.
  PurchaseRequestsFilter cleared() => const PurchaseRequestsFilter();
}
