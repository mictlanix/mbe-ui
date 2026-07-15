import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/widgets/catalog_filter_bar.dart';

void main() {
  Widget wrap(
    double width, {
    List<Widget> filters = const [],
    List<Widget> actions = const [],
  }) =>
      MaterialApp(
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

  testWidgets('actions remain present, reflowed, at narrow width (FR-021)',
      (tester) async {
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
}
