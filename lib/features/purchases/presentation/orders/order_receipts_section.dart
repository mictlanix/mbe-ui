import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/widgets/record_id_text.dart';
import 'package:mbe_ui/features/inventory/presentation/receipts/inventory_receipts_list_screen.dart';
import 'package:mbe_ui/features/inventory/presentation/shared/inventory_name_cells.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_order.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// "Entradas": the entry receipts the last confirm created (spec 080 FR-022,
/// research R11), one row each with its number, warehouse, facility and line
/// count. "Abrir" opens the receipt's detail and needs InventoryReceipts
/// (SystemObject 15) read; without it the button is absent.
///
/// Renders nothing for an empty list, which is every plain load: `GET`
/// returns no receipts until mictlanix/mbe-api#355.
///
/// simplified: no state chip per receipt, because the confirm response
/// carries none; add `InventoryDocumentStatusChip` when mictlanix/mbe-api#355
/// returns the receipts with their state.
class OrderReceiptsSection extends ConsumerWidget {
  const OrderReceiptsSection({super.key, required this.receipts});

  final List<OrderReceipt> receipts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (receipts.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    // InventoryReceipts (15) read: the receipt detail's route gate.
    final canOpen = ref
        .watch(accessControlProvider)
        .can(SystemObject.inventoryReceipts, AccessRight.read);

    return Column(
      key: const Key('purchase_order_receipts'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: spacing.sm,
      children: [
        Text(
          l10n.purchaseOrderReceiptsTitle,
          style: theme.textTheme.titleMedium,
        ),
        for (final receipt in receipts)
          Row(
            key: Key('purchase_order_receipt_${receipt.id}'),
            spacing: spacing.md,
            children: [
              RecordIdText(l10n.purchaseOrderReceiptItem('${receipt.id}')),
              Expanded(
                child: Row(
                  spacing: spacing.xs,
                  children: [
                    Flexible(
                      child: InventoryWarehouseName(
                        warehouseId: receipt.warehouseId,
                      ),
                    ),
                    const Text('·'),
                    Flexible(
                      child: InventoryFacilityName(
                        facilityId: receipt.facilityId,
                      ),
                    ),
                  ],
                ),
              ),
              Text(l10n.toPurchaseLineCount(receipt.lineCount)),
              if (canOpen)
                TextButton(
                  key: Key('purchase_order_receipt_open_${receipt.id}'),
                  onPressed: () =>
                      context.push('$inventoryReceiptsPath/${receipt.id}'),
                  child: Text(l10n.purchaseOrderReceiptOpen),
                ),
            ],
          ),
      ],
    );
  }
}
