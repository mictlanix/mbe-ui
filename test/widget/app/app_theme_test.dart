import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/app/theme/app_theme.dart';
import 'package:mbe_ui/core/branding/brand_config.dart';
import 'package:mbe_ui/core/branding/xbe_palette.dart';

void main() {
  group('AppTheme.of — default XBE palette (US1)', () {
    // BrandConfig.fromEnvironment() itself reads compile-time --dart-define
    // values that can't vary per test; the default-vs-override behavior is
    // exercised directly via BrandConfig's public constructor instead,
    // which is what fromEnvironment() resolves to when no dart-defines are
    // set (usesDefaultPalette: true, seedColor: XbePalette.gold).
    const defaultBrand = BrandConfig(displayName: 'Mictlanix Business Essentials');

    test('dark ColorScheme uses the pinned XBE brand roles', () {
      final theme = AppTheme.of(defaultBrand);
      final scheme = theme.dark.colorScheme;

      expect(scheme.primary, XbePalette.gold);
      expect(scheme.tertiary, XbePalette.orange);
      expect(scheme.error, XbePalette.red);
      expect(scheme.surface, const Color(0xFF14120F));
      expect(scheme.secondary, XbePalette.wordmarkGray);
      expect(scheme.onPrimary, XbePalette.darkOnPrimary);
      expect(scheme.onSurface, XbePalette.darkOnSurface);
    });

    test('light ColorScheme uses the pinned XBE brand roles', () {
      final theme = AppTheme.of(defaultBrand);
      final scheme = theme.light.colorScheme;

      expect(scheme.primary, XbePalette.gold);
      expect(scheme.error, const Color(0xFFC4262E));
      expect(scheme.surface, const Color(0xFFFBF8F3));
      expect(scheme.tertiary, XbePalette.orange);
      expect(scheme.onSurface, XbePalette.lightOnSurface);
    });

    test('display/title/label text roles use Archivo; body stays default', () {
      final theme = AppTheme.of(defaultBrand);
      final textTheme = theme.dark.textTheme;

      expect(textTheme.headlineMedium?.fontFamily, 'Archivo');
      expect(textTheme.titleLarge?.fontFamily, 'Archivo');
      expect(textTheme.labelLarge?.fontFamily, 'Archivo');
      // bodyLarge is untouched — no fontFamily override applied.
      expect(textTheme.bodyLarge?.fontFamily, isNot('Archivo'));
    });

    test('both themes use Material 3', () {
      final theme = AppTheme.of(defaultBrand);
      expect(theme.light.useMaterial3, isTrue);
      expect(theme.dark.useMaterial3, isTrue);
    });
  });

  group('AppTheme.of — overridden seed isolation (US5, FR-007)', () {
    // A deployment that sets its own seed (BRAND_SEED_COLOR) must get a
    // wholly seed-derived scheme with zero XBE-specific pins — this is the
    // single most important guarantee in spec 019 (quickstart.md §4).
    const overriddenBrand = BrandConfig(
      displayName: 'CASA MAESTRA',
      seedColor: Color(0xFF1B5E20),
      usesDefaultPalette: false,
    );

    test('dark ColorScheme carries no XBE pins', () {
      final scheme = AppTheme.of(overriddenBrand).dark.colorScheme;

      expect(scheme.primary, isNot(XbePalette.gold));
      expect(scheme.tertiary, isNot(XbePalette.orange));
      expect(scheme.error, isNot(XbePalette.red));
      expect(scheme.secondary, isNot(XbePalette.wordmarkGray));
      expect(scheme.surface, isNot(const Color(0xFF14120F)));
      expect(scheme.onSurface, isNot(XbePalette.darkOnSurface));
    });

    test('light ColorScheme carries no XBE pins', () {
      final scheme = AppTheme.of(overriddenBrand).light.colorScheme;

      expect(scheme.primary, isNot(XbePalette.gold));
      expect(scheme.tertiary, isNot(XbePalette.orange));
      expect(scheme.error, isNot(const Color(0xFFC4262E)));
      expect(scheme.surface, isNot(const Color(0xFFFBF8F3)));
    });

    test(
      'an explicit seed equal to XbePalette.gold still counts as an override (no pins)',
      () {
        // usesDefaultPalette is driven by whether BRAND_SEED_COLOR was set
        // at all, not by the seed's value — this is what makes the
        // isolation guarantee unambiguous (data-model.md).
        const sameHueOverride = BrandConfig(
          displayName: 'X',
          seedColor: XbePalette.gold,
          usesDefaultPalette: false,
        );
        final scheme = AppTheme.of(sameHueOverride).dark.colorScheme;

        // primary still traces back to the gold hue (same seed), but the
        // brand-exact pins (tertiary/error/secondary/surfaces) must not
        // apply — only fromSeed's algorithmic derivation does.
        expect(scheme.tertiary, isNot(XbePalette.orange));
        expect(scheme.error, isNot(XbePalette.red));
        expect(scheme.secondary, isNot(XbePalette.wordmarkGray));
        expect(scheme.surface, isNot(const Color(0xFF14120F)));
      },
    );
  });
}
