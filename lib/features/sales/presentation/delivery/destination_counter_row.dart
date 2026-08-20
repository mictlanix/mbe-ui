import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/domain/entities/line_distribution.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';
import 'package:mbe_ui/features/sales/presentation/delivery/destination_line_row.dart';
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
/// No edit affordance and no removal action (FR-011, spec 030 FR-023) — it
/// is not a destination the cashier composed. Expandable like
/// `DestinationCard` (spec 030 US4), so the cashier can see *which* units
/// stay at the store, not only how many (FR-025…FR-030): expanded, it lists
/// every sale line — zeros included — with the sum of what a recorded
/// counter-pickup destination already holds for it plus whatever is still
/// unassigned to anything (data-model.md §3). Own expansion state,
/// independent of every `DestinationCard`'s (FR-025), for the same reason
/// card expansion is view-local rather than a provider (research, spec 026
/// data-model §4).
class DestinationCounterRow extends ConsumerStatefulWidget {
  const DestinationCounterRow({
    super.key,
    this.counterDestination,
    required this.distribution,
  });

  /// The sale's own counter-pickup destination, if one has been recorded.
  final Destination? counterDestination;

  /// Every sale line's distribution, read both for the header preview when
  /// [counterDestination] is `null` and for the expanded body always
  /// (FR-026, FR-027).
  final List<LineDistribution> distribution;

  @override
  ConsumerState<DestinationCounterRow> createState() => _DestinationCounterRowState();
}

class _DestinationCounterRowState extends ConsumerState<DestinationCounterRow> {
  bool _expanded = false;

  /// The total quantity staying at the store for [line] (data-model.md §3):
  /// what a recorded counter-pickup destination already holds for it, plus
  /// whatever is still unassigned to any destination. The two single-source
  /// cases this replaces — a preview with no recorded destination, or a
  /// recorded destination with nothing left over — reduce to exactly what
  /// each used to report alone; the sum only differs on a resumed mixed sale
  /// carrying both at once, where today's header under-reports (research
  /// R11).
  String _storeShare(LineDistribution line) {
    final destination = widget.counterDestination;
    final recorded = destination == null
        ? '0'
        : (line.perDestination[destination.id] ?? '0');
    return addAmounts(recorded, line.atCounter);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final fmt = ref.watch(formattersProvider);

    // FR-027/FR-028: one computed list feeds the header counts and the
    // expanded body, so the two can never disagree.
    final shares = [for (final line in widget.distribution) _storeShare(line)];
    final lines = shares.where((q) => !isZeroAmount(q)).length;
    final units = shares.fold('0', addAmounts);

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: theme.shapes.lgRadius,
            onTap: () => setState(() => _expanded = !_expanded),
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
                  // Counts on their own line beneath the title, not squeezed
                  // onto the same row (mirrors `DestinationCard`'s own fix,
                  // SC-007) — a fixed-width trailing label overflowed a
                  // phone width here exactly as it did on the card.
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
                            l10n.posDestinationCounts(lines, fmt.field.quantity(units)),
                            style: theme.typeRoles.metricLabel.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: _expanded
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Divider(height: 1, color: theme.colorScheme.outlineVariant),
                      Padding(
                        padding: EdgeInsets.fromLTRB(spacing.sm, 0, spacing.sm, spacing.sm),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.posCounterPickupLinesTitle,
                              style: theme.typeRoles.metricLabel,
                            ),
                            for (var i = 0; i < widget.distribution.length; i++)
                              DestinationLineRow(
                                key: Key('counter_line_${widget.distribution[i].saleLineId}'),
                                productName: widget.distribution[i].productName,
                                quantity: shares[i],
                                fmt: fmt,
                              ),
                          ],
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
