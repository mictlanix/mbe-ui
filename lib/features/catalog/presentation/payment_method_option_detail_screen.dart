import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

/// Create / view / edit screen for a single payment method option (FR-003,
/// FR-006, FR-007, US1). [paymentMethodOptionId] is `null` in create mode.
class PaymentMethodOptionDetailScreen extends ConsumerStatefulWidget {
  const PaymentMethodOptionDetailScreen({
    super.key,
    this.paymentMethodOptionId,
    this.forceReadOnly = false,
  });

  final int? paymentMethodOptionId;

  /// Forces read-only rendering — set when navigated to via a row click
  /// rather than Edit (constitution §VI), read from the `?view=true` query
  /// parameter.
  final bool forceReadOnly;

  @override
  ConsumerState<PaymentMethodOptionDetailScreen> createState() =>
      _PaymentMethodOptionDetailScreenState();
}

class _PaymentMethodOptionDetailScreenState
    extends ConsumerState<PaymentMethodOptionDetailScreen> {
  bool get _isEdit => widget.paymentMethodOptionId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(paymentMethodOptionFormControllerProvider.notifier)
            .loadForEdit(widget.paymentMethodOptionId!);
      });
    }
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
    final readOnly = (_isEdit && !canUpdate) || widget.forceReadOnly;
    final l10n = AppLocalizations.of(context)!;
    final facilityRepo = ref.read(facilityRepositoryProvider);
    final warehouseRepo = ref.read(warehouseRepositoryProvider);

    final title = readOnly
        ? l10n.viewPaymentMethodOptionTitle
        : (_isEdit
              ? l10n.editPaymentMethodOptionTitle
              : l10n.newPaymentMethodOptionTitle);

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
        access.can(SystemObject.paymentMethodOptions, AccessRight.delete);

    final mode = !_isEdit
        ? RecordFormMode.create
        : (readOnly ? RecordFormMode.view : RecordFormMode.edit);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ResponsiveFormGrid(
          // Keyed on the loaded record's id so the field subtree remounts
          // once `loadForEdit` resolves — `TextFormField`/`CatalogEntityPicker`
          // seed from `initialValue`/`initialDisplayText` only on first mount
          // (Flutter's documented `initialValue` behavior), so without this
          // key a fast-resolving load can leave every field showing its
          // pre-load (empty) value even though the loaded data has arrived.
          key: ValueKey(formState.paymentMethodOptionId),
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
                onChanged: fieldsEnabled
                    ? controller.displayOnTicketChanged
                    : null,
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
                    ? () => context.replace(
                        '/payment-method-options/${widget.paymentMethodOptionId}',
                      )
                    : null,
                onSave: canSave
                    ? (_isEdit
                          ? controller.submitUpdate
                          : controller.submitCreate)
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
        ),
      ),
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
