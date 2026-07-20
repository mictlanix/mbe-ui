import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/employee_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/vehicle_operator_repository_impl.dart';
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
  disabled: false,
  sessionVersion: 1,
  privileges: [
    Privilege(systemObject: SystemObject.vehicleOperators, rawValue: 2),
  ],
);

const _fullAccessUser = User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: false,
  disabled: false,
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
    active: true,
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
    active: false,
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
  }) async {
    when(
      () => repository.list(
        search: any(named: 'search'),
        driverId: any(named: 'driverId'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async =>
          VehicleOperatorListResult(items: operators, total: operators.length),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vehicleOperatorRepositoryProvider.overrideWithValue(repository),
          employeeRepositoryProvider.overrideWithValue(employeeRepository),
          accessControlProvider.overrideWithValue(_accessFor(signedInAs)),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: VehicleOperatorsListScreen()),
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

    expect(find.byKey(const Key('inactive_badge')), findsOneWidget);
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
            builder: (_, _) =>
                const Scaffold(body: VehicleOperatorsListScreen()),
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
}
