import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/data/taxpayer_issuer_repository_impl.dart';

const _jsonHeaders = {
  Headers.contentTypeHeader: [Headers.jsonContentType],
};

void main() {
  group('TaxpayerIssuerRepositoryImpl — regression: pre-existing list-only '
      'consumers keep working (research §13)', () {
    test('list() still returns TaxpayerIssuerListItem (spec 014 autocomplete)', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'items': [_issuerJson()],
            'total': 1,
          }),
          200,
          headers: _jsonHeaders,
        ),
      );

      final result = await repository.list();

      expect(result.total, 1);
      expect(result.items.single.rfc, 'XAXX010101000');
    });

    test('the lightweight get() still resolves an RFC to a display name '
        '(FR-034b)', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode(_issuerJson()),
          200,
          headers: _jsonHeaders,
        ),
      );

      final item = await repository.get('XAXX010101000');

      expect(item?.name, 'Acme Corp');
    });

    test('the lightweight get() still degrades to null on 404', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'detail': 'not found'}),
          404,
          headers: _jsonHeaders,
        ),
      );

      final item = await repository.get('UNKNOWN000000');

      expect(item, isNull);
    });
  });

  group('TaxpayerIssuerRepositoryImpl.create (new, FR-011)', () {
    test('sends the client-supplied RFC as taxpayer_issuer_id', () async {
      RequestOptions? captured;
      final repository = _repositoryWith((options) async {
        captured = options;
        return ResponseBody.fromString(
          jsonEncode(_issuerJson()),
          201,
          headers: _jsonHeaders,
        );
      });

      await repository.create(
        rfc: 'XAXX010101000',
        name: 'Acme Corp',
        regime: '601',
        postalCode: '06500',
      );

      final body = _decodeBody(captured!.data);
      expect(body['taxpayer_issuer_id'], 'XAXX010101000');
      expect(body['regime'], '601');
      expect(body['postal_code'], '06500');
    });

    test('a duplicate RFC rejection maps to AppError.validation (FR-017)', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'detail': [
              {
                'loc': ['body', 'taxpayer_issuer_id'],
                'msg': 'Taxpayer issuer already exists',
                'type': 'value_error',
              },
            ],
          }),
          422,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.create(
          rfc: 'XAXX010101000',
          regime: '601',
        ),
        throwsA(isA<ValidationError>()),
      );
    });
  });

  group('TaxpayerIssuerRepositoryImpl.update (new, FR-012, FR-015)', () {
    test('the rfc path param is used, and the id is never sent in the body '
        '(immutable)', () async {
      RequestOptions? captured;
      final repository = _repositoryWith((options) async {
        captured = options;
        return ResponseBody.fromString(
          jsonEncode(_issuerJson()),
          200,
          headers: _jsonHeaders,
        );
      });

      await repository.update(rfc: 'XAXX010101000', name: 'Updated Corp');

      expect(captured!.path, contains('XAXX010101000'));
      final body = _decodeBody(captured!.data);
      expect(body.containsKey('taxpayer_issuer_id'), isFalse);
      expect(body['name'], 'Updated Corp');
    });

    test('404 maps to AppError.notFound', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'detail': 'Taxpayer issuer not found'}),
          404,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.update(rfc: 'UNKNOWN000000', name: 'x'),
        throwsA(const AppError.notFound('Taxpayer issuer not found')),
      );
    });
  });

  group('TaxpayerIssuerRepositoryImpl.delete (new, FR-016)', () {
    test('204 completes with no error', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString('', 204),
      );

      await expectLater(repository.delete('XAXX010101000'), completes);
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

Map<String, Object?> _decodeBody(Object? data) => data is String
    ? jsonDecode(data) as Map<String, Object?>
    : data as Map<String, Object?>;

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
