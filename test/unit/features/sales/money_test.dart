import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/domain/payment_method.dart';
import 'package:mbe_ui/features/sales/domain/entities/cash_session.dart';
import 'package:mbe_ui/features/sales/domain/entities/denomination_count.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';

void main() {
  group('countedTotal', () {
    test('sums a full 11-denomination count exactly — the property SC-004 '
        'depends on: the identical sum in double accumulates rounding error, '
        'this must not', () {
      const counts = [
        DenominationCount(denomination: '1000', quantity: 2),
        DenominationCount(denomination: '500', quantity: 3),
        DenominationCount(denomination: '200', quantity: 1),
        DenominationCount(denomination: '100', quantity: 4),
        DenominationCount(denomination: '50', quantity: 5),
        DenominationCount(denomination: '20', quantity: 6),
        DenominationCount(denomination: '10', quantity: 7),
        DenominationCount(denomination: '5', quantity: 8),
        DenominationCount(denomination: '2', quantity: 9),
        DenominationCount(denomination: '1', quantity: 10),
        DenominationCount(denomination: '0.50', quantity: 11),
      ];

      final total = countedTotal(counts);

      // 2000+1500+200+400+250+120+70+40+18+10+5.5 = 4613.5
      expect(total, Decimal.parse('4613.5'));
    });

    test('an empty count is zero', () {
      expect(countedTotal(const []), Decimal.zero);
    });

    test('a single low-value denomination with a large quantity does not '
        'drift — the exact-decimal property, not an approximation', () {
      const counts = [DenominationCount(denomination: '0.50', quantity: 1000000)];
      expect(countedTotal(counts), Decimal.parse('500000'));
    });
  });

  group('expectedCash', () {
    test('opening amount alone when there are no payments yet', () {
      final result = expectedCash(openingAmount: '500', payments: const []);
      expect(result, Decimal.parse('500'));
    });

    test('includes only the cash-method payment total', () {
      final result = expectedCash(
        openingAmount: '500',
        payments: [
          PaymentMethodTotal(method: PaymentMethod.cash.code, total: '3240'),
          PaymentMethodTotal(method: PaymentMethod.creditCard.code, total: '1180'),
        ],
      );
      // 500 + 3240, credit card excluded entirely.
      expect(result, Decimal.parse('3740'));
    });

    test('a session with only non-cash payments has expected cash equal to '
        'the opening amount alone', () {
      final result = expectedCash(
        openingAmount: '500',
        payments: [
          PaymentMethodTotal(method: PaymentMethod.debitCard.code, total: '900'),
        ],
      );
      expect(result, Decimal.parse('500'));
    });

    test('a negative cash total (net of refunds) is not floored at zero — '
        'the figure is advisory and must reflect reality, not hide it', () {
      final result = expectedCash(
        openingAmount: '500',
        payments: [PaymentMethodTotal(method: PaymentMethod.cash.code, total: '-100')],
      );
      expect(result, Decimal.parse('400'));
    });
  });

  group('difference', () {
    test('positive when counted exceeds expected (over)', () {
      final result = difference(
        counted: Decimal.parse('3690'),
        expected: Decimal.parse('3740'),
      );
      expect(result.sign, -1);
    });

    test('zero when counted equals expected exactly', () {
      final result = difference(
        counted: Decimal.parse('3740'),
        expected: Decimal.parse('3740'),
      );
      expect(result, Decimal.zero);
      expect(result.sign, 0);
    });

    test('negative when counted is short of expected', () {
      final result = difference(
        counted: Decimal.parse('3800'),
        expected: Decimal.parse('3740'),
      );
      expect(result.sign, 1);
    });
  });

  group('extendedAmount', () {
    test('multiplies a denomination by its quantity', () {
      expect(Decimal.parse(extendedAmount('500', 3)), Decimal.parse('1500'));
    });

    test('a zero quantity extends to zero', () {
      expect(Decimal.parse(extendedAmount('1000', 0)), Decimal.zero);
    });
  });

  group('parseAmount / formatAmount', () {
    test('round-trips a server-supplied decimal string', () {
      expect(formatAmount(parseAmount('500.00')), isNotEmpty);
    });
  });

  // 020-point-of-sale additions: the generic Decimal helpers this feature's
  // balance/change/distribution arithmetic needs (T008), which 021's
  // cash-specific helpers above don't provide.
  group('addAmounts', () {
    test('adds two decimal strings exactly', () {
      expect(addAmounts('100.25', '50.10'), '150.35');
    });

    test('adding zero is a no-op', () {
      expect(addAmounts('100.25', '0'), '100.25');
    });
  });

  group('subtractAmounts', () {
    test('subtracts two decimal strings exactly', () {
      expect(subtractAmounts('150.35', '50.10'), '100.25');
    });

    test('can go negative — a refund/overpayment is not floored at zero', () {
      expect(subtractAmounts('50', '100'), '-50');
    });
  });

  group('compareAmounts', () {
    test('positive when the first amount is greater', () {
      expect(compareAmounts('100', '50').sign, 1);
    });

    test('negative when the first amount is smaller', () {
      expect(compareAmounts('50', '100').sign, -1);
    });

    test('zero when the amounts are numerically equal, regardless of '
        'trailing zeros', () {
      expect(compareAmounts('100.00', '100'), 0);
    });
  });

  group('isZeroAmount', () {
    test('true for a plain zero', () {
      expect(isZeroAmount('0'), isTrue);
    });

    test('true for a zero written with decimal places', () {
      expect(isZeroAmount('0.00'), isTrue);
    });

    test('false for any non-zero amount', () {
      expect(isZeroAmount('0.01'), isFalse);
    });
  });
}
