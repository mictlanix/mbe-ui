import 'package:flutter/material.dart';

import 'package:mbe_ui/core/branding/brand_config.dart';
import 'package:mbe_ui/core/network/dio_client.dart' as dio_client;
import 'package:mbe_ui/core/network/photo_url.dart' as photo_url;
import 'package:mbe_ui/features/sales/pos_defaults.dart' as pos_defaults;

/// The deployment's fixed, build-time configuration (spec 027 FR-001–FR-007)
/// — one documented place listing every option a deployment can set via
/// `--dart-define-from-file=.env`, consolidating what used to be four
/// scattered `String.fromEnvironment`/`int.fromEnvironment` call sites.
///
/// **Not a redirection of those call sites.** [apiBaseUrl]/[photosBaseUrl]
/// mirror the existing top-level `const` values in `dio_client.dart`/
/// `photo_url.dart` rather than re-declaring `String.fromEnvironment` a
/// second time — those constants must stay reachable as plain top-level
/// `const`s: `photosBaseUrl` defaults to `apiBaseUrl` as a compile-time
/// cross-reference (research.md R7), and `resolvePhotoUrl` is a pure
/// function called from domain-entity factories with no `ref`/DI seam to
/// carry a provider-resolved value through. [brand] is genuinely composed —
/// `BrandConfig.fromEnvironment()` is called once here and `brandConfigProvider`
/// re-points at `AppSettings.brand` (data-model.md §1.1) — since its few
/// consumers are all widgets with `ref` access.
///
/// Never mutable from the UI (FR-007) — resolved once at startup and held
/// for the life of the process via [appSettingsProvider].
@immutable
class AppSettings {
  const AppSettings({
    required this.apiBaseUrl,
    required this.photosBaseUrl,
    required this.posDefaultCustomerId,
    required this.brand,
    required this.defaultLocale,
  });

  /// mbe-api base URL. Mirrors `dio_client.dart`'s `apiBaseUrl` const.
  final String apiBaseUrl;

  /// Legacy photo virtual-root base URL. Mirrors `photo_url.dart`'s
  /// `photosBaseUrl` const, itself defaulting to [apiBaseUrl].
  final String photosBaseUrl;

  /// The walk-in customer id a new sale defaults to. Mirrors
  /// `pos_defaults.dart`'s `posDefaultCustomerId` const.
  final int posDefaultCustomerId;

  /// Per-deployment brand tokens (constitution §V) — composed unchanged.
  final BrandConfig brand;

  /// The deployment's default locale (`DEFAULT_LOCALE`, e.g. `es_MX`),
  /// falling back to `es_MX` on an unset or malformed value (FR-005) — the
  /// value a user gets before/absent a personal language override
  /// (spec 027 FR-018).
  final Locale defaultLocale;

  static const _defaultLocaleEnv = String.fromEnvironment(
    'DEFAULT_LOCALE',
    defaultValue: 'es_MX',
  );

  /// Build-time source (FR-001). Every field has a documented default
  /// (FR-004) and a malformed value falls back rather than preventing
  /// startup (FR-005) — the same rule `BrandConfig._parseSeedColor` already
  /// applies to a bad hex color.
  factory AppSettings.fromEnvironment() {
    return AppSettings(
      apiBaseUrl: dio_client.apiBaseUrl,
      photosBaseUrl: photo_url.photosBaseUrl,
      posDefaultCustomerId: pos_defaults.posDefaultCustomerId,
      brand: BrandConfig.fromEnvironment(),
      defaultLocale: _parseLocale(_defaultLocaleEnv),
    );
  }

  /// Parses a `language_COUNTRY` or `language` code (e.g. `es_MX`, `en`)
  /// into a [Locale]. Falls back to `es_MX` on anything that doesn't parse
  /// into at least a language subtag.
  static Locale _parseLocale(String code) {
    final parts = code.split(RegExp('[_-]'));
    final language = parts.isNotEmpty ? parts.first : '';
    if (language.isEmpty) return const Locale('es', 'MX');
    if (parts.length > 1 && parts[1].isNotEmpty) {
      return Locale(language, parts[1]);
    }
    return Locale(language);
  }
}
