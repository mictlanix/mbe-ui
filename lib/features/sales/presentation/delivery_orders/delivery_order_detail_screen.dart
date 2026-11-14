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
import 'package:mbe_ui/core/widgets/compact_field.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/fact_strip_row.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart' show toAppError;
import 'package:mbe_ui/core/widgets/responsive_form_grid.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_order.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_order_detail_controller.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_order_name_cells.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_order_status_chip.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_orders_list_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// One delivery order (spec 061 contracts C4): header facts, the detail
/// band, the rejection banner and the lines.
///
/// A full screen with its own address rather than a side panel, because an
/// order owns child lines and linked sections, and parent and child orders
/// link to it (constitution §VI record-surface criteria). `AppBar.actions`
/// stays empty; every action belongs in the body.
///
/// The body is a column of sections, top to bottom: rejection banner, facts
/// strip, detail band, lines. Later stories add, below the lines and in this
/// order, the proof of delivery (US7), the history (US5) and the action area
/// (US2); see [_DeliveryOrderBody].
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

/// The loaded order, as a column of sections. Read-only for now.
///
/// Where later stories plug in:
/// - "Editar encabezado" (US3) ends the detail band ([_DetailBand]);
/// - "Agregar línea" and the per-line icons (US3) go in [_LinesSection];
/// - the proof (US7), history (US5) and action area (US2) are appended to
///   this column after [_LinesSection], in that order (contracts C4).
class _DeliveryOrderBody extends StatelessWidget {
  const _DeliveryOrderBody({required this.detail});

  final DeliveryOrderDetail detail;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).spacing;
    final order = detail.order;
    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.screenMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.sectionGap,
        children: [
          if (order.rejectionReason != null)
            _RejectionBanner(reason: order.rejectionReason!),
          _HeaderFacts(order: order),
          _DetailBand(detail: detail),
          _LinesSection(detail: detail),
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
  const _DetailBand({required this.detail});

  final DeliveryOrderDetail detail;

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
  const _LinesSection({required this.detail});

  final DeliveryOrderDetail detail;

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
                  Text('${line.productCode} ${line.productName}'),
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
        Text(l10n.deliveryOrderLinesTitle, style: theme.textTheme.titleMedium),
        lines,
      ],
    );
  }
}
