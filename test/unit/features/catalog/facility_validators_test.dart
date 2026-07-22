import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/features/catalog/domain/catalog_field_validators.dart';

void main() {
  group('CatalogFieldValidators.isValidRfcShape (FR-034)', () {
    test('accepts a well-formed 12/13-char RFC', () {
      expect(CatalogFieldValidators.isValidRfcShape('AAA010101AAA'), isTrue);
      expect(CatalogFieldValidators.isValidRfcShape('XAXX010101000'), isTrue);
    });

    test('rejects an empty value', () {
      expect(CatalogFieldValidators.isValidRfcShape(''), isFalse);
      expect(CatalogFieldValidators.isValidRfcShape('   '), isFalse);
    });

    test('rejects a value longer than 13 characters', () {
      expect(
        CatalogFieldValidators.isValidRfcShape('AAA010101AAABQ'),
        isFalse,
      );
    });

    test('is shape-only — never claims the RFC is a registered issuer', () {
      // A syntactically fine but almost-certainly-unregistered RFC still
      // passes the shape check; existence is the server's call (FR-034).
      expect(CatalogFieldValidators.isValidRfcShape('ZZZ999999ZZ9'), isTrue);
    });
  });
}
