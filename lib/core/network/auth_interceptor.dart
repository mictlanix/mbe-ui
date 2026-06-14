import 'package:dio/dio.dart';

import '../errors/app_error.dart';
import '../storage/token_storage.dart';

/// Attaches `Authorization: Bearer <token>` from [TokenStorage] to every
/// request and maps non-2xx dio responses to [AppError] subtypes
/// (data-model.md "Domain error types"; contracts/mbe-api-auth-users.md
/// "Error shape"). On a `401`, also invokes [onUnauthorized] so
/// `AuthNotifier` can transition to `unauthenticated(reason:
/// sessionInvalid)`.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokenStorage);

  final TokenStorage _tokenStorage;

  /// Set by `AuthNotifier` to react to session invalidation. Left unset in
  /// contexts (e.g. tests) that don't need this side effect.
  void Function()? onUnauthorized;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _tokenStorage.read();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final appError = mapDioException(err);
    if (appError is AuthError) {
      onUnauthorized?.call();
    }
    handler.next(err.copyWith(error: appError));
  }
}

/// Maps a [DioException] to an [AppError] subtype.
AppError mapDioException(DioException error) {
  final response = error.response;
  if (response == null) {
    return AppError.network(error.message);
  }

  final statusCode = response.statusCode ?? 0;
  switch (statusCode) {
    case 401:
      return const AppError.auth();
    case 404:
      return const AppError.notFound();
    case 422:
      return AppError.validation(_fieldErrorsFrom(response.data));
    default:
      if (statusCode >= 500) {
        return AppError.server(statusCode: statusCode);
      }
      return AppError.server(statusCode: statusCode);
  }
}

List<FieldError> _fieldErrorsFrom(Object? data) {
  if (data is! Map) return const [];
  final detail = data['detail'];
  if (detail is! List) return const [];
  return detail
      .whereType<Map>()
      .map((entry) {
        final loc = (entry['loc'] as List? ?? const [])
            .map((segment) => segment.toString())
            .toList();
        return FieldError(
          loc: loc,
          msg: entry['msg']?.toString() ?? '',
          type: entry['type']?.toString() ?? '',
        );
      })
      .toList();
}
