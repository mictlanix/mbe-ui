import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/record_form_actions.dart';
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
              span: FormGridSpan.full,
              RecordFormActions(
                mode: mode,
                saveLabel: l10n.saveButton,
                editLabel: l10n.editRecordTooltip,
                deleteLabel: l10n.deletePriceListButton,
                isSubmitting: formState.submitting,
                editKey: const Key('edit_price_list_button'),
                saveKey: const Key('save_button'),
                deleteKey: const Key('delete_price_list_button'),
                onEdit: (canUpdate && widget.priceListId != null)
                    ? () =>
                          context.replace('/price-lists/${widget.priceListId}')
                    : null,
                onSave: canSave
                    ? (_isEdit
                          ? controller.submitUpdate
                          : controller.submitCreate)
                    : null,
                onDelete: canDelete ? controller.delete : null,
                deleteConfirmation: RecordDeleteConfirmation(
                  title: l10n.deletePriceListConfirmTitle,
                  message: l10n.deletePriceListConfirmMessage(formState.name),
                  confirmLabel: l10n.deleteButton,
                  cancelLabel: l10n.cancelButton,
                  confirmKey: const Key('confirm_delete_price_list_button'),
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
    default:
      return code;
  }
}
