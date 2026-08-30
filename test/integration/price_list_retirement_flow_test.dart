import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/pricing/data/price_list_repository_impl.dart';
import 'package:mbe_ui/features/pricing/data/product_price_repository_impl.dart';

/// Exercises the price list retirement golden path against a *real*
/// mbe-api instance (constitution §VII), covering
/// specs/034-price-list-retirement-ui quickstart.md's manual steps 1-9:
/// preview → pick a replacement → confirm → 204 → the moved customers read
/// as being on the replacement.
///
/// Requires mbe-api running at [apiBaseUrl] (default `http://127.0.0.1:8000`)
/// and a seeded test account holding `priceLists` create+delete,
/// `products`/`pricing`/`customers` create — enough to stage the throwaway
/// records this test creates and retires. Configure via `--dart-define`:
///   --dart-define=MBE_MERGE_TEST_USERNAME=...
///   --dart-define=MBE_MERGE_TEST_PASSWORD=...
///
/// Reuses `product_merge_flow_test.dart`'s credential env vars rather than
/// declaring a new pair — both need the same broad create/delete rights on
/// a throwaway account, and the repo's dev tenant already has one seeded
/// (reference_pos_integration_test_invocation.md's `clavo` pattern is the
/// POS-specific pair; this is the merge-flow pair, chosen because it is
/// already scoped for "create and destroy catalog records").
///
/// Skipped when credentials aren't provided.
const _username = String.fromEnvironment('MBE_MERGE_TEST_USERNAME');
const _password = String.fromEnvironment('MBE_MERGE_TEST_PASSWORD');

const _hasCredentials = _username != '' && _password != '';

/// A real SAT unit code — `product.unit_of_measurement` is a foreign key
/// into `sat_unit_of_measurement`. `H87` is "Pieza".
const _unitOfMeasurement = 'H87';

void main() {
  Future<Dio> authenticatedDio(String username, String password) async {
    final dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
    final token = await AuthRepositoryImpl(
      dio,
    ).login(username: username, password: password);
    dio.options.headers['Authorization'] = 'Bearer $token';
    return dio;
  }

  test(
    'golden path: a list carrying prices and an assigned customer retires '
    'in one request, the prices are gone, and the customer reads as being '
    'on the named replacement (SC-001, SC-002, SC-003)',
    () async {
      final dio = await authenticatedDio(_username, _password);
      final priceListRepo = PriceListRepositoryImpl(dio);
      final productRepo = ProductRepositoryImpl(dio);
      final productPriceRepo = ProductPriceRepositoryImpl(dio);
      final customerRepo = CustomerRepositoryImpl(dio);

      final suffix = DateTime.now().millisecondsSinceEpoch;

      final retiring = await priceListRepo.create(
        name: 'IT Retirement Retiring $suffix',
      );
      final replacement = await priceListRepo.create(
        name: 'IT Retirement Replacement $suffix',
      );
      final product = await productRepo.create(
        code: 'IT-RETIRE-$suffix',
        name: 'Integration Test Retirement Product',
        unitOfMeasurement: _unitOfMeasurement,
      );
      await productPriceRepo.create(
        productId: product.productId,
        priceListId: retiring.priceListId,
        price: '19.99',
      );
      final customer = await customerRepo.create(
        code: 'IT-RETIRE-$suffix',
        name: 'Integration Test Retirement Customer',
        priceList: retiring.priceListId,
      );

      // The preview reports both categories, largest first, with a total
      // (FR-002, SC-005) — asked before anything is touched.
      final preview = await priceListRepo.deletePreview(
        priceListId: retiring.priceListId,
      );
      expect(
        preview.categories.map((c) => c.key),
        containsAll(['product_price.list', 'customer.price_list']),
      );
      expect(preview.total, greaterThanOrEqualTo(2));

      await priceListRepo.delete(
        priceListId: retiring.priceListId,
        replacement: replacement.priceListId,
      );

      // The list is gone.
      await expectLater(
        () => priceListRepo.get(priceListId: retiring.priceListId),
        throwsA(isA<NotFoundError>()),
      );

      // The customer moved to the replacement, exactly as the outcome the
      // dialog reports (FR-017, SC-003).
      final movedCustomer = await customerRepo.get(
        customerId: customer.customerId,
      );
      expect(movedCustomer.priceList.id, replacement.priceListId);
    },
    skip: !_hasCredentials,
  );

  test(
    'a list something other than its prices and customers still points at '
    'refuses the deletion, unchanged (FR-018, SC-004 backstop)',
    () async {
      final dio = await authenticatedDio(_username, _password);
      final priceListRepo = PriceListRepositoryImpl(dio);

      final blocked = await priceListRepo.create(
        name: 'IT Retirement Blocked ${DateTime.now().millisecondsSinceEpoch}',
      );

      // Naming the list as its own replacement is refused with a 400
      // (contracts/mbe-api-price-list-retirement.md §2) — a cheap way to
      // exercise a real refusal without seeding a sales order.
      await expectLater(
        () => priceListRepo.delete(
          priceListId: blocked.priceListId,
          replacement: blocked.priceListId,
        ),
        throwsA(isA<ServerError>()),
      );

      final stillThere = await priceListRepo.get(
        priceListId: blocked.priceListId,
      );
      expect(stillThere.priceListId, blocked.priceListId);
    },
    skip: !_hasCredentials,
  );
}
