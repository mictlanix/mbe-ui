import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/config/formatting_settings.dart';
import 'package:mbe_ui/core/formatting/app_formatters.dart';

void main() {
  const field = FieldFormatters(settings: FormattingSettings());

  group('field.price / parsePrice (contracts/formatting-surface.md)', () {
    test('renders at the configured currency decimal digits', () {
      expect(field.price('50.0000000'), '50.00');
    });

    test('parsePrice reads its own output back (numeric, not string, equality '
        '— Decimal.toString() drops the trailing zero "50.00" carries)', () {
      final parsed = field.parsePrice('50.00');
      expect(parsed, isNotNull);
      expect(Decimal.parse(parsed!), Decimal.parse('50.00'));
    });

    test('parsePrice returns null for unparseable input', () {
      expect(field.parsePrice('not-a-number'), isNull);
    });
  });

  group('field.rate / parseRate (contracts/formatting-surface.md)', () {
    test('renders the stored rate as a bare percentage, no rounding', () {
      expect(field.rate('0.1600'), '16');
      expect(field.rate('0.075'), '7.5');
    });

    test('parseRate is the inverse: "16" → "0.16"', () {
      expect(field.parseRate('16'), '0.16');
    });

    test('parseRate returns null for unparseable input — parsePercentAsRate\'s existing contract', () {
      expect(field.parseRate('abc'), isNull);
    });
  });

  group('field.quantity / parseQuantity', () {
    test('drops trailing zeros, matching display.quantity', () {
      expect(field.quantity('3.0000'), '3');
      expect(field.quantity('2.5000'), '2.5');
    });

    test('parseQuantity reads its own output back', () {
      expect(field.parseQuantity('3'), '3');
    });

    test('parseQuantity returns null for unparseable input', () {
      expect(field.parseQuantity('nope'), isNull);
    });
  });
}
