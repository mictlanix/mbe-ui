import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/formatting/app_formatters.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_order.dart';
import 'package:mbe_ui/features/purchases/domain/zero_price.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

// The prompts the order detail screen opens (spec 080 research R11,
// wireframes "Dialogs"). Each only asks; the screen runs the write and shows
// its refusal above the action area, localized from its code (§III).

/// Asks before confirming [order], which can't be undone (FR-021): the
/// supplier, line count and total, the warehouses that will get an entry
/// receipt, the zero-priced lines when there are any, and that it can no
/// longer be edited. `true` to confirm.
Future<bool> showConfirmOrderDialog(
  BuildContext context,
  PurchaseOrder order,
) async =>
    await showResponsiveDialog<bool>(
      context,
      builder: (_) => _ConfirmOrderDialog(order: order),
    ) ??
    false;

class _ConfirmOrderDialog extends ConsumerWidget {
  const _ConfirmOrderDialog({required this.order});

  final PurchaseOrder order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final fmt = ref.watch(formattersProvider);
    final supplier = order.supplierName;
    // Each destination once, in line order, by name.
    final warehouses = [
      for (final id in {
        for (final line in order.lines)
          if (line.warehouseId != null) line.warehouseId!,
      })
        ref.watch(warehouseDisplayNameProvider(id)).value ?? '#$id',
    ];
    final zeroPrice = zeroPriceLines(order.lines);

    return ResponsiveDialog(
      key: const Key('purchase_order_confirm_dialog'),
      title: l10n.purchaseOrderConfirmTitle('${order.id}'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          Text(
            l10n.purchaseOrderConfirmSummary(
              supplier == null || supplier.isEmpty
                  ? emptyValuePlaceholder
                  : supplier,
              l10n.toPurchaseLineCount(order.lines.length),
              fmt.display.currency(order.total.toString()),
            ),
            key: const Key('purchase_order_confirm_summary'),
          ),
          if (warehouses.isNotEmpty)
            Text(
              l10n.purchaseOrderConfirmReceipts(warehouses.join(', ')),
              key: const Key('purchase_order_confirm_warehouses'),
            ),
          if (zeroPrice.isNotEmpty)
            Row(
              key: const Key('purchase_order_confirm_zero_price'),
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: spacing.sm,
              children: [
                Icon(
                  Icons.warning_amber_outlined,
                  // A warning, not an error: as `OrderWarningsBand`.
                  color: theme.colorScheme.tertiary,
                ),
                Expanded(
                  child: Text(
                    l10n.purchaseOrderConfirmZeroPrice(
                      zeroPrice.length,
                      zeroPrice
                          .map((l) => '${l.productCode} ${l.productName}')
                          .join(', '),
                    ),
                  ),
                ),
              ],
            ),
          Text(l10n.purchaseOrderConfirmIrreversible),
        ],
      ),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.purchaseOrderBack,
        onPressed: () => Navigator.of(context).pop(false),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('purchase_order_confirm_submit'),
        label: l10n.purchaseOrderConfirm,
        onPressed: () => Navigator.of(context).pop(true),
      ),
    );
  }
}

/// Asks before removing [line] from its draft order, naming the product.
/// `true` to remove.
Future<bool> showRemoveOrderLineDialog(
  BuildContext context,
  PurchaseOrderLine line,
) async =>
    await showResponsiveDialog<bool>(
      context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        final code = line.productCode.isEmpty
            ? '#${line.productId}'
            : line.productCode;
        return ResponsiveDialog(
          key: const Key('purchase_order_line_remove_dialog'),
          title: l10n.purchaseOrderRemoveTitle,
          body: Text(
            l10n.purchaseOrderRemoveBody('$code ${line.productName}'),
            key: const Key('purchase_order_line_remove_body'),
          ),
          secondaryAction: ResponsiveDialogAction(
            label: l10n.purchaseOrderBack,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          primaryAction: ResponsiveDialogAction(
            key: const Key('purchase_order_line_remove_submit'),
            label: l10n.purchaseOrderRemoveAction,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        );
      },
    ) ??
    false;

/// Asks before cancelling draft [order] (FR-024): it stays cancelled and its
/// request lines go back to Por comprar. `true` to cancel.
Future<bool> showCancelOrderDialog(
  BuildContext context,
  PurchaseOrder order,
) async =>
    await showResponsiveDialog<bool>(
      context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return ResponsiveDialog(
          key: const Key('purchase_order_cancel_dialog'),
          title: l10n.purchaseOrderCancelTitle('${order.id}'),
          body: Text(
            l10n.purchaseOrderCancelBody,
            key: const Key('purchase_order_cancel_body'),
          ),
          secondaryAction: ResponsiveDialogAction(
            label: l10n.purchaseOrderBack,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          primaryAction: ResponsiveDialogAction(
            key: const Key('purchase_order_cancel_submit'),
            label: l10n.purchaseOrderCancelAction,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        );
      },
    ) ??
    false;
