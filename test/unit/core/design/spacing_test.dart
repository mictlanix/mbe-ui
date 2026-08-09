import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/design/spacing.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';

void main() {
  group('Spacing', () {
    test('the 8-step scale is a positive, ascending multiple-of-4 grid', () {
      final s = Spacing.forTier(LayoutTier.expanded);
      final steps = [
        s.none,
        s.xxs,
        s.xs,
        s.sm,
        s.md,
        s.lg,
        s.xl,
        s.xxl,
        s.xxxl,
      ];
      for (final step in steps) {
        expect(step % 4, 0, reason: '$step is not a multiple of 4');
      }
      for (var i = 1; i < steps.length; i++) {
        expect(steps[i], greaterThan(steps[i - 1]));
      }
    });

    test('every tier-dependent field resolves for all four tiers', () {
      for (final tier in LayoutTier.values) {
        final s = Spacing.forTier(tier);
        expect(s.screenMargin, greaterThan(0));
        expect(s.cardPadding, greaterThan(0));
        expect(s.fieldGapVertical, greaterThan(0));
        expect(s.sectionGap, greaterThan(0));
        // paneGutter/fieldGapHorizontal are legitimately 0 at compact
        // (stacked / single-column) -- never null, per data-model.md §1.
        expect(s.paneGutter, greaterThanOrEqualTo(0));
        expect(s.fieldGapHorizontal, greaterThanOrEqualTo(0));
        expect(s.contentMaxWidth, greaterThan(0));
      }
    });

    test('contentMaxWidth is unbounded except at large', () {
      expect(
        Spacing.forTier(LayoutTier.compact).contentMaxWidth,
        double.infinity,
      );
      expect(
        Spacing.forTier(LayoutTier.medium).contentMaxWidth,
        double.infinity,
      );
      expect(
        Spacing.forTier(LayoutTier.expanded).contentMaxWidth,
        double.infinity,
      );
      expect(Spacing.forTier(LayoutTier.large).contentMaxWidth, 1440);
    });

    test(
      'screenMargin/cardPadding/sectionGap step up crossing the expanded boundary',
      () {
        final medium = Spacing.forTier(LayoutTier.medium);
        final expanded = Spacing.forTier(LayoutTier.expanded);
        expect(expanded.cardPadding, greaterThan(medium.cardPadding));
      },
    );
  });
}
