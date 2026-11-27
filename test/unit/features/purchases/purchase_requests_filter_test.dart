import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_request.dart';
import 'package:mbe_ui/features/purchases/presentation/requests/purchase_requests_filter.dart';

/// Spec 079 research R9: the list's view state lives in the URL.
void main() {
  test('no facets: nothing narrowed, page 0, own scope', () {
    final filter = PurchaseRequestsFilter.fromQuery(const ListQuery());

    expect(filter, const PurchaseRequestsFilter());
    expect(filter.all, isFalse);
    expect(filter.activeFilterCount, 0);
    expect(filter.isNarrowed, isFalse);
  });

  test('a full filter round-trips through the URL', () {
    final filter = PurchaseRequestsFilter(
      all: true,
      status: PurchaseRequestStatus.submitted,
      facilityId: 2,
      warehouseId: 3,
      creatorId: 5,
      from: DateTime(2026, 11, 1),
      to: DateTime(2026, 11, 30),
      serial: 571,
      pageIndex: 2,
    );

    final query = filter.toQuery();
    expect(query.search, '571');
    expect(query.facet('all'), 'true');
    expect(query.facet('status'), 'submitted');
    expect(query.facet('facility'), '2');
    expect(query.facet('warehouse'), '3');
    expect(query.facet('creator'), '5');
    expect(query.facet('from'), '2026-11-01');
    expect(query.facet('to'), '2026-11-30');
    expect(query.pageIndex, 2);
    expect(PurchaseRequestsFilter.fromQuery(query), filter);
  });

  test('every status round-trips through its wire value', () {
    for (final status in PurchaseRequestStatus.values) {
      final filter = PurchaseRequestsFilter(status: status);
      expect(PurchaseRequestsFilter.fromQuery(filter.toQuery()), filter);
    }
  });

  test('the default scope puts no all facet in the URL', () {
    expect(const PurchaseRequestsFilter().toQuery().facet('all'), isNull);
  });

  test('the badge counts all, each facet and the date range as one, not the '
      'folio or the page', () {
    expect(
      PurchaseRequestsFilter(
        all: true,
        status: PurchaseRequestStatus.draft,
        facilityId: 2,
        warehouseId: 3,
        creatorId: 5,
        from: DateTime(2026, 11, 1),
        to: DateTime(2026, 11, 30),
      ).activeFilterCount,
      6,
    );
    expect(const PurchaseRequestsFilter(all: true).activeFilterCount, 1);
    const searched = PurchaseRequestsFilter(serial: 571, pageIndex: 4);
    expect(searched.activeFilterCount, 0);
    expect(searched.isNarrowed, isTrue);
  });

  test('cleared keeps nothing, not even the folio or the scope', () {
    final cleared = PurchaseRequestsFilter(
      all: true,
      status: PurchaseRequestStatus.draft,
      serial: 571,
      pageIndex: 3,
    ).cleared();

    expect(cleared, const PurchaseRequestsFilter());
  });

  test('an unknown status and non-numeric ids and folio are ignored', () {
    final filter = PurchaseRequestsFilter.fromQuery(
      const ListQuery(search: 'abc')
          .withFacet('status', 'paid')
          .withFacet('facility', 'x')
          .withFacet('warehouse', 'y')
          .withFacet('creator', 'z')
          .withFacet('all', 'yes'),
    );

    expect(filter, const PurchaseRequestsFilter());
  });

  test('a half-open or reversed date range is dropped', () {
    final half = PurchaseRequestsFilter.fromQuery(
      const ListQuery().withFacet('from', '2026-11-01'),
    );
    final reversed = PurchaseRequestsFilter.fromQuery(
      const ListQuery()
          .withFacet('from', '2026-11-30')
          .withFacet('to', '2026-11-01'),
    );

    expect(half.from, isNull);
    expect(reversed.from, isNull);
    expect(reversed.to, isNull);
  });
}
