import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/config/app_settings_provider.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/features/sales/domain/entities/fulfillment_mode.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/presentation/capture/capture_step.dart';
import 'package:mbe_ui/features/sales/presentation/delivery/delivery_step.dart';
import 'package:mbe_ui/features/sales/presentation/orders/foreign_order_guard.dart';
import 'package:mbe_ui/features/sales/presentation/orders/order_editor_controller.dart';
import 'package:mbe_ui/features/sales/presentation/orders/order_header_panel.dart';
import 'package:mbe_ui/features/sales/presentation/orders/order_step_controller.dart';
import 'package:mbe_ui/features/sales/presentation/orders/sales_orders_list_controller.dart';
import 'package:mbe_ui/features/sales/presentation/sale_editor.dart';
import 'package:mbe_ui/features/sales/presentation/sales_order_write_scope.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The back-office order workspace (spec 039 contracts/order-workspace.md):
/// a two-step host — Venta, Entrega — reached at `/sales/orders/new` and
/// `/sales/orders/:orderId`, top-level sibling routes mirroring
/// `PosWorkspaceScreen`'s own shape (full-screen, no shell).
///
/// Naming a customer is Venta's own first move, not a screen of its own
/// (corrected 2026-09-20 — an earlier Cliente step ahead of Venta was
/// removed): `CaptureStep.excludeGenericCustomer` keeps the walk-in customer
/// out of reach, and withholds product capture until a real one is
/// attached (FR-009, FR-011).
///
/// Installs the nested `ProviderScope` the shared capture and delivery
/// surfaces read through (contracts/shared-step-seam.md §5) — all **four**
/// seam providers together, so this workspace's writes, unconfirmed edits and
/// confirm failures are never held open, shut, or painted by the register's
/// own, and vice versa (FR-042, FR-043).
class OrderWorkspaceScreen extends ConsumerWidget {
  const OrderWorkspaceScreen({super.key, this.orderId});

  /// `null` for `/sales/orders/new` — a fresh order, opened lazily by
  /// Venta's own first customer attach (FR-005). Non-null for
  /// `/sales/orders/:orderId` — an existing order to load.
  final int? orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProviderScope(
      overrides: [
        saleEditorProvider.overrideWith(
          (ref) => ref.watch(orderEditorControllerProvider(orderId).notifier),
        ),
        saleWritesScopeProvider.overrideWithValue(salesOrderWritesScope),
        saleConfirmErrorProvider.overrideWith((ref) => null),
        // Mirrors the register's own default exactly, aimed at this
        // workspace's own step controller instead of POS's — a confirm
        // failure (a credit refusal on the first destination create, or a
        // goods refusal) returns the user to Venta either way, since that is
        // the one step that can fix either: the customer bar to choose a
        // different customer, the lines to fix what is priced or stocked
        // wrong. The message itself is what tells the two apart (FR-056) —
        // `ErrorBanner` already renders `CreditHoldError` with its own
        // distinct headline, never implying the lines are at fault.
        saleConfirmFailureProvider.overrideWith((ref) {
          return (error) {
            ref.read(saleConfirmErrorProvider.notifier).state = error;
            ref.read(orderStepControllerProvider.notifier).returnToVenta();
          };
        }),
        // A fresh instance per workspace mount — without this override,
        // `OrderStepController` (a plain, non-family provider) would resolve
        // to one instance shared by every order ever opened in the session,
        // exactly the bug `OrderEditorController`'s own `autoDispose` +
        // family key already avoids for the order's data.
        orderStepControllerProvider.overrideWith(OrderStepController.new),
      ],
      child: _OrderWorkspaceBody(orderId: orderId),
    );
  }
}

class _OrderWorkspaceBody extends ConsumerStatefulWidget {
  const _OrderWorkspaceBody({required this.orderId});

  final int? orderId;

  @override
  ConsumerState<_OrderWorkspaceBody> createState() =>
      _OrderWorkspaceBodyState();
}

class _OrderWorkspaceBodyState extends ConsumerState<_OrderWorkspaceBody> {
  /// Whether the `/sales/orders/new` → `/sales/orders/<id>` URL rewrite has
  /// already run for this instance — mirrors
  /// `pos_workspace_screen.dart`'s own `_rewrittenUrl`.
  bool _rewrittenUrl = false;

  /// Whether a cancel is in flight — the action shows a spinner and
  /// refuses to fire twice, as it did on the replaced `order_screen.dart`.
  bool _cancelling = false;

  /// The order id the step machine was last aligned to (data-model.md §4).
  ///
  /// Needed for more than a genuine reopen: the URL rewrite below mounts a
  /// **brand-new** `OrderWorkspaceScreen`, with its own fresh
  /// `orderStepControllerProvider` override defaulting to Venta — unlike
  /// POS, where the step controller is one true app-wide singleton that
  /// survives a widget remount. Without this, advancing to Entrega from
  /// Venta's own line count would be silently undone the instant the URL
  /// rewrite fires, on every single order. So this runs unconditionally
  /// whenever an order exists, not only for a `widget.orderId != null`
  /// reopen — which also means US3's own resume case (a genuinely reopened
  /// order) needs no separate wiring: both are the same question, answered
  /// the same way (research R2).
  int? _syncedOrderId;

  /// Once a order exists under a `/new` mount, the URL is rewritten to its
  /// real id — mirrors `PosWorkspaceScreen._maybeRewriteUrl`.
  void _maybeRewriteUrl(Sale order) {
    if (widget.orderId != null || _rewrittenUrl) return;
    _rewrittenUrl = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      GoRouter.of(context).replace('/sales/orders/${order.id}');
    });
  }

  void _syncStepTo(Sale order) {
    if (_syncedOrderId == order.id) return;
    _syncedOrderId = order.id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(orderStepControllerProvider.notifier).resumeTo(order);
    });
  }

  /// The current step named plainly — mirrors `PosWorkspaceScreen
  /// ._stepTitle` exactly, so the app bar's title row reads the same way on
  /// both hosts (corrected 2026-09-20: this workspace's own title had
  /// dropped it entirely, leaving the step indicator pill to stand alone).
  String _stepTitle(BuildContext context, OrderStep step) {
    final l10n = AppLocalizations.of(context)!;
    return switch (step) {
      OrderStep.venta => l10n.salesOrderStepVenta,
      OrderStep.entrega => l10n.salesOrderStepEntrega,
    };
  }

  Future<void> _cancel() async {
    setState(() => _cancelling = true);
    try {
      await ref
          .read(orderEditorControllerProvider(widget.orderId).notifier)
          .cancel();
    } on AppError catch (e) {
      // Routed through the seam's own failure path rather than a private
      // error field: a refused cancel is shown where every other refusal in
      // this workspace is shown, on Venta's banner (FR-056).
      if (mounted) ref.read(saleConfirmFailureProvider)(e);
      await ref
          .read(orderEditorControllerProvider(widget.orderId).notifier)
          .refresh();
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  Future<void> _confirmCancel(AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.salesOrderCancelDialogTitle),
        content: Text(l10n.salesOrderCancelDialogMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.salesOrderCancelDialogKeepEditing),
          ),
          FilledButton(
            key: const Key('sales_order_cancel_confirm_button'),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.salesOrderCancelDialogConfirm),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) await _cancel();
  }

  @override
  Widget build(BuildContext context) {
    final orderAsync = ref.watch(orderEditorControllerProvider(widget.orderId));
    final step = ref.watch(orderStepControllerProvider);
    final access = ref.watch(accessControlProvider);
    final canUpdate = access.can(SystemObject.salesOrders, AccessRight.update);
    final l10n = AppLocalizations.of(context)!;
    // Offered on a draft and nowhere else: a committed, paid or already
    // cancelled order has nothing this action could do, so it is absent
    // rather than disabled (FR-034, contracts/order-workspace.md §8).
    final order = orderAsync.valueOrNull;
    final canCancel =
        canUpdate &&
        order != null &&
        order.isEditable &&
        !isForeignOrder(order, settings: ref.watch(appSettingsProvider));

    // 2026-09-20: moved out of the app bar and into whichever footer is
    // current — `SaleTotalsBar`/`LineDistributionFoot`'s own
    // `secondaryAction` slot, immediately before the primary action, for
    // consistency with the register's own footer-anchored actions. Built
    // once here rather than in `_StepHost`, which has no access to
    // `_cancelling`/`_confirmCancel`.
    final cancelButton = canCancel
        ? TextButton(
            key: const Key('sales_order_cancel_button'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: _cancelling ? null : () => _confirmCancel(l10n),
            child: _cancelling
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.salesOrderCancelAction),
          )
        : null;

    return Scaffold(
      appBar: AppBar(
        shape: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        leading: IconButton(
          key: const Key('sales_order_workspace_back'),
          icon: const Icon(Icons.arrow_back),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/sales/orders'),
        ),
        // Mirrors `PosWorkspaceScreen`'s own title row exactly: the current
        // step named plainly on the left, the step indicator pushed to the
        // right (corrected 2026-09-20 — it used to sit where this plain
        // title now does, with nothing on the right at all).
        //
        // `component_themes.dart` already sets `centerTitle: false` for
        // every `AppBar`, so this title `Row` always gets the toolbar's full
        // available width to lay out in (measured: 1112px of it on a 1200px
        // surface) — centring was never the bug. The real bug was here: an
        // earlier version paired `Flexible(child: Text(...))` (default
        // `flex: 1`) with a separate `Spacer()`, so the title text claimed
        // an equal, fixed share of the row's free space right alongside the
        // `Spacer` — leaving whatever the (short) text didn't use stranded
        // between the two, and the indicator ~270px short of the bar's true
        // right edge. `Expanded` on the text alone, with no `Spacer`, makes
        // it the row's *only* flexible child, so it absorbs 100% of the
        // genuinely free space — the indicator then sits flush against
        // whatever's left over, and the text, still left-aligned within its
        // now-larger box, renders exactly where it did before.
        title: Row(
          children: [
            Expanded(
              // At the compact tier under a large text-scale factor, the
              // plain title and the indicator's own pills compete for the
              // same narrow row — this shrinks first, with an ellipsis,
              // rather than overflow (FR-018).
              child: Text(
                _stepTitle(context, step.current),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _StepIndicator(current: step.current),
          ],
        ),
      ),
      body: orderAsync.when(
        data: (order) {
          // Checked before anything else touches the order: a register sale
          // reached through the "Pedidos" list must not be advanced to a
          // step, rewritten into this workspace's URL, or rendered with an
          // editable control (FR-053, research R5).
          if (order != null &&
              isForeignOrder(order, settings: ref.watch(appSettingsProvider))) {
            return const _ForeignOrderNotice();
          }
          if (order != null) {
            _maybeRewriteUrl(order);
            _syncStepTo(order);
          }
          return _StepHost(
            current: step.current,
            order: order,
            canUpdate: canUpdate,
            cancelButton: cancelButton,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ErrorBanner(
              error: toAppError(error),
              onDismiss: () =>
                  ref.invalidate(orderEditorControllerProvider(widget.orderId)),
            ),
          ),
        ),
      ),
    );
  }
}

/// The declined state for an order this workspace did not raise: an
/// explanation and a way back, and no editable control at all — not a
/// disabled one (FR-053, contracts/order-workspace.md §9).
class _ForeignOrderNotice extends StatelessWidget {
  const _ForeignOrderNotice();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Center(
      key: const Key('sales_order_foreign_notice'),
      child: Padding(
        padding: EdgeInsets.all(theme.spacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: theme.spacing.sm,
          children: [
            Icon(
              Icons.point_of_sale_outlined,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            Text(
              l10n.salesOrderForeignOrderTitle,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            Text(
              l10n.salesOrderForeignOrderMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Always two steps — unlike POS, whose count varies with fulfilment mode,
/// because this workspace has no mode to vary (FR-021). No chevrons, no
/// current-pill icon distinction beyond fill — mirrors `_StepIndicator`'s
/// own POS styling, minus the parts that do not apply here (no return-to-
/// venta tap target yet; that lands with the resume work, spec 039 US3).
class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.current});

  final OrderStep current;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (LayoutBreakpoints.isCompact(context)) {
      return Text(
        key: const Key('sales_order_step_progress'),
        l10n.salesOrderStepProgress(current.index + 1, OrderStep.values.length),
        style: theme.textTheme.titleSmall,
      );
    }

    final labels = {
      OrderStep.venta: l10n.salesOrderStepVenta,
      OrderStep.entrega: l10n.salesOrderStepEntrega,
    };
    final icons = {
      OrderStep.venta: Icons.edit_note,
      OrderStep.entrega: Icons.local_shipping_outlined,
    };

    return Container(
      key: const Key('sales_order_step_indicator'),
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
          for (var i = 0; i < OrderStep.values.length; i++)
            _StepPill(
              position: i + 1,
              label: labels[OrderStep.values[i]]!,
              icon: icons[OrderStep.values[i]]!,
              isCurrent: i == current.index,
            ),
        ],
      ),
    );
  }
}

class _StepPill extends StatelessWidget {
  const _StepPill({
    required this.position,
    required this.label,
    required this.icon,
    required this.isCurrent,
  });

  final int position;
  final String label;
  final IconData icon;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 28,
      margin: EdgeInsets.symmetric(horizontal: theme.spacing.xxs / 2),
      padding: EdgeInsets.symmetric(horizontal: theme.spacing.xs),
      decoration: ShapeDecoration(
        color: isCurrent ? theme.colorScheme.secondaryContainer : null,
        shape: const StadiumBorder(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: theme.spacing.xxs,
        children: [
          if (isCurrent)
            Icon(icon, size: 16, color: theme.colorScheme.onSecondaryContainer),
          Text(
            '$position · $label',
            style: theme.textTheme.labelLarge?.copyWith(
              color: isCurrent
                  ? theme.colorScheme.onSecondaryContainer
                  : theme.colorScheme.onSurfaceVariant,
              fontWeight: isCurrent ? FontWeight.w500 : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepHost extends ConsumerWidget {
  const _StepHost({
    required this.current,
    required this.order,
    required this.canUpdate,
    required this.cancelButton,
  });

  final OrderStep current;

  /// `null` only on a genuinely new order, nothing chosen yet — Venta's own
  /// `CaptureStep` renders directly from this, exactly as it does for a
  /// register nobody has started a sale on (FR-005): the customer band
  /// shows a search, and product capture stays withheld until it succeeds
  /// (FR-009, FR-011).
  final Sale? order;
  final bool canUpdate;

  /// Built once by `_OrderWorkspaceBodyState` (which owns `_cancelling`) and
  /// handed down rather than rebuilt here — `null` when cancel is not
  /// offered (FR-034). Forwarded to whichever step is current as its own
  /// `secondaryAction`, immediately before that step's primary action.
  final Widget? cancelButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final editable = order?.isEditable ?? true;
    final canEditFields = canUpdate && editable;

    return switch (current) {
      OrderStep.venta => CaptureStep(
        sale: order,
        excludeGenericCustomer: true,
        showFulfillmentSelector: false,
        attachFulfillmentIntent: FulfillmentMode.delivery,
        continueLabel: l10n.salesOrderContinueToDeliveryAction,
        onContinue: (order != null && order!.lineCount > 0)
            ? () => ref
                  .read(orderStepControllerProvider.notifier)
                  .advanceToEntrega()
            : null,
        headerExtra: order == null
            ? null
            : OrderHeaderPanel(
                sale: order!,
                canEdit: canEditFields,
                canEditPriority: canUpdate,
                onStale: () =>
                    ref.invalidate(orderEditorControllerProvider(order!.id)),
              ),
        secondaryAction: cancelButton,
      ),
      // The header rides above `DeliveryStep` here, same widget and same
      // props as Venta's own `headerExtra` — not a second copy. Every
      // reachable order on this step has `status != draft` (the first
      // destination create is what got it here, spec A2), so `canEditFields`
      // reads false and the panel renders read-only in place — except
      // priority, which `canEditPriority` keeps editable on its own
      // (FR-034, FR-035). This is the *only* place a committed order's
      // priority is reachable at all: `resumeTargetFor` never sends a
      // completed or paid order back to Venta.
      OrderStep.entrega => Column(
        children: [
          OrderHeaderPanel(
            sale: order!,
            canEdit: canEditFields,
            canEditPriority: canUpdate,
            onStale: () =>
                ref.invalidate(orderEditorControllerProvider(order!.id)),
          ),
          Expanded(
            child: DeliveryStep(
              sale: order!,
              mode: FulfillmentMode.delivery,
              closeLabel: l10n.salesOrderCompleteDeliveryAction,
              // FR-031: this workspace never offers counter pickup as a
              // fulfilment choice (FR-021), so it must not fall back to one
              // here either — found live (T062), not by a test that existed
              // beforehand.
              allowCounterSweep: false,
              // The order is already committed by the time this fires — the
              // first destination create is what did it (spec A2) — so
              // there is nothing left to write here. Only the "Pedidos"
              // list needs telling: it has its own read of this order's
              // folio/status, taken before either existed.
              onClose: () => ref.invalidate(salesOrdersListControllerProvider),
              secondaryAction: cancelButton,
            ),
          ),
        ],
      ),
    };
  }
}
