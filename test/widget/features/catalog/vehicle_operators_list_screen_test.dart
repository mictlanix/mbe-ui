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
import 'package:mbe_ui/features/catalog/data/employee_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/vehicle_operator_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/employee.dart';
import 'package:mbe_ui/features/catalog/domain/entities/employee_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/vehicle_operator.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/employee_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/vehicle_operator_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/vehicle_operators_list_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockVehicleOperatorRepository extends Mock
    implements VehicleOperatorRepository {}

class MockEmployeeRepository extends Mock implements EmployeeRepository {}

const _readOnlyUser = User(
  userId: 'reader',
  email: 'reader@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [
    Privilege(systemObject: SystemObject.vehicleOperators, rawValue: 2),
  ],
);

const _fullAccessUser = User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [
    Privilege(systemObject: SystemObject.vehicleOperators, rawValue: 15),
  ],
);

final _testOperators = [
  VehicleOperator(
    vehicleOperatorId: 1,
    driverId: 7,
    driverName: 'Jane Doe',
    licenseType: 'A',
    driverLicenseNumber: 'LN-1',
    issueDate: DateTime(2026, 1, 1),
    expirationDate: DateTime(2099, 1, 1),
    issuingLocation: 'CDMX',
    status: EntityStatus.active,
    daysUntilExpiry: 3650,
  ),
  VehicleOperator(
    vehicleOperatorId: 2,
    driverId: 8,
    driverName: 'John Smith',
    licenseType: 'B',
    driverLicenseNumber: 'LN-2',
    issueDate: DateTime(2020, 1, 1),
    expirationDate: DateTime(2021, 1, 1),
    issuingLocation: 'GDL',
    status: EntityStatus.inactive,
    daysUntilExpiry: -100,
  ),
];

AccessControlService _accessFor(User user) =>
    AccessControlService(AuthState.authenticated(token: 't', user: user));

void main() {
  late MockVehicleOperatorRepository repository;
  late MockEmployeeRepository employeeRepository;

  setUp(() {
    repository = MockVehicleOperatorRepository();
    employeeRepository = MockEmployeeRepository();
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    required User signedInAs,
    List<VehicleOperator> operators = const [],
    ListQuery query = const ListQuery(),
  }) async {
    when(
      () => repository.list(
        search: any(named: 'search'),
        driverId: any(named: 'driverId'),
        status: any(named: 'status'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async =>
          VehicleOperatorListResult(items: operators, total: operators.length),
    );

    // Mirrors production's shape (app_router.dart): the list lives inside
    // its own `StatefulShellBranch`, with its own nested Navigator distinct
    // from the outer/root one. The filter sheet attaches to the root
    // Navigator (`useRootNavigator: true`, catalog_filter_sheet.dart) so it
    // survives a same-branch `context.go` on every live filter change — a
    // flat single-Navigator router would conflate the two and tear the
    // sheet down after the first change.
    final router = GoRouter(
      initialLocation: query.toUri('/vehicle-operators').toString(),
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) => navigationShell,
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/vehicle-operators',
                  builder: (_, state) => Scaffold(
                    body: VehicleOperatorsListScreen(
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
          vehicleOperatorRepositoryProvider.overrideWithValue(repository),
          employeeRepositoryProvider.overrideWithValue(employeeRepository),
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

  testWidgets('shows driver name (not a raw id) for every operator (FR-017)', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      signedInAs: _fullAccessUser,
      operators: _testOperators,
    );

    expect(find.text('Jane Doe'), findsOneWidget);
    expect(find.text('John Smith'), findsOneWidget);
  });

  testWidgets('shows an inactive badge for an inactive operator', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      signedInAs: _fullAccessUser,
      operators: _testOperators,
    );

    expect(find.byKey(const Key('status_badge_inactive')), findsOneWidget);
  });

  testWidgets('search box, pagination, and filter button are present', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      signedInAs: _fullAccessUser,
      operators: _testOperators,
    );

    expect(
      find.byKey(const Key('vehicle_operators_search_field')),
      findsOneWidget,
    );
    expect(find.byType(PaginatedDataTable2), findsOneWidget);
    expect(
      find.byKey(const Key('vehicle_operators_filter_button')),
      findsOneWidget,
    );
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

    expect(find.byKey(const Key('new_vehicle_operator_button')), findsNothing);
  });

  testWidgets(
    'a row click opens the read-only detail view (constitution §VI)',
    (tester) async {
      when(
        () => repository.list(
          search: any(named: 'search'),
          driverId: any(named: 'driverId'),
          status: any(named: 'status'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => VehicleOperatorListResult(
          items: _testOperators,
          total: _testOperators.length,
        ),
      );

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, state) => Scaffold(
              body: VehicleOperatorsListScreen(
                query: ListQuery.fromUri(state.uri),
              ),
            ),
          ),
          GoRoute(
            path: '/vehicle-operators/:vehicleOperatorId',
            builder: (_, state) => Scaffold(body: Text(state.uri.toString())),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            vehicleOperatorRepositoryProvider.overrideWithValue(repository),
            employeeRepositoryProvider.overrideWithValue(employeeRepository),
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

      await tester.tap(find.text('Jane Doe'));
      await tester.pumpAndSettle();

      expect(find.text('/vehicle-operators/1?view=true'), findsOneWidget);
    },
  );

  testWidgets('an empty result shows the empty state', (tester) async {
    await pumpScreen(tester, signedInAs: _fullAccessUser, operators: const []);

    expect(find.byKey(const Key('vehicle_operators_table')), findsNothing);
  });

  group('URL-driven filters (017-ui-consistency-filters US3)', () {
    testWidgets(
      'a driver facet in the URL is passed to the repository, and its name '
      'is resolved for cold-load display (data-model.md §4)',
      (tester) async {
        when(() => employeeRepository.get(employeeId: 7)).thenAnswer(
          (_) async => Employee(
            employeeId: 7,
            firstName: 'Jane',
            lastName: 'Doe',
            nickname: 'Jane',
            gender: null,
            birthday: DateTime(1990),
            salesPerson: false,
            status: EntityStatus.active,
            startJobDate: DateTime(2020),
          ),
        );

        await pumpScreen(
          tester,
          signedInAs: _fullAccessUser,
          operators: _testOperators,
          query: const ListQuery(
            facets: {
              'driver': ['7'],
            },
          ),
        );

        verify(
          () => repository.list(
            search: any(named: 'search'),
            driverId: 7,
            status: any(named: 'status'),
            skip: any(named: 'skip'),
            limit: any(named: 'limit'),
          ),
        ).called(greaterThanOrEqualTo(1));

        await tester.tap(
          find.byKey(const Key('vehicle_operators_filter_button')),
        );
        await tester.pumpAndSettle();

        expect(
          find.descendant(
            of: find.byKey(const Key('vehicle_operators_filter_driver')),
            matching: find.text('Jane Doe'),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'a status facet combines with the driver facet (FR-010, FR-013), and '
      'the filtered total/page count comes from the server response, not '
      'items.length (FR-014)',
      (tester) async {
        when(() => employeeRepository.get(employeeId: 7)).thenAnswer(
          (_) async => Employee(
            employeeId: 7,
            firstName: 'Jane',
            lastName: 'Doe',
            nickname: 'Jane',
            gender: null,
            birthday: DateTime(1990),
            salesPerson: false,
            status: EntityStatus.active,
            startJobDate: DateTime(2020),
          ),
        );

        await pumpScreen(
          tester,
          signedInAs: _fullAccessUser,
          operators: [_testOperators.first],
          query: const ListQuery(
            facets: {
              'driver': ['7'],
              'status': ['active'],
            },
          ),
        );

        verify(
          () => repository.list(
            search: any(named: 'search'),
            driverId: 7,
            status: EntityStatus.active,
            skip: any(named: 'skip'),
            limit: any(named: 'limit'),
          ),
        ).called(greaterThanOrEqualTo(1));
        expect(find.text('1–1 of 1'), findsOneWidget);

        await tester.tap(
          find.byKey(const Key('vehicle_operators_filter_button')),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('vehicle_operators_filter_status_active')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'selecting a driver filter navigates to a URL carrying that facet',
      (tester) async {
        final router = GoRouter(
          initialLocation: '/vehicle-operators',
          routes: [
            GoRoute(
              path: '/vehicle-operators',
              builder: (_, state) => Scaffold(
                body: VehicleOperatorsListScreen(
                  query: ListQuery.fromUri(state.uri),
                ),
              ),
            ),
          ],
        );
        when(
          () => repository.list(
            search: any(named: 'search'),
            driverId: any(named: 'driverId'),
            status: any(named: 'status'),
            skip: any(named: 'skip'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer(
          (_) async => VehicleOperatorListResult(
            items: _testOperators,
            total: _testOperators.length,
          ),
        );
        when(
          () => employeeRepository.list(search: any(named: 'search')),
        ).thenAnswer(
          (_) async => EmployeeListResult(
            items: [
              EmployeeListItem(
                employeeId: 7,
                fullName: 'Jane Doe',
                nickname: 'Jane',
                status: EntityStatus.active,
                salesPerson: false,
              ),
            ],
            total: 1,
          ),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              vehicleOperatorRepositoryProvider.overrideWithValue(repository),
              employeeRepositoryProvider.overrideWithValue(
                employeeRepository,
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

        await tester.tap(
          find.byKey(const Key('vehicle_operators_filter_button')),
        );
        await tester.pumpAndSettle();

        await tester.enterText(
          find.descendant(
            of: find.byKey(const Key('vehicle_operators_filter_driver')),
            matching: find.byType(TextFormField),
          ),
          'Jane',
        );
        await tester.pumpAndSettle(const Duration(milliseconds: 400));

        await tester.tap(find.text('Jane Doe').last);
        await tester.pumpAndSettle();

        expect(
          router.routerDelegate.currentConfiguration.uri.toString(),
          '/vehicle-operators?driver=7',
        );
      },
    );
  });
}
