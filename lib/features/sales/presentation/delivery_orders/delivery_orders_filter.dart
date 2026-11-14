import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payments_filter.dart';

part 'delivery_orders_filter.freezed.dart';

/// The "Órdenes de entrega" list's addressable view state (spec 061
/// data-model §2, research R3). Every field lives in the URL, so Back from an
/// order returns to the same page and filters.
///
/// An absent [status] means every status: the interim opening state until
/// mbe-api#312 lets one request cover the non-terminal statuses (FR-003). An
/// absent [facilityId] means the server's default, the caller's facility.
@freezed
abstract class DeliveryOrdersFilter with _$DeliveryOrdersFilter {
  const DeliveryOrdersFilter._();

  const factory DeliveryOrdersFilter({
    /// The folio search box: digits only, `null` when empty. Carried in
    /// `ListQuery.search`, like every other list's search box.
    String? search,
    DeliveryOrderStatus? status,
    FulfillmentType? type,

    /// Both ends or neither, as in Pagos: a half-open or reversed range is
    /// dropped by [fromQuery].
    DateTime? dateFrom,
    DateTime? dateTo,
    int? customerId,
    int? salesOrderId,

    /// Administrators only. Never set for anyone else by [fromQuery], and
    /// dropped again by the list controller's fetch (research R3).
    int? facilityId,
    @Default(0) int pageIndex,
  }) = _DeliveryOrdersFilter;

  /// [isAdministrator] decides whether the `facility` key is read at all.
  /// mbe-api honours any `facility` from any reader (mbe-api#314), so a
  /// non-administrator's hand-typed `facility` must never reach the request.
  /// The list controller drops it a second time on its own terms; keep both.
  factory DeliveryOrdersFilter.fromQuery(
    ListQuery query, {
    required bool isAdministrator,
  }) {
    var from = parsePaymentsDateFacet(query.facet('from'));
    var to = parsePaymentsDateFacet(query.facet('to'));
    if (from == null || to == null || to.isBefore(from)) {
      from = null;
      to = null;
    }
    final search = query.search.trim();
    final statusCode = _parseIntFacet(query.facet('status'));
    final typeCode = _parseIntFacet(query.facet('type'));
    return DeliveryOrdersFilter(
      search: RegExp(r'^\d+$').hasMatch(search) ? search : null,
      status: DeliveryOrderStatus.values
          .where((s) => s.value == statusCode)
          .firstOrNull,
      type: FulfillmentType.values
          .where((t) => t.value == typeCode)
          .firstOrNull,
      dateFrom: from,
      dateTo: to,
      customerId: _parseIntFacet(query.facet('customer')),
      salesOrderId: _parseIntFacet(query.facet('order')),
      facilityId: isAdministrator
          ? _parseIntFacet(query.facet('facility'))
          : null,
      pageIndex: query.pageIndex,
    );
  }

  /// This filter as a URL query, facets in their canonical order.
  ListQuery toQuery() => ListQuery(search: search ?? '', pageIndex: pageIndex)
      .withFacet('status', status?.value.toString())
      .withFacet('type', type?.value.toString())
      .withFacet(
        'from',
        dateFrom == null ? null : encodePaymentsDateFacet(dateFrom!),
      )
      .withFacet('to', dateTo == null ? null : encodePaymentsDateFacet(dateTo!))
      .withFacet('customer', customerId?.toString())
      .withFacet('order', salesOrderId?.toString())
      .withFacet('facility', facilityId?.toString());

  /// What the drawer badge counts: one per facet in use, a date range as
  /// one. Not the search box, nor the page.
  int get activeFilterCount =>
      (status != null ? 1 : 0) +
      (type != null ? 1 : 0) +
      (dateFrom != null ? 1 : 0) +
      (customerId != null ? 1 : 0) +
      (salesOrderId != null ? 1 : 0) +
      (facilityId != null ? 1 : 0);

  bool get isNarrowed => activeFilterCount > 0 || search != null;

  /// "Limpiar todo": every facet emptied, the search box kept, back to page 1.
  DeliveryOrdersFilter cleared() => DeliveryOrdersFilter(search: search);
}

int? _parseIntFacet(String? value) =>
    value == null ? null : int.tryParse(value);
