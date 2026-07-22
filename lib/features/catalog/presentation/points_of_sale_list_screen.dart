import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/widgets/catalog_action_icons.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_bar.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_sheet.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/core/widgets/catalog_search_bar.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/entity_status_controls.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/facility_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/point_sale.dart';
import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';
import 'package:mbe_ui/features/catalog/presentation/points_of_sale_list_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Points of Sale catalog list screen (FR-001, FR-002, FR-003, US3). Gated
/// by `can(SystemObject.pointsOfSale, AccessRight.read)` in the router.
/// Ships a filter drawer (facility + warehouse pickers + status) since the
/// list endpoint exposes all three facets, per constitution §VI.
class PointsOfSaleListScreen extends ConsumerWidget {
  const PointsOfSaleListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageAsync = ref.watch(pointsOfSaleListControllerProvider);
    final filter = ref.watch(pointSaleFilterControllerProvider);
    final filterController = ref.read(
      pointSaleFilterControllerProvider.notifier,
    );
    final access = ref.watch(accessControlProvider);
    final canCreate = access.can(
      SystemObject.pointsOfSale,
      AccessRight.create,
    );
    final canUpdate = access.can(
      SystemObject.pointsOfSale,
      AccessRight.update,
    );
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
              onSubmitted: filterController.searchChanged,
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
                    onClearAll: filterController.reset,
                    builder: (_) => const _PointSaleFiltersPanel(),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: pageAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) =>
                Center(child: Text(l10n.pointsOfSaleLoadError(e))),
            data: (CatalogPage<PointSale> page) => page.items.isEmpty
                ? Center(child: Text(l10n.noPointsOfSaleFound))
                : DataTableView<PointSale>(
                    key: const Key('points_of_sale_table'),
                    columns: [
                      DataTableColumn.text(
                        label: l10n.columnFacility,
                        text: (p) =>
                            p.facilityDisplayName(l10n.unknownFacilityLabel),
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
                    onPageChanged: (pageIndex) => ref
                        .read(pointsOfSaleListControllerProvider.notifier)
                        .goToPage(pageIndex),
                    onRowTap: (p) => context.push(
                      '/points-of-sale/${p.pointSaleId}?view=true',
                    ),
                    rowActionsBuilder: (context, p) => buildCatalogRowActions(
                      editTooltip: l10n.editActionTooltip,
                      onEdit: canUpdate
                          ? () =>
                                context.push('/points-of-sale/${p.pointSaleId}')
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
/// list by warehouse hasn't necessarily picked a facility first.
class _PointSaleFiltersPanel extends ConsumerWidget {
  const _PointSaleFiltersPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(pointSaleFilterControllerProvider);
    final filterController = ref.read(
      pointSaleFilterControllerProvider.notifier,
    );
    final l10n = AppLocalizations.of(context)!;
    final facilityRepo = ref.read(facilityRepositoryProvider);
    final warehouseRepo = ref.read(warehouseRepositoryProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CatalogEntityPicker<FacilityListItem>(
          key: const Key('points_of_sale_filter_facility'),
          label: l10n.facilityFieldLabel,
          displayStringForOption: (f) => f.name,
          optionsBuilder: (query) async {
            final result = await facilityRepo.list(
              search: query.isEmpty ? null : query,
            );
            return result.items;
          },
          onSelected: (f) =>
              filterController.facilitySelected(f.facilityId, f.name),
          initialDisplayText: filter.facilityDisplayText,
        ),
        const SizedBox(height: 12),
        CatalogEntityPicker<Warehouse>(
          key: const Key('points_of_sale_filter_warehouse'),
          label: l10n.warehouseFieldLabel,
          displayStringForOption: (w) => w.name,
          optionsBuilder: (query) async {
            final result = await warehouseRepo.list(
              search: query.isEmpty ? null : query,
            );
            return result.items;
          },
          onSelected: (w) =>
              filterController.warehouseSelected(w.warehouseId, w.name),
          initialDisplayText: filter.warehouseDisplayText,
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
          onChanged: filterController.statusChanged,
        ),
      ],
    );
  }
}
