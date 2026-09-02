import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/core/widgets/entity_status_controls.dart';
import 'package:mbe_ui/features/auth/data/user_profile_repository_impl.dart';
import 'package:mbe_ui/features/auth/domain/entities/user_profile.dart';

part 'user_profiles_controller.freezed.dart';
part 'user_profiles_controller.g.dart';

const _pageSize = 20;

/// The profile catalog's addressable view state (024-user-profiles FR-004),
/// mirroring `UserFilter` (017-ui-consistency-filters). Derived from the
/// route's [ListQuery] — the URL, not a mutable notifier, is the source of
/// truth.
@freezed
class UserProfileFilter with _$UserProfileFilter {
  const factory UserProfileFilter({
    @Default('') String search,
    EntityStatus? status,
    @Default(0) int pageIndex,
  }) = _UserProfileFilter;

  factory UserProfileFilter.fromQuery(ListQuery query) {
    return UserProfileFilter(
      search: query.search,
      status: decodeStatusFacet(query),
      pageIndex: query.pageIndex,
    );
  }
}

/// Derived facet-filter summary for the profile catalog's Filters button
/// badge, mirroring `UserFilterBadge`.
extension UserProfileFilterBadge on UserProfileFilter {
  int get activeFilterCount => status != null ? 1 : 0;

  bool get hasActiveFilters => activeFilterCount > 0;
}

/// Error codes for [UserProfileFormState.error], mapped to localized text in
/// the UI layer, mirroring `UserFormErrorCode`. A [ValidationError]'s
/// server-provided `msg` is stored directly in `error` instead (it can't be
/// localized client-side either way — same convention as the user form).
abstract final class UserProfileFormErrorCode {
  static const nameRequired = 'nameRequired';
  static const loadFailed = 'loadFailed';
  static const saveFailed = 'saveFailed';
  static const deleteFailed = 'deleteFailed';
}

/// Admin profile-form state (024-user-profiles data-model.md §3). Supports
/// both create and edit modes; local UI state, not persisted (constitution
/// §II).
@freezed
class UserProfileFormState with _$UserProfileFormState {
  const factory UserProfileFormState({
    @Default('') String name,
    @Default('') String description,
    @Default(EntityStatus.active) EntityStatus status,
    @Default(<Privilege>[]) List<Privilege> privileges,
    @Default(false) bool loading,
    @Default(false) bool submitting,
    @Default(false) bool saved,
    @Default(false) bool deleted,
    String? error,

    /// The server-provided detail behind [error] (mbe-api's `detail` string
    /// on a `404`/`409`/`5xx`), shown alongside the localized [error]
    /// message since it can't be localized client-side. `null` for a
    /// [ValidationError]'s message (already raw server text stored directly
    /// in `error`).
    String? errorDetail,
  }) = _UserProfileFormState;
}

/// Whether at least one active profile exists — so the profile picker on
/// the new-user form and the apply dialog can show "no profiles yet"
/// instead of an empty, unexplained dropdown (024-user-profiles US2
/// scenario 14).
@riverpod
Future<bool> hasActiveUserProfiles(Ref ref) async {
  final result = await ref
      .read(userProfileRepositoryProvider)
      .list(status: EntityStatus.active, limit: 1);
  return result.total > 0;
}

/// Fetches and holds the admin profile catalog (024-user-profiles FR-001,
/// FR-002, FR-003) for the given [UserProfileFilter]. A family keyed by the
/// filter value, mirroring `UsersController`.
@riverpod
class UserProfilesController extends _$UserProfilesController {
  @override
  Future<CatalogPage<UserProfileSummary>> build(UserProfileFilter filter) {
    return fetchClampedPage(
      pageIndex: filter.pageIndex,
      pageSize: _pageSize,
      fetch: (pageIndex) => _fetch(filter.copyWith(pageIndex: pageIndex)),
    );
  }

  Future<CatalogPage<UserProfileSummary>> _fetch(
    UserProfileFilter filter,
  ) async {
    final result = await ref
        .read(userProfileRepositoryProvider)
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

/// Manages the create/edit profile form (024-user-profiles FR-006, FR-007).
/// Local UI state, not persisted (constitution §II). Call [loadProfile] on
/// the detail screen's `initState` when editing an existing profile.
@riverpod
class UserProfileFormController extends _$UserProfileFormController {
  @override
  UserProfileFormState build() => const UserProfileFormState();

  /// Populates the form from an existing profile (edit mode).
  Future<void> loadProfile(int profileId) async {
    state = state.copyWith(loading: true, error: null, errorDetail: null);
    try {
      final profile = await ref
          .read(userProfileRepositoryProvider)
          .get(profileId: profileId);
      state = UserProfileFormState(
        name: profile.name,
        description: profile.description ?? '',
        status: profile.status,
        privileges: profile.privileges,
      );
    } on AppError catch (e) {
      state = state.copyWith(
        loading: false,
        error: UserProfileFormErrorCode.loadFailed,
        errorDetail: e.serverMessage,
      );
    }
  }

  void nameChanged(String v) =>
      state = state.copyWith(name: v, error: null, errorDetail: null);

  void descriptionChanged(String v) =>
      state = state.copyWith(description: v, error: null, errorDetail: null);

  void statusChanged(EntityStatus v) =>
      state = state.copyWith(status: v, error: null, errorDetail: null);

  /// Updates the `rawValue` bitmask for one [SystemObject] in the form's
  /// privileges list. Removes the entry when [rawValue] is 0 — a profile
  /// stores an entry only for what it grants (024-user-profiles FR-010),
  /// same logic as `UserFormController.privilegeChanged`.
  void privilegeChanged(SystemObject obj, int rawValue) {
    final updated = state.privileges
        .where((p) => p.systemObject != obj)
        .toList();
    if (rawValue != 0) {
      updated.add(Privilege(systemObject: obj, rawValue: rawValue));
    }
    state = state.copyWith(privileges: updated, error: null, errorDetail: null);
  }

  /// Drops every cached page of the catalog list so a create/update/delete
  /// is visible the moment the form pops back to it. The list is a family
  /// keyed by filter, and the list screen stays mounted underneath the
  /// pushed form — so without this its provider keeps its listener, serves
  /// the stale cached page, and the change appears to have been lost.
  /// Matches every other catalog form controller (e.g.
  /// `CustomerFormController`, `LabelFormController._invalidateCaches`).
  void _invalidateCaches() {
    ref.invalidate(userProfilesControllerProvider);
    ref.invalidate(hasActiveUserProfilesProvider);
  }

  /// Creates or updates the profile. Pass [existingProfileId] for edit mode
  /// (null for create).
  Future<void> save({int? existingProfileId}) async {
    if (state.name.trim().isEmpty) {
      state = state.copyWith(
        error: UserProfileFormErrorCode.nameRequired,
        errorDetail: null,
      );
      return;
    }

    state = state.copyWith(
      submitting: true,
      error: null,
      errorDetail: null,
      saved: false,
    );
    try {
      final repo = ref.read(userProfileRepositoryProvider);
      if (existingProfileId != null) {
        await repo.update(
          profileId: existingProfileId,
          name: state.name,
          description: state.description.isEmpty ? null : state.description,
          status: state.status,
          privileges: state.privileges,
        );
      } else {
        await repo.create(
          name: state.name,
          description: state.description.isEmpty ? null : state.description,
          status: state.status,
          privileges: state.privileges,
        );
      }
      _invalidateCaches();
      state = state.copyWith(submitting: false, saved: true);
    } on AppError catch (e) {
      if (e is ValidationError && e.errors.isNotEmpty) {
        state = state.copyWith(submitting: false, error: e.errors.first.msg);
      } else {
        state = state.copyWith(
          submitting: false,
          error: UserProfileFormErrorCode.saveFailed,
          errorDetail: e.serverMessage,
        );
      }
    }
  }

  Future<void> deleteProfile(int profileId) async {
    state = state.copyWith(submitting: true, error: null, errorDetail: null);
    try {
      await ref
          .read(userProfileRepositoryProvider)
          .delete(profileId: profileId);
      _invalidateCaches();
      state = state.copyWith(submitting: false, deleted: true);
    } on AppError catch (e) {
      if (e is ValidationError && e.errors.isNotEmpty) {
        state = state.copyWith(submitting: false, error: e.errors.first.msg);
      } else {
        state = state.copyWith(
          submitting: false,
          error: UserProfileFormErrorCode.deleteFailed,
          errorDetail: e.serverMessage,
        );
      }
    }
  }
}
