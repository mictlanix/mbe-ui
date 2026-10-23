import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/record_form_actions.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/responsive_form_grid.dart';
import 'package:mbe_ui/features/catalog/data/address_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/bank_account_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/contact_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/address_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/bank_account.dart';
import 'package:mbe_ui/features/catalog/domain/entities/contact.dart';
import 'package:mbe_ui/features/catalog/presentation/address_inline_create.dart';
import 'package:mbe_ui/features/catalog/presentation/bank_account_inline_create.dart';
import 'package:mbe_ui/features/catalog/presentation/contact_inline_create.dart';
import 'package:mbe_ui/features/catalog/presentation/supplier_agreements_section.dart';
import 'package:mbe_ui/features/catalog/presentation/supplier_form_controller.dart';
import 'package:mbe_ui/features/catalog/presentation/widgets/linked_records_section.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Create / view / edit form for a single supplier, hosted by
/// `SupplierDetailScreen` on the `/suppliers/new` and
/// `/suppliers/:supplierId` routes (spec 050: moved back from the shared
/// record panel because the linked-record sections outgrew it).
/// [supplierId] is `null` in create mode. Below its six fields it shows the
/// supplier's addresses, contacts and bank accounts as
/// [LinkedRecordsSection]s, and its agreements. See `customer_form.dart` for
/// the pattern this follows.
class SupplierForm extends ConsumerStatefulWidget {
  const SupplierForm({
    super.key,
    this.supplierId,
    this.forceReadOnly = false,
    this.onEditRequested,
    this.onCreated,
  });

  final int? supplierId;

  /// What the Edit control does on a read-only form. `null` switches this
  /// form to editable in place; the detail screen passes a navigation to its
  /// edit route instead, so its AppBar title follows the mode.
  final VoidCallback? onEditRequested;

  /// Called with the new supplier's id after a successful create, so the
  /// detail screen can reopen it in edit mode (FR-015a). `null` pops, as
  /// does every update and delete.
  final ValueChanged<int>? onCreated;

  /// Opens the form read-only regardless of the caller's update privilege —
  /// set for a row-click open (constitution §VI). The in-panel Edit control
  /// clears this.
  final bool forceReadOnly;

  @override
  ConsumerState<SupplierForm> createState() => SupplierFormPanelState();
}

/// Public so a caller can address it via `GlobalKey<SupplierFormPanelState>`
/// and query [isDirty] before leaving.
class SupplierFormPanelState extends ConsumerState<SupplierForm> {
  bool get _isEdit => widget.supplierId != null;

  late bool _readOnlyOverride = widget.forceReadOnly;

  /// The detail screen's Edit replaces `?view=true` with the edit route, and
  /// the router keeps this same widget for it — so follow the new mode.
  @override
  void didUpdateWidget(SupplierForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.forceReadOnly != widget.forceReadOnly) {
      _readOnlyOverride = widget.forceReadOnly;
    }
    // A create form reopened as the supplier it just saved (FR-015a): the
    // router keeps this State, so load the new record into it.
    if (oldWidget.supplierId != widget.supplierId && _isEdit) {
      _snapshot = null;
      _loadForEdit();
    }
  }

  /// Snapshot of [SupplierFormState] captured once loading actually
  /// completes — awaited directly in [initState], not inferred from a
  /// `build()`-timing flag (spec 035 T028: a fast-resolving repository can
  /// resolve entirely within the same microtask flush that follows
  /// `addPostFrameCallback`, so Flutter never rebuilds with `loading: true`
  /// visible at all).
  SupplierFormState? _snapshot;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _loadForEdit();
    } else {
      _snapshot = ref.read(supplierFormControllerProvider);
    }
  }

  void _loadForEdit() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref
          .read(supplierFormControllerProvider.notifier)
          .loadForEdit(widget.supplierId!);
      if (mounted) {
        setState(() => _snapshot = ref.read(supplierFormControllerProvider));
      }
    });
  }

  bool isDirty() {
    final current = ref.read(supplierFormControllerProvider);
    return _snapshot != null && _snapshot != current;
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(supplierFormControllerProvider);
    final controller = ref.read(supplierFormControllerProvider.notifier);
    final access = ref.watch(accessControlProvider);
    final canCreate = access.can(SystemObject.suppliers, AccessRight.create);
    final canUpdate = access.can(SystemObject.suppliers, AccessRight.update);
    final readOnly = (_isEdit && !canUpdate) || _readOnlyOverride;
    final l10n = AppLocalizations.of(context)!;
    final addressRepo = ref.read(addressRepositoryProvider);
    final contactRepo = ref.read(contactRepositoryProvider);
    final bankAccountRepo = ref.read(bankAccountRepositoryProvider);

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
    // create form this one replaced, FR-015a), so its `saved` is not ours.
    if (_snapshot != null && (formState.saved || formState.deleted)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final createdId = formState.supplierId;
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
        access.can(SystemObject.suppliers, AccessRight.delete);

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
              key: _errorBannerKey(formState.error!),
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
            key: const Key('comment_field'),
            initialValue: formState.comment,
            decoration: InputDecoration(labelText: l10n.commentLabel),
            enabled: fieldsEnabled,
            onChanged: controller.commentChanged,
            maxLines: 3,
          ),
        ),
        // Linked records and agreements (spec 050). Linking or unlinking needs
        // the same right as saving the supplier (the sections are editable
        // exactly when the fields are); searching needs read on the linked
        // kind, creating needs create on it (FR-018, FR-019).
        const FormGridChild(span: FormGridSpan.full, Divider()),
        // Addresses and contacts pair side by side on wide tiers (§VI).
        FormGridChild(
          LinkedRecordsSection<AddressListItem>(
            key: const Key('supplier_addresses_section'),
            sectionId: 'addresses',
            title: l10n.supplierAddressesSection,
            emptyText: l10n.supplierAddressesEmpty,
            items: formState.addresses,
            idOf: (a) => a.addressId,
            labelOf: (a) => a.label,
            statusOf: (a) => a.status,
            editable: fieldsEnabled,
            searchLabel: l10n.supplierAddressLinkLabel,
            searchExisting: access.can(SystemObject.addresses, AccessRight.read)
                ? (query) async => (await addressRepo.list(
                    search: query.isEmpty ? null : query,
                    status: EntityStatus.active,
                  )).items
                : null,
            onLinked: controller.addressAdded,
            onUnlinked: (a) => controller.addressRemoved(a.addressId),
            onCreateNew: access.can(SystemObject.addresses, AccessRight.create)
                ? () => showAddressInlineCreateDialog(context)
                : null,
          ),
        ),
        FormGridChild(
          LinkedRecordsSection<Contact>(
            key: const Key('supplier_contacts_section'),
            sectionId: 'contacts',
            title: l10n.supplierContactsSection,
            emptyText: l10n.supplierContactsEmpty,
            items: formState.contacts,
            idOf: (c) => c.contactId,
            labelOf: (c) => c.name,
            subtitleOf: (c) => [
              c.jobTitle,
              c.preferredPhone,
              c.email,
            ].where((p) => p != null && p.isNotEmpty).join(' · '),
            editable: fieldsEnabled,
            searchLabel: l10n.supplierContactLinkLabel,
            searchExisting: access.can(SystemObject.contacts, AccessRight.read)
                ? (query) =>
                      contactRepo.list(search: query.isEmpty ? null : query)
                : null,
            onLinked: controller.contactAdded,
            onUnlinked: (c) => controller.contactRemoved(c.contactId),
            onCreateNew: access.can(SystemObject.contacts, AccessRight.create)
                ? () => showContactInlineCreateDialog(context)
                : null,
          ),
        ),
        const FormGridChild(span: FormGridSpan.full, Divider()),
        FormGridChild(
          span: FormGridSpan.full,
          LinkedRecordsSection<BankAccount>(
            key: const Key('supplier_bank_accounts_section'),
            sectionId: 'bank_accounts',
            title: l10n.supplierBankAccountsSection,
            emptyText: l10n.supplierBankAccountsEmpty,
            items: formState.bankAccounts,
            idOf: (b) => b.bankAccountId,
            labelOf: (b) => b.label,
            subtitleOf: (b) => b.reference,
            editable: fieldsEnabled,
            searchLabel: l10n.supplierBankAccountLinkLabel,
            searchExisting:
                access.can(SystemObject.bankAccounts, AccessRight.read)
                ? (query) async => (await bankAccountRepo.list(
                    search: query.isEmpty ? null : query,
                  )).items
                : null,
            onLinked: controller.bankAccountAdded,
            onUnlinked: (b) => controller.bankAccountRemoved(b.bankAccountId),
            onCreateNew:
                access.can(SystemObject.bankAccounts, AccessRight.create)
                ? () => showBankAccountInlineCreateDialog(context)
                : null,
          ),
        ),
        const FormGridChild(span: FormGridSpan.full, Divider()),
        FormGridChild(
          span: FormGridSpan.full,
          SupplierAgreementsSection(
            key: const Key('supplier_agreements_section'),
            supplierId: widget.supplierId,
            readOnly: readOnly,
          ),
        ),
        FormGridChild(
          span: FormGridSpan.full,
          RecordFormActions(
            mode: mode,
            saveLabel: l10n.saveButton,
            editLabel: l10n.editRecordTooltip,
            deleteLabel: l10n.deleteSupplierButton,
            isSubmitting: formState.submitting,
            editKey: const Key('edit_supplier_button'),
            saveKey: const Key('save_button'),
            deleteKey: const Key('delete_supplier_button'),
            onEdit: (canUpdate && widget.supplierId != null)
                ? (widget.onEditRequested ??
                      () => setState(() => _readOnlyOverride = false))
                : null,
            onSave: canSave
                ? (_isEdit ? controller.submitUpdate : controller.submitCreate)
                : null,
            onDelete: canDelete ? controller.delete : null,
            deleteConfirmation: RecordDeleteConfirmation(
              title: l10n.deleteSupplierConfirmTitle,
              message: l10n.deleteSupplierConfirmMessage(formState.name),
              confirmLabel: l10n.deleteButton,
              cancelLabel: l10n.cancelButton,
              confirmKey: const Key('confirm_delete_supplier_button'),
            ),
          ),
        ),
      ],
    );
  }
}

Key? _errorBannerKey(String code) {
  switch (code) {
    case SupplierFormErrorCode.saveConflict:
      return const Key('supplier_save_conflict_banner');
    case SupplierFormErrorCode.deleteConflict:
      return const Key('supplier_delete_conflict_banner');
    default:
      return null;
  }
}

String _localizeFormError(AppLocalizations l10n, String code) {
  switch (code) {
    case SupplierFormErrorCode.loadFailed:
      return l10n.supplierLoadFailedError;
    case SupplierFormErrorCode.createFailed:
      return l10n.supplierCreateFailedError;
    case SupplierFormErrorCode.updateFailed:
      return l10n.supplierUpdateFailedError;
    case SupplierFormErrorCode.deleteFailed:
      return l10n.supplierDeleteFailedError;
    case SupplierFormErrorCode.saveConflict:
      return l10n.supplierSaveConflictError;
    case SupplierFormErrorCode.deleteConflict:
      return l10n.supplierDeleteConflictError;
    case SupplierFormErrorCode.createPermissionDenied:
      return l10n.supplierCreatePermissionDeniedError;
    case SupplierFormErrorCode.updatePermissionDenied:
      return l10n.supplierUpdatePermissionDeniedError;
    case SupplierFormErrorCode.deletePermissionDenied:
      return l10n.supplierDeletePermissionDeniedError;
    default:
      return code;
  }
}

String? _localizeFieldError(AppLocalizations l10n, String? code) {
  if (code == null) return null;
  switch (code) {
    case SupplierFormErrorCode.codeRequired:
      return l10n.supplierCodeRequiredError;
    case SupplierFormErrorCode.nameRequired:
      return l10n.supplierNameRequiredError;
    case SupplierFormErrorCode.creditLimitInvalid:
      return l10n.creditLimitInvalidError;
    case SupplierFormErrorCode.creditDaysInvalid:
      return l10n.creditDaysInvalidError;
    default:
      return code;
  }
}
