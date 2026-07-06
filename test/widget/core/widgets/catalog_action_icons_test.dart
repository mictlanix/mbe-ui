import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/widgets/catalog_action_icons.dart';

void main() {
  Widget wrap(List<Widget> children) => MaterialApp(
        home: Scaffold(body: Row(children: children)),
      );

  testWidgets('renders only the Edit action (constitution §VI)',
      (tester) async {
    await tester.pumpWidget(
      wrap(
        buildCatalogRowActions(editTooltip: 'Edit', onEdit: () {}),
      ),
    );

    final icons = tester
        .widgetList<IconButton>(find.byType(IconButton))
        .map((b) => (b.icon as Icon).icon)
        .toList();

    expect(icons, [CatalogAction.edit.icon]);
  });

  testWidgets('omits the Edit action when its callback is null, rather '
      'than disabling it', (tester) async {
    await tester.pumpWidget(
      wrap(buildCatalogRowActions(editTooltip: 'Edit', onEdit: null)),
    );

    expect(find.byType(IconButton), findsNothing);
  });

  test('each action maps to exactly one icon glyph', () {
    expect(CatalogAction.create.icon, Icons.add);
    expect(CatalogAction.edit.icon, Icons.edit_outlined);
  });
}
