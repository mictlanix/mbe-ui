import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_itinerary.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payments_filter.dart';

part 'delivery_itineraries_filter.freezed.dart';

/// The "Itinerarios" list's addressable view state (spec 075 FR-003). Every
/// field lives in the URL, so Back from a trip returns to the same page and
/// filters. There is no search box: the endpoint has none (research R14).
///
/// With no [status], the list shows every status.
@freezed
abstract class DeliveryItinerariesFilter with _$DeliveryItinerariesFilter {
  const DeliveryItinerariesFilter._();

  const factory DeliveryItinerariesFilter({
    /// One value, as the server takes one; `null` is every status.
    ItineraryStatus? status,

    /// Both ends or neither, as in Pagos and Órdenes de entrega: a half-open or
    /// reversed range is dropped by [fromQuery].
    DateTime? dateFrom,
    DateTime? dateTo,
    int? vehicleId,
    int? operatorId,
    int? warehouseId,
    @Default(0) int pageIndex,
  }) = _DeliveryItinerariesFilter;

  factory DeliveryItinerariesFilter.fromQuery(ListQuery query) {
    var from = parsePaymentsDateFacet(query.facet('from'));
    var to = parsePaymentsDateFacet(query.facet('to'));
    if (from == null || to == null || to.isBefore(from)) {
      from = null;
      to = null;
    }
    final statusCode = _parseIntFacet(query.facet('status'));
    return DeliveryItinerariesFilter(
      status: ItineraryStatus.values
          .where((s) => s.value == statusCode)
          .firstOrNull,
      dateFrom: from,
      dateTo: to,
      vehicleId: _parseIntFacet(query.facet('vehicle')),
      operatorId: _parseIntFacet(query.facet('operator')),
      warehouseId: _parseIntFacet(query.facet('warehouse')),
      pageIndex: query.pageIndex,
    );
  }

  /// This filter as a URL query, facets in their canonical order.
  ListQuery toQuery() => ListQuery(pageIndex: pageIndex)
      .withFacet('status', status?.value.toString())
      .withFacet(
        'from',
        dateFrom == null ? null : encodePaymentsDateFacet(dateFrom!),
      )
      .withFacet('to', dateTo == null ? null : encodePaymentsDateFacet(dateTo!))
      .withFacet('vehicle', vehicleId?.toString())
      .withFacet('operator', operatorId?.toString())
      .withFacet('warehouse', warehouseId?.toString());

  /// What the drawer badge counts: one per facet in use, a date range as one.
  int get activeFilterCount =>
      (status != null ? 1 : 0) +
      (dateFrom != null ? 1 : 0) +
      (vehicleId != null ? 1 : 0) +
      (operatorId != null ? 1 : 0) +
      (warehouseId != null ? 1 : 0);

  bool get isNarrowed => activeFilterCount > 0;

  /// "Limpiar todo": every facet emptied, back to page 1.
  DeliveryItinerariesFilter cleared() => const DeliveryItinerariesFilter();
}

int? _parseIntFacet(String? value) =>
    value == null ? null : int.tryParse(value);
