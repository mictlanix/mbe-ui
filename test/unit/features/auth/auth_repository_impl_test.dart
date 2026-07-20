import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';

const _jsonHeaders = {
  Headers.contentTypeHeader: [Headers.jsonContentType],
};

void main() {
  group('AuthRepositoryImpl.login', () {
    test('200 returns the access token', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'access_token': 'abc123', 'token_type': 'bearer'}),
          200,
          headers: _jsonHeaders,
        ),
      );

      final token = await repository.login(
        username: 'jdoe',
        password: 'secret',
      );

      expect(token, 'abc123');
    });

    test('401 maps to AppError.auth (FR-008)', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'detail': 'Incorrect username or password'}),
          401,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.login(username: 'jdoe', password: 'wrong'),
        throwsA(const AppError.auth('Incorrect username or password')),
      );
    });

    test('422 maps to AppError.validation with field errors', () async {
      final repository = _repositoryWith(
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

      await expectLater(
        () => repository.login(username: '', password: ''),
        throwsA(
          const AppError.validation([
            FieldError(
              loc: ['body', 'username'],
              msg: 'field required',
              type: 'missing',
            ),
          ]),
        ),
      );
    });

    test('5xx maps to AppError.server', () async {
      final repository = _repositoryWith(
        (options) async =>
            ResponseBody.fromString('Internal Server Error', 500),
      );

      await expectLater(
        () => repository.login(username: 'jdoe', password: 'secret'),
        throwsA(const AppError.server(statusCode: 500)),
      );
    });

    test('a connection failure maps to AppError.network', () async {
      final repository = _repositoryWith(
        (options) async => throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          error: 'Failed host lookup',
        ),
      );

      await expectLater(
        () => repository.login(username: 'jdoe', password: 'secret'),
        throwsA(isA<NetworkError>()),
      );
    });
  });

  group('AuthRepositoryImpl.me', () {
    test('200 maps to a User', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'user_id': 'jdoe',
            'email': 'jdoe@example.com',
            'employee_id': null,
            'administrator': false,
            'status': 0,
            'session_version': 3,
            'settings': null,
            'privileges': [
              {
                'system_object': 92,
                'privileges': 2,
                'allow_create': false,
                'allow_read': true,
                'allow_update': false,
                'allow_delete': false,
              },
            ],
          }),
          200,
          headers: _jsonHeaders,
        ),
      );

      final user = await repository.me();

      expect(user.userId, 'jdoe');
      expect(user.email, 'jdoe@example.com');
      expect(user.administrator, isFalse);
      expect(user.sessionVersion, 3);
      expect(user.privileges, hasLength(1));
      expect(user.privileges.single.systemObject, SystemObject.users);
      expect(user.privileges.single.rawValue, 2);
    });

    test('401 maps to AppError.auth (session invalid)', () async {
      final repository = _repositoryWith(
        (options) async =>
            ResponseBody.fromString('{}', 401, headers: _jsonHeaders),
      );

      await expectLater(() => repository.me(), throwsA(const AppError.auth()));
    });

    test('5xx maps to AppError.server', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString('', 503),
      );

      await expectLater(
        () => repository.me(),
        throwsA(const AppError.server(statusCode: 503)),
      );
    });

    test('a connection failure maps to AppError.network', () async {
      final repository = _repositoryWith(
        (options) async => throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          error: 'Connection refused',
        ),
      );

      await expectLater(() => repository.me(), throwsA(isA<NetworkError>()));
    });
  });

  group('AuthRepositoryImpl.changePassword', () {
    test('204 returns normally', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString('', 204),
      );
      await expectLater(
        () => repository.changePassword(
          oldPassword: 'old123',
          newPassword: 'new123',
        ),
        returnsNormally,
      );
    });

    test(
      '422 wrong current password maps to AppError.validation (FR-009)',
      () async {
        final repository = _repositoryWith(
          (options) async => ResponseBody.fromString(
            jsonEncode({
              'detail': [
                {
                  'loc': ['body', 'old_password'],
                  'msg': 'Incorrect password',
                  'type': 'value_error',
                },
              ],
            }),
            422,
            headers: _jsonHeaders,
          ),
        );
        await expectLater(
          () => repository.changePassword(
            oldPassword: 'wrong',
            newPassword: 'newpass1',
          ),
          throwsA(isA<ValidationError>()),
        );
      },
    );

    test(
      '422 new_password too short maps to AppError.validation (FR-009)',
      () async {
        final repository = _repositoryWith(
          (options) async => ResponseBody.fromString(
            jsonEncode({
              'detail': [
                {
                  'loc': ['body', 'new_password'],
                  'msg': 'Value should have at least 6 items',
                  'type': 'too_short',
                },
              ],
            }),
            422,
            headers: _jsonHeaders,
          ),
        );
        await expectLater(
          () => repository.changePassword(
            oldPassword: 'correct',
            newPassword: 'x',
          ),
          throwsA(isA<ValidationError>()),
        );
      },
    );
  });

  group('AuthRepositoryImpl.recoverConfirm', () {
    test('204 returns normally', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString('', 204),
      );
      await expectLater(
        () => repository.recoverConfirm(
          recoveryToken: 'valid-tok',
          newPassword: 'newpass1',
        ),
        returnsNormally,
      );
    });

    test(
      '422 invalid/expired recovery token maps to AppError.validation (FR-010)',
      () async {
        final repository = _repositoryWith(
          (options) async => ResponseBody.fromString(
            jsonEncode({
              'detail': [
                {
                  'loc': ['body', 'recovery_token'],
                  'msg': 'Invalid or expired recovery token',
                  'type': 'value_error',
                },
              ],
            }),
            422,
            headers: _jsonHeaders,
          ),
        );
        await expectLater(
          () => repository.recoverConfirm(
            recoveryToken: 'bad-token',
            newPassword: 'newpass1',
          ),
          throwsA(isA<ValidationError>()),
        );
      },
    );
  });
}

AuthRepositoryImpl _repositoryWith(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = _FakeHttpClientAdapter(handler);
  return AuthRepositoryImpl(dio);
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
