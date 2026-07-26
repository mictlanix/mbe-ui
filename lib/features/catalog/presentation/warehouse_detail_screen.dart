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
import 'package:mbe_ui/features/catalog/presentation/warehouse_form_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Create / view / edit screen for a single warehouse (FR-013, FR-014,
/// FR-015, US1). [warehouseId] is `null` in create mode.
class WarehouseDetailScreen extends ConsumerStatefulWidget {
  const WarehouseDetailScreen({
    super.key,
    this.warehouseId,
    this.forceReadOnly = false,
  });

  final int? warehouseId;

  /// Forces read-only rendering — set when navigated to via a row click
  /// rather than Edit (constitution §VI), read from the `?view=true` query
  /// parameter.
  final bool forceReadOnly;

  @override
  ConsumerState<WarehouseDetailScreen> createState() =>
      _WarehouseDetailScreenState();
}

class _WarehouseDetailScreenState extends ConsumerState<WarehouseDetailScreen> {
  bool get _isEdit => widget.warehouseId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(warehouseFormControllerProvider.notifier)
            .loadForEdit(widget.warehouseId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(warehouseFormControllerProvider);
    final controller = ref.read(warehouseFormControllerProvider.notifier);
    final access = ref.watch(accessControlProvider);
    final canCreate = access.can(SystemObject.warehouses, AccessRight.create);
    final canUpdate = access.can(SystemObject.warehouses, AccessRight.update);
    final readOnly = (_isEdit && !canUpdate) || widget.forceReadOnly;
    final l10n = AppLocalizations.of(context)!;
    final facilityRepo = ref.read(facilityRepositoryProvider);

    final title = readOnly
        ? l10n.viewWarehouseTitle
        : (_isEdit ? l10n.editWarehouseTitle : l10n.newWarehouseTitle);

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
        access.can(SystemObject.warehouses, AccessRight.delete);

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
                deleteLabel: l10n.deleteWarehouseButton,
                isSubmitting: formState.submitting,
                editKey: const Key('edit_warehouse_button'),
                saveKey: const Key('save_button'),
                deleteKey: const Key('delete_warehouse_button'),
                onEdit: (canUpdate && widget.warehouseId != null)
                    ? () => context.replace('/warehouses/${widget.warehouseId}')
                    : null,
                onSave: canSave
                    ? (_isEdit ? controller.submitUpdate : controller.submitCreate)
                    : null,
                onDelete: canDelete ? controller.delete : null,
                deleteConfirmation: RecordDeleteConfirmation(
                  title: l10n.deleteWarehouseConfirmTitle,
                  message: l10n.deleteWarehouseConfirmMessage(formState.name),
                  confirmLabel: l10n.deleteButton,
                  cancelLabel: l10n.cancelButton,
                  confirmKey: const Key('confirm_delete_warehouse_button'),
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
    case WarehouseFormErrorCode.loadFailed:
      return l10n.warehouseLoadFailedError;
    case WarehouseFormErrorCode.createFailed:
      return l10n.warehouseCreateFailedError;
    case WarehouseFormErrorCode.updateFailed:
      return l10n.warehouseUpdateFailedError;
    case WarehouseFormErrorCode.deleteFailed:
      return l10n.warehouseDeleteFailedError;
    case WarehouseFormErrorCode.createPermissionDenied:
      return l10n.warehouseCreatePermissionDeniedError;
    case WarehouseFormErrorCode.updatePermissionDenied:
      return l10n.warehouseUpdatePermissionDeniedError;
    case WarehouseFormErrorCode.deletePermissionDenied:
      return l10n.warehouseDeletePermissionDeniedError;
    default:
      return code;
  }
}

String? _localizeFieldError(AppLocalizations l10n, String? code) {
  if (code == null) return null;
  switch (code) {
    case WarehouseFormErrorCode.facilityRequired:
      return l10n.warehouseFacilityRequiredError;
    case WarehouseFormErrorCode.codeRequired:
      return l10n.warehouseCodeRequiredError;
    case WarehouseFormErrorCode.nameRequired:
      return l10n.warehouseNameRequiredError;
    default:
      return code;
  }
}
