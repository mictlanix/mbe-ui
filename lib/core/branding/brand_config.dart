import 'package:flutter/foundation.dart';

/// Per-deployment brand/flavor descriptor, resolved at build time from
/// `--dart-define` values (constitution §V; spec 010 US3). The first brand
/// seam in the app: consumed by `HomeWelcome` for the Home welcome asset and
/// display name. No brand values are hardcoded in `app/theme/`.
@immutable
class BrandConfig {
  const BrandConfig({required this.displayName, this.welcomeAsset});

  /// Deployment display name (e.g. "CASA MAESTRA"). Defaults to the app name.
  final String displayName;

  /// Asset path of the deployment's welcome image, or `null` to fall back to
  /// the bundled default placeholder.
  final String? welcomeAsset;

  bool get hasWelcomeAsset => welcomeAsset != null && welcomeAsset!.isNotEmpty;

  /// Build-time source. Values are injected via `--dart-define`, e.g.
  /// `--dart-define=BRAND_DISPLAY_NAME="CASA MAESTRA"
  ///  --dart-define=BRAND_WELCOME_ASSET=assets/branding/casa_maestra.png`.
  factory BrandConfig.fromEnvironment() {
    return BrandConfig(
      displayName: const String.fromEnvironment(
        'BRAND_DISPLAY_NAME',
        defaultValue: 'Mictlanix Business Essentials',
      ),
      welcomeAsset: const bool.hasEnvironment('BRAND_WELCOME_ASSET')
          ? const String.fromEnvironment('BRAND_WELCOME_ASSET')
          : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is BrandConfig &&
      other.displayName == displayName &&
      other.welcomeAsset == welcomeAsset;

  @override
  int get hashCode => Object.hash(displayName, welcomeAsset);
}
