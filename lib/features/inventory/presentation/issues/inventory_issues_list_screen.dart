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
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_issue.dart';
import 'package:mbe_ui/features/inventory/presentation/shared/inventory_document_status_chip.dart';
import 'package:mbe_ui/features/inventory/presentation/shared/inventory_documents_filter.dart';
import 'package:mbe_ui/features/inventory/presentation/issues/inventory_issues_list_controller.dart';
import 'package:mbe_ui/features/inventory/presentation/issues/new_issue_dialog.dart';
import 'package:mbe_ui/features/inventory/presentation/shared/inventory_name_cells.dart';
import 'package:mbe_ui/features/inventory/presentation/shared/inventory_warehouse_options.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

const inventoryIssuesPath = '/inventory/issues';

/// Salidas de almacén: the issues the server grants the user, newest
/// first (spec 068 US1, contracts/ui-contract.md "List screen"). Gated by
/// InventoryIssues (SystemObject 16) read.
///
/// An issue is a document, so a row has no icons and its tap opens the
/// detail screen (§VI document reading). There is no search box: the
/// endpoint has none (FR-003).
class InventoryIssuesListScreen extends ConsumerWidget {
  const InventoryIssuesListScreen({super.key, required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final access = ref.watch(accessControlProvider);
    // InventoryIssues (16) create, and Warehouses (4) read for the
    // dialog's warehouse picker (FR-005, FR-016).
    final canCreate =
        access.can(SystemObject.inventoryIssues, AccessRight.create) &&
        access.can(SystemObject.warehouses, AccessRight.read);
    final filter = InventoryDocumentsFilter.fromQuery(query);
    final pageAsync = ref.watch(inventoryIssuesListControllerProvider(filter));
    final fmt = ref.watch(formattersProvider);
    final compact = LayoutBreakpoints.isCompact(context);
    final clearedPath = const ListQuery().toUri(inventoryIssuesPath).toString();
    final facetsClearedPath = filter
        .cleared()
        .toQuery()
        .toUri(inventoryIssuesPath)
        .toString();

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
                key: const Key('inventory_issues_filter_button'),
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
                        _InventoryIssuesFiltersPanel(query: query),
                  ),
                ),
              ),
            ),
          ],
          actions: [
            if (canCreate)
              FilledButton.icon(
                key: const Key('inventory_issues_new_button'),
                onPressed: () async {
                  final id = await showNewIssueDialog(context);
                  if (id != null && context.mounted) {
                    context.push('$inventoryIssuesPath/$id');
                  }
                },
                icon: const Icon(Icons.add),
                label: Text(l10n.inventoryIssueNewAction),
              ),
          ],
        ),
        Expanded(
          child: CatalogListStateView<InventoryIssueSummary>(
            state: pageAsync,
            isFiltered: filter.isNarrowed,
            emptyMessage: l10n.inventoryIssueEmpty,
            clearFiltersLabel: l10n.clearFiltersButton,
            onClearFilters: () => context.go(clearedPath),
            retryLabel: l10n.retryButton,
            onRetry: () =>
                ref.invalidate(inventoryIssuesListControllerProvider(filter)),
            onData: (page) => DataTableView<InventoryIssueSummary>(
              key: const Key('inventory_issues_table'),
              columns: [
                DataTableColumn(
                  label: l10n.inventoryIssueColFolio,
                  size: ColumnSize.S,
                  numeric: true,
                  cellBuilder: (context, r) => RecordIdText(
                    r.serial == null
                        ? l10n.inventoryDocumentDraftFolio('${r.id}')
                        : '${r.serial}',
                    key: Key('inventory_issue_folio_${r.id}'),
                    textAlign: TextAlign.end,
                  ),
                ),
                DataTableColumn(
                  label: l10n.inventoryIssueColWarehouse,
                  size: ColumnSize.M,
                  cellBuilder: (context, r) => InventoryWarehouseName(
                    warehouseId: r.warehouseId,
                    name: r.warehouseName,
                  ),
                ),
                if (!compact)
                  DataTableColumn(
                    label: l10n.inventoryIssueColFacility,
                    size: ColumnSize.M,
                    cellBuilder: (context, r) => InventoryFacilityName(
                      facilityId: r.facilityId,
                      name: r.facilityName,
                    ),
                  ),
                DataTableColumn(
                  label: l10n.inventoryIssueColStatus,
                  size: ColumnSize.S,
                  cellBuilder: (context, r) =>
                      InventoryDocumentStatusChip(status: r.status),
                ),
                if (!compact)
                  DataTableColumn(
                    label: l10n.inventoryIssueColCreator,
                    size: ColumnSize.M,
                    cellBuilder: (context, r) => InventoryEmployeeName(
                      employeeId: r.creatorId,
                      name: r.creatorName,
                    ),
                  ),
                DataTableColumn.timestamp(
                  label: l10n.inventoryIssueColDate,
                  size: ColumnSize.S,
                  text: (r) => fmt.display.dateTime(r.createdAt),
                ),
              ],
              rows: page.items,
              pagination: page,
              onPageChanged: (pageIndex) => context.go(
                query
                    .copyWith(pageIndex: pageIndex)
                    .toUri(inventoryIssuesPath)
                    .toString(),
              ),
              onRowTap: (r) => context.push('$inventoryIssuesPath/${r.id}'),
            ),
          ),
        ),
      ],
    );
  }
}

/// The drawer's facets (spec 068 ui-contract): Estado, and Almacén with Warehouses
/// (4) read. Each change writes the URL and returns to the first page.
class _InventoryIssuesFiltersPanel extends ConsumerWidget {
  const _InventoryIssuesFiltersPanel({required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Warehouses (4) read: the picker lists warehouses (FR-016).
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
      updated.copyWith(pageIndex: 0).toUri(inventoryIssuesPath).toString(),
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
              l10n.inventoryIssueFacetStatus,
              style: theme.textTheme.titleSmall,
            ),
            Wrap(
              key: const Key('inventory_issues_status_filter'),
              spacing: spacing.sm,
              runSpacing: spacing.sm,
              children: [
                ChoiceChip(
                  key: const Key('inventory_issues_status_all'),
                  label: Text(l10n.inventoryIssueFacetAll),
                  selected: filter.status == null,
                  onSelected: (_) => goTo(query.withFacet('status', null)),
                ),
                for (final status in InventoryDocumentStatus.values)
                  ChoiceChip(
                    key: Key('inventory_issues_status_${status.name}'),
                    label: Text(inventoryDocumentStatusLabel(l10n, status)),
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
            key: const Key('inventory_issues_warehouse_filter'),
            label: l10n.inventoryIssueFacetWarehouse,
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
