import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/facility_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';
import 'package:mbe_ui/features/catalog/presentation/point_sale_form_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Create / view / edit form for a single point of sale (spec 035 US5 —
/// converted from the pushed `/points-of-sale/new` /
/// `/points-of-sale/:pointSaleId` routes to the shared record panel,
/// `showRecordSheet`). [pointSaleId] is `null` in create mode. Unlike the
/// top-level catalogs, a point of sale is a facility child reached only
/// from `FacilityCard`'s child actions in `facilities_list_screen.dart`,
/// never from its own list screen. See `label_form.dart` for the base
/// pattern (spec 035 T029).
class PointSaleForm extends ConsumerStatefulWidget {
  const PointSaleForm({
    super.key,
    this.pointSaleId,
    this.forceReadOnly = false,
    this.facilityId,
  });

  final int? pointSaleId;

  /// Opens the form read-only regardless of the caller's update privilege —
  /// set for a row-click open (constitution §VI). The in-panel Edit control
  /// clears this.
  final bool forceReadOnly;

  /// Pre-selects the facility picker in create mode — set when reached from
  /// a facility card's "+ Punto de venta" (018-nested-facility-management
  /// FR-022/FR-023). Ignored in edit mode, where [loadForEdit] supplies the
  /// real facility.
  final int? facilityId;

  @override
  ConsumerState<PointSaleForm> createState() => PointSaleFormPanelState();
}

/// Public so a caller can address it via `GlobalKey<PointSaleFormPanelState>`
/// and query [isDirty] from `showRecordSheet`'s `isDirty` callback.
class PointSaleFormPanelState extends ConsumerState<PointSaleForm> {
  bool get _isEdit => widget.pointSaleId != null;

  late bool _readOnlyOverride = widget.forceReadOnly;

  /// Snapshot of [PointSaleFormState] captured once loading actually
  /// completes — awaited directly in [initState], not inferred from a
  /// `build()`-timing flag (spec 035 T028).
  PointSaleFormState? _snapshot;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await ref
            .read(pointSaleFormControllerProvider.notifier)
            .loadForEdit(widget.pointSaleId!);
        if (mounted) {
          setState(() => _snapshot = ref.read(pointSaleFormControllerProvider));
        }
      });
    } else if (widget.facilityId != null) {
      final facilityId = widget.facilityId!;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final name = await ref.read(
          facilityDisplayNameProvider(facilityId).future,
        );
        if (!mounted) return;
        ref
            .read(pointSaleFormControllerProvider.notifier)
            .facilitySelected(facilityId, name ?? '');
        setState(() => _snapshot = ref.read(pointSaleFormControllerProvider));
      });
    } else {
      _snapshot = ref.read(pointSaleFormControllerProvider);
    }
  }

  bool isDirty() {
    final current = ref.read(pointSaleFormControllerProvider);
    return _snapshot != null && _snapshot != current;
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(pointSaleFormControllerProvider);
    final controller = ref.read(pointSaleFormControllerProvider.notifier);
    final access = ref.watch(accessControlProvider);
    final canCreate = access.can(SystemObject.pointsOfSale, AccessRight.create);
    final canUpdate = access.can(SystemObject.pointsOfSale, AccessRight.update);
    final readOnly = (_isEdit && !canUpdate) || _readOnlyOverride;
    final l10n = AppLocalizations.of(context)!;
    final facilityRepo = ref.read(facilityRepositoryProvider);
    final warehouseRepo = ref.read(warehouseRepositoryProvider);

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
        access.can(SystemObject.pointsOfSale, AccessRight.delete);

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
          // FR-022: scoped to the selected facility — only that facility's
          // warehouses are offered, so a mismatched pairing cannot be built
          // through this picker.
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
        FormGridChild(
          span: FormGridSpan.full,
          RecordFormActions(
            mode: mode,
            saveLabel: l10n.saveButton,
            editLabel: l10n.editRecordTooltip,
            deleteLabel: l10n.deletePointSaleButton,
            isSubmitting: formState.submitting,
            editKey: const Key('edit_point_sale_button'),
            saveKey: const Key('save_button'),
            deleteKey: const Key('delete_point_sale_button'),
            onEdit: (canUpdate && widget.pointSaleId != null)
                ? () => setState(() => _readOnlyOverride = false)
                : null,
            onSave: canSave
                ? (_isEdit ? controller.submitUpdate : controller.submitCreate)
                : null,
            onDelete: canDelete ? controller.delete : null,
            deleteConfirmation: RecordDeleteConfirmation(
              title: l10n.deletePointSaleConfirmTitle,
              message: l10n.deletePointSaleConfirmMessage(formState.name),
              confirmLabel: l10n.deleteButton,
              cancelLabel: l10n.cancelButton,
              confirmKey: const Key('confirm_delete_point_sale_button'),
            ),
          ),
        ),
      ],
    );
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
