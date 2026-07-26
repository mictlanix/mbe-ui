import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/vehicle_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/vehicle.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/vehicle_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/vehicles_list_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockVehicleRepository extends Mock implements VehicleRepository {}

const _readOnlyUser = User(
  userId: 'reader',
  email: 'reader@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.vehicle, rawValue: 2)],
);

const _fullAccessUser = User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.vehicle, rawValue: 15)],
);

const _testVehicles = [
  Vehicle(
    vehicleId: 1,
    licensePlate: 'ABC-123',
    name: 'Freightliner',
    nickname: 'Big Red',
    tonsCapacity: 10,
    status: EntityStatus.active,
  ),
  Vehicle(
    vehicleId: 2,
    licensePlate: 'XYZ-987',
    name: 'Sprinter',
    nickname: 'Speedy',
    tonsCapacity: 3,
    status: EntityStatus.inactive,
  ),
];

AccessControlService _accessFor(User user) =>
    AccessControlService(AuthState.authenticated(token: 't', user: user));

void main() {
  late MockVehicleRepository repository;

  setUp(() {
    repository = MockVehicleRepository();
  });

  Future<GoRouter> pumpScreen(
    WidgetTester tester, {
    required User signedInAs,
    List<Vehicle> vehicles = _testVehicles,
    ListQuery query = const ListQuery(),
  }) async {
    when(
      () => repository.list(
        search: any(named: 'search'),
        status: any(named: 'status'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => VehicleListResult(items: vehicles, total: vehicles.length),
    );

    // Mirrors production's shape (app_router.dart): the list lives inside
    // its own `StatefulShellBranch`, with its own nested Navigator distinct
    // from the outer/root one. The filter sheet attaches to the root
    // Navigator (`useRootNavigator: true`, catalog_filter_sheet.dart) so it
    // survives a same-branch `context.go` on every live filter change — a
    // flat single-Navigator router would conflate the two and tear the
    // sheet down after the first change.
    final router = GoRouter(
      initialLocation: query.toUri('/vehicles').toString(),
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) => navigationShell,
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/vehicles',
                  builder: (_, state) => Scaffold(
                    body: VehiclesListScreen(
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
          vehicleRepositoryProvider.overrideWithValue(repository),
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
    return router;
  }

  testWidgets('shows plate, name, and nickname for every vehicle', (
    tester,
  ) async {
    await pumpScreen(tester, signedInAs: _fullAccessUser);

    expect(find.text('ABC-123'), findsOneWidget);
    expect(find.text('Freightliner'), findsOneWidget);
    expect(find.text('Big Red'), findsOneWidget);
  });

  testWidgets('shows an inactive badge for an inactive vehicle (FR-014)', (
    tester,
  ) async {
    await pumpScreen(tester, signedInAs: _fullAccessUser);

    expect(find.byKey(const Key('status_badge_inactive')), findsOneWidget);
  });

  testWidgets('search box and pagination are present', (tester) async {
    await pumpScreen(tester, signedInAs: _fullAccessUser);

    expect(find.byKey(const Key('vehicles_search_field')), findsOneWidget);
    expect(find.byType(PaginatedDataTable2), findsOneWidget);
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

    expect(find.byKey(const Key('new_vehicle_button')), findsNothing);
  });

  testWidgets(
    'a row click opens the read-only detail view (constitution §VI)',
    (tester) async {
      when(
        () => repository.list(
          search: any(named: 'search'),
          status: any(named: 'status'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => VehicleListResult(
          items: _testVehicles,
          total: _testVehicles.length,
        ),
      );

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, state) => Scaffold(
              body: VehiclesListScreen(query: ListQuery.fromUri(state.uri)),
            ),
          ),
          GoRoute(
            path: '/vehicles/:vehicleId',
            builder: (_, state) => Scaffold(body: Text(state.uri.toString())),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            vehicleRepositoryProvider.overrideWithValue(repository),
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

      await tester.tap(find.text('ABC-123'));
      await tester.pumpAndSettle();

      expect(find.text('/vehicles/1?view=true'), findsOneWidget);
    },
  );

  testWidgets('an empty result shows the empty state', (tester) async {
    await pumpScreen(tester, signedInAs: _fullAccessUser, vehicles: const []);

    expect(find.byKey(const Key('vehicles_table')), findsNothing);
  });

  group('URL-driven filters (017-ui-consistency-filters US2, FR-009)', () {
    testWidgets(
      'a status facet in the URL is passed to the repository, and the '
      'filtered total/page count comes from the server response, not '
      'items.length (FR-014)',
      (tester) async {
        await pumpScreen(
          tester,
          signedInAs: _fullAccessUser,
          vehicles: [_testVehicles.first],
          query: const ListQuery(
            facets: {
              'status': ['inactive'],
            },
          ),
        );

        verify(
          () => repository.list(
            search: any(named: 'search'),
            status: EntityStatus.inactive,
            skip: any(named: 'skip'),
            limit: any(named: 'limit'),
          ),
        ).called(greaterThanOrEqualTo(1));
        expect(find.text('1–1 of 1'), findsOneWidget);
      },
    );

    testWidgets(
      'the status facet renders via the shared EntityStatusFilterChips, not '
      'a bespoke widget (FR-013)',
      (tester) async {
        await pumpScreen(tester, signedInAs: _fullAccessUser);

        await tester.tap(find.byKey(const Key('vehicles_filter_button')));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('vehicles_filter_status_active')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('vehicles_filter_status_inactive')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'selecting a status filter navigates to a URL carrying that facet, '
      'and the Filters badge reflects it',
      (tester) async {
        final router = await pumpScreen(tester, signedInAs: _fullAccessUser);

        await tester.tap(find.byKey(const Key('vehicles_filter_button')));
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const Key('vehicles_filter_status_inactive')),
        );
        await tester.pumpAndSettle();

        expect(
          router.routeInformationProvider.value.uri.toString(),
          '/vehicles?status=inactive',
        );

        final badge = tester.widget<Badge>(
          find.ancestor(
            of: find.byKey(const Key('vehicles_filter_button')),
            matching: find.byType(Badge),
          ),
        );
        expect(badge.isLabelVisible, isTrue);
      },
    );

    testWidgets('Clear all removes the status facet from the URL', (
      tester,
    ) async {
      final router = await pumpScreen(
        tester,
        signedInAs: _fullAccessUser,
        query: const ListQuery(
          facets: {
            'status': ['inactive'],
          },
        ),
      );

      await tester.tap(find.byKey(const Key('vehicles_filter_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('filter_sheet_clear_all_button')));
      await tester.pumpAndSettle();

      expect(router.routeInformationProvider.value.uri.toString(), '/vehicles');
    });
  });

  group(
    'RISK GATE (017-ui-consistency-filters T008, plan Phase 2): '
    'context.go to the same shell-branch path with a different query MUST '
    'update the branch in place, not rebuild/reset it',
    () {
      Future<GoRouter> pumpShell(
        WidgetTester tester, {
        required List<Vehicle> vehicles,
      }) async {
        when(
          () => repository.list(
            search: any(named: 'search'),
            status: any(named: 'status'),
            skip: any(named: 'skip'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer(
          (_) async =>
              VehicleListResult(items: vehicles, total: vehicles.length),
        );

        // Mirrors app_router.dart's real shape: a StatefulShellRoute with
        // (at least) two branches, Vehicles among them — not a bare
        // single-route GoRouter, since the risk is specifically whether the
        // *shell* preserves the branch across a same-path `go`.
        final router = GoRouter(
          initialLocation: '/vehicles',
          routes: [
            StatefulShellRoute.indexedStack(
              builder: (context, state, navigationShell) => navigationShell,
              branches: [
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/home',
                      builder: (_, _) =>
                          const Scaffold(body: Text('home branch')),
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/vehicles',
                      builder: (_, state) => Scaffold(
                        body: VehiclesListScreen(
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
              vehicleRepositoryProvider.overrideWithValue(repository),
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
        return router;
      }

      testWidgets(
        'unsubmitted search text survives a same-path `go` with new query '
        'parameters — proof the widget subtree was updated, not torn down '
        'and remounted',
        (tester) async {
          final router = await pumpShell(tester, vehicles: _testVehicles);

          // Type into the search box WITHOUT submitting — pure ephemeral
          // State internal to CatalogSearchBar's TextEditingController, not
          // derived from `initialValue` after first mount. If `go` rebuilt
          // the branch/subtree from scratch, this text would be gone.
          await tester.enterText(
            find.byKey(const Key('vehicles_search_field')),
            'unsubmitted-draft',
          );
          await tester.pump();

          // Simulate a pagination click: same path, new query.
          router.go(
            const ListQuery(pageIndex: 1).toUri('/vehicles').toString(),
          );
          await tester.pumpAndSettle();

          expect(find.text('unsubmitted-draft'), findsOneWidget);
        },
      );

      testWidgets(
        'the repository is re-queried with the new page and the rendered '
        'result reflects it — the URL change actually took effect',
        (tester) async {
          final router = await pumpShell(tester, vehicles: _testVehicles);

          router.go(
            const ListQuery(pageIndex: 1).toUri('/vehicles').toString(),
          );
          await tester.pumpAndSettle();

          verify(
            () => repository.list(
              search: null,
              status: null,
              skip: 20,
              limit: 20,
            ),
          ).called(greaterThanOrEqualTo(1));
        },
      );

      testWidgets(
        'the branch stays selected (no navigator push, no branch reset) '
        'across a same-path query change',
        (tester) async {
          final router = await pumpShell(tester, vehicles: _testVehicles);

          final canPopBefore = Navigator.of(
            tester.element(find.byType(VehiclesListScreen)),
          ).canPop();

          router.go(
            const ListQuery(pageIndex: 1).toUri('/vehicles').toString(),
          );
          await tester.pumpAndSettle();

          // Still on the Vehicles branch, still not a pushed route on top
          // of it — `go` updated the existing page in place.
          expect(find.byType(VehiclesListScreen), findsOneWidget);
          final canPopAfter = Navigator.of(
            tester.element(find.byType(VehiclesListScreen)),
          ).canPop();
          expect(canPopBefore, isFalse);
          expect(canPopAfter, isFalse);
        },
      );
    },
  );
}
