import 'package:flutter/material.dart';

/// The app's four accessibility text-size levels (spec 027 FR-019,
/// constitution §V) — a user's overall text-size preference, applied
/// app-wide via [ComposedTextScaler]. `normal` is the default and is the
/// identity composition (research.md R1): at this level the rendered app is
/// byte-identical to before this feature, which is what keeps every existing
/// golden/screenshot baseline valid with no re-baselining.
enum TextSizeLevel {
  small(0.9),
  normal(1.0),
  large(1.15),
  extraLarge(1.3);

  const TextSizeLevel(this.factor);

  /// The multiplier applied to a font size before the platform's own
  /// [TextScaler] scales it (research.md R1) — never a replacement for the
  /// platform scaler, so a user who already scaled text at the OS level
  /// keeps that scaling with this level's factor applied on top.
  final double factor;
}

/// A [TextScaler] that composes [level]'s factor with [platform]'s own
/// scaling, rather than replacing it (spec 027 research.md R1):
/// `effective.scale(size) == platform.scale(size * level.factor)`.
///
/// At [TextSizeLevel.normal] (factor `1.0`) this is the identity — the
/// widget tree renders exactly as it did before this feature existed, which
/// is why every golden/screenshot baseline needs no re-baselining at the
/// default level. Delegating to [platform]'s own `scale` (rather than
/// multiplying `platform.textScaleFactor`, which is deprecated) keeps
/// non-linear platform scalers (e.g. Android 14+) correct.
@immutable
class ComposedTextScaler extends TextScaler {
  const ComposedTextScaler({required this.platform, required this.level});

  final TextScaler platform;
  final TextSizeLevel level;

  @override
  double scale(double fontSize) => platform.scale(fontSize * level.factor);

  // Overriding this abstract (but deprecated) getter is required by
  // `TextScaler` itself, not a use of the deprecated API by choice.
  @override
  // ignore: deprecated_member_use
  double get textScaleFactor => platform.textScaleFactor * level.factor;

  @override
  bool operator ==(Object other) =>
      other is ComposedTextScaler &&
      other.platform == platform &&
      other.level == level;

  @override
  int get hashCode => Object.hash(platform, level);
}
