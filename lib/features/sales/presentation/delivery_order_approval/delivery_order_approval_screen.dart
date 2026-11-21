import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/widgets/catalog_action_icons.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_order.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_order_approval/approval_dialogs.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_order_approval/approval_target.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_order_approval/delivery_order_approval_queue_controller.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_order_name_cells.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_orders_list_screen.dart'
    show deliveryOrdersPath;
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_order_status_chip.dart';
import 'package:mbe_ui/features/sales/presentation/register_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

const deliveryOrderApprovalPath = '/sales/delivery-order-approval';

/// Aprobación de entregas: the delivery orders waiting for a supervisor's
/// decision at the user's facility (spec 062 US1, contracts C2). Gated by
/// Delivery Order Approval (SystemObject 94) read.
///
/// A table and pagination, with no filter row: the server takes only paging
/// for this list, so there is nothing to search or filter (FR-003). A
/// supervisor approves or rejects from the row icons, which need Delivery
/// Order Approval update and are absent without it (FR-005).
class DeliveryOrderApprovalScreen extends ConsumerWidget {
  const DeliveryOrderApprovalScreen({super.key, required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;

    // No request at all for a user with no facility: the server would ask for
    // `facility IS NULL` and answer an empty page that reads as "nothing
    // waiting" (FR-004). Administrators included, as in the delivery orders
    // list.
    if (ref.watch(userFacilityIdProvider) == null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(spacing.screenMargin),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: spacing.sm,
            children: [
              Text(
                key: const Key('delivery_order_approval_no_facility'),
                l10n.deliveryOrderApprovalNoFacilityTitle,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              Text(
                l10n.deliveryOrderApprovalNoFacilityMessage,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final pageIndex = query.pageIndex;
    final pageAsync = ref.watch(
      deliveryOrderApprovalQueueControllerProvider(pageIndex),
    );
    final fmt = ref.watch(formattersProvider);
    final compact = LayoutBreakpoints.isCompact(context);
    final access = ref.watch(accessControlProvider);
    final canDecide = access.can(
      SystemObject.deliveryOrderApproval,
      AccessRight.update,
    );
    // A row opens the order's own screen, which is gated on Delivery Orders
    // read (spec 061). Without that right a tap would only be redirected, so
    // the rows aren't tappable at all (FR-006, Clarification Q1).
    final canOpen = access.can(SystemObject.deliveryOrders, AccessRight.read);

    // A refusal is not a failure: the user isn't allowed this list, and
    // asking again won't change that.
    if (_isForbidden(pageAsync)) return const _QueueForbidden();

    return CatalogListStateView<DeliveryOrderSummary>(
      state: pageAsync,
      // Nothing to filter, so nothing to clear: the empty state has no action.
      isFiltered: false,
      emptyMessage: l10n.deliveryOrderApprovalEmpty,
      clearFiltersLabel: l10n.clearFiltersButton,
      onClearFilters: () => context.go(deliveryOrderApprovalPath),
      retryLabel: l10n.retryButton,
      onRetry: () => ref.invalidate(
        deliveryOrderApprovalQueueControllerProvider(pageIndex),
      ),
      onData: (page) => DataTableView<DeliveryOrderSummary>(
        key: const Key('delivery_order_approval_table'),
        columns: [
          DataTableColumn.id(
            label: l10n.deliveryOrderColumnSerial,
            size: ColumnSize.S,
            text: (o) => o.serial == null ? '#${o.id}' : '${o.serial}',
          ),
          DataTableColumn(
            label: l10n.deliveryOrderColumnCustomer,
            size: ColumnSize.L,
            cellBuilder: (context, o) => DeliveryOrderCustomerName(
              customerId: o.customerId,
              name: o.customerName,
            ),
          ),
          if (!compact)
            DataTableColumn(
              label: l10n.deliveryOrderColumnType,
              size: ColumnSize.S,
              cellBuilder: (context, o) =>
                  Text(deliveryOrderTypeLabel(l10n, o.type)),
            ),
          DataTableColumn.timestamp(
            label: l10n.deliveryOrderColumnScheduled,
            size: ColumnSize.S,
            text: (o) => fmt.display.date(o.date),
          ),
          if (!compact)
            DataTableColumn(
              label: l10n.deliveryOrderColumnDestination,
              size: ColumnSize.L,
              cellBuilder: (context, o) => DeliveryOrderShipTo(
                type: o.type,
                customerId: o.customerId,
                facilityId: o.facilityId,
                shipToId: o.shipToId,
                shipToLabel: o.shipToLabel,
                facilityName: o.facilityName,
              ),
            ),
          if (!compact)
            DataTableColumn.text(
              label: l10n.deliveryOrderColumnSalesOrders,
              size: ColumnSize.S,
              text: (o) => o.salesOrderIds.join(', '),
            ),
          DataTableColumn(
            label: l10n.deliveryOrderApprovalColumnPriority,
            numeric: true,
            size: ColumnSize.S,
            cellBuilder: (context, o) => Text('${o.priority}'),
          ),
        ],
        rows: page.items,
        pagination: page,
        onPageChanged: (index) => context.go(
          query
              .copyWith(pageIndex: index)
              .toUri(deliveryOrderApprovalPath)
              .toString(),
        ),
        // Push, not go, so back returns to the queue (spec 062 R4).
        onRowTap: canOpen
            ? (o) => context.push('$deliveryOrdersPath/${o.id}')
            : null,
        // An order here isn't editable, so the primary slot is the queue's
        // own job: approve, with reject as the one direct secondary action —
        // two icons, as §VI allows (spec 060 does the same for verify). Without
        // update there are no actions, and no column.
        rowActionsBuilder: canDecide
            ? (context, o) => buildCatalogRowActions(
                editTooltip: l10n.editActionTooltip,
                primaryAction: CatalogRowAction(
                  key: Key('approve_delivery_order_${o.id}'),
                  icon: Icons.check_circle_outline,
                  tooltip: l10n.deliveryOrderApproveAction,
                  onPressed: () => _approve(context, o),
                ),
                extraActions: [
                  CatalogRowAction(
                    key: Key('reject_delivery_order_${o.id}'),
                    icon: Icons.block,
                    tooltip: l10n.deliveryOrderRejectAction,
                    onPressed: () => _reject(context, o),
                  ),
                ],
              )
            : null,
      ),
    );
  }
}

/// Approves [order] after its confirmation, and says so with the status the
/// server returned (FR-009). The queue reloads by itself: the write
/// invalidates it.
Future<void> _approve(BuildContext context, DeliveryOrderSummary order) async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = AppLocalizations.of(context)!;
  final target = ApprovalTarget.fromSummary(order);
  final status = await showApproveDeliveryOrderDialog(context, target);
  if (status == null) return;
  messenger.showSnackBar(
    SnackBar(
      content: Text(
        l10n.deliveryOrderSnackApproved(
          target.folio,
          deliveryOrderStatusLabel(l10n, status),
        ),
      ),
    ),
  );
}

/// Rejects [order] back to its author with a reason, and says so (FR-012).
/// The order leaves the queue: the write invalidates it, and the server has
/// moved the order to Borrador.
Future<void> _reject(BuildContext context, DeliveryOrderSummary order) async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = AppLocalizations.of(context)!;
  final target = ApprovalTarget.fromSummary(order);
  final status = await showRejectDeliveryOrderDialog(context, target);
  if (status == null) return;
  messenger.showSnackBar(
    SnackBar(content: Text(l10n.deliveryOrderSnackRejected(target.folio))),
  );
}

/// Whether the server refused the queue outright (403): an access change
/// mid-session, since the route is gated on the same right. A retry button on
/// it would be wrong.
bool _isForbidden(AsyncValue<Object?> page) {
  final error = page.error;
  return error != null &&
      switch (toAppError(error)) {
        ServerError(statusCode: 403) => true,
        _ => false,
      };
}

/// The queue's "not allowed" state: a message and nothing to retry.
class _QueueForbidden extends StatelessWidget {
  const _QueueForbidden();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(spacing.screenMargin),
        child: Text(
          l10n.deliveryOrderApprovalForbidden,
          key: const Key('delivery_order_approval_forbidden'),
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
