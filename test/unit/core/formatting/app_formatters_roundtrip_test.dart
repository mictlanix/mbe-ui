import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/config/formatting_settings.dart';
import 'package:mbe_ui/core/formatting/app_formatters.dart';

/// Property test for contracts/formatting-surface.md's guarantee:
/// `parseX(field.x(v)) == v` for every value the domain can hold
/// (research.md R8, spec 028 FR-006).
///
/// **Numeric equality, not string equality.** `field.rate('0.1600')` returns
/// `'16'`; `parseRate('16')` returns `'0.16'` — a different *string* than the
/// original `'0.1600'`, but the same *value*. Every case below asserts via
/// [Decimal] comparison for this reason.
///
/// **"Stored precision exceeds displayed precision" means the wire
/// *string* is padded with trailing zeros, not that the value carries
/// genuine significant digits beyond what's shown** (research.md R8;
/// spec.md Edge Cases: a value truly exceeding display precision is shown
/// rounded, but the caller must resend the untouched original — a UI-level
/// rule this formatter cannot itself guarantee). Every generated value below
/// is padded with extra trailing zeros for exactly this reason: it exercises
/// a wire string longer than the field's own precision while keeping the
/// invariant genuinely true.
void main() {
  const field = FieldFormatters(settings: FormattingSettings());

  Decimal d(String s) => Decimal.parse(s);

  /// Base values at a spread of magnitudes and genuine precisions, each
  /// padded with 1-5 extra trailing zeros to simulate mbe-api's wire format
  /// (e.g. `"50.0000000"` for a value that is genuinely just `50.00`), plus
  /// the base's own canonical form unpadded.
  List<String> paddedVariants(String base) {
    final withDecimalPoint = base.contains('.') ? base : '$base.0';
    return [
      base,
      for (var pad = 1; pad <= 5; pad++) '$withDecimalPoint${'0' * pad}',
    ];
  }

  group('field.price / parsePrice round-trip', () {
    for (final base in ['0', '0.5', '3', '16.99', '1234.5', '50', '7.1']) {
      for (final variant in paddedVariants(base)) {
        test('"$variant" round-trips to the same value', () {
          final formatted = field.price(variant);
          final parsedBack = field.parsePrice(formatted);
          expect(parsedBack, isNotNull, reason: 'price output must parse back');
          expect(
            d(parsedBack!),
            d(variant),
            reason: '$variant → "$formatted" → $parsedBack must be the same value',
          );
        });
      }
    }
  });

  group('field.rate / parseRate round-trip', () {
    for (final base in ['0', '0.16', '0.075', '1', '0.3333', '0.005']) {
      for (final variant in paddedVariants(base)) {
        test('"$variant" round-trips to the same value', () {
          final formatted = field.rate(variant);
          final parsedBack = field.parseRate(formatted);
          expect(parsedBack, isNotNull, reason: 'rate output must parse back');
          expect(
            d(parsedBack!),
            d(variant),
            reason: '$variant → "$formatted" → $parsedBack must be the same value',
          );
        });
      }
    }
  });

  group('field.quantity / parseQuantity round-trip', () {
    for (final base in ['0', '1', '3', '2.5', '100', '0.25']) {
      for (final variant in paddedVariants(base)) {
        test('"$variant" round-trips to the same value', () {
          final formatted = field.quantity(variant);
          final parsedBack = field.parseQuantity(formatted);
          expect(parsedBack, isNotNull, reason: 'quantity output must parse back');
          expect(
            d(parsedBack!),
            d(variant),
            reason: '$variant → "$formatted" → $parsedBack must be the same value',
          );
        });
      }
    }
  });
}
