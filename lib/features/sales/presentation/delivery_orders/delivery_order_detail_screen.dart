import 'dart:typed_data';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/app_formatters.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';
import 'package:mbe_ui/core/widgets/catalog_action_icons.dart';
import 'package:mbe_ui/core/widgets/compact_field.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/fact_strip_row.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart' show toAppError;
import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
import 'package:mbe_ui/core/widgets/responsive_form_grid.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_order.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_order_approval/approval_dialogs.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_order_approval/approval_target.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/add_line_dialog.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_order_detail_controller.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_order_dialogs.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_order_name_cells.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_order_print.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_order_status_chip.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_orders_list_screen.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/header_dialog.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/pickup_dialog.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// One delivery order (spec 061 contracts C4): header facts, the detail
/// band, the rejection banner, the lines, the proof of delivery, the history
/// and the status actions.
///
/// A full screen with its own address rather than a side panel, because an
/// order owns child lines and linked sections, and parent and child orders
/// link to it (constitution §VI record-surface criteria). `AppBar.actions`
/// stays empty; every action belongs in the body.
///
/// The body is a column of sections, top to bottom: rejection banner, facts
/// strip, detail band, lines, proof of delivery, history, action area; see
/// [_DeliveryOrderBody].
class DeliveryOrderDetailScreen extends ConsumerWidget {
  /// [deliveryOrderId] is `null` for an address whose id isn't a number,
  /// which shows the not-found state instead of throwing.
  const DeliveryOrderDetailScreen({super.key, required this.deliveryOrderId});

  final int? deliveryOrderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final id = deliveryOrderId;
    if (id == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.navDeliveryOrders)),
        body: const _NotFound(),
      );
    }
    final detail = ref.watch(deliveryOrderDetailControllerProvider(id));
    final order = detail.value?.order;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          order == null
              ? l10n.navDeliveryOrders
              : order.serial == null
              ? l10n.deliveryOrderTitleDraft
              : l10n.deliveryOrderTitle('${order.serial}'),
        ),
      ),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => error is NotFoundError
            ? const _NotFound()
            : _LoadFailed(
                error: toAppError(error),
                onRetry: () =>
                    ref.invalidate(deliveryOrderDetailControllerProvider(id)),
              ),
        data: (data) => _DeliveryOrderBody(detail: data),
      ),
    );
  }
}

/// Back to the list: pops when the list is underneath, otherwise goes there.
void _backToList(BuildContext context) =>
    context.canPop() ? context.pop() : context.go(deliveryOrdersPath);

class _NotFound extends StatelessWidget {
  const _NotFound();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    return Padding(
      padding: EdgeInsets.all(spacing.screenMargin),
      child: Column(
        key: const Key('delivery_order_not_found'),
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.fieldGapVertical,
        children: [
          const ErrorBanner(error: AppError.notFound()),
          OutlinedButton(
            key: const Key('delivery_order_back_to_list'),
            onPressed: () => _backToList(context),
            child: Text(l10n.deliveryOrderBackToList),
          ),
        ],
      ),
    );
  }
}

class _LoadFailed extends StatelessWidget {
  const _LoadFailed({required this.error, required this.onRetry});

  final AppError error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    return Padding(
      padding: EdgeInsets.all(spacing.screenMargin),
      child: Column(
        key: const Key('delivery_order_load_failed'),
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.fieldGapVertical,
        children: [
          ErrorBanner(error: error),
          Wrap(
            spacing: spacing.sm,
            runSpacing: spacing.sm,
            children: [
              OutlinedButton(
                key: const Key('delivery_order_back_to_list'),
                onPressed: () => _backToList(context),
                child: Text(l10n.deliveryOrderBackToList),
              ),
              FilledButton(
                key: const Key('delivery_order_retry_button'),
                onPressed: onRetry,
                child: Text(l10n.retryButton),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The loaded order, as a column of sections (contracts C4). The action area
/// stays last; [_DeliveryOrderBodyState._actionButtons] follows data-model
/// §3, and the dialogs live in `delivery_order_dialogs.dart` and
/// `pickup_dialog.dart`.
///
/// Stateful so the confirm's busy flag and a refusal survive the reload every
/// write triggers: the screen keeps showing this body while it refetches.
class _DeliveryOrderBody extends ConsumerStatefulWidget {
  const _DeliveryOrderBody({required this.detail});

  final DeliveryOrderDetail detail;

  @override
  ConsumerState<_DeliveryOrderBody> createState() => _DeliveryOrderBodyState();
}

class _DeliveryOrderBodyState extends ConsumerState<_DeliveryOrderBody> {
  /// Set from a confirm's success until the reloaded order arrives.
  bool _confirming = false;

  /// The last status action's refusal, shown above the action area.
  AppError? _actionError;

  DeliveryOrder get _order => widget.detail.order;

  /// The folio for a snackbar; a draft has none yet.
  String _serialOf(DeliveryOrder order, AppLocalizations l10n) =>
      order.serial == null ? l10n.deliveryOrderDraftFolio : '${order.serial}';

  void _snack(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));

  Future<void> _confirm() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final id = _order.id;
    setState(() => _actionError = null);
    final result = await showConfirmDeliveryOrderDialog(context, _order);
    if (!mounted || result == null) return;
    if (result.error != null) {
      setState(() => _actionError = result.error);
      return;
    }
    // The folio is the server's: read it from the reload the write started.
    // Until it lands the button stays busy, so the stale draft can't be
    // confirmed twice.
    setState(() => _confirming = true);
    DeliveryOrder? confirmed;
    try {
      confirmed = (await ref.read(
        deliveryOrderDetailControllerProvider(id).future,
      )).order;
    } on Object {
      // The screen shows the failed reload itself.
    }
    if (!mounted) return;
    setState(() => _confirming = false);
    if (confirmed != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            l10n.deliveryOrderSnackConfirmed(_serialOf(confirmed, l10n)),
          ),
        ),
      );
    }
  }

  /// Opens a status action's dialog; a refusal shows above the action area,
  /// a success says so with the order's folio. Either way the order reloads.
  Future<void> _statusAction(
    Future<DeliveryOrderActionResult?> Function() open,
    String Function(AppLocalizations l10n, String serial) done,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final serial = _serialOf(_order, l10n);
    setState(() => _actionError = null);
    final result = await open();
    if (!mounted || result == null) return;
    if (result.error != null) {
      setState(() => _actionError = result.error);
      return;
    }
    _snack(done(l10n, serial));
  }

  Future<void> _cancel() => _statusAction(
    () => showCancelDeliveryOrderDialog(context, _order),
    (l10n, serial) => l10n.deliveryOrderSnackCancelled(serial),
  );

  /// Approves the order after its confirmation (spec 062 FR-013). A refusal
  /// stays inside the dialog, so only a success comes back, with the status
  /// the server put the order in.
  Future<void> _approve() async {
    final l10n = AppLocalizations.of(context)!;
    final serial = _serialOf(_order, l10n);
    setState(() => _actionError = null);
    final status = await showApproveDeliveryOrderDialog(
      context,
      ApprovalTarget.fromOrder(_order),
    );
    if (!mounted || status == null) return;
    _snack(
      l10n.deliveryOrderSnackApproved(
        serial,
        deliveryOrderStatusLabel(l10n, status),
      ),
    );
  }

  /// Rejects the order back to its author with a reason (spec 062 FR-013).
  /// Same shape as [_approve]: the order reloads as Borrador with the reason
  /// in its banner and history.
  Future<void> _reject() async {
    final l10n = AppLocalizations.of(context)!;
    final serial = _serialOf(_order, l10n);
    setState(() => _actionError = null);
    final status = await showRejectDeliveryOrderDialog(
      context,
      ApprovalTarget.fromOrder(_order),
    );
    if (!mounted || status == null) return;
    _snack(l10n.deliveryOrderSnackRejected(serial));
  }

  Future<void> _requeue() => _statusAction(
    () => showRequeueDeliveryOrderDialog(context, _order),
    (l10n, serial) => l10n.deliveryOrderSnackRequeued(serial),
  );

  Future<void> _markReady() => _statusAction(
    () => showReadyDeliveryOrderDialog(context, _order),
    (l10n, serial) => l10n.deliveryOrderSnackReady(serial),
  );

  /// Refusals stay inside the pickup dialog, so only a success comes back.
  Future<void> _pickup() async {
    final l10n = AppLocalizations.of(context)!;
    final serial = _serialOf(_order, l10n);
    setState(() => _actionError = null);
    if (await showPickupDialog(context, _order) && mounted) {
      _snack(l10n.deliveryOrderSnackPickedUp(serial));
    }
  }

  Future<void> _editHeader() async {
    final l10n = AppLocalizations.of(context)!;
    final serial = _serialOf(_order, l10n);
    if (await showDeliveryOrderHeaderDialog(context, _order) && mounted) {
      _snack(l10n.deliveryOrderSnackHeaderSaved(serial));
    }
  }

  Future<void> _addLine() async {
    final l10n = AppLocalizations.of(context)!;
    final serial = _serialOf(_order, l10n);
    if (await showAddDeliveryOrderLineDialog(context, _order) > 0 && mounted) {
      _snack(l10n.deliveryOrderSnackLineAdded(serial));
    }
  }

  Future<void> _editLine(DeliveryOrderLine line) async {
    final l10n = AppLocalizations.of(context)!;
    final serial = _serialOf(_order, l10n);
    final saved = await showDeliveryOrderLineQuantityDialog(
      context,
      orderId: _order.id,
      line: line,
      saleId: widget.detail.sales[line.salesOrderDetailId],
    );
    if (saved && mounted) _snack(l10n.deliveryOrderSnackLineUpdated(serial));
  }

  Future<void> _removeLine(DeliveryOrderLine line) async {
    final l10n = AppLocalizations.of(context)!;
    final serial = _serialOf(_order, l10n);
    final removed = await showRemoveDeliveryOrderLineDialog(
      context,
      orderId: _order.id,
      line: line,
    );
    if (removed && mounted) _snack(l10n.deliveryOrderSnackLineRemoved(serial));
  }

  /// The status actions the order's status, its type and the user's rights
  /// allow (data-model §3, FR-011): absent, never disabled, without them. An
  /// outlined "Cancelar orden" (US4) goes first, then the one filled primary.
  ///
  /// Each right is checked per button. Spec 061's actions need Delivery
  /// Orders update ([canUpdate]); "Rechazar" and "Aprobar" on an order
  /// waiting for approval need Delivery Order Approval update ([canDecide])
  /// and nothing else (spec 062 R7), so an approver without the first right
  /// still gets both. Cancelar, Rechazar, Aprobar is the order.
  List<Widget> _actionButtons({
    required bool canUpdate,
    required bool canDecide,
    required bool canPrint,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final order = _order;
    final status = order.status;
    final isPickup = order.type == FulfillmentType.counterPickup;
    return [
      // Print comes first, so the filled status action stays rightmost
      // (spec 064 research R8).
      if (canPrint)
        OutlinedButton.icon(
          key: const Key('delivery_order_view_ticket'),
          onPressed: _viewTicket,
          icon: const Icon(Icons.receipt_long_outlined),
          label: Text(l10n.deliveryOrderViewTicket),
        ),
      // The Letter format is the secondary print action: a text button next
      // to the ticket (spec 064 FR-001).
      if (canPrint)
        TextButton.icon(
          key: const Key('delivery_order_view_letter'),
          onPressed: _viewLetter,
          icon: const Icon(Icons.description_outlined),
          label: Text(l10n.deliveryOrderViewLetter),
        ),
      // Offered in En preparación even when the order may be on an open
      // itinerary: the server refuses that cancel with
      // `delivery_order.on_itinerary` (mbe-api#311), shown as the refusal.
      if (canUpdate && _cancellable.contains(status))
        OutlinedButton(
          key: const Key('delivery_order_cancel'),
          onPressed: _confirming ? null : _cancel,
          child: Text(l10n.deliveryOrderCancelAction),
        ),
      if (canDecide && status == DeliveryOrderStatus.pendingApproval) ...[
        OutlinedButton(
          key: const Key('delivery_order_reject'),
          onPressed: _reject,
          child: Text(l10n.deliveryOrderRejectAction),
        ),
        FilledButton(
          key: const Key('delivery_order_approve'),
          onPressed: _approve,
          child: Text(l10n.deliveryOrderApproveAction),
        ),
      ],
      if (canUpdate && order.isDraft)
        FilledButton(
          key: const Key('delivery_order_confirm'),
          // The one disabled action: a draft with no lines (FR-016).
          onPressed: _confirming || order.lines.isEmpty ? null : _confirm,
          child: _confirming
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.deliveryOrderConfirmAction),
        ),
      if (canUpdate && status == DeliveryOrderStatus.failed)
        FilledButton(
          key: const Key('delivery_order_requeue'),
          onPressed: _requeue,
          child: Text(l10n.deliveryOrderRequeueAction),
        ),
      if (canUpdate && isPickup && status == DeliveryOrderStatus.approved)
        FilledButton(
          key: const Key('delivery_order_ready'),
          onPressed: _markReady,
          child: Text(l10n.deliveryOrderReadyAction),
        ),
      if (canUpdate && isPickup && status == DeliveryOrderStatus.readyForPickup)
        FilledButton(
          key: const Key('delivery_order_pickup'),
          onPressed: _pickup,
          child: Text(l10n.deliveryOrderPickupAction),
        ),
    ];
  }

  Future<void> _viewTicket() {
    final order = _order;
    return openDeliveryTicket(
      context,
      ref,
      orderId: order.id,
      folio: _serialOf(order, AppLocalizations.of(context)!),
      facilityId: order.facilityId,
      warehouseIds: distinctWarehouses(order.lines),
    );
  }

  Future<void> _viewLetter() {
    final order = _order;
    return openDeliveryLetter(
      context,
      ref,
      orderId: order.id,
      folio: _serialOf(order, AppLocalizations.of(context)!),
    );
  }

  /// Where "Cancelar orden" is offered (FR-018, data-model §3).
  static const _cancellable = {
    DeliveryOrderStatus.draft,
    DeliveryOrderStatus.pendingApproval,
    DeliveryOrderStatus.approved,
    DeliveryOrderStatus.readyForPickup,
    DeliveryOrderStatus.inPreparation,
    DeliveryOrderStatus.failed,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final access = ref.watch(accessControlProvider);
    final detail = widget.detail;
    final order = detail.order;
    final canUpdate = access.can(
      SystemObject.deliveryOrders,
      AccessRight.update,
    );
    // Header and lines are editable only on a draft (FR-015).
    final canEdit = canUpdate && order.isDraft;
    // Step 1 of "Agregar línea" lists sales (contracts C7).
    final canAddLine =
        canEdit && access.can(SystemObject.salesOrders, AccessRight.read);
    final canDecide = access.can(
      SystemObject.deliveryOrderApproval,
      AccessRight.update,
    );
    final buttons = _actionButtons(
      canUpdate: canUpdate,
      canDecide: canDecide,
      canPrint: canPrintDeliveryOrder(access, order.status),
    );

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.screenMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.sectionGap,
        children: [
          if (order.rejectionReason != null)
            _RejectionBanner(reason: order.rejectionReason!),
          _HeaderFacts(order: order),
          _DetailBand(
            detail: detail,
            onEditHeader: canEdit ? _editHeader : null,
          ),
          _LinesSection(
            detail: detail,
            onAddLine: canAddLine ? _addLine : null,
            onEditLine: canEdit ? _editLine : null,
            onRemoveLine: canEdit ? _removeLine : null,
          ),
          if (detail.proof != null)
            _ProofSection(
              orderId: order.id,
              orderLabel: _serialOf(order, l10n),
              proof: detail.proof!,
            ),
          _HistorySection(events: detail.events),
          if (_actionError != null) DeliveryOrderRefusal(error: _actionError!),
          if (buttons.isNotEmpty)
            Align(
              key: const Key('delivery_order_actions'),
              alignment: AlignmentDirectional.centerEnd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: spacing.xs,
                children: [
                  Wrap(
                    alignment: WrapAlignment.end,
                    spacing: spacing.sm,
                    runSpacing: spacing.sm,
                    children: buttons,
                  ),
                  if (order.isDraft && order.lines.isEmpty)
                    Text(
                      l10n.deliveryOrderConfirmNeedsLines,
                      key: const Key('delivery_order_confirm_needs_lines'),
                      style: theme.textTheme.bodySmall,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// The last rejection, shown while the order carries one (spec Edge Cases
/// "Rejected and back to draft").
class _RejectionBanner extends StatelessWidget {
  const _RejectionBanner({required this.reason});

  final String reason;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final color = theme.colorScheme.onTertiaryContainer;
    return Material(
      key: const Key('delivery_order_rejection_banner'),
      color: theme.colorScheme.tertiaryContainer,
      borderRadius: theme.shapes.mdRadius,
      child: Padding(
        padding: EdgeInsets.all(spacing.md),
        child: Row(
          spacing: spacing.sm,
          children: [
            Icon(Icons.warning_amber_outlined, color: color),
            Expanded(
              child: Text(
                l10n.deliveryOrderRejectionBanner(reason),
                style: TextStyle(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderFacts extends ConsumerWidget {
  const _HeaderFacts({required this.order});

  final DeliveryOrder order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final fmt = ref.watch(formattersProvider);
    return FactStripRow(
      key: const Key('delivery_order_facts'),
      facts: [
        CompactField(
          label: l10n.deliveryOrderColumnSerial,
          child: Text(
            order.serial == null
                ? l10n.deliveryOrderDraftFolio
                : '${order.serial}',
            key: const Key('delivery_order_serial'),
          ),
        ),
        CompactField(
          label: l10n.deliveryOrderColumnStatus,
          child: DeliveryOrderStatusChip(status: order.status),
        ),
        CompactField(
          label: l10n.deliveryOrderColumnType,
          child: Text(deliveryOrderTypeLabel(l10n, order.type)),
        ),
        CompactField(
          label: l10n.deliveryOrderColumnCustomer,
          child: DeliveryOrderCustomerName(customerId: order.customerId),
        ),
        CompactField(
          label: l10n.deliveryOrderFactFacility,
          child: DeliveryOrderFacilityName(facilityId: order.facilityId),
        ),
        CompactField(
          label: l10n.deliveryOrderColumnScheduled,
          child: Text(fmt.display.date(order.date)),
        ),
        CompactField(
          label: l10n.deliveryOrderFactPriority,
          child: Text(fmt.display.count(order.priority)),
        ),
      ],
      trailing: const SizedBox.shrink(),
    );
  }
}

/// Destino, Contacto, Pedidos, Comentario, and the parent and child orders
/// as links (FR-007).
class _DetailBand extends ConsumerWidget {
  const _DetailBand({required this.detail, this.onEditHeader});

  final DeliveryOrderDetail detail;

  /// Opens the header dialog; `null` hides "Editar encabezado" (FR-015).
  final VoidCallback? onEditHeader;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final order = detail.order;
    final canOpenSales = ref
        .watch(accessControlProvider)
        .can(SystemObject.salesOrders, AccessRight.read);
    final children = order.status == DeliveryOrderStatus.partiallyDelivered
        ? detail.children
        : const <DeliveryOrderSummary>[];

    return ResponsiveFormGrid(
      key: const Key('delivery_order_detail_band'),
      maxColumns: 2,
      spacing: spacing.fieldGapHorizontal,
      alignment: AlignmentDirectional.centerStart.resolve(
        Directionality.of(context),
      ),
      children: [
        FormGridChild(
          CompactField(
            label: l10n.deliveryOrderColumnDestination,
            child: DeliveryOrderShipTo(
              type: order.type,
              customerId: order.customerId,
              facilityId: order.facilityId,
              shipToId: order.shipToId,
              truncate: false,
            ),
          ),
        ),
        FormGridChild(
          CompactField(
            label: l10n.deliveryOrderFactContact,
            child: DeliveryOrderContact(
              customerId: order.customerId,
              contactId: order.contactId,
              truncate: false,
            ),
          ),
        ),
        FormGridChild(
          CompactField(
            label: l10n.deliveryOrderColumnSalesOrders,
            child: order.salesOrderIds.isEmpty
                ? const Text(emptyValuePlaceholder)
                : _Links(
                    links: [
                      for (final saleId in order.salesOrderIds)
                        (
                          key: Key('delivery_order_sale_link_$saleId'),
                          label: '$saleId',
                          // Without Sales Orders read the route would only
                          // redirect, so the number is shown as plain text.
                          target: canOpenSales ? '/sales/orders/$saleId' : null,
                        ),
                    ],
                  ),
          ),
        ),
        FormGridChild(
          CompactField(
            label: l10n.deliveryOrderFactComment,
            child: Text(
              (order.comment?.isEmpty ?? true)
                  ? emptyValuePlaceholder
                  : order.comment!,
            ),
          ),
        ),
        if (order.parentId != null)
          FormGridChild(
            CompactField(
              label: l10n.deliveryOrderFactParent,
              // The order carries only its parent's id, not its folio.
              child: _Links(
                links: [
                  (
                    key: const Key('delivery_order_parent_link'),
                    label: '#${order.parentId}',
                    target: '$deliveryOrdersPath/${order.parentId}',
                  ),
                ],
              ),
            ),
          ),
        if (children.isNotEmpty)
          FormGridChild(
            CompactField(
              label: l10n.deliveryOrderFactChild,
              child: _Links(
                links: [
                  for (final child in children)
                    (
                      key: Key('delivery_order_child_link_${child.id}'),
                      label: child.serial == null
                          ? l10n.deliveryOrderDraftFolio
                          : '${child.serial}',
                      target: '$deliveryOrdersPath/${child.id}',
                    ),
                ],
              ),
            ),
          ),
        if (onEditHeader != null)
          FormGridChild(
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: OutlinedButton.icon(
                key: const Key('delivery_order_edit_header'),
                onPressed: onEditHeader,
                icon: Icon(CatalogAction.edit.icon),
                label: Text(l10n.deliveryOrderEditHeader),
              ),
            ),
            span: FormGridSpan.full,
          ),
      ],
    );
  }
}

typedef _Link = ({Key key, String label, String? target});

/// A run of record links; one without a [_Link.target] is plain text.
class _Links extends StatelessWidget {
  const _Links({required this.links});

  final List<_Link> links;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).spacing;
    return Wrap(
      spacing: spacing.sm,
      runSpacing: spacing.xs,
      children: [
        for (final link in links)
          link.target == null
              ? Text(link.label, key: link.key)
              : TextButton(
                  key: link.key,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    alignment: AlignmentDirectional.centerStart,
                  ),
                  onPressed: () => context.push(link.target!),
                  child: Text(link.label),
                ),
      ],
    );
  }
}

/// The lines (FR-008): a table on wider tiers, cards at the compact tier.
/// Every quantity is kept and never truncated.
class _LinesSection extends ConsumerWidget {
  const _LinesSection({
    required this.detail,
    this.onAddLine,
    this.onEditLine,
    this.onRemoveLine,
  });

  final DeliveryOrderDetail detail;

  /// Each `null` hides its control (FR-015, contracts C7).
  final VoidCallback? onAddLine;
  final void Function(DeliveryOrderLine line)? onEditLine;
  final void Function(DeliveryOrderLine line)? onRemoveLine;

  /// ✎ and 🗑 for [line], or none when the lines aren't editable.
  List<Widget> _lineActions(AppLocalizations l10n, DeliveryOrderLine line) {
    final onEdit = onEditLine;
    final onRemove = onRemoveLine;
    if (onEdit == null || onRemove == null) return const [];
    return buildCatalogRowActions(
      editTooltip: l10n.deliveryOrderLineEditTooltip,
      editKey: Key('delivery_order_line_edit_${line.id}'),
      onEdit: () => onEdit(line),
      extraActions: [
        CatalogRowAction(
          key: Key('delivery_order_line_remove_${line.id}'),
          icon: Icons.delete_outline,
          tooltip: l10n.deliveryOrderLineRemoveTooltip,
          onPressed: () => onRemove(line),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final fmt = ref.watch(formattersProvider);
    final order = detail.order;

    String saleOf(DeliveryOrderLine line) {
      final saleId = detail.sales[line.salesOrderDetailId];
      return saleId == null ? emptyValuePlaceholder : '$saleId';
    }

    final quantities = <(String, String Function(DeliveryOrderLine))>[
      (l10n.deliveryOrderLineColumnOrdered, (l) => l.quantity.toString()),
      (l10n.deliveryOrderLineColumnCommitted, (l) => l.committed.toString()),
      (l10n.deliveryOrderLineColumnDelivered, (l) => l.delivered.toString()),
      (l10n.deliveryOrderLineColumnReturned, (l) => l.returned.toString()),
      (l10n.deliveryOrderLineColumnOpen, (l) => l.open.toString()),
    ];

    final Widget lines;
    if (LayoutBreakpoints.isCompact(context)) {
      lines = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final line in order.lines) ...[
            Padding(
              key: Key('delivery_order_line_card_${line.id}'),
              padding: EdgeInsets.symmetric(vertical: spacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: spacing.xs,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text('${line.productCode} ${line.productName}'),
                      ),
                      ..._lineActions(l10n, line),
                    ],
                  ),
                  Row(
                    children: [
                      Flexible(
                        child: DeliveryOrderWarehouseName(
                          facilityId: order.facilityId,
                          warehouseId: line.warehouseId,
                        ),
                      ),
                      Text(
                        ' · ${l10n.deliveryOrderLineColumnSalesOrder} '
                        '${saleOf(line)}',
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: spacing.md,
                    runSpacing: spacing.xs,
                    children: [
                      for (final (label, value) in quantities)
                        Text(
                          '$label ${fmt.display.quantity(value(line))}',
                          style: theme.textTheme.bodySmall,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
          ],
        ],
      );
    } else {
      lines = DataTableView<DeliveryOrderLine>(
        key: const Key('delivery_order_lines_table'),
        shrinkWrap: true,
        margin: EdgeInsets.zero,
        rows: order.lines,
        rowActionsBuilder: onEditLine == null
            ? null
            : (context, line) => _lineActions(l10n, line),
        columns: [
          DataTableColumn.text(
            label: l10n.deliveryOrderLineColumnCode,
            size: ColumnSize.S,
            text: (line) => line.productCode,
          ),
          DataTableColumn.text(
            label: l10n.deliveryOrderLineColumnProduct,
            size: ColumnSize.L,
            text: (line) => line.productName,
          ),
          DataTableColumn(
            label: l10n.deliveryOrderLineColumnWarehouse,
            size: ColumnSize.M,
            cellBuilder: (context, line) => DeliveryOrderWarehouseName(
              facilityId: order.facilityId,
              warehouseId: line.warehouseId,
            ),
          ),
          DataTableColumn(
            label: l10n.deliveryOrderLineColumnSalesOrder,
            size: ColumnSize.S,
            cellBuilder: (context, line) => Text(saleOf(line)),
          ),
          for (final (label, value) in quantities)
            DataTableColumn(
              label: label,
              numeric: true,
              size: ColumnSize.S,
              cellBuilder: (context, line) =>
                  Text(fmt.display.quantity(value(line))),
            ),
        ],
      );
    }

    return Column(
      key: const Key('delivery_order_lines'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: spacing.sm,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.deliveryOrderLinesTitle,
                style: theme.textTheme.titleMedium,
              ),
            ),
            if (onAddLine != null)
              OutlinedButton.icon(
                key: const Key('delivery_order_add_line'),
                onPressed: onAddLine,
                icon: Icon(CatalogAction.create.icon),
                label: Text(l10n.deliveryOrderAddLine),
              ),
          ],
        ),
        lines,
      ],
    );
  }
}

/// The proof of delivery, read-only (FR-010): who received it, the
/// identification they showed, when and by whom it was captured, and the
/// photo. A failure shows inside this section only.
class _ProofSection extends ConsumerWidget {
  const _ProofSection({
    required this.orderId,
    required this.orderLabel,
    required this.proof,
  });

  static const _thumbnailSize = 120.0;

  final int orderId;

  /// The order's folio, titling the enlarged photo.
  final String orderLabel;
  final AsyncValue<ProofOfDelivery> proof;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final fmt = ref.watch(formattersProvider);
    final failed = Text(
      l10n.deliveryOrderProofLoadFailed,
      key: const Key('delivery_order_proof_failed'),
      style: TextStyle(color: theme.colorScheme.error),
    );

    return Column(
      key: const Key('delivery_order_proof'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: spacing.sm,
      children: [
        Text(l10n.deliveryOrderProofTitle, style: theme.textTheme.titleMedium),
        proof.when(
          loading: () => const LinearProgressIndicator(),
          error: (_, _) => failed,
          data: (proof) => Wrap(
            spacing: spacing.lg,
            runSpacing: spacing.sm,
            crossAxisAlignment: WrapCrossAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: spacing.sm,
                children: [
                  CompactField(
                    label: l10n.deliveryOrderProofReceiver,
                    child: Text(
                      proof.receiverName,
                      key: const Key('delivery_order_proof_receiver'),
                    ),
                  ),
                  CompactField(
                    label: l10n.deliveryOrderProofIdShown,
                    child: Text(
                      proof.receiverIdShown,
                      key: const Key('delivery_order_proof_id_shown'),
                    ),
                  ),
                  CompactField(
                    label: l10n.deliveryOrderProofCapturedAt,
                    child: Text(fmt.display.dateTime(proof.capturedAt)),
                  ),
                  CompactField(
                    label: l10n.deliveryOrderProofCapturedBy,
                    child: DeliveryOrderEmployeeName(
                      employeeId: proof.capturedBy,
                      truncate: false,
                    ),
                  ),
                ],
              ),
              // Read only once the details are in (research R5).
              ref
                  .watch(deliveryOrderProofImageProvider(orderId))
                  .when(
                    loading: () => const SizedBox.square(
                      dimension: _thumbnailSize,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (_, _) => failed,
                    data: (bytes) => Tooltip(
                      message: l10n.deliveryOrderProofEnlargeTooltip,
                      child: InkWell(
                        key: const Key('delivery_order_proof_photo'),
                        onTap: () => _enlarge(context, bytes),
                        child: ClipRRect(
                          borderRadius: theme.shapes.mdRadius,
                          child: Image.memory(
                            bytes,
                            width: _thumbnailSize,
                            height: _thumbnailSize,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => failed,
                          ),
                        ),
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }

  void _enlarge(BuildContext context, Uint8List bytes) {
    final l10n = AppLocalizations.of(context)!;
    showResponsiveDialog<void>(
      context,
      builder: (context) => ResponsiveDialog(
        key: const Key('delivery_order_proof_photo_dialog'),
        title: '${l10n.deliveryOrderProofTitle} · $orderLabel',
        maxWidth: 960,
        body: Image.memory(bytes, fit: BoxFit.contain),
        primaryAction: ResponsiveDialogAction(
          label: MaterialLocalizations.of(context).closeButtonLabel,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
}

/// The status history (FR-009), oldest first: when, from → to (a dash for
/// the creation event), who, and the reason. Bounded to a handful of events,
/// so it isn't paginated (research R5). A failed history shows inside this
/// section only.
class _HistorySection extends ConsumerWidget {
  const _HistorySection({required this.events});

  final AsyncValue<List<DeliveryOrderEvent>> events;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final fmt = ref.watch(formattersProvider);
    final compact = LayoutBreakpoints.isCompact(context);

    String label(DeliveryOrderStatus? status) => status == null
        ? emptyValuePlaceholder
        : deliveryOrderStatusLabel(l10n, status);

    Widget row(DeliveryOrderEvent event) {
      final when = Text(fmt.display.dateTime(event.at));
      final transition = Text(
        '${label(event.from)} → ${label(event.to)}',
        key: Key('delivery_order_event_transition_${event.id}'),
      );
      final who = DeliveryOrderEmployeeName(employeeId: event.employeeId);
      final reason = event.reason;
      final why = reason == null || reason.isEmpty
          ? const Text(emptyValuePlaceholder)
          : Tooltip(
              message: reason,
              child: Text(
                reason,
                key: Key('delivery_order_event_reason_${event.id}'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            );
      return Padding(
        key: Key('delivery_order_event_${event.id}'),
        padding: EdgeInsets.symmetric(vertical: spacing.xs),
        child: compact
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: spacing.xs,
                children: [when, transition, who, why],
              )
            : Row(
                spacing: spacing.md,
                children: [
                  Expanded(flex: 2, child: when),
                  Expanded(flex: 3, child: transition),
                  Expanded(flex: 2, child: who),
                  Expanded(flex: 3, child: why),
                ],
              ),
      );
    }

    return Column(
      key: const Key('delivery_order_history'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: spacing.sm,
      children: [
        Text(
          l10n.deliveryOrderHistoryTitle,
          style: theme.textTheme.titleMedium,
        ),
        events.when(
          loading: () => const LinearProgressIndicator(),
          error: (error, _) => ErrorBanner(
            key: const Key('delivery_order_events_error'),
            error: toAppError(error),
          ),
          data: (events) {
            if (events.isEmpty) {
              return Text(
                l10n.deliveryOrderEventsEmpty,
                key: const Key('delivery_order_events_empty'),
              );
            }
            final ordered = [...events]
              ..sort((a, b) {
                final byTime = a.at.compareTo(b.at);
                return byTime != 0 ? byTime : a.id.compareTo(b.id);
              });
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (i, event) in ordered.indexed) ...[
                  if (i > 0) const Divider(height: 1),
                  row(event),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}
