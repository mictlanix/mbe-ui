import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/sales/data/cash_session_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/cash_session.dart';
import 'package:mbe_ui/features/sales/domain/entities/denomination_count.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';
import 'package:mbe_ui/features/sales/presentation/current_session_controller.dart';

part 'close_session_form_controller.freezed.dart';
part 'close_session_form_controller.g.dart';

/// Error codes for [CloseSessionFormState.error] (mirrors
/// `OpenSessionFormErrorCode`).
abstract final class CloseSessionFormErrorCode {
  static const quantityInvalid = 'quantityInvalid';
  static const alreadyClosed = 'alreadyClosed';
  static const sessionNotFound = 'sessionNotFound';
  static const closeFailed = 'closeFailed';
  static const closePermissionDenied = 'closePermissionDenied';
}

/// The close-session form's state (data-model.md §11). [countedTotal],
/// [expectedCash] and [difference] are recomputed strings, not derived at
/// render time, so "updates immediately" (FR-017) is a property of the state
/// a widget test can assert after one quantity change.
@freezed
class CloseSessionFormState with _$CloseSessionFormState {
  const factory CloseSessionFormState({
    int? cashSessionId,
    @Default(<String, int>{}) Map<String, int> quantities,
    @Default('0') String countedTotal,
    @Default('0') String expectedCash,
    @Default('0') String difference,
    @Default(false) bool submitting,
    @Default(false) bool closed,
    String? error,
    String? errorDetail,
    @Default(<String, String>{}) Map<String, String> fieldErrors,
  }) = _CloseSessionFormState;
}

/// Manages the close-session form (User Story 2, FR-013 to FR-026).
///
/// Whether an all-zero count needs the "counted and found empty"
/// confirmation (FR-021) is decided by the screen, not here — this
/// controller submits whatever is in [CloseSessionFormState.quantities]
/// when [submit] is called (research.md §11: the confirmation is a
/// client-only UI gate, not a controller-level rule).
@riverpod
class CloseSessionFormController extends _$CloseSessionFormController {
  @override
  CloseSessionFormState build() => const CloseSessionFormState();

  /// Seeds the form from an already-loaded [session] — the expected-cash
  /// figure (opening amount + cash-method payments only) is fixed for the
  /// lifetime of the count; only the counted total and difference change as
  /// the cashier enters quantities.
  void loadSession(CashSession session) {
    final expected = expectedCash(
      openingAmount: session.openingAmount,
      payments: session.paymentsByMethod,
    );
    state = CloseSessionFormState(
      cashSessionId: session.cashSessionId,
      expectedCash: formatAmount(expected),
      countedTotal: formatAmount(Decimal.zero),
      difference: formatAmount(difference(counted: Decimal.zero, expected: expected)),
    );
  }

  /// Sets [denomination]'s counted quantity, replacing any prior value for
  /// the same denomination, and recomputes the counted total and
  /// difference against the fixed expected figure.
  void quantityChanged(String denomination, int quantity) {
    final quantities = Map<String, int>.from(state.quantities)
      ..[denomination] = quantity;
    final counted = countedTotal([
      for (final entry in quantities.entries)
        DenominationCount(denomination: entry.key, quantity: entry.value),
    ]);
    final expected = parseAmount(state.expectedCash);
    state = state.copyWith(
      quantities: quantities,
      countedTotal: formatAmount(counted),
      difference: formatAmount(difference(counted: counted, expected: expected)),
      error: null,
      errorDetail: null,
      fieldErrors: const {},
    );
  }

  /// Closes the session (FR-013). Re-checks the caller's
  /// `cashSessionClose` update privilege immediately before submitting.
  Future<void> submit() async {
    final cashSessionId = state.cashSessionId;
    if (cashSessionId == null) return;

    if (state.quantities.values.any((q) => q < 0)) {
      state = state.copyWith(
        fieldErrors: {'quantities': CloseSessionFormErrorCode.quantityInvalid},
      );
      return;
    }

    if (!ref
        .read(accessControlProvider)
        .can(SystemObject.cashSessionClose, AccessRight.update)) {
      state = state.copyWith(
        error: CloseSessionFormErrorCode.closePermissionDenied,
        errorDetail: null,
      );
      return;
    }

    state = state.copyWith(
      submitting: true,
      error: null,
      errorDetail: null,
      fieldErrors: const {},
    );
    final counts = [
      for (final entry in state.quantities.entries)
        if (entry.value > 0)
          DenominationCount(denomination: entry.key, quantity: entry.value),
    ];
    try {
      await ref
          .read(cashSessionRepositoryProvider)
          .close(cashSessionId: cashSessionId, counts: counts);
      ref.invalidate(currentSessionControllerProvider);
      state = state.copyWith(submitting: false, closed: true);
    } on AppError catch (e) {
      if (e is ValidationError) {
        state = state.copyWith(submitting: false, fieldErrors: _fieldErrorsFromServer(e));
      } else if (e is ServerError && e.statusCode == 409) {
        // FR-024: entered quantities are NOT cleared — the state above this
        // catch block is untouched except for submitting/error/errorDetail.
        state = state.copyWith(
          submitting: false,
          error: CloseSessionFormErrorCode.alreadyClosed,
          errorDetail: e.serverMessage,
        );
      } else if (e is NotFoundError) {
        state = state.copyWith(
          submitting: false,
          error: CloseSessionFormErrorCode.sessionNotFound,
          errorDetail: e.serverMessage,
        );
      } else {
        state = state.copyWith(
          submitting: false,
          error: CloseSessionFormErrorCode.closeFailed,
          errorDetail: e.serverMessage,
        );
      }
    }
  }
}

Map<String, String> _fieldErrorsFromServer(ValidationError error) {
  final result = <String, String>{};
  for (final fieldError in error.errors) {
    final locKey = fieldError.loc.isNotEmpty ? fieldError.loc.last : 'error';
    result[locKey] = fieldError.msg;
  }
  return result;
}
