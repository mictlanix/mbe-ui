import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/widgets/catalog_action_icons.dart';

void main() {
  Widget wrap(List<Widget> children) => MaterialApp(
        home: Scaffold(body: Row(children: children)),
      );

  testWidgets(
      'renders view, edit, delete in that fixed left-to-right order (FR-004)',
      (tester) async {
    await tester.pumpWidget(
      wrap(
        buildCatalogRowActions(
          viewTooltip: 'View',
          editTooltip: 'Edit',
          deleteTooltip: 'Delete',
          onView: () {},
          onEdit: () {},
          onDelete: () {},
        ),
      ),
    );

    final icons = tester
        .widgetList<IconButton>(find.byType(IconButton))
        .map((b) => (b.icon as Icon).icon)
        .toList();

    expect(icons, [
      CatalogAction.view.icon,
      CatalogAction.edit.icon,
      CatalogAction.delete.icon,
    ]);
  });

  testWidgets('omits an action when its callback is null, rather than '
      'disabling it (FR-012)', (tester) async {
    await tester.pumpWidget(
      wrap(
        buildCatalogRowActions(
          viewTooltip: 'View',
          editTooltip: 'Edit',
          deleteTooltip: 'Delete',
          onView: () {},
          onEdit: null,
          onDelete: null,
        ),
      ),
    );

    expect(find.byType(IconButton), findsOneWidget);
    expect(
      tester.widget<IconButton>(find.byType(IconButton)).onPressed,
      isNotNull,
    );
  });

  test('each action maps to exactly one icon glyph (FR-005)', () {
    expect(CatalogAction.create.icon, Icons.add);
    expect(CatalogAction.view.icon, Icons.visibility_outlined);
    expect(CatalogAction.edit.icon, Icons.edit_outlined);
    expect(CatalogAction.delete.icon, Icons.delete_outline);
  });
}
