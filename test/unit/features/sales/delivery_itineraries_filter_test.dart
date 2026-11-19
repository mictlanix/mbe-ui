import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_itinerary.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/delivery_itineraries_filter.dart';

/// Spec 075 FR-003: the list's whole view state lives in the URL.
void main() {
  test('no facets decode to every status, nothing narrowed, page 0', () {
    final filter = DeliveryItinerariesFilter.fromQuery(const ListQuery());

    expect(filter, const DeliveryItinerariesFilter());
    expect(filter.activeFilterCount, 0);
    expect(filter.isNarrowed, isFalse);
  });

  test('every facet round-trips through the URL', () {
    final filter = DeliveryItinerariesFilter(
      status: ItineraryStatus.departed,
      dateFrom: DateTime(2026, 11, 1),
      dateTo: DateTime(2026, 11, 18),
      vehicleId: 4,
      operatorId: 9,
      warehouseId: 3,
      pageIndex: 2,
    );

    final decoded = DeliveryItinerariesFilter.fromQuery(filter.toQuery());

    expect(decoded, filter);
  });

  test('the badge counts one per facet, a date range as one', () {
    final filter = DeliveryItinerariesFilter(
      status: ItineraryStatus.open,
      dateFrom: DateTime(2026, 11, 1),
      dateTo: DateTime(2026, 11, 18),
      vehicleId: 4,
    );

    expect(filter.activeFilterCount, 3);
    expect(filter.isNarrowed, isTrue);
  });

  test('a half-open or reversed date range is dropped', () {
    final half = DeliveryItinerariesFilter.fromQuery(
      const ListQuery().withFacet('from', '2026-11-01'),
    );
    final reversed = DeliveryItinerariesFilter.fromQuery(
      const ListQuery()
          .withFacet('from', '2026-11-18')
          .withFacet('to', '2026-11-01'),
    );

    expect(half.dateFrom, isNull);
    expect(reversed.dateFrom, isNull);
    expect(reversed.dateTo, isNull);
  });

  test('an unknown status or a non-number id is ignored', () {
    final filter = DeliveryItinerariesFilter.fromQuery(
      const ListQuery().withFacet('status', '9').withFacet('vehicle', 'abc'),
    );

    expect(filter.status, isNull);
    expect(filter.vehicleId, isNull);
  });

  test('cleared empties every facet and returns to page 0', () {
    const filter = DeliveryItinerariesFilter(
      status: ItineraryStatus.closed,
      vehicleId: 4,
      pageIndex: 3,
    );

    expect(filter.cleared(), const DeliveryItinerariesFilter());
  });
}
