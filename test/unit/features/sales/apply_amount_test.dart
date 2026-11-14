import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/features/sales/presentation/payments/apply_payment_dialog.dart';

/// Spec 059 FR-007 (T010): what may be applied to an order.
void main() {
  group('applyCeiling', () {
    test('is the smaller of the order balance and the payment remainder', () {
      expect(applyCeiling('900.00', '1500.00'), '900.00');
      expect(applyCeiling('2400.00', '1500.00'), '1500.00');
    });

    test('compares as decimals, not as text', () {
      expect(applyCeiling('900.00', '1000.00'), '900.00');
      expect(applyCeiling('9.5', '10.25'), '9.5');
    });

    test('equal figures give either one', () {
      expect(applyCeiling('500.00', '500.00'), '500.00');
    });
  });

  group('applyAmountIssue', () {
    test('accepts anything above zero up to the ceiling, the ceiling too', () {
      expect(applyAmountIssue('0.01', '900.00'), isNull);
      expect(applyAmountIssue('450', '900.00'), isNull);
      expect(applyAmountIssue('900.00', '900.00'), isNull);
      expect(applyAmountIssue(' 900 ', '900.00'), isNull);
    });

    test('refuses an amount above the ceiling', () {
      expect(applyAmountIssue('900.01', '900.00'), ApplyAmountIssue.tooHigh);
      expect(applyAmountIssue('1200', '900.00'), ApplyAmountIssue.tooHigh);
    });

    test('refuses zero, negatives, blanks and text', () {
      for (final text in ['0', '0.00', '-5', '', '  ', 'abc', '1,5', '9.0.0']) {
        expect(
          applyAmountIssue(text, '900.00'),
          ApplyAmountIssue.invalid,
          reason: '"$text"',
        );
      }
    });

    test('refuses a fraction of a cent', () {
      expect(applyAmountIssue('10.005', '900.00'), ApplyAmountIssue.invalid);
    });
  });
}
