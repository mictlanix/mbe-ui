import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/catalog_action_icons.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/responsive_form_grid.dart';
import 'package:mbe_ui/features/catalog/data/sat_catalog_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/sat_catalog_item.dart';
import 'package:mbe_ui/features/catalog/presentation/taxpayer_recipient_form_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Create / view / edit screen for a single taxpayer recipient (FR-023,
/// FR-024, FR-025, US5). [taxpayerRecipientId] is `null` in create mode.
/// Unlike the other four catalogs, this entity's id is a client-supplied
/// **String** (the RFC tax id) — editable only in create mode, mirroring
/// the Users admin screen's `user_id_field` pattern (research.md §9).
class TaxpayerRecipientDetailScreen extends ConsumerStatefulWidget {
  const TaxpayerRecipientDetailScreen({
    super.key,
    this.taxpayerRecipientId,
    this.forceReadOnly = false,
  });

  final String? taxpayerRecipientId;

  /// Forces read-only rendering — set when navigated to via a row click
  /// rather than Edit (constitution §VI), read from the `?view=true` query
  /// parameter.
  final bool forceReadOnly;

  @override
  ConsumerState<TaxpayerRecipientDetailScreen> createState() =>
      _TaxpayerRecipientDetailScreenState();
}

class _TaxpayerRecipientDetailScreenState
    extends ConsumerState<TaxpayerRecipientDetailScreen> {
  bool get _isEdit => widget.taxpayerRecipientId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(taxpayerRecipientFormControllerProvider.notifier)
            .loadForEdit(widget.taxpayerRecipientId!);
      });
    }
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
    final readOnly = (_isEdit && !canUpdate) || widget.forceReadOnly;
    final l10n = AppLocalizations.of(context)!;
    final satRepo = ref.read(satCatalogRepositoryProvider);

    final title = readOnly
        ? l10n.viewTaxpayerRecipientTitle
        : (_isEdit
              ? l10n.editTaxpayerRecipientTitle
              : l10n.newTaxpayerRecipientTitle);

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
        access.can(SystemObject.taxpayerRecipients, AccessRight.delete);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (readOnly && canUpdate && widget.taxpayerRecipientId != null)
            IconButton(
              key: const Key('edit_taxpayer_recipient_button'),
              icon: Icon(CatalogAction.edit.icon),
              tooltip: l10n.editRecordTooltip,
              onPressed: () => context.replace(
                '/taxpayer-recipients/${widget.taxpayerRecipientId}',
              ),
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
                  key: const Key('delete_taxpayer_recipient_button'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  ),
                  onPressed: formState.submitting
                      ? null
                      : () =>
                            _confirmDelete(context, controller, formState.name),
                  child: Text(l10n.deleteTaxpayerRecipientButton),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    TaxpayerRecipientFormController controller,
    String name,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteTaxpayerRecipientConfirmTitle),
        content: Text(l10n.deleteTaxpayerRecipientConfirmMessage(name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancelButton),
          ),
          FilledButton(
            key: const Key('confirm_delete_taxpayer_recipient_button'),
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
