import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';
import 'package:mbe_ui/features/sales/domain/entities/product_lookup_result.dart';
import 'package:mbe_ui/features/sales/presentation/capture/product_stock_cache.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Picks the warehouse a sale line is taken from (spec 047 FR-012, C5). One
/// row per warehouse with its full name and what is known of its stock for
/// [quantity]; the current one is marked. Returns the picked id, or `null`
/// when the cashier backed out.
///
/// [productName] only titles the pop-up's subtitle.
Future<int?> showWarehousePicker(
  BuildContext context, {
  required List<Warehouse> warehouses,
  required int? selected,
  required ProductStock? stock,
  required Decimal quantity,
  String? productName,
}) {
  return showDialog<int>(
    context: context,
    builder: (_) => _WarehousePickerDialog(
      warehouses: warehouses,
      selected: selected,
      stock: stock,
      quantity: quantity,
      productName: productName,
    ),
  );
}

class _WarehousePickerDialog extends ConsumerWidget {
  const _WarehousePickerDialog({
    required this.warehouses,
    required this.selected,
    required this.stock,
    required this.quantity,
    required this.productName,
  });

  final List<Warehouse> warehouses;
  final int? selected;
  final ProductStock? stock;
  final Decimal quantity;
  final String? productName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final fmt = ref.watch(formattersProvider);
    final quantityText = fmt.field.quantity(quantity.toString());
    final subtitle = productName == null
        ? quantityText
        : '$productName · $quantityText';
    // A product present in the cache but not checked has no stock to run out
    // of (R5): any warehouse is valid, so no row warns.
    final notTracked = stock != null && !stock!.checked;

    return AlertDialog(
      key: const Key('warehouse_picker_dialog'),
      // Keeps a 16 px inset at phone width so the 480 px cap still fits.
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.posWarehousePickerTitle),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (notTracked)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(l10n.posWarehousePickerNotTracked),
              ),
            Flexible(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 320),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: warehouses.length,
                  itemBuilder: (context, index) {
                    final w = warehouses[index];
                    final isCurrent = w.warehouseId == selected;
                    return ListTile(
                      key: Key('warehouse_option_${w.warehouseId}'),
                      minTileHeight: 56,
                      selected: isCurrent,
                      // A translucent tint, not a solid primaryContainer: on
                      // the solid fill the red short/no-stock flag was barely
                      // legible. The name keeps the regular text colour (an
                      // amber name on the light theme's cream tint did not
                      // read); the check alone carries `primary`.
                      selectedTileColor: scheme.primary.withValues(alpha: 0.16),
                      selectedColor: scheme.onSurface,
                      leading: SizedBox(
                        width: 24,
                        child: isCurrent
                            ? Icon(Icons.check, color: scheme.primary)
                            : null,
                      ),
                      title: Text(w.name),
                      subtitle: notTracked
                          ? null
                          : WarehouseStockFlag(
                              stock: stock,
                              warehouseId: w.warehouseId,
                              quantity: quantity,
                            ),
                      onTap: () => Navigator.of(context).pop(w.warehouseId),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancelButton),
        ),
      ],
    );
  }
}

/// How a warehouse's stock compares with an ordered quantity.
enum WarehouseStockLevel { enough, short, none, unknown }

/// The 4-state stock flag (data-model.md §6, FR-020/FR-021): the confirmed
/// available quantity when it covers [quantity], otherwise the short or
/// exhausted wording with a warning icon, or "not checked" when [stock] has no
/// row for the warehouse.
class WarehouseStockFlag extends ConsumerWidget {
  const WarehouseStockFlag({
    super.key,
    required this.stock,
    required this.warehouseId,
    required this.quantity,
  });

  final ProductStock? stock;
  final int warehouseId;
  final Decimal quantity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final fmt = ref.watch(formattersProvider);
    final theme = Theme.of(context);
    final outline = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final warning = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.error,
    );
    WarehouseStock? row;
    for (final entry in stock?.warehouses ?? const <WarehouseStock>[]) {
      if (entry.warehouse == warehouseId) row = entry;
    }
    final available = Decimal.tryParse(row?.available ?? '') ?? Decimal.zero;
    final level = row == null
        ? WarehouseStockLevel.unknown
        : available.sign <= 0
        ? WarehouseStockLevel.none
        : quantity > available
        ? WarehouseStockLevel.short
        : WarehouseStockLevel.enough;
    Widget warn(String text) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.warning_amber, size: 14, color: warning?.color),
        const SizedBox(width: 4),
        Flexible(child: Text(text, style: warning)),
      ],
    );
    return switch (level) {
      WarehouseStockLevel.enough => Text(
        fmt.field.quantity(row!.available),
        style: outline,
      ),
      WarehouseStockLevel.unknown => Text(
        l10n.posLineWarehouseStockUnknown,
        style: outline,
      ),
      WarehouseStockLevel.short => warn(
        l10n.posLineWarehouseStockShort(fmt.field.quantity(row!.available)),
      ),
      WarehouseStockLevel.none => warn(l10n.posLineWarehouseStockNone),
    };
  }
}
