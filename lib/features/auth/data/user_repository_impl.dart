import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart' hide EntityStatus;

import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/access/user_settings.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/auth_interceptor.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/auth/domain/repositories/user_repository.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(ref.watch(dioProvider));
});

/// `UserRepository` backed by the generated `mbe_api_client` `UsersApi`
/// (contracts/mbe-api-auth-users.md "Users" section).
class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(Dio dio) : _api = UsersApi(dio, standardSerializers);

  final UsersApi _api;

  @override
  Future<UserListResult> list({
    String? search,
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final response = await _api.listUsersApiV1UsersGet(
        search: search,
        skip: skip,
        limit: limit,
      );
      final items = (response.data?.items.toList() ?? <UserListItem>[])
          .map(UserSummary.fromListItem)
          .toList();
      return UserListResult(items: items, total: response.data?.total ?? 0);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<User> get({required String userId}) async {
    try {
      final response = await _api.getUserApiV1UsersUserIdGet(userId: userId);
      final user = response.data;
      if (user == null) throw const AppError.server();
      return User.fromResponse(user);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<User> create({
    required String userId,
    required String password,
    required String email,
    int? employeeId,
    bool administrator = false,
    EntityStatus status = EntityStatus.active,
  }) async {
    try {
      final response = await _api.createUserApiV1UsersPost(
        userCreate: UserCreate(
          (b) => b
            ..userId = userId
            ..password = password
            ..email = email
            ..employeeId = employeeId
            ..administrator = administrator
            ..status = status.toApi(),
        ),
      );
      final user = response.data;
      if (user == null) throw const AppError.server();
      return User.fromResponse(user);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<User> update({
    required String userId,
    String? email,
    int? employeeId,
    bool? administrator,
    EntityStatus? status,
    List<Privilege>? privileges,
    UserSettings? settings,
  }) async {
    try {
      final response = await _api.updateUserApiV1UsersUserIdPut(
        userId: userId,
        userUpdate: UserUpdate((b) {
          if (email != null) b.email = email;
          if (employeeId != null) b.employeeId = employeeId;
          if (administrator != null) b.administrator = administrator;
          if (status != null) b.status = status.toApi();
          if (privileges != null) {
            b.privileges.replace(privileges.map((p) => p.toUpdate()));
          }
          if (settings != null) b.settings.replace(settings.toUpdate());
        }),
      );
      final user = response.data;
      if (user == null) throw const AppError.server();
      return User.fromResponse(user);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<void> delete({required String userId}) async {
    try {
      await _api.deleteUserApiV1UsersUserIdDelete(userId: userId);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<RecoverPasswordResult> recoverPassword({
    required String userId,
  }) async {
    try {
      final response = await _api
          .recoverPasswordApiV1UsersUserIdRecoverPasswordPost(userId: userId);
      final result = response.data;
      if (result == null) throw const AppError.server();
      return RecoverPasswordResult(
        recoveryToken: result.recoveryToken,
        expiresAt: result.expiresAt,
      );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }
}

AppError _toAppError(DioException error) {
  final mapped = error.error;
  return mapped is AppError ? mapped : mapDioException(error);
}
