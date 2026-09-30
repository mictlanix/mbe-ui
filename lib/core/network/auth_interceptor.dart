import 'dart:convert';

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
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
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
  final body = _jsonBodyOf(response);
  switch (statusCode) {
    case 401:
      return AppError.auth(_detailFrom(body));
    case 404:
      return AppError.notFound(_detailFrom(body));
    case 422:
      return AppError.validation(_fieldErrorsFrom(body));
    default:
      return AppError.server(
        statusCode: statusCode,
        message: _detailFrom(body),
      );
  }
}

/// The response body, with a JSON error re-read from bytes.
///
/// `ResponseType.bytes` applies to error responses as well as successes, so
/// a request made that way (the generated PDF print methods, spec 044) gets
/// even `{"detail": "Sales order not found"}` as a `Uint8List`. Without this,
/// `_detailFrom` and `_fieldErrorsFrom` see a non-`Map` and the server's only
/// explanation is dropped. A body that is not JSON, or does not parse, is
/// returned untouched, so those helpers yield no message rather than throw.
Object? _jsonBodyOf(Response<dynamic> response) {
  final data = response.data;
  if (data is! List<int>) return data;
  final contentType = response.headers.value(Headers.contentTypeHeader) ?? '';
  if (!contentType.contains('json')) return data;
  try {
    return jsonDecode(utf8.decode(data));
  } on FormatException {
    return data;
  }
}

/// Extracts FastAPI's `{"detail": "<message>"}` string shape (used for
/// `HTTPException`, as opposed to `422`'s list-of-`ValidationError` shape).
///
/// Some mbe-api conflicts raise a *structured* detail instead — the
/// sales-order confirm endpoint answers a 409 with
/// `{"detail": {"message": "Insufficient stock", "lines": [...]}}`, verified
/// against a live backend. Returning `null` for those dropped the only
/// explanation the server gave, so the headline is surfaced here. Callers
/// that need the rest of the structure (the POS capture step wants the
/// per-line reasons, FR-039) read `response.data` themselves.
String? _detailFrom(Object? data) {
  if (data is! Map) return null;
  final detail = data['detail'];
  if (detail is String) return detail;
  if (detail is Map && detail['message'] is String) {
    return detail['message'] as String;
  }
  return null;
}

List<FieldError> _fieldErrorsFrom(Object? data) {
  if (data is! Map) return const [];
  final detail = data['detail'];
  if (detail is! List) return const [];
  return detail.whereType<Map>().map((entry) {
    final loc = (entry['loc'] as List? ?? const [])
        .map((segment) => segment.toString())
        .toList();
    return FieldError(
      loc: loc,
      msg: entry['msg']?.toString() ?? '',
      type: entry['type']?.toString() ?? '',
    );
  }).toList();
}
