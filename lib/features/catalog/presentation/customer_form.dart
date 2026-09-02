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
import 'package:mbe_ui/features/catalog/data/employee_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/taxpayer_recipient_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_recipient_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/employee_list_item.dart';
import 'package:mbe_ui/features/catalog/presentation/customer_form_controller.dart';
import 'package:mbe_ui/features/pricing/data/price_list_repository_impl.dart';
import 'package:mbe_ui/features/pricing/domain/entities/price_list.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Create / view / edit form for a single customer (spec 035 US5 —
/// converted from the pushed `/customers/new` / `/customers/:customerId`
/// routes to the shared record panel, `showRecordSheet`). [customerId] is
/// `null` in create mode. Owns three `CatalogEntityPicker`s (price list,
/// salesperson/employee, taxpayer recipient) — confirms FR-035 (every
/// picker a converted form already offers keeps working unchanged) for the
/// entity with the most pickers of the fourteen. Per the FR-035 spec
/// correction, this form has no inline address/contact creation — that
/// original assumption was false. See `label_form.dart` for the base
/// pattern (spec 035 T029).
class CustomerForm extends ConsumerStatefulWidget {
  const CustomerForm({super.key, this.customerId, this.forceReadOnly = false});

  final int? customerId;

  /// Opens the form read-only regardless of the caller's update privilege —
  /// set for a row-click open (constitution §VI). The in-panel Edit control
  /// clears this.
  final bool forceReadOnly;

  @override
  ConsumerState<CustomerForm> createState() => CustomerFormPanelState();
}

/// Public so a caller can address it via `GlobalKey<CustomerFormPanelState>`
/// and query [isDirty] from `showRecordSheet`'s `isDirty` callback.
class CustomerFormPanelState extends ConsumerState<CustomerForm> {
  bool get _isEdit => widget.customerId != null;

  late bool _readOnlyOverride = widget.forceReadOnly;

  /// Snapshot of [CustomerFormState] captured once loading actually
  /// completes — awaited directly in [initState], not inferred from a
  /// `build()`-timing flag (spec 035 T028).
  CustomerFormState? _snapshot;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await ref
            .read(customerFormControllerProvider.notifier)
            .loadForEdit(widget.customerId!);
        if (mounted) {
          setState(() => _snapshot = ref.read(customerFormControllerProvider));
        }
      });
    } else {
      _snapshot = ref.read(customerFormControllerProvider);
    }
  }

  bool isDirty() {
    final current = ref.read(customerFormControllerProvider);
    return _snapshot != null && _snapshot != current;
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(customerFormControllerProvider);
    final controller = ref.read(customerFormControllerProvider.notifier);
    final access = ref.watch(accessControlProvider);
    final canCreate = access.can(SystemObject.customers, AccessRight.create);
    final canUpdate = access.can(SystemObject.customers, AccessRight.update);
    final readOnly = (_isEdit && !canUpdate) || _readOnlyOverride;
    final l10n = AppLocalizations.of(context)!;
    final priceListRepo = ref.read(priceListRepositoryProvider);
    final employeeRepo = ref.read(employeeRepositoryProvider);
    final taxpayerRepo = ref.read(taxpayerRecipientRepositoryProvider);

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
        access.can(SystemObject.customers, AccessRight.delete);

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
                  msg: localizeCustomerFormError(l10n, formState.error!),
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
              errorText: localizeCustomerFieldError(
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
              errorText: localizeCustomerFieldError(
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
            errorText: localizeCustomerFieldError(
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
          CatalogEntityPicker<TaxpayerRecipientListItem>(
            key: const Key('taxpayer_field'),
            label: l10n.taxpayerRecipientFieldLabel,
            displayStringForOption: (t) =>
                '${t.taxpayerRecipientId} — ${t.name}',
            optionsBuilder: (query) async {
              final result = await taxpayerRepo.list(
                search: query.isEmpty ? null : query,
              );
              return result.items;
            },
            onSelected: (t) =>
                controller.taxpayerSelected(t.taxpayerRecipientId, t.name),
            initialDisplayText: formState.taxpayerDisplayText,
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
              errorText: localizeCustomerFieldError(
                l10n,
                formState.fieldErrors['creditLimit'] ??
                    formState.fieldErrors['credit_limit'],
              ),
            ),
            enabled: fieldsEnabled,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: controller.creditLimitChanged,
          ),
        ),
        FormGridChild(
          TextFormField(
            key: const Key('credit_days_field'),
            initialValue: formState.creditDays,
            decoration: InputDecoration(
              labelText: l10n.creditDaysLabel,
              errorText: localizeCustomerFieldError(
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
                  onChanged: fieldsEnabled ? controller.shippingChanged : null,
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
        FormGridChild(
          span: FormGridSpan.full,
          RecordFormActions(
            mode: mode,
            saveLabel: l10n.saveButton,
            editLabel: l10n.editRecordTooltip,
            deleteLabel: l10n.deleteCustomerButton,
            isSubmitting: formState.submitting,
            editKey: const Key('edit_customer_button'),
            saveKey: const Key('save_button'),
            deleteKey: const Key('delete_customer_button'),
            onEdit: (canUpdate && widget.customerId != null)
                ? () => setState(() => _readOnlyOverride = false)
                : null,
            onSave: canSave
                ? (_isEdit ? controller.submitUpdate : controller.submitCreate)
                : null,
            onDelete: canDelete ? controller.delete : null,
            deleteConfirmation: RecordDeleteConfirmation(
              title: l10n.deleteCustomerConfirmTitle,
              message: l10n.deleteCustomerConfirmMessage(formState.name),
              confirmLabel: l10n.deleteButton,
              cancelLabel: l10n.cancelButton,
              confirmKey: const Key('confirm_delete_customer_button'),
            ),
          ),
        ),
      ],
    );
  }
}

String localizeCustomerFormError(AppLocalizations l10n, String code) {
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

String? localizeCustomerFieldError(AppLocalizations l10n, String? code) {
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
