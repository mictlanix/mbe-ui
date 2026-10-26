import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/pricing/data/price_list_repository_impl.dart';

/// Live round trip for spec 052's customer discounts (research R11) against a
/// *real* mbe-api instance (constitution §VII): a throwaway customer gets a
/// discount on a discovered product, a repeat is refused (409), an unknown
/// product is refused (422), the rate is changed and read back as a fraction,
/// then the discount is removed (a second removal is a 404) and the customer
/// deleted.
///
/// Operates at the repository layer like `supplier_sub_panels_live_test.dart`.
/// The price list and product are discovered at runtime, never hard-coded; the
/// test is skipped (not failed) when the tenant has none. It creates its own
/// customer, so no real customer's discounts are touched.
///
/// Requires mbe-api at [apiBaseUrl] (default `http://127.0.0.1:8000`, or
/// `--dart-define=API_BASE_URL=...`) and an administrator account:
///   --dart-define=MBE_CATALOG_TEST_USERNAME=...
///   --dart-define=MBE_CATALOG_TEST_PASSWORD=...
///
/// Skipped entirely when credentials aren't provided — it creates and
/// deletes real records.
const _username = String.fromEnvironment('MBE_CATALOG_TEST_USERNAME');
const _password = String.fromEnvironment('MBE_CATALOG_TEST_PASSWORD');

const _canRun = _username != '' && _password != '';

void main() {
  late CustomerRepositoryImpl customerRepo;
  int? customerId;
  int? discountId;

  tearDown(() async {
    // Best-effort cleanup, in dependency order. Failures are swallowed so a
    // test failure is never masked by a cleanup error.
    if (!_canRun) return;
    final cid = customerId;
    if (cid != null) {
      try {
        if (discountId != null) {
          await customerRepo.deleteDiscount(
            customerId: cid,
            customerDiscountId: discountId!,
          );
        }
      } catch (_) {}
      try {
        await customerRepo.delete(customerId: cid);
      } catch (_) {}
    }
    customerId = null;
    discountId = null;
  });

  test(
    'Customer discounts: add, repeat refused, unknown product refused, '
    'change, remove, remove again',
    () async {
      final dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
      final token = await AuthRepositoryImpl(
        dio,
      ).login(username: _username, password: _password);
      dio.options.headers['Authorization'] = 'Bearer $token';
      customerRepo = CustomerRepositoryImpl(dio);
      final suffix = DateTime.now().millisecondsSinceEpoch;

      // 1. Runtime-discovered fixtures.
      final priceLists = await PriceListRepositoryImpl(dio).list(limit: 1);
      final products = await ProductRepositoryImpl(
        dio,
      ).list(status: EntityStatus.active, limit: 1);
      if (priceLists.items.isEmpty || products.items.isEmpty) {
        markTestSkipped(
          'Tenant has no price list or no active product; '
          'cannot exercise customer discounts.',
        );
        return;
      }
      final productId = products.items.first.productId;

      // 2. A throwaway customer, so no real customer is touched.
      final customer = await customerRepo.create(
        name: 'IntegrationTest-$suffix',
        priceList: priceLists.items.first.priceListId,
      );
      customerId = customer.customerId;
      expect(
        await customerRepo.listDiscounts(customerId: customerId!),
        isEmpty,
      );

      // 3. Add a 10 % discount: stored as a fraction, listed with its product.
      final created = await customerRepo.createDiscount(
        customerId: customerId!,
        productId: productId,
        discount: '0.1',
      );
      discountId = created.customerDiscountId;
      var listed = await customerRepo.listDiscounts(customerId: customerId!);
      expect(listed, hasLength(1));
      expect(listed.single.customerDiscountId, discountId);
      expect(listed.single.productId, productId);
      expect(listed.single.productCode, products.items.first.code);
      expect(double.parse(listed.single.discount), closeTo(0.1, 1e-9));

      // 4. A repeat on the same product is a 409.
      await expectLater(
        customerRepo.createDiscount(
          customerId: customerId!,
          productId: productId,
          discount: '0.2',
        ),
        throwsA(
          isA<ServerError>().having((e) => e.statusCode, 'statusCode', 409),
        ),
      );

      // 5. An unknown product is a 422.
      await expectLater(
        customerRepo.createDiscount(
          customerId: customerId!,
          productId: 2147483000,
          discount: '0.2',
        ),
        throwsA(isA<ValidationError>()),
      );

      // 6. Change the rate to 12.5 %: read back as the fraction 0.125.
      await customerRepo.updateDiscount(
        customerId: customerId!,
        customerDiscountId: discountId!,
        discount: '0.125',
      );
      listed = await customerRepo.listDiscounts(customerId: customerId!);
      expect(listed, hasLength(1));
      expect(double.parse(listed.single.discount), closeTo(0.125, 1e-9));
      expect(listed.single.productId, productId, reason: 'product is fixed');

      // 7. Remove it; a second removal is a 404.
      await customerRepo.deleteDiscount(
        customerId: customerId!,
        customerDiscountId: discountId!,
      );
      expect(
        await customerRepo.listDiscounts(customerId: customerId!),
        isEmpty,
      );
      await expectLater(
        customerRepo.deleteDiscount(
          customerId: customerId!,
          customerDiscountId: discountId!,
        ),
        throwsA(isA<NotFoundError>()),
      );
      discountId = null;

      // 8. The throwaway customer goes too.
      await customerRepo.delete(customerId: customerId!);
      customerId = null;
    },
    skip: !_canRun,
    timeout: const Timeout(Duration(seconds: 90)),
  );
}
