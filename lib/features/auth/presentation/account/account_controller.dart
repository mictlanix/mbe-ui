import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';

part 'account_controller.freezed.dart';
part 'account_controller.g.dart';

/// Form state for `POST /api/v1/auth/change-password` (FR-009).
@freezed
class ChangePasswordFormState with _$ChangePasswordFormState {
  const factory ChangePasswordFormState({
    @Default('') String oldPassword,
    @Default('') String newPassword,
    @Default(false) bool submitting,
    @Default(false) bool success,
    String? error,
  }) = _ChangePasswordFormState;
}

/// Drives `ChangePasswordScreen` (FR-009). Local UI state, not persisted
/// (constitution §II).
@riverpod
class ChangePasswordController extends _$ChangePasswordController {
  @override
  ChangePasswordFormState build() => const ChangePasswordFormState();

  void oldPasswordChanged(String value) =>
      state = state.copyWith(oldPassword: value, error: null, success: false);

  void newPasswordChanged(String value) =>
      state = state.copyWith(newPassword: value, error: null, success: false);

  Future<void> submit() async {
    if (state.oldPassword.isEmpty || state.newPassword.isEmpty) {
      state = state.copyWith(error: 'Please fill in all fields.');
      return;
    }
    if (state.newPassword.length < 6) {
      state = state.copyWith(
        error: 'New password must be at least 6 characters.',
      );
      return;
    }

    state = state.copyWith(submitting: true, error: null);
    try {
      await ref
          .read(authRepositoryProvider)
          .changePassword(
            oldPassword: state.oldPassword,
            newPassword: state.newPassword,
          );
      state = state.copyWith(submitting: false, success: true);
    } on AppError catch (e) {
      final msg = e is ValidationError && e.errors.isNotEmpty
          ? e.errors.first.msg
          : 'Failed to change password. Please try again.';
      state = state.copyWith(submitting: false, error: msg);
    }
  }
}

/// Form state for `POST /api/v1/auth/recover` (FR-010 — user-initiated confirm).
@freezed
class RecoveryFormState with _$RecoveryFormState {
  const factory RecoveryFormState({
    @Default('') String recoveryToken,
    @Default('') String newPassword,
    @Default(false) bool submitting,
    @Default(false) bool success,
    String? error,
  }) = _RecoveryFormState;
}

/// Drives the recovery-confirm form on `ForgotPasswordScreen` (FR-010).
/// Local UI state, not persisted (constitution §II).
@riverpod
class RecoveryController extends _$RecoveryController {
  @override
  RecoveryFormState build() => const RecoveryFormState();

  void recoveryTokenChanged(String value) =>
      state = state.copyWith(recoveryToken: value, error: null, success: false);

  void newPasswordChanged(String value) =>
      state = state.copyWith(newPassword: value, error: null, success: false);

  Future<void> submit() async {
    if (state.recoveryToken.isEmpty || state.newPassword.isEmpty) {
      state = state.copyWith(error: 'Please fill in all fields.');
      return;
    }
    if (state.newPassword.length < 6) {
      state = state.copyWith(
        error: 'New password must be at least 6 characters.',
      );
      return;
    }

    state = state.copyWith(submitting: true, error: null);
    try {
      await ref
          .read(authRepositoryProvider)
          .recoverConfirm(
            recoveryToken: state.recoveryToken,
            newPassword: state.newPassword,
          );
      state = state.copyWith(submitting: false, success: true);
    } on AppError catch (e) {
      final msg = e is ValidationError && e.errors.isNotEmpty
          ? e.errors.first.msg
          : 'Invalid or expired recovery link. Contact your administrator.';
      state = state.copyWith(submitting: false, error: msg);
    }
  }
}
