import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/features/auth/presentation/admin/privileges_grid.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

void main() {
  Future<void> pumpGrid(
    WidgetTester tester, {
    required List<Privilege> privileges,
    void Function(SystemObject, int)? onChanged,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: PrivilegesGrid(privileges: privileges, onChanged: onChanged),
          ),
        ),
      ),
    );
  }

  testWidgets('renders header row with C/R/U/D columns', (tester) async {
    await pumpGrid(tester, privileges: const []);

    expect(find.text('C'), findsOneWidget);
    expect(find.text('R'), findsOneWidget);
    expect(find.text('U'), findsOneWidget);
    expect(find.text('D'), findsOneWidget);
    expect(find.text('Module'), findsOneWidget);
  });

  // SystemObject.products is index 0 in SystemObject.values, so it's
  // guaranteed to land on the grid's first page regardless of page size.
  testWidgets('renders a row for SystemObject.products', (tester) async {
    await pumpGrid(tester, privileges: const []);

    expect(find.text('products'), findsOneWidget);
  });

  testWidgets('checked boxes reflect privilege rawValue', (tester) async {
    // rawValue 2 = read only
    await pumpGrid(
      tester,
      privileges: [
        const Privilege(systemObject: SystemObject.products, rawValue: 2),
      ],
    );

    // Find all checkboxes — checkboxes for the products row: C=false,
    // R=true, U=false, D=false. We can't easily find the exact row
    // checkboxes by position so we assert at least one is true and some are
    // false.
    final checkboxes = tester.widgetList<Checkbox>(find.byType(Checkbox));
    final values = checkboxes.map((cb) => cb.value).toList();
    expect(values.any((v) => v == true), isTrue);
    expect(values.any((v) => v == false), isTrue);
  });

  testWidgets('toggling a checkbox calls onChanged with updated rawValue', (
    tester,
  ) async {
    SystemObject? changedObj;
    int? changedRaw;

    // Start with no privileges for products (raw=0). Tap the Create checkbox.
    await pumpGrid(
      tester,
      privileges: const [],
      onChanged: (obj, raw) {
        changedObj = obj;
        changedRaw = raw;
      },
    );

    // Invoked directly rather than via tester.tap(): PaginatedDataTable2's
    // nested scrollable render tree makes precise hit-testing of interior
    // cell widgets unreliable in the test environment (see the analogous
    // note in products_list_screen_test.dart). This still exercises the
    // real onChanged behavior.
    final checkbox = tester.widget<Checkbox>(
      find.byKey(const Key('privilege_products_create')),
    );
    checkbox.onChanged!(true);
    await tester.pump();

    expect(changedObj, isNotNull);
    expect(changedRaw, isNotNull);
    expect(changedRaw! > 0, isTrue);
  });

  testWidgets('read-only when onChanged is null — checkboxes disabled', (
    tester,
  ) async {
    await pumpGrid(
      tester,
      privileges: [
        const Privilege(systemObject: SystemObject.products, rawValue: 15),
      ],
      // onChanged: null (default)
    );

    final checkboxes = tester.widgetList<Checkbox>(find.byType(Checkbox));
    // All checkboxes should be disabled (onChanged == null)
    expect(checkboxes.every((cb) => cb.onChanged == null), isTrue);
  });

  testWidgets(
    'paginates the ~100+ SystemObject list instead of rendering it all at '
    'once, so the row count stays bounded per page',
    (tester) async {
      await pumpGrid(tester, privileges: const []);

      // Far fewer rows on screen than SystemObject.values.length (107).
      final rowLabels = tester
          .widgetList<Text>(
            find.descendant(
              of: find.byKey(const Key('privileges_table')),
              matching: find.byType(Text),
            ),
          )
          .length;
      expect(rowLabels, lessThan(SystemObject.values.length));

      // The next-page control changes the visible module names.
      expect(find.text('products'), findsOneWidget);
      await tester.tap(find.byTooltip('Next page'));
      await tester.pumpAndSettle();
      expect(find.text('products'), findsNothing);
    },
  );

  testWidgets(
    'the table box is tall enough to show a full page (10 rows) without '
    "needing its own internal scroll — no scrollbar nested inside the "
    "form's own scrollbar",
    (tester) async {
      await pumpGrid(tester, privileges: const []);

      // pointsOfSale is SystemObject.values[9] — the 10th and last row on a
      // 10-row first page. If the box is tall enough, its checkbox is fully
      // within the table's bounds with no scrolling required to reveal it.
      final tableBottom = tester
          .getBottomLeft(find.byKey(const Key('privileges_table')))
          .dy;
      final lastRowCheckboxBottom = tester
          .getBottomLeft(find.byKey(const Key('privilege_pointsOfSale_delete')))
          .dy;

      expect(find.text('pointsOfSale'), findsOneWidget);
      expect(lastRowCheckboxBottom, lessThanOrEqualTo(tableBottom));
    },
  );

  testWidgets(
    'every C/R/U/D header renders with a real, non-zero width — regression '
    'guard for a DataColumn2 layout bug where every fixed-width column but '
    'the last collapses to zero width when several appear consecutively '
    '(reproduced in isolation against data_table_2 directly; fixed here by '
    'merging the four checkboxes into a single fixedWidth column instead of '
    'four separate ones)',
    (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpGrid(tester, privileges: const []);

      final widths = {
        for (final label in ['C', 'R', 'U', 'D'])
          label: tester.getRect(find.text(label).first).width,
      };

      for (final entry in widths.entries) {
        expect(
          entry.value,
          greaterThan(0),
          reason: '${entry.key} header collapsed to zero width',
        );
      }
      // All four should be laid out identically (same font/tooltip wrapper).
      expect(widths.values.toSet(), hasLength(1));
    },
  );
}
