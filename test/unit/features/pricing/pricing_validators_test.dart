import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/features/pricing/domain/pricing_validators.dart';

void main() {
  group('PricingValidators.isRequiredNonEmpty', () {
    test('rejects empty and whitespace-only strings', () {
      expect(PricingValidators.isRequiredNonEmpty(''), isFalse);
      expect(PricingValidators.isRequiredNonEmpty('   '), isFalse);
    });

    test('accepts a non-empty name', () {
      expect(PricingValidators.isRequiredNonEmpty('Retail'), isTrue);
    });
  });

  group('PricingValidators.isNonNegativeDecimal (prices, FR-011)', () {
    test('accepts zero — an unpriced/free item is valid', () {
      expect(PricingValidators.isNonNegativeDecimal('0'), isTrue);
      expect(PricingValidators.isNonNegativeDecimal('0.00'), isTrue);
    });

    test('accepts a positive decimal', () {
      expect(PricingValidators.isNonNegativeDecimal('120.50'), isTrue);
    });

    test('rejects a negative amount', () {
      expect(PricingValidators.isNonNegativeDecimal('-1'), isFalse);
      expect(PricingValidators.isNonNegativeDecimal('-0.01'), isFalse);
    });

    test('rejects empty and non-numeric input', () {
      expect(PricingValidators.isNonNegativeDecimal(''), isFalse);
      expect(PricingValidators.isNonNegativeDecimal('abc'), isFalse);
    });
  });

  group(
    'PricingValidators.isOptionalNonNegativeDecimal (price list margins, FR-006)',
    () {
      test('accepts an empty value — margins are optional on create', () {
        expect(PricingValidators.isOptionalNonNegativeDecimal(''), isTrue);
      });

      test('accepts a non-negative decimal when present', () {
        expect(PricingValidators.isOptionalNonNegativeDecimal('0.40'), isTrue);
      });

      test('rejects a negative margin when present', () {
        expect(PricingValidators.isOptionalNonNegativeDecimal('-0.1'), isFalse);
      });
    },
  );

  group('PricingValidators.isPositiveDecimal (exchange rates, FR-016)', () {
    test('rejects zero — unlike prices, a rate cannot be zero', () {
      expect(PricingValidators.isPositiveDecimal('0'), isFalse);
      expect(PricingValidators.isPositiveDecimal('0.0'), isFalse);
    });

    test('accepts a positive rate', () {
      expect(PricingValidators.isPositiveDecimal('17.50'), isTrue);
    });

    test('rejects a negative rate', () {
      expect(PricingValidators.isPositiveDecimal('-17.50'), isFalse);
    });

    test('rejects empty and non-numeric input', () {
      expect(PricingValidators.isPositiveDecimal(''), isFalse);
      expect(PricingValidators.isPositiveDecimal('abc'), isFalse);
    });
  });
}
