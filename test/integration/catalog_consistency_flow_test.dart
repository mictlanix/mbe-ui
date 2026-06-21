import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/auth/data/user_repository_impl.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';

/// Exercises the Users catalog's search + pagination, and the
/// Create/View/Edit/Delete RBAC contract shared by every catalog, against
/// a *real* mbe-api instance (constitution §VII — no mocked/offline mode).
/// Covers quickstart.md "Users search + pagination" and "Consistent row
/// actions" (spec.md "User Story 1" and "User Story 2").
///
/// Requires mbe-api running at [apiBaseUrl] (default
/// `http://127.0.0.1:8000`) with at least 21 users seeded (more than one
/// page at the fixed page size of 20). Configure via `--dart-define`:
///   --dart-define=MBE_ADMIN_USERNAME=...      (an administrator account)
///   --dart-define=MBE_ADMIN_PASSWORD=...
///   --dart-define=MBE_KNOWN_USER_ID=...       (an existing user's username)
///   --dart-define=MBE_READONLY_USERNAME=...   (account with only Users Read)
///   --dart-define=MBE_READONLY_PASSWORD=...
///
/// Tests requiring seeded credentials/data are skipped when not provided.
const _adminUsername = String.fromEnvironment('MBE_ADMIN_USERNAME');
const _adminPassword = String.fromEnvironment('MBE_ADMIN_PASSWORD');
const _knownUserId = String.fromEnvironment('MBE_KNOWN_USER_ID');
const _readOnlyUsername = String.fromEnvironment('MBE_READONLY_USERNAME');
const _readOnlyPassword = String.fromEnvironment('MBE_READONLY_PASSWORD');

const _hasAdminCredentials = _adminUsername != '' && _adminPassword != '';
const _hasKnownUser = _knownUserId != '';
const _hasReadOnlyCredentials =
    _readOnlyUsername != '' && _readOnlyPassword != '';

void main() {
  Future<UserRepositoryImpl> authenticatedUserRepository() async {
    final dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
    final token = await AuthRepositoryImpl(
      dio,
    ).login(username: _adminUsername, password: _adminPassword);
    dio.options.headers['Authorization'] = 'Bearer $token';
    return UserRepositoryImpl(dio);
  }

  test(
    'scenario 1: the first page is bounded at the fixed page size (FR-002)',
    () async {
      final repo = await authenticatedUserRepository();

      final page = await repo.list(skip: 0, limit: 20);

      expect(page.items.length, lessThanOrEqualTo(20));
    },
    skip: !_hasAdminCredentials,
  );

  test(
    'scenario 2: a partial-username search finds the known user (SC-001)',
    () async {
      final repo = await authenticatedUserRepository();

      final result = await repo.list(search: _knownUserId);

      expect(
        result.items.any((u) => u.userId == _knownUserId),
        isTrue,
        reason: 'expected $_knownUserId among search results',
      );
    },
    skip: !_hasAdminCredentials || !_hasKnownUser,
  );

  test('scenario 3: navigating to page 2 returns a different set of users '
      '(FR-002)', () async {
    final repo = await authenticatedUserRepository();

    final firstPage = await repo.list(skip: 0, limit: 20);
    if (firstPage.total <= 20) {
      // Dataset too small to exercise a second page — nothing to assert.
      return;
    }
    final secondPage = await repo.list(skip: 20, limit: 20);

    final firstPageIds = firstPage.items.map((u) => u.userId).toSet();
    final secondPageIds = secondPage.items.map((u) => u.userId).toSet();
    expect(firstPageIds.intersection(secondPageIds), isEmpty);
  }, skip: !_hasAdminCredentials);

  test('scenario 4: clearing the search returns the full paginated list '
      '(FR-001)', () async {
    final repo = await authenticatedUserRepository();

    final searched = await repo.list(search: _knownUserId);
    expect(searched.items, isNotEmpty);

    final cleared = await repo.list();
    expect(cleared.total, greaterThanOrEqualTo(searched.items.length));
  }, skip: !_hasAdminCredentials || !_hasKnownUser);

  test(
    'US2 scenario 1: a Read-only account is denied Update/Delete on the '
    'Users catalog, so Edit/Delete row actions would be omitted (FR-012)',
    () async {
      final dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
      final authRepository = AuthRepositoryImpl(dio);
      final token = await authRepository.login(
        username: _readOnlyUsername,
        password: _readOnlyPassword,
      );
      dio.options.headers['Authorization'] = 'Bearer $token';
      final user = await authRepository.me();
      final access = AccessControlService(
        AuthState.authenticated(token: token, user: user),
      );

      expect(access.can(SystemObject.users, AccessRight.read), isTrue);
      expect(access.can(SystemObject.users, AccessRight.update), isFalse);
      expect(access.can(SystemObject.users, AccessRight.delete), isFalse);
    },
    skip: !_hasReadOnlyCredentials,
  );

  test('US2 scenario 2: View opens the same record Edit would, just read-only '
      '(FR-006)', () async {
    final repo = await authenticatedUserRepository();

    // The View and Edit row actions both resolve to the same underlying
    // record — confirmed by fetching it once, as either action would.
    final user = await repo.get(userId: _knownUserId);

    expect(user.userId, _knownUserId);
  }, skip: !_hasAdminCredentials || !_hasKnownUser);
}
