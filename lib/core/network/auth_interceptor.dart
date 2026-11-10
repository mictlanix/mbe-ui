import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import '../errors/api_problem.dart';
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

  /// Set by `AuthNotifier`; invoked on a `403 password_change_required`
  /// (spec 048 US5) so the app can route to the forced password change.
  void Function()? onPasswordChangeRequired;

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
    } else if (_isPasswordChangeRequired(appError)) {
      onPasswordChangeRequired?.call();
    }
    handler.next(err.copyWith(error: appError));
  }
}

const _passwordChangeRequired = 'password_change_required';

/// A refusal asking the user to change their password first: recognized by
/// the server's `auth.password_change_required` code (spec 058), or, for a
/// server that sends no code, by a 403 whose `detail` is exactly
/// `password_change_required`.
bool _isPasswordChangeRequired(AppError error) =>
    error.problem?.code == api.ErrorCode.authPeriodPasswordChangeRequired ||
    (error is ServerError &&
        error.statusCode == 403 &&
        error.message == _passwordChangeRequired);

/// The customer-credit refusals (`customer.credit_hold` and its siblings).
/// They are `AppError.creditHold` whatever status they arrive with, so a
/// caller can tell "this customer cannot take credit" apart by type, not by
/// matching the server's prose (spec 039 FR-055/FR-056).
const _creditCodes = {
  api.ErrorCode.customerPeriodCreditHold,
  api.ErrorCode.customerPeriodCreditLimitExceeded,
  api.ErrorCode.customerPeriodCreditLimitReached,
  api.ErrorCode.customerPeriodNoCreditLimit,
  api.ErrorCode.customerPeriodWalkInNoCredit,
};

/// Maps a [DioException] to an [AppError] subtype.
AppError mapDioException(DioException error) {
  final response = error.response;
  if (response == null) {
    return AppError.network(error.message);
  }

  final statusCode = response.statusCode ?? 0;
  final body = _jsonBodyOf(response);
  // The server's own `code` and `params` (mbe-api spec 036), kept beside the
  // English `detail` so the UI can show a message in the user's language
  // (spec 058). `null` for a body without a string `code`, which then maps
  // exactly as it always has.
  final problem = ApiProblem.fromBody(body);
  if (problem != null) {
    // The server's own account of the refusal stays in the log even when the
    // user sees a localized message instead of its English `detail` (spec 058
    // FR-020). Written here, once per failed request, and never the request,
    // its headers, or a rejected value.
    debugPrint(
      'api-error $statusCode ${problem.codeName} '
      'params=${jsonEncode(problem.params)} detail=${problem.detail}',
    );
  }
  if (_creditCodes.contains(problem?.code)) {
    return AppError.creditHold(_detailFrom(body), problem);
  }
  switch (statusCode) {
    case 401:
      return AppError.auth(_detailFrom(body), problem);
    case 404:
      return AppError.notFound(_detailFrom(body), problem);
    case 422:
      return AppError.validation(
        _fieldErrorsFrom(body),
        _detailFrom(body),
        problem,
      );
    default:
      return AppError.server(
        statusCode: statusCode,
        message: _detailFrom(body),
        problem: problem,
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
    final ctx = entry['ctx'];
    final failed = ctx is Map ? ctx['failed'] : null;
    // `entry['input']` (the rejected password) is deliberately never read.
    return FieldError(
      loc: loc,
      msg: entry['msg']?.toString() ?? '',
      type: entry['type']?.toString() ?? '',
      failedRules: failed is List
          ? failed.map((rule) => rule.toString()).toList()
          : const [],
    );
  }).toList();
}
