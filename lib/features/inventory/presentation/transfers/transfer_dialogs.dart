import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_transfer.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/inventory/presentation/transfers/inventory_transfer_actions.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

// The prompts the transfer detail screen opens (spec 069 ui-contract "Dialogs",
// wireframes "Dialogs"). Each runs its own write through
// `InventoryTransferActions`, which puts the returned transfer on screen.

/// A line's product for a sentence: its name, else its code, else its id.
String _productLabel(InventoryTransferLine line) =>
    line.productName ?? line.productCode ?? '#${line.productId}';

/// The refusal inside a dialog, localized from its code (§III).
class _Refusal extends StatelessWidget {
  const _Refusal({required this.error});

  final AppError error;

  @override
  Widget build(BuildContext context) => ErrorBanner(
    key: const Key('inventory_transfer_dialog_refusal'),
    error: error,
  );
}

// ---------------------------------------------------------------------------
// Cantidad de la partida
// ---------------------------------------------------------------------------

/// Changes [line]'s quantity on draft [transferId]. `true` once saved. The
/// client checks only that the quantity is above 0; every refusal shows
/// inline and keeps the dialog open.
Future<bool> showTransferLineQuantityDialog(
  BuildContext context, {
  required int transferId,
  required InventoryTransferLine line,
}) async =>
    await showResponsiveDialog<bool>(
      context,
      builder: (context) =>
          _LineQuantityDialog(transferId: transferId, line: line),
    ) ??
    false;

class _LineQuantityDialog extends ConsumerStatefulWidget {
  const _LineQuantityDialog({required this.transferId, required this.line});

  final int transferId;
  final InventoryTransferLine line;

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
        .read(inventoryTransferActionsProvider.notifier)
        .updateLine(widget.transferId, widget.line.id, quantity: value);
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
      key: const Key('inventory_transfer_line_quantity_dialog'),
      title: l10n.inventoryTransferLineQuantityTitle,
      dismissible: !_busy,
      hasUnsavedChanges: () => _quantity.text != _initial,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          Text('${line.productCode ?? ''} ${line.productName ?? ''}'.trim()),
          TextField(
            key: const Key('inventory_transfer_line_quantity_field'),
            controller: _quantity,
            enabled: !_busy,
            autofocus: true,
            textAlign: TextAlign.end,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.inventoryTransferFieldQuantity,
              errorText: _valid ? null : l10n.inventoryTransferQuantityInvalid,
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
        key: const Key('inventory_transfer_line_quantity_submit'),
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

/// Asks before removing [line] from draft [transferId], then removes it.
/// `true` once removed; a refusal shows inline and keeps the dialog open.
Future<bool> showRemoveTransferLineDialog(
  BuildContext context, {
  required int transferId,
  required InventoryTransferLine line,
}) async =>
    await showResponsiveDialog<bool>(
      context,
      builder: (context) =>
          _RemoveLineDialog(transferId: transferId, line: line),
    ) ??
    false;

class _RemoveLineDialog extends ConsumerStatefulWidget {
  const _RemoveLineDialog({required this.transferId, required this.line});

  final int transferId;
  final InventoryTransferLine line;

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
        .read(inventoryTransferActionsProvider.notifier)
        .removeLine(widget.transferId, widget.line.id);
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
      key: const Key('inventory_transfer_line_remove_dialog'),
      title: l10n.inventoryTransferRemoveTitle(_productLabel(widget.line)),
      dismissible: !_busy,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          Text(l10n.inventoryTransferRemoveBody),
          if (_refusal != null) _Refusal(error: _refusal!),
        ],
      ),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.cancelButton,
        onPressed: _busy ? null : () => Navigator.of(context).pop(false),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('inventory_transfer_line_remove_submit'),
        label: l10n.inventoryTransferRemoveAction,
        busy: _busy,
        onPressed: _remove,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Despachar traspaso
// ---------------------------------------------------------------------------

/// What dispatching (or, later, cancelling or closing) a transfer answered:
/// the refusal, or `null` when it went through.
typedef TransferSettled = ({AppError? error});

/// Explains that dispatching [transfer] takes its stock out of the origin and
/// leaves it in transit until the destination receives it (FR-013), then
/// dispatches it.
///
/// Closes on any outcome and answers the [TransferSettled] to the caller,
/// which shows a refusal (such as `inventory_document.insufficient_stock`)
/// above its action area. `null` when the user backed out.
Future<TransferSettled?> showDispatchTransferDialog(
  BuildContext context,
  InventoryTransfer transfer,
) => showResponsiveDialog<TransferSettled>(
  context,
  builder: (context) => _DispatchDialog(transfer: transfer),
);

class _DispatchDialog extends ConsumerStatefulWidget {
  const _DispatchDialog({required this.transfer});

  final InventoryTransfer transfer;

  @override
  ConsumerState<_DispatchDialog> createState() => _DispatchDialogState();
}

class _DispatchDialogState extends ConsumerState<_DispatchDialog> {
  bool _busy = false;

  Future<void> _dispatch() async {
    if (_busy) return;
    final navigator = Navigator.of(context);
    setState(() => _busy = true);
    final error = await ref
        .read(inventoryTransferActionsProvider.notifier)
        .dispatch(widget.transfer.id);
    if (!mounted) return;
    navigator.pop((error: error));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final transfer = widget.transfer;
    final source =
        ref.watch(warehouseDisplayNameProvider(transfer.warehouseId)).value ??
        '#${transfer.warehouseId}';
    final destination =
        ref.watch(warehouseDisplayNameProvider(transfer.warehouseToId)).value ??
        '#${transfer.warehouseToId}';

    return ResponsiveDialog(
      key: const Key('inventory_transfer_dispatch_dialog'),
      title: l10n.inventoryTransferDispatchTitle,
      dismissible: !_busy,
      body: Text(
        l10n.inventoryTransferDispatchBody(source, destination),
        key: const Key('inventory_transfer_dispatch_body'),
      ),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.inventoryTransferBack,
        onPressed: _busy ? null : () => Navigator.of(context).pop(),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('inventory_transfer_dispatch_submit'),
        label: l10n.inventoryTransferDispatchAction,
        busy: _busy,
        onPressed: _dispatch,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Cerrar pendiente y Cancelar traspaso
// ---------------------------------------------------------------------------

/// A prompt that runs one write on [transfer] and closes on any outcome,
/// answering the [TransferSettled] for the detail screen to show.
class _SettleDialog extends ConsumerStatefulWidget {
  const _SettleDialog({
    required this.dialogKey,
    required this.submitKey,
    required this.title,
    required this.body,
    required this.action,
    required this.run,
  });

  final Key dialogKey;
  final Key submitKey;
  final String title;
  final String body;
  final String action;
  final Future<AppError?> Function(InventoryTransferActions actions) run;

  @override
  ConsumerState<_SettleDialog> createState() => _SettleDialogState();
}

class _SettleDialogState extends ConsumerState<_SettleDialog> {
  bool _busy = false;

  Future<void> _submit() async {
    if (_busy) return;
    final navigator = Navigator.of(context);
    setState(() => _busy = true);
    final error = await widget.run(
      ref.read(inventoryTransferActionsProvider.notifier),
    );
    if (!mounted) return;
    navigator.pop((error: error));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ResponsiveDialog(
      key: widget.dialogKey,
      title: widget.title,
      dismissible: !_busy,
      body: Text(widget.body),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.inventoryTransferBack,
        onPressed: _busy ? null : () => Navigator.of(context).pop(),
      ),
      primaryAction: ResponsiveDialogAction(
        key: widget.submitKey,
        label: widget.action,
        busy: _busy,
        onPressed: _submit,
      ),
    );
  }
}

/// The name of warehouse [id] for a sentence: its name, else `#id`.
String _warehouseLabel(WidgetRef ref, int id) =>
    ref.watch(warehouseDisplayNameProvider(id)).value ?? '#$id';

/// "Cerrar pendiente" (spec 069 FR-015): says that what is still outstanding
/// goes back to the origin and the transfer becomes Recibido, then closes it.
/// `null` when the user backed out. The detail screen gates the button on
/// InventoryTransfers (17) delete and an in-transit transfer.
Future<TransferSettled?> showCloseTransferDialog(
  BuildContext context,
  InventoryTransfer transfer,
) => showResponsiveDialog<TransferSettled>(
  context,
  builder: (_) => _CloseDialog(transfer: transfer),
);

class _CloseDialog extends ConsumerWidget {
  const _CloseDialog({required this.transfer});

  final InventoryTransfer transfer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return _SettleDialog(
      dialogKey: const Key('inventory_transfer_close_dialog'),
      submitKey: const Key('inventory_transfer_close_submit'),
      title: l10n.inventoryTransferCloseTitle,
      body: l10n.inventoryTransferCloseBody(
        transfer.outstandingLines.length,
        _warehouseLabel(ref, transfer.warehouseId),
      ),
      action: l10n.inventoryTransferCloseAction,
      run: (actions) => actions.close(transfer.id),
    );
  }
}

/// "Cancelar traspaso" (spec 069 FR-016): a draft is simply dropped; a
/// dispatched one names its folio and the origin that gets the stock back,
/// plus what the destination already received when any line has something
/// received. There is no reason field: the endpoint takes none. `null` when
/// the user backed out. The detail screen gates the button on
/// InventoryTransfers (17) delete and a transfer that isn't cancelled.
Future<TransferSettled?> showCancelTransferDialog(
  BuildContext context,
  InventoryTransfer transfer,
) => showResponsiveDialog<TransferSettled>(
  context,
  builder: (_) => _CancelDialog(transfer: transfer),
);

class _CancelDialog extends ConsumerWidget {
  const _CancelDialog({required this.transfer});

  final InventoryTransfer transfer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final folio = '${transfer.serial}';
    final source = _warehouseLabel(ref, transfer.warehouseId);
    final anyReceived = transfer.lines.any(
      (line) => line.quantityReceived > Decimal.zero,
    );
    return _SettleDialog(
      dialogKey: const Key('inventory_transfer_cancel_dialog'),
      submitKey: const Key('inventory_transfer_cancel_submit'),
      title: l10n.inventoryTransferCancelTitle,
      body: !transfer.isDispatched
          ? l10n.inventoryTransferCancelDraftBody
          : anyReceived
          ? l10n.inventoryTransferCancelDispatchedReceivedBody(
              folio,
              source,
              _warehouseLabel(ref, transfer.warehouseToId),
            )
          : l10n.inventoryTransferCancelDispatchedBody(folio, source),
      action: l10n.inventoryTransferCancelAction,
      run: (actions) => actions.cancel(transfer.id),
    );
  }
}
