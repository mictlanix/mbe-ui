import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/widgets/catalog_action_icons.dart';

void main() {
  Widget wrap(List<Widget> children) => MaterialApp(
    home: Scaffold(body: Row(children: children)),
  );

  testWidgets('renders only the Edit action (constitution §VI)', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(buildCatalogRowActions(editTooltip: 'Edit', onEdit: () {})),
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

  testWidgets(
    'a single extra action renders as its own direct icon beside Edit '
    '(constitution §VI, v1.7.0)',
    (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        wrap(
          buildCatalogRowActions(
            editTooltip: 'Edit',
            onEdit: () {},
            extraActions: [
              CatalogRowAction(
                icon: Icons.sell_outlined,
                tooltip: 'View pricing',
                onPressed: () => tapped = true,
              ),
            ],
          ),
        ),
      );

      final icons = tester
          .widgetList<IconButton>(find.byType(IconButton))
          .map((b) => (b.icon as Icon).icon)
          .toList();
      expect(icons, [CatalogAction.edit.icon, Icons.sell_outlined]);
      expect(find.byType(PopupMenuButton<VoidCallback>), findsNothing);

      await tester.tap(find.byIcon(Icons.sell_outlined));
      expect(tapped, isTrue);
    },
  );

  testWidgets('two or more extra actions collapse into a single overflow menu '
      'instead of stacking more row icons (constitution §VI, v1.7.0)', (
    tester,
  ) async {
    var firstTapped = false;
    var secondTapped = false;
    await tester.pumpWidget(
      wrap(
        buildCatalogRowActions(
          editTooltip: 'Edit',
          onEdit: () {},
          moreActionsTooltip: 'More actions',
          extraActions: [
            CatalogRowAction(
              icon: Icons.sell_outlined,
              tooltip: 'View pricing',
              onPressed: () => firstTapped = true,
            ),
            CatalogRowAction(
              icon: Icons.history,
              tooltip: 'View history',
              onPressed: () => secondTapped = true,
            ),
          ],
        ),
      ),
    );

    // Exactly two icons total: Edit + the overflow trigger (PopupMenuButton
    // renders its own IconButton internally) — no direct icon for either
    // extra action.
    expect(find.byType(IconButton), findsNWidgets(2));
    expect(find.byType(PopupMenuButton<VoidCallback>), findsOneWidget);
    expect(find.byIcon(Icons.sell_outlined), findsNothing);
    expect(find.byIcon(Icons.history), findsNothing);

    await tester.tap(find.byType(PopupMenuButton<VoidCallback>));
    await tester.pumpAndSettle();
    expect(find.text('View pricing'), findsOneWidget);
    expect(find.text('View history'), findsOneWidget);

    await tester.tap(find.text('View pricing'));
    await tester.pumpAndSettle();
    expect(firstTapped, isTrue);
    expect(secondTapped, isFalse);
  });
}
