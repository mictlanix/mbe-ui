import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/formatting/percent_input.dart';

void main() {
  group('PercentInput.validate', () {
    test('refuses empty and non-numeric text as invalid', () {
      expect(PercentInput.validate(''), PercentInputError.invalid);
      expect(PercentInput.validate('   '), PercentInputError.invalid);
      expect(PercentInput.validate('abc'), PercentInputError.invalid);
    });

    test('refuses values outside 0-100', () {
      expect(PercentInput.validate('-1'), PercentInputError.outOfRange);
      expect(PercentInput.validate('101'), PercentInputError.outOfRange);
      expect(PercentInput.validate('100.01'), PercentInputError.outOfRange);
    });

    test('refuses more decimals than allowed (default 6)', () {
      expect(PercentInput.validate('1.1234567'), PercentInputError.tooPrecise);
      expect(
        PercentInput.validate('0.00001', maxDecimals: 4),
        PercentInputError.tooPrecise,
      );
    });

    test('accepts valid percentages', () {
      for (final ok in ['0', '100', '2.5', '0.000001', '1.123456', ' 7 ']) {
        expect(PercentInput.validate(ok), isNull, reason: ok);
      }
      expect(PercentInput.validate('100', maxDecimals: 4), isNull);
    });
  });

  group('PercentInput.parse', () {
    test('returns the fraction', () {
      expect(PercentInput.parse('2.5', maxDecimals: 4), Decimal.parse('0.025'));
      expect(
        PercentInput.parse('0.0125', maxDecimals: 4),
        Decimal.parse('0.000125'),
      );
      expect(PercentInput.parse('100', maxDecimals: 4), Decimal.one);
    });

    test('returns null when refused', () {
      expect(PercentInput.parse('0.00001', maxDecimals: 4), isNull);
      expect(PercentInput.parse('100.01', maxDecimals: 4), isNull);
      expect(PercentInput.parse(''), isNull);
      expect(PercentInput.parse('abc'), isNull);
      expect(PercentInput.parse('-1'), isNull);
    });
  });
}
