import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart' hide EntityStatus;

import 'package:mbe_ui/core/domain/entity_status.dart';

import 'privilege.dart';
import 'user_settings.dart';

part 'user.freezed.dart';

/// The current user's identity and RBAC data (data-model.md "User"), mapped
/// from `UserResponse`. Shared kernel, consumed by `AuthState` (T012) and
/// `AccessControlService` (T017).
@freezed
class User with _$User {
  const factory User({
    required String userId,
    required String email,
    int? employeeId,
    required bool administrator,
    required EntityStatus status,
    required int sessionVersion,
    UserSettings? settings,
    required List<Privilege> privileges,

    /// The profile this account was last provisioned from, if any
    /// (024-user-profiles data-model.md §2). Provenance only — never read by
    /// `AccessControlService` or any permission decision.
    int? profileId,
    String? profileName,
  }) = _User;

  factory User.fromResponse(UserResponse response) {
    return User(
      userId: response.userId,
      email: response.email,
      employeeId: response.employeeId,
      administrator: response.administrator,
      status: EntityStatus.fromApi(response.status),
      sessionVersion: response.sessionVersion,
      settings: response.settings == null
          ? null
          : UserSettings.fromResponse(response.settings!),
      privileges: response.privileges
          .map(Privilege.fromResponse)
          .whereType<Privilege>()
          .toList(),
      profileId: response.profileId,
      profileName: response.profileName,
    );
  }
}

/// A row in the admin Users list (data-model.md "UserSummary"), mapped from
/// `UserListItem`.
@freezed
class UserSummary with _$UserSummary {
  const factory UserSummary({
    required String userId,
    required String email,
    int? employeeId,
    required bool administrator,
    required EntityStatus status,

    /// The profile this account was last provisioned from, if any
    /// (024-user-profiles data-model.md §2). See [User.profileId].
    int? profileId,
    String? profileName,
  }) = _UserSummary;

  factory UserSummary.fromListItem(UserListItem item) {
    return UserSummary(
      userId: item.userId,
      email: item.email,
      employeeId: item.employeeId,
      administrator: item.administrator,
      status: EntityStatus.fromApi(item.status),
      profileId: item.profileId,
      profileName: item.profileName,
    );
  }
}
