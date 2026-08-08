import 'package:flutter/material.dart';

import 'package:mbe_ui/features/sales/domain/entities/line_distribution.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// FR-033: for every line, how much was ordered, how much is spoken for, and
/// how much is still at the counter — the running answer to "is this sale
/// fully distributed yet".
class LineDistributionPanel extends StatelessWidget {
  const LineDistributionPanel({super.key, required this.distribution});

  final List<LineDistribution> distribution;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      key: const Key('line_distribution_panel'),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.posDistributionTitle, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            for (final line in distribution)
              Padding(
                key: Key('distribution_row_${line.saleLineId}'),
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(flex: 3, child: Text(line.productName)),
                    Expanded(
                      child: Text(
                        l10n.posDistributionOrdered(formatQuantity(line.ordered)),
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        l10n.posDistributionAssigned(
                          formatQuantity(line.distributed),
                        ),
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        l10n.posDistributionAtCounter(
                          formatQuantity(line.atCounter),
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: line.isOverClaimed
                              ? theme.colorScheme.error
                              : line.isFullyDistributed
                              ? theme.colorScheme.primary
                              : null,
                        ),
                      ),
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
