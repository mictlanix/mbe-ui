import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/record_form_actions.dart';
import 'package:mbe_ui/core/widgets/record_sheet.dart';
import 'package:mbe_ui/core/widgets/responsive_form_grid.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Opens a settings record in the shared panel (`showRecordSheet`). [isDirty]
/// reads the form's controller from the app's container, because the panel's
/// dismissal guard lives outside the form's subtree.
Future<void> showCommissionSettingsPanel(
  BuildContext context, {
  required String title,
  required Widget form,
  required bool Function(ProviderContainer container) isDirty,
}) {
  final container = ProviderScope.containerOf(context);
  return showRecordSheet(
    context,
    title: title,
    form: (_) => form,
    isDirty: () => isDirty(container),
  );
}

/// The body of a labels, participations or agents panel: the fields the
/// caller draws, the refusal banner and the shared [RecordFormActions].
///
/// Rights follow each call (spec 078 contract): Save is Create on a new
/// record and Update on an existing one, Edit is Update, Delete is Delete,
/// all on SystemObject 112. A row click opens it read-only ([forceReadOnly]);
/// the panel's Edit control makes it editable.
class CommissionSettingsPanel extends ConsumerStatefulWidget {
  const CommissionSettingsPanel({
    super.key,
    required this.isEdit,
    required this.forceReadOnly,
    required this.submitting,
    required this.error,
    required this.fields,
    required this.onSave,
    required this.onDelete,
    required this.deleteTitle,
    required this.deleteMessage,
    required this.keyPrefix,
  });

  final bool isEdit;
  final bool forceReadOnly;
  final bool submitting;
  final AppError? error;

  /// The fields, given whether they take input.
  final List<Widget> Function(bool enabled) fields;

  /// Each answers `true` when the server accepted the write.
  final Future<bool> Function() onSave;
  final Future<bool> Function() onDelete;
  final String deleteTitle;
  final String deleteMessage;

  /// Prefix of the keys of the Edit, Save, Delete and confirm buttons.
  final String keyPrefix;

  @override
  ConsumerState<CommissionSettingsPanel> createState() =>
      _CommissionSettingsPanelState();
}

class _CommissionSettingsPanelState
    extends ConsumerState<CommissionSettingsPanel> {
  late bool _readOnly = widget.forceReadOnly;

  Future<void> _run(Future<bool> Function() action) async {
    final done = await action();
    if (done && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final access = ref.watch(accessControlProvider);
    const object = SystemObject.commissionsBySalesPerson;
    final canCreate = access.can(object, AccessRight.create);
    final canUpdate = access.can(object, AccessRight.update);
    final canDelete = access.can(object, AccessRight.delete);
    final isEdit = widget.isEdit;
    final readOnly = (isEdit && !canUpdate) || _readOnly;
    final mode = !isEdit
        ? RecordFormMode.create
        : (readOnly ? RecordFormMode.view : RecordFormMode.edit);
    final canSave = !readOnly && (isEdit ? canUpdate : canCreate);

    return ResponsiveFormGrid(
      maxColumns: 1,
      children: [
        if (widget.error != null)
          FormGridChild(
            span: FormGridSpan.full,
            ErrorBanner(
              key: Key('${widget.keyPrefix}_error'),
              error: widget.error!,
            ),
          ),
        for (final field in widget.fields(!widget.submitting && !readOnly))
          FormGridChild(span: FormGridSpan.full, field),
        FormGridChild(
          span: FormGridSpan.full,
          RecordFormActions(
            mode: mode,
            saveLabel: l10n.saveButton,
            editLabel: l10n.editRecordTooltip,
            deleteLabel: l10n.deleteButton,
            isSubmitting: widget.submitting,
            editKey: Key('${widget.keyPrefix}_edit_button'),
            saveKey: Key('${widget.keyPrefix}_save_button'),
            deleteKey: Key('${widget.keyPrefix}_delete_button'),
            onEdit: isEdit && canUpdate
                ? () => setState(() => _readOnly = false)
                : null,
            onSave: canSave ? () => _run(widget.onSave) : null,
            onDelete: isEdit && !readOnly && canDelete
                ? () => _run(widget.onDelete)
                : null,
            deleteConfirmation: RecordDeleteConfirmation(
              title: widget.deleteTitle,
              message: widget.deleteMessage,
              confirmLabel: l10n.deleteButton,
              cancelLabel: l10n.cancelButton,
              confirmKey: Key('${widget.keyPrefix}_confirm_delete_button'),
            ),
          ),
        ),
      ],
    );
  }
}
