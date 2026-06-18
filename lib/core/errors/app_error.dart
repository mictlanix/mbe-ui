import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_error.freezed.dart';

/// Domain error hierarchy returned/thrown by repository methods (constitution
/// §III, data-model.md "Domain error types"). `core/network/` maps non-2xx
/// dio responses to these variants.
@freezed
sealed class AppError with _$AppError {
  /// `422` (`HTTPValidationError`) — field-level validation messages.
  const factory AppError.validation(List<FieldError> errors) = ValidationError;

  /// `401` from any endpoint, or `400` from `/auth/login`.
  const factory AppError.auth([String? message]) = AuthError;

  /// `404` (e.g. unknown `user_id`).
  const factory AppError.notFound([String? message]) = NotFoundError;

  /// `5xx`.
  const factory AppError.server({int? statusCode, String? message}) = ServerError;

  /// Connection/timeout failure before a response is received.
  const factory AppError.network([String? message]) = NetworkError;
}

/// A single `loc`/`msg`/`type` entry from mbe-api's `ValidationError` schema.
@freezed
class FieldError with _$FieldError {
  const factory FieldError({
    required List<String> loc,
    required String msg,
    required String type,
  }) = _FieldError;
}

extension AppErrorServerMessage on AppError {
  /// The server-provided detail behind this error (e.g. mbe-api's `detail`
  /// string on a `404`/`5xx`), for display alongside a localized generic
  /// message since it can't be localized client-side. `null` for
  /// [ValidationError] (its field-level messages are surfaced separately)
  /// and for errors the server sent without a `detail` string.
  String? get serverMessage => switch (this) {
        AuthError(message: final m) => m,
        NotFoundError(message: final m) => m,
        ServerError(message: final m) => m,
        NetworkError(message: final m) => m,
        ValidationError() => null,
      };
}
