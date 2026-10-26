import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/domain/facility_type.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/record_form_actions.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/entity_status_controls.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/product_photo.dart';
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

  /// Opens the native file picker restricted to JPEG/PNG and stages the
  /// result via [FacilityFormController.logoPicked]; type/size validation
  /// happens in the controller.
  Future<void> _pickLogo(FacilityFormController controller) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png'],
      withData: true,
    );
    final file = result?.files.singleOrNull;
    final bytes = file?.bytes;
    if (file == null || bytes == null) return;
    controller.logoPicked(bytes, file.name);
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

    // A saved record whose logo upload failed stays open so the error shows
    // and the next save retries the upload.
    if ((formState.saved && formState.error == null) || formState.deleted) {
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

    final mode = !_isEdit
        ? RecordFormMode.create
        : (readOnly ? RecordFormMode.view : RecordFormMode.edit);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
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
                    controller.addressSelected(
                      created.addressId,
                      created.label,
                    );
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
              _LogoSection(
                formState: formState,
                // Absent on a read-only record (spec 049 C2); held, not
                // hidden, while a save is in flight.
                canEdit: !readOnly,
                enabled: fieldsEnabled,
                errorText: _localizeFieldError(
                  l10n,
                  formState.fieldErrors['logo'],
                ),
                onPick: () => _pickLogo(controller),
                onRemove: controller.logoRemoveRequested,
              ),
            ),
            FormGridChild(
              span: FormGridSpan.full,
              RecordFormActions(
                mode: mode,
                saveLabel: l10n.saveButton,
                editLabel: l10n.editRecordTooltip,
                deleteLabel: l10n.deleteFacilityButton,
                isSubmitting: formState.submitting,
                editKey: const Key('edit_facility_button'),
                saveKey: const Key('save_button'),
                deleteKey: const Key('delete_facility_button'),
                onEdit: (canUpdate && widget.facilityId != null)
                    ? () => context.replace('/facilities/${widget.facilityId}')
                    : null,
                onSave: canSave
                    ? (_isEdit || formState.facilityId != null
                          ? controller.submitUpdate
                          : controller.submitCreate)
                    : null,
                onDelete: canDelete ? controller.delete : null,
                deleteConfirmation: RecordDeleteConfirmation(
                  title: l10n.deleteFacilityConfirmTitle,
                  message: l10n.deleteFacilityConfirmMessage(formState.name),
                  confirmLabel: l10n.deleteButton,
                  cancelLabel: l10n.cancelButton,
                  confirmKey: const Key('confirm_delete_facility_button'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The facility logo preview plus its upload / replace / remove actions and
/// any logo field error. A staged (not yet uploaded) logo previews from
/// memory; a logo marked for removal shows the placeholder.
class _LogoSection extends StatelessWidget {
  const _LogoSection({
    required this.formState,
    required this.canEdit,
    required this.enabled,
    required this.errorText,
    required this.onPick,
    required this.onRemove,
  });

  final FacilityFormState formState;
  final bool canEdit;
  final bool enabled;
  final String? errorText;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final staged = formState.pendingLogoBytes;
    final storedUrl = formState.logoMarkedForRemoval ? null : formState.logoUrl;
    final hasLogo = staged != null || storedUrl != null;

    return Column(
      key: const Key('facility_logo_section'),
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(l10n.facilityLogoLabel, style: theme.textTheme.labelLarge),
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            if (staged != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.memory(
                  staged,
                  width: 96,
                  height: 96,
                  fit: BoxFit.contain,
                ),
              )
            else
              ProductPhoto(photoUrl: storedUrl, size: 96),
            if (canEdit)
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton.icon(
                    key: Key(
                      hasLogo
                          ? 'facility_logo_replace_button'
                          : 'facility_logo_upload_button',
                    ),
                    onPressed: enabled ? onPick : null,
                    icon: const Icon(Icons.upload),
                    label: Text(
                      hasLogo
                          ? l10n.facilityLogoReplaceButton
                          : l10n.facilityLogoUploadButton,
                    ),
                  ),
                  if (hasLogo)
                    TextButton.icon(
                      key: const Key('facility_logo_remove_button'),
                      onPressed: enabled ? onRemove : null,
                      icon: const Icon(Icons.delete_outline),
                      label: Text(l10n.facilityLogoRemoveButton),
                    ),
                ],
              ),
          ],
        ),
        if (errorText != null)
          Text(
            errorText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
      ],
    );
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
      spacing: 8,
      children: [
        Expanded(child: picker),
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
    case FacilityFormErrorCode.logoUploadFailed:
      return l10n.facilityLogoUploadFailedError;
    case FacilityFormErrorCode.logoRemoveFailed:
      return l10n.facilityLogoRemoveFailedError;
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
    case FacilityFormErrorCode.logoInvalidType:
      return l10n.facilityLogoInvalidTypeError;
    case FacilityFormErrorCode.logoTooLarge:
      return l10n.facilityLogoTooLargeError;
    default:
      return code;
  }
}
