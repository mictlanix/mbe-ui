import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/widgets/brand_logo.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(home: Scaffold(body: child)),
      ),
    );
    await tester.pump();
  }

  group('BrandLogo minimum-size enforcement (FR-003/004)', () {
    testWidgets('lockup below its minimum width (51px) renders nothing', (
      tester,
    ) async {
      await pump(
        tester,
        const BrandLogo(style: BrandLogoStyle.lockup, width: 40),
      );
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('lockup at/above its minimum width (51px) renders', (
      tester,
    ) async {
      await pump(
        tester,
        const BrandLogo(style: BrandLogoStyle.lockup, width: 51),
      );
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('mark below its minimum width (37px) renders nothing', (
      tester,
    ) async {
      await pump(
        tester,
        const BrandLogo(style: BrandLogoStyle.mark, width: 20),
      );
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('mark at/above its minimum width (37px) renders', (
      tester,
    ) async {
      await pump(
        tester,
        const BrandLogo(style: BrandLogoStyle.mark, width: 37),
      );
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('height-mode (nav header) renders without a width check', (
      tester,
    ) async {
      await pump(
        tester,
        const BrandLogo(style: BrandLogoStyle.mark, height: 34),
      );
      expect(find.byType(Image), findsOneWidget);
    });
  });

  group('BrandLogo variant selection', () {
    testWidgets('neutral background renders the full-color asset untinted', (
      tester,
    ) async {
      await pump(
        tester,
        const BrandLogo(style: BrandLogoStyle.lockup, width: 236),
      );
      expect(find.byType(ColorFiltered), findsNothing);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('brandFill background applies a white ColorFilter', (
      tester,
    ) async {
      await pump(
        tester,
        const BrandLogo(
          style: BrandLogoStyle.lockup,
          width: 236,
          background: BrandLogoBackground.brandFill,
        ),
      );
      final filtered = tester.widget<ColorFiltered>(find.byType(ColorFiltered));
      expect(
        filtered.colorFilter,
        const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      );
    });
  });

  group('BrandLogo clear space (FR-003)', () {
    testWidgets('width-mode wraps the asset in 8%-of-width padding', (
      tester,
    ) async {
      await pump(
        tester,
        const BrandLogo(style: BrandLogoStyle.lockup, width: 200),
      );
      final padding = tester.widget<Padding>(
        find
            .ancestor(of: find.byType(Image), matching: find.byType(Padding))
            .first,
      );
      expect(padding.padding, const EdgeInsets.all(16)); // 200 * 0.08
    });
  });

  group('BrandWatermark', () {
    testWidgets('renders at 7% opacity, white-tinted, in a dark theme', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData(brightness: Brightness.dark),
            home: const Scaffold(body: BrandWatermark(width: 100)),
          ),
        ),
      );
      await tester.pump();

      final opacity = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacity.opacity, closeTo(0.07, 0.0001));
      expect(find.byType(ColorFiltered), findsOneWidget);
    });

    testWidgets('renders at 6% opacity, full-color, in a light theme', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData(brightness: Brightness.light),
            home: const Scaffold(body: BrandWatermark(width: 100)),
          ),
        ),
      );
      await tester.pump();

      final opacity = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacity.opacity, closeTo(0.06, 0.0001));
      expect(find.byType(ColorFiltered), findsNothing);
    });
  });
}
