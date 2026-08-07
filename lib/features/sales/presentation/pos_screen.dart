import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/features/sales/domain/entities/current_session.dart';
import 'package:mbe_ui/features/sales/domain/entities/fulfillment_mode.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/presentation/capture/capture_step.dart';
import 'package:mbe_ui/features/sales/presentation/delivery/delivery_step.dart';
import 'package:mbe_ui/features/sales/presentation/payment/payment_step.dart';
import 'package:mbe_ui/features/sales/presentation/current_session_controller.dart';
import 'package:mbe_ui/features/sales/presentation/pos_gate_screen.dart';
import 'package:mbe_ui/features/sales/presentation/pos_resume_controller.dart';
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

class _PosBody extends ConsumerStatefulWidget {
  const _PosBody();

  @override
  ConsumerState<_PosBody> createState() => _PosBodyState();
}

class _PosBodyState extends ConsumerState<_PosBody> {
  /// The sale the step machine was last aligned to. A resumed sale reopens at
  /// the step its own status and `shipTo` imply (FR-057), but only once —
  /// re-deriving on every build would fight the cashier's own navigation.
  int? _syncedSaleId;

  void _syncStepTo(Sale sale) {
    final facilityAddressId = ref
        .watch(facilityAddressControllerProvider(sale.facility))
        .valueOrNull;
    // Wait for the facility address before aligning: without it every sale
    // looks like counter pickup, and a delivery sale would land on the wrong
    // step and then not be moved again.
    if (facilityAddressId == null) return;
    if (_syncedSaleId == sale.id) return;

    _syncedSaleId = sale.id;
    final target = resumeTargetFor(sale, facilityAddressId: facilityAddressId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(posStepControllerProvider.notifier)
          .jumpTo(target.step, mode: target.mode);
    });
  }

  @override
  Widget build(BuildContext context) {
    final sale = ref.watch(posSaleControllerProvider);
    final step = ref.watch(posStepControllerProvider);
    final current = sale.valueOrNull;
    if (current != null) _syncStepTo(current);
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
      PosStep.entrega => DeliveryStep(
        sale: sale,
        mode: ref.watch(posStepControllerProvider).mode,
        onClose: () => _finish(context, ref),
      ),
    };
  }

  /// The sale is done — show its folio and offer the next one (FR-050).
  void _finish(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
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

  /// Cobro → Entrega for a delivery/mixed sale; for counter pickup the sale
  /// is done, so the change due is shown and a new sale is offered (FR-050).
  void _closePayment(BuildContext context, WidgetRef ref) {
    final stepNotifier = ref.read(posStepControllerProvider.notifier);
    if (ref.read(posStepControllerProvider).mode != FulfillmentMode.counterPickup) {
      stepNotifier.advanceFromCobro();
      return;
    }
    _finish(context, ref);
  }
}
