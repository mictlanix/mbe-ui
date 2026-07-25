import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart';

import 'package:mbe_ui/features/catalog/data/taxpayer_issuer_repository_impl.dart';

const _jsonHeaders = {
  Headers.contentTypeHeader: [Headers.jsonContentType],
};

void main() {
  group('TaxpayerIssuer.fromResponse (via TaxpayerIssuerRepositoryImpl.getDetail)', () {
    test('maps the pre-expanded regime/postalCode SAT objects (data-model §2)', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode(_issuerJson()),
          200,
          headers: _jsonHeaders,
        ),
      );

      final issuer = await repository.getDetail('XAXX010101000');

      expect(issuer.rfc, 'XAXX010101000');
      expect(issuer.name, 'Acme Corp');
      expect(issuer.regime?.description, 'General de Ley Personas Morales');
      expect(issuer.postalCode?.description, 'Ciudad de México');
      expect(issuer.provider, FiscalCertificationProvider.number1);
    });

    test('a null regime/postalCode falls back to null rather than crashing', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({..._issuerJson(), 'regime': null, 'postal_code': null}),
          200,
          headers: _jsonHeaders,
        ),
      );

      final issuer = await repository.getDetail('XAXX010101000');

      expect(issuer.regime, isNull);
      expect(issuer.postalCode, isNull);
    });

    test('a missing name falls back to empty (Taxpayer Recipient precedent)', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({..._issuerJson(), 'name': null}),
          200,
          headers: _jsonHeaders,
        ),
      );

      final issuer = await repository.getDetail('XAXX010101000');

      expect(issuer.name, isEmpty);
    });
  });
}

Map<String, Object?> _issuerJson() => {
  'taxpayer_issuer_id': 'XAXX010101000',
  'name': 'Acme Corp',
  'regime': {'id': '601', 'description': 'General de Ley Personas Morales'},
  'provider': 1,
  'postal_code': {'id': '06500', 'description': 'Ciudad de México'},
  'comment': null,
};

TaxpayerIssuerRepositoryImpl _repositoryWith(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = _FakeHttpClientAdapter(handler);
  return TaxpayerIssuerRepositoryImpl(dio);
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
