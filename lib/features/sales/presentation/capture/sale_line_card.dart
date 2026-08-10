import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/widgets/money_formatters.dart';
import 'package:mbe_ui/core/widgets/product_photo.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_line.dart';
import 'package:mbe_ui/features/sales/presentation/capture/sale_line_editing.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// One line, compact tier (US5, FR-053, SC-007): the same controls as
/// `SaleLineRow` stacked into a phone-width card instead of strung across one
/// row. Nothing is dropped — every field FR-022 asks for is still editable —
/// they are simply reached by scrolling down rather than across.
///
/// Behaviour comes wholesale from [SaleLineEditing]; this file is layout.
class SaleLineCard extends ConsumerStatefulWidget {
  const SaleLineCard({
    super.key,
    required this.line,
    required this.facilityId,
    this.enabled = true,
  });

  final SaleLine line;
  final int facilityId;
  final bool enabled;

  @override
  ConsumerState<SaleLineCard> createState() => _SaleLineCardState();
}

class _SaleLineCardState extends ConsumerState<SaleLineCard>
    with SaleLineEditing<SaleLineCard> {
  @override
  SaleLine get line => widget.line;

  @override
  int get facilityId => widget.facilityId;

  @override
  bool get lineEnabled => widget.enabled;

  @override
  void didUpdateWidget(covariant SaleLineCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.line != widget.line) syncFields();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final line = widget.line;
    final enabled = this.enabled;
    final shortfall = this.shortfall(l10n);

    return Card(
      key: Key('sale_line_card_${line.id}'),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product and the line's own total — the two things worth seeing
            // without reading any further.
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Reserved slot (spec 023 research R11): neither the
                // product-lookup nor the sale-line payload carries a photo
                // today, so this is the shared placeholder until mbe-api
                // exposes one.
                const ProductPhoto(photoUrl: null, size: 36),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(line.productName, style: theme.textTheme.bodyLarge),
                      Text(
                        line.productCode,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  MoneyFormatters.currency(line.total),
                  style: theme.textTheme.titleMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: enabled ? removeLine : null,
                  tooltip: l10n.posRemoveLineTooltip,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Quantity gets its own row: it is the field a cashier touches
            // most, and the steppers need room for a thumb.
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  tooltip: l10n.posLineDecreaseQuantity,
                  onPressed: enabled ? () => step(-1) : null,
                ),
                Expanded(
                  child: TextField(
                    controller: quantityField,
                    enabled: enabled,
                    textAlign: TextAlign.center,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: l10n.posLineQuantityLabel,
                      // FR-022's unit, inline rather than in a column of its
                      // own — there is no room for one at this width.
                      suffixText: line.unit,
                    ),
                    onSubmitted: (v) => update(quantity: v),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: l10n.posLineIncreaseQuantity,
                  onPressed: enabled ? () => step(1) : null,
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: priceField,
              enabled: enabled,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: l10n.posLinePriceLabel),
              onSubmitted: (v) => update(price: v),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: discountField,
                    enabled: enabled,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: l10n.posLineDiscountLabel,
                    ),
                    onSubmitted: (v) => updateRate(discountRate: v),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: taxField,
                    enabled: enabled,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(labelText: l10n.posLineTaxLabel),
                    onSubmitted: (v) => updateRate(taxRate: v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            warehousePicker(),
            if (shortfall != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                // Stacked rather than side by side: the warning text and the
                // adjust action both need the full width here.
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber,
                          size: 16,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            shortfall,
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        ),
                      ],
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
