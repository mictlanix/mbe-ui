import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/vehicle_operator_repository_impl.dart';

/// Live round trip for spec 051's vehicle operator license photos against a
/// *real* mbe-api instance (constitution §VII): upload, read back, replace,
/// remove, and the unauthenticated read that must be refused.
///
/// This is also the live check constitution §III asks for before a generated
/// multipart wrapper is trusted (quickstart Q4), and it proves the raw-bytes
/// read (research R1) against the server's real `image/png` response.
///
/// Operates at the repository layer like `supplier_sub_panels_live_test.dart`.
/// It borrows an existing operator that has no photo, discovered at runtime,
/// and leaves it as it found it: the photo is removed at the end, and again in
/// the tear-down if the test dies midway. (It does not create an operator —
/// creating one is rejected with 409 on the dev tenant for any input, which is
/// unrelated to photos.) Skipped (not failed) without credentials or when every
/// operator already has a photo.
///
/// Requires mbe-api at [apiBaseUrl] (default `http://127.0.0.1:8000`, or
/// `--dart-define=API_BASE_URL=...`) and an administrator account:
///   --dart-define=MBE_CATALOG_TEST_USERNAME=...
///   --dart-define=MBE_CATALOG_TEST_PASSWORD=...
const _username = String.fromEnvironment('MBE_CATALOG_TEST_USERNAME');
const _password = String.fromEnvironment('MBE_CATALOG_TEST_PASSWORD');

const _canRun = _username != '' && _password != '';

/// A valid 1×1 PNG — every chunk's CRC checks out, unlike `kTinyPng` in the
/// document test fakes.
final _png = Uint8List.fromList(const [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, //
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0D, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0xF8, 0xCF, 0xC0, 0xF0,
  0x1F, 0x00, 0x05, 0x00, 0x01, 0xFF, 0x89, 0x99, 0x3D, 0x1D, 0x00, 0x00,
  0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);

void main() {
  late Dio dio;
  late VehicleOperatorRepositoryImpl repo;
  int? operatorId;

  tearDown(() async {
    // Best-effort cleanup; a failure here must never mask a test failure. A
    // 404 just means the test already removed the photo.
    final id = operatorId;
    if (!_canRun || id == null) return;
    try {
      await repo.removeLicensePhoto(vehicleOperatorId: id);
    } catch (_) {}
    operatorId = null;
  });

  test('License photo: upload, read back as PNG, replace, remove, and refuse '
      'unauthenticated reads', () async {
    dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
    final token = await AuthRepositoryImpl(
      dio,
    ).login(username: _username, password: _password);
    dio.options.headers['Authorization'] = 'Bearer $token';
    repo = VehicleOperatorRepositoryImpl(dio);

    // 1. Runtime-discovered operator with no photo yet.
    final page = await repo.list(limit: 100);
    final candidates = page.items.where((o) => !o.hasLicensePhoto);
    if (candidates.isEmpty) {
      markTestSkipped('Every operator already has a photo; none to borrow.');
      return;
    }
    final id = candidates.first.vehicleOperatorId;
    operatorId = id;

    // 2. Nothing stored yet: reading it is a 404.
    expect((await repo.get(vehicleOperatorId: id)).hasLicensePhoto, isFalse);
    await expectLater(
      repo.getLicensePhoto(vehicleOperatorId: id),
      throwsA(isA<NotFoundError>()),
      reason: 'reading a photo that was never stored is a 404',
    );

    // 3. Upload through the generated multipart wrapper (§III live check).
    final uploaded = await repo.uploadLicensePhoto(
      vehicleOperatorId: id,
      bytes: _png,
      filename: 'license.png',
    );
    expect(uploaded.hasLicensePhoto, isTrue);
    expect((await repo.get(vehicleOperatorId: id)).hasLicensePhoto, isTrue);

    // 4. Read back through the raw-bytes GET (research R1): a real PNG.
    final stored = await repo.getLicensePhoto(vehicleOperatorId: id);
    expect(stored.sublist(0, 8), _png.sublist(0, 8));

    // 5. Replace: still exactly one photo, still readable.
    await repo.uploadLicensePhoto(
      vehicleOperatorId: id,
      bytes: _png,
      filename: 'renewed.png',
    );
    expect((await repo.get(vehicleOperatorId: id)).hasLicensePhoto, isTrue);
    expect(
      (await repo.getLicensePhoto(vehicleOperatorId: id)).sublist(0, 8),
      _png.sublist(0, 8),
    );

    // 6. The photo is personal data: no token, no photo (quickstart Q5).
    await expectLater(
      Dio(BaseOptions(baseUrl: apiBaseUrl)).get<List<int>>(
        '/api/v1/vehicle-operators/$id/license-photo',
        options: Options(responseType: ResponseType.bytes),
      ),
      throwsA(
        isA<DioException>().having(
          (e) => e.response?.statusCode,
          'status',
          401,
        ),
      ),
    );

    // 7. A file the server cannot decode is refused, and the stored photo
    // is left as it was.
    await expectLater(
      repo.uploadLicensePhoto(
        vehicleOperatorId: id,
        bytes: Uint8List.fromList(List.filled(32, 7)),
        filename: 'not-an-image.png',
      ),
      throwsA(isA<AppError>()),
    );
    expect((await repo.get(vehicleOperatorId: id)).hasLicensePhoto, isTrue);

    // 8. Remove: the flag clears and the read is a 404 again.
    await repo.removeLicensePhoto(vehicleOperatorId: id);
    expect((await repo.get(vehicleOperatorId: id)).hasLicensePhoto, isFalse);
    await expectLater(
      repo.getLicensePhoto(vehicleOperatorId: id),
      throwsA(isA<NotFoundError>()),
    );
  }, skip: !_canRun);
}
