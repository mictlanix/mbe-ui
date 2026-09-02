import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/record_form_actions.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/responsive_form_grid.dart';
import 'package:mbe_ui/features/catalog/data/sat_catalog_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/sat_catalog_item.dart';
import 'package:mbe_ui/features/catalog/presentation/taxpayer_recipient_form_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Create / view / edit form for a single taxpayer recipient (spec 035
/// US5 — converted from the pushed `/taxpayer-recipients/new` /
/// `/taxpayer-recipients/:taxpayerRecipientId` routes to the shared record
/// panel, `showRecordSheet`). [taxpayerRecipientId] is `null` in create
/// mode. Unlike the other entities, this one's id is a client-supplied
/// **String** (the RFC tax id) — editable only in create mode, mirroring
/// the Users admin screen's `user_id_field` pattern (research.md §9). Owns
/// two `CatalogEntityPicker`s (postal code, tax regime) against the SAT
/// catalog. See `label_form.dart` for the base pattern (spec 035 T029).
class TaxpayerRecipientForm extends ConsumerStatefulWidget {
  const TaxpayerRecipientForm({
    super.key,
    this.taxpayerRecipientId,
    this.forceReadOnly = false,
  });

  final String? taxpayerRecipientId;

  /// Opens the form read-only regardless of the caller's update privilege —
  /// set for a row-click open (constitution §VI). The in-panel Edit control
  /// clears this.
  final bool forceReadOnly;

  @override
  ConsumerState<TaxpayerRecipientForm> createState() =>
      TaxpayerRecipientFormPanelState();
}

/// Public so a caller can address it via
/// `GlobalKey<TaxpayerRecipientFormPanelState>` and query [isDirty] from
/// `showRecordSheet`'s `isDirty` callback.
class TaxpayerRecipientFormPanelState
    extends ConsumerState<TaxpayerRecipientForm> {
  bool get _isEdit => widget.taxpayerRecipientId != null;

  late bool _readOnlyOverride = widget.forceReadOnly;

  /// Snapshot of [TaxpayerRecipientFormState] captured once loading
  /// actually completes — awaited directly in [initState], not inferred
  /// from a `build()`-timing flag (spec 035 T028).
  TaxpayerRecipientFormState? _snapshot;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await ref
            .read(taxpayerRecipientFormControllerProvider.notifier)
            .loadForEdit(widget.taxpayerRecipientId!);
        if (mounted) {
          setState(
            () => _snapshot = ref.read(
              taxpayerRecipientFormControllerProvider,
            ),
          );
        }
      });
    } else {
      _snapshot = ref.read(taxpayerRecipientFormControllerProvider);
    }
  }

  bool isDirty() {
    final current = ref.read(taxpayerRecipientFormControllerProvider);
    return _snapshot != null && _snapshot != current;
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(taxpayerRecipientFormControllerProvider);
    final controller = ref.read(
      taxpayerRecipientFormControllerProvider.notifier,
    );
    final access = ref.watch(accessControlProvider);
    final canCreate = access.can(
      SystemObject.taxpayerRecipients,
      AccessRight.create,
    );
    final canUpdate = access.can(
      SystemObject.taxpayerRecipients,
      AccessRight.update,
    );
    final readOnly = (_isEdit && !canUpdate) || _readOnlyOverride;
    final l10n = AppLocalizations.of(context)!;
    final satRepo = ref.read(satCatalogRepositoryProvider);

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
        access.can(SystemObject.taxpayerRecipients, AccessRight.delete);

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
          TextFormField(
            key: const Key('taxpayer_recipient_id_field'),
            initialValue: formState.taxpayerRecipientId,
            decoration: InputDecoration(
              labelText: l10n.taxpayerRecipientIdLabel,
              errorText: _localizeFieldError(
                l10n,
                formState.fieldErrors['taxpayerRecipientId'],
              ),
            ),
            // Editable only on create — immutable once persisted
            // (research.md §9).
            enabled: fieldsEnabled && !_isEdit,
            onChanged: controller.taxpayerRecipientIdChanged,
          ),
        ),
        FormGridChild(
          TextFormField(
            key: const Key('taxpayer_recipient_name_field'),
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
            key: const Key('taxpayer_recipient_email_field'),
            initialValue: formState.email,
            decoration: InputDecoration(
              labelText: l10n.emailLabel,
              errorText: _localizeFieldError(
                l10n,
                formState.fieldErrors['email'],
              ),
            ),
            enabled: fieldsEnabled,
            onChanged: controller.emailChanged,
          ),
        ),
        FormGridChild(
          CatalogEntityPicker<SatCatalogItem>(
            key: const Key('postal_code_field'),
            label: l10n.postalCodeFieldLabel,
            displayStringForOption: (item) => item.description != null
                ? '${item.code} — ${item.description}'
                : item.code,
            optionsBuilder: (query) async {
              final result = await satRepo.listPostalCodes(
                search: query.isEmpty ? null : query,
              );
              return result.items;
            },
            onSelected: (item) => controller.postalCodeSelected(
              item.code,
              item.description ?? item.code,
            ),
            initialDisplayText: formState.postalCodeDisplayText.isNotEmpty
                ? formState.postalCodeDisplayText
                : (formState.postalCode ?? ''),
            enabled: fieldsEnabled,
          ),
        ),
        FormGridChild(
          CatalogEntityPicker<SatCatalogItem>(
            key: const Key('regime_field'),
            label: l10n.regimeFieldLabel,
            displayStringForOption: (item) => item.description != null
                ? '${item.code} — ${item.description}'
                : item.code,
            optionsBuilder: (query) async {
              final result = await satRepo.listTaxRegimes(
                search: query.isEmpty ? null : query,
              );
              return result.items;
            },
            onSelected: (item) => controller.regimeSelected(
              item.code,
              item.description ?? item.code,
            ),
            initialDisplayText: formState.regimeDisplayText.isNotEmpty
                ? formState.regimeDisplayText
                : (formState.regime ?? ''),
            enabled: fieldsEnabled,
          ),
        ),
        FormGridChild(
          span: FormGridSpan.full,
          RecordFormActions(
            mode: mode,
            saveLabel: l10n.saveButton,
            editLabel: l10n.editRecordTooltip,
            deleteLabel: l10n.deleteTaxpayerRecipientButton,
            isSubmitting: formState.submitting,
            editKey: const Key('edit_taxpayer_recipient_button'),
            saveKey: const Key('save_button'),
            deleteKey: const Key('delete_taxpayer_recipient_button'),
            onEdit: (canUpdate && widget.taxpayerRecipientId != null)
                ? () => setState(() => _readOnlyOverride = false)
                : null,
            onSave: canSave
                ? (_isEdit ? controller.submitUpdate : controller.submitCreate)
                : null,
            onDelete: canDelete ? controller.delete : null,
            deleteConfirmation: RecordDeleteConfirmation(
              title: l10n.deleteTaxpayerRecipientConfirmTitle,
              message: l10n.deleteTaxpayerRecipientConfirmMessage(
                formState.name,
              ),
              confirmLabel: l10n.deleteButton,
              cancelLabel: l10n.cancelButton,
              confirmKey: const Key(
                'confirm_delete_taxpayer_recipient_button',
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
    case TaxpayerRecipientFormErrorCode.loadFailed:
      return l10n.taxpayerRecipientLoadFailedError;
    case TaxpayerRecipientFormErrorCode.createFailed:
      return l10n.taxpayerRecipientCreateFailedError;
    case TaxpayerRecipientFormErrorCode.updateFailed:
      return l10n.taxpayerRecipientUpdateFailedError;
    case TaxpayerRecipientFormErrorCode.deleteFailed:
      return l10n.taxpayerRecipientDeleteFailedError;
    case TaxpayerRecipientFormErrorCode.createPermissionDenied:
      return l10n.taxpayerRecipientCreatePermissionDeniedError;
    case TaxpayerRecipientFormErrorCode.updatePermissionDenied:
      return l10n.taxpayerRecipientUpdatePermissionDeniedError;
    case TaxpayerRecipientFormErrorCode.deletePermissionDenied:
      return l10n.taxpayerRecipientDeletePermissionDeniedError;
    default:
      return code;
  }
}

String? _localizeFieldError(AppLocalizations l10n, String? code) {
  if (code == null) return null;
  switch (code) {
    case TaxpayerRecipientFormErrorCode.idRequired:
      return l10n.taxpayerRecipientIdRequiredError;
    case TaxpayerRecipientFormErrorCode.nameRequired:
      return l10n.taxpayerRecipientNameRequiredError;
    case TaxpayerRecipientFormErrorCode.emailRequired:
      return l10n.taxpayerRecipientEmailRequiredError;
    default:
      return code;
  }
}
