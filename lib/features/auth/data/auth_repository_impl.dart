import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart';

import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/api_serializers.dart';
import 'package:mbe_ui/core/network/auth_interceptor.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/auth/domain/entities/password_policy.dart';
import 'package:mbe_ui/features/auth/domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(dioProvider));
});

/// The deployment's password policy. No client-side fallback: on failure the
/// forms show the checklist as unavailable and leave enforcement to the
/// server.
final passwordPolicyProvider = FutureProvider<PasswordPolicy>((ref) {
  return ref.watch(authRepositoryProvider).passwordPolicy();
});

/// `AuthRepository` backed by the generated `mbe_api_client` `AuthApi`
/// (contracts/mbe-api-auth-users.md "POST /api/v1/auth/login",
/// "GET /api/v1/auth/me").
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(Dio dio) : _api = AuthApi(dio, appSerializers);

  final AuthApi _api;

  @override
  Future<String> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _api.loginApiV1AuthLoginPost(
        username: username,
        password: password,
      );
      final token = response.data;
      if (token == null) {
        throw const AppError.auth();
      }
      return token.accessToken;
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<User> me() async {
    try {
      final response = await _api.getMeApiV1AuthMeGet();
      final user = response.data;
      if (user == null) {
        throw const AppError.auth();
      }
      return User.fromResponse(user);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await _api.changePasswordApiV1AuthChangePasswordPost(
        changePasswordRequest: ChangePasswordRequest(
          (b) => b
            ..oldPassword = oldPassword
            ..newPassword = newPassword,
        ),
      );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<void> recoverConfirm({
    required String recoveryToken,
    required String newPassword,
  }) async {
    try {
      await _api.confirmRecoveryApiV1AuthRecoverPost(
        confirmRecoveryRequest: ConfirmRecoveryRequest(
          (b) => b
            ..recoveryToken = recoveryToken
            ..newPassword = newPassword,
        ),
      );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<PasswordPolicy> passwordPolicy() async {
    try {
      final response = await _api.getPasswordPolicyApiV1AuthPasswordPolicyGet();
      final policy = response.data;
      if (policy == null) {
        throw const AppError.server();
      }
      return PasswordPolicy(
        minLength: policy.minLength,
        requireUpper: policy.requireUpper,
        requireLower: policy.requireLower,
        requireDigit: policy.requireDigit,
        requireSymbol: policy.requireSymbol,
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
