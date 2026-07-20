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
import 'package:mbe_ui/features/catalog/data/employee_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/employee_list_item.dart';
import 'package:mbe_ui/features/catalog/presentation/customer_form_controller.dart';
import 'package:mbe_ui/features/pricing/data/price_list_repository_impl.dart';
import 'package:mbe_ui/features/pricing/domain/entities/price_list.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Create / view / edit screen for a single customer (FR-018, FR-019,
/// FR-020, FR-021, US4). [customerId] is `null` in create mode.
class CustomerDetailScreen extends ConsumerStatefulWidget {
  const CustomerDetailScreen({
    super.key,
    this.customerId,
    this.forceReadOnly = false,
  });

  final int? customerId;

  /// Forces read-only rendering — set when navigated to via a row click
  /// rather than Edit (constitution §VI), read from the `?view=true` query
  /// parameter.
  final bool forceReadOnly;

  @override
  ConsumerState<CustomerDetailScreen> createState() =>
      _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends ConsumerState<CustomerDetailScreen> {
  bool get _isEdit => widget.customerId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(customerFormControllerProvider.notifier)
            .loadForEdit(widget.customerId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(customerFormControllerProvider);
    final controller = ref.read(customerFormControllerProvider.notifier);
    final access = ref.watch(accessControlProvider);
    final canCreate = access.can(SystemObject.customers, AccessRight.create);
    final canUpdate = access.can(SystemObject.customers, AccessRight.update);
    final readOnly = (_isEdit && !canUpdate) || widget.forceReadOnly;
    final l10n = AppLocalizations.of(context)!;
    final priceListRepo = ref.read(priceListRepositoryProvider);
    final employeeRepo = ref.read(employeeRepositoryProvider);

    final title = readOnly
        ? l10n.viewCustomerTitle
        : (_isEdit ? l10n.editCustomerTitle : l10n.newCustomerTitle);

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
        access.can(SystemObject.customers, AccessRight.delete);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (readOnly && canUpdate && widget.customerId != null)
            IconButton(
              key: const Key('edit_customer_button'),
              icon: Icon(CatalogAction.edit.icon),
              tooltip: l10n.editRecordTooltip,
              onPressed: () =>
                  context.replace('/customers/${widget.customerId}'),
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
                key: const Key('code_field'),
                initialValue: formState.code,
                decoration: InputDecoration(
                  labelText: l10n.codeLabel,
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
              CatalogEntityPicker<PriceList>(
                key: const Key('price_list_field'),
                label: l10n.priceListFieldLabel,
                displayStringForOption: (p) => p.name,
                optionsBuilder: (query) async {
                  final result = await priceListRepo.list(
                    search: query.isEmpty ? null : query,
                  );
                  return result.items;
                },
                onSelected: (p) =>
                    controller.priceListSelected(p.priceListId, p.name),
                initialDisplayText: formState.priceListDisplayText,
                errorText: _localizeFieldError(
                  l10n,
                  formState.fieldErrors['priceList'],
                ),
                enabled: fieldsEnabled,
              ),
            ),
            FormGridChild(
              CatalogEntityPicker<EmployeeListItem>(
                key: const Key('salesperson_field'),
                label: l10n.salesPersonLabel,
                displayStringForOption: (e) => e.fullName,
                optionsBuilder: (query) async {
                  final result = await employeeRepo.list(
                    search: query.isEmpty ? null : query,
                  );
                  return result.items;
                },
                onSelected: (e) =>
                    controller.salespersonSelected(e.employeeId, e.fullName),
                initialDisplayText: formState.salespersonDisplayText.isNotEmpty
                    ? formState.salespersonDisplayText
                    : l10n.noneAssignedLabel,
                enabled: fieldsEnabled,
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
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
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
                key: const Key('customer_comment_field'),
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
                      key: const Key('shipping_switch'),
                      title: Text(l10n.shippingLabel),
                      value: formState.shipping,
                      onChanged: fieldsEnabled
                          ? controller.shippingChanged
                          : null,
                    ),
                  ),
                  Expanded(
                    child: SwitchListTile(
                      key: const Key('shipping_required_document_switch'),
                      title: Text(l10n.shippingRequiredDocumentLabel),
                      value: formState.shippingRequiredDocument,
                      onChanged: fieldsEnabled
                          ? controller.shippingRequiredDocumentChanged
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            if (_isEdit)
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
                  key: const Key('delete_customer_button'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  ),
                  onPressed: formState.submitting
                      ? null
                      : () =>
                            _confirmDelete(context, controller, formState.name),
                  child: Text(l10n.deleteCustomerButton),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    CustomerFormController controller,
    String name,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteCustomerConfirmTitle),
        content: Text(l10n.deleteCustomerConfirmMessage(name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancelButton),
          ),
          FilledButton(
            key: const Key('confirm_delete_customer_button'),
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
    case CustomerFormErrorCode.loadFailed:
      return l10n.customerLoadFailedError;
    case CustomerFormErrorCode.createFailed:
      return l10n.customerCreateFailedError;
    case CustomerFormErrorCode.updateFailed:
      return l10n.customerUpdateFailedError;
    case CustomerFormErrorCode.deleteFailed:
      return l10n.customerDeleteFailedError;
    case CustomerFormErrorCode.createPermissionDenied:
      return l10n.customerCreatePermissionDeniedError;
    case CustomerFormErrorCode.updatePermissionDenied:
      return l10n.customerUpdatePermissionDeniedError;
    case CustomerFormErrorCode.deletePermissionDenied:
      return l10n.customerDeletePermissionDeniedError;
    default:
      return code;
  }
}

String? _localizeFieldError(AppLocalizations l10n, String? code) {
  if (code == null) return null;
  switch (code) {
    case CustomerFormErrorCode.codeRequired:
      return l10n.customerCodeRequiredError;
    case CustomerFormErrorCode.nameRequired:
      return l10n.customerNameRequiredError;
    case CustomerFormErrorCode.priceListRequired:
      return l10n.customerPriceListRequiredError;
    case CustomerFormErrorCode.creditLimitInvalid:
      return l10n.creditLimitInvalidError;
    case CustomerFormErrorCode.creditDaysInvalid:
      return l10n.creditDaysInvalidError;
    default:
      return code;
  }
}
