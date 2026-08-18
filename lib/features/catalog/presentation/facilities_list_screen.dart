import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_bar.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_sheet.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/core/widgets/catalog_search_bar.dart';
import 'package:mbe_ui/core/widgets/entity_status_controls.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/features/catalog/domain/entities/facility_list_item.dart';
import 'package:mbe_ui/features/catalog/presentation/facilities_list_controller.dart';
import 'package:mbe_ui/features/catalog/presentation/widgets/facility_card.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

const _facilitiesPath = '/facilities';

/// Facilities catalog screen (018-nested-facility-management). Replaces the
/// plain table with an expandable org-chart-style hierarchy — each facility
/// a card expanding into its own warehouses, points of sale and cash
/// drawers (FR-005–FR-011).
///
/// [query] is decoded from the route by the router builder, same as before
/// this feature — the URL remains the source of truth for search, status
/// and page (FR-016). Expansion state is view-local (FR-013) and lives in
/// this widget's [State], not the URL.
class FacilitiesListScreen extends ConsumerStatefulWidget {
  const FacilitiesListScreen({super.key, required this.query});

  final ListQuery query;

  @override
  ConsumerState<FacilitiesListScreen> createState() =>
      _FacilitiesListScreenState();
}

class _FacilitiesListScreenState extends ConsumerState<FacilitiesListScreen> {
  final Set<int> _expandedFacilityIds = {};

  void _toggle(int facilityId) {
    setState(() {
      if (!_expandedFacilityIds.remove(facilityId)) {
        _expandedFacilityIds.add(facilityId);
      }
    });
  }

  bool _allExpanded(List<FacilityListItem> facilities) =>
      facilities.isNotEmpty &&
      facilities.every((f) => _expandedFacilityIds.contains(f.facilityId));

  void _toggleAll(List<FacilityListItem> facilities) {
    setState(() {
      if (_allExpanded(facilities)) {
        _expandedFacilityIds.clear();
      } else {
        _expandedFacilityIds.addAll(facilities.map((f) => f.facilityId));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filter = FacilityFilter.fromQuery(widget.query);
    final pageAsync = ref.watch(facilitiesListControllerProvider(filter));
    final access = ref.watch(accessControlProvider);
    final canCreateFacility = access.can(
      SystemObject.facilities,
      AccessRight.create,
    );
    final canUpdateFacility = access.can(
      SystemObject.facilities,
      AccessRight.update,
    );
    final l10n = AppLocalizations.of(context)!;
    final isCompact = LayoutBreakpoints.isCompact(context);

    return Scaffold(
      floatingActionButton: isCompact && canCreateFacility
          ? FloatingActionButton.extended(
              key: const Key('new_facility_fab'),
              onPressed: () => context.push('/facilities/new'),
              icon: const Icon(Icons.add),
              label: Text(l10n.newFacilityTooltip),
            )
          : null,
      body: Column(
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
                  widget.query
                      .copyWith(search: value, pageIndex: 0)
                      .toUri(_facilitiesPath)
                      .toString(),
                ),
              ),
              actions: [
                _ExpandAllButton(
                  facilities: pageAsync.valueOrNull?.items ?? const [],
                  allExpanded: _allExpanded(
                    pageAsync.valueOrNull?.items ?? const [],
                  ),
                  onPressed: () =>
                      _toggleAll(pageAsync.valueOrNull?.items ?? const []),
                ),
                if (!isCompact && canCreateFacility)
                  FilledButton.icon(
                    key: const Key('new_facility_button'),
                    icon: const Icon(Icons.add),
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
              isFiltered: widget.query.isFiltered,
              emptyMessage: l10n.noFacilitiesFound,
              createLabel: canCreateFacility ? l10n.newFacilityTooltip : null,
              onCreate: canCreateFacility
                  ? () => context.push('/facilities/new')
                  : null,
              clearFiltersLabel: l10n.clearFiltersButton,
              onClearFilters: () => context.go(_facilitiesPath),
              retryLabel: l10n.retryButton,
              onRetry: () =>
                  ref.invalidate(facilitiesListControllerProvider(filter)),
              onData: (page) => Column(
                children: [
                  Expanded(
                    // Deliberately `SingleChildScrollView` + `Column`, not
                    // `ListView` (research §1). Even `ListView(children:
                    // [...])` renders through Flutter's sliver viewport,
                    // which only materializes elements within the visible
                    // area plus a small cache extent — a `ref.watch()` on an
                    // off-screen card simply never runs. That surfaced as a
                    // real bug during implementation: expanding one card
                    // grew it tall enough to push its neighbor out of the
                    // cache extent, and that neighbor's `FacilityCard`
                    // silently unmounted (found in a widget test, not by
                    // inspection). `Column` has no viewport concept at all —
                    // every child is a real `Element` from first build,
                    // which is what FR-017's "counts correct on first paint"
                    // actually requires. Safe because the list is
                    // hard-bounded at the facilities page size (20).
                    child: SingleChildScrollView(
                      key: const Key('facilities_card_list'),
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                      child: Column(
                        children: [
                          for (final facility in page.items) ...[
                            FacilityCard(
                              key: ValueKey(facility.facilityId),
                              facility: facility,
                              expanded: _expandedFacilityIds.contains(
                                facility.facilityId,
                              ),
                              onToggle: () => _toggle(facility.facilityId),
                              onView: () => context.push(
                                '/facilities/${facility.facilityId}?view=true',
                              ),
                              onEdit: canUpdateFacility
                                  ? () => context.push(
                                      '/facilities/${facility.facilityId}',
                                    )
                                  : null,
                              warehouseActions: _childActions(
                                context,
                                access,
                                facility.facilityId,
                                object: SystemObject.warehouses,
                                path: '/warehouses',
                              ),
                              pointSaleActions: _childActions(
                                context,
                                access,
                                facility.facilityId,
                                object: SystemObject.pointsOfSale,
                                path: '/points-of-sale',
                              ),
                              cashDrawerActions: _childActions(
                                context,
                                access,
                                facility.facilityId,
                                object: SystemObject.cashDrawers,
                                path: '/cash-drawers',
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ],
                      ),
                    ),
                  ),
                  _PaginationFooter(
                    page: page,
                    onPageChanged: (pageIndex) => context.go(
                      widget.query
                          .copyWith(pageIndex: pageIndex)
                          .toUri(_facilitiesPath)
                          .toString(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  FacilityChildActions _childActions(
    BuildContext context,
    AccessControlService access,
    int facilityId, {
    required SystemObject object,
    required String path,
  }) {
    final canUpdate = access.can(object, AccessRight.update);
    final canCreate = access.can(object, AccessRight.create);
    return FacilityChildActions(
      onView: (id) => context.push('$path/$id?view=true'),
      onEdit: canUpdate ? (id) => context.push('$path/$id') : null,
      onCreate: canCreate
          ? () => context.push('$path/new?facility=$facilityId')
          : null,
    );
  }
}

class _ExpandAllButton extends StatelessWidget {
  const _ExpandAllButton({
    required this.facilities,
    required this.allExpanded,
    required this.onPressed,
  });

  final List<FacilityListItem> facilities;
  final bool allExpanded;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return OutlinedButton.icon(
      key: const Key('facilities_expand_all'),
      onPressed: facilities.isEmpty ? null : onPressed,
      icon: Icon(allExpanded ? Icons.unfold_less : Icons.unfold_more),
      label: Text(
        allExpanded ? l10n.facilitiesCollapseAll : l10n.facilitiesExpandAll,
      ),
    );
  }
}

/// A minimal pagination footer for the card list — `DataTableView`'s
/// pagination is `data_table_2`-specific (`PaginatedDataTable2`) and cannot
/// drive a non-table list, so this screen needs its own (FR-005, mandatory
/// pagination retained per constitution §VI).
class _PaginationFooter extends StatelessWidget {
  const _PaginationFooter({required this.page, required this.onPageChanged});

  final CatalogPage<FacilityListItem> page;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    if (page.total == 0) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    final start = page.pageIndex * page.pageSize + 1;
    final end = start + page.items.length - 1;
    final lastPageIndex = (page.total - 1) ~/ page.pageSize;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            l10n.facilitiesPaginationSummary(start, end, page.total),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          IconButton(
            key: const Key('facilities_previous_page'),
            icon: const Icon(Icons.chevron_left),
            tooltip: l10n.previousPageTooltip,
            onPressed: page.pageIndex > 0
                ? () => onPageChanged(page.pageIndex - 1)
                : null,
          ),
          IconButton(
            key: const Key('facilities_next_page'),
            icon: const Icon(Icons.chevron_right),
            tooltip: l10n.nextPageTooltip,
            onPressed: page.pageIndex < lastPageIndex
                ? () => onPageChanged(page.pageIndex + 1)
                : null,
          ),
        ],
      ),
    );
  }
}

/// The Facilities catalog's status-only facet filter (unchanged from before
/// this feature). Each change navigates immediately via `context.go` — the
/// panel itself holds no state.
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
      spacing: 8,
      children: [
        Text(
          l10n.statusFilterLabel,
          style: Theme.of(context).textTheme.titleSmall,
        ),
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
