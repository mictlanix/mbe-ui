import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/config/app_settings_provider.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/app_formatters.dart';
import 'package:mbe_ui/core/widgets/catalog_action_icons.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination_line.dart';
import 'package:mbe_ui/features/sales/domain/entities/line_distribution.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';
import 'package:mbe_ui/features/sales/presentation/delivery/destination_line_row.dart';
import 'package:mbe_ui/features/sales/presentation/widgets/quantity_stepper.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// One already-created destination (FR-029, contract §4): a collapsible card
/// with a positional badge, an identity/counts header, and — expanded —
/// every sale line with the quantity this destination takes of it, assigned
/// on the mock's stepper pill (contract §4.4).
///
/// [badge] and [distribution] are supplied by the caller rather than
/// recomputed here (`delivery_step.dart` builds the badge map and the
/// distribution once per build, data-model.md §2.1) so a card's badge always
/// agrees with the same letter the distribution rail shows for it
/// (research R8).
///
/// [onAssign]/[onAdjust]/[onDrop] are plain async callbacks, not a direct
/// Riverpod read — `delivery_step.dart` wires them to
/// `DeliveryController.assignLine`/`.adjustLine`/`.dropLine`, keeping this
/// widget itself provider-free, exactly as [onRemove] already is. Left
/// unset, every row renders read-only, which is what a test that only
/// exercises the header/expansion still gets for free.
///
/// Own expansion state, independent per card (research R5, FR-014) — a
/// hand-rolled header rather than `ExpansionTile`, since the header packs a
/// badge, a divider and two trailing icons that `ExpansionTile`'s
/// leading/trailing slots don't have room for.
class DestinationCard extends ConsumerStatefulWidget {
  const DestinationCard({
    super.key,
    required this.destination,
    required this.badge,
    required this.distribution,
    this.onRemove,
    this.onEdit,
    this.onAssign,
    this.onAdjust,
    this.onDrop,
    this.enabled = true,
    this.initiallyExpanded = false,
  });

  final Destination destination;

  /// This destination's positional badge (`D1`, `D2`, …) — absent for the
  /// counter row, which does not use this widget.
  final String badge;

  /// Every sale line, so the body lists all of them (FR-018), not only the
  /// ones this destination currently carries.
  final List<LineDistribution> distribution;

  final VoidCallback? onRemove;

  /// Opens the composer, prefilled, to edit this destination's header (spec
  /// 030 FR-017…FR-022) — `null` on the store row, which uses
  /// `DestinationCounterRow` instead and never carries this callback.
  final VoidCallback? onEdit;

  /// Assigns a sale line to this destination for the first time
  /// (`POST .../lines`, mbe-api#163) — called only for a line
  /// [Destination.lines] does not yet carry.
  final Future<void> Function({required int saleLineId, required String quantity})?
  onAssign;

  /// Adjusts a line this destination already carries (`PUT .../lines/{id}`)
  /// — `lineId` is the destination's own line id, not the sale line's.
  final Future<void> Function({required int lineId, required String quantity})?
  onAdjust;

  /// Drops a line to zero (`DELETE .../lines/{id}`, FR-022).
  final Future<void> Function({required int lineId})? onDrop;

  final bool enabled;

  /// A freshly-created destination opens expanded, since it holds nothing yet
  /// and the next thing the cashier does is fill it (spec Assumptions).
  final bool initiallyExpanded;

  @override
  ConsumerState<DestinationCard> createState() => _DestinationCardState();
}

class _DestinationCardState extends ConsumerState<DestinationCard> {
  late bool _expanded = widget.initiallyExpanded;

  /// One [QuantityStepperController] per sale line, created lazily and kept
  /// for the card's whole lifetime (spec 030 research R1/R2) — the debounce,
  /// the pending-value display and the discard-and-reset that used to be
  /// hand-rolled here now live in the shared control every sale line on the
  /// capture step also uses.
  final Map<int, QuantityStepperController> _quantityControllers = {};

  /// Sale line id → the server's own refusal message (FR-024).
  final Map<int, String> _lineErrors = {};

  bool get _interactive =>
      widget.onAssign != null && widget.onAdjust != null && widget.onDrop != null;

  @override
  void dispose() {
    // Each controller flushes its own still-pending commit on the way out
    // (spec 030 research R8) — the hand-rolled "fire whatever is pending"
    // loop this used to be is now the controller's own contract.
    for (final controller in _quantityControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  /// FR-021's clamp: the destination could hold everything [line] still
  /// owes plus whatever it already holds (research R7) — the same figure
  /// `update_line`/`add_line` validate server-side.
  String _ceilingFor(LineDistribution line) =>
      addAmounts(line.claimable, line.perDestination[widget.destination.id] ?? '0');

  /// The controller for [line], created on first use and re-synced from the
  /// latest server value and ceiling on every build (research R7's `sync`
  /// precedence — a burst in progress is left alone; an ordinary update is
  /// adopted).
  QuantityStepperController _controllerFor(LineDistribution line) {
    final accepted = line.perDestination[widget.destination.id] ?? '0';
    final ceiling = _ceilingFor(line);
    final existing = _quantityControllers[line.saleLineId];
    if (existing != null) {
      existing.sync(value: accepted, max: ceiling);
      return existing;
    }
    return _quantityControllers[line.saleLineId] = QuantityStepperController(
      value: accepted,
      max: ceiling,
      onCommit: (value) => _commit(line.saleLineId, value),
      debounce: ref.read(quantityCommitDebounceProvider),
    );
  }

  /// [QuantityStepperController.onCommit] for one sale line: dispatches on
  /// whether this destination already carries the line (research R13):
  /// `onAssign` the first time, `onAdjust` after, `onDrop` at zero — never a
  /// second `onAssign`, which the server refuses with a 409.
  ///
  /// Looks the line up fresh from [widget.distribution] rather than trusting
  /// a captured one — the controller in [_controllerFor] is created once and
  /// kept for the card's whole lifetime, so the `line` a closure captured at
  /// creation time may be stale by the time this actually runs.
  Future<bool> _commit(int saleLineId, String requested) async {
    DestinationLine? existingLine;
    for (final destinationLine in widget.destination.lines) {
      if (destinationLine.salesOrderDetail == saleLineId) {
        existingLine = destinationLine;
        break;
      }
    }

    try {
      if (isZeroAmount(requested)) {
        if (existingLine != null) await widget.onDrop!(lineId: existingLine.id);
      } else if (existingLine != null) {
        await widget.onAdjust!(lineId: existingLine.id, quantity: requested);
      } else {
        await widget.onAssign!(saleLineId: saleLineId, quantity: requested);
      }
      if (mounted) setState(() => _lineErrors.remove(saleLineId));
      return true;
    } on AppError catch (e) {
      if (!mounted) return false;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _lineErrors[saleLineId] =
            l10n.posDeliveryAssignmentRefused(e.serverMessage ?? l10n.errorServerGeneric);
      });
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final destination = widget.destination;
    final fmt = ref.watch(formattersProvider);

    return Card(
      key: Key('destination_card_${destination.id}'),
      margin: EdgeInsets.symmetric(vertical: spacing.xxs),
      // The mock's own `border:1px solid #23232C` on the destination card.
      // `cardTheme`'s shape is kept — only the hairline is added — so the
      // radius stays the one every other card in the product uses.
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _badge(context),
                  SizedBox(width: spacing.sm),
                  // The identity block owns the counts too (on their own
                  // line, set apart by a lighter colour, FR-013) rather than
                  // squeezing them onto the header's one row — a fixed
                  // divider-plus-label footprint there overflowed a phone
                  // width the moment the address was more than a few
                  // characters (SC-007).
                  Expanded(child: _identity(context, l10n, fmt)),
                  // Edit before remove before the chevron — the mock's own
                  // order (spec 030 FR-017), and the fixed Edit icon every
                  // action set in the product uses (constitution §VI).
                  if (widget.enabled && widget.onEdit != null)
                    IconButton(
                      key: Key('destination_edit_${destination.id}'),
                      icon: Icon(CatalogAction.edit.icon),
                      tooltip: l10n.editActionTooltip,
                      onPressed: widget.onEdit,
                    ),
                  if (widget.enabled && widget.onRemove != null)
                    IconButton(
                      key: Key('destination_remove_${destination.id}'),
                      icon: const Icon(Icons.delete_outline),
                      tooltip: l10n.posRemoveDestination,
                      style: IconButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                      ),
                      onPressed: widget.onRemove,
                    ),
                  Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            // A rule under the header once the card is open: expanded, the
            // quantity list ran straight into the address block with nothing
            // stating where the identity ends and the assignment begins.
            child: _expanded
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Divider(
                        height: 1,
                        color: theme.colorScheme.outlineVariant,
                      ),
                      _body(context, l10n, fmt),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _badge(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: theme.shapes.smRadius,
      ),
      child: Text(widget.badge, style: theme.typeRoles.recordId),
    );
  }

  Widget _identity(BuildContext context, AppLocalizations l10n, AppFormatters fmt) {
    final theme = Theme.of(context);
    final destination = widget.destination;
    final subtitle = [
      if (destination.contactName != null) destination.contactName!,
      if (destination.contactPhone != null) destination.contactPhone!,
      if (destination.date != null) fmt.display.date(destination.date),
    ].join(' · ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          destination.addressSummary ?? l10n.posDeliveryAddressPending,
          style: theme.typeRoles.cardTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (subtitle.isNotEmpty)
          Text(
            subtitle,
            style: theme.typeRoles.metricLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        Padding(
          padding: EdgeInsets.only(top: theme.spacing.xxs),
          child: Text(
            l10n.posDestinationCounts(
              destination.lineCount,
              fmt.field.quantity(destination.unitCount),
            ),
            style: theme.typeRoles.metricLabel.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _body(BuildContext context, AppLocalizations l10n, AppFormatters fmt) {
    final theme = Theme.of(context);
    final spacing = theme.spacing;

    return Padding(
      padding: EdgeInsets.fromLTRB(spacing.sm, 0, spacing.sm, spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.posDestinationLinesTitle, style: theme.typeRoles.metricLabel),
          for (final line in widget.distribution)
            _interactive
                ? _assignableRow(context, l10n, fmt, line)
                : _readOnlyRow(context, fmt, line),
        ],
      ),
    );
  }

  /// Before this destination has assignment callbacks wired (or in a test
  /// that doesn't need them) — the quantity this destination takes, and
  /// nothing to interact with. [DestinationLineRow] (spec 030 research R11)
  /// is the same shape `DestinationCounterRow`'s expanded body draws.
  Widget _readOnlyRow(BuildContext context, AppFormatters fmt, LineDistribution line) =>
      DestinationLineRow(
        key: Key('destination_line_${widget.destination.id}_${line.saleLineId}'),
        productName: line.productName,
        quantity: line.perDestination[widget.destination.id] ?? '0',
        fmt: fmt,
      );

  /// Contract §4.3: product name and what the sale still owes, an
  /// "elsewhere" chip when the counter holds some of it, and the stepper
  /// pill (§4.4).
  Widget _assignableRow(
    BuildContext context,
    AppLocalizations l10n,
    AppFormatters fmt,
    LineDistribution line,
  ) {
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final controller = _controllerFor(line);
    final error = _lineErrors[line.saleLineId];

    return Padding(
      key: Key('destination_line_${widget.destination.id}_${line.saleLineId}'),
      padding: EdgeInsets.symmetric(vertical: spacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      line.productName,
                      style: theme.typeRoles.tableCell,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // `Wrap`, not `Row` — at a narrow width the badge, the
                    // assign-all icon and the stepper pill already claim
                    // most of the card's width, so the chip flows onto its
                    // own line rather than overflowing (SC-007).
                    Wrap(
                      spacing: spacing.xs,
                      runSpacing: spacing.xxs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          l10n.posDistributionOrdered(fmt.field.quantity(line.ordered)),
                          style: theme.typeRoles.metricLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (!isZeroAmount(line.atCounter))
                          _chip(
                            context,
                            l10n.posDestinationCounterChip(fmt.field.quantity(line.atCounter)),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: spacing.sm),
              IconButton(
                key: Key('destination_claim_all_${line.saleLineId}'),
                tooltip: l10n.posDistributionClaimAll,
                icon: const Icon(Icons.keyboard_double_arrow_left),
                onPressed: widget.enabled
                    ? () => controller.set(_ceilingFor(line))
                    : null,
              ),
              QuantityStepper(
                controller: controller,
                enabled: widget.enabled,
                fieldKey: Key('destination_quantity_${line.saleLineId}'),
                decrementTooltip: l10n.posLineDecreaseQuantity,
                incrementTooltip: l10n.posLineIncreaseQuantity,
              ),
            ],
          ),
          if (error != null)
            Padding(
              padding: EdgeInsets.only(top: spacing.xxs),
              child: Text(error, style: TextStyle(color: theme.colorScheme.error)),
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
