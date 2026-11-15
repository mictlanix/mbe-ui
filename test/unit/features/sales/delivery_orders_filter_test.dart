import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_orders_filter.dart';

DeliveryOrdersFilter _decode(ListQuery query, {bool admin = false}) =>
    DeliveryOrdersFilter.fromQuery(query, isAdministrator: admin);

/// Spec 061 data-model §2, research R3: the list's whole view state lives in
/// the URL.
void main() {
  test('no facets decode to the active statuses, nothing narrowed, page 0 '
      '(FR-003, mbe-api#312)', () {
    final filter = _decode(const ListQuery());

    expect(filter, const DeliveryOrdersFilter());
    expect(filter.status, isNull);
    expect(filter.everyStatus, isFalse);
    expect(filter.requestStatuses, DeliveryOrderStatus.active);
    expect(filter.activeFilterCount, 0);
    expect(filter.isNarrowed, isFalse);
  });

  test('"Todas" is status=all: every status, one badge, cleared back to '
      'active', () {
    final filter = _decode(const ListQuery().withFacet('status', 'all'));

    expect(filter.everyStatus, isTrue);
    expect(filter.requestStatuses, isNull);
    expect(filter.toQuery().facet('status'), 'all');
    expect(filter.activeFilterCount, 1);
    expect(filter.cleared().requestStatuses, DeliveryOrderStatus.active);
  });

  test('a chosen status asks for that status alone', () {
    const filter = DeliveryOrdersFilter(status: DeliveryOrderStatus.delivered);

    expect(filter.requestStatuses, [DeliveryOrderStatus.delivered]);
  });

  test('the active statuses are every non-terminal one', () {
    expect(DeliveryOrderStatus.active, [
      DeliveryOrderStatus.draft,
      DeliveryOrderStatus.pendingApproval,
      DeliveryOrderStatus.approved,
      DeliveryOrderStatus.readyForPickup,
      DeliveryOrderStatus.inPreparation,
      DeliveryOrderStatus.inTransit,
      DeliveryOrderStatus.failed,
    ]);
  });

  test('a full filter round-trips through the URL', () {
    final filter = DeliveryOrdersFilter(
      search: '1042',
      status: DeliveryOrderStatus.readyForPickup,
      type: FulfillmentType.counterPickup,
      dateFrom: DateTime(2026, 11, 1),
      dateTo: DateTime(2026, 11, 30),
      customerId: 77,
      salesOrderId: 501,
      facilityId: 3,
      pageIndex: 2,
    );

    final query = filter.toQuery();
    expect(query.search, '1042');
    expect(query.facet('status'), '3');
    expect(query.facet('type'), '0');
    expect(query.facet('from'), '2026-11-01');
    expect(query.facet('to'), '2026-11-30');
    expect(query.facet('customer'), '77');
    expect(query.facet('order'), '501');
    expect(query.facet('facility'), '3');
    expect(_decode(query, admin: true), filter);
  });

  test('every status and type round-trips through its wire number', () {
    for (final status in DeliveryOrderStatus.values) {
      final filter = DeliveryOrdersFilter(status: status);
      expect(_decode(filter.toQuery()).status, status);
    }
    for (final type in FulfillmentType.values) {
      final filter = DeliveryOrdersFilter(type: type);
      expect(_decode(filter.toQuery()).type, type);
    }
  });

  test('a search with anything but digits is dropped', () {
    expect(_decode(const ListQuery(search: ' 42 ')).search, '42');
    expect(_decode(const ListQuery(search: 'ana')).search, isNull);
    expect(_decode(const ListQuery(search: '42a')).search, isNull);
    expect(_decode(const ListQuery(search: '   ')).search, isNull);
  });

  test('an unknown status or type, or a non-numeric id, is ignored', () {
    final filter = _decode(
      const ListQuery()
          .withFacet('status', '99')
          .withFacet('type', 'pickup')
          .withFacet('customer', 'abc')
          .withFacet('order', 'x1'),
    );

    expect(filter, const DeliveryOrdersFilter());
  });

  test('a half-open or reversed date range is dropped', () {
    expect(
      _decode(const ListQuery().withFacet('from', '2026-11-01')).dateFrom,
      isNull,
    );
    final reversed = _decode(
      const ListQuery()
          .withFacet('from', '2026-11-30')
          .withFacet('to', '2026-11-01'),
    );
    expect(reversed.dateFrom, isNull);
    expect(reversed.dateTo, isNull);
  });

  test('each facet counts once, a date range as one, search not at all', () {
    expect(
      const DeliveryOrdersFilter(
        status: DeliveryOrderStatus.draft,
      ).activeFilterCount,
      1,
    );
    expect(
      DeliveryOrdersFilter(
        status: DeliveryOrderStatus.draft,
        type: FulfillmentType.delivery,
        dateFrom: DateTime(2026, 11, 1),
        dateTo: DateTime(2026, 11, 2),
        customerId: 1,
        salesOrderId: 2,
        facilityId: 3,
      ).activeFilterCount,
      6,
    );

    const searchOnly = DeliveryOrdersFilter(search: '12');
    expect(searchOnly.activeFilterCount, 0);
    expect(searchOnly.isNarrowed, isTrue);
  });

  test('clearing empties every facet and returns to page 1', () {
    final cleared = DeliveryOrdersFilter(
      search: '12',
      status: DeliveryOrderStatus.failed,
      type: FulfillmentType.delivery,
      dateFrom: DateTime(2026, 11, 1),
      dateTo: DateTime(2026, 11, 2),
      customerId: 1,
      salesOrderId: 2,
      facilityId: 3,
      pageIndex: 4,
    ).cleared();

    expect(cleared, const DeliveryOrdersFilter(search: '12'));
    expect(cleared.activeFilterCount, 0);
  });

  group('facility (mbe-api#314)', () {
    final query = const ListQuery().withFacet('facility', '5');

    test('is ignored for a non-administrator', () {
      final filter = _decode(query);
      expect(filter.facilityId, isNull);
      expect(filter.activeFilterCount, 0);
    });

    test('is decoded for an administrator', () {
      expect(_decode(query, admin: true).facilityId, 5);
    });
  });
}
