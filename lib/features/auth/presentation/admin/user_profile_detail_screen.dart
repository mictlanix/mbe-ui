import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/entity_status_controls.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/record_form_actions.dart';
import 'package:mbe_ui/features/auth/presentation/admin/privileges_grid.dart';
import 'package:mbe_ui/features/auth/presentation/admin/user_profiles_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Create / edit screen for a single user profile (024-user-profiles
/// FR-005–FR-008, contracts/user-profile-screens.md §2). [profileId] is null
/// in create mode; non-null in edit mode. Mirrors `UserDetailScreen`
/// structurally, reusing `PrivilegesGrid` unmodified for the permission mask.
class UserProfileDetailScreen extends ConsumerStatefulWidget {
  const UserProfileDetailScreen({
    super.key,
    this.profileId,
    this.forceReadOnly = false,
  });

  final int? profileId;

  /// Forces read-only rendering regardless of administrator access — set
  /// when navigated to via the whole-row tap rather than the Edit row
  /// action, read from the `?view=true` query parameter, mirroring
  /// `UserDetailScreen.forceReadOnly`.
  final bool forceReadOnly;

  @override
  ConsumerState<UserProfileDetailScreen> createState() =>
      _UserProfileDetailScreenState();
}

class _UserProfileDetailScreenState
    extends ConsumerState<UserProfileDetailScreen> {
  final _formKey = GlobalKey<FormState>();

  bool get _isEdit => widget.profileId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      // Load after the first frame so the provider is already mounted.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(userProfileFormControllerProvider.notifier)
            .loadProfile(widget.profileId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(userProfileFormControllerProvider);
    final controller = ref.read(userProfileFormControllerProvider.notifier);
    final readOnly = widget.forceReadOnly;
    final fieldsEnabled = !formState.submitting && !readOnly;
    final l10n = AppLocalizations.of(context)!;
    final title = readOnly
        ? l10n.viewUserProfileTitle
        : (_isEdit ? l10n.editUserProfileTitle : l10n.newUserProfileTitle);

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
                    // The server's own message (e.g. a delete conflict
                    // naming how many users reference this profile) can't
                    // be localized client-side, so it's shown as
                    // supplementary detail under the localized heading
                    // above (same convention as UserDetailScreen).
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
              TextFormField(
                key: const Key('user_profile_name_field'),
                initialValue: formState.name,
                decoration: InputDecoration(
                  labelText: l10n.userProfileNameFieldLabel,
                ),
                enabled: fieldsEnabled,
                onChanged: controller.nameChanged,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? l10n.userProfileNameRequiredError
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('user_profile_description_field'),
                initialValue: formState.description,
                decoration: InputDecoration(
                  labelText: l10n.userProfileDescriptionFieldLabel,
                ),
                enabled: fieldsEnabled,
                maxLines: 3,
                onChanged: controller.descriptionChanged,
              ),
              const SizedBox(height: 12),
              EntityStatusFormField(
                value: formState.status,
                onChanged: fieldsEnabled ? controller.statusChanged : null,
              ),
              const SizedBox(height: 16),
              const Divider(key: Key('user_profile_permissions_divider')),
              const SizedBox(height: 16),
              Text(
                l10n.permissionsLabel,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              PrivilegesGrid(
                key: const Key('privileges_table'),
                privileges: formState.privileges,
                onChanged: fieldsEnabled ? controller.privilegeChanged : null,
              ),
              const SizedBox(height: 24),
              RecordFormActions(
                mode: mode,
                saveLabel: l10n.saveButton,
                editLabel: l10n.editRecordTooltip,
                deleteLabel: l10n.deleteUserProfileTooltip,
                isSubmitting: formState.submitting,
                editKey: const Key('edit_user_profile_button'),
                saveKey: const Key('save_user_profile_button'),
                deleteKey: const Key('delete_user_profile_button'),
                onEdit: widget.profileId != null
                    ? () => context.replace('/user-profiles/${widget.profileId}')
                    : null,
                onSave: !readOnly ? () => _submit(controller) : null,
                onDelete: (_isEdit && !readOnly)
                    ? () => controller.deleteProfile(widget.profileId!)
                    : null,
                deleteConfirmation: RecordDeleteConfirmation(
                  title: l10n.deleteUserProfileConfirmTitle,
                  // `RecordFormActions` builds this eagerly regardless of
                  // mode (only ever *shown* when `onDelete` is non-null,
                  // i.e. an existing profile), so `formState.name` — never
                  // null — is safe here even in create mode.
                  message: l10n.deleteUserProfileConfirmMessage(
                    formState.name,
                  ),
                  confirmLabel: l10n.deleteButton,
                  cancelLabel: l10n.cancelButton,
                  confirmKey: const Key('confirm_delete_user_profile'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit(UserProfileFormController controller) {
    if (_formKey.currentState?.validate() ?? false) {
      controller.save(existingProfileId: widget.profileId);
    }
  }
}

/// Localizes a [UserProfileFormErrorCode] for [UserProfileFormState.error].
/// Falls back to the raw value for a `ValidationError`'s server-provided
/// message, which is stored directly in `error` instead of being one of
/// these codes (mirrors `_localizeFormError` in `user_detail_screen.dart`).
String _localizeFormError(AppLocalizations l10n, String code) {
  switch (code) {
    case UserProfileFormErrorCode.nameRequired:
      return l10n.userProfileNameRequiredError;
    case UserProfileFormErrorCode.loadFailed:
      return l10n.userProfileLoadFailedError;
    case UserProfileFormErrorCode.saveFailed:
      return l10n.userProfileSaveFailedError;
    case UserProfileFormErrorCode.deleteFailed:
      return l10n.userProfileDeleteFailedError;
    default:
      return code;
  }
}
