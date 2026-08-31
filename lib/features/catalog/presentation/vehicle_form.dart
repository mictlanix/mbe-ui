import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

/// Create / view / edit form for a single vehicle (spec 035 US5 — converted
/// from the pushed `/vehicles/new` / `/vehicles/:vehicleId` routes to the
/// shared record panel, `showRecordSheet`). [vehicleId] is `null` in create
/// mode. See `label_form.dart` for the pattern this follows (spec 035 T029).
class VehicleForm extends ConsumerStatefulWidget {
  const VehicleForm({super.key, this.vehicleId, this.forceReadOnly = false});

  final int? vehicleId;

  /// Opens the form read-only regardless of the caller's update privilege —
  /// set for a row-click open (constitution §VI). The in-panel Edit control
  /// clears this.
  final bool forceReadOnly;

  @override
  ConsumerState<VehicleForm> createState() => VehicleFormPanelState();
}

/// Public so a caller can address it via `GlobalKey<VehicleFormPanelState>`
/// and query [isDirty] from `showRecordSheet`'s `isDirty` callback.
class VehicleFormPanelState extends ConsumerState<VehicleForm> {
  bool get _isEdit => widget.vehicleId != null;

  late bool _readOnlyOverride = widget.forceReadOnly;

  /// Snapshot of [VehicleFormState] captured once loading actually
  /// completes — awaited directly in [initState], not inferred from a
  /// `build()`-timing flag (spec 035 T028).
  VehicleFormState? _snapshot;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await ref
            .read(vehicleFormControllerProvider.notifier)
            .loadForEdit(widget.vehicleId!);
        if (mounted) {
          setState(() => _snapshot = ref.read(vehicleFormControllerProvider));
        }
      });
    } else {
      _snapshot = ref.read(vehicleFormControllerProvider);
    }
  }

  bool isDirty() {
    final current = ref.read(vehicleFormControllerProvider);
    return _snapshot != null && _snapshot != current;
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(vehicleFormControllerProvider);
    final controller = ref.read(vehicleFormControllerProvider.notifier);
    final access = ref.watch(accessControlProvider);
    final canCreate = access.can(SystemObject.vehicle, AccessRight.create);
    final canUpdate = access.can(SystemObject.vehicle, AccessRight.update);
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
        access.can(SystemObject.vehicle, AccessRight.delete);

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
                ? () => setState(() => _readOnlyOverride = false)
                : null,
            onSave: canSave
                ? (_isEdit ? controller.submitUpdate : controller.submitCreate)
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
