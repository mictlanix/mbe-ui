import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/domain/gender.dart';
import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/employee_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/employee.dart';
import 'package:mbe_ui/features/catalog/domain/entities/employee_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/employee_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/employees_list_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockEmployeeRepository extends Mock implements EmployeeRepository {}

const _readOnlyUser = User(
  userId: 'reader',
  email: 'reader@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.employees, rawValue: 2)],
);

const _fullAccessUser = User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.employees, rawValue: 15)],
);

const _testEmployees = [
  EmployeeListItem(
    employeeId: 1,
    fullName: 'Jane Doe',
    nickname: 'Janie',
    status: EntityStatus.active,
    salesPerson: true,
  ),
  EmployeeListItem(
    employeeId: 2,
    fullName: 'John Smith',
    nickname: 'Johnny',
    status: EntityStatus.inactive,
    salesPerson: false,
  ),
];

AccessControlService _accessFor(User user) =>
    AccessControlService(AuthState.authenticated(token: 't', user: user));

void main() {
  late MockEmployeeRepository repository;

  setUp(() {
    repository = MockEmployeeRepository();
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    required User signedInAs,
    List<EmployeeListItem> employees = _testEmployees,
    ListQuery query = const ListQuery(),
  }) async {
    when(
      () => repository.list(
        search: any(named: 'search'),
        status: any(named: 'status'),
        salesPerson: any(named: 'salesPerson'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async =>
          EmployeeListResult(items: employees, total: employees.length),
    );

    // Mirrors production's shape (app_router.dart): the list lives inside
    // its own `StatefulShellBranch`, with its own nested Navigator distinct
    // from the outer/root one. The filter sheet attaches to the root
    // Navigator (`useRootNavigator: true`, catalog_filter_sheet.dart) so it
    // survives a same-branch `context.go` on every live filter change — a
    // flat single-Navigator router would conflate the two and tear the
    // sheet down after the first change.
    final router = GoRouter(
      initialLocation: query.toUri('/employees').toString(),
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) => navigationShell,
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/employees',
                  builder: (_, state) => Scaffold(
                    body: EmployeesListScreen(
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
          employeeRepositoryProvider.overrideWithValue(repository),
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

  testWidgets('shows full name and nickname for every employee', (
    tester,
  ) async {
    await pumpScreen(tester, signedInAs: _fullAccessUser);

    expect(find.text('Jane Doe'), findsOneWidget);
    expect(find.text('Janie'), findsOneWidget);
    expect(find.text('John Smith'), findsOneWidget);
  });

  testWidgets('search box, filter button, and pagination are present', (
    tester,
  ) async {
    await pumpScreen(tester, signedInAs: _fullAccessUser);

    expect(find.byKey(const Key('employees_search_field')), findsOneWidget);
    expect(find.byKey(const Key('employees_filter_button')), findsOneWidget);
    expect(find.byType(PaginatedDataTable2), findsOneWidget);
  });

  testWidgets(
    'the filter drawer opens with active and sales-person tri-state chips',
    (tester) async {
      await pumpScreen(tester, signedInAs: _fullAccessUser);

      await tester.tap(find.byKey(const Key('employees_filter_button')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('employees_filter_status_active')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('employees_filter_sales_person')),
        findsOneWidget,
      );
    },
  );

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

    expect(find.byKey(const Key('new_employee_button')), findsNothing);
  });

  testWidgets(
    'a row click opens the record read-only in a panel over the list — no '
    'navigation, since there is no per-record route anymore (spec 035 US5)',
    (tester) async {
      when(
        () => repository.list(
          search: any(named: 'search'),
          status: any(named: 'status'),
          salesPerson: any(named: 'salesPerson'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => EmployeeListResult(
          items: _testEmployees,
          total: _testEmployees.length,
        ),
      );
      when(() => repository.get(employeeId: 1)).thenAnswer(
        (_) async => Employee(
          employeeId: 1,
          firstName: 'Jane',
          lastName: 'Doe',
          nickname: 'Janie',
          gender: Gender.female,
          birthday: DateTime(1990, 5, 15),
          status: EntityStatus.active,
          salesPerson: true,
          startJobDate: DateTime(2020, 1, 10),
        ),
      );

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, state) => Scaffold(
              body: EmployeesListScreen(query: ListQuery.fromUri(state.uri)),
            ),
          ),
        ],
      );

      SharedPreferences.setMockInitialValues({});
      final sharedPreferences = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(sharedPreferences),
            employeeRepositoryProvider.overrideWithValue(repository),
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

      expect(router.state.uri.path, '/');
      final firstNameField = tester.widget<TextFormField>(
        find.byKey(const Key('first_name_field')),
      );
      expect(firstNameField.initialValue, 'Jane');
      expect(firstNameField.enabled, isFalse);
      expect(find.byKey(const Key('edit_employee_button')), findsOneWidget);
    },
  );

  testWidgets('an empty result shows the empty state', (tester) async {
    await pumpScreen(tester, signedInAs: _fullAccessUser, employees: const []);

    expect(find.byKey(const Key('employees_table')), findsNothing);
  });

  group('URL-driven filters (017-ui-consistency-filters US3)', () {
    testWidgets('a status facet in the URL is passed to the repository', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        signedInAs: _fullAccessUser,
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
          salesPerson: any(named: 'salesPerson'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).called(greaterThanOrEqualTo(1));
    });

    testWidgets('a salesPerson facet in the URL is passed to the repository', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        signedInAs: _fullAccessUser,
        query: const ListQuery(
          facets: {
            'salesPerson': ['true'],
          },
        ),
      );

      verify(
        () => repository.list(
          search: any(named: 'search'),
          status: any(named: 'status'),
          salesPerson: true,
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).called(greaterThanOrEqualTo(1));
    });

    testWidgets(
      'selecting a status filter navigates to a URL carrying that facet',
      (tester) async {
        final router = GoRouter(
          initialLocation: '/employees',
          routes: [
            GoRoute(
              path: '/employees',
              builder: (_, state) => Scaffold(
                body: EmployeesListScreen(query: ListQuery.fromUri(state.uri)),
              ),
            ),
          ],
        );
        when(
          () => repository.list(
            search: any(named: 'search'),
            status: any(named: 'status'),
            salesPerson: any(named: 'salesPerson'),
            skip: any(named: 'skip'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer(
          (_) async => EmployeeListResult(items: _testEmployees, total: 2),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              employeeRepositoryProvider.overrideWithValue(repository),
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

        await tester.tap(find.byKey(const Key('employees_filter_button')));
        await tester.pumpAndSettle();

        await tester.tap(
          find.byKey(const Key('employees_filter_status_inactive')),
        );
        await tester.pumpAndSettle();

        expect(
          router.routerDelegate.currentConfiguration.uri.toString(),
          '/employees?status=inactive',
        );
      },
    );
  });
}
