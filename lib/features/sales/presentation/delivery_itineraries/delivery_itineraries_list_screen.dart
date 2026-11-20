import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/formatting/app_formatters.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/widgets/catalog_action_icons.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_bar.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_sheet.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/date_range_filter_chip.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_itinerary.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/delivery_itineraries_filter.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/delivery_itineraries_list_controller.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/itinerary_lookups.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/itinerary_pickers.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/itinerary_status_chip.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/new_itinerary_dialog.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payments_filter.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

const deliveryItinerariesPath = '/sales/delivery-itineraries';

/// A trip's own screen: `/sales/delivery-itineraries/{id}`.
String deliveryItineraryPath(int id) => '$deliveryItinerariesPath/$id';

/// Itinerarios: the trips, newest first (spec 075 US4, ui-contract "List
/// screen"). Gated by Delivery Itineraries (SystemObject 87) read.
///
/// A trip is a document, so a row has no Edit and its tap opens the trip's own
/// screen (constitution §VI, as the other logistics lists). There is no search
/// box, because the endpoint has none; the drawer filters by status, date,
/// vehicle, operator and dispatch warehouse. "Nuevo itinerario" needs create.
class DeliveryItinerariesListScreen extends ConsumerWidget {
  const DeliveryItinerariesListScreen({super.key, required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final access = ref.watch(accessControlProvider);
    final filter = DeliveryItinerariesFilter.fromQuery(query);
    final pageAsync = ref.watch(
      deliveryItinerariesListControllerProvider(filter),
    );
    final fmt = ref.watch(formattersProvider);
    final compact = LayoutBreakpoints.isCompact(context);
    final clearedPath = const ListQuery()
        .toUri(deliveryItinerariesPath)
        .toString();
    final facetsClearedPath = filter
        .cleared()
        .toQuery()
        .toUri(deliveryItinerariesPath)
        .toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.fieldGapVertical,
      children: [
        CatalogFilterBar(
          actions: [
            if (access.can(
              SystemObject.deliveryItineraries,
              AccessRight.create,
            ))
              FilledButton.icon(
                key: const Key('delivery_itineraries_new'),
                icon: Icon(CatalogAction.create.icon),
                label: Text(l10n.itineraryActionNew),
                onPressed: () async {
                  final id = await showNewItineraryDialog(context);
                  if (id != null && context.mounted) {
                    context.push(deliveryItineraryPath(id));
                  }
                },
              ),
          ],
          filters: [
            Badge.count(
              count: filter.activeFilterCount,
              isLabelVisible: filter.activeFilterCount > 0,
              child: IconButton.outlined(
                key: const Key('delivery_itineraries_filter_button'),
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
                        _ItinerariesFiltersPanel(query: query),
                  ),
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: CatalogListStateView<ItinerarySummary>(
            state: pageAsync,
            isFiltered: filter.isNarrowed,
            emptyMessage: l10n.itinerariesEmpty,
            clearFiltersLabel: l10n.clearFiltersButton,
            onClearFilters: () => context.go(clearedPath),
            retryLabel: l10n.retryButton,
            onRetry: () => ref.invalidate(
              deliveryItinerariesListControllerProvider(filter),
            ),
            onData: (page) => DataTableView<ItinerarySummary>(
              key: const Key('delivery_itineraries_table'),
              columns: compact
                  ? _compactColumns(l10n, fmt)
                  : _wideColumns(l10n, fmt),
              rows: page.items,
              pagination: page,
              onPageChanged: (pageIndex) => context.go(
                query
                    .copyWith(pageIndex: pageIndex)
                    .toUri(deliveryItinerariesPath)
                    .toString(),
              ),
              // A trip has no Edit and no View toggle: the row tap is the way
              // in (document reading, as 067-069).
              onRowTap: (t) => context.push(deliveryItineraryPath(t.id)),
            ),
          ),
        ),
      ],
    );
  }
}

/// A row's name: the server's, else the number, else "—" when none is set.
String _name(String? name, int? id) =>
    name ?? (id == null ? emptyValuePlaceholder : '#$id');

List<DataTableColumn<ItinerarySummary>> _wideColumns(
  AppLocalizations l10n,
  AppFormatters fmt,
) => [
  DataTableColumn.id(
    label: l10n.itineraryColumnNumber,
    size: ColumnSize.S,
    numeric: true,
    text: (t) => '${t.id}',
  ),
  DataTableColumn.timestamp(
    label: l10n.itineraryColumnDate,
    size: ColumnSize.S,
    text: (t) => fmt.display.date(t.date),
  ),
  DataTableColumn.text(
    label: l10n.itineraryColumnVehicle,
    size: ColumnSize.M,
    text: (t) => _name(t.vehicleName, t.vehicleId),
  ),
  DataTableColumn.text(
    label: l10n.itineraryColumnOperator,
    size: ColumnSize.M,
    text: (t) => _name(t.operatorName, t.vehicleOperatorId),
  ),
  DataTableColumn.text(
    label: l10n.itineraryColumnWarehouse,
    size: ColumnSize.M,
    text: (t) => _name(t.warehouseName, t.warehouseId),
  ),
  DataTableColumn(
    label: l10n.itineraryColumnStatus,
    size: ColumnSize.M,
    cellBuilder: (context, t) => ItineraryStatusChip(status: t.status),
  ),
  DataTableColumn.timestamp(
    label: l10n.itineraryColumnDeparture,
    size: ColumnSize.S,
    text: (t) => fmt.display.dateTime(t.departedAt),
  ),
  DataTableColumn.timestamp(
    label: l10n.itineraryColumnReturn,
    size: ColumnSize.S,
    text: (t) => fmt.display.dateTime(t.returnedAt),
  ),
];

/// Each row becomes two lines (wireframes "Compact tier"): the number and
/// date, then the vehicle and operator. The warehouse and the return time are
/// dropped; the trip screen shows them. The status is never truncated.
List<DataTableColumn<ItinerarySummary>> _compactColumns(
  AppLocalizations l10n,
  AppFormatters fmt,
) => [
  DataTableColumn(
    label: l10n.itineraryColumnNumber,
    size: ColumnSize.L,
    cellBuilder: (context, t) => Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${t.id} · ${fmt.display.date(t.date)}',
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          [
            _name(t.vehicleName, t.vehicleId),
            _name(t.operatorName, t.vehicleOperatorId),
            if (t.departedAt != null) fmt.display.dateTime(t.departedAt),
          ].join(' · '),
          style: Theme.of(context).textTheme.bodySmall,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  ),
  DataTableColumn(
    label: l10n.itineraryColumnStatus,
    size: ColumnSize.M,
    cellBuilder: (context, t) => ItineraryStatusChip(status: t.status),
  ),
];

/// The drawer's facets: status (one at a time, as the server takes one), the
/// date range, and the vehicle, operator and dispatch-warehouse pickers, each
/// shown only with read on its catalog (§IV). Each change writes the URL and
/// returns to the first page.
class _ItinerariesFiltersPanel extends ConsumerWidget {
  const _ItinerariesFiltersPanel({required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final access = ref.watch(accessControlProvider);
    bool canRead(SystemObject object) => access.can(object, AccessRight.read);
    final filter = DeliveryItinerariesFilter.fromQuery(query);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final titleStyle = theme.textTheme.titleSmall;

    void goTo(ListQuery updated) => context.go(
      updated.copyWith(pageIndex: 0).toUri(deliveryItinerariesPath).toString(),
    );

    final vehicleName =
        filter.vehicleId == null || !canRead(SystemObject.vehicle)
        ? null
        : ref.watch(vehicleFacetNameProvider(filter.vehicleId!)).value;
    final operatorName =
        filter.operatorId == null || !canRead(SystemObject.vehicleOperators)
        ? null
        : ref.watch(operatorFacetNameProvider(filter.operatorId!)).value;
    final warehouseName =
        filter.warehouseId == null || !canRead(SystemObject.warehouses)
        ? null
        : ref.watch(warehouseDisplayNameProvider(filter.warehouseId!)).value;

    Widget clearable(Key key, int? id, String facet, Widget picker) => Row(
      spacing: spacing.sm,
      children: [
        Expanded(child: picker),
        if (id != null)
          IconButton(
            key: key,
            icon: const Icon(Icons.close),
            tooltip: l10n.clearFiltersButton,
            onPressed: () => goTo(query.withFacet(facet, null)),
          ),
      ],
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.fieldGapVertical,
      children: [
        Text(l10n.itineraryFilterStatus, style: titleStyle),
        Wrap(
          spacing: spacing.sm,
          runSpacing: spacing.sm,
          children: [
            ChoiceChip(
              key: const Key('delivery_itineraries_status_all'),
              label: Text(l10n.itineraryFilterStatusAll),
              selected: filter.status == null,
              onSelected: (_) => goTo(query.withFacet('status', null)),
            ),
            for (final status in ItineraryStatus.values)
              ChoiceChip(
                key: Key('delivery_itineraries_status_${status.name}'),
                label: Text(itineraryStatusLabel(l10n, status)),
                selected: filter.status == status,
                onSelected: (_) =>
                    goTo(query.withFacet('status', status.value.toString())),
              ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: spacing.sm,
          children: [
            Text(l10n.itineraryFilterDate, style: titleStyle),
            DateRangeFilterChip(
              key: const Key('delivery_itineraries_date_filter'),
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
        if (canRead(SystemObject.vehicle))
          clearable(
            const Key('delivery_itineraries_vehicle_clear'),
            filter.vehicleId,
            'vehicle',
            ItineraryVehiclePicker(
              key: const Key('delivery_itineraries_vehicle_filter'),
              label: l10n.itineraryFilterVehicle,
              initialDisplayText: filter.vehicleId == null
                  ? l10n.itineraryFilterAny
                  : (vehicleName ?? '#${filter.vehicleId}'),
              onSelected: (v) =>
                  goTo(query.withFacet('vehicle', '${v.vehicleId}')),
            ),
          ),
        if (canRead(SystemObject.vehicleOperators))
          clearable(
            const Key('delivery_itineraries_operator_clear'),
            filter.operatorId,
            'operator',
            ItineraryOperatorPicker(
              key: const Key('delivery_itineraries_operator_filter'),
              label: l10n.itineraryFilterOperator,
              initialDisplayText: filter.operatorId == null
                  ? l10n.itineraryFilterAny
                  : (operatorName ?? '#${filter.operatorId}'),
              onSelected: (o) =>
                  goTo(query.withFacet('operator', '${o.vehicleOperatorId}')),
            ),
          ),
        if (canRead(SystemObject.warehouses))
          clearable(
            const Key('delivery_itineraries_warehouse_clear'),
            filter.warehouseId,
            'warehouse',
            ItineraryWarehousePicker(
              key: const Key('delivery_itineraries_warehouse_filter'),
              label: l10n.itineraryFilterWarehouse,
              initialDisplayText: filter.warehouseId == null
                  ? l10n.itineraryFilterAny
                  : (warehouseName ?? '#${filter.warehouseId}'),
              onSelected: (w) =>
                  goTo(query.withFacet('warehouse', '${w.warehouseId}')),
            ),
          ),
      ],
    );
  }
}
