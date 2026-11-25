import 'package:decimal/decimal.dart';

/// Why a typed percentage is refused; callers map it to their own message.
enum PercentInputError { invalid, outOfRange, tooPrecise }

/// Reads a percentage typed by a person ("2.5") as the fraction the API
/// stores (0.025). Shared so every percent field validates the same way
/// (constitution §V).
abstract final class PercentInput {
  /// The first rule [text] breaks, or `null` when it is a valid percentage
  /// from 0 to 100 with at most [maxDecimals] decimals. Empty text is
  /// [PercentInputError.invalid].
  static PercentInputError? validate(String text, {int maxDecimals = 6}) {
    final parsed = Decimal.tryParse(text.trim());
    if (parsed == null) return PercentInputError.invalid;
    if (parsed < Decimal.zero || parsed > Decimal.fromInt(100)) {
      return PercentInputError.outOfRange;
    }
    if (parsed.scale > maxDecimals) return PercentInputError.tooPrecise;
    return null;
  }

  /// [text] as a fraction ("2.5" -> 0.025), or `null` when [validate]
  /// refuses it.
  static Decimal? parse(String text, {int maxDecimals = 6}) {
    if (validate(text, maxDecimals: maxDecimals) != null) return null;
    return (Decimal.parse(text.trim()) / Decimal.fromInt(100)).toDecimal(
      scaleOnInfinitePrecision: maxDecimals + 2,
    );
  }
}
