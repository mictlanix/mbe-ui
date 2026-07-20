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
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/employee_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/customer_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/employee_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/customers_list_screen.dart';
import 'package:mbe_ui/features/pricing/data/price_list_repository_impl.dart';
import 'package:mbe_ui/features/pricing/domain/repositories/price_list_repository.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockCustomerRepository extends Mock implements CustomerRepository {}

class MockPriceListRepository extends Mock implements PriceListRepository {}

class MockEmployeeRepository extends Mock implements EmployeeRepository {}

const _readOnlyUser = User(
  userId: 'reader',
  email: 'reader@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.customers, rawValue: 2)],
);

const _fullAccessUser = User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.customers, rawValue: 15)],
);

const _testCustomers = [
  CustomerListItem(
    customerId: 1,
    code: 'CUST-001',
    name: 'Acme Corp',
    creditLimit: '1000.50',
    creditDays: 30,
    priceList: PriceListRef(id: 1, name: 'Retail'),
    salesperson: EmployeeRef(id: 2, name: 'Jane Doe'),
    status: EntityStatus.active,
  ),
  CustomerListItem(
    customerId: 2,
    code: 'CUST-002',
    name: 'Beta LLC',
    creditLimit: '0',
    creditDays: 0,
    priceList: PriceListRef(id: 1, name: 'Retail'),
    status: EntityStatus.active,
  ),
];

AccessControlService _accessFor(User user) =>
    AccessControlService(AuthState.authenticated(token: 't', user: user));

void main() {
  late MockCustomerRepository repository;
  late MockPriceListRepository priceListRepository;
  late MockEmployeeRepository employeeRepository;

  setUp(() {
    repository = MockCustomerRepository();
    priceListRepository = MockPriceListRepository();
    employeeRepository = MockEmployeeRepository();
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    required User signedInAs,
    List<CustomerListItem> customers = _testCustomers,
  }) async {
    when(
      () => repository.list(
        search: any(named: 'search'),
        status: any(named: 'status'),
        priceList: any(named: 'priceList'),
        salesperson: any(named: 'salesperson'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => CustomerPage(items: customers, total: customers.length),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          customerRepositoryProvider.overrideWithValue(repository),
          priceListRepositoryProvider.overrideWithValue(priceListRepository),
          employeeRepositoryProvider.overrideWithValue(employeeRepository),
          accessControlProvider.overrideWithValue(_accessFor(signedInAs)),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: CustomersListScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows salesperson by name and a "none assigned" fallback', (
    tester,
  ) async {
    await pumpScreen(tester, signedInAs: _fullAccessUser);

    expect(find.text('Acme Corp'), findsOneWidget);
    expect(find.text('Jane Doe'), findsOneWidget);
    expect(find.text('Beta LLC'), findsOneWidget);
    expect(find.text('None assigned'), findsOneWidget);
  });

  testWidgets('search box, filter button, and pagination are present', (
    tester,
  ) async {
    await pumpScreen(tester, signedInAs: _fullAccessUser);

    expect(find.byKey(const Key('customers_search_field')), findsOneWidget);
    expect(find.byKey(const Key('customers_filter_button')), findsOneWidget);
    expect(find.byType(PaginatedDataTable2), findsOneWidget);
  });

  testWidgets(
    'the filter drawer opens with active tri-state and price-list/salesperson pickers',
    (tester) async {
      await pumpScreen(tester, signedInAs: _fullAccessUser);

      await tester.tap(find.byKey(const Key('customers_filter_button')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('customers_filter_status_active')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('customers_filter_price_list')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('customers_filter_salesperson')),
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

    expect(find.byKey(const Key('new_customer_button')), findsNothing);
  });

  testWidgets(
    'a row click opens the read-only detail view (constitution §VI)',
    (tester) async {
      when(
        () => repository.list(
          search: any(named: 'search'),
          status: any(named: 'status'),
          priceList: any(named: 'priceList'),
          salesperson: any(named: 'salesperson'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async =>
            CustomerPage(items: _testCustomers, total: _testCustomers.length),
      );

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const Scaffold(body: CustomersListScreen()),
          ),
          GoRoute(
            path: '/customers/:customerId',
            builder: (_, state) => Scaffold(body: Text(state.uri.toString())),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            customerRepositoryProvider.overrideWithValue(repository),
            priceListRepositoryProvider.overrideWithValue(priceListRepository),
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

      await tester.tap(find.text('Acme Corp'));
      await tester.pumpAndSettle();

      expect(find.text('/customers/1?view=true'), findsOneWidget);
    },
  );

  testWidgets('an empty result shows the empty state', (tester) async {
    await pumpScreen(tester, signedInAs: _fullAccessUser, customers: const []);

    expect(find.byKey(const Key('customers_table')), findsNothing);
  });
}
