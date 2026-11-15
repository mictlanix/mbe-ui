import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_bar.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_sheet.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/features/sales/domain/entities/pending_delivery.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_order_name_cells.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_orders_list_screen.dart'
    show deliveryOrdersPath;
import 'package:mbe_ui/features/sales/presentation/for_delivery/pending_deliveries_controller.dart';
import 'package:mbe_ui/features/sales/presentation/for_delivery/pending_deliveries_filter.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Por entregar: the delivery lines still waiting to be loaded onto a truck,
/// for one date period at a time (spec 063, contracts C2–C5). Gated by For
/// Delivery (SystemObject 91) read, at the route and the navigation entry.
///
/// A filter row, a table and pagination. The period is the only facet and
/// lives in the shared filter panel; there is no search box because the
/// server offers none for this queue (FR-011). The queue is read-only
/// (FR-010), so rows carry no actions. A tap opens the order behind the
/// line, but only with Delivery Orders (71) read (FR-009): the order's
/// screen is gated on that right.
///
/// The queue spans every active facility, as the legacy screen did, so there
/// is no facility notice and no facility guard.
class PendingDeliveriesScreen extends ConsumerWidget {
  const PendingDeliveriesScreen({super.key, required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final filter = PendingDeliveriesFilter.fromQuery(query);
    final viewAsync = ref.watch(
      pendingDeliveriesControllerProvider(filter.period, filter.pageIndex),
    );
    final fmt = ref.watch(formattersProvider);
    final compact = LayoutBreakpoints.isCompact(context);
    final canOpen = ref
        .watch(accessControlProvider)
        .can(SystemObject.deliveryOrders, AccessRight.read);
    final clearedPath = filter
        .cleared()
        .toQuery()
        .toUri(forDeliveryPath)
        .toString();

    void reload() => ref.invalidate(
      pendingDeliveriesControllerProvider(filter.period, filter.pageIndex),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.fieldGapVertical,
      children: [
        CatalogFilterBar(
          filters: [
            Badge.count(
              count: filter.activeFilterCount,
              isLabelVisible: filter.activeFilterCount > 0,
              child: IconButton.outlined(
                key: const Key('for_delivery_filter_button'),
                icon: const Icon(Icons.tune),
                tooltip: l10n.filtersTooltip,
                onPressed: () => showCatalogFilterSheet(
                  context,
                  title: l10n.filtersButton,
                  clearAllLabel: l10n.clearAllFilters,
                  applyLabel: l10n.applyFilters,
                  onClearAll: () => context.go(clearedPath),
                  builder: (_) => CurrentListQueryBuilder(
                    builder: (context, query) =>
                        _PendingDeliveriesFiltersPanel(query: query),
                  ),
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: CatalogListStateView<PendingDeliveryLine>(
            state: viewAsync.whenData((view) => view.page),
            isFiltered: filter.isNarrowed,
            emptyMessage: l10n.forDeliveryEmpty,
            clearFiltersLabel: l10n.clearFiltersButton,
            onClearFilters: () => context.go(clearedPath),
            retryLabel: l10n.retryButton,
            onRetry: reload,
            onData: (page) => DataTableView<PendingDeliveryLine>(
              key: const Key('for_delivery_table'),
              columns: [
                DataTableColumn(
                  label: l10n.deliveryOrderColumnSerial,
                  size: ColumnSize.S,
                  cellBuilder: (context, l) => Text(
                    l.serial == null
                        ? l10n.deliveryOrderDraftFolio
                        : '${l.serial}',
                  ),
                ),
                DataTableColumn(
                  label: l10n.deliveryOrderColumnCustomer,
                  size: ColumnSize.L,
                  cellBuilder: (context, l) =>
                      DeliveryOrderCustomerName(customerId: l.customerId),
                ),
                if (!compact)
                  DataTableColumn(
                    label: l10n.deliveryOrderColumnDestination,
                    size: ColumnSize.L,
                    cellBuilder: (context, l) => DeliveryOrderCustomerAddress(
                      customerId: l.customerId,
                      shipToId: l.shipToId,
                    ),
                  ),
                DataTableColumn(
                  label: l10n.deliveryOrderColumnScheduled,
                  size: ColumnSize.S,
                  cellBuilder: (context, l) => Text(
                    l.scheduledDate == null
                        ? l10n.forDeliveryNoDate
                        : fmt.display.date(l.scheduledDate),
                  ),
                ),
                DataTableColumn(
                  label: l10n.forDeliveryColumnPriority,
                  numeric: true,
                  size: ColumnSize.S,
                  cellBuilder: (context, l) => Text('${l.priority}'),
                ),
                DataTableColumn.text(
                  label: l10n.forDeliveryColumnProduct,
                  size: ColumnSize.L,
                  text: (l) => '${l.productCode} ${l.productName}',
                ),
                DataTableColumn(
                  label: l10n.forDeliveryColumnWarehouse,
                  size: ColumnSize.M,
                  cellBuilder: (context, l) =>
                      WarehouseNameById(warehouseId: l.warehouseId),
                ),
                DataTableColumn(
                  label: l10n.forDeliveryColumnOpenQuantity,
                  numeric: true,
                  size: ColumnSize.S,
                  cellBuilder: (context, l) =>
                      Text(fmt.display.quantity(l.openQuantity)),
                ),
              ],
              rows: page.items,
              pagination: page,
              onPageChanged: (index) => context.go(
                filter
                    .copyWith(pageIndex: index)
                    .toQuery()
                    .toUri(forDeliveryPath)
                    .toString(),
              ),
              // Push, not go, so back returns to the queue. The queue then
              // reloads on the same period and page: this screen writes
              // nothing, so nothing else would refresh it, and the order may
              // have been cancelled or sent back meanwhile (spec 063 R6).
              onRowTap: canOpen
                  ? (l) => context
                        .push('$deliveryOrdersPath/${l.deliveryOrderId}')
                        .then((_) => reload())
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}

String _periodLabel(AppLocalizations l10n, PendingDeliveryPeriod period) =>
    switch (period) {
      PendingDeliveryPeriod.earlier => l10n.forDeliveryPeriodEarlier,
      PendingDeliveryPeriod.yesterday => l10n.forDeliveryPeriodYesterday,
      PendingDeliveryPeriod.today => l10n.forDeliveryPeriodToday,
      PendingDeliveryPeriod.tomorrow => l10n.forDeliveryPeriodTomorrow,
      PendingDeliveryPeriod.dayAfter => l10n.forDeliveryPeriodDayAfter,
      PendingDeliveryPeriod.later => l10n.forDeliveryPeriodLater,
    };

/// The filter panel: one single-select "Periodo", no "all" option (spec 063
/// C3, R5). Counts and dates come from the last successful load, so they stay
/// visible while a newly picked period loads; until the first load succeeds
/// the options carry their labels only.
class _PendingDeliveriesFiltersPanel extends ConsumerWidget {
  const _PendingDeliveriesFiltersPanel({required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final fmt = ref.watch(formattersProvider);
    final filter = PendingDeliveriesFilter.fromQuery(query);
    final summaries = {
      for (final s
          in ref.watch(lastPendingDeliverySummariesProvider) ??
              const <PendingDeliveryPeriodSummary>[])
        s.period: s,
    };

    String optionText(PendingDeliveryPeriod period) {
      final label = _periodLabel(l10n, period);
      final summary = summaries[period];
      if (summary == null) return label;
      final date = summary.date;
      return date == null
          ? l10n.forDeliveryPeriodOptionUndated(label, summary.total)
          : l10n.forDeliveryPeriodOptionDated(
              label,
              fmt.display.date(date),
              summary.total,
            );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rebuilt when the value changes: a dropdown reads its initial value
        // only once.
        KeyedSubtree(
          key: ValueKey(('period', filter.period)),
          child: DropdownButtonFormField<PendingDeliveryPeriod>(
            key: const Key('for_delivery_period_filter'),
            initialValue: filter.period,
            isExpanded: true,
            decoration: InputDecoration(labelText: l10n.forDeliveryPeriodLabel),
            items: [
              for (final period in PendingDeliveryPeriod.values)
                DropdownMenuItem(
                  value: period,
                  child: Text(optionText(period)),
                ),
            ],
            onChanged: (period) {
              if (period == null) return;
              // A new period always starts on page 1 (FR-007).
              context.go(
                PendingDeliveriesFilter(
                  period: period,
                ).toQuery().toUri(forDeliveryPath).toString(),
              );
            },
          ),
        ),
      ],
    );
  }
}
