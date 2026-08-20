import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/config/app_settings.dart';
import 'package:mbe_ui/core/config/app_settings_provider.dart';
import 'package:mbe_ui/core/config/formatting_settings.dart';
import 'package:mbe_ui/core/branding/brand_config.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';

const _settings = AppSettings(
  apiBaseUrl: 'x',
  photosBaseUrl: 'x',
  posDefaultCustomerId: 1,
  brand: BrandConfig(displayName: 'X'),
  defaultLocale: Locale('es', 'MX'),
  formatting: FormattingSettings(),
);

/// `resolvedLocaleProvider` (consumed by `formattersProvider`, research.md
/// R1) reads through `userDisplayPreferencesControllerProvider`, which needs
/// a real `SharedPreferences` instance — the same requirement
/// `user_display_preferences_controller_test.dart`'s own `containerWith`
/// helper exists to satisfy.
Future<ProviderContainer> containerWith({AppSettings appSettings = _settings}) async {
  SharedPreferences.setMockInitialValues({});
  final sharedPreferences = await SharedPreferences.getInstance();
  return ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      appSettingsProvider.overrideWithValue(appSettings),
    ],
  );
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
  });

  test('is overridable in tests (constitution §II)', () async {
    final container = await containerWith();
    addTearDown(container.dispose);

    final fmt = container.read(formattersProvider);
    expect(fmt.display.date(DateTime(2026, 8, 17)), '2026-08-17');
  });

  test('a deployment override changes every rendering it feeds (spec 028 FR-010)', () async {
    final container = await containerWith(
      appSettings: const AppSettings(
        apiBaseUrl: 'x',
        photosBaseUrl: 'x',
        posDefaultCustomerId: 1,
        brand: BrandConfig(displayName: 'X'),
        defaultLocale: Locale('es', 'MX'),
        formatting: FormattingSettings(datePattern: 'd/M/yyyy'),
      ),
    );
    addTearDown(container.dispose);

    final fmt = container.read(formattersProvider);
    expect(fmt.display.date(DateTime(2026, 8, 17)), '17/8/2026');
  });

  test(
    'resolves once per read — the same AppFormatters instance is returned '
    'until a dependency actually changes (research.md R1: not reconstructed '
    'per cell)',
    () async {
      final container = await containerWith();
      addTearDown(container.dispose);

      final first = container.read(formattersProvider);
      final second = container.read(formattersProvider);
      expect(identical(first, second), isTrue);
    },
  );

  test('a new AppFormatters is built only when appSettingsProvider changes', () async {
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();
    // updateOverrides replaces the whole list and cannot change its length
    // (ProviderContainer.updateOverrides), so both original overrides are
    // repeated here, in the original order, with only appSettingsProvider's
    // value changed.
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        appSettingsProvider.overrideWithValue(_settings),
      ],
    );
    addTearDown(container.dispose);

    final before = container.read(formattersProvider);

    container.updateOverrides([
      sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      appSettingsProvider.overrideWithValue(
        const AppSettings(
          apiBaseUrl: 'x',
          photosBaseUrl: 'x',
          posDefaultCustomerId: 1,
          brand: BrandConfig(displayName: 'X'),
          defaultLocale: Locale('es', 'MX'),
          formatting: FormattingSettings(datePattern: 'd/M/yyyy'),
        ),
      ),
    ]);

    final after = container.read(formattersProvider);
    expect(identical(before, after), isFalse);
    expect(before.display.date(DateTime(2026, 8, 17)), '2026-08-17');
    expect(after.display.date(DateTime(2026, 8, 17)), '17/8/2026');
  });
}
