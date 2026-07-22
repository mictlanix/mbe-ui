import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mbe_api_client/mbe_api_client.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/domain/fiscal_certification_provider_label.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/catalog_action_icons.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/responsive_form_grid.dart';
import 'package:mbe_ui/features/catalog/data/sat_catalog_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/sat_catalog_item.dart';
import 'package:mbe_ui/features/catalog/presentation/taxpayer_certificates_section.dart';
import 'package:mbe_ui/features/catalog/presentation/taxpayer_issuer_form_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Create / view / edit screen for a single taxpayer issuer ("Razón
/// Social"; FR-011, FR-012, FR-015, FR-016, US2). [rfc] is `null` in create
/// mode. Unlike the int-keyed catalogs, this entity's id is a client-supplied
/// **String** (the RFC) — editable only in create mode, mirroring the
/// Taxpayer Recipient screen's `taxpayer_recipient_id_field` pattern
/// (research §4).
///
/// For a **persisted** issuer, also hosts the Certificates section (US3,
/// FR-019/FR-025) below the issuer's own fields — a divider-delimited child
/// collection, not a route of its own (research §9).
class TaxpayerIssuerDetailScreen extends ConsumerStatefulWidget {
  const TaxpayerIssuerDetailScreen({
    super.key,
    this.rfc,
    this.forceReadOnly = false,
  });

  final String? rfc;

  /// Forces read-only rendering — set when navigated to via a row click
  /// rather than Edit (constitution §VI), read from the `?view=true` query
  /// parameter.
  final bool forceReadOnly;

  @override
  ConsumerState<TaxpayerIssuerDetailScreen> createState() =>
      _TaxpayerIssuerDetailScreenState();
}

class _TaxpayerIssuerDetailScreenState
    extends ConsumerState<TaxpayerIssuerDetailScreen> {
  bool get _isEdit => widget.rfc != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(taxpayerIssuerFormControllerProvider.notifier)
            .loadForEdit(widget.rfc!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(taxpayerIssuerFormControllerProvider);
    final controller = ref.read(taxpayerIssuerFormControllerProvider.notifier);
    final access = ref.watch(accessControlProvider);
    final canCreate = access.can(SystemObject.taxpayers, AccessRight.create);
    final canUpdate = access.can(SystemObject.taxpayers, AccessRight.update);
    final readOnly = (_isEdit && !canUpdate) || widget.forceReadOnly;
    final l10n = AppLocalizations.of(context)!;
    final satRepo = ref.read(satCatalogRepositoryProvider);

    final title = readOnly
        ? l10n.viewTaxpayerIssuerTitle
        : (_isEdit ? l10n.editTaxpayerIssuerTitle : l10n.newTaxpayerIssuerTitle);

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
        access.can(SystemObject.taxpayers, AccessRight.delete);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (readOnly && canUpdate && widget.rfc != null)
            IconButton(
              key: const Key('edit_taxpayer_issuer_button'),
              icon: Icon(CatalogAction.edit.icon),
              tooltip: l10n.editRecordTooltip,
              onPressed: () =>
                  context.replace('/taxpayer-issuers/${widget.rfc}'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ResponsiveFormGrid(
              // Keyed on isEdit (false until `loadForEdit` resolves, then
              // true) so the field subtree remounts once loaded data
              // arrives — `TextFormField`/`CatalogEntityPicker` seed from
              // `initialValue`/`initialDisplayText` only on first mount, so
              // a fast-resolving load can otherwise leave every field
              // showing its pre-load (empty) value (payment_method_option_
              // detail_screen.dart carries the identical fix + rationale).
              key: ValueKey(formState.isEdit),
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
                    key: const Key('rfc_field'),
                    initialValue: formState.rfc,
                    decoration: InputDecoration(
                      labelText: l10n.rfcFieldLabel,
                      errorText: _localizeFieldError(
                        l10n,
                        // Client-side validation keys this 'rfc'; a server
                        // rejection (e.g. duplicate RFC, FR-017) keys its
                        // field error by the wire name `taxpayer_issuer_id`
                        // instead — check both so a server-side duplicate
                        // rejection surfaces under this field either way.
                        formState.fieldErrors['rfc'] ??
                            formState.fieldErrors['taxpayer_issuer_id'],
                      ),
                    ),
                    // Editable only on create — immutable once persisted
                    // (FR-012, Taxpayer Recipient precedent).
                    enabled: fieldsEnabled && !_isEdit,
                    onChanged: controller.rfcChanged,
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
                    initialDisplayText: formState.regimeDisplayText,
                    errorText: _localizeFieldError(
                      l10n,
                      formState.fieldErrors['regime'],
                    ),
                    enabled: fieldsEnabled,
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
                    initialDisplayText: formState.postalCodeDisplayText,
                    enabled: fieldsEnabled,
                  ),
                ),
                FormGridChild(
                  DropdownButtonFormField<FiscalCertificationProvider>(
                    key: const Key('provider_field'),
                    initialValue: formState.provider,
                    decoration: InputDecoration(
                      labelText: l10n.providerFieldLabel,
                    ),
                    items: [
                      for (final provider in fiscalCertificationProviderValues)
                        DropdownMenuItem(
                          value: provider,
                          child: Text(
                            fiscalCertificationProviderLabel(l10n, provider),
                          ),
                        ),
                    ],
                    onChanged: fieldsEnabled
                        ? (value) {
                            if (value != null) controller.providerChanged(value);
                          }
                        : null,
                  ),
                ),
                FormGridChild(
                  span: FormGridSpan.full,
                  TextFormField(
                    key: const Key('comment_field'),
                    initialValue: formState.comment,
                    decoration: InputDecoration(labelText: l10n.columnComment),
                    enabled: fieldsEnabled,
                    onChanged: controller.commentChanged,
                    maxLines: 3,
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
                      key: const Key('delete_taxpayer_issuer_button'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        foregroundColor: Theme.of(context).colorScheme.onError,
                      ),
                      onPressed: formState.submitting
                          ? null
                          : () => _confirmDelete(
                              context,
                              controller,
                              formState.name,
                            ),
                      child: Text(l10n.deleteTaxpayerIssuerButton),
                    ),
                  ),
              ],
            ),
            // Certificates section (US3, FR-019, FR-025): only for a
            // persisted issuer — a certificate needs an existing RFC to
            // belong to, so it never renders on the create form.
            if (_isEdit) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              TaxpayerCertificatesSection(
                rfc: widget.rfc!,
                // Agregar follows the SAME read-only flag as every other
                // body mutation control on this screen — never exposed on a
                // read-only/View render, even to a create-privileged user
                // (FR-025, constitution §VI row-click-is-read-only rule).
                readOnly: readOnly,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    TaxpayerIssuerFormController controller,
    String name,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteTaxpayerIssuerConfirmTitle),
        content: Text(l10n.deleteTaxpayerIssuerConfirmMessage(name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancelButton),
          ),
          FilledButton(
            key: const Key('confirm_delete_taxpayer_issuer_button'),
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
    case TaxpayerIssuerFormErrorCode.loadFailed:
      return l10n.taxpayerIssuerLoadFailedError;
    case TaxpayerIssuerFormErrorCode.createFailed:
      return l10n.taxpayerIssuerCreateFailedError;
    case TaxpayerIssuerFormErrorCode.updateFailed:
      return l10n.taxpayerIssuerUpdateFailedError;
    case TaxpayerIssuerFormErrorCode.deleteFailed:
      return l10n.taxpayerIssuerDeleteFailedError;
    case TaxpayerIssuerFormErrorCode.createPermissionDenied:
      return l10n.taxpayerIssuerCreatePermissionDeniedError;
    case TaxpayerIssuerFormErrorCode.updatePermissionDenied:
      return l10n.taxpayerIssuerUpdatePermissionDeniedError;
    case TaxpayerIssuerFormErrorCode.deletePermissionDenied:
      return l10n.taxpayerIssuerDeletePermissionDeniedError;
    default:
      return code;
  }
}

String? _localizeFieldError(AppLocalizations l10n, String? code) {
  if (code == null) return null;
  switch (code) {
    case TaxpayerIssuerFormErrorCode.rfcRequired:
      return l10n.taxpayerIssuerRfcRequiredError;
    case TaxpayerIssuerFormErrorCode.nameRequired:
      return l10n.taxpayerIssuerNameRequiredError;
    case TaxpayerIssuerFormErrorCode.regimeRequired:
      return l10n.taxpayerIssuerRegimeRequiredError;
    default:
      return code;
  }
}
