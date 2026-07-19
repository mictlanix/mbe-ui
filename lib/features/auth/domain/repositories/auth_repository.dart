import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/errors/app_error.dart';

/// Auth-related calls to mbe-api (contracts/mbe-api-auth-users.md
/// "POST /api/v1/auth/login", "GET /api/v1/auth/me").
abstract class AuthRepository {
  /// `POST /api/v1/auth/login` (OAuth2 "password" grant). Returns the access
  /// token on success, or throws an [AppError] (`AuthError`/`ValidationError`
  /// on `401`/`422` — both surfaced as FR-008's generic message).
  Future<String> login({required String username, required String password});

  /// `GET /api/v1/auth/me`. Throws `AuthError` on `401`.
  Future<User> me();

  /// `POST /api/v1/auth/change-password` (FR-009). Throws `ValidationError`
  /// on `422` (wrong `old_password` or `new_password` too short).
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  });

  /// `POST /api/v1/auth/recover` (FR-010). Throws `ValidationError` on `422`
  /// (invalid/expired `recovery_token` or `new_password` too short).
  Future<void> recoverConfirm({
    required String recoveryToken,
    required String newPassword,
  });
}
