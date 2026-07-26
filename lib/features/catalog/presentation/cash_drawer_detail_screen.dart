import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/record_form_actions.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/entity_status_controls.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/responsive_form_grid.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/facility_list_item.dart';
import 'package:mbe_ui/features/catalog/presentation/cash_drawer_form_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Create / view / edit screen for a single cash drawer (FR-016, FR-017,
/// FR-015, US2). [cashDrawerId] is `null` in create mode.
class CashDrawerDetailScreen extends ConsumerStatefulWidget {
  const CashDrawerDetailScreen({
    super.key,
    this.cashDrawerId,
    this.forceReadOnly = false,
  });

  final int? cashDrawerId;

  /// Forces read-only rendering — set when navigated to via a row click
  /// rather than Edit (constitution §VI), read from the `?view=true` query
  /// parameter.
  final bool forceReadOnly;

  @override
  ConsumerState<CashDrawerDetailScreen> createState() =>
      _CashDrawerDetailScreenState();
}

class _CashDrawerDetailScreenState
    extends ConsumerState<CashDrawerDetailScreen> {
  bool get _isEdit => widget.cashDrawerId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(cashDrawerFormControllerProvider.notifier)
            .loadForEdit(widget.cashDrawerId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(cashDrawerFormControllerProvider);
    final controller = ref.read(cashDrawerFormControllerProvider.notifier);
    final access = ref.watch(accessControlProvider);
    final canCreate = access.can(SystemObject.cashDrawers, AccessRight.create);
    final canUpdate = access.can(SystemObject.cashDrawers, AccessRight.update);
    final readOnly = (_isEdit && !canUpdate) || widget.forceReadOnly;
    final l10n = AppLocalizations.of(context)!;
    final facilityRepo = ref.read(facilityRepositoryProvider);

    final title = readOnly
        ? l10n.viewCashDrawerTitle
        : (_isEdit ? l10n.editCashDrawerTitle : l10n.newCashDrawerTitle);

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
        access.can(SystemObject.cashDrawers, AccessRight.delete);

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
              CatalogEntityPicker<FacilityListItem>(
                key: const Key('facility_field'),
                label: l10n.facilityFieldLabel,
                displayStringForOption: (f) => f.name,
                optionsBuilder: (query) async {
                  final result = await facilityRepo.list(
                    search: query.isEmpty ? null : query,
                  );
                  return result.items;
                },
                onSelected: (f) =>
                    controller.facilitySelected(f.facilityId, f.name),
                initialDisplayText: formState.facilityDisplayText,
                errorText: _localizeFieldError(
                  l10n,
                  formState.fieldErrors['facility'],
                ),
                enabled: fieldsEnabled,
              ),
            ),
            FormGridChild(
              TextFormField(
                key: const Key('code_field'),
                initialValue: formState.code,
                decoration: InputDecoration(
                  labelText: l10n.columnCode,
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
                  labelText: l10n.columnName,
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
                key: const Key('comment_field'),
                initialValue: formState.comment,
                decoration: InputDecoration(labelText: l10n.columnComment),
                enabled: fieldsEnabled,
                onChanged: controller.commentChanged,
                maxLines: 3,
              ),
            ),
            FormGridChild(
              span: FormGridSpan.full,
              EntityStatusFormField(
                value: formState.status,
                onChanged: fieldsEnabled ? controller.statusChanged : null,
              ),
            ),
            FormGridChild(
              span: FormGridSpan.full,
              RecordFormActions(
                mode: mode,
                saveLabel: l10n.saveButton,
                editLabel: l10n.editRecordTooltip,
                deleteLabel: l10n.deleteCashDrawerButton,
                isSubmitting: formState.submitting,
                editKey: const Key('edit_cash_drawer_button'),
                saveKey: const Key('save_button'),
                deleteKey: const Key('delete_cash_drawer_button'),
                onEdit: (canUpdate && widget.cashDrawerId != null)
                    ? () => context.replace(
                        '/cash-drawers/${widget.cashDrawerId}',
                      )
                    : null,
                onSave: canSave
                    ? (_isEdit
                          ? controller.submitUpdate
                          : controller.submitCreate)
                    : null,
                onDelete: canDelete ? controller.delete : null,
                deleteConfirmation: RecordDeleteConfirmation(
                  title: l10n.deleteCashDrawerConfirmTitle,
                  message: l10n.deleteCashDrawerConfirmMessage(formState.name),
                  confirmLabel: l10n.deleteButton,
                  cancelLabel: l10n.cancelButton,
                  confirmKey: const Key('confirm_delete_cash_drawer_button'),
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
    case CashDrawerFormErrorCode.loadFailed:
      return l10n.cashDrawerLoadFailedError;
    case CashDrawerFormErrorCode.createFailed:
      return l10n.cashDrawerCreateFailedError;
    case CashDrawerFormErrorCode.updateFailed:
      return l10n.cashDrawerUpdateFailedError;
    case CashDrawerFormErrorCode.deleteFailed:
      return l10n.cashDrawerDeleteFailedError;
    case CashDrawerFormErrorCode.createPermissionDenied:
      return l10n.cashDrawerCreatePermissionDeniedError;
    case CashDrawerFormErrorCode.updatePermissionDenied:
      return l10n.cashDrawerUpdatePermissionDeniedError;
    case CashDrawerFormErrorCode.deletePermissionDenied:
      return l10n.cashDrawerDeletePermissionDeniedError;
    default:
      return code;
  }
}

String? _localizeFieldError(AppLocalizations l10n, String? code) {
  if (code == null) return null;
  switch (code) {
    case CashDrawerFormErrorCode.facilityRequired:
      return l10n.cashDrawerFacilityRequiredError;
    case CashDrawerFormErrorCode.codeRequired:
      return l10n.cashDrawerCodeRequiredError;
    case CashDrawerFormErrorCode.nameRequired:
      return l10n.cashDrawerNameRequiredError;
    default:
      return code;
  }
}
