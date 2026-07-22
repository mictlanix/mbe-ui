import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/domain/facility_type.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/catalog_action_icons.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/entity_status_controls.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/responsive_form_grid.dart';
import 'package:mbe_ui/features/catalog/data/address_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/sat_catalog_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/taxpayer_issuer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/address_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/sat_catalog_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_issuer_list_item.dart';
import 'package:mbe_ui/features/catalog/presentation/address_inline_create.dart';
import 'package:mbe_ui/features/catalog/presentation/facility_form_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Create / view / edit screen for a single facility (FR-028 – FR-035, US4).
/// [facilityId] is `null` in create mode.
class FacilityDetailScreen extends ConsumerStatefulWidget {
  const FacilityDetailScreen({
    super.key,
    this.facilityId,
    this.forceReadOnly = false,
  });

  final int? facilityId;

  /// Forces read-only rendering — set when navigated to via a row click
  /// rather than Edit (constitution §VI), read from the `?view=true` query
  /// parameter.
  final bool forceReadOnly;

  @override
  ConsumerState<FacilityDetailScreen> createState() =>
      _FacilityDetailScreenState();
}

class _FacilityDetailScreenState extends ConsumerState<FacilityDetailScreen> {
  bool get _isEdit => widget.facilityId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(facilityFormControllerProvider.notifier)
            .loadForEdit(widget.facilityId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(facilityFormControllerProvider);
    final controller = ref.read(facilityFormControllerProvider.notifier);
    final access = ref.watch(accessControlProvider);
    final canCreate = access.can(SystemObject.facilities, AccessRight.create);
    final canUpdate = access.can(SystemObject.facilities, AccessRight.update);
    final canReadTaxpayers = access.can(
      SystemObject.taxpayers,
      AccessRight.read,
    );
    final canCreateAddress = access.can(
      SystemObject.addresses,
      AccessRight.create,
    );
    final readOnly = (_isEdit && !canUpdate) || widget.forceReadOnly;
    final l10n = AppLocalizations.of(context)!;
    final satRepo = ref.read(satCatalogRepositoryProvider);
    final addressRepo = ref.read(addressRepositoryProvider);
    final taxpayerRepo = ref.read(taxpayerIssuerRepositoryProvider);

    final title = readOnly
        ? l10n.viewFacilityTitle
        : (_isEdit ? l10n.editFacilityTitle : l10n.newFacilityTitle);

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
        access.can(SystemObject.facilities, AccessRight.delete);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (readOnly && canUpdate && widget.facilityId != null)
            IconButton(
              key: const Key('edit_facility_button'),
              icon: Icon(CatalogAction.edit.icon),
              tooltip: l10n.editRecordTooltip,
              onPressed: () =>
                  context.replace('/facilities/${widget.facilityId}'),
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
                  labelText: l10n.columnCode,
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
              DropdownButtonFormField<FacilityType>(
                key: const Key('facility_type_field'),
                initialValue: formState.type,
                decoration: InputDecoration(labelText: l10n.columnType),
                items: [
                  DropdownMenuItem(
                    value: FacilityType.store,
                    child: Text(l10n.facilityTypeStore),
                  ),
                  DropdownMenuItem(
                    value: FacilityType.productionSite,
                    child: Text(l10n.facilityTypeProductionSite),
                  ),
                ],
                onChanged: fieldsEnabled
                    ? (v) {
                        if (v != null) controller.typeChanged(v);
                      }
                    : null,
              ),
            ),
            FormGridChild(
              EntityStatusFormField(
                value: formState.status,
                onChanged: fieldsEnabled ? controller.statusChanged : null,
              ),
            ),
            FormGridChild(
              CatalogEntityPicker<SatCatalogItem>(
                key: const Key('location_field'),
                label: l10n.columnLocation,
                displayStringForOption: (s) => s.description ?? s.code,
                optionsBuilder: (query) async {
                  final result = await satRepo.listPostalCodes(
                    search: query.isEmpty ? null : query,
                  );
                  return result.items;
                },
                onSelected: (s) => controller.locationSelected(
                  s.code,
                  s.description ?? s.code,
                ),
                initialDisplayText: formState.locationDisplayText,
                errorText: _localizeFieldError(
                  l10n,
                  formState.fieldErrors['location'],
                ),
                enabled: fieldsEnabled,
              ),
            ),
            // Address picker + inline-create (FR-031/FR-032). The
            // inline-create button is shown only with create privilege on
            // addresses; without it the picker still works over existing
            // addresses.
            FormGridChild(
              _AddressField(
                displayText: formState.addressDisplayText,
                errorText: _localizeFieldError(
                  l10n,
                  formState.fieldErrors['address'],
                ),
                enabled: fieldsEnabled,
                showInlineCreate: fieldsEnabled && canCreateAddress,
                optionsBuilder: (query) async {
                  final result = await addressRepo.list(
                    search: query.isEmpty ? null : query,
                  );
                  return result.items;
                },
                onSelected: (a) =>
                    controller.addressSelected(a.addressId, a.label),
                onCreatePressed: () async {
                  final created = await showAddressInlineCreateDialog(context);
                  if (created != null) {
                    controller.addressSelected(created.addressId, created.label);
                  }
                },
              ),
            ),
            // Taxpayer autocomplete (FR-034), gated on taxpayers(24); it
            // degrades to a shape-validated typed RFC entry when the user
            // cannot read taxpayers. There is deliberately NO inline
            // create-issuer path (FR-034a).
            FormGridChild(
              canReadTaxpayers
                  ? CatalogEntityPicker<TaxpayerIssuerListItem>(
                      key: const Key('taxpayer_field'),
                      label: l10n.columnTaxpayer,
                      displayStringForOption: (t) => t.displayText,
                      optionsBuilder: (query) async {
                        final result = await taxpayerRepo.list(
                          search: query.isEmpty ? null : query,
                        );
                        return result.items;
                      },
                      onSelected: (t) =>
                          controller.taxpayerSelected(t.rfc, t.displayText),
                      initialDisplayText: formState.taxpayerDisplayText,
                      errorText: _localizeFieldError(
                        l10n,
                        formState.fieldErrors['taxpayer'],
                      ),
                      enabled: fieldsEnabled,
                    )
                  : TextFormField(
                      key: const Key('taxpayer_rfc_field'),
                      initialValue: formState.taxpayerRfc,
                      maxLength: 13,
                      decoration: InputDecoration(
                        labelText: l10n.columnTaxpayer,
                        errorText: _localizeFieldError(
                          l10n,
                          formState.fieldErrors['taxpayer'],
                        ),
                      ),
                      enabled: fieldsEnabled,
                      onChanged: controller.taxpayerRfcTyped,
                    ),
            ),
            FormGridChild(
              TextFormField(
                key: const Key('receipt_message_field'),
                initialValue: formState.receiptMessage,
                decoration: InputDecoration(
                  labelText: l10n.facilityReceiptMessageLabel,
                ),
                enabled: fieldsEnabled,
                onChanged: controller.receiptMessageChanged,
              ),
            ),
            FormGridChild(
              TextFormField(
                key: const Key('default_batch_field'),
                initialValue: formState.defaultBatch,
                decoration: InputDecoration(
                  labelText: l10n.facilityDefaultBatchLabel,
                ),
                enabled: fieldsEnabled,
                onChanged: controller.defaultBatchChanged,
              ),
            ),
            FormGridChild(
              span: FormGridSpan.full,
              TextFormField(
                key: const Key('logo_field'),
                initialValue: formState.logo,
                decoration: InputDecoration(
                  labelText: l10n.facilityLogoLabel,
                ),
                enabled: fieldsEnabled,
                onChanged: controller.logoChanged,
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
                  key: const Key('delete_facility_button'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  ),
                  onPressed: formState.submitting
                      ? null
                      : () =>
                            _confirmDelete(context, controller, formState.name),
                  child: Text(l10n.deleteFacilityButton),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    FacilityFormController controller,
    String name,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteFacilityConfirmTitle),
        content: Text(l10n.deleteFacilityConfirmMessage(name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancelButton),
          ),
          FilledButton(
            key: const Key('confirm_delete_facility_button'),
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

/// The facility form's address field: a [CatalogEntityPicker] plus an
/// optional inline "new address" action (FR-031/FR-032). The create action
/// is shown only when [showInlineCreate] is true (the caller gates it on
/// `addresses(11)` create privilege).
class _AddressField extends StatelessWidget {
  const _AddressField({
    required this.displayText,
    required this.errorText,
    required this.enabled,
    required this.showInlineCreate,
    required this.optionsBuilder,
    required this.onSelected,
    required this.onCreatePressed,
  });

  final String displayText;
  final String? errorText;
  final bool enabled;
  final bool showInlineCreate;
  final Future<Iterable<AddressListItem>> Function(String query) optionsBuilder;
  final ValueChanged<AddressListItem> onSelected;
  final VoidCallback onCreatePressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final picker = CatalogEntityPicker<AddressListItem>(
      key: const Key('address_field'),
      label: l10n.columnAddress,
      displayStringForOption: (a) => a.label,
      optionsBuilder: optionsBuilder,
      onSelected: onSelected,
      initialDisplayText: displayText,
      errorText: errorText,
      enabled: enabled,
    );

    if (!showInlineCreate) return picker;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: picker),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: IconButton.outlined(
            key: const Key('new_address_button'),
            icon: const Icon(Icons.add_location_alt_outlined),
            tooltip: l10n.newAddressTooltip,
            onPressed: onCreatePressed,
          ),
        ),
      ],
    );
  }
}

String _localizeFormError(AppLocalizations l10n, String code) {
  switch (code) {
    case FacilityFormErrorCode.loadFailed:
      return l10n.facilityLoadFailedError;
    case FacilityFormErrorCode.createFailed:
      return l10n.facilityCreateFailedError;
    case FacilityFormErrorCode.updateFailed:
      return l10n.facilityUpdateFailedError;
    case FacilityFormErrorCode.deleteFailed:
      return l10n.facilityDeleteFailedError;
    case FacilityFormErrorCode.createPermissionDenied:
      return l10n.facilityCreatePermissionDeniedError;
    case FacilityFormErrorCode.updatePermissionDenied:
      return l10n.facilityUpdatePermissionDeniedError;
    case FacilityFormErrorCode.deletePermissionDenied:
      return l10n.facilityDeletePermissionDeniedError;
    default:
      return code;
  }
}

String? _localizeFieldError(AppLocalizations l10n, String? code) {
  if (code == null) return null;
  switch (code) {
    case FacilityFormErrorCode.codeRequired:
      return l10n.facilityCodeRequiredError;
    case FacilityFormErrorCode.nameRequired:
      return l10n.facilityNameRequiredError;
    case FacilityFormErrorCode.locationRequired:
      return l10n.facilityLocationRequiredError;
    case FacilityFormErrorCode.addressRequired:
      return l10n.facilityAddressRequiredError;
    case FacilityFormErrorCode.taxpayerRequired:
      return l10n.facilityTaxpayerRequiredError;
    case FacilityFormErrorCode.taxpayerInvalid:
      return l10n.facilityTaxpayerInvalidError;
    default:
      return code;
  }
}
