import 'package:freezed_annotation/freezed_annotation.dart';

part 'fiscal_cancellation.freezed.dart';

/// How one cancellation request stands (spec 072 data-model). The client's
/// `status` is a plain string, so an outcome this version doesn't know maps to
/// [unknown] and the raw value is kept for display.
enum CancellationOutcome {
  requested,
  pending,
  accepted,
  expired,
  rejected,
  notCancellable,
  failed,
  unknown;

  /// `requested` (answer unknown) and `pending` (the receiver hasn't answered)
  /// are the two states in which the request is still open.
  bool get isOpen => this == requested || this == pending;

  static CancellationOutcome fromWire(String wire) => switch (wire) {
    'requested' => requested,
    'pending' => pending,
    'accepted' => accepted,
    'expired' => expired,
    'rejected' => rejected,
    'not_cancellable' => notCancellable,
    'failed' => failed,
    _ => unknown,
  };
}

/// One request to cancel a document, newest first on the detail. `requestedBy`
/// is an employee id.
@freezed
abstract class FiscalCancellation with _$FiscalCancellation {
  const factory FiscalCancellation({
    required int id,
    required String reason,
    String? substitution,
    required CancellationOutcome outcome,

    /// The status string as the server sent it, shown when [outcome] is
    /// [CancellationOutcome.unknown].
    required String rawOutcome,
    String? pacCode,
    String? pacMessage,
    required int requestedBy,
    required DateTime requestedAt,
    DateTime? answeredAt,
    DateTime? resolvedAt,
  }) = _FiscalCancellation;
}
