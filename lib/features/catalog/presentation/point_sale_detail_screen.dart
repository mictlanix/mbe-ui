import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/catalog_action_icons.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/entity_status_controls.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/responsive_form_grid.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/facility_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';
import 'package:mbe_ui/features/catalog/presentation/point_sale_form_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Create / view / edit screen for a single point of sale (FR-019, FR-020,
/// FR-021, FR-022, US3). [pointSaleId] is `null` in create mode.
class PointSaleDetailScreen extends ConsumerStatefulWidget {
  const PointSaleDetailScreen({
    super.key,
    this.pointSaleId,
    this.forceReadOnly = false,
  });

  final int? pointSaleId;

  /// Forces read-only rendering — set when navigated to via a row click
  /// rather than Edit (constitution §VI), read from the `?view=true` query
  /// parameter.
  final bool forceReadOnly;

  @override
  ConsumerState<PointSaleDetailScreen> createState() =>
      _PointSaleDetailScreenState();
}

class _PointSaleDetailScreenState extends ConsumerState<PointSaleDetailScreen> {
  bool get _isEdit => widget.pointSaleId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(pointSaleFormControllerProvider.notifier)
            .loadForEdit(widget.pointSaleId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(pointSaleFormControllerProvider);
    final controller = ref.read(pointSaleFormControllerProvider.notifier);
    final access = ref.watch(accessControlProvider);
    final canCreate = access.can(
      SystemObject.pointsOfSale,
      AccessRight.create,
    );
    final canUpdate = access.can(
      SystemObject.pointsOfSale,
      AccessRight.update,
    );
    final readOnly = (_isEdit && !canUpdate) || widget.forceReadOnly;
    final l10n = AppLocalizations.of(context)!;
    final facilityRepo = ref.read(facilityRepositoryProvider);
    final warehouseRepo = ref.read(warehouseRepositoryProvider);

    final title = readOnly
        ? l10n.viewPointSaleTitle
        : (_isEdit ? l10n.editPointSaleTitle : l10n.newPointSaleTitle);

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
        access.can(SystemObject.pointsOfSale, AccessRight.delete);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (readOnly && canUpdate && widget.pointSaleId != null)
            IconButton(
              key: const Key('edit_point_sale_button'),
              icon: Icon(CatalogAction.edit.icon),
              tooltip: l10n.editRecordTooltip,
              onPressed: () =>
                  context.replace('/points-of-sale/${widget.pointSaleId}'),
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
              // FR-022: scoped to the selected facility — only that
              // facility's warehouses are offered, so a mismatched pairing
              // cannot be built through this picker.
              CatalogEntityPicker<Warehouse>(
                key: const Key('warehouse_field'),
                label: l10n.warehouseFieldLabel,
                displayStringForOption: (w) => w.name,
                optionsBuilder: (query) async {
                  final result = await warehouseRepo.list(
                    search: query.isEmpty ? null : query,
                    facilityId: formState.facilityId,
                  );
                  return result.items;
                },
                onSelected: (w) =>
                    controller.warehouseSelected(w.warehouseId, w.name),
                initialDisplayText: formState.warehouseDisplayText,
                errorText: _localizeFieldError(
                  l10n,
                  formState.fieldErrors['warehouse'],
                ),
                enabled: fieldsEnabled && formState.facilityId != null,
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
                  key: const Key('delete_point_sale_button'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  ),
                  onPressed: formState.submitting
                      ? null
                      : () =>
                            _confirmDelete(context, controller, formState.name),
                  child: Text(l10n.deletePointSaleButton),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    PointSaleFormController controller,
    String name,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deletePointSaleConfirmTitle),
        content: Text(l10n.deletePointSaleConfirmMessage(name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancelButton),
          ),
          FilledButton(
            key: const Key('confirm_delete_point_sale_button'),
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
    case PointSaleFormErrorCode.loadFailed:
      return l10n.pointSaleLoadFailedError;
    case PointSaleFormErrorCode.createFailed:
      return l10n.pointSaleCreateFailedError;
    case PointSaleFormErrorCode.updateFailed:
      return l10n.pointSaleUpdateFailedError;
    case PointSaleFormErrorCode.deleteFailed:
      return l10n.pointSaleDeleteFailedError;
    case PointSaleFormErrorCode.createPermissionDenied:
      return l10n.pointSaleCreatePermissionDeniedError;
    case PointSaleFormErrorCode.updatePermissionDenied:
      return l10n.pointSaleUpdatePermissionDeniedError;
    case PointSaleFormErrorCode.deletePermissionDenied:
      return l10n.pointSaleDeletePermissionDeniedError;
    default:
      return code;
  }
}

String? _localizeFieldError(AppLocalizations l10n, String? code) {
  if (code == null) return null;
  switch (code) {
    case PointSaleFormErrorCode.facilityRequired:
      return l10n.pointSaleFacilityRequiredError;
    case PointSaleFormErrorCode.codeRequired:
      return l10n.pointSaleCodeRequiredError;
    case PointSaleFormErrorCode.nameRequired:
      return l10n.pointSaleNameRequiredError;
    case PointSaleFormErrorCode.warehouseRequired:
      return l10n.pointSaleWarehouseRequiredError;
    default:
      return code;
  }
}
