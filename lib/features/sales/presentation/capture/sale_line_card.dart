import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/confirmable_text_field.dart';
import 'package:mbe_ui/core/widgets/product_photo.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_line.dart';
import 'package:mbe_ui/features/sales/presentation/capture/sale_line_editing.dart';
import 'package:mbe_ui/features/sales/presentation/widgets/quantity_stepper.dart';
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
    this.showComment = false,
  });

  final SaleLine line;
  final int facilityId;
  final bool enabled;

  /// Renders an editable per-line comment beneath the card (spec 029
  /// FR-020). `false` (the default) leaves the register's layout exactly as
  /// it was before this feature — only the back-office order screen passes
  /// `true`.
  final bool showComment;

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
    if (oldWidget.line != widget.line) {
      syncFields();
      if (widget.showComment) commentField.sync(value: line.comment ?? '');
    }
  }

  @override
  void dispose() {
    if (widget.showComment) commentField.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final line = widget.line;
    final enabled = this.enabled;
    final shortfall = this.shortfall(l10n);
    final fmt = ref.watch(formattersProvider);

    return Card(
      key: Key('sale_line_card_${line.id}'),
      margin: const EdgeInsets.symmetric(vertical: 4),
      // Outlined, as in `SaleLineRow` and the customer band.
      shape: RoundedRectangleBorder(
        borderRadius: theme.shapes.mdRadius,
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // Every gap in this column is a uniform 8px (spec 028 US2 worked
          // example, contracts/spacing-conversion.md) — declared once here
          // rather than as a SizedBox between every child. The conditional
          // shortfall child below needed a Padding(top: 8) only because a
          // collection-`if` child can't take a preceding spacer; `spacing`
          // handles that natively; when `shortfall` is null the child never
          // enters the list, so no gap is left dangling.
          spacing: 8,
          children: [
            // Product and the line's own total — the two things worth seeing
            // without reading any further.
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // The product's real photo since mbe-api#157 (spec 023 research
                // R11) put one on both shapes a till reads; the shared widget
                // still placeholders a product without one.
                ProductPhoto(photoUrl: line.photo, size: 36),
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
                  fmt.display.currency(line.total),
                  style: theme.textTheme.titleMedium,
                ),
                // The error colour every destructive action in the product
                // carries, as in `SaleLineRow`.
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  style: IconButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                  ),
                  onPressed: enabled ? removeLine : null,
                  tooltip: l10n.posRemoveLineTooltip,
                ),
              ],
            ),
            // Quantity gets its own row: it is the field a cashier touches
            // most, and the steppers need room for a thumb. [QuantityStepper]
            // (spec 030), gated on [lineEnabled] alone rather than [enabled]:
            // the quantity control stays live through a discount/tax/
            // warehouse write in flight (FR-004) — `_enqueue` in
            // `sale_line_editing.dart` is what keeps the writes from racing.
            QuantityStepper(
              key: ValueKey('quantity-stepper-${line.id}'),
              controller: quantityStepper,
              enabled: lineEnabled,
              fieldKey: Key('sale_line_quantity_${line.id}'),
              decoration: InputDecoration(
                labelText: l10n.posLineQuantityLabel,
                // FR-022's unit, inline rather than in a column of its
                // own — there is no room for one at this width.
                suffixText: line.unit,
              ),
              decrementTooltip: l10n.posLineDecreaseQuantity,
              incrementTooltip: l10n.posLineIncreaseQuantity,
            ),
            // Read-only here as in the wide row (FR-038c) — a price is
            // adjusted through the discount, not typed over.
            TextField(
              controller: priceField,
              readOnly: true,
              canRequestFocus: false,
              mouseCursor: SystemMouseCursors.basic,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              decoration: InputDecoration(labelText: l10n.posLinePriceLabel),
            ),
            Row(
              spacing: 8,
              children: [
                Expanded(
                  child: ConfirmableTextField(
                    controller: discountField,
                    fieldKey: Key('sale_line_discount_${line.id}'),
                    enabled: enabled,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: l10n.posLineDiscountLabel,
                    ),
                    format: (wire) => ref.read(formattersProvider).field.rate(wire),
                  ),
                ),
                // Chosen, not typed (FR-038b).
                Expanded(child: taxRatePicker()),
              ],
            ),
            warehousePicker(),
            // Stacked rather than side by side: the warning text and the
            // adjust action both need the full width here. No Padding(top: 8)
            // wrapper — the outer Column's own `spacing` supplies that gap,
            // and only when this child is actually present.
            if (shortfall != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    spacing: 4,
                    children: [
                      Icon(
                        Icons.warning_amber,
                        size: 16,
                        color: theme.colorScheme.error,
                      ),
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
                      onPressed: () => quantityStepper.set(availableQuantity),
                      child: Text(l10n.posLineAdjustToAvailable),
                    ),
                ],
              ),
            if (widget.showComment)
              ConfirmableTextField(
                controller: commentField,
                enabled: enabled,
                fieldKey: Key('sale_line_comment_${line.id}'),
                decoration: InputDecoration(labelText: l10n.salesOrderCommentLabel),
              ),
          ],
        ),
      ),
    );
  }
}
