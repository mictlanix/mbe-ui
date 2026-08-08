import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/features/sales/domain/entities/current_session.dart';
import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/fulfillment_mode.dart';
import 'package:mbe_ui/features/sales/domain/entities/open_sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/presentation/capture/capture_step.dart';
import 'package:mbe_ui/features/sales/presentation/delivery/delivery_step.dart';
import 'package:mbe_ui/features/sales/presentation/payment/payment_step.dart';
import 'package:mbe_ui/features/sales/presentation/current_session_controller.dart';
import 'package:mbe_ui/features/sales/presentation/pos_gate_screen.dart';
import 'package:mbe_ui/features/sales/presentation/pos_header_band.dart';
import 'package:mbe_ui/features/sales/presentation/open_sales_selector_controller.dart';
import 'package:mbe_ui/features/sales/presentation/pos_resume_controller.dart';
import 'package:mbe_ui/features/sales/presentation/pos_sale_controller.dart';
import 'package:mbe_ui/features/sales/presentation/register_controller.dart';
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
    final facilityAddress = ref.watch(
      facilityAddressControllerProvider(sale.facility),
    );
    // Wait only while it is still *in flight*: without the facility address
    // every sale looks like counter pickup, and a delivery sale would land on
    // the wrong step and never be moved again.
    //
    // A lookup that has *failed* is a different case and must not wait
    // forever — `valueOrNull` is null for both, and treating them alike left
    // resume silently broken for every sale, including drafts and unpaid ones
    // where the facility address does not affect the answer. On failure the
    // sale is resolved without it, which is what `resumeTargetFor`'s nullable
    // parameter is for: it degrades to counter pickup rather than guessing
    // delivery.
    if (!facilityAddress.hasValue && !facilityAddress.hasError) return;
    if (_syncedSaleId == sale.id) return;

    _syncedSaleId = sale.id;
    final target = resumeTargetFor(
      sale,
      facilityAddressId: facilityAddress.valueOrNull,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(posStepControllerProvider.notifier)
          .jumpTo(target.step, mode: target.mode);
    });
  }

  /// US3 scenario 6 / Edge Cases: a sale left with nothing on it is
  /// cancelled rather than abandoned, so the register's selector does not
  /// accumulate empty drafts. A sale that has lines is left open — that is
  /// exactly what the selector is for.
  Future<void> _discardIfEmpty(Sale? leaving) async {
    if (leaving == null || leaving.lines.isNotEmpty) return;
    if (leaving.status != SaleStatus.draft) return;
    try {
      await ref.read(salesOrderRepositoryProvider).cancel(saleId: leaving.id);
    } on Object {
      // Best effort: failing to tidy up must never block the cashier from
      // moving to the sale they asked for.
    }
  }

  Future<void> _selectSale(OpenSale selected) async {
    final leaving = ref.read(posSaleControllerProvider).valueOrNull;
    if (leaving?.id == selected.id) return;
    await _discardIfEmpty(leaving);
    await ref.read(posSaleControllerProvider.notifier).load(selected.id);
    _refreshSelector();
  }

  Future<void> _startNewSale() async {
    final leaving = ref.read(posSaleControllerProvider).valueOrNull;
    await _discardIfEmpty(leaving);
    await ref.read(posSaleControllerProvider.notifier).startNew();
    _refreshSelector();
  }

  void _refreshSelector() {
    final pointSale =
        ref.read(posSaleControllerProvider).valueOrNull?.pointSale ??
        ref.read(registerPointSaleProvider);
    if (pointSale != null) {
      ref.invalidate(openSalesSelectorControllerProvider(pointSale));
    }
  }

  @override
  Widget build(BuildContext context) {
    final sale = ref.watch(posSaleControllerProvider);
    final current = sale.valueOrNull;
    if (current != null) _syncStepTo(current);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PosHeaderBand(
          sale: current,
          onSaleSelected: _selectSale,
          onStartNew: _startNewSale,
        ),
        Expanded(
          child: sale.when(
            data: (value) => _StepHost(
              step: ref.watch(posStepControllerProvider).current,
              sale: value,
            ),
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

class _StepHost extends ConsumerWidget {
  const _StepHost({required this.step, required this.sale});

  final PosStep step;

  /// `null` on an untouched register — only Venta can render that, and it is
  /// the only step reachable there.
  final Sale? sale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = sale;
    if (current == null) return CaptureStep(sale: null);
    return switch (step) {
      PosStep.venta => CaptureStep(sale: current),
      PosStep.cobro => PaymentStep(
        sale: current,
        onClose: () => _closePayment(context, ref),
      ),
      PosStep.entrega => DeliveryStep(
        sale: current,
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
          l10n.posSaleReference('${sale?.serial ?? sale?.provisionalReference}'),
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
