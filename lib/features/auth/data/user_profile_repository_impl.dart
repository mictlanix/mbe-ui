import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart' hide EntityStatus;

import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/auth_interceptor.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/auth/domain/entities/user_profile.dart';
import 'package:mbe_ui/features/auth/domain/repositories/user_profile_repository.dart';

final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  return UserProfileRepositoryImpl(ref.watch(dioProvider));
});

/// `UserProfileRepository` backed by the generated `mbe_api_client`
/// `UserProfilesApi` (024-user-profiles contracts/mbe-api-user-profiles.md).
class UserProfileRepositoryImpl implements UserProfileRepository {
  UserProfileRepositoryImpl(Dio dio)
    : _api = UserProfilesApi(dio, standardSerializers);

  final UserProfilesApi _api;

  @override
  Future<UserProfileListResult> list({
    String? search,
    EntityStatus? status,
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final response = await _api.listUserProfilesApiV1UserProfilesGet(
        search: search,
        status: status?.toApi(),
        skip: skip,
        limit: limit,
      );
      final items =
          (response.data?.items.toList() ?? <UserProfileListItem>[])
              .map(UserProfileSummary.fromListItem)
              .toList();
      return UserProfileListResult(
        items: items,
        total: response.data?.total ?? 0,
      );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<UserProfile> get({required int profileId}) async {
    try {
      final response = await _api.getUserProfileApiV1UserProfilesProfileIdGet(
        profileId: profileId,
      );
      final profile = response.data;
      if (profile == null) throw const AppError.server();
      return UserProfile.fromResponse(profile);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<UserProfile> create({
    required String name,
    String? description,
    EntityStatus status = EntityStatus.active,
    List<Privilege> privileges = const [],
  }) async {
    try {
      final response = await _api.createUserProfileApiV1UserProfilesPost(
        userProfileCreate: UserProfileCreate(
          (b) => b
            ..name = name
            ..description = description
            ..status = status.toApi()
            ..privileges.replace(
              _nonZero(privileges).map((p) => p.toProfileUpdate()),
            ),
        ),
      );
      final profile = response.data;
      if (profile == null) throw const AppError.server();
      return UserProfile.fromResponse(profile);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<UserProfile> update({
    required int profileId,
    String? name,
    String? description,
    EntityStatus? status,
    List<Privilege>? privileges,
  }) async {
    try {
      final response = await _api.updateUserProfileApiV1UserProfilesProfileIdPut(
        profileId: profileId,
        userProfileUpdate: UserProfileUpdate((b) {
          if (name != null) b.name = name;
          if (description != null) b.description = description;
          if (status != null) b.status = status.toApi();
          if (privileges != null) {
            b.privileges.replace(
              _nonZero(privileges).map((p) => p.toProfileUpdate()),
            );
          }
        }),
      );
      final profile = response.data;
      if (profile == null) throw const AppError.server();
      return UserProfile.fromResponse(profile);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<void> delete({required int profileId}) async {
    try {
      await _api.deleteUserProfileApiV1UserProfilesProfileIdDelete(
        profileId: profileId,
      );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<User> apply({required int profileId, required String userId}) async {
    try {
      final response = await _api
          .applyUserProfileApiV1UserProfilesProfileIdApplyUserIdPost(
            profileId: profileId,
            userId: userId,
          );
      final user = response.data;
      if (user == null) throw const AppError.server();
      return User.fromResponse(user);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  /// Drops any privilege whose mask is `0` — a profile stores an entry only
  /// for what it grants (024-user-profiles research.md §4, FR-010).
  Iterable<Privilege> _nonZero(List<Privilege> privileges) =>
      privileges.where((p) => p.rawValue != 0);
}

AppError _toAppError(DioException error) {
  final mapped = error.error;
  return mapped is AppError ? mapped : mapDioException(error);
}
