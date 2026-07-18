import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/domain/currency.dart';

void main() {
  group('Currency.fromValue', () {
    test('maps 0/1/2 to mxn/usd/eur', () {
      expect(Currency.fromValue(0), Currency.mxn);
      expect(Currency.fromValue(1), Currency.usd);
      expect(Currency.fromValue(2), Currency.eur);
    });

    test('returns null for an unrecognized code', () {
      expect(Currency.fromValue(99), isNull);
    });
  });
}
