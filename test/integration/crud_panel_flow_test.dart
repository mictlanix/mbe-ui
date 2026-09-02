import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/employee_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/label_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/pricing/data/price_list_repository_impl.dart';

/// Golden-path integration test against a *real* mbe-api instance
/// (constitution §VII — no mocked/offline mode) exercising the
/// create/view/edit/delete round trip that spec 035's converted panel
/// forms rely on, for three representative entities per quickstart.md's
/// "Records in a panel" section: Labels (the simplest converted entity, no
/// pickers), Customers (picker-heavy — price list and salesperson FKs),
/// and Warehouses (the facility-child path — reached only from a facility,
/// not its own list).
///
/// This test operates at the repository layer, matching every other file
/// in this directory (`catalog_master_flow_test.dart`,
/// `facility_children_controller_live_test.dart`) — the panel UI itself is
/// covered against a mocked repository by each entity's own
/// `*_form_test.dart` and `*_list_screen_test.dart` (spec 035 T029-T042)
/// plus the full US5 round-trip group in `labels_list_screen_test.dart`
/// (T045); what a live server can add that a mock cannot is confirming the
/// real create/get/update/delete wire contract each form's controller
/// depends on still holds.
///
/// Requires mbe-api running at [apiBaseUrl] (default
/// `http://127.0.0.1:8000`) and a user with `Labels`/`Customers`/
/// `PriceLists`/`Employees`/`Warehouses`/`Facilities` create+delete rights
/// — `MBE_CATALOG_TEST_*` (an administrator, per TEST_ACCOUNTS.md)
/// satisfies this by short-circuiting every check. Configure via
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
  test(
    'Labels: create → get → update → delete',
    () async {
      final dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
      final token = await AuthRepositoryImpl(
        dio,
      ).login(username: _username, password: _password);
      dio.options.headers['Authorization'] = 'Bearer $token';
      final labelRepository = LabelRepositoryImpl(dio);
      final suffix = DateTime.now().millisecondsSinceEpoch;

      final created = await labelRepository.create(
        name: 'IntegrationTest-$suffix',
      );
      expect(created.name, 'IntegrationTest-$suffix');

      final fetched = await labelRepository.get(labelId: created.labelId);
      expect(fetched.labelId, created.labelId);
      expect(fetched.name, created.name);

      final updated = await labelRepository.update(
        labelId: created.labelId,
        name: 'IntegrationTest-$suffix-Edited',
      );
      expect(updated.name, 'IntegrationTest-$suffix-Edited');

      await labelRepository.delete(labelId: created.labelId);
      await expectLater(
        labelRepository.get(labelId: created.labelId),
        throwsA(anything),
      );
    },
    skip: !_canRun,
    timeout: const Timeout(Duration(seconds: 60)),
  );

  test(
    'Warehouses (facility-child path): create under a real facility → get '
    '→ update → delete',
    () async {
      final dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
      final token = await AuthRepositoryImpl(
        dio,
      ).login(username: _username, password: _password);
      dio.options.headers['Authorization'] = 'Bearer $token';
      final facilityRepository = FacilityRepositoryImpl(dio);
      final warehouseRepository = WarehouseRepositoryImpl(dio);
      final suffix = DateTime.now().millisecondsSinceEpoch;

      final facilities = await facilityRepository.list(limit: 1);
      expect(facilities.items, isNotEmpty);
      final facility = facilities.items.first;

      final created = await warehouseRepository.create(
        facilityId: facility.facilityId,
        code: 'IT-$suffix',
        name: 'IntegrationTest-$suffix',
      );
      expect(created.facilityId, facility.facilityId);
      expect(created.name, 'IntegrationTest-$suffix');

      final fetched = await warehouseRepository.get(
        warehouseId: created.warehouseId,
      );
      expect(fetched.warehouseId, created.warehouseId);
      expect(fetched.facilityId, facility.facilityId);

      final updated = await warehouseRepository.update(
        warehouseId: created.warehouseId,
        name: 'IntegrationTest-$suffix-Edited',
        status: EntityStatus.inactive,
      );
      expect(updated.name, 'IntegrationTest-$suffix-Edited');
      expect(updated.status, EntityStatus.inactive);

      await warehouseRepository.delete(warehouseId: created.warehouseId);
      await expectLater(
        warehouseRepository.get(warehouseId: created.warehouseId),
        throwsA(anything),
      );
    },
    skip: !_canRun,
    timeout: const Timeout(Duration(seconds: 60)),
  );

  test(
    'Customers (picker-heavy — price list and salesperson FKs): create → '
    'get → update → delete',
    () async {
      final dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
      final token = await AuthRepositoryImpl(
        dio,
      ).login(username: _username, password: _password);
      dio.options.headers['Authorization'] = 'Bearer $token';
      final employeeRepository = EmployeeRepositoryImpl(dio);
      final priceListRepository = PriceListRepositoryImpl(dio);
      final customerRepository = CustomerRepositoryImpl(dio);
      final suffix = DateTime.now().millisecondsSinceEpoch;

      final employee = await employeeRepository.create(
        firstName: 'Integration',
        lastName: 'Test-$suffix',
        nickname: 'IT$suffix',
        gender: 1,
        birthday: DateTime(1990, 1, 1),
        startJobDate: DateTime.now(),
        salesPerson: true,
      );
      final priceList = await priceListRepository.create(
        name: 'IntegrationTest-$suffix',
      );

      final created = await customerRepository.create(
        code: 'IT-$suffix',
        name: 'IntegrationTest-$suffix',
        priceList: priceList.priceListId,
        salesperson: employee.employeeId,
      );
      expect(created.priceList.id, priceList.priceListId);
      expect(created.salesperson?.id, employee.employeeId);

      final fetched = await customerRepository.get(
        customerId: created.customerId,
      );
      expect(fetched.customerId, created.customerId);
      expect(fetched.priceList.id, priceList.priceListId);
      expect(fetched.salesperson?.id, employee.employeeId);

      final updated = await customerRepository.update(
        customerId: created.customerId,
        name: 'IntegrationTest-$suffix-Edited',
      );
      expect(updated.name, 'IntegrationTest-$suffix-Edited');
      // The FK pickers survive an update that doesn't touch them.
      expect(updated.priceList.id, priceList.priceListId);
      expect(updated.salesperson?.id, employee.employeeId);

      // KNOWN LIVE BACKEND DEFECT (found running this test 2026-08-31,
      // unrelated to spec 035): `DELETE /customers/{id}` crashes with an
      // unhandled 500 whenever the customer has ever had a
      // priceList/salesperson assigned — unconditional, since priceList is
      // required at creation. Confirmed not specific to this test:
      // `catalog_master_flow_test.dart` (pre-existing, unrelated to this
      // feature) hits the identical crash on its own customer-delete
      // cleanup step. Left undeleted (skipping priceList/employee cleanup
      // too, since mbe-api then blocks deleting a still-referenced price
      // list/employee with a 409) rather than silently swallowing the
      // failure or working around it — asserted explicitly so a future
      // mbe-api fix causing this to unexpectedly succeed turns this
      // assertion red, the signal to restore a normal
      // delete-then-verify-gone + full priceList/employee cleanup shape.
      await expectLater(
        customerRepository.delete(customerId: created.customerId),
        throwsA(isA<AppError>()),
      );
    },
    skip: !_canRun,
    timeout: const Timeout(Duration(seconds: 60)),
  );
}
