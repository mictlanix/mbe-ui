import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/branding/brand_config.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';
import 'package:mbe_ui/app/theme/app_theme.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_bar.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';

void main() {
  Widget wrap(
    double width, {
    List<Widget> filters = const [],
    List<Widget> actions = const [],
  }) => MaterialApp(
    home: Scaffold(
      body: SizedBox(
        width: width,
        child: CatalogFilterBar(
          search: const TextField(key: Key('search')),
          filters: filters,
          actions: actions,
        ),
      ),
    ),
  );

  testWidgets(
    'lays out search + filters on one Row at >= 840px width (FR-009)',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        wrap(900, filters: [Text('Filter A'), Text('Filter B')]),
      );

      expect(find.byType(Row), findsWidgets);
      expect(find.byType(Wrap), findsNothing);
    },
  );

  testWidgets('reflows search + filters into a Wrap below 840px width', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(600, filters: [Text('Filter A'), Text('Filter B')]),
    );

    expect(find.byType(Wrap), findsOneWidget);
  });

  testWidgets('with no facet filters, the single-row requirement holds '
      'trivially', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(wrap(900, filters: const []));

    expect(find.byKey(const Key('search')), findsOneWidget);
    expect(find.byType(Wrap), findsNothing);
  });

  testWidgets('entity actions render to the left of the filters, between '
      'search and filters, on one row (spec 010 FR-018)', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      wrap(
        900,
        filters: const [Text('Filters', key: Key('filters'))],
        actions: const [Text('Add', key: Key('add'))],
      ),
    );

    expect(find.byType(Wrap), findsNothing);
    // Actions sit between the search box and the filters button.
    final searchX = tester.getTopLeft(find.byKey(const Key('search'))).dx;
    final addX = tester.getTopLeft(find.byKey(const Key('add'))).dx;
    final filtersX = tester.getTopLeft(find.byKey(const Key('filters'))).dx;
    expect(addX, greaterThan(searchX));
    expect(filtersX, greaterThan(addX));
  });

  testWidgets('actions remain present, reflowed, at narrow width (FR-021)', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        600,
        filters: const [Text('Filters')],
        actions: const [Text('Add', key: Key('add'))],
      ),
    );

    expect(find.byType(Wrap), findsOneWidget);
    expect(find.byKey(const Key('add')), findsOneWidget);
  });

  /// Real-inset alignment (spec 035 FR-013/FR-014/FR-016). §VI requires this
  /// kind of alignment to be asserted by measuring actual geometry, not by
  /// inspection or by checking that a token was referenced — the whole defect
  /// was two numbers (a per-screen `EdgeInsets.all(8)` and `cardTheme`'s
  /// tier-dependent `cardPadding`) that were each individually "right" and
  /// simply did not agree.
  group('aligns with the list surface beneath it (FR-013/FR-014/FR-016)', () {
    /// Pumps the bar above a real [DataTableView] under the *real* app theme
    /// — a bare `ThemeData` would give the `Card` Flutter's own 4dp default
    /// margin instead of `cardPadding`, so the two would trivially disagree
    /// and the test would prove nothing about production.
    Future<void> pumpBarOverTable(WidgetTester tester, double width) async {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final base = AppTheme.of(
        const BrandConfig(displayName: 'Test'),
      ).light;

      await tester.pumpWidget(
        MaterialApp(
          theme: base,
          builder: (context, child) => Theme(
            data: DesignTheme.forTier(
              Theme.of(context),
              LayoutBreakpoints.tierOfContext(context),
            ),
            child: child!,
          ),
          home: Scaffold(
            body: Column(
              children: [
                CatalogFilterBar(
                  search: const TextField(key: Key('search')),
                  filters: const [
                    Icon(Icons.tune, key: Key('filters')),
                  ],
                ),
                Expanded(
                  child: DataTableView<int>(
                    key: const Key('table'),
                    columns: [
                      DataTableColumn<int>.text(
                        label: 'N',
                        text: (n) => '$n',
                      ),
                    ],
                    rows: const [1, 2],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    for (final width in <double>[700, 900, 1300]) {
      testWidgets('content edges match the table card at ${width}px', (
        tester,
      ) async {
        await pumpBarOverTable(tester, width);

        // The Card's own RenderBox *includes* its margin (Card builds a
        // `Container(margin: ...)` around its `Material`), so measuring the
        // Card would compare against the page edge, not the visible surface.
        // The inner Material is where the table actually starts.
        final table = tester.getRect(
          find
              .descendant(
                of: find.byType(Card).first,
                matching: find.byType(Material),
              )
              .first,
        );
        final search = tester.getRect(find.byKey(const Key('search')));
        final filters = tester.getRect(find.byKey(const Key('filters')));

        // Left edges line up exactly — this is the "rectangle 1" gap.
        expect(
          search.left,
          moreOrLessEquals(table.left, epsilon: 0.5),
          reason: 'search box left edge must match the table card left edge',
        );

        if (width >= LayoutBreakpoints.expanded) {
          // Single-row layout: the last trailing control ends flush with the
          // table's right edge — this is the "rectangle 2" gap. The old
          // `Padding(right: 8)` on every trailing widget put it 8dp short of
          // its own row's edge, independent of the outer inset.
          expect(
            filters.right,
            moreOrLessEquals(table.right, epsilon: 0.5),
            reason:
                'last filter control right edge must match the table card '
                'right edge',
          );
        } else {
          // Reflowed layout: filters wrap onto their own left-aligned line,
          // so the meaningful assertion is that the wrap starts on the same
          // left edge, not that it reaches the right one.
          expect(
            filters.left,
            moreOrLessEquals(table.left, epsilon: 0.5),
            reason:
                'reflowed filters must start on the table card left edge',
          );
        }
      });
    }
  });
}
