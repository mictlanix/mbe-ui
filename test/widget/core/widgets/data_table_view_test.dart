import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/app/theme/app_theme.dart';
import 'package:mbe_ui/core/branding/brand_config.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';

void main() {
  List<DataTableColumn<int>> columns() => [
    DataTableColumn<int>.text(label: 'ID', text: (i) => 'ID-$i'),
    DataTableColumn<int>.text(label: 'A', text: (i) => 'a' * 40),
    DataTableColumn<int>.text(label: 'B', text: (i) => 'b' * 40),
  ];

  testWidgets('never pins a column during horizontal scroll, unpaginated '
      '(FR-001)', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DataTableView<int>(columns: columns(), rows: const [1, 2, 3]),
        ),
      ),
    );

    final table = tester.widget<DataTable2>(find.byType(DataTable2));
    expect(table.fixedLeftColumns, 0);
  });

  testWidgets('never pins a column during horizontal scroll, paginated '
      '(FR-001)', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DataTableView<int>(
            columns: columns(),
            rows: const [1, 2, 3],
            pagination: const CatalogPage(
              items: [1, 2, 3],
              total: 3,
              pageIndex: 0,
              pageSize: 20,
            ),
            onPageChanged: (_) {},
          ),
        ),
      ),
    );

    final table = tester.widget<PaginatedDataTable2>(
      find.byType(PaginatedDataTable2),
    );
    expect(table.fixedLeftColumns, 0);
  });

  testWidgets(
    'does not render blank filler rows when the result set is smaller than '
    'one page — a short catalog must not look like it has extra padding '
    'below its real data (spec 011 follow-up: renderEmptyRowsInTheEnd)',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DataTableView<int>(
              columns: columns(),
              rows: const [1, 2, 3],
              pagination: const CatalogPage(
                items: [1, 2, 3],
                total: 3,
                pageIndex: 0,
                pageSize: 20,
              ),
              onPageChanged: (_) {},
            ),
          ),
        ),
      );

      final table = tester.widget<PaginatedDataTable2>(
        find.byType(PaginatedDataTable2),
      );
      expect(table.renderEmptyRowsInTheEnd, isFalse);

      // Only the 3 real rows' first-column cells appear — no blank rows
      // padding the table out to the 20-row page size.
      expect(find.text('ID-1'), findsOneWidget);
      expect(find.text('ID-2'), findsOneWidget);
      expect(find.text('ID-3'), findsOneWidget);
    },
  );

  testWidgets(
    'shows page-0 rows after a mutation resets the provider to page 0 while '
    'viewing a later page, instead of staying stuck on a stale row cursor '
    'and rendering blank rows (live-verified regression: creating/editing/ '
    'deleting a record invalidates the list provider, which always refetches '
    'page 0 — PaginatedDataTable2 must resync, not keep showing the old '
    'page)',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DataTableView<int>(
              columns: columns(),
              rows: const [21],
              pagination: const CatalogPage(
                items: [21],
                total: 21,
                pageIndex: 1,
                pageSize: 20,
              ),
              onPageChanged: (_) {},
            ),
          ),
        ),
      );
      expect(find.text('ID-21'), findsOneWidget);

      // Simulate `_invalidateCaches()`: the provider is invalidated and its
      // `build()` always refetches page 0, regardless of which page was
      // being viewed — same widget tree position, new pagination state.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DataTableView<int>(
              columns: columns(),
              rows: const [1, 2, 3],
              pagination: const CatalogPage(
                items: [1, 2, 3],
                total: 21,
                pageIndex: 0,
                pageSize: 20,
              ),
              onPageChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('ID-1'), findsOneWidget);
      expect(find.text('ID-2'), findsOneWidget);
      expect(find.text('ID-3'), findsOneWidget);
    },
  );

  testWidgets(
    'passes minWidth through to the unpaginated table, so a wide column set '
    'scrolls within its own region rather than the page (spec 033 research.md '
    '§R2, constitution §VI)',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DataTableView<int>(
              columns: columns(),
              rows: const [1, 2, 3],
              minWidth: 2000,
            ),
          ),
        ),
      );

      final table = tester.widget<DataTable2>(find.byType(DataTable2));
      expect(table.minWidth, 2000);
    },
  );

  testWidgets('passes minWidth through to the paginated table', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DataTableView<int>(
            columns: columns(),
            rows: const [1, 2, 3],
            pagination: const CatalogPage(
              items: [1, 2, 3],
              total: 3,
              pageIndex: 0,
              pageSize: 20,
            ),
            onPageChanged: (_) {},
            minWidth: 2000,
          ),
        ),
      ),
    );

    final table = tester.widget<PaginatedDataTable2>(
      find.byType(PaginatedDataTable2),
    );
    expect(table.minWidth, 2000);
  });

  testWidgets(
    'omitting minWidth leaves both tables at their default (null) — no '
    'behaviour change for every existing caller',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DataTableView<int>(columns: columns(), rows: const [1, 2, 3]),
          ),
        ),
      );

      final table = tester.widget<DataTable2>(find.byType(DataTable2));
      expect(table.minWidth, isNull);
    },
  );

  group('shrinkWrap (spec 049 US5)', () {
    // The real app theme: a bare ThemeData has no card border and a 4dp
    // margin, so it would not exercise the border/margin arithmetic.
    Future<void> pumpShrunk(
      WidgetTester tester,
      int rowCount, {
      EdgeInsetsGeometry? margin = EdgeInsets.zero,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.of(const BrandConfig(displayName: 'Test')).light,
          home: Scaffold(
            body: SingleChildScrollView(
              child: DataTableView<int>(
                columns: columns(),
                rows: [for (var i = 0; i < rowCount; i++) i],
                shrinkWrap: true,
                margin: margin,
              ),
            ),
          ),
        ),
      );
    }

    for (final (count, margin) in [
      (1, EdgeInsets.zero),
      (8, EdgeInsets.zero),
      (1, null),
      (8, null),
    ]) {
      testWidgets('sizes to $count row(s) with margin $margin: no vertical '
          'scroll, no blank space', (tester) async {
        await pumpShrunk(tester, count, margin: margin);

        final vertical = tester
            .stateList<ScrollableState>(
              find.descendant(
                of: find.byType(DataTable2),
                matching: find.byType(Scrollable),
              ),
            )
            .where((s) => s.position.axis == Axis.vertical);
        expect(vertical, isNotEmpty);
        for (final scrollable in vertical) {
          expect(scrollable.position.maxScrollExtent, 0);
        }
        // Heading + rows are fully visible: the last row's bottom is within
        // the table's own bounds.
        final table = tester.getRect(find.byType(DataTable2));
        final lastRow = tester.getRect(find.text('ID-${count - 1}'));
        expect(lastRow.bottom, lessThanOrEqualTo(table.bottom));
        // No unneeded blank space: the table is exactly its heading, its
        // rows and their dividers tall.
        final widget = tester.widget<DataTable2>(find.byType(DataTable2));
        expect(
          table.height,
          widget.headingRowHeight! +
              count * widget.dataRowHeight! +
              (count + 1) * widget.dividerThickness!,
        );
      });
    }

    testWidgets('margin overrides the card margin', (tester) async {
      await pumpShrunk(tester, 2);

      final card = tester.getRect(find.byType(Card));
      final table = tester.getRect(find.byType(DataTable2));
      expect(card.left, table.left);
      expect(card.right, table.right);
      expect(card.left, 0);
    });
  });
}
