import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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
          body: DataTableView<int>(
            columns: columns(),
            rows: const [1, 2, 3],
          ),
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
}
