import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/sales/data/cash_session_repository_impl.dart';
import 'package:mbe_ui/features/sales/presentation/current_session_controller.dart';

part 'open_session_form_controller.freezed.dart';
part 'open_session_form_controller.g.dart';

/// Error codes for [OpenSessionFormState.error]/`fieldErrors`, localized in
/// the UI layer (mirrors `CashDrawerFormErrorCode`).
abstract final class OpenSessionFormErrorCode {
  static const drawerRequired = 'drawerRequired';
  static const amountNegative = 'amountNegative';
  static const amountInvalid = 'amountInvalid';
  static const drawerBusy = 'drawerBusy';
  static const cashierBusy = 'cashierBusy';
  static const noDrawerConfigured = 'noDrawerConfigured';
  static const drawerNotFound = 'drawerNotFound';
  static const openFailed = 'openFailed';
  static const openPermissionDenied = 'openPermissionDenied';
}

/// The open-session form's state (data-model.md §11).
@freezed
class OpenSessionFormState with _$OpenSessionFormState {
  const factory OpenSessionFormState({
    int? cashDrawerId,
    @Default('') String cashDrawerDisplayText,
    @Default('0') String openingAmount,
    @Default(false) bool submitting,
    @Default(false) bool saved,

    /// The other session's id, populated only on a cashier-busy 409
    /// (research.md §4) — the screen uses it to link straight to that
    /// session's detail (FR-010) instead of leaving the open form as the
    /// only path forward.
    int? blockingSessionId,
    String? error,
    String? errorDetail,
    @Default(<String, String>{}) Map<String, String> fieldErrors,
  }) = _OpenSessionFormState;
}

/// Manages the open-session form (User Story 1, FR-005 to FR-012).
@riverpod
class OpenSessionFormController extends _$OpenSessionFormController {
  @override
  OpenSessionFormState build() => const OpenSessionFormState();

  /// Preselects the drawer assigned to the signed-in user
  /// (`userSettings.cashDrawerId`/`cashDrawerName`) — called once by the
  /// screen at init, mirroring `CashDrawerFormController.facilitySelected`'s
  /// seeding pattern. A `null` id leaves the form with no preselection,
  /// which is the "must choose explicitly" case (FR-007).
  void seedAssignedDrawer(int? cashDrawerId, String? cashDrawerName) {
    state = state.copyWith(
      cashDrawerId: cashDrawerId,
      cashDrawerDisplayText: cashDrawerName ?? '',
    );
  }

  void drawerSelected(int cashDrawerId, String name) => state = state.copyWith(
    cashDrawerId: cashDrawerId,
    cashDrawerDisplayText: name,
    error: null,
    errorDetail: null,
    blockingSessionId: null,
    fieldErrors: const {},
  );

  void openingAmountChanged(String value) => state = state.copyWith(
    openingAmount: value,
    error: null,
    errorDetail: null,
    fieldErrors: const {},
  );

  Map<String, String> _validate() {
    final errors = <String, String>{};
    if (state.cashDrawerId == null) {
      errors['cashDrawer'] = OpenSessionFormErrorCode.drawerRequired;
    }
    final raw = state.openingAmount.trim();
    if (raw.isNotEmpty) {
      final amount = Decimal.tryParse(raw);
      if (amount == null) {
        errors['openingAmount'] = OpenSessionFormErrorCode.amountInvalid;
      } else if (amount < Decimal.zero) {
        errors['openingAmount'] = OpenSessionFormErrorCode.amountNegative;
      }
    }
    return errors;
  }

  /// Opens the session (FR-005). Re-checks the caller's `pos` create
  /// privilege immediately before submitting, since it may have been
  /// revoked since the form was opened.
  Future<void> submit() async {
    final fieldErrors = _validate();
    if (fieldErrors.isNotEmpty) {
      state = state.copyWith(
        fieldErrors: fieldErrors,
        error: null,
        errorDetail: null,
      );
      return;
    }

    if (!ref.read(accessControlProvider).can(SystemObject.pos, AccessRight.create)) {
      state = state.copyWith(
        error: OpenSessionFormErrorCode.openPermissionDenied,
        errorDetail: null,
      );
      return;
    }

    state = state.copyWith(
      submitting: true,
      error: null,
      errorDetail: null,
      blockingSessionId: null,
      fieldErrors: const {},
    );
    final rawAmount = state.openingAmount.trim();
    try {
      await ref
          .read(cashSessionRepositoryProvider)
          .open(
            cashDrawerId: state.cashDrawerId,
            openingAmount: rawAmount.isEmpty ? '0' : rawAmount,
          );
      ref.invalidate(currentSessionControllerProvider);
      state = state.copyWith(submitting: false, saved: true);
    } on AppError catch (e) {
      await _handleSubmitError(e);
    }
  }

  Future<void> _handleSubmitError(AppError e) async {
    if (e is ValidationError) {
      final serverFieldErrors = _fieldErrorsFromServer(e);
      if (serverFieldErrors.isEmpty) {
        // A plain-string-detail 422 (e.g. "no drawer configured") has no
        // per-field loc to key on — degrade to a generic failure rather
        // than silently clearing the form with no explanation. Unreachable
        // in practice: FR-007a blocks this client-side before submit.
        state = state.copyWith(
          submitting: false,
          error: OpenSessionFormErrorCode.noDrawerConfigured,
          errorDetail: null,
        );
      } else {
        state = state.copyWith(submitting: false, fieldErrors: serverFieldErrors);
      }
      return;
    }

    if (e is ServerError && e.statusCode == 409) {
      // The two 409s are indistinguishable by status — disambiguate by
      // re-reading whether the caller now has a session, not by parsing the
      // raw detail string (research.md §4).
      var cashierBusy = false;
      int? blockingSessionId;
      try {
        final current = await ref.read(cashSessionRepositoryProvider).getCurrent();
        final session = current.session;
        if (session != null) {
          cashierBusy = true;
          blockingSessionId = session.cashSessionId;
        }
      } catch (_) {
        // Re-read failed — fall back to drawer-busy. Telling the cashier
        // their own drawer choice is unavailable is a safer default than
        // incorrectly asking them to close a session that may not exist.
      }
      state = state.copyWith(
        submitting: false,
        error: cashierBusy
            ? OpenSessionFormErrorCode.cashierBusy
            : OpenSessionFormErrorCode.drawerBusy,
        errorDetail: e.serverMessage,
        blockingSessionId: blockingSessionId,
      );
      return;
    }

    if (e is NotFoundError) {
      state = state.copyWith(
        submitting: false,
        error: OpenSessionFormErrorCode.drawerNotFound,
        errorDetail: e.serverMessage,
      );
      return;
    }

    state = state.copyWith(
      submitting: false,
      error: OpenSessionFormErrorCode.openFailed,
      errorDetail: e.serverMessage,
    );
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
