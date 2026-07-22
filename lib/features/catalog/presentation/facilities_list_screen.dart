import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/domain/facility_type.dart';
import 'package:mbe_ui/core/widgets/catalog_action_icons.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_bar.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_sheet.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/core/widgets/catalog_search_bar.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/entity_status_controls.dart';
import 'package:mbe_ui/features/catalog/domain/entities/facility_list_item.dart';
import 'package:mbe_ui/features/catalog/presentation/facilities_list_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Facilities catalog list screen (FR-001, FR-002, FR-003, FR-028, US4).
/// Gated by `can(SystemObject.facilities, AccessRight.read)` in the router.
/// Ships a filter drawer with a status facet only — the facilities list
/// endpoint exposes no `facility` facet on itself (constitution §VI still
/// requires the drawer since a real facet exists).
class FacilitiesListScreen extends ConsumerWidget {
  const FacilitiesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageAsync = ref.watch(facilitiesListControllerProvider);
    final filter = ref.watch(facilityFilterControllerProvider);
    final filterController = ref.read(
      facilityFilterControllerProvider.notifier,
    );
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
              onSubmitted: filterController.searchChanged,
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
                    onClearAll: filterController.reset,
                    builder: (_) => const _FacilityFiltersPanel(),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: pageAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(l10n.facilitiesLoadError(e))),
            data: (CatalogPage<FacilityListItem> page) => page.items.isEmpty
                ? Center(child: Text(l10n.noFacilitiesFound))
                : DataTableView<FacilityListItem>(
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
                    onPageChanged: (pageIndex) => ref
                        .read(facilitiesListControllerProvider.notifier)
                        .goToPage(pageIndex),
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

/// The Facilities catalog's status-only facet filter (FR-003, FR-028).
class _FacilityFiltersPanel extends ConsumerWidget {
  const _FacilityFiltersPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(facilityFilterControllerProvider);
    final filterController = ref.read(
      facilityFilterControllerProvider.notifier,
    );
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
          onChanged: filterController.statusChanged,
        ),
      ],
    );
  }
}
