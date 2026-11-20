import 'package:flutter/material.dart';

/// Brand accent plus success and warning roles that `ColorScheme` has no slot
/// for (spec 077 research R3). Every brand supplies all twelve for each
/// brightness; a theme that registers none falls back to
/// [SemanticColors.fromScheme] so a bare `ThemeData` never crashes.
///
/// Status chips read success/warning from here instead of borrowing
/// `secondary`/`tertiary` containers, and the app-bar rule reads [accent].
/// `accentContainer` is for the `promo` tone only; it must never signal an
/// error, because the Casa Maestra brand is red (spec 077 FR-015).
@immutable
class SemanticColors extends ThemeExtension<SemanticColors> {
  const SemanticColors({
    required this.accent,
    required this.onAccent,
    required this.accentContainer,
    required this.onAccentContainer,
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.warning,
    required this.onWarning,
    required this.warningContainer,
    required this.onWarningContainer,
  });

  /// A brand's own accent family, with the shared neutral success/warning
  /// values for [brightness]. The XBE brand has no success/warning in its
  /// guide, so it uses these too (research R3).
  factory SemanticColors.withAccent(
    Brightness brightness, {
    required Color accent,
    required Color onAccent,
    required Color accentContainer,
    required Color onAccentContainer,
  }) {
    final light = brightness == Brightness.light;
    return SemanticColors(
      accent: accent,
      onAccent: onAccent,
      accentContainer: accentContainer,
      onAccentContainer: onAccentContainer,
      success: light ? _lightSuccess : _darkSuccess,
      onSuccess: light ? Colors.white : _darkOnSuccess,
      successContainer: light ? _lightSuccessContainer : _darkSuccessContainer,
      onSuccessContainer: light
          ? _lightOnSuccessContainer
          : _darkOnSuccessContainer,
      warning: light ? _lightWarning : _darkWarning,
      onWarning: light ? Colors.white : _darkOnWarning,
      warningContainer: light ? _lightWarningContainer : _darkWarningContainer,
      onWarningContainer: light
          ? _lightOnWarningContainer
          : _darkOnWarningContainer,
    );
  }

  /// Accent taken from the scheme's tertiary roles (the XBE brand reserves
  /// orange for accents, spec 019 FR-009), so it adds no new XBE color.
  factory SemanticColors.fromScheme(ColorScheme scheme) =>
      SemanticColors.withAccent(
        scheme.brightness,
        accent: scheme.tertiary,
        onAccent: _readableOn(scheme.tertiary, scheme.onTertiary),
        accentContainer: scheme.tertiaryContainer,
        onAccentContainer: scheme.onTertiaryContainer,
      );

  /// [preferred] when it reads on [background] (4.5:1), else whichever of
  /// black and white reads better. XBE's pinned white-on-orange tertiary pair
  /// is 3.2:1, so its accent needs this; a seed-derived tertiary pair already
  /// passes and is kept as is.
  static Color _readableOn(Color background, Color preferred) {
    double ratio(Color a, Color b) {
      final l1 = a.computeLuminance();
      final l2 = b.computeLuminance();
      return (l1 > l2 ? l1 + 0.05 : l2 + 0.05) /
          (l1 > l2 ? l2 + 0.05 : l1 + 0.05);
    }

    if (ratio(preferred, background) >= 4.5) return preferred;
    return ratio(Colors.black, background) >= ratio(Colors.white, background)
        ? Colors.black
        : Colors.white;
  }

  final Color accent;
  final Color onAccent;
  final Color accentContainer;
  final Color onAccentContainer;
  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color onSuccessContainer;
  final Color warning;
  final Color onWarning;
  final Color warningContainer;
  final Color onWarningContainer;

  // Shared neutral status tones (the Casa Maestra design system's values).
  // `on-success` / `on-warning` are not named there: white on light, and the
  // design system's darkest same-hue ink on dark.
  static const _lightSuccess = Color(0xFF1B6B3A);
  static const _lightSuccessContainer = Color(0xFFC9EFD3);
  static const _lightOnSuccessContainer = Color(0xFF00210D);
  static const _darkSuccess = Color(0xFF7FD69A);
  static const _darkOnSuccess = Color(0xFF00210D);
  static const _darkSuccessContainer = Color(0xFF0F4A26);
  static const _darkOnSuccessContainer = Color(0xFFC9EFD3);
  static const _lightWarning = Color(0xFF855300);
  static const _lightWarningContainer = Color(0xFFFFDDB3);
  static const _lightOnWarningContainer = Color(0xFF2A1700);
  static const _darkWarning = Color(0xFFFFB95E);
  static const _darkOnWarning = Color(0xFF2A1700);
  static const _darkWarningContainer = Color(0xFF5A3A00);
  static const _darkOnWarningContainer = Color(0xFFFFDDB3);

  @override
  SemanticColors copyWith({
    Color? accent,
    Color? onAccent,
    Color? accentContainer,
    Color? onAccentContainer,
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? warning,
    Color? onWarning,
    Color? warningContainer,
    Color? onWarningContainer,
  }) => SemanticColors(
    accent: accent ?? this.accent,
    onAccent: onAccent ?? this.onAccent,
    accentContainer: accentContainer ?? this.accentContainer,
    onAccentContainer: onAccentContainer ?? this.onAccentContainer,
    success: success ?? this.success,
    onSuccess: onSuccess ?? this.onSuccess,
    successContainer: successContainer ?? this.successContainer,
    onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
    warning: warning ?? this.warning,
    onWarning: onWarning ?? this.onWarning,
    warningContainer: warningContainer ?? this.warningContainer,
    onWarningContainer: onWarningContainer ?? this.onWarningContainer,
  );

  @override
  SemanticColors lerp(SemanticColors? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return SemanticColors(
      accent: l(accent, other.accent),
      onAccent: l(onAccent, other.onAccent),
      accentContainer: l(accentContainer, other.accentContainer),
      onAccentContainer: l(onAccentContainer, other.onAccentContainer),
      success: l(success, other.success),
      onSuccess: l(onSuccess, other.onSuccess),
      successContainer: l(successContainer, other.successContainer),
      onSuccessContainer: l(onSuccessContainer, other.onSuccessContainer),
      warning: l(warning, other.warning),
      onWarning: l(onWarning, other.onWarning),
      warningContainer: l(warningContainer, other.warningContainer),
      onWarningContainer: l(onWarningContainer, other.onWarningContainer),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is SemanticColors &&
      other.accent == accent &&
      other.onAccent == onAccent &&
      other.accentContainer == accentContainer &&
      other.onAccentContainer == onAccentContainer &&
      other.success == success &&
      other.onSuccess == onSuccess &&
      other.successContainer == successContainer &&
      other.onSuccessContainer == onSuccessContainer &&
      other.warning == warning &&
      other.onWarning == onWarning &&
      other.warningContainer == warningContainer &&
      other.onWarningContainer == onWarningContainer;

  @override
  int get hashCode => Object.hash(
    accent,
    onAccent,
    accentContainer,
    onAccentContainer,
    success,
    onSuccess,
    successContainer,
    onSuccessContainer,
    warning,
    onWarning,
    warningContainer,
    onWarningContainer,
  );
}

extension SemanticColorsTheme on ThemeData {
  /// Falls back to values derived from the scheme when no [SemanticColors] is
  /// registered, so a widget test pumping a bare `ThemeData` still works.
  SemanticColors get semanticColors =>
      extension<SemanticColors>() ?? SemanticColors.fromScheme(colorScheme);
}
