import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/domain/facility_type.dart';
import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/facility.dart';
import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/facility_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/warehouse_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/warehouses_list_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockWarehouseRepository extends Mock implements WarehouseRepository {}

class MockFacilityRepository extends Mock implements FacilityRepository {}

const _readOnlyUser = User(
  userId: 'reader',
  email: 'reader@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.warehouses, rawValue: 2)],
);

const _fullAccessUser = User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.warehouses, rawValue: 15)],
);

final _testWarehouses = [
  Warehouse(
    warehouseId: 1,
    facilityId: 9,
    facilityName: 'Main Store',
    code: 'WH-1',
    name: 'Main Warehouse',
    status: EntityStatus.active,
  ),
  Warehouse(
    warehouseId: 2,
    facilityId: 10,
    facilityName: 'North Plant',
    code: 'WH-2',
    name: 'North Warehouse',
    status: EntityStatus.inactive,
  ),
];

AccessControlService _accessFor(User user) =>
    AccessControlService(AuthState.authenticated(token: 't', user: user));

void main() {
  late MockWarehouseRepository repository;
  late MockFacilityRepository facilityRepository;

  setUp(() {
    repository = MockWarehouseRepository();
    facilityRepository = MockFacilityRepository();
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    required User signedInAs,
    List<Warehouse> warehouses = const [],
    ListQuery query = const ListQuery(),
  }) async {
    when(
      () => repository.list(
        search: any(named: 'search'),
        facilityId: any(named: 'facilityId'),
        status: any(named: 'status'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async =>
          WarehouseListResult(items: warehouses, total: warehouses.length),
    );

    // Mirrors production's shape (app_router.dart): the list lives inside
    // its own `StatefulShellBranch`, with its own nested Navigator distinct
    // from the outer/root one. The filter sheet attaches to the root
    // Navigator (`useRootNavigator: true`, catalog_filter_sheet.dart) so it
    // survives a same-branch `context.go` on every live filter change — a
    // flat single-Navigator router would conflate the two and tear the
    // sheet down after the first change.
    final router = GoRouter(
      initialLocation: query.toUri('/warehouses').toString(),
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) => navigationShell,
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/warehouses',
                  builder: (_, state) => Scaffold(
                    body: WarehousesListScreen(
                      query: ListQuery.fromUri(state.uri),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          warehouseRepositoryProvider.overrideWithValue(repository),
          facilityRepositoryProvider.overrideWithValue(facilityRepository),
          accessControlProvider.overrideWithValue(_accessFor(signedInAs)),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'shows facility name (not a raw id) for every warehouse (FR-015)',
    (tester) async {
      await pumpScreen(
        tester,
        signedInAs: _fullAccessUser,
        warehouses: _testWarehouses,
      );

      expect(find.text('Main Store'), findsOneWidget);
      expect(find.text('North Plant'), findsOneWidget);
    },
  );

  testWidgets('shows an inactive badge for an inactive warehouse', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      signedInAs: _fullAccessUser,
      warehouses: _testWarehouses,
    );

    expect(find.byKey(const Key('status_badge_inactive')), findsOneWidget);
  });

  testWidgets('search box, pagination, and filter button are present', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      signedInAs: _fullAccessUser,
      warehouses: _testWarehouses,
    );

    expect(find.byKey(const Key('warehouses_search_field')), findsOneWidget);
    expect(find.byType(PaginatedDataTable2), findsOneWidget);
    expect(find.byKey(const Key('warehouses_filter_button')), findsOneWidget);
  });

  testWidgets(
    'the Edit row icon is hidden (not disabled) without update privilege '
    '(constitution §VI)',
    (tester) async {
      await pumpScreen(tester, signedInAs: _readOnlyUser);

      expect(find.byIcon(Icons.edit_outlined), findsNothing);
    },
  );

  testWidgets('the Create button is hidden without create privilege', (
    tester,
  ) async {
    await pumpScreen(tester, signedInAs: _readOnlyUser);

    expect(find.byKey(const Key('new_warehouse_button')), findsNothing);
  });

  testWidgets(
    'a row click opens the read-only detail view (constitution §VI)',
    (tester) async {
      when(
        () => repository.list(
          search: any(named: 'search'),
          facilityId: any(named: 'facilityId'),
          status: any(named: 'status'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => WarehouseListResult(
          items: _testWarehouses,
          total: _testWarehouses.length,
        ),
      );

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, state) => Scaffold(
              body: WarehousesListScreen(query: ListQuery.fromUri(state.uri)),
            ),
          ),
          GoRoute(
            path: '/warehouses/:warehouseId',
            builder: (_, state) => Scaffold(body: Text(state.uri.toString())),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            warehouseRepositoryProvider.overrideWithValue(repository),
            facilityRepositoryProvider.overrideWithValue(facilityRepository),
            accessControlProvider.overrideWithValue(
              _accessFor(_fullAccessUser),
            ),
          ],
          child: MaterialApp.router(
            routerConfig: router,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Main Warehouse'));
      await tester.pumpAndSettle();

      expect(find.text('/warehouses/1?view=true'), findsOneWidget);
    },
  );

  testWidgets('an empty result shows the empty state', (tester) async {
    await pumpScreen(tester, signedInAs: _fullAccessUser, warehouses: const []);

    expect(find.byKey(const Key('warehouses_table')), findsNothing);
  });

  group('URL-driven filters (017-ui-consistency-filters US3)', () {
    testWidgets(
      'a status facet in the URL is passed to the repository',
      (tester) async {
        await pumpScreen(
          tester,
          signedInAs: _fullAccessUser,
          warehouses: _testWarehouses,
          query: const ListQuery(
            facets: {
              'status': ['inactive'],
            },
          ),
        );

        verify(
          () => repository.list(
            search: any(named: 'search'),
            facilityId: any(named: 'facilityId'),
            status: EntityStatus.inactive,
            skip: any(named: 'skip'),
            limit: any(named: 'limit'),
          ),
        ).called(greaterThanOrEqualTo(1));
      },
    );

    testWidgets(
      'a facility facet in the URL is passed to the repository, and its '
      'name is resolved for cold-load display (data-model.md §4)',
      (tester) async {
        when(
          () => facilityRepository.get(facilityId: 9),
        ).thenAnswer(
          (_) async => const Facility(
            facilityId: 9,
            code: 'F-9',
            name: 'Main Store',
            type: FacilityType.store,
            locationId: 'MX',
            locationLabel: 'Mexico',
            addressId: 1,
            addressLabel: 'Main St',
            taxpayerRfc: 'AAA010101AAA',
            status: EntityStatus.active,
          ),
        );

        await pumpScreen(
          tester,
          signedInAs: _fullAccessUser,
          warehouses: _testWarehouses,
          query: const ListQuery(
            facets: {
              'facility': ['9'],
            },
          ),
        );

        verify(
          () => repository.list(
            search: any(named: 'search'),
            facilityId: 9,
            status: any(named: 'status'),
            skip: any(named: 'skip'),
            limit: any(named: 'limit'),
          ),
        ).called(greaterThanOrEqualTo(1));

        await tester.tap(find.byKey(const Key('warehouses_filter_button')));
        await tester.pumpAndSettle();

        expect(
          find.descendant(
            of: find.byKey(const Key('warehouses_filter_facility')),
            matching: find.text('Main Store'),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'selecting a status filter navigates to a URL carrying that facet',
      (tester) async {
        final router = GoRouter(
          initialLocation: '/warehouses',
          routes: [
            GoRoute(
              path: '/warehouses',
              builder: (_, state) => Scaffold(
                body: WarehousesListScreen(query: ListQuery.fromUri(state.uri)),
              ),
            ),
          ],
        );
        when(
          () => repository.list(
            search: any(named: 'search'),
            facilityId: any(named: 'facilityId'),
            status: any(named: 'status'),
            skip: any(named: 'skip'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer(
          (_) async =>
              WarehouseListResult(items: _testWarehouses, total: 2),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              warehouseRepositoryProvider.overrideWithValue(repository),
              facilityRepositoryProvider.overrideWithValue(
                facilityRepository,
              ),
              accessControlProvider.overrideWithValue(
                _accessFor(_fullAccessUser),
              ),
            ],
            child: MaterialApp.router(
              routerConfig: router,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('warehouses_filter_button')));
        await tester.pumpAndSettle();

        await tester.tap(
          find.byKey(const Key('warehouses_filter_status_inactive')),
        );
        await tester.pumpAndSettle();

        expect(
          router.routerDelegate.currentConfiguration.uri.toString(),
          '/warehouses?status=inactive',
        );
      },
    );
  });
}
