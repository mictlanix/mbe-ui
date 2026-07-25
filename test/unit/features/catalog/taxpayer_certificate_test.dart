import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/catalog/data/taxpayer_certificate_repository_impl.dart';

const _jsonHeaders = {
  Headers.contentTypeHeader: [Headers.jsonContentType],
};

void main() {
  group('TaxpayerCertificate.fromResponse (via TaxpayerCertificateRepositoryImpl.listForIssuer)', () {
    test('maps number/taxpayer/validity/status (data-model §3)', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'items': [_certificateJson()],
            'total': 1,
          }),
          200,
          headers: _jsonHeaders,
        ),
      );

      final certificates = await repository.listForIssuer('XAXX010101000');
      final certificate = certificates.single;

      expect(certificate.taxpayerCertificateId, '00001000000203341766');
      expect(certificate.taxpayer, 'XAXX010101000');
      expect(certificate.validFrom, DateTime.parse('2025-01-01T00:00:00.000Z'));
      expect(certificate.validTo, DateTime.parse('2029-01-01T00:00:00.000Z'));
      expect(certificate.status, EntityStatus.active);
    });

    test('scopes the list to the given issuer RFC via the taxpayer filter '
        '(FR-020)', () async {
      late Map<String, dynamic> captured;
      final repository = _repositoryWith((options) async {
        captured = options.queryParameters;
        return ResponseBody.fromString(
          jsonEncode({'items': [], 'total': 0}),
          200,
          headers: _jsonHeaders,
        );
      });

      await repository.listForIssuer('XAXX010101000');

      expect(captured['taxpayer'], 'XAXX010101000');
    });
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
