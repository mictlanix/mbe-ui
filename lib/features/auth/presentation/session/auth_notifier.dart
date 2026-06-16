import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';

part 'auth_notifier.g.dart';

/// Session-scoped notifier (data-model.md "AuthSession / AuthState").
///
/// On first read, attempts to restore a session from `TokenStorage` via
/// `GET /api/v1/auth/me`. Drives `signIn`/`signOut` (FR-001, FR-004) and
/// reacts to `401`s from any request via [AuthInterceptor.onUnauthorized]
/// (FR-003).
@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<AuthState> build() async {
    ref.read(authInterceptorProvider).onUnauthorized = handleSessionInvalid;

    final tokenStorage = ref.read(tokenStorageProvider);
    final token = await tokenStorage.read();
    if (token == null) {
      return const AuthState.unauthenticated();
    }

    try {
      final user = await ref.read(authRepositoryProvider).me();
      return AuthState.authenticated(token: token, user: user);
    } on AppError {
      await tokenStorage.clear();
      return const AuthState.unauthenticated(reason: SignOutReason.sessionInvalid);
    }
  }

  /// Submits credentials to `POST /api/v1/auth/login`, then fetches the user
  /// via `GET /api/v1/auth/me` (FR-001). On `401`/`422`, transitions to
  /// `unauthenticated(reason: invalidCredentials)` with FR-008's generic
  /// error — the caller does not see which field was wrong.
  Future<void> signIn({required String username, required String password}) async {
    state = const AsyncData(AuthState.authenticating());

    final tokenStorage = ref.read(tokenStorageProvider);
    final repository = ref.read(authRepositoryProvider);
    try {
      final token = await repository.login(username: username, password: password);
      await tokenStorage.write(token);
      final user = await repository.me();
      state = AsyncData(AuthState.authenticated(token: token, user: user));
    } on AppError {
      await tokenStorage.clear();
      state = const AsyncData(AuthState.unauthenticated(reason: SignOutReason.invalidCredentials));
    }
  }

  /// User-initiated sign out (FR-004).
  Future<void> signOut() async {
    await ref.read(tokenStorageProvider).clear();
    state = const AsyncData(AuthState.unauthenticated(reason: SignOutReason.signedOut));
  }

  /// Called by [AuthInterceptor] when any request returns `401` (FR-003,
  /// FR-014): the token is invalid/expired or `session_version` was bumped
  /// server-side.
  void handleSessionInvalid() {
    unawaited(ref.read(tokenStorageProvider).clear());
    state = const AsyncData(AuthState.unauthenticated(reason: SignOutReason.sessionInvalid));
  }

  /// Updates the in-memory [User] when an administrator edits their own
  /// account (FR-014 best-effort; the authoritative invalidation is the next
  /// `401` via `session_version`). No-op if [updated] does not match the
  /// current user or the session is not authenticated.
  void refreshCurrentUser(User updated) {
    final current = state.valueOrNull;
    if (current is! AuthAuthenticated) return;
    if (current.user.userId != updated.userId) return;
    state = AsyncData(AuthState.authenticated(token: current.token, user: updated));
  }
}
