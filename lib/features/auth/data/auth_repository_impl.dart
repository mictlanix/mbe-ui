import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart';

import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/auth_interceptor.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/auth/domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(dioProvider));
});

/// `AuthRepository` backed by the generated `mbe_api_client` `AuthApi`
/// (contracts/mbe-api-auth-users.md "POST /api/v1/auth/login",
/// "GET /api/v1/auth/me").
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(Dio dio) : _api = AuthApi(dio, standardSerializers);

  final AuthApi _api;

  @override
  Future<String> login({required String username, required String password}) async {
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
}

AppError _toAppError(DioException error) {
  final mapped = error.error;
  return mapped is AppError ? mapped : mapDioException(error);
}
