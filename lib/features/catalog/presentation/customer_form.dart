import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/record_form_actions.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/entity_status_controls.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/responsive_form_grid.dart';
import 'package:mbe_ui/features/catalog/data/address_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/contact_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/employee_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/taxpayer_recipient_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/address_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/contact.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_recipient_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/employee_list_item.dart';
import 'package:mbe_ui/features/catalog/presentation/address_inline_create.dart';
import 'package:mbe_ui/features/catalog/presentation/contact_inline_create.dart';
import 'package:mbe_ui/features/catalog/presentation/customer_discounts_section.dart';
import 'package:mbe_ui/features/catalog/presentation/customer_form_controller.dart';
import 'package:mbe_ui/features/catalog/presentation/taxpayer_recipient_inline_create.dart';
import 'package:mbe_ui/features/catalog/presentation/widgets/linked_records_section.dart';
import 'package:mbe_ui/features/pricing/data/price_list_repository_impl.dart';
import 'package:mbe_ui/features/pricing/domain/entities/price_list.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Create / view / edit form for a single customer, hosted by
/// `CustomerDetailScreen` on the `/customers/new` and
/// `/customers/:customerId` routes (moved back from the shared record panel
/// by 046-catalog-improvements: the linked-record sections outgrew it).
/// [customerId] is `null` in create mode. Owns two `CatalogEntityPicker`s (price list,
/// salesperson/employee) and three [LinkedRecordsSection]s — addresses,
/// contacts and taxpayer recipients — where the customer's links are added,
/// created and removed (046-catalog-improvements US1). The linked records
/// are shared, so they are never edited from here (FR-009). See
/// `label_form.dart` for the base pattern (spec 035 T029).
class CustomerForm extends ConsumerStatefulWidget {
  const CustomerForm({
    super.key,
    this.customerId,
    this.forceReadOnly = false,
    this.onEditRequested,
    this.onCreated,
  });

  final int? customerId;

  /// What the Edit control does on a read-only form. `null` switches this
  /// form to editable in place; the detail screen passes a navigation to its
  /// edit route instead, so its AppBar title follows the mode.
  final VoidCallback? onEditRequested;

  /// Called with the new customer's id after a successful create, so the
  /// detail screen can reopen it in edit mode and discounts can be added at
  /// once (spec 052 FR-007a). `null` pops, as does every update and delete.
  final ValueChanged<int>? onCreated;

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

  /// The detail screen's Edit replaces `?view=true` with the edit route, and
  /// the router keeps this same widget for it — so follow the new mode.
  @override
  void didUpdateWidget(CustomerForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.forceReadOnly != widget.forceReadOnly) {
      _readOnlyOverride = widget.forceReadOnly;
    }
    // A create form reopened as the customer it just saved (FR-007a): the
    // router may keep this State, so load the new record into it.
    if (oldWidget.customerId != widget.customerId && _isEdit) {
      _snapshot = null;
      _loadForEdit();
    }
  }

  /// Snapshot of [CustomerFormState] captured once loading actually
  /// completes — awaited directly in [initState], not inferred from a
  /// `build()`-timing flag (spec 035 T028).
  CustomerFormState? _snapshot;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _loadForEdit();
    } else {
      _snapshot = ref.read(customerFormControllerProvider(widget.customerId));
    }
  }

  void _loadForEdit() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref
          .read(customerFormControllerProvider(widget.customerId).notifier)
          .loadForEdit(widget.customerId!);
      if (mounted) {
        setState(
          () => _snapshot = ref.read(
            customerFormControllerProvider(widget.customerId),
          ),
        );
      }
    });
  }

  bool isDirty() {
    final current = ref.read(customerFormControllerProvider(widget.customerId));
    return _snapshot != null && _snapshot != current;
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(
      customerFormControllerProvider(widget.customerId),
    );
    final controller = ref.read(
      customerFormControllerProvider(widget.customerId).notifier,
    );
    final access = ref.watch(accessControlProvider);
    final canCreate = access.can(SystemObject.customers, AccessRight.create);
    final canUpdate = access.can(SystemObject.customers, AccessRight.update);
    final readOnly = (_isEdit && !canUpdate) || _readOnlyOverride;
    final l10n = AppLocalizations.of(context)!;
    final priceListRepo = ref.read(priceListRepositoryProvider);
    final employeeRepo = ref.read(employeeRepositoryProvider);
    final taxpayerRepo = ref.read(taxpayerRecipientRepositoryProvider);
    final addressRepo = ref.read(addressRepositoryProvider);
    final contactRepo = ref.read(contactRepositoryProvider);
    // The walk-in customer's links are fixed (FR-021): nothing can be linked
    // to it, and its RFC is always the generic one.
    final isGeneric = controller.isGenericCustomer;

    if (formState.loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    // `_snapshot` is still null while an edit form has not finished loading:
    // the controller's state may then be the previous form's leftover (the
    // create form this one replaced, FR-007a), so its `saved` is not ours.
    if (_snapshot != null && (formState.saved || formState.deleted)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final createdId = formState.customerId;
        if (formState.saved &&
            !_isEdit &&
            createdId != null &&
            widget.onCreated != null) {
          widget.onCreated!(createdId);
        } else {
          Navigator.of(context).pop();
        }
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
        // `code` is optional (FR-011) and sits here, right after credit days
        // (FR-012), rather than at the top of the form where a required
        // identifier would normally go.
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
        // Status belongs with the customer's own fields, ahead of the
        // linked-record sections.
        if (_isEdit)
          FormGridChild(
            span: FormGridSpan.full,
            EntityStatusFormField(
              value: formState.status,
              onChanged: fieldsEnabled ? controller.statusChanged : null,
            ),
          ),
        // Linked records (046-catalog-improvements FR-001..FR-008). Linking or
        // unlinking needs the same right as saving the customer (the
        // sections are disabled exactly when the fields are); searching
        // needs read on the linked kind, creating needs create on it.
        const FormGridChild(span: FormGridSpan.full, Divider()),
        // Addresses and contacts pair side by side on wide tiers (§VI).
        FormGridChild(
          LinkedRecordsSection<AddressListItem>(
            key: const Key('customer_addresses_section'),
            sectionId: 'addresses',
            title: l10n.customerAddressesSection,
            emptyText: l10n.customerAddressesEmpty,
            items: formState.addresses,
            idOf: (a) => a.addressId,
            labelOf: (a) => a.label,
            statusOf: (a) => a.status,
            editable: fieldsEnabled,
            searchLabel: l10n.customerAddressLinkLabel,
            searchExisting:
                !isGeneric &&
                    access.can(SystemObject.addresses, AccessRight.read)
                ? (query) async => (await addressRepo.list(
                    search: query.isEmpty ? null : query,
                    status: EntityStatus.active,
                  )).items
                : null,
            onLinked: controller.addressAdded,
            onUnlinked: (a) => controller.addressRemoved(a.addressId),
            onCreateNew:
                !isGeneric &&
                    access.can(SystemObject.addresses, AccessRight.create)
                ? () => showAddressInlineCreateDialog(context)
                : null,
          ),
        ),
        FormGridChild(
          LinkedRecordsSection<Contact>(
            key: const Key('customer_contacts_section'),
            sectionId: 'contacts',
            title: l10n.customerContactsSection,
            emptyText: l10n.customerContactsEmpty,
            items: formState.contacts,
            idOf: (c) => c.contactId,
            labelOf: (c) => c.name,
            subtitleOf: (c) => c.preferredPhone ?? c.email,
            editable: fieldsEnabled,
            searchLabel: l10n.customerContactLinkLabel,
            searchExisting:
                !isGeneric &&
                    access.can(SystemObject.contacts, AccessRight.read)
                ? (query) =>
                      contactRepo.list(search: query.isEmpty ? null : query)
                : null,
            onLinked: controller.contactAdded,
            onUnlinked: (c) => controller.contactRemoved(c.contactId),
            onCreateNew:
                !isGeneric &&
                    access.can(SystemObject.contacts, AccessRight.create)
                ? () => showContactInlineCreateDialog(context)
                : null,
          ),
        ),
        const FormGridChild(span: FormGridSpan.full, Divider()),
        FormGridChild(
          span: FormGridSpan.full,
          LinkedRecordsSection<TaxpayerRecipientListItem>(
            key: const Key('customer_taxpayers_section'),
            sectionId: 'taxpayers',
            title: l10n.customerTaxpayersSection,
            emptyText: l10n.customerTaxpayersEmpty,
            items: formState.taxpayers,
            idOf: (t) => t.taxpayerRecipientId,
            labelOf: (t) => t.taxpayerRecipientId,
            subtitleOf: (t) => t.name,
            editable: fieldsEnabled && !isGeneric,
            searchLabel: l10n.customerTaxpayerLinkLabel,
            searchExisting:
                !isGeneric &&
                    access.can(
                      SystemObject.taxpayerRecipients,
                      AccessRight.read,
                    )
                ? (query) async => (await taxpayerRepo.list(
                    search: query.isEmpty ? null : query,
                  )).items
                : null,
            onLinked: controller.taxpayerAdded,
            onUnlinked: (t) =>
                controller.taxpayerRemoved(t.taxpayerRecipientId),
            onCreateNew:
                !isGeneric &&
                    access.can(
                      SystemObject.taxpayerRecipients,
                      AccessRight.create,
                    )
                ? () => showTaxpayerRecipientInlineCreateDialog(context)
                : null,
          ),
        ),
        if (isGeneric)
          FormGridChild(
            span: FormGridSpan.full,
            Text(
              l10n.customerGenericTaxpayerNote(genericTaxpayerRfc),
              key: const Key('customer_generic_taxpayer_note'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        // Discounts (spec 052): a child collection with its own endpoint, so
        // it loads and saves independently of the customer's Save.
        const FormGridChild(span: FormGridSpan.full, Divider()),
        FormGridChild(
          span: FormGridSpan.full,
          CustomerDiscountsSection(
            key: const Key('customer_discounts_section'),
            customerId: widget.customerId,
            readOnly: readOnly,
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
                ? (widget.onEditRequested ??
                      () => setState(() => _readOnlyOverride = false))
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
