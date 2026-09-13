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
import 'package:mbe_ui/features/sales/presentation/orders/customer_step.dart';
import 'package:mbe_ui/features/sales/presentation/orders/foreign_order_guard.dart';
import 'package:mbe_ui/features/sales/presentation/orders/order_editor_controller.dart';
import 'package:mbe_ui/features/sales/presentation/orders/order_header_panel.dart';
import 'package:mbe_ui/features/sales/presentation/orders/order_step_controller.dart';
import 'package:mbe_ui/features/sales/presentation/orders/sales_orders_list_controller.dart';
import 'package:mbe_ui/features/sales/presentation/sale_editor.dart';
import 'package:mbe_ui/features/sales/presentation/sales_order_write_scope.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The back-office order workspace (spec 039 contracts/order-workspace.md):
/// a three-step host — Cliente, Venta, Entrega — reached at
/// `/sales/orders/new` and `/sales/orders/:orderId`, top-level sibling
/// routes mirroring `PosWorkspaceScreen`'s own shape (full-screen, no shell).
///
/// Installs the nested `ProviderScope` the shared capture and delivery
/// surfaces read through (contracts/shared-step-seam.md §5) — all **four**
/// seam providers together, so this workspace's writes, unconfirmed edits and
/// confirm failures are never held open, shut, or painted by the register's
/// own, and vice versa (FR-042, FR-043).
class OrderWorkspaceScreen extends ConsumerWidget {
  const OrderWorkspaceScreen({super.key, this.orderId});

  /// `null` for `/sales/orders/new` — a fresh order, opened lazily by the
  /// Cliente step's own first customer attach (FR-005). Non-null for
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
  /// `orderStepControllerProvider` override defaulting to Cliente — unlike
  /// POS, where the step controller is one true app-wide singleton that
  /// survives a widget remount. Without this, advancing to Venta from the
  /// Cliente step's own attach would be silently undone the instant the URL
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
    final isGeneric = ref
        .read(appSettingsProvider)
        .isGenericCustomer(order.customer);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(orderStepControllerProvider.notifier)
          .resumeTo(order, isGenericCustomer: isGeneric);
    });
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
        title: _StepIndicator(current: step.current),
        actions: [
          if (canCancel)
            Padding(
              padding: EdgeInsets.only(right: Theme.of(context).spacing.xs),
              child: TextButton(
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
              ),
            ),
        ],
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

/// Always three steps — unlike POS, whose count varies with fulfilment mode,
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
      OrderStep.cliente: l10n.salesOrderStepCliente,
      OrderStep.venta: l10n.salesOrderStepVenta,
      OrderStep.entrega: l10n.salesOrderStepEntrega,
    };
    final icons = {
      OrderStep.cliente: Icons.person_outline,
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
  });

  final OrderStep current;

  /// `null` only while [OrderStep.cliente] is current and no order has been
  /// opened yet — the Cliente step needs nothing else to render.
  final Sale? order;
  final bool canUpdate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    if (order == null) return const CustomerStep();

    final editable = order!.isEditable;
    final canEditFields = canUpdate && editable;

    return switch (current) {
      OrderStep.cliente => const CustomerStep(),
      OrderStep.venta => CaptureStep(
        sale: order,
        excludeGenericCustomer: true,
        showFulfillmentSelector: false,
        continueLabel: l10n.salesOrderContinueToDeliveryAction,
        onContinue: (order!.lineCount > 0)
            ? () => ref
                  .read(orderStepControllerProvider.notifier)
                  .advanceToEntrega()
            : null,
        headerExtra: OrderHeaderPanel(
          sale: order!,
          canEdit: canEditFields,
          canEditPriority: canUpdate,
          onStale: () =>
              ref.invalidate(orderEditorControllerProvider(order!.id)),
        ),
      ),
      OrderStep.entrega => DeliveryStep(
        sale: order!,
        mode: FulfillmentMode.delivery,
        closeLabel: l10n.salesOrderCompleteDeliveryAction,
        // The order is already committed by the time this fires — the first
        // destination create is what did it (spec A2) — so there is nothing
        // left to write here. Only the "Pedidos" list needs telling: it has
        // its own read of this order's folio/status, taken before either
        // existed.
        onClose: () => ref.invalidate(salesOrdersListControllerProvider),
      ),
    };
  }
}
