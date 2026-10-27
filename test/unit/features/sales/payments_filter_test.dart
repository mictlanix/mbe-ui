import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payments_filter.dart';

/// Spec 054 data-model.md §4: the Pagos list's whole view state lives in the
/// URL, and there is no default date range (research R6).
void main() {
  group('PaymentsFilter.fromQuery', () {
    test('no facets decode to all-null, page 0 — no default dates', () {
      final filter = PaymentsFilter.fromQuery(const ListQuery());
      expect(filter.customerId, isNull);
      expect(filter.dateFrom, isNull);
      expect(filter.dateTo, isNull);
      expect(filter.methodCode, isNull);
      expect(filter.verified, isNull);
      expect(filter.cashSessionId, isNull);
      expect(filter.pageIndex, 0);
      expect(filter.hasActiveFilters, isFalse);
    });

    test('decodes every facet', () {
      final query = const ListQuery(pageIndex: 3)
          .withFacet('customer', '12')
          .withFacet('date-from', '2026-08-01')
          .withFacet('date-to', '2026-08-05')
          .withFacet('method', '4')
          .withFacet('verified', 'true')
          .withFacet('cash-session', '77');
      final filter = PaymentsFilter.fromQuery(query);
      expect(filter.customerId, 12);
      expect(filter.dateFrom, DateTime(2026, 8, 1));
      expect(filter.dateTo, DateTime(2026, 8, 5));
      expect(filter.methodCode, 4);
      expect(filter.verified, isTrue);
      expect(filter.cashSessionId, 77);
      expect(filter.pageIndex, 3);
    });

    test('verified is tri-state: true, false and absent', () {
      PaymentsFilter decode(String? value) => PaymentsFilter.fromQuery(
        const ListQuery().withFacet('verified', value),
      );
      expect(decode('true').verified, isTrue);
      expect(decode('false').verified, isFalse);
      expect(decode(null).verified, isNull);
      expect(decode('maybe').verified, isNull);
    });

    test('an unparseable numeric facet degrades to null', () {
      final query = const ListQuery()
          .withFacet('customer', 'abc')
          .withFacet('method', '')
          .withFacet('cash-session', '1.5');
      final filter = PaymentsFilter.fromQuery(query);
      expect(filter.customerId, isNull);
      expect(filter.methodCode, isNull);
      expect(filter.cashSessionId, isNull);
    });

    test('an inverted date range is dropped as a whole', () {
      final filter = PaymentsFilter.fromQuery(
        const ListQuery()
            .withFacet('date-from', '2026-08-10')
            .withFacet('date-to', '2026-08-01'),
      );
      expect(filter.dateFrom, isNull);
      expect(filter.dateTo, isNull);
    });

    test('a half-open range is dropped as a whole', () {
      final onlyFrom = PaymentsFilter.fromQuery(
        const ListQuery().withFacet('date-from', '2026-08-01'),
      );
      final onlyTo = PaymentsFilter.fromQuery(
        const ListQuery().withFacet('date-to', '2026-08-01'),
      );
      expect(onlyFrom.dateFrom, isNull);
      expect(onlyFrom.dateTo, isNull);
      expect(onlyTo.dateFrom, isNull);
      expect(onlyTo.dateTo, isNull);
    });

    test('a same-day range is kept', () {
      final filter = PaymentsFilter.fromQuery(
        const ListQuery()
            .withFacet('date-from', '2026-08-01')
            .withFacet('date-to', '2026-08-01'),
      );
      expect(filter.dateFrom, DateTime(2026, 8, 1));
      expect(filter.dateTo, DateTime(2026, 8, 1));
    });

    test('a malformed or nonexistent date is rejected, not rolled over', () {
      for (final bad in ['2026-02-31', '2026-8-1', 'yesterday', '']) {
        final filter = PaymentsFilter.fromQuery(
          const ListQuery()
              .withFacet('date-from', bad)
              .withFacet('date-to', '2026-08-05'),
        );
        expect(filter.dateFrom, isNull, reason: bad);
        expect(filter.dateTo, isNull, reason: bad);
      }
    });
  });

  group('date facet round trip', () {
    test('encodePaymentsDateFacet pads and survives fromQuery', () {
      expect(encodePaymentsDateFacet(DateTime(2026, 3, 7)), '2026-03-07');
      final filter = PaymentsFilter.fromQuery(
        const ListQuery()
            .withFacet(
              'date-from',
              encodePaymentsDateFacet(DateTime(2026, 3, 7)),
            )
            .withFacet(
              'date-to',
              encodePaymentsDateFacet(DateTime(2026, 12, 31)),
            ),
      );
      expect(filter.dateFrom, DateTime(2026, 3, 7));
      expect(filter.dateTo, DateTime(2026, 12, 31));
    });
  });

  group('activeFilterCount', () {
    test('counts each facet once, a date range as one', () {
      final filter = PaymentsFilter(
        customerId: 1,
        dateFrom: DateTime(2026, 8, 1),
        dateTo: DateTime(2026, 8, 5),
        methodCode: 4,
        verified: false,
        cashSessionId: 9,
      );
      expect(filter.activeFilterCount, 5);
      expect(filter.hasActiveFilters, isTrue);
    });

    test('verified=false counts (it is a facet, not "off")', () {
      expect(const PaymentsFilter(verified: false).activeFilterCount, 1);
    });

    test('the page index is not a filter', () {
      const filter = PaymentsFilter(pageIndex: 4);
      expect(filter.activeFilterCount, 0);
      expect(filter.hasActiveFilters, isFalse);
    });
  });

  group('scope (US3, FR-002, FR-012)', () {
    final allQuery = const ListQuery()
        .withFacet('scope', 'all')
        .withFacet('customer', '12')
        .withFacet('date-from', '2026-08-01')
        .withFacet('date-to', '2026-08-05')
        .withFacet('method', '4')
        .withFacet('verified', 'true')
        .withFacet('cash-session', '77');

    test('defaults to the facility scope', () {
      expect(
        PaymentsFilter.fromQuery(const ListQuery()).scope,
        PaymentsScope.facility,
      );
    });

    test('scope=all is honoured only with canSearchAllFacilities', () {
      expect(
        PaymentsFilter.fromQuery(allQuery, canSearchAllFacilities: true).scope,
        PaymentsScope.allFacilities,
      );
      expect(PaymentsFilter.fromQuery(allQuery).scope, PaymentsScope.facility);
      expect(
        PaymentsFilter.fromQuery(allQuery, canSearchAllFacilities: false).scope,
        PaymentsScope.facility,
      );
    });

    test('a user who cannot search all keeps their facility-only facets and '
        'no reference', () {
      final filter = PaymentsFilter.fromQuery(allQuery.copyWith(search: 'REF'));
      expect(filter.methodCode, 4);
      expect(filter.verified, isTrue);
      expect(filter.cashSessionId, 77);
      expect(filter.reference, isNull);
    });

    test('facility-only facets are ignored in the all scope; customer and '
        'dates stay', () {
      final filter = PaymentsFilter.fromQuery(
        allQuery,
        canSearchAllFacilities: true,
      );
      expect(filter.methodCode, isNull);
      expect(filter.verified, isNull);
      expect(filter.cashSessionId, isNull);
      expect(filter.customerId, 12);
      expect(filter.dateFrom, DateTime(2026, 8, 1));
      expect(filter.dateTo, DateTime(2026, 8, 5));
    });

    test('the reference is the trimmed search text, in the all scope only', () {
      final all = const ListQuery(
        search: '  REF-9  ',
      ).withFacet('scope', 'all');
      expect(
        PaymentsFilter.fromQuery(all, canSearchAllFacilities: true).reference,
        'REF-9',
      );
      expect(
        PaymentsFilter.fromQuery(
          const ListQuery(search: 'REF-9'),
          canSearchAllFacilities: true,
        ).reference,
        isNull,
      );
    });

    test('a blank search is no reference', () {
      final all = const ListQuery(search: '   ').withFacet('scope', 'all');
      expect(
        PaymentsFilter.fromQuery(all, canSearchAllFacilities: true).reference,
        isNull,
      );
    });
  });

  group('activeFilterCount and isNarrowed with the reference', () {
    test('the reference is not a counted facet', () {
      const filter = PaymentsFilter(
        scope: PaymentsScope.allFacilities,
        customerId: 1,
        reference: 'REF',
      );
      expect(filter.activeFilterCount, 1);
    });

    test('only valid facets count in the all scope', () {
      final filter = PaymentsFilter.fromQuery(
        const ListQuery(search: 'REF')
            .withFacet('scope', 'all')
            .withFacet('method', '4')
            .withFacet('verified', 'false')
            .withFacet('cash-session', '3')
            .withFacet('customer', '1'),
        canSearchAllFacilities: true,
      );
      expect(filter.activeFilterCount, 1);
    });

    test('isNarrowed includes the reference, hasActiveFilters does not', () {
      const onlyReference = PaymentsFilter(
        scope: PaymentsScope.allFacilities,
        reference: 'REF',
      );
      expect(onlyReference.hasActiveFilters, isFalse);
      expect(onlyReference.isNarrowed, isTrue);
      expect(const PaymentsFilter().isNarrowed, isFalse);
      expect(const PaymentsFilter(verified: true).isNarrowed, isTrue);
    });
  });

  group('paymentsQueryForScope (FR-012)', () {
    final loaded = const ListQuery(search: 'REF', pageIndex: 3)
        .withFacet('customer', '12')
        .withFacet('date-from', '2026-08-01')
        .withFacet('date-to', '2026-08-05')
        .withFacet('method', '4')
        .withFacet('verified', 'true')
        .withFacet('cash-session', '77');

    test('to all: keeps customer and dates, sets scope, drops the rest', () {
      final q = paymentsQueryForScope(loaded, PaymentsScope.allFacilities);
      expect(q.facet('scope'), 'all');
      expect(q.facet('customer'), '12');
      expect(q.facet('date-from'), '2026-08-01');
      expect(q.facet('date-to'), '2026-08-05');
      expect(q.facet('method'), isNull);
      expect(q.facet('verified'), isNull);
      expect(q.facet('cash-session'), isNull);
      expect(q.search, isEmpty);
      expect(q.pageIndex, 0);
    });

    test('to facility: clears the scope, keeps customer and dates, drops the '
        'search and page', () {
      final q = paymentsQueryForScope(
        loaded.withFacet('scope', 'all'),
        PaymentsScope.facility,
      );
      expect(q.facet('scope'), isNull);
      expect(q.facet('customer'), '12');
      expect(q.facet('date-from'), '2026-08-01');
      expect(q.facet('date-to'), '2026-08-05');
      expect(q.facet('method'), isNull);
      expect(q.search, isEmpty);
      expect(q.pageIndex, 0);
    });

    test('an empty query stays empty apart from the scope', () {
      expect(
        paymentsQueryForScope(
          const ListQuery(),
          PaymentsScope.facility,
        ).toUri('/p').toString(),
        '/p',
      );
      expect(
        paymentsQueryForScope(
          const ListQuery(),
          PaymentsScope.allFacilities,
        ).toUri('/p').queryParameters,
        {'scope': 'all'},
      );
    });
  });
}
