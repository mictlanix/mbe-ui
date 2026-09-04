import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/features/sales/domain/entities/current_session.dart';
import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/fulfillment_mode.dart';
import 'package:mbe_ui/features/sales/domain/entities/open_sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/presentation/capture/capture_step.dart';
import 'package:mbe_ui/features/sales/presentation/delivery/delivery_step.dart';
import 'package:mbe_ui/features/sales/presentation/payment/order_payments_controller.dart';
import 'package:mbe_ui/features/sales/presentation/payment/payment_step.dart';
import 'package:mbe_ui/features/sales/presentation/current_session_controller.dart';
import 'package:mbe_ui/features/sales/presentation/pos_gate_screen.dart';
import 'package:mbe_ui/features/sales/presentation/open_sales_selector.dart';
import 'package:mbe_ui/features/sales/presentation/open_sales_selector_controller.dart';
import 'package:mbe_ui/features/sales/presentation/pos_resume_controller.dart';
import 'package:mbe_ui/features/sales/presentation/pos_sales_list_controller.dart';
import 'package:mbe_ui/features/sales/presentation/pos_sale_controller.dart';
import 'package:mbe_ui/features/sales/presentation/register_controller.dart';
import 'package:mbe_ui/features/sales/presentation/pos_step_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The full-screen sale workspace (spec 023 contracts/pos-workspace.md),
/// reached at `/sales/pos/new` and `/sales/pos/:saleId` — top-level sibling
/// routes, not a shell branch, so it renders with no navigation rail or
/// drawer. This revises spec 020 decision 2 ("the screen lives inside the
/// ordinary application shell") for the workspace only; `/sales/pos` itself
/// is now the sales list, which does stay in the shell
/// (`PosSalesListScreen`).
///
/// Checks the cash session gate (contracts/pos-screen.md §0) before touching
/// anything else, exactly as the former `PosScreen` did: `state == none`
/// renders [PosGateScreen] and stops there — no sale is opened. Otherwise
/// loads or opens the sale named by [saleId] and renders the step host.
class PosWorkspaceScreen extends ConsumerWidget {
  const PosWorkspaceScreen({super.key, this.saleId});

  /// `null` for `/sales/pos/new` — a fresh sale, opened lazily by the first
  /// action that needs one (spec 020's anti-empty-draft rule). Non-null for
  /// `/sales/pos/:saleId` — an existing sale to load.
  final int? saleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSession = ref.watch(currentSessionControllerProvider);
    return currentSession.when(
      data: (current) {
        if (current.state == SessionState.none) {
          return const Scaffold(body: PosGateScreen());
        }
        return _PosWorkspaceBody(saleId: saleId);
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          // Matches cash_session_detail_screen.dart's own error-state
          // padding, not a one-off value.
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ErrorBanner(
              error: toAppError(error),
              onDismiss: () => ref.invalidate(currentSessionControllerProvider),
            ),
          ),
        ),
      ),
    );
  }
}

class _PosWorkspaceBody extends ConsumerStatefulWidget {
  const _PosWorkspaceBody({required this.saleId});

  final int? saleId;

  @override
  ConsumerState<_PosWorkspaceBody> createState() => _PosWorkspaceBodyState();
}

class _PosWorkspaceBodyState extends ConsumerState<_PosWorkspaceBody> {
  /// The sale the step machine was last aligned to. A resumed sale reopens at
  /// the step its own status and `shipTo` imply (FR-057), but only once —
  /// re-deriving on every build would fight the cashier's own navigation.
  int? _syncedSaleId;

  /// Whether the `/sales/pos/new` → `/sales/pos/<id>` URL rewrite has already
  /// run for this instance (contracts §1.1).
  bool _rewrittenUrl = false;

  @override
  void initState() {
    super.initState();
    // Dispatched exactly once — `initState` runs once per instance, and
    // go_router mounts a fresh instance per navigation rather than reusing
    // this one across sales, so no extra guard is needed here
    // (contracts/pos-workspace.md §1.1).
    final saleId = widget.saleId;
    if (saleId != null) {
      // Scheduled after the first frame, matching `_syncStepTo`'s own
      // deferral below: a mutation issued from `initState` would otherwise
      // run before this widget's `ref` is fully wired into the tree.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(posSaleControllerProvider.notifier).load(saleId);
      });
    }
    // `saleId == null` (`/sales/pos/new`): nothing is dispatched. The
    // capture step already renders a `sale == null` state, and mbe-api is
    // touched only by the first real action (spec 020's anti-empty-draft
    // rule) — see `_maybeRewriteUrl` for what happens once that action opens
    // a sale.
  }

  /// Once a sale exists under a `/new` mount, the URL is rewritten to the
  /// sale's real id — a reload of `/sales/pos/new` would otherwise repeat
  /// spec 020's 39-empty-draft problem once per reload (research R2).
  void _maybeRewriteUrl(Sale sale) {
    if (widget.saleId != null || _rewrittenUrl) return;
    _rewrittenUrl = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      GoRouter.of(context).replace('/sales/pos/${sale.id}');
    });
  }

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

  /// The workspace's own Back affordance (contracts/pos-workspace.md §6):
  /// an empty draft is discarded exactly as leaving it for another sale
  /// already discards it (`_discardIfEmpty`), *then* the route is left —
  /// popped when there is a page to return to, or sent to the list directly
  /// for a route reached by a fresh deep link with nothing on the stack
  /// beneath it.
  Future<void> _leaveWorkspace(BuildContext context, Sale? current) async {
    await _discardIfEmpty(current);
    _refreshSalesList();
    if (!context.mounted) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/sales/pos');
    }
  }

  /// FR-009: whatever this workspace did to the sale — rang it up, finished
  /// it, cancelled an empty draft — must be visible on the list the cashier
  /// lands back on. `PosSalesListScreen` cannot do this on its own for a sale
  /// started here: it awaits the `push` it issued, and `_maybeRewriteUrl`
  /// **replaces** `/sales/pos/new` with the sale's real id, which leaves that
  /// future permanently uncompleted (verified against go_router) — so the
  /// list's own refresh never runs for exactly the sale that needs it most,
  /// the one it has never seen.
  ///
  /// The whole family, not one instance: the list is keyed by
  /// `(pointSale, PosSalesFilter)` and this screen knows nothing about the
  /// filter the cashier left behind.
  void _refreshSalesList() {
    ref.invalidate(posSalesListControllerProvider);
    ref.invalidate(openSalesSelectorControllerProvider);
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
    ref.read(posStepControllerProvider.notifier).reset();
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

  /// Why the sale named by `widget.saleId` cannot be opened — `null` for
  /// every ordinary case, including the whole `/sales/pos/new` path, which
  /// has nothing to be unreachable about (contracts/pos-workspace.md §1.2).
  /// A **finished** sale (paid, fully distributed) is deliberately not one
  /// of these reasons — it opens read-only via the ordinary step host, same
  /// as any other non-editable sale (spec 023 FR-006a/FR-019).
  _UnreachableReason? _unreachableReasonFor(AsyncValue<Sale?> sale, Sale? current) {
    if (widget.saleId == null) return null;
    final error = sale.error;
    if (error != null && toAppError(error) is NotFoundError) {
      return _UnreachableReason.unknown;
    }
    if (current != null) {
      if (current.status == SaleStatus.cancelled) return _UnreachableReason.cancelled;
      final myRegister = ref.read(registerPointSaleProvider);
      if (myRegister != null && current.pointSale != myRegister) {
        return _UnreachableReason.otherRegister;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final sale = ref.watch(posSaleControllerProvider);
    final current = sale.valueOrNull;

    final unreachable = _unreachableReasonFor(sale, current);
    if (unreachable != null) return _UnreachableSalePanel(reason: unreachable);

    if (current != null) {
      _syncStepTo(current);
      _maybeRewriteUrl(current);
    }

    final step = ref.watch(posStepControllerProvider);
    // The selector is keyed by the register, not by the sale in hand — so an
    // untouched POS still offers the open sales to resume. Without this,
    // reloading the page would strand every unfinished sale (US3).
    final pointSale = current?.pointSale ?? ref.watch(registerPointSaleProvider);

    // spec 036 FR-005: whether the step track's Venta pill is a tappable way
    // back to the cart. Loading/error on the payments read denies the
    // transition (conservative default, matching `sale_workability.dart`).
    final canReturnToCapture =
        current != null &&
        step.current != PosStep.venta &&
        ref
            .read(posStepControllerProvider.notifier)
            .canReturnToCapture(
              isEditable: current.isEditable,
              hasNonCancelledPayments: ref
                  .watch(orderPaymentsControllerProvider(current.id))
                  .maybeWhen(
                    data: (payments) => payments.any((p) => !p.cancelled),
                    orElse: () => true,
                  ),
            );
    void onReturnToVenta() =>
        ref.read(posStepControllerProvider.notifier).returnToVenta();

    return Scaffold(
      appBar: AppBar(
        // The mock's own header rule (`border-bottom:1px solid #1E1E26`),
        // and the one thing separating the band from the step beneath it:
        // `AppBarTheme` paints it on `scheme.surface`, which is exactly the
        // canvas every step's content sits on, so with no rule the title,
        // the selector and the step track floated on the same plane as the
        // sale. A hairline rather than an elevation — a shadow only shows
        // once something scrolls under it (`scrolledUnderElevation`), and
        // the border is what the rails, the footer bands and the cards in
        // this workspace already use to state a boundary.
        shape: Border(
          bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        leading: IconButton(
          key: const Key('pos_workspace_back'),
          icon: const Icon(Icons.arrow_back),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => _leaveWorkspace(context, current),
        ),
        // The sale's reference is the **selector's** own label, not a chip
        // beside it: the mock's header has one control there — receipt icon,
        // reference, open-count badge, chevron (frame `2a`) — and rendering
        // both put the same number on screen twice, since
        // `OpenSalesSelector` already shows the id and the folio.
        title: Row(
          children: [
            Text(_stepTitle(context, step.current)),
            if (pointSale != null) ...[
              const SizedBox(width: 12),
              OpenSalesSelector(
                pointSale: pointSale,
                // FR-040: the id always, the folio once assigned. Both are
                // absent until a sale exists.
                currentId: current?.provisionalReference,
                currentSerial: current?.serial,
                onSelected: _selectSale,
                onStartNew: _startNewSale,
              ),
            ],
            const Spacer(),
            _StepIndicator(
              step: step,
              canReturnToVenta: canReturnToCapture,
              onReturnToVenta: onReturnToVenta,
            ),
          ],
        ),
        // Constitution §VI (v1.10.0): a screen's actions live in the body,
        // not the app bar. The identity chip, the selector and the step
        // indicator above are title-area content, not actions — Back is
        // `leading`, which the rule does not restrict (spec 023 research
        // R13, Complexity Tracking).
        actions: const [],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Renders nothing when the session is healthy; the non-blocking
          // stale-session banner otherwise (`state == none` never reaches
          // here — the top-level gate in `PosWorkspaceScreen` already
          // stopped there).
          const PosGateScreen(),
          Expanded(
            child: sale.when(
              data: (value) => _StepHost(step: step.current, sale: value),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: ErrorBanner(
                    error: toAppError(error),
                    onDismiss: () => ref.invalidate(posSaleControllerProvider),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _stepTitle(BuildContext context, PosStep step) {
    final l10n = AppLocalizations.of(context)!;
    return switch (step) {
      PosStep.venta => l10n.posStepVenta,
      PosStep.cobro => l10n.posStepCobro,
      PosStep.entrega => l10n.posStepEntrega,
    };
  }
}

/// Two steps or three, driven by the fulfilment mode (FR-005) — the current
/// one emphasised rather than the others hidden, so the cashier can see what
/// is still ahead.
///
/// One stadium container holding a pill per step, the current one filled and
/// carrying its own icon, the rest quiet text — the mock's frame `2a` track
/// (`height:40; border-radius:20` around `height:28; border-radius:14` pills).
/// There are **no chevrons**: the numbering already states the order, and the
/// track already groups them, so an arrow between each pair was chrome that
/// only cost width.
///
/// On a phone there is no room for the track at all: three pills would push
/// the selector off the band, so it collapses to "Paso N de M" (US5, SC-007).
/// The position is what matters; the names are on the step itself.
class _StepIndicator extends StatelessWidget {
  const _StepIndicator({
    required this.step,
    required this.canReturnToVenta,
    required this.onReturnToVenta,
  });

  final PosStepState step;

  /// spec 036 FR-005: whether tapping back to Venta is currently allowed.
  final bool canReturnToVenta;
  final VoidCallback onReturnToVenta;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (LayoutBreakpoints.isCompact(context)) {
      // spec 036 FR-005/research R2: pills collapse to plain text here, so
      // the text itself is the compact-tier back-to-Venta affordance.
      final progress = Text(
        key: const Key('pos_step_progress'),
        l10n.posStepProgress(step.current.index + 1, step.stepCount),
        style: theme.textTheme.titleSmall,
      );
      if (!canReturnToVenta) return progress;
      return InkWell(
        key: const Key('pos_step_progress_return_to_venta'),
        onTap: onReturnToVenta,
        child: progress,
      );
    }

    // `PosStep`'s own order — Venta → Cobro → Entrega — which spec 020 settled
    // and spec 023 put out of scope. The mock numbers them Venta → Entrega →
    // Cobro; that is the mock disagreeing with the product, not a layout
    // detail, so only the styling is taken from it.
    const steps = PosStep.values;
    final labels = {
      PosStep.venta: l10n.posStepVenta,
      PosStep.cobro: l10n.posStepCobro,
      PosStep.entrega: l10n.posStepEntrega,
    };
    final icons = {
      PosStep.venta: Icons.edit_note,
      PosStep.cobro: Icons.payments_outlined,
      PosStep.entrega: Icons.local_shipping_outlined,
    };

    return Container(
      key: const Key('pos_step_indicator'),
      height: 40,
      padding: EdgeInsets.symmetric(horizontal: theme.spacing.xxs),
      decoration: ShapeDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        shape: StadiumBorder(
          side: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < step.stepCount; i++)
            _StepPill(
              position: i + 1,
              label: labels[steps[i]]!,
              icon: icons[steps[i]]!,
              current: i == step.current.index,
              // spec 036 FR-005: only the Venta pill is ever a way back, and
              // only while it's actually allowed.
              onTap: steps[i] == PosStep.venta && canReturnToVenta
                  ? onReturnToVenta
                  : null,
            ),
        ],
      ),
    );
  }
}

/// One step in the track. The current one is a filled chip carrying its icon;
/// the rest are quiet, iconless text at the same height, so the track's
/// rhythm does not change as the sale advances.
class _StepPill extends StatelessWidget {
  const _StepPill({
    required this.position,
    required this.label,
    required this.icon,
    required this.current,
    this.onTap,
  });

  final int position;
  final String label;
  final IconData icon;
  final bool current;

  /// spec 036 FR-005: non-null only for the Venta pill when returning to it
  /// is currently allowed — every other pill stays inert, exactly as before.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = Container(
      height: 28,
      margin: EdgeInsets.symmetric(horizontal: theme.spacing.xxs / 2),
      padding: EdgeInsets.symmetric(horizontal: theme.spacing.xs),
      decoration: ShapeDecoration(
        color: current ? theme.colorScheme.secondaryContainer : null,
        shape: const StadiumBorder(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: theme.spacing.xxs,
        children: [
          if (current)
            Icon(icon, size: 16, color: theme.colorScheme.onSecondaryContainer),
          Text(
            '$position · $label',
            style: theme.textTheme.labelLarge?.copyWith(
              color: current
                  ? theme.colorScheme.onSecondaryContainer
                  : theme.colorScheme.onSurfaceVariant,
              fontWeight: current ? FontWeight.w500 : null,
            ),
          ),
        ],
      ),
    );
    if (onTap == null) return content;
    return InkWell(
      key: const Key('pos_step_pill_return_to_venta'),
      customBorder: const StadiumBorder(),
      onTap: onTap,
      child: content,
    );
  }
}

enum _UnreachableReason { unknown, cancelled, otherRegister }

/// A sale that cannot be opened at all — unknown, cancelled, or belonging to
/// another register (contracts/pos-workspace.md §1.2). No sale is opened in
/// its place; the only way forward is back to the list.
class _UnreachableSalePanel extends StatelessWidget {
  const _UnreachableSalePanel({required this.reason});

  final _UnreachableReason reason;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final message = switch (reason) {
      _UnreachableReason.unknown => l10n.posSaleUnreachableUnknown,
      _UnreachableReason.cancelled => l10n.posSaleUnreachableCancelled,
      _UnreachableReason.otherRegister => l10n.posSaleUnreachableOtherRegister,
    };
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: const Key('pos_workspace_back'),
          icon: const Icon(Icons.arrow_back),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => context.canPop() ? context.pop() : context.go('/sales/pos'),
        ),
      ),
      body: Center(
        child: Padding(
          key: const Key('pos_sale_unreachable'),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: theme.colorScheme.outline),
              const SizedBox(height: 16),
              Text(
                l10n.posSaleUnreachableTitle,
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(message, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.go('/sales/pos'),
                child: Text(l10n.posSaleBackToListAction),
              ),
            ],
          ),
        ),
      ),
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
    // The sale that just finished is no longer one the register can resume,
    // so the header selector's own listing has to be re-read — the same
    // refresh `_startNewSale` and `_selectSale` already do when *they* move
    // off a sale. Without it the selector keeps offering the finished sale
    // (and counting it) for the whole of the next one.
    ref.invalidate(openSalesSelectorControllerProvider);
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
              ref.read(posStepControllerProvider.notifier).reset();
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
