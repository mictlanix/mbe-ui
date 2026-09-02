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
  final dio = Dio(
    BaseOptions(
      baseUrl: ref.watch(appSettingsProvider).apiBaseUrl,
      // On Flutter Web, dio's adapter issues requests via XMLHttpRequest,
      // which is subject to the browser's own HTTP cache — invisible to
      // every mocked-repository test in this app, since none of them touch
      // a real XHR. Without this header, a GET whose URL/params are byte-
      // identical to a previous request (e.g. resubmitting an unchanged
      // catalog search, spec 035 FR-008) can be served straight from the
      // browser cache with no round-trip to mbe-api at all, silently
      // defeating "always refetch" regardless of how correctly the
      // Riverpod/widget layer above it behaves. `no-cache` (not `no-store`)
      // forces revalidation with the origin on every request rather than
      // disabling caching outright — the right one for a "must not read
      // stale data" guarantee, since it costs a round-trip either way.
      headers: const {'Cache-Control': 'no-cache'},
    ),
  );
  dio.interceptors.add(ref.watch(authInterceptorProvider));
  return dio;
});
