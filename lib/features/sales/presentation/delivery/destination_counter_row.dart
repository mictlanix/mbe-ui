import 'package:flutter/material.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/domain/entities/line_distribution.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The counter's share, always first in the destination list on a mixed sale
/// (FR-009, FR-010) — never shown on a pure-delivery sale.
///
/// Renders from the recorded counter-pickup `Destination` when one exists
/// (a resumed sale, or after the close-time sweep); otherwise from the
/// distribution's own unassigned remainder, which previews where the sweep
/// will put it without creating anything early (research R4). The two
/// sources agree by construction — after the sweep, the created destination
/// holds exactly the quantities the preview was showing.
///
/// No expand affordance and no removal action (FR-011) — it is not a
/// destination the cashier composed.
class DestinationCounterRow extends StatelessWidget {
  const DestinationCounterRow({
    super.key,
    this.counterDestination,
    required this.distribution,
  });

  /// The sale's own counter-pickup destination, if one has been recorded.
  final Destination? counterDestination;

  /// Every sale line's distribution, read for the preview when
  /// [counterDestination] is `null`.
  final List<LineDistribution> distribution;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;

    final destination = counterDestination;
    final int lines;
    final String units;
    if (destination != null) {
      lines = destination.lineCount;
      units = destination.unitCount;
    } else {
      final atCounter = distribution.where((d) => !isZeroAmount(d.atCounter));
      lines = atCounter.length;
      units = atCounter.fold('0', (sum, d) => addAmounts(sum, d.atCounter));
    }

    return Card(
      key: const Key('destination_counter_row'),
      margin: EdgeInsets.symmetric(vertical: spacing.xxs),
      // The same hairline the destination cards beside it carry, so the
      // counter row reads as one of the group rather than a lighter panel
      // above it.
      shape: RoundedRectangleBorder(
        borderRadius: theme.shapes.lgRadius,
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: EdgeInsets.all(spacing.sm),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: theme.shapes.smRadius,
              ),
              child: Icon(
                Icons.store_outlined,
                color: theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
            SizedBox(width: spacing.sm),
            // Counts on their own line beneath the title, not squeezed onto
            // the same row (mirrors `DestinationCard`'s own fix, SC-007) —
            // a fixed-width trailing label overflowed a phone width here
            // exactly as it did on the card.
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.posCounterPickupRemainder,
                    style: theme.typeRoles.cardTitle,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: spacing.xxs),
                    child: Text(
                      l10n.posDestinationCounts(lines, formatQuantity(units)),
                      style: theme.typeRoles.metricLabel.copyWith(
                        color: theme.colorScheme.primary,
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
