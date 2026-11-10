import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mbe_ui/core/errors/api_problem.dart';
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

  group('AuthInterceptor password_change_required', () {
    Future<AppError> forbidden(String detail, void Function() onRequired) {
      final dio = _dioWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'detail': detail}),
          403,
          headers: _jsonHeaders,
        ),
        onPasswordChangeRequired: onRequired,
      );
      return _errorOf(() => dio.get<Object>('/x'));
    }

    test('a 403 password_change_required fires the callback and still '
        'fails the request', () async {
      var calls = 0;

      final error = await forbidden('password_change_required', () => calls++);

      expect(calls, 1);
      expect(
        error,
        isA<ServerError>()
            .having((e) => e.statusCode, 'statusCode', 403)
            .having((e) => e.message, 'message', 'password_change_required'),
      );
    });

    test('any other 403 does not fire it', () async {
      var calls = 0;

      await forbidden('Insufficient privileges', () => calls++);

      expect(calls, 0);
    });

    test(
      'the code alone fires it, whatever the detail says (spec 058)',
      () async {
        var calls = 0;
        final dio = _dioWith(
          (options) async => ResponseBody.fromString(
            jsonEncode({
              'status': 403,
              'code': 'auth.password_change_required',
              'detail': 'You must change your password',
            }),
            403,
            headers: _jsonHeaders,
          ),
          onPasswordChangeRequired: () => calls++,
        );

        final error = await _errorOf(() => dio.get<Object>('/x'));

        expect(calls, 1);
        expect(error, isA<ServerError>());
      },
    );

    test('a coded 403 for another reason does not fire it', () async {
      var calls = 0;
      final dio = _dioWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'status': 403,
            'code': 'auth.forbidden',
            'detail': 'Insufficient privileges',
            'params': {
              'required': [
                {'system_object': 7, 'right': 2},
              ],
            },
          }),
          403,
          headers: _jsonHeaders,
        ),
        onPasswordChangeRequired: () => calls++,
      );

      await _errorOf(() => dio.get<Object>('/x'));

      expect(calls, 0);
    });
  });

  group('AuthInterceptor credit refusals by code (spec 058)', () {
    const creditCodes = [
      'customer.credit_hold',
      'customer.credit_limit_exceeded',
      'customer.credit_limit_reached',
      'customer.no_credit_limit',
      'customer.walk_in_no_credit',
    ];

    test(
      'each credit code is a CreditHoldError, whatever the status',
      () async {
        for (final code in creditCodes) {
          for (final status in [409, 422]) {
            final error = await _fetchBytes(
              status,
              jsonBody: {'status': status, 'code': code, 'detail': 'English'},
            );
            expect(error, isA<CreditHoldError>(), reason: '$code $status');
            expect((error as CreditHoldError).message, 'English');
            expect(error.problem!.codeName, code);
          }
        }
      },
    );

    test(
      'another coded 422 with a string detail stays a ValidationError',
      () async {
        final error = await _fetchBytes(
          422,
          jsonBody: {
            'status': 422,
            'code': 'sales_order.below_min_quantity',
            'detail': 'Below the minimum order quantity',
          },
        );

        expect(error, isA<ValidationError>());
        expect((error as ValidationError).problem!.code, isNotNull);
      },
    );
  });

  group('AuthInterceptor error mapping for ordinary bodies', () {
    test(
      'a password_policy 422 keeps the failed rules and not the input',
      () async {
        final dio = _dioWith(
          (options) async => ResponseBody.fromString(
            jsonEncode({
              'detail': [
                {
                  'type': 'password_policy',
                  'loc': ['body', 'new_password'],
                  'msg': 'Password does not meet the policy',
                  'ctx': {
                    'failed': ['min_length', 'require_digit'],
                  },
                  'input': 'hunter2-rejected',
                },
              ],
            }),
            422,
            headers: _jsonHeaders,
          ),
        );

        final error = await _errorOf(() => dio.get<Object>('/x'));

        final field = (error as ValidationError).errors.single;
        expect(field.type, 'password_policy');
        expect(field.failedRules, ['min_length', 'require_digit']);
        expect(field.toString(), isNot(contains('hunter2-rejected')));
      },
    );

    test('a 422 without ctx has no failed rules', () async {
      final dio = _dioWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'detail': [
              {
                'loc': ['body', 'username'],
                'msg': 'field required',
                'type': 'missing',
              },
            ],
          }),
          422,
          headers: _jsonHeaders,
        ),
      );

      final error = await _errorOf(() => dio.get<Object>('/x'));

      expect((error as ValidationError).errors.single.failedRules, isEmpty);
    });

    test('a string-detail 422 keeps the server explanation (#172)', () async {
      final dio = _dioWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'detail': 'Customer has 3 overdue credit order(s)'}),
          422,
          headers: _jsonHeaders,
        ),
      );

      final error = await _errorOf(() => dio.get<Object>('/x'));

      expect(
        error,
        isA<ValidationError>()
            .having((e) => e.errors, 'errors', isEmpty)
            .having(
              (e) => e.serverMessage,
              'serverMessage',
              'Customer has 3 overdue credit order(s)',
            ),
      );
    });

    test('a field-list 422 carries no server message', () async {
      final dio = _dioWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'detail': [
              {
                'loc': ['body', 'username'],
                'msg': 'field required',
                'type': 'missing',
              },
            ],
          }),
          422,
          headers: _jsonHeaders,
        ),
      );

      final error = await _errorOf(() => dio.get<Object>('/x'));

      expect(error.serverMessage, isNull);
    });

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

  group('AuthInterceptor reads the server problem (spec 058)', () {
    Map<String, Object?> coded(String code, {Map<String, Object?>? params}) => {
      'status': 409,
      'code': code,
      'detail': 'Some English',
      'params': ?params,
    };

    test('a coded 409 keeps its code, params and English detail', () async {
      final dio = _dioWith(
        (options) async => ResponseBody.fromString(
          jsonEncode(coded('cash_session.drawer_busy', params: {'x': 1})),
          409,
          headers: _jsonHeaders,
        ),
      );

      final error = await _errorOf(() => dio.get<Object>('/x'));

      expect(error, isA<ServerError>());
      final problem = (error as ServerError).problem!;
      expect(problem.code, api.ErrorCode.cashSessionPeriodDrawerBusy);
      expect(problem.params, {'x': 1});
      expect(error.message, 'Some English');
    });

    test('the same body delivered as bytes carries the problem too', () async {
      final error = await _fetchBytes(
        404,
        jsonBody: {
          'status': 404,
          'code': 'resource.not_found',
          'detail': 'Sales order not found',
          'params': {'resource': 'sales_order', 'id': 7},
        },
      );

      expect(error, isA<NotFoundError>());
      expect(
        (error as NotFoundError).problem!.code,
        api.ErrorCode.resourcePeriodNotFound,
      );
      expect(error.message, 'Sales order not found');
    });

    test('each status keeps its variant and gains the problem', () async {
      for (final (status, matcher) in <(int, Matcher)>[
        (401, isA<AuthError>()),
        (404, isA<NotFoundError>()),
        (500, isA<ServerError>()),
      ]) {
        final error = await _fetchBytes(
          status,
          jsonBody: coded('server.error'),
        );
        expect(error, matcher, reason: 'status $status');
        expect(
          switch (error) {
            AuthError(:final problem) => problem,
            NotFoundError(:final problem) => problem,
            ServerError(:final problem) => problem,
            _ => null,
          },
          isNotNull,
          reason: 'status $status',
        );
      }
    });

    test('a coded 422 with a string detail keeps both', () async {
      final error = await _fetchBytes(
        422,
        jsonBody: coded(
          'sales_order.below_min_quantity',
          params: {'min_order_qty': 12},
        ),
      );

      expect(error, isA<ValidationError>());
      expect((error as ValidationError).errors, isEmpty);
      expect(error.serverMessage, 'Some English');
      expect(error.problem!.intParam('min_order_qty'), 12);
    });

    test('a code this client does not know is kept, never thrown', () async {
      final error = await _fetchBytes(
        409,
        jsonBody: coded('future.not_yet_invented'),
      );

      expect(error, isA<ServerError>());
      final problem = (error as ServerError).problem!;
      expect(problem.codeName, 'future.not_yet_invented');
      expect(problem.code, isNull);
      expect(error.message, 'Some English');
    });

    test(
      'a body without a code maps exactly as before, with no problem',
      () async {
        final error = await _fetchBytes(
          409,
          jsonBody: {'detail': 'Cash session is not closed'},
        );

        expect(
          error,
          isA<ServerError>()
              .having((e) => e.problem, 'problem', isNull)
              .having(
                (e) => e.message,
                'message',
                'Cash session is not closed',
              ),
        );
      },
    );

    test(
      'a coded refusal is logged once, with code, params and detail',
      () async {
        final lines = <String>[];
        final original = debugPrint;
        debugPrint = (message, {wrapWidth}) => lines.add(message ?? '');
        addTearDown(() => debugPrint = original);

        await _fetchBytes(
          422,
          jsonBody: coded('customer.credit_hold', params: {'overdue_count': 4}),
        );

        expect(lines, [
          'api-error 422 customer.credit_hold params={"overdue_count":4} '
              'detail=Some English',
        ]);
      },
    );

    test('an uncoded refusal is not logged', () async {
      final lines = <String>[];
      final original = debugPrint;
      debugPrint = (message, {wrapWidth}) => lines.add(message ?? '');
      addTearDown(() => debugPrint = original);

      await _fetchBytes(
        409,
        jsonBody: {'detail': 'Cash session is not closed'},
      );

      expect(lines, isEmpty);
    });

    test('a field-list 422 has no problem', () async {
      final error = await _fetchBytes(
        422,
        jsonBody: {
          'detail': [
            {
              'loc': ['body', 'name'],
              'msg': 'field required',
              'type': 'missing',
            },
          ],
        },
      );

      expect((error as ValidationError).problem, isNull);
      expect(error.errors, hasLength(1));
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
  void Function()? onPasswordChangeRequired,
}) {
  final interceptor = AuthInterceptor(_NoTokenStorage())
    ..onUnauthorized = onUnauthorized
    ..onPasswordChangeRequired = onPasswordChangeRequired;
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
