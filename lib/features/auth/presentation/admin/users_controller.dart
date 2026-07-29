import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/access/user_settings.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/auth/data/user_repository_impl.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/features/catalog/data/employee_repository_impl.dart';

part 'users_controller.freezed.dart';
part 'users_controller.g.dart';

const _pageSize = 20;

extension _EntityStatusByName on List<EntityStatus> {
  EntityStatus? byNameOrNull(String name) {
    for (final value in this) {
      if (value.name == name) return value;
    }
    return null;
  }
}

/// The Users list screen's addressable view state
/// (017-ui-consistency-filters FR-011, FR-017, data-model.md "UserFilter"):
/// search and a status facet. Derived from the route's [ListQuery] — the
/// URL, not a mutable notifier, is the source of truth.
@freezed
class UserFilter with _$UserFilter {
  const factory UserFilter({
    @Default('') String search,
    EntityStatus? status,
    @Default(0) int pageIndex,
  }) = _UserFilter;

  factory UserFilter.fromQuery(ListQuery query) {
    final statusRaw = query.facet('status');
    return UserFilter(
      search: query.search,
      status: statusRaw != null
          ? EntityStatus.values.byNameOrNull(statusRaw)
          : null,
      pageIndex: query.pageIndex,
    );
  }
}

/// Derived facet-filter summary for the Users list's Filters button badge,
/// mirroring `VehicleFilterBadge.activeFilterCount`. [search] has its own
/// always-visible box and is excluded.
extension UserFilterBadge on UserFilter {
  int get activeFilterCount => status != null ? 1 : 0;

  bool get hasActiveFilters => activeFilterCount > 0;
}

/// Error codes for [UserFormState.error], mapped to localized text in the
/// UI layer (`user_detail_screen.dart`) since this controller has no
/// `BuildContext`/`AppLocalizations` access. A [ValidationError]'s
/// server-provided `msg` is stored directly in `error` instead (it can't be
/// localized client-side either way), so it isn't one of these codes.
abstract final class UserFormErrorCode {
  static const emailRequired = 'emailRequired';
  static const usernameRequired = 'usernameRequired';
  static const employeeRequired = 'employeeRequired';
  static const passwordLength = 'passwordLength';
  static const loadFailed = 'loadFailed';
  static const saveFailed = 'saveFailed';
  static const deleteFailed = 'deleteFailed';
  static const recoveryFailed = 'recoveryFailed';
}

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

    /// The selected employee's display name, shown in the employee picker.
    /// Pre-filled by [UserFormController.loadUser] (resolved via a lookup,
    /// since `UserResponse.employeeId` is a bare id with no expansion) and
    /// set directly by [UserFormController.employeeSelected] when the user
    /// picks a new one.
    @Default('') String employeeDisplayText,
    @Default(false) bool administrator,
    @Default(EntityStatus.active) EntityStatus status,
    @Default(<Privilege>[]) List<Privilege> privileges,
    UserSettings? settings,
    @Default(false) bool loading,
    @Default(false) bool submitting,
    @Default(false) bool saved,
    @Default(false) bool deleted,
    String? error,

    /// The server-provided detail behind [error] (e.g. mbe-api's `detail`
    /// string on a `404`/`5xx`), shown alongside the localized [error]
    /// message since it can't be localized client-side. `null` for
    /// client-side-only errors and for a [ValidationError]'s message
    /// (already raw server text stored directly in `error`).
    String? errorDetail,
    String? recoveryToken,
    String? recoveryExpiresAt,
  }) = _UserFormState;
}

/// Fetches and holds the admin users list (FR-001, FR-002, FR-011) for the
/// given [UserFilter]. A family keyed by the filter value: a different URL
/// is a different provider instance, and `ref.invalidate` after a mutation
/// re-fetches the *same* page rather than resetting to page 0 (FR-025,
/// research §3).
@riverpod
class UsersController extends _$UsersController {
  @override
  Future<CatalogPage<UserSummary>> build(UserFilter filter) {
    return fetchClampedPage(
      pageIndex: filter.pageIndex,
      pageSize: _pageSize,
      fetch: (pageIndex) => _fetch(filter.copyWith(pageIndex: pageIndex)),
    );
  }

  Future<CatalogPage<UserSummary>> _fetch(UserFilter filter) async {
    final result = await ref
        .read(userRepositoryProvider)
        .list(
          search: filter.search.isEmpty ? null : filter.search,
          status: filter.status,
          skip: filter.pageIndex * _pageSize,
          limit: _pageSize,
        );
    return CatalogPage(
      items: result.items,
      total: result.total,
      pageIndex: filter.pageIndex,
      pageSize: _pageSize,
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

  /// Populates the form from an existing user (edit mode). If an
  /// `employeeId` is set, resolves it to a display name for the employee
  /// picker via a lookup — `UserResponse.employeeId` is a bare id with no
  /// server-side expansion. A stale/orphaned id (the referenced employee no
  /// longer exists) falls back to a raw `#id` label rather than failing the
  /// whole load.
  Future<void> loadUser(String userId) async {
    state = state.copyWith(loading: true, error: null, errorDetail: null);
    try {
      final user = await ref.read(userRepositoryProvider).get(userId: userId);
      var employeeDisplayText = '';
      if (user.employeeId != null) {
        try {
          final employee = await ref
              .read(employeeRepositoryProvider)
              .get(employeeId: user.employeeId!);
          employeeDisplayText = '${employee.firstName} ${employee.lastName}';
        } on AppError {
          employeeDisplayText = '#${user.employeeId}';
        }
      }
      state = UserFormState(
        email: user.email,
        employeeId: user.employeeId,
        employeeDisplayText: employeeDisplayText,
        administrator: user.administrator,
        status: user.status,
        privileges: user.privileges,
        settings: user.settings,
      );
    } on AppError catch (e) {
      state = state.copyWith(
        loading: false,
        error: UserFormErrorCode.loadFailed,
        errorDetail: e.serverMessage,
      );
    }
  }

  void userIdChanged(String v) =>
      state = state.copyWith(userId: v, error: null, errorDetail: null);
  void passwordChanged(String v) =>
      state = state.copyWith(password: v, error: null, errorDetail: null);
  void emailChanged(String v) =>
      state = state.copyWith(email: v, error: null, errorDetail: null);

  /// Sets the employee picked from the `CatalogEntityPicker` (or clears the
  /// assignment when [id] is `null`).
  void employeeSelected(int? id, String displayText) {
    state = state.copyWith(
      employeeId: id,
      employeeDisplayText: displayText,
      error: null,
      errorDetail: null,
    );
  }

  void administratorChanged(bool v) =>
      state = state.copyWith(administrator: v, error: null, errorDetail: null);

  void statusChanged(EntityStatus v) =>
      state = state.copyWith(status: v, error: null, errorDetail: null);

  /// Updates the `rawValue` bitmask for one [SystemObject] in the form's
  /// privileges list. Removes the entry when [rawValue] is 0.
  void privilegeChanged(SystemObject obj, int rawValue) {
    final updated = state.privileges
        .where((p) => p.systemObject != obj)
        .toList();
    if (rawValue != 0) {
      updated.add(Privilege(systemObject: obj, rawValue: rawValue));
    }
    state = state.copyWith(privileges: updated, error: null, errorDetail: null);
  }

  /// Creates or updates the user. Pass [existingUserId] for edit mode (null
  /// for create). On a successful update of the signed-in administrator's own
  /// account, refreshes the in-memory session (FR-014).
  Future<void> save({String? existingUserId}) async {
    if (state.email.isEmpty) {
      state = state.copyWith(
        error: UserFormErrorCode.emailRequired,
        errorDetail: null,
      );
      return;
    }
    if (existingUserId == null) {
      if (state.userId.isEmpty) {
        state = state.copyWith(
          error: UserFormErrorCode.usernameRequired,
          errorDetail: null,
        );
        return;
      }
      if (state.password.length < 6) {
        state = state.copyWith(
          error: UserFormErrorCode.passwordLength,
          errorDetail: null,
        );
        return;
      }
      if (state.employeeId == null) {
        state = state.copyWith(
          error: UserFormErrorCode.employeeRequired,
          errorDetail: null,
        );
        return;
      }
    }

    state = state.copyWith(
      submitting: true,
      error: null,
      errorDetail: null,
      saved: false,
    );
    try {
      final repo = ref.read(userRepositoryProvider);
      if (existingUserId != null) {
        final updated = await repo.update(
          userId: existingUserId,
          email: state.email,
          employeeId: state.employeeId,
          administrator: state.administrator,
          status: state.status,
          privileges: state.privileges,
          settings: state.settings,
        );
        ref.read(authNotifierProvider.notifier).refreshCurrentUser(updated);
      } else {
        final created = await repo.create(
          userId: state.userId,
          password: state.password,
          email: state.email,
          employeeId: state.employeeId!,
          administrator: state.administrator,
          status: state.status,
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
      if (e is ValidationError && e.errors.isNotEmpty) {
        state = state.copyWith(submitting: false, error: e.errors.first.msg);
      } else {
        state = state.copyWith(
          submitting: false,
          error: UserFormErrorCode.saveFailed,
          errorDetail: e.serverMessage,
        );
      }
    }
  }

  /// Triggers admin-initiated password recovery (FR-010 admin path) and
  /// stores the result for display.
  Future<void> recoverPassword(String userId) async {
    state = state.copyWith(
      submitting: true,
      error: null,
      errorDetail: null,
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
    } on AppError catch (e) {
      state = state.copyWith(
        submitting: false,
        error: UserFormErrorCode.recoveryFailed,
        errorDetail: e.serverMessage,
      );
    }
  }

  Future<void> deleteUser(String userId) async {
    state = state.copyWith(submitting: true, error: null, errorDetail: null);
    try {
      await ref.read(userRepositoryProvider).delete(userId: userId);
      ref.invalidate(usersControllerProvider);
      state = state.copyWith(submitting: false, deleted: true);
    } on AppError catch (e) {
      if (e is ValidationError && e.errors.isNotEmpty) {
        state = state.copyWith(submitting: false, error: e.errors.first.msg);
      } else {
        state = state.copyWith(
          submitting: false,
          error: UserFormErrorCode.deleteFailed,
          errorDetail: e.serverMessage,
        );
      }
    }
  }

  void clearRecoveryResult() =>
      state = state.copyWith(recoveryToken: null, recoveryExpiresAt: null);
}
