import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/auth/domain/entities/user_profile.dart';

/// User profile management calls to mbe-api
/// (024-user-profiles contracts/mbe-api-user-profiles.md). Every operation is
/// administrator-only server-side (research.md §2) — screens gate on
/// `AccessControlService.isAdministrator`, not a `SystemObject`.
abstract class UserProfileRepository {
  /// `GET /api/v1/user-profiles`.
  Future<UserProfileListResult> list({
    String? search,
    EntityStatus? status,
    int skip = 0,
    int limit = 20,
  });

  /// `GET /api/v1/user-profiles/{profile_id}`.
  Future<UserProfile> get({required int profileId});

  /// `POST /api/v1/user-profiles`.
  Future<UserProfile> create({
    required String name,
    String? description,
    EntityStatus status = EntityStatus.active,
    List<Privilege> privileges = const [],
  });

  /// `PUT /api/v1/user-profiles/{profile_id}`. Privileges, when supplied,
  /// replace the profile's full set.
  Future<UserProfile> update({
    required int profileId,
    String? name,
    String? description,
    EntityStatus? status,
    List<Privilege>? privileges,
  });

  /// `DELETE /api/v1/user-profiles/{profile_id}`. Refused as a conflict while
  /// any user references the profile.
  Future<void> delete({required int profileId});

  /// `POST /api/v1/user-profiles/{profile_id}/apply/{user_id}` — copies the
  /// profile's permissions onto the user as a full replace and invalidates
  /// the user's sessions. Returns the full updated user.
  Future<User> apply({required int profileId, required String userId});
}

/// `UserProfileListResponse` (`items`, `total`) — used by
/// `UserProfilesController` for pagination.
class UserProfileListResult {
  const UserProfileListResult({required this.items, required this.total});

  final List<UserProfileSummary> items;
  final int total;
}
