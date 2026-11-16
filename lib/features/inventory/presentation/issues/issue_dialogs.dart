import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_issue.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/inventory/presentation/issues/inventory_issue_actions.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

// The prompts the issue detail screen opens (spec 068 ui-contract "Dialogs",
// wireframes "Dialogs"). Each runs its own write through
// `InventoryIssueActions`, which puts the returned issue on screen.

/// A line's product for a sentence: its name, else its code, else its id.
String _productLabel(InventoryIssueLine line) =>
    line.productName ?? line.productCode ?? '#${line.productId}';

/// The refusal inside a dialog, localized from its code (§III).
class _Refusal extends StatelessWidget {
  const _Refusal({required this.error});

  final AppError error;

  @override
  Widget build(BuildContext context) => ErrorBanner(
    key: const Key('inventory_issue_dialog_refusal'),
    error: error,
  );
}

// ---------------------------------------------------------------------------
// Cantidad de la partida
// ---------------------------------------------------------------------------

/// Changes [line]'s quantity on draft [issueId]. `true` once saved. The
/// client checks only that the quantity is above 0; every refusal shows
/// inline and keeps the dialog open.
Future<bool> showIssueLineQuantityDialog(
  BuildContext context, {
  required int issueId,
  required InventoryIssueLine line,
}) async =>
    await showResponsiveDialog<bool>(
      context,
      builder: (context) => _LineQuantityDialog(issueId: issueId, line: line),
    ) ??
    false;

class _LineQuantityDialog extends ConsumerStatefulWidget {
  const _LineQuantityDialog({required this.issueId, required this.line});

  final int issueId;
  final InventoryIssueLine line;

  @override
  ConsumerState<_LineQuantityDialog> createState() =>
      _LineQuantityDialogState();
}

class _LineQuantityDialogState extends ConsumerState<_LineQuantityDialog> {
  late final String _initial = ref
      .read(formattersProvider)
      .field
      .quantity(widget.line.quantity.toString());
  late final _quantity = TextEditingController(text: _initial);
  bool _busy = false;
  AppError? _refusal;

  @override
  void dispose() {
    _quantity.dispose();
    super.dispose();
  }

  Decimal? get _value {
    final parsed = ref
        .read(formattersProvider)
        .field
        .parseQuantity(_quantity.text);
    return parsed == null ? null : Decimal.parse(parsed);
  }

  bool get _valid => (_value ?? Decimal.zero) > Decimal.zero;

  bool get _canSave => !_busy && _valid && _value != widget.line.quantity;

  Future<void> _save() async {
    final value = _value;
    if (!_canSave || value == null) return;
    final navigator = Navigator.of(context);
    setState(() {
      _busy = true;
      _refusal = null;
    });
    final error = await ref
        .read(inventoryIssueActionsProvider.notifier)
        .updateLine(widget.issueId, widget.line.id, quantity: value);
    if (!mounted) return;
    if (error == null) {
      navigator.pop(true);
      return;
    }
    setState(() {
      _busy = false;
      _refusal = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final line = widget.line;

    return ResponsiveDialog(
      key: const Key('inventory_issue_line_quantity_dialog'),
      title: l10n.inventoryIssueLineQuantityTitle,
      dismissible: !_busy,
      hasUnsavedChanges: () => _quantity.text != _initial,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          Text('${line.productCode ?? ''} ${line.productName ?? ''}'.trim()),
          TextField(
            key: const Key('inventory_issue_line_quantity_field'),
            controller: _quantity,
            enabled: !_busy,
            autofocus: true,
            textAlign: TextAlign.end,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.inventoryIssueFieldQuantity,
              errorText: _valid ? null : l10n.inventoryIssueQuantityInvalid,
            ),
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _save(),
          ),
          if (_refusal != null) _Refusal(error: _refusal!),
        ],
      ),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.cancelButton,
        onPressed: _busy ? null : () => Navigator.of(context).maybePop(),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('inventory_issue_line_quantity_submit'),
        label: l10n.saveButton,
        busy: _busy,
        onPressed: _canSave ? _save : null,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Quitar partida
// ---------------------------------------------------------------------------

/// Asks before removing [line] from draft [issueId], then removes it.
/// `true` once removed; a refusal shows inline and keeps the dialog open.
Future<bool> showRemoveIssueLineDialog(
  BuildContext context, {
  required int issueId,
  required InventoryIssueLine line,
}) async =>
    await showResponsiveDialog<bool>(
      context,
      builder: (context) => _RemoveLineDialog(issueId: issueId, line: line),
    ) ??
    false;

class _RemoveLineDialog extends ConsumerStatefulWidget {
  const _RemoveLineDialog({required this.issueId, required this.line});

  final int issueId;
  final InventoryIssueLine line;

  @override
  ConsumerState<_RemoveLineDialog> createState() => _RemoveLineDialogState();
}

class _RemoveLineDialogState extends ConsumerState<_RemoveLineDialog> {
  bool _busy = false;
  AppError? _refusal;

  Future<void> _remove() async {
    if (_busy) return;
    final navigator = Navigator.of(context);
    setState(() {
      _busy = true;
      _refusal = null;
    });
    final error = await ref
        .read(inventoryIssueActionsProvider.notifier)
        .removeLine(widget.issueId, widget.line.id);
    if (!mounted) return;
    if (error == null) {
      navigator.pop(true);
      return;
    }
    setState(() {
      _busy = false;
      _refusal = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;

    return ResponsiveDialog(
      key: const Key('inventory_issue_line_remove_dialog'),
      title: l10n.inventoryIssueRemoveTitle(_productLabel(widget.line)),
      dismissible: !_busy,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          Text(l10n.inventoryIssueRemoveBody),
          if (_refusal != null) _Refusal(error: _refusal!),
        ],
      ),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.cancelButton,
        onPressed: _busy ? null : () => Navigator.of(context).pop(false),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('inventory_issue_line_remove_submit'),
        label: l10n.inventoryIssueRemoveAction,
        busy: _busy,
        onPressed: _remove,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Confirmar salida
// ---------------------------------------------------------------------------

/// What confirming (or cancelling) an issue answered: the refusal, or `null`
/// when it went through.
typedef IssueSettled = ({AppError? error});

/// Explains that confirming [issue] takes its stock out of its warehouse
/// (FR-012), then confirms it.
///
/// Closes on any outcome and answers the [IssueSettled] to the caller, which
/// shows a refusal (such as `inventory_document.insufficient_stock`) above
/// its action area. `null` when the user backed out.
Future<IssueSettled?> showConfirmIssueDialog(
  BuildContext context,
  InventoryIssue issue,
) => showResponsiveDialog<IssueSettled>(
  context,
  builder: (context) => _ConfirmDialog(issue: issue),
);

class _ConfirmDialog extends ConsumerStatefulWidget {
  const _ConfirmDialog({required this.issue});

  final InventoryIssue issue;

  @override
  ConsumerState<_ConfirmDialog> createState() => _ConfirmDialogState();
}

class _ConfirmDialogState extends ConsumerState<_ConfirmDialog> {
  bool _busy = false;

  Future<void> _confirm() async {
    if (_busy) return;
    final navigator = Navigator.of(context);
    setState(() => _busy = true);
    final error = await ref
        .read(inventoryIssueActionsProvider.notifier)
        .confirm(widget.issue.id);
    if (!mounted) return;
    navigator.pop((error: error));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final warehouseId = widget.issue.warehouseId;
    final warehouse =
        ref.watch(warehouseDisplayNameProvider(warehouseId)).value ??
        '#$warehouseId';

    return ResponsiveDialog(
      key: const Key('inventory_issue_confirm_dialog'),
      title: l10n.inventoryIssueConfirmTitle,
      dismissible: !_busy,
      body: Text(
        l10n.inventoryIssueConfirmBody(warehouse),
        key: const Key('inventory_issue_confirm_body'),
      ),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.inventoryIssueBack,
        onPressed: _busy ? null : () => Navigator.of(context).pop(),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('inventory_issue_confirm_submit'),
        label: l10n.inventoryIssueConfirmAction,
        busy: _busy,
        onPressed: _confirm,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Cancelar salida
// ---------------------------------------------------------------------------

/// Explains what cancelling [issue] does (a draft posted nothing; a
/// completed issue's stock goes back into its warehouse), then cancels it.
/// There is no reason field: the endpoint takes none.
///
/// Closes on any outcome and answers the [IssueSettled] to the caller, which
/// shows a refusal above its action area. `null` when the user backed out.
Future<IssueSettled?> showCancelIssueDialog(
  BuildContext context,
  InventoryIssue issue,
) => showResponsiveDialog<IssueSettled>(
  context,
  builder: (context) => _CancelDialog(issue: issue),
);

class _CancelDialog extends ConsumerStatefulWidget {
  const _CancelDialog({required this.issue});

  final InventoryIssue issue;

  @override
  ConsumerState<_CancelDialog> createState() => _CancelDialogState();
}

class _CancelDialogState extends ConsumerState<_CancelDialog> {
  bool _busy = false;

  Future<void> _cancel() async {
    if (_busy) return;
    final navigator = Navigator.of(context);
    setState(() => _busy = true);
    final error = await ref
        .read(inventoryIssueActionsProvider.notifier)
        .cancel(widget.issue.id);
    if (!mounted) return;
    navigator.pop((error: error));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final issue = widget.issue;
    final warehouse =
        ref.watch(warehouseDisplayNameProvider(issue.warehouseId)).value ??
        '#${issue.warehouseId}';

    return ResponsiveDialog(
      key: const Key('inventory_issue_cancel_dialog'),
      title: l10n.inventoryIssueCancelTitle,
      dismissible: !_busy,
      body: Text(
        issue.isDraft
            ? l10n.inventoryIssueCancelDraftBody
            : l10n.inventoryIssueCancelCompletedBody(
                '${issue.serial ?? issue.id}',
                warehouse,
              ),
        key: const Key('inventory_issue_cancel_body'),
      ),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.inventoryIssueBack,
        onPressed: _busy ? null : () => Navigator.of(context).pop(),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('inventory_issue_cancel_submit'),
        label: l10n.inventoryIssueCancelAction,
        busy: _busy,
        onPressed: _cancel,
      ),
    );
  }
}
