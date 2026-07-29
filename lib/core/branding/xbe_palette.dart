import 'package:flutter/material.dart';

/// XBE brand color tokens and logo placement constants (spec 019 default
/// palette), transcribed verbatim from the approved brand guide — never
/// algorithmically derived. Applied to the default build's `ColorScheme`s
/// through [ColorScheme.fromSeed]'s per-role overrides (constitution §V;
/// research R1/R2), gated by [BrandConfig.usesDefaultPalette] so a
/// deployment overriding the seed never inherits these XBE-specific values.
class XbePalette {
  const XbePalette._();

  // --- Brand hues ------------------------------------------------------

  /// Pantone 124 C — seed color and dark-scheme `primary`.
  static const gold = Color(0xFFECAB03);

  /// Pantone 165 C — `tertiary`, accent/charts only.
  static const orange = Color(0xFFEC672A);

  /// Pantone 1795 C — `error` only, never decorative (FR-009).
  static const red = Color(0xFFD8262E);

  /// Cool Gray 3 C — dark-scheme `secondary` (wordmark on dark).
  static const wordmarkGray = Color(0xFFC7C7C8);

  /// Gold used as *text/icon* foreground on light surfaces (research R2) —
  /// raw [gold] fails text contrast there; correct only as a fill (paired
  /// with [darkOnPrimary]/[lightOnPrimary]), never for text/icon color.
  static const goldInk = Color(0xFF7A5600);

  // --- Dark-scheme pins --------------------------------------------------

  static const darkOnPrimary = Color(0xFF241900);
  static const darkPrimaryContainer = Color(0xFF4B3703);
  static const darkOnPrimaryContainer = Color(0xFFFFD466);
  static const darkOnSecondary = Color(0xFF232323);
  static const darkOnTertiary = Color(0xFF2B0F00);
  static const darkOnError = Colors.white;
  static const darkErrorContainer = Color(0xFF3A1416);
  static const darkOnErrorContainer = Color(0xFFFF8F93);
  static const darkSurface = Color(0xFF14120F);
  static const darkOnSurface = Color(0xFFEFE9DF);
  static const darkOnSurfaceVariant = Color(0xFFB4ACA0);
  static const darkOutline = Color(0xFF4E473D);
  static const darkOutlineVariant = Color(0xFF332E27);
  static const darkSurfaceContainerLowest = Color(0xFF0F0D0B);
  static const darkSurfaceContainerLow = Color(0xFF1B1814);
  static const darkSurfaceContainer = Color(0xFF221E19);

  // --- Light-scheme pins (added to the design project after initial
  // planning — research R2; transcribed, not derived) ---------------------

  static const lightOnPrimary = Color(0xFF241900);
  static const lightPrimaryContainer = Color(0xFFFFE7A8);
  static const lightOnPrimaryContainer = Color(0xFF5C4000);
  static const lightSecondary = Color(0xFF5A5349);
  static const lightOnSecondary = Colors.white;
  static const lightOnTertiary = Colors.white;

  /// Pantone 1795 C adjusted for 4.6:1 contrast on white.
  static const lightError = Color(0xFFC4262E);
  static const lightOnError = Colors.white;
  static const lightErrorContainer = Color(0xFFFBDEDF);
  static const lightOnErrorContainer = Color(0xFFA31219);
  static const lightSurface = Color(0xFFFBF8F3);
  static const lightOnSurface = Color(0xFF1C1A16);
  static const lightSurfaceContainerLowest = Colors.white;
  static const lightSurfaceContainer = Color(0xFFF3EDE3);
  static const lightOnSurfaceVariant = Color(0xFF5A5349);
  static const lightOutline = Color(0xFFC4BBAC);
  static const lightOutlineVariant = Color(0xFFE3DACC);

  // --- Logo placement constants (brand guide's logo rules; FR-003/004/010) --

  static const lockupLoginWidth = 236.0;
  static const lockupMinWidth = 51.0;
  static const markMinWidth = 37.0;
  static const markNavHeight = 34.0;
  static const clearSpaceRatio = 0.08;
  static const watermarkOpacityDark = 0.07;
  static const watermarkOpacityLight = 0.06;
}
