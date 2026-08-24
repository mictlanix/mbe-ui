import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/access/user_settings.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/domain/facility_type.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/features/catalog/data/employee_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/employee.dart';
import 'package:mbe_ui/features/catalog/domain/entities/employee_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/facility.dart';
import 'package:mbe_ui/features/catalog/domain/entities/facility_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/employee_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/facility_repository.dart';

import 'pos_test_harness.dart';
import 'sales_orders_filters_test.dart' show pumpOrdersRouted;
import 'sales_orders_list_screen_test.dart' show stubListOrders;

class _FixedAuthNotifier extends AuthNotifier {
  _FixedAuthNotifier(this._state);
  final AuthState _state;
  @override
  Future<AuthState> build() async => _state;
}

class MockEmployeeRepository extends Mock implements EmployeeRepository {}

class MockFacilityRepository extends Mock implements FacilityRepository {}

User _user({required bool administrator}) => User(
  userId: administrator ? 'admin-1' : 'salesperson-1',
  email: 'user@example.com',
  administrator: administrator,
  status: EntityStatus.active,
  sessionVersion: 1,
  settings: const UserSettings(facilityId: 9),
  privileges: [Privilege(systemObject: SystemObject.salesOrders, rawValue: 2)],
);

Employee _employee(int id) => Employee(
  employeeId: id,
  firstName: 'Ana',
  lastName: 'López',
  nickname: 'Ana',
  gender: null,
  birthday: DateTime(1990, 1, 1),
  salesPerson: true,
  status: EntityStatus.active,
  startJobDate: DateTime(2020, 1, 1),
);

Facility _facility(int id) => Facility(
  facilityId: id,
  code: 'FAC-$id',
  name: 'Sucursal Centro',
  type: FacilityType.store,
  locationId: '55600',
  locationLabel: '55600',
  addressId: 1,
  addressLabel: 'Address',
  taxpayerRfc: 'AAA010101AAA',
  status: EntityStatus.active,
);

/// FR-006, FR-011 (spec 029): the salesperson and facility facets are
/// administrator-only, resolve an id arriving in the URL to a name rather
/// than showing a bare number, and reach the request/address exactly as
/// `sales_orders_scoping_test.dart` (the unit-level counterpart) already
/// confirms for the request side.
void main() {
  late MockSalesOrderRepository salesOrders;
  late MockEmployeeRepository employees;
  late MockFacilityRepository facilities;

  setUp(() {
    salesOrders = MockSalesOrderRepository();
    employees = MockEmployeeRepository();
    facilities = MockFacilityRepository();
    stubListOrders(salesOrders, page: testSalesPage(const []));
    when(() => employees.get(employeeId: 100)).thenAnswer((_) async => _employee(100));
    when(() => facilities.get(facilityId: 5)).thenAnswer((_) async => _facility(5));
  });

  Future<void> pump(
    WidgetTester tester, {
    required bool administrator,
    ListQuery query = const ListQuery(),
  }) async {
    await pumpOrdersRouted(
      tester,
      initialLocation: query.toUri('/sales/orders').toString(),
      overrides: [
        authNotifierProvider.overrideWith(
          () => _FixedAuthNotifier(
            AuthState.authenticated(token: 't', user: _user(administrator: administrator)),
          ),
        ),
        salesOrderOverride(salesOrders),
        employeeRepositoryProvider.overrideWithValue(employees),
        facilityRepositoryProvider.overrideWithValue(facilities),
      ],
    );
    await tester.tap(find.byKey(const Key('sales_orders_filter_button')));
    await tester.pumpAndSettle();
  }

  testWidgets('both facets are present for an administrator', (tester) async {
    await pump(tester, administrator: true);

    expect(
      find.byKey(const Key('sales_orders_filter_salesperson')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('sales_orders_filter_facility')), findsOneWidget);
  });

  testWidgets('both facets are absent for an ordinary user', (tester) async {
    await pump(tester, administrator: false);

    expect(find.byKey(const Key('sales_orders_filter_salesperson')), findsNothing);
    expect(find.byKey(const Key('sales_orders_filter_facility')), findsNothing);
  });

  testWidgets(
    'a salesperson/facility id arriving in the URL resolves to a name, '
    'not a bare number',
    (tester) async {
      await pump(
        tester,
        administrator: true,
        query: const ListQuery(
          facets: {
            'salesperson': ['100'],
            'facility': ['5'],
          },
        ),
      );

      final salesperson = tester.widget<CatalogEntityPicker<EmployeeListItem>>(
        find.byKey(const Key('sales_orders_filter_salesperson')),
      );
      expect(salesperson.initialDisplayText, 'Ana López');

      final facility = tester.widget<CatalogEntityPicker<FacilityListItem>>(
        find.byKey(const Key('sales_orders_filter_facility')),
      );
      expect(facility.initialDisplayText, 'Sucursal Centro');
    },
  );

  testWidgets(
    'with neither facet set, the facility one still shows the caller\'s '
    'own facility rather than a blank field (scenario 2)',
    (tester) async {
      when(() => facilities.get(facilityId: 9)).thenAnswer((_) async => _facility(9));

      await pump(tester, administrator: true);

      final facility = tester.widget<CatalogEntityPicker<FacilityListItem>>(
        find.byKey(const Key('sales_orders_filter_facility')),
      );
      expect(facility.initialDisplayText, 'Sucursal Centro');

      final salesperson = tester.widget<CatalogEntityPicker<EmployeeListItem>>(
        find.byKey(const Key('sales_orders_filter_salesperson')),
      );
      expect(salesperson.initialDisplayText, isNotEmpty);
    },
  );
}
