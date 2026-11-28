import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payments_filter.dart';

part 'purchase_orders_filter.freezed.dart';

/// The "Órdenes de compra" list's addressable view state (spec 080 research
/// R15). Every field lives in the URL, so Back from an order returns to the
/// same page and filters. URL keys: `search` (the order number box), `all`,
/// `status`, `supplier`, `creator`, `from`, `to`, `page`.
@freezed
abstract class PurchaseOrdersFilter with _$PurchaseOrdersFilter {
  const PurchaseOrdersFilter._();

  const factory PurchaseOrdersFilter({
    /// "Todas" instead of "Mis órdenes".
    @Default(false) bool all,
    InventoryDocumentStatus? status,
    int? supplierId,
    int? creatorId,

    /// Both ends or neither: a half-open or reversed range is dropped.
    DateTime? from,
    DateTime? to,

    /// The order number sent as `id`; null when the box is empty or not a
    /// number.
    int? orderId,

    /// The search box text as typed, kept even when it is not a number.
    @Default('') String search,
    @Default(0) int pageIndex,
  }) = _PurchaseOrdersFilter;

  /// An unknown `status` or a non-numeric `supplier` or `creator` is ignored.
  /// A non-numeric search is kept for the box but sends no `id`.
  factory PurchaseOrdersFilter.fromQuery(ListQuery query) {
    var from = parsePaymentsDateFacet(query.facet('from'));
    var to = parsePaymentsDateFacet(query.facet('to'));
    if (from == null || to == null || to.isBefore(from)) {
      from = null;
      to = null;
    }
    final status = query.facet('status');
    return PurchaseOrdersFilter(
      all: query.facet('all') == 'true',
      status: InventoryDocumentStatus.values
          .where((s) => s.name == status)
          .firstOrNull,
      supplierId: int.tryParse(query.facet('supplier') ?? ''),
      creatorId: int.tryParse(query.facet('creator') ?? ''),
      from: from,
      to: to,
      orderId: int.tryParse(query.search.trim()),
      search: query.search,
      pageIndex: query.pageIndex,
    );
  }

  /// This filter as a URL query, facets in their canonical order. The
  /// `status` value is the wire value.
  ListQuery toQuery() => ListQuery(search: search, pageIndex: pageIndex)
      .withFacet('all', all ? 'true' : null)
      .withFacet('status', status?.name)
      .withFacet('supplier', supplierId?.toString())
      .withFacet('creator', creatorId?.toString())
      .withFacet('from', from == null ? null : encodePaymentsDateFacet(from!))
      .withFacet('to', to == null ? null : encodePaymentsDateFacet(to!));

  /// What the drawer badge counts: one per facet in use, `all` when true and
  /// the date range as one. Not the number search box, nor the page.
  int get activeFilterCount =>
      (all ? 1 : 0) +
      (status != null ? 1 : 0) +
      (supplierId != null ? 1 : 0) +
      (creatorId != null ? 1 : 0) +
      (from != null ? 1 : 0);

  /// Anything narrows the list, the search box included: it tells an empty
  /// list from an over-filtered one.
  bool get isNarrowed => activeFilterCount > 0 || search.trim().isNotEmpty;

  /// "Limpiar todo": everything emptied, back to page 1.
  PurchaseOrdersFilter cleared() => const PurchaseOrdersFilter();
}
