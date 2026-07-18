import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/catalog_action_icons.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/responsive_form_grid.dart';
import 'package:mbe_ui/features/pricing/presentation/price_list_form_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Create / view / edit screen for a single price list (FR-002, FR-003,
/// FR-004). [priceListId] is `null` in create mode.
class PriceListDetailScreen extends ConsumerStatefulWidget {
  const PriceListDetailScreen({
    super.key,
    this.priceListId,
    this.forceReadOnly = false,
  });

  final int? priceListId;

  /// Forces read-only rendering — set when navigated to via a row click
  /// rather than Edit (constitution §VI), read from the `?view=true` query
  /// parameter.
  final bool forceReadOnly;

  @override
  ConsumerState<PriceListDetailScreen> createState() =>
      _PriceListDetailScreenState();
}

class _PriceListDetailScreenState extends ConsumerState<PriceListDetailScreen> {
  bool get _isEdit => widget.priceListId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(priceListFormControllerProvider.notifier)
            .loadForEdit(widget.priceListId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(priceListFormControllerProvider);
    final controller = ref.read(priceListFormControllerProvider.notifier);
    final access = ref.watch(accessControlProvider);
    final canCreate = access.can(SystemObject.priceLists, AccessRight.create);
    final canUpdate = access.can(SystemObject.priceLists, AccessRight.update);
    final readOnly = (_isEdit && !canUpdate) || widget.forceReadOnly;
    final l10n = AppLocalizations.of(context)!;

    final title = readOnly
        ? l10n.viewPriceListTitle
        : (_isEdit ? l10n.editPriceListTitle : l10n.newPriceListTitle);

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
        access.can(SystemObject.priceLists, AccessRight.delete);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (readOnly && canUpdate && widget.priceListId != null)
            IconButton(
              key: const Key('edit_price_list_button'),
              icon: Icon(CatalogAction.edit.icon),
              tooltip: l10n.editRecordTooltip,
              onPressed: () =>
                  context.replace('/price-lists/${widget.priceListId}'),
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
              span: FormGridSpan.full,
              TextFormField(
                key: const Key('price_list_name_field'),
                initialValue: formState.name,
                decoration: InputDecoration(
                  labelText: l10n.priceListNameLabel,
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
                key: const Key('price_list_high_margin_field'),
                initialValue: formState.highProfitMargin,
                decoration: InputDecoration(
                  labelText: l10n.priceListHighProfitMarginLabel,
                  errorText: _localizeFieldError(
                    l10n,
                    formState.fieldErrors['highProfitMargin'] ??
                        formState.fieldErrors['high_profit_margin'],
                  ),
                ),
                enabled: fieldsEnabled,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: controller.highProfitMarginChanged,
              ),
            ),
            FormGridChild(
              TextFormField(
                key: const Key('price_list_low_margin_field'),
                initialValue: formState.lowProfitMargin,
                decoration: InputDecoration(
                  labelText: l10n.priceListLowProfitMarginLabel,
                  errorText: _localizeFieldError(
                    l10n,
                    formState.fieldErrors['lowProfitMargin'] ??
                        formState.fieldErrors['low_profit_margin'],
                  ),
                ),
                enabled: fieldsEnabled,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: controller.lowProfitMarginChanged,
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
                  key: const Key('delete_price_list_button'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  ),
                  onPressed: formState.submitting
                      ? null
                      : () =>
                            _confirmDelete(context, controller, formState.name),
                  child: Text(l10n.deletePriceListButton),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    PriceListFormController controller,
    String name,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deletePriceListConfirmTitle),
        content: Text(l10n.deletePriceListConfirmMessage(name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancelButton),
          ),
          FilledButton(
            key: const Key('confirm_delete_price_list_button'),
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
    case PriceListFormErrorCode.loadFailed:
      return l10n.priceListLoadFailedError;
    case PriceListFormErrorCode.createFailed:
      return l10n.priceListCreateFailedError;
    case PriceListFormErrorCode.updateFailed:
      return l10n.priceListUpdateFailedError;
    case PriceListFormErrorCode.deleteFailed:
      return l10n.priceListDeleteFailedError;
    case PriceListFormErrorCode.createPermissionDenied:
      return l10n.priceListCreatePermissionDeniedError;
    case PriceListFormErrorCode.updatePermissionDenied:
      return l10n.priceListUpdatePermissionDeniedError;
    case PriceListFormErrorCode.deletePermissionDenied:
      return l10n.priceListDeletePermissionDeniedError;
    default:
      return code;
  }
}

String? _localizeFieldError(AppLocalizations l10n, String? code) {
  if (code == null) return null;
  switch (code) {
    case PriceListFormErrorCode.nameRequired:
      return l10n.priceListNameRequiredError;
    case PriceListFormErrorCode.marginInvalid:
      return l10n.priceListMarginInvalidError;
    default:
      return code;
  }
}
