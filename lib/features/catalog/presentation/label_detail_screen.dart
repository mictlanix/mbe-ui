import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/catalog_action_icons.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/responsive_form_grid.dart';
import 'package:mbe_ui/features/catalog/presentation/label_form_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Create / view / edit screen for a single label (FR-012, FR-013, US2).
/// [labelId] is `null` in create mode.
class LabelDetailScreen extends ConsumerStatefulWidget {
  const LabelDetailScreen({
    super.key,
    this.labelId,
    this.forceReadOnly = false,
  });

  final int? labelId;

  /// Forces read-only rendering — set when navigated to via a row click
  /// rather than Edit (constitution §VI), read from the `?view=true` query
  /// parameter.
  final bool forceReadOnly;

  @override
  ConsumerState<LabelDetailScreen> createState() => _LabelDetailScreenState();
}

class _LabelDetailScreenState extends ConsumerState<LabelDetailScreen> {
  bool get _isEdit => widget.labelId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(labelFormControllerProvider.notifier)
            .loadForEdit(widget.labelId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(labelFormControllerProvider);
    final controller = ref.read(labelFormControllerProvider.notifier);
    final access = ref.watch(accessControlProvider);
    final canCreate = access.can(SystemObject.labels, AccessRight.create);
    final canUpdate = access.can(SystemObject.labels, AccessRight.update);
    final readOnly = (_isEdit && !canUpdate) || widget.forceReadOnly;
    final l10n = AppLocalizations.of(context)!;

    final title = readOnly
        ? l10n.viewLabelTitle
        : (_isEdit ? l10n.editLabelTitle : l10n.newLabelTitle);

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

    final fieldsEnabled = !formState.submitting && !readOnly;
    final canSave = !widget.forceReadOnly && (_isEdit ? canUpdate : canCreate);
    final canDelete =
        _isEdit &&
        !readOnly &&
        access.can(SystemObject.labels, AccessRight.delete);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (readOnly && canUpdate && widget.labelId != null)
            IconButton(
              key: const Key('edit_label_button'),
              icon: Icon(CatalogAction.edit.icon),
              tooltip: l10n.editRecordTooltip,
              onPressed: () => context.replace('/labels/${widget.labelId}'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ResponsiveFormGrid(
          maxColumns: 2,
          children: [
            if (formState.error != null)
              FormGridChild(
                span: FormGridSpan.full,
                ErrorBanner(
                  error: AppError.validation([
                    FieldError(
                      loc: const [],
                      msg: _localizeFormError(l10n, formState.error!),
                      type: 'error',
                    ),
                    if (formState.errorDetail != null)
                      FieldError(
                        loc: const [],
                        msg: formState.errorDetail!,
                        type: 'error',
                      ),
                  ]),
                ),
              ),
            FormGridChild(
              span: FormGridSpan.full,
              TextFormField(
                key: const Key('label_name_field'),
                initialValue: formState.name,
                decoration: InputDecoration(
                  labelText: l10n.nameLabel,
                  errorText: _localizeFieldError(
                    l10n,
                    formState.fieldErrors['name'],
                  ),
                ),
                enabled: fieldsEnabled,
                onChanged: controller.nameChanged,
              ),
            ),
            FormGridChild(
              span: FormGridSpan.full,
              TextFormField(
                key: const Key('label_comment_field'),
                initialValue: formState.comment,
                decoration: InputDecoration(labelText: l10n.commentLabel),
                enabled: fieldsEnabled,
                onChanged: controller.commentChanged,
                maxLines: 3,
              ),
            ),
            if (canSave)
              FormGridChild(
                span: FormGridSpan.full,
                FilledButton(
                  key: const Key('save_button'),
                  onPressed: formState.submitting
                      ? null
                      : (_isEdit
                            ? controller.submitUpdate
                            : controller.submitCreate),
                  child: formState.submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.saveButton),
                ),
              ),
            if (canDelete)
              FormGridChild(
                span: FormGridSpan.full,
                FilledButton(
                  key: const Key('delete_label_button'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  ),
                  onPressed: formState.submitting
                      ? null
                      : () =>
                            _confirmDelete(context, controller, formState.name),
                  child: Text(l10n.deleteLabelButton),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    LabelFormController controller,
    String name,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteLabelConfirmTitle),
        content: Text(l10n.deleteLabelConfirmMessage(name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancelButton),
          ),
          FilledButton(
            key: const Key('confirm_delete_label_button'),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.deleteButton),
          ),
        ],
      ),
    );
    if (confirmed == true) controller.delete();
  }
}

String _localizeFormError(AppLocalizations l10n, String code) {
  switch (code) {
    case LabelFormErrorCode.loadFailed:
      return l10n.labelLoadFailedError;
    case LabelFormErrorCode.createFailed:
      return l10n.labelCreateFailedError;
    case LabelFormErrorCode.updateFailed:
      return l10n.labelUpdateFailedError;
    case LabelFormErrorCode.deleteFailed:
      return l10n.labelDeleteFailedError;
    case LabelFormErrorCode.createPermissionDenied:
      return l10n.labelCreatePermissionDeniedError;
    case LabelFormErrorCode.updatePermissionDenied:
      return l10n.labelUpdatePermissionDeniedError;
    case LabelFormErrorCode.deletePermissionDenied:
      return l10n.labelDeletePermissionDeniedError;
    default:
      return code;
  }
}

String? _localizeFieldError(AppLocalizations l10n, String? code) {
  if (code == null) return null;
  switch (code) {
    case LabelFormErrorCode.nameRequired:
      return l10n.labelNameRequiredError;
    default:
      return code;
  }
}
