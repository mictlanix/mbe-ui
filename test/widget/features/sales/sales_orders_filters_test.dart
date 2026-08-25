import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/access/user_settings.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/repositories/sales_order_repository.dart';
import 'package:mbe_ui/features/sales/presentation/orders/sales_orders_list_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import 'pos_test_harness.dart';
import 'sales_orders_list_screen_test.dart' show stubListOrders;

class _FixedAuthNotifier extends AuthNotifier {
  _FixedAuthNotifier(this._state);
  final AuthState _state;
  @override
  Future<AuthState> build() async => _state;
}

User _user({int? facilityId = 9}) => User(
  userId: 'salesperson-1',
  email: 'salesperson@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  settings: facilityId == null ? null : UserSettings(facilityId: facilityId),
  privileges: [
    Privilege(systemObject: SystemObject.salesOrders, rawValue: 1 | 4),
  ],
);

/// A minimal routed harness for `/sales/orders`, mirroring
/// `pos_test_harness.dart`'s `pumpPosRouted` — that helper only wires the
/// three POS routes, so this feature needs its own for tests that drive
/// real navigation (facet taps that call `context.go`) rather than a bare
/// widget pump.
Future<GoRouter> pumpOrdersRouted(
  WidgetTester tester, {
  List<Override> overrides = const [],
  String initialLocation = '/sales/orders',
}) async {
  tester.view.physicalSize = const Size(1200, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({});
  final sharedPreferences = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ...overrides,
    ],
  );
  addTearDown(container.dispose);

  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/sales/orders',
        builder: (context, state) =>
            Scaffold(body: SalesOrdersListScreen(query: ListQuery.fromUri(state.uri))),
      ),
    ],
  );

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        routerConfig: router,
        locale: const Locale('es', 'MX'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

/// FR-008, FR-009, FR-010, FR-013: date range and status facets narrow the
/// list and land in the address; clearing returns to the current month,
/// never to unbounded; an out-of-range page clamps to the last one.
void main() {
  late MockSalesOrderRepository salesOrders;

  setUp(() {
    salesOrders = MockSalesOrderRepository();
  });

  Future<GoRouter> pumpListRouted(
    WidgetTester tester, {
    ListQuery query = const ListQuery(),
  }) {
    return pumpOrdersRouted(
      tester,
      initialLocation: query.toUri('/sales/orders').toString(),
      overrides: [
        authNotifierProvider.overrideWith(
          () => _FixedAuthNotifier(AuthState.authenticated(token: 't', user: _user())),
        ),
        salesOrderOverride(salesOrders),
      ],
    );
  }

  testWidgets('the status facet narrows the request and lands in the '
      'address, counted in the badge', (tester) async {
    stubListOrders(salesOrders, page: testSalesPage(const []));

    final router = await pumpListRouted(tester);
    await tester.tap(find.byKey(const Key('sales_orders_filter_button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('sales_orders_filter_status_draft')));
    await tester.pumpAndSettle();

    expect(router.state.uri.queryParameters['status'], 'draft');
    verify(
      () => salesOrders.listOrders(
        mine: any(named: 'mine'),
        facility: any(named: 'facility'),
        salesperson: any(named: 'salesperson'),
        status: SaleStatus.draft,
        dateFrom: any(named: 'dateFrom'),
        dateTo: any(named: 'dateTo'),
        search: any(named: 'search'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).called(greaterThan(0));

    final badge = tester.widget<Badge>(
      find.ancestor(
        of: find.byKey(const Key('sales_orders_filter_button')),
        matching: find.byType(Badge),
      ),
    );
    expect(badge.isLabelVisible, isTrue);
  });

  testWidgets('the date-range facet narrows the request and lands in the '
      'address', (tester) async {
    stubListOrders(salesOrders, page: testSalesPage(const []));

    final router = await pumpListRouted(tester);
    await tester.tap(find.byKey(const Key('sales_orders_filter_button')));
    await tester.pumpAndSettle();

    // The date-range chip opens a picker dialog; simplest deterministic
    // check here is the encoded facet round-trip, exercised directly
    // through the URL rather than driving the calendar UI.
    router.go(
      const ListQuery()
          .withFacet('date-from', '2026-08-01')
          .withFacet('date-to', '2026-08-05')
          .toUri('/sales/orders')
          .toString(),
    );
    await tester.pumpAndSettle();

    verify(
      () => salesOrders.listOrders(
        mine: any(named: 'mine'),
        facility: any(named: 'facility'),
        salesperson: any(named: 'salesperson'),
        status: any(named: 'status'),
        // The repository interface itself receives calendar-date midnights
        // — end-of-day widening (`wireDateEnd`) happens one layer down, in
        // `sales_order_repository_impl.dart`, past what this mock sees.
        dateFrom: DateTime(2026, 8, 1),
        dateTo: DateTime(2026, 8, 5),
        search: any(named: 'search'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).called(greaterThan(0));
  });

  testWidgets('clear-all returns the range to the current month — never to '
      'unbounded', (tester) async {
    stubListOrders(salesOrders, page: testSalesPage(const []));

    final router = await pumpListRouted(
      tester,
      query: const ListQuery().withFacet('status', 'draft'),
    );
    await tester.tap(find.byKey(const Key('sales_orders_filter_button')));
    await tester.pumpAndSettle();

    // Spanish shares one string ("Limpiar filtros") between the sheet's
    // clear-all button and the empty-state's clear-filters button, so a
    // text finder alone is ambiguous here — target the sheet button's key.
    await tester.tap(find.byKey(const Key('filter_sheet_clear_all_button')));
    await tester.pumpAndSettle();

    expect(router.state.uri.queryParameters.containsKey('status'), isFalse);
    expect(router.state.uri.queryParameters.containsKey('date-from'), isFalse);
    expect(router.state.uri.queryParameters.containsKey('date-to'), isFalse);
  });

  testWidgets('an out-of-range page clamps to the last available page rather '
      'than a blank list', (tester) async {
    when(
      () => salesOrders.listOrders(
        mine: any(named: 'mine'),
        facility: any(named: 'facility'),
        salesperson: any(named: 'salesperson'),
        status: any(named: 'status'),
        dateFrom: any(named: 'dateFrom'),
        dateTo: any(named: 'dateTo'),
        search: any(named: 'search'),
        skip: 100,
        limit: 20,
      ),
    ).thenAnswer((_) async => const OpenSalePage(items: [], total: 3));
    when(
      () => salesOrders.listOrders(
        mine: any(named: 'mine'),
        facility: any(named: 'facility'),
        salesperson: any(named: 'salesperson'),
        status: any(named: 'status'),
        dateFrom: any(named: 'dateFrom'),
        dateTo: any(named: 'dateTo'),
        search: any(named: 'search'),
        skip: 0,
        limit: 20,
      ),
    ).thenAnswer(
      // A page's `items` must actually fill up to `total` (or the page
      // size) — a `total` of 3 with only 1 item returned is a page the
      // real API would never produce, and `PaginatedDataTable2` never
      // settles when asked to render rows a page claims but doesn't have.
      (_) async => testSalesPage([
        testOpenSale(id: 1),
        testOpenSale(id: 2),
        testOpenSale(id: 3),
      ]),
    );

    await pumpListRouted(tester, query: const ListQuery(pageIndex: 5));
    await tester.pumpAndSettle();

    expect(find.text('1'), findsOneWidget);
  });
}
