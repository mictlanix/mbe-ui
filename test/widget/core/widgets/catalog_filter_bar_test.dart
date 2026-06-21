import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/widgets/catalog_filter_bar.dart';

void main() {
  Widget wrap(double width, {required List<Widget> filters}) => MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: width,
            child: CatalogFilterBar(
              search: const TextField(key: Key('search')),
              filters: filters,
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
  });

  testWidgets('reflows search + filters into a Wrap below 840px width',
      (tester) async {
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
}
