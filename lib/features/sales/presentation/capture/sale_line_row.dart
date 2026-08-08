import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/widgets/money_formatters.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_line.dart';
import 'package:mbe_ui/features/sales/presentation/capture/sale_line_editing.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// One line, expanded tier (FR-022, FR-023): product, warehouse picker with
/// availability, quantity stepper, unit, in-place price/discount/tax-rate
/// edit, line total, delete, and the non-blocking shortfall warning (FR-025,
/// FR-026). Read-only once `Sale.isEditable` is false (FR-041) — the caller
/// passes `enabled: false` rather than this row deciding on its own.
///
/// Everything it *does* comes from [SaleLineEditing]; this is the wide
/// arrangement of it. See `SaleLineCard` for the compact one.
class SaleLineRow extends ConsumerStatefulWidget {
  const SaleLineRow({
    super.key,
    required this.line,
    required this.facilityId,
    this.enabled = true,
  });

  final SaleLine line;
  final int facilityId;
  final bool enabled;

  @override
  ConsumerState<SaleLineRow> createState() => _SaleLineRowState();
}

class _SaleLineRowState extends ConsumerState<SaleLineRow>
    with SaleLineEditing<SaleLineRow> {
  @override
  SaleLine get line => widget.line;

  @override
  int get facilityId => widget.facilityId;

  @override
  bool get lineEnabled => widget.enabled;

  @override
  void didUpdateWidget(covariant SaleLineRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.line != widget.line) syncFields();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final line = widget.line;
    final enabled = this.enabled;
    final shortfall = this.shortfall(l10n);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    '${line.productCode} — ${line.productName}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Expanded(flex: 2, child: warehousePicker()),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: enabled ? removeLine : null,
                  tooltip: l10n.posRemoveLineTooltip,
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: enabled ? () => step(-1) : null,
                ),
                SizedBox(
                  width: 64,
                  child: TextField(
                    controller: quantityField,
                    enabled: enabled,
                    textAlign: TextAlign.center,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: l10n.posLineQuantityLabel),
                    onSubmitted: (v) => update(quantity: v),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: enabled ? () => step(1) : null,
                ),
                // FR-022's unit column (mbe-api#145). Absent for a product
                // with no unit on file, rather than a placeholder.
                if (line.unit != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      line.unit!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                Expanded(
                  child: TextField(
                    controller: priceField,
                    enabled: enabled,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: l10n.posLinePriceLabel),
                    onSubmitted: (v) => update(price: v),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: discountField,
                    enabled: enabled,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: l10n.posLineDiscountLabel),
                    onSubmitted: (v) => updateRate(discountRate: v),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: taxField,
                    enabled: enabled,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: l10n.posLineTaxLabel),
                    onSubmitted: (v) => updateRate(taxRate: v),
                  ),
                ),
                const SizedBox(width: 8),
                Text(MoneyFormatters.currency(line.total)),
              ],
            ),
            if (shortfall != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber,
                      size: 16,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        shortfall,
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                    if (enabled)
                      TextButton(
                        onPressed: () => update(quantity: availableQuantity),
                        child: Text(l10n.posLineAdjustToAvailable),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
