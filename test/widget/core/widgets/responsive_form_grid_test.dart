import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/layout/breakpoints.dart';
import 'package:mbe_ui/core/widgets/responsive_form_grid.dart';

/// spec 037 FR-016c: the sales-order header's disclosed group reads six-up at
/// the large tier, which needed a new input on this shared grid. Every form in
/// the app renders through it, so the point of these tests is less the new
/// behaviour than the guarantee around it — a caller that omits the input gets
/// exactly what it got before.
void main() {
  group('columnsForWidth — the tier mapping every form relies on', () {
    test('is unchanged for a caller that passes no override', () {
      expect(ResponsiveFormGrid.columnsForWidth(400), 1);
      expect(ResponsiveFormGrid.columnsForWidth(LayoutBreakpoints.compact), 2);
      expect(ResponsiveFormGrid.columnsForWidth(1000), 2);
      expect(ResponsiveFormGrid.columnsForWidth(LayoutBreakpoints.large), 3);
      expect(ResponsiveFormGrid.columnsForWidth(1600), 3);
    });

    test('the override applies to the large tier only', () {
      expect(ResponsiveFormGrid.columnsForWidth(400, largeTierColumns: 6), 1);
      expect(ResponsiveFormGrid.columnsForWidth(1000, largeTierColumns: 6), 2);
      expect(ResponsiveFormGrid.columnsForWidth(1600, largeTierColumns: 6), 6);
    });
  });

  group('the rendered grid', () {
    /// Each child reports the width it was actually given, so a test can read
    /// the column count back off the layout rather than trusting the maths.
    Future<List<double>> widths(
      WidgetTester tester, {
      required double surface,
      int? largeTierColumns,
      int childCount = 6,
    }) async {
      tester.view.physicalSize = Size(surface, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveFormGrid(
              largeTierColumns: largeTierColumns,
              children: [
                for (var i = 0; i < childCount; i++)
                  FormGridChild(SizedBox(key: ValueKey(i), height: 20)),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      return [
        for (var i = 0; i < childCount; i++)
          tester.getSize(find.byKey(ValueKey(i))).width,
      ];
    }

    testWidgets('a caller that omits the override still gets three columns at '
        'the large tier', (tester) async {
      final sizes = await widths(tester, surface: 1400);
      // Three across: each cell is roughly a third of the content width, and
      // the six children therefore occupy two runs.
      expect(sizes.first, closeTo((1200 - 32) / 3, 1));
    });

    testWidgets('the override puts six on one line at the large tier', (
      tester,
    ) async {
      final sizes = await widths(tester, surface: 1400, largeTierColumns: 6);
      expect(sizes.first, closeTo((1200 - 16 * 5) / 6, 1));
      // Every child is the same width — one run of six, not a ragged wrap.
      for (final width in sizes) {
        expect(width, closeTo(sizes.first, 0.5));
      }
    });

    testWidgets('is centred by default, and starts at the leading edge when '
        'asked (spec 037)', (tester) async {
      Future<double> leftEdgeOf({AlignmentGeometry? alignment}) async {
        tester.view.physicalSize = const Size(1600, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              // Three children fill the large tier's three columns, so the
              // grid actually occupies its 1200 cap — with one child the
              // `Wrap` shrink-wraps and there is no alignment to observe.
              body: ResponsiveFormGrid(
                alignment: alignment ?? Alignment.center,
                children: const [
                  FormGridChild(SizedBox(key: ValueKey('first'), height: 20)),
                  FormGridChild(SizedBox(height: 20)),
                  FormGridChild(SizedBox(height: 20)),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        return tester.getTopLeft(find.byKey(const ValueKey('first'))).dx;
      }

      // 1600 wide against the grid's 1200 cap leaves 400 to distribute.
      expect(await leftEdgeOf(), closeTo(200, 1));
      expect(
        await leftEdgeOf(alignment: AlignmentDirectional.centerStart),
        closeTo(0, 1),
      );
    });

    testWidgets('the override leaves narrower tiers alone', (tester) async {
      final compact = await widths(tester, surface: 500, largeTierColumns: 6);
      expect(compact.first, closeTo(500, 1), reason: 'one column at compact');

      final expanded = await widths(tester, surface: 1000, largeTierColumns: 6);
      expect(
        expanded.first,
        closeTo((1000 - 16) / 2, 1),
        reason: 'two columns at expanded',
      );
    });
  });
}
