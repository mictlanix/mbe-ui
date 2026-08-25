import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/formatting/app_formatters.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_line.dart';
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
class SaleTotalsBar extends ConsumerWidget {
  const SaleTotalsBar({
    super.key,
    required this.sale,
    required this.onContinue,
    required this.confirming,
    this.compact = false,
    this.actionLabel,
    this.actionKey = const Key('pos_continue_to_payment'),
    this.showAction = true,
    this.secondaryAction,
  });

  /// `null` on an untouched register (spec 020 — only Venta can render that).
  /// The band renders in full there too, reading zeros — the same figures a
  /// sale opened a moment later starts on — so nothing about this footer
  /// moves when the first action creates one.
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

  /// Overrides the primary action's label and drops the arrow icon — the
  /// back-office order screen's own "Confirm" rather than the register's
  /// "step being moved to" wording (spec 029 FR-025). `null` (the default)
  /// keeps the register's own label and arrow exactly as before this
  /// feature.
  final String? actionLabel;

  /// The primary action button's widget key. A second screen reusing this
  /// bar needs its own key for widget tests to find its button; defaults to
  /// the register's existing key so POS tests are unaffected.
  final Key actionKey;

  /// `false` omits the primary action entirely — not merely disabled
  /// (spec 029 FR-027, contracts/sales-orders-screen.md §2.5): a confirmed,
  /// paid or cancelled back-office order offers no confirm affordance at
  /// all. `true` (the default) keeps every POS sale's behaviour unchanged —
  /// the register never renders a state this bar exists for that isn't
  /// still on the Venta step, so its button is always meaningful there.
  final bool showAction;

  /// A low-emphasis action rendered immediately before the primary one
  /// (spec 032 FR-013) — the back-office order screen's "Cancel order",
  /// which used to sit in a band of its own beneath this bar. `null` (the
  /// default) renders the bar exactly as it was, so every register screen
  /// is untouched (FR-019).
  final Widget? secondaryAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final currentSale = sale;
    final fmt = ref.watch(formattersProvider);

    // The counts and the money either side of one rule, as in the mock — a
    // single divider after Artículos, not one between every pair, which would
    // turn a summary into a table. `Wrap` rather than `Row` so the group still
    // degrades at the narrow end of the non-compact range instead of
    // overflowing; the divider simply wraps with them.
    final stats = Wrap(
      spacing: spacing.lg,
      runSpacing: spacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: _groups(context, fmt, l10n, currentSale),
    );

    // The total is the mock's own right-aligned block, pushed against the
    // action rather than trailing the other figures — it is the number the
    // cashier reads out, not another stat in the row.
    final total = _group(
      context,
      l10n.posTotalsTotalLabel,
      fmt.display.currency(currentSale?.total ?? '0'),
      crossAxisAlignment: CrossAxisAlignment.end,
      figureStyle: Theme.of(context).typeRoles.metricValue,
    );

    final label = actionLabel;
    final button = FloatingActionButton.extended(
      key: actionKey,
      onPressed: onContinue,
      // The step being moved to, named plainly, with the arrow after it — the
      // mock's own `Entrega →`. `FloatingActionButton.extended`'s `icon` slot
      // would put it in front, so the whole thing is the label. A caller
      // that supplies [actionLabel] gets that text with no arrow instead —
      // there is no "next step" for it to point at.
      label: confirming
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : label != null
          ? Text(label)
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
                if (secondaryAction != null) ...[
                  SizedBox(height: spacing.xs),
                  secondaryAction!,
                ],
                if (showAction) ...[
                  SizedBox(height: spacing.xs),
                  button,
                ],
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
                if (secondaryAction != null) ...[
                  SizedBox(width: spacing.lg),
                  secondaryAction!,
                ],
                if (showAction) ...[
                  SizedBox(width: secondaryAction == null ? spacing.lg : spacing.xs),
                  button,
                ],
              ],
            ),
    );
  }

  /// [sale] is `null` on a register nobody has started yet, and the figures
  /// are then all zero — which is *exactly* what a freshly opened sale reads
  /// too, so the band does not change shape at the moment the first action
  /// creates one. It used to render nothing there and then grow this whole
  /// row in place, one of the jumps that made starting a sale feel like the
  /// screen was reassembling itself.
  List<Widget> _groups(
    BuildContext context,
    AppFormatters fmt,
    AppLocalizations l10n,
    Sale? sale,
  ) {
    final unitCount = (sale?.lines ?? const <SaleLine>[]).fold(
      Decimal.zero,
      (sum, line) => sum + (Decimal.tryParse(line.quantity) ?? Decimal.zero),
    );
    final subtotal = sale?.subtotal ?? '0';
    final taxTotal = sale?.taxTotal ?? '0';
    final discount = subtractAmounts(
      addAmounts(subtotal, taxTotal),
      sale?.total ?? '0',
    );

    return [
      _group(
        context,
        l10n.posTotalsArticlesLabel,
        // The figure is passed twice on purpose: as text, so a fractional
        // quantity prints exactly as `Decimal` rendered it, and as a number,
        // so the noun beside it can agree.
        l10n.posTotalsCounts(
          sale?.lineCount ?? 0,
          unitCount.toString(),
          unitCount.toDouble(),
        ),
      ),
      // What the sale *is* on one side, what it *costs* on the other.
      _divider(context),
      _group(context, l10n.posTotalsSubtotalLabel, fmt.display.currency(subtotal)),
      if (!isZeroAmount(discount))
        // The mock's leading minus is display-only — [discount] itself is
        // still the plain magnitude FR-047 derives from Sale.
        _group(context, l10n.posTotalsDiscountLabel, '−${fmt.display.currency(discount)}'),
      _group(context, l10n.posTotalsTaxLabel, fmt.display.currency(taxTotal)),
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
