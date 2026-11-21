import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/app/theme/app_theme.dart';
import 'package:mbe_ui/core/branding/brand_config.dart';
import 'package:mbe_ui/core/branding/brand_registry.dart';
import 'package:mbe_ui/core/branding/brands/casa_maestra_brand.dart';
import 'package:mbe_ui/core/branding/brands/xbe_brand.dart';
import 'package:mbe_ui/core/branding/semantic_colors.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';

/// Casa Maestra (`xbe.cm`) transcribes the design system's tokens exactly
/// (spec 077 FR-006..FR-010, SC-001). Every expected value below is copied
/// from spec.md › Verbatim Constraints, not from the implementation.
void main() {
  Color c(int v) => Color(0xFF000000 | v);

  final brand = BrandConfig.resolve(
    brandId: 'xbe.cm',
    displayName: 'ignored',
    seedColorHex: '',
    hasSeedColor: false,
    lockupAsset: 'ignored',
    markAsset: 'ignored',
  );
  final appTheme = AppTheme.of(brand);

  group('registration and assets', () {
    test('xbe.cm is registered and selected by BRAND_ID', () {
      expect(isRegisteredBrand('xbe.cm'), isTrue);
      expect(brand.definition, same(casaMaestraBrand));
      expect(brand.usesDefaultPalette, isTrue);
    });

    test('display name, seed and assets come from the definition', () {
      expect(brand.displayName, 'Casa Maestra');
      expect(brand.seedColor, c(0x00325F));
      expect(brand.lockupAsset, 'assets/brand/xbe.cm/casa-maestra-logo.png');
      expect(
        brand.lockupReversedAsset,
        'assets/brand/xbe.cm/casa-maestra-logo-reversed.png',
      );
      expect(brand.markAsset, 'assets/brand/xbe.cm/casa-maestra-mark.png');
    });

    test('brand-navy and brand-red are the exact logo colors', () {
      expect(casaMaestraNavy, c(0x00325F));
      expect(casaMaestraRed, c(0xFF2014));
    });

    test('the default brand stays registered and distinct', () {
      expect(kBrandRegistry['xbe'], same(xbeBrand));
      expect(brandDefinitionById('xbe.cm'), isNot(same(xbeBrand)));
    });
  });

  group('color roles (SC-001)', () {
    // role → [light, dark]
    final expected = <String, List<int>>{
      'primary': [0x00325F, 0xA9C7F0],
      'onPrimary': [0xFFFFFF, 0x002D55],
      'primaryContainer': [0xD5E3F8, 0x1C4675],
      'onPrimaryContainer': [0x001B3A, 0xD5E3F8],
      'surface': [0xF6F8FB, 0x0C1420],
      'surfaceContainerLowest': [0xFFFFFF, 0x080E18],
      'surfaceContainerLow': [0xFFFFFF, 0x121B28],
      'surfaceContainer': [0xEEF2F7, 0x162030],
      'surfaceContainerHigh': [0xE9EDF3, 0x1E2837],
      'surfaceContainerHighest': [0xE1E7EF, 0x283344],
      'onSurface': [0x0F1C2E, 0xE2E8F1],
      'onSurfaceVariant': [0x46536A, 0xB9C3D3],
      'outline': [0x76839A, 0x8994A8],
      'outlineVariant': [0xC9D1DC, 0x334055],
      'error': [0xBA1A1A, 0xFFB4AB],
      'onError': [0xFFFFFF, 0x690005],
      'errorContainer': [0xFFDAD6, 0x93000A],
      'onErrorContainer': [0x410002, 0xFFDAD6],
      'scrim': [0x000000, 0x000000],
    };

    Color role(ColorScheme s, String name) => switch (name) {
      'primary' => s.primary,
      'onPrimary' => s.onPrimary,
      'primaryContainer' => s.primaryContainer,
      'onPrimaryContainer' => s.onPrimaryContainer,
      'surface' => s.surface,
      'surfaceContainerLowest' => s.surfaceContainerLowest,
      'surfaceContainerLow' => s.surfaceContainerLow,
      'surfaceContainer' => s.surfaceContainer,
      'surfaceContainerHigh' => s.surfaceContainerHigh,
      'surfaceContainerHighest' => s.surfaceContainerHighest,
      'onSurface' => s.onSurface,
      'onSurfaceVariant' => s.onSurfaceVariant,
      'outline' => s.outline,
      'outlineVariant' => s.outlineVariant,
      'error' => s.error,
      'onError' => s.onError,
      'errorContainer' => s.errorContainer,
      'onErrorContainer' => s.onErrorContainer,
      'scrim' => s.scrim,
      _ => throw ArgumentError(name),
    };

    expected.forEach((name, values) {
      test('$name: light ${values[0].toRadixString(16)}, '
          'dark ${values[1].toRadixString(16)}', () {
        expect(role(appTheme.light.colorScheme, name), c(values[0]));
        expect(role(appTheme.dark.colorScheme, name), c(values[1]));
      });
    });

    test('accent, success and warning families', () {
      final l = appTheme.light.extension<SemanticColors>()!;
      final d = appTheme.dark.extension<SemanticColors>()!;
      // accent
      expect(l.accent, c(0xD7190F));
      expect(d.accent, c(0xFF8E7E));
      expect(l.onAccent, c(0xFFFFFF));
      expect(d.onAccent, c(0x3B0400));
      expect(l.accentContainer, c(0xFFDAD4));
      expect(d.accentContainer, c(0x7A1209));
      expect(l.onAccentContainer, c(0x4A0500));
      expect(d.onAccentContainer, c(0xFFDAD4));
      // success
      expect(l.success, c(0x1B6B3A));
      expect(d.success, c(0x7FD69A));
      expect(l.successContainer, c(0xC9EFD3));
      expect(d.successContainer, c(0x0F4A26));
      expect(l.onSuccessContainer, c(0x00210D));
      expect(d.onSuccessContainer, c(0xC9EFD3));
      // warning
      expect(l.warning, c(0x855300));
      expect(d.warning, c(0xFFB95E));
      expect(l.warningContainer, c(0xFFDDB3));
      expect(d.warningContainer, c(0x5A3A00));
      expect(l.onWarningContainer, c(0x2A1700));
      expect(d.onWarningContainer, c(0xFFDDB3));
      // roles the design system leaves out: white on light, dark ink on dark
      expect(l.onSuccess, c(0xFFFFFF));
      expect(l.onWarning, c(0xFFFFFF));
      expect(d.onSuccess, c(0x00210D));
      expect(d.onWarning, c(0x2A1700));
    });

    test('primary is already a safe foreground: no light-ink demotion', () {
      // BrandInk only demotes XBE's gold; navy primary is used as is.
      expect(appTheme.light.extension<SemanticColors>(), isNotNull);
      expect(casaMaestraBrand.lightInk, isNull);
    });
  });

  group('typography (FR-007, FR-008)', () {
    void expectStyle(
      TextStyle? s, {
      required String family,
      required double size,
      required double line,
      required FontWeight weight,
      required double tracking,
    }) {
      expect(s, isNotNull);
      expect(s!.fontFamily, family);
      expect(s.fontSize, size);
      expect(s.height! * s.fontSize!, closeTo(line, 0.001));
      expect(s.fontWeight, weight);
      expect(s.letterSpacing ?? 0, closeTo(tracking, 0.001));
    }

    for (final theme in [appTheme.light, appTheme.dark]) {
      final t = theme.textTheme;
      final b = theme.brightness.name;
      const bitter = 'Bitter';
      const roboto = 'BrandRoboto';
      test('$b: display, headline and title use Bitter', () {
        expectStyle(
          t.displayLarge,
          family: bitter,
          size: 57,
          line: 64,
          weight: FontWeight.w700,
          tracking: -0.75,
        );
        expectStyle(
          t.displayMedium,
          family: bitter,
          size: 45,
          line: 52,
          weight: FontWeight.w700,
          tracking: -0.5,
        );
        expectStyle(
          t.displaySmall,
          family: bitter,
          size: 36,
          line: 44,
          weight: FontWeight.w700,
          tracking: -0.25,
        );
        expectStyle(
          t.headlineLarge,
          family: bitter,
          size: 32,
          line: 40,
          weight: FontWeight.w700,
          tracking: -0.25,
        );
        expectStyle(
          t.headlineMedium,
          family: bitter,
          size: 28,
          line: 36,
          weight: FontWeight.w600,
          tracking: 0,
        );
        expectStyle(
          t.headlineSmall,
          family: bitter,
          size: 24,
          line: 32,
          weight: FontWeight.w600,
          tracking: 0,
        );
        expectStyle(
          t.titleLarge,
          family: bitter,
          size: 22,
          line: 28,
          weight: FontWeight.w600,
          tracking: 0,
        );
        expectStyle(
          t.titleMedium,
          family: bitter,
          size: 16,
          line: 24,
          weight: FontWeight.w600,
          tracking: 0.15,
        );
        expectStyle(
          t.titleSmall,
          family: bitter,
          size: 14,
          line: 20,
          weight: FontWeight.w600,
          tracking: 0.1,
        );
      });
      test('$b: body and label use Roboto', () {
        expectStyle(
          t.bodyLarge,
          family: roboto,
          size: 16,
          line: 24,
          weight: FontWeight.w400,
          tracking: 0.5,
        );
        expectStyle(
          t.bodyMedium,
          family: roboto,
          size: 14,
          line: 20,
          weight: FontWeight.w400,
          tracking: 0.25,
        );
        expectStyle(
          t.bodySmall,
          family: roboto,
          size: 12,
          line: 16,
          weight: FontWeight.w400,
          tracking: 0.4,
        );
        expectStyle(
          t.labelLarge,
          family: roboto,
          size: 14,
          line: 20,
          weight: FontWeight.w500,
          tracking: 0.1,
        );
        expectStyle(
          t.labelMedium,
          family: roboto,
          size: 12,
          line: 16,
          weight: FontWeight.w500,
          tracking: 0.5,
        );
        expectStyle(
          t.labelSmall,
          family: roboto,
          size: 11,
          line: 16,
          weight: FontWeight.w500,
          tracking: 0.5,
        );
      });
    }

    test('mono stays RobotoMono for every brand', () {
      expect(TypeRoles.monoFamily, 'RobotoMono');
      final themed = DesignTheme.forTier(appTheme.light, LayoutTier.expanded);
      expect(themed.typeRoles.recordId.fontFamily, 'RobotoMono');
      expect(themed.typeRoles.timestamp.fontFamily, 'RobotoMono');
    });
  });

  group('product tokens are not brandable (FR-005)', () {
    for (final tier in LayoutTier.values) {
      test('spacing, shape and density match XBE at ${tier.name}', () {
        final xbe = DesignTheme.forTier(
          AppTheme.of(const BrandConfig(displayName: 'X')).light,
          tier,
        );
        final cm = DesignTheme.forTier(appTheme.light, tier);
        expect(cm.spacing.screenMargin, xbe.spacing.screenMargin);
        expect(cm.spacing.cardPadding, xbe.spacing.cardPadding);
        expect(cm.shapes.lg, xbe.shapes.lg);
        expect(cm.shapes.xl, xbe.shapes.xl);
        expect(cm.density.minTargetSize, xbe.density.minTargetSize);
        expect(cm.density.tableDataRowHeight, xbe.density.tableDataRowHeight);
      });
    }
  });

  group('login pane and cleared legacy flags', () {
    test('Casa Maestra follows the theme with one accent bar', () {
      expect(casaMaestraBrand.loginPane.followsTheme, isTrue);
      expect(casaMaestraBrand.loginPane.accentBars, hasLength(1));
    });

    test('legacy BRAND_* flags are ignored when xbe.cm is selected', () {
      final withFlags = BrandConfig.resolve(
        brandId: 'xbe.cm',
        displayName: 'Other',
        welcomeAsset: 'assets/branding/other.png',
        seedColorHex: '1B5E20',
        hasSeedColor: true,
        lockupAsset: 'other.png',
        markAsset: 'other.png',
      );
      expect(withFlags, brand);
    });
  });
}
