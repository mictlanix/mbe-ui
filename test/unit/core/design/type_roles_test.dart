import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/design/type_roles.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';

void main() {
  // A fully-populated, real M3 TextTheme -- every role distinct and
  // non-null, so slot -> role resolution can be checked precisely rather
  // than approximated.
  final textTheme = ThemeData(useMaterial3: true).textTheme;

  TextStyle emphasize(TextStyle? style) =>
      style!.copyWith(fontWeight: FontWeight.w700);
  TextStyle mono(TextStyle? style) => style!.copyWith(fontFamily: 'RobotoMono');
  TextStyle tabular(TextStyle? style) =>
      style!.copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

  group('TypeRoles.resolve — all 21 slots, all 4 tiers (FR-008)', () {
    test('compact tier', () {
      final r = TypeRoles.resolve(textTheme, LayoutTier.compact);
      expect(r.screenTitle, textTheme.titleLarge);
      expect(r.heroHeading, textTheme.headlineMedium);
      expect(r.heroSubhead, textTheme.bodyLarge);
      expect(r.pageHeading, emphasize(textTheme.headlineSmall));
      expect(r.sectionHeading, textTheme.titleMedium);
      expect(r.cardTitle, textTheme.titleMedium);
      expect(r.metricValue, emphasize(textTheme.headlineSmall));
      expect(r.metricLabel, textTheme.bodySmall);
      expect(r.navLabel, textTheme.labelLarge);
      expect(r.navHeader, textTheme.titleSmall);
      expect(r.tableHeader, textTheme.labelLarge);
      expect(r.tableCell, textTheme.bodyMedium);
      expect(r.fieldInput, textTheme.bodyLarge);
      expect(r.fieldLabel, textTheme.bodySmall);
      expect(r.chipLabel, textTheme.labelLarge);
      expect(r.buttonLabel, textTheme.labelLarge);
      expect(r.money, tabular(textTheme.bodyMedium));
      expect(r.recordId, mono(textTheme.bodyMedium));
      expect(r.timestamp, mono(textTheme.bodySmall));
      expect(r.productCode, textTheme.bodyMedium);
      expect(r.overlayText, textTheme.bodyMedium);
    });

    test('medium tier', () {
      final r = TypeRoles.resolve(textTheme, LayoutTier.medium);
      expect(r.screenTitle, textTheme.titleLarge);
      expect(r.heroHeading, textTheme.displaySmall);
      expect(r.heroSubhead, textTheme.bodyLarge);
      expect(r.pageHeading, emphasize(textTheme.headlineMedium));
      expect(r.sectionHeading, textTheme.titleMedium);
      expect(r.cardTitle, textTheme.titleMedium);
      expect(r.metricValue, emphasize(textTheme.headlineMedium));
      expect(r.metricLabel, textTheme.bodySmall);
      expect(r.navLabel, textTheme.labelLarge);
      expect(r.navHeader, textTheme.titleSmall);
      expect(r.tableHeader, textTheme.labelLarge);
      expect(r.tableCell, textTheme.bodyMedium);
      expect(r.fieldInput, textTheme.bodyLarge);
      expect(r.fieldLabel, textTheme.bodySmall);
      expect(r.chipLabel, textTheme.labelLarge);
      expect(r.buttonLabel, textTheme.labelLarge);
      expect(r.money, tabular(textTheme.bodyMedium));
      expect(r.recordId, mono(textTheme.bodyMedium));
      expect(r.timestamp, mono(textTheme.bodySmall));
      expect(r.productCode, textTheme.bodyMedium);
      expect(r.overlayText, textTheme.bodyMedium);
    });

    test('expanded tier', () {
      final r = TypeRoles.resolve(textTheme, LayoutTier.expanded);
      expect(r.screenTitle, textTheme.titleLarge);
      expect(r.heroHeading, textTheme.displaySmall);
      expect(r.heroSubhead, textTheme.bodyLarge);
      expect(r.pageHeading, emphasize(textTheme.headlineMedium));
      expect(r.sectionHeading, textTheme.titleLarge);
      expect(r.cardTitle, textTheme.titleMedium);
      expect(r.metricValue, emphasize(textTheme.headlineMedium));
      expect(r.metricLabel, textTheme.bodySmall);
      expect(r.navLabel, textTheme.labelLarge);
      expect(r.navHeader, textTheme.titleSmall);
      expect(r.tableHeader, textTheme.labelLarge);
      expect(r.tableCell, textTheme.bodyMedium);
      expect(r.fieldInput, textTheme.bodyMedium);
      expect(r.fieldLabel, textTheme.bodySmall);
      expect(r.chipLabel, textTheme.labelMedium);
      expect(r.buttonLabel, textTheme.labelLarge);
      expect(r.money, tabular(textTheme.bodyMedium));
      expect(r.recordId, mono(textTheme.bodyMedium));
      expect(r.timestamp, mono(textTheme.bodySmall));
      expect(r.productCode, textTheme.bodyMedium);
      expect(r.overlayText, textTheme.bodySmall);
    });

    test(
      'large tier matches expanded (data-model.md §5 merges the two columns)',
      () {
        final expanded = TypeRoles.resolve(textTheme, LayoutTier.expanded);
        final large = TypeRoles.resolve(textTheme, LayoutTier.large);
        expect(large.screenTitle, expanded.screenTitle);
        expect(large.heroHeading, expanded.heroHeading);
        expect(large.sectionHeading, expanded.sectionHeading);
        expect(large.metricValue, expanded.metricValue);
        expect(large.fieldInput, expanded.fieldInput);
        expect(large.chipLabel, expanded.chipLabel);
        expect(large.overlayText, expanded.overlayText);
      },
    );

    test(
      'productCode is never RobotoMono; recordId/timestamp always are (FR-028)',
      () {
        for (final tier in LayoutTier.values) {
          final r = TypeRoles.resolve(textTheme, tier);
          expect(r.productCode.fontFamily, isNot('RobotoMono'));
          expect(r.recordId.fontFamily, 'RobotoMono');
          expect(r.timestamp.fontFamily, 'RobotoMono');
        }
      },
    );
  });
}
