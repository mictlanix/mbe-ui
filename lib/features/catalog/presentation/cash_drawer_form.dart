import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/record_form_actions.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/entity_status_controls.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/responsive_form_grid.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/facility_list_item.dart';
import 'package:mbe_ui/features/catalog/presentation/cash_drawer_form_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Create / view / edit form for a single cash drawer (spec 035 US5 —
/// converted from the pushed `/cash-drawers/new` /
/// `/cash-drawers/:cashDrawerId` routes to the shared record panel,
/// `showRecordSheet`). [cashDrawerId] is `null` in create mode. Unlike the
/// top-level catalogs, a cash drawer is a facility child reached only from
/// `FacilityCard`'s child actions in `facilities_list_screen.dart`, never
/// from its own list screen. See `label_form.dart` for the base pattern
/// (spec 035 T029).
class CashDrawerForm extends ConsumerStatefulWidget {
  const CashDrawerForm({
    super.key,
    this.cashDrawerId,
    this.forceReadOnly = false,
    this.facilityId,
  });

  final int? cashDrawerId;

  /// Opens the form read-only regardless of the caller's update privilege —
  /// set for a row-click open (constitution §VI). The in-panel Edit control
  /// clears this.
  final bool forceReadOnly;

  /// Pre-selects the facility picker in create mode — set when reached from
  /// a facility card's "+ Caja" (018-nested-facility-management
  /// FR-022/FR-023). Ignored in edit mode, where [loadForEdit] supplies the
  /// real facility.
  final int? facilityId;

  @override
  ConsumerState<CashDrawerForm> createState() => CashDrawerFormPanelState();
}

/// Public so a caller can address it via `GlobalKey<CashDrawerFormPanelState>`
/// and query [isDirty] from `showRecordSheet`'s `isDirty` callback.
class CashDrawerFormPanelState extends ConsumerState<CashDrawerForm> {
  bool get _isEdit => widget.cashDrawerId != null;

  late bool _readOnlyOverride = widget.forceReadOnly;

  /// Snapshot of [CashDrawerFormState] captured once loading actually
  /// completes — awaited directly in [initState], not inferred from a
  /// `build()`-timing flag (spec 035 T028).
  CashDrawerFormState? _snapshot;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await ref
            .read(cashDrawerFormControllerProvider.notifier)
            .loadForEdit(widget.cashDrawerId!);
        if (mounted) {
          setState(
            () => _snapshot = ref.read(cashDrawerFormControllerProvider),
          );
        }
      });
    } else if (widget.facilityId != null) {
      final facilityId = widget.facilityId!;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final name = await ref.read(
          facilityDisplayNameProvider(facilityId).future,
        );
        if (!mounted) return;
        ref
            .read(cashDrawerFormControllerProvider.notifier)
            .facilitySelected(facilityId, name ?? '');
        setState(
          () => _snapshot = ref.read(cashDrawerFormControllerProvider),
        );
      });
    } else {
      _snapshot = ref.read(cashDrawerFormControllerProvider);
    }
  }

  bool isDirty() {
    final current = ref.read(cashDrawerFormControllerProvider);
    return _snapshot != null && _snapshot != current;
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(cashDrawerFormControllerProvider);
    final controller = ref.read(cashDrawerFormControllerProvider.notifier);
    final access = ref.watch(accessControlProvider);
    final canCreate = access.can(SystemObject.cashDrawers, AccessRight.create);
    final canUpdate = access.can(SystemObject.cashDrawers, AccessRight.update);
    final readOnly = (_isEdit && !canUpdate) || _readOnlyOverride;
    final l10n = AppLocalizations.of(context)!;
    final facilityRepo = ref.read(facilityRepositoryProvider);

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
        access.can(SystemObject.cashDrawers, AccessRight.delete);

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
          span: FormGridSpan.full,
          CatalogEntityPicker<FacilityListItem>(
            key: const Key('facility_field'),
            label: l10n.facilityFieldLabel,
            displayStringForOption: (f) => f.name,
            optionsBuilder: (query) async {
              final result = await facilityRepo.list(
                search: query.isEmpty ? null : query,
              );
              return result.items;
            },
            onSelected: (f) =>
                controller.facilitySelected(f.facilityId, f.name),
            initialDisplayText: formState.facilityDisplayText,
            errorText: _localizeFieldError(
              l10n,
              formState.fieldErrors['facility'],
            ),
            enabled: fieldsEnabled,
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
        FormGridChild(
          span: FormGridSpan.full,
          EntityStatusFormField(
            value: formState.status,
            onChanged: fieldsEnabled ? controller.statusChanged : null,
          ),
        ),
        FormGridChild(
          span: FormGridSpan.full,
          RecordFormActions(
            mode: mode,
            saveLabel: l10n.saveButton,
            editLabel: l10n.editRecordTooltip,
            deleteLabel: l10n.deleteCashDrawerButton,
            isSubmitting: formState.submitting,
            editKey: const Key('edit_cash_drawer_button'),
            saveKey: const Key('save_button'),
            deleteKey: const Key('delete_cash_drawer_button'),
            onEdit: (canUpdate && widget.cashDrawerId != null)
                ? () => setState(() => _readOnlyOverride = false)
                : null,
            onSave: canSave
                ? (_isEdit ? controller.submitUpdate : controller.submitCreate)
                : null,
            onDelete: canDelete ? controller.delete : null,
            deleteConfirmation: RecordDeleteConfirmation(
              title: l10n.deleteCashDrawerConfirmTitle,
              message: l10n.deleteCashDrawerConfirmMessage(formState.name),
              confirmLabel: l10n.deleteButton,
              cancelLabel: l10n.cancelButton,
              confirmKey: const Key('confirm_delete_cash_drawer_button'),
            ),
          ),
        ),
      ],
    );
  }
}

String _localizeFormError(AppLocalizations l10n, String code) {
  switch (code) {
    case CashDrawerFormErrorCode.loadFailed:
      return l10n.cashDrawerLoadFailedError;
    case CashDrawerFormErrorCode.createFailed:
      return l10n.cashDrawerCreateFailedError;
    case CashDrawerFormErrorCode.updateFailed:
      return l10n.cashDrawerUpdateFailedError;
    case CashDrawerFormErrorCode.deleteFailed:
      return l10n.cashDrawerDeleteFailedError;
    case CashDrawerFormErrorCode.createPermissionDenied:
      return l10n.cashDrawerCreatePermissionDeniedError;
    case CashDrawerFormErrorCode.updatePermissionDenied:
      return l10n.cashDrawerUpdatePermissionDeniedError;
    case CashDrawerFormErrorCode.deletePermissionDenied:
      return l10n.cashDrawerDeletePermissionDeniedError;
    default:
      return code;
  }
}

String? _localizeFieldError(AppLocalizations l10n, String? code) {
  if (code == null) return null;
  switch (code) {
    case CashDrawerFormErrorCode.facilityRequired:
      return l10n.cashDrawerFacilityRequiredError;
    case CashDrawerFormErrorCode.codeRequired:
      return l10n.cashDrawerCodeRequiredError;
    case CashDrawerFormErrorCode.nameRequired:
      return l10n.cashDrawerNameRequiredError;
    default:
      return code;
  }
}
