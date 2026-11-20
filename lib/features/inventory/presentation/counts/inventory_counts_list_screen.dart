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
import 'package:mbe_ui/core/widgets/record_id_text.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_count.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';
import 'package:mbe_ui/features/inventory/presentation/counts/inventory_count_status_chip.dart';
import 'package:mbe_ui/features/inventory/presentation/counts/inventory_counts_list_controller.dart';
import 'package:mbe_ui/features/inventory/presentation/counts/new_count_dialog.dart';
import 'package:mbe_ui/features/inventory/presentation/shared/inventory_documents_filter.dart';
import 'package:mbe_ui/features/inventory/presentation/shared/inventory_name_cells.dart';
import 'package:mbe_ui/features/inventory/presentation/shared/inventory_warehouse_options.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

const inventoryCountsPath = '/inventory/counts';

/// Conteos físicos: the counts the server grants the user, newest first
/// (spec 070 US1, contracts/ui-contract.md "List screen"). Gated by
/// PhysicalCountAdjustment (SystemObject 74) read.
///
/// A count is a document, so a row has no icons and its tap opens the
/// detail screen (§VI document reading). There is no search box: the
/// endpoint has none.
class InventoryCountsListScreen extends ConsumerWidget {
  const InventoryCountsListScreen({super.key, required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final filter = InventoryDocumentsFilter.fromQuery(query);
    final pageAsync = ref.watch(inventoryCountsListControllerProvider(filter));
    final fmt = ref.watch(formattersProvider);
    final access = ref.watch(accessControlProvider);
    // PhysicalCountAdjustment (74) create, plus Warehouses (4) read for the
    // dialog's warehouse picker.
    final canCreate =
        access.can(SystemObject.physicalCountAdjustment, AccessRight.create) &&
        access.can(SystemObject.warehouses, AccessRight.read);
    final compact = LayoutBreakpoints.isCompact(context);
    final clearedPath = const ListQuery().toUri(inventoryCountsPath).toString();
    final facetsClearedPath = filter
        .cleared()
        .toQuery()
        .toUri(inventoryCountsPath)
        .toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.fieldGapVertical,
      children: [
        // The bar lays out its actions first and its filters last.
        CatalogFilterBar(
          filters: [
            Badge.count(
              count: filter.activeFilterCount,
              isLabelVisible: filter.activeFilterCount > 0,
              child: IconButton.outlined(
                key: const Key('inventory_counts_filter_button'),
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
                        _InventoryCountsFiltersPanel(query: query),
                  ),
                ),
              ),
            ),
          ],
          actions: [
            if (canCreate)
              FilledButton.icon(
                key: const Key('inventory_counts_new_button'),
                onPressed: () async {
                  final id = await showNewCountDialog(context);
                  if (id != null && context.mounted) {
                    context.push('$inventoryCountsPath/$id');
                  }
                },
                icon: const Icon(Icons.add),
                label: Text(l10n.inventoryCountActionNew),
              ),
          ],
        ),
        Expanded(
          child: CatalogListStateView<InventoryCountSummary>(
            state: pageAsync,
            isFiltered: filter.isNarrowed,
            emptyMessage: l10n.inventoryCountListEmpty,
            clearFiltersLabel: l10n.clearFiltersButton,
            onClearFilters: () => context.go(clearedPath),
            retryLabel: l10n.retryButton,
            onRetry: () =>
                ref.invalidate(inventoryCountsListControllerProvider(filter)),
            onData: (page) => DataTableView<InventoryCountSummary>(
              key: const Key('inventory_counts_table'),
              columns: [
                DataTableColumn(
                  label: l10n.inventoryCountColFolio,
                  size: ColumnSize.S,
                  numeric: true,
                  cellBuilder: (context, r) => RecordIdText(
                    r.serial == null
                        ? l10n.inventoryCountDraftFolio('${r.id}')
                        : '${r.serial}',
                    key: Key('inventory_count_folio_${r.id}'),
                    textAlign: TextAlign.end,
                  ),
                ),
                // Count summaries carry ids only, so the names go through
                // the id lookup (research R12).
                DataTableColumn(
                  label: l10n.inventoryCountColWarehouse,
                  size: ColumnSize.M,
                  cellBuilder: (context, r) => InventoryWarehouseName(
                    warehouseId: r.warehouseId,
                    name: null,
                  ),
                ),
                if (!compact)
                  DataTableColumn(
                    label: l10n.inventoryCountColFacility,
                    size: ColumnSize.M,
                    cellBuilder: (context, r) => InventoryFacilityName(
                      facilityId: r.facilityId,
                      name: null,
                    ),
                  ),
                DataTableColumn(
                  label: l10n.inventoryCountColStatus,
                  size: ColumnSize.S,
                  cellBuilder: (context, r) =>
                      InventoryCountStatusChip(status: r.status),
                ),
                if (!compact)
                  DataTableColumn(
                    label: l10n.inventoryCountColCreatedBy,
                    size: ColumnSize.M,
                    cellBuilder: (context, r) => InventoryEmployeeName(
                      employeeId: r.creatorId,
                      name: null,
                    ),
                  ),
                DataTableColumn.timestamp(
                  label: l10n.inventoryCountColDate,
                  size: ColumnSize.S,
                  text: (r) => fmt.display.dateTime(r.createdAt),
                ),
              ],
              rows: page.items,
              pagination: page,
              onPageChanged: (pageIndex) => context.go(
                query
                    .copyWith(pageIndex: pageIndex)
                    .toUri(inventoryCountsPath)
                    .toString(),
              ),
              onRowTap: (r) => context.push('$inventoryCountsPath/${r.id}'),
            ),
          ),
        ),
      ],
    );
  }
}

/// The drawer's facets (spec 070 ui-contract): Estado, and Almacén with
/// Warehouses (4) read. Each change writes the URL and returns to the first
/// page.
class _InventoryCountsFiltersPanel extends ConsumerWidget {
  const _InventoryCountsFiltersPanel({required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Warehouses (4) read: the picker lists warehouses.
    final canReadWarehouses = ref
        .watch(accessControlProvider)
        .can(SystemObject.warehouses, AccessRight.read);
    final filter = InventoryDocumentsFilter.fromQuery(query);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final warehouseId = filter.warehouseId;
    final warehouseName = warehouseId == null || !canReadWarehouses
        ? null
        : ref.watch(warehouseDisplayNameProvider(warehouseId)).value;

    void goTo(ListQuery updated) => context.go(
      updated.copyWith(pageIndex: 0).toUri(inventoryCountsPath).toString(),
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
              l10n.inventoryCountFilterStatus,
              style: theme.textTheme.titleSmall,
            ),
            Wrap(
              key: const Key('inventory_counts_status_filter'),
              spacing: spacing.sm,
              runSpacing: spacing.sm,
              children: [
                ChoiceChip(
                  key: const Key('inventory_counts_status_all'),
                  label: Text(l10n.inventoryCountFilterAll),
                  selected: filter.status == null,
                  onSelected: (_) => goTo(query.withFacet('status', null)),
                ),
                for (final status in InventoryDocumentStatus.values)
                  ChoiceChip(
                    key: Key('inventory_counts_status_${status.name}'),
                    label: Text(inventoryCountStatusLabel(l10n, status)),
                    selected: filter.status == status,
                    // Tapping the selected chip again clears the facet.
                    onSelected: (selected) => goTo(
                      query.withFacet('status', selected ? status.name : null),
                    ),
                  ),
              ],
            ),
          ],
        ),
        if (canReadWarehouses)
          CatalogEntityPicker<Warehouse>(
            key: const Key('inventory_counts_warehouse_filter'),
            label: l10n.inventoryCountFilterWarehouse,
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
