import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/auth_interceptor.dart';
import 'package:mbe_ui/core/storage/token_storage.dart';

/// `ResponseType.bytes` applies to error responses too, so the server's JSON
/// refusal of a PDF request (spec 044, research R9) reaches the interceptor as
/// a `Uint8List`. These tests run the real interceptor over a stubbed adapter
/// so the whole `onError` → `mapDioException` path is exercised.
void main() {
  group('AuthInterceptor error mapping for byte bodies', () {
    test('a JSON 404 delivered as bytes keeps the server detail', () async {
      final error = await _fetchBytes(
        404,
        jsonBody: {'detail': 'Sales order not found'},
      );

      expect(
        error,
        isA<NotFoundError>().having(
          (e) => e.message,
          'message',
          'Sales order not found',
        ),
      );
    });

    test('a JSON 409 delivered as bytes keeps the server detail', () async {
      final error = await _fetchBytes(
        409,
        jsonBody: {'detail': 'Cash session is not closed'},
      );

      expect(
        error,
        isA<ServerError>()
            .having((e) => e.statusCode, 'statusCode', 409)
            .having((e) => e.message, 'message', 'Cash session is not closed'),
      );
    });

    test('a JSON 403 delivered as bytes keeps the server detail', () async {
      final error = await _fetchBytes(
        403,
        jsonBody: {'detail': 'Insufficient privileges'},
      );

      expect(
        error,
        isA<ServerError>()
            .having((e) => e.statusCode, 'statusCode', 403)
            .having((e) => e.message, 'message', 'Insufficient privileges'),
      );
    });

    test('a JSON 422 delivered as bytes keeps its field errors', () async {
      final error = await _fetchBytes(
        422,
        jsonBody: {
          'detail': [
            {
              'loc': ['path', 'sales_order_id'],
              'msg': 'Input should be a valid integer',
              'type': 'int_parsing',
            },
          ],
        },
      );

      expect(error, isA<ValidationError>());
      final fields = (error as ValidationError).errors;
      expect(fields, hasLength(1));
      expect(fields.single.loc, ['path', 'sales_order_id']);
      expect(fields.single.msg, 'Input should be a valid integer');
      expect(fields.single.type, 'int_parsing');
    });

    test('a JSON 401 delivered as bytes is an AuthError and still signs the '
        'user out (session expiry while a document loads)', () async {
      var unauthorizedCalls = 0;

      final error = await _fetchBytes(
        401,
        jsonBody: {'detail': 'Could not validate credentials'},
        onUnauthorized: () => unauthorizedCalls++,
      );

      expect(
        error,
        isA<AuthError>().having(
          (e) => e.message,
          'message',
          'Could not validate credentials',
        ),
      );
      expect(unauthorizedCalls, 1);
    });

    test(
      'a body that is not JSON yields no message and does not throw',
      () async {
        final error = await _fetchBytes(
          500,
          rawBody: Uint8List.fromList(utf8.encode('<html>Bad gateway</html>')),
          contentType: 'text/html',
        );

        expect(
          error,
          isA<ServerError>()
              .having((e) => e.statusCode, 'statusCode', 500)
              .having((e) => e.message, 'message', isNull),
        );
      },
    );

    test('a body labelled JSON that does not parse yields no message and '
        'does not throw', () async {
      final error = await _fetchBytes(
        500,
        rawBody: Uint8List.fromList(utf8.encode('{not json')),
      );

      expect(
        error,
        isA<ServerError>().having((e) => e.message, 'message', isNull),
      );
    });

    test('an empty byte body yields no message and does not throw', () async {
      final error = await _fetchBytes(502, rawBody: Uint8List(0));

      expect(
        error,
        isA<ServerError>()
            .having((e) => e.statusCode, 'statusCode', 502)
            .having((e) => e.message, 'message', isNull),
      );
    });
  });

  group('AuthInterceptor error mapping for ordinary bodies', () {
    test(
      'a JSON body already decoded to a Map behaves exactly as before',
      () async {
        final dio = _dioWith(
          (options) async => ResponseBody.fromString(
            jsonEncode({'detail': 'Sales order not found'}),
            404,
            headers: _jsonHeaders,
          ),
        );

        final error = await _errorOf(() => dio.get<Object>('/x'));

        expect(
          error,
          isA<NotFoundError>().having(
            (e) => e.message,
            'message',
            'Sales order not found',
          ),
        );
      },
    );

    test('a structured detail still surfaces its headline', () async {
      final dio = _dioWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'detail': {'message': 'Insufficient stock', 'lines': []},
          }),
          409,
          headers: _jsonHeaders,
        ),
      );

      final error = await _errorOf(() => dio.get<Object>('/x'));

      expect(
        error,
        isA<ServerError>().having(
          (e) => e.message,
          'message',
          'Insufficient stock',
        ),
      );
    });
  });
}

const _jsonHeaders = {
  Headers.contentTypeHeader: ['application/json'],
};

/// Requests `/x` as bytes (as the generated print methods do) against a stub
/// answering [status], and returns the [AppError] the interceptor attached.
Future<AppError> _fetchBytes(
  int status, {
  Map<String, Object?>? jsonBody,
  Uint8List? rawBody,
  String contentType = 'application/json',
  void Function()? onUnauthorized,
}) {
  final bytes =
      rawBody ?? Uint8List.fromList(utf8.encode(jsonEncode(jsonBody)));
  final dio = _dioWith(
    (options) async => ResponseBody.fromBytes(
      bytes,
      status,
      headers: {
        Headers.contentTypeHeader: [contentType],
      },
    ),
    onUnauthorized: onUnauthorized,
  );
  return _errorOf(
    () => dio.get<Object>(
      '/x',
      options: Options(responseType: ResponseType.bytes),
    ),
  );
}

Future<AppError> _errorOf(Future<Object?> Function() request) async {
  try {
    await request();
  } on DioException catch (e) {
    final mapped = e.error;
    if (mapped is AppError) return mapped;
    fail('the interceptor did not attach an AppError: ${e.error}');
  }
  fail('expected the request to fail');
}

Dio _dioWith(
  Future<ResponseBody> Function(RequestOptions options) handler, {
  void Function()? onUnauthorized,
}) {
  final interceptor = AuthInterceptor(_NoTokenStorage())
    ..onUnauthorized = onUnauthorized;
  return Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = _FakeHttpClientAdapter(handler)
    ..interceptors.add(interceptor);
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
