import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/catalog_action_icons.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/features/auth/presentation/admin/privileges_grid.dart';
import 'package:mbe_ui/features/auth/presentation/admin/users_controller.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (readOnly && canUpdate && widget.userId != null)
            IconButton(
              key: const Key('edit_user_button'),
              icon: Icon(CatalogAction.edit.icon),
              tooltip: l10n.editRecordTooltip,
              onPressed: () => context.replace('/users/${widget.userId}'),
            ),
        ],
      ),
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
              SwitchListTile(
                key: const Key('administrator_switch'),
                title: Text(l10n.administratorLabel),
                value: formState.administrator,
                onChanged: fieldsEnabled
                    ? controller.administratorChanged
                    : null,
              ),
              SwitchListTile(
                key: const Key('disabled_switch'),
                title: Text(l10n.disabledLabel),
                value: formState.disabled,
                onChanged: fieldsEnabled ? controller.disabledChanged : null,
              ),
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
                onChanged: fieldsEnabled ? controller.privilegeChanged : null,
              ),
              const SizedBox(height: 24),
              if (canUpdate && !widget.forceReadOnly)
                FilledButton(
                  key: const Key('save_button'),
                  onPressed: formState.submitting
                      ? null
                      : () => _submit(controller),
                  child: formState.submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.saveButton),
                ),
              if (_isEdit && canUpdate && !widget.forceReadOnly) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  key: const Key('recover_password_button'),
                  icon: const Icon(Icons.lock_reset),
                  label: Text(l10n.recoverPasswordTooltip),
                  onPressed: formState.submitting
                      ? null
                      : () => controller.recoverPassword(widget.userId!),
                ),
              ],
              if (canDelete) ...[
                const SizedBox(height: 12),
                FilledButton(
                  key: const Key('delete_user_button'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  ),
                  onPressed: formState.submitting
                      ? null
                      : () => _confirmDelete(context, controller),
                  child: Text(l10n.deleteUserTooltip),
                ),
              ],
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

  Future<void> _confirmDelete(
    BuildContext context,
    UserFormController controller,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteUserConfirmTitle),
        content: Text(l10n.deleteUserConfirmMessage(widget.userId!)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancelButton),
          ),
          FilledButton(
            key: const Key('confirm_delete_button'),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.deleteButton),
          ),
        ],
      ),
    );
    if (confirmed == true) controller.deleteUser(widget.userId!);
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
            SelectableText(
              token,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontFamily: 'monospace'),
            ),
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
