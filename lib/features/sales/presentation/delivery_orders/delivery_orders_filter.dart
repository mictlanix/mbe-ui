import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payments_filter.dart';

part 'delivery_orders_filter.freezed.dart';

/// Whether [access] may list another facility's delivery orders: the
/// server's rule since mbe-api#314, read on SearchCreditsFromAllStores (101)
/// or DeliveryItineraries (87). Administrators pass through
/// [AccessControlService.can].
bool seesEveryFacilitysDeliveryOrders(AccessControlService access) =>
    access.can(SystemObject.searchCreditsFromAllStores, AccessRight.read) ||
    access.can(SystemObject.deliveryItineraries, AccessRight.read);

/// The "Órdenes de entrega" list's addressable view state (spec 061
/// data-model §2, research R3). Every field lives in the URL, so Back from an
/// order returns to the same page and filters.
///
/// With no [status] and no [everyStatus], the list shows the active
/// (non-terminal) statuses, its opening state (FR-003, mbe-api#312). An
/// absent [facilityId] means the server's default, the caller's facility.
@freezed
abstract class DeliveryOrdersFilter with _$DeliveryOrdersFilter {
  const DeliveryOrdersFilter._();

  const factory DeliveryOrdersFilter({
    /// The folio search box: digits only, `null` when empty. Carried in
    /// `ListQuery.search`, like every other list's search box.
    String? search,
    DeliveryOrderStatus? status,

    /// "Todas": every status, terminal ones included. Ignored when [status]
    /// is set. URL `status=all`.
    @Default(false) bool everyStatus,
    FulfillmentType? type,

    /// Both ends or neither, as in Pagos: a half-open or reversed range is
    /// dropped by [fromQuery].
    DateTime? dateFrom,
    DateTime? dateTo,
    int? customerId,
    int? salesOrderId,

    /// Only for a user who [seesEveryFacilitysDeliveryOrders]. Never set for
    /// anyone else by [fromQuery], and dropped again by the list controller's
    /// fetch (research R3).
    int? facilityId,
    @Default(0) int pageIndex,
  }) = _DeliveryOrdersFilter;

  /// [seesEveryFacility] decides whether the `facility` key is read at all, so
  /// anyone else's hand-typed `facility` never reaches the request.
  /// mbe-api checks it too since mbe-api#314; this stays as defence in depth.
  /// The list controller drops it a second time on its own terms; keep both.
  factory DeliveryOrdersFilter.fromQuery(
    ListQuery query, {
    required bool seesEveryFacility,
  }) {
    var from = parsePaymentsDateFacet(query.facet('from'));
    var to = parsePaymentsDateFacet(query.facet('to'));
    if (from == null || to == null || to.isBefore(from)) {
      from = null;
      to = null;
    }
    final search = query.search.trim();
    final statusFacet = query.facet('status');
    final statusCode = _parseIntFacet(statusFacet);
    final typeCode = _parseIntFacet(query.facet('type'));
    return DeliveryOrdersFilter(
      search: RegExp(r'^\d+$').hasMatch(search) ? search : null,
      status: DeliveryOrderStatus.values
          .where((s) => s.value == statusCode)
          .firstOrNull,
      everyStatus: statusFacet == _everyStatusFacet,
      type: FulfillmentType.values
          .where((t) => t.value == typeCode)
          .firstOrNull,
      dateFrom: from,
      dateTo: to,
      customerId: _parseIntFacet(query.facet('customer')),
      salesOrderId: _parseIntFacet(query.facet('order')),
      facilityId: seesEveryFacility
          ? _parseIntFacet(query.facet('facility'))
          : null,
      pageIndex: query.pageIndex,
    );
  }

  /// This filter as a URL query, facets in their canonical order.
  ListQuery toQuery() => ListQuery(search: search ?? '', pageIndex: pageIndex)
      .withFacet('status', statusFacet)
      .withFacet('type', type?.value.toString())
      .withFacet(
        'from',
        dateFrom == null ? null : encodePaymentsDateFacet(dateFrom!),
      )
      .withFacet('to', dateTo == null ? null : encodePaymentsDateFacet(dateTo!))
      .withFacet('customer', customerId?.toString())
      .withFacet('order', salesOrderId?.toString())
      .withFacet('facility', facilityId?.toString());

  /// The `status` URL value: a wire number, `all`, or `null` for active.
  String? get statusFacet =>
      status?.value.toString() ?? (everyStatus ? _everyStatusFacet : null);

  /// The statuses to request: the chosen one, every status (`null`), or the
  /// active ones.
  List<DeliveryOrderStatus>? get requestStatuses => status != null
      ? [status!]
      : everyStatus
      ? null
      : DeliveryOrderStatus.active;

  /// What the drawer badge counts: one per facet in use, a date range as
  /// one. Not the search box, nor the page.
  int get activeFilterCount =>
      (statusFacet != null ? 1 : 0) +
      (type != null ? 1 : 0) +
      (dateFrom != null ? 1 : 0) +
      (customerId != null ? 1 : 0) +
      (salesOrderId != null ? 1 : 0) +
      (facilityId != null ? 1 : 0);

  bool get isNarrowed => activeFilterCount > 0 || search != null;

  /// "Limpiar todo": every facet emptied, the search box kept, back to page 1.
  DeliveryOrdersFilter cleared() => DeliveryOrdersFilter(search: search);
}

const _everyStatusFacet = 'all';

int? _parseIntFacet(String? value) =>
    value == null ? null : int.tryParse(value);
