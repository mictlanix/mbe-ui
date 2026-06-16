import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/access/user_settings.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/auth/data/user_repository_impl.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';

part 'users_controller.freezed.dart';
part 'users_controller.g.dart';

/// Admin user-form state (data-model.md "Admin user-form state").
/// Supports both create and edit modes; local UI state, not persisted
/// (constitution §II).
@freezed
class UserFormState with _$UserFormState {
  const factory UserFormState({
    @Default('') String userId,
    @Default('') String password,
    @Default('') String email,
    int? employeeId,
    @Default(false) bool administrator,
    @Default(false) bool disabled,
    @Default(<Privilege>[]) List<Privilege> privileges,
    UserSettings? settings,
    @Default(false) bool loading,
    @Default(false) bool submitting,
    @Default(false) bool saved,
    @Default(false) bool deleted,
    String? error,
    String? recoveryToken,
    String? recoveryExpiresAt,
  }) = _UserFormState;
}

/// Fetches and holds the admin users list (FR-011).
@riverpod
class UsersController extends _$UsersController {
  @override
  Future<List<UserSummary>> build() {
    return ref.read(userRepositoryProvider).list();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(userRepositoryProvider).list(),
    );
  }
}

/// Manages the create/edit user form (FR-012/FR-013). Local UI state, not
/// persisted (constitution §II). Call [loadUser] on the detail screen's
/// `initState` when editing an existing user.
@riverpod
class UserFormController extends _$UserFormController {
  @override
  UserFormState build() => const UserFormState();

  /// Populates the form from an existing user (edit mode).
  Future<void> loadUser(String userId) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final user = await ref.read(userRepositoryProvider).get(userId: userId);
      state = UserFormState(
        email: user.email,
        employeeId: user.employeeId,
        administrator: user.administrator,
        disabled: user.disabled,
        privileges: user.privileges,
        settings: user.settings,
      );
    } on AppError {
      state = state.copyWith(loading: false, error: 'Failed to load user.');
    }
  }

  void userIdChanged(String v) => state = state.copyWith(userId: v, error: null);
  void passwordChanged(String v) => state = state.copyWith(password: v, error: null);
  void emailChanged(String v) => state = state.copyWith(email: v, error: null);

  void employeeIdChanged(String v) {
    state = state.copyWith(employeeId: int.tryParse(v), error: null);
  }

  void administratorChanged(bool v) =>
      state = state.copyWith(administrator: v, error: null);

  void disabledChanged(bool v) =>
      state = state.copyWith(disabled: v, error: null);

  /// Updates the `rawValue` bitmask for one [SystemObject] in the form's
  /// privileges list. Removes the entry when [rawValue] is 0.
  void privilegeChanged(SystemObject obj, int rawValue) {
    final updated = state.privileges
        .where((p) => p.systemObject != obj)
        .toList();
    if (rawValue != 0) {
      updated.add(Privilege(systemObject: obj, rawValue: rawValue));
    }
    state = state.copyWith(privileges: updated, error: null);
  }

  /// Creates or updates the user. Pass [existingUserId] for edit mode (null
  /// for create). On a successful update of the signed-in administrator's own
  /// account, refreshes the in-memory session (FR-014).
  Future<void> save({String? existingUserId}) async {
    if (state.email.isEmpty) {
      state = state.copyWith(error: 'Email is required.');
      return;
    }
    if (existingUserId == null) {
      if (state.userId.isEmpty) {
        state = state.copyWith(error: 'Username is required.');
        return;
      }
      if (state.password.length < 6) {
        state = state.copyWith(error: 'Password must be at least 6 characters.');
        return;
      }
    }

    state = state.copyWith(submitting: true, error: null, saved: false);
    try {
      final repo = ref.read(userRepositoryProvider);
      if (existingUserId != null) {
        final updated = await repo.update(
          userId: existingUserId,
          email: state.email,
          employeeId: state.employeeId,
          administrator: state.administrator,
          disabled: state.disabled,
          privileges: state.privileges,
          settings: state.settings,
        );
        ref.read(authNotifierProvider.notifier).refreshCurrentUser(updated);
      } else {
        final created = await repo.create(
          userId: state.userId,
          password: state.password,
          email: state.email,
          employeeId: state.employeeId,
          administrator: state.administrator,
          disabled: state.disabled,
        );
        if (state.privileges.isNotEmpty) {
          await repo.update(
            userId: created.userId,
            privileges: state.privileges,
          );
        }
      }
      state = state.copyWith(submitting: false, saved: true);
    } on AppError catch (e) {
      final msg = e is ValidationError && e.errors.isNotEmpty
          ? e.errors.first.msg
          : 'Failed to save user.';
      state = state.copyWith(submitting: false, error: msg);
    }
  }

  /// Triggers admin-initiated password recovery (FR-010 admin path) and
  /// stores the result for display.
  Future<void> recoverPassword(String userId) async {
    state = state.copyWith(
      submitting: true,
      error: null,
      recoveryToken: null,
      recoveryExpiresAt: null,
    );
    try {
      final result = await ref
          .read(userRepositoryProvider)
          .recoverPassword(userId: userId);
      state = state.copyWith(
        submitting: false,
        recoveryToken: result.recoveryToken,
        recoveryExpiresAt: result.expiresAt,
      );
    } on AppError {
      state = state.copyWith(
        submitting: false,
        error: 'Failed to generate recovery token.',
      );
    }
  }

  Future<void> deleteUser(String userId) async {
    state = state.copyWith(submitting: true, error: null);
    try {
      await ref.read(userRepositoryProvider).delete(userId: userId);
      ref.read(usersControllerProvider.notifier).refresh();
      state = state.copyWith(submitting: false, deleted: true);
    } on AppError catch (e) {
      final msg = e is ValidationError && e.errors.isNotEmpty
          ? e.errors.first.msg
          : 'Failed to delete user.';
      state = state.copyWith(submitting: false, error: msg);
    }
  }

  void clearRecoveryResult() =>
      state = state.copyWith(recoveryToken: null, recoveryExpiresAt: null);
}
