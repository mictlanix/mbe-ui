import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/features/sales/domain/entities/fulfillment_mode.dart';
import 'package:mbe_ui/features/sales/domain/entities/line_distribution.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';
import 'package:mbe_ui/features/sales/presentation/delivery/delivery_controller.dart';
import 'package:mbe_ui/features/sales/presentation/delivery/destination_card.dart';
import 'package:mbe_ui/features/sales/presentation/delivery/destination_editor.dart';
import 'package:mbe_ui/features/sales/presentation/delivery/line_distribution_panel.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The Entrega step (contracts/pos-screen.md §3): the destinations recorded
/// so far, an editor for the next one, and the running distribution.
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
  bool _editing = false;
  bool _closing = false;
  AppError? _error;

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

        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            if (_error != null) ...[
              ErrorBanner(
                error: _error!,
                onDismiss: () => setState(() => _error = null),
              ),
              const SizedBox(height: 12),
            ],
            if (list.isEmpty && !_editing)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text(l10n.posNoDestinationsYet)),
              ),
            for (final destination in list)
              DestinationCard(
                destination: destination,
                enabled: !_closing,
                onRemove: destination.isCounterPickup
                    ? null
                    : () => _remove(destination.id, l10n.posRemoveDestinationReason),
              ),
            const SizedBox(height: 12),
            if (_editing)
              DestinationEditor(
                sale: widget.sale,
                onDone: () => setState(() => _editing = false),
              )
            else ...[
              LineDistributionPanel(distribution: distribution),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  key: const Key('delivery_add_destination_button'),
                  onPressed: _closing ? null : () => setState(() => _editing = true),
                  icon: const Icon(Icons.add_location_alt_outlined),
                  label: Text(l10n.posAddDestination),
                ),
              ),
            ],
            const SizedBox(height: 16),
            // FR-035: a pure-delivery sale names what is still unassigned
            // rather than only greying the button out.
            if (!complete && !_isMixed && outstanding.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  key: const Key('delivery_outstanding_notice'),
                  l10n.posDeliveryOutstanding(
                    outstanding
                        .map(
                          (d) =>
                              '${d.productName} (${formatQuantity(d.atCounter)})',
                        )
                        .join(', '),
                  ),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            FilledButton(
              key: const Key('delivery_close_button'),
              onPressed: (complete && !_editing && !_closing)
                  ? () => _close(distribution)
                  : null,
              child: _closing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.posFinishSale),
            ),
          ],
        );
      },
    );
  }
}
