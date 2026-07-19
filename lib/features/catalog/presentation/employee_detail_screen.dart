import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/domain/gender.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/catalog_action_icons.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/responsive_form_grid.dart';
import 'package:mbe_ui/features/catalog/presentation/employee_form_controller.dart';
import 'package:mbe_ui/features/pricing/presentation/pricing_formatters.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Create / view / edit screen for a single employee (FR-015, FR-016, US3).
/// [employeeId] is `null` in create mode.
class EmployeeDetailScreen extends ConsumerStatefulWidget {
  const EmployeeDetailScreen({
    super.key,
    this.employeeId,
    this.forceReadOnly = false,
  });

  final int? employeeId;

  /// Forces read-only rendering — set when navigated to via a row click
  /// rather than Edit (constitution §VI), read from the `?view=true` query
  /// parameter.
  final bool forceReadOnly;

  @override
  ConsumerState<EmployeeDetailScreen> createState() =>
      _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends ConsumerState<EmployeeDetailScreen> {
  bool get _isEdit => widget.employeeId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(employeeFormControllerProvider.notifier)
            .loadForEdit(widget.employeeId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(employeeFormControllerProvider);
    final controller = ref.read(employeeFormControllerProvider.notifier);
    final access = ref.watch(accessControlProvider);
    final canCreate = access.can(SystemObject.employees, AccessRight.create);
    final canUpdate = access.can(SystemObject.employees, AccessRight.update);
    final readOnly = (_isEdit && !canUpdate) || widget.forceReadOnly;
    final l10n = AppLocalizations.of(context)!;

    final title = readOnly
        ? l10n.viewEmployeeTitle
        : (_isEdit ? l10n.editEmployeeTitle : l10n.newEmployeeTitle);

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
        access.can(SystemObject.employees, AccessRight.delete);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (readOnly && canUpdate && widget.employeeId != null)
            IconButton(
              key: const Key('edit_employee_button'),
              icon: Icon(CatalogAction.edit.icon),
              tooltip: l10n.editRecordTooltip,
              onPressed: () =>
                  context.replace('/employees/${widget.employeeId}'),
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
                key: const Key('first_name_field'),
                initialValue: formState.firstName,
                decoration: InputDecoration(
                  labelText: l10n.firstNameLabel,
                  errorText: _localizeFieldError(
                    l10n,
                    formState.fieldErrors['firstName'],
                  ),
                ),
                enabled: fieldsEnabled,
                onChanged: controller.firstNameChanged,
              ),
            ),
            FormGridChild(
              TextFormField(
                key: const Key('last_name_field'),
                initialValue: formState.lastName,
                decoration: InputDecoration(
                  labelText: l10n.lastNameLabel,
                  errorText: _localizeFieldError(
                    l10n,
                    formState.fieldErrors['lastName'],
                  ),
                ),
                enabled: fieldsEnabled,
                onChanged: controller.lastNameChanged,
              ),
            ),
            FormGridChild(
              TextFormField(
                key: const Key('nickname_field'),
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
              DropdownButtonFormField<Gender>(
                key: const Key('gender_field'),
                initialValue: formState.gender,
                decoration: InputDecoration(
                  labelText: l10n.genderLabel,
                  errorText: _localizeFieldError(
                    l10n,
                    formState.fieldErrors['gender'],
                  ),
                ),
                items: [
                  DropdownMenuItem(
                    value: Gender.female,
                    child: Text(l10n.genderFemaleLabel),
                  ),
                  DropdownMenuItem(
                    value: Gender.male,
                    child: Text(l10n.genderMaleLabel),
                  ),
                ],
                onChanged: !fieldsEnabled
                    ? null
                    : (gender) => controller.genderChanged(gender),
              ),
            ),
            FormGridChild(
              InkWell(
                key: const Key('birthday_field'),
                onTap: !fieldsEnabled
                    ? null
                    : () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: formState.birthday ?? DateTime(1990),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) controller.birthdayChanged(picked);
                      },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.birthdayLabel,
                    errorText: _localizeFieldError(
                      l10n,
                      formState.fieldErrors['birthday'],
                    ),
                  ),
                  child: Text(
                    formState.birthday != null
                        ? PricingFormatters.date(formState.birthday!)
                        : '',
                  ),
                ),
              ),
            ),
            FormGridChild(
              InkWell(
                key: const Key('start_job_date_field'),
                onTap: !fieldsEnabled
                    ? null
                    : () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: formState.startJobDate ?? DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          controller.startJobDateChanged(picked);
                        }
                      },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.startJobDateLabel,
                    errorText: _localizeFieldError(
                      l10n,
                      formState.fieldErrors['startJobDate'],
                    ),
                  ),
                  child: Text(
                    formState.startJobDate != null
                        ? PricingFormatters.date(formState.startJobDate!)
                        : '',
                  ),
                ),
              ),
            ),
            FormGridChild(
              TextFormField(
                key: const Key('taxpayer_id_field'),
                initialValue: formState.taxpayerId,
                decoration: InputDecoration(labelText: l10n.taxpayerIdLabel),
                enabled: fieldsEnabled,
                onChanged: controller.taxpayerIdChanged,
              ),
            ),
            FormGridChild(
              TextFormField(
                key: const Key('personal_id_field'),
                initialValue: formState.personalId,
                decoration: InputDecoration(labelText: l10n.personalIdLabel),
                enabled: fieldsEnabled,
                onChanged: controller.personalIdChanged,
              ),
            ),
            FormGridChild(
              TextFormField(
                key: const Key('enroll_number_field'),
                initialValue: formState.enrollNumber,
                decoration: InputDecoration(
                  labelText: l10n.enrollNumberLabel,
                  errorText: _localizeFieldError(
                    l10n,
                    formState.fieldErrors['enrollNumber'],
                  ),
                ),
                enabled: fieldsEnabled,
                keyboardType: TextInputType.number,
                onChanged: controller.enrollNumberChanged,
              ),
            ),
            FormGridChild(
              span: FormGridSpan.full,
              TextFormField(
                key: const Key('employee_comment_field'),
                initialValue: formState.comment,
                decoration: InputDecoration(labelText: l10n.commentLabel),
                enabled: fieldsEnabled,
                onChanged: controller.commentChanged,
                maxLines: 3,
              ),
            ),
            FormGridChild(
              span: FormGridSpan.full,
              Row(
                children: [
                  Expanded(
                    child: SwitchListTile(
                      key: const Key('sales_person_switch'),
                      title: Text(l10n.salesPersonLabel),
                      value: formState.salesPerson,
                      onChanged: fieldsEnabled
                          ? controller.salesPersonChanged
                          : null,
                    ),
                  ),
                  Expanded(
                    child: SwitchListTile(
                      key: const Key('active_switch'),
                      title: Text(l10n.activeLabel),
                      value: formState.active,
                      onChanged: fieldsEnabled
                          ? controller.activeChanged
                          : null,
                    ),
                  ),
                ],
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
                  key: const Key('delete_employee_button'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  ),
                  onPressed: formState.submitting
                      ? null
                      : () => _confirmDelete(
                          context,
                          controller,
                          '${formState.firstName} ${formState.lastName}',
                        ),
                  child: Text(l10n.deleteEmployeeButton),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    EmployeeFormController controller,
    String name,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteEmployeeConfirmTitle),
        content: Text(l10n.deleteEmployeeConfirmMessage(name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancelButton),
          ),
          FilledButton(
            key: const Key('confirm_delete_employee_button'),
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
    case EmployeeFormErrorCode.loadFailed:
      return l10n.employeeLoadFailedError;
    case EmployeeFormErrorCode.createFailed:
      return l10n.employeeCreateFailedError;
    case EmployeeFormErrorCode.updateFailed:
      return l10n.employeeUpdateFailedError;
    case EmployeeFormErrorCode.deleteFailed:
      return l10n.employeeDeleteFailedError;
    case EmployeeFormErrorCode.createPermissionDenied:
      return l10n.employeeCreatePermissionDeniedError;
    case EmployeeFormErrorCode.updatePermissionDenied:
      return l10n.employeeUpdatePermissionDeniedError;
    case EmployeeFormErrorCode.deletePermissionDenied:
      return l10n.employeeDeletePermissionDeniedError;
    default:
      return code;
  }
}

String? _localizeFieldError(AppLocalizations l10n, String? code) {
  if (code == null) return null;
  switch (code) {
    case EmployeeFormErrorCode.firstNameRequired:
      return l10n.employeeFirstNameRequiredError;
    case EmployeeFormErrorCode.lastNameRequired:
      return l10n.employeeLastNameRequiredError;
    case EmployeeFormErrorCode.nicknameRequired:
      return l10n.employeeNicknameRequiredError;
    case EmployeeFormErrorCode.genderRequired:
      return l10n.employeeGenderRequiredError;
    case EmployeeFormErrorCode.birthdayRequired:
      return l10n.employeeBirthdayRequiredError;
    case EmployeeFormErrorCode.startJobDateRequired:
      return l10n.employeeStartJobDateRequiredError;
    case EmployeeFormErrorCode.enrollNumberInvalid:
      return l10n.employeeEnrollNumberInvalidError;
    default:
      return code;
  }
}
