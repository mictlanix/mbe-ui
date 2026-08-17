import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/config/app_settings_provider.dart';
import 'package:mbe_ui/core/design/text_scale.dart';
import 'package:mbe_ui/core/settings/user_display_preferences.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

part 'user_display_preferences_controller.g.dart';

// `theme_mode` is the pre-existing key `ThemeModeController` used — reused
// verbatim (spec 027 FR-017) so a choice already on a user's device survives
// the upgrade. `text_size_level`/`locale_override` are new.
const _themeModeKey = 'theme_mode';
const _textSizeLevelKey = 'text_size_level';
const _localeOverrideKey = 'locale_override';

/// The signed-in user's [UserDisplayPreferences], persisted via
/// `shared_preferences` and read synchronously (spec 027 research.md R5):
/// [sharedPreferencesProvider] is seeded in `main()` before `runApp`, so
/// `build()` restores a stored choice on its very first read — no async
/// gap, no flash of the default on launch (the defect the old
/// `ThemeModeController._restore()` had).
///
/// Folds `app_theme.dart`'s former `ThemeModeController` into this single
/// controller (data-model.md §3) — `app.dart` reads `themeMode` from here
/// instead.
@Riverpod(keepAlive: true)
class UserDisplayPreferencesController extends _$UserDisplayPreferencesController {
  @override
  UserDisplayPreferences build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return UserDisplayPreferences(
      themeMode: _readThemeMode(prefs),
      textSizeLevel: _readTextSizeLevel(prefs),
      localeOverride: _readLocaleOverride(prefs),
    );
  }

  /// Every setting applies immediately (FR-020) and persists synchronously
  /// (FR-021) — no separate Save step.
  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await ref.read(sharedPreferencesProvider).setString(_themeModeKey, mode.name);
  }

  Future<void> setTextSizeLevel(TextSizeLevel level) async {
    state = state.copyWith(textSizeLevel: level);
    await ref.read(sharedPreferencesProvider).setString(_textSizeLevelKey, level.name);
  }

  /// `null` clears the override — "follow system"/deployment default
  /// (FR-018).
  Future<void> setLocaleOverride(Locale? locale) async {
    state = state.copyWith(localeOverride: () => locale);
    final prefs = ref.read(sharedPreferencesProvider);
    if (locale == null) {
      await prefs.remove(_localeOverrideKey);
    } else {
      await prefs.setString(_localeOverrideKey, _encodeLocale(locale));
    }
  }

  // Unreadable/corrupt stored values fall back to the default silently
  // (FR-022) — never a startup error.

  ThemeMode _readThemeMode(SharedPreferences prefs) {
    final stored = prefs.getString(_themeModeKey);
    if (stored == null) return ThemeMode.system;
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == stored,
      orElse: () => ThemeMode.system,
    );
  }

  TextSizeLevel _readTextSizeLevel(SharedPreferences prefs) {
    final stored = prefs.getString(_textSizeLevelKey);
    if (stored == null) return TextSizeLevel.normal;
    return TextSizeLevel.values.firstWhere(
      (level) => level.name == stored,
      orElse: () => TextSizeLevel.normal,
    );
  }

  Locale? _readLocaleOverride(SharedPreferences prefs) {
    final stored = prefs.getString(_localeOverrideKey);
    if (stored == null || stored.isEmpty) return null;
    return _decodeLocale(stored);
  }
}

String _encodeLocale(Locale locale) =>
    locale.countryCode == null ? locale.languageCode : '${locale.languageCode}_${locale.countryCode}';

Locale? _decodeLocale(String code) {
  final parts = code.split('_');
  final language = parts.isNotEmpty ? parts.first : '';
  if (language.isEmpty) return null;
  if (parts.length > 1 && parts[1].isNotEmpty) return Locale(language, parts[1]);
  return Locale(language);
}

/// The locale actually applied to the app: [UserDisplayPreferences.localeOverride]
/// when set, else the deployment's [AppSettings.defaultLocale] — validated
/// against [AppLocalizations.supportedLocales] **by language code**
/// (matching Flutter's own resolution: `supportedLocales` lists bare
/// `Locale('es')`/`Locale('en')` with no country subtag, so `es_MX` is
/// "supported" by its `es` language match, and the country subtag is kept
/// for date/number formatting rather than discarded). A locale naming an
/// unsupported language falls back to the deployment default, then to
/// `supportedLocales.first` (spec 027 FR-018, Edge Cases "a locale with no
/// bundled translations").
@riverpod
Locale resolvedLocale(Ref ref) {
  final preferences = ref.watch(userDisplayPreferencesControllerProvider);
  final appSettings = ref.watch(appSettingsProvider);
  final supported = AppLocalizations.supportedLocales;

  bool isSupported(Locale locale) =>
      supported.any((l) => l.languageCode == locale.languageCode);

  final override = preferences.localeOverride;
  if (override != null && isSupported(override)) return override;
  if (isSupported(appSettings.defaultLocale)) return appSettings.defaultLocale;
  return supported.first;
}
