import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/catalog_action_icons.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/responsive_form_grid.dart';
import 'package:mbe_ui/features/catalog/data/employee_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/employee_list_item.dart';
import 'package:mbe_ui/features/catalog/presentation/vehicle_operator_form_controller.dart';
import 'package:mbe_ui/features/pricing/presentation/pricing_formatters.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Create / view / edit screen for a single vehicle operator (FR-015,
/// FR-016, FR-017, US3). [vehicleOperatorId] is `null` in create mode.
class VehicleOperatorDetailScreen extends ConsumerStatefulWidget {
  const VehicleOperatorDetailScreen({
    super.key,
    this.vehicleOperatorId,
    this.forceReadOnly = false,
  });

  final int? vehicleOperatorId;

  /// Forces read-only rendering — set when navigated to via a row click
  /// rather than Edit (constitution §VI), read from the `?view=true` query
  /// parameter.
  final bool forceReadOnly;

  @override
  ConsumerState<VehicleOperatorDetailScreen> createState() =>
      _VehicleOperatorDetailScreenState();
}

class _VehicleOperatorDetailScreenState
    extends ConsumerState<VehicleOperatorDetailScreen> {
  bool get _isEdit => widget.vehicleOperatorId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(vehicleOperatorFormControllerProvider.notifier)
            .loadForEdit(widget.vehicleOperatorId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(vehicleOperatorFormControllerProvider);
    final controller = ref.read(vehicleOperatorFormControllerProvider.notifier);
    final access = ref.watch(accessControlProvider);
    final canCreate = access.can(
      SystemObject.vehicleOperators,
      AccessRight.create,
    );
    final canUpdate = access.can(
      SystemObject.vehicleOperators,
      AccessRight.update,
    );
    final readOnly = (_isEdit && !canUpdate) || widget.forceReadOnly;
    final l10n = AppLocalizations.of(context)!;
    final employeeRepo = ref.read(employeeRepositoryProvider);

    final title = readOnly
        ? l10n.viewVehicleOperatorTitle
        : (_isEdit
              ? l10n.editVehicleOperatorTitle
              : l10n.newVehicleOperatorTitle);

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
        access.can(SystemObject.vehicleOperators, AccessRight.delete);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (readOnly && canUpdate && widget.vehicleOperatorId != null)
            IconButton(
              key: const Key('edit_vehicle_operator_button'),
              icon: Icon(CatalogAction.edit.icon),
              tooltip: l10n.editRecordTooltip,
              onPressed: () => context.replace(
                '/vehicle-operators/${widget.vehicleOperatorId}',
              ),
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
                  child: Text(
                    formState.issueDate != null
                        ? PricingFormatters.date(formState.issueDate!)
                        : '',
                  ),
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
                          initialDate:
                              formState.expirationDate ?? DateTime.now(),
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
                  child: Text(
                    formState.expirationDate != null
                        ? PricingFormatters.date(formState.expirationDate!)
                        : '',
                  ),
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
              SwitchListTile(
                key: const Key('vehicle_operator_active_switch'),
                title: Text(l10n.activeLabel),
                value: formState.active,
                onChanged: fieldsEnabled ? controller.activeChanged : null,
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
                  key: const Key('delete_vehicle_operator_button'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  ),
                  onPressed: formState.submitting
                      ? null
                      : () => _confirmDelete(
                          context,
                          controller,
                          formState.driverDisplayText,
                        ),
                  child: Text(l10n.deleteVehicleOperatorButton),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    VehicleOperatorFormController controller,
    String name,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteVehicleOperatorConfirmTitle),
        content: Text(l10n.deleteVehicleOperatorConfirmMessage(name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancelButton),
          ),
          FilledButton(
            key: const Key('confirm_delete_vehicle_operator_button'),
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
