import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/entity_status_controls.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/record_form_actions.dart';
import 'package:mbe_ui/features/auth/data/user_profile_repository_impl.dart';
import 'package:mbe_ui/features/auth/domain/entities/user_profile.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/auth/presentation/admin/apply_profile_dialog.dart';
import 'package:mbe_ui/features/auth/presentation/admin/privileges_grid.dart';
import 'package:mbe_ui/features/auth/presentation/admin/user_profiles_controller.dart';
import 'package:mbe_ui/features/auth/presentation/admin/users_controller.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/features/catalog/data/employee_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/employee_list_item.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Create / edit screen for a single user account (FR-012/FR-013/FR-014).
/// [userId] is null in create mode; non-null in edit mode.
class UserDetailScreen extends ConsumerStatefulWidget {
  const UserDetailScreen({super.key, this.userId, this.forceReadOnly = false});

  final String? userId;

  /// Forces read-only rendering regardless of update permission — set when
  /// navigated to via the View row action rather than Edit (FR-006,
  /// research.md §5), read from the `?view=true` query parameter.
  final bool forceReadOnly;

  @override
  ConsumerState<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends ConsumerState<UserDetailScreen> {
  final _formKey = GlobalKey<FormState>();

  bool get _isEdit => widget.userId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      // Load after the first frame so the provider is already mounted.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(userFormControllerProvider.notifier).loadUser(widget.userId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(userFormControllerProvider);
    final controller = ref.read(userFormControllerProvider.notifier);
    final access = ref.watch(accessControlProvider);
    final canUpdate = access.can(SystemObject.users, AccessRight.update);
    final canDelete =
        !widget.forceReadOnly &&
        _isEdit &&
        access.can(SystemObject.users, AccessRight.delete);
    final readOnly = (_isEdit && !canUpdate) || widget.forceReadOnly;
    final fieldsEnabled = !formState.submitting && !readOnly;
    final l10n = AppLocalizations.of(context)!;
    final employeeRepo = ref.read(employeeRepositoryProvider);
    // Applying a profile is administrator-only server-side, matching the
    // profile catalog itself (024-user-profiles research.md §2) — neither
    // the create-form picker nor the apply action is a per-object
    // permission, so they gate on the administrator flag rather than
    // `canUpdate`.
    final isAdministrator = access.isAdministrator;
    final signedInUserId = switch (ref.watch(authNotifierProvider).valueOrNull) {
      AuthAuthenticated(:final user) => user.userId,
      _ => null,
    };
    final title = readOnly
        ? l10n.viewUserTitle
        : (_isEdit ? l10n.editUserTitle : l10n.newUserTitle);

    if (formState.loading) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (formState.saved || formState.deleted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.pop();
      });
    }

    final mode = !_isEdit
        ? RecordFormMode.create
        : (readOnly ? RecordFormMode.view : RecordFormMode.edit);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (formState.error != null) ...[
                ErrorBanner(
                  error: AppError.validation([
                    FieldError(
                      loc: const [],
                      msg: _localizeFormError(l10n, formState.error!),
                      type: 'error',
                    ),
                    // The server's own message (e.g. "User not found") can't
                    // be localized client-side, so it's shown as
                    // supplementary detail under the localized heading above.
                    if (formState.errorDetail != null)
                      FieldError(
                        loc: const [],
                        msg: formState.errorDetail!,
                        type: 'error',
                      ),
                  ]),
                ),
                const SizedBox(height: 16),
              ],
              if (formState.recoveryToken != null) ...[
                _RecoveryTokenCard(
                  token: formState.recoveryToken!,
                  expiresAt: formState.recoveryExpiresAt ?? '',
                  onDismiss: controller.clearRecoveryResult,
                ),
                const SizedBox(height: 16),
              ],
              if (!_isEdit) ...[
                TextFormField(
                  key: const Key('user_id_field'),
                  decoration: InputDecoration(labelText: l10n.usernameLabel),
                  enabled: fieldsEnabled,
                  onChanged: controller.userIdChanged,
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return l10n.userUsernameRequiredError;
                    }
                    if (v.length < 4 || v.length > 20) {
                      return l10n.userIdLengthError;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('password_field'),
                  decoration: InputDecoration(labelText: l10n.passwordLabel),
                  obscureText: true,
                  enabled: fieldsEnabled,
                  onChanged: controller.passwordChanged,
                  validator: (v) => (v ?? '').length < 6
                      ? l10n.userPasswordLengthError
                      : null,
                ),
                const SizedBox(height: 12),
              ],
              TextFormField(
                key: const Key('email_field'),
                initialValue: formState.email,
                decoration: InputDecoration(labelText: l10n.emailLabel),
                enabled: fieldsEnabled,
                onChanged: controller.emailChanged,
                validator: (v) => (v == null || v.isEmpty)
                    ? l10n.userEmailRequiredError
                    : null,
              ),
              const SizedBox(height: 12),
              CatalogEntityPicker<EmployeeListItem>(
                key: const Key('employee_id_field'),
                label: l10n.employeeIdLabel,
                displayStringForOption: (e) => e.fullName,
                optionsBuilder: (query) async {
                  final result = await employeeRepo.list(
                    search: query.isEmpty ? null : query,
                  );
                  return result.items;
                },
                onSelected: (e) =>
                    controller.employeeSelected(e.employeeId, e.fullName),
                initialDisplayText: formState.employeeDisplayText,
                enabled: fieldsEnabled,
              ),
              const SizedBox(height: 12),
              // Create mode only (024-user-profiles FR-016/FR-017): naming
              // a profile here provisions the account with it in the same
              // action, replacing the per-object walk through the grid
              // below — which this hides while a profile is selected,
              // since the profile already determines the full permission
              // set (research.md §7). Built by a method rather than inline
              // so `hasActiveUserProfilesProvider` — a real network call —
              // is only ever watched when this branch actually renders,
              // never on every build of an edit-mode/non-administrator
              // screen.
              if (!_isEdit && isAdministrator) ...[
                _buildProfilePicker(controller, formState, fieldsEnabled, l10n),
                const SizedBox(height: 12),
              ],
              SwitchListTile(
                key: const Key('administrator_switch'),
                title: Text(l10n.administratorLabel),
                value: formState.administrator,
                onChanged: fieldsEnabled
                    ? controller.administratorChanged
                    : null,
              ),
              EntityStatusFormField(
                value: formState.status,
                onChanged: fieldsEnabled ? controller.statusChanged : null,
              ),
              // Provenance only, both edit and view mode — never implies
              // the account's current permissions still match this profile
              // (024-user-profiles FR-029, FR-030).
              if (_isEdit && formState.profileName.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.userProvisionedFromLabel(formState.profileName),
                  key: const Key('user_provisioned_from_label'),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              // Hidden while a profile is selected on create: the profile
              // already is the account's permission set, so showing the
              // grid beside it would wrongly imply the two combine.
              if (_isEdit || formState.profileId == null) ...[
                const SizedBox(height: 16),
                const Divider(key: Key('permissions_divider')),
                const SizedBox(height: 16),
                Text(
                  l10n.permissionsLabel,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                PrivilegesGrid(
                  key: const Key('privileges_grid'),
                  privileges: formState.privileges,
                  onChanged: fieldsEnabled
                      ? controller.privilegeChanged
                      : null,
                ),
              ],
              const SizedBox(height: 24),
              if (_isEdit && canUpdate && !widget.forceReadOnly) ...[
                OutlinedButton.icon(
                  key: const Key('recover_password_button'),
                  icon: const Icon(Icons.lock_reset),
                  label: Text(l10n.recoverPasswordTooltip),
                  onPressed: formState.submitting
                      ? null
                      : () => controller.recoverPassword(widget.userId!),
                ),
                const SizedBox(height: 12),
              ],
              // Edit mode only, administrator-only, never in view mode or
              // on a not-yet-created account (024-user-profiles FR-019,
              // FR-025).
              if (_isEdit && isAdministrator && !widget.forceReadOnly) ...[
                OutlinedButton.icon(
                  key: const Key('apply_profile_button'),
                  icon: const Icon(Icons.badge_outlined),
                  label: Text(l10n.applyProfileButtonLabel),
                  onPressed: formState.submitting
                      ? null
                      : () => showApplyProfileDialog(
                          context,
                          userId: widget.userId!,
                          isSelf: signedInUserId == widget.userId,
                        ),
                ),
                const SizedBox(height: 12),
              ],
              RecordFormActions(
                mode: mode,
                saveLabel: l10n.saveButton,
                editLabel: l10n.editRecordTooltip,
                deleteLabel: l10n.deleteUserTooltip,
                isSubmitting: formState.submitting,
                editKey: const Key('edit_user_button'),
                saveKey: const Key('save_button'),
                deleteKey: const Key('delete_user_button'),
                onEdit: (canUpdate && widget.userId != null)
                    ? () => context.replace('/users/${widget.userId}')
                    : null,
                onSave: (canUpdate && !widget.forceReadOnly)
                    ? () => _submit(controller)
                    : null,
                onDelete: canDelete
                    ? () => controller.deleteUser(widget.userId!)
                    : null,
                deleteConfirmation: RecordDeleteConfirmation(
                  title: l10n.deleteUserConfirmTitle,
                  // `RecordFormActions` builds this eagerly regardless of
                  // mode (it's only ever *shown* when `onDelete` is
                  // non-null, i.e. an existing user), so this must not
                  // force-unwrap a null `widget.userId` in create mode.
                  message: l10n.deleteUserConfirmMessage(widget.userId ?? ''),
                  confirmLabel: l10n.deleteButton,
                  cancelLabel: l10n.cancelButton,
                  confirmKey: const Key('confirm_delete_button'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit(UserFormController controller) {
    if (_formKey.currentState?.validate() ?? false) {
      controller.save(existingUserId: widget.userId);
    }
  }

  /// The create-mode profile choice (024-user-profiles FR-016), or a
  /// "no profiles yet" message when the active catalog is empty (US2
  /// scenario 14). Only ever called from the `!_isEdit && isAdministrator`
  /// branch in [build], so `hasActiveUserProfilesProvider` — a real fetch —
  /// is watched only when this field is actually on screen.
  Widget _buildProfilePicker(
    UserFormController controller,
    UserFormState formState,
    bool fieldsEnabled,
    AppLocalizations l10n,
  ) {
    final hasProfilesAsync = ref.watch(hasActiveUserProfilesProvider);
    if (hasProfilesAsync.valueOrNull == false) {
      return Text(
        l10n.noUserProfilesYetMessage,
        key: const Key('no_user_profiles_yet_on_create'),
      );
    }
    final userProfileRepo = ref.read(userProfileRepositoryProvider);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: CatalogEntityPicker<UserProfileSummary>(
            key: const Key('user_profile_picker'),
            label: l10n.userProfilePickerLabel,
            displayStringForOption: (p) => p.name,
            optionsBuilder: (query) async {
              final result = await userProfileRepo.list(
                search: query.isEmpty ? null : query,
                status: EntityStatus.active,
              );
              return result.items;
            },
            onSelected: (p) =>
                controller.profileSelected(p.userProfileId, p.name),
            initialDisplayText: formState.profileName,
            enabled: fieldsEnabled,
          ),
        ),
        if (formState.profileId != null)
          IconButton(
            key: const Key('clear_user_profile_button'),
            icon: const Icon(Icons.clear),
            tooltip: l10n.cancelButton,
            onPressed: fieldsEnabled
                ? () => controller.profileSelected(null, '')
                : null,
          ),
      ],
    );
  }
}

class _RecoveryTokenCard extends StatelessWidget {
  const _RecoveryTokenCard({
    required this.token,
    required this.expiresAt,
    required this.onDismiss,
  });

  final String token;
  final String expiresAt;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.key),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.recoveryTokenTitle,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Spacer(),
                IconButton(
                  key: const Key('dismiss_recovery_button'),
                  icon: const Icon(Icons.close),
                  onPressed: onDismiss,
                ),
              ],
            ),
            const SizedBox(height: 8),
            SelectableText(token, style: Theme.of(context).typeRoles.recordId),
            const SizedBox(height: 4),
            Text(
              AppLocalizations.of(context)!.recoveryExpiresAt(expiresAt),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// Localizes a [UserFormErrorCode] for [UserFormState.error]. Falls back to
/// the raw value for a [ValidationError]'s server-provided message, which
/// is stored directly in `error` instead of being one of these codes.
String _localizeFormError(AppLocalizations l10n, String code) {
  switch (code) {
    case UserFormErrorCode.emailRequired:
      return l10n.userEmailRequiredError;
    case UserFormErrorCode.usernameRequired:
      return l10n.userUsernameRequiredError;
    case UserFormErrorCode.employeeRequired:
      return l10n.userEmployeeRequiredError;
    case UserFormErrorCode.passwordLength:
      return l10n.userPasswordLengthError;
    case UserFormErrorCode.loadFailed:
      return l10n.userLoadFailedError;
    case UserFormErrorCode.saveFailed:
      return l10n.userSaveFailedError;
    case UserFormErrorCode.deleteFailed:
      return l10n.userDeleteFailedError;
    case UserFormErrorCode.recoveryFailed:
      return l10n.userRecoveryFailedError;
    default:
      return code;
  }
}
