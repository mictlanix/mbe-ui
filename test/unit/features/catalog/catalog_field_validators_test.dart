import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/features/catalog/domain/catalog_field_validators.dart';

void main() {
  group('CatalogFieldValidators.isRequiredNonEmpty', () {
    test('rejects empty and whitespace-only strings', () {
      expect(CatalogFieldValidators.isRequiredNonEmpty(''), isFalse);
      expect(CatalogFieldValidators.isRequiredNonEmpty('   '), isFalse);
    });

    test('accepts a non-empty value', () {
      expect(CatalogFieldValidators.isRequiredNonEmpty('ACME'), isTrue);
    });
  });

  group('CatalogFieldValidators.isOptionalNonNegativeDecimal (creditLimit)', () {
    test('accepts an empty value — creditLimit is optional on create', () {
      expect(CatalogFieldValidators.isOptionalNonNegativeDecimal(''), isTrue);
    });

    test('accepts zero and a positive decimal when present', () {
      expect(
        CatalogFieldValidators.isOptionalNonNegativeDecimal('0'),
        isTrue,
      );
      expect(
        CatalogFieldValidators.isOptionalNonNegativeDecimal('1000.50'),
        isTrue,
      );
    });

    test('rejects a negative amount when present', () {
      expect(
        CatalogFieldValidators.isOptionalNonNegativeDecimal('-1'),
        isFalse,
      );
    });

    test('rejects non-numeric input when present', () {
      expect(
        CatalogFieldValidators.isOptionalNonNegativeDecimal('abc'),
        isFalse,
      );
    });

    test('does not reject or truncate a high-precision decimal string', () {
      expect(
        CatalogFieldValidators.isOptionalNonNegativeDecimal('1000.123456'),
        isTrue,
      );
    });
  });

  group('CatalogFieldValidators.isOptionalNonNegativeInteger (creditDays/enrollNumber)', () {
    test('accepts an empty value', () {
      expect(CatalogFieldValidators.isOptionalNonNegativeInteger(''), isTrue);
    });

    test('accepts zero and a positive integer when present', () {
      expect(
        CatalogFieldValidators.isOptionalNonNegativeInteger('0'),
        isTrue,
      );
      expect(
        CatalogFieldValidators.isOptionalNonNegativeInteger('30'),
        isTrue,
      );
    });

    test('rejects a negative integer when present', () {
      expect(
        CatalogFieldValidators.isOptionalNonNegativeInteger('-1'),
        isFalse,
      );
    });

    test('rejects a non-integer decimal when present', () {
      expect(
        CatalogFieldValidators.isOptionalNonNegativeInteger('1.5'),
        isFalse,
      );
    });
  });
}
