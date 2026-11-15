import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/sales/domain/entities/pending_delivery.dart';
import 'package:mbe_ui/features/sales/presentation/for_delivery/pending_deliveries_filter.dart';

/// Spec 063 data-model §4, research R3: the screen's whole view state lives in
/// the URL.
void main() {
  test('no facet decodes to Hoy, nothing narrowed, page 0', () {
    final filter = PendingDeliveriesFilter.fromQuery(const ListQuery());

    expect(filter, const PendingDeliveriesFilter());
    expect(filter.period, PendingDeliveryPeriod.today);
    expect(filter.activeFilterCount, 0);
    expect(filter.isNarrowed, isFalse);
  });

  test('an unknown period decodes to Hoy', () {
    final filter = PendingDeliveriesFilter.fromQuery(
      const ListQuery().withFacet('period', 'bogus'),
    );

    expect(filter.period, PendingDeliveryPeriod.today);
  });

  test('every period round-trips through the URL, with its server key', () {
    for (final period in PendingDeliveryPeriod.values) {
      final filter = PendingDeliveriesFilter(period: period, pageIndex: 2);

      expect(PendingDeliveriesFilter.fromQuery(filter.toQuery()), filter);
    }
    expect(
      PendingDeliveriesFilter(
        period: PendingDeliveryPeriod.dayAfter,
      ).toQuery().facet('period'),
      'day_after',
    );
  });

  test('Hoy is left out of the URL', () {
    final uri = const PendingDeliveriesFilter().toQuery().toUri(
      forDeliveryPath,
    );

    expect(uri.toString(), forDeliveryPath);
  });

  test('the page index is read from the query, 1-based in the URL', () {
    final filter = PendingDeliveriesFilter.fromQuery(
      ListQuery.fromUri(Uri.parse('$forDeliveryPath?period=later&page=3')),
    );

    expect(filter.period, PendingDeliveryPeriod.later);
    expect(filter.pageIndex, 2);
  });

  test('the badge counts one for any period but Hoy', () {
    for (final period in PendingDeliveryPeriod.values) {
      final filter = PendingDeliveriesFilter(period: period);
      final expected = period == PendingDeliveryPeriod.today ? 0 : 1;

      expect(filter.activeFilterCount, expected);
      expect(filter.isNarrowed, expected == 1);
    }
  });

  test('cleared goes back to Hoy on the first page', () {
    final filter = PendingDeliveriesFilter(
      period: PendingDeliveryPeriod.later,
      pageIndex: 4,
    );

    expect(filter.cleared(), const PendingDeliveriesFilter());
  });
}
