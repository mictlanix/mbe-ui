import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/app/theme/app_theme.dart';
import 'package:mbe_ui/core/branding/brand_config.dart';
import 'package:mbe_ui/core/branding/brand_ink.dart';
import 'package:mbe_ui/core/branding/xbe_palette.dart';

/// WCAG 2.1 relative luminance / contrast ratio, so the palette's own
/// contrast claims are asserted rather than trusted.
double _relativeLuminance(Color color) {
  double linearize(double channel) => channel <= 0.03928
      ? channel / 12.92
      : math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * linearize(color.r) +
      0.7152 * linearize(color.g) +
      0.0722 * linearize(color.b);
}

double _contrastRatio(Color foreground, Color background) {
  final a = _relativeLuminance(foreground);
  final b = _relativeLuminance(background);
  return (math.max(a, b) + 0.05) / (math.min(a, b) + 0.05);
}

void main() {
  group('AppTheme.of — default XBE palette (US1)', () {
    // BrandConfig.fromEnvironment() itself reads compile-time --dart-define
    // values that can't vary per test; the default-vs-override behavior is
    // exercised directly via BrandConfig's public constructor instead,
    // which is what fromEnvironment() resolves to when no dart-defines are
    // set (usesDefaultPalette: true, seedColor: XbePalette.gold).
    const defaultBrand = BrandConfig(
      displayName: 'Mictlanix Business Essentials',
    );

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

    test(
      'TextTheme ink traces to the pinned onSurface, not the M3 baseline',
      () {
        // app_theme.dart used to seed _brandTextTheme's base from a bare
        // ThemeData(brightness:) carrying no colorScheme, so Flutter's M3
        // baseline ink (#1D1B20 light / #E6E0E9 dark) won ThemeData's
        // defaultTextTheme.merge over the pinned XBE values (spec 022 FR-001).
        for (final theme in [
          AppTheme.of(defaultBrand).light,
          AppTheme.of(defaultBrand).dark,
        ]) {
          final onSurface = theme.colorScheme.onSurface;
          for (final style in [
            theme.textTheme.displayLarge,
            theme.textTheme.displayMedium,
            theme.textTheme.displaySmall,
            theme.textTheme.headlineLarge,
            theme.textTheme.headlineMedium,
            theme.textTheme.headlineSmall,
            theme.textTheme.titleLarge,
            theme.textTheme.titleMedium,
            theme.textTheme.titleSmall,
            theme.textTheme.bodyLarge,
            theme.textTheme.bodyMedium,
            theme.textTheme.bodySmall,
            theme.textTheme.labelLarge,
            theme.textTheme.labelMedium,
            theme.textTheme.labelSmall,
          ]) {
            expect(
              style?.color,
              onSurface,
              reason:
                  '${theme.brightness.name} mode text role must use the '
                  'pinned onSurface, not the M3 baseline ink',
            );
          }
        }
      },
    );

    test('light surfaceContainerLow is pinned, not seed-derived', () {
      // Previously dark-only; light mode fell back to a seed-derived value
      // nobody approved (spec 022 FR-002).
      final light = AppTheme.of(defaultBrand).light;
      expect(
        light.colorScheme.surfaceContainerLow,
        XbePalette.lightSurfaceContainerLow,
      );
    });

    test(
      'every TextTheme role computes >= 4.5:1 contrast against its surface',
      () {
        // FR-022/SC-003's actual, computed proof -- not inferred from the
        // color-equality checks above. Reuses the file's own WCAG helper.
        for (final theme in [
          AppTheme.of(defaultBrand).light,
          AppTheme.of(defaultBrand).dark,
        ]) {
          final surface = theme.colorScheme.surface;
          final roles = <String, TextStyle?>{
            'displayLarge': theme.textTheme.displayLarge,
            'displayMedium': theme.textTheme.displayMedium,
            'displaySmall': theme.textTheme.displaySmall,
            'headlineLarge': theme.textTheme.headlineLarge,
            'headlineMedium': theme.textTheme.headlineMedium,
            'headlineSmall': theme.textTheme.headlineSmall,
            'titleLarge': theme.textTheme.titleLarge,
            'titleMedium': theme.textTheme.titleMedium,
            'titleSmall': theme.textTheme.titleSmall,
            'bodyLarge': theme.textTheme.bodyLarge,
            'bodyMedium': theme.textTheme.bodyMedium,
            'bodySmall': theme.textTheme.bodySmall,
            'labelLarge': theme.textTheme.labelLarge,
            'labelMedium': theme.textTheme.labelMedium,
            'labelSmall': theme.textTheme.labelSmall,
          };
          roles.forEach((name, style) {
            final color = style?.color;
            if (color == null) return;
            final ratio = _contrastRatio(color, surface);
            expect(
              ratio,
              greaterThanOrEqualTo(4.5),
              reason:
                  '$name in ${theme.brightness.name} mode must clear 4.5:1 '
                  'against surface (got ${ratio.toStringAsFixed(2)}:1)',
            );
          });
        }
      },
    );

    test('brandInk demotes gold to goldInk on light, keeps gold on dark', () {
      final theme = AppTheme.of(defaultBrand);

      // Light: raw gold fails as a foreground, so text/icon uses goldInk.
      expect(theme.light.brandInk.primary, XbePalette.goldInk);
      // Dark: gold is already accessible on the warm-dark ramp.
      expect(theme.dark.brandInk.primary, XbePalette.gold);
    });

    test('brandInk clears 4.5:1 against the surface it is drawn on', () {
      // The whole reason this token exists (brand guide § "Modo claro";
      // contracts/brand-tokens.md § xbeGoldInk) — assert the outcome, not
      // the constant, so a future palette edit can't silently regress it.
      for (final theme in [
        AppTheme.of(defaultBrand).light,
        AppTheme.of(defaultBrand).dark,
      ]) {
        final ratio = _contrastRatio(
          theme.brandInk.primary,
          theme.colorScheme.surface,
        );
        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason:
              'brandInk.primary must be legible as text on surface '
              '(${theme.brightness.name} mode, got ${ratio.toStringAsFixed(2)}:1)',
        );
      }
    });

    test('raw gold primary would NOT pass on the light surface', () {
      // Guards the premise: if Material ever stopped pinning gold to light
      // `primary`, the demotion above would become dead code and this test
      // is what says so.
      final light = AppTheme.of(defaultBrand).light;
      expect(
        _contrastRatio(light.colorScheme.primary, light.colorScheme.surface),
        lessThan(4.5),
      );
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

    test('brandInk never leaks XBE goldInk into an overridden build', () {
      // The light-mode demotion is an XBE-palette correction; a deployment
      // with its own seed gets fromSeed's already-accessible `primary`.
      for (final theme in [
        AppTheme.of(overriddenBrand).light,
        AppTheme.of(overriddenBrand).dark,
      ]) {
        expect(theme.brandInk.primary, isNot(XbePalette.goldInk));
        expect(theme.brandInk.primary, theme.colorScheme.primary);
      }
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
