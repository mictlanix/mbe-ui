import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/navigation/list_search_submit.dart';

/// Unit coverage of `submitCatalogSearch` (spec 035 FR-008/FR-009/FR-011),
/// exercised through a minimal real `GoRouter` rather than a mocked
/// `BuildContext` — `context.go` is an extension method with no interface to
/// fake, so a router is the direct way to observe whether navigation
/// happened at all.
void main() {
  Future<GoRouter> pumpRouter(WidgetTester tester, {required String path}) async {
    final router = GoRouter(
      initialLocation: path,
      routes: [
        GoRoute(
          path: '/list',
          builder: (_, _) => const Scaffold(body: Text('list')),
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    return router;
  }

  testWidgets(
    'a changed term navigates with the new search and a reset page index, '
    'and does NOT call refresh (FR-009: exactly one path, never both)',
    (tester) async {
      final router = await pumpRouter(tester, path: '/list?page=3');
      var refreshCalled = false;

      submitCatalogSearch(
        context: tester.element(find.text('list')),
        query: const ListQuery(pageIndex: 2),
        path: '/list',
        submitted: 'new-term',
        current: '',
        refresh: () => refreshCalled = true,
      );
      await tester.pumpAndSettle();

      expect(refreshCalled, isFalse);
      final location = router.routerDelegate.currentConfiguration.uri.toString();
      expect(location, contains('search=new-term'));
      // Page reset to 0 -> no `page` param in the encoded URL (FR-020).
      expect(location, isNot(contains('page=')));
    },
  );

  testWidgets(
    'an unchanged term calls refresh instead of navigating, preserving the '
    'current page/facets (FR-008/FR-011)',
    (tester) async {
      final router = await pumpRouter(tester, path: '/list?page=3');
      final locationBefore = router.routerDelegate.currentConfiguration.uri.toString();
      var refreshCalled = false;

      submitCatalogSearch(
        context: tester.element(find.text('list')),
        query: const ListQuery(search: 'same', pageIndex: 2),
        path: '/list',
        submitted: 'same',
        current: 'same',
        refresh: () => refreshCalled = true,
      );
      await tester.pumpAndSettle();

      expect(refreshCalled, isTrue);
      // No navigation occurred at all — the route is exactly what it was.
      final locationAfter = router.routerDelegate.currentConfiguration.uri.toString();
      expect(locationAfter, locationBefore);
    },
  );

  testWidgets('an empty-to-empty submission (search cleared, then re-submitted '
      'unchanged) still calls refresh, not navigation', (tester) async {
    final router = await pumpRouter(tester, path: '/list');
    var refreshCalled = false;

    submitCatalogSearch(
      context: tester.element(find.text('list')),
      query: const ListQuery(),
      path: '/list',
      submitted: '',
      current: '',
      refresh: () => refreshCalled = true,
    );
    await tester.pumpAndSettle();

    expect(refreshCalled, isTrue);
    expect(router.routerDelegate.currentConfiguration.uri.toString(), '/list');
  });
}
