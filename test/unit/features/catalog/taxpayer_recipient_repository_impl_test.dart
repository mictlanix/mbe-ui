import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/data/taxpayer_recipient_repository_impl.dart';

const _jsonHeaders = {
  Headers.contentTypeHeader: [Headers.jsonContentType],
};

void main() {
  group('TaxpayerRecipientRepositoryImpl.list', () {
    test('200 returns items and total', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'items': [_taxpayerJson()],
            'total': 1,
          }),
          200,
          headers: _jsonHeaders,
        ),
      );

      final result = await repository.list();

      expect(result.total, 1);
      expect(result.items.single.taxpayerRecipientId, 'XAXX010101000');
    });
  });

  group('TaxpayerRecipientRepositoryImpl.get', () {
    test(
      '200 maps expanded postalCode/regime FKs to descriptions (research.md §7)',
      () async {
        final repository = _repositoryWith(
          (options) async => ResponseBody.fromString(
            jsonEncode(_taxpayerJson()),
            200,
            headers: _jsonHeaders,
          ),
        );

        final taxpayer = await repository.get(
          taxpayerRecipientId: 'XAXX010101000',
        );

        expect(taxpayer.postalCode?.description, 'Ciudad de México');
        expect(taxpayer.regime?.description, 'General de Ley Personas Morales');
      },
    );

    test(
      'an unresolved postalCode/regime falls back to null rather than crashing',
      () async {
        final repository = _repositoryWith(
          (options) async => ResponseBody.fromString(
            jsonEncode({
              ..._taxpayerJson(),
              'postal_code': null,
              'regime': null,
            }),
            200,
            headers: _jsonHeaders,
          ),
        );

        final taxpayer = await repository.get(
          taxpayerRecipientId: 'XAXX010101000',
        );

        expect(taxpayer.postalCode, isNull);
        expect(taxpayer.regime, isNull);
      },
    );

    test('404 maps to AppError.notFound', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'detail': 'Taxpayer recipient not found'}),
          404,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.get(taxpayerRecipientId: 'UNKNOWN000000'),
        throwsA(const AppError.notFound('Taxpayer recipient not found')),
      );
    });
  });

  group('TaxpayerRecipientRepositoryImpl.create', () {
    test(
      'sends the client-supplied taxpayerRecipientId in the request body',
      () async {
        RequestOptions? captured;
        final repository = _repositoryWith((options) async {
          captured = options;
          return ResponseBody.fromString(
            jsonEncode(_taxpayerJson()),
            201,
            headers: _jsonHeaders,
          );
        });

        await repository.create(
          taxpayerRecipientId: 'XAXX010101000',
          email: 'test@example.com',
          name: 'Acme Corp',
          postalCode: '06500',
          regime: '601',
        );

        final sentBody = _decodeBody(captured!.data);
        expect(sentBody['taxpayer_recipient_id'], 'XAXX010101000');
        expect(sentBody['postal_code'], '06500');
        expect(sentBody['regime'], '601');
      },
    );

    test('a duplicate tax id rejection maps to AppError.validation, not a '
        'silent overwrite (FR-027)', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'detail': [
              {
                'loc': ['body', 'taxpayer_recipient_id'],
                'msg': 'Taxpayer recipient already exists',
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
          taxpayerRecipientId: 'XAXX010101000',
          email: 'test@example.com',
        ),
        throwsA(isA<ValidationError>()),
      );
    });
  });

  group('TaxpayerRecipientRepositoryImpl.update', () {
    test('the rfc path param is used, and the id is never sent in the body '
        '(immutable, research.md §9)', () async {
      RequestOptions? captured;
      final repository = _repositoryWith((options) async {
        captured = options;
        return ResponseBody.fromString(
          jsonEncode(_taxpayerJson()),
          200,
          headers: _jsonHeaders,
        );
      });

      await repository.update(
        taxpayerRecipientId: 'XAXX010101000',
        email: 'updated@example.com',
      );

      expect(captured!.path, contains('XAXX010101000'));
      final sentBody = _decodeBody(captured!.data);
      expect(sentBody.containsKey('taxpayer_recipient_id'), isFalse);
      expect(sentBody['email'], 'updated@example.com');
    });

    test('404 maps to AppError.notFound', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'detail': 'Taxpayer recipient not found'}),
          404,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.update(
          taxpayerRecipientId: 'UNKNOWN000000',
          email: 'anything@example.com',
        ),
        throwsA(const AppError.notFound('Taxpayer recipient not found')),
      );
    });
  });

  group('TaxpayerRecipientRepositoryImpl.delete', () {
    test('204 completes with no error', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString('', 204),
      );

      await expectLater(
        repository.delete(taxpayerRecipientId: 'XAXX010101000'),
        completes,
      );
    });
  });
}

Map<String, Object?> _taxpayerJson() => {
  'taxpayer_recipient_id': 'XAXX010101000',
  'name': 'Acme Corp',
  'email': 'test@example.com',
  'postal_code': {'id': '06500', 'description': 'Ciudad de México'},
  'regime': {'id': '601', 'description': 'General de Ley Personas Morales'},
};

Map<String, Object?> _decodeBody(Object? data) => data is String
    ? jsonDecode(data) as Map<String, Object?>
    : data as Map<String, Object?>;

TaxpayerRecipientRepositoryImpl _repositoryWith(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = _FakeHttpClientAdapter(handler);
  return TaxpayerRecipientRepositoryImpl(dio);
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
