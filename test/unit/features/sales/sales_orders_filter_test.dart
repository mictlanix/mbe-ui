import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/presentation/orders/sales_orders_list_controller.dart';

void main() {
  group('SalesOrdersFilter.fromQuery — the month default', () {
    test(
      'two calls with the same "today" instant, at different microseconds, '
      'produce an equal filter — the confirmed infinite-loop trap '
      '(research §R5)',
      () {
        // Regression: `SalesOrdersListController` is watched by a
        // `@riverpod` family keyed on the whole `SalesOrdersFilter`. If
        // `today` were used at full `DateTime.now()` precision, no two
        // calls across separate widget rebuilds would ever construct an
        // equal filter, so the family would never reuse a provider
        // instance — confirmed for `PosSalesFilter` (spec 023): a widget
        // test pumping the list screen never settled until `fromQuery`
        // truncated `today` to a calendar date before use.
        final first = SalesOrdersFilter.fromQuery(
          const ListQuery(),
          today: DateTime(2026, 8, 10, 9, 0, 0, 0),
          isAdministrator: false,
        );
        final second = SalesOrdersFilter.fromQuery(
          const ListQuery(),
          today: DateTime(2026, 8, 10, 9, 0, 0, 999),
          isAdministrator: false,
        );
        expect(first, equals(second));
      },
    );

    test(
      'defaults from/to to the first and last day of the calendar month '
      'containing today',
      () {
        final today = DateTime(2026, 8, 10, 23, 59, 59, 999);
        final filter = SalesOrdersFilter.fromQuery(
          const ListQuery(),
          today: today,
          isAdministrator: false,
        );

        expect(filter.from, DateTime(2026, 8, 1));
        expect(filter.to, DateTime(2026, 8, 31));
        expect(filter.isDefaultRange(today), isTrue);
      },
    );

    test('an explicit date-from/date-to facet overrides the default', () {
      final filter = SalesOrdersFilter.fromQuery(
        const ListQuery(
          facets: {
            'date-from': ['2026-08-01'],
            'date-to': ['2026-08-05'],
          },
        ),
        today: DateTime(2026, 8, 10),
        isAdministrator: false,
      );
      expect(filter.from, DateTime(2026, 8, 1));
      expect(filter.to, DateTime(2026, 8, 5));
      expect(filter.isDefaultRange(DateTime(2026, 8, 10)), isFalse);
    });

    test(
      'an unparseable date facet degrades to the month default rather than '
      'throwing',
      () {
        final filter = SalesOrdersFilter.fromQuery(
          const ListQuery(facets: {'date-from': ['not-a-date']}),
          today: DateTime(2026, 8, 10),
          isAdministrator: false,
        );
        expect(filter.from, DateTime(2026, 8, 1));
      },
    );

    test('an unrecognized status name degrades to null rather than throwing', () {
      final filter = SalesOrdersFilter.fromQuery(
        const ListQuery(facets: {'status': ['not-a-status']}),
        today: DateTime(2026, 8, 10),
        isAdministrator: false,
      );
      expect(filter.status, isNull);
    });

    test('a recognized status name decodes', () {
      final filter = SalesOrdersFilter.fromQuery(
        const ListQuery(facets: {'status': ['draft']}),
        today: DateTime(2026, 8, 10),
        isAdministrator: false,
      );
      expect(filter.status, SaleStatus.draft);
    });
  });

  group('SalesOrdersFilter.fromQuery — admin-only facets (FR-006, FR-011)', () {
    test('salesperson and facility decode when isAdministrator is true', () {
      final filter = SalesOrdersFilter.fromQuery(
        const ListQuery(
          facets: {
            'salesperson': ['100'],
            'facility': ['9'],
          },
        ),
        today: DateTime(2026, 8, 10),
        isAdministrator: true,
      );
      expect(filter.salesperson, 100);
      expect(filter.facility, 9);
    });

    test(
      'salesperson and facility are dropped for a non-administrator — '
      'whatever the URL says (the hand-edited-address edge case, SC-009)',
      () {
        final filter = SalesOrdersFilter.fromQuery(
          const ListQuery(
            facets: {
              'salesperson': ['100'],
              'facility': ['9'],
            },
          ),
          today: DateTime(2026, 8, 10),
          isAdministrator: false,
        );
        expect(filter.salesperson, isNull);
        expect(filter.facility, isNull);
      },
    );

    test('an unparseable salesperson/facility facet degrades to null', () {
      final filter = SalesOrdersFilter.fromQuery(
        const ListQuery(
          facets: {
            'salesperson': ['not-a-number'],
            'facility': ['also-not'],
          },
        ),
        today: DateTime(2026, 8, 10),
        isAdministrator: true,
      );
      expect(filter.salesperson, isNull);
      expect(filter.facility, isNull);
    });
  });

  group('activeFilterCount (search excluded)', () {
    test('zero for the default filter', () {
      final today = DateTime(2026, 8, 10);
      final filter = SalesOrdersFilter.fromQuery(
        const ListQuery(),
        today: today,
        isAdministrator: false,
      );
      expect(filter.activeFilterCount(today), 0);
    });

    test('counts a non-default range, status, salesperson and facility '
        'independently', () {
      final today = DateTime(2026, 8, 10);
      final filter = SalesOrdersFilter.fromQuery(
        const ListQuery(
          facets: {
            'date-from': ['2026-08-01'],
            'date-to': ['2026-08-01'],
            'status': ['draft'],
            'salesperson': ['100'],
            'facility': ['9'],
          },
        ),
        today: today,
        isAdministrator: true,
      );
      expect(filter.activeFilterCount(today), 4);
    });

    test('search does not count toward the badge', () {
      final today = DateTime(2026, 8, 10);
      final filter = SalesOrdersFilter.fromQuery(
        const ListQuery(search: 'Acme'),
        today: today,
        isAdministrator: false,
      );
      expect(filter.activeFilterCount(today), 0);
    });
  });
}
