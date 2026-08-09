import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/app/theme/app_theme.dart';
import 'package:mbe_ui/core/branding/brand_config.dart';
import 'package:mbe_ui/core/branding/brand_ink.dart';
import 'package:mbe_ui/core/branding/xbe_palette.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';

/// SC-008 / FR-010's structural proof: requesting a design token never
/// requires knowing which brand is deployed.
///
/// Nuance worth being explicit about (this is the correct reading of
/// SC-008, not a loosened one): [Spacing], [Shapes] and [Density] hold
/// literal numbers with no brand input at all, so their *values* are
/// trivially identical under any two brand configs. [Elevations] and
/// [TypeRoles] instead hold a fixed *mapping* onto the brand's own
/// [ColorScheme]/[TextTheme] (research R8/data-model.md §3/§5) — their
/// *resolved output* legitimately differs by brand (a card correctly picks
/// up whatever `surfaceContainerLow` that brand's palette produces), while
/// the *rule* ("raised" always means `surfaceContainerLow`) stays fixed.
/// This test proves both halves precisely, rather than asserting a naive
/// whole-object equality that would be false for the latter two by design.
void main() {
  const defaultBrand = BrandConfig(
    displayName: 'Mictlanix Business Essentials',
  );
  const overriddenBrand = BrandConfig(
    displayName: 'CASA MAESTRA',
    seedColor: Color(0xFF1B5E20),
    usesDefaultPalette: false,
  );

  ThemeData themeFor(
    BrandConfig brand,
    Brightness brightness,
    LayoutTier tier,
  ) {
    final appTheme = AppTheme.of(brand);
    final base = brightness == Brightness.light
        ? appTheme.light
        : appTheme.dark;
    return DesignTheme.forTier(base, tier);
  }

  group(
    'Spacing / Shapes / Density — literal values identical across brands',
    () {
      for (final tier in LayoutTier.values) {
        test('at ${tier.name} tier', () {
          final a = themeFor(defaultBrand, Brightness.light, tier);
          final b = themeFor(overriddenBrand, Brightness.light, tier);

          expect(a.spacing.screenMargin, b.spacing.screenMargin);
          expect(a.spacing.cardPadding, b.spacing.cardPadding);
          expect(a.spacing.lg, b.spacing.lg);
          expect(a.spacing.contentMaxWidth, b.spacing.contentMaxWidth);

          expect(a.shapes.lg, b.shapes.lg);
          expect(a.shapes.xs, b.shapes.xs);

          expect(a.density.visualDensity, b.density.visualDensity);
          expect(a.density.minTargetSize, b.density.minTargetSize);
        });
      }
    },
  );

  group(
    'Elevations / TypeRoles — mapping identical, resolved output brand-derived',
    () {
      test(
        'Elevations.raised tracks each brand\'s own surfaceContainerLow',
        () {
          final a = themeFor(
            defaultBrand,
            Brightness.light,
            LayoutTier.expanded,
          );
          final b = themeFor(
            overriddenBrand,
            Brightness.light,
            LayoutTier.expanded,
          );

          // The mapping is the same rule for both...
          expect(
            a.elevations.raised.surfaceColor,
            a.colorScheme.surfaceContainerLow,
          );
          expect(
            b.elevations.raised.surfaceColor,
            b.colorScheme.surfaceContainerLow,
          );
          // ...but the two brands' surfaceContainerLow differ, so the resolved
          // color legitimately differs too -- proving this ISN'T a hardcoded
          // XBE value leaking through (spec 019 FR-007 extended to this token).
          expect(
            a.elevations.raised.surfaceColor,
            isNot(b.elevations.raised.surfaceColor),
          );
        },
      );

      test('TypeRoles.sectionHeading tracks each brand\'s own titleLarge', () {
        final a = themeFor(defaultBrand, Brightness.light, LayoutTier.expanded);
        final b = themeFor(
          overriddenBrand,
          Brightness.light,
          LayoutTier.expanded,
        );

        expect(a.typeRoles.sectionHeading, a.textTheme.titleLarge);
        expect(b.typeRoles.sectionHeading, b.textTheme.titleLarge);
        // The default brand's titleLarge is Archivo-branded; an overridden
        // seed gets Material's unbranded titleLarge -- legitimately different.
        expect(a.typeRoles.sectionHeading, isNot(b.typeRoles.sectionHeading));
      });
    },
  );

  test(
    'no XbePalette-traceable value survives into an overridden brand\'s tokens',
    () {
      final overridden = themeFor(
        overriddenBrand,
        Brightness.light,
        LayoutTier.expanded,
      );
      expect(
        overridden.elevations.raised.surfaceColor,
        isNot(XbePalette.lightSurfaceContainerLow),
      );
      expect(overridden.brandInk.primary, isNot(XbePalette.goldInk));
    },
  );
}
