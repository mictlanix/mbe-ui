import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
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
///
/// Tests requiring seeded credentials/data are skipped when not provided.
/// US2-US4 scenarios (create/edit/deactivate) are exercised by
/// `test/integration/product_catalog_flow_test.dart` extensions added in
/// later phases (T017, T025, T032), not here.
const _testUsername = String.fromEnvironment('MBE_TEST_USERNAME');
const _testPassword = String.fromEnvironment('MBE_TEST_PASSWORD');
const _knownProductCode = String.fromEnvironment('MBE_KNOWN_PRODUCT_CODE');
const _knownProductNamePart =
    String.fromEnvironment('MBE_KNOWN_PRODUCT_NAME_PART');

const _hasTestCredentials = _testUsername != '' && _testPassword != '';
const _hasKnownProduct = _knownProductCode != '';
const _hasKnownProductName = _knownProductNamePart != '';

void main() {
  late AuthRepositoryImpl authRepository;
  late ProductRepositoryImpl productRepository;

  setUp(() {
    final dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
    authRepository = AuthRepositoryImpl(dio);
    productRepository = ProductRepositoryImpl(dio);
  });

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
      final result =
          await productRepository.list(search: _knownProductNamePart);

      expect(
        result.items.any(
          (p) => p.name.toLowerCase().contains(_knownProductNamePart.toLowerCase()),
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
}
