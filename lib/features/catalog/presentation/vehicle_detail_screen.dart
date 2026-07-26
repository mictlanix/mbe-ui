import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/record_form_actions.dart';
import 'package:mbe_ui/core/widgets/entity_status_controls.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/responsive_form_grid.dart';
import 'package:mbe_ui/features/catalog/presentation/vehicle_form_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Create / view / edit screen for a single vehicle (FR-012, FR-013, US2).
/// [vehicleId] is `null` in create mode.
class VehicleDetailScreen extends ConsumerStatefulWidget {
  const VehicleDetailScreen({
    super.key,
    this.vehicleId,
    this.forceReadOnly = false,
  });

  final int? vehicleId;

  /// Forces read-only rendering — set when navigated to via a row click
  /// rather than Edit (constitution §VI), read from the `?view=true` query
  /// parameter.
  final bool forceReadOnly;

  @override
  ConsumerState<VehicleDetailScreen> createState() =>
      _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends ConsumerState<VehicleDetailScreen> {
  bool get _isEdit => widget.vehicleId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(vehicleFormControllerProvider.notifier)
            .loadForEdit(widget.vehicleId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(vehicleFormControllerProvider);
    final controller = ref.read(vehicleFormControllerProvider.notifier);
    final access = ref.watch(accessControlProvider);
    final canCreate = access.can(SystemObject.vehicle, AccessRight.create);
    final canUpdate = access.can(SystemObject.vehicle, AccessRight.update);
    final readOnly = (_isEdit && !canUpdate) || widget.forceReadOnly;
    final l10n = AppLocalizations.of(context)!;

    final title = readOnly
        ? l10n.viewVehicleTitle
        : (_isEdit ? l10n.editVehicleTitle : l10n.newVehicleTitle);

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
        access.can(SystemObject.vehicle, AccessRight.delete);

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
              TextFormField(
                key: const Key('vehicle_license_plate_field'),
                initialValue: formState.licensePlate,
                decoration: InputDecoration(
                  labelText: l10n.licensePlateLabel,
                  errorText: _localizeFieldError(
                    l10n,
                    formState.fieldErrors['licensePlate'],
                  ),
                ),
                enabled: fieldsEnabled,
                onChanged: controller.licensePlateChanged,
              ),
            ),
            FormGridChild(
              TextFormField(
                key: const Key('vehicle_tons_capacity_field'),
                initialValue: formState.tonsCapacity,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.tonsCapacityLabel,
                  errorText: _localizeFieldError(
                    l10n,
                    formState.fieldErrors['tonsCapacity'],
                  ),
                ),
                enabled: fieldsEnabled,
                onChanged: controller.tonsCapacityChanged,
              ),
            ),
            FormGridChild(
              TextFormField(
                key: const Key('vehicle_name_field'),
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
                key: const Key('vehicle_nickname_field'),
                initialValue: formState.nickname,
                decoration: InputDecoration(
                  labelText: l10n.nicknameLabel,
                  errorText: _localizeFieldError(
                    l10n,
                    formState.fieldErrors['nickname'],
                  ),
                ),
                enabled: fieldsEnabled,
                onChanged: controller.nicknameChanged,
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
                deleteLabel: l10n.deleteVehicleButton,
                isSubmitting: formState.submitting,
                editKey: const Key('edit_vehicle_button'),
                saveKey: const Key('save_button'),
                deleteKey: const Key('delete_vehicle_button'),
                onEdit: (canUpdate && widget.vehicleId != null)
                    ? () => context.replace('/vehicles/${widget.vehicleId}')
                    : null,
                onSave: canSave
                    ? (_isEdit
                          ? controller.submitUpdate
                          : controller.submitCreate)
                    : null,
                onDelete: canDelete ? controller.delete : null,
                deleteConfirmation: RecordDeleteConfirmation(
                  title: l10n.deleteVehicleConfirmTitle,
                  message: l10n.deleteVehicleConfirmMessage(formState.name),
                  confirmLabel: l10n.deleteButton,
                  cancelLabel: l10n.cancelButton,
                  confirmKey: const Key('confirm_delete_vehicle_button'),
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
    case VehicleFormErrorCode.loadFailed:
      return l10n.vehicleLoadFailedError;
    case VehicleFormErrorCode.createFailed:
      return l10n.vehicleCreateFailedError;
    case VehicleFormErrorCode.updateFailed:
      return l10n.vehicleUpdateFailedError;
    case VehicleFormErrorCode.deleteFailed:
      return l10n.vehicleDeleteFailedError;
    case VehicleFormErrorCode.createPermissionDenied:
      return l10n.vehicleCreatePermissionDeniedError;
    case VehicleFormErrorCode.updatePermissionDenied:
      return l10n.vehicleUpdatePermissionDeniedError;
    case VehicleFormErrorCode.deletePermissionDenied:
      return l10n.vehicleDeletePermissionDeniedError;
    default:
      return code;
  }
}

String? _localizeFieldError(AppLocalizations l10n, String? code) {
  if (code == null) return null;
  switch (code) {
    case VehicleFormErrorCode.licensePlateRequired:
      return l10n.vehicleLicensePlateRequiredError;
    case VehicleFormErrorCode.nameRequired:
      return l10n.vehicleNameRequiredError;
    case VehicleFormErrorCode.nicknameRequired:
      return l10n.vehicleNicknameRequiredError;
    case VehicleFormErrorCode.tonsCapacityInvalid:
      return l10n.vehicleTonsCapacityInvalidError;
    default:
      return code;
  }
}
