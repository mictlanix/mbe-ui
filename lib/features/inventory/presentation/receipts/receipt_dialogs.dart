import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_receipt.dart';
import 'package:mbe_ui/features/inventory/presentation/receipts/inventory_receipt_actions.dart';
import 'package:mbe_ui/features/inventory/presentation/receipts/receipt_warnings.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

// The prompts the receipt detail screen opens (spec 067 research R11,
// wireframes "Dialogs"). Each runs its own write through
// `InventoryReceiptActions`, which puts the returned receipt on screen.

/// A line's product for a sentence: its name, else its code, else its id.
String _productLabel(InventoryReceiptLine line) =>
    line.productName ?? line.productCode ?? '#${line.productId}';

/// The refusal inside a dialog, localized from its code (§III).
class _Refusal extends StatelessWidget {
  const _Refusal({required this.error});

  final AppError error;

  @override
  Widget build(BuildContext context) => ErrorBanner(
    key: const Key('inventory_receipt_dialog_refusal'),
    error: error,
  );
}

// ---------------------------------------------------------------------------
// Cantidad de la partida
// ---------------------------------------------------------------------------

/// Changes [line]'s quantity on draft [receiptId]. `true` once saved. The
/// client checks only that the quantity is above 0; every refusal shows
/// inline and keeps the dialog open.
Future<bool> showReceiptLineQuantityDialog(
  BuildContext context, {
  required int receiptId,
  required InventoryReceiptLine line,
}) async =>
    await showResponsiveDialog<bool>(
      context,
      builder: (context) =>
          _LineQuantityDialog(receiptId: receiptId, line: line),
    ) ??
    false;

class _LineQuantityDialog extends ConsumerStatefulWidget {
  const _LineQuantityDialog({required this.receiptId, required this.line});

  final int receiptId;
  final InventoryReceiptLine line;

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
        .read(inventoryReceiptActionsProvider.notifier)
        .updateLine(widget.receiptId, widget.line.id, quantity: value);
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
      key: const Key('inventory_receipt_line_quantity_dialog'),
      title: l10n.inventoryReceiptLineQuantityTitle,
      dismissible: !_busy,
      hasUnsavedChanges: () => _quantity.text != _initial,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          Text('${line.productCode ?? ''} ${line.productName ?? ''}'.trim()),
          TextField(
            key: const Key('inventory_receipt_line_quantity_field'),
            controller: _quantity,
            enabled: !_busy,
            autofocus: true,
            textAlign: TextAlign.end,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.inventoryReceiptFieldQuantity,
              errorText: _valid ? null : l10n.inventoryReceiptQuantityInvalid,
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
        key: const Key('inventory_receipt_line_quantity_submit'),
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

/// Asks before removing [line] from draft [receiptId], then removes it.
/// `true` once removed; a refusal shows inline and keeps the dialog open.
Future<bool> showRemoveReceiptLineDialog(
  BuildContext context, {
  required int receiptId,
  required InventoryReceiptLine line,
}) async =>
    await showResponsiveDialog<bool>(
      context,
      builder: (context) => _RemoveLineDialog(receiptId: receiptId, line: line),
    ) ??
    false;

class _RemoveLineDialog extends ConsumerStatefulWidget {
  const _RemoveLineDialog({required this.receiptId, required this.line});

  final int receiptId;
  final InventoryReceiptLine line;

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
        .read(inventoryReceiptActionsProvider.notifier)
        .removeLine(widget.receiptId, widget.line.id);
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
      key: const Key('inventory_receipt_line_remove_dialog'),
      title: l10n.inventoryReceiptRemoveTitle(_productLabel(widget.line)),
      dismissible: !_busy,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          Text(l10n.inventoryReceiptRemoveBody),
          if (_refusal != null) _Refusal(error: _refusal!),
        ],
      ),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.cancelButton,
        onPressed: _busy ? null : () => Navigator.of(context).pop(false),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('inventory_receipt_line_remove_submit'),
        label: l10n.inventoryReceiptRemoveAction,
        busy: _busy,
        onPressed: _remove,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Confirmar entrada
// ---------------------------------------------------------------------------

/// Explains what confirming [receipt] does, then confirms it.
///
/// Closes on any outcome and answers the [ReceiptSettled] to the caller,
/// which shows a refusal (such as `inventory_document.no_lines`) above its
/// action area. `null` when the user backed out.
Future<ReceiptSettled?> showConfirmReceiptDialog(
  BuildContext context,
  InventoryReceipt receipt,
) => showResponsiveDialog<ReceiptSettled>(
  context,
  builder: (context) => _ConfirmDialog(receipt: receipt),
);

class _ConfirmDialog extends ConsumerStatefulWidget {
  const _ConfirmDialog({required this.receipt});

  final InventoryReceipt receipt;

  @override
  ConsumerState<_ConfirmDialog> createState() => _ConfirmDialogState();
}

class _ConfirmDialogState extends ConsumerState<_ConfirmDialog> {
  bool _busy = false;

  Future<void> _confirm() async {
    if (_busy) return;
    final navigator = Navigator.of(context);
    setState(() => _busy = true);
    final result = await ref
        .read(inventoryReceiptActionsProvider.notifier)
        .confirm(widget.receipt.id);
    if (!mounted) return;
    navigator.pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final fmt = ref.watch(formattersProvider);
    final overReceipts = widget.receipt.overReceipts;

    return ResponsiveDialog(
      key: const Key('inventory_receipt_confirm_dialog'),
      title: l10n.inventoryReceiptConfirmTitle,
      dismissible: !_busy,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          Text(
            l10n.inventoryReceiptConfirmBody,
            key: const Key('inventory_receipt_confirm_body'),
          ),
          // The over-receipts, so the clerk sees them before posting stock
          // (research R11). Never blocking.
          if (overReceipts.isNotEmpty)
            Column(
              key: const Key('inventory_receipt_confirm_over_receipts'),
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: spacing.xs,
              children: [
                for (final over in overReceipts)
                  Text(overReceiptText(l10n, fmt, over)),
              ],
            ),
        ],
      ),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.inventoryReceiptBack,
        onPressed: _busy ? null : () => Navigator.of(context).pop(),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('inventory_receipt_confirm_submit'),
        label: l10n.inventoryReceiptConfirmAction,
        busy: _busy,
        onPressed: _confirm,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Cancelar entrada
// ---------------------------------------------------------------------------

/// Explains what cancelling [receipt] does (a draft adds no stock; a
/// confirmed receipt's stock is taken back out), then cancels it. There is
/// no reason field: the endpoint takes none (research R11).
///
/// Closes on any outcome and answers the [ReceiptSettled] to the caller,
/// which shows a refusal (such as `inventory_document.insufficient_stock`)
/// above its action area. `null` when the user backed out.
Future<ReceiptSettled?> showCancelReceiptDialog(
  BuildContext context,
  InventoryReceipt receipt,
) => showResponsiveDialog<ReceiptSettled>(
  context,
  builder: (context) => _CancelDialog(receipt: receipt),
);

class _CancelDialog extends ConsumerStatefulWidget {
  const _CancelDialog({required this.receipt});

  final InventoryReceipt receipt;

  @override
  ConsumerState<_CancelDialog> createState() => _CancelDialogState();
}

class _CancelDialogState extends ConsumerState<_CancelDialog> {
  bool _busy = false;

  Future<void> _cancel() async {
    if (_busy) return;
    final navigator = Navigator.of(context);
    setState(() => _busy = true);
    final result = await ref
        .read(inventoryReceiptActionsProvider.notifier)
        .cancel(widget.receipt.id);
    if (!mounted) return;
    navigator.pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ResponsiveDialog(
      key: const Key('inventory_receipt_cancel_dialog'),
      title: l10n.inventoryReceiptCancelTitle,
      dismissible: !_busy,
      body: Text(
        widget.receipt.isDraft
            ? l10n.inventoryReceiptCancelDraftBody
            : l10n.inventoryReceiptCancelCompletedBody,
        key: const Key('inventory_receipt_cancel_body'),
      ),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.inventoryReceiptBack,
        onPressed: _busy ? null : () => Navigator.of(context).pop(),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('inventory_receipt_cancel_submit'),
        label: l10n.inventoryReceiptCancelAction,
        busy: _busy,
        onPressed: _cancel,
      ),
    );
  }
}
