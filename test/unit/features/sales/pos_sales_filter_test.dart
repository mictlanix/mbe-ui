import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/sales/presentation/pos_sales_list_controller.dart';

void main() {
  group('PosSalesFilter.fromQuery — today defaulting', () {
    test(
      'two calls with the same "today" instant, at different microseconds, '
      'produce an equal filter',
      () {
        // Regression: `PosSalesListController` is watched by a @riverpod
        // family keyed on the whole `PosSalesFilter`. If `today` were used
        // at full `DateTime.now()` precision, no two calls across separate
        // widget rebuilds would ever construct an equal filter, so the
        // family would never reuse a provider instance — confirmed live: a
        // widget test pumping `PosSalesListScreen` never settled (a
        // permanent loading spinner) until `fromQuery` started truncating
        // `today` to its calendar date before use.
        final first = PosSalesFilter.fromQuery(
          const ListQuery(),
          today: DateTime(2026, 8, 10, 9, 0, 0, 0),
        );
        final second = PosSalesFilter.fromQuery(
          const ListQuery(),
          today: DateTime(2026, 8, 10, 9, 0, 0, 999),
        );
        expect(first, equals(second));
      },
    );

    test('defaults both from and to to the calendar date, time stripped', () {
      final filter = PosSalesFilter.fromQuery(
        const ListQuery(),
        today: DateTime(2026, 8, 10, 23, 59, 59, 999),
      );
      expect(filter.from, DateTime(2026, 8, 10));
      expect(filter.to, DateTime(2026, 8, 10));
      expect(filter.isToday, isTrue);
    });

    test('an explicit date-from/date-to facet overrides the default', () {
      final filter = PosSalesFilter.fromQuery(
        const ListQuery(
          facets: {'date-from': ['2026-08-01'], 'date-to': ['2026-08-05']},
        ),
        today: DateTime(2026, 8, 10),
      );
      expect(filter.from, DateTime(2026, 8, 1));
      expect(filter.to, DateTime(2026, 8, 5));
      expect(filter.isToday, isFalse);
    });

    test('an unparseable date facet degrades to today rather than throwing', () {
      final filter = PosSalesFilter.fromQuery(
        const ListQuery(facets: {'date-from': ['not-a-date']}),
        today: DateTime(2026, 8, 10),
      );
      expect(filter.from, DateTime(2026, 8, 10));
    });
  });
}
