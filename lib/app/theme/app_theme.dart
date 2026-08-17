import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/branding/brand_config.dart';
import 'package:mbe_ui/core/branding/brand_config_provider.dart';
import 'package:mbe_ui/core/branding/brand_ink.dart';
import 'package:mbe_ui/core/branding/xbe_palette.dart';

/// Light/dark `ThemeData`, both derived from the same [BrandConfig.seedColor]
/// via `ColorScheme.fromSeed` (constitution §V; spec 019 research R1/R2).
/// The XBE default palette's brand-exact role pins are applied *through*
/// `fromSeed`'s own per-role overrides — never as a replacement for it —
/// and only when [BrandConfig.usesDefaultPalette] is true, so a deployment
/// overriding the seed always gets a wholly seed-derived scheme with no
/// XBE-specific colors (FR-007 isolation).
class AppTheme {
  const AppTheme._(this.light, this.dark);

  final ThemeData light;
  final ThemeData dark;

  factory AppTheme.of(BrandConfig brand) {
    return AppTheme._(
      _buildTheme(_lightScheme(brand), Brightness.light, brand),
      _buildTheme(_darkScheme(brand), Brightness.dark, brand),
    );
  }

  static ThemeData _buildTheme(
    ColorScheme colorScheme,
    Brightness brightness,
    BrandConfig brand,
  ) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: _brandTextTheme(
        ThemeData(colorScheme: colorScheme, useMaterial3: true).textTheme,
      ),
      extensions: [BrandInk.forBrand(brand, colorScheme)],
    );
  }

  static ColorScheme _darkScheme(BrandConfig brand) {
    if (!brand.usesDefaultPalette) {
      return ColorScheme.fromSeed(
        seedColor: brand.seedColor,
        brightness: Brightness.dark,
        dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
      );
    }
    return ColorScheme.fromSeed(
      seedColor: brand.seedColor,
      brightness: Brightness.dark,
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
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
    );
  }

  static ColorScheme _lightScheme(BrandConfig brand) {
    if (!brand.usesDefaultPalette) {
      return ColorScheme.fromSeed(
        seedColor: brand.seedColor,
        dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
      );
    }
    return ColorScheme.fromSeed(
      seedColor: brand.seedColor,
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
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
    );
  }

  /// Maps display/headline/title/label roles to the bundled Archivo family
  /// (FR-002); body/table roles stay on the base Material text theme
  /// (Roboto, unchanged).
  static TextTheme _brandTextTheme(TextTheme base) {
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
}

/// The active deployment's [AppTheme] (light + dark `ThemeData`), derived
/// from [brandConfigProvider] (spec 019).
final appThemeProvider = Provider<AppTheme>(
  (ref) => AppTheme.of(ref.watch(brandConfigProvider)),
);
