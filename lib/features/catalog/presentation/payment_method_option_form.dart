import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/domain/payment_method.dart';
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
import 'package:mbe_ui/features/catalog/presentation/payment_method_option_form_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Create / view / edit form for a single payment method option (spec 035
/// US5 — converted from the pushed `/payment-method-options/new` /
/// `/payment-method-options/:paymentMethodOptionId` routes to the shared
/// record panel, `showRecordSheet`). [paymentMethodOptionId] is `null` in
/// create mode. See `label_form.dart` for the base pattern (spec 035 T029).
class PaymentMethodOptionForm extends ConsumerStatefulWidget {
  const PaymentMethodOptionForm({
    super.key,
    this.paymentMethodOptionId,
    this.forceReadOnly = false,
  });

  final int? paymentMethodOptionId;

  /// Opens the form read-only regardless of the caller's update privilege —
  /// set for a row-click open (constitution §VI). The in-panel Edit control
  /// clears this.
  final bool forceReadOnly;

  @override
  ConsumerState<PaymentMethodOptionForm> createState() =>
      PaymentMethodOptionFormPanelState();
}

/// Public so a caller can address it via
/// `GlobalKey<PaymentMethodOptionFormPanelState>` and query [isDirty] from
/// `showRecordSheet`'s `isDirty` callback.
class PaymentMethodOptionFormPanelState
    extends ConsumerState<PaymentMethodOptionForm> {
  bool get _isEdit => widget.paymentMethodOptionId != null;

  late bool _readOnlyOverride = widget.forceReadOnly;

  /// Snapshot of [PaymentMethodOptionFormState] captured once loading
  /// actually completes — awaited directly in [initState], not inferred
  /// from a `build()`-timing flag (spec 035 T028).
  PaymentMethodOptionFormState? _snapshot;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await ref
            .read(paymentMethodOptionFormControllerProvider.notifier)
            .loadForEdit(widget.paymentMethodOptionId!);
        if (mounted) {
          setState(
            () => _snapshot = ref.read(
              paymentMethodOptionFormControllerProvider,
            ),
          );
        }
      });
    } else {
      _snapshot = ref.read(paymentMethodOptionFormControllerProvider);
    }
  }

  bool isDirty() {
    final current = ref.read(paymentMethodOptionFormControllerProvider);
    return _snapshot != null && _snapshot != current;
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(paymentMethodOptionFormControllerProvider);
    final controller = ref.read(
      paymentMethodOptionFormControllerProvider.notifier,
    );
    final access = ref.watch(accessControlProvider);
    final canCreate = access.can(
      SystemObject.paymentMethodOptions,
      AccessRight.create,
    );
    final canUpdate = access.can(
      SystemObject.paymentMethodOptions,
      AccessRight.update,
    );
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
        access.can(SystemObject.paymentMethodOptions, AccessRight.delete);

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
          CatalogEntityPicker<Warehouse>(
            key: const Key('warehouse_field'),
            label: l10n.warehouseFieldLabel,
            displayStringForOption: (w) => w.name,
            optionsBuilder: (query) async {
              final result = await warehouseRepo.list(
                search: query.isEmpty ? null : query,
              );
              return result.items;
            },
            onSelected: (w) =>
                controller.warehouseSelected(w.warehouseId, w.name),
            initialDisplayText: formState.warehouseDisplayText,
            enabled: fieldsEnabled,
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
          DropdownButtonFormField<int>(
            key: const Key('payment_method_field'),
            initialValue: formState.paymentMethod,
            // Some labels (e.g. "To the satisfaction of the creditor")
            // are long enough to overflow the field's fixed width
            // without `isExpanded` + an ellipsis-capable child.
            isExpanded: true,
            decoration: InputDecoration(
              labelText: l10n.paymentMethodFieldLabel,
              errorText: _localizeFieldError(
                l10n,
                formState.fieldErrors['paymentMethod'],
              ),
            ),
            items: [
              for (final method in PaymentMethod.values)
                DropdownMenuItem(
                  value: method.code,
                  child: Text(
                    paymentMethodLabel(l10n, method.code),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: fieldsEnabled
                ? (value) {
                    if (value != null) {
                      controller.paymentMethodChanged(value);
                    }
                  }
                : null,
          ),
        ),
        FormGridChild(
          TextFormField(
            key: const Key('number_of_payments_field'),
            initialValue: '${formState.numberOfPayments}',
            decoration: InputDecoration(
              labelText: l10n.numberOfPaymentsFieldLabel,
              errorText: _localizeFieldError(
                l10n,
                formState.fieldErrors['numberOfPayments'],
              ),
            ),
            keyboardType: TextInputType.number,
            enabled: fieldsEnabled,
            onChanged: (v) {
              final parsed = int.tryParse(v.trim());
              if (parsed != null) {
                controller.numberOfPaymentsChanged(parsed);
              }
            },
          ),
        ),
        FormGridChild(
          TextFormField(
            key: const Key('commission_field'),
            initialValue: formState.commission,
            decoration: InputDecoration(
              labelText: l10n.commissionFieldLabel,
              errorText: _localizeFieldError(
                l10n,
                formState.fieldErrors['commission'],
              ),
            ),
            enabled: fieldsEnabled,
            onChanged: controller.commissionChanged,
          ),
        ),
        FormGridChild(
          SwitchListTile(
            key: const Key('display_on_ticket_field'),
            title: Text(l10n.displayOnTicketFieldLabel),
            value: formState.displayOnTicket,
            onChanged: fieldsEnabled ? controller.displayOnTicketChanged : null,
            contentPadding: EdgeInsets.zero,
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
            deleteLabel: l10n.deletePaymentMethodOptionButton,
            isSubmitting: formState.submitting,
            editKey: const Key('edit_payment_method_option_button'),
            saveKey: const Key('save_button'),
            deleteKey: const Key('delete_payment_method_option_button'),
            onEdit: (canUpdate && widget.paymentMethodOptionId != null)
                ? () => setState(() => _readOnlyOverride = false)
                : null,
            onSave: canSave
                ? (_isEdit ? controller.submitUpdate : controller.submitCreate)
                : null,
            onDelete: canDelete ? controller.delete : null,
            deleteConfirmation: RecordDeleteConfirmation(
              title: l10n.deletePaymentMethodOptionConfirmTitle,
              message: l10n.deletePaymentMethodOptionConfirmMessage(
                formState.name,
              ),
              confirmLabel: l10n.deleteButton,
              cancelLabel: l10n.cancelButton,
              confirmKey: const Key(
                'confirm_delete_payment_method_option_button',
              ),
            ),
          ),
        ),
      ],
    );
  }
}

String _localizeFormError(AppLocalizations l10n, String code) {
  switch (code) {
    case PaymentMethodOptionFormErrorCode.loadFailed:
      return l10n.paymentMethodOptionLoadFailedError;
    case PaymentMethodOptionFormErrorCode.createFailed:
      return l10n.paymentMethodOptionCreateFailedError;
    case PaymentMethodOptionFormErrorCode.updateFailed:
      return l10n.paymentMethodOptionUpdateFailedError;
    case PaymentMethodOptionFormErrorCode.deleteFailed:
      return l10n.paymentMethodOptionDeleteFailedError;
    case PaymentMethodOptionFormErrorCode.createPermissionDenied:
      return l10n.paymentMethodOptionCreatePermissionDeniedError;
    case PaymentMethodOptionFormErrorCode.updatePermissionDenied:
      return l10n.paymentMethodOptionUpdatePermissionDeniedError;
    case PaymentMethodOptionFormErrorCode.deletePermissionDenied:
      return l10n.paymentMethodOptionDeletePermissionDeniedError;
    default:
      return code;
  }
}

String? _localizeFieldError(AppLocalizations l10n, String? code) {
  if (code == null) return null;
  switch (code) {
    case PaymentMethodOptionFormErrorCode.facilityRequired:
      return l10n.paymentMethodOptionFacilityRequiredError;
    case PaymentMethodOptionFormErrorCode.nameRequired:
      return l10n.paymentMethodOptionNameRequiredError;
    case PaymentMethodOptionFormErrorCode.paymentMethodRequired:
      return l10n.paymentMethodOptionPaymentMethodRequiredError;
    case PaymentMethodOptionFormErrorCode.numberOfPaymentsInvalid:
      return l10n.paymentMethodOptionNumberOfPaymentsInvalidError;
    case PaymentMethodOptionFormErrorCode.commissionInvalid:
      return l10n.paymentMethodOptionCommissionInvalidError;
    default:
      return code;
  }
}
