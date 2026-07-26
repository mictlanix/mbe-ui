import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/domain/facility_type.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/widgets/catalog_action_icons.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_bar.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_sheet.dart';
import 'package:mbe_ui/core/widgets/catalog_search_bar.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/entity_status_controls.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/features/catalog/domain/entities/facility_list_item.dart';
import 'package:mbe_ui/features/catalog/presentation/facilities_list_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

const _facilitiesPath = '/facilities';

/// Facilities catalog list screen (FR-001, FR-002, FR-003, FR-028, US4).
/// Gated by `can(SystemObject.facilities, AccessRight.read)` in the router.
/// Ships a filter drawer with a status facet only — the facilities list
/// endpoint exposes no `facility` facet on itself (constitution §VI still
/// requires the drawer since a real facet exists).
///
/// [query] is decoded from the route by the router builder
/// (017-ui-consistency-filters FR-017) — the URL is this screen's only
/// source of view state; there is no local filter notifier.
class FacilitiesListScreen extends ConsumerWidget {
  const FacilitiesListScreen({super.key, required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = FacilityFilter.fromQuery(query);
    final pageAsync = ref.watch(facilitiesListControllerProvider(filter));
    final access = ref.watch(accessControlProvider);
    final canCreate = access.can(SystemObject.facilities, AccessRight.create);
    final canUpdate = access.can(SystemObject.facilities, AccessRight.update);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: CatalogFilterBar(
            search: CatalogSearchBar(
              key: const Key('facilities_search_field'),
              label: l10n.facilitiesSearchLabel,
              searchTooltip: l10n.searchButtonTooltip,
              initialValue: filter.search,
              onSubmitted: (value) => context.go(
                query
                    .copyWith(search: value, pageIndex: 0)
                    .toUri(_facilitiesPath)
                    .toString(),
              ),
            ),
            actions: [
              if (canCreate)
                FilledButton.icon(
                  key: const Key('new_facility_button'),
                  icon: Icon(CatalogAction.create.icon),
                  label: Text(l10n.newFacilityTooltip),
                  onPressed: () => context.push('/facilities/new'),
                ),
            ],
            filters: [
              Badge.count(
                count: filter.activeFilterCount,
                isLabelVisible: filter.hasActiveFilters,
                child: IconButton.outlined(
                  key: const Key('facilities_filter_button'),
                  icon: const Icon(Icons.tune),
                  tooltip: l10n.filtersTooltip,
                  onPressed: () => showCatalogFilterSheet(
                    context,
                    title: l10n.filtersButton,
                    clearAllLabel: l10n.clearAllFilters,
                    applyLabel: l10n.applyFilters,
                    onClearAll: () => context.go(_facilitiesPath),
                    builder: (_) => CurrentListQueryBuilder(
                      builder: (context, query) =>
                          _FacilityFiltersPanel(query: query),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: CatalogListStateView<FacilityListItem>(
            state: pageAsync,
            isFiltered: query.isFiltered,
            emptyMessage: l10n.noFacilitiesFound,
            createLabel: canCreate ? l10n.newFacilityTooltip : null,
            onCreate: canCreate ? () => context.push('/facilities/new') : null,
            clearFiltersLabel: l10n.clearFiltersButton,
            onClearFilters: () => context.go(_facilitiesPath),
            retryLabel: l10n.retryButton,
            onRetry: () =>
                ref.invalidate(facilitiesListControllerProvider(filter)),
            onData: (page) => DataTableView<FacilityListItem>(
              key: const Key('facilities_table'),
              columns: [
                DataTableColumn.text(
                  label: l10n.columnCode,
                  text: (f) => f.code,
                  size: ColumnSize.S,
                ),
                DataTableColumn.text(
                  label: l10n.columnName,
                  text: (f) => f.name,
                  size: ColumnSize.L,
                ),
                DataTableColumn.text(
                  label: l10n.columnType,
                  text: (f) => switch (f.type) {
                    FacilityType.store => l10n.facilityTypeStore,
                    FacilityType.productionSite =>
                      l10n.facilityTypeProductionSite,
                  },
                  size: ColumnSize.M,
                ),
                DataTableColumn(
                  label: l10n.columnStatus,
                  fixedWidth: 130,
                  cellBuilder: (context, f) =>
                      EntityStatusCell(status: f.status),
                ),
              ],
              rows: page.items,
              pagination: page,
              onPageChanged: (pageIndex) => context.go(
                query
                    .copyWith(pageIndex: pageIndex)
                    .toUri(_facilitiesPath)
                    .toString(),
              ),
              onRowTap: (f) =>
                  context.push('/facilities/${f.facilityId}?view=true'),
              rowActionsBuilder: (context, f) => buildCatalogRowActions(
                editTooltip: l10n.editActionTooltip,
                onEdit: canUpdate
                    ? () => context.push('/facilities/${f.facilityId}')
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The Facilities catalog's status-only facet filter (FR-003, FR-028). Each
/// change navigates immediately via `context.go` — the panel itself holds
/// no state.
class _FacilityFiltersPanel extends ConsumerWidget {
  const _FacilityFiltersPanel({required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = FacilityFilter.fromQuery(query);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.statusFilterLabel,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        EntityStatusFilterChips(
          filterKey: 'facilities_filter_status',
          value: filter.status,
          onChanged: (status) => context.go(
            query
                .withFacet('status', status?.name)
                .copyWith(pageIndex: 0)
                .toUri(_facilitiesPath)
                .toString(),
          ),
        ),
      ],
    );
  }
}
