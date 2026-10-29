import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/sales/domain/entities/customer_refund.dart';
import 'package:mbe_ui/features/sales/presentation/refunds/refunds_filter.dart';

/// Spec 057 data-model: the "Devoluciones" list's whole view state lives in
/// the URL.
void main() {
  group('RefundsFilter.fromQuery', () {
    test('no facets decode to all-off, page 0', () {
      final filter = RefundsFilter.fromQuery(const ListQuery());

      expect(filter.status, isNull);
      expect(filter.customerId, isNull);
      expect(filter.salesOrderId, isNull);
      expect(filter.pageIndex, 0);
      expect(filter.activeFilterCount, 0);
      expect(filter.isNarrowed, isFalse);
    });

    test('decodes status, customer, order and page', () {
      final query = const ListQuery(pageIndex: 2)
          .withFacet('status', 'draft')
          .withFacet('customer', '10653')
          .withFacet('order', '42');

      final filter = RefundsFilter.fromQuery(query);

      expect(filter.status, RefundStatus.draft);
      expect(filter.customerId, 10653);
      expect(filter.salesOrderId, 42);
      expect(filter.pageIndex, 2);
    });

    test('every status round-trips through its wire name', () {
      for (final status in RefundStatus.values) {
        final filter = RefundsFilter.fromQuery(
          const ListQuery().withFacet('status', status.wireName),
        );
        expect(filter.status, status);
      }
    });

    test('an unknown status or a non-numeric id is dropped, not thrown on', () {
      final filter = RefundsFilter.fromQuery(
        const ListQuery()
            .withFacet('status', 'bogus')
            .withFacet('customer', 'abc')
            .withFacet('order', 'x1'),
      );

      expect(filter.status, isNull);
      expect(filter.customerId, isNull);
      expect(filter.salesOrderId, isNull);
      expect(filter.isNarrowed, isFalse);
    });

    test('counts each active facet once', () {
      int count(ListQuery q) => RefundsFilter.fromQuery(q).activeFilterCount;

      expect(count(const ListQuery().withFacet('status', 'completed')), 1);
      expect(count(const ListQuery().withFacet('customer', '5')), 1);
      expect(count(const ListQuery().withFacet('order', '9')), 1);
      expect(
        count(
          const ListQuery()
              .withFacet('status', 'draft')
              .withFacet('customer', '5')
              .withFacet('order', '9'),
        ),
        3,
      );
    });

    test('the page does not count as a filter', () {
      final filter = RefundsFilter.fromQuery(const ListQuery(pageIndex: 4));

      expect(filter.isNarrowed, isFalse);
    });
  });
}
