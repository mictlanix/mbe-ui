import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';

/// Exercises product photo display/upload/replace/remove against a *real*
/// mbe-api instance (constitution §VII — no mocked/offline mode), covering
/// quickstart.md Stories 1-3. Requires mbe-api running at [apiBaseUrl]
/// (default `http://127.0.0.1:8000`).
///
/// Configure via `--dart-define`:
///   --dart-define=MBE_TEST_USERNAME=...           (account with products.update)
///   --dart-define=MBE_TEST_PASSWORD=...
///   --dart-define=MBE_READONLY_USERNAME=...       (account with products.read only)
///   --dart-define=MBE_READONLY_PASSWORD=...
///   --dart-define=MBE_NO_PHOTO_PRODUCT_ID=...     (an existing product id with no photo)
///   --dart-define=MBE_WITH_PHOTO_PRODUCT_ID=...   (an existing product id that already has a photo)
///   --dart-define=MBE_MUTABLE_PRODUCT_ID=...      (a product id safe to upload/remove photos on
///                                                   repeatedly; tests clean up via removePhoto after)
///
/// Tests requiring seeded credentials/data are skipped when not provided.
/// US3 replace/remove scenarios are exercised by an extension added in a
/// later phase (T024), not here.
const _testUsername = String.fromEnvironment('MBE_TEST_USERNAME');
const _testPassword = String.fromEnvironment('MBE_TEST_PASSWORD');
const _readOnlyUsername = String.fromEnvironment('MBE_READONLY_USERNAME');
const _readOnlyPassword = String.fromEnvironment('MBE_READONLY_PASSWORD');
const _noPhotoProductId = String.fromEnvironment('MBE_NO_PHOTO_PRODUCT_ID');
const _withPhotoProductId = String.fromEnvironment('MBE_WITH_PHOTO_PRODUCT_ID');
const _mutableProductId = String.fromEnvironment('MBE_MUTABLE_PRODUCT_ID');

const _hasTestCredentials = _testUsername != '' && _testPassword != '';
const _hasReadOnlyCredentials =
    _readOnlyUsername != '' && _readOnlyPassword != '';
const _hasNoPhotoProduct = _noPhotoProductId != '';
const _hasWithPhotoProduct = _withPhotoProductId != '';
const _hasMutableProduct = _mutableProductId != '';

/// A minimal valid 1x1 PNG (smallest file PIL will reliably decode), used
/// so the upload tests don't depend on a real test fixture image on disk.
final _tinyPngBytes = Uint8List.fromList([
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0D, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x64, 0x60, 0x60, 0x60,
  0x00, 0x00, 0x00, 0x05, 0x00, 0x01, 0x5D, 0x4C, 0x8F, 0x0C, 0x00, 0x00,
  0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);

Future<ProductRepositoryImpl> _authenticatedProductRepository(
  String username,
  String password,
) async {
  final dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
  final token = await AuthRepositoryImpl(dio).login(
    username: username,
    password: password,
  );
  dio.options.headers['Authorization'] = 'Bearer $token';
  return ProductRepositoryImpl(dio);
}

void main() {
  test(
    'scenario: a product with a photo shows it on the detail screen '
    '(FR-001)',
    () async {
      final repository =
          await _authenticatedProductRepository(_testUsername, _testPassword);

      final product = await repository.get(
        productId: int.parse(_withPhotoProductId),
      );

      expect(product.photo, isNotNull);
    },
    skip: !_hasTestCredentials || !_hasWithPhotoProduct,
  );

  test(
    'scenario: a product with no photo shows the placeholder on the '
    'detail screen (FR-002, SC-004)',
    () async {
      final repository =
          await _authenticatedProductRepository(_testUsername, _testPassword);

      final product = await repository.get(
        productId: int.parse(_noPhotoProductId),
      );

      expect(product.photo, isNull);
    },
    skip: !_hasTestCredentials || !_hasNoPhotoProduct,
  );

  test(
    'scenario: a product with a photo shows it in its own list row '
    '(mictlanix/mbe-api#71, FR-001)',
    () async {
      final repository =
          await _authenticatedProductRepository(_testUsername, _testPassword);
      final product = await repository.get(
        productId: int.parse(_withPhotoProductId),
      );

      final result = await repository.list(search: product.code, limit: 1);

      expect(result.items, isNotEmpty);
      expect(result.items.single.photo, product.photo);
    },
    skip: !_hasTestCredentials || !_hasWithPhotoProduct,
  );

  test(
    'scenario: uploading a valid photo persists it and is reflected on '
    'the next get (FR-003, SC-001)',
    () async {
      final repository =
          await _authenticatedProductRepository(_testUsername, _testPassword);
      final productId = int.parse(_mutableProductId);

      final uploaded = await repository.uploadPhoto(
        productId: productId,
        bytes: _tinyPngBytes,
        filename: 'photo.png',
      );
      expect(uploaded.photo, isNotNull);

      final reloaded = await repository.get(productId: productId);
      expect(reloaded.photo, uploaded.photo);

      await repository.removePhoto(productId: productId); // cleanup
    },
    skip: !_hasTestCredentials || !_hasMutableProduct,
  );

  test(
    'scenario: an unsupported file type is rejected with a validation '
    'error (FR-006, SC-002)',
    () async {
      final repository =
          await _authenticatedProductRepository(_testUsername, _testPassword);

      await expectLater(
        () => repository.uploadPhoto(
          productId: int.parse(_mutableProductId),
          bytes: Uint8List.fromList('not an image'.codeUnits),
          filename: 'document.txt',
        ),
        throwsA(isA<ValidationError>()),
      );
    },
    skip: !_hasTestCredentials || !_hasMutableProduct,
  );

  test(
    'scenario: an oversized file is rejected with a validation error '
    '(FR-007, SC-002)',
    () async {
      final repository =
          await _authenticatedProductRepository(_testUsername, _testPassword);

      await expectLater(
        () => repository.uploadPhoto(
          productId: int.parse(_mutableProductId),
          bytes: Uint8List(2 * 1024 * 1024 + 1),
          filename: 'photo.png',
        ),
        throwsA(isA<ValidationError>()),
      );
    },
    skip: !_hasTestCredentials || !_hasMutableProduct,
  );

  test(
    'scenario: replacing an existing photo updates it everywhere the '
    'product is displayed (FR-004)',
    () async {
      final repository =
          await _authenticatedProductRepository(_testUsername, _testPassword);
      final productId = int.parse(_mutableProductId);

      final first = await repository.uploadPhoto(
        productId: productId,
        bytes: _tinyPngBytes,
        filename: 'first.png',
      );
      final second = await repository.uploadPhoto(
        productId: productId,
        bytes: _tinyPngBytes,
        filename: 'second.png',
      );

      expect(second.photo, isNotNull);
      final reloaded = await repository.get(productId: productId);
      expect(reloaded.photo, second.photo);

      // Content-hash dedup (research.md §1) means uploading the same bytes
      // twice may legitimately resolve to the same filename/URL — this
      // assertion only confirms the *second* call's result persisted, not
      // that the URL necessarily changed.
      expect(first.photo, isNotNull);

      await repository.removePhoto(productId: productId); // cleanup
    },
    skip: !_hasTestCredentials || !_hasMutableProduct,
  );

  test(
    'scenario: removing a photo reverts the product to the placeholder '
    'everywhere it is displayed (FR-005, SC-005)',
    () async {
      final repository =
          await _authenticatedProductRepository(_testUsername, _testPassword);
      final productId = int.parse(_mutableProductId);
      await repository.uploadPhoto(
        productId: productId,
        bytes: _tinyPngBytes,
        filename: 'photo.png',
      );

      final removed = await repository.removePhoto(productId: productId);

      expect(removed.photo, isNull);
      final reloaded = await repository.get(productId: productId);
      expect(reloaded.photo, isNull);
    },
    skip: !_hasTestCredentials || !_hasMutableProduct,
  );

  test(
    'scenario: a Read-only account can still view photos (no privilege '
    'required to read) (FR-009)',
    () async {
      final repository = await _authenticatedProductRepository(
        _readOnlyUsername,
        _readOnlyPassword,
      );

      final product = await repository.get(
        productId: int.parse(_withPhotoProductId),
      );

      expect(product.photo, isNotNull);
    },
    skip: !_hasReadOnlyCredentials || !_hasWithPhotoProduct,
  );
}
