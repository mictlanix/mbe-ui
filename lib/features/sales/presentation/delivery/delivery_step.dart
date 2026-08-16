import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/domain/entities/fulfillment_mode.dart';
import 'package:mbe_ui/features/sales/domain/entities/line_distribution.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';
import 'package:mbe_ui/features/sales/presentation/delivery/delivery_controller.dart';
import 'package:mbe_ui/features/sales/presentation/delivery/destination_card.dart';
import 'package:mbe_ui/features/sales/presentation/delivery/destination_counter_row.dart';
import 'package:mbe_ui/features/sales/presentation/delivery/destination_editor.dart';
import 'package:mbe_ui/features/sales/presentation/delivery/line_distribution_panel.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The Entrega step (contracts/pos-screen.md §3, spec 026
/// contracts/delivery-surface.md): at the Large tier (≥ 1200 px) two regions
/// — the destinations (counter row, cards, add action) on the left and a
/// fixed-width distribution rail on the right; below that tier, the same
/// content as one column with the rail's foot pinned as a footer band,
/// mirroring the capture and payment steps' own treatment.
///
/// Closing is mode-specific:
///
/// - **delivery** — every unit must be assigned; an unassigned remainder
///   blocks the close and is named (FR-035);
/// - **mixed** — the remainder is legitimate and is swept into a
///   `COUNTER_PICKUP` destination on close, with `lines` omitted so the
///   server computes it against the same figure it validates everything else
///   against (FR-036).
class DeliveryStep extends ConsumerStatefulWidget {
  const DeliveryStep({
    super.key,
    required this.sale,
    required this.mode,
    required this.onClose,
  });

  final Sale sale;
  final FulfillmentMode mode;
  final VoidCallback onClose;

  @override
  ConsumerState<DeliveryStep> createState() => _DeliveryStepState();
}

class _DeliveryStepState extends ConsumerState<DeliveryStep> {
  bool _closing = false;
  AppError? _error;

  /// The destination the sheet most recently created, if any — opened
  /// expanded, since it holds nothing yet and the next thing the cashier
  /// does is fill it (FR-029, spec Assumptions). Diffed against the
  /// provider's own ids before/after the sheet closes rather than threaded
  /// through `onDone`, since that callback also fires on Cancel.
  int? _justCreatedId;

  bool get _isMixed => widget.mode == FulfillmentMode.mixed;

  Future<void> _close(List<LineDistribution> distribution) async {
    setState(() {
      _closing = true;
      _error = null;
    });
    try {
      // FR-036: only mixed sweeps, and only when something is actually left.
      final hasRemainder = distribution.any((d) => !d.isFullyDistributed);
      if (_isMixed && hasRemainder) {
        await ref
            .read(deliveryControllerProvider(widget.sale).notifier)
            .sweepRemainderToCounter();
      }
      if (mounted) widget.onClose();
    } on AppError catch (e) {
      setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _closing = false);
    }
  }

  Future<void> _remove(int destinationId, String reason) async {
    setState(() => _error = null);
    try {
      await ref
          .read(deliveryControllerProvider(widget.sale).notifier)
          .removeDestination(destinationId, reason: reason);
    } on AppError catch (e) {
      setState(() => _error = e);
    }
  }

  /// FR-026: a right-anchored side sheet over the rail at the two-region
  /// tier, a full-width bottom sheet below it — mirroring
  /// `showCatalogFilterSheet`'s mechanics (research R10), including
  /// `useRootNavigator: true`: the POS lives inside a `StatefulShellBranch`
  /// with its own nested Navigator, which would tear the sheet down the
  /// moment this step's own state changed underneath it.
  Future<void> _openAddDestinationSheet() async {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final wide = MediaQuery.sizeOf(context).width >= LayoutBreakpoints.large;
    final editor = DestinationEditor(
      sale: widget.sale,
      onDone: () => Navigator.of(context, rootNavigator: true).pop(),
    );
    final priorIds = (ref.read(deliveryControllerProvider(widget.sale)).valueOrNull ??
            const <Destination>[])
        .map((d) => d.id)
        .toSet();

    if (!wide) {
      await showModalBottomSheet<void>(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (ctx) => editor,
      );
      _markJustCreated(priorIds);
      return;
    }

    await showGeneralDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: true,
      barrierLabel: l10n.posAddDestinationSheetTitle,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (ctx, _, _) => Align(
        alignment: Alignment.centerRight,
        child: Material(
          color: Theme.of(ctx).colorScheme.surface,
          elevation: 1,
          child: SafeArea(
            child: SizedBox(
              width: 400,
              height: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      spacing.md,
                      spacing.sm,
                      spacing.xs,
                      spacing.none,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.posAddDestinationSheetTitle,
                            style: Theme.of(ctx).typeRoles.sectionHeading,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          tooltip: MaterialLocalizations.of(ctx).closeButtonLabel,
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: SingleChildScrollView(child: editor)),
                ],
              ),
            ),
          ),
        ),
      ),
      transitionBuilder: (ctx, anim, _, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
        child: child,
      ),
    );
    _markJustCreated(priorIds);
  }

  void _markJustCreated(Set<int> priorIds) {
    if (!mounted) return;
    final current = ref.read(deliveryControllerProvider(widget.sale)).valueOrNull ??
        const <Destination>[];
    final created = current.where((d) => !priorIds.contains(d.id));
    if (created.isNotEmpty) setState(() => _justCreatedId = created.first.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final destinations = ref.watch(deliveryControllerProvider(widget.sale));

    return destinations.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ErrorBanner(
            error: toAppError(error),
            onDismiss: () =>
                ref.invalidate(deliveryControllerProvider(widget.sale)),
          ),
        ),
      ),
      data: (list) {
        final distribution = ref
            .read(deliveryControllerProvider(widget.sale).notifier)
            .distribution();
        final complete = isDistributionComplete(distribution, isMixed: _isMixed);
        final outstanding = distribution
            .where((d) => !d.isFullyDistributed)
            .toList();

        // Positional badges over the addressed destinations only (research
        // R8) — the same map keys both a card's header and the rail's chips,
        // so the two can never disagree.
        final addressed = [for (final d in list) if (!d.isCounterPickup) d];
        final badges = <int, String>{
          for (var i = 0; i < addressed.length; i++)
            addressed[i].id: l10n.posDestinationBadge(i + 1),
        };
        Destination? counterDestination;
        for (final d in list) {
          if (d.isCounterPickup) {
            counterDestination = d;
            break;
          }
        }
        final destinationGroupCount = addressed.length + (_isMixed ? 1 : 0);

        // FR-036/data-model §2.2's assigned-units figure: total ordered
        // minus whatever is still unclaimed by any destination — this
        // already counts a recorded counter-pickup destination's own share
        // as assigned, exactly as the mock's "409 / 409" reads once the
        // store's 18 units are their own destination row.
        final totalUnits = distribution.fold(
          '0',
          (sum, d) => addAmounts(sum, d.ordered),
        );
        final unclaimed = distribution.fold(
          '0',
          (sum, d) => addAmounts(sum, d.atCounter),
        );
        final assignedUnits = subtractAmounts(totalUnits, unclaimed);

        // R14: an empty create is refused on a sale with nothing left
        // unassigned — exactly the condition that opens the finish gate for
        // a pure-delivery sale, and always true once a mixed sale is fully
        // assigned too.
        final nothingLeftToAssign = distribution.every((d) => isZeroAmount(d.atCounter));

        final outstandingMessage = (!complete && !_isMixed && outstanding.isNotEmpty)
            ? l10n.posDeliveryOutstanding(
                outstanding
                    .map(
                      (d) =>
                          '${d.productName} (${formatQuantity(d.atCounter)})',
                    )
                    .join(', '),
              )
            : null;

        final spacing = Theme.of(context).spacing;
        final error = _error == null
            ? null
            : Padding(
                padding: EdgeInsets.only(bottom: spacing.sm),
                child: ErrorBanner(
                  error: _error!,
                  onDismiss: () => setState(() => _error = null),
                ),
              );

        final destinationItems = _destinationItems(
          context,
          l10n,
          addressed: addressed,
          badges: badges,
          counterDestination: counterDestination,
          distribution: distribution,
          nothingLeftToAssign: nothingLeftToAssign,
        );

        final wide = MediaQuery.sizeOf(context).width >= LayoutBreakpoints.large;

        if (wide) {
          return Padding(
            padding: EdgeInsets.all(spacing.screenMargin),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Not scrollable as a whole: FR-007 reserves scrolling for
                // the destination list and the distribution list, each on
                // its own — the destinations region below is itself a
                // `ListView`, but this outer column is not.
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ?error,
                      Expanded(child: ListView(children: destinationItems)),
                    ],
                  ),
                ),
                SizedBox(width: spacing.paneGutter),
                SizedBox(
                  width: 360,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: LineDistributionPanel(
                          distribution: distribution,
                          badges: badges,
                          destinationGroupCount: destinationGroupCount,
                          isMixed: _isMixed,
                          counterDestination: counterDestination,
                          fillHeight: true,
                        ),
                      ),
                      LineDistributionFoot(
                        assigned: assignedUnits,
                        total: totalUnits,
                        outstandingMessage: outstandingMessage,
                        onClose: (complete && !_closing)
                            ? () => _close(distribution)
                            : null,
                        closing: _closing,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        // Below the Large tier: one column, the mock's phone order — counter
        // row, cards, add action, then the distribution — with the foot
        // pinned as a footer band rather than scrolling with the rest
        // (matching `SaleTotalsBar`'s and the payment step's own treatment).
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(spacing.screenMargin),
                children: [
                  ?error,
                  ...destinationItems,
                  SizedBox(height: spacing.sectionGap),
                  LineDistributionPanel(
                    distribution: distribution,
                    badges: badges,
                    destinationGroupCount: destinationGroupCount,
                    isMixed: _isMixed,
                    counterDestination: counterDestination,
                  ),
                ],
              ),
            ),
            LineDistributionFoot(
              assigned: assignedUnits,
              total: totalUnits,
              outstandingMessage: outstandingMessage,
              onClose: (complete && !_closing) ? () => _close(distribution) : null,
              closing: _closing,
            ),
          ],
        );
      },
    );
  }

  /// FR-009: counter row first, then one card per addressed destination in
  /// recorded order, then the add action, with the empty state shown only
  /// when there is nothing addressed to list. Adding a destination is a
  /// modal sheet now (US4) rather than an inline replacement of this list,
  /// so nothing here branches on whether one is open — the sheet's own
  /// barrier already makes everything behind it unreachable.
  List<Widget> _destinationItems(
    BuildContext context,
    AppLocalizations l10n, {
    required List<Destination> addressed,
    required Map<int, String> badges,
    required Destination? counterDestination,
    required List<LineDistribution> distribution,
    required bool nothingLeftToAssign,
  }) {
    final spacing = Theme.of(context).spacing;

    return [
      if (_isMixed) ...[
        DestinationCounterRow(
          counterDestination: counterDestination,
          distribution: distribution,
        ),
        SizedBox(height: spacing.xs),
      ],
      if (addressed.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Center(child: Text(l10n.posNoDestinationsYet)),
        ),
      for (final destination in addressed)
        DestinationCard(
          // Without an explicit key, removing a destination earlier in the
          // list would shift every later one into the wrong Element by
          // position, letting Flutter reuse a card's State — its stepper
          // controllers and expansion flag — for a *different* destination.
          key: ValueKey(destination.id),
          destination: destination,
          badge: badges[destination.id]!,
          distribution: distribution,
          enabled: !_closing,
          initiallyExpanded: destination.id == _justCreatedId,
          onRemove: () => _remove(destination.id, l10n.posRemoveDestinationReason),
          onAssign: ({required saleLineId, required quantity}) => ref
              .read(deliveryControllerProvider(widget.sale).notifier)
              .assignLine(
                destinationId: destination.id,
                saleLineId: saleLineId,
                quantity: quantity,
              ),
          onAdjust: ({required lineId, required quantity}) => ref
              .read(deliveryControllerProvider(widget.sale).notifier)
              .adjustLine(destinationId: destination.id, lineId: lineId, quantity: quantity),
          onDrop: ({required lineId}) => ref
              .read(deliveryControllerProvider(widget.sale).notifier)
              .dropLine(destinationId: destination.id, lineId: lineId),
        ),
      SizedBox(height: spacing.sm),
      Align(
        alignment: Alignment.centerLeft,
        child: OutlinedButton.icon(
          key: const Key('delivery_add_destination_button'),
          onPressed: (_closing || nothingLeftToAssign) ? null : _openAddDestinationSheet,
          icon: const Icon(Icons.add_location_alt_outlined),
          label: Text(
            nothingLeftToAssign ? l10n.posAddDestinationNothingLeft : l10n.posAddDestination,
          ),
        ),
      ),
    ];
  }
}
