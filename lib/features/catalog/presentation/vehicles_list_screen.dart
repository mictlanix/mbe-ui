import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/widgets/catalog_action_icons.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_bar.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_sheet.dart';
import 'package:mbe_ui/core/widgets/catalog_search_bar.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/entity_status_controls.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/features/catalog/domain/entities/vehicle.dart';
import 'package:mbe_ui/features/catalog/presentation/vehicles_list_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

const _vehiclesPath = '/vehicles';

/// Vehicles catalog list screen (FR-001, FR-002, FR-009, US2). Gated by
/// `can(SystemObject.vehicle, AccessRight.read)` in the router. Ships a
/// status filter drawer since the list endpoint exposes a `status` facet
/// (constitution §VI).
///
/// [query] is decoded from the route by the router builder
/// (017-ui-consistency-filters FR-017) — the URL is this screen's only
/// source of view state; there is no local filter notifier.
class VehiclesListScreen extends ConsumerWidget {
  const VehiclesListScreen({super.key, required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = VehicleFilter.fromQuery(query);
    final pageAsync = ref.watch(vehiclesListControllerProvider(filter));
    final access = ref.watch(accessControlProvider);
    final canCreate = access.can(SystemObject.vehicle, AccessRight.create);
    final canUpdate = access.can(SystemObject.vehicle, AccessRight.update);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: CatalogFilterBar(
            search: CatalogSearchBar(
              key: const Key('vehicles_search_field'),
              label: l10n.vehiclesSearchLabel,
              searchTooltip: l10n.searchButtonTooltip,
              initialValue: filter.search,
              onSubmitted: (value) => context.go(
                query
                    .copyWith(search: value, pageIndex: 0)
                    .toUri(_vehiclesPath)
                    .toString(),
              ),
            ),
            actions: [
              if (canCreate)
                FilledButton.icon(
                  key: const Key('new_vehicle_button'),
                  icon: Icon(CatalogAction.create.icon),
                  label: Text(l10n.newVehicleTooltip),
                  onPressed: () => context.push('/vehicles/new'),
                ),
            ],
            filters: [
              Badge.count(
                count: filter.activeFilterCount,
                isLabelVisible: filter.hasActiveFilters,
                child: IconButton.outlined(
                  key: const Key('vehicles_filter_button'),
                  icon: const Icon(Icons.tune),
                  tooltip: l10n.filtersTooltip,
                  onPressed: () => showCatalogFilterSheet(
                    context,
                    title: l10n.filtersButton,
                    clearAllLabel: l10n.clearAllFilters,
                    applyLabel: l10n.applyFilters,
                    onClearAll: () => context.go(_vehiclesPath),
                    builder: (_) => CurrentListQueryBuilder(
                      builder: (context, query) =>
                          _VehicleFiltersPanel(query: query),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: CatalogListStateView<Vehicle>(
            state: pageAsync,
            isFiltered: query.isFiltered,
            emptyMessage: l10n.noVehiclesFound,
            createLabel: canCreate ? l10n.newVehicleTooltip : null,
            onCreate: canCreate ? () => context.push('/vehicles/new') : null,
            clearFiltersLabel: l10n.clearFiltersButton,
            onClearFilters: () => context.go(_vehiclesPath),
            retryLabel: l10n.retryButton,
            onRetry: () =>
                ref.invalidate(vehiclesListControllerProvider(filter)),
            onData: (page) => DataTableView<Vehicle>(
              key: const Key('vehicles_table'),
              columns: [
                DataTableColumn.text(
                  label: l10n.licensePlateLabel,
                  text: (v) => v.licensePlate,
                  size: ColumnSize.M,
                ),
                DataTableColumn.text(
                  label: l10n.nameLabel,
                  text: (v) => v.name,
                  size: ColumnSize.L,
                ),
                DataTableColumn.text(
                  label: l10n.nicknameLabel,
                  text: (v) => v.nickname,
                  size: ColumnSize.M,
                ),
                DataTableColumn(
                  label: l10n.columnStatus,
                  fixedWidth: 130,
                  cellBuilder: (context, v) =>
                      EntityStatusCell(status: v.status),
                ),
              ],
              rows: page.items,
              pagination: page,
              onPageChanged: (pageIndex) => context.go(
                query
                    .copyWith(pageIndex: pageIndex)
                    .toUri(_vehiclesPath)
                    .toString(),
              ),
              onRowTap: (v) =>
                  context.push('/vehicles/${v.vehicleId}?view=true'),
              rowActionsBuilder: (context, v) => buildCatalogRowActions(
                editTooltip: l10n.editActionTooltip,
                onEdit: canUpdate
                    ? () => context.push('/vehicles/${v.vehicleId}')
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The Vehicles catalog's status facet, rendered inside the filter panel
/// opened from the Filters button (FR-009). A [ConsumerWidget] so the
/// controls stay reactive as the URL changes while the sheet — which lives
/// on its own navigator route — is open. Each change navigates immediately
/// via `context.go`; the panel itself holds no state.
class _VehicleFiltersPanel extends ConsumerWidget {
  const _VehicleFiltersPanel({required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = VehicleFilter.fromQuery(query);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(
          l10n.statusFilterLabel,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        EntityStatusFilterChips(
          filterKey: 'vehicles_filter_status',
          value: filter.status,
          onChanged: (status) => context.go(
            query
                .withFacet('status', status?.name)
                .copyWith(pageIndex: 0)
                .toUri(_vehiclesPath)
                .toString(),
          ),
        ),
      ],
    );
  }
}
