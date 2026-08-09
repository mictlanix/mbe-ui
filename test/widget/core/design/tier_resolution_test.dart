import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/app/theme/app_theme.dart';
import 'package:mbe_ui/core/branding/brand_config.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';

const _defaultBrand = BrandConfig(displayName: 'Mictlanix Business Essentials');

/// Pumps a minimal app shell with the same tier-resolving `builder` wiring
/// as `lib/app/app.dart`, at a given logical-pixel width, and returns the
/// resolved theme visible to a descendant of `MaterialApp.builder` --
/// i.e. what every real route/dialog/sheet actually sees.
Future<ThemeData> _pumpAtWidth(WidgetTester tester, double width) async {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  late ThemeData resolved;
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        theme: AppTheme.of(_defaultBrand).light,
        builder: (context, child) {
          final tier = LayoutBreakpoints.tierOfContext(context);
          resolved = DesignTheme.forTier(Theme.of(context), tier);
          return Theme(data: resolved, child: child!);
        },
        home: const SizedBox.shrink(),
      ),
    ),
  );
  await tester.pump();
  return resolved;
}

void main() {
  group('MaterialApp.builder tier resolution (research R1)', () {
    testWidgets('480px resolves compact', (tester) async {
      final theme = await _pumpAtWidth(tester, 480);
      expect(
        theme.spacing.screenMargin,
        Spacing.forTier(LayoutTier.compact).screenMargin,
      );
    });

    testWidgets('720px resolves medium', (tester) async {
      final theme = await _pumpAtWidth(tester, 720);
      expect(
        theme.spacing.screenMargin,
        Spacing.forTier(LayoutTier.medium).screenMargin,
      );
    });

    testWidgets('1024px resolves expanded', (tester) async {
      final theme = await _pumpAtWidth(tester, 1024);
      expect(
        theme.spacing.cardPadding,
        Spacing.forTier(LayoutTier.expanded).cardPadding,
      );
    });

    testWidgets('1440px resolves large', (tester) async {
      final theme = await _pumpAtWidth(tester, 1440);
      expect(theme.spacing.contentMaxWidth, 1440);
    });

    testWidgets('the tier-resolved theme sits above the Navigator', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1024, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      late BuildContext routeContext;
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.of(_defaultBrand).light,
            builder: (context, child) {
              final tier = LayoutBreakpoints.tierOfContext(context);
              return Theme(
                data: DesignTheme.forTier(Theme.of(context), tier),
                child: child!,
              );
            },
            home: Builder(
              builder: (context) {
                routeContext = context;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      await tester.pump();

      // A widget below the Navigator sees the tier-resolved theme, not the
      // tier-agnostic base -- proving `builder` wraps the Navigator.
      expect(
        Theme.of(routeContext).extension<Spacing>(),
        isNotNull,
        reason: 'route content must inherit the tier-resolved theme',
      );
    });
  });

  group('Metrics step at the 840px expanded boundary (FR-013, US6)', () {
    testWidgets(
      'cardPadding/fieldGapHorizontal change crossing 840px; screenMargin/paneGutter/sectionGap do not',
      (tester) async {
        // Per data-model.md §1's table, medium and expanded share the same
        // screenMargin/paneGutter/sectionGap/fieldGapVertical value -- only
        // cardPadding and fieldGapHorizontal actually step at 840px. Asserted
        // both ways (equal where documented equal, unequal where documented
        // unequal) so this test would fail loudly if a future data-model.md
        // revision changes either without this assertion being updated too.
        final medium = await _pumpAtWidth(tester, 720);
        final expanded = await _pumpAtWidth(tester, 900);

        expect(expanded.spacing.cardPadding, isNot(medium.spacing.cardPadding));
        expect(
          expanded.spacing.fieldGapHorizontal,
          isNot(medium.spacing.fieldGapHorizontal),
        );
        expect(expanded.spacing.screenMargin, medium.spacing.screenMargin);
        expect(expanded.spacing.paneGutter, medium.spacing.paneGutter);
        expect(expanded.spacing.sectionGap, medium.spacing.sectionGap);
      },
    );

    testWidgets(
      'compact-tier values resolve even though no compact layout consumes them (FR-014)',
      (tester) async {
        final compact = await _pumpAtWidth(tester, 480);

        expect(
          compact.spacing.screenMargin,
          Spacing.forTier(LayoutTier.compact).screenMargin,
        );
        expect(compact.spacing.paneGutter, 0);
        expect(compact.spacing.fieldGapHorizontal, 0);
      },
    );
  });

  group(
    'A themed control measurably adapts at the tablet/desktop boundary (FR-013)',
    () {
      Future<RenderBox> pumpCard(WidgetTester tester, double width) async {
        final theme = await _pumpAtWidth(tester, width);
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: theme,
              builder: (context, child) {
                final tier = LayoutBreakpoints.tierOfContext(context);
                return Theme(
                  data: DesignTheme.forTier(Theme.of(context), tier),
                  child: child!,
                );
              },
              home: Scaffold(
                body: Card(
                  key: const Key('probe_card'),
                  child: const SizedBox(width: 100, height: 100),
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        return tester.renderObject<RenderBox>(
          find.byKey(const Key('probe_card')),
        );
      }

      testWidgets(
        'a Card renders at a different size at medium vs. expanded width',
        (tester) async {
          // The Card's own content is fixed (100x100); CardThemeData.margin is
          // sourced from theme.spacing, which does differ at these two widths
          // (verified above) -- so the Card's rendered size, which includes its
          // margin, must differ too. This is the automated proxy for "a real
          // control visibly adapts," moving FR-013's claim off manual-only
          // verification for at least one control.
          final atMedium = await pumpCard(tester, 720);
          final atExpanded = await pumpCard(tester, 900);

          expect(atExpanded.size, isNot(atMedium.size));
        },
      );
    },
  );
}
