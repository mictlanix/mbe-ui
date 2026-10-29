import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/compact_field.dart';
import 'package:mbe_ui/features/sales/domain/entities/customer_refund.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// One refund line as a stacked block for compact screens (spec 057 contracts
/// C8): product, then price and refundable quantity, then the return control,
/// the warehouse and the total.
///
/// The controls are passed in already built, so the detail screen wires one
/// set of handlers for this block and for a table row alike. [quantity] and
/// [warehouse] are the draft's stepper and tap-field, or plain text when the
/// refund is read-only; [error] is a refused write's server detail.
class RefundLineBlock extends ConsumerWidget {
  const RefundLineBlock({
    super.key,
    required this.line,
    required this.quantity,
    required this.warehouse,
    this.quantityLabel,
    this.error,
  });

  final RefundLine line;
  final Widget quantity;
  final Widget warehouse;

  /// Caption over [quantity]; defaults to "Devolver".
  final String? quantityLabel;
  final String? error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final fmt = ref.watch(formattersProvider);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${line.productCode} · ${line.productName}',
            style: theme.textTheme.titleSmall,
          ),
          SizedBox(height: spacing.xs),
          Text(
            '${fmt.display.currency(line.price)} · '
            '${l10n.refundColumnRefundable} '
            '${fmt.field.quantity(line.refundableQuantity)}',
            style: theme.textTheme.bodySmall,
          ),
          SizedBox(height: spacing.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: CompactField(
                  label: quantityLabel ?? l10n.refundColumnReturn,
                  fillWidth: true,
                  child: quantity,
                ),
              ),
              SizedBox(width: spacing.sm),
              Expanded(
                flex: 3,
                child: CompactField(
                  label: l10n.refundColumnWarehouse,
                  fillWidth: true,
                  child: warehouse,
                ),
              ),
              SizedBox(width: spacing.sm),
              Expanded(
                flex: 2,
                child: CompactField(
                  label: l10n.refundColumnTotal,
                  fillWidth: true,
                  child: Text(fmt.display.currency(line.total)),
                ),
              ),
            ],
          ),
          if (error != null) ...[
            SizedBox(height: spacing.xs),
            Text(
              error!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
