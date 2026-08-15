import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/widgets/money_formatters.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Always-visible summary (FR-028): line count, unit count, subtotal,
/// discount, tax and grand total, all read directly from [Sale] — never
/// recomputed locally (research.md §1).
///
/// Also carries the step's primary action (spec 023 contracts/pos-workspace.md
/// §3.1): the footer used to be two separate bands — this bar, then a
/// second `Padding` below it holding "Continuar al cobro" — which is exactly
/// the extra vertical space the workspace exists to reclaim. Merged into one
/// band here structurally.
///
/// Each figure sits under its own uppercase label (contracts/capture-surface
/// .md §5) — `TypeRoles.metricLabel`/`.money` for the ordinary groups, the
/// larger `.metricValue` for the grand total, which stays the visually
/// dominant, right-aligned element the mock gives it. No literal font size
/// or color: the mock's palette and 32 px total are a presentation, not a
/// requirement — everything here resolves through the spec 022 tokens.
class SaleTotalsBar extends StatelessWidget {
  const SaleTotalsBar({
    super.key,
    required this.sale,
    required this.onContinue,
    required this.confirming,
    this.compact = false,
  });

  /// `null` on an untouched register (spec 020 — only Venta can render that).
  /// The button still renders (disabled) in that case; only the stats are
  /// skipped, since there is nothing yet to summarize.
  final Sale? sale;

  /// `null` disables the button — there is no sale yet, it has no lines, it
  /// is not editable, or a confirm is already in flight.
  final VoidCallback? onContinue;

  /// Swaps the button's label for a small spinner while `confirm()` runs.
  final bool confirming;

  /// A pinned bottom action is a thumb target on a phone, so the button
  /// takes the full band width there and the stats wrap above it, rather
  /// than sharing one row (spec 020 FR-053).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final currentSale = sale;

    // The counts and the money either side of one rule, as in the mock — a
    // single divider after Artículos, not one between every pair, which would
    // turn a summary into a table. `Wrap` rather than `Row` so the group still
    // degrades at the narrow end of the non-compact range instead of
    // overflowing; the divider simply wraps with them.
    final stats = currentSale == null
        ? const SizedBox.shrink()
        : Wrap(
            spacing: spacing.lg,
            runSpacing: spacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: _groups(context, l10n, currentSale),
          );

    // The total is the mock's own right-aligned block, pushed against the
    // action rather than trailing the other figures — it is the number the
    // cashier reads out, not another stat in the row.
    final total = currentSale == null
        ? const SizedBox.shrink()
        : _group(
            context,
            l10n.posTotalsTotalLabel,
            MoneyFormatters.currency(currentSale.total),
            crossAxisAlignment: CrossAxisAlignment.end,
            figureStyle: Theme.of(context).typeRoles.metricValue,
          );

    final button = FloatingActionButton.extended(
      key: const Key('pos_continue_to_payment'),
      onPressed: onContinue,
      // The step being moved to, named plainly, with the arrow after it — the
      // mock's own `Entrega →`. `FloatingActionButton.extended`'s `icon` slot
      // would put it in front, so the whole thing is the label.
      label: confirming
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.posStepCobro),
                SizedBox(width: spacing.xs),
                const Icon(Icons.arrow_forward),
              ],
            ),
    );

    // Its own surface, not the canvas the lines scroll on: the band is a
    // statement *about* those lines, so it reads as a separate plane beneath
    // them rather than as one more thing in the list. The same fill the line
    // cards carry (`elevations.raised`, what `cardTheme` uses), with the
    // mock's own hairline along the top and square corners — it spans the
    // full width and is pinned to the bottom edge, so there is no corner for
    // a radius to round.
    return Container(
      key: const Key('pos_totals_footer'),
      decoration: BoxDecoration(
        color: theme.elevations.raised.surfaceColor,
        border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      padding: EdgeInsets.symmetric(horizontal: spacing.screenMargin, vertical: spacing.sm),
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                stats,
                SizedBox(height: spacing.xs),
                total,
                SizedBox(height: spacing.xs),
                button,
              ],
            )
          // Centred, so the labelled stat blocks, the total and the action all
          // sit on the band's own middle rather than each on its own edge.
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: stats),
                SizedBox(width: spacing.lg),
                total,
                SizedBox(width: spacing.lg),
                button,
              ],
            ),
    );
  }

  List<Widget> _groups(BuildContext context, AppLocalizations l10n, Sale sale) {
    final unitCount = sale.lines.fold(
      Decimal.zero,
      (sum, line) => sum + (Decimal.tryParse(line.quantity) ?? Decimal.zero),
    );
    final discount = subtractAmounts(addAmounts(sale.subtotal, sale.taxTotal), sale.total);

    return [
      _group(
        context,
        l10n.posTotalsArticlesLabel,
        // The figure is passed twice on purpose: as text, so a fractional
        // quantity prints exactly as `Decimal` rendered it, and as a number,
        // so the noun beside it can agree.
        l10n.posTotalsCounts(
          sale.lineCount,
          unitCount.toString(),
          unitCount.toDouble(),
        ),
      ),
      // What the sale *is* on one side, what it *costs* on the other.
      _divider(context),
      _group(context, l10n.posTotalsSubtotalLabel, MoneyFormatters.currency(sale.subtotal)),
      if (!isZeroAmount(discount))
        // The mock's leading minus is display-only — [discount] itself is
        // still the plain magnitude FR-047 derives from Sale.
        _group(context, l10n.posTotalsDiscountLabel, '−${MoneyFormatters.currency(discount)}'),
      _group(context, l10n.posTotalsTaxLabel, MoneyFormatters.currency(sale.taxTotal)),
    ];
  }

  /// The mock's single hairline rule between the counts and the money — a
  /// fixed 44 px so it reads as a divider between two blocks rather than
  /// stretching to whatever the tallest neighbour happens to be.
  Widget _divider(BuildContext context) => Container(
    key: const Key('pos_totals_divider'),
    width: 1,
    height: 44,
    color: Theme.of(context).colorScheme.outlineVariant,
  );

  /// One labelled stat: the smallest label role, letter-spaced and
  /// uppercased (the same treatment `facility_child_section.dart` gives its
  /// own group labels), over the figure in [figureStyle] — `.money`
  /// (tabular figures) unless the caller wants something else, as the total
  /// group does.
  Widget _group(
    BuildContext context,
    String label,
    String figure, {
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
    TextStyle? figureStyle,
  }) {
    final theme = Theme.of(context);
    final typeRoles = theme.typeRoles;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          label.toUpperCase(),
          style: typeRoles.metricLabel.copyWith(
            letterSpacing: 0.8,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(figure, style: figureStyle ?? typeRoles.money),
      ],
    );
  }
}
