import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';

/// Exercises `ProductRepositoryImpl` against a *real* mbe-api instance
/// (constitution §VII — no mocked/offline mode), covering quickstart.md
/// "Story 1" acceptance scenarios 1, 2, and 4 (spec.md "User Story 1 -
/// Browse and find products").
///
/// Requires mbe-api running at [apiBaseUrl] (default
/// `http://127.0.0.1:8000`) with at least one known product seeded.
/// Configure via `--dart-define`:
///   --dart-define=MBE_TEST_USERNAME=...        (account with products.read)
///   --dart-define=MBE_TEST_PASSWORD=...
///   --dart-define=MBE_KNOWN_PRODUCT_CODE=...    (an existing product's code)
///   --dart-define=MBE_KNOWN_PRODUCT_NAME_PART=... (a partial name match)
///   --dart-define=MBE_CREATE_TEST_USERNAME=...  (account with products.create)
///   --dart-define=MBE_CREATE_TEST_PASSWORD=...
///
/// Tests requiring seeded credentials/data are skipped when not provided.
/// US3/US4 scenarios (edit/deactivate) are exercised by extensions added in
/// later phases (T025, T032), not here.
const _testUsername = String.fromEnvironment('MBE_TEST_USERNAME');
const _testPassword = String.fromEnvironment('MBE_TEST_PASSWORD');
const _knownProductCode = String.fromEnvironment('MBE_KNOWN_PRODUCT_CODE');
const _knownProductNamePart = String.fromEnvironment(
  'MBE_KNOWN_PRODUCT_NAME_PART',
);
const _createUsername = String.fromEnvironment('MBE_CREATE_TEST_USERNAME');
const _createPassword = String.fromEnvironment('MBE_CREATE_TEST_PASSWORD');

const _hasTestCredentials = _testUsername != '' && _testPassword != '';
const _hasKnownProduct = _knownProductCode != '';
const _hasKnownProductName = _knownProductNamePart != '';
const _hasCreateCredentials = _createUsername != '' && _createPassword != '';

void main() {
  late AuthRepositoryImpl authRepository;
  late ProductRepositoryImpl productRepository;

  setUp(() {
    final dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
    authRepository = AuthRepositoryImpl(dio);
    productRepository = ProductRepositoryImpl(dio);
  });

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
    'scenario 1: an exact code search finds the known product (SC-001)',
    () async {
      final result = await productRepository.list(search: _knownProductCode);

      expect(
        result.items.any((p) => p.code == _knownProductCode),
        isTrue,
        reason: 'expected $_knownProductCode among search results',
      );
    },
    skip: !_hasKnownProduct,
  );

  test(
    'scenario 2: a partial name search finds matching products',
    () async {
      final result = await productRepository.list(
        search: _knownProductNamePart,
      );

      expect(
        result.items.any(
          (p) => p.name.toLowerCase().contains(
            _knownProductNamePart.toLowerCase(),
          ),
        ),
        isTrue,
      );
    },
    skip: !_hasKnownProductName,
  );

  test(
    'scenario 4: a user without products privilege is denied access (FR-012, SC-004)',
    () async {
      final token = await authRepository.login(
        username: _testUsername,
        password: _testPassword,
      );
      final user = await authRepository.me();
      final access = AccessControlService(
        AuthState.authenticated(token: token, user: user),
      );

      // A module with no `Privilege` row is fully inaccessible (FR-012).
      // The seeded test account is expected to have no `products` privilege.
      expect(access.can(SystemObject.products, AccessRight.read), isFalse);
    },
    skip: !_hasTestCredentials,
  );

  test('US2 scenario 1: a valid create appears in the catalog as active '
      '(FR-003, FR-015, SC-002)', () async {
    final repo = await authenticatedProductRepository(
      _createUsername,
      _createPassword,
    );
    final code = 'IT-${DateTime.now().millisecondsSinceEpoch}';

    final created = await repo.create(
      code: code,
      name: 'Integration Test Widget',
      unitOfMeasurement: 'PCE',
    );

    expect(created.code, code);
    expect(created.status, EntityStatus.active);

    final fetched = await repo.get(productId: created.productId);
    expect(fetched.code, code);
  }, skip: !_hasCreateCredentials);

  test(
    'US2 scenario 2: a duplicate code is rejected (FR-004)',
    () async {
      final repo = await authenticatedProductRepository(
        _createUsername,
        _createPassword,
      );
      final code = 'IT-${DateTime.now().millisecondsSinceEpoch}';

      await repo.create(
        code: code,
        name: 'Integration Test Widget',
        unitOfMeasurement: 'PCE',
      );

      await expectLater(
        () => repo.create(
          code: code,
          name: 'Integration Test Widget Duplicate',
          unitOfMeasurement: 'PCE',
        ),
        throwsA(isA<ValidationError>()),
      );
    },
    skip: !_hasCreateCredentials,
  );

  test(
    'US2 scenario 4: an invalid name is rejected (FR-006)',
    () async {
      final repo = await authenticatedProductRepository(
        _createUsername,
        _createPassword,
      );

      await expectLater(
        () => repo.create(
          code: 'IT-${DateTime.now().millisecondsSinceEpoch}',
          name: 'Hi',
          unitOfMeasurement: 'PCE',
        ),
        throwsA(isA<ValidationError>()),
      );
    },
    skip: !_hasCreateCredentials,
  );

  test('US3 scenario 1: editing a name/tax rate persists and is reflected on '
      'a fresh get() (FR-009)', () async {
    final repo = await authenticatedProductRepository(
      _createUsername,
      _createPassword,
    );
    final created = await repo.create(
      code: 'IT-${DateTime.now().millisecondsSinceEpoch}',
      name: 'Integration Test Widget',
      unitOfMeasurement: 'PCE',
      taxRate: '0.16',
    );

    final updated = await repo.update(
      productId: created.productId,
      name: 'Integration Test Widget Updated',
      taxRate: '0',
    );

    expect(updated.name, 'Integration Test Widget Updated');
    expect(updated.taxRate, '0');

    final fetched = await repo.get(productId: created.productId);
    expect(fetched.name, 'Integration Test Widget Updated');
  }, skip: !_hasCreateCredentials);

  test(
    'US3 scenario 2: renaming to an existing code is rejected (FR-004)',
    () async {
      final repo = await authenticatedProductRepository(
        _createUsername,
        _createPassword,
      );
      final existingCode = 'IT-${DateTime.now().millisecondsSinceEpoch}-a';
      await repo.create(
        code: existingCode,
        name: 'Integration Test Widget A',
        unitOfMeasurement: 'PCE',
      );
      final toRename = await repo.create(
        code: 'IT-${DateTime.now().millisecondsSinceEpoch}-b',
        name: 'Integration Test Widget B',
        unitOfMeasurement: 'PCE',
      );

      await expectLater(
        () => repo.update(productId: toRename.productId, code: existingCode),
        throwsA(isA<ValidationError>()),
      );
    },
    skip: !_hasCreateCredentials,
  );

  test('US3 scenario 3: a user without products.update privilege is denied '
      '(FR-012, FR-013)', () async {
    final token = await authRepository.login(
      username: _testUsername,
      password: _testPassword,
    );
    final user = await authRepository.me();
    final access = AccessControlService(
      AuthState.authenticated(token: token, user: user),
    );

    expect(access.can(SystemObject.products, AccessRight.update), isFalse);
  }, skip: !_hasTestCredentials);

  test('US4 scenario 1: deactivating excludes a product from the default '
      '(active-only) list (FR-010, FR-011, SC-005)', () async {
    final repo = await authenticatedProductRepository(
      _createUsername,
      _createPassword,
    );
    final code = 'IT-${DateTime.now().millisecondsSinceEpoch}';
    final created = await repo.create(
      code: code,
      name: 'Integration Test Widget',
      unitOfMeasurement: 'PCE',
    );

    final deactivated = await repo.update(
      productId: created.productId,
      status: EntityStatus.inactive,
    );
    expect(deactivated.status, EntityStatus.inactive);

    final activeOnly = await repo.list(
      search: code,
      status: EntityStatus.active,
    );
    expect(
      activeOnly.items.any((p) => p.productId == created.productId),
      isFalse,
    );
  }, skip: !_hasCreateCredentials);

  test('US4 scenario 2: a deactivated product is still found with the '
      '"include disabled" filter, marked inactive (FR-011)', () async {
    final repo = await authenticatedProductRepository(
      _createUsername,
      _createPassword,
    );
    final code = 'IT-${DateTime.now().millisecondsSinceEpoch}';
    final created = await repo.create(
      code: code,
      name: 'Integration Test Widget',
      unitOfMeasurement: 'PCE',
    );
    await repo.update(
      productId: created.productId,
      status: EntityStatus.inactive,
    );

    final includeDisabled = await repo.list(search: code);
    final found = includeDisabled.items.singleWhere(
      (p) => p.productId == created.productId,
    );
    expect(found.status, EntityStatus.inactive);
  }, skip: !_hasCreateCredentials);

  test('US4 scenario 4: a user without products.delete privilege is denied '
      '(FR-012)', () async {
    final token = await authRepository.login(
      username: _testUsername,
      password: _testPassword,
    );
    final user = await authRepository.me();
    final access = AccessControlService(
      AuthState.authenticated(token: token, user: user),
    );

    expect(access.can(SystemObject.products, AccessRight.delete), isFalse);
  }, skip: !_hasTestCredentials);
}
