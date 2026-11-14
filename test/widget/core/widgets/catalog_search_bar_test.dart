import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/widgets/catalog_search_bar.dart';

void main() {
  Future<List<String>> pump(WidgetTester tester) async {
    final submitted = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(),
          ),
        ),
        home: Scaffold(
          body: CatalogSearchBar(
            label: 'Search',
            searchTooltip: 'Go',
            onSubmitted: submitted.add,
          ),
        ),
      ),
    );
    return submitted;
  }

  testWidgets('shows exactly one search icon', (tester) async {
    await pump(tester);

    expect(find.byIcon(Icons.search), findsOneWidget);
  });

  testWidgets('the icon button submits the typed text', (tester) async {
    final submitted = await pump(tester);

    await tester.enterText(find.byType(TextField), 'clavo');
    expect(submitted, isEmpty);
    await tester.tap(find.byIcon(Icons.search));

    expect(submitted, ['clavo']);
  });

  testWidgets('Enter submits; typing alone does not', (tester) async {
    final submitted = await pump(tester);

    await tester.enterText(find.byType(TextField), 'tornillo');
    await tester.pump();
    expect(submitted, isEmpty);

    await tester.testTextInput.receiveAction(TextInputAction.search);
    expect(submitted, ['tornillo']);
  });

  testWidgets('enabled and focused borders are stadium-shaped', (tester) async {
    await pump(tester);

    final decoration = tester
        .widget<TextField>(find.byType(TextField))
        .decoration!;
    final height = tester.getSize(find.byType(TextField)).height;
    for (final border in [decoration.enabledBorder, decoration.focusedBorder]) {
      expect(border, isA<OutlineInputBorder>());
      final radius = (border! as OutlineInputBorder).borderRadius.topLeft.x;
      expect(radius, greaterThanOrEqualTo(height / 2));
    }
  });

  testWidgets('input formatters filter what is typed (spec 061 C2)', (
    tester,
  ) async {
    final submitted = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CatalogSearchBar(
            label: 'Folio',
            onSubmitted: submitted.add,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'a1b2');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pump();

    expect(find.text('12'), findsOneWidget);
    expect(submitted, ['12']);
  });
}
