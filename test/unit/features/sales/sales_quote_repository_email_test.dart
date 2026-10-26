import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/auth_interceptor.dart';
import 'package:mbe_ui/core/storage/token_storage.dart';
import 'package:mbe_ui/features/sales/data/sales_quote_repository_impl.dart';

const _jsonHeaders = {
  Headers.contentTypeHeader: [Headers.jsonContentType],
};

void main() {
  group('SalesQuoteRepositoryImpl.email', () {
    test('POSTs {"to": [...]} in order to the quote email route', () async {
      RequestOptions? captured;
      final repository = _repositoryWith((options) async {
        captured = options;
        return _ok();
      });

      await repository.email(
        quoteId: 42,
        recipients: ['z@b.mx', 'a@b.mx', 'm@b.mx'],
      );

      expect(captured!.method, 'POST');
      expect(captured!.path, '/api/v1/sales-quotes/42/email');
      final body = captured!.data;
      final decoded = body is String ? jsonDecode(body) : body;
      expect(decoded, {
        'to': ['z@b.mx', 'a@b.mx', 'm@b.mx'],
      });
    });

    test('200 maps to a receipt', () async {
      final repository = _repositoryWith((options) async => _ok());

      final receipt = await repository.email(
        quoteId: 42,
        recipients: ['a@b.mx'],
      );

      expect(receipt.recipients, ['a@b.mx', 'c@d.mx']);
      expect(receipt.sentAt.year, 2026);
      expect(receipt.sentAt.month, 10);
      expect(receipt.sentAt.day, 24);
      expect(receipt.sentAt.hour, 10);
      expect(receipt.sentAt.minute, 30);
    });

    for (final status in [409, 502, 503]) {
      test('$status maps to ServerError with the server detail', () async {
        final repository = _repositoryWith(
          (options) async => _error(status, {'detail': 'detail $status'}),
        );

        await expectLater(
          () => repository.email(quoteId: 42, recipients: ['a@b.mx']),
          throwsA(
            isA<ServerError>()
                .having((e) => e.statusCode, 'statusCode', status)
                .having((e) => e.message, 'message', 'detail $status'),
          ),
        );
      });
    }

    test('422 with a string detail is a ValidationError, not a credit '
        'hold', () async {
      final repository = _repositoryWith(
        (options) async =>
            _error(422, {'detail': "Not a valid email address: 'x'"}),
      );

      await expectLater(
        () => repository.email(quoteId: 42, recipients: ['x']),
        throwsA(
          isA<ValidationError>().having(
            (e) => e.message,
            'message',
            "Not a valid email address: 'x'",
          ),
        ),
      );
    });

    test('422 with list detail maps to ValidationError field errors', () async {
      final repository = _repositoryWith(
        (options) async => _error(422, {
          'detail': [
            {
              'loc': ['body', 'to'],
              'msg': 'bad recipient',
              'type': 'value_error',
            },
          ],
        }),
      );

      await expectLater(
        () => repository.email(quoteId: 42, recipients: ['x']),
        throwsA(
          isA<ValidationError>().having(
            (e) => e.errors.map((f) => '${f.loc.join('.')}: ${f.msg}').toList(),
            'errors',
            ['body.to: bad recipient'],
          ),
        ),
      );
    });

    test('a connection failure is a NetworkError', () async {
      final repository = _repositoryWith((options) async {
        throw DioException.connectionError(
          requestOptions: options,
          reason: 'no route to host',
        );
      });

      await expectLater(
        () => repository.email(quoteId: 42, recipients: ['a@b.mx']),
        throwsA(isA<NetworkError>()),
      );
    });
  });
}

ResponseBody _ok() => ResponseBody.fromString(
  jsonEncode({
    'recipients': ['a@b.mx', 'c@d.mx'],
    'sent_at': '2026-10-24T10:30:00',
  }),
  200,
  headers: _jsonHeaders,
);

ResponseBody _error(int status, Map<String, Object?> body) =>
    ResponseBody.fromBytes(
      Uint8List.fromList(utf8.encode(jsonEncode(body))),
      status,
      headers: _jsonHeaders,
    );

SalesQuoteRepositoryImpl _repositoryWith(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = _FakeHttpClientAdapter(handler)
    ..interceptors.add(AuthInterceptor(_NoTokenStorage()));
  return SalesQuoteRepositoryImpl(dio);
}

class _NoTokenStorage extends TokenStorage {
  @override
  Future<String?> read() async => null;
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
