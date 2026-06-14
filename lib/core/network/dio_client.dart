import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/token_storage.dart';
import 'auth_interceptor.dart';

/// mbe-api base URL. Override with
/// `--dart-define=API_BASE_URL=https://...` for non-local environments.
const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://127.0.0.1:8000',
);

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

final authInterceptorProvider = Provider<AuthInterceptor>((ref) {
  return AuthInterceptor(ref.watch(tokenStorageProvider));
});

/// Base `Dio` instance for all mbe-api clients (auth + users for this
/// feature; reused by every later feature's generated API clients).
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
  dio.interceptors.add(ref.watch(authInterceptorProvider));
  return dio;
});
