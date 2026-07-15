# Contract: BrandConfig + provider — `core/branding/`

The first build-time brand/flavor seam (Principle V), consumed by `HomeWelcome`.

## Types

```dart
@freezed
class BrandConfig with _$BrandConfig {
  const BrandConfig._();
  const factory BrandConfig({
    required String displayName,
    String? welcomeAsset,
  }) = _BrandConfig;

  bool get hasWelcomeAsset => welcomeAsset != null && welcomeAsset!.isNotEmpty;

  /// Build-time source: values injected via --dart-define, with defaults.
  factory BrandConfig.fromEnvironment() => const BrandConfig(
    displayName: String.fromEnvironment('BRAND_DISPLAY_NAME',
        defaultValue: 'Mictlanix Business Essentials'),
    welcomeAsset: bool.hasEnvironment('BRAND_WELCOME_ASSET')
        ? String.fromEnvironment('BRAND_WELCOME_ASSET')
        : null,
  );
}

@Riverpod(keepAlive: true)
BrandConfig brandConfig(BrandConfigRef ref) => BrandConfig.fromEnvironment();
```

## Rules

- No brand values are hardcoded in `app/theme/`; the seed color is unchanged by this feature (out of scope, research §4).
- `welcomeAsset` is an asset path bundled by the deployment; this repo ships only the default placeholder `assets/branding/default_welcome.png` (added to `pubspec.yaml` `flutter/assets`).
- The provider is overridable in tests to exercise both branded and default paths.

## Build usage (documentation)

```
flutter run --dart-define=BRAND_DISPLAY_NAME="CASA MAESTRA" \
            --dart-define=BRAND_WELCOME_ASSET=assets/branding/casa_maestra_welcome.png
```

(Per-deployment art such as the Casa Maestra logo is supplied by that deployment's build, not committed as a repo default.)

## Acceptance

1. With no `--dart-define`, `brandConfigProvider` yields `displayName == 'Mictlanix Business Essentials'`, `hasWelcomeAsset == false`.
2. Overriding the provider with a `welcomeAsset` makes `hasWelcomeAsset == true` and drives `HomeWelcome`'s branded branch (see home-welcome contract).
