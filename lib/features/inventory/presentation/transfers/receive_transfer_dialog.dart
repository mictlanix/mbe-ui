import 'package:decimal/decimal.dart';
import 'package:data_table_2/data_table_2.dart' show ColumnSize;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/app_formatters.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_transfer.dart';
import 'package:mbe_ui/features/inventory/presentation/transfers/inventory_transfer_actions.dart';
import 'package:mbe_ui/features/inventory/presentation/transfers/transfer_dialogs.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The refusals after which the transfer on screen is stale. The dialog
/// closes on them and the detail screen's banner shows the message; the
/// actions notifier has already reloaded the transfer.
const _closingCodes = {
  api.ErrorCode.inventoryTransferPeriodOverReceived,
  api.ErrorCode.inventoryTransferPeriodNotInTransit,
};

/// "Recibir" (spec 069 FR-014, research R7): one row per line with something
/// outstanding, each filled in with its outstanding quantity. Answers the
/// refusal to show in the detail screen's banner, `(error: null)` once
/// received, or `null` when the user backed out.
///
/// Every other refusal (`facility.other_facility`, `lock.busy`, ...) stays in
/// the dialog. The detail screen gates the button on InventoryTransfers (17)
/// update and an in-transit transfer.
Future<TransferSettled?> showReceiveTransferDialog(
  BuildContext context,
  InventoryTransfer transfer,
) => showResponsiveDialog<TransferSettled>(
  context,
  builder: (_) => _ReceiveDialog(transfer: transfer),
);

class _ReceiveDialog extends ConsumerStatefulWidget {
  const _ReceiveDialog({required this.transfer});

  final InventoryTransfer transfer;

  @override
  ConsumerState<_ReceiveDialog> createState() => _ReceiveDialogState();
}

class _ReceiveDialogState extends ConsumerState<_ReceiveDialog> {
  late final List<InventoryTransferLine> _lines =
      widget.transfer.outstandingLines;
  late final Map<int, String> _initial = {
    for (final line in _lines)
      line.id: ref
          .read(formattersProvider)
          .field
          .quantity(line.quantityOutstanding.toString()),
  };
  late final Map<int, TextEditingController> _fields = {
    for (final line in _lines)
      line.id: TextEditingController(text: _initial[line.id]),
  };
  bool _busy = false;
  AppError? _refusal;

  @override
  void dispose() {
    for (final field in _fields.values) {
      field.dispose();
    }
    super.dispose();
  }

  /// What [line]'s field holds; `null` when empty or unreadable.
  Decimal? _value(InventoryTransferLine line) {
    final parsed = ref
        .read(formattersProvider)
        .field
        .parseQuantity(_fields[line.id]!.text);
    return parsed == null ? null : Decimal.parse(parsed);
  }

  /// The field error for [line]: unreadable or negative, or above what is
  /// outstanding.
  String? _error(AppLocalizations l10n, InventoryTransferLine line) {
    final value = _value(line);
    if (value == null || value < Decimal.zero) {
      return l10n.inventoryTransferReceiveInvalid;
    }
    if (value > line.quantityOutstanding) {
      return l10n.inventoryTransferReceiveMax(
        ref
            .read(formattersProvider)
            .display
            .quantity(line.quantityOutstanding.toString()),
      );
    }
    return null;
  }

  bool _hasUnsavedChanges() =>
      _lines.any((line) => _fields[line.id]!.text != _initial[line.id]);

  bool _canReceive(AppLocalizations l10n) =>
      !_busy &&
      _lines.every((line) => _error(l10n, line) == null) &&
      _lines.any((line) => _value(line)! > Decimal.zero);

  Future<void> _receive(AppLocalizations l10n) async {
    if (!_canReceive(l10n)) return;
    final navigator = Navigator.of(context);
    // Every row still at its outstanding quantity: receive it all, with no
    // body. Otherwise every row above 0, the untouched ones included, so
    // lowering one doesn't drop the others.
    final untouched = _lines.every(
      (line) => _value(line) == line.quantityOutstanding,
    );
    setState(() {
      _busy = true;
      _refusal = null;
    });
    final error = await ref
        .read(inventoryTransferActionsProvider.notifier)
        .receive(
          widget.transfer.id,
          lines: untouched
              ? null
              : {
                  for (final line in _lines)
                    if (_value(line)! > Decimal.zero) line.id: _value(line)!,
                },
        );
    if (!mounted) return;
    if (error == null || _closingCodes.contains(error.problem?.code)) {
      navigator.pop((error: error));
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
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final fmt = ref.watch(formattersProvider);
    final transfer = widget.transfer;
    final errors = [
      for (final line in _lines)
        if (_error(l10n, line) case final message?)
          (line: line, message: message),
    ];

    return ResponsiveDialog(
      key: const Key('inventory_transfer_receive_dialog'),
      title: l10n.inventoryTransferReceiveTitle(
        '${transfer.serial ?? transfer.id}',
      ),
      dismissible: !_busy,
      hasUnsavedChanges: _hasUnsavedChanges,
      maxWidth: 720,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          DataTableView<InventoryTransferLine>(
            key: const Key('inventory_transfer_receive_table'),
            shrinkWrap: true,
            margin: EdgeInsets.zero,
            rows: _lines,
            columns: [
              DataTableColumn.text(
                label: l10n.inventoryTransferLineColCode,
                size: ColumnSize.S,
                text: (line) => line.productCode ?? emptyValuePlaceholder,
              ),
              DataTableColumn.text(
                label: l10n.inventoryTransferLineColProduct,
                size: ColumnSize.L,
                text: (line) => line.productName ?? emptyValuePlaceholder,
              ),
              DataTableColumn(
                label: l10n.inventoryTransferLineColOutstanding,
                numeric: true,
                size: ColumnSize.S,
                cellBuilder: (context, line) => Text(
                  fmt.display.quantity(line.quantityOutstanding.toString()),
                  key: Key('inventory_transfer_receive_outstanding_${line.id}'),
                ),
              ),
              DataTableColumn(
                label: l10n.inventoryTransferReceiveColReceive,
                numeric: true,
                size: ColumnSize.M,
                cellBuilder: (context, line) => TextField(
                  key: Key('inventory_transfer_receive_field_${line.id}'),
                  controller: _fields[line.id],
                  enabled: !_busy,
                  textAlign: TextAlign.end,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    // The message is listed under the table: a table row has
                    // a fixed height, so the field only turns red here.
                    error: _error(l10n, line) == null
                        ? null
                        : const SizedBox.shrink(),
                  ),
                  onChanged: (_) => setState(() => _refusal = null),
                  onSubmitted: (_) => _receive(l10n),
                ),
              ),
            ],
          ),
          for (final (:line, :message) in errors)
            Text(
              '${line.productCode ?? '#${line.productId}'} · $message',
              key: Key('inventory_transfer_receive_error_${line.id}'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          Text(l10n.inventoryTransferReceiveHint),
          if (_refusal != null)
            ErrorBanner(
              key: const Key('inventory_transfer_dialog_refusal'),
              error: _refusal!,
            ),
        ],
      ),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.cancelButton,
        onPressed: _busy ? null : () => Navigator.of(context).maybePop(),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('inventory_transfer_receive_submit'),
        label: l10n.inventoryTransferReceiveSubmit,
        busy: _busy,
        onPressed: _canReceive(l10n) ? () => _receive(l10n) : null,
      ),
    );
  }
}
