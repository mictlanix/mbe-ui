import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/record_form_actions.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/responsive_form_grid.dart';
import 'package:mbe_ui/features/pricing/domain/entities/price_list.dart';
import 'package:mbe_ui/features/pricing/presentation/price_list_delete_dialog.dart';
import 'package:mbe_ui/features/pricing/presentation/price_list_form_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Create / view / edit form for a single price list (spec 035 US5 —
/// converted from the pushed `/price-lists/new` / `/price-lists/:priceListId`
/// routes to the shared record panel, `showRecordSheet`). [priceListId] is
/// `null` in create mode. See `label_form.dart` for the base pattern (spec
/// 035 T029); the delete flow here is its own review dialog
/// (`showPriceListDeleteDialog`, spec 034), not the shared
/// `RecordDeleteConfirmation`.
class PriceListForm extends ConsumerStatefulWidget {
  const PriceListForm({
    super.key,
    this.priceListId,
    this.forceReadOnly = false,
  });

  final int? priceListId;

  /// Opens the form read-only regardless of the caller's update privilege —
  /// set for a row-click open (constitution §VI). The in-panel Edit control
  /// clears this.
  final bool forceReadOnly;

  @override
  ConsumerState<PriceListForm> createState() => PriceListFormPanelState();
}

/// Public so a caller can address it via `GlobalKey<PriceListFormPanelState>`
/// and query [isDirty] from `showRecordSheet`'s `isDirty` callback.
class PriceListFormPanelState extends ConsumerState<PriceListForm> {
  bool get _isEdit => widget.priceListId != null;

  late bool _readOnlyOverride = widget.forceReadOnly;

  /// Snapshot of [PriceListFormState] captured once loading actually
  /// completes — awaited directly in [initState], not inferred from a
  /// `build()`-timing flag (spec 035 T028).
  PriceListFormState? _snapshot;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await ref
            .read(priceListFormControllerProvider.notifier)
            .loadForEdit(widget.priceListId!);
        if (mounted) {
          setState(() => _snapshot = ref.read(priceListFormControllerProvider));
        }
      });
    } else {
      _snapshot = ref.read(priceListFormControllerProvider);
    }
  }

  bool isDirty() {
    final current = ref.read(priceListFormControllerProvider);
    return _snapshot != null && _snapshot != current;
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(priceListFormControllerProvider);
    final controller = ref.read(priceListFormControllerProvider.notifier);
    final access = ref.watch(accessControlProvider);
    final canCreate = access.can(SystemObject.priceLists, AccessRight.create);
    final canUpdate = access.can(SystemObject.priceLists, AccessRight.update);
    final readOnly = (_isEdit && !canUpdate) || _readOnlyOverride;
    final l10n = AppLocalizations.of(context)!;

    if (formState.loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (formState.saved) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
    }

    final fieldsEnabled = !formState.submitting && !readOnly;
    final canSave = !readOnly && (_isEdit ? canUpdate : canCreate);
    final canDelete =
        _isEdit &&
        !readOnly &&
        access.can(SystemObject.priceLists, AccessRight.delete);

    final mode = !_isEdit
        ? RecordFormMode.create
        : (readOnly ? RecordFormMode.view : RecordFormMode.edit);

    return ResponsiveFormGrid(
      maxColumns: 2,
      children: [
        // Delete refusals are shown *inside* the review dialog instead
        // (FR-019, `PriceListDeleteDialog`'s own `ErrorBanner`) — showing
        // them here too would render the server's refusal twice, once
        // behind the modal and once inside it.
        if (formState.error != null && !_isDeleteError(formState.error!))
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
                ? () => setState(() => _readOnlyOverride = false)
                : null,
            onSave: canSave
                ? (_isEdit ? controller.submitUpdate : controller.submitCreate)
                : null,
            onDelete: canDelete
                ? () => _reviewAndDelete(context, formState, l10n)
                : null,
            // The review dialog replaces this shared component's own
            // confirmation (specs/034-price-list-retirement-ui
            // research.md R7) — `RecordFormActions` already invokes
            // `onDelete` directly whenever `deleteConfirmation` is null.
            deleteConfirmation: null,
          ),
        ),
      ],
    );
  }

  /// Opens the delete review dialog and, on a successful deletion, shows the
  /// confirmation snackbar *before* popping the screen (FR-017) —
  /// `ScaffoldMessenger` sits above the popped route, the same ordering
  /// `merge_products_screen.dart` uses. Replaces the old
  /// `formState.deleted`-driven post-frame pop (research.md R9): with the
  /// dialog on the navigation stack, that flag flipping would have popped
  /// the dialog instead of the screen.
  Future<void> _reviewAndDelete(
    BuildContext context,
    PriceListFormState formState,
    AppLocalizations l10n,
  ) async {
    final outcome = await showPriceListDeleteDialog(
      context,
      priceList: PriceList(
        priceListId: widget.priceListId!,
        name: formState.name,
      ),
    );
    if (outcome == null || !context.mounted) return;

    final fmt = ref.read(formattersProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          outcome.replacementName != null && outcome.movedCount > 0
              ? l10n.priceListDeletedWithMoveMessage(
                  outcome.movedCount,
                  fmt.display.count(outcome.movedCount),
                  outcome.replacementName!,
                )
              : l10n.priceListDeletedMessage,
        ),
      ),
    );
    if (mounted) Navigator.of(context).pop();
  }
}

bool _isDeleteError(String code) =>
    code == PriceListFormErrorCode.deleteFailed ||
    code == PriceListFormErrorCode.deletePermissionDenied;

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
