import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/auth/domain/entities/password_policy.dart';

part 'account_controller.freezed.dart';
part 'account_controller.g.dart';

/// Codes for the local `error` of the password forms, mapped to localized
/// text in the UI layer (`localizePasswordFormError`) since controllers have
/// no `AppLocalizations` access.
abstract final class PasswordFormErrorCode {
  static const fieldsRequired = 'fieldsRequired';
  static const passwordMismatch = 'passwordMismatch';
}

/// The policy rules [password] misses. Empty when the policy hasn't loaded:
/// the client doesn't block and the server enforces it (R2).
Set<PasswordRule> _unmetRules(Ref ref, String password) {
  return ref.read(passwordPolicyProvider).value?.unmet(password) ?? const {};
}

/// A local policy miss, shaped like the server's rejection so the form maps
/// both through `rulesFromFieldError`.
AppError _policyRejection(Set<PasswordRule> rules) {
  return AppError.validation([
    FieldError(
      loc: const [],
      msg: '',
      type: 'password_policy',
      failedRules: [for (final rule in rules) rule.serverName],
    ),
  ]);
}

/// Form state for `POST /api/v1/auth/change-password` (FR-009).
@freezed
abstract class ChangePasswordFormState with _$ChangePasswordFormState {
  const factory ChangePasswordFormState({
    @Default('') String oldPassword,
    @Default('') String newPassword,
    @Default('') String confirmPassword,
    @Default(false) bool submitting,
    @Default(false) bool success,

    /// A [PasswordFormErrorCode] from the local checks.
    String? error,

    /// A repository failure, surfaced through the shared `ErrorBanner`.
    AppError? failure,
  }) = _ChangePasswordFormState;
}

/// Drives `ChangePasswordScreen` (FR-009). Local UI state, not persisted
/// (constitution §II).
@riverpod
class ChangePasswordController extends _$ChangePasswordController {
  @override
  ChangePasswordFormState build() => const ChangePasswordFormState();

  void oldPasswordChanged(String value) => state = state.copyWith(
    oldPassword: value,
    error: null,
    failure: null,
    success: false,
  );

  void newPasswordChanged(String value) => state = state.copyWith(
    newPassword: value,
    error: null,
    failure: null,
    success: false,
  );

  void confirmPasswordChanged(String value) => state = state.copyWith(
    confirmPassword: value,
    error: null,
    failure: null,
    success: false,
  );

  Future<void> submit() async {
    if (state.oldPassword.isEmpty || state.newPassword.isEmpty) {
      state = state.copyWith(error: PasswordFormErrorCode.fieldsRequired);
      return;
    }
    final unmet = _unmetRules(ref, state.newPassword);
    if (unmet.isNotEmpty) {
      state = state.copyWith(failure: _policyRejection(unmet));
      return;
    }
    if (state.newPassword != state.confirmPassword) {
      state = state.copyWith(error: PasswordFormErrorCode.passwordMismatch);
      return;
    }

    state = state.copyWith(submitting: true, error: null, failure: null);
    try {
      await ref
          .read(authRepositoryProvider)
          .changePassword(
            oldPassword: state.oldPassword,
            newPassword: state.newPassword,
          );
      state = state.copyWith(submitting: false, success: true);
    } on AppError catch (e) {
      state = state.copyWith(submitting: false, failure: e);
    }
  }
}

/// Form state for `POST /api/v1/auth/recover` (FR-010 — user-initiated confirm).
@freezed
abstract class RecoveryFormState with _$RecoveryFormState {
  const factory RecoveryFormState({
    @Default('') String recoveryToken,
    @Default('') String newPassword,
    @Default('') String confirmPassword,
    @Default(false) bool submitting,
    @Default(false) bool success,

    /// A [PasswordFormErrorCode] from the local checks.
    String? error,

    /// A repository failure, surfaced through the shared `ErrorBanner`.
    AppError? failure,
  }) = _RecoveryFormState;
}

/// Drives the recovery-confirm form on `ForgotPasswordScreen` (FR-010).
/// Local UI state, not persisted (constitution §II).
@riverpod
class RecoveryController extends _$RecoveryController {
  @override
  RecoveryFormState build() => const RecoveryFormState();

  void recoveryTokenChanged(String value) => state = state.copyWith(
    recoveryToken: value,
    error: null,
    failure: null,
    success: false,
  );

  void newPasswordChanged(String value) => state = state.copyWith(
    newPassword: value,
    error: null,
    failure: null,
    success: false,
  );

  void confirmPasswordChanged(String value) => state = state.copyWith(
    confirmPassword: value,
    error: null,
    failure: null,
    success: false,
  );

  Future<void> submit() async {
    if (state.recoveryToken.isEmpty || state.newPassword.isEmpty) {
      state = state.copyWith(error: PasswordFormErrorCode.fieldsRequired);
      return;
    }
    final unmet = _unmetRules(ref, state.newPassword);
    if (unmet.isNotEmpty) {
      state = state.copyWith(failure: _policyRejection(unmet));
      return;
    }
    if (state.newPassword != state.confirmPassword) {
      state = state.copyWith(error: PasswordFormErrorCode.passwordMismatch);
      return;
    }

    state = state.copyWith(submitting: true, error: null, failure: null);
    try {
      await ref
          .read(authRepositoryProvider)
          .recoverConfirm(
            recoveryToken: state.recoveryToken,
            newPassword: state.newPassword,
          );
      state = state.copyWith(submitting: false, success: true);
    } on AppError catch (e) {
      state = state.copyWith(submitting: false, failure: e);
    }
  }
}
