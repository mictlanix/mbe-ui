import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/branding/brand_config.dart';
import 'package:mbe_ui/core/config/app_settings.dart';
import 'package:mbe_ui/core/config/app_settings_provider.dart';
import 'package:mbe_ui/core/config/formatting_settings.dart';
import 'package:mbe_ui/core/network/dio_client.dart';

void main() {
  group('AppSettings.fromEnvironment() defaults (spec 027 FR-004)', () {
    // fromEnvironment() itself reads compile-time --dart-define values,
    // which can't vary per test case at runtime (test/unit/core/branding/
    // brand_config_test.dart's own note on BrandConfig.fromEnvironment()).
    // With no --dart-define passed to this test run, every field must
    // reproduce today's exact rendering (FR-004: the app runs with no .env
    // at all).
    test('every field matches its documented default', () {
      final settings = AppSettings.fromEnvironment();

      expect(settings.apiBaseUrl, 'http://127.0.0.1:8000');
      expect(settings.photosBaseUrl, settings.apiBaseUrl);
      expect(settings.posDefaultCustomerId, 1);
      expect(settings.defaultLocale, const Locale('es', 'MX'));
      expect(settings.brand, const BrandConfig(displayName: 'Mictlanix Business Essentials'));
      // spec 028 FR-011: the date default is ISO, not the locale-derived
      // rendering the app used before this feature.
      expect(settings.formatting, const FormattingSettings());
    });
  });

  // AppSettings._parseLocale is private; this test mirrors its documented
  // rules exactly, the same convention brand_config_test.dart already uses
  // for BrandConfig._parseSeedColor.
  group('DEFAULT_LOCALE parsing rules (AppSettings._parseLocale)', () {
    Locale parse(String code) {
      final parts = code.split(RegExp('[_-]'));
      final language = parts.isNotEmpty ? parts.first : '';
      if (language.isEmpty) return const Locale('es', 'MX');
      if (parts.length > 1 && parts[1].isNotEmpty) {
        return Locale(language, parts[1]);
      }
      return Locale(language);
    }

    test('parses a language_COUNTRY code', () {
      expect(parse('es_MX'), const Locale('es', 'MX'));
      expect(parse('en_US'), const Locale('en', 'US'));
    });

    test('parses a language-COUNTRY (hyphenated) code', () {
      expect(parse('en-US'), const Locale('en', 'US'));
    });

    test('parses a bare language code with no country', () {
      expect(parse('en'), const Locale('en'));
    });

    test('falls back to es_MX on empty input (FR-005)', () {
      expect(parse(''), const Locale('es', 'MX'));
    });
  });

  group('appSettingsProvider (spec 027 FR-001)', () {
    test('is overridable in tests (constitution §II)', () {
      const overridden = AppSettings(
        apiBaseUrl: 'https://test.example.com',
        photosBaseUrl: 'https://photos.example.com',
        posDefaultCustomerId: 42,
        brand: BrandConfig(displayName: 'Test Brand'),
        defaultLocale: Locale('en', 'US'),
        formatting: FormattingSettings(),
      );
      final container = ProviderContainer(
        overrides: [appSettingsProvider.overrideWithValue(overridden)],
      );
      addTearDown(container.dispose);

      expect(container.read(appSettingsProvider), overridden);
    });

    // FR-003: overriding API_BASE_URL changes dioProvider's base URL and
    // nothing else — the consolidation changes where the value is read
    // from, never what a screen does with it.
    test('overriding apiBaseUrl changes dioProvider.baseUrl only', () {
      const overridden = AppSettings(
        apiBaseUrl: 'https://override.example.com',
        photosBaseUrl: 'https://override.example.com',
        posDefaultCustomerId: 1,
        brand: BrandConfig(displayName: 'X'),
        defaultLocale: Locale('es', 'MX'),
        formatting: FormattingSettings(),
      );
      final container = ProviderContainer(
        overrides: [appSettingsProvider.overrideWithValue(overridden)],
      );
      addTearDown(container.dispose);

      final dio = container.read(dioProvider);
      expect(dio.options.baseUrl, 'https://override.example.com');
    });
  });

  // spec 028 T003: FormattingSettings.fromEnvironment falls back per-key on
  // a malformed value rather than throwing, the same rule
  // BrandConfig._parseSeedColor already applies to a bad hex color.
  // FormattingSettings._parseDigits/_nonEmptyOrDefault are private; this
  // group mirrors their documented rules directly (brand_config_test.dart's
  // convention for BrandConfig._parseSeedColor).
  group('FormattingSettings fallback rules (spec 028 FR-013)', () {
    int parseDigits(String value, int fallback) {
      final parsed = int.tryParse(value);
      if (parsed == null || parsed < 0) return fallback;
      return parsed;
    }

    String nonEmptyOrDefault(String value, String fallback) =>
        value.isEmpty ? fallback : value;

    test('a non-numeric digit count falls back to the default', () {
      expect(parseDigits('abc', 2), 2);
      expect(parseDigits('', 0), 0);
    });

    test('a negative digit count falls back to the default', () {
      expect(parseDigits('-1', 2), 2);
    });

    test('a valid non-negative digit count is used as given', () {
      expect(parseDigits('4', 2), 4);
      expect(parseDigits('0', 2), 0);
    });

    test('an empty pattern/symbol string falls back to the default', () {
      expect(nonEmptyOrDefault('', 'yyyy-MM-dd'), 'yyyy-MM-dd');
    });

    test('a non-empty pattern/symbol string is used as given', () {
      expect(nonEmptyOrDefault('d/M/yyyy', 'yyyy-MM-dd'), 'd/M/yyyy');
    });

    test('FormattingSettings.fromEnvironment reproduces the ISO default with no --dart-define', () {
      // Mirrors the AppSettings.fromEnvironment() test above: fromEnvironment()
      // reads compile-time values, so this only proves the no-.env path.
      final settings = FormattingSettings.fromEnvironment();

      expect(settings.datePattern, 'yyyy-MM-dd');
      expect(settings.dateTimePattern, 'yyyy-MM-dd HH:mm');
      expect(settings.currencySymbol, r'$');
      expect(settings.currencyCode, 'MXN');
      expect(settings.currencyDecimalDigits, 2);
      expect(settings.percentDecimalDigits, 2);
      expect(settings.quantityDecimalDigits, 0);
    });
  });
}
