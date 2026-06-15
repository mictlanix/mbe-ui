import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';

part 'login_controller.freezed.dart';
part 'login_controller.g.dart';

/// Sign-in form state (data-model.md "Login form state"). Local UI state,
/// not persisted (constitution §II).
@freezed
class LoginFormState with _$LoginFormState {
  const factory LoginFormState({
    @Default('') String username,
    @Default('') String password,
    @Default(false) bool submitting,
    String? error,
  }) = _LoginFormState;
}

/// Drives the sign-in form (FR-001, FR-008). Delegates the actual sign-in
/// attempt to [AuthNotifier.signIn] and surfaces a single generic error
/// message on `401`/`422` without indicating which field was wrong.
@riverpod
class LoginController extends _$LoginController {
  @override
  LoginFormState build() => const LoginFormState();

  void usernameChanged(String value) {
    state = state.copyWith(username: value, error: null);
  }

  void passwordChanged(String value) {
    state = state.copyWith(password: value, error: null);
  }

  Future<void> submit() async {
    if (state.username.isEmpty || state.password.isEmpty) {
      state = state.copyWith(error: 'Please enter your username and password.');
      return;
    }

    state = state.copyWith(submitting: true, error: null);

    await ref.read(authNotifierProvider.notifier).signIn(
      username: state.username,
      password: state.password,
    );

    final authState = ref.read(authNotifierProvider).valueOrNull;
    final invalidCredentials = authState is AuthUnauthenticated &&
        authState.reason == SignOutReason.invalidCredentials;

    state = state.copyWith(
      submitting: false,
      error: invalidCredentials ? 'Invalid username or password.' : null,
    );
  }
}
