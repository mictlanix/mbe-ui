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
  const factory AppError.server({int? statusCode, String? message}) =
      ServerError;

  /// Connection/timeout failure before a response is received.
  const factory AppError.network([String? message]) = NetworkError;

  /// A `422` whose `detail` is a plain string naming a credit refusal —
  /// arrears, no credit limit, or over the limit (spec 039 research R8) —
  /// rather than the field-level list `ValidationError` carries or the
  /// `{"message", "lines"}` shape a goods refusal carries. Its own variant
  /// rather than folded into [ServerError] so a caller can tell "this
  /// customer cannot take credit" apart from any other server refusal by
  /// type, not by matching the server's own prose (spec 039 FR-055/FR-056).
  const factory AppError.creditHold([String? message]) = CreditHoldError;
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
    CreditHoldError(message: final m) => m,
    ValidationError() => null,
  };
}
