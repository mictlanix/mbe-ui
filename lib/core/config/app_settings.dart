import 'package:flutter/material.dart';

import 'package:mbe_ui/core/branding/brand_config.dart';
import 'package:mbe_ui/core/config/formatting_settings.dart';
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
    required this.formatting,
    this.inputDebounce = const Duration(milliseconds: 300),
    this.quantityCommitDebounce = const Duration(milliseconds: 400),
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

  /// Deployment-level value-formatting configuration (spec 028 FR-010) — date
  /// patterns, currency symbol/code, and decimal-digit counts. Never
  /// reachable from the UI and never a per-user preference; consumed
  /// exclusively through `formattersProvider` (`lib/core/formatting/`).
  final FormattingSettings formatting;

  /// The delay a search-style field (one that waits after the user stops
  /// typing before issuing a request) waits before calling out
  /// (`INPUT_DEBOUNCE_MS`, spec 036 FR-028). Consumed via
  /// `inputDebounceProvider` by `CatalogEntityPicker` and
  /// `ProductSearchField` — neither keeps its own hardcoded delay.
  final Duration inputDebounce;

  /// The delay a quantity-commit field (one that waits after the user stops
  /// adjusting a value before saving it) waits before saving
  /// (`QUANTITY_COMMIT_DEBOUNCE_MS`, spec 036 FR-028). Consumed via
  /// `quantityCommitDebounceProvider` by `QuantityStepperController` and its
  /// two hosts (`sale_line_editing.dart`, `destination_card.dart`) — a
  /// separate setting from [inputDebounce] because the two categories serve
  /// different purposes and already default to different delays
  /// (research.md R13).
  final Duration quantityCommitDebounce;

  /// Whether [customerId] is the generic walk-in customer
  /// ([posDefaultCustomerId]). The one, shared way to answer that question
  /// (spec 036 data-model.md §5) — the Sales Order customer picker and the
  /// POS fulfillment-mode gate both call this rather than each comparing
  /// against [posDefaultCustomerId] independently.
  bool isGenericCustomer(int customerId) => customerId == posDefaultCustomerId;

  static const _defaultLocaleEnv = String.fromEnvironment(
    'DEFAULT_LOCALE',
    defaultValue: 'es_MX',
  );
  static const _inputDebounceMsEnv = String.fromEnvironment(
    'INPUT_DEBOUNCE_MS',
    defaultValue: '300',
  );
  static const _quantityCommitDebounceMsEnv = String.fromEnvironment(
    'QUANTITY_COMMIT_DEBOUNCE_MS',
    defaultValue: '400',
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
      formatting: FormattingSettings.fromEnvironment(),
      inputDebounce: _parseDebounceMs(_inputDebounceMsEnv, 300),
      quantityCommitDebounce: _parseDebounceMs(_quantityCommitDebounceMsEnv, 400),
    );
  }

  /// Parses a millisecond debounce duration. Falls back to [fallbackMs] on
  /// anything that isn't a non-negative integer — a malformed build flag
  /// must not brick app startup, mirroring
  /// `FormattingSettings._parseDigits`.
  static Duration _parseDebounceMs(String value, int fallbackMs) {
    final parsed = int.tryParse(value);
    if (parsed == null || parsed < 0) return Duration(milliseconds: fallbackMs);
    return Duration(milliseconds: parsed);
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
