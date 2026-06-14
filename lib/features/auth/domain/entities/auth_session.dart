import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:mbe_ui/core/access/user.dart';

part 'auth_session.freezed.dart';

/// Why the client transitioned to [AuthState.unauthenticated]
/// (data-model.md "AuthSession / AuthState").
enum SignOutReason {
  /// Login request returned `401`/`422`.
  invalidCredentials,

  /// User chose "sign out".
  signedOut,

  /// Any authenticated request returned `401` (token expired or
  /// `session_version` revoked server-side).
  sessionInvalid,
}

/// Client-side session lifecycle (data-model.md "AuthSession / AuthState",
/// FR-002/FR-003/FR-004).
///
/// ```text
/// unauthenticated --(submit credentials)--> authenticating
/// authenticating --(200 + user fetched)--> authenticated
/// authenticating --(401/422)--> unauthenticated(reason: invalidCredentials)
/// authenticated --(sign out)--> unauthenticated(reason: signedOut)
/// authenticated --(any request returns 401)--> unauthenticated(reason: sessionInvalid)
/// ```
@freezed
sealed class AuthState with _$AuthState {
  /// No valid session. `reason` is `null` if the user has never signed in.
  const factory AuthState.unauthenticated({SignOutReason? reason}) = AuthUnauthenticated;

  /// Login request in flight (FR-001 acceptance scenario 1).
  const factory AuthState.authenticating() = AuthAuthenticating;

  /// Valid session; `user.privileges` feeds `AccessControlService`.
  const factory AuthState.authenticated({
    required String token,
    required User user,
  }) = AuthAuthenticated;
}
