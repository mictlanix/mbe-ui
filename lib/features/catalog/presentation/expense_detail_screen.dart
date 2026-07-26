import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/record_form_actions.dart';
import 'package:mbe_ui/core/widgets/responsive_form_grid.dart';
import 'package:mbe_ui/features/catalog/presentation/expense_form_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Create / view / edit screen for a single expense (FR-010, FR-011, US1).
/// [expenseId] is `null` in create mode.
class ExpenseDetailScreen extends ConsumerStatefulWidget {
  const ExpenseDetailScreen({
    super.key,
    this.expenseId,
    this.forceReadOnly = false,
  });

  final int? expenseId;

  /// Forces read-only rendering — set when navigated to via a row click
  /// rather than Edit (constitution §VI), read from the `?view=true` query
  /// parameter.
  final bool forceReadOnly;

  @override
  ConsumerState<ExpenseDetailScreen> createState() =>
      _ExpenseDetailScreenState();
}

class _ExpenseDetailScreenState extends ConsumerState<ExpenseDetailScreen> {
  bool get _isEdit => widget.expenseId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(expenseFormControllerProvider.notifier)
            .loadForEdit(widget.expenseId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(expenseFormControllerProvider);
    final controller = ref.read(expenseFormControllerProvider.notifier);
    final access = ref.watch(accessControlProvider);
    final canCreate = access.can(SystemObject.expenses, AccessRight.create);
    final canUpdate = access.can(SystemObject.expenses, AccessRight.update);
    final readOnly = (_isEdit && !canUpdate) || widget.forceReadOnly;
    final l10n = AppLocalizations.of(context)!;

    final title = readOnly
        ? l10n.viewExpenseTitle
        : (_isEdit ? l10n.editExpenseTitle : l10n.newExpenseTitle);

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
        access.can(SystemObject.expenses, AccessRight.delete);

    final mode = !_isEdit
        ? RecordFormMode.create
        : (readOnly ? RecordFormMode.view : RecordFormMode.edit);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
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
                key: const Key('expense_name_field'),
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
                key: const Key('expense_comment_field'),
                initialValue: formState.comment,
                decoration: InputDecoration(labelText: l10n.commentLabel),
                enabled: fieldsEnabled,
                onChanged: controller.commentChanged,
                maxLines: 3,
              ),
            ),
            FormGridChild(
              span: FormGridSpan.full,
              RecordFormActions(
                mode: mode,
                saveLabel: l10n.saveButton,
                editLabel: l10n.editRecordTooltip,
                deleteLabel: l10n.deleteExpenseButton,
                isSubmitting: formState.submitting,
                editKey: const Key('edit_expense_button'),
                saveKey: const Key('save_button'),
                deleteKey: const Key('delete_expense_button'),
                onEdit: (canUpdate && widget.expenseId != null)
                    ? () => context.replace('/expenses/${widget.expenseId}')
                    : null,
                onSave: canSave
                    ? (_isEdit
                          ? controller.submitUpdate
                          : controller.submitCreate)
                    : null,
                onDelete: canDelete ? controller.delete : null,
                deleteConfirmation: RecordDeleteConfirmation(
                  title: l10n.deleteExpenseConfirmTitle,
                  message: l10n.deleteExpenseConfirmMessage(formState.name),
                  confirmLabel: l10n.deleteButton,
                  cancelLabel: l10n.cancelButton,
                  confirmKey: const Key('confirm_delete_expense_button'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _localizeFormError(AppLocalizations l10n, String code) {
  switch (code) {
    case ExpenseFormErrorCode.loadFailed:
      return l10n.expenseLoadFailedError;
    case ExpenseFormErrorCode.createFailed:
      return l10n.expenseCreateFailedError;
    case ExpenseFormErrorCode.updateFailed:
      return l10n.expenseUpdateFailedError;
    case ExpenseFormErrorCode.deleteFailed:
      return l10n.expenseDeleteFailedError;
    case ExpenseFormErrorCode.createPermissionDenied:
      return l10n.expenseCreatePermissionDeniedError;
    case ExpenseFormErrorCode.updatePermissionDenied:
      return l10n.expenseUpdatePermissionDeniedError;
    case ExpenseFormErrorCode.deletePermissionDenied:
      return l10n.expenseDeletePermissionDeniedError;
    default:
      return code;
  }
}

String? _localizeFieldError(AppLocalizations l10n, String? code) {
  if (code == null) return null;
  switch (code) {
    case ExpenseFormErrorCode.nameRequired:
      return l10n.expenseNameRequiredError;
    default:
      return code;
  }
}
