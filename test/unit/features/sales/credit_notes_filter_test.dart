import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/sales/presentation/credit_notes/credit_notes_filter.dart';

/// Spec 056 data-model §7: the "Notas de crédito" list's whole view state
/// lives in the URL.
void main() {
  group('CreditNotesFilter.fromQuery', () {
    test('no facets decode to all-off, page 0', () {
      final filter = CreditNotesFilter.fromQuery(const ListQuery());

      expect(filter.customerId, isNull);
      expect(filter.openOnly, isFalse);
      expect(filter.pageIndex, 0);
      expect(filter.activeFilterCount, 0);
      expect(filter.isNarrowed, isFalse);
    });

    test('decodes the customer, the balance switch and the page', () {
      final query = const ListQuery(
        pageIndex: 2,
      ).withFacet('customer', '10653').withFacet('open', '1');

      final filter = CreditNotesFilter.fromQuery(query);

      expect(filter.customerId, 10653);
      expect(filter.openOnly, isTrue);
      expect(filter.pageIndex, 2);
    });

    test('counts each active facet once', () {
      expect(
        CreditNotesFilter.fromQuery(
          const ListQuery().withFacet('customer', '5'),
        ).activeFilterCount,
        1,
      );
      expect(
        CreditNotesFilter.fromQuery(
          const ListQuery().withFacet('open', '1'),
        ).activeFilterCount,
        1,
      );
      expect(
        CreditNotesFilter.fromQuery(
          const ListQuery().withFacet('customer', '5').withFacet('open', '1'),
        ).activeFilterCount,
        2,
      );
    });

    test('a customer that is not a number is dropped, not thrown on', () {
      final filter = CreditNotesFilter.fromQuery(
        const ListQuery().withFacet('customer', 'abc'),
      );

      expect(filter.customerId, isNull);
    });

    test('only "1" turns the balance switch on', () {
      for (final value in ['0', 'true', 'yes', '']) {
        expect(
          CreditNotesFilter.fromQuery(
            const ListQuery().withFacet('open', value),
          ).openOnly,
          isFalse,
          reason: '"$value"',
        );
      }
    });

    test('the page does not count as a filter', () {
      final filter = CreditNotesFilter.fromQuery(const ListQuery(pageIndex: 4));

      expect(filter.isNarrowed, isFalse);
    });
  });
}
