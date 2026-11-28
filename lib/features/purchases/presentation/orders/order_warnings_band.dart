import 'package:flutter/material.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_order.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// A warning-toned band listing one line per zero-priced product (spec 080
/// FR-019, research R10), in the look of `RequestMinimumBand`. Computed by
/// the UI; the server's English `warnings` are never shown. Never blocking.
/// Nothing when the list is empty.
class OrderWarningsBand extends StatelessWidget {
  const OrderWarningsBand({super.key, required this.zeroPriceLines});

  /// The lines whose price is 0 (`zeroPriceLines`).
  final List<PurchaseOrderLine> zeroPriceLines;

  @override
  Widget build(BuildContext context) {
    if (zeroPriceLines.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final color = theme.colorScheme.onTertiaryContainer;
    return Material(
      key: const Key('order_warnings_band'),
      color: theme.colorScheme.tertiaryContainer,
      borderRadius: theme.shapes.mdRadius,
      child: Padding(
        padding: EdgeInsets.all(spacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: spacing.sm,
          children: [
            Icon(Icons.warning_amber_outlined, color: color),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: spacing.xs,
                children: [
                  for (final line in zeroPriceLines)
                    Text(
                      l10n.purchaseOrderZeroPriceWarning(
                        line.productCode,
                        line.productName,
                      ),
                      style: TextStyle(color: color),
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
