import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart' hide EntityStatus;

import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';

part 'user_profile.freezed.dart';

/// A named, reusable permission template (024-user-profiles data-model.md
/// "UserProfile"), mapped from `UserProfileResponse`. `privileges` is
/// **sparse** — an entry exists only for a system object the profile grants
/// something on; every other object is denied.
@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required int userProfileId,
    required String name,
    String? description,
    required EntityStatus status,
    required List<Privilege> privileges,
  }) = _UserProfile;

  factory UserProfile.fromResponse(UserProfileResponse response) {
    return UserProfile(
      userProfileId: response.userProfileId,
      name: response.name,
      description: response.description,
      status: EntityStatus.fromApi(response.status),
      privileges: response.privileges
          .map(Privilege.fromProfileResponse)
          .whereType<Privilege>()
          .toList(),
    );
  }
}

/// A row in the profile catalog list, and an option in every profile picker
/// (024-user-profiles data-model.md "UserProfileSummary"), mapped from
/// `UserProfileListItem`. Carries no privileges — the list endpoint doesn't
/// expand them.
@freezed
class UserProfileSummary with _$UserProfileSummary {
  const factory UserProfileSummary({
    required int userProfileId,
    required String name,
    String? description,
    required EntityStatus status,
  }) = _UserProfileSummary;

  factory UserProfileSummary.fromListItem(UserProfileListItem item) {
    return UserProfileSummary(
      userProfileId: item.userProfileId,
      name: item.name,
      description: item.description,
      status: EntityStatus.fromApi(item.status),
    );
  }
}
