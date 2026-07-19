import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';

/// Exercises `ProductRepositoryImpl.mergeProducts` against a *real* mbe-api
/// instance (constitution §VII), covering quickstart.md's US1 golden path
/// (specs/008-merge-products spec.md "User Story 1 - Fuse a confirmed
/// duplicate into the canonical product").
///
/// Requires mbe-api running at [apiBaseUrl] (default
/// `http://127.0.0.1:8000`) and a seeded test account holding both
/// `products` create (to stage throwaway products) and `productsMerge`
/// create (to merge them). Configure via `--dart-define`:
///   --dart-define=MBE_MERGE_TEST_USERNAME=...
///   --dart-define=MBE_MERGE_TEST_PASSWORD=...
///
/// Skipped when credentials aren't provided, matching
/// product_catalog_flow_test.dart's convention.
const _mergeUsername = String.fromEnvironment('MBE_MERGE_TEST_USERNAME');
const _mergePassword = String.fromEnvironment('MBE_MERGE_TEST_PASSWORD');

const _hasMergeCredentials = _mergeUsername != '' && _mergePassword != '';

void main() {
  Future<ProductRepositoryImpl> authenticatedProductRepository(
    String username,
    String password,
  ) async {
    final dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
    final token = await AuthRepositoryImpl(
      dio,
    ).login(username: username, password: password);
    dio.options.headers['Authorization'] = 'Bearer $token';
    return ProductRepositoryImpl(dio);
  }

  test(
    'US1 golden path: merging a freshly-created duplicate into a canonical '
    'product removes the duplicate and keeps the canonical (SC-001, SC-002)',
    () async {
      final repo = await authenticatedProductRepository(
        _mergeUsername,
        _mergePassword,
      );
      final suffix = DateTime.now().millisecondsSinceEpoch;

      final canonical = await repo.create(
        code: 'IT-MERGE-CANON-$suffix',
        name: 'Integration Test Merge Canonical',
        unitOfMeasurement: 'PCE',
      );
      final duplicate = await repo.create(
        code: 'IT-MERGE-DUP-$suffix',
        name: 'Integration Test Merge Duplicate',
        unitOfMeasurement: 'PCE',
      );

      await repo.mergeProducts(
        productId: canonical.productId,
        duplicateId: duplicate.productId,
      );

      final stillThere = await repo.get(productId: canonical.productId);
      expect(stillThere.productId, canonical.productId);

      await expectLater(
        () => repo.get(productId: duplicate.productId),
        throwsA(isA<NotFoundError>()),
      );
    },
    skip: !_hasMergeCredentials,
  );

  test('self-merge is rejected with a 400, leaving the product in place '
      '(FR-006 backstop)', () async {
    final repo = await authenticatedProductRepository(
      _mergeUsername,
      _mergePassword,
    );
    final product = await repo.create(
      code: 'IT-MERGE-SELF-${DateTime.now().millisecondsSinceEpoch}',
      name: 'Integration Test Merge Self',
      unitOfMeasurement: 'PCE',
    );

    await expectLater(
      () => repo.mergeProducts(
        productId: product.productId,
        duplicateId: product.productId,
      ),
      throwsA(isA<ServerError>()),
    );

    final stillThere = await repo.get(productId: product.productId);
    expect(stillThere.productId, product.productId);
  }, skip: !_hasMergeCredentials);

  test(
    'merging against a non-existent duplicate returns 404 (FR-011)',
    () async {
      final repo = await authenticatedProductRepository(
        _mergeUsername,
        _mergePassword,
      );
      final canonical = await repo.create(
        code: 'IT-MERGE-NF-${DateTime.now().millisecondsSinceEpoch}',
        name: 'Integration Test Merge Not-Found',
        unitOfMeasurement: 'PCE',
      );

      await expectLater(
        () => repo.mergeProducts(
          productId: canonical.productId,
          duplicateId: 999999999,
        ),
        throwsA(isA<NotFoundError>()),
      );
    },
    skip: !_hasMergeCredentials,
  );
}
