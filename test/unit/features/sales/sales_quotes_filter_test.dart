import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/presentation/quotes/sales_quotes_list_controller.dart';

void main() {
  group('SalesQuotesFilter.fromQuery', () {
    test('decodes status, customer and salesperson facets, and search', () {
      final filter = SalesQuotesFilter.fromQuery(
        const ListQuery(
          facets: {
            'status': ['draft'],
            'customer': ['7'],
            'salesperson': ['100'],
          },
          search: 'Acme',
        ),
      );
      expect(filter.status, SaleStatus.draft);
      expect(filter.customer, 7);
      expect(filter.salesperson, 100);
      expect(filter.search, 'Acme');
    });

    test('an unrecognized status name degrades to null rather than throwing', () {
      final filter = SalesQuotesFilter.fromQuery(
        const ListQuery(facets: {'status': ['not-a-status']}),
      );
      expect(filter.status, isNull);
    });

    test('an unparseable customer/salesperson facet degrades to null', () {
      final filter = SalesQuotesFilter.fromQuery(
        const ListQuery(
          facets: {
            'customer': ['not-a-number'],
            'salesperson': ['also-not'],
          },
        ),
      );
      expect(filter.customer, isNull);
      expect(filter.salesperson, isNull);
    });

    test('everything defaults to unset for an empty query', () {
      final filter = SalesQuotesFilter.fromQuery(const ListQuery());
      expect(filter.status, isNull);
      expect(filter.customer, isNull);
      expect(filter.salesperson, isNull);
      expect(filter.search, '');
      expect(filter.pageIndex, 0);
    });
  });

  group('activeFilterCount (search excluded, per house convention)', () {
    test('zero for the default filter', () {
      final filter = SalesQuotesFilter.fromQuery(const ListQuery());
      expect(filter.activeFilterCount, 0);
      expect(filter.hasActiveFilters, isFalse);
    });

    test('counts status and customer independently', () {
      final filter = SalesQuotesFilter.fromQuery(
        const ListQuery(
          facets: {
            'status': ['draft'],
            'customer': ['7'],
          },
        ),
      );
      expect(filter.activeFilterCount, 2);
      expect(filter.hasActiveFilters, isTrue);
    });

    test('search does not count toward the badge', () {
      final filter = SalesQuotesFilter.fromQuery(
        const ListQuery(search: 'Acme'),
      );
      expect(filter.activeFilterCount, 0);
      expect(filter.hasActiveFilters, isFalse);
    });
  });
}
