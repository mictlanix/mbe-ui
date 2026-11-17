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
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_bar.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_sheet.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_transfer.dart';
import 'package:mbe_ui/features/inventory/presentation/shared/inventory_name_cells.dart';
import 'package:mbe_ui/features/inventory/presentation/shared/inventory_warehouse_options.dart';
import 'package:mbe_ui/features/inventory/presentation/transfers/in_transit_screen.dart';
import 'package:mbe_ui/features/inventory/presentation/transfers/inventory_transfer_status_chip.dart';
import 'package:mbe_ui/features/inventory/presentation/transfers/inventory_transfers_filter.dart';
import 'package:mbe_ui/features/inventory/presentation/transfers/inventory_transfers_list_controller.dart';
import 'package:mbe_ui/features/inventory/presentation/transfers/new_transfer_dialog.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

const inventoryTransfersPath = '/inventory/transfers';

/// Traspasos: the transfers the server grants the user, newest first (spec
/// 069 US1, contracts/ui-contract.md "List screen"). Gated by
/// InventoryTransfers (SystemObject 17) read.
///
/// A transfer is a document, so a row has no icons and its tap opens the
/// detail screen (§VI document reading). There is no search box: the
/// endpoint has none.
class InventoryTransfersListScreen extends ConsumerWidget {
  const InventoryTransfersListScreen({super.key, required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final access = ref.watch(accessControlProvider);
    // InventoryTransfers (17) create, and Warehouses (4) read for the
    // dialog's warehouse pickers.
    final canCreate =
        access.can(SystemObject.inventoryTransfers, AccessRight.create) &&
        access.can(SystemObject.warehouses, AccessRight.read);
    final filter = InventoryTransfersFilter.fromQuery(query);
    final pageAsync = ref.watch(
      inventoryTransfersListControllerProvider(filter),
    );
    final fmt = ref.watch(formattersProvider);
    final compact = LayoutBreakpoints.isCompact(context);
    final clearedPath = const ListQuery()
        .toUri(inventoryTransfersPath)
        .toString();
    final facetsClearedPath = filter
        .cleared()
        .toQuery()
        .toUri(inventoryTransfersPath)
        .toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.fieldGapVertical,
      children: [
        CatalogFilterBar(
          filters: [
            Badge.count(
              count: filter.activeCount,
              isLabelVisible: filter.activeCount > 0,
              child: IconButton.outlined(
                key: const Key('inventory_transfers_filter_button'),
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
                        _InventoryTransfersFiltersPanel(query: query),
                  ),
                ),
              ),
            ),
          ],
          actions: [
            // Anyone who can see the list can open En tránsito (read on 17).
            OutlinedButton.icon(
              key: const Key('inventory_transfers_in_transit_button'),
              onPressed: () => context.push(inTransitPath),
              icon: const Icon(Icons.local_shipping_outlined),
              label: Text(l10n.inventoryTransferInTransitAction),
            ),
            if (canCreate)
              FilledButton.icon(
                key: const Key('inventory_transfers_new_button'),
                onPressed: () async {
                  final id = await showNewTransferDialog(context);
                  if (id != null && context.mounted) {
                    context.push('$inventoryTransfersPath/$id');
                  }
                },
                icon: const Icon(Icons.add),
                label: Text(l10n.inventoryTransferNewAction),
              ),
          ],
        ),
        Expanded(
          child: CatalogListStateView<InventoryTransferSummary>(
            state: pageAsync,
            isFiltered: filter.isNarrowed,
            emptyMessage: l10n.inventoryTransferEmpty,
            clearFiltersLabel: l10n.clearFiltersButton,
            onClearFilters: () => context.go(clearedPath),
            retryLabel: l10n.retryButton,
            onRetry: () => ref.invalidate(
              inventoryTransfersListControllerProvider(filter),
            ),
            onData: (page) => DataTableView<InventoryTransferSummary>(
              key: const Key('inventory_transfers_table'),
              columns: [
                DataTableColumn(
                  label: l10n.inventoryTransferColFolio,
                  size: ColumnSize.S,
                  numeric: true,
                  cellBuilder: (context, r) => Text(
                    r.serial == null
                        ? l10n.inventoryDocumentDraftFolio('${r.id}')
                        : '${r.serial}',
                    key: Key('inventory_transfer_folio_${r.id}'),
                    textAlign: TextAlign.end,
                  ),
                ),
                DataTableColumn(
                  label: l10n.inventoryTransferColSource,
                  size: ColumnSize.M,
                  cellBuilder: (context, r) => InventoryWarehouseName(
                    warehouseId: r.warehouseId,
                    name: r.warehouseName,
                  ),
                ),
                DataTableColumn(
                  label: l10n.inventoryTransferColDestination,
                  size: ColumnSize.M,
                  cellBuilder: (context, r) => InventoryWarehouseName(
                    warehouseId: r.warehouseToId,
                    name: r.warehouseToName,
                  ),
                ),
                if (!compact)
                  DataTableColumn(
                    label: l10n.inventoryTransferColFacility,
                    size: ColumnSize.M,
                    cellBuilder: (context, r) => InventoryFacilityName(
                      facilityId: r.facilityId,
                      name: r.facilityName,
                    ),
                  ),
                DataTableColumn(
                  label: l10n.inventoryTransferColStatus,
                  size: ColumnSize.S,
                  cellBuilder: (context, r) =>
                      InventoryTransferStatusChip(status: r.status),
                ),
                if (!compact)
                  DataTableColumn(
                    label: l10n.inventoryTransferColCreator,
                    size: ColumnSize.M,
                    cellBuilder: (context, r) => InventoryEmployeeName(
                      employeeId: r.creatorId,
                      name: r.creatorName,
                    ),
                  ),
                DataTableColumn(
                  label: l10n.inventoryTransferColDate,
                  size: ColumnSize.S,
                  cellBuilder: (context, r) =>
                      Text(fmt.display.dateTime(r.createdAt)),
                ),
              ],
              rows: page.items,
              pagination: page,
              onPageChanged: (pageIndex) => context.go(
                query
                    .copyWith(pageIndex: pageIndex)
                    .toUri(inventoryTransfersPath)
                    .toString(),
              ),
              onRowTap: (r) => context.push('$inventoryTransfersPath/${r.id}'),
            ),
          ),
        ),
      ],
    );
  }
}

/// The drawer's facets (spec 069 ui-contract): Estado, and Almacén (origen o
/// destino) with Warehouses (4) read. Each change writes the URL and returns
/// to the first page.
class _InventoryTransfersFiltersPanel extends ConsumerWidget {
  const _InventoryTransfersFiltersPanel({required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Warehouses (4) read: the picker lists warehouses.
    final canReadWarehouses = ref
        .watch(accessControlProvider)
        .can(SystemObject.warehouses, AccessRight.read);
    final filter = InventoryTransfersFilter.fromQuery(query);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final warehouseId = filter.warehouseId;
    final warehouseName = warehouseId == null || !canReadWarehouses
        ? null
        : ref.watch(warehouseDisplayNameProvider(warehouseId)).value;

    void goTo(ListQuery updated) => context.go(
      updated.copyWith(pageIndex: 0).toUri(inventoryTransfersPath).toString(),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.fieldGapVertical,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: spacing.sm,
          children: [
            Text(
              l10n.inventoryTransferFacetStatus,
              style: theme.textTheme.titleSmall,
            ),
            Wrap(
              key: const Key('inventory_transfers_status_filter'),
              spacing: spacing.sm,
              runSpacing: spacing.sm,
              children: [
                ChoiceChip(
                  key: const Key('inventory_transfers_status_all'),
                  label: Text(l10n.inventoryTransferFacetAll),
                  selected: filter.status == null,
                  onSelected: (_) => goTo(query.withFacet('status', null)),
                ),
                for (final status in InventoryTransferStatus.values)
                  ChoiceChip(
                    key: Key('inventory_transfers_status_${status.name}'),
                    label: Text(inventoryTransferStatusLabel(l10n, status)),
                    selected: filter.status == status,
                    // Tapping the selected chip again clears the facet.
                    onSelected: (selected) => goTo(
                      selected
                          ? query.withFacet(
                              'status',
                              (filter.copyWith(
                                status: status,
                              )).toQuery().facet('status'),
                            )
                          : query.withFacet('status', null),
                    ),
                  ),
              ],
            ),
          ],
        ),
        if (canReadWarehouses)
          CatalogEntityPicker<Warehouse>(
            key: const Key('inventory_transfers_warehouse_filter'),
            label: l10n.inventoryTransferFacetWarehouse,
            displayStringForOption: (w) => w.name,
            optionSubtitle: (w) => w.facilityName,
            optionsBuilder: (search) => inventoryFilterWarehouseOptions(
              ref.read(warehouseRepositoryProvider),
              search,
            ),
            onSelected: (w) =>
                goTo(query.withFacet('warehouse', '${w.warehouseId}')),
            initialDisplayText:
                warehouseName ?? (warehouseId == null ? null : '#$warehouseId'),
          ),
      ],
    );
  }
}
