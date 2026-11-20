import 'package:flutter/material.dart';

import 'package:mbe_ui/core/branding/brand_definition.dart';
import 'package:mbe_ui/core/branding/xbe_palette.dart';

/// The default XBE brand (spec 019). Every value here is *moved* from
/// [XbePalette], `AppTheme` and `BrandConfig`, not changed: the default build
/// must stay pixel-identical (spec 077 FR-004). Accent, success and warning
/// are not pinned — they derive from the scheme (see `SemanticColors`).
const xbeBrand = BrandDefinition(
  id: 'xbe',
  displayName: 'Mictlanix Business Essentials',
  seedColor: XbePalette.gold,
  light: BrandColors(
    primary: XbePalette.gold,
    onPrimary: XbePalette.lightOnPrimary,
    primaryContainer: XbePalette.lightPrimaryContainer,
    onPrimaryContainer: XbePalette.lightOnPrimaryContainer,
    secondary: XbePalette.lightSecondary,
    onSecondary: XbePalette.lightOnSecondary,
    tertiary: XbePalette.orange,
    onTertiary: XbePalette.lightOnTertiary,
    error: XbePalette.lightError,
    onError: XbePalette.lightOnError,
    errorContainer: XbePalette.lightErrorContainer,
    onErrorContainer: XbePalette.lightOnErrorContainer,
    surface: XbePalette.lightSurface,
    onSurface: XbePalette.lightOnSurface,
    onSurfaceVariant: XbePalette.lightOnSurfaceVariant,
    outline: XbePalette.lightOutline,
    outlineVariant: XbePalette.lightOutlineVariant,
    surfaceContainerLowest: XbePalette.lightSurfaceContainerLowest,
    surfaceContainerLow: XbePalette.lightSurfaceContainerLow,
    surfaceContainer: XbePalette.lightSurfaceContainer,
  ),
  dark: BrandColors(
    primary: XbePalette.gold,
    onPrimary: XbePalette.darkOnPrimary,
    primaryContainer: XbePalette.darkPrimaryContainer,
    onPrimaryContainer: XbePalette.darkOnPrimaryContainer,
    secondary: XbePalette.wordmarkGray,
    onSecondary: XbePalette.darkOnSecondary,
    tertiary: XbePalette.orange,
    onTertiary: XbePalette.darkOnTertiary,
    error: XbePalette.red,
    onError: XbePalette.darkOnError,
    errorContainer: XbePalette.darkErrorContainer,
    onErrorContainer: XbePalette.darkOnErrorContainer,
    surface: XbePalette.darkSurface,
    onSurface: XbePalette.darkOnSurface,
    onSurfaceVariant: XbePalette.darkOnSurfaceVariant,
    outline: XbePalette.darkOutline,
    outlineVariant: XbePalette.darkOutlineVariant,
    surfaceContainerLowest: XbePalette.darkSurfaceContainerLowest,
    surfaceContainerLow: XbePalette.darkSurfaceContainerLow,
    surfaceContainer: XbePalette.darkSurfaceContainer,
  ),
  typography: BrandTypography(_xbeTextTheme),
  lockupAsset: 'assets/brand/login_lockup.png',
  markAsset: 'assets/brand/nav_lockup.png',
  lightInk: XbePalette.goldInk,
  loginPane: LoginPaneStyle(
    followsTheme: false,
    background: XbePalette.darkSurface,
    title: XbePalette.darkOnSurface,
    subtitle: XbePalette.darkOnSurfaceVariant,
    accentBars: [XbePalette.red, XbePalette.orange, XbePalette.gold],
  ),
);

/// Display/headline/title/label roles on the bundled Archivo family (spec 019
/// FR-002); body/table roles stay on the base Material text theme (Roboto).
TextTheme _xbeTextTheme(TextTheme base) {
  const archivo = 'Archivo';
  TextStyle? brand(TextStyle? style, FontWeight weight) =>
      style?.copyWith(fontFamily: archivo, fontWeight: weight);
  return base.copyWith(
    displayLarge: brand(base.displayLarge, FontWeight.w700),
    displayMedium: brand(base.displayMedium, FontWeight.w700),
    displaySmall: brand(base.displaySmall, FontWeight.w700),
    headlineLarge: brand(base.headlineLarge, FontWeight.w600),
    headlineMedium: brand(base.headlineMedium, FontWeight.w600),
    headlineSmall: brand(base.headlineSmall, FontWeight.w600),
    titleLarge: brand(base.titleLarge, FontWeight.w600),
    titleMedium: brand(base.titleMedium, FontWeight.w600),
    titleSmall: brand(base.titleSmall, FontWeight.w600),
    labelLarge: brand(base.labelLarge, FontWeight.w600),
    labelMedium: brand(base.labelMedium, FontWeight.w600),
    labelSmall: brand(base.labelSmall, FontWeight.w600),
  );
}
