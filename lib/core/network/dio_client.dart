import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/config/app_settings_provider.dart';

import '../storage/token_storage.dart';
import 'auth_interceptor.dart';

/// mbe-api base URL. Override with
/// `--dart-define=API_BASE_URL=https://...` for non-local environments.
///
/// Kept as a plain top-level `const` — not routed through [appSettingsProvider]
/// at its definition — because `photo_url.dart`'s `photosBaseUrl` defaults to
/// this value as a compile-time cross-reference (spec 027 research.md R7);
/// a provider-resolved value can't be a `const` default. [dioProvider] below
/// is the one consumer with `ref` access, so it reads the settings-provider
/// value instead (test-overridable, spec 027 FR-003).
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
  final dio = Dio(BaseOptions(baseUrl: ref.watch(appSettingsProvider).apiBaseUrl));
  dio.interceptors.add(ref.watch(authInterceptorProvider));
  return dio;
});
