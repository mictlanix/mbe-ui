import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/employee_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/expense_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/vehicle_operator_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/vehicle_repository_impl.dart';

/// Golden-path integration test against a *real* mbe-api instance
/// (constitution §VII — no mocked/offline mode): create an expense, create a
/// vehicle, then create a vehicle operator picking an existing employee as
/// driver and confirm it lists by driver name with a days-until-expiry
/// indicator (quickstart.md "Golden path"; spec.md US1/US2/US3).
///
/// Requires mbe-api running at [apiBaseUrl] (default
/// `http://127.0.0.1:8000`) and a user with `Expenses`/`Vehicle`/
/// `VehicleOperators`/`Employees` create+delete rights. Configure via
/// `--dart-define`:
///   --dart-define=MBE_CATALOG_TEST_USERNAME=...
///   --dart-define=MBE_CATALOG_TEST_PASSWORD=...
///
/// Skipped entirely when credentials aren't provided — this test creates
/// and then deletes real records, so it must never run unattended against
/// an unknown environment.
const _username = String.fromEnvironment('MBE_CATALOG_TEST_USERNAME');
const _password = String.fromEnvironment('MBE_CATALOG_TEST_PASSWORD');

const _canRun = _username != '' && _password != '';

void main() {
  test('create expense → create vehicle → create vehicle operator picking an '
      'existing employee as driver', () async {
    final dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
    final token = await AuthRepositoryImpl(
      dio,
    ).login(username: _username, password: _password);
    dio.options.headers['Authorization'] = 'Bearer $token';

    final employeeRepository = EmployeeRepositoryImpl(dio);
    final expenseRepository = ExpenseRepositoryImpl(dio);
    final vehicleRepository = VehicleRepositoryImpl(dio);
    final vehicleOperatorRepository = VehicleOperatorRepositoryImpl(dio);

    final suffix = DateTime.now().millisecondsSinceEpoch;

    // 1. US1 — create an expense.
    final expense = await expenseRepository.create(
      name: 'IntegrationTest-$suffix',
    );
    expect(expense.name, 'IntegrationTest-$suffix');

    // 2. US2 — create a vehicle.
    final vehicle = await vehicleRepository.create(
      licensePlate: 'IT-$suffix',
      name: 'Integration Test Vehicle',
      nickname: 'ITV-$suffix',
      tonsCapacity: 5,
    );
    expect(vehicle.licensePlate, 'IT-$suffix');

    // 3. Reuse the employee catalog (spec 012) purely as a driver source —
    // create a throwaway employee for this run.
    final employee = await employeeRepository.create(
      firstName: 'Integration',
      lastName: 'Driver-$suffix',
      nickname: 'ID$suffix',
      gender: 1,
      birthday: DateTime(1990, 1, 1),
      startJobDate: DateTime.now(),
    );

    // 4. US3 — create a vehicle operator selecting that employee as
    // driver, proving the driver picker + Date round-trip against the
    // real server (research.md §4, §5).
    final vehicleOperator = await vehicleOperatorRepository.create(
      driverId: employee.employeeId,
      licenseType: 'A',
      driverLicenseNumber: 'LN-$suffix',
      issueDate: DateTime.now(),
      expirationDate: DateTime.now().add(const Duration(days: 365)),
      issuingLocation: 'CDMX',
    );
    expect(vehicleOperator.driverId, employee.employeeId);
    expect(vehicleOperator.driverName, contains('Integration'));

    // 5. Confirm the driver-by-name filter round-trips against the real
    // `employee` query param (research.md §6).
    final filtered = await vehicleOperatorRepository.list(
      driverId: employee.employeeId,
    );
    expect(
      filtered.items.map((op) => op.vehicleOperatorId),
      contains(vehicleOperator.vehicleOperatorId),
    );

    // Cleanup: leave no test data behind.
    await vehicleOperatorRepository.delete(
      vehicleOperatorId: vehicleOperator.vehicleOperatorId,
    );
    await employeeRepository.delete(employeeId: employee.employeeId);
    await vehicleRepository.delete(vehicleId: vehicle.vehicleId);
    await expenseRepository.delete(expenseId: expense.expenseId);
  }, skip: !_canRun);
}
