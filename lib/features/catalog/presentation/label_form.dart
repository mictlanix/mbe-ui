import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/record_form_actions.dart';
import 'package:mbe_ui/core/widgets/responsive_form_grid.dart';
import 'package:mbe_ui/features/catalog/presentation/label_form_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Create / view / edit form for a single label (spec 035 US5 — converted
/// from the pushed `/labels/new` / `/labels/:labelId` routes to the shared
/// record panel, `showRecordSheet`). [labelId] is `null` in create mode.
///
/// Hosted by `LabelsListScreen` inside `showRecordSheet`, not pushed as its
/// own route — the panel's own header supplies the "New/View/Edit Label"
/// title (computed once, at the moment the panel opens; toggling [onEdit]
/// below changes this form's own editability and action set, but does not
/// retitle the panel header — a deliberate simplification, spec 035 R6/T029).
class LabelForm extends ConsumerStatefulWidget {
  const LabelForm({super.key, this.labelId, this.forceReadOnly = false});

  final int? labelId;

  /// Opens the form read-only regardless of the caller's update privilege —
  /// set for a row-click open (constitution §VI: a stray click never risks
  /// an unintended edit). The in-panel Edit control (below) clears this.
  final bool forceReadOnly;

  @override
  ConsumerState<LabelForm> createState() => LabelFormPanelState();
}

/// Public so a caller can address it via `GlobalKey<LabelFormPanelState>` and
/// query [isDirty] from `showRecordSheet`'s `isDirty` callback — the panel's
/// dismissal guard lives outside this widget's subtree, so it needs a typed
/// handle onto the state actually holding the dirty computation (spec 035
/// data-model.md §3).
class LabelFormPanelState extends ConsumerState<LabelForm> {
  bool get _isEdit => widget.labelId != null;

  /// Whether the form is currently read-only. Starts at
  /// [LabelForm.forceReadOnly]; the in-panel Edit control clears it — there
  /// is no route to navigate to for that toggle anymore.
  late bool _readOnlyOverride = widget.forceReadOnly;

  /// Snapshot of [LabelFormState] the instant loading finishes (edit mode)
  /// or immediately (create mode, which never loads) — the dirty-check
  /// baseline. `null` only while a load is still in flight.
  ///
  /// Captured by directly **awaiting** [LabelFormController.loadForEdit]
  /// (below), not by inferring completion from `build()` having observed a
  /// `loading: true` frame — a fast-resolving repository (every mocked test,
  /// and plausibly a warm cache in production) can complete the load
  /// entirely within the same microtask flush that follows the
  /// `addPostFrameCallback`, so Flutter coalesces the `loading: true` state
  /// away and this widget never rebuilds with it visible at all. A
  /// `_sawLoading`-style flag driven off `build()` would then never see the
  /// signal it is waiting for, and `_snapshot` would never be captured.
  LabelFormState? _snapshot;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await ref
            .read(labelFormControllerProvider.notifier)
            .loadForEdit(widget.labelId!);
        if (mounted) setState(() => _snapshot = ref.read(labelFormControllerProvider));
      });
    } else {
      // Create mode never loads — the pristine baseline is available
      // synchronously, from the controller's own default state.
      _snapshot = ref.read(labelFormControllerProvider);
    }
  }

  /// Whether the user has made a change worth warning about before
  /// discarding (spec 035 FR-032). `false` while still loading — a panel
  /// that hasn't finished loading has nothing of the user's to lose.
  bool isDirty() {
    final current = ref.read(labelFormControllerProvider);
    return _snapshot != null && _snapshot != current;
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(labelFormControllerProvider);
    final controller = ref.read(labelFormControllerProvider.notifier);
    final access = ref.watch(accessControlProvider);
    final canCreate = access.can(SystemObject.labels, AccessRight.create);
    final canUpdate = access.can(SystemObject.labels, AccessRight.update);
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

    if (formState.saved || formState.deleted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
    }

    final fieldsEnabled = !formState.submitting && !readOnly;
    // `!readOnly` (the computed, current flag), not `!widget.forceReadOnly`
    // (the constructor's initial value) — the in-panel Edit control flips
    // `_readOnlyOverride` on the *same* widget instance rather than
    // remounting a differently-configured one the way a route change used
    // to, so Save's own gate has to track that live state too.
    final canSave = !readOnly && (_isEdit ? canUpdate : canCreate);
    final canDelete =
        _isEdit &&
        !readOnly &&
        access.can(SystemObject.labels, AccessRight.delete);

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
          TextFormField(
            key: const Key('label_name_field'),
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
          span: FormGridSpan.full,
          TextFormField(
            key: const Key('label_comment_field'),
            initialValue: formState.comment,
            decoration: InputDecoration(labelText: l10n.commentLabel),
            enabled: fieldsEnabled,
            onChanged: controller.commentChanged,
            maxLines: 3,
          ),
        ),
        FormGridChild(
          span: FormGridSpan.full,
          RecordFormActions(
            mode: mode,
            saveLabel: l10n.saveButton,
            editLabel: l10n.editRecordTooltip,
            deleteLabel: l10n.deleteLabelButton,
            isSubmitting: formState.submitting,
            editKey: const Key('edit_label_button'),
            saveKey: const Key('save_button'),
            deleteKey: const Key('delete_label_button'),
            onEdit: (canUpdate && widget.labelId != null)
                ? () => setState(() => _readOnlyOverride = false)
                : null,
            onSave: canSave
                ? (_isEdit ? controller.submitUpdate : controller.submitCreate)
                : null,
            onDelete: canDelete ? controller.delete : null,
            deleteConfirmation: RecordDeleteConfirmation(
              title: l10n.deleteLabelConfirmTitle,
              message: l10n.deleteLabelConfirmMessage(formState.name),
              confirmLabel: l10n.deleteButton,
              cancelLabel: l10n.cancelButton,
              confirmKey: const Key('confirm_delete_label_button'),
            ),
          ),
        ),
      ],
    );
  }
}

String _localizeFormError(AppLocalizations l10n, String code) {
  switch (code) {
    case LabelFormErrorCode.loadFailed:
      return l10n.labelLoadFailedError;
    case LabelFormErrorCode.createFailed:
      return l10n.labelCreateFailedError;
    case LabelFormErrorCode.updateFailed:
      return l10n.labelUpdateFailedError;
    case LabelFormErrorCode.deleteFailed:
      return l10n.labelDeleteFailedError;
    case LabelFormErrorCode.createPermissionDenied:
      return l10n.labelCreatePermissionDeniedError;
    case LabelFormErrorCode.updatePermissionDenied:
      return l10n.labelUpdatePermissionDeniedError;
    case LabelFormErrorCode.deletePermissionDenied:
      return l10n.labelDeletePermissionDeniedError;
    default:
      return code;
  }
}

String? _localizeFieldError(AppLocalizations l10n, String? code) {
  if (code == null) return null;
  switch (code) {
    case LabelFormErrorCode.nameRequired:
      return l10n.labelNameRequiredError;
    default:
      return code;
  }
}
