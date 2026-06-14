import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';

import 'access_right.dart';
import 'system_object.dart';

/// Deny-by-default RBAC surface consumed by every feature (constitution
/// §IV, contracts/access_control.md). Derived (read-only) from
/// `authNotifierProvider`'s current `AuthState`.
class AccessControlService {
  const AccessControlService(this._authState);

  final AuthState _authState;

  /// `true` only when [AuthState] is `authenticated`.
  bool get isAuthenticated => _authState is AuthAuthenticated;

  /// `true` when the current user's `administrator == true`.
  bool get isAdministrator {
    final state = _authState;
    return state is AuthAuthenticated && state.user.administrator;
  }

  /// `true` if the current user is an administrator, OR has a `Privilege`
  /// for [object] whose bitmask includes [right]. `false` if
  /// unauthenticated, if [object] has no `Privilege` entry, or if the bit is
  /// unset.
  bool can(SystemObject object, AccessRight right) {
    final state = _authState;
    if (state is! AuthAuthenticated) return false;
    if (state.user.administrator) return true;

    for (final privilege in state.user.privileges) {
      if (privilege.systemObject == object) {
        return privilege.has(right);
      }
    }
    return false;
  }
}

final accessControlProvider = Provider<AccessControlService>((ref) {
  final authState = ref.watch(authNotifierProvider).valueOrNull ??
      const AuthState.unauthenticated();
  return AccessControlService(authState);
});
