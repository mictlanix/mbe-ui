import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:mbe_ui/core/branding/xbe_palette.dart';

/// Per-deployment brand/flavor descriptor, resolved at build time from
/// `--dart-define` values (constitution §V; spec 010 US3; spec 019). The
/// first brand seam in the app: consumed by `HomeWelcome` for the Home
/// welcome asset and display name, and by [AppTheme]/`BrandLogo` for the
/// color scheme and logo assets. No brand values are hardcoded in
/// `app/theme/`.
@immutable
class BrandConfig {
  const BrandConfig({
    required this.displayName,
    this.welcomeAsset,
    this.seedColor = XbePalette.gold,
    this.usesDefaultPalette = true,
    this.lockupAsset = _defaultLockupAsset,
    this.markAsset = _defaultMarkAsset,
  });

  static const _defaultLockupAsset = 'assets/brand/login_lockup.png';
  static const _defaultMarkAsset = 'assets/brand/nav_lockup.png';

  /// Deployment display name (e.g. "CASA MAESTRA"). Defaults to the app name.
  final String displayName;

  /// Asset path of the deployment's welcome image, or `null` to fall back to
  /// the bundled default placeholder.
  final String? welcomeAsset;

  /// Seed color for `ColorScheme.fromSeed`. Defaults to the XBE brand gold.
  final Color seedColor;

  /// `true` when no deployment brand override is configured (i.e.
  /// `BRAND_SEED_COLOR` is unset) — gates whether the XBE brand-exact
  /// `ColorScheme` role pins apply. `false` whenever a deployment sets its
  /// own seed, even if that value happens to equal [XbePalette.gold]: an
  /// explicit override always means "derive everything from my seed,"
  /// which is what keeps FR-007's isolation guarantee unambiguous.
  final bool usesDefaultPalette;

  /// Full lockup (icon + wordmark) asset path, for the login branding pane.
  final String lockupAsset;

  /// Isologo mark asset path, for the navigation header.
  final String markAsset;

  bool get hasWelcomeAsset => welcomeAsset != null && welcomeAsset!.isNotEmpty;

  /// Build-time source. Values are injected via `--dart-define`, e.g.
  /// `--dart-define=BRAND_DISPLAY_NAME="CASA MAESTRA"
  ///  --dart-define=BRAND_WELCOME_ASSET=assets/branding/casa_maestra.png
  ///  --dart-define=BRAND_SEED_COLOR=1B5E20`.
  factory BrandConfig.fromEnvironment() {
    const seedColorHex = String.fromEnvironment('BRAND_SEED_COLOR');
    const displayName = String.fromEnvironment(
      'BRAND_DISPLAY_NAME',
      defaultValue: 'Mictlanix Business Essentials',
    );
    const welcomeAsset = bool.hasEnvironment('BRAND_WELCOME_ASSET')
        ? String.fromEnvironment('BRAND_WELCOME_ASSET')
        : null;
    const lockupAsset = String.fromEnvironment(
      'BRAND_LOCKUP_ASSET',
      defaultValue: _defaultLockupAsset,
    );
    const markAsset = String.fromEnvironment(
      'BRAND_MARK_ASSET',
      defaultValue: _defaultMarkAsset,
    );
    if (kDebugMode) {
      debugPrint(
        '[BrandConfig] BRAND_DISPLAY_NAME=$displayName '
        'BRAND_WELCOME_ASSET=$welcomeAsset '
        'BRAND_SEED_COLOR=$seedColorHex '
        'BRAND_LOCKUP_ASSET=$lockupAsset '
        'BRAND_MARK_ASSET=$markAsset',
      );
    }
    return BrandConfig(
      displayName: displayName,
      welcomeAsset: welcomeAsset,
      seedColor: _parseSeedColor(seedColorHex),
      usesDefaultPalette: !const bool.hasEnvironment('BRAND_SEED_COLOR'),
      lockupAsset: lockupAsset,
      markAsset: markAsset,
    );
  }

  /// Parses a `RRGGBB`/`#RRGGBB` hex string into a [Color]. Falls back to
  /// [XbePalette.gold] on an empty or malformed value — a malformed build
  /// flag must not brick app startup.
  static Color _parseSeedColor(String hex) {
    final cleaned = hex.startsWith('#') ? hex.substring(1) : hex;
    if (cleaned.length != 6) return XbePalette.gold;
    final value = int.tryParse(cleaned, radix: 16);
    if (value == null) return XbePalette.gold;
    return Color(0xFF000000 | value);
  }

  @override
  bool operator ==(Object other) =>
      other is BrandConfig &&
      other.displayName == displayName &&
      other.welcomeAsset == welcomeAsset &&
      other.seedColor == seedColor &&
      other.usesDefaultPalette == usesDefaultPalette &&
      other.lockupAsset == lockupAsset &&
      other.markAsset == markAsset;

  @override
  int get hashCode => Object.hash(
    displayName,
    welcomeAsset,
    seedColor,
    usesDefaultPalette,
    lockupAsset,
    markAsset,
  );
}
