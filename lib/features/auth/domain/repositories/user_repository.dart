import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/access/user_settings.dart';

/// Result of `POST /api/v1/users/{user_id}/recover-password` (FR-010 admin
/// path). Carries the signed token the administrator relays to the user.
class RecoverPasswordResult {
  const RecoverPasswordResult({
    required this.recoveryToken,
    required this.expiresAt,
  });

  final String recoveryToken;
  final String expiresAt;
}

/// User management calls to mbe-api (contracts/mbe-api-auth-users.md "Users"
/// section). Access is gated by `AccessControlService.can(SystemObject.users,
/// ...)` at the screen level.
abstract class UserRepository {
  /// `GET /api/v1/users` (FR-011).
  Future<List<UserSummary>> list();

  /// `GET /api/v1/users/{user_id}` (FR-012/FR-013).
  Future<User> get({required String userId});

  /// `POST /api/v1/users` (FR-012). Note: privileges cannot be set at
  /// creation — call [update] after creation to assign them.
  Future<User> create({
    required String userId,
    required String password,
    required String email,
    int? employeeId,
    bool administrator = false,
    bool disabled = false,
  });

  /// `PUT /api/v1/users/{user_id}` (FR-012/FR-013). All fields optional;
  /// only non-null values are sent. Throws `NotFoundError` on `404`.
  Future<User> update({
    required String userId,
    String? email,
    int? employeeId,
    bool? administrator,
    bool? disabled,
    List<Privilege>? privileges,
    UserSettings? settings,
  });

  /// `POST /api/v1/users/{user_id}/recover-password` (FR-010 admin path).
  Future<RecoverPasswordResult> recoverPassword({required String userId});
}
