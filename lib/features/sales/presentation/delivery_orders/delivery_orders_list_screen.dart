import 'dart:async';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/config/app_settings_provider.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/navigation/list_search_submit.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_bar.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_sheet.dart';
import 'package:mbe_ui/core/widgets/catalog_search_bar.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/date_range_filter_chip.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/facility_list_item.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_order.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_order_name_cells.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_order_status_chip.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_orders_filter.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_orders_list_controller.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payments_filter.dart';
import 'package:mbe_ui/features/sales/presentation/register_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

const deliveryOrdersPath = '/sales/delivery-orders';

/// Órdenes de entrega: the facility's delivery orders, newest first (spec
/// 061 US1, contracts C2). Gated by Delivery Orders (SystemObject 71) read.
///
/// A standard list screen (filter row, list, pagination) with no create
/// action: orders are created only in the POS. A delivery order is a
/// document, so a row carries no icons and its tap opens the detail screen.
class DeliveryOrdersListScreen extends ConsumerWidget {
  const DeliveryOrdersListScreen({super.key, required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;

    // No request at all for a user with no facility, administrators
    // included, as in Pedidos (spec Edge Cases).
    if (ref.watch(userFacilityIdProvider) == null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(spacing.screenMargin),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: spacing.sm,
            children: [
              Text(
                key: const Key('delivery_orders_no_facility'),
                l10n.deliveryOrdersNoFacilityTitle,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              Text(
                l10n.deliveryOrdersNoFacilityMessage,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final isAdministrator = ref.watch(accessControlProvider).isAdministrator;
    final filter = DeliveryOrdersFilter.fromQuery(
      query,
      isAdministrator: isAdministrator,
    );
    final pageAsync = ref.watch(deliveryOrdersListControllerProvider(filter));
    final fmt = ref.watch(formattersProvider);
    final compact = LayoutBreakpoints.isCompact(context);
    final clearedPath = const ListQuery().toUri(deliveryOrdersPath).toString();
    final facetsClearedPath = filter
        .cleared()
        .toQuery()
        .toUri(deliveryOrdersPath)
        .toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.fieldGapVertical,
      children: [
        CatalogFilterBar(
          search: CatalogSearchBar(
            key: const Key('delivery_orders_search'),
            label: l10n.deliveryOrdersSearchHint,
            searchTooltip: l10n.searchButtonTooltip,
            initialValue: filter.search ?? '',
            // The server's search matches a number only (spec Edge Cases),
            // so anything but digits is dropped from the term.
            // simplified: dropped on submit rather than refused while typing,
            // since CatalogSearchBar takes no input formatters; give it an
            // `inputFormatters` parameter and pass `digitsOnly` here.
            onSubmitted: (value) => submitCatalogSearch(
              context: context,
              query: query,
              path: deliveryOrdersPath,
              submitted: value.replaceAll(RegExp(r'\D'), ''),
              current: filter.search ?? '',
              refresh: () =>
                  ref.invalidate(deliveryOrdersListControllerProvider(filter)),
            ),
          ),
          filters: [
            Badge.count(
              count: filter.activeFilterCount,
              isLabelVisible: filter.activeFilterCount > 0,
              child: IconButton.outlined(
                key: const Key('delivery_orders_filter_button'),
                icon: const Icon(Icons.tune),
                tooltip: l10n.filtersTooltip,
                onPressed: () => showCatalogFilterSheet(
                  context,
                  title: l10n.filtersButton,
                  clearAllLabel: l10n.clearAllFilters,
                  applyLabel: l10n.applyFilters,
                  onClearAll: () => context.go(facetsClearedPath),
                  builder: (_) => CurrentListQueryBuilder(
                    builder: (context, query) =>
                        _DeliveryOrdersFiltersPanel(query: query),
                  ),
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: CatalogListStateView<DeliveryOrderSummary>(
            state: pageAsync,
            isFiltered: filter.isNarrowed,
            emptyMessage: l10n.deliveryOrdersEmpty,
            clearFiltersLabel: l10n.clearFiltersButton,
            onClearFilters: () => context.go(clearedPath),
            retryLabel: l10n.retryButton,
            onRetry: () =>
                ref.invalidate(deliveryOrdersListControllerProvider(filter)),
            onData: (page) => DataTableView<DeliveryOrderSummary>(
              key: const Key('delivery_orders_table'),
              columns: [
                DataTableColumn(
                  label: l10n.deliveryOrderColumnSerial,
                  size: ColumnSize.S,
                  cellBuilder: (context, o) => Text(
                    o.serial == null
                        ? l10n.deliveryOrderDraftFolio
                        : '${o.serial}',
                  ),
                ),
                DataTableColumn(
                  label: l10n.deliveryOrderColumnCustomer,
                  size: ColumnSize.L,
                  cellBuilder: (context, o) =>
                      DeliveryOrderCustomerName(customerId: o.customerId),
                ),
                if (!compact)
                  DataTableColumn(
                    label: l10n.deliveryOrderColumnType,
                    size: ColumnSize.S,
                    cellBuilder: (context, o) =>
                        Text(deliveryOrderTypeLabel(l10n, o.type)),
                  ),
                DataTableColumn(
                  label: l10n.deliveryOrderColumnScheduled,
                  size: ColumnSize.S,
                  cellBuilder: (context, o) => Text(fmt.display.date(o.date)),
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
                    ),
                  ),
                if (!compact)
                  DataTableColumn.text(
                    label: l10n.deliveryOrderColumnSalesOrders,
                    size: ColumnSize.S,
                    text: (o) => o.salesOrderIds.join(', '),
                  ),
                DataTableColumn(
                  label: l10n.deliveryOrderColumnStatus,
                  size: ColumnSize.M,
                  cellBuilder: (context, o) =>
                      DeliveryOrderStatusChip(status: o.status),
                ),
              ],
              rows: page.items,
              pagination: page,
              onPageChanged: (pageIndex) => context.go(
                query
                    .copyWith(pageIndex: pageIndex)
                    .toUri(deliveryOrdersPath)
                    .toString(),
              ),
              // A delivery order has no row icons: the tap is the way in.
              onRowTap: (o) => context.push('$deliveryOrdersPath/${o.id}'),
            ),
          ),
        ),
      ],
    );
  }
}

/// The drawer's facets (contracts C3): status, type, scheduled date,
/// customer (with Customers read), sales order and facility (administrators
/// only). Each change writes the URL and returns to the first page.
class _DeliveryOrdersFiltersPanel extends ConsumerWidget {
  const _DeliveryOrdersFiltersPanel({required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final access = ref.watch(accessControlProvider);
    final isAdministrator = access.isAdministrator;
    final canReadCustomers = access.can(
      SystemObject.customers,
      AccessRight.read,
    );
    final filter = DeliveryOrdersFilter.fromQuery(
      query,
      isAdministrator: isAdministrator,
    );
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final titleStyle = theme.textTheme.titleSmall;

    void goTo(ListQuery updated) => context.go(
      updated.copyWith(pageIndex: 0).toUri(deliveryOrdersPath).toString(),
    );

    final customerName = filter.customerId == null || !canReadCustomers
        ? null
        : ref.watch(customerDisplayNameProvider(filter.customerId!)).value;
    final facilityName = filter.facilityId == null || !isAdministrator
        ? null
        : ref.watch(facilityDisplayNameProvider(filter.facilityId!)).value;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.fieldGapVertical,
      children: [
        // Rebuilt when the value changes: a dropdown reads its initial value
        // only once.
        KeyedSubtree(
          key: ValueKey(('status', filter.status)),
          child: DropdownButtonFormField<DeliveryOrderStatus?>(
            key: const Key('delivery_orders_status_filter'),
            initialValue: filter.status,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: l10n.deliveryOrderFilterStatus,
            ),
            items: [
              DropdownMenuItem<DeliveryOrderStatus?>(
                value: null,
                child: Text(l10n.deliveryOrderFilterAllStatuses),
              ),
              for (final status in DeliveryOrderStatus.values)
                DropdownMenuItem<DeliveryOrderStatus?>(
                  value: status,
                  child: Text(deliveryOrderStatusLabel(l10n, status)),
                ),
            ],
            onChanged: (status) =>
                goTo(query.withFacet('status', status?.value.toString())),
          ),
        ),
        KeyedSubtree(
          key: ValueKey(('type', filter.type)),
          child: DropdownButtonFormField<FulfillmentType?>(
            key: const Key('delivery_orders_type_filter'),
            initialValue: filter.type,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: l10n.deliveryOrderFilterType,
            ),
            items: [
              DropdownMenuItem<FulfillmentType?>(
                value: null,
                child: Text(l10n.deliveryOrderFilterAllTypes),
              ),
              for (final type in FulfillmentType.values)
                DropdownMenuItem<FulfillmentType?>(
                  value: type,
                  child: Text(deliveryOrderTypeLabel(l10n, type)),
                ),
            ],
            onChanged: (type) =>
                goTo(query.withFacet('type', type?.value.toString())),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: spacing.sm,
          children: [
            Text(l10n.deliveryOrderFilterScheduled, style: titleStyle),
            DateRangeFilterChip(
              key: const Key('delivery_orders_date_filter'),
              from: filter.dateFrom,
              to: filter.dateTo,
              isToday: false,
              onChanged: (range) => goTo(
                query
                    .withFacet('from', encodePaymentsDateFacet(range.start))
                    .withFacet('to', encodePaymentsDateFacet(range.end)),
              ),
              onClear: () =>
                  goTo(query.withFacet('from', null).withFacet('to', null)),
            ),
          ],
        ),
        if (canReadCustomers)
          CatalogEntityPicker<CustomerListItem>(
            key: const Key('delivery_orders_customer_filter'),
            label: l10n.deliveryOrderFilterCustomer,
            displayStringForOption: (c) => '${c.code} — ${c.name}',
            optionsBuilder: (search) async {
              final result = await ref
                  .read(customerRepositoryProvider)
                  .list(search: search.isEmpty ? null : search, limit: 10);
              return result.items;
            },
            onSelected: (c) =>
                goTo(query.withFacet('customer', '${c.customerId}')),
            initialDisplayText: customerName ?? filter.customerId?.toString(),
          ),
        _SalesOrderFilterField(
          initialValue: filter.salesOrderId?.toString(),
          label: l10n.deliveryOrderFilterSalesOrder,
          hint: l10n.deliveryOrderFilterSalesOrderHint,
          onApply: (value) {
            final order = int.tryParse(value);
            if (value.isEmpty || order != null) {
              goTo(query.withFacet('order', order?.toString()));
            }
          },
        ),
        if (isAdministrator)
          Row(
            spacing: spacing.sm,
            children: [
              Expanded(
                child: CatalogEntityPicker<FacilityListItem>(
                  key: const Key('delivery_orders_facility_filter'),
                  label: l10n.deliveryOrderFilterFacility,
                  displayStringForOption: (f) => f.name,
                  optionsBuilder: (search) async {
                    final result = await ref
                        .read(facilityRepositoryProvider)
                        .list(search: search.isEmpty ? null : search);
                    return result.items;
                  },
                  onSelected: (f) =>
                      goTo(query.withFacet('facility', '${f.facilityId}')),
                  // Unset is the server's default, the caller's own facility.
                  initialDisplayText: filter.facilityId == null
                      ? l10n.deliveryOrderFilterMyFacility
                      : (facilityName ?? '${filter.facilityId}'),
                ),
              ),
              if (filter.facilityId != null)
                TextButton(
                  key: const Key('delivery_orders_facility_mine'),
                  onPressed: () => goTo(query.withFacet('facility', null)),
                  child: Text(l10n.deliveryOrderFilterMyFacility),
                ),
            ],
          ),
      ],
    );
  }
}

/// The sales-order filter: applies after the typing pause
/// (`inputDebounceProvider`) and on submit, never once per digit.
class _SalesOrderFilterField extends ConsumerStatefulWidget {
  const _SalesOrderFilterField({
    required this.initialValue,
    required this.label,
    required this.hint,
    required this.onApply,
  });

  final String? initialValue;
  final String label;
  final String hint;
  final ValueChanged<String> onApply;

  @override
  ConsumerState<_SalesOrderFilterField> createState() =>
      _SalesOrderFilterFieldState();
}

class _SalesOrderFilterFieldState
    extends ConsumerState<_SalesOrderFilterField> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _apply(String value) {
    _debounce?.cancel();
    widget.onApply(value);
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: const Key('delivery_orders_sales_order_filter'),
      initialValue: widget.initialValue,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
      ),
      onChanged: (value) {
        _debounce?.cancel();
        _debounce = Timer(ref.read(inputDebounceProvider), () => _apply(value));
      },
      onFieldSubmitted: _apply,
    );
  }
}
