import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/record_form_actions.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/responsive_form_grid.dart';
import 'package:mbe_ui/features/catalog/presentation/supplier_form_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Create / view / edit form for a single supplier (spec 035 US5 —
/// converted from the pushed `/suppliers/new` / `/suppliers/:supplierId`
/// routes to the shared record panel, `showRecordSheet`). [supplierId] is
/// `null` in create mode. See `label_form.dart` for the pattern this
/// follows (spec 035 T029).
class SupplierForm extends ConsumerStatefulWidget {
  const SupplierForm({super.key, this.supplierId, this.forceReadOnly = false});

  final int? supplierId;

  /// Opens the form read-only regardless of the caller's update privilege —
  /// set for a row-click open (constitution §VI). The in-panel Edit control
  /// clears this.
  final bool forceReadOnly;

  @override
  ConsumerState<SupplierForm> createState() => SupplierFormPanelState();
}

/// Public so a caller can address it via `GlobalKey<SupplierFormPanelState>`
/// and query [isDirty] from `showRecordSheet`'s `isDirty` callback.
class SupplierFormPanelState extends ConsumerState<SupplierForm> {
  bool get _isEdit => widget.supplierId != null;

  late bool _readOnlyOverride = widget.forceReadOnly;

  /// Snapshot of [SupplierFormState] captured once loading actually
  /// completes — awaited directly in [initState], not inferred from a
  /// `build()`-timing flag (spec 035 T028: a fast-resolving repository can
  /// resolve entirely within the same microtask flush that follows
  /// `addPostFrameCallback`, so Flutter never rebuilds with `loading: true`
  /// visible at all).
  SupplierFormState? _snapshot;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await ref
            .read(supplierFormControllerProvider.notifier)
            .loadForEdit(widget.supplierId!);
        if (mounted) {
          setState(() => _snapshot = ref.read(supplierFormControllerProvider));
        }
      });
    } else {
      _snapshot = ref.read(supplierFormControllerProvider);
    }
  }

  bool isDirty() {
    final current = ref.read(supplierFormControllerProvider);
    return _snapshot != null && _snapshot != current;
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(supplierFormControllerProvider);
    final controller = ref.read(supplierFormControllerProvider.notifier);
    final access = ref.watch(accessControlProvider);
    final canCreate = access.can(SystemObject.suppliers, AccessRight.create);
    final canUpdate = access.can(SystemObject.suppliers, AccessRight.update);
    final readOnly = (_isEdit && !canUpdate) || _readOnlyOverride;
    final l10n = AppLocalizations.of(context)!;

    if (formState.loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (formState.saved || formState.deleted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
    }

    final fieldsEnabled = !formState.submitting && !readOnly;
    final canSave = !readOnly && (_isEdit ? canUpdate : canCreate);
    final canDelete =
        _isEdit &&
        !readOnly &&
        access.can(SystemObject.suppliers, AccessRight.delete);

    final mode = !_isEdit
        ? RecordFormMode.create
        : (readOnly ? RecordFormMode.view : RecordFormMode.edit);

    return ResponsiveFormGrid(
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
              errorText: _localizeFieldError(l10n, formState.fieldErrors['code']),
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
              errorText: _localizeFieldError(l10n, formState.fieldErrors['name']),
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
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
        FormGridChild(
          span: FormGridSpan.full,
          RecordFormActions(
            mode: mode,
            saveLabel: l10n.saveButton,
            editLabel: l10n.editRecordTooltip,
            deleteLabel: l10n.deleteSupplierButton,
            isSubmitting: formState.submitting,
            editKey: const Key('edit_supplier_button'),
            saveKey: const Key('save_button'),
            deleteKey: const Key('delete_supplier_button'),
            onEdit: (canUpdate && widget.supplierId != null)
                ? () => setState(() => _readOnlyOverride = false)
                : null,
            onSave: canSave
                ? (_isEdit ? controller.submitUpdate : controller.submitCreate)
                : null,
            onDelete: canDelete ? controller.delete : null,
            deleteConfirmation: RecordDeleteConfirmation(
              title: l10n.deleteSupplierConfirmTitle,
              message: l10n.deleteSupplierConfirmMessage(formState.name),
              confirmLabel: l10n.deleteButton,
              cancelLabel: l10n.cancelButton,
              confirmKey: const Key('confirm_delete_supplier_button'),
            ),
          ),
        ),
      ],
    );
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
