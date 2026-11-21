import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/branding/brand_config.dart';
import 'package:mbe_ui/core/branding/brand_config_provider.dart';
import 'package:mbe_ui/core/branding/brand_ink.dart';
import 'package:mbe_ui/core/branding/semantic_colors.dart';

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
      textTheme: brand.definition.typography.apply(
        ThemeData(colorScheme: colorScheme, useMaterial3: true).textTheme,
      ),
      extensions: [
        BrandInk.forBrand(brand, colorScheme),
        _semanticColors(brand, colorScheme),
      ],
    );
  }

  /// A deployment that overrides the seed gets a wholly seed-derived scheme
  /// with none of the brand's pins (FR-007 isolation); otherwise the brand's
  /// pinned roles go through `fromSeed`'s own per-role overrides.
  static ColorScheme _scheme(BrandConfig brand, Brightness brightness) {
    if (!brand.usesDefaultPalette) {
      return ColorScheme.fromSeed(
        seedColor: brand.seedColor,
        brightness: brightness,
        dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
      );
    }
    return brand.definition
        .colorsFor(brightness)
        .toScheme(brand.seedColor, brightness);
  }

  static ColorScheme _darkScheme(BrandConfig brand) =>
      _scheme(brand, Brightness.dark);

  static ColorScheme _lightScheme(BrandConfig brand) =>
      _scheme(brand, Brightness.light);

  static SemanticColors _semanticColors(
    BrandConfig brand,
    ColorScheme scheme,
  ) =>
      (brand.usesDefaultPalette
          ? brand.definition.semanticFor(scheme.brightness)
          : null) ??
      SemanticColors.fromScheme(scheme);
}

/// The active deployment's [AppTheme] (light + dark `ThemeData`), derived
/// from [brandConfigProvider] (spec 019).
final appThemeProvider = Provider<AppTheme>(
  (ref) => AppTheme.of(ref.watch(brandConfigProvider)),
);
