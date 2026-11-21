import 'package:flutter/material.dart';

import 'package:mbe_ui/core/branding/brand_definition.dart';
import 'package:mbe_ui/core/branding/semantic_colors.dart';

/// Exact logo navy from the Casa Maestra design system. Logo and brand blocks
/// only; it is also `primary` in the light theme.
const casaMaestraNavy = Color(0xFF00325F);

/// Exact logo red. Logo and brand blocks only: white text on it is 3.84:1, so
/// it is never behind small text and never fills a control (spec 077 FR-011).
const casaMaestraRed = Color(0xFFFF2014);

/// Casa Maestra (`BRAND_ID=xbe.cm`, spec 077). Every value is transcribed from
/// the Casa Maestra design system's `tokens.json`; `on-success` and
/// `on-warning`, which it leaves out, are white on light and its darkest
/// same-hue ink on dark. Colors the design system does not name stay
/// seed-derived through `ColorScheme.fromSeed` (constitution §V).
const casaMaestraBrand = BrandDefinition(
  id: 'xbe.cm',
  displayName: 'Casa Maestra',
  seedColor: casaMaestraNavy,
  light: BrandColors(
    primary: Color(0xFF00325F),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFD5E3F8),
    onPrimaryContainer: Color(0xFF001B3A),
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    surface: Color(0xFFF6F8FB),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFFFFFFF),
    surfaceContainer: Color(0xFFEEF2F7),
    surfaceContainerHigh: Color(0xFFE9EDF3),
    surfaceContainerHighest: Color(0xFFE1E7EF),
    onSurface: Color(0xFF0F1C2E),
    onSurfaceVariant: Color(0xFF46536A),
    outline: Color(0xFF76839A),
    outlineVariant: Color(0xFFC9D1DC),
    scrim: Color(0xFF000000),
  ),
  dark: BrandColors(
    primary: Color(0xFFA9C7F0),
    onPrimary: Color(0xFF002D55),
    primaryContainer: Color(0xFF1C4675),
    onPrimaryContainer: Color(0xFFD5E3F8),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF0C1420),
    surfaceContainerLowest: Color(0xFF080E18),
    surfaceContainerLow: Color(0xFF121B28),
    surfaceContainer: Color(0xFF162030),
    surfaceContainerHigh: Color(0xFF1E2837),
    surfaceContainerHighest: Color(0xFF283344),
    onSurface: Color(0xFFE2E8F1),
    onSurfaceVariant: Color(0xFFB9C3D3),
    outline: Color(0xFF8994A8),
    outlineVariant: Color(0xFF334055),
    scrim: Color(0xFF000000),
  ),
  lightSemantic: SemanticColors(
    accent: Color(0xFFD7190F),
    onAccent: Color(0xFFFFFFFF),
    accentContainer: Color(0xFFFFDAD4),
    onAccentContainer: Color(0xFF4A0500),
    success: Color(0xFF1B6B3A),
    onSuccess: Color(0xFFFFFFFF),
    successContainer: Color(0xFFC9EFD3),
    onSuccessContainer: Color(0xFF00210D),
    warning: Color(0xFF855300),
    onWarning: Color(0xFFFFFFFF),
    warningContainer: Color(0xFFFFDDB3),
    onWarningContainer: Color(0xFF2A1700),
  ),
  darkSemantic: SemanticColors(
    accent: Color(0xFFFF8E7E),
    onAccent: Color(0xFF3B0400),
    accentContainer: Color(0xFF7A1209),
    onAccentContainer: Color(0xFFFFDAD4),
    success: Color(0xFF7FD69A),
    onSuccess: Color(0xFF00210D),
    successContainer: Color(0xFF0F4A26),
    onSuccessContainer: Color(0xFFC9EFD3),
    warning: Color(0xFFFFB95E),
    onWarning: Color(0xFF2A1700),
    warningContainer: Color(0xFF5A3A00),
    onWarningContainer: Color(0xFFFFDDB3),
  ),
  typography: BrandTypography(_casaMaestraTextTheme),
  lockupAsset: 'assets/brand/xbe.cm/casa-maestra-logo.png',
  lockupReversedAsset: 'assets/brand/xbe.cm/casa-maestra-logo-reversed.png',
  markAsset: 'assets/brand/xbe.cm/casa-maestra-mark.png',
  loginPane: LoginPaneStyle(
    followsTheme: true,
    // One bar in the theme's accent color (red on light, soft red on dark).
    accentBars: [null],
  ),
);

/// Bitter for display, headline and title; Roboto (bundled as `BrandRoboto`,
/// so the platform Roboto the default brand uses is not replaced) for body and
/// label. Sizes, line heights, weights and tracking are the design system's
/// type table, so a step off the M3 ramp cannot slip in.
TextTheme _casaMaestraTextTheme(TextTheme base) {
  const bitter = 'Bitter';
  const roboto = 'BrandRoboto';
  TextStyle? style(
    TextStyle? from,
    String family,
    double size,
    double line,
    FontWeight weight,
    double tracking,
  ) => from?.copyWith(
    fontFamily: family,
    fontSize: size,
    height: line / size,
    fontWeight: weight,
    letterSpacing: tracking,
  );
  const w400 = FontWeight.w400;
  const w500 = FontWeight.w500;
  const w600 = FontWeight.w600;
  const w700 = FontWeight.w700;
  return base.copyWith(
    displayLarge: style(base.displayLarge, bitter, 57, 64, w700, -0.75),
    displayMedium: style(base.displayMedium, bitter, 45, 52, w700, -0.5),
    displaySmall: style(base.displaySmall, bitter, 36, 44, w700, -0.25),
    headlineLarge: style(base.headlineLarge, bitter, 32, 40, w700, -0.25),
    headlineMedium: style(base.headlineMedium, bitter, 28, 36, w600, 0),
    headlineSmall: style(base.headlineSmall, bitter, 24, 32, w600, 0),
    titleLarge: style(base.titleLarge, bitter, 22, 28, w600, 0),
    titleMedium: style(base.titleMedium, bitter, 16, 24, w600, 0.15),
    titleSmall: style(base.titleSmall, bitter, 14, 20, w600, 0.1),
    bodyLarge: style(base.bodyLarge, roboto, 16, 24, w400, 0.5),
    bodyMedium: style(base.bodyMedium, roboto, 14, 20, w400, 0.25),
    bodySmall: style(base.bodySmall, roboto, 12, 16, w400, 0.4),
    labelLarge: style(base.labelLarge, roboto, 14, 20, w500, 0.1),
    labelMedium: style(base.labelMedium, roboto, 12, 16, w500, 0.5),
    labelSmall: style(base.labelSmall, roboto, 11, 16, w500, 0.5),
  );
}
