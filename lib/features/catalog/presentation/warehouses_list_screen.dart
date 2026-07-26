import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/widgets/catalog_action_icons.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_bar.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_sheet.dart';
import 'package:mbe_ui/core/widgets/catalog_search_bar.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/entity_status_controls.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/facility_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';
import 'package:mbe_ui/features/catalog/presentation/warehouses_list_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

const _warehousesPath = '/warehouses';

/// Warehouses catalog list screen (FR-001, FR-002, FR-003, US1). Gated by
/// `can(SystemObject.warehouses, AccessRight.read)` in the router. Ships a
/// filter drawer (facility picker + status) since the list endpoint exposes
/// both facets, per constitution §VI.
///
/// [query] is decoded from the route by the router builder
/// (017-ui-consistency-filters FR-017) — the URL is this screen's only
/// source of view state; there is no local filter notifier.
class WarehousesListScreen extends ConsumerWidget {
  const WarehousesListScreen({super.key, required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = WarehouseFilter.fromQuery(query);
    final pageAsync = ref.watch(warehousesListControllerProvider(filter));
    final access = ref.watch(accessControlProvider);
    final canCreate = access.can(SystemObject.warehouses, AccessRight.create);
    final canUpdate = access.can(SystemObject.warehouses, AccessRight.update);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: CatalogFilterBar(
            search: CatalogSearchBar(
              key: const Key('warehouses_search_field'),
              label: l10n.warehousesSearchLabel,
              searchTooltip: l10n.searchButtonTooltip,
              initialValue: filter.search,
              onSubmitted: (value) => context.go(
                query
                    .copyWith(search: value, pageIndex: 0)
                    .toUri(_warehousesPath)
                    .toString(),
              ),
            ),
            actions: [
              if (canCreate)
                FilledButton.icon(
                  key: const Key('new_warehouse_button'),
                  icon: Icon(CatalogAction.create.icon),
                  label: Text(l10n.newWarehouseTooltip),
                  onPressed: () => context.push('/warehouses/new'),
                ),
            ],
            filters: [
              Badge.count(
                count: filter.activeFilterCount,
                isLabelVisible: filter.hasActiveFilters,
                child: IconButton.outlined(
                  key: const Key('warehouses_filter_button'),
                  icon: const Icon(Icons.tune),
                  tooltip: l10n.filtersTooltip,
                  onPressed: () => showCatalogFilterSheet(
                    context,
                    title: l10n.filtersButton,
                    clearAllLabel: l10n.clearAllFilters,
                    applyLabel: l10n.applyFilters,
                    onClearAll: () => context.go(_warehousesPath),
                    builder: (_) => CurrentListQueryBuilder(
                      builder: (context, query) =>
                          _WarehouseFiltersPanel(query: query),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: CatalogListStateView<Warehouse>(
            state: pageAsync,
            isFiltered: query.isFiltered,
            emptyMessage: l10n.noWarehousesFound,
            createLabel: canCreate ? l10n.newWarehouseTooltip : null,
            onCreate: canCreate ? () => context.push('/warehouses/new') : null,
            clearFiltersLabel: l10n.clearFiltersButton,
            onClearFilters: () => context.go(_warehousesPath),
            retryLabel: l10n.retryButton,
            onRetry: () =>
                ref.invalidate(warehousesListControllerProvider(filter)),
            onData: (page) => DataTableView<Warehouse>(
              key: const Key('warehouses_table'),
              columns: [
                DataTableColumn.text(
                  label: l10n.columnFacility,
                  text: (w) => w.facilityDisplayName(l10n.unknownFacilityLabel),
                  size: ColumnSize.M,
                ),
                DataTableColumn.text(
                  label: l10n.columnCode,
                  text: (w) => w.code,
                  size: ColumnSize.S,
                ),
                DataTableColumn.text(
                  label: l10n.columnName,
                  text: (w) => w.name,
                  size: ColumnSize.L,
                ),
                DataTableColumn(
                  label: l10n.columnStatus,
                  fixedWidth: 130,
                  cellBuilder: (context, w) =>
                      EntityStatusCell(status: w.status),
                ),
              ],
              rows: page.items,
              pagination: page,
              onPageChanged: (pageIndex) => context.go(
                query
                    .copyWith(pageIndex: pageIndex)
                    .toUri(_warehousesPath)
                    .toString(),
              ),
              onRowTap: (w) =>
                  context.push('/warehouses/${w.warehouseId}?view=true'),
              rowActionsBuilder: (context, w) => buildCatalogRowActions(
                editTooltip: l10n.editActionTooltip,
                onEdit: canUpdate
                    ? () => context.push('/warehouses/${w.warehouseId}')
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The Warehouses catalog's facet filters (facility picker + status),
/// rendered inside the filter panel (FR-003). Each change navigates
/// immediately via `context.go` — the panel itself holds no state.
class _WarehouseFiltersPanel extends ConsumerWidget {
  const _WarehouseFiltersPanel({required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = WarehouseFilter.fromQuery(query);
    final l10n = AppLocalizations.of(context)!;
    final facilityRepo = ref.read(facilityRepositoryProvider);

    // Cold-load resolution (data-model.md §4): a shared link carries only
    // the facility id, so its display name is resolved here rather than
    // shown blank.
    final resolvedFacilityName = filter.facilityId != null
        ? ref.watch(facilityDisplayNameProvider(filter.facilityId!)).valueOrNull
        : null;

    void goTo(ListQuery updated) =>
        context.go(updated.toUri(_warehousesPath).toString());

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CatalogEntityPicker<FacilityListItem>(
          key: const Key('warehouses_filter_facility'),
          label: l10n.facilityFieldLabel,
          displayStringForOption: (f) => f.name,
          optionsBuilder: (query) async {
            final result = await facilityRepo.list(
              search: query.isEmpty ? null : query,
            );
            return result.items;
          },
          onSelected: (f) => goTo(
            query
                .withFacet('facility', '${f.facilityId}')
                .copyWith(pageIndex: 0),
          ),
          initialDisplayText:
              resolvedFacilityName ?? filter.facilityId?.toString(),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.statusFilterLabel,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        EntityStatusFilterChips(
          filterKey: 'warehouses_filter_status',
          value: filter.status,
          onChanged: (status) => goTo(
            query.withFacet('status', status?.name).copyWith(pageIndex: 0),
          ),
        ),
      ],
    );
  }
}
