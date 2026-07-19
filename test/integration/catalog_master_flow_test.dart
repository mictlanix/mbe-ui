import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/employee_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/sat_catalog_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/taxpayer_recipient_repository_impl.dart';
import 'package:mbe_ui/features/pricing/data/price_list_repository_impl.dart';

/// Golden-path integration test against a *real* mbe-api instance
/// (constitution §VII — no mocked/offline mode): create an employee, create
/// a customer selecting that employee as salesperson and a fresh price
/// list, then create a taxpayer recipient with a postal code and tax
/// regime picked from the SAT catalogs (quickstart.md "Golden path";
/// spec.md US3/US4/US5).
///
/// Requires mbe-api running at [apiBaseUrl] (default
/// `http://127.0.0.1:8000`) and a user with `Employees`/`Customers`/
/// `PriceLists`/`TaxpayerRecipients` create+delete rights. Configure via
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
  test('create employee → create customer (salesperson + price list) → '
      'create taxpayer recipient (postal code + tax regime)', () async {
    final dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
    final token = await AuthRepositoryImpl(
      dio,
    ).login(username: _username, password: _password);
    dio.options.headers['Authorization'] = 'Bearer $token';

    final employeeRepository = EmployeeRepositoryImpl(dio);
    final priceListRepository = PriceListRepositoryImpl(dio);
    final customerRepository = CustomerRepositoryImpl(dio);
    final satCatalogRepository = SatCatalogRepositoryImpl(dio);
    final taxpayerRecipientRepository = TaxpayerRecipientRepositoryImpl(dio);

    final suffix = DateTime.now().millisecondsSinceEpoch;

    // 1. US3 — create an employee (the future customer's salesperson).
    final employee = await employeeRepository.create(
      firstName: 'Integration',
      lastName: 'Test-$suffix',
      nickname: 'IT$suffix',
      gender: 1,
      birthday: DateTime(1990, 1, 1),
      startJobDate: DateTime.now(),
      salesPerson: true,
    );
    expect(employee.firstName, 'Integration');

    // 2. Reuse the existing price-list catalog (specs/011) purely as a
    // picker source — create a throwaway list for this run.
    final priceList = await priceListRepository.create(
      name: 'IntegrationTest-$suffix',
    );

    // 3. US4 — create a customer selecting that employee as salesperson
    // and the fresh price list.
    final customer = await customerRepository.create(
      code: 'IT-$suffix',
      name: 'Integration Test Customer',
      priceList: priceList.priceListId,
      salesperson: employee.employeeId,
    );
    expect(customer.salesperson?.id, employee.employeeId);
    expect(customer.priceList.id, priceList.priceListId);

    // 4. US5 — create a taxpayer recipient with a postal code and tax
    // regime searched from the SAT catalogs (proves the two new
    // SatCatalogRepository methods against the real server, research.md
    // §5).
    final postalCodes = await satCatalogRepository.listPostalCodes(limit: 1);
    final taxRegimes = await satCatalogRepository.listTaxRegimes(limit: 1);
    expect(postalCodes.items, isNotEmpty);
    expect(taxRegimes.items, isNotEmpty);

    final taxpayerRecipient = await taxpayerRecipientRepository.create(
      taxpayerRecipientId: 'XAXX010101$suffix'.substring(0, 13),
      email: 'integration-test-$suffix@example.com',
      name: 'Integration Test Recipient',
      postalCode: postalCodes.items.first.code,
      regime: taxRegimes.items.first.code,
    );
    expect(taxpayerRecipient.postalCode?.code, postalCodes.items.first.code);
    expect(taxpayerRecipient.regime?.code, taxRegimes.items.first.code);

    // Cleanup: leave no test data behind.
    await taxpayerRecipientRepository.delete(
      taxpayerRecipientId: taxpayerRecipient.taxpayerRecipientId,
    );
    await customerRepository.delete(customerId: customer.customerId);
    await priceListRepository.delete(priceListId: priceList.priceListId);
    await employeeRepository.delete(employeeId: employee.employeeId);
  }, skip: !_canRun);
}
