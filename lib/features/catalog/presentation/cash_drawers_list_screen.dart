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
import 'package:mbe_ui/features/catalog/domain/entities/cash_drawer.dart';
import 'package:mbe_ui/features/catalog/presentation/cash_drawers_list_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

const _cashDrawersPath = '/cash-drawers';

/// CashDrawers catalog list screen (FR-001, FR-002, FR-003, US2). Gated by
/// `can(SystemObject.cashDrawers, AccessRight.read)` in the router. Ships a
/// filter drawer (facility picker + status) since the list endpoint exposes
/// both facets, per constitution §VI.
///
/// [query] is decoded from the route by the router builder
/// (017-ui-consistency-filters FR-017) — the URL is this screen's only
/// source of view state; there is no local filter notifier.
class CashDrawersListScreen extends ConsumerWidget {
  const CashDrawersListScreen({super.key, required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = CashDrawerFilter.fromQuery(query);
    final pageAsync = ref.watch(cashDrawersListControllerProvider(filter));
    final access = ref.watch(accessControlProvider);
    final canCreate = access.can(SystemObject.cashDrawers, AccessRight.create);
    final canUpdate = access.can(SystemObject.cashDrawers, AccessRight.update);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: CatalogFilterBar(
            search: CatalogSearchBar(
              key: const Key('cash_drawers_search_field'),
              label: l10n.cashDrawersSearchLabel,
              searchTooltip: l10n.searchButtonTooltip,
              initialValue: filter.search,
              onSubmitted: (value) => context.go(
                query
                    .copyWith(search: value, pageIndex: 0)
                    .toUri(_cashDrawersPath)
                    .toString(),
              ),
            ),
            actions: [
              if (canCreate)
                FilledButton.icon(
                  key: const Key('new_cash_drawer_button'),
                  icon: Icon(CatalogAction.create.icon),
                  label: Text(l10n.newCashDrawerTooltip),
                  onPressed: () => context.push('/cash-drawers/new'),
                ),
            ],
            filters: [
              Badge.count(
                count: filter.activeFilterCount,
                isLabelVisible: filter.hasActiveFilters,
                child: IconButton.outlined(
                  key: const Key('cash_drawers_filter_button'),
                  icon: const Icon(Icons.tune),
                  tooltip: l10n.filtersTooltip,
                  onPressed: () => showCatalogFilterSheet(
                    context,
                    title: l10n.filtersButton,
                    clearAllLabel: l10n.clearAllFilters,
                    applyLabel: l10n.applyFilters,
                    onClearAll: () => context.go(_cashDrawersPath),
                    builder: (_) => CurrentListQueryBuilder(
                      builder: (context, query) =>
                          _CashDrawerFiltersPanel(query: query),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: CatalogListStateView<CashDrawer>(
            state: pageAsync,
            isFiltered: query.isFiltered,
            emptyMessage: l10n.noCashDrawersFound,
            createLabel: canCreate ? l10n.newCashDrawerTooltip : null,
            onCreate: canCreate
                ? () => context.push('/cash-drawers/new')
                : null,
            clearFiltersLabel: l10n.clearFiltersButton,
            onClearFilters: () => context.go(_cashDrawersPath),
            retryLabel: l10n.retryButton,
            onRetry: () =>
                ref.invalidate(cashDrawersListControllerProvider(filter)),
            onData: (page) => DataTableView<CashDrawer>(
              key: const Key('cash_drawers_table'),
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
                    .toUri(_cashDrawersPath)
                    .toString(),
              ),
              onRowTap: (w) =>
                  context.push('/cash-drawers/${w.cashDrawerId}?view=true'),
              rowActionsBuilder: (context, w) => buildCatalogRowActions(
                editTooltip: l10n.editActionTooltip,
                onEdit: canUpdate
                    ? () => context.push('/cash-drawers/${w.cashDrawerId}')
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The CashDrawers catalog's facet filters (facility picker + status),
/// rendered inside the filter panel (FR-003). Each change navigates
/// immediately via `context.go` — the panel itself holds no state.
class _CashDrawerFiltersPanel extends ConsumerWidget {
  const _CashDrawerFiltersPanel({required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = CashDrawerFilter.fromQuery(query);
    final l10n = AppLocalizations.of(context)!;
    final facilityRepo = ref.read(facilityRepositoryProvider);

    final resolvedFacilityName = filter.facilityId != null
        ? ref.watch(facilityDisplayNameProvider(filter.facilityId!)).valueOrNull
        : null;

    void goTo(ListQuery updated) =>
        context.go(updated.toUri(_cashDrawersPath).toString());

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CatalogEntityPicker<FacilityListItem>(
          key: const Key('cash_drawers_filter_facility'),
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
        Text(
          l10n.statusFilterLabel,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        EntityStatusFilterChips(
          filterKey: 'cash_drawers_filter_status',
          value: filter.status,
          onChanged: (status) => goTo(
            query.withFacet('status', status?.name).copyWith(pageIndex: 0),
          ),
        ),
      ],
    );
  }
}
