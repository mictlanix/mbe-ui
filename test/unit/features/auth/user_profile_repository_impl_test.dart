import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/auth/data/user_profile_repository_impl.dart';

const _jsonHeaders = {
  Headers.contentTypeHeader: [Headers.jsonContentType],
};

const _profileJson = {
  'user_profile_id': 5,
  'name': 'Cashier',
  'description': 'Front counter',
  'status': 0,
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
  group('UserProfileRepositoryImpl.list', () {
    test('200 returns items and total', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'items': [
              {
                'user_profile_id': 5,
                'name': 'Cashier',
                'description': 'Front counter',
                'status': 0,
              },
            ],
            'total': 1,
          }),
          200,
          headers: _jsonHeaders,
        ),
      );

      final result = await repository.list();

      expect(result.items, hasLength(1));
      expect(result.total, 1);
      expect(result.items.first.name, 'Cashier');
    });

    test('passes search/status/skip/limit through as query params', () async {
      RequestOptions? captured;
      final repository = _repositoryWith((options) async {
        captured = options;
        return ResponseBody.fromString(
          jsonEncode({'items': <dynamic>[], 'total': 0}),
          200,
          headers: _jsonHeaders,
        );
      });

      await repository.list(
        search: 'cash',
        status: EntityStatus.active,
        skip: 20,
        limit: 20,
      );

      expect(captured!.queryParameters['search'], 'cash');
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

  group('UserProfileRepositoryImpl.get', () {
    test('200 returns UserProfile with mapped privileges', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode(_profileJson),
          200,
          headers: _jsonHeaders,
        ),
      );

      final profile = await repository.get(profileId: 5);

      expect(profile.name, 'Cashier');
      expect(profile.privileges, hasLength(1));
      expect(profile.privileges.single.systemObject, SystemObject.users);
      expect(profile.privileges.single.allowRead, isTrue);
    });

    test(
      'a response entry naming an unknown system object is dropped, not '
      'thrown (same posture as Privilege.fromResponse)',
      () async {
        final repository = _repositoryWith(
          (options) async => ResponseBody.fromString(
            jsonEncode({
              ..._profileJson,
              'privileges': [
                {
                  'system_object': 999999,
                  'privileges': 15,
                  'allow_create': true,
                  'allow_read': true,
                  'allow_update': true,
                  'allow_delete': true,
                },
              ],
            }),
            200,
            headers: _jsonHeaders,
          ),
        );

        final profile = await repository.get(profileId: 5);

        expect(profile.privileges, isEmpty);
      },
    );

    test('404 maps to AppError.notFound', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'detail': 'Not found'}),
          404,
          headers: _jsonHeaders,
        ),
      );
      await expectLater(
        () => repository.get(profileId: 999),
        throwsA(isA<NotFoundError>()),
      );
    });
  });

  group('UserProfileRepositoryImpl.create', () {
    test('201 returns the created UserProfile', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode(_profileJson),
          201,
          headers: _jsonHeaders,
        ),
      );

      final profile = await repository.create(name: 'Cashier');

      expect(profile.name, 'Cashier');
    });

    test(
      'a privilege whose mask is 0 is never sent — a profile stores an '
      'entry only for what it grants (FR-010, research.md §4)',
      () async {
        RequestOptions? captured;
        final repository = _repositoryWith((options) async {
          captured = options;
          return ResponseBody.fromString(
            jsonEncode(_profileJson),
            201,
            headers: _jsonHeaders,
          );
        });

        await repository.create(
          name: 'Cashier',
          privileges: const [
            Privilege(systemObject: SystemObject.users, rawValue: 2),
            Privilege(systemObject: SystemObject.products, rawValue: 0),
          ],
        );

        final sentBody = _decodeBody(captured!.data);
        final sentPrivileges = sentBody['privileges'] as List<dynamic>;
        expect(sentPrivileges, hasLength(1));
        expect(
          (sentPrivileges.single as Map)['system_object'],
          SystemObject.users.value,
        );
      },
    );

    test('an empty privilege list saves a valid, permission-less profile '
        '(FR-011)', () async {
      RequestOptions? captured;
      final repository = _repositoryWith((options) async {
        captured = options;
        return ResponseBody.fromString(
          jsonEncode({..._profileJson, 'privileges': <dynamic>[]}),
          201,
          headers: _jsonHeaders,
        );
      });

      final profile = await repository.create(name: 'Empty Role');

      final sentBody = _decodeBody(captured!.data);
      expect(sentBody['privileges'], isEmpty);
      expect(profile.privileges, isEmpty);
    });

    test('409 duplicate name (case-insensitive) maps to a ValidationError',
        () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'detail': 'A profile named "Cashier" already exists'}),
          409,
          headers: _jsonHeaders,
        ),
      );
      await expectLater(
        () => repository.create(name: 'cashier'),
        throwsA(isA<AppError>()),
      );
    });
  });

  group('UserProfileRepositoryImpl.update', () {
    test('200 returns updated UserProfile', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({..._profileJson, 'status': 1}),
          200,
          headers: _jsonHeaders,
        ),
      );

      final profile = await repository.update(
        profileId: 5,
        status: EntityStatus.inactive,
      );

      expect(profile.status, EntityStatus.inactive);
    });

    test('a zero-mask privilege is dropped on update too', () async {
      RequestOptions? captured;
      final repository = _repositoryWith((options) async {
        captured = options;
        return ResponseBody.fromString(
          jsonEncode(_profileJson),
          200,
          headers: _jsonHeaders,
        );
      });

      await repository.update(
        profileId: 5,
        privileges: const [
          Privilege(systemObject: SystemObject.products, rawValue: 0),
        ],
      );

      final sentBody = _decodeBody(captured!.data);
      expect(sentBody['privileges'], isEmpty);
    });

    test('404 maps to AppError.notFound', () async {
      final repository = _repositoryWith(
        (options) async =>
            ResponseBody.fromString('{}', 404, headers: _jsonHeaders),
      );
      await expectLater(
        () => repository.update(profileId: 999),
        throwsA(isA<NotFoundError>()),
      );
    });
  });

  group('UserProfileRepositoryImpl.delete', () {
    test('204 completes', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString('', 204),
      );
      await repository.delete(profileId: 5);
    });

    test(
      '409 referenced-by-users conflict maps to an AppError carrying the '
      'server detail (FR-014)',
      () async {
        final repository = _repositoryWith(
          (options) async => ResponseBody.fromString(
            jsonEncode({'detail': '3 users still reference this profile'}),
            409,
            headers: _jsonHeaders,
          ),
        );
        await expectLater(
          () => repository.delete(profileId: 5),
          throwsA(isA<AppError>()),
        );
      },
    );
  });

  group('UserProfileRepositoryImpl.apply', () {
    test('200 returns the full updated User', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'user_id': 'jdoe',
            'email': 'jdoe@example.com',
            'employee_id': 7,
            'administrator': false,
            'status': 0,
            'session_version': 2,
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
            'profile_id': 5,
            'profile_name': 'Cashier',
          }),
          200,
          headers: _jsonHeaders,
        ),
      );

      final user = await repository.apply(profileId: 5, userId: 'jdoe');

      expect(user.profileId, 5);
      expect(user.profileName, 'Cashier');
      expect(user.privileges, hasLength(1));
      expect(user.privileges.single.systemObject, SystemObject.users);
      expect(user.privileges.single.has(AccessRight.read), isTrue);
    });

    test('409 inactive profile maps to an AppError', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'detail': 'Profile is inactive'}),
          409,
          headers: _jsonHeaders,
        ),
      );
      await expectLater(
        () => repository.apply(profileId: 5, userId: 'jdoe'),
        throwsA(isA<AppError>()),
      );
    });

    test('404 missing profile or user maps to AppError.notFound', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'detail': 'Not found'}),
          404,
          headers: _jsonHeaders,
        ),
      );
      await expectLater(
        () => repository.apply(profileId: 999, userId: 'nobody'),
        throwsA(isA<NotFoundError>()),
      );
    });
  });
}

Map<String, Object?> _decodeBody(Object? data) => data is String
    ? jsonDecode(data) as Map<String, Object?>
    : data as Map<String, Object?>;

UserProfileRepositoryImpl _repositoryWith(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = _FakeHttpClientAdapter(handler);
  return UserProfileRepositoryImpl(dio);
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
