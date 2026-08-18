import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/config/app_settings.dart';
import 'package:mbe_ui/core/config/app_settings_provider.dart';
import 'package:mbe_ui/core/config/formatting_settings.dart';
import 'package:mbe_ui/core/branding/brand_config.dart';
import 'package:mbe_ui/core/design/text_scale.dart';
import 'package:mbe_ui/core/settings/user_display_preferences_controller.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';

Future<ProviderContainer> containerWith({
  Map<String, Object> prefs = const {},
  AppSettings? appSettings,
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final sharedPreferences = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      if (appSettings != null) appSettingsProvider.overrideWithValue(appSettings),
    ],
  );
  return container;
}

void main() {
  group('UserDisplayPreferencesController defaults (spec 027 FR-016/017/018/019)', () {
    test('with nothing stored: system theme, normal text size, no locale override', () async {
      final container = await containerWith();
      addTearDown(container.dispose);

      final state = container.read(userDisplayPreferencesControllerProvider);
      expect(state.themeMode, ThemeMode.system);
      expect(state.textSizeLevel, TextSizeLevel.normal);
      expect(state.localeOverride, isNull);
    });
  });

  group('Every setting applies immediately (FR-020) and persists (FR-021)', () {
    test('setThemeMode updates state synchronously and persists', () async {
      final container = await containerWith();
      addTearDown(container.dispose);
      final controller = container.read(userDisplayPreferencesControllerProvider.notifier);

      final future = controller.setThemeMode(ThemeMode.dark);
      // State is updated before the persistence write completes — no
      // restart/re-login required to see the effect (FR-020).
      expect(container.read(userDisplayPreferencesControllerProvider).themeMode, ThemeMode.dark);
      await future;

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('theme_mode'), 'dark');
    });

    test('setTextSizeLevel updates state synchronously and persists', () async {
      final container = await containerWith();
      addTearDown(container.dispose);
      final controller = container.read(userDisplayPreferencesControllerProvider.notifier);

      await controller.setTextSizeLevel(TextSizeLevel.extraLarge);

      expect(
        container.read(userDisplayPreferencesControllerProvider).textSizeLevel,
        TextSizeLevel.extraLarge,
      );
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('text_size_level'), 'extraLarge');
    });

    test('setLocaleOverride persists and null clears the stored key', () async {
      final container = await containerWith();
      addTearDown(container.dispose);
      final controller = container.read(userDisplayPreferencesControllerProvider.notifier);

      await controller.setLocaleOverride(const Locale('en', 'US'));
      expect(
        container.read(userDisplayPreferencesControllerProvider).localeOverride,
        const Locale('en', 'US'),
      );
      var prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('locale_override'), 'en_US');

      await controller.setLocaleOverride(null);
      expect(container.read(userDisplayPreferencesControllerProvider).localeOverride, isNull);
      prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('locale_override'), isFalse);
    });
  });

  group('Corrupt/unreadable stored preferences fall back silently (FR-022)', () {
    test('an unrecognized text_size_level value falls back to normal', () async {
      final container = await containerWith(prefs: {'text_size_level': 'gigantic'});
      addTearDown(container.dispose);

      expect(
        container.read(userDisplayPreferencesControllerProvider).textSizeLevel,
        TextSizeLevel.normal,
      );
    });

    test('an unrecognized theme_mode value falls back to system', () async {
      final container = await containerWith(prefs: {'theme_mode': 'not-a-mode'});
      addTearDown(container.dispose);

      expect(
        container.read(userDisplayPreferencesControllerProvider).themeMode,
        ThemeMode.system,
      );
    });

    test('an empty locale_override value is treated as absent', () async {
      final container = await containerWith(prefs: {'locale_override': ''});
      addTearDown(container.dispose);

      expect(container.read(userDisplayPreferencesControllerProvider).localeOverride, isNull);
    });
  });

  group('The pre-existing theme_mode key is reused verbatim (FR-017)', () {
    test('a value stored before this feature by ThemeModeController still restores', () async {
      // ThemeModeController used to store ThemeMode.name directly under
      // 'theme_mode' — this must keep reading the exact same key/format.
      final container = await containerWith(prefs: {'theme_mode': 'light'});
      addTearDown(container.dispose);

      expect(container.read(userDisplayPreferencesControllerProvider).themeMode, ThemeMode.light);
    });
  });

  group('resolvedLocaleProvider (spec 027 FR-018, data-model.md §4)', () {
    test('with no override, resolves to the deployment default when supported', () async {
      final container = await containerWith(
        appSettings: const AppSettings(
          apiBaseUrl: 'x',
          photosBaseUrl: 'x',
          posDefaultCustomerId: 1,
          brand: BrandConfig(displayName: 'X'),
          defaultLocale: Locale('en', 'US'),
          formatting: FormattingSettings(),
        ),
      );
      addTearDown(container.dispose);

      expect(container.read(resolvedLocaleProvider), const Locale('en', 'US'));
    });

    test('a user override takes precedence over the deployment default', () async {
      final container = await containerWith(prefs: {'locale_override': 'en_US'});
      addTearDown(container.dispose);

      expect(container.read(resolvedLocaleProvider), const Locale('en', 'US'));
    });

    test('an unsupported deployment default falls back to the first supported locale', () async {
      final container = await containerWith(
        appSettings: const AppSettings(
          apiBaseUrl: 'x',
          photosBaseUrl: 'x',
          posDefaultCustomerId: 1,
          brand: BrandConfig(displayName: 'X'),
          defaultLocale: Locale('xx', 'YY'),
          formatting: FormattingSettings(),
        ),
      );
      addTearDown(container.dispose);

      // AppLocalizations.supportedLocales is [en, es] — 'xx' matches
      // neither, so the app must not crash and must fall back rather than
      // rendering untranslated keys (spec.md Edge Cases).
      expect(container.read(resolvedLocaleProvider).languageCode, isIn(['en', 'es']));
    });
  });
}
