import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/features/sales/domain/entities/current_session.dart';
import 'package:mbe_ui/features/sales/domain/entities/fulfillment_mode.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/presentation/capture/capture_step.dart';
import 'package:mbe_ui/features/sales/presentation/payment/payment_step.dart';
import 'package:mbe_ui/features/sales/presentation/current_session_controller.dart';
import 'package:mbe_ui/features/sales/presentation/pos_gate_screen.dart';
import 'package:mbe_ui/features/sales/presentation/pos_sale_controller.dart';
import 'package:mbe_ui/features/sales/presentation/pos_step_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The Point of Sale screen (contracts/pos-screen.md §1). Checks the cash
/// session gate (§0) before touching anything else: `state == none` renders
/// [PosGateScreen] and stops there — no sale is opened. Otherwise renders the
/// header band, the step host and a stale-session banner when applicable.
class PosScreen extends ConsumerWidget {
  const PosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSession = ref.watch(currentSessionControllerProvider);
    return currentSession.when(
      data: (current) {
        if (current.state == SessionState.none) return const PosGateScreen();
        return const _PosBody();
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ErrorBanner(
            error: toAppError(error),
            onDismiss: () => ref.invalidate(currentSessionControllerProvider),
          ),
        ),
      ),
    );
  }
}

class _PosBody extends ConsumerWidget {
  const _PosBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sale = ref.watch(posSaleControllerProvider);
    final step = ref.watch(posStepControllerProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HeaderBand(step: step, sale: sale.value),
        // Renders the stale banner or nothing — PosGateScreen owns every
        // rendering decision that follows from `CurrentSession` alone
        // (contracts/pos-screen.md §0); `state == none` never reaches here.
        const PosGateScreen(),
        Expanded(
          child: sale.when(
            data: (value) => _StepHost(step: step.current, sale: value),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ErrorBanner(
                  error: toAppError(error),
                  onDismiss: () => ref.invalidate(posSaleControllerProvider),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderBand extends StatelessWidget {
  const _HeaderBand({required this.step, required this.sale});

  final PosStepState step;
  final Sale? sale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final labels = [
      l10n.posStepVenta,
      l10n.posStepCobro,
      l10n.posStepEntrega,
    ].take(step.stepCount).toList();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // FR-040: once confirmed, every reference display reads the
          // assigned folio (`serial`) instead of the provisional `id`.
          if (sale != null) Text('#${sale!.serial ?? sale!.provisionalReference}'),
          const Spacer(),
          for (var i = 0; i < labels.length; i++) ...[
            Text(
              '${i + 1}·${labels[i]}',
              style: i == step.current.index
                  ? Theme.of(context).textTheme.titleSmall
                  : Theme.of(context).textTheme.bodyMedium,
            ),
            if (i < labels.length - 1) const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.chevron_right, size: 16),
            ),
          ],
        ],
      ),
    );
  }
}

class _StepHost extends ConsumerWidget {
  const _StepHost({required this.step, required this.sale});

  final PosStep step;
  final Sale sale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (step) {
      PosStep.venta => CaptureStep(sale: sale),
      PosStep.cobro => PaymentStep(
        sale: sale,
        onClose: () => _closePayment(context, ref),
      ),
      PosStep.entrega => Center(child: Text(AppLocalizations.of(context)!.posStepEntrega)),
    };
  }

  /// Cobro → Entrega for a delivery/mixed sale; for counter pickup the sale
  /// is done, so the change due is shown and a new sale is offered (FR-050).
  void _closePayment(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final stepNotifier = ref.read(posStepControllerProvider.notifier);
    if (ref.read(posStepControllerProvider).mode != FulfillmentMode.counterPickup) {
      stepNotifier.advanceFromCobro();
      return;
    }
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.posSaleCompletedTitle),
        content: Text(
          l10n.posSaleReference('${sale.serial ?? sale.provisionalReference}'),
        ),
        actions: [
          FilledButton(
            key: const Key('start_new_sale_button'),
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(posSaleControllerProvider.notifier).startNew();
              ref.read(posStepControllerProvider.notifier).jumpTo(PosStep.venta);
            },
            child: Text(l10n.posNewSaleAction),
          ),
        ],
      ),
    );
  }
}
