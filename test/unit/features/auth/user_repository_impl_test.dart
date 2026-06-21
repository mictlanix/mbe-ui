import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/auth/data/user_repository_impl.dart';

const _jsonHeaders = {
  Headers.contentTypeHeader: [Headers.jsonContentType],
};

const _userJson = {
  'user_id': 'jdoe',
  'email': 'jdoe@example.com',
  'employee_id': null,
  'administrator': false,
  'disabled': false,
  'session_version': 1,
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
};

void main() {
  group('UserRepositoryImpl.list', () {
    test('200 returns items and total', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'items': [
              {
                'user_id': 'admin',
                'email': 'admin@example.com',
                'employee_id': null,
                'administrator': true,
                'disabled': false,
              },
              {
                'user_id': 'jdoe',
                'email': 'jdoe@example.com',
                'employee_id': null,
                'administrator': false,
                'disabled': false,
              },
            ],
            'total': 2,
          }),
          200,
          headers: _jsonHeaders,
        ),
      );

      final result = await repository.list();

      expect(result.items, hasLength(2));
      expect(result.total, 2);
      expect(result.items.first.userId, 'admin');
      expect(result.items.first.administrator, isTrue);
    });

    test('passes search/skip/limit through as query params', () async {
      RequestOptions? captured;
      final repository = _repositoryWith((options) async {
        captured = options;
        return ResponseBody.fromString(
          jsonEncode({'items': <dynamic>[], 'total': 0}),
          200,
          headers: _jsonHeaders,
        );
      });

      await repository.list(search: 'jdoe', skip: 20, limit: 20);

      expect(captured!.queryParameters['search'], 'jdoe');
      expect(captured!.queryParameters['skip'], 20);
      expect(captured!.queryParameters['limit'], 20);
    });

    test('401 maps to AppError.auth', () async {
      final repository = _repositoryWith(
        (options) async =>
            ResponseBody.fromString('{}', 401, headers: _jsonHeaders),
      );
      await expectLater(
        () => repository.list(),
        throwsA(const AppError.auth()),
      );
    });
  });

  group('UserRepositoryImpl.get', () {
    test('200 returns User with privileges', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode(_userJson),
          200,
          headers: _jsonHeaders,
        ),
      );

      final user = await repository.get(userId: 'jdoe');

      expect(user.userId, 'jdoe');
      expect(user.privileges, hasLength(1));
      expect(user.privileges.single.systemObject, SystemObject.users);
    });

    test('404 maps to AppError.notFound', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'detail': 'Not found'}),
          404,
          headers: _jsonHeaders,
        ),
      );
      await expectLater(
        () => repository.get(userId: 'nobody'),
        throwsA(isA<NotFoundError>()),
      );
    });
  });

  group('UserRepositoryImpl.create', () {
    test('201 returns the created User', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode(_userJson),
          201,
          headers: _jsonHeaders,
        ),
      );

      final user = await repository.create(
        userId: 'jdoe',
        password: 'secret1',
        email: 'jdoe@example.com',
      );

      expect(user.userId, 'jdoe');
    });

    test('422 duplicate user_id maps to AppError.validation', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'detail': [
              {
                'loc': ['body', 'user_id'],
                'msg': 'User already exists',
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
          userId: 'existing',
          password: 'pass1',
          email: 'x@example.com',
        ),
        throwsA(isA<ValidationError>()),
      );
    });
  });

  group('UserRepositoryImpl.update', () {
    test('200 returns updated User', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({..._userJson, 'disabled': true}),
          200,
          headers: _jsonHeaders,
        ),
      );

      final user = await repository.update(userId: 'jdoe', disabled: true);

      expect(user.disabled, isTrue);
    });

    test('404 maps to AppError.notFound', () async {
      final repository = _repositoryWith(
        (options) async =>
            ResponseBody.fromString('{}', 404, headers: _jsonHeaders),
      );
      await expectLater(
        () => repository.update(userId: 'nobody'),
        throwsA(isA<NotFoundError>()),
      );
    });
  });

  group('UserRepositoryImpl.recoverPassword', () {
    test('200 returns recovery token and expiry', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'recovery_token': 'tok-abc123',
            'expires_at': '2026-06-16T00:00:00Z',
          }),
          200,
          headers: _jsonHeaders,
        ),
      );

      final result = await repository.recoverPassword(userId: 'jdoe');

      expect(result.recoveryToken, 'tok-abc123');
      expect(result.expiresAt, '2026-06-16T00:00:00Z');
    });

    test('5xx maps to AppError.server', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString('error', 500),
      );
      await expectLater(
        () => repository.recoverPassword(userId: 'jdoe'),
        throwsA(isA<ServerError>()),
      );
    });
  });
}

UserRepositoryImpl _repositoryWith(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = _FakeHttpClientAdapter(handler);
  return UserRepositoryImpl(dio);
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
