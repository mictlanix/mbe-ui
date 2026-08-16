import 'package:flutter/material.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/money_formatters.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination_line.dart';
import 'package:mbe_ui/features/sales/domain/entities/line_distribution.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';
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
class DestinationCard extends StatefulWidget {
  const DestinationCard({
    super.key,
    required this.destination,
    required this.badge,
    required this.distribution,
    this.onRemove,
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
  State<DestinationCard> createState() => _DestinationCardState();
}

class _DestinationCardState extends State<DestinationCard> {
  late bool _expanded = widget.initiallyExpanded;

  /// One controller per sale line, created lazily and kept for the card's
  /// whole lifetime — the stepper and the typed field are two paths to the
  /// same value (FR-020), so both read and write the same controller.
  final Map<int, TextEditingController> _quantityControllers = {};

  /// Sale line ids with a request in flight — their row's controls are
  /// inert until it settles (FR-025).
  final Set<int> _busyLines = {};

  /// Sale line id → the server's own refusal message (FR-024).
  final Map<int, String> _lineErrors = {};

  bool get _interactive =>
      widget.onAssign != null && widget.onAdjust != null && widget.onDrop != null;

  @override
  void dispose() {
    for (final controller in _quantityControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(int saleLineId, String value) {
    final existing = _quantityControllers[saleLineId];
    if (existing != null) return existing;
    return _quantityControllers[saleLineId] = TextEditingController(
      text: formatQuantity(value),
    );
  }

  /// FR-021's clamp: the destination could hold everything [line] still
  /// owes plus whatever it already holds (research R7) — the same figure
  /// `update_line`/`add_line` validate server-side.
  String _ceilingFor(LineDistribution line) =>
      addAmounts(line.claimable, line.perDestination[widget.destination.id] ?? '0');

  /// Dispatches on whether this destination already carries [line]
  /// (research R13): `onAssign` the first time, `onAdjust` after,
  /// `onDrop` at zero — never a second `onAssign`, which the server would
  /// refuse with a 409.
  Future<void> _setQuantity(LineDistribution line, String requested) async {
    final current = line.perDestination[widget.destination.id] ?? '0';
    if (compareAmounts(requested, current) == 0) return;

    final ceiling = _ceilingFor(line);
    if (compareAmounts(requested, '0') < 0 || compareAmounts(requested, ceiling) > 0) {
      // Refused client-side, before a request that would only be refused
      // server-side anyway (FR-021, SC-006).
      _controllerFor(line.saleLineId, current).text = formatQuantity(current);
      return;
    }

    DestinationLine? existingLine;
    for (final destinationLine in widget.destination.lines) {
      if (destinationLine.salesOrderDetail == line.saleLineId) {
        existingLine = destinationLine;
        break;
      }
    }

    setState(() {
      _busyLines.add(line.saleLineId);
      _lineErrors.remove(line.saleLineId);
    });
    try {
      if (isZeroAmount(requested)) {
        if (existingLine != null) await widget.onDrop!(lineId: existingLine.id);
      } else if (existingLine != null) {
        await widget.onAdjust!(lineId: existingLine.id, quantity: requested);
      } else {
        await widget.onAssign!(saleLineId: line.saleLineId, quantity: requested);
      }
    } on AppError catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _lineErrors[line.saleLineId] =
            l10n.posDeliveryAssignmentRefused(e.serverMessage ?? l10n.errorServerGeneric);
      });
      _controllerFor(line.saleLineId, current).text = formatQuantity(current);
    } finally {
      if (mounted) setState(() => _busyLines.remove(line.saleLineId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final destination = widget.destination;

    return Card(
      key: Key('destination_card_${destination.id}'),
      margin: EdgeInsets.symmetric(vertical: spacing.xxs),
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
                  Expanded(child: _identity(context, l10n)),
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
            child: _expanded ? _body(context, l10n) : const SizedBox.shrink(),
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

  Widget _identity(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final destination = widget.destination;
    final subtitle = [
      if (destination.contactName != null) destination.contactName!,
      if (destination.contactPhone != null) destination.contactPhone!,
      if (destination.date != null) MoneyFormatters.date(destination.date!),
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
              formatQuantity(destination.unitCount),
            ),
            style: theme.typeRoles.metricLabel.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _body(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final spacing = theme.spacing;

    return Padding(
      padding: EdgeInsets.fromLTRB(spacing.sm, 0, spacing.sm, spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.posDestinationLinesTitle, style: theme.typeRoles.metricLabel),
          for (final line in widget.distribution)
            _interactive ? _assignableRow(context, l10n, line) : _readOnlyRow(context, line),
        ],
      ),
    );
  }

  /// Before this destination has assignment callbacks wired (or in a test
  /// that doesn't need them) — the quantity this destination takes, and
  /// nothing to interact with.
  Widget _readOnlyRow(BuildContext context, LineDistribution line) {
    final theme = Theme.of(context);
    final quantity = line.perDestination[widget.destination.id] ?? '0';
    return Padding(
      key: Key('destination_line_${widget.destination.id}_${line.saleLineId}'),
      padding: EdgeInsets.symmetric(vertical: theme.spacing.xxs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              line.productName,
              style: theme.typeRoles.tableCell,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(formatQuantity(quantity), style: theme.typeRoles.recordId),
        ],
      ),
    );
  }

  /// Contract §4.3: product name and what the sale still owes, an
  /// "elsewhere" chip when the counter holds some of it, and the stepper
  /// pill (§4.4).
  Widget _assignableRow(BuildContext context, AppLocalizations l10n, LineDistribution line) {
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final current = line.perDestination[widget.destination.id] ?? '0';
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
                          l10n.posDistributionOrdered(formatQuantity(line.ordered)),
                          style: theme.typeRoles.metricLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (!isZeroAmount(line.atCounter))
                          _chip(
                            context,
                            l10n.posDestinationCounterChip(formatQuantity(line.atCounter)),
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
                onPressed: widget.enabled && !_busyLines.contains(line.saleLineId)
                    ? () => _setQuantity(line, _ceilingFor(line))
                    : null,
              ),
              _stepper(context, l10n, line, current),
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

  Widget _stepper(
    BuildContext context,
    AppLocalizations l10n,
    LineDistribution line,
    String current,
  ) {
    final theme = Theme.of(context);
    final controller = _controllerFor(line.saleLineId, current);
    final busy = _busyLines.contains(line.saleLineId);
    final enabled = widget.enabled && !busy;
    final ceiling = _ceilingFor(line);

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: theme.shapes.xlRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 18),
            tooltip: l10n.posLineDecreaseQuantity,
            visualDensity: VisualDensity.compact,
            onPressed: enabled && compareAmounts(current, '0') > 0
                ? () => _setQuantity(line, subtractAmounts(current, '1'))
                : null,
          ),
          SizedBox(
            width: 56,
            child: TextField(
              key: Key('destination_quantity_${line.saleLineId}'),
              controller: controller,
              enabled: enabled,
              textAlign: TextAlign.center,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onSubmitted: (value) => _setQuantity(line, value),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            tooltip: l10n.posLineIncreaseQuantity,
            visualDensity: VisualDensity.compact,
            onPressed: enabled && compareAmounts(current, ceiling) < 0
                ? () => _setQuantity(line, addAmounts(current, '1'))
                : null,
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
