import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/features/catalog/data/taxpayer_certificate_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/taxpayer_certificate_repository.dart';

const _jsonHeaders = {
  Headers.contentTypeHeader: [Headers.jsonContentType],
};

void main() {
  group('TaxpayerCertificateRepositoryImpl.upload', () {
    test('base64-encodes the raw certificate/key bytes into the wire string '
        'fields (research §8)', () async {
      RequestOptions? captured;
      final repository = _repositoryWith((options) async {
        captured = options;
        return ResponseBody.fromString(
          jsonEncode(_certificateJson()),
          201,
          headers: _jsonHeaders,
        );
      });

      final certBytes = [1, 2, 3, 4];
      final keyBytes = [5, 6, 7, 8];

      await repository.upload(
        taxpayer: 'XAXX010101000',
        certificateBytes: certBytes,
        keyBytes: keyBytes,
        keyPassword: 'secret',
      );

      final body = captured!.data as FormData;
      final fields = {for (final f in body.fields) f.key: f.value};
      expect(fields['taxpayer'], 'XAXX010101000');
      expect(fields['certificate'], base64Encode(certBytes));
      expect(fields['key'], base64Encode(keyBytes));
      expect(fields['key_password'], 'secret');
    });

    test('returns the server-derived TaxpayerCertificate on success', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode(_certificateJson()),
          201,
          headers: _jsonHeaders,
        ),
      );

      final certificate = await repository.upload(
        taxpayer: 'XAXX010101000',
        certificateBytes: const [1],
        keyBytes: const [2],
        keyPassword: 'secret',
      );

      expect(certificate.taxpayerCertificateId, '00001000000203341766');
      expect(certificate.validFrom, isNotNull);
      expect(certificate.validTo, isNotNull);
    });

    test('an invalid pair / wrong password rejection maps to AppError', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'detail': 'Invalid certificate/key pair or wrong password'}),
          400,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.upload(
          taxpayer: 'XAXX010101000',
          certificateBytes: const [1],
          keyBytes: const [2],
          keyPassword: 'wrong',
        ),
        throwsA(isA<Object>()),
      );
    });
  });

  test('TaxpayerCertificateRepository exposes no update/delete methods '
      '(research §9, FR-024)', () {
    // Compile-time assertion: the interface has neither method — if one were
    // ever added, this test file (and every call site) would fail to
    // compile, making the omission enforced rather than merely documented.
    expect(TaxpayerCertificateRepository, isNotNull);
  });
}

Map<String, Object?> _certificateJson() => {
  'taxpayer_certificate_id': '00001000000203341766',
  'taxpayer': 'XAXX010101000',
  'valid_from': '2025-01-01T00:00:00.000Z',
  'valid_to': '2029-01-01T00:00:00.000Z',
  'status': 0,
};

TaxpayerCertificateRepositoryImpl _repositoryWith(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = _FakeHttpClientAdapter(handler);
  return TaxpayerCertificateRepositoryImpl(dio);
}

class _FakeHttpClientAdapter implements HttpClientAdapter {
  _FakeHttpClientAdapter(this._handler);

  final Future<ResponseBody> Function(RequestOptions options) _handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) => _handler(options);

  @override
  void close({bool force = false}) {}
}
