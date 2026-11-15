import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/domain/payment_method.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/sales/presentation/payment_verification/payment_verification_filter.dart';

void main() {
  PaymentVerificationFilter read(String query) =>
      PaymentVerificationFilter.fromQuery(
        ListQuery.fromUri(Uri.parse('/sales/payment-verification$query')),
      );

  test('the default method is Transfer (spec 060 R3)', () {
    expect(verificationDefaultMethodCode, PaymentMethod.eft.code);
  });

  group('the bare address is the opening state', () {
    final filter = read('');

    test('Transfer, every facility, any date, first page', () {
      expect(filter.facilityId, isNull);
      expect(filter.dateFrom, isNull);
      expect(filter.dateTo, isNull);
      expect(filter.pageIndex, 0);
      expect(filter.methodCode, PaymentMethod.eft.code);
      expect(
        filter.method,
        const VerificationMethodFilter.code(verificationDefaultMethodCode),
      );
    });

    test('the badge reads 1, because Transfer already narrows', () {
      expect(filter.activeFilterCount, 1);
    });

    test('it does not differ from the default', () {
      expect(filter.differsFromDefault, isFalse);
    });
  });

  group('method facet', () {
    test('"all" is no method filter', () {
      final filter = read('?method=all');
      expect(filter.method, const VerificationMethodFilter.all());
      expect(filter.methodCode, isNull);
      expect(filter.activeFilterCount, 0);
      expect(filter.differsFromDefault, isTrue);
    });

    test('a known code is that method', () {
      final filter = read('?method=1');
      expect(filter.methodCode, PaymentMethod.cash.code);
      expect(filter.differsFromDefault, isTrue);
    });

    test('junk reads as Transfer', () {
      expect(read('?method=junk').methodCode, PaymentMethod.eft.code);
    });

    test('a code the app has no method for reads as Transfer', () {
      expect(read('?method=7').methodCode, PaymentMethod.eft.code);
    });
  });

  group('facility and dates', () {
    test('a facility is read and counted', () {
      final filter = read('?facility=4');
      expect(filter.facilityId, 4);
      expect(filter.activeFilterCount, 2);
      expect(filter.differsFromDefault, isTrue);
    });

    test('an unparsable facility is dropped', () {
      expect(read('?facility=north').facilityId, isNull);
    });

    test('a date range is read and counts as one facet', () {
      final filter = read('?date-from=2026-11-01&date-to=2026-11-13');
      expect(filter.dateFrom, DateTime(2026, 11, 1));
      expect(filter.dateTo, DateTime(2026, 11, 13));
      expect(filter.activeFilterCount, 2);
      expect(filter.differsFromDefault, isTrue);
    });

    test('a half-open range is dropped', () {
      final filter = read('?date-from=2026-11-01');
      expect(filter.dateFrom, isNull);
      expect(filter.dateTo, isNull);
    });

    test('a reversed range is dropped', () {
      final filter = read('?date-from=2026-11-13&date-to=2026-11-01');
      expect(filter.dateFrom, isNull);
      expect(filter.dateTo, isNull);
    });

    test('a date that does not exist is dropped', () {
      final filter = read('?date-from=2026-02-31&date-to=2026-03-05');
      expect(filter.dateFrom, isNull);
    });
  });

  group('rejected facet (mbe-api#310)', () {
    test('true and false are read, counted and written back', () {
      for (final value in [true, false]) {
        final filter = read('?rejected=$value');
        expect(filter.rejected, value);
        expect(filter.activeFilterCount, 2);
        expect(filter.differsFromDefault, isTrue);
        expect(filter.toQuery().facet('rejected'), '$value');
      }
    });

    test('absent or junk is both', () {
      expect(read('').rejected, isNull);
      expect(read('?rejected=maybe').rejected, isNull);
    });
  });

  test('the page index is read', () {
    // The address counts pages from 1; the index from 0.
    expect(read('?page=3').pageIndex, 2);
  });

  group('toQuery', () {
    test('leaves the default method out of the address', () {
      expect(const PaymentVerificationFilter().toQuery().facets, isEmpty);
    });

    test('writes "all" for no method filter', () {
      final query = const PaymentVerificationFilter(
        method: VerificationMethodFilter.all(),
      ).toQuery();
      expect(query.facet('method'), 'all');
    });

    test('round-trips every field', () {
      final filter = PaymentVerificationFilter(
        facilityId: 4,
        dateFrom: DateTime(2026, 11, 1),
        dateTo: DateTime(2026, 11, 13),
        method: const VerificationMethodFilter.code(1),
        pageIndex: 2,
      );
      expect(PaymentVerificationFilter.fromQuery(filter.toQuery()), filter);
    });

    test('round-trips "all"', () {
      const filter = PaymentVerificationFilter(
        method: VerificationMethodFilter.all(),
      );
      expect(PaymentVerificationFilter.fromQuery(filter.toQuery()), filter);
    });
  });
}
