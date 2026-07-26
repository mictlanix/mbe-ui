import 'package:flutter/material.dart';

import 'package:mbe_ui/core/widgets/catalog_action_icons.dart';

/// Which of the three states a record detail screen is currently in —
/// determines which actions [RecordFormActions] may show at all, on top of
/// the RBAC-driven `null callback ⇒ absent` gating (017-ui-consistency-filters
/// contracts/record-form-actions.md §2).
enum RecordFormMode {
  /// A not-yet-persisted record. Only Save is ever shown.
  create,

  /// A persisted record, rendered read-only. Only Edit is ever shown.
  view,

  /// A persisted record, rendered editable. Delete (if privileged) then
  /// Save are shown; Edit never is (the form is already editable).
  edit,
}

/// The wording and keys for the delete confirmation dialog
/// [RecordFormActions] shows before invoking `onDelete` — the *pattern* is
/// shared, the wording stays per-entity (contract §4).
class RecordDeleteConfirmation {
  const RecordDeleteConfirmation({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    this.confirmKey,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final Key? confirmKey;
}

/// The shared record action area (017-ui-consistency-filters FR-001–FR-008,
/// contracts/record-form-actions.md) — replaces the app-bar edit `IconButton`
/// and the hand-copied Save/Delete `FilledButton`s + `_confirmDelete` dialog
/// previously duplicated across all 18 detail screens.
///
/// Rendered as the last, full-width [FormGridChild] of a record's
/// [ResponsiveFormGrid] — but its buttons are right-aligned and
/// content-sized, never stretched (FR-004): `Align` gives its `Wrap` child
/// loose constraints regardless of the tight width the grid's `SizedBox`
/// imposes on this widget itself.
///
/// A `null` callback means the corresponding action is not rendered at all,
/// never rendered-but-disabled — RBAC visibility is structurally
/// impossible to get wrong (FR-007). [mode] additionally fixes *which*
/// actions are even eligible to render (Delete only in [RecordFormMode.edit],
/// Edit only in [RecordFormMode.view], Save never in [RecordFormMode.view]),
/// so a caller cannot accidentally show Edit alongside Save.
class RecordFormActions extends StatelessWidget {
  const RecordFormActions({
    super.key,
    required this.mode,
    required this.saveLabel,
    required this.editLabel,
    required this.deleteLabel,
    this.onEdit,
    this.onSave,
    this.onDelete,
    this.isSubmitting = false,
    this.deleteConfirmation,
    this.editKey,
    this.saveKey,
    this.deleteKey,
  });

  final RecordFormMode mode;
  final String saveLabel;
  final String editLabel;
  final String deleteLabel;

  /// `null` ⇒ Edit is absent, regardless of [mode].
  final VoidCallback? onEdit;

  /// `null` ⇒ Save is absent, regardless of [mode].
  final VoidCallback? onSave;

  /// `null` ⇒ Delete is absent, regardless of [mode].
  final VoidCallback? onDelete;

  /// While `true`, every action is suppressed (no double submission,
  /// FR-008) and Edit/Delete render disabled rather than disappearing —
  /// this is transient in-flight state, not an RBAC decision.
  final bool isSubmitting;

  /// Shown before invoking [onDelete]. `null` skips confirmation (not used
  /// by any screen today, but not disallowed).
  final RecordDeleteConfirmation? deleteConfirmation;

  final Key? editKey;
  final Key? saveKey;
  final Key? deleteKey;

  bool get _showDelete => mode == RecordFormMode.edit && onDelete != null;
  bool get _showEdit => mode == RecordFormMode.view && onEdit != null;
  bool get _showSave => mode != RecordFormMode.view && onSave != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttons = <Widget>[
      // Fixed left-to-right order: Delete, then Edit-or-Save (contract §2)
      // — the destructive action sits furthest from the primary one, and
      // the primary/confirming action is rightmost.
      if (_showDelete)
        OutlinedButton(
          key: deleteKey,
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.colorScheme.error,
            side: BorderSide(color: theme.colorScheme.error),
          ),
          onPressed: isSubmitting ? null : () => _confirmAndDelete(context),
          child: Text(deleteLabel),
        ),
      if (_showEdit)
        OutlinedButton.icon(
          key: editKey,
          icon: Icon(CatalogAction.edit.icon),
          label: Text(editLabel),
          onPressed: isSubmitting ? null : onEdit,
        ),
      if (_showSave)
        FilledButton(
          key: saveKey,
          onPressed: isSubmitting ? null : onSave,
          child: isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(saveLabel),
        ),
    ];

    if (buttons.isEmpty) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.centerRight,
      child: Wrap(
        alignment: WrapAlignment.end,
        spacing: 12,
        runSpacing: 8,
        children: buttons,
      ),
    );
  }

  Future<void> _confirmAndDelete(BuildContext context) async {
    final confirmation = deleteConfirmation;
    if (confirmation == null) {
      onDelete?.call();
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(confirmation.title),
        content: Text(confirmation.message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(confirmation.cancelLabel),
          ),
          FilledButton(
            key: confirmation.confirmKey,
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(confirmation.confirmLabel),
          ),
        ],
      ),
    );
    if (confirmed == true) onDelete?.call();
  }
}
