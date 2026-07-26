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
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/facility_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/point_sale.dart';
import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';
import 'package:mbe_ui/features/catalog/presentation/points_of_sale_list_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

const _pointsOfSalePath = '/points-of-sale';

/// Points of Sale catalog list screen (FR-001, FR-002, FR-003, US3). Gated
/// by `can(SystemObject.pointsOfSale, AccessRight.read)` in the router.
/// Ships a filter drawer (facility + warehouse pickers + status) since the
/// list endpoint exposes all three facets, per constitution §VI.
///
/// [query] is decoded from the route by the router builder
/// (017-ui-consistency-filters FR-017) — the URL is this screen's only
/// source of view state; there is no local filter notifier.
class PointsOfSaleListScreen extends ConsumerWidget {
  const PointsOfSaleListScreen({super.key, required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = PointSaleFilter.fromQuery(query);
    final pageAsync = ref.watch(pointsOfSaleListControllerProvider(filter));
    final access = ref.watch(accessControlProvider);
    final canCreate = access.can(SystemObject.pointsOfSale, AccessRight.create);
    final canUpdate = access.can(SystemObject.pointsOfSale, AccessRight.update);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: CatalogFilterBar(
            search: CatalogSearchBar(
              key: const Key('points_of_sale_search_field'),
              label: l10n.pointsOfSaleSearchLabel,
              searchTooltip: l10n.searchButtonTooltip,
              initialValue: filter.search,
              onSubmitted: (value) => context.go(
                query
                    .copyWith(search: value, pageIndex: 0)
                    .toUri(_pointsOfSalePath)
                    .toString(),
              ),
            ),
            actions: [
              if (canCreate)
                FilledButton.icon(
                  key: const Key('new_point_sale_button'),
                  icon: Icon(CatalogAction.create.icon),
                  label: Text(l10n.newPointSaleTooltip),
                  onPressed: () => context.push('/points-of-sale/new'),
                ),
            ],
            filters: [
              Badge.count(
                count: filter.activeFilterCount,
                isLabelVisible: filter.hasActiveFilters,
                child: IconButton.outlined(
                  key: const Key('points_of_sale_filter_button'),
                  icon: const Icon(Icons.tune),
                  tooltip: l10n.filtersTooltip,
                  onPressed: () => showCatalogFilterSheet(
                    context,
                    title: l10n.filtersButton,
                    clearAllLabel: l10n.clearAllFilters,
                    applyLabel: l10n.applyFilters,
                    onClearAll: () => context.go(_pointsOfSalePath),
                    builder: (_) => CurrentListQueryBuilder(
                      builder: (context, query) =>
                          _PointSaleFiltersPanel(query: query),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: CatalogListStateView<PointSale>(
            state: pageAsync,
            isFiltered: query.isFiltered,
            emptyMessage: l10n.noPointsOfSaleFound,
            createLabel: canCreate ? l10n.newPointSaleTooltip : null,
            onCreate: canCreate
                ? () => context.push('/points-of-sale/new')
                : null,
            clearFiltersLabel: l10n.clearFiltersButton,
            onClearFilters: () => context.go(_pointsOfSalePath),
            retryLabel: l10n.retryButton,
            onRetry: () =>
                ref.invalidate(pointsOfSaleListControllerProvider(filter)),
            onData: (page) => DataTableView<PointSale>(
              key: const Key('points_of_sale_table'),
              columns: [
                DataTableColumn.text(
                  label: l10n.columnFacility,
                  text: (p) => p.facilityDisplayName(l10n.unknownFacilityLabel),
                  size: ColumnSize.M,
                ),
                DataTableColumn.text(
                  label: l10n.columnCode,
                  text: (p) => p.code,
                  size: ColumnSize.S,
                ),
                DataTableColumn.text(
                  label: l10n.columnName,
                  text: (p) => p.name,
                  size: ColumnSize.L,
                ),
                DataTableColumn.text(
                  label: l10n.columnWarehouse,
                  text: (p) =>
                      p.warehouseDisplayName(l10n.unknownWarehouseLabel),
                  size: ColumnSize.M,
                ),
                DataTableColumn(
                  label: l10n.columnStatus,
                  fixedWidth: 130,
                  cellBuilder: (context, p) =>
                      EntityStatusCell(status: p.status),
                ),
              ],
              rows: page.items,
              pagination: page,
              onPageChanged: (pageIndex) => context.go(
                query
                    .copyWith(pageIndex: pageIndex)
                    .toUri(_pointsOfSalePath)
                    .toString(),
              ),
              onRowTap: (p) =>
                  context.push('/points-of-sale/${p.pointSaleId}?view=true'),
              rowActionsBuilder: (context, p) => buildCatalogRowActions(
                editTooltip: l10n.editActionTooltip,
                onEdit: canUpdate
                    ? () => context.push('/points-of-sale/${p.pointSaleId}')
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The Points of Sale catalog's facet filters (facility picker, warehouse
/// picker, status), rendered inside the filter panel (FR-003). Unlike the
/// facility-scoped warehouse *field* on the create/edit form (FR-022), the
/// warehouse *filter* here is intentionally unscoped — a user narrowing the
/// list by warehouse hasn't necessarily picked a facility first. Each
/// change navigates immediately via `context.go` — the panel itself holds
/// no state.
class _PointSaleFiltersPanel extends ConsumerWidget {
  const _PointSaleFiltersPanel({required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = PointSaleFilter.fromQuery(query);
    final l10n = AppLocalizations.of(context)!;
    final facilityRepo = ref.read(facilityRepositoryProvider);
    final warehouseRepo = ref.read(warehouseRepositoryProvider);

    final resolvedFacilityName = filter.facilityId != null
        ? ref.watch(facilityDisplayNameProvider(filter.facilityId!)).valueOrNull
        : null;
    final resolvedWarehouseName = filter.warehouseId != null
        ? ref
              .watch(warehouseDisplayNameProvider(filter.warehouseId!))
              .valueOrNull
        : null;

    void goTo(ListQuery updated) =>
        context.go(updated.toUri(_pointsOfSalePath).toString());

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CatalogEntityPicker<FacilityListItem>(
          key: const Key('points_of_sale_filter_facility'),
          label: l10n.facilityFieldLabel,
          displayStringForOption: (f) => f.name,
          optionsBuilder: (searchQuery) async {
            final result = await facilityRepo.list(
              search: searchQuery.isEmpty ? null : searchQuery,
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
        CatalogEntityPicker<Warehouse>(
          key: const Key('points_of_sale_filter_warehouse'),
          label: l10n.warehouseFieldLabel,
          displayStringForOption: (w) => w.name,
          optionsBuilder: (searchQuery) async {
            final result = await warehouseRepo.list(
              search: searchQuery.isEmpty ? null : searchQuery,
            );
            return result.items;
          },
          onSelected: (w) => goTo(
            query
                .withFacet('warehouse', '${w.warehouseId}')
                .copyWith(pageIndex: 0),
          ),
          initialDisplayText:
              resolvedWarehouseName ?? filter.warehouseId?.toString(),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.statusFilterLabel,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        EntityStatusFilterChips(
          filterKey: 'points_of_sale_filter_status',
          value: filter.status,
          onChanged: (status) => goTo(
            query.withFacet('status', status?.name).copyWith(pageIndex: 0),
          ),
        ),
      ],
    );
  }
}
