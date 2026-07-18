import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:mbe_ui/features/pricing/presentation/pricing_formatters.dart';

void main() {
  // DateFormat requires locale symbol data to be initialized before use —
  // normally done once at app startup (main.dart); a plain unit test has no
  // app startup to piggyback on, so it's done here instead.
  setUpAll(() async {
    await initializeDateFormatting();
  });

  group('PricingFormatters.currency', () {
    test('formats a whole-number price as MXN with two decimals', () {
      expect(PricingFormatters.currency('120'), r'$120.00');
    });

    test('formats a price with cents', () {
      expect(PricingFormatters.currency('120.5'), r'$120.50');
    });

    test('formats zero', () {
      expect(PricingFormatters.currency('0'), r'$0.00');
    });

    test('a high-precision decimal string is not truncated to the wrong '
        'magnitude — the integer part and thousands grouping survive '
        '(spec Edge Cases — "Very small or large decimals")', () {
      final formatted = PricingFormatters.currency('1234567.891234');
      expect(formatted, r'$1,234,567.89');
      // Never collapse a large value to scientific notation.
      expect(formatted, isNot(contains('e')));
      expect(formatted, isNot(contains('E')));
    });

    test('a non-numeric value falls back to zero rather than crashing', () {
      expect(PricingFormatters.currency('not-a-number'), r'$0.00');
    });
  });

  group('PricingFormatters.percent', () {
    test('formats a standard margin', () {
      expect(PricingFormatters.percent('0.40'), '40%');
    });

    test('formats zero', () {
      expect(PricingFormatters.percent('0'), '0%');
    });

    test('a high-precision margin still resolves to a sane whole-number '
        'percentage rather than an empty/garbled string', () {
      final formatted = PricingFormatters.percent('0.123456789');
      expect(formatted, isNotEmpty);
      expect(formatted, endsWith('%'));
    });
  });

  group('PricingFormatters.date', () {
    test('formats a DateTime as a short locale-aware date', () {
      final formatted = PricingFormatters.date(DateTime(2026, 7, 17));
      expect(formatted, isNotEmpty);
      // Locale-aware date rendering, not a raw ISO string.
      expect(formatted, isNot(contains('T')));
    });
  });
}
