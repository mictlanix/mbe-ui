import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/formatting/app_formatters.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/domain/entities/line_distribution.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// FR-033: for every line, how much was ordered and where each destination's
/// share of it is going — the running answer to "is this sale fully
/// distributed yet", read directly (contract §5.2) rather than derived by
/// subtracting four columns as the old panel did.
///
/// Each row's chips carry the same badge letters [DestinationCard] shows in
/// its own header (research R8) — [badges] is built once by
/// `delivery_step.dart` and handed to both, so the two can never disagree.
///
/// `ListView.separated(shrinkWrap: true)` — safe both wrapped in an
/// `Expanded` (the wide rail, where it scrolls on its own, FR-007) and as a
/// plain child of the step's own outer `ListView` below the two-region
/// threshold (mirrors `AppliedPaymentsPanel`'s precedent).
class LineDistributionPanel extends ConsumerWidget {
  const LineDistributionPanel({
    super.key,
    required this.distribution,
    required this.badges,
    required this.destinationGroupCount,
    required this.isMixed,
    this.counterDestination,
    this.fillHeight = false,
  });

  final List<LineDistribution> distribution;

  /// Destination id → its positional badge (`D1`, `D2`, …) — addressed
  /// destinations only (research R8).
  final Map<int, String> badges;

  /// How many groups the destinations region is showing (addressed + the
  /// counter row, when present) — FR-035's header count.
  final int destinationGroupCount;

  final bool isMixed;

  /// The sale's own counter-pickup destination, if one has been recorded —
  /// same value `DestinationCounterRow` reads, so a line's counter chip and
  /// the counter row agree on the same either/or rule (research R4): once a
  /// destination is recorded, its own lines are the answer; otherwise the
  /// distribution's own unclaimed remainder previews it.
  final Destination? counterDestination;

  /// `true` at the wide, two-region tier: the header stays put and only the
  /// row list scrolls (FR-007). `false` below the threshold, where this
  /// whole widget is a plain child of the step's outer scrolling `ListView`.
  final bool fillHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final typeRoles = theme.typeRoles;
    final fmt = ref.watch(formattersProvider);

    // The mock's `border-bottom` under the rail title — the header states
    // what the list below it is, so a rule closes it rather than leaving the
    // first row to run straight into the subtitle.
    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            spacing.none,
            spacing.md,
            spacing.none,
            spacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.posDistributionTitle, style: typeRoles.sectionHeading),
              Text(
                l10n.posDistributionRailSubtitle(
                  distribution.length,
                  destinationGroupCount,
                ),
                style: typeRoles.metricLabel,
              ),
            ],
          ),
        ),
        Divider(height: 1, color: theme.colorScheme.outlineVariant),
        SizedBox(height: spacing.xs),
      ],
    );

    final rows = ListView.separated(
      key: const Key('line_distribution_panel'),
      shrinkWrap: true,
      physics: fillHeight ? null : const NeverScrollableScrollPhysics(),
      itemCount: distribution.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: theme.colorScheme.outlineVariant,
      ),
      itemBuilder: (context, index) => _row(context, l10n, fmt, distribution[index]),
    );

    if (fillHeight) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [header, Expanded(child: rows)],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [header, rows],
    );
  }

  Widget _row(
    BuildContext context,
    AppLocalizations l10n,
    AppFormatters fmt,
    LineDistribution line,
  ) {
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final typeRoles = theme.typeRoles;

    final chips = <String>[];
    for (final entry in line.perDestination.entries) {
      if (counterDestination != null && entry.key == counterDestination!.id) {
        continue;
      }
      if (isZeroAmount(entry.value)) continue;
      final badge = badges[entry.key];
      if (badge == null) continue;
      chips.add('$badge ${fmt.field.quantity(entry.value)}');
    }
    final counterShare = counterDestination != null
        ? (line.perDestination[counterDestination!.id] ?? '0')
        : line.atCounter;
    if (!isZeroAmount(counterShare)) {
      chips.add(l10n.posDestinationCounterChip(fmt.field.quantity(counterShare)));
    }

    // FR-034: a pure-delivery line still outstanding is marked, never by
    // colour alone. On a mixed sale a non-zero counter share is the normal
    // shape of the sale, not a problem.
    final outstanding = !isMixed && !line.isFullyDistributed;
    final overClaimed = line.isOverClaimed;

    return Padding(
      key: Key('distribution_row_${line.saleLineId}'),
      padding: EdgeInsets.symmetric(vertical: spacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.productName,
                  style: typeRoles.tableCell,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (chips.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: spacing.xxs),
                    child: Wrap(
                      spacing: spacing.xs,
                      runSpacing: spacing.xxs,
                      children: [
                        for (final chip in chips) _chip(context, chip),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: spacing.sm),
          if (overClaimed || outstanding)
            Padding(
              padding: EdgeInsets.only(right: spacing.xxs),
              child: Icon(
                overClaimed ? Icons.error_outline : Icons.warning_amber_outlined,
                size: 16,
                color: overClaimed
                    ? theme.colorScheme.error
                    : theme.colorScheme.tertiary,
              ),
            ),
          Text(
            fmt.field.quantity(line.ordered),
            style: typeRoles.recordId.copyWith(
              color: overClaimed
                  ? theme.colorScheme.error
                  : outstanding
                  ? theme.colorScheme.tertiary
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, String label) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: theme.spacing.xs, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: theme.shapes.smRadius,
      ),
      child: Text(label, style: theme.typeRoles.recordId),
    );
  }
}

/// The pinned block at the rail's foot (contract §5.3): the assigned-units
/// total, the outstanding-lines reason while the gate is closed, and the
/// finish action — `isDistributionComplete` and the close handling moved
/// here from `delivery_step.dart`, not reimplemented (FR-001).
class LineDistributionFoot extends ConsumerWidget {
  const LineDistributionFoot({
    super.key,
    required this.assigned,
    required this.total,
    this.outstandingMessage,
    required this.onClose,
    required this.closing,
    this.onSweepAndClose,
  });

  final String assigned;
  final String total;

  /// `null` when the gate is open or the sale is mixed — shown only while a
  /// pure-delivery sale still has something outstanding (FR-037).
  final String? outstandingMessage;

  /// `null` disables the button.
  final VoidCallback? onClose;
  final bool closing;

  /// Sweeps whatever is unassigned to the counter and finishes, offered only
  /// while [outstandingMessage] is blocking the close.
  ///
  /// Without it a sale whose remainder is *meant* for the counter is a dead
  /// end: `FulfillmentMode.mixed` is UI-only state that `resumeTargetFor`
  /// cannot reconstruct (it answers `delivery` or `counterPickup` only), so
  /// any resumed mixed sale comes back looking pure-delivery and its
  /// remainder blocks the close forever. Asking here is what
  /// `fulfillment_mode.dart` means by "the delivery step itself asks about
  /// rather than inferring".
  final VoidCallback? onSweepAndClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final fmt = ref.watch(formattersProvider);

    return Container(
      padding: EdgeInsets.all(spacing.cardPadding),
      decoration: BoxDecoration(
        color: theme.elevations.raised.surfaceColor,
        border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.posDeliveryAssignedUnits(
              fmt.field.quantity(assigned),
              fmt.field.quantity(total),
            ),
            style: theme.typeRoles.metricLabel,
          ),
          if (outstandingMessage != null) ...[
            SizedBox(height: spacing.xs),
            Text(
              key: const Key('delivery_outstanding_notice'),
              outstandingMessage!,
              style: TextStyle(color: theme.colorScheme.error),
            ),
            if (onSweepAndClose != null) ...[
              SizedBox(height: spacing.xs),
              // Secondary, and only ever shown beside the reason the close is
              // blocked, so the remainder still has to be a deliberate
              // decision rather than something the primary button does
              // quietly.
              OutlinedButton.icon(
                key: const Key('delivery_sweep_to_counter_button'),
                onPressed: closing ? null : onSweepAndClose,
                icon: const Icon(Icons.store_outlined),
                label: Text(l10n.posDeliverRestAtCounter),
              ),
            ],
          ],
          SizedBox(height: spacing.sm),
          // The same footer action `SaleTotalsBar` carries on the capture
          // step: an extended FAB, stretched by the column it sits in, with
          // the icon after the label. A check rather than an arrow — this
          // one ends the sale instead of moving to the next step.
          //
          // A FAB keeps its own fill when `onPressed` is null, so the gated
          // state is spelled out here — without it the button would look
          // pressable while units are still unassigned, which the
          // `FilledButton` this replaces got for free.
          FloatingActionButton.extended(
            key: const Key('delivery_close_button'),
            onPressed: onClose,
            backgroundColor: onClose == null
                ? theme.colorScheme.onSurface.withValues(alpha: 0.12)
                : null,
            foregroundColor: onClose == null
                ? theme.colorScheme.onSurface.withValues(alpha: 0.38)
                : null,
            label: closing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(l10n.posFinishSale),
                      SizedBox(width: spacing.xs),
                      const Icon(Icons.check),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
