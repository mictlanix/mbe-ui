import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/record_form_actions.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/entity_status_controls.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/responsive_form_grid.dart';
import 'package:mbe_ui/features/catalog/data/employee_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/employee_list_item.dart';
import 'package:mbe_ui/features/catalog/presentation/vehicle_operator_form_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Create / view / edit form for a single vehicle operator (spec 035 US5 —
/// converted from the pushed `/vehicle-operators/new` /
/// `/vehicle-operators/:vehicleOperatorId` routes to the shared record
/// panel, `showRecordSheet`). [vehicleOperatorId] is `null` in create mode.
/// Owns a `CatalogEntityPicker` (the driver, an Employee) — the first
/// entity-picker converted; confirms FR-035 (every field a converted form
/// already offers keeps working unchanged) for pickers specifically, ahead
/// of Employees/Customers which have several each. See `label_form.dart`
/// for the base pattern (spec 035 T029).
class VehicleOperatorForm extends ConsumerStatefulWidget {
  const VehicleOperatorForm({
    super.key,
    this.vehicleOperatorId,
    this.forceReadOnly = false,
  });

  final int? vehicleOperatorId;

  /// Opens the form read-only regardless of the caller's update privilege —
  /// set for a row-click open (constitution §VI). The in-panel Edit control
  /// clears this.
  final bool forceReadOnly;

  @override
  ConsumerState<VehicleOperatorForm> createState() =>
      VehicleOperatorFormPanelState();
}

/// Public so a caller can address it via
/// `GlobalKey<VehicleOperatorFormPanelState>` and query [isDirty] from
/// `showRecordSheet`'s `isDirty` callback.
class VehicleOperatorFormPanelState extends ConsumerState<VehicleOperatorForm> {
  bool get _isEdit => widget.vehicleOperatorId != null;

  late bool _readOnlyOverride = widget.forceReadOnly;

  /// Snapshot of [VehicleOperatorFormState] captured once loading actually
  /// completes — awaited directly in [initState], not inferred from a
  /// `build()`-timing flag (spec 035 T028).
  VehicleOperatorFormState? _snapshot;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await ref
            .read(vehicleOperatorFormControllerProvider.notifier)
            .loadForEdit(widget.vehicleOperatorId!);
        if (mounted) {
          setState(
            () => _snapshot = ref.read(vehicleOperatorFormControllerProvider),
          );
        }
      });
    } else {
      _snapshot = ref.read(vehicleOperatorFormControllerProvider);
    }
  }

  bool isDirty() {
    final current = ref.read(vehicleOperatorFormControllerProvider);
    return _snapshot != null && _snapshot != current;
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(vehicleOperatorFormControllerProvider);
    final controller = ref.read(vehicleOperatorFormControllerProvider.notifier);
    final access = ref.watch(accessControlProvider);
    final fmt = ref.watch(formattersProvider);
    final canCreate = access.can(
      SystemObject.vehicleOperators,
      AccessRight.create,
    );
    final canUpdate = access.can(
      SystemObject.vehicleOperators,
      AccessRight.update,
    );
    final readOnly = (_isEdit && !canUpdate) || _readOnlyOverride;
    final l10n = AppLocalizations.of(context)!;
    final employeeRepo = ref.read(employeeRepositoryProvider);

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
        access.can(SystemObject.vehicleOperators, AccessRight.delete);

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
          span: FormGridSpan.full,
          CatalogEntityPicker<EmployeeListItem>(
            key: const Key('driver_field'),
            label: l10n.driverLabel,
            displayStringForOption: (e) => e.fullName,
            optionsBuilder: (query) async {
              final result = await employeeRepo.list(
                search: query.isEmpty ? null : query,
              );
              return result.items;
            },
            onSelected: (e) =>
                controller.driverSelected(e.employeeId, e.fullName),
            initialDisplayText: formState.driverDisplayText,
            errorText: _localizeFieldError(
              l10n,
              formState.fieldErrors['driver'],
            ),
            enabled: fieldsEnabled,
          ),
        ),
        FormGridChild(
          TextFormField(
            key: const Key('license_type_field'),
            initialValue: formState.licenseType,
            decoration: InputDecoration(
              labelText: l10n.licenseTypeLabel,
              errorText: _localizeFieldError(
                l10n,
                formState.fieldErrors['licenseType'],
              ),
            ),
            enabled: fieldsEnabled,
            onChanged: controller.licenseTypeChanged,
          ),
        ),
        FormGridChild(
          TextFormField(
            key: const Key('driver_license_number_field'),
            initialValue: formState.driverLicenseNumber,
            decoration: InputDecoration(
              labelText: l10n.driverLicenseNumberLabel,
              errorText: _localizeFieldError(
                l10n,
                formState.fieldErrors['driverLicenseNumber'],
              ),
            ),
            enabled: fieldsEnabled,
            onChanged: controller.driverLicenseNumberChanged,
          ),
        ),
        FormGridChild(
          InkWell(
            key: const Key('issue_date_field'),
            onTap: !fieldsEnabled
                ? null
                : () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: formState.issueDate ?? DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) controller.issueDateChanged(picked);
                  },
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: l10n.issueDateLabel,
                errorText: _localizeFieldError(
                  l10n,
                  formState.fieldErrors['issueDate'],
                ),
              ),
              // fmt.display.date renders '—' for a null date
              // (spec 028 FR-008), replacing this field's own empty
              // string rendering.
              child: Text(fmt.display.date(formState.issueDate)),
            ),
          ),
        ),
        FormGridChild(
          InkWell(
            key: const Key('expiration_date_field'),
            onTap: !fieldsEnabled
                ? null
                : () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: formState.expirationDate ?? DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      controller.expirationDateChanged(picked);
                    }
                  },
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: l10n.expirationDateLabel,
                errorText: _localizeFieldError(
                  l10n,
                  formState.fieldErrors['expirationDate'],
                ),
              ),
              // Same em-dash rule as issueDate above.
              child: Text(fmt.display.date(formState.expirationDate)),
            ),
          ),
        ),
        FormGridChild(
          TextFormField(
            key: const Key('issuing_location_field'),
            initialValue: formState.issuingLocation,
            decoration: InputDecoration(
              labelText: l10n.issuingLocationLabel,
              errorText: _localizeFieldError(
                l10n,
                formState.fieldErrors['issuingLocation'],
              ),
            ),
            enabled: fieldsEnabled,
            onChanged: controller.issuingLocationChanged,
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
            deleteLabel: l10n.deleteVehicleOperatorButton,
            isSubmitting: formState.submitting,
            editKey: const Key('edit_vehicle_operator_button'),
            saveKey: const Key('save_button'),
            deleteKey: const Key('delete_vehicle_operator_button'),
            onEdit: (canUpdate && widget.vehicleOperatorId != null)
                ? () => setState(() => _readOnlyOverride = false)
                : null,
            onSave: canSave
                ? (_isEdit ? controller.submitUpdate : controller.submitCreate)
                : null,
            onDelete: canDelete ? controller.delete : null,
            deleteConfirmation: RecordDeleteConfirmation(
              title: l10n.deleteVehicleOperatorConfirmTitle,
              message: l10n.deleteVehicleOperatorConfirmMessage(
                formState.driverDisplayText,
              ),
              confirmLabel: l10n.deleteButton,
              cancelLabel: l10n.cancelButton,
              confirmKey: const Key('confirm_delete_vehicle_operator_button'),
            ),
          ),
        ),
      ],
    );
  }
}

String _localizeFormError(AppLocalizations l10n, String code) {
  switch (code) {
    case VehicleOperatorFormErrorCode.loadFailed:
      return l10n.vehicleOperatorLoadFailedError;
    case VehicleOperatorFormErrorCode.createFailed:
      return l10n.vehicleOperatorCreateFailedError;
    case VehicleOperatorFormErrorCode.updateFailed:
      return l10n.vehicleOperatorUpdateFailedError;
    case VehicleOperatorFormErrorCode.deleteFailed:
      return l10n.vehicleOperatorDeleteFailedError;
    case VehicleOperatorFormErrorCode.createPermissionDenied:
      return l10n.vehicleOperatorCreatePermissionDeniedError;
    case VehicleOperatorFormErrorCode.updatePermissionDenied:
      return l10n.vehicleOperatorUpdatePermissionDeniedError;
    case VehicleOperatorFormErrorCode.deletePermissionDenied:
      return l10n.vehicleOperatorDeletePermissionDeniedError;
    default:
      return code;
  }
}

String? _localizeFieldError(AppLocalizations l10n, String? code) {
  if (code == null) return null;
  switch (code) {
    case VehicleOperatorFormErrorCode.driverRequired:
      return l10n.vehicleOperatorDriverRequiredError;
    case VehicleOperatorFormErrorCode.licenseTypeRequired:
      return l10n.vehicleOperatorLicenseTypeRequiredError;
    case VehicleOperatorFormErrorCode.driverLicenseNumberRequired:
      return l10n.vehicleOperatorDriverLicenseNumberRequiredError;
    case VehicleOperatorFormErrorCode.issueDateRequired:
      return l10n.vehicleOperatorIssueDateRequiredError;
    case VehicleOperatorFormErrorCode.expirationDateRequired:
      return l10n.vehicleOperatorExpirationDateRequiredError;
    case VehicleOperatorFormErrorCode.expirationBeforeIssue:
      return l10n.vehicleOperatorExpirationBeforeIssueError;
    case VehicleOperatorFormErrorCode.issuingLocationRequired:
      return l10n.vehicleOperatorIssuingLocationRequiredError;
    default:
      return code;
  }
}
