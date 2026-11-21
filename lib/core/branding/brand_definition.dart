import 'package:flutter/material.dart';

import 'package:mbe_ui/core/branding/semantic_colors.dart';

/// One deployment brand, defined in reviewed code (spec 077, constitution §V).
///
/// A brand may set only its color roles, typography and logo assets (plus its
/// display name and login-pane style). Spacing, shape, elevation, density and
/// breakpoints are product tokens in `core/design/` and are deliberately not
/// fields here (FR-005). Values are transcribed from the brand's source, never
/// derived by algorithm.
@immutable
class BrandDefinition {
  const BrandDefinition({
    required this.id,
    required this.displayName,
    required this.seedColor,
    required this.light,
    required this.dark,
    required this.typography,
    required this.lockupAsset,
    required this.markAsset,
    required this.loginPane,
    this.lockupReversedAsset,
    this.lightInk,
    this.lightSemantic,
    this.darkSemantic,
  });

  /// Registry key: `xbe` (the default) or `xbe.cm`.
  final String id;

  final String displayName;

  /// Seed for `ColorScheme.fromSeed`. Every role the brand does not pin is
  /// derived from it (constitution §V).
  final Color seedColor;

  final BrandColors light;
  final BrandColors dark;
  final BrandTypography typography;

  /// Full lockup (icon + wordmark), for the login pane.
  final String lockupAsset;

  /// Lockup recolored for dark grounds. `null` means [lockupAsset] is used in
  /// both themes (XBE).
  final String? lockupReversedAsset;

  /// Isologo mark, for the navigation header.
  final String markAsset;

  final LoginPaneStyle loginPane;

  /// Foreground stand-in for `primary` on light surfaces, when the brand's
  /// `primary` fails contrast as text (XBE gold). `null` when `primary` is
  /// already a safe foreground.
  final Color? lightInk;

  /// Pinned accent/success/warning roles. `null` derives them from the scheme
  /// (accent from tertiary, shared neutral success/warning).
  final SemanticColors? lightSemantic;
  final SemanticColors? darkSemantic;

  BrandColors colorsFor(Brightness b) => b == Brightness.light ? light : dark;

  SemanticColors? semanticFor(Brightness b) =>
      b == Brightness.light ? lightSemantic : darkSemantic;
}

/// The `ColorScheme` roles a brand pins on top of `fromSeed`. A `null` role is
/// left to `fromSeed`, so XBE's 20 pins and Casa Maestra's longer list use the
/// same type.
@immutable
class BrandColors {
  const BrandColors({
    this.primary,
    this.onPrimary,
    this.primaryContainer,
    this.onPrimaryContainer,
    this.secondary,
    this.onSecondary,
    this.tertiary,
    this.onTertiary,
    this.error,
    this.onError,
    this.errorContainer,
    this.onErrorContainer,
    this.surface,
    this.onSurface,
    this.onSurfaceVariant,
    this.outline,
    this.outlineVariant,
    this.surfaceContainerLowest,
    this.surfaceContainerLow,
    this.surfaceContainer,
    this.surfaceContainerHigh,
    this.surfaceContainerHighest,
    this.scrim,
  });

  final Color? primary;
  final Color? onPrimary;
  final Color? primaryContainer;
  final Color? onPrimaryContainer;
  final Color? secondary;
  final Color? onSecondary;
  final Color? tertiary;
  final Color? onTertiary;
  final Color? error;
  final Color? onError;
  final Color? errorContainer;
  final Color? onErrorContainer;
  final Color? surface;
  final Color? onSurface;
  final Color? onSurfaceVariant;
  final Color? outline;
  final Color? outlineVariant;
  final Color? surfaceContainerLowest;
  final Color? surfaceContainerLow;
  final Color? surfaceContainer;
  final Color? surfaceContainerHigh;
  final Color? surfaceContainerHighest;
  final Color? scrim;

  /// `ColorScheme.fromSeed` with this brand's pins as per-role overrides —
  /// never a replacement for it (constitution §V).
  ColorScheme toScheme(Color seed, Brightness brightness) =>
      ColorScheme.fromSeed(
        seedColor: seed,
        brightness: brightness,
        dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        secondary: secondary,
        onSecondary: onSecondary,
        tertiary: tertiary,
        onTertiary: onTertiary,
        error: error,
        onError: onError,
        errorContainer: errorContainer,
        onErrorContainer: onErrorContainer,
        surface: surface,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
        outline: outline,
        outlineVariant: outlineVariant,
        surfaceContainerLowest: surfaceContainerLowest,
        surfaceContainerLow: surfaceContainerLow,
        surfaceContainer: surfaceContainer,
        surfaceContainerHigh: surfaceContainerHigh,
        surfaceContainerHighest: surfaceContainerHighest,
        scrim: scrim,
      );
}

/// Maps a brand's families, weights and metrics onto the base Material
/// `TextTheme`. A function, so each brand states exactly which styles it
/// overrides and the rest stay on the base theme.
@immutable
class BrandTypography {
  const BrandTypography(this.apply);

  final TextTheme Function(TextTheme base) apply;
}

/// How the login branding pane is painted.
@immutable
class LoginPaneStyle {
  const LoginPaneStyle({
    required this.followsTheme,
    required this.accentBars,
    this.background,
    this.title,
    this.subtitle,
  });

  /// `true`: background and text come from the active theme (surface,
  /// onSurface, onSurfaceVariant) and the pane switches with it. `false`: the
  /// fixed colors below apply in both themes (XBE's always-dark pane).
  final bool followsTheme;

  final Color? background;
  final Color? title;
  final Color? subtitle;

  /// The accent bars under the lockup; empty draws none. A `null` entry is
  /// drawn in the theme's accent color.
  final List<Color?> accentBars;
}
