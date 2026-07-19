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
import 'package:mbe_ui/features/catalog/presentation/supplier_form_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Create / view / edit screen for a single supplier (FR-010, FR-011, US1).
/// [supplierId] is `null` in create mode.
class SupplierDetailScreen extends ConsumerStatefulWidget {
  const SupplierDetailScreen({
    super.key,
    this.supplierId,
    this.forceReadOnly = false,
  });

  final int? supplierId;

  /// Forces read-only rendering — set when navigated to via a row click
  /// rather than Edit (constitution §VI), read from the `?view=true` query
  /// parameter.
  final bool forceReadOnly;

  @override
  ConsumerState<SupplierDetailScreen> createState() =>
      _SupplierDetailScreenState();
}

class _SupplierDetailScreenState extends ConsumerState<SupplierDetailScreen> {
  bool get _isEdit => widget.supplierId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(supplierFormControllerProvider.notifier)
            .loadForEdit(widget.supplierId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(supplierFormControllerProvider);
    final controller = ref.read(supplierFormControllerProvider.notifier);
    final access = ref.watch(accessControlProvider);
    final canCreate = access.can(SystemObject.suppliers, AccessRight.create);
    final canUpdate = access.can(SystemObject.suppliers, AccessRight.update);
    final readOnly = (_isEdit && !canUpdate) || widget.forceReadOnly;
    final l10n = AppLocalizations.of(context)!;

    final title = readOnly
        ? l10n.viewSupplierTitle
        : (_isEdit ? l10n.editSupplierTitle : l10n.newSupplierTitle);

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
        access.can(SystemObject.suppliers, AccessRight.delete);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (readOnly && canUpdate && widget.supplierId != null)
            IconButton(
              key: const Key('edit_supplier_button'),
              icon: Icon(CatalogAction.edit.icon),
              tooltip: l10n.editRecordTooltip,
              onPressed: () =>
                  context.replace('/suppliers/${widget.supplierId}'),
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
              TextFormField(
                key: const Key('code_field'),
                initialValue: formState.code,
                decoration: InputDecoration(
                  labelText: l10n.codeLabel,
                  errorText: _localizeFieldError(
                    l10n,
                    formState.fieldErrors['code'],
                  ),
                ),
                enabled: fieldsEnabled,
                onChanged: controller.codeChanged,
              ),
            ),
            FormGridChild(
              TextFormField(
                key: const Key('name_field'),
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
              TextFormField(
                key: const Key('zone_field'),
                initialValue: formState.zone,
                decoration: InputDecoration(labelText: l10n.zoneLabel),
                enabled: fieldsEnabled,
                onChanged: controller.zoneChanged,
              ),
            ),
            FormGridChild(
              TextFormField(
                key: const Key('credit_limit_field'),
                initialValue: formState.creditLimit,
                decoration: InputDecoration(
                  labelText: l10n.creditLimitLabel,
                  errorText: _localizeFieldError(
                    l10n,
                    formState.fieldErrors['creditLimit'] ??
                        formState.fieldErrors['credit_limit'],
                  ),
                ),
                enabled: fieldsEnabled,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: controller.creditLimitChanged,
              ),
            ),
            FormGridChild(
              TextFormField(
                key: const Key('credit_days_field'),
                initialValue: formState.creditDays,
                decoration: InputDecoration(
                  labelText: l10n.creditDaysLabel,
                  errorText: _localizeFieldError(
                    l10n,
                    formState.fieldErrors['creditDays'] ??
                        formState.fieldErrors['credit_days'],
                  ),
                ),
                enabled: fieldsEnabled,
                keyboardType: TextInputType.number,
                onChanged: controller.creditDaysChanged,
              ),
            ),
            FormGridChild(
              span: FormGridSpan.full,
              TextFormField(
                key: const Key('comment_field'),
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
                  key: const Key('delete_supplier_button'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  ),
                  onPressed: formState.submitting
                      ? null
                      : () =>
                            _confirmDelete(context, controller, formState.name),
                  child: Text(l10n.deleteSupplierButton),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    SupplierFormController controller,
    String name,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteSupplierConfirmTitle),
        content: Text(l10n.deleteSupplierConfirmMessage(name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancelButton),
          ),
          FilledButton(
            key: const Key('confirm_delete_supplier_button'),
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
    case SupplierFormErrorCode.loadFailed:
      return l10n.supplierLoadFailedError;
    case SupplierFormErrorCode.createFailed:
      return l10n.supplierCreateFailedError;
    case SupplierFormErrorCode.updateFailed:
      return l10n.supplierUpdateFailedError;
    case SupplierFormErrorCode.deleteFailed:
      return l10n.supplierDeleteFailedError;
    case SupplierFormErrorCode.createPermissionDenied:
      return l10n.supplierCreatePermissionDeniedError;
    case SupplierFormErrorCode.updatePermissionDenied:
      return l10n.supplierUpdatePermissionDeniedError;
    case SupplierFormErrorCode.deletePermissionDenied:
      return l10n.supplierDeletePermissionDeniedError;
    default:
      return code;
  }
}

String? _localizeFieldError(AppLocalizations l10n, String? code) {
  if (code == null) return null;
  switch (code) {
    case SupplierFormErrorCode.codeRequired:
      return l10n.supplierCodeRequiredError;
    case SupplierFormErrorCode.nameRequired:
      return l10n.supplierNameRequiredError;
    case SupplierFormErrorCode.creditLimitInvalid:
      return l10n.creditLimitInvalidError;
    case SupplierFormErrorCode.creditDaysInvalid:
      return l10n.creditDaysInvalidError;
    default:
      return code;
  }
}
