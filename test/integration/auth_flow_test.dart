import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';

/// Exercises `AuthRepositoryImpl` against a *real* mbe-api instance
/// (constitution §VII — no mocked/offline mode), covering quickstart.md
/// "Story 1" acceptance scenarios 1, 2, 6, and 7 (spec.md "User Story 1 -
/// Sign In and Work Within a Session").
///
/// Scenarios 3 (session expiry) and 4 (access revocation by an
/// administrator while the user is signed in) require restarting mbe-api or
/// a second admin session and are validated manually per quickstart.md.
///
/// Requires mbe-api running at [apiBaseUrl] (default
/// `http://127.0.0.1:8000`). Configure seeded accounts with
/// `--dart-define`:
///   --dart-define=MBE_ADMIN_USERNAME=...
///   --dart-define=MBE_ADMIN_PASSWORD=...
///   --dart-define=MBE_TEST_USERNAME=...   (non-administrator)
///   --dart-define=MBE_TEST_PASSWORD=...
///
/// Tests requiring seeded credentials are skipped when they are not
/// provided.
const _adminUsername = String.fromEnvironment('MBE_ADMIN_USERNAME');
const _adminPassword = String.fromEnvironment('MBE_ADMIN_PASSWORD');
const _testUsername = String.fromEnvironment('MBE_TEST_USERNAME');
const _testPassword = String.fromEnvironment('MBE_TEST_PASSWORD');

const _hasAdminCredentials = _adminUsername != '' && _adminPassword != '';
const _hasTestCredentials = _testUsername != '' && _testPassword != '';

void main() {
  late AuthRepositoryImpl repository;

  setUp(() {
    repository = AuthRepositoryImpl(Dio(BaseOptions(baseUrl: apiBaseUrl)));
  });

  test(
    'scenario 1: valid administrator credentials sign in and reflect full access',
    () async {
      final token = await repository.login(
        username: _adminUsername,
        password: _adminPassword,
      );
      expect(token, isNotEmpty);

      final user = await repository.me();
      final access = AccessControlService(AuthState.authenticated(token: token, user: user));

      expect(access.isAuthenticated, isTrue);
      expect(access.isAdministrator, isTrue); // FR-006
      expect(access.can(SystemObject.users, AccessRight.delete), isTrue);
    },
    skip: !_hasAdminCredentials,
  );

  test(
    'scenario 2: an incorrect password yields a single generic error (FR-008)',
    () async {
      await expectLater(
        () => repository.login(username: 'does-not-exist', password: 'wrong-password'),
        throwsA(anyOf(isA<AuthError>(), isA<ValidationError>())),
      );
    },
  );

  test(
    'scenario 6: a non-administrator only has the privileges seeded for their account (FR-005/FR-007)',
    () async {
      final token = await repository.login(
        username: _testUsername,
        password: _testPassword,
      );
      final user = await repository.me();
      final access = AccessControlService(AuthState.authenticated(token: token, user: user));

      expect(access.isAuthenticated, isTrue);
      expect(access.isAdministrator, isFalse);
      // A module with no `Privilege` row is fully inaccessible (FR-007).
      // The seeded test account is expected to have no `Users` privilege.
      expect(access.can(SystemObject.users, AccessRight.read), isFalse);
    },
    skip: !_hasTestCredentials,
  );

  test(
    'scenario 7: an administrator can access every module regardless of individual privileges (FR-006)',
    () async {
      final token = await repository.login(
        username: _adminUsername,
        password: _adminPassword,
      );
      final user = await repository.me();
      final access = AccessControlService(AuthState.authenticated(token: token, user: user));

      for (final object in SystemObject.values) {
        for (final right in AccessRight.values) {
          if (right == AccessRight.none) continue;
          expect(access.can(object, right), isTrue, reason: '$object.$right');
        }
      }
    },
    skip: !_hasAdminCredentials,
  );
}
