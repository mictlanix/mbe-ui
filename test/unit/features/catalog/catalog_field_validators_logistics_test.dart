import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/features/catalog/domain/catalog_field_validators.dart';

void main() {
  group('CatalogFieldValidators.isRequiredNonNegativeInteger', () {
    test('rejects an empty value', () {
      expect(CatalogFieldValidators.isRequiredNonNegativeInteger(''), isFalse);
    });

    test('rejects a negative value', () {
      expect(
        CatalogFieldValidators.isRequiredNonNegativeInteger('-1'),
        isFalse,
      );
    });

    test('rejects a decimal value', () {
      expect(
        CatalogFieldValidators.isRequiredNonNegativeInteger('1.5'),
        isFalse,
      );
    });

    test('accepts zero', () {
      expect(CatalogFieldValidators.isRequiredNonNegativeInteger('0'), isTrue);
    });

    test('accepts a positive integer', () {
      expect(CatalogFieldValidators.isRequiredNonNegativeInteger('12'), isTrue);
    });
  });

  group('CatalogFieldValidators.dateNotBefore', () {
    test('rejects an expiration date before the issue date', () {
      expect(
        CatalogFieldValidators.dateNotBefore(
          DateTime(2026, 6, 1),
          DateTime(2026, 5, 1),
        ),
        isFalse,
      );
    });

    test('accepts an equal date', () {
      final date = DateTime(2026, 6, 1);
      expect(CatalogFieldValidators.dateNotBefore(date, date), isTrue);
    });

    test('accepts a later expiration date', () {
      expect(
        CatalogFieldValidators.dateNotBefore(
          DateTime(2026, 5, 1),
          DateTime(2026, 6, 1),
        ),
        isTrue,
      );
    });

    test(
      'treats a null start or end as valid (required check runs separately)',
      () {
        expect(
          CatalogFieldValidators.dateNotBefore(null, DateTime(2026, 6, 1)),
          isTrue,
        );
        expect(
          CatalogFieldValidators.dateNotBefore(DateTime(2026, 6, 1), null),
          isTrue,
        );
      },
    );
  });
}
